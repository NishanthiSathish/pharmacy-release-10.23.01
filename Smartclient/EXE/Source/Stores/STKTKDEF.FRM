VERSION 5.00
Begin VB.Form StockTakeDefaults 
   Appearance      =   0  'Flat
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Stock Take Settings"
   ClientHeight    =   8100
   ClientLeft      =   1095
   ClientTop       =   960
   ClientWidth     =   5535
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
   Icon            =   "STKTKDEF.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8100
   ScaleWidth      =   5535
   Begin VB.TextBox txtMethod 
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
      Height          =   300
      Index           =   4
      Left            =   2145
      MaxLength       =   20
      TabIndex        =   8
      Top             =   1320
      Visible         =   0   'False
      Width           =   1020
   End
   Begin VB.OptionButton optStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  by &Single Product"
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
      Height          =   240
      Index           =   4
      Left            =   360
      TabIndex        =   5
      Top             =   1350
      Width           =   2220
   End
   Begin VB.CheckBox chkStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  &Closed Stock Take  (Stock level hidden)"
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
      Height          =   360
      Index           =   0
      Left            =   990
      TabIndex        =   11
      Top             =   3975
      Width           =   3500
   End
   Begin VB.CheckBox chkStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  Include Items Not on Live Stock Control"
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
      Height          =   360
      Index           =   3
      Left            =   990
      TabIndex        =   14
      Top             =   5055
      Width           =   3500
   End
   Begin VB.CheckBox chkStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  Include Not in Use Items"
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
      Height          =   360
      Index           =   2
      Left            =   990
      TabIndex        =   13
      Top             =   4695
      Width           =   3500
   End
   Begin VB.CheckBox chkStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  Include Non-Stock Items"
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
      Height          =   360
      Index           =   1
      Left            =   990
      TabIndex        =   12
      Top             =   4320
      Width           =   3500
   End
   Begin VB.TextBox txtMethod 
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
      Height          =   300
      Index           =   1
      Left            =   2145
      TabIndex        =   6
      Top             =   600
      Visible         =   0   'False
      Width           =   1020
   End
   Begin VB.TextBox txtMethod 
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
      Height          =   300
      Index           =   3
      Left            =   2145
      MaxLength       =   20
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   1680
      Visible         =   0   'False
      Width           =   1020
   End
   Begin VB.TextBox txtMethod 
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
      Height          =   300
      Index           =   2
      Left            =   2145
      MaxLength       =   100
      TabIndex        =   7
      Top             =   960
      Visible         =   0   'False
      Width           =   3015
   End
   Begin VB.OptionButton optStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  &Random Selection"
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
      Height          =   240
      Index           =   1
      Left            =   360
      TabIndex        =   3
      Top             =   630
      Value           =   -1  'True
      Width           =   2220
   End
   Begin VB.OptionButton optStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  by &Location Code"
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
      Height          =   240
      Index           =   2
      Left            =   360
      TabIndex        =   4
      Top             =   990
      Width           =   2220
   End
   Begin VB.OptionButton optStockTake 
      Appearance      =   0  'Flat
      Caption         =   "  by &BNF Group"
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
      Height          =   240
      Index           =   3
      Left            =   375
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   1710
      Visible         =   0   'False
      Width           =   2220
   End
   Begin VB.TextBox txtMaxItems 
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
      Height          =   300
      Left            =   4140
      MaxLength       =   6
      TabIndex        =   10
      Top             =   3405
      Width           =   780
   End
   Begin VB.CommandButton cmdReview 
      Appearance      =   0  'Flat
      Caption         =   "&Preview"
      Height          =   450
      Left            =   210
      TabIndex        =   15
      Top             =   5625
      Width           =   1050
   End
   Begin VB.CommandButton cmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      Height          =   450
      Left            =   1305
      TabIndex        =   18
      Top             =   7500
      Width           =   1050
   End
   Begin VB.CommandButton cmdCancel 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   450
      Left            =   3120
      TabIndex        =   19
      Top             =   7515
      Width           =   1050
   End
   Begin VB.Label lblDetails 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1065
      Left            =   360
      TabIndex        =   21
      Top             =   1980
      Width           =   4995
   End
   Begin VB.Label lblDescription 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1065
      Left            =   360
      TabIndex        =   20
      Top             =   1965
      Width           =   4995
   End
   Begin VB.Image CmdDropDown 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   315
      Left            =   3135
      Picture         =   "STKTKDEF.frx":030A
      Top             =   1320
      Visible         =   0   'False
      Width           =   285
   End
   Begin VB.Label lblReview 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
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
      Height          =   1080
      Left            =   225
      TabIndex        =   17
      Top             =   6270
      Width           =   5100
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "&Maximum number of items for this StockTake:"
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
      Height          =   315
      Left            =   630
      TabIndex        =   9
      Top             =   3435
      Width           =   3525
   End
   Begin VB.Label Label3 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Select Stock Take Method and Number of Items to Include:"
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
      Height          =   285
      Left            =   180
      TabIndex        =   2
      Top             =   225
      Width           =   5145
   End
   Begin VB.Label Label4 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Count number of items which will be in the Stock Take"
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
      Height          =   210
      Left            =   630
      TabIndex        =   16
      Top             =   3675
      Visible         =   0   'False
      Width           =   4020
   End
