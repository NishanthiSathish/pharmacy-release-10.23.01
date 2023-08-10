VERSION 5.00
Begin VB.UserControl ucPSE 
   BackColor       =   &H00FFFFC0&
   ClientHeight    =   12690
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   13050
   ScaleHeight     =   12690
   ScaleWidth      =   13050
   Begin VB.PictureBox Picture1 
      Height          =   12735
      Left            =   0
      ScaleHeight     =   12675
      ScaleWidth      =   13035
      TabIndex        =   0
      Top             =   0
      Width           =   13095
      Begin VB.Frame Frame1 
         Height          =   1455
         Left            =   480
         TabIndex        =   11
         Top             =   8400
         Width           =   5055
         Begin VB.Label lblDialogue 
            Height          =   1095
            Left            =   270
            TabIndex        =   12
            Top             =   240
            Width           =   4575
         End
      End
      Begin VB.CommandButton cmdCancel 
         Caption         =   "&Cancel"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   600
         Style           =   1  'Graphical
         TabIndex        =   10
         Top             =   1920
         Visible         =   0   'False
         Width           =   4815
      End
      Begin VB.ListBox LstProducts 
         Height          =   5520
         Left            =   195
         TabIndex        =   9
         Top             =   2820
         Width           =   5670
      End
      Begin VB.CommandButton CmdEdit 
         Caption         =   "&Edit Product"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   540
         Left            =   600
         Style           =   1  'Graphical
         TabIndex        =   7
         Top             =   480
         Visible         =   0   'False
         Width           =   4815
      End
      Begin VB.CommandButton CmdAdd 
         Caption         =   "&Add New Product"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   600
         Style           =   1  'Graphical
         TabIndex        =   6
         Top             =   1200
         Visible         =   0   'False
         Width           =   4815
      End
      Begin VB.ListBox Lstbox 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   5100
         Left            =   600
         TabIndex        =   3
         Top             =   3240
         Width           =   4935
      End
      Begin VB.Line lineSite 
         Visible         =   0   'False
         X1              =   480
         X2              =   5560
         Y1              =   2640
         Y2              =   2640
      End
      Begin VB.Label lblListboxHeader 
         Alignment       =   2  'Center
         Caption         =   "Data Views Available"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   480
         TabIndex        =   8
         Top             =   2900
         Width           =   5175
      End
      Begin VB.Label lblTitle 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1215
         Left            =   360
         TabIndex        =   5
         Top             =   1200
         Width           =   5415
      End
      Begin VB.Label lblStatus 
         Height          =   495
         Index           =   0
         Left            =   960
         TabIndex        =   4
         Top             =   840
         Width           =   4575
      End
      Begin VB.Label lblMode 
         Height          =   495
         Left            =   1080
         TabIndex        =   2
         Top             =   8400
         Width           =   3615
      End
      Begin VB.Label LblProductLevel 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   360
         TabIndex        =   1
         Top             =   240
         Width           =   5415
      End
   End
End
Attribute VB_Name = "ucPSE"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'-----------------------------------------------------------------------------------------
'                          Product Stock Editor user control
'-----------------------------------------------------------------------------------------
'converted from V8 code

'08oct08 CKJ SetConnection: corrected token handling & tidied the handling of failed connection
'22oct08 AK  RefreshState/CmdAdd_Click: If UpdateServiceView then Add Product becomes Import from DSS Master (F0018781)
'22oct08 AK  SelectView: Added "Update Service View" (F0018781)
'29Mar10 CKJ cmdAdd_click: added d.livestockctrl = "Y" to import from other site & from DSS Master [RCN P0007 F0077938]
'09Jun10 XN  Allow user to add stores only product if DSS on web enabled (F0088717)
'03Aug10 XN  CmdAdd_Click: If stores only product then can't default InUse to "S" instead set productID = 0 (F0088717)
'20Jul12 CKJ Added robot product information options  TFS37640
'            Added site name and colour bar           TFS39406
'29Aug12 TH  SetConnection: Replaced call to ParseURLToken product editor is an exe so we do not get the URL from the command line  (TFS 42368)
'04Oct12 CKJ Use transport layer wrapper (TFS44503)
'24Apr13 XN  SetConnection: Changed seed to work on any PC (60910)
'09Oct13 XN  CmdAdd_Click: Add setting to allow some sites to add drug if they have dss on web (TFS 75466)
'            SelectView: Only show Update Service View if DSS drug (TFS 75466)
'06Feb14 XN  SendToRobot: Added for Web version of product editor 56701

Option Explicit
DefBool A-Z

Public Function SetConnection(ByVal sessionID As Long, ByVal AscribeSiteNumber As Long, ByVal URLToken As String) As Boolean
'09May05 CKJ Main procedure to initialise the database connection
'12Aug08 CKJ Replaced PhaRTL with call via MSCAPI, added param URLtoken
'08oct08 CKJ corrected above mod - required tag setting for token
'            tidied the handling of failed connection - sets label & raises error
'29Aug12 TH  Replaced call to ParseURLToken product editor is an exe so we do not get the URL from the command line  (TFS 42368)
'24Apr13 XN  Changed seed to work on any PC (60910)

'Dim ConnectionString As String
Dim valid As Boolean
Dim phase As Single                                      '12Aug08 CKJ added
Dim Detail As String                                     '   "
Dim UnencryptedData As String       '15Aug12 CKJ Replacement for ConnectionString      (TFS36929)
Dim blnUseWebConn As Boolean        '   "        Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String    '   "        Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String   '   "        Added to store the unencrypted token

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = PROJECT & ".SetConnection"

   On Error GoTo ErrorHandler
   
   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   UCsetcolours

   If sessionID = 0 Then Err.Raise 32767, ErrSource, "Invalid SessionID (Zero)"
   If AscribeSiteNumber = 0 Then Err.Raise 32767, ErrSource, "Invalid SiteNumber (Zero)"
   
   g_SessionID = sessionID
   SiteNumber = AscribeSiteNumber
        
   If Val(Right$(date$, 4)) < 2008 Then
      Err.Raise 32767, ErrSource, "The clock in this computer has been set to " & date$ & cr & "Please correct the date on this computer"
   End If
        
   valid = False
   If Not gTransport Is Nothing Then
      If Not gTransportConnectionIsNothing() Then              '15Aug12 CKJ
         If gTransportConnectionState() = adStateOpen Then     '15Aug12 CKJ
            valid = True
            'Reset site stuff, just in case 02Apr07 TH Added
            'gDispSite = GetLocationID_Site(SiteNumber)        '15Aug12 CKJ removed - duplicatre of call below
            'ReadSiteInfo                                      '   "
         End If
      End If
   End If
    
   If Not valid Then
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)      '08oct08 CKJ added
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC

      'ConnectionString = ParseURLToken(sessionID, URLToken, phase, Detail) '   "        added (note that no message is shown for phase/detail)
      'UnencryptedData = ParseCommandURLToken(sessionID, URLToken, phase, Detail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
      UnencryptedData = ParseURLToken(sessionID, URLToken, phase, Detail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken) '29Aug12 TH Replaced above (TFS 42368)
      If blnUseWebConn Then
         Set gTransport = New PharmacyWebData.Transport
         gTransport.UnencryptedKey = UnencryptedData
         gTransport.URLToken = strUnencryptedToken
         gTransport.ProxyURL = strWebDataProxyURL
         valid = True
      Else
         '~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
         'UnencryptedData = "provider=sqloledb;server=***;database=***;uid=***;password=***;"
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         
         If UnencryptedData <> "" Then
            Set gTransport = New PharmacyData.Transport
            Set gTransport.Connection = New ADODB.Connection
            gTransport.Connection.Open UnencryptedData
            valid = True
         Else
            lblDialogue.Caption = "Product stock editor" & cr & "Unable to connect to database" & cr & "Phase " & Format$(phase, "0.#") & " " & Detail   '17Aug12 CKJ added  "0.#"
            Err.Raise 32767, ErrSource, (lblDialogue.Caption)
         End If
      End If
   End If
   
   If valid Then
      gDispSite = GetLocationID_Site(SiteNumber)
      ReadSiteInfo
      App.HelpFile = AppPathNoSlash() & "\ASCSHELL.HLP"
      UCsetcolours                     '20Jul12 CKJ Added
      SetSiteLine lineSite, False      '   "
      lblDialogue.Caption = SiteName() '   "        Show site name when otherwise blank
   End If
   
   'Reset Parent form handler
   ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

Cleanup:
   If ErrNumber Then
      On Error Resume Next
      gTransportConnectionClose     '15Aug12 CKJ
      SetgTransportConnectionToNothing     '15Aug12 CKJ
      Set gTransport = Nothing
      On Error GoTo 0
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
   End If
   
