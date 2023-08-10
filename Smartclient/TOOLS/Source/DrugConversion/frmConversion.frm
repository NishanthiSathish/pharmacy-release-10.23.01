VERSION 5.00
Begin VB.Form frmConversion 
   Caption         =   "Drug Conversion Utility"
   ClientHeight    =   10710
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9240
   LinkTopic       =   "Form2"
   ScaleHeight     =   10710
   ScaleWidth      =   9240
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdBNF 
      Caption         =   "Import BNF"
      Height          =   1095
      Left            =   5640
      TabIndex        =   14
      Top             =   9000
      Width           =   2655
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Import Barcodes"
      Height          =   495
      Left            =   4560
      TabIndex        =   13
      Top             =   8160
      Width           =   2175
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Enabled         =   0   'False
      Height          =   1455
      Left            =   720
      TabIndex        =   12
      Top             =   7560
      Width           =   2895
   End
   Begin VB.CommandButton cmdTemplateCheck 
      Caption         =   "Check Templates"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   975
      Left            =   4560
      TabIndex        =   11
      Top             =   6480
      Width           =   3495
   End
   Begin VB.CommandButton cmdDosingChanges 
      Caption         =   "Change Dosing Details"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   855
      Left            =   480
      TabIndex        =   10
      Top             =   6240
      Width           =   3135
   End
   Begin VB.CommandButton cmdNMP 
      Caption         =   "Non Medicinal Drug Import"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   855
      Left            =   4560
      TabIndex        =   9
      Top             =   4560
      Width           =   3255
   End
   Begin VB.TextBox txtSession 
      Height          =   495
      Left            =   3360
      TabIndex        =   8
      Text            =   "258"
      Top             =   1800
      Width           =   1695
   End
   Begin VB.TextBox txtConnect 
      Height          =   495
      Left            =   3360
      MousePointer    =   1  'Arrow
      TabIndex        =   5
      Text            =   "server=Tony-H;database=debug4;uid=sys;password=ascribe;provider=sqloledb;"
      Top             =   960
      Width           =   5655
   End
   Begin VB.CommandButton cmdUpdate 
      Caption         =   "Medicinal Drug Import"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   855
      Left            =   480
      TabIndex        =   4
      Top             =   4560
      Width           =   3135
   End
   Begin VB.TextBox txtDrive 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3360
      TabIndex        =   3
      Text            =   "D"
      Top             =   3600
      Width           =   375
   End
   Begin VB.TextBox txtSite 
      Height          =   495
      Left            =   3360
      TabIndex        =   0
      Text            =   "884"
      Top             =   2640
      Width           =   2055
   End
   Begin VB.Label lblSession 
      Caption         =   "Session ID"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   240
      TabIndex        =   7
      Top             =   1800
      Width           =   2895
   End
   Begin VB.Label Label3 
      Caption         =   "Connection String"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   6
      Top             =   960
      Width           =   2895
   End
   Begin VB.Label Label2 
      Caption         =   "Dispdata Drive"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   2
      Top             =   3600
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "Current Site Number"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   1
      Top             =   2640
      Width           =   2895
   End
End
Attribute VB_Name = "frmConversion"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBNF_Click()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSql As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim strParams As String
Dim lngProductID As Long
Dim lngProductStockID As Long
Dim blnCyto As Boolean
Dim gLocationId As Long
Dim lngMasterSiteID As Long
Dim lngKeep As Long
Dim lngCode As Long
Dim blnUpdate As Boolean


      ConnectionString = txtConnect.Text
      
      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      'Set gTransport = New PharmacyData.Transport
      Set gTransport = New R9604PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSitenumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSitenumber & "\NOD" For Input As #fil Len = 16
      Input #fil, nod&
      Close #fil

      lngFilePointerOut = FreeFile
      Open FILE$ For Binary Access Read Shared As lngFilePointerOut Len = 1024
    
            
      numofrecs = nod
      For intloop = 0 To numofrecs
         lngProductStockID = 0
         blnUpdate = False
         DoEvents
         Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
            
         'First we get an associated ProductId which we can use to populate the next records.
                    
         strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
                     gTransport.CreateInputParameterXML("BNF", trnDataTypeVarChar, 13, prod.bnf)
                     
          
         lngProductID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWProductStockLinkBNFAlterbySiscode", strParams)
            
         
      Next
          
      MsgBox "All Done"
End Sub

Private Sub cmdDosingChanges_Click()
Dim rs As ADODB.Recordset
Dim strParams As String
Dim ConnectionString As String
Dim strSql As String
Dim g_SessionID As Long
Dim g_adoCn As ADODB.Connection
Dim gTransport As PharmacyData.Transport
Dim lngOK As Long



ConnectionString = txtConnect.Text

g_SessionID = Val(txtSession.Text)

Set g_adoCn = New ADODB.Connection
g_adoCn.ConnectionString = ConnectionString
g_adoCn.Open

' gTransport.Connection.Open(
Set gTransport = New PharmacyData.Transport
Set gTransport.Connection = g_adoCn

'Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pTEMPgetDosingChangesNEW", "")

'If rs.RecordCount > 0 Then
''PrintformV , DosingUnits, DPSform
'Do While Not rs.EOF
'
'   strParams = gTransport.CreateInputParameterXML("Productid", trnDataTypeint, 4, rs!ProductID) & _
'               gTransport.CreateInputParameterXML("dosesperissueunit", trnDataTypeFloat, 8, rs!doseperissueunit)
'
'   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pTEMPUpdateDoses", strParams)
''
''
'
'   rs.MoveNext
'Loop
'End If