End
Attribute VB_Name = "StockTakeDefaults"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------
'        Set Stock Take Defaults
'
'14Jan98 CKJ Written
'23Jan13 CKJ Added support for multiple locations, comma separated with * wildcard  TFS 53365
'
'-----------------------------------------------------------------

DefInt A-Z
Option Explicit

Private Sub cmdCancel_Click()

   Me.Hide

End Sub

Private Sub CmdDropDown_Click()
   
   txtMethod_KeyDown 4, 13, 0

End Sub

Private Sub cmdOK_Click()

   Me.Tag = "1"
   Me.Hide

End Sub

Private Sub cmdReview_Click()

Dim Method%, Includes$, count%

   Method = 0
   Includes$ = ""
   For count = 1 To 4 '3
      If optStockTake(count).value Then Method = count
      If count < 4 Then Includes$ = Includes$ & Iff(chkStockTake(count), "1", "0")
   Next
   lblReview.Caption = ReviewStockTakeSettings(Method, (txtMethod(Method).Text), Val(txtMaxItems.Text), Includes$)

End Sub

Private Sub Form_Activate()

   Me.Tag = ""

End Sub

Private Sub Form_Load()
   
   SetChrome Me
  
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then
         Cancel = True
         Me.Hide
      End If

End Sub

Private Sub optStockTake_Click(Index As Integer)

Dim showItem As Boolean

   showItem = optStockTake(2).value ''TrueFalse((optStockTake(2).Value))
   txtMethod(2).Visible = showItem
   txtMethod(2).Enabled = showItem

   showItem = optStockTake(3).value '' TrueFalse((optStockTake(3).Value))
   txtMethod(3).Visible = showItem
   txtMethod(3).Enabled = showItem
   
   showItem = optStockTake(4).value '' TrueFalse((optStockTake(3).Value))
   txtMethod(4).Visible = showItem
   txtMethod(4).Enabled = showItem
   'lblDescription.Visible = showItem    '20Apr09 TH (F0051041)'17Jan13 CKJ removed
   lblDetails.Visible = showItem    '20Apr09 TH (F0051041)
   CmdDropDown.Visible = showItem
   CmdDropDown.Enabled = showItem
   
   '17Jan13 CKJ added block
   If Index = 2 Then
      lblDescription.Caption = "Enter one or more location codes separated by commas" & crlf _
         & "Each code can include * as a wildcard, for example" & crlf _
         & "      DS1,DS2*,CD*,*BL" & crlf _
         & "Note that only the primary stock location is used."
   Else
      lblDescription.Caption = ""
   End If
      
