VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "MSCOMCTL.OCX"
Begin VB.Form FrmBondStore 
   Caption         =   "Bond Store Management"
   ClientHeight    =   10605
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   12750
   LinkTopic       =   "Form1"
   ScaleHeight     =   10605
   ScaleWidth      =   12750
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdClose 
      Cancel          =   -1  'True
      Caption         =   "&Close"
      Height          =   495
      Left            =   11040
      TabIndex        =   1
      Top             =   9960
      Width           =   1575
   End
   Begin VB.Frame FraBond 
      Height          =   9735
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   12495
      Begin VB.CommandButton cmdFilter 
         Caption         =   "&Filter"
         Height          =   375
         Left            =   10680
         TabIndex        =   14
         Top             =   1320
         Width           =   1335
      End
      Begin VB.TextBox txtNSVCode 
         Height          =   285
         Left            =   8760
         TabIndex        =   13
         Top             =   1320
         Width           =   1095
      End
      Begin VB.TextBox txtDescription 
         Height          =   285
         Left            =   4800
         TabIndex        =   11
         Top             =   1320
         Width           =   3135
      End
      Begin VB.TextBox txtBatch 
         Height          =   285
         Left            =   1920
         TabIndex        =   9
         Top             =   1320
         Width           =   1815
      End
      Begin VB.PictureBox PicInfo1 
         BackColor       =   &H0080C0FF&
         Height          =   135
         Left            =   120
         ScaleHeight     =   75
         ScaleWidth      =   8475
         TabIndex        =   5
         Top             =   8520
         Width           =   8535
      End
      Begin VB.CommandButton cmdDestroy 
         Caption         =   "&Destroy"
         Height          =   375
         Left            =   11040
         TabIndex        =   4
         Top             =   8880
         Width           =   1335
      End
      Begin VB.CommandButton cmdRelease 
         Caption         =   "&Release"
         Height          =   375
         Left            =   9360
         TabIndex        =   3
         Top             =   8880
         Width           =   1335
      End
      Begin MSComctlLib.ListView lvwBond 
         CausesValidation=   0   'False
         Height          =   6255
         Left            =   120
         TabIndex        =   2
         Top             =   2040
         Width           =   12255
         _ExtentX        =   21616
         _ExtentY        =   11033
         LabelEdit       =   1
         LabelWrap       =   -1  'True
         HideSelection   =   0   'False
         FullRowSelect   =   -1  'True
         _Version        =   393217
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         Appearance      =   1
         NumItems        =   0
      End
      Begin VB.Image ImgProduct 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   9840
         Picture         =   "FrmBondStore.frx":0000
         Top             =   1320
         Width           =   285
      End
      Begin VB.Label lblProduct 
         Caption         =   "Product"
         Height          =   255
         Left            =   8040
         TabIndex        =   12
         Top             =   1320
         Width           =   855
      End
      Begin VB.Label lblDesc 
         Caption         =   "Description"
         Height          =   255
         Left            =   3840
         TabIndex        =   10
         Top             =   1320
         Width           =   1215
      End
      Begin VB.Label lblBatch 
         Caption         =   "Batch"
         Height          =   255
         Left            =   1320
         TabIndex        =   8
         Top             =   1320
         Width           =   735
      End
      Begin VB.Label lblFilter 
         Caption         =   "Filter by :"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   1320
         Width           =   1335
      End
      Begin VB.Label lblTitle 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   240
         TabIndex        =   6
         Top             =   480
         Width           =   12015
      End
   End
End
Attribute VB_Name = "FrmBondStore"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'18Jul13 TH Written (TFS 56613)

Private Sub cmdClose_Click()
   Me.Hide
End Sub

Private Sub cmdDestroy_Click()
'Here we will first ask if the user is sure.
'Then collect any notes, reasons or general text for the record
'Then create an X Type transaction, though as this is from BOnd it must NOT change value or cost. Indeed the cost on the transaction should be zero
'to ensure it does not cause trouble on reports

      'If Me.lvwBond.SelectedItem.index > 0 Then BondStoreDestroyBatch Me, Me.lvwBond.SelectedItem.index '19Sep13 TH Added index check (TFS 73705)
      If Me.lvwBond.ListItems.count > 0 Then BondStoreDestroyBatch Me, Me.lvwBond.SelectedItem.index '01Oct13 TH Changed to listcount check (TFS 73705)