'rs.Close
'Set rs = Nothing

Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pTEMPgetConvfactChangesNEW", "")

If rs.RecordCount > 0 Then
'PrintformV , DosingUnits, DPSform
Do While Not rs.EOF
   
   strParams = gTransport.CreateInputParameterXML("nsvcode", trnDataTypeVarChar, 7, rs!NSVCode) & _
               gTransport.CreateInputParameterXML("Convfact", trnDataTypeint, 4, rs!newconvfact)

   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pTEMPUpdateConvfact", strParams)
            


   rs.MoveNext
Loop
End If

rs.Close
Set rs = Nothing



End Sub

'''Private Sub cmdNMP_Click()
'''Dim prod As DrugParameters
'''Dim lngFilePointerOut As Long
'''Dim FILE$
'''Dim blnException As Boolean
'''Dim lngFilePointer As Long
'''Dim strLine As String
'''Dim lngrecs As Long
'''Dim g_adoCn As ADODB.Connection
'''Dim m_lngCurrentTransPointer As Long
'''Dim ConnectionString As String
'''Dim strSql As String
'''Dim strdate As String
'''Dim lngReturn As Long
'''Dim stryear
'''Dim strWholeFile As String
'''Dim intloop As Integer
'''Dim numofrecs As Integer
'''Dim lngFudge As Long
'''Dim sglTemp As Single
'''Dim lngTemp As Long
'''Dim intTemp As Integer
'''Dim DblTemp As Double
'''Dim nod As Long
'''Dim lngProductFlatDSSID As Long
'''Dim strParams As String
'''Dim lngProductID As Long
'''Dim lngProductStockID As Long
'''Dim blnCyto As Boolean
'''Dim gLocationId As Long
'''Dim lngDupes As Long
'''Dim lngMasterSiteID
'''Dim lngKeep As Long
'''Dim lngCode As Long
'''Dim DSSDrugID As Long
'''Dim strParam As String
'''Dim lngSiteProductDataEditableID As Long
'''Dim dummy As Long
'''Dim strDesc As String
'''Dim lngSiteProductdataID As Long
'''Dim blnUpdate As Boolean
'''Dim rsAddon As ADODB.Recordset
'''
'''      ConnectionString = txtConnect.Text
'''
'''      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)
'''
'''      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
'''
'''      g_SessionID = Val(txtSession.Text)
'''      Set g_adoCn = New ADODB.Connection
'''      g_adoCn.ConnectionString = ConnectionString
'''      g_adoCn.Open
'''
'''      Set gTransport = New PharmacyData.Transport
'''      Set gTransport.Connection = g_adoCn
'''
'''      'Now we need to derive the siteID and the MasterSiteID
'''      gDispSite = GetLocationID_Site(strSitenumber)
'''
'''      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
'''      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
'''
'''
'''      fil = FreeFile
'''      Open txtDrive.Text & ":\dispdata." & strSitenumber & "\NOD" For Input As #fil Len = 16
'''      Input #fil, nod&
'''      Close #fil
'''
'''      lngFilePointerOut = FreeFile
'''      Open FILE$ For Binary Access Read Shared As lngFilePointerOut Len = 1024
'''
'''      blnException = False
'''
'''      numofrecs = nod
'''      For intloop = 1 To numofrecs
'''         DoEvents
'''         Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
'''
'''         'First - is it by some cock up already in as a prescribable product - quite likely
'''         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'''                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
'''         lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWproductCountByNSVCode", strParams)
'''         If lngProductID = 0 Then
'''
'''            lngProductID = 0
'''            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
'''                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
'''
'''            lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pTempisNMP", strParams)
'''            If lngProductID > 0 Then
'''               'OK here we are going to create a product row from scratch
'''               strDesc = prod.storesdescription
'''               If strDesc = "" Then
'''                  strDesc = prod.Description
'''               End If
'''               strDesc = replace(strDesc, "!", " ")
'''               'First we will create the NMP. This will give us the ProductID that we require throughout
'''               'Actually No, first we will see if we have an existing NMP Match
'''               lngProductID = 0
'''               strParams = gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 128, strDesc)
'''               lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pNMPProductIDbyDescription", strParams)
'''
'''               If lngProductID = 0 Then
'''
'''                  strParams = gTransport.CreateInputParameterXML("LookupType", trnDataTypeVarChar, 50, "Default") & _
'''                              gTransport.CreateInputParameterXML("IndexGroup", trnDataTypeVarChar, 50, "Default") & _
'''                              gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 128, strDesc)
'''                  lngProductID = gTransport.ExecuteInsertSP(g_SessionID, "NMP", strParams)
'''               End If
'''               DoEvents
'''               If lngProductID > 0 Then
'''                  'OK we have the ID now lets create a the pharmacy records for it
'''                  'Get the DrugID
'''                  'Not so fast. Lets check this - first is there an existing Siteproductdata record ?
'''                  strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
'''                              gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
'''                  DSSDrugID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductdataSelectDrugIDByNSVCode", strParams)
'''
'''                  If DSSDrugID = 0 Then
'''                     GetPointerSQL "P:\dispdata.884" & "\DrugID", DSSDrugID, True
'''
'''                     strParam = "" _
'''                        & gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, prod.barcode) _
'''                        & gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, prod.SisCode) _
'''                        & gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, prod.Code) _
'''                        & gTransport.CreateInputParameterXML("LabelDescription", trnDataTypeVarChar, 255, prod.Description) _
'''                        & gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, prod.tradename) _
'''                        & gTransport.CreateInputParameterXML("printformv", trnDataTypeVarChar, 5, prod.PrintformV) _
'''                        & gTransport.CreateInputParameterXML("storesdescription", trnDataTypeVarChar, 56, prod.storesdescription)
'''                     strParam = strParam _
'''                        & gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, Val(prod.convfact)) _
'''                        & gTransport.CreateInputParameterXML("mlsperpack", trnDataTypeFloat, 8, prod.mlsperpack) _
'''                        & gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, prod.cyto) _
'''                        & gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, prod.warcode) _
'''                        & gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, prod.warcode2) _
'''                        & gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, prod.inscode) _
'''                        & gTransport.CreateInputParameterXML("DosesperIssueUnit", trnDataTypeFloat, 8, prod.dosesperissueunit) _
'''                        & gTransport.CreateInputParameterXML("DosingUnits", trnDataTypeVarChar, 20, prod.DosingUnits) _
'''                        & gTransport.CreateInputParameterXML("DPSForm", trnDataTypeVarChar, 4, Left$(prod.DPSform, 4)) _
'''                        & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, DSSDrugID) _
'''                        & gTransport.CreateInputParameterXML("LabelInIssueUnits", trnDataTypeVarChar, 1, "0") _
'''                        & gTransport.CreateInputParameterXML("Canusespoon", trnDataTypeVarChar, 1, "0")
'''
'''
'''                     'Insert
'''                     strParam = strParam & gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
'''                     On Error Resume Next
'''                     lngSiteProductdataID = gTransport.ExecuteInsertSP(g_SessionID, "SiteProductData", strParam)
'''                     If Err Then
'''                        Err = 0
'''
'''                     End If
'''                  End If
'''
'''                  'We Need Here to add the new DrugID into the AMPP_MAPPER table
'''                  strParam = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
'''                           & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, DSSDrugID)
'''                  On Error Resume Next
'''                  dummy = gTransport.ExecuteInsertLinkSP(g_SessionID, "DSS_AMPPMapper", strParam)
'''                  If Err Then
'''                     Err = 0
'''
'''                  End If
'''
'''                  'Should we not check to see if there is already a Product stock record ? OK
'''                  strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'''                              gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
'''                  lngProductStockID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductSelectProductStockIDByNSV", strParams)
'''
'''                  With prod
'''                     strSql = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, .inuse) & _
'''                              gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, .cyto) & _
'''                              gTransport.CreateInputParameterXML("formulary", trnDataTypeVarChar, 1, .formulary) & _
'''                              gTransport.CreateInputParameterXML("wardcode", trnDataTypeVarChar, 6, .warcode) & _
'''                              gTransport.CreateInputParameterXML("wardcode2", trnDataTypeVarChar, 6, .warcode2) & _
'''                              gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, .inscode) & _
'''                              gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, 6, .dircode) & _
'''                              gTransport.CreateInputParameterXML("labelformat", trnDataTypeVarChar, 1, .labelformat) & _
'''                              gTransport.CreateInputParameterXML("extralabel", trnDataTypeVarChar, 3, .extralabel) & _
'''                              gTransport.CreateInputParameterXML("expiryminutes", trnDataTypeint, 4, .expiryminutes) & _
'''                              gTransport.CreateInputParameterXML("minissue", trnDataTypeVarChar, 4, .minissue) & _
'''                              gTransport.CreateInputParameterXML("maxissue", trnDataTypeVarChar, 5, .maxissue) & _
'''                              gTransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, .lastissued) & _
'''                              gTransport.CreateInputParameterXML("issuewholepack", trnDataTypeVarChar, 1, .issueWholePack)
'''
'''
'''                     strSql = strSql & _
'''                              gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
'''                              gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
'''                              gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
'''                              gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
'''                              gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
'''                              gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
'''                              gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
'''
'''
'''                     strSql = strSql & _
'''                              gTransport.CreateInputParameterXML("loccode2", trnDataTypeVarChar, 3, .loccode2) & _
'''                              gTransport.CreateInputParameterXML("anuse", trnDataTypeVarChar, 9, .anuse) & _
'''                              gTransport.CreateInputParameterXML("usethisperiod", trnDataTypeFloat, 8, .usethisperiod) & _
'''                              gTransport.CreateInputParameterXML("recalcatperiodend", trnDataTypeVarChar, 1, .recalcatperiodend) & _
'''                              gTransport.CreateInputParameterXML("datelastperiodend", trnDataTypeVarChar, 8, .datelastperiodend) & _
'''                              gTransport.CreateInputParameterXML("usagedamping", trnDataTypeFloat, 8, .usagedamping) & _
'''                              gTransport.CreateInputParameterXML("safetyfactor", trnDataTypeFloat, 8, .safetyfactor) & _
'''                              gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, .supcode) & _
'''                              gTransport.CreateInputParameterXML("altsupcode", trnDataTypeVarChar, 29, .altsupcode) & _
'''                              gTransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, .lastordered)
'''
'''                     strSql = strSql & _
'''                              gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
'''                              gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
'''                              gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
'''                              gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
'''                              gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
'''                              gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
'''                              gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
'''                              gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
'''                              gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message)
'''
'''                     strSql = strSql & _
'''                              gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
'''                              gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
'''                              gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
'''                              gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
'''                              gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
'''                              gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
'''                              gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
'''                              gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .local)
'''                     strSql = strSql & _
'''                              gTransport.CreateInputParameterXML("CIVAS", trnDataTypeVarChar, 1, .civas) & _
'''                              gTransport.CreateInputParameterXML("mgPerml", trnDataTypeFloat, 8, .mgPerml) & _
'''                              gTransport.CreateInputParameterXML("maxInfusionRate", trnDataTypeFloat, 8, .MaxInfusionRate) & _
'''                              gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeFloat, 8, .InfusionTime) & _
'''                              gTransport.CreateInputParameterXML("Minmgperml", trnDataTypeFloat, 8, .MinmgPerml) & _
'''                              gTransport.CreateInputParameterXML("Maxmgperml", trnDataTypeFloat, 8, .MaxmgPerml) & _
'''                              gTransport.CreateInputParameterXML("IVContainer", trnDataTypeVarChar, 1, .IVcontainer) & _
'''                              gTransport.CreateInputParameterXML("DisplacementVolume", trnDataTypeFloat, 8, .DisplacementVolume) & _
'''                              gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, .ReconVol) & _
'''                              gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, 3, .ReconAbbr) & _
'''                              gTransport.CreateInputParameterXML("Diluent1", trnDataTypeVarChar, 3, .Diluent1Abbr) & _
'''                              gTransport.CreateInputParameterXML("Diluent2", trnDataTypeVarChar, 3, .Diluent2Abbr) & _
'''                              gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, CLng(.convfact)) & _
'''                              gTransport.CreateInputParameterXML("dosesperIssueunit", trnDataTypeFloat, 8, .dosesperissueunit) '& _
'''                              'gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .storespack)
'''                  End With
'''      ''            gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
'''      ''                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal) & _
'''      ''                        gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
'''      ''                        gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _
'''
'''                  If lngProductStockID > 0 Then
'''                     strSql = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) & _
'''                              gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) & strSql
'''                     lngProductStockID = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strSql)
'''                     blnUpdate = True
'''                  Else
'''                     strSql = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
'''                              & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strSql
'''                     ''dummy = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
'''                     '.ProductStockID = dummy '05Jul05 TH Added
'''                     lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
'''                  End If
'''                  If lngProductStockID > 0 And (Not blnUpdate) Then
'''                     'And finally a Supplier profile record for the default supplier
'''                     'Later we may want to create extra records for each altsupplier or directly convert supplier profiles (best to do that first I reckon)
'''                     With prod
'''                        strSql = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
'''                                 gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
'''                                 gTransport.CreateInputParameterXML("PrimarySup", trnDataTypeBit, 1, 1) & _
'''                                 gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
'''                                 gTransport.CreateInputParameterXML("ReorderPckSize", trnDataTypeVarChar, 5, .reorderpcksize) & _
'''                                 gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, .reorderlvl) & _
'''                                 gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
'''                                 gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
'''                                 gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
'''                                 gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .leadtime) & _
'''                                 gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
'''                                 gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
'''                                 gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
'''                                 gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
'''                                 gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
'''                                 ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
'''                     End With
'''                     lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
'''
'''                  End If
'''
'''               End If
'''            End If
'''         End If
'''   Next
'''
'''   MsgBox "All Done"
'''
'''End Sub

