VERSION 5.00
Begin VB.Form DrugContract 
   Appearance      =   0  'Flat
   BackColor       =   &H80000004&
   Caption         =   "Drug Contract Information"
   ClientHeight    =   10080
   ClientLeft      =   5520
   ClientTop       =   3105
   ClientWidth     =   8445
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
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   10080
   ScaleWidth      =   8445
   Begin VB.Frame Frame1 
      Height          =   9975
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8415
      Begin VB.CheckBox ChkSetAsPrimary 
         Height          =   375
         Left            =   7920
         TabIndex        =   27
         Top             =   7200
         Width           =   255
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   525
         Index           =   14
         Left            =   5880
         MaxLength       =   30
         MultiLine       =   -1  'True
         TabIndex        =   26
         TabStop         =   0   'False
         Top             =   6240
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Enabled         =   0   'False
         Height          =   525
         Index           =   13
         Left            =   3000
         MaxLength       =   30
         MultiLine       =   -1  'True
         TabIndex        =   25
         TabStop         =   0   'False
         Top             =   6240
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   525
         Index           =   12
         Left            =   5880
         MaxLength       =   36
         MultiLine       =   -1  'True
         TabIndex        =   24
         TabStop         =   0   'False
         Top             =   5280
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Enabled         =   0   'False
         Height          =   525
         Index           =   6
         Left            =   3000
         MaxLength       =   36
         MultiLine       =   -1  'True
         TabIndex        =   23
         TabStop         =   0   'False
         Top             =   5280
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   1
         Left            =   5880
         MaxLength       =   10
         TabIndex        =   10
         Top             =   3240
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Enabled         =   0   'False
         Height          =   285
         Index           =   2
         Left            =   3000
         MaxLength       =   9
         TabIndex        =   9
         TabStop         =   0   'False
         Top             =   3960
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   3
         Left            =   5880
         MaxLength       =   9
         TabIndex        =   8
         Top             =   3960
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Enabled         =   0   'False
         Height          =   285
         Index           =   0
         Left            =   3000
         MaxLength       =   10
         TabIndex        =   7
         TabStop         =   0   'False
         Top             =   3225
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   4
         Left            =   6720
         MaxLength       =   10
         TabIndex        =   6
         Top             =   7920
         Width           =   1395
      End
      Begin VB.CommandButton Command1 
         Appearance      =   0  'Flat
         Caption         =   "&Save"
         Height          =   435
         Index           =   0
         Left            =   2880
         TabIndex        =   5
         Top             =   9120
         Width           =   1035
      End
      Begin VB.CommandButton Command1 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "&Cancel"
         Height          =   435
         Index           =   1
         Left            =   4440
         TabIndex        =   4
         Top             =   9120
         Width           =   1035
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   5
         Left            =   1200
         MaxLength       =   13
         TabIndex        =   1
         Top             =   480
         Width           =   1395
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   11
         Left            =   5880
         MaxLength       =   10
         TabIndex        =   3
         Top             =   4620
         Width           =   2235
      End
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   7
         Left            =   5940
         MaxLength       =   5
         TabIndex        =   2
         Top             =   480
         Width           =   1275
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Set As Primary Supplier"
         ForeColor       =   &H80000008&
         Height          =   315
         Index           =   3
         Left            =   4080
         TabIndex        =   28
         Top             =   7275
         Width           =   1995
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "SupplierTradeName"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   1
         Left            =   360
         TabIndex        =   22
         Top             =   6240
         Width           =   1680
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Supplier Reference"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   0
         Left            =   360
         TabIndex        =   21
         Top             =   5400
         Width           =   1650
      End
      Begin VB.Label lblSupplier 
         Height          =   615
         Left            =   360
         TabIndex        =   20
         Top             =   1800
         Width           =   7815
      End
      Begin VB.Label LblStoresDesc 
         Alignment       =   2  'Center
         Height          =   495
         Left            =   240
         TabIndex        =   19
         Top             =   1200
         Width           =   7935
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Item"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   19
         Left            =   555
         TabIndex        =   18
         Top             =   540
         Width           =   495
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Contract &Number"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   18
         Left            =   360
         TabIndex        =   17
         Top             =   3240
         Width           =   1440
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Contract &Price (£)"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   2
         Left            =   360
         TabIndex        =   16
         Top             =   3975
         Width           =   1515
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Current"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   16
         Left            =   3720
         TabIndex        =   15
         Top             =   2760
         Width           =   645
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "New"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   15
         Left            =   6840
         TabIndex        =   14
         Top             =   2760
         Width           =   405
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "&Date to be updated"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   14
         Left            =   4080
         TabIndex        =   13
         Top             =   7965
         Width           =   1905
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Contract Stop Date"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   12
         Left            =   360
         TabIndex        =   12
         Top             =   4680
         Width           =   1650
      End
      Begin VB.Line Line2 
         X1              =   240
         X2              =   8160
         Y1              =   2520
         Y2              =   2520
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Supplier"
         ForeColor       =   &H80000008&
         Height          =   195
         Index           =   11
         Left            =   4680
         TabIndex        =   11
         Top             =   540
         Width           =   705
      End
      Begin VB.Image ImgSupplier 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   5640
         Picture         =   "DRUGCONT.frx":0000
         Top             =   480
         Width           =   285
      End
   End