''   If valid Then
''      lblStatus.Caption = " Connected "
''   Else
''      UserControlEnable False
''      lblStatus.Caption = " Unable to connect "
''   End If
   SetConnection = valid
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
'   ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Function


Public Function RefreshState(ByVal sessionID As Long, ByVal ProductID As Long) As Boolean
'22oct08 AK Replace Add with Import if Update Service View is True (F0018781)
'20Apr09 TH Added sitenumber on heap or UHB Interfacing (F0050875)
'09Jun10 XN Allow user to add stores only product if DSS on web enabled (F0088717)

Dim blnOK As Boolean
Dim rs As ADODB.Recordset
Dim strParams As String
Dim strDesc As String

Dim blnTMUnresolved As Boolean
Dim rsTMS As ADODB.Recordset
Dim intCount As Integer
Dim ErrNumber As Long, ErrDescription As String

Const ErrSource As String = PROJECT & ".RefreshState"

   On Error GoTo ErrorHandler
   
   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   UCsetcolours
   SetSiteLine lineSite, False      '20Jul12 CKJ Added
   
   '---------------- FOR EDITING ONLY
   '''ProductID = 0 '11Nov05 TH Frig cos now we are just doing an editor not adding for now
   cmdCancel.Visible = True
   cmdCancel.Enabled = True
   CmdEdit.Enabled = True
   CmdEdit.Visible = True
   
   Lstbox.Clear
   LstProducts.Clear
   LblProductLevel.Caption = ""
   lblTitle.Caption = ""
   gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
   strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            UserID = RtrimGetField(rs!initials)
            UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
         End If
         rs.Close
      End If
      Set rs = Nothing
   End If
   ReadSiteInfo
   Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0  '20Apr09 TH Added For UHB Interfacing (F0050875)
   UserControlIsAlive = 1
   '''' Exit Function
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "EnableProductAddition", 0)) Then
      CmdAdd.Enabled = True 'False
      CmdAdd.Visible = True 'False
   End If
   
   '----------------

   blnNMP = False
   
   'First we need to check if this is a) an existing product in AMPP_Mapper, or a new product AT THE AMPP LEVEL !
   blnOK = CheckAMPPMapped(ProductID)
   
   gProductID = ProductID