Private Sub cmdTemplateCheck_Click()
Dim prod As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSql As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim strParams As String
Dim lngProductID As Long
Dim lngProductStockID As Long
Dim blnCyto As Boolean
Dim gLocationId As Long
Dim lngMasterSiteID As Long
Dim lngKeep As Long
Dim lngCode As Long
Dim blnUpdate As Boolean
Dim rsTemplates As ADODB.Recordset
Dim xmldoc As MSXML2.DOMDocument
Dim strPrescribingUnit As String
Dim xmlnode As MSXML2.IXMLDOMNode
Dim rsProduct As ADODB.Recordset
Dim xmlAttribute As MSXML2.IXMLDOMAttribute
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim Scaling As String
Dim strPrescriptionType As String
Dim Dose As Single
Dim strUnit As String
Dim strRXDose As String
Dim strProductName As String
Dim strProductType As String
Dim rsProductstuff As ADODB.Recordset
Dim strTemplate As String
Dim found As Integer
Dim blnSuppressQtyCalc As Boolean
Dim strHeader As String
Dim strRecord As String
Dim strFile As String
'Dim strHeader As String
''Dim lngFilePointer As Long
Dim strFormulaRoot As String

      

      ConnectionString = txtConnect.Text
      
      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      dispdata$ = txtDrive.Text & ":\dispdata." & strSitenumber
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      Set gTransport.Connection = g_adoCn
      
      strHeader = "PrescriptionType|ProductName|ProductType|PharmacyProduct|Unit|rxDose|PrescribingUnit|Dose|Instruction|Form|CalcQty"
      strFile = txtDrive.Text & ":\TemplateCheck.txt"
      lngFilePointer = FreeFile
      Open strFile For Output As #lngFilePointer
      Print #lngFilePointer, strHeader
      
      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSitenumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
      
      strFormulaRoot = "My Formulary"
      
      strParams = gTransport.CreateInputParameterXML("TamplateRootName", trnDataTypeVarChar, 128, strFormulaRoot)
      Set rsTemplates = gTransport.ExecuteSelectSP(g_SessionID, "pTempGetMyFormularyTemplatesADO", strParams)

      If Not rsTemplates.EOF Then
      rsTemplates.MoveFirst
      Do While Not rsTemplates.EOF
         strPrescribingUnit = ""
         ProductID = 0
         If Trim$(rsTemplates!DefaultXML) <> "" Then
            Set xmldoc = New MSXML2.DOMDocument
            If xmldoc.loadXML(rsTemplates!DefaultXML) Then
            'get the dosing thing then get out!
               'Set xmlnode = xmlDoc.selectSingleNode("root/data") 'RELOAD THE NODE!
               'strPrescribingUnit =xmlnode.attributes(
               'Set xmlAttribute = xmlnode.Attributes.getNamedItem("UnitID_Dose")
               'Dose = 100
               Set xmlNodeList = xmldoc.selectNodes("root/data/attribute")
               For Each xmlnode In xmlNodeList
                     If xmlnode.Attributes.getNamedItem("name").Text = "ProductID" Then ProductID = CLng(xmlnode.Attributes.getNamedItem("value").Text)
                     If xmlnode.Attributes.getNamedItem("name").Text = "UnitID_Dose" Then strPrescribingUnit = xmlnode.Attributes.getNamedItem("text").Text
                     If xmlnode.Attributes.getNamedItem("name").Text = "Dose" Then Dose = CSng(Val(xmlnode.Attributes.getNamedItem("value").Text))
                     If Trim$(strPrescribingUnit) <> "" And ProductID <> 0 And Dose <> 100 Then Exit For
                     
               
                  
               'strPrescribingUnit = xmlnode.Attributes.getNamedItem("text").Text
               'Set xmlnode = Nothing
               'Set xmlnode = xmlDoc.selectSingleNode("root/ProductID") 'RELOAD THE NODE!
               'strPrescribingUnit =xmlnode.attributes(
               'ProductID = CLng(xmlnode.Attributes.getNamedItem("value").Text)
               'Set xmlnode = Nothing
               Next
            End If
            Set xmldoc = Nothing
         End If
         
         strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID)
         Set rsProductstuff = gTransport.ExecuteSelectSP(g_SessionID, "pTempGetProductNameandType", strParams)
         If Not rsProductstuff.EOF Then
         strProductName = rsProductstuff.Fields("rxproduct")
         strProductType = rsProductstuff.Fields("ProductType")
         End If
         Set rsProductstuff = Nothing
         strRxproduct = ProductID
         strRXDose = CStr(Dose)
         strPrescriptionType = rsTemplates.Fields("description")
         strTemplate = " Template = " & strPrescriptionType & Chr(13) & " Product = " & strProductName & Chr(13) & " Type = " & strProductType & Chr(13) & Chr(13)
         If Trim$(strPrescribingUnit) <> "" And ProductID <> 0 Then
            'Now we have the beginnings
            'Here we get the product Family and loop through all the pharm prods
            strParameters = _
            gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
            gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID)
            
            Set rsProduct = gTransport.ExecuteSelectSP(g_SessionID, "pTEMPWProductLookupByProductID_VMPorAMPExtra", strParameters)
            If Not rsProduct.EOF Then
               rsProduct.MoveFirst
               Do While Not rsProduct.EOF
               'Now we have the pharmacy prods
                  CastRecordsetToProduct rsProduct, d
                  Dose = CSng(strRXDose)
                  If ScalePrescribedUnits(d, strPrescribingUnit, Dose, 0, 0, Scaling, strUnit) Then
                     'scaling possible record results and check label settings/def.issue qty
                     'rx = 6 strPrescribing Units
                     'on label
                     'MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling & Chr(13) & " Unit = " & strUnit & Chr(13) & "rxDose = " & strRXDose & Chr(13) & "rxUnit = " & strPrescribingUnit & Chr(13) & " doseqty = " & CStr(Dose)
                     'Get label settings
                     du$ = UCase$(Trim$(Iff(d.LabelInIssueUnits, d.PrintformV, d.DosingUnits)) & Trim$(d.DPSform))        'DPSform is "" or one character
                     Instruction$ = TxtDPatmed("", du$ & "instruct", found)                                               'Take/Give etc
                     Form$ = TxtDPatmed("", du$ & "form", 0)
                     
                     strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.Description) & "|" & strUnit & "|" & strRXDose & "|" & strPrescribingUnit & "|" & CStr(Dose)
                     strRecord = strRecord & "|" & Instruction$ & "|" & Form$
                     If InStr(1, "," & TxtD(dispdata$ & "\PATMED.INI", "", "", "QuantityManualEntryTypes", 0) & ",", "," & du$ & ",", 1) Then
                        blnSuppressQtyCalc = True
                     End If
                     If blnSuppressQtyCalc Then
                        strRecord = strRecord & "|NO"
                     Else
                        strRecord = strRecord & "|YES"
                     End If
                  
                  Else
                     'Scaling not possible record and move on
                     'MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling
                     strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.Description) & "|||||||"

                  End If
                  Print #lngFilePointer, strRecord
                  rsProduct.MoveNext
               Loop
            End If
            Set rsProduct = Nothing
         
         End If
      
      rsTemplates.MoveNext
      Loop
      End If
      
      Close #lngFilePointer