End
Attribute VB_Name = "DrugContract"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------------------
'                                DRUGCONT.FRM
'
'??????? ??? Created
'03May98 CKJ Y2K minor mod to give better help on entering an invalid date
'23May98 CFY Command1_Click: Added logging to record when price and contract changes have been made
'20Nov98 TH  Form_load: Price label now goes through money (country specific)
'20Jan05 TH  Overhaul for enh68048. Various changes
'14Feb05 TH  Text1_KeyPress: Added primitive masking to allow only for numeric entry of new contract price
'            Added dropdown bitmap for the supplier selection launcher
'            widened and deepened label containing drug description
'19May10 TH  Text1_KeyPress: Now allow stores only products to also be available for contract changes (F0055971)
'                            it is on a setting but allows stores only by default.
'09Nov10 TH  Text1_KeyPress: (F0100840) Added suopplier tradename and reference number on load if they are already in for update
'------------------------------------------------------------------------------------------------

'------ V10 Consolidation : Welcome to our new world (looks like the old one I know, but keep the faith !!)


'29Aug08 TH Dont validate the suppliercode if it hasnt changed - was blanking other data (F0025880)
'02Nov10 TH Extended input box for supplier reference number (UMMC PRF) (F0094388/RCN545)
'15Nov13 XN Command1_Click: Moved labutils.log to WPharmacyLog table 56701


Option Explicit
DefInt A-Z

Const modulename$ = "DRUGCONT.FRM"
Dim stored$(5)
Dim blnEditingsupplierprofile As Boolean  '07Jan08 TH Added
Dim strCachedSupcode As String '29Aug08 TH (F0025880)

Private Sub CmdDropDown_Click()
'20Jan05 TH Written

Dim supcode$
Dim FoundSup As Long

   asksupplier supcode$, 0, "ES", "Enter Supplier Code", False, sup, False  '15Nov12 TH Added PSO param
   If k.escd Then Exit Sub
   getsupplier supcode$, False, FoundSup, sup
   If FoundSup = 0 Then
         popmessagecr "Aborting", "Supplier code '" + supcode$ + "' not found"
         k.escd = True
      Else
         Text1(7).Text = supcode$
      End If

End Sub

Private Sub Command1_Click(Index As Integer)
'23May98 CFY Added logging to record when price and contract changes have been made
'02Nov10 TH Extended supplier ref number in IO proc from 20 to 36 characters max.(UMMC PRF) (F0094388/RCN545)
'15Nov13 XN Moved labutils.log to WPharmacyLog table 56701

Const procname$ = "Command1()_Click"

Dim resumeval%, retries%
Dim SQL$, ans$, upddate$, outdate$
Dim loopvar, OK, Changed
'Dim tempdyn As dynaset
Dim msg$    '23May98 CFY Added
Dim foundPtr As Long     '01Jun02 ALL/ATW
Dim intloop As Integer
Dim lngStart As Long, lngStop As Long, lngNow As Long, lngUpdate As Long
Dim strAns As String
Dim blnUpdateNow As Integer
Dim FoundSup As Long
Dim strDesc As String
Dim strParams As String
Dim rsWExtrDrugDetails As ADODB.Recordset
Dim strDateUpdated As String
Dim lngWExtraDrugDetailID As Long
Dim strCurrentStartDate As String
Dim strCurrentStopDate As String
Dim lngOK As Long
Dim strNewContractPricePence As String
Dim strNewSupRefNo As String
Dim strNewSupplierTradeName As String
Dim blnSetDefaultSupplier As Boolean
Dim SupProfile As TSupProfile
Dim intSupprofFound As Integer  '05Oct07 TH Added


    Select Case Index
        Case 0
        
            If Trim$(Text1(4).Text) = "" Then
               popmessagecr "", "Date to be Updated cannot be blank"
               Exit Sub
            End If
            'First Validate the dates
            For intloop = 4 To 11
               If (intloop = 4 Or intloop > 9) And (intloop <> 10) Then
                  If Trim$(Text1(intloop).Text) <> "" Then
                     upddate$ = Trim$(Text1(intloop).Text)
                     Storesparsedate upddate$, outdate$, "1", OK
                     If OK Then
                        Text1(intloop).Text = outdate$
                     Else
                        'popmessagecr "Error", "Invalid date format. Please correct and try again."
                        BadDate         '03May98 CKJ Y2K more use than the box above
                        Exit Sub
                     End If
                  End If
               End If
            Next
            
            'Check New Number,Price and Supcode fields are entered