''  ' If Not blnOK Then
''      blnAMPP = isAMPP(ProductID)
''  ' End If
   blnTM = isTM(ProductID)
   blnNMP = isNMP(ProductID)
   blnTMUnresolved = False
   If blnTM Then
      'OK this is a TM now we need to display for this TM all the associated items attached
      'First we need to get the product family associated with this
      '16Oct08 TH Added new routeID param
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID) & _
                  gTransport.CreateInputParameterXML("RouteID", trnDataTypeint, 4, 0)
      Set rsTMS = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLookupByProductID_VMPorAMP", strParams)
      
      '20Jul12 CKJ Added block to allow more of the description to be seen
      ReDim TabStops(1) As Long
      TabStops(1) = 10 * 4
      ListBoxTextBoxSetTabs LstProducts, 1, TabStops()
         
      LstProducts.AddItem "< ADD NEW PHARMACY ITEM >"
      LstProducts.AddItem "< CREATE NEW PRODUCT FROM EXISTING PHARMACY PRODUCT >" '23Mar06 TH altered text
      LstProducts.ItemData(0) = 0
      LstProducts.ItemData(1) = 0
      intCount = 2
      If Not rsTMS.EOF Then
         
         Do While Not rsTMS.EOF
            strDesc = RtrimGetField(rsTMS!Description)
            
            plingparse strDesc, "!"
            '''g_strTMDescription = strDesc
            LstProducts.AddItem RtrimGetField(rsTMS!SisCode) & TB & strDesc         '20Jul12 CKJ Removed superfluous space
      
            LstProducts.ItemData(intCount) = RtrimGetField(rsTMS!productstockID)
            intCount = intCount + 1
            rsTMS.MoveNext
         Loop
      End If
      LblProductLevel.Caption = "Prescribable Product"
      CmdEdit.Visible = False
      CmdAdd.Visible = False
      LstProducts.Visible = True
      LstProducts.Enabled = True
      LstProducts.ListIndex = 0 '27Mar06 TH
      LstProducts.SetFocus  '24Apr06 TH Added
   End If
   If blnNMP Then
   End If
   If (Not blnNMP) And (Not blnTM) Then
      CmdEdit.Visible = True
      CmdAdd.Visible = True
      CmdEdit.Enabled = True
      CmdAdd.Enabled = True
   End If
   
   'lstTMProducts.Visible = False
'''''   If blnOK Then  'Only Fire up if this is at an acceptable level or it has an existing row
'''''      If Not blnAMPP Then
'''''         'This item is a TM level mapping therefore we must check to see if there are existing products and
'''''         'if so whether the user wants to add a new one at this level or edit an existing one
'''''         LblProductLevel.Caption = "Pharmacy Product Editor at TM Level"
'''''         'lstTMProducts.AddItem "<NEW>"
'''''         'Lets go get all the TMs from here (the ID's and the descriptions)
'''''''         Set rsTMS = GetProductStockRowsbyTMProductID(ProductID)
'''''''         If rsTMS.RecordCount > 0 Then
'''''''            intCount = 0
'''''''            Do While Not rsTMS.EOF
'''''''               lstTMProducts.AddItem RtrimGetField(rsTMS!Description)
'''''''
'''''''               lstTMProducts.ItemData(intCount) = RtrimGetField(rsTMS!ProductStockID)
'''''''               intCount = intCount + 1
'''''''               rsTMS.MoveNext
'''''''            Loop
'''''''         End If
'''''         'lstTMProducts.Visible = True
'''''         CmdEdit.Visible = True
'''''         CmdAdd.Visible = True
'''''         lblTitle.Caption = "TM Level Product Mapping. Please use the buttons to either edit an existing product at this level or add a new one"
'''''         blnTMUnresolved = True
'''''      Else
'''''         'Now we need to know if this is NMP or not
'''''''         'Standard AMPP level
'''''''         CmdEdit.Visible = False
'''''''
'''''''         LblProductLevel.Caption = "Pharmacy Product Editor at AMPP Level"
'''''''         'lstTMProducts.Visible = False
'''''''         blnOK = GetProductNLbyProductID(ProductID, d)
'''''''         d.ProductID = ProductID 'This must be initialised for a product addition
'''''''         strDesc = d.storesdescription
'''''''         If Trim$(strDesc) = "" Then strDesc = d.Description
'''''''         If Trim$(strDesc) <> "" And Trim$(d.SisCode) <> "" Then
'''''''            plingparse strDesc, "!"
'''''''            lblTitle.Caption = Trim$(strDesc)
'''''''            CmdAdd.Visible = False
'''''''         Else
'''''''            lblTitle.Caption = "New Pharmacy Product" 'Should never happen
'''''''            Lstbox.Visible = False
'''''''            lblListboxHeader.Visible = False
'''''''         End If
'''''''         lngProductStockID = d.ProductStockID
'''''      End If
'''''   Else
'''''   'New Product at DSS/Pharmacy level
'''''   If Not blnAMPP Then
'''''         'This item is a TM level mapping therefore we must check to see if there are existing products and
'''''         'if so whether the user wants to add a new one at this level or edit an existing one
'''''         'Actually you bone head this is a new product because it does not exist in the DSSMapping table
'''''         'So now we go directly to addition of new item.
'''''
'''''         LblProductLevel.Caption = "Pharmacy Product Editor at TM Level"
'''''         'lstTMProducts.AddItem "<NEW>"
'''''         'lstTMProducts.Visible = False
'''''         CmdEdit.Visible = False
'''''         CmdAdd.Visible = False
'''''         lblTitle.Caption = "New Pharmacy Product"
'''''
'''''
'''''      Else
'''''         'Standard AMPP level
'''''         LblProductLevel.Caption = "Pharmacy Product Editor at AMPP Level"
'''''         'lstTMProducts.Visible = False
'''''         lblTitle.Caption = "New Pharmacy Product"
'''''         CmdEdit.Visible = False
'''''         CmdAdd.Visible = False
'''''         lngProductStockID = 0
'''''      End If
'''''
'''''   End If
   
   If (blnAMPP Or blnTM) And (Not blnTMUnresolved) Then
      SelectView
   End If
   
   'Reset Parent form handler
   ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

Cleanup:                            '08oct08 CKJ added basic error trap & cleanup
   If ErrNumber Then
      On Error Resume Next
      rs.Close
      Set rs = Nothing
      rsTMS.Close
      Set rsTMS = Nothing
      On Error GoTo 0
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
   End If
   
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function


'Injection/Infusion prescription
'-------------------------------
'prescriptiontypedescription=Infusion
'
'PrescriptionInfusion table
'  (RequestID)
'  UnitID_InfusionDuration
'  UnitID_RateMass
'  UnitID_RateTime
'  Continuous
'  InfusionDuration
'  InfusionDurationLow
'  Rate
'  RateMin
'  RateMax
'
'

Private Sub UCsetcolours()

Dim ctrl As Control
   
   For Each ctrl In Controls
'      Select Case ctrl.ForeColor
'         Case &H80000008
'         Case &H8000000A
'         Case &H80000005
'         End Select
      
'      ctrl.BackColor = &HFFE3D6     'main background
'      ctrl.BackColor = &HC0C0C0     'silver
'      ctrl.BackColor = &HB48246     'bit darker blue
'      ctrl.BackColor = &HA97868     'another blue
'      ctrl.BackColor = &HF0D3C6     'and another
'      ctrl.BackColor = &HE6E0B0     'Paler blue
      
      On Error GoTo ErrorHandler
      
      Select Case ctrl.BackColor
         Case &H80000008
''            Stop
         Case &H8000000A, &HC0C0C0
            ctrl.BackColor = &HFFE3D6
         Case &H8000000F
            ctrl.BackColor = &HFFE3D6
         Case &H80000005, &HFFFFFF
            'white is fine for text boxes
         Case Else
''            Debug.Print Hex(ctrl.BackColor), ctrl.name
''            Stop
         End Select
                  
      ctrl.FontName = "Arial"
         
Continue:
   Next
   
Exit Sub

ErrorHandler:
Resume Continue

End Sub



Private Sub CmdAdd_Click()
'22oct08 AK Added Import Product Check for Update Service View
'29Mar10 CKJ added d.livestockctrl = "Y" to import from other site & from DSS Master [RCN P0007 F0077938]
'03Aug10 XN If stores only product then can't default InUse to "S" instead set productID = 0 (F0088717)
'09Oct13 XN 75466 Add setting to allow some sites to add drug if they have dss on web
Dim strDesc As String
Dim strResult As String
Dim strAns As String
Dim strParams As String
Dim strLines() As String
Dim rsTMS As ADODB.Recordset
Dim blnNMPPSelected As Boolean
Dim strDialogueText As String
Dim strDrugMaster As String
Dim intFound As Integer
Dim lngCount As Long
Dim intNumofsites As Integer
Dim intCount As Integer
Dim lngResult As Long
Dim blnDuplicate As Boolean
Dim strDrugImport As String
Dim rsResult As ADODB.Recordset
Dim strDate As String

   ''popmessagecr "", "This functionality will be provided by DSS on the Web" '21Feb07 TH Such stupid wishfull thinking ....
      
   ''Exit Sub
   'lblTitle.Caption = "New Pharmacy Product"
   lngProductStockID = 0
   'OK, this is a bit of a mess but lets try asnd make the best of it.
   strDialogueText = TxtD(dispdata$ & "\StkMaint.ini", "Dialogue", "Medicinal product is one prescribed with a dose. Non-Medicinal product is prescribed without a dose. A stores only product is one that is not prescribed for a patient, such as bottles and cartons", "ProductAdd", 0)

   lblDialogue.Caption = strDialogueText


   k.escd = False
   
   'OK New Product. First Lets assertain if they want a medicinal product or not
   blnNMP = False
   blnStoresOnly = False '22Mar06 TH Added
   
   '22oct08 AK Added Import Product Check for Update Service View
   '09Oct13 XN 75466 Add setting to allow some sites to add drug if they have dss on web
   frmoptionset -1, "Choose Product Type"
   If UCase(SettingValueGet("System", "Reference", "DSSUpdateServiceInUse")) = "TRUE" And _
      UCase(SettingValueGet("Security", "Settings", "DSSMaster")) = "FALSE" And _
      TrueFalse(TxtD(dispdata$ & "\stkmaint.ini", "DSSLockDown", "N", "AllowAddProduct", 0)) = False Then       ' 09Oct13 XN 75466 Allow adding product if enabled for site
      frmoptionset -1, "Choose Product Type"
      frmoptionset 1, "Stores Only Product"                                         '09Jun10 XN  Allow user to add stores only product if DSS on web enabled (F0088717)
      frmoptionset 1, "Import Product from Master File"
      frmoptionset 1, "Import Product from Other Site"
      frmoptionshow "1", strResult
      If strResult <> "" Then strResult = CStr(CInt(strResult) + 2)                 '09Jun10 XN  Allow user to add stores only product if DSS on web enabled (F0088717)
   Else
      frmoptionset -1, "Choose Product Type"
      frmoptionset 1, "Medicinal Product"
      frmoptionset 1, "Non-Medicinal Product"
      frmoptionset 1, "Stores Only Product" '13Feb06 TH Added
      frmoptionset 1, "Import Product from Master File"
      frmoptionset 1, "Import Product from Other Site"
      frmoptionshow "1", strResult
   End If
   frmoptionset 0, ""
   lblDialogue.Caption = SiteName()    '20Jul12 CKJ Show site name when otherwise blank
   If Val(strResult) = 0 Then k.escd = True
   If Not k.escd Then
      If Val(strResult) = 2 Then blnNMP = True
      If Val(strResult) = 3 Then blnStoresOnly = True '13Feb06 TH Added
      BlankWProduct d
      gProductID = 0
      d.ProductID = 0 '13Feb06 TH Added
      If Val(strResult) = 4 Then 'Import from Master  05Dec06TH Added
         'Ok Here we switch sites to Use the DSS Master Site
         'Present findrdrug using new master param
         k.Max = 13
         k.min = 2
         'k.helpnum = 50
         InputWin "Import From Master File", "Enter item code       ", strDrugMaster, k
               
         If Not k.escd Then
            'dispdata$ = donordispdata$
            findrdrug strDrugMaster, 1, d, 0, intFound, 0, True, False      'is it found on other site?

            If intFound Then
               'Once we hve a drug we present it for editing WITHOUT an NSVCode
               'Switch site back to original
               '-------------------
               'OK Now we want to check that this DrugID is not already in use in the local file
               'If it is then we want to warn the user. If they continue we will set the drugid to a
               'nominal neg figure that we can pick up on the save so as to generate a new drugid
               '21Feb07 TH NO ! We need to check only if this is currently in the actual stock holding
               'If not then we import but overlay with the EXISTING siteproductData row. If the item does
               'already exist in the stock holding THEN we need to create a new siteproductdata row - this will
               'be a new item outside of DSS until the next check (could be an overlay or something)
               
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID)
               'lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDataCountbySiteID", strParams)
               lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductCountbySiteIDandDrugID", strParams) '21Feb07 TH Replaced. see note above
               
               If lngCount > 0 Then
                  askwin "Duplicate Product", "There is already a local stock line for this product." & crlf & crlf & "Are you sure you wish to continue", strAns, k
                  If strAns = "Y" Then
                     d.DrugID = 0
                  Else
                     k.escd = True
                  End If
               End If
                
               If Not k.escd Then '12Dec06 TH
                  'd.SisCode = "" '12Dec06 TH WHY - do it as per v8
                  'lngProductStockID = d.productstockID
                  gProductID = d.ProductID
                  '20Feb07 TH Added
                  ' OK We have selected a masterfile line with a valid DrugID, now we need to check that this line
                  ' does not pre-exist for this DSS Master Site. If it does then we need to load the existing fields ?? (should be locked down ?? BUT we MUST get SiteproductdataID to avoid dupes)
                  'GET the siteProductDataID for the masterSiteID if it exists
                  d.SiteProductDataID = 0 'This is to force save against correct DSSMasterSiteID
                  
                  strDate = Format(Now, "DDMMYYYY") '21Apr08 TH Added
                  d.datelastperiodend = strDate     '   "
                  d.livestockctrl = "Y"         '29Mar10 CKJ added [RCN P0007 F0077938]
                  
                  If d.DrugID <> 0 Then FillDrugParamswithDSSSiteData d, gDispSite, d.DrugID
               
                  ''d.SiteProductDataID = 0 'This is to force save against correct DSSMasterSiteID
                  'ViewSelected 1000, "Minimum Entry For New Product" 'Look this up !!!
                  ViewSelected 1003, "Minimum Entry For Imported Product" 'Look this up !!!
                  If d.productstockID <> 0 Then
                     SelectView
                     Lstbox.Visible = True
                     lblListboxHeader.Visible = True
                     'strDesc = d.storesdescription
                     'If Trim$(strDesc) = "" Then strDesc = d.Description  XN 4Jun15 98073 New local stores description
                                         strDesc = d.DrugDescription
                     If Trim$(strDesc) <> "" And Trim$(d.SisCode) <> "" Then
                        plingparse strDesc, "!"
                        lblTitle.Caption = Trim$(strDesc)
                     End If
                     
                     SelectView
                     LstProducts.Visible = False
                           
                     If blnNMPPSelected Then
                        LblProductLevel.Caption = "Non-Medicinal Product"
                        blnNMP = True
                     End If
                     CmdEdit.Visible = False
                     CmdAdd.Visible = False
                     '-------
                  End If
               End If
            End If
         End If
      
      ElseIf Val(strResult) = 5 Then 'Import from Other Site 22Apr07TH Added
         'Select Site
         ReadLocalSites
         intNumofsites = UBound(localsitenos)
         frmoptionset -1, "Select Site"
         For intCount = 1 To intNumofsites
            'Remove our own site and the master !!!
            'If localsitenos%(intCount) <> SiteNumber Or localsitenos%(intCount) = 999 Then
            frmoptionset 1, localsiteabb$(intCount)
            'End If
         Next
         frmoptionshow "1", strAns               'Preset 1st button 'On'
         frmoptionset 0, ""                    'Unload Form
         k.escd = (Trim$(strAns) = "")
         If Not k.escd Then
            'Change gDispSiteID
            SetDispdata localsitenos%(Val(strAns))
            'Present findrdrug using new master param
            k.Max = 13
            k.min = 2
            'k.helpnum = 50
            InputWin "Import From " & localsiteabb$(Val(strAns)), "Enter item code       ", strDrugImport, k
            If Not k.escd Then
               'Select item
               findrdrug strDrugImport, 1, d, 0, intFound, 0, False, False
            Else
               intFound = 0
            End If
            If intFound Then
            
               'Bring Item into editor, reset siteID and change fields as required.
               gProductID = d.ProductID
               SetDispdata 0
               'Do we already have this product on this site ?
               'If we do then we pop a message and then load the local item
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, d.SisCode) & _
                           gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, "") & _
                           gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 255, "") & _
                           gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, "") & _
                           gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 7, "") & _
                           gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, "") & _
                           gTransport.CreateInputParameterXML("bnf", trnDataTypeVarChar, 13, "") '29Apr08 TH Added

               Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWproductLookupbyCriteria", strParams)
               If rsResult.RecordCount > 0 Then blnDuplicate = True
               rsResult.Close
               Set rsResult = Nothing
               If blnDuplicate Then
                  If TrueFalse(TxtD(dispdata$ & "\StkMaint.ini", "Settings", "N", "AllowEditOnImportingDuplicate", 0)) Then
                     'strDesc = d.storesdescription
                     'If Trim$(strDesc) = "" Then strDesc = d.Description  XN 4Jun15 98073 New local stores description
                                         strDesc = d.DrugDescription
                     plingparse strDesc, "!"
                     popmessagecr "!Product Stock Editor", Trim$(strDesc) & " already exists in the current site. " & crlf & crlf & _
                     "Will show existing product for edit"
                     getdrug d, 0, 0, False
                  Else
                     'strDesc = d.storesdescription
                     'If Trim$(strDesc) = "" Then strDesc = d.Description XN 4Jun15 98073 New local stores description
                                         strDesc = d.DrugDescription
                     plingparse strDesc, "!"
                     popmessagecr "!Product Stock Editor", Trim$(strDesc) & " already exists in the current site. " & crlf & crlf & _
                     "Cannot import Item"
                     gProductID = 0
                     k.escd = True
                  End If
               Else
                  'Set the proper fields
                  d.supcode = ""
                  d.WSupplierProfileID = 0
                  d.productstockID = 0
                  d.createddate = ""
                  d.createdterminal = ""
                  d.createdtime = ""
                  d.CreatedUser = ""
                  d.modifieddate = ""
                  d.modifiedterminal = ""
                  d.modifiedtime = ""
                  d.modifieduser = ""
                  d.ordercycle = ""
                  d.outstanding = "0"
                  d.stocklvl = "0"
                  d.altsupcode = ""
                  d.contno = ""
                  d.contprice = "0"
                  d.cyclelength = "0"
                  strDate = Format(Now, "DDMMYYYY") '27Apr07 TH
                  d.datelastperiodend = strDate     '   "
                  d.lastissued = ""
                  d.lastordered = ""
                  d.laststocktakedate = ""
                  d.laststocktaketime = ""
                  d.LeadTime = "0"
                  d.loccode = ""
                  d.loccode2 = ""
                  d.lossesgains = "0"
                  d.reorderlvl = "0"
                  d.reorderpcksize = "0"
                  d.reorderqty = "0"
                  d.sislistprice = "0"
                  d.stocktakestatus = "0"
                  d.SupplierTradeName = ""
                  d.SuppRefno = ""
                  d.usethisperiod = "0"
                  d.livestockctrl = "Y"         '29Mar10 CKJ added [RCN P0007 F0077938]
               
               End If
               If Not k.escd Then
                  ViewSelected 1004, "Minimum Entry For Site Imported Product" 'Look this up !!!
                  If d.productstockID <> 0 Then
                     SelectView
                     Lstbox.Visible = True
                     lblListboxHeader.Visible = True
                     'strDesc = d.storesdescription
                     'If Trim$(strDesc) = "" Then strDesc = d.Description   XN 4Jun15 98073 New local stores description
                                         strDesc = d.DrugDescription
                     If Trim$(strDesc) <> "" And Trim$(d.SisCode) <> "" Then
                        plingparse strDesc, "!"
                        lblTitle.Caption = Trim$(strDesc)
                     End If
                     
                     SelectView
                     LstProducts.Visible = False
                           
                     If blnNMPPSelected Then
                        LblProductLevel.Caption = "Non-Medicinal Product"
                        blnNMP = True
                     End If
                     CmdEdit.Visible = False
                     CmdAdd.Visible = False
                     '-------
                  End If
               End If
            End If
            SetDispdata 0
         End If
      Else
                  ' 03Aug10 XN InUse can't be set to "S" anymore (F0088717)
'         If blnStoresOnly Then '15Mar06 TH Added
'            d.inuse = "S"
'            g_strTMDescription = "" '22Mar06 TH Blank descriptions
'         Else
'            d.inuse = "Y"
'         End If
         If blnStoresOnly Then '15Mar06 TH Added
            g_strTMDescription = "" '22Mar06 TH Blank descriptions
         End If
         d.inuse = "Y"
         ' End of F0088717
         d.cyto = "N"
         d.civas = "N"
         d.formulary = "Y"
         d.sisstock = "Y"
         d.livestockctrl = "Y"
         d.recalcatperiodend = "Y"
         d.vatrate = "1"
         d.ATC = "N"
         d.datelastperiodend = Format(Now, "ddmmyyyy")
         d.stocktakestatus = "0"
         If blnNMP Or blnStoresOnly Then
            If blnNMP Then
               'Right new medicinal product - here we will try and get the user to push in a therapeutic moiety
               ''popmessagecr "Stock Maintenance", "This functionality is not yet available"
               ''Exit Sub
               InputWin "Add New Non-Medicinal Product", "Enter Description for Non-Medicinal Product", strAns, k
               If Not k.escd Then
                  'Populate a list box from this with available Moieties (or straight through if on, msg if none)
                  strParams = gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 128, strAns)
                  Set rsTMS = gTransport.ExecuteSelectSP(g_SessionID, "pNMPPUnLinkedList", strParams)
                  
                 If rsTMS.RecordCount > 1 Then
                     'OK lets display the available TMs
                     Unload LstBoxFrm
                     LstBoxFrm.Lstbox.Clear
                     LstBoxFrm.Caption = "Select Non-Medicinal Product"
                     LstBoxFrm.lblHead = "ID     " & TB & "Non-Medicial Product" & Space$(34)
                     Do While Not rsTMS.EOF
                        LstBoxFrm.Lstbox.AddItem RtrimGetField(rsTMS!ProductID) & " " & TB & RtrimGetField(rsTMS!Description)
                        'LstBoxFrm.LstBox.ItemData(intCount) = RtrimGetField(rsTMS!ProductID)
                        'intCount = intCount + 1
                        rsTMS.MoveNext
                     Loop
                     LstBoxShow
                     If Len(LstBoxFrm.Tag) > 6 Then
                        ReDim strLines(2)
                        deflines LstBoxFrm.Tag, strLines(), TB, 1, 2
                        gProductID = CLng(strLines(1))
                        g_strTMDescription = strLines(2)
                        blnNMPPSelected = True
                     End If
                     Unload LstBoxFrm
                  ElseIf rsTMS.RecordCount = 1 Then
                     'lets go with this then
                     blnNMPPSelected = True
                     gProductID = RtrimGetField(rsTMS!ProductID)
      
                     g_strTMDescription = RtrimGetField(rsTMS!Description)
                     plingparse g_strTMDescription, "!"
                  Else
                     popmessagecr "!Pharmacy Product Editor", "No Non-Medicinal Products Found with this search criteria"
                  End If
                  rsTMS.Close
                  Set rsTMS = Nothing
               End If
            End If
            If blnNMPPSelected = True Or blnStoresOnly Then
               ''Lstbox.Visible = False
               BlankWProduct d
               'strDesc = Mid$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB), InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB, vbTextCompare))
               strDesc = g_strTMDescription 'strLines(2)
               BlankWProduct d
               d.inuse = "Y"
               d.cyto = "N"
               d.civas = "N"
               d.formulary = "Y"
               d.sisstock = "Y"
               d.livestockctrl = "Y"
               d.recalcatperiodend = "Y"
               d.vatrate = "1"
               d.ATC = "N"
               'dcopy = d      not needed now?
               ''d.Code = temp$
               'd.datelastperiodend = Format(Now, "mm/dd/yyyy")       '19Feb99 CFY Added     '21Apr99 CFY Corrected
               'd.datelastperiodend = Format(Now, "dd/mm/yyyy")       '21Apr99 CFY Added      '          "               '27Apr99 CFY Added
               d.datelastperiodend = Format(Now, "ddmmyyyy")
               d.stocktakestatus = "0"    '09Mar00 TH Added
                           'd.Description = Left$(strDesc & Space$(56), 56) XN 4Jun15 98073 New local stores description
               d.DrugDescription = Left$(strDesc & Space$(56), 56)
                           d.LabelDescription = Left$(strDesc & Space$(56), 56)
               d.storesdescription = Left$(strDesc & Space$(56), 56)
               If blnStoresOnly Then d.ProductID = 0                              '03Aug10 XN If stores only product then productID should be 0 (F0088717)
               ViewSelected 1000, "Minimum Entry For New Product" 'Look this up !!!
               If d.productstockID <> 0 Then
                  'assume saved
                  'CmdEdit.Visible = False
                  'CmdAdd.Visible = False
                  Lstbox.Visible = True
                  lblListboxHeader.Visible = True
                  'strDesc = d.storesdescription
                  'If Trim$(strDesc) = "" Then strDesc = d.Description XN 4Jun15 98073 New local stores description
                                  strDesc = d.DrugDescription
                  If Trim$(strDesc) <> "" And Trim$(d.SisCode) <> "" Then
                     plingparse strDesc, "!"
                     lblTitle.Caption = Trim$(strDesc)
                  End If
                  lngProductStockID = d.productstockID
                  '16Mar06 TH Added Block
                  gProductID = d.ProductID
                  SelectView
                  LstProducts.Visible = False
                  
                  If blnNMPPSelected Then
                     LblProductLevel.Caption = "Non-Medicinal Product"
                     blnNMP = True
                  ElseIf d.ProductID < 0 Then
                     LblProductLevel.Caption = "Stores Only Product"
                  End If
                  CmdEdit.Visible = False
                  CmdAdd.Visible = False
                  '-------
               End If
               
            End If
            '   End If
         Else
            'Right new medicinal product - here we will try and get the user to push in a therapeutic moiety
            strDialogueText = TxtD(dispdata$ & "\StkMaint.ini", "Dialogue", "This is the prescribed product form", "ProductAdd", 0)
            lblDialogue.Caption = strDialogueText
            InputWin "Add New Medicinal Product", "Enter Therapeutic Moiety for New product", strAns, k
            lblDialogue.Caption = SiteName()    '20Jul12 CKJ Show site name when otherwise blank
            If Not k.escd Then
               'Populate a list box from this with available Moieties (or straight through if on, msg if none)
               strParams = gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 50, strAns)
               Set rsTMS = gTransport.ExecuteSelectSP(g_SessionID, "pPRODUCT_MOIETIES_BY_NAME_NONXML", strParams)
               
               If rsTMS.RecordCount > 1 Then
                  'OK lets display the available TMs
                  Unload LstBoxFrm
                  LstBoxFrm.Lstbox.Clear
                  LstBoxFrm.Caption = "Select Therapeutic Moiety"
                  LstBoxFrm.lblHead = "ID     " & TB & "Therapeutic Moiety" & Space$(34)
                  Do While Not rsTMS.EOF
                     LstBoxFrm.Lstbox.AddItem RtrimGetField(rsTMS!ProductID) & " " & TB & RtrimGetField(rsTMS!Description)
                     'LstBoxFrm.LstBox.ItemData(intCount) = RtrimGetField(rsTMS!ProductID)
                     'intCount = intCount + 1
                     rsTMS.MoveNext
                  Loop
                  LstBoxShow
                  If Len(LstBoxFrm.Tag) > 6 Then
                     ReDim strLines(2)
                     deflines LstBoxFrm.Tag, strLines(), TB, 1, 2
                     gProductID = CLng(strLines(1))
                     g_strTMDescription = strLines(2)
                     blnTM = True
                  End If
                  Unload LstBoxFrm
               ElseIf rsTMS.RecordCount = 1 Then
                  'lets go with this then
                  blnTM = True
                  gProductID = RtrimGetField(rsTMS!ProductID)
               Else
                  popmessagecr "!Pharmacy Product Editor", "No Moieties Found with this search criteria"
               End If
               rsTMS.Close
               Set rsTMS = Nothing
               If blnTM = True Then
                  ''Lstbox.Visible = False
                  RefreshState g_SessionID, gProductID
               End If
            End If
         End If
      End If
''      CmdAdd.Visible = False
''      Else
''      CmdAdd.Visible = True
''      End If
   End If
'CmdEdit.Visible = False

End Sub

Private Sub cmdCancel_Click()
   Lstbox.Clear
   Lstbox.Refresh
   '17Jan06 TH Added
   LstProducts.Clear
   LstProducts.Refresh
   LstProducts.Visible = True '27Apr07 TH Added
   
   lblDialogue.Caption = SiteName()    '20Jul12 CKJ Show site name when otherwise blank
   
   blnAMPP = False
   blnTM = False
   '---------------
   g_strTMDescription = "" '16Mar06 TH Added
   blnStoresOnly = False
   Me.RefreshState g_SessionID, 0
End Sub

Private Sub CmdEdit_Click()

Dim rsTMS As ADODB.Recordset
Dim lngFound As Long
Dim strNSVCode As String
Dim strDesc As String
Dim strAns As String
Dim strDrug As String
Dim intNewDrug As Integer
Dim found As Integer


   lblDialogue.Caption = SiteName()    '20Jul12 CKJ Show site name when otherwise blank
   BlankWProduct d
   strAns = ""
   k.Max = 13
   k.min = 0            'was 2
   'k.helpnum = 1020
   InputWin "Edit Pharmacy Product", "Enter lookup code", strAns, k

   If k.escd Then
      Exit Sub
   Else
      strDrug = strAns
      intNewDrug = 2                             ' allows entry of new ASC code
      findrdrug strDrug, 1, d, lngFound, found, intNewDrug, 0, False     ' 01Jun02 ALL/ATW
      If Not k.escd And Not found Then
         'If intNewDrug = False Then  'Or index = 0
            popmessagecr "Stock Maintenance", "Code '" & strAns & "' was not found"
            k.escd = True
         'End If
      End If
   End If
   If lngFound > 0 And Not k.escd Then
      lngProductStockID = d.productstockID
      gProductID = d.ProductID
      SelectView
      LstProducts.Visible = False
      'strDesc = d.storesdescription
      'If Trim$(strDesc) = "" Then strDesc = d.Description  XN 4Jun15 98073 New local stores description
          strDesc = d.DrugDescription
      plingparse strDesc, "!"
      lblTitle.Caption = Trim$(strDesc)
      'Findout if this is a PP or NMP
      If isNMPP(d.ProductID) Then
          LblProductLevel.Caption = "Non-Medicinal Product"
         'blnAMPP = False

            blnNMP = True
      ElseIf d.ProductID <= 0 Then
      'ElseIf d.ProductID < 0 Then
         LblProductLevel.Caption = "Stores Only Product"
         lblDialogue.Caption = "A Stores only product can only be ordered, received and issued through the Pharmacy stores and ward stock modules. They cannot be dispensed to an individual named patient"
      Else
         LblProductLevel.Caption = "Medicinal Product"
      End If
      blnAMPP = isAMPP(d.ProductID)
      If (Not blnNMP) And (Not blnAMPP) Then
         blnTM = True
      End If
      CmdEdit.Visible = False
      CmdAdd.Visible = False
   End If



''lngProductStockID = 0
''Set rsTMS = GetProductStockRowsbyTMProductID(gProductID)
''         If rsTMS.RecordCount > 0 Then
''            Do While Not rsTMS.EOF
''               LstBoxFrm.LstBox.AddItem RtrimGetField(rsTMS!SisCode) & TB & RtrimGetField(rsTMS!Description) & TB & RtrimGetField(rsTMS!convfact) & TB & RtrimGetField(rsTMS!dosesperissueunit) & " " & RtrimGetField(rsTMS!DosingUnits)
''
''               rsTMS.MoveNext
''            Loop
''            LstBoxShow
''            If Len(LstBoxFrm.Tag) > 6 Then
''               strNSVCode = Left(LstBoxFrm.Tag, 7)
''               d.SisCode = strNSVCode
''               getdrug d, 0, lngFound, False
''               If lngFound > 0 Then
''                  lngProductStockID = d.ProductStockID
''                  SelectView
''                  strDesc = d.storesdescription
''                  plingparse strDesc, "!"
''                  lblTitle.Caption = Trim$(strDesc)
''                  CmdEdit.Visible = False
''                  CmdAdd.Visible = False
''               End If
''            End If
''            Unload LstBoxFrm
''         End If
''rsTMS.Close
''Set rsTMS = Nothing
End Sub

Private Sub LstBox_Click()
''Dim ViewNumber As Integer
''Static LastView As Integer
''Const Stkmaint$ = "\stkmaint.ini"
''Dim ViewName$
''Dim NumOfEntries As Integer
''Dim intloop As Integer
''Dim tmp$
''Dim ptr As Integer
''Dim Info$, Summary$
''Dim SomeChange As Boolean
''Dim dcop As DrugParameters
''Dim dwas$
''Dim TotFields As Integer
''Dim numoflines As Integer
''
''ReDim lines$(2)
''
''
''
''
''
''ViewNumber = LstBox.ItemData((LstBox.ListIndex))
''tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", Format$(ViewNumber), 0)
''      deflines tmp$, lines$(), ",", 0, numoflines
''
''ViewName$ = lines$(0)
''ViewSelected ViewNumber, ViewName$


''           TotFields = Val(TxtD(dispdata$ & Stkmaint$, "data", "0", "Total", 0))
''         If TotFields = 0 Then
''               ''popmessagecr "Error", "Cannot find Stock Maintenance configuration file; " & Stkmaint$
''               Exit Sub
''            End If
''
''         ReDim presentent$(TotFields)
''
''   dcop = d
''   LSet r = d
''   dwas$ = Left$(r.record, Len(d))
''   StructToArray
''   Summary$ = ""
''
''
''            If Not k.escd Then                                      '??jul99 AE added if...
''                  ''setmodulardrug d
''                  LastView = ViewNumber
''                  ConstructView dispdata$ & Stkmaint$, "Views", "Data", ViewNumber, "0", 0, ViewName$, NumOfEntries
''                  Ques.Caption = ViewName$ & " - Number" & Str$(LstBox.ListIndex)
''                  For intloop = 1 To NumOfEntries
''                      QuesSetText intloop, RTrim$(presentent$(Val(Ques.lblDesc(intloop).Tag)))
''                  Next
''                  QuesMakeCtrl 0, 1000                 '12Aug97 CKJ Show print button
''
''                  QuesCallbackMode = 10
''                  QuesShow NumOfEntries                '<== Edit now
''                  QuesCallbackMode = 0
''
''                  For intloop = 1 To NumOfEntries
''                     tmp$ = QuesGetText(intloop)
''                     ptr = Val(Ques.lblDesc(intloop).Tag)
''                     If tmp$ <> RTrim$(presentent$(ptr)) Then
''                           '17Jul97 CKJ Add cr if line is long
''                           'info$ = pad$((Ques.lblDesc(i)), 25) & " " & "Was : '" & RTrim$(presentent$(Ptr)) & "' Now : '" & tmp$ & "'"
''                           info$ = pad$((Ques.lblDesc(intloop)), 25) & " " & "Was : '" & RTrim$(presentent$(ptr)) & "'"
''                           If Len(RTrim$(presentent$(ptr))) + Len(tmp$) > 50 Then info$ = info$ & cr & Space$(25)
''                           info$ = info$ & " Now : '" & tmp$ & "'"
''                           Summary$ = Summary$ & info$ & cr
''                           SomeChange = True
''                           'log changes here
''                           WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & " " & info$
''                        End If
''                     presentent$(ptr) = tmp$
''                  Next
''                  'If Len(Summary$) Then popmessagecr "", Summary$    'for debugging
''                  Unload Ques
''                  '''If FixedView Then ViewNumber = 0     'exit
''
''                  '09Jul99 AE Added block IF
''''                  If PkView Then
''''                        If Not SomeChange Then
''''                              RegEdited = False                        'Clear if no changes made, so we can view
''''                              ClearDkinStruct                          'another regimen
''''                              StructtoArrayKinetics                    '   "
''''                           Else
''''                              ArrayToKineticsStruct                    'otherwise, store the changes
''''                           End If                                      '   "
''''                     End If                                            '   "
''''                  '---------
''               End If                                                  '??Jul99AE Added