End Sub

Private Sub cmdUpdate_Click()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSql As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim strParams As String
Dim lngProductID As Long
Dim lngProductStockID As Long
Dim blnCyto As Boolean
Dim gLocationId As Long
Dim lngMasterSiteID As Long
Dim lngKeep As Long
Dim lngCode As Long
Dim blnUpdate As Boolean
'R9604PharmacyData000


      ConnectionString = txtConnect.Text
      
      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      'Set gTransport = New PharmacyData.Transport
      Set gTransport = New R9604PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSitenumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSitenumber & "\NOD" For Input As #fil Len = 16
      Input #fil, nod&
      Close #fil

      lngFilePointerOut = FreeFile
      Open FILE$ For Binary Access Read Shared As lngFilePointerOut Len = 1024
    
            
      numofrecs = nod
      For intloop = 0 To numofrecs
         lngProductStockID = 0
         blnUpdate = False
         DoEvents
         Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
            
         'First we get an associated ProductId which we can use to populate the next records.
                    
         strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetProductIDFromNSVCode", strParams)
            
         If lngProductID > 0 Then

            DoEvents
            'OK we have the ID now lets create a ProductStock record for it
            'Check that there is not an existing stock row on this ProductID with the same pack and strength (illegal !)
            'strParams = gtransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID) & _
            '                     gtransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
            '                     gtransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) & _
            '                     gtransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact)
            '
            'lngResult = gtransport.ExecuteSelectReturnSP(g_SessionID, "pProductStockCountbyCriteria", strParams)
            '08Dec05 TH We need to update raw file here with any update dosesperissueunit
            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pTempDoseChangesByNSVCode", strParams)
            If Not rsAddon.EOF Then
               prod.dosesperissueunit = rsAddon!doseperissueunit
               
            End If
            Set rsAddon = Nothing
            
            
            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pTempConvfactChangesByNSVCode", strParams)
            If Not rsAddon.EOF Then
               'prod.dosesperissueunit = rsAddon!doseperissueunit
               If rsAddon![new convfact] <> Val(prod.convfact) Then
                  'here we need to alter the value 'No we dont
                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
                  
                  prod.stocklvl = Format$(((Val(prod.stocklvl) / Val(prod.convfact)) * rsAddon![new convfact]))
                  prod.convfact = Format$(rsAddon![new convfact])
                  '!!! We need to alter the stock level
               
               End If
               
            End If
            Set rsAddon = Nothing
            
            'OMiGod Here we need to check if the issueunits are different. If they are the cost will be altered !!!
            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strParams)
            If Not rsAddon.EOF Then
               'prod.dosesperissueunit = rsAddon!doseperissueunit
               If Trim$(UCase$(rsAddon![PrintformV])) <> Trim$(UCase$(prod.PrintformV)) Then
                  'here we need to alter the value 'No we dont
                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
                  '''MsgBox "Houston - Could be a problem here !"
               
               End If
               
            End If
            Set rsAddon = Nothing
            
            'Should we not check to see if there is already a Product stock record ? OK
            ''strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
            ''            gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
            ''lngProductStockID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductSelectProductStockIDByNSV", strParams)
               
            With prod
               strSql = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, .inuse) & _
                        gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, .cyto) & _
                        gTransport.CreateInputParameterXML("formulary", trnDataTypeVarChar, 1, .formulary) & _
                        gTransport.CreateInputParameterXML("wardcode", trnDataTypeVarChar, 6, .warcode) & _
                        gTransport.CreateInputParameterXML("wardcode2", trnDataTypeVarChar, 6, .warcode2) & _
                        gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, .inscode) & _
                        gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, 6, .dircode) & _
                        gTransport.CreateInputParameterXML("labelformat", trnDataTypeVarChar, 1, .labelformat) & _
                        gTransport.CreateInputParameterXML("extralabel", trnDataTypeVarChar, 3, .extralabel) & _
                        gTransport.CreateInputParameterXML("expiryminutes", trnDataTypeint, 4, .expiryminutes) & _
                        gTransport.CreateInputParameterXML("minissue", trnDataTypeVarChar, 4, .minissue) & _
                        gTransport.CreateInputParameterXML("maxissue", trnDataTypeVarChar, 5, .maxissue) & _
                        gTransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, .lastissued) & _
                        gTransport.CreateInputParameterXML("issuewholepack", trnDataTypeVarChar, 1, .issueWholePack)
                
                     
               strSql = strSql & _
                        gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                        gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
                        gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
                        gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
                        gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
                        gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
                        gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
   
            
               strSql = strSql & _
                        gTransport.CreateInputParameterXML("loccode2", trnDataTypeVarChar, 3, .loccode2) & _
                        gTransport.CreateInputParameterXML("anuse", trnDataTypeVarChar, 9, .anuse) & _
                        gTransport.CreateInputParameterXML("usethisperiod", trnDataTypeFloat, 8, .usethisperiod) & _
                        gTransport.CreateInputParameterXML("recalcatperiodend", trnDataTypeVarChar, 1, .recalcatperiodend) & _
                        gTransport.CreateInputParameterXML("datelastperiodend", trnDataTypeVarChar, 8, .datelastperiodend) & _
                        gTransport.CreateInputParameterXML("usagedamping", trnDataTypeFloat, 8, .usagedamping) & _
                        gTransport.CreateInputParameterXML("safetyfactor", trnDataTypeFloat, 8, .safetyfactor) & _
                        gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, .supcode) & _
                        gTransport.CreateInputParameterXML("altsupcode", trnDataTypeVarChar, 29, .altsupcode) & _
                        gTransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, .lastordered)
                        
               strSql = strSql & _
                        gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
                        gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
                        gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
                        gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
                        gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
                        gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
                        gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
                        gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
                        gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message)
                        
               strSql = strSql & _
                        gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
                        gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
                        gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
                        gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
                        gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
                        gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
                        gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
                        gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .local)
               strSql = strSql & _
                        gTransport.CreateInputParameterXML("CIVAS", trnDataTypeVarChar, 1, .civas) & _
                        gTransport.CreateInputParameterXML("mgPerml", trnDataTypeFloat, 8, .mgPerml) & _
                        gTransport.CreateInputParameterXML("maxInfusionRate", trnDataTypeFloat, 8, .MaxInfusionRate) & _
                        gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeFloat, 8, .InfusionTime) & _
                        gTransport.CreateInputParameterXML("Minmgperml", trnDataTypeFloat, 8, .MinmgPerml) & _
                        gTransport.CreateInputParameterXML("Maxmgperml", trnDataTypeFloat, 8, .MaxmgPerml) & _
                        gTransport.CreateInputParameterXML("IVContainer", trnDataTypeVarChar, 1, .IVcontainer) & _
                        gTransport.CreateInputParameterXML("DisplacementVolume", trnDataTypeFloat, 8, .DisplacementVolume) & _
                        gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, .ReconVol) & _
                        gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, 3, .ReconAbbr) & _
                        gTransport.CreateInputParameterXML("Diluent1", trnDataTypeVarChar, 3, .Diluent1Abbr) & _
                        gTransport.CreateInputParameterXML("Diluent2", trnDataTypeVarChar, 3, .Diluent2Abbr) & _
                        gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, CLng(.convfact)) & _
                        gTransport.CreateInputParameterXML("dosesperIssueunit", trnDataTypeFloat, 8, .dosesperissueunit) & _
                        gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .storespack)
            End With
''            gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
''                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal) & _
''                        gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
''                        gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _

            If lngProductStockID > 0 Then
               strSql = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) & _
                        gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) & strSql
               lngProductStockID = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strSql)
               blnUpdate = True
            Else
               strSql = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
                        & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strSql
               ''dummy = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
               '.ProductStockID = dummy '05Jul05 TH Added
               lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
            End If
            If lngProductStockID > 0 And (Not blnUpdate) Then
               'And finally a Supplier profile record for the default supplier
               'Later we may want to create extra records for each altsupplier or directly convert supplier profiles (best to do that first I reckon)
               With prod
                  strSql = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
                           gTransport.CreateInputParameterXML("PrimarySup", trnDataTypeBit, 1, 1) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderPckSize", trnDataTypeVarChar, 5, .reorderpcksize) & _
                           gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, .reorderlvl) & _
                           gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .leadtime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
               End With
               lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)

            End If
         Else
          'No match on siscode so we will store this in a tmp table for use later
''          strParams = gtransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
''                     gtransport.CreateInputParameterXML("StoresDesc", trnDataTypeVarChar, 56, prod.storesdescription) & _
''                     gtransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, prod.inuse) & _
''                     gtransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, prod.lastissued) & _
''                     gtransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, prod.lastordered) & _
''                     gtransport.CreateInputParameterXML("Duplicate", trnDataTypeBit, 1, 0)
          '''lngKeep = gtransport.ExecuteInsertSP(g_SessionID, "TEMPNSVCODES", strParams)
         Debug.Print prod.SisCode
         End If

      Next
          
      MsgBox "All Done"
      