''            If Trim$(Text1(1).Text) = "" Then
''               popmessagecr "", "New contract number not entered"
''               Exit Sub
''            End If
''            If Trim$(Text1(3).Text) = "" Then
''               popmessagecr "", "New price not entered"
''               Exit Sub
''            End If
            If Trim$(Text1(7).Text) = "" Then
               popmessagecr "", "Supplier code not entered"
               Exit Sub    '? For Now
            Else
               getsupplier Trim$(Text1(7).Text), False, FoundSup, sup
               If FoundSup = 0 Then
                  popmessagecr "", "Supplier code '" + Trim$(Text1(7).Text) + "' not found"
                  Exit Sub
               Else
                  'Text1(7).text = supcode$
                  '05Oct07 TH Added block
                  GetSupProfile d.SisCode, Trim$(Text1(7).Text), SupProfile, 0, intSupprofFound
                  If Not intSupprofFound Then
                     popmessagecr "", "Supplier Profile for '" + Trim$(Text1(7).Text) + "' not found" & crlf & crlf & "A supplier profile for this product and supplier must be added before making contract changes"
                     Exit Sub
                  End If
                  '------------
               End If

            End If

            'check price is not negative
            If Val(Trim$(Text1(3).Text)) < 0 Then
               popmessagecr "", "a negative new price is not a valid entry"
               Exit Sub
            End If


            'check new stopdate is after new start date
''            If Trim$(Text1(9).Text) <> "" And Trim$(Text1(11).Text) <> "" Then
''               datetodays (Text1(9).Text), (Text1(11).Text), lngStart, 0, "", 0
''               If lngStart < 0 Then
''                  popmessagecr "", "new start date must be earlier than the new stop date"
''                  Exit Sub
''               End If
''            End If

            'StopDate Must not be in past
            If Trim$(Text1(11).Text) <> "" Then
               datetodays (Text1(11).Text), Format$(Now, "DD/MM/YYYY"), lngStop, 0, "", 0
               If lngStop > 0 Then
                  popmessagecr "", "new stop date cannot be set in the past"
                  Exit Sub
               End If
            End If

            'Date For Update must not be in the past
            If Trim$(Text1(4).Text) <> "" Then
               datetodays (Text1(4).Text), Format$(Now, "DD/MM/YYYY"), lngNow, 0, "", 0
               If lngNow > 0 Then
                  popmessagecr "", "date to be updated cannot be set in the past"
                  Exit Sub
               End If
            End If
            
            'If we are updating in the future then we must ensure we only ever have one record to be set as
            'the primary supplier on one intance (date) of the auto update. If there is already a record for this
            'we inform the user and refuse to save.
            If lngNow < 0 And ChkSetAsPrimary.Value = 1 Then
               If CheckForDuplicateSetPrimarySupplier(d.SisCode, Text1(4).Text) Then
                  popmessagecr "", "There is already a scheduled record to change the Primary Supplier on this date"
                  Exit Sub
               End If
            
            
            End If

            'New StartDate cannot be before the date for update