End Sub

Private Sub cmdFilter_Click()
'Collect the information from the UI, feed into the sps and load the grid
'18Sep13 TH Filter Search on Description within now automatic TFS 73393
'24Sep13 TH Fixed typo on above mod

Dim strNSVCode As String
Dim strDescription As String
Dim StrBatch As String
Dim strParams As String
Dim rsBond As ADODB.Recordset
Dim strFilter As String

   strNSVCode = Me.txtNSVCode.text
   strDescription = Me.txtDescription.text
   StrBatch = Me.txtBatch.text
   
   If StrBatch <> "" Then strFilter = strFilter & "and Batch Number like '" & Trim$(StrBatch) & "' "
   If strDescription <> "" Then strFilter = strFilter & "and Description like '" & Trim$(strDescription) & "' "
   If strNSVCode <> "" Then strFilter = strFilter & "and NSVCode = '" & Trim$(strNSVCode) & "' "
   
   If strFilter <> "" Then
      strFilter = "Pharmacy Bond Store : " & Right$(strFilter, Len(strFilter) - 4)
   Else
      strFilter = "Pharmacy Bond Store : Showing All items"
   End If
   
   
   Me.lblTitle.Caption = strFilter
   
   '18Sep13 TH Search within now automatic TFS 73393
   If strDescription <> "" Then strDescription = "%" & Trim$(strDescription) & "%" '24Sep13 TH fixed typo (= instead of final &)
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("BatchNumber", trnDataTypeVarChar, 25, StrBatch) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 50, strDescription) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
   Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyCriteria", strParams)

   setBondFilter strParams '16Jul13 TH This is used to refresh the grid on destroy or release
   
   fillBondTable Me, 0, rsBond
   
End Sub

Private Sub cmdRelease_Click()
   
   'If Me.lvwBond.SelectedItem.index > 0 Then BondStoreReleaseBatch Me, Me.lvwBond.SelectedItem.index '19Sep13 TH Added index check (TFS 73705)
   If Me.lvwBond.ListItems.count > 0 Then BondStoreReleaseBatch Me, Me.lvwBond.SelectedItem.index '01Oct13 TH Changed to listcount check (TFS 73705)
   
End Sub

Private Sub Form_Load()

   CentreForm Me
   SetChrome Me
   
End Sub

Private Sub ImgSupplier_Click()

End Sub

Private Sub ImgProduct_Click()


BondFormFindrug Me
            

End Sub

Private Sub lvwBond_Click()


   If Me.lvwBond.ListItems.count > 0 Then
      If Me.lvwBond.SelectedItem.Index = 0 Then
         BondGrid_RowChange 1
      Else
         BondGrid_RowChange Me.lvwBond.SelectedItem.Index
      End If
   End If
End Sub

Private Sub lvwBond_ItemClick(ByVal Item As MSComctlLib.ListItem)
If Me.lvwBond.ListItems.count > 0 Then
   BondGrid_RowChange Me.lvwBond.SelectedItem.Index
End If
End Sub
Public Sub BondGrid_RowChange(ByVal lngIndex As Long)
   UpdateBondPanel Me
End Sub

Private Sub txtBatch_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
   
   If (KeyAscii = 13) Then cmdFilter_Click  '03Oct13 TH (TFS 74967)

End Sub

Private Sub txtDescription_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
   If (KeyAscii = 37) Then KeyAscii = 0  '18Sep13 TH Trap % (TFS 73393)
   
   If (KeyAscii = 13) Then cmdFilter_Click  '03Oct13 TH (TFS 74967)
   
End Sub

Private Sub txtNSVCode_KeyPress(KeyAscii As Integer)
If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0

If KeyAscii = 13 Then BondFormFindrug Me

End Sub
Sub BondFormFindrug(ByVal frmBond As Form)
Dim dlocal As DrugParameters
Dim intFound As Integer
Dim strNSV As String
Dim intloop As Integer
Dim blnOK As Boolean

      strNSV = Me.txtNSVCode.text
         
            
      findrdrug strNSV, 0, dlocal, 0, intFound, False, False, False
      
      If intFound Then
         Me.txtNSVCode.text = dlocal.SisCode
      End If

End Sub