End Sub

Private Sub Command1_Click()
'Here is what we want.
'1. We bring back all the my formulary templates
'2. We load each template and select the prescribing unit
'3. we use the product family to get all the pharmacy prods on this template.
'4. we basically run the scaling , check the issue unit, on the issue screen
'   check what goes on the label

Dim prod As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSql As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim strParams As String
Dim lngProductID As Long
Dim lngProductStockID As Long
Dim blnCyto As Boolean
Dim gLocationId As Long
Dim lngMasterSiteID As Long
Dim lngKeep As Long
Dim lngCode As Long
Dim blnUpdate As Boolean
Dim rsTemplates As ADODB.Recordset
Dim xmldoc As MSXML2.DOMDocument
Dim strPrescribingUnit As String
Dim xmlnode As MSXML2.IXMLDOMNode
Dim rsProduct As ADODB.Recordset
Dim xmlAttribute As MSXML2.IXMLDOMAttribute
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim Scaling As String
Dim strPrescriptionType As String
Dim Dose As Single
Dim strUnit As String
Dim strRXDose As String
Dim strProductName As String
Dim strProductType As String
Dim rsProductstuff As ADODB.Recordset
Dim strTemplate As String


      ConnectionString = txtConnect.Text
      
      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSitenumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
      
      strParams = gTransport.CreateInputParameterXML("TamplateRootName", trnDataTypeVarChar, 128, "My Formulary")
      Set rsTemplates = gTransport.ExecuteSelectSP(g_SessionID, "pTempGetMyFormularyTemplatesADO", strParams)

      If Not rsTemplates.EOF Then
      rsTemplates.MoveFirst
      Do While Not rsTemplates.EOF
         strPrescribingUnit = ""
         ProductID = 0
         If Trim$(rsTemplates!DefaultXML) <> "" Then
            Set xmldoc = New MSXML2.DOMDocument
            If xmldoc.loadXML(rsTemplates!DefaultXML) Then
            'get the dosing thing then get out!
               'Set xmlnode = xmlDoc.selectSingleNode("root/data") 'RELOAD THE NODE!
               'strPrescribingUnit =xmlnode.attributes(
               'Set xmlAttribute = xmlnode.Attributes.getNamedItem("UnitID_Dose")
               'Dose = 100
               Set xmlNodeList = xmldoc.selectNodes("root/data/attribute")
               For Each xmlnode In xmlNodeList
                     If xmlnode.Attributes.getNamedItem("name").Text = "ProductID" Then ProductID = CLng(xmlnode.Attributes.getNamedItem("value").Text)
                     If xmlnode.Attributes.getNamedItem("name").Text = "UnitID_Dose" Then strPrescribingUnit = xmlnode.Attributes.getNamedItem("text").Text
                     If xmlnode.Attributes.getNamedItem("name").Text = "Dose" Then Dose = CSng(xmlnode.Attributes.getNamedItem("value").Text)
                     If Trim$(strPrescribingUnit) <> "" And ProductID <> 0 And Dose <> 100 Then Exit For
                     
               
                  
               'strPrescribingUnit = xmlnode.Attributes.getNamedItem("text").Text
               'Set xmlnode = Nothing
               'Set xmlnode = xmlDoc.selectSingleNode("root/ProductID") 'RELOAD THE NODE!
               'strPrescribingUnit =xmlnode.attributes(
               'ProductID = CLng(xmlnode.Attributes.getNamedItem("value").Text)
               'Set xmlnode = Nothing
               Next
            End If
            Set xmldoc = Nothing
         End If
         
         strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID)
         Set rsProductstuff = gTransport.ExecuteSelectSP(g_SessionID, "pTempGetProductNameandType", strParams)
         If Not rsProductstuff.EOF Then
         strProductName = rsProductstuff.Fields("rxproduct")
         strProductType = rsProductstuff.Fields("ProductType")
         End If
         Set rsProductstuff = Nothing
         strRxproduct = ProductID
         strRXDose = CStr(Dose)
         strPrescriptionType = rsTemplates.Fields("description")
         strTemplate = " Template = " & strPrescriptionType & Chr(13) & " Product = " & strProductName & Chr(13) & " Type = " & strProductType & Chr(13) & Chr(13)
         If Trim$(strPrescribingUnit) <> "" And ProductID <> 0 Then
            'Now we have the beginnings
            'Here we get the product Family and loop through all the pharm prods
            strParameters = _
            gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
            gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID)
            
            Set rsProduct = gTransport.ExecuteSelectSP(g_SessionID, "pTEMPWProductLookupByProductID_VMPorAMPExtra", strParameters)
            If Not rsProduct.EOF Then
               rsProduct.MoveFirst
               Do While Not rsProduct.EOF
               'Now we have the pharmacy prods
                  CastRecordsetToProduct rsProduct, d
                  Dose = CSng(strRXDose)
                  If ScalePrescribedUnits(d, strPrescribingUnit, Dose, 0, 0, Scaling, strUnit) Then
                  'scaling possible record results and check label settings/def.issue qty
                  'rx = 6 strPrescribing Units
                  'on label
                  MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling & Chr(13) & " Unit = " & strUnit & Chr(13) & "rxDose = " & strRXDose & Chr(13) & "rxUnit = " & strPrescribingUnit & Chr(13) & " doseqty = " & CStr(Dose)
                  
                  Else
                  'Scaling not possible record and move on
                  MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling
                  End If
                  
                  rsProduct.MoveNext
               Loop
            End If
            Set rsProduct = Nothing
         
         End If
      
      rsTemplates.MoveNext
      Loop
      End If
      