''            If Trim$(Text1(9).Text) <> "" And Trim$(Text1(11).Text) <> "" Then
''               datetodays (Text1(9).Text), (Text1(4).Text), lngStart, 0, "", 0
''               If lngStart < 0 Then
''                  popmessagecr "", "new start date must be on or before date for update"
''                  Exit Sub
''               End If
''            End If


            d.SisCode = Text1(5).Text
            'getdrug d, 0, foundPtr&, True   '10Oct06 TH Replaced
            getdrug d, 0, foundPtr&, False   '     "
            If foundPtr& Then
               If lngNow = 0 Then
                  blnUpdateNow = True
                  k.escd = False
                  askwin "Contract Update", "Update Product contract information now. Y/N", strAns, k
                  If Not strAns = "Y" Or k.escd Then
                     'putdrug d  'Drop the lock first you damn dolt !!! '10Oct06 TH Removed
                     Exit Sub
                  Else                                '10Oct06 TH Added to make locking tighter
                     'getdrug d, 0, foundPtr&, True    '     "
                     GetSupProfile d.SisCode, Trim$(Text1(7).Text), SupProfile, 0, 0
                  End If
                  If SupProfile.contno <> Trim$(Text1(1).Text) Then                                                                       '23May98 CFY Added
                     msg$ = " Contract no. (" & SupProfile.supcode & ")     Was: '" & Trim$(SupProfile.contno) & "' is : '" & Trim$(Text1(0).Text) & "'"   '        "
                     SupProfile.contno = Trim$(Text1(1).Text)
                     'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & msg$                              '23May98 CFY Added
                     WriteLogSQL msg$, "labutils", 0, 0, d.SisCode      ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701

                  End If
                  If SupProfile.contprice <> Format$(Val(Text1(3).Text) * 100) Then
                     msg$ = " Contract price (" & SupProfile.supcode & ")   Was : '" & Trim$(SupProfile.contprice) & "' is : '" & Format$(Val(Text1(2).Text) * 100) & "'"  '23May98 CFY Added
                     SupProfile.contprice = Format$(Val(Text1(3).Text) * 100)                                                                         '       "
                     'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & msg$
                     WriteLogSQL msg$, "labutils", 0, 0, d.SisCode      ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
                  End If                                                                                                                     '23May98 CFY Added
                  'If d.supcode <> Trim$(Text1(7).Text) Then
                  '   msg$ = " Default Supplier          Was : '" & Trim$(d.supcode) & "' is : '" & Trim$(Text1(6).Text) & "'"  '23May98 CFY Added
                  '   d.supcode = Trim$(Text1(7).Text)                                                                      '       "
                  '   WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & msg$
                  'End If
                  If SupProfile.SupplierTradeName <> Trim$(Text1(14).Text) Then                                                                       '23May98 CFY Added
                     'msg$ = " SupplierTradeName.              Was : '" & Trim$(d.contno) & "' is : '" & Trim$(Text1(0).Text) & "'"   '        "
                     SupProfile.SupplierTradeName = Trim$(Text1(14).Text)
                     'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & msg$                              '23May98 CFY Added
                  End If
                  If SupProfile.SuppRefno <> Trim$(Text1(12).Text) Then                                                                       '23May98 CFY Added
                     'msg$ = " Supplier Reference no.              Was : '" & Trim$(d.SuppRefno) & "' is : '" & Trim$(Text1(0).Text) & "'"   '        "
                     SupProfile.SuppRefno = Trim$(Text1(12).Text)
                     'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & msg$                              '23May98 CFY Added
                  End If
                  PutSupProfile SupProfile, 0 '08Mar07 TH Moved from above to stop problems vis-a-vis possible putdrug
                  If ChkSetAsPrimary.Value = 1 Then
                     getdrug d, 0, foundPtr&, True '22Jan07 TH the only bit of the product file that needs changing outside the profile
                     d.WSupplierProfileID = -100 '08Mar07 TH Added flag to ensure WSupplierProfile not saved.
                     d.supcode = Trim$(Text1(7).Text)
                     putdrug d  '10Oct06 TH Moved here from below
                  End If
                  'putdrug d  '10Oct06 TH Moved here from below
                  'PutSupProfile SupProfile, 0
               End If
               'putdrug d  '03Dec04 TH Moved here
               'Get the existing DateUpdate here
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                           gTransport.CreateInputParameterXML("SupplierCode", trnDataTypeVarChar, 5, sup.Code)
               Set rsWExtrDrugDetails = gTransport.ExecuteSelectSP(g_SessionID, "pWExtraDrugDetailbyNSVCodeandSupplierCode", strParams)
               If Not rsWExtrDrugDetails.EOF Then
                  rsWExtrDrugDetails.MoveFirst
                  strDateUpdated = GetField(rsWExtrDrugDetails!DateUpdated)
                  lngWExtraDrugDetailID = GetField(rsWExtrDrugDetails!WExtraDrugDetailID)
               Else
                  strDateUpdated = ""
                  lngWExtraDrugDetailID = 0
               End If
               rsWExtrDrugDetails.Close
               Set rsWExtrDrugDetails = Nothing
               If blnUpdateNow Then
                  strDateUpdated = Format$(Now, "DD/MM/YYYY")
               End If
            strNewSupplierTradeName = Trim$(Text1(14).Text)
            strNewSupRefNo = Trim$(Text1(12).Text)
            blnSetDefaultSupplier = ChkSetAsPrimary.Value
            '13Oct06 TH removed newstartdate
            'gTransport.CreateInputParameterXML("newStartDate", trnDataTypeVarChar, 10, Trim$(Text1(9).Text)) & _

            strNewContractPricePence = Format(Val(Trim$(Text1(3).Text)) * 100) '25Apr06 TH Use this now so that we display in £ but store in pence
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                        gTransport.CreateInputParameterXML("NewContractPrice", trnDataTypeVarChar, 9, strNewContractPricePence) & _
                        gTransport.CreateInputParameterXML("NewContractNumber", trnDataTypeVarChar, 10, Trim$(Text1(1).Text)) & _
                        gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, Trim$(Text1(4).Text)) & _
                        gTransport.CreateInputParameterXML("SupplierCode", trnDataTypeVarChar, 5, Trim$(Text1(7).Text)) & _
                        gTransport.CreateInputParameterXML("DateUpdated", trnDataTypeVarChar, 10, strDateUpdated) & _
                        gTransport.CreateInputParameterXML("newStopDate", trnDataTypeVarChar, 10, Trim$(Text1(11).Text)) & _
                        gTransport.CreateInputParameterXML("UpdatedBy", trnDataTypeVarChar, 3, UserID$) & _
                        gTransport.CreateInputParameterXML("DateEntered", trnDataTypeVarChar, 10, Format$(Now, "DD/MM/YYYY")) & _
                        gTransport.CreateInputParameterXML("NewSupRefNo", trnDataTypeVarChar, 36, strNewSupRefNo) & _
                        gTransport.CreateInputParameterXML("NewSupplierTradeName", trnDataTypeVarChar, 30, strNewSupplierTradeName) & _
                        gTransport.CreateInputParameterXML("SetDefaultSupplier", trnDataTypeBit, 1, blnSetDefaultSupplier)


            If lngWExtraDrugDetailID > 0 Then
              'Update
              strParams = gTransport.CreateInputParameterXML("WExtraDrugDetailID", trnDataTypeint, 4, lngWExtraDrugDetailID) & strParams
              lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraDrugDetail", strParams)
            Else
              'Insert
              lngOK = gTransport.ExecuteInsertSP(g_SessionID, "WExtraDrugDetail", strParams)
            End If
               
            strDesc = Trim$(d.DrugDescription)
            plingparse strDesc, "!"
            If blnUpdateNow Then
               popmessagecr "", "Changes to contract information for " & strDesc & " have been updated and will apply to any new orders from this supplier"
            Else
               popmessagecr "", "Changes to contract information for " & strDesc & " saved for processing on " & Trim$(Text1(4).Text)
            End If
            For intloop = 0 To 14
               If intloop <> 6 And intloop <> 8 And intloop <> 10 And intloop <> 9 Then Text1(intloop).Text = ""
            Next
            Text1(6).Text = ""
            LblStoresDesc.Caption = ""
            BlankWProduct d
            Text1(5).SetFocus
         Else
            popmessagecr "", "No item selected. Update cannot proceed"
         End If
            
        Case 1
            For loopvar = 0 To 4
                If Trim$(stored$(loopvar)) <> Trim$(Text1(loopvar).Text) Then Changed = True
            Next
                        
            If Changed Then
                  If Len(Trim$(Text1(5).Text)) = 7 Then  'Only prompt for save if there is an nsvcode here
                     setinput 0, k
                     k.escd = False
                     Confirm "Exiting", "exit without saving changes", ans$, k
                     If ans$ = "Y" And Not k.escd Then Unload DrugContract
                  Else
                     Unload DrugContract
                  End If
               Else
                  Unload DrugContract
               End If
    End Select