End Sub

Private Sub txtMethod_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)

Dim lngFound As Long
Dim strNSVCode As String
Dim intFound As Integer
Dim strDescription As String
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim strDate As String

k.escd = False
Select Case Index
   Case 4
      If KeyCode = 13 Then
         strNSVCode = Trim$(txtMethod(4).Text)
         If Trim$(strNSVCode) = "" Then EnterDrug strNSVCode, "Enter Item"
         If Not k.escd Then
            findrdrug strNSVCode, True, d, False, intFound, False, False, False
            If intFound = 0 Then                                     '   "
               k.escd = True
               lblDetails.Caption = ""
            Else
               'Run checks to see how this is place vis-a-vis other stock takes
               singleItemChecks
            End If
         End If
      Else
         If Len(Trim$(txtMethod(4).Text)) <> 7 Then
            lblDescription.Caption = ""
            lblDetails.Caption = ""
         Else
            d.SisCode = Trim$(txtMethod(4).Text)
            getdrug d, 0, lngFound, False
            If lngFound > 0 Then
               singleItemChecks
            Else
               lblDescription.Caption = ""
               lblDetails.Caption = ""
            End If
         End If
      End If
   End Select
End Sub

Private Sub singleItemChecks()

Dim strDescription As String
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim strDate As String
Dim strAns As String

   strDescription = d.DrugDescription ' strDescription = GetStoresDescription()  XN 4Jun15 98073 New local stores description
   plingparse strDescription, "!"

   If Val(d.stocktakestatus) = 1 Then
      'This item should exist on an existing stock take - try and find it and report the stocktake to the user
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLinebyNSVCODE", strParams)
      If rsStockTake.RecordCount > 0 Then
         rsStockTake.MoveFirst
         popmessagecr "!", strDescription & crlf & crlf & "This item is already on stock take : " & RtrimGetField(rsStockTake!StockTakeName) & crlf & crlf & _
         "This item cannot be selected until authorised from this stock take."
      Else
         popmessagecr "!", strDescription & crlf & crlf & "This item's status suggests it is already on a stock take, but no existing stock take with this item can be found." & crlf & crlf & _
         "The drug file may need resetting before this item is available for further stock takes"
      End If
      rsStockTake.Close
      Set rsStockTake = Nothing
      k.escd = True
      lblDescription.Caption = ""
      lblDetails.Caption = ""
   ElseIf Val(d.stocktakestatus) = 2 Then
      setinput 0, k
      k.escd = False
      parsedate d.laststocktakedate, strDate, "dd mmm yyyy", 0
      Confirm "", strDescription & crlf & crlf & "This item's last stock take was on " & strDate & ". If you continue then this will reset the status for this single item" & crlf & crlf & "OK to proceed", strAns, k
      If strAns = "Y" And Not k.escd Then
         getdrug d, d.productstockID, 0, True
         d.stocktakestatus = "0"
         putdrug d
         txtMethod(4).Text = d.SisCode
         lblDetails.Caption = strDescription & cr & cr & "Last stock take on " & strDate
         'lblLastDate.Caption = "Last stock take on " & strDate
      Else
         k.escd = True
         lblDescription.Caption = ""
         lblDetails.Caption = ""
      End If
   Else
      txtMethod(4).Text = d.SisCode
      strDescription = d.DrugDescription ' strDescription = GetStoresDescription()  XN 4Jun15 98073 New local stores description
      plingparse strDescription, "!"
      'lblDescription.Caption = strDescription
      parsedate d.laststocktakedate, strDate, "dd mmm yyyy", 0
      'lblLastDate.Caption = "Last stock take on " & strDate
      lblDetails.Caption = strDescription & cr & cr & "Last stock take on " & strDate
   End If

End Sub