End Sub

Sub SelectView()
'find categories & offer a choice to the user, read from stkmaint.ini
'secondary barcodes are offered at the end of the list
' returns ViewChosen = 0 user escaped
'                      1 to n for View chosen
'                     -1 secondary barcodes
' 8Apr97 CKJ Added SuppInfo
'15Oct97 CKJ Added log view to list
'??Jul99 AE  Additions; only show pharmacokinetics view if it is enabled in the licence file
'09Oct13 XN 75466 Only show Update Service View if DSS drug

'!!** add passwording

Dim found%, TotCats%, i%, tmp$, Numoflines%
Const Stkmaint$ = "\stkmaint.ini"

    Lstbox.Clear     '27Mar06 TH
    Lstbox.Refresh   '   "
 
    ReDim lines$(2)
    TotCats = Val(TxtD(dispdata$ & Stkmaint$, "views", "0", "Total", found))
   'If TotCats = 0 Then
   '      popmessagecr "Error", "Cannot find Stock Maintenance configuration file; " & Stkmaint$
   '      Exit Sub
   '   End If

   'Me.Caption = "Stock Maintenance"
   'Me.lblTitle = SuppInfo$ & cr & "Select category to view" & cr
   'Me.lblHead = ""
   
    For i = 1 To TotCats
        tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", Format$(i), found)
        deflines tmp$, lines$(), ",", 0, Numoflines
        Lstbox.AddItem lines$(0)
        Lstbox.ItemData(Lstbox.NewIndex) = i
    Next

   'If PKEnabled() Then
   '      tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", "1002", found)        '       "
   '      If found Then                                                         '       "
   '            deflines tmp$, lines$(), ",", 0, numoflines                     '       "
   '            LstBoxFrm.LstBox.AddItem lines$(0)                              '       "
   '            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 1002     '       "
   '         End If                                                             '       "
   '   End If                                                                   '       "
   'Unload frmMsgWin                                                            '       "
   
    '23Jul12 CKJ Added block for robot configuration    TFS37640
    deflines TxtD(dispdata$ & Stkmaint$, "views", "", 1010, found), lines$(), ",", 0, Numoflines
    Lstbox.AddItem lines$(0)
    Lstbox.ItemData(Lstbox.NewIndex) = 1010
    Lstbox.AddItem "Send Product Information to Robot"
    Lstbox.ItemData(Lstbox.NewIndex) = -14
    Lstbox.AddItem "Print Shelf Edge Label"
    Lstbox.ItemData(Lstbox.NewIndex) = -15
    '---
    
    Lstbox.AddItem "Secondary barcodes"
    Lstbox.ItemData(Lstbox.NewIndex) = -1
    Lstbox.AddItem "View issues/returns for this item"     '15Oct97 CKJ Added
    Lstbox.ItemData(Lstbox.NewIndex) = -2        '   "
    Lstbox.AddItem "View orders/receipts for this item"    '   "
    Lstbox.ItemData(Lstbox.NewIndex) = -3        '   "
    Lstbox.AddItem "Edit Supplier Profiles"    '   "
    Lstbox.ItemData(Lstbox.NewIndex) = -4
    Lstbox.AddItem "Set Primary Supplier"    '   "
    Lstbox.ItemData(Lstbox.NewIndex) = -5
    Lstbox.AddItem "Delete Supplier Profile"    '   "
    Lstbox.ItemData(Lstbox.NewIndex) = -6
   
   '22oct08 AK Added DSS Master setting check to add Update Service View (F0018781)
   '10Jun10 XN Got below to use the DSSUpdateServiceInUse instead of the DSSMaster flag (F0088717)
   '09Oct13 XN 75466 Only show Update Service View if DSS drug
    If d.DrugID < 10000000 And UCase(SettingValueGet("System", "Reference", "DSSUpdateServiceInUse")) = "TRUE" Then
        Lstbox.AddItem "Update Service View"
        Lstbox.ItemData(Lstbox.NewIndex) = -7
    End If
    
    '15Nov11 TH Ported - more to make future numbering easier than to allow pbs before full merge
    If Val(TxtD(dispdata$ & "\patbill.ini", "PatientBilling", "", "BillingType", 0)) = 2 Then
       Lstbox.AddItem "Add PBS Mappings" '23oct08 AK Added F0033581
       Lstbox.ItemData(Lstbox.NewIndex) = -8 '23oct08 AK Added F0033581
       Lstbox.AddItem "Delete PBS Mappings" '23oct08 AK Added F0033581
       Lstbox.ItemData(Lstbox.NewIndex) = -9
    End If
    
    '15Nov11 TH PCT Work (TFS19196)
    If TrueFalse(TxtD(dispdata$ & "\patbill.ini", "PCT", "N", "PCTBilling", 0)) Then 'DEBUG - switched on remember to clear this for production !!!!
       Lstbox.AddItem "Add PCT Mappings"
       Lstbox.ItemData(Lstbox.NewIndex) = -10
       Lstbox.AddItem "View PCT Mappings"
       Lstbox.ItemData(Lstbox.NewIndex) = -11
       Lstbox.AddItem "Delete PCT Mappings"
       Lstbox.ItemData(Lstbox.NewIndex) = -12
       Lstbox.AddItem "Switch PCT Primary Ingredient"
       Lstbox.ItemData(Lstbox.NewIndex) = -13
    End If
    '----------
    
   ''If FullAccess And fileexists(dispdata$ & "\restrict.idx") Then                   '15Jul98 CKJ Added
   ''      Me.LstBox.AddItem "Set General Import Restrictions for this item"   '   "
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -4                  '   "
   ''      Me.LstBox.AddItem "Set Specific Import Restrictions for this item"  '   "
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -5                  '   "
   ''  End If                                                                        '   "

   ''If ExternalPricingActive() Then ' 02May02 ATW Add extra option for external price DB
   ''      Me.LstBox.AddItem "Adjust catalogue price"
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -6
   ''   End If
         
   ''For i = 0 To Lstbox.ListCount - 1
   ''   If Lstbox.ItemData(i) = DefaultView Then
   ''         Lstbox.ListIndex = i
   ''      End If
   ''Next
   ''LstBoxShow
   ''ViewChosen = 0
   ''If Me.LstBox.ListIndex > -1 Then`
   ''      ViewChosen = Me.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
   ''   End If
   '''Unload LstBoxFrm
    Lstbox.ListIndex = 0 '27Mar06 TH Added
    'LstBox.Selected(0) = True
    On Error Resume Next    '08oct08 CKJ added
    If LstProducts.Visible = False Then Lstbox.SetFocus '12nov08 AK Added lstProducts.Visible check to ensure LstBox is on top
    On Error GoTo 0         '   "
   
End Sub

Private Sub LstBox_DblClick()

Static LastView As Integer

Dim ViewNumber As Integer
Dim Viewname$
Dim NumOfEntries As Integer
Dim intloop As Integer
Dim tmp$
Dim ptr As Integer
Dim Info$, Summary$
Dim SomeChange As Boolean
Dim dcop As DrugParameters
Dim dwas$
Dim TotFields As Integer
Dim Numoflines As Integer

Const Stkmaint$ = "\stkmaint.ini"

   ReDim lines$(2)

   If Lstbox.ListIndex > -1 Then
      ViewNumber = Lstbox.ItemData((Lstbox.ListIndex))
      tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", Format$(ViewNumber), 0)
      deflines tmp$, lines$(), ",", 0, Numoflines
           
      Viewname$ = lines$(0)
      ViewSelected ViewNumber, Viewname$
   End If
   
   On Error Resume Next    '08oct08 CKJ added
   Lstbox.SetFocus         '   "
   On Error GoTo 0         '   "

End Sub

Private Sub Lstbox_KeyDown(KeyCode As Integer, Shift As Integer)

'MsgBox LstProducts.ListIndex

'MsgBox LstProducts.ListIndex
If KeyCode = 13 Then LstBox_DblClick
MousePointer = STDCURSOR

End Sub

Private Sub LstBox_KeyUp(KeyCode As Integer, Shift As Integer)
''If KeyCode = 13 Then
''LstProducts_Click
''MsgBox LstProducts.ListIndex
''LstProducts_DblClick
''End If
End Sub

Private Sub LstProducts_DblClick()
Dim rsTMS As ADODB.Recordset
Dim lngFound As Long
Dim strNSVCode As String
Dim strDesc As String
Dim lngTMProductID As Long
Dim strTMDescription As String
Dim strParams As String
Dim intCount As Integer
Dim lclProductID As Long
Dim strLines() As String
Dim strAns As String
Dim blnCopyProduct As Boolean
Dim strDrug As String
Dim found As Integer
Dim intNewDrug As Integer
'Dim lclProductID  As Long
Dim strMsg As String
'Dim strAns As String
Dim strDialogueText As String


   If LstProducts.ListCount = 0 Then Exit Sub '27Apr07 TH Added

   lblTitle.Caption = ""
   k.escd = False
   lclProductID = gProductID
   ''If LstProducts.ItemData(LstProducts.ListIndex) > 1 Then
   If LstProducts.ListIndex > 1 Then
      'd.ProductStockID = LstProducts.ItemData(LstProducts.ListIndex)
      ''Else
      strMsg = "This will edit the existing stock line for " & Left$(LstProducts.Text, 7) & "." & crlf & _
      "If you wish to Add or Copy an existing product definition for a new product line then" & crlf & _
      "please cancel and select the appropriate option from the list." & crlf & crlf & _
      "To edit the existing stock line press Yes"
         
      strMsg = TxtD(dispdata$ & "\stkmaint.ini", "Maintenance", strMsg, "EditDrugfromMoietyMsg", 0)
      strAns = "Y"
      askwin "?Stock Maintenance", strMsg, strAns, k
      If strAns = "Y" And Not k.escd Then
      
         BlankWProduct d
         getdrug d, LstProducts.ItemData(LstProducts.ListIndex), 0, False
         gProductID = d.ProductID
         
         LstProducts.Visible = False
         'strDesc = d.storesdescription
         'If Trim$(strDesc) = "" Then strDesc = d.Description XN 4Jun15 98073 New local stores description
                 strDesc = d.DrugDescription
         plingparse strDesc, "!"
         lblTitle.Caption = Trim$(strDesc)
         SelectView
      End If
   ElseIf LstProducts.ListIndex < 2 Then
      If LstProducts.ListIndex = 1 Then blnCopyProduct = True
      'Here we are adding a Product. We need to allow the user to chose a suitable match
      'Either the original TM or a currently unmatched AMPP
      'Get the TM description and ProductID
      
      lngProductStockID = 0
      strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID)
      
      'Set rsTMS = GetNonPharmacyAMPPbyTMProductID(gProductID)
      Set rsTMS = gTransport.ExecuteSelectSP(g_SessionID, "pAMPPUnLinkedList", strParams)
      
      ''If rsTMS.RecordCount > 0 Then
         Unload LstBoxFrm    '24Apr06 TH
         LstBoxFrm.Lstbox.Clear
         LstBoxFrm.Caption = "Select Actual Medicinal Packaged Product"
         LstBoxFrm.lblHead = "ID     " & TB & "AMPP Description" & Space$(34) & TB & "Manufacturer" & Space$(80)
         Do While Not rsTMS.EOF
            LstBoxFrm.Lstbox.AddItem RtrimGetField(rsTMS!ProductID) & TB & RtrimGetField(rsTMS!Description) & TB & RtrimGetField(rsTMS!Manufacturer)
            LstBoxFrm.Lstbox.ItemData(intCount) = RtrimGetField(rsTMS!ProductID)
            rsTMS.MoveNext
         Loop
         LstBoxFrm.Lstbox.AddItem Format$(gProductID) & TB & g_strTMDescription & TB & "GENERIC GENERIC"
         LstBoxShow
         If Len(LstBoxFrm.Tag) > 6 Then
            'strNSVCode = Left(LstBoxFrm.Tag, 7)
            'd.SisCode = strNSVCode
            'get the Id from the tag cos the library is a bag of ...
            ReDim strLines(3)
            deflines LstBoxFrm.Tag, strLines(), TB, 1, 3
            Unload LstBoxFrm
            'gProductID = CLng(Left$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB)))
            lngTMProductID = gProductID
            gProductID = CLng(strLines(1))
            If isTM(gProductID) Then
               strAns = "N"
               askwin "!New Pharmacy Product", "You are attempting to match against a Therapeutic Moiety." & crlf & crlf & "Are you certain that this is correct ?", strAns, k
               If Not strAns = "Y" Then
                  k.escd = True
               Else
                  blnTM = True
               End If
            Else
               blnAMPP = True
            End If
            If Not k.escd Then
               
               If blnCopyProduct Then
                  'Here we need to get the template product to prepopulate the editor
                  strDialogueText = TxtD(dispdata$ & "\StkMaint.ini", "Dialogue", "Select current product to copy from", "ProductCopy", 0)
                  lblDialogue.Caption = strDialogueText
                  Do
                     BlankWProduct d
                     strAns = ""
                     k.Max = 13
                     k.min = 2
                     InputWin "Copy Product Definition", "Enter lookup code", strAns, k
                     strDrug = strAns
                     intNewDrug = 2
                     findrdrug strDrug, 1, d, lngFound, found, intNewDrug, False, False
                     If Not k.escd And Not found Then
                        If intNewDrug = False Then  'Or index = 0
                           popmessagecr "Stock Maintenance", "Code '" & strAns & "' was not found"
                           k.escd = True
                        End If
                     End If
                  Loop While (Not found) And (Not k.escd)
                  lblDialogue.Caption = SiteName()    '20Jul12 CKJ Show site name when otherwise blank
                  
                  If (Not k.escd) And (found) Then
                     d.inuse = "N"
                     d.deluserid = ""
                     d.stocklvl = ""
                     d.indexed = "0"
                     d.datelastperiodend = Format(Now, "ddmmyyyy")
                     d.lossesgains = 0
                     d.outstanding = 0
                     d.usethisperiod = 0
                     d.barcode = ""
                     d.lastissued = ""
                     d.lastordered = ""
                     d.stocktakestatus = "0"
                     d.ProductID = gProductID
                     d.productstockID = 0
                     d.SiteProductDataID = 0
                     d.SisCode = ""
                     d.DrugID = 0 '20Feb07 TH
                  End If
               Else
                  BlankWProduct d
                  'strDesc = Mid$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB), InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB, vbTextCompare))
                  strDesc = strLines(2)
                  
                  BlankWProduct d
                  d.inuse = "Y"
                  d.cyto = "N"
                  d.civas = "N"
                  d.formulary = "Y"
                  d.sisstock = "Y"
                  d.livestockctrl = "Y"
                  d.recalcatperiodend = "Y"
                  d.vatrate = "1"
                  d.ATC = "N"
                  d.datelastperiodend = Format(Now, "ddmmyyyy")
                  d.stocktakestatus = "0"    '09Mar00 TH Added
                  If TrueFalse(TxtD(dispdata$ & "\StkMaint.ini", "Settings", "Y", "UseDescriptionForNewProduct", 0)) Then '05Nov07 TH Changed default
                     'd.Description = Left$(strDesc & Space$(56), 56) XN 4Jun15 98073 New local stores description
                                         d.DrugDescription = Left$(strDesc & Space$(56), 56)
                                         d.LabelDescription = Left$(strDesc & Space$(56), 56)
                     d.storesdescription = Left$(strDesc & Space$(56), 56)
                  End If
               End If
               If Not k.escd Then
                  ViewSelected 1000, "Minimum Entry For New Product"
                  'getdrug d, lclProductID, lngFound, False
                  'If lngFound > 0 Then
                  If Not k.escd Then
                     'lngProductStockID = 0   '07Dec05 TH Removed
                     LstProducts.Visible = False
                     'SelectView
                     'strDesc = d.storesdescription
                     plingparse strDesc, "!"
                     lblTitle.Caption = Trim$(strDesc)
                  Else
                     gProductID = lngTMProductID
                     LstProducts.Visible = True
                  End If
               End If
            End If
         End If
      ''Else
      ''   Unload LstBoxFrm
      ''End If
      
      rsTMS.Close
      Set rsTMS = Nothing
   
   End If
   If k.escd Then gProductID = lclProductID
End Sub

Private Sub LstProducts_KeyPress(KeyAscii As Integer)

   If KeyAscii = 13 Then LstProducts_DblClick '24Apr06 TH Added
   
End Sub

Private Sub UserControl_Show()
'Fires in design mode and at run time

   StoreUCHwnd UserControl.Hwnd     '12Jul12 CKJ for MechDisp
   
End Sub

Sub SetSiteLine(ctl As Object, ByVal InactiveVisible As Boolean)
'02Jul12 CKJ written to mirror (and use) StoresMenuBarColour      TFS39406
   
Dim enable As Boolean
Dim strColour As String
Dim Colour As Long
   
   On Error GoTo SetSiteLine_Error
   
   enable = False                                                    'assume no connection
   If Not gTransport Is Nothing Then                                 'transport object exists
      'If Not gTransport.Connection Is Nothing Then                  'and is connected
      If Not gTransportConnectionIsNothing() Then                    'and is connected    '04Oct12 CKJ use wrapper TFS44503
         'If gTransport.Connection.State = adStateOpen Then          'and ready for use
         If gTransportConnectionState() = adStateOpen Then           'and ready for use   '04Oct12 CKJ use wrapper TFS44503
            enable = True                                            'proceed
         End If
      End If
   End If
      
   If enable Then
      strColour = TxtD(dispdata$ & "\siteinfo.ini", "", "", "DispensingSiteColour", 0)     'override if desired
      If Len(strColour) = 0 Then
         strColour = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StoresMenuBarColour", 0)   'default uses Stores setting
      End If
      
      If Len(strColour) Then
         Select Case LCase$(strColour)
            Case "black":   Colour = ColorConstants.vbBlack
            Case "blue":    Colour = ColorConstants.vbBlue
            Case "cyan":    Colour = ColorConstants.vbCyan
            Case "green":   Colour = ColorConstants.vbGreen
            Case "magenta": Colour = ColorConstants.vbMagenta
            Case "red":     Colour = ColorConstants.vbRed
            Case "white":   Colour = ColorConstants.vbWhite
            Case "yellow":  Colour = ColorConstants.vbYellow
            Case Else
               If IsNumeric(strColour) Then
                  Colour = CLng(strColour)
               Else
                  enable = False
               End If
            End Select
      Else
         enable = False
      End If
   End If
    
SetSiteLine_WayOut:
   On Error Resume Next
   If enable Then
      ctl.BorderColor = Colour
      ctl.BorderWidth = Val(TxtD(dispdata$ & "\siteinfo.ini", "", "3", "DispensingSiteColourWidth", 0))
      ctl.Visible = True
   Else
      ctl.Visible = InactiveVisible
      ctl.BorderWidth = 1
      ctl.BorderColor = ColorConstants.vbWhite
   End If
   On Error GoTo 0
   
Exit Sub

SetSiteLine_Error:
   enable = False
Resume SetSiteLine_WayOut

End Sub

Function SiteName() As String
'20Jul12 CKJ written

   If SiteNumber Then
      SiteName = hospabbr$ & "  (" & Format$(SiteNumber) & ")" & crlf & crlf & hospname1$ & crlf & hospname2$
   Else
      SiteName = ""
   End If
   
End Function

Public Function SendToRobot(ByVal sessionID As Long, ByVal NSVCode As String) As Boolean
'06Feb14 XN 56701 Added send to robot function for Web version of product editor

Dim rs As ADODB.Recordset
Dim strParams As String
Dim lngFound As Long
Dim intNewDrug As Integer
Dim found As Integer
Dim ErrNumber As Long, ErrDescription As String

Const ErrSource As String = PROJECT & ".SendToRobot"

   On Error GoTo ErrorHandler
   
   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   ' Get user info
   gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
   strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            UserID = RtrimGetField(rs!initials)
            UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
         End If
         rs.Close
      End If
      Set rs = Nothing
   End If
   ReadSiteInfo
   Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0
   UserControlIsAlive = 1

   ' Load drug
   BlankWProduct d
   findrdrug NSVCode, 1, d, lngFound, found, intNewDrug, 0, False
   If Not k.escd And Not found Then
        popmessagecr "Stock Maintenance", "Code '" & NSVCode & "' was not found"
        k.escd = True
   End If

   ' Send to robot
   If lngFound > 0 And Not k.escd Then
      gProductID = d.ProductID
      SendRobotProductData d
   End If
   
   'Reset Parent form handler
   ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

Cleanup:
   If ErrNumber Then
      On Error Resume Next
      rs.Close
      Set rs = Nothing
      On Error GoTo 0
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
   End If
   
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function