Exit Sub

DCUpdateTableErr:

   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
   End Select
   
End Sub





Private Sub Form_Load()
   SetChrome Me
   Label1(2).Caption = "Contract &Price (" & money(5) & ")"    '20Nov98 TH Made country specific
   CentreForm DrugContract
   

End Sub

Private Sub Form_Unload(Cancel As Integer)

    Me.Hide
    ScreenRefresh

End Sub


Private Sub imgSupplier_Click()
'20Jan05 TH Written

Dim strSupCode As String
Dim lngSup As Long
Dim strSiscode As String
Dim lngFound As Long
Dim blnEscaped As Boolean
Dim strDesc As String
Dim strParams As String
Dim rsExtraDrugDetails As ADODB.Recordset
Dim lngStop As Long

   'asksupplier strSupcode, 0, "ES", "Enter Supplier Code", False, sup  '**!!**
   strSiscode = Text1(5).Text
   BlankWProduct d
   d.SisCode = strSiscode
   getdrug d, 0, lngFound, False
   If lngFound <> 0 Then
      blnEditingsupplierprofile = True '07Jan08 TH Added
      EditSupProfile True, blnEscaped
      If Not blnEscaped Then
         'here we will load the various fields for this profile
         LoadSupplierForContract
      Else '10Oct06 TH Added on Escape
      
         Text1(1).Text = ""
         Text1(3).Text = ""
         Text1(4).Text = ""
         Text1(7).Text = "" 'Supplier Code
         'Text1(9).Text = ""
         Text1(11).Text = ""
         Text1(12).Text = ""
         Text1(14).Text = ""
         ChkSetAsPrimary.Value = 0
         clearsup sup
         
      End If
      blnEditingsupplierprofile = False '07Jan08 TH Added
''      asksupplier strSupcode, 0, "PROFILES", "Enter Supplier Code", False, sup  '07Oct06 TH Added
''      If k.escd Then Exit Sub
''      getsupplier strSupcode, False, lngSup, sup
''      If lngSup = 0 Then
''         popmessagecr "Aborting", "Supplier code '" + strSupcode + "' not found"
''         lblSupplier.Caption = ""
''         k.escd = True
''      Else
''         Text1(7).Text = strSupcode
''         lblSupplier.Caption = "From  :  " & sup.fullname
''      End If
   End If