End Sub

Private Sub Command2_Click()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSql As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim strParams As String
Dim lngProductID As Long
Dim lngProductStockID As Long
Dim blnCyto As Boolean
Dim gLocationId As Long
Dim lngMasterSiteID As Long
Dim lngKeep As Long
Dim lngCode As Long
Dim blnUpdate As Boolean


      ConnectionString = txtConnect.Text
      
      strSitenumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      'Set gTransport = New PharmacyData.Transport
      Set gTransport = New R9604PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSitenumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSitenumber & "\NOD" For Input As #fil Len = 16
      Input #fil, nod&
      Close #fil

      lngFilePointerOut = FreeFile
      Open FILE$ For Binary Access Read Shared As lngFilePointerOut Len = 1024
    
            
      numofrecs = nod
      For intloop = 0 To numofrecs
         lngProductStockID = 0
         blnUpdate = False
         DoEvents
         Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
            
         'First we get an associated ProductId which we can use to populate the next records.
                    
         strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
                     gTransport.CreateInputParameterXML("Barcode", trnDataTypeVarChar, 13, prod.barcode) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngProductID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pSiteProductDataUpdateBarcodebysisCode", strParams)
            
         
      Next
          
      MsgBox "All Done"
End Sub

Private Sub Form_Load()
TB = Chr$(9)
crlf = Chr$(13) & Chr$(10)

End Sub