End Sub

Private Sub Text1_GotFocus(Index As Integer)

    Select Case Index
        Case 0 To 5, 8 To 11
            DrugContract.Text1(Index).SelStart = 0
            DrugContract.Text1(Index).SelLength = Len(DrugContract.Text1(Index).Text)
        Case 7
            strCachedSupcode = Text1(Index).Text
        Case Else
    End Select


End Sub

Private Sub Text1_KeyPress(Index As Integer, KeyAscii As Integer)
'14Feb05 TH Added primitive masking to allow only for numeric entry of new contract price
'19May10 TH Now allow stores only products to also be available for contract changes (F0055971)
'09Nov10 TH (F0100840) Added suopplier tradename and reference number on load if they are already in for update

Dim NSV$, SQL$
Dim loopvar, found
'Dim snap As snapshot

Dim upddate$, outdate$   '19jan98 EAC
Dim OK%                  '19Jan98 EAC
Dim strDesc As String
Dim lngStop As Long
Dim strParams As String
Dim rsExtraDrugDetails As ADODB.Recordset
Dim lngSup As Long
Dim intStores As Integer '19May10 TH Added (F0055971)

    Select Case Index
        Case 0
        Case 1
        Case 2
        Case 3
            '14Feb05 TH Added primitive masking to allow only for numeric entry
            If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
  
        Case 7 'Supplier
            If KeyAscii = 13 And Trim$(Text1(7).Text) = "" Then imgSupplier_Click
        
        Case 4, 8, 9, 10, 11 '19Jan98 EAC parsedate when entered / leaving text box
            Select Case KeyAscii
               Case 9, 13
                  If Trim$(Text1(4).Text) <> "" Then
                     upddate$ = Trim$(Text1(4).Text)
                     parsedate upddate$, outdate$, "1", OK
                     If OK Then
                        Text1(4).Text = outdate$
                     Else
                        'popmessagecr "Error", "Invalid date format. Please correct and try again."
                        BadDate         '03May98 CKJ Y2K more use than the box above
                        Exit Sub
                     End If
                  End If
               End Select

        Case 5
            Select Case KeyAscii
                Case 13
                  lblSupplier.Caption = ""
                  NSV$ = Text1(Index).Text
                  If Trim$(NSV$) <> "" Then
                     'findrdrug NSV$, 0, d, 0, found, False, False ' foundPtr, found, False '01Jun02 ALL/ATW
                     intStores = Val(TxtD(dispdata$ & "\winord.ini", "ContractUpdate", "-1", "AllowStoresOnly", 0))  '19May10 TH (F0055971)
                     findrdrug NSV$, intStores, d, 0, found, False, False, False ' foundPtr, found, False                   '  "        Replace above line and allow stores only (on setting)
                     If found Then
                        Text1(Index).Text = d.SisCode
                        
                        getdrug d, 0, 0, False ' foundPtr, found, False '01Jun02 ALL/ATW
                        Text1(0).Text = d.contno
                        Text1(1).Text = d.contno
                        Text1(2).Text = Format$(Val(d.contprice) / 100, "0.00")
                        Text1(3).Text = Format$(Val(d.contprice) / 100, "0.00")
                        Text1(7).Text = d.supcode
                        Text1(12).Text = d.SuppRefno           'These are defaults
                        Text1(14).Text = d.SupplierTradeName   '    "
                        Text1(6).Text = d.SuppRefno
                        Text1(13).Text = d.SupplierTradeName
                        
                        strDesc = d.DrugDescription
                        plingparse strDesc, "!"
                        LblStoresDesc.Caption = Trim$(strDesc)
                        getsupplier d.supcode, 0, lngSup, sup
                        If lngSup > 0 Then lblSupplier.Caption = "From  :  " & sup.fullname
      
                        'SQL$ = "SELECT * FROM ExtraDrugDetails WHERE (NSVCODE = '" & d.SisCode & "');"
                        'Set snap = SupDB.CreateSnapshot(SQL$)
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                                    gTransport.CreateInputParameterXML("SupplierCode", trnDataTypeVarChar, 5, d.supcode)
                        Set rsExtraDrugDetails = gTransport.ExecuteSelectSP(g_SessionID, "pWExtraDrugDetailbyNSVCodeandSupplierCode", strParams)
                        If Not rsExtraDrugDetails.EOF Then
                           If Len(GetField(rsExtraDrugDetails!DateUpdated)) = 10 Then datetodays GetField(rsExtraDrugDetails!DateUpdated), Format$(Now, "DD/MM/YYYY"), lngStop, 0, "", 0
                           If lngStop >= 0 Or Len(GetField(rsExtraDrugDetails!DateUpdated)) <> 10 Then
                           'Text1(1).Text = d.contno
                              Text1(1).Text = GetField(rsExtraDrugDetails!NewContractNumber)
                              'Text1(3).Text = GetField(rsExtraDrugDetails!NewContractPrice) '25Apr06 TH Replaced with below
                              Text1(3).Text = Format(Val(GetField(rsExtraDrugDetails!NewContractPrice)) / 100)
                              Text1(4).Text = GetField(rsExtraDrugDetails!DateofChange)
                              Text1(7).Text = GetField(rsExtraDrugDetails!SupplierCode)
                              Text1(11).Text = GetField(rsExtraDrugDetails!newStopDate)
                              '09Nov10 TH (F0100840) Added these if they are already in for update
                              Text1(12).Text = GetField(rsExtraDrugDetails!newSuprefno)
                              Text1(14).Text = GetField(rsExtraDrugDetails!newSupplierTradeName)
                           End If
                           'Text1(8).Text = GetField(rsExtraDrugDetails!CurrentStartDate)
                           'Text1(10).Text = GetField(rsExtraDrugDetails!CurrentStopDate)
                        Else
                            Text1(1).Text = ""
                            Text1(3).Text = ""
                            Text1(4).Text = ""
                            ''Text1(7).Text = ""
                            Text1(11).Text = ""
                            'Text1(8).Text = ""
                            'Text1(10).Text = ""
                           
                        End If
                        rsExtraDrugDetails.Close
                        Set rsExtraDrugDetails = Nothing
                     Else
                        If Not k.escd Then
                           popmessagecr "Error", "Item not found."
                        End If
                        Text1(Index).Text = ""
                        Text1(1).Text = ""
                        Text1(3).Text = ""
                        Text1(4).Text = ""
                        ''Text1(7).Text = ""
                        Text1(11).Text = ""
                        'Text1(8).Text = ""
                        'Text1(10).Text = ""
                        Text1(12).Text = ""
                        Text1(14).Text = ""
                        Text1(6).Text = ""
                        Text1(13).Text = ""
                        
                     End If
                  End If

                  For loopvar = 0 To 4
                      stored$(loopvar) = Text1(loopvar).Text
                  Next
          
               Case Else
            End Select
         Case Else
      End Select

End Sub

Private Sub Text1_LostFocus(Index As Integer)
'29Aug08 TH Dont validate the suppliercode if it hasnt changed - was blanking other data (F0025880)

Dim upddate$
Dim outdate$
Dim OK As Integer
Dim lngSup As Long
Dim tmpSup As supplierstruct
Dim strMsg As String

If blnEditingsupplierprofile Then Exit Sub '04Apr08 TH Added (F0012093)

   Select Case Index
'      Case 5
''         upddate$ = Trim$(Text1(7).Text) '07Oct06 TH Moved from below
''         If Trim$(Text1(9).Text) <> "" Then
''            'upddate$ = Trim$(Text1(7).Text)
''            'Here we will try and get a valid supplier and then populate the label if valid
''            getsupplier upddate$, 0, lngSup, tmpSup
''            If lngSup > 0 Then
''               lblSupplier.Caption = "From  :  " & tmpSup.fullname
''            Else
''               lblSupplier.Caption = ""
''            End If
''         Else
''            lblSupplier.Caption = ""
''         End If
      Case 7
               'If Trim$(Text1(7).text) <> "" Then
               'If Trim$(Text1(7).Text) <> "" And (Not blnEditingsupplierprofile) Then   '07Jan08 TH
               '29Aug08 TH Replaced above (F0025880)
               If (Trim$(UCase$(strCachedSupcode)) <> Trim$(UCase$(Text1(7).Text))) And Trim$(Text1(7).Text) <> "" And (Not blnEditingsupplierprofile) Then   '07Jan08 TH
                  upddate$ = Trim$(Text1(7).Text)
                  'Here we will try and get a valid supplier and then populate the label if valid
                  getsupplier upddate$, 0, lngSup, sup
                  If lngSup > 0 Then
                     lblSupplier.Caption = "From  :  " & sup.fullname
                     'Now we have a valid supplier we must load the profile, contract change record
                     LoadSupplierForContract
                  Else
                     lblSupplier.Caption = ""
                     '10Oct06 TH Added on Escape
                     strMsg = Text1(7).Text & " is not a valid supplier"
                     popmessagecr "", strMsg
                     Text1(1).Text = ""
                     Text1(3).Text = ""
                     Text1(4).Text = ""
                     Text1(7).Text = "" 'Supplier Code
                     Text1(11).Text = ""
                     Text1(12).Text = ""
                     Text1(14).Text = ""
                     ChkSetAsPrimary.Value = 0
                     clearsup sup
                  End If
               ElseIf strCachedSupcode = "" Then '29Aug08 TH Added clause (F0025880)
                  lblSupplier.Caption = ""
                  Text1(1).Text = ""
                  Text1(3).Text = ""
                  Text1(4).Text = ""
                  Text1(7).Text = "" 'Supplier Code
                  Text1(11).Text = ""
                  Text1(12).Text = ""
                  Text1(14).Text = ""
                  ChkSetAsPrimary.Value = 0
                  clearsup sup

               End If
      Case 9, 11, 4
         If Trim$(Text1(Index).Text) <> "" Then
               upddate$ = Trim$(Text1(Index).Text)
               Storesparsedate upddate$, outdate$, "1", OK
               If OK And Left$(outdate$, 2) <> "00" Then
                        Text1(Index).Text = outdate$
                  Else
                        'popmessagecr "Error", "Invalid date format. Please correct and try again."
                        BadDate         '03May98 CKJ Y2K more use than the box above
                        Exit Sub
                  End If
            End If
         
         'If (Trim$(Text1(4).Text) = "" And Index = 9) Then Text1(4).Text = Trim$(Text1(9).Text)
      Case Else
   End Select
   

End Sub

Public Sub LoadSupplierForContract()
Dim strSupCode As String
Dim lngSup As Long
Dim strSiscode As String
Dim lngFound As Long
Dim blnEscaped As Boolean
Dim strDesc As String
Dim strParams As String
Dim rsExtraDrugDetails As ADODB.Recordset
Dim lngStop As Long
         getdrugsup d, 0, 0, False, sup.Code ' foundPtr, found, False '01Jun02 ALL/ATW
         Text1(0).Text = d.contno
         Text1(1).Text = d.contno
         Text1(2).Text = Format$(Val(d.contprice) / 100, "0.00")
         Text1(3).Text = Format$(Val(d.contprice) / 100, "0.00")
         Text1(7).Text = sup.Code 'd.supcode
         Text1(6).Text = d.SuppRefno
         Text1(13).Text = d.SupplierTradeName
         strDesc = d.DrugDescription
         plingparse strDesc, "!"
         LblStoresDesc.Caption = Trim$(strDesc)
         getsupplier d.supcode, 0, lngSup, sup
         If lngSup > 0 Then lblSupplier.Caption = "From  :  " & sup.fullname

         'SQL$ = "SELECT * FROM ExtraDrugDetails WHERE (NSVCODE = '" & d.SisCode & "');"
         'Set snap = SupDB.CreateSnapshot(SQL$)
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                     gTransport.CreateInputParameterXML("SupplierCode", trnDataTypeVarChar, 5, sup.Code)
         Set rsExtraDrugDetails = gTransport.ExecuteSelectSP(g_SessionID, "pWExtraDrugDetailbyNSVCodeandSupplierCode", strParams)
         If Not rsExtraDrugDetails.EOF Then
            If Len(GetField(rsExtraDrugDetails!DateUpdated)) = 10 Then datetodays GetField(rsExtraDrugDetails!DateUpdated), Format$(Now, "DD/MM/YYYY"), lngStop, 0, "", 0
            If lngStop >= 0 Or Len(GetField(rsExtraDrugDetails!DateUpdated)) <> 10 Then
            'Text1(1).Text = d.contno
               Text1(1).Text = GetField(rsExtraDrugDetails!NewContractNumber)
               'Text1(3).Text = GetField(rsExtraDrugDetails!NewContractPrice) '25Apr06 TH Replaced with below
               Text1(3).Text = Format(Val(GetField(rsExtraDrugDetails!NewContractPrice)) / 100)
               Text1(4).Text = GetField(rsExtraDrugDetails!DateofChange)
               Text1(7).Text = GetField(rsExtraDrugDetails!SupplierCode)
               'Text1(9).Text = GetField(rsExtraDrugDetails!newStartDate)
               Text1(11).Text = GetField(rsExtraDrugDetails!newStopDate)
               Text1(12).Text = GetField(rsExtraDrugDetails!newSuprefno)
               Text1(14).Text = GetField(rsExtraDrugDetails!newSupplierTradeName)
               ChkSetAsPrimary.Value = Iff(GetField(rsExtraDrugDetails!SetDefaultSupplier), 1, 0)
            End If
            'Text1(8).Text = GetField(rsExtraDrugDetails!CurrentStartDate)
            'Text1(10).Text = GetField(rsExtraDrugDetails!CurrentStopDate)
         Else
             Text1(1).Text = ""
             Text1(3).Text = ""
             Text1(4).Text = ""
             ''Text1(7).Text = ""
             'Text1(9).Text = ""
             Text1(11).Text = ""
             Text1(12).Text = d.SuppRefno          '10Oct06 TH These two fields use current data as default for new records
             Text1(14).Text = d.SupplierTradeName  '     "
             ChkSetAsPrimary.Value = 0
         End If
         rsExtraDrugDetails.Close
         Set rsExtraDrugDetails = Nothing
      
End Sub



