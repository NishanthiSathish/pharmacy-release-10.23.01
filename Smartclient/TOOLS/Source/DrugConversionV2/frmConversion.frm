VERSION 5.00
Begin VB.Form frmConversion 
   Caption         =   "Drug Conversion Utility"
   ClientHeight    =   3645
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   11880
   LinkTopic       =   "Form2"
   ScaleHeight     =   3645
   ScaleWidth      =   11880
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame1 
      Caption         =   "Load PS and WSP Options"
      Height          =   1695
      Left            =   6600
      TabIndex        =   45
      Top             =   840
      Width           =   2775
      Begin VB.TextBox txtNoOfChars 
         Height          =   285
         Left            =   2280
         TabIndex        =   36
         Text            =   "5"
         Top             =   840
         Width           =   375
      End
      Begin VB.CheckBox chkTestDescription 
         Caption         =   "Compare Description: Len"
         Height          =   195
         Left            =   120
         TabIndex        =   35
         Top             =   840
         Value           =   1  'Checked
         Width           =   2295
      End
      Begin VB.CheckBox chkTestConvfact 
         Caption         =   "Compare Convfact"
         Height          =   195
         Left            =   120
         TabIndex        =   37
         Top             =   1080
         Value           =   1  'Checked
         Width           =   1815
      End
      Begin VB.CheckBox chkTestIssueUnits 
         Caption         =   "Compare Issue Units"
         Height          =   195
         Left            =   120
         TabIndex        =   38
         Top             =   1320
         Width           =   1815
      End
      Begin VB.CheckBox chkInUseOnly 
         Caption         =   "In Use Only"
         Height          =   195
         Left            =   120
         TabIndex        =   34
         Top             =   600
         Width           =   1815
      End
      Begin VB.CheckBox chkPrimaryBarcode 
         Caption         =   "Primary Barcode Check"
         Height          =   195
         Left            =   120
         TabIndex        =   33
         Top             =   360
         Width           =   2175
      End
   End
   Begin VB.CommandButton cmdProcessAlternateBarCodes 
      Caption         =   "Load Alternate Barcodes"
      Height          =   495
      Left            =   9600
      TabIndex        =   40
      Top             =   240
      Width           =   2175
   End
   Begin VB.CommandButton cmdLoadPSAndWSP 
      Caption         =   "Load PS and WSP Tables"
      Height          =   495
      Left            =   6840
      TabIndex        =   39
      Top             =   2640
      Width           =   2175
   End
   Begin VB.TextBox txtStatus 
      BackColor       =   &H80000004&
      Height          =   315
      Left            =   120
      TabIndex        =   41
      TabStop         =   0   'False
      Top             =   3240
      Width           =   11655
   End
   Begin VB.CommandButton cmdLoadHoldingTable 
      Caption         =   "Load Holding Table"
      Height          =   495
      Left            =   6840
      TabIndex        =   32
      Top             =   120
      Width           =   2175
   End
   Begin VB.Frame fraConnection 
      Caption         =   "Connection"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3015
      Left            =   120
      TabIndex        =   20
      Top             =   120
      Width           =   6375
      Begin VB.TextBox txtSession 
         Height          =   315
         Left            =   1440
         TabIndex        =   26
         Text            =   "1"
         Top             =   2520
         Width           =   1695
      End
      Begin VB.TextBox txtDispPath 
         Height          =   315
         Left            =   1440
         TabIndex        =   25
         Text            =   "e:\dispdata.002"
         Top             =   2160
         Width           =   2895
      End
      Begin VB.TextBox txtPassword 
         Height          =   315
         IMEMode         =   3  'DISABLE
         Left            =   1440
         PasswordChar    =   "*"
         TabIndex        =   24
         Top             =   1800
         Width           =   3960
      End
      Begin VB.TextBox txtUserID 
         Height          =   315
         Left            =   1440
         TabIndex        =   23
         Text            =   "icwsys"
         Top             =   1440
         Width           =   3960
      End
      Begin VB.TextBox txtInitCatalog 
         Height          =   315
         Left            =   1440
         TabIndex        =   22
         Top             =   1080
         Width           =   3960
      End
      Begin VB.TextBox txtDataSource 
         Height          =   315
         Left            =   1440
         TabIndex        =   21
         Top             =   720
         Width           =   3960
      End
      Begin VB.TextBox txtProvider 
         Height          =   315
         Left            =   1440
         TabIndex        =   1
         Text            =   "SQLOLEDB.1"
         Top             =   360
         Width           =   3960
      End
      Begin VB.Label lblSession 
         Caption         =   "Session ID: "
         Height          =   375
         Left            =   480
         TabIndex        =   44
         Top             =   2520
         Width           =   855
      End
      Begin VB.Label lblTL 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "Dispdata Path: "
         Height          =   375
         Index           =   5
         Left            =   240
         TabIndex        =   43
         Top             =   2160
         Width           =   1095
      End
      Begin VB.Label Label5 
         Alignment       =   1  'Right Justify
         Caption         =   "Password: "
         Height          =   255
         Left            =   480
         TabIndex        =   31
         Top             =   1800
         Width           =   855
      End
      Begin VB.Label Label4 
         Alignment       =   1  'Right Justify
         Caption         =   "User ID: "
         Height          =   255
         Left            =   480
         TabIndex        =   30
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Database: "
         Height          =   375
         Index           =   1
         Left            =   360
         TabIndex        =   29
         Top             =   1080
         Width           =   975
      End
      Begin VB.Label Label2 
         Alignment       =   1  'Right Justify
         Caption         =   "Server: "
         Height          =   255
         Index           =   1
         Left            =   480
         TabIndex        =   28
         Top             =   720
         Width           =   855
      End
      Begin VB.Label Label6 
         Alignment       =   1  'Right Justify
         Caption         =   "Provider: "
         Height          =   255
         Left            =   360
         TabIndex        =   27
         Top             =   360
         Width           =   975
      End
   End
   Begin VB.CommandButton Command3 
      Caption         =   "E&xit"
      Height          =   855
      Left            =   8880
      TabIndex        =   19
      TabStop         =   0   'False
      Top             =   8400
      Width           =   1575
   End
   Begin VB.CommandButton CmdHerefordStockConvert 
      Caption         =   "Hereford Stock Conversion"
      Enabled         =   0   'False
      Height          =   975
      Left            =   8640
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   10320
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.CommandButton CmdAddenbrookesROQROL 
      Caption         =   "Addenbrookes ROQ/ROL"
      Enabled         =   0   'False
      Height          =   1095
      Left            =   9120
      TabIndex        =   17
      TabStop         =   0   'False
      Top             =   8760
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.CommandButton cmdHereford 
      Caption         =   "Hereford"
      Enabled         =   0   'False
      Height          =   1095
      Left            =   8520
      TabIndex        =   16
      TabStop         =   0   'False
      Top             =   10200
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.CommandButton cmdAddenBarcodes 
      Caption         =   "Import Dummy barcodes"
      Height          =   495
      Left            =   9600
      TabIndex        =   42
      Top             =   840
      Width           =   2175
   End
   Begin VB.CommandButton cmdAddenStockConvert 
      Caption         =   "         Addenbrookes          Stock Conversion"
      Enabled         =   0   'False
      Height          =   855
      Left            =   8640
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   7080
      Visible         =   0   'False
      Width           =   2055
   End
   Begin VB.CommandButton cmdAddenbrooks 
      Caption         =   "AddenBrooks"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1095
      Left            =   840
      TabIndex        =   14
      TabStop         =   0   'False
      Top             =   9240
      Visible         =   0   'False
      Width           =   3735
   End
   Begin VB.CommandButton cmdBNF 
      Caption         =   "Import BNF"
      Enabled         =   0   'False
      Height          =   1095
      Left            =   5640
      TabIndex        =   13
      TabStop         =   0   'False
      Top             =   9000
      Visible         =   0   'False
      Width           =   2655
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Import Barcodes"
      Enabled         =   0   'False
      Height          =   495
      Left            =   4560
      TabIndex        =   12
      TabStop         =   0   'False
      Top             =   11280
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Enabled         =   0   'False
      Height          =   1455
      Left            =   720
      TabIndex        =   11
      TabStop         =   0   'False
      Top             =   10680
      Visible         =   0   'False
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
      TabIndex        =   10
      TabStop         =   0   'False
      Top             =   9600
      Visible         =   0   'False
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
      TabIndex        =   9
      TabStop         =   0   'False
      Top             =   9360
      Visible         =   0   'False
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
      TabIndex        =   8
      TabStop         =   0   'False
      Top             =   7680
      Visible         =   0   'False
      Width           =   3255
   End
   Begin VB.TextBox txtConnect 
      Height          =   495
      Left            =   3360
      MousePointer    =   1  'Arrow
      TabIndex        =   6
      TabStop         =   0   'False
      Text            =   "server=ASCSQL;database=GOLiveDB;uid=sys;password=ascribe;provider=sqloledb;"
      Top             =   4440
      Width           =   7095
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
      Left            =   1200
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   8400
      Width           =   2895
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
      TabIndex        =   4
      TabStop         =   0   'False
      Text            =   "E"
      Top             =   6720
      Width           =   375
   End
   Begin VB.TextBox txtSite 
      Height          =   495
      Left            =   3360
      TabIndex        =   0
      TabStop         =   0   'False
      Text            =   "999"
      Top             =   5760
      Width           =   2055
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
      TabIndex        =   7
      Top             =   4440
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
      Index           =   0
      Left            =   240
      TabIndex        =   3
      Top             =   6720
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
      Index           =   0
      Left            =   240
      TabIndex        =   2
      Top             =   5760
      Width           =   2895
   End
End
Attribute VB_Name = "frmConversion"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------
'                      Conversion form
'                      ---------------
'
'            Written
'21May10 XN  Added missing fields for product stock
'               DDDValue
'               DDDUnits
'               UserField1
'               UserField2
'               UserField3
'               HIProduct
'               PIPCode
'               MasterPIP
'               EDILinkCode
'            Also made comparison of PrintFormV case insensitive
'27May10 AJK Changed EDILinkCode datatype for F0061692
'16Jul10 XN  Improved adding the mssing fields F0084942
'16Mar13 TH  PopulateProductStockAndWsupplierProfile: Added fields from v8 for EyeLabel and PSOLabel. (TFS 58981)
'12Nov14 XN  handle individual record errors 43683

'----------------------------------------------------------

Dim idx, linlen, lastpathfile$, ToTlines&, IdxedLines&, dontclose                '22Sep09 PJC added
Const idxminlen% = 7      ' 6 chars for the record pointer, plus <CR> or <LF>    '22Sep09 PJC added
'22Sep09 PJC Added Progress information and mousepointer and Error handler
Private Sub cmdAddenBarcodes_Click()
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
Dim dummy() As Boolean
'R9604PharmacyData000
Dim lngCount As Long             '22Sep09 PJC added
Dim rsSite As ADODB.Recordset    '22Sep09 PJC added as not declared before

      Me.MousePointer = 11
      
      On Error GoTo ERR_HANDLER
      'ConnectionString = txtConnect.Text             '22Sep09 PJC added call to get connection
      ConnectionString = GetConnectionString()        '              "
      
      strSiteNumber = Right$("000" & Trim$(txtDispPath.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
                                        
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      'strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      'Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pSelectAddenBrookesNSV" & strSitenumber, "")
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pSelectSiteProductDataNSV", "")
      If Not rsSite.EOF Then
      rsSite.MoveFirst
      Do While Not rsSite.EOF
      d.SisCode = GetField(rsSite!SisCode)
      getdrug d, 0, lngDummy, False
      'If Trim$(d.barcode) = "0" Or Trim$(d.barcode) = "" And lngDummy > 0 Then
      If lngDummy > 0 Then
         If Trim$(d.barcode) = "" Then
            dummyEAN d.SisCode, d.barcode
            'End If
            lngDummy = PutSiteProductDataNL(d, dummy())
         End If
      End If
      lngDummy = 0
      rsSite.MoveNext
      
      lngCount = lngCount + 1
      If lngCount Mod 100 = 0 Or lngCount = rsSite.RecordCount Or lngCount = 1 Then
         txtStatus = "Processing Dummy Barcodes. RecordCount: " & Format$(lngCount, "0000") & " of " & Format$(rsSite.RecordCount, "0000")
         DoEvents
      End If

      
      Loop
      
      MsgBox "Done"
      End If
      
Cleanup:
      On Error Resume Next
      rsSite.Close
      Set rsSite = Nothing
      Me.MousePointer = 0
      Exit Sub

ERR_HANDLER:
      MsgBox Err.Description, vbCritical
      Resume Cleanup

End Sub

Private Sub CmdAddenbrookesROQROL_Click()
'Dim d As V8DrugParameters
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
'R9604PharmacyData000
Dim lngFound As Long
Dim stkval As Double

      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      'FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      

      'strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      'lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
      GoTo OutPatient
Stores:

      gDispSite = GetLocationID_Site(426)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesconversion426", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
            'update productstock set cost = convert(varchar(9),cast(cast(cast([426stkval].[Avg cost] as float)*100 as money) as decimal(9,1)))
'from [426stkval] where productstock.message = [426stkval].catno
'and locationID_Site = 15
            d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![avg cost])) * GetField(rsSite![costmultiplier]) * 100)))
            '''If Val(GetField(rsSite![pack size])) > 0 And LCase(Trim$(d.PrintformV)) <> "pack" Then
            '''   d.cost = LTrim$(Str$(dp(d.cost / Val(GetField(rsSite![pack size])) * d.convfact)))
            '''End If
            If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
            If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
            '''''d.cost = LTrim$(Str$(dp(Val(d.cost) * Val(GetField(rsSite![IPO]))))) 'Factor in the IPO thang
            'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * d.convfact))
            
            'Factor in the IPO thang
            '''''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![IPO])) * d.convfact))
            'New Attempt
            '''If Val(GetField(rsSite![pack size])) > 0 And LCase(Trim$(d.PrintformV)) <> "pack" Then
               '''''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![pack size])) * d.convfact))
               d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
            '''Else
               '''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock]))))

            '''End If
            
            putdrug d
            End If
            rsSite.MoveNext
         Loop
      End If
      
      
      rsSite.Close
      Set rsSite = Nothing
      
''GoTo out

InPatient:
      
      gDispSite = GetLocationID_Site(427)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesROQROLconversion427", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
            stkval = 0
            stkval = CDbl(Val(GetField(rsSite![Extended Value])))
            stkval = stkval + CDbl(Val(GetField(rsSite![RExtended Value]))) ''REmove for Inpat Only
            
            ''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![dispensing factor])) * d.convfact))
            d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
            d.stocklvl = LTrim$(Str$(Val(d.stocklvl) + (Val(GetField(rsSite![Rstock])) * d.convfact))) ''REmove for Inpat Only
            If Val(d.stocklvl) = 0 Then
            d.cost = "0" '-----here we need from the store !!!(* 100 !!))
            Else
            d.cost = LTrim$(Str$(dp(stkval / Val(d.stocklvl) * d.convfact * 100)))
            End If
            ''d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![Avg cost])) * 100)))
            If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
            If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))

            
            'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
            
            
            End If
            putdrug d
            rsSite.MoveNext
         Loop
      End If
      
''GoTo out

OutPatient:
      
      gDispSite = GetLocationID_Site(428)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesconversion428", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
            'stkval = 0
            'stkval = CDbl(Val(GetField(rsSite![Extended Value])))
            'stkval = stkval + CDbl(Val(GetField(rsSite![RExtended Value])))
            
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock]))))
            '''d.stocklvl = LTrim$(Str$(Val(d.stocklvl) + (Val(GetField(rsSite![Rstock])) * d.convfact)))
            d.stocklvl = LTrim$(Str$((Val(GetField(rsSite![stock])) / Val(GetField(rsSite![Dispensing factor]))) * d.convfact))
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
            
            'If Val(d.stocklvl) = 0 Then
            'd.cost = "0"
            'Else
            '''d.cost = LTrim$(Str$(dp(Val(GetField(rsSite![avg cost])) * d.convfact * 100)))
            'd.cost = LTrim$(Str$(dp((Val(GetField(rsSite![avg cost])) / (Val(GetField(rsSite![Dispensing Factor]))) * d.convfact) * 100)))
            d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![avg cost])) * 100)))
            'd.cost = LTrim$(Str$(dp((Val(GetField(rsSite![avg cost])))))) ' * (Val(GetField(rsSite![Dispensing Factor])))) * 100)))
            ''d.cost = LTrim$(Str$(dp(Val(GetField(rsSite![avg cost])) * 100)))
            'End If
            ''d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![Avg cost])) * 100)))
            If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
            If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
            
            'If Val(d.cost) = 0 And Val(d.cost) = 0 Then
            

            
            'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
            
            
            End If
            putdrug d
            rsSite.MoveNext
         Loop
      End If
      
      
      rsSite.Close
      Set rsSite = Nothing
out:
MsgBox "All Done"
      
End Sub

Private Sub cmdAddenbrooks_Click()
'Dim d As V8DrugParameters
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
Dim strSecondarysup As String
Dim AddAlternativeBarcode As Long
Dim blnNotStores As Boolean
'R9604PharmacyData000


      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      
      
      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeVarChar, 3, strSiteNumber)
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pSelectAddenBrooks" & strSiteNumber, "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            'If lngDrugID > 0 Then
            '''----------------------
            strBarcode = ""
            If gDispSite = 15 Then strBarcode = Trim$(RtrimGetField(rsSite![ean]))
''            '
''            '   If Len(strBarcode) = 8 Or Len(strBarcode) = 13 Then
''            '      strBarcode = strBarcode
''            '      strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, GetField(rsSite![SiteProductDataID])) & _
''            '                  gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 13, strBarcode)
''            '      AddAlternativeBarcode = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWAlternativeBarcodeAdd", strParam)
''            '   End If
''            'GoTo Skip
            '------------------------------
            lngProductStockID = 0
            blnUpdate = False
            BlankWProduct d
            d.SisCode = RtrimGetField(rsSite!NSV)
            'First we get an associated ProductId which we can use to populate the next records.
            '21Feb07 TH Now the main link is on DrugID from SiteProductData
                       
            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
             
            lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforProductID", strParams)
            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
             
            lngDrugID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforDrugID", strParams)
               
            If lngDrugID > 0 Then
   
               DoEvents
               On Error Resume Next
               
               'Now we will populate where we can the d structure
               'We are now etting this from site - this is new !!Not documented though
               If gDispSite = 15 Then
                  d.inuse = RtrimGetField(rsSite![in use])
               Else
               d.inuse = "Y"
               End If
               If Val(RtrimGetField(rsSite!formulary)) = 1 Then
                  d.formulary = "Y"
               Else
                  d.formulary = "N"
               End If
               d.extralabel = ""
               d.minissue = "1"
               d.maxissue = "500" '02May07 TH
               d.issueWholePack = "N"
               d.sisstock = "Y"
               d.livestockctrl = "Y"
               d.outstanding = "0"
               'Added checks on no binno required (so why put that !!!)
               If InStr(RtrimGetField(rsSite![location]), "no binno") = 0 Then d.loccode = RtrimGetField(rsSite![location])
               If InStr(RtrimGetField(rsSite![Secondary location]), "no binno") = 0 Then d.loccode2 = RtrimGetField(rsSite![Secondary location])
               
               d.recalcatperiodend = RtrimGetField(rsSite![Reorder Quantity Calculation])
               d.datelastperiodend = Format(Now, "DDMMYYYY")
               d.usagedamping = "0.75"
               'd.safetyfactor = "1.2"
               d.safetyfactor = "1" 'May07 TH
               d.supcode = RtrimGetField(rsSite![Primary supplier])
               If Trim$(d.supcode) = "" Then d.supcode = "CPSD"
               d.lastordered = ""
               d.stocktakestatus = "0"
               d.altsupcode = "" 'Not used anyway
               d.laststocktakedate = ""
               d.laststocktaketime = ""
               d.batchtracking = "1"
               d.lossesgains = "0"
               d.ledcode = "" '??
               d.pflag = ""
               d.message = RtrimGetField(rsSite![catno])
               d.PILnumber = 0
               d.PIL2 = ""
               d.CreatedUser = "ASC"
               d.createdterminal = "ASC"
               d.createddate = Format(Now, "DDMMYYYY")
               d.createdtime = Format(Now, "HHNNSS")
               d.modifieduser = "ASC"
               d.modifiedterminal = "ASC"
               d.modifieddate = Format(Now, "DDMMYYYY")
               d.modifiedtime = Format(Now, "HHNNSS")
               d.local = RtrimGetField(rsSite![catno]) '??????
               d.civas = "N"
               d.storespack = "PACK"
               ''d.tradename = RtrimGetField(rsSite![brand])
               d.therapcode = ""
               strSecondarysup = GetField(rsSite![Secondary Supplier])
               If strSecondarysup = "N/A" Then strSecondarysup = ""
               
               '14Jul10 XN F0084942 Added missing fields
               d.DDDValue = ""
               d.DDDUnits = ""
               d.UserField1 = ""
               d.UserField2 = ""
               d.UserField3 = ""
               d.HIProduct = ""
               d.pipcode = ""
               d.MasterPip = ""
               d.EDILinkCode = ""
               ' End of F0061692
               
               strBarcode = Trim$(RtrimGetField(rsSite![Primary supplier Barcode]))
               If gDispSite = 19 Then strSecondarysup = ""
               If gDispSite <> 15 Then strBarcode = ""
               'If Len(strBarcode) = 8 Or Len(strBarcode) = 13 Then
               '   strBarcode = strBarcode
               '   strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, GetField(rsSite![SiteProductDataID])) & _
               '               gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 13, strBarcode)
               '   AddAlternativeBarcode = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWAlternativeBarcodeAdd", strParam)
               'Else
               '
               'End If
               'strBarcode = "" 'Calc the default elsewhere
         
               '------------
               'Important stuff - dont forget
               '-----------------------------
               On Error GoTo 0
               '17May07 This is not supplied in locations any more d.cost = Format$(Val(RtrimGetField(rsSite![price per pack ex VAT])) * 100, "########.####")
               ''d.stocklvl = Format$(RtrimGetField(rsSite![stock]))
               If RtrimGetField(rsSite![VAT]) = "A" Then 'Was A !!!!!
                  d.vatrate = "1"
               Else
                  d.vatrate = "0"
               End If
               'Set the Oral suppositories
               If Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.01" Or Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.02" Or Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.04" Then
                  d.vatrate = "2"
               End If
               If gDispSite <> 15 Then blnNotStores = True
               'If d.loccode = "RBT" Then blnNotStores = False
               If gDispSite = 19 Then
                  If d.loccode = "RBT" Then
                     'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![RROL])) * RtrimGetField(rsSite![convfact]))
                     'd.reorderqty = Int((RtrimGetField(rsSite![RROQ])) + 0.9999) 'Round up !
                     '17May07 TH Now need to add the reorder levels of robot and none robot
                     '17May07 TH removed to below d.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * Val(GetField(rsSite![HORIS conversion factor])))
                     'd.reorderlvl = Format$(Val(d.reorderlvl) + Val(RtrimGetField(rsSite![NROL])) * Val(GetField(rsSite![HORIS conversion factor])))
                     '''''d.reorderqty = Int((RtrimGetField(rsSite![NROQ])) + 0.9999) 'Round up !

                     d.anuse = Int((Val(RtrimGetField(rsSite![issues pcm-rbt])) * 12 * Val(GetField(rsSite![HORIS conversion factor - rbt]))) + 0.9999)
                     
                  Else
                     'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * Val(RtrimGetField(rsSite![HORIS conversion factor])))
                     'd.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![HORIS conversion factor]))) + 0.9999) 'Round up !
                     '17May07 TH removed to below d.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) / Val(RtrimGetField(rsSite![Dispensing factor])) * RtrimGetField(rsSite![convfact]))
                     '''''d.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![Dispensing factor]))) + 0.9999)
                     d.anuse = Int((((Val(RtrimGetField(rsSite![issues pcm ipp])) * 12) / Val(RtrimGetField(rsSite![DF - ipp]))) * RtrimGetField(rsSite![convfact])) + 0.9999)
                  End If
                  '17May07 TH Now need to add the reorder levels of robot and none robot
                  intRobotRol = (Val(d.reorderlvl) + Val(RtrimGetField(rsSite![ROL - Rbt])) * Val(GetField(rsSite![HORIS conversion factor - rbt])))
                  intRol = (Val(RtrimGetField(rsSite![ROL - IPP])) / Val(RtrimGetField(rsSite![DF - ipp])) * RtrimGetField(rsSite![convfact]))
                  d.reorderlvl = Format$(intRobotRol + intRol)
               Else
                  If blnNotStores Then
                     'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) / Val(RtrimGetField(rsSite![Dispensing factor])) * RtrimGetField(rsSite![convfact]))
                      'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) * Val(RtrimGetField(rsSite![HORIS conversion factor])))
                      ''''d.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) * RtrimGetField(rsSite![convfact]))
                       '11apr07 TH Factor DF then round up to nearest pack
                       'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * Val(RtrimGetField(rsSite![HORIS conversion factor])))
                       'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * Val(RtrimGetField(rsSite![HORIS conversion factor])))
                     d.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) / Val(RtrimGetField(rsSite![DF])) * RtrimGetField(rsSite![convfact]))
                     d.anuse = Int((((Val(RtrimGetField(rsSite![issues pcm])) * 12) / Val(RtrimGetField(rsSite![DF]))) * RtrimGetField(rsSite![convfact])) + 0.9999)
                    
                  Else
                     '''''d.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * RtrimGetField(rsSite![convfact]))
                     '''''d.anuse = Int((Val(RtrimGetField(rsSite![issuespcm])) * 12 * RtrimGetField(rsSite![convfact])) + 0.9999)
                     d.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) * Val(GetField(rsSite![HORIS conversion factor])))
                     d.anuse = Int((Val(RtrimGetField(rsSite![issuespcm])) * 12 * Val(GetField(rsSite![HORIS conversion factor]))) + 0.9999)
                  
                     'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![NROL])) * Val(RtrimGetField(rsSite![HORIS conversion factor])))
                     'd.reorderqty = RtrimGetField(rsSite![ROQ])
                  End If
'''''                  If blnNotStores Then
'''''                     'd.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![Dispensing factor]))) + 0.9999) 'Round up !
'''''                     'd.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![HORIS conversion factor]))) + 0.9999) 'Round up !
'''''                     'd.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![Dispensing factor])) * RtrimGetField(rsSite![convfact])) + 0.9999)
'''''                     d.reorderqty = Int((Val(RtrimGetField(rsSite![NROQ])) / Val(RtrimGetField(rsSite![Dispensing factor]))) + 0.9999)
'''''                  Else
'''''                     d.reorderqty = Int((RtrimGetField(rsSite![NROQ])) + 0.9999) 'Round up !
'''''                  End If
               End If
                  
               d.reorderqty = Int(((Val(d.reorderlvl) * 2) / Val(RtrimGetField(rsSite![convfact]))) + 0.9999)
               'If Val(d.reorderlvl) = 0 Or Val(d.reorderqty) = 0 Then
               
               'If gDispSite = 15 Or gDispSite = 20 Then
               'More new gubbins unasked for (only supplied for Store, Outpatient)
                  d.sisstock = RtrimGetField(rsSite![stocked])
               'Else
               '   If Val(d.reorderlvl) = 0 And RtrimGetField(rsSite![Reorder Quantity Calculation]) = "N" Then
               '      d.sisstock = "N"
               '   Else
               '      d.sisstock = "Y"
               '   End If
               'End If
               
               On Error Resume Next
               If gDispSite = 15 Then '24Apr05 TH only need outers in store
                  d.reorderpcksize = RtrimGetField(rsSite![MOQ]) * RtrimGetField(rsSite![IPO])
               Else
                  d.reorderpcksize = ""
               End If
               'd.reorderpcksize = RtrimGetField(rsSite![MOQ]) / Val(GetField(rsSite![IPO])) '11Apr07 TH Divide now by IPO
               If Val(RtrimGetField(rsSite![IPO])) > 0 Then
                  d.sislistprice = Format$(Val(RtrimGetField(rsSite![Latest price]) / RtrimGetField(rsSite![IPO]) * 100), "########.####")
               Else
                  d.sislistprice = Format$(Val(RtrimGetField(rsSite![Latest price]) * 100), "########.####")
               End If
               d.sislistprice = Format$(Val(d.sislistprice))
               If Trim$(d.sislistprice) = "." Then d.sislistprice = "0"
               
               If Trim$(d.cost) = "." Then d.sislistprice = "0"
               
               'Fudge for Golive stuff
               'If d.vatrate = "1" Then d.sislistprice = LTrim$(Str$(dp((Val(d.sislistprice) / 117.5) * 100)))
               'If d.vatrate = "2" Then d.sislistprice = LTrim$(Str$(dp((Val(d.sislistprice) / 105) * 100)))
               'If Val(d.cost) = 0 Then d.sislistprice = "0"
               '--------------------------
            
               
               'If Trim$(d.sislistprice) = "" Then d.sislistprice = d.cost 'Later if at all as this is a bogus bad cost
               
               
               'OMiGod Here we need to check if the issueunits are different. If they are the cost will be altered !!!
   ''            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
   ''                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
   ''            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strParams)
   ''            If Not rsAddon.EOF Then
   ''               'prod.dosesperissueunit = rsAddon!doseperissueunit
   ''               If Trim$(UCase$(rsAddon![PrintformV])) <> Trim$(UCase$(prod.PrintformV)) Then
   ''                  'here we need to alter the value 'No we dont
   ''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
   ''                  '''MsgBox "Houston - Could be a problem here !"
   ''
   ''               End If
   ''               '22Jan07 TH Added section
   ''               If rsAddon![convfact] <> Val(prod.convfact) Then
   ''                  'here we need to alter the value 'No we dont
   ''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
   ''
   ''                  prod.stocklvl = Format$(((Val(prod.stocklvl) / Val(prod.convfact)) * rsAddon![convfact]))
   ''                  prod.convfact = Format$(rsAddon![convfact])
   ''                  '!!! We need to alter the stock level
   ''
   ''               End If
   ''
   ''            End If
   ''            Set rsAddon = Nothing
               
               With d
                  strSQL = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, .inuse) & _
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
                   
                        
                  strSQL = strSQL & _
                        gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                        gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
                        gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
                        gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, .reorderlvl) & _
                        gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                        gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
                        gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
                        gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
                        gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
   
      
               
                  strSQL = strSQL & _
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
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
                           gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
                           gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
                           gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
                           gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
                           gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
                           gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
                           gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
                           gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message)
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
                           gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
                           gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
                           gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
                           gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
                           gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
                           gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
                           gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .local)
                  strSQL = strSQL & _
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
                           gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, 0) & _
                           gTransport.CreateInputParameterXML("dosesperIssueunit", trnDataTypeFloat, 8, .dosesperissueunit) & _
                           gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .storespack) & _
                           gTransport.CreateInputParameterXML("Therpcode", trnDataTypeVarChar, 2, .therapcode)
                  '27May10 AJK F0061692 Changed datatype of EDILinkCode to char
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID) & _
                           gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, .DDDValue) & _
                           gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, .DDDUnits) & _
                           gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .UserField1) & _
                           gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .UserField2) & _
                           gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, .UserField3) & _
                           gTransport.CreateInputParameterXML("HIProduct", trnDataTypeVarChar, 1, .HIProduct) & _
                           gTransport.CreateInputParameterXML("PIPCode", trnDataTypeVarChar, 7, .pipcode) & _
                           gTransport.CreateInputParameterXML("MasterPIP", trnDataTypeVarChar, 7, .MasterPip) & _
                           gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeChar, 13, .EDILinkCode)
                End With
   ''            gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
   ''                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal) & _
   ''                        gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
   ''                        gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _
'14Jul10 XN F0084942 Removed dead code
'               If lngProductStockID > 0 Then
'                  strSQL = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) & _
'                           gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) & strSQL
'                  lngProductStockID = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strSQL)
'                  blnUpdate = True
'               Else
' end of F0084942
                  strSQL = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
                           & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strSQL
                  ''dummy = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
                  '.ProductStockID = dummy '05Jul05 TH Added
'                   strSQL = strSQL & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID)
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSQL)
'               End If '14Jul10 XN F0084942 Removed dead code
               If lngProductStockID > 0 And (Not blnUpdate) Then
                  'And finally a Supplier profile record for the default supplier
                  'Later we may want to create extra records for each altsupplier or directly convert supplier profiles (best to do that first I reckon)
                  With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderOuter", trnDataTypeVarChar, 6, .reorderpcksize) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                  End With
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
''                  strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
''                     gTransport.CreateInputParameterXML("Barcode", trnDataTypeVarChar, 13, d.barcode) & _
''                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
''
''                  lngDummy = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pSiteProductDataUpdateBarcodebysisCode", strParams)
                  If Trim$(strBarcode) <> "" And Val(strBarcode) > 0 Then
                    strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                       gTransport.CreateInputParameterXML("Barcode", trnDataTypeVarChar, 13, strBarcode) & _
                       gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
            
                    lngDummy = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pAlternativeBarcodeConversionInsert", strParams)
                  End If
                  
                  If Trim$(strSecondarysup) <> "" And Val(strSecondarysup) > 0 Then
                     'lets create another supplier profile for the other supplier
                     'WE need to see if we have any other details for this. For now we MUST not use primary sup values
                     'where these are specific
                     With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, Trim$(strSecondarysup)) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("ReorderOuter", trnDataTypeVarChar, 6, .reorderpcksize) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, "0") & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, "0") & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                  End With
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)

                  End If
               End If
            Else
               Debug.Print prod.SisCode
            End If
Skip:
         rsSite.MoveNext
      Loop
      End If
          
      MsgBox "All Done"
      
End Sub

Private Sub cmdAddenStockConvert_Click()
'Dim d As V8DrugParameters
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
'R9604PharmacyData000
Dim lngFound As Long
Dim stkval As Double

      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      'FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      

      'strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      'lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
      GoTo InPatient
Stores:

      gDispSite = GetLocationID_Site(426)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesconversion426", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
            'update productstock set cost = convert(varchar(9),cast(cast(cast([426stkval].[Avg cost] as float)*100 as money) as decimal(9,1)))
'from [426stkval] where productstock.message = [426stkval].catno
'and locationID_Site = 15
            d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![avg cost])) * GetField(rsSite![costmultiplier]) * 100)))
            '''If Val(GetField(rsSite![pack size])) > 0 And LCase(Trim$(d.PrintformV)) <> "pack" Then
            '''   d.cost = LTrim$(Str$(dp(d.cost / Val(GetField(rsSite![pack size])) * d.convfact)))
            '''End If
            If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
            If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
            If Val(d.cost) = 0 Then d.cost = "0"
            '''''d.cost = LTrim$(Str$(dp(Val(d.cost) * Val(GetField(rsSite![IPO]))))) 'Factor in the IPO thang
            'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * d.convfact))
            
            'Factor in the IPO thang
            '''''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![IPO])) * d.convfact))
            'New Attempt
            '''If Val(GetField(rsSite![pack size])) > 0 And LCase(Trim$(d.PrintformV)) <> "pack" Then
               '''''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![pack size])) * d.convfact))
               d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
            '''Else
               '''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock]))))
            If Val(d.stocklvl) = 0 Then d.stocklvl = "0"
            '''End If
            
            putdrug d
            End If
            rsSite.MoveNext
         Loop
      End If
      
      
      rsSite.Close
      Set rsSite = Nothing
      
GoTo OutPatient

InPatient:
      
      gDispSite = GetLocationID_Site(427)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesconversion427", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
               stkval = 0
               stkval = CDbl(Val(GetField(rsSite![Extended Value])))
               stkval = stkval + CDbl(Val(GetField(rsSite![RExtended Value]))) ''REmove for Inpat Only
               
               ''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![dispensing factor])) * d.convfact))
               ''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
               d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor - IPP]))))
               d.stocklvl = LTrim$(Str$(Val(d.stocklvl) + (Val(GetField(rsSite![Rstock])) * d.convfact))) ''REmove for Inpat Only
               If Val(d.stocklvl) = 0 Then
                  '17May07 TH Now do get the stores cost
                  d.cost = LTrim$(Str$(Val(GetField(rsSite![storescost])) * 100)) '"0" '-----here we need from the store !!!(* 100 !!))
               Else
                  d.cost = LTrim$(Str$(dp(stkval / Val(d.stocklvl) * d.convfact * 100)))
               End If
               ''d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![Avg cost])) * 100)))
               If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
               If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
               If Val(d.cost) = 0 Then d.cost = "0"
               
               'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
               
            
            End If
            putdrug d
            rsSite.MoveNext
         Loop
      End If
      
GoTo out

OutPatient:
      
      gDispSite = GetLocationID_Site(428)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pAddenBrookesconversion428", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
            'stkval = 0
            'stkval = CDbl(Val(GetField(rsSite![Extended Value])))
            'stkval = stkval + CDbl(Val(GetField(rsSite![RExtended Value])))
            
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock]))))
            '''d.stocklvl = LTrim$(Str$(Val(d.stocklvl) + (Val(GetField(rsSite![Rstock])) * d.convfact)))
            d.stocklvl = LTrim$(Str$((Val(GetField(rsSite![stock])) / Val(GetField(rsSite![Dispensing factor]))) * d.convfact))
            'd.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
            
            'If Val(d.stocklvl) = 0 Then
            'd.cost = "0"
            'Else
            '''d.cost = LTrim$(Str$(dp(Val(GetField(rsSite![avg cost])) * d.convfact * 100)))
            'd.cost = LTrim$(Str$(dp((Val(GetField(rsSite![avg cost])) / (Val(GetField(rsSite![Dispensing Factor]))) * d.convfact) * 100)))
            d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![avg cost])) * 100)))
            'd.cost = LTrim$(Str$(dp((Val(GetField(rsSite![avg cost])))))) ' * (Val(GetField(rsSite![Dispensing Factor])))) * 100)))
            ''d.cost = LTrim$(Str$(dp(Val(GetField(rsSite![avg cost])) * 100)))
            'End If
            ''d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![Avg cost])) * 100)))
            If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
            If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
            If Val(d.cost) = 0 Then d.cost = "0"
            'If Val(d.cost) = 0 And Val(d.cost) = 0 Then
            

            
            'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
            
            
            End If
            putdrug d
            rsSite.MoveNext
         Loop
      End If
      
      
      rsSite.Close
      Set rsSite = Nothing
out:
MsgBox "All Done"
      
End Sub

Private Sub cmdBNF_Click()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSiteNumber & "\NOD" For Input As #fil Len = 16
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
Dim strSQL As String
Dim g_SessionID As Long
Dim g_adoCn As ADODB.Connection
'Dim gTransport As T9906PharmacyData000.Transport
Dim gTransport As PharmacyData.Transport
Dim lngOK As Long



ConnectionString = txtConnect.Text

g_SessionID = Val(txtSession.Text)

Set g_adoCn = New ADODB.Connection
g_adoCn.ConnectionString = ConnectionString
g_adoCn.Open

' gTransport.Connection.Open(
Set gTransport = New PharmacyData.Transport
'Set gTransport = New T9906PharmacyData000.Transport
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

Private Sub cmdHereford_Click()
'Dim d As V8DrugParameters
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
Dim strSecondarysup As String
Dim AddAlternativeBarcode As Long
Dim blnNotStores As Boolean
'R9604PharmacyData000
Dim strPrimarysup As String
Dim strThirdsup As String
Dim strFourthsup As String
Dim rsBin As ADODB.Recordset
Dim strLoc As String
Dim strfirst As String
Dim strSecond As String


      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      
      
      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeVarChar, 3, strSiteNumber)
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pSelectHereford" & strSiteNumber, "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            'If lngDrugID > 0 Then
            '''----------------------
''            'strBarcode = Trim$(RtrimGetField(rsSite![Primary supplier Bar code]))
''            '
''            '   If Len(strBarcode) = 8 Or Len(strBarcode) = 13 Then
''            '      strBarcode = strBarcode
''            '      strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, GetField(rsSite![SiteProductDataID])) & _
''            '                  gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 13, strBarcode)
''            '      AddAlternativeBarcode = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWAlternativeBarcodeAdd", strParam)
''            '   End If
''            'GoTo Skip
            '------------------------------
            lngProductStockID = 0
            blnUpdate = False
            BlankWProduct d
            d.SisCode = RtrimGetField(rsSite!siteCode)
            'First we get an associated ProductId which we can use to populate the next records.
            '21Feb07 TH Now the main link is on DrugID from SiteProductData
                       
''            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
''                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
             
'            lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforProductID", strParams)
            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
             
            lngDrugID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforDrugID", strParams)
               
            If lngDrugID > 0 Then
   
               DoEvents
               On Error Resume Next
               
               d.cost = Format$(dp(Val(RtrimGetField(rsSite![Issue Price(exc VAT)]))), "########.####")
               'd.cost = Format$(dp(Val(RtrimGetField(rsSite![Average Price])) * 100), "########.####")
               
               'Select Case RtrimGetField(rsSite![VAT])
               Select Case RtrimGetField(rsSite![First Supplier VAT rate])
                  Case 17.5: d.vatrate = "1"
                  Case 5: d.vatrate = "2"
                  Case 0: d.vatrate = "0"
                  Case Else: d.vatrate = "1"
               End Select
               If RtrimGetField(rsSite![Manual Order Only flag]) = "Y" Then d.sisstock = "N"
               If RtrimGetField(rsSite![Manual Order Only flag]) = "N" Then d.sisstock = "Y"

               
               'Now we will populate where we can the d structure
               d.inuse = "Y"
               d.recalcatperiodend = "Y"
               d.livestockctrl = "Y"
               d.batchtracking = "1" 'none
               d.minissue = "1"
               d.maxissue = "1000"
               d.reorderlvl = Format$(Val(RtrimGetField(rsSite![OrdLvl (IssUnit)])))
               'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![Reorder Level])))
               d.reorderqty = Format$(Val(RtrimGetField(rsSite![OrdQty (Pk)1])))
               'd.reorderqty = Format$(Val(RtrimGetField(rsSite![Reorder Quantity])))
               d.stocklvl = Format$(Val(RtrimGetField(rsSite![StkBalOut])))
               'd.stocklvl = Format$(Val(RtrimGetField(rsSite![Stock Balance])))
               d.sislistprice = Format$(dp(Val(RtrimGetField(rsSite![Issue Price(exc VAT)]))))
               'd.sislistprice = Format$(dp(Val(RtrimGetField(rsSite![Average Price])) * 100))
               d.usagedamping = "0.75"
               d.safetyfactor = "1.2"
               d.stocktakestatus = "0"
               d.altsupcode = "" 'Not used anyway
               d.laststocktakedate = ""
               d.laststocktaketime = ""
               d.issueWholePack = "N"
               d.anuse = Format$(dp(Val(RtrimGetField(rsSite![AveYD]))))
               'd.anuse = Format$(dp(Val(RtrimGetField(rsSite![Average Daily Demand])) * 365))
               'Goddam 3rd parties - need to change again!
''               strLoc = RtrimGetField(rsSite![bin])
''               If Len(Trim$(strLoc)) > 0 Then
''                  If InStr(strLoc, "\") > 0 Then
''                  'We have two locations
''               'd.loccode = RtrimGetField(rsSite![loc1])
''               'd.loccode2 = RtrimGetField(rsSite![loc2])
''                  'the first
''                     strfirst = Left$(strLoc, (InStr(strLoc, "\") - 1))
''                     strSecond = Right$(strLoc, Len(strLoc) - InStr(strLoc, "\"))
''                     strParams = gTransport.CreateInputParameterXML("Loc", trnDataTypeVarChar, 10, strfirst)
''                     Set rsBin = gTransport.ExecuteSelectSP(g_SessionID, "pConvertHerefordBin", strParams)
''                     If rsBin.RecordCount > 0 Then
''                        d.loccode = RtrimGetField(rsBin![loc1])
''                     End If
''                     Set rsBin = Nothing
''                     strParams = gTransport.CreateInputParameterXML("Loc", trnDataTypeVarChar, 10, strSecond)
''                     Set rsBin = gTransport.ExecuteSelectSP(g_SessionID, "pConvertHerefordBin", strParams)
''                     If rsBin.RecordCount > 0 Then
''                        d.loccode2 = RtrimGetField(rsBin![loc1])
''                     End If
''                     Set rsBin = Nothing
''                  Else
''                     'just get the first
''                     strParams = gTransport.CreateInputParameterXML("Loc", trnDataTypeVarChar, 10, strLoc)
''                     Set rsBin = gTransport.ExecuteSelectSP(g_SessionID, "pConvertHerefordBin", strParams)
''                     If rsBin.RecordCount > 0 Then
''                        d.loccode = RtrimGetField(rsBin![loc1])
''                     End If
''                     Set rsBin = Nothing
''                  End If
''               End If
               d.loccode = RtrimGetField(rsSite![loc1])
               d.loccode2 = RtrimGetField(rsSite![loc2])
               d.formulary = "Y"
               '----------------------------
               
               d.extralabel = ""
               d.sisstock = "Y"
               d.outstanding = "0"
               'Added checks on no binno required (so why put that !!!)
               
               d.datelastperiodend = Format(Now, "DDMMYYYY")
               
               ''If Trim$(d.supcode) = "" Then d.supcode = "CPSD"
               d.lastordered = ""
               d.stocktakestatus = "0"
               d.altsupcode = "" 'Not used anyway
               d.laststocktakedate = ""
               d.laststocktaketime = ""
               d.batchtracking = "1"
               d.lossesgains = "0"
               d.ledcode = "" '??
               d.pflag = ""
               d.message = RtrimGetField(rsSite![Unique code])
               d.PILnumber = 0
               d.PIL2 = ""
               d.CreatedUser = "ASC"
               d.createdterminal = "ASC"
               d.createddate = Format(Now, "DDMMYYYY")
               d.createdtime = Format(Now, "HHNNSS")
               d.modifieduser = "ASC"
               d.modifiedterminal = "ASC"
               d.modifieddate = Format(Now, "DDMMYYYY")
               d.modifiedtime = Format(Now, "HHNNSS")
               d.local = "" '??????
               d.civas = "N"
               d.storespack = "PACK"
               ''d.tradename = RtrimGetField(rsSite![brand])
               d.therapcode = ""
               strSecondarysup = GetField(rsSite![sup2])
               strThirdsup = GetField(rsSite![sup3])
               strFourthsup = GetField(rsSite![sup4])
                              
               '14Jul10 XN F0084942 Added missing fields
               d.DDDValue = ""
               d.DDDUnits = ""
               d.UserField1 = ""
               d.UserField2 = ""
               d.UserField3 = ""
               d.HIProduct = ""
               d.pipcode = ""
               d.MasterPip = ""
               d.EDILinkCode = ""
               ' End of F0061692
               
               'strBarcode = Trim$(RtrimGetField(rsSite![Primary supplier Bar code]))
               'If Len(strBarcode) = 8 Or Len(strBarcode) = 13 Then
               '   strBarcode = strBarcode
               '   strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, GetField(rsSite![SiteProductDataID])) & _
               '               gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 13, strBarcode)
               '   AddAlternativeBarcode = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWAlternativeBarcodeAdd", strParam)
               'Else
               '
               'End If
               strBarcode = "" 'Calc the default elsewhere
         
               '------------
               'Important stuff - dont forget
               '-----------------------------
''               On Error GoTo 0
''               d.cost = Format$(Val(RtrimGetField(rsSite![price per pack ex VAT])) * 100, "########.####")
''               ''d.stocklvl = Format$(RtrimGetField(rsSite![stock]))
''               If RtrimGetField(rsSite![VAT]) = "A" Then
''                  d.vatrate = "1"
''               Else
''                  d.vatrate = "0"
''               End If
''               'Set the Oral suppositories
''               If Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.01" Or Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.02" Or Left$(RtrimGetField(rsSite![bnf]) & Space$(10), 8) = "07.03.04" Then
''                  d.vatrate = "2"
''               End If
''               If gDispSite <> 15 Then blnNotStores = True
''               ''If d.loccode = "RBT" Then blnNotStores = False
''               If blnNotStores Then
''                  d.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) / Val(RtrimGetField(rsSite![dispensing factor])) * RtrimGetField(rsSite![convfact]))
''                    '11apr07 TH Factor DF then round up to nearest pack
''               Else
''                  d.reorderlvl = Format$(Val(RtrimGetField(rsSite![ROL])) * RtrimGetField(rsSite![convfact]))
''                  'd.reorderqty = RtrimGetField(rsSite![ROQ])
''               End If
''               d.reorderqty = Int((RtrimGetField(rsSite![ROQ])) + 0.5)
''               If Val(d.reorderlvl) = 0 Or Val(d.reorderqty) = 0 Then
''                  d.sisstock = "N"
''               Else
''                  d.sisstock = "Y"
''               End If
               
               On Error Resume Next
               d.reorderpcksize = "1"
''               RtrimGetField(rsSite![MOQ])
''               'd.reorderpcksize = RtrimGetField(rsSite![MOQ]) / Val(GetField(rsSite![IPO])) '11Apr07 TH Divide now by IPO
''               If Val(RtrimGetField(rsSite![IPO])) > 0 Then
''                  d.sislistprice = Format$(RtrimGetField(rsSite![Latest price paid (ex VAT)]) / RtrimGetField(rsSite![IPO]) * 100, "########.####")
''               Else
''                  d.sislistprice = Format$(RtrimGetField(rsSite![Latest price paid (ex VAT)]) * 100, "########.####")
''               End If
''               If Trim$(d.sislistprice) = "." Then d.sislistprice = "0"
               'If Trim$(d.sislistprice) = "" Then d.sislistprice = d.cost 'Later if at all as this is a bogus bad cost
               'PRIMARY SUPPLIER
               d.supcode = RtrimGetField(rsSite![sup1])
               strPrimarysup = d.supcode
               'OMiGod Here we need to check if the issueunits are different. If they are the cost will be altered !!!
   ''            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
   ''                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
   ''            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strParams)
   ''            If Not rsAddon.EOF Then
   ''               'prod.dosesperissueunit = rsAddon!doseperissueunit
   ''               If Trim$(UCase$(rsAddon![PrintformV])) <> Trim$(UCase$(prod.PrintformV)) Then
   ''                  'here we need to alter the value 'No we dont
   ''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
   ''                  '''MsgBox "Houston - Could be a problem here !"
   ''
   ''               End If
   ''               '22Jan07 TH Added section
   ''               If rsAddon![convfact] <> Val(prod.convfact) Then
   ''                  'here we need to alter the value 'No we dont
   ''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
   ''
   ''                  prod.stocklvl = Format$(((Val(prod.stocklvl) / Val(prod.convfact)) * rsAddon![convfact]))
   ''                  prod.convfact = Format$(rsAddon![convfact])
   ''                  '!!! We need to alter the stock level
   ''
   ''               End If
   ''
   ''            End If
   ''            Set rsAddon = Nothing
               
               With d
                  strSQL = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, .inuse) & _
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
                   
                        
                  strSQL = strSQL & _
                        gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                        gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
                        gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
                        gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, .reorderlvl) & _
                        gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                        gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
                        gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
                        gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
                        gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
   
      
               
                  strSQL = strSQL & _
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
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
                           gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
                           gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
                           gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
                           gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
                           gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
                           gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
                           gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
                           gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message)
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
                           gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
                           gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
                           gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
                           gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
                           gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
                           gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
                           gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .local)
                  strSQL = strSQL & _
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
                           gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, 0) & _
                           gTransport.CreateInputParameterXML("dosesperIssueunit", trnDataTypeFloat, 8, .dosesperissueunit) & _
                           gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .storespack) & _
                           gTransport.CreateInputParameterXML("Therpcode", trnDataTypeVarChar, 2, .therapcode)
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID) & _
                           gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, .DDDValue) & _
                           gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, .DDDUnits) & _
                           gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .UserField1) & _
                           gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .UserField2) & _
                           gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, .UserField3) & _
                           gTransport.CreateInputParameterXML("HIProduct", trnDataTypeVarChar, 1, .HIProduct) & _
                           gTransport.CreateInputParameterXML("PIPCode", trnDataTypeVarChar, 7, .pipcode) & _
                           gTransport.CreateInputParameterXML("MasterPIP", trnDataTypeVarChar, 7, .MasterPip) & _
                           gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeChar, 4, .EDILinkCode)
                           
               End With
   ''            gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
   ''                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal) & _
   ''                        gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
   ''                        gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _

' 14Jul10 XN F0084942 Removed what looked like dead code.
'               If lngProductStockID > 0 Then
'                  strSQL = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) & _
'                           gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) & strSQL
'                  lngProductStockID = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strSQL)
'                  blnUpdate = True
'               Else
' end of F0084942
                  strSQL = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
                           & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strSQL
                  ''dummy = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
                  '.ProductStockID = dummy '05Jul05 TH Added
'                   strSQL = strSQL & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID)
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSQL)
'               End If ' 14Jul10 XN F0084942 Removed what looked like dead code.
               If lngProductStockID > 0 And (Not blnUpdate) Then
                  'And finally a Supplier profile record for the default supplier
                  'Later we may want to create extra records for each altsupplier or directly convert supplier profiles (best to do that first I reckon)
                  d.contno = Format$(RtrimGetField(rsSite![ContractOut]))
                  d.contprice = Format$(dp(Val(RtrimGetField(rsSite![Contract price pence exc VAT]))))
                     
                  With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderOuter", trnDataTypeVarChar, 6, .reorderpcksize) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                  End With
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
                  strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                     gTransport.CreateInputParameterXML("Barcode", trnDataTypeVarChar, 13, d.barcode) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
            
                  lngDummy = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pSiteProductDataUpdateBarcodebysisCode", strParams)
                  d.contno = ""
                  d.contprice = ""
                  
                  If Trim$(strSecondarysup) <> "" And (Trim$(strSecondarysup) <> Trim$(strPrimarysup)) Then
                     'lets create another supplier profile for the other supplier
                     With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, Trim$(strSecondarysup)) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                     End With
                     lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
                  End If
                  If Trim$(strThirdsup) <> "" And ((Trim$(strThirdsup) <> Trim$(strPrimarysup)) And (Trim$(strThirdsup) <> Trim$(strSecondarysup))) Then
                     'lets create another supplier profile for the other supplier
                     d.contno = Format$(RtrimGetField(rsSite![ContractOut1]))
                     d.contprice = Format$(dp(Val(RtrimGetField(rsSite![Contract price pence exc VAT]))))
                     With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, Trim$(strThirdsup)) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                     End With
                     lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
                  End If
                  d.contno = ""
                  d.contprice = ""
                     
                  If Trim$(strFourthsup) <> "" And ((Trim$(strFourthsup) <> Trim$(strPrimarysup)) And (Trim$(strFourthsup) <> Trim$(strSecondarysup)) And (Trim$(strFourthsup) <> Trim$(strThirdsup))) Then
                     'lets create another supplier profile for the other supplier
                     With d
                     strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, Trim$(strFourthsup)) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                           ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
                     End With
                     lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
                  End If
               End If
            Else
               Debug.Print prod.SisCode
            End If
Skip:
         rsSite.MoveNext
      Loop
      End If
          
      MsgBox "All Done"
End Sub

Private Sub CmdHerefordStockConvert_Click()
Dim d As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
Dim lngDummy As Long
'R9604PharmacyData000
Dim lngFound As Long
Dim stkval As Double
Dim stock As Long
Dim rsStock As ADODB.Recordset
Dim rsSite As ADODB.Recordset
Dim strCost As String
      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      'FILE$ = txtDrive.Text & ":\dispdata." & strSitenumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      

      'strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      'lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
      ''GoTo OutPatient


InPatient:
      
      gDispSite = GetLocationID_Site(173)
      
      Set rsSite = gTransport.ExecuteSelectSP(g_SessionID, "pWproductSisCode", "")
         
      If rsSite.RecordCount > 0 Then
         Do While Not rsSite.EOF
            d.SisCode = GetField(rsSite!SisCode)
            DoEvents
            lngFound = 0
            getdrug d, 0, lngFound, True
            If lngFound > 0 Then
               strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
               Set rsStock = gTransport.ExecuteSelectSP(g_SessionID, "pHerefordStockconversion", strParams)
               'REORDER ONLY
''               If InStr(d.reorderqty, ".") > 0 Then d.reorderqty = Format(Int((Val(d.reorderqty)) + 0.9999))
''               GoTo reorder
               
               
               
               stkval = 0
               stock = 0
               strCost = "0"
               d.lossesgains = "0"
               If rsStock.RecordCount > 1 Then MsgBox "biggy"
               Do While Not rsStock.EOF
                  stkval = stkval + CDbl(Val(GetField(rsStock![StkVal(p)]))) ''REmove for Inpat Only
                  stock = stock + CLng(Val(GetField(rsStock![StkBalOut])))
                  d.reorderlvl = Format$(Val(RtrimGetField(rsStock![OrdLvl (IssUnit)])))
                  'd.reorderlvl = Format$(Val(RtrimGetField(rsSite![Reorder Level])))
                  d.reorderqty = Format$(Val(RtrimGetField(rsStock![OrdQty (Pk) - Out])))
                  strCost = Format$(dp(Val(RtrimGetField(rsStock![Issue Price(exc VAT)]))), "########.####")
                  If InStr(d.reorderqty, ".") > 0 Then
                     d.reorderqty = Format$(Int((Val(d.reorderqty)) + 0.9999))
                  End If
               
                  rsStock.MoveNext
               Loop
               ''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) / Val(GetField(rsSite![dispensing factor])) * d.convfact))
               ''d.stocklvl = LTrim$(Str$(Val(GetField(rsSite![stock])) * Val(GetField(rsSite![HORIS conversion factor]))))
               d.stocklvl = LTrim$(Str$(stock))
               'd.stocklvl = LTrim$(Str$(Val(d.stocklvl) + (Val(GetField(rsSite![Rstock])) * d.convfact))) ''REmove for Inpat Only
               If Val(d.stocklvl) = 0 Then
                  'NB We are using converted cost here and this is NET already no VAT calcs
                  '17May07 TH Now do get the stores cost ALREADY THERE
                  'd.cost = LTrim$(Str$(Val(GetField(rsSite![storescost])) * 100)) '"0" '-----here we need from the store !!!(* 100 !!))
                  d.cost = strCost
               
                  If Val(d.cost) = 0 Then d.cost = "0"
                  If Val(stkval) <> 0 Then
                     'Here we put in losses and gains
                     d.lossesgains = LTrim$(Str$(dp(Val(stkval))))
                  End If
                  
               Else
                  'd.cost = LTrim$(Str$(dp(stkval / Val(d.stocklvl) * d.convfact * 100))) stkval already in pence
                  d.cost = LTrim$(Str$(dp(stkval / Val(d.stocklvl) * d.convfact)))
                  'This value is Gross so we must back calculate the VAT
                  If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
                  If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
                  If Val(d.cost) = 0 Then d.cost = "0"
            
               End If
               If Val(d.stocklvl) = 0 Then d.stocklvl = "0"
               
               ''d.cost = LTrim$(Str$(dp(CDbl(GetField(rsSite![Avg cost])) * 100)))
''               If d.vatrate = "1" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 117.5) * 100)))
''               If d.vatrate = "2" Then d.cost = LTrim$(Str$(dp((Val(d.cost) / 105) * 100)))
''               If Val(d.cost) = 0 Then d.cost = "0"
               
               'update productstock set stocklvl = [426stkval].[stock]*productstock.convfact from productstock join [426stkval] on productstock.message = [426stkval].catno
reorder:
            
            End If
            putdrug d
            rsSite.MoveNext
         Loop
      End If
    MsgBox "All Done"
End Sub

Private Sub cmdLoadHoldingTable_Click()
   CreateAndLoadHoldingTable
End Sub

Private Sub cmdLoadPSAndWSP_Click()
   PopulateProductStockAndWsupplierProfile
End Sub

Sub getidxline(idxchan%, lineno&, linelen%, idxentry$, idxvector&, Del%)
'-----------------------------------------------------------------------------
' Read line from a pre-opened index. Supply channel No., total linelength
' and line No. required. Note that this is the actual line number in the
' file, i.e. add two to skip the length & length indexed markers.
' Del% =false unless eol marker is <LF>
'-----------------------------------------------------------------------------
Dim idxline$      '01Jun02 All/CKJ

   procname$ = "getidxline"
   Do
      On Error GoTo getidxlineErr     '17Feb95 CKJ Must be in loop
      ErrNo = False
      idxline$ = Space$(linelen)
      Get #idxchan, (lineno& - 1) * linelen + 1, idxline$
      'Err70msg ErrNo, "Index"
   Loop While ErrNo
   On Error GoTo 0

   idxentry$ = RTrim$(Left$(idxline$, linelen - idxminlen))  ' 30Mar91 CKJ was Trim$ - ie removed leading spaces
   idxvector& = Val(Mid$(idxline$, linelen - idxminlen + 1))
   Del = False
   If Right$(idxline$, 1) = Chr$(10) Then Del = True
Exit Sub

getidxlineErr:
   ErrNo = Err
   MsgBox Err.Description, vbCritical
End Sub



Private Sub cmdProcessAlternateBarCodes_Click()
   AddSupplimentaryBarcodes
End Sub

Private Sub cmdTemplateCheck_Click()
Dim prod As DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      dispdata$ = txtDrive.Text & ":\dispdata." & strSiteNumber
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn
      
      strHeader = "PrescriptionType|ProductName|ProductType|PharmacyProduct|Unit|rxDose|PrescribingUnit|Dose|Instruction|Form|CalcQty"
      strFile = txtDrive.Text & ":\TemplateCheck.txt"
      lngFilePointer = FreeFile
      Open strFile For Output As #lngFilePointer
      Print #lngFilePointer, strHeader
      
      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

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
                     
					 'strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.Description) & "|" & strUnit & "|" & strRXDose & "|" & strPrescribingUnit & "|" & CStr(Dose)
                     strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.LabelDescription) & "|" & strUnit & "|" & strRXDose & "|" & strPrescribingUnit & "|" & CStr(Dose)
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
                     'strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.Description) & "|||||||"
					 strRecord = strPrescriptionType & "|" & strProductName & "|" & strProductType & "|" & Trim$(d.LabelDescription) & "|||||||"

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

'03Aug10 XN F0088717 InUse can not be "S" anymore
Private Sub cmdUpdate_Click()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim FILE$
Dim lngFilePointer As Long
Dim g_adoCn As ADODB.Connection
Dim ConnectionString As String
Dim strSQL As String
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
'R9604PharmacyData000 T9906


      ConnectionString = txtConnect.Text
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      'MsgBox "1"
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open
      'MsgBox "2"
      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      'MsgBox "3"
      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSiteNumber & "\NOD" For Input As #fil Len = 16
      Input #fil, nod&
      Close #fil

      'MsgBox "4"
      lngFilePointerOut = FreeFile
      Open FILE$ For Binary Access Read Shared As lngFilePointerOut Len = 1024
    
      'MsgBox "5"
      numofrecs = nod
      For intloop = 0 To numofrecs
         If intloop = 0 Then MsgBox "6"
         lngProductStockID = 0
         blnUpdate = False
         DoEvents
         Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
            
         'First we get an associated ProductId which we can use to populate the next records.
         '21Feb07 TH Now the main link is on DrugID from SiteProductData
                    
         strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforProductID", strParams)
         strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngDrugID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforDrugID", strParams)
         If intloop = 0 Then MsgBox "7"
         If lngDrugID > 0 Then

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
''            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
''            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pTempDoseChangesByNSVCode", strParams)
''            If Not rsAddon.EOF Then
''               prod.dosesperissueunit = rsAddon!doseperissueunit
''
''            End If
''            Set rsAddon = Nothing
            
            
''            strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
''            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pTempConvfactChangesByNSVCode", strParams)
''            If Not rsAddon.EOF Then
''               'prod.dosesperissueunit = rsAddon!doseperissueunit
''               If rsAddon![new convfact] <> Val(prod.convfact) Then
''                  'here we need to alter the value 'No we dont
''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
''
''                  prod.stocklvl = Format$(((Val(prod.stocklvl) / Val(prod.convfact)) * rsAddon![new convfact]))
''                  prod.convfact = Format$(rsAddon![new convfact])
''                  '!!! We need to alter the stock level
''
''               End If
''
''            End If
''            Set rsAddon = Nothing
            
            'OMiGod Here we need to check if the issueunits are different. If they are the cost will be altered !!!
''            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
''                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
''            Set rsAddon = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strParams)
''            If Not rsAddon.EOF Then
''               'prod.dosesperissueunit = rsAddon!doseperissueunit
''               If Trim$(UCase$(rsAddon![PrintformV])) <> Trim$(UCase$(prod.PrintformV)) Then
''                  'here we need to alter the value 'No we dont
''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
''                  '''MsgBox "Houston - Could be a problem here !"
''
''               End If
''               '22Jan07 TH Added section
''               If rsAddon![convfact] <> Val(prod.convfact) Then
''                  'here we need to alter the value 'No we dont
''                  ''prod.cost = Format$(((Val(prod.cost) / Val(prod.convfact)) * rsAddon![new convfact]))
''
''                  prod.stocklvl = Format$(((Val(prod.stocklvl) / Val(prod.convfact)) * rsAddon![convfact]))
''                  prod.convfact = Format$(rsAddon![convfact])
''                  '!!! We need to alter the stock level
''
''               End If
''
''            End If
''            Set rsAddon = Nothing
            
            'Should we not check to see if there is already a Product stock record ? OK
            ''strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
            ''            gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, prod.SisCode)
            ''lngProductStockID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductSelectProductStockIDByNSV", strParams)
               
            With prod
                strSQL = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, Iff(UCase$(Trim$(.inuse)) = "S", "Y", UCase$(Trim$(inuse)))) '03Aug10 XN F0088717 InUse can not be "S" anymore
                ' strSQL = gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, .inuse)

                strSQL = strSQL & _
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
                   
                        
                  strSQL = strSQL & _
                        gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                        gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
                        gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
                        gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, .reorderlvl) & _
                        gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .reorderqty) & _
                        gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
                        gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
                        gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
                        gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
   
      
               
                  strSQL = strSQL & _
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
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
                           gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
                           gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
                           gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
                           gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
                           gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
                           gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
                           gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
                           gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message)
                           
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
                           gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
                           gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
                           gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
                           gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
                           gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
                           gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
                           gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .local)
                  strSQL = strSQL & _
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
                           gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, 0) & _
                           gTransport.CreateInputParameterXML("dosesperIssueunit", trnDataTypeFloat, 8, .dosesperissueunit) & _
                           gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .storespack) & _
                           gTransport.CreateInputParameterXML("Therpcode", trnDataTypeVarChar, 2, .therapcode)
                  strSQL = strSQL & _
                           gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID) & _
                           gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, "") & _
                           gTransport.CreateInputParameterXML("HIProduct", trnDataTypeVarChar, 1, "") & _
                           gTransport.CreateInputParameterXML("PIPCode", trnDataTypeVarChar, 7, .pipcode) & _
                           gTransport.CreateInputParameterXML("MasterPIP", trnDataTypeVarChar, 7, .MasterPip) & _
                           gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeChar, 4, "")
               End With
''            gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
''                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal) & _
''                        gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
''                        gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _
'14Jul10 XN F0084942 Removed dead code
'            If lngProductStockID > 0 Then
'               strSQL = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) & _
'                        gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) & strSQL
'               lngProductStockID = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strSQL)
'               blnUpdate = True
'            Else
' end of F0084942
               strSQL = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
                        & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strSQL
               ''dummy = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSql)
               '.ProductStockID = dummy '05Jul05 TH Added
'                strSQL = strSQL & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID)
               lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSQL)
'            End If     '14Jul10 XN F0084942 Removed dead code
            If lngProductStockID > 0 And (Not blnUpdate) Then
               'And finally a Supplier profile record for the default supplier
               'Later we may want to create extra records for each altsupplier or directly convert supplier profiles (best to do that first I reckon)
               With prod
                  strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .SisCode) & _
                           gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
                           gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .contno) & _
                           gTransport.CreateInputParameterXML("ReorderOuter", trnDataTypeVarChar, 6, .reorderpcksize) & _
                           gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .sislistprice) & _
                           gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .contprice) & _
                           gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .LeadTime) & _
                           gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                           gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .tradename) & _
                           gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                           gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .vatrate) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                 ''lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSql)
               End With
               lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)

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
Dim strSQL As String
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
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

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
                  'MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling & Chr(13) & " Unit = " & strUnit & Chr(13) & "rxDose = " & strRXDose & Chr(13) & "rxUnit = " & strPrescribingUnit & Chr(13) & " doseqty = " & CStr(Dose)
				  MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.LabelDescription) & Chr(13) & Chr(13) & Scaling & Chr(13) & " Unit = " & strUnit & Chr(13) & "rxDose = " & strRXDose & Chr(13) & "rxUnit = " & strPrescribingUnit & Chr(13) & " doseqty = " & CStr(Dose)
                  
                  Else
                  'Scaling not possible record and move on
                  'MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.Description) & Chr(13) & Chr(13) & Scaling
				  MsgBox strTemplate & "Pharmacy Item  : " & Trim$(d.LabelDescription) & Chr(13) & Chr(13) & Scaling
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
Dim strSQL As String
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
      
      strSiteNumber = Right$("000" & Trim$(txtSite.Text), 3)

      FILE$ = txtDrive.Text & ":\dispdata." & strSiteNumber & "\prodinfo.v8"
      
      g_SessionID = Val(txtSession.Text)
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = ConnectionString
      g_adoCn.Open

      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn

      'Now we need to derive the siteID and the MasterSiteID
      gDispSite = GetLocationID_Site(strSiteNumber)

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)

      
      fil = FreeFile
      Open txtDrive.Text & ":\dispdata." & strSiteNumber & "\NOD" For Input As #fil Len = 16
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

Private Sub Command3_Click()
   Unload Me
   
End Sub



Private Sub Form_Load()
TB = Chr$(9)
crlf = Chr$(13) & Chr$(10)

End Sub
'22Sep09 PJC Added for building up the connection string from the txt boxes
Private Function GetConnectionString() As String

    GetConnectionString = "Provider=" + txtProvider.Text + ";" _
               + "User ID=" + txtUserID.Text + ";" _
               + "Password=" + txtPassword.Text + ";" _
               + "database=" + txtInitCatalog.Text + ";" _
               + "server=" + txtDataSource.Text

End Function
'22Sep09 PJC Added for creating and populating the Prodinfo Holding table.
'12Nov14 XN  43683 handle individual record errors
Private Sub CreateAndLoadHoldingTable()
Dim prod As V8DrugParameters
Dim lngFilePointerOut As Long
Dim strFile As String
Dim g_adoCn As ADODB.Connection
Dim strSQL As String
Dim lngReturn As Long
Dim numofrecs As Integer
Dim nod As Long
Dim intloop As Integer
Dim dataError As Boolean      'XN 12Nov14 43683 Handle Invalid Data / Control character
Dim currentNSVCode As String  'XN 12Nov14 43683 Handle Invalid Data / Control character

'R9604PharmacyData000 T9906
Dim strTableName As String
Dim lngID As Long
Dim lngLocationID_Site As Long

      strSiteNumber = Right$("000" & Trim$(txtDispPath), 3)
      strTableName = "V8Products" & strSiteNumber
      strFile = Trim$(txtDispPath) & "\prodinfo.v8"
      txtStatus = ""
      If MsgBox("This process will delete all information from the holding table " & strTableName & " Continue?", vbQuestion + vbYesNo) = vbNo Then Exit Sub
      
      g_SessionID = Val(txtSession.Text)
      If g_SessionID = 0 Then
         MsgBox "Please provide Session ID", vbInformation
         Exit Sub
      End If
      
On Error GoTo ERR_CONN
      Set g_adoCn = New ADODB.Connection
      g_adoCn.ConnectionString = GetConnectionString()
      g_adoCn.Open
   
      Set gTransport = New PharmacyData.Transport
      'Set gTransport = New T9906PharmacyData000.Transport
      Set gTransport.Connection = g_adoCn
      'Now we need to derive the siteID and the MasterSiteID
      lngLocationID_Site = GetLocationID_Site(strSiteNumber)
      If lngLocationID_Site = 0 Then
         MsgBox "Location and Site information not set up in the database for dispdata: " & strSiteNumber & " Please check the dispdata path and Site information in the DB match.", vbCritical
      Else


         strSQL = gTransport.CreateInputParameterXML("TableName", trnDataTypeVarChar, 100, strTableName)
         strSQL = strSQL & gTransport.CreateInputParameterXML("HoldingOrErrorTable", trnDataTypeVarChar, 1, "H")
         'lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugConversionUtilityTableCreate", strSQL)
         lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugV8ConversionUtilityTableCreate", strSQL) '13Mar13 TH Quick fix to stop builder versioning the sp (TFS 58757)
         
         'strSQL = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
         'lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
   
         fil = FreeFile
         Open Trim$(txtDispPath) & "\NOD" For Input As #fil Len = 16
         Input #fil, nod&
         Close #fil
         
         lngFilePointerOut = FreeFile
         Open strFile For Binary Access Read Shared As lngFilePointerOut Len = 1024
         Me.MousePointer = 11
         numofrecs = nod
         
         'XN 12Nov14 43683 If errror then handle and move to next record
         On Error GoTo dataError
         
         dataError = False
         currentNSVCode = ""
                     
         For intloop = 0 To numofrecs
            
            lngProductStockID = 0
            blnUpdate = False
            DoEvents
            Get #lngFilePointerOut, (CLng(intloop) * 1024) + 1, prod
               
            DoEvents
            
            If Trim$(prod.SisCode) = "" Then
               'MsgBox "Blank product This will not be included in the Holding table. Line " & intloop, vbInformation  XN 12Nov14 43683
               Err.Raise LibErrorEnum.erEmptyLine, "RaiseError", "Blank product This will not be included in the Holding table."
            Else
          
               With prod
                  currentNSVCode = .Code
                 
                  strSQL = gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 8, .Code) & _
                  gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, .Description) & _
                  gTransport.CreateInputParameterXML("inuse", trnDataTypeVarChar, 1, .inuse) & _
                  gTransport.CreateInputParameterXML("deluserid", trnDataTypeVarChar, 3, .deluserid) & _
                  gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, .tradename) & _
                  gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .cost) & _
                  gTransport.CreateInputParameterXML("contno", trnDataTypeVarChar, 10, .contno) & _
                  gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, .supcode) & _
                  gTransport.CreateInputParameterXML("altsupcode", trnDataTypeVarChar, 29, .altsupcode) & _
                  gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, .warcode2) & _
                  gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, .ledcode) & _
                  gTransport.CreateInputParameterXML("SisCode", trnDataTypeVarChar, 7, .SisCode) & _
                  gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, .barcode) & _
                  gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, .cyto) & _
                  gTransport.CreateInputParameterXML("civas", trnDataTypeVarChar, 1, .civas) & _
                  gTransport.CreateInputParameterXML("formulary", trnDataTypeVarChar, 1, .formulary)
                  
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("bnf", trnDataTypeVarChar, 13, .bnf) & _
                  gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, .ReconVol) & _
                  gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, 3, .ReconAbbr) & _
                  gTransport.CreateInputParameterXML("Diluent1Abbr", trnDataTypeVarChar, 3, .Diluent1Abbr) & _
                  gTransport.CreateInputParameterXML("Diluent2Abbr", trnDataTypeVarChar, 3, .Diluent2Abbr) & _
                  gTransport.CreateInputParameterXML("MaxmgPerml", trnDataTypeFloat, 8, .MaxmgPerml) & _
                  gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, .warcode) & _
                  gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, .inscode) & _
                  gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, 6, .dircode) & _
                  gTransport.CreateInputParameterXML("labelformat", trnDataTypeVarChar, 1, .labelformat) & _
                  gTransport.CreateInputParameterXML("expiryminutes", trnDataTypeint, 4, .expiryminutes) & _
                  gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .sisstock) & _
                  gTransport.CreateInputParameterXML("ATC", trnDataTypeVarChar, 1, .ATC) & _
                  gTransport.CreateInputParameterXML("reorderpcksize", trnDataTypeVarChar, 5, .reorderpcksize) & _
                  gTransport.CreateInputParameterXML("PrintformV", trnDataTypeVarChar, 5, .PrintformV) & _
                  gTransport.CreateInputParameterXML("minissue", trnDataTypeVarChar, 4, .minissue) & _
                  gTransport.CreateInputParameterXML("maxissue", trnDataTypeVarChar, 5, .maxissue) & _
                  gTransport.CreateInputParameterXML("reorderlvl", trnDataTypeVarChar, 8, .reorderlvl) & _
                  gTransport.CreateInputParameterXML("reorderqty", trnDataTypeVarChar, 6, .reorderqty)
                  
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("convfact", trnDataTypeVarChar, 5, .convfact) & _
                  gTransport.CreateInputParameterXML("anuse", trnDataTypeVarChar, 9, .anuse) & _
                  gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .message) & _
                  gTransport.CreateInputParameterXML("therapcode", trnDataTypeVarChar, 2, .therapcode) & _
                  gTransport.CreateInputParameterXML("extralabel", trnDataTypeVarChar, 3, .extralabel) & _
                  gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                  gTransport.CreateInputParameterXML("sislistprice", trnDataTypeVarChar, 9, .sislistprice) & _
                  gTransport.CreateInputParameterXML("contprice", trnDataTypeVarChar, 9, .contprice) & _
                  gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .livestockctrl) & _
                  gTransport.CreateInputParameterXML("leadtime", trnDataTypeVarChar, 3, .LeadTime) & _
                  gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode) & _
                  gTransport.CreateInputParameterXML("usagedamping", trnDataTypeFloat, 8, .usagedamping) & _
                  gTransport.CreateInputParameterXML("safetyfactor", trnDataTypeFloat, 8, .safetyfactor) & _
                  gTransport.CreateInputParameterXML("indexed", trnDataTypeVarChar, 1, .indexed) & _
                  gTransport.CreateInputParameterXML("recalcatperiodend", trnDataTypeVarChar, 1, .recalcatperiodend) & _
                  gTransport.CreateInputParameterXML("blank", trnDataTypeVarChar, 6, .blank) & _
                  gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .lossesgains) & _
                  gTransport.CreateInputParameterXML("spare", trnDataTypeVarChar, 7, .spare) & _
                  gTransport.CreateInputParameterXML("dosesperissueunit", trnDataTypeFloat, 8, .dosesperissueunit) & _
                  gTransport.CreateInputParameterXML("mlsperpack", trnDataTypeint, 4, .mlsperpack)
                  
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .ordercycle) & _
                  gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .cyclelength) & _
                  gTransport.CreateInputParameterXML("lastreconcileprice", trnDataTypeVarChar, 9, .lastreconcileprice) & _
                  gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .outstanding) & _
                  gTransport.CreateInputParameterXML("usethisperiod", trnDataTypeFloat, 8, .usethisperiod) & _
                  gTransport.CreateInputParameterXML("vatrate", trnDataTypeVarChar, 1, .vatrate) & _
                  gTransport.CreateInputParameterXML("DosingUnits", trnDataTypeVarChar, 5, .DosingUnits) & _
                  gTransport.CreateInputParameterXML("ATCCode", trnDataTypeVarChar, 8, .ATCCode) & _
                  gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .UserMsg) & _
                  gTransport.CreateInputParameterXML("MaxInfusionRate", trnDataTypeFloat, 8, .MaxInfusionRate) & _
                  gTransport.CreateInputParameterXML("MinmgPerml", trnDataTypeFloat, 8, .MinmgPerml) & _
                  gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeFloat, 8, .InfusionTime) & _
                  gTransport.CreateInputParameterXML("mgPerml", trnDataTypeFloat, 8, .mgPerml) & _
                  gTransport.CreateInputParameterXML("IVcontainer", trnDataTypeVarChar, 1, .IVcontainer) & _
                  gTransport.CreateInputParameterXML("DisplacementVolume", trnDataTypeFloat, 8, .DisplacementVolume) & _
                  gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .PILnumber) & _
                  gTransport.CreateInputParameterXML("datelastperiodend", trnDataTypeVarChar, 8, .datelastperiodend) & _
                  gTransport.CreateInputParameterXML("MinDailyDose", trnDataTypeFloat, 8, .MinDailyDose) & _
                  gTransport.CreateInputParameterXML("MaxDailyDose", trnDataTypeFloat, 8, .MaxDailyDose) & _
                  gTransport.CreateInputParameterXML("MinDoseFrequency", trnDataTypeFloat, 8, .MinDoseFrequency)
                  
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("MaxDoseFrequency", trnDataTypeFloat, 8, .MaxDoseFrequency) & _
                  gTransport.CreateInputParameterXML("route", trnDataTypeVarChar, 20, .route) & _
                  gTransport.CreateInputParameterXML("chemical", trnDataTypeVarChar, 50, .chemical) & _
                  gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 7, .local) & _
                  gTransport.CreateInputParameterXML("extralocal", trnDataTypeVarChar, 3, .extralocal) & _
                  gTransport.CreateInputParameterXML("DosesPerAdminUnit", trnDataTypeFloat, 8, .DosesPerAdminUnit) & _
                  gTransport.CreateInputParameterXML("adminunit", trnDataTypeVarChar, 5, .adminunit) & _
                  gTransport.CreateInputParameterXML("DPSform", trnDataTypeVarChar, 25, .DPSform) & _
                  gTransport.CreateInputParameterXML("storesdescription", trnDataTypeVarChar, 56, .storesdescription) & _
                  gTransport.CreateInputParameterXML("storespack", trnDataTypeVarChar, 5, .storespack) & _
                  gTransport.CreateInputParameterXML("teamworkbtn", trnDataTypeint, 4, .teamworkbtn) & _
                  gTransport.CreateInputParameterXML("StrengthDesc", trnDataTypeVarChar, 12, .StrengthDesc) & _
                  gTransport.CreateInputParameterXML("loccode2", trnDataTypeVarChar, 3, .loccode2) & _
                  gTransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, .lastissued) & _
                  gTransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, .lastordered) & _
                  gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
                  gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, .createdterminal)
                  
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, .createddate) & _
                  gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, .createdtime) & _
                  gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .modifieduser) & _
                  gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .modifiedterminal) & _
                  gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .modifieddate) & _
                  gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .modifiedtime) & _
                  gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .batchtracking) & _
                  gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .stocktakestatus) & _
                  gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .laststocktakedate) & _
                  gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .laststocktaketime) & _
                  gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
                  gTransport.CreateInputParameterXML("issueWholePack", trnDataTypeVarChar, 1, .issueWholePack) & _
                  gTransport.CreateInputParameterXML("HasFormula", trnDataTypeVarChar, 1, .HasFormula) & _
                  gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .PIL2) & _
                  gTransport.CreateInputParameterXML("StripSize", trnDataTypeVarChar, 5, .StripSize) & _
                  gTransport.CreateInputParameterXML("pipcode", trnDataTypeVarChar, 7, .pipcode) & _
                  gTransport.CreateInputParameterXML("sparePIP", trnDataTypeVarChar, 5, .sparePIP) & _
                  gTransport.CreateInputParameterXML("MasterPip", trnDataTypeVarChar, 7, .MasterPip) & _
                  gTransport.CreateInputParameterXML("spareMasterPip", trnDataTypeVarChar, 5, .spareMasterPip)
                  
                  '28Sep12 TH Added new fields
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("PhysicalDescription", trnDataTypeVarChar, 35, .PhysicalDescription) & _
                  gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, .DDDValue) & _
                  gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, .DDDUnits) & _
                  gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .UserField1) & _
                  gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .UserField2) & _
                  gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, .UserField3) & _
                  gTransport.CreateInputParameterXML("HIProduct", trnDataTypeVarChar, 1, .HIProduct) & _
                  gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 5, lngLocationID_Site)
                  
                  lngID = gTransport.ExecuteInsertSP(g_SessionID, strTableName, strSQL)
                        
               End With
               
               currentNSVCode = ""
            End If
            
DataResume:
            If intloop Mod 100 = 0 Or intloop = numofrecs Then
                txtStatus = "Processing File: " & strFile & " RecordCount: " & Format$(intloop + 1) & " of " & Format$(numofrecs + 1)
                DoEvents
            End If
   
         Next
         
         'MsgBox "Product File: " & strFile & " has been loaded into table: " & strTableName, vbInformation  XN 12Nov14 43683
         If dataError Then
            MsgBox "Product File: " & strFile & " has been loaded into table: " & strTableName + vbNewLine + "Some lines failed to convert correctly", vbExclamation
            Shell "notepad.exe """ + LogName(strTableName) + """", vbNormalFocus
         Else
            MsgBox "Product File: " & strFile & " has been loaded into table: " & strTableName, vbInformation
         End If
      End If
      On Error GoTo 0
      

END_RESUME:
      Me.MousePointer = 0
      On Error Resume Next
      gTransport.Connection.Close
      Set gTransport = Nothing
      Close #fil
      Close #lngFilePointerOut
      Exit Sub
      
ERR_CONN:
   MsgBox Err.Description
   Resume END_RESUME
   
dataError:
   ' XN 12Nov14 43683 handle individual record errors
   dataError = True
   WriteToLogAndLogTable strTableName, g_SessionID, currentNSVCode, lngLocationID_Site, " Record " + CStr(intloop) + " - " + Err.Description, True
   Resume DataResume
      
End Sub

Sub PopulateProductStockAndWsupplierProfile()

'22Sep09 PJC Added for populating the ProductStock and WSupplierProfile tables
'03Aug10 XN F0088717 InUse can not be "S" anymore
'18Sep12 TH Added PNExclude (TFS)
'16Mar13 TH Added fields from v8 for EyeLabel and PSOLabel. (TFS 58981)
'28Oct13 TH Added field for ExpiryWarnDays. (TFS  76688)
'05Nov14 TH Modified and created user/term and date now use ASC variables and current datetime on conversion (TFS 103570)


Dim strSQL                 As String
Dim rs                     As ADODB.Recordset
Dim strSiteNumber          As String
Dim strTableName           As String
Dim g_adoCn                As ADODB.Connection
Dim lngLocationID_Site     As Long
Dim lngProductID           As Long
Dim lngDrugID              As Long
Dim lngDSSMasterSiteID     As Long
Dim lngID                  As Long
Dim intCounter             As Integer
Dim intTotal               As Integer
Dim lngSiteProductDataID   As Long
Dim rsSPD                  As ADODB.Recordset
Dim lngErr                 As Long
Dim blnError               As Boolean
Dim strBarcode             As String
Dim lngSiteProductDataAliasID As Long
Dim intNoOfChars           As Integer

   intNoOfChars = Val(txtNoOfChars)
   strSiteNumber = Right$("000" & Trim$(txtDispPath), 3)
   strTableName = "V8Products" & strSiteNumber
   
   If MsgBox("This process will delete all information from the ProductStock, WsupplierProfile and Error table " & strTableName & " for this site: " & strSiteNumber & Chr(13) & Chr(10) & "HOWEVER, the Barcodes in the SiteProductDataAlais table will be left untouched as these are not site Specific." & Chr(13) & Chr(10) & " Do you want to continue?", vbQuestion + vbYesNo) = vbNo Then Exit Sub
   
   g_SessionID = Val(txtSession.Text)
   If g_SessionID = 0 Then
      MsgBox "Please provide Session ID", vbInformation
      Exit Sub
   End If
   txtStatus = ""
On Error GoTo ERR_CONN
   Set g_adoCn = New ADODB.Connection
   g_adoCn.ConnectionString = GetConnectionString()
   g_adoCn.Open

   Set gTransport = New PharmacyData.Transport
   'Set gTransport = New T9906PharmacyData000.Transport
   Set gTransport.Connection = g_adoCn
   'Now we need to derive the siteID and the MasterSiteID
   lngLocationID_Site = GetLocationID_Site(strSiteNumber)

   strSQL = gTransport.CreateInputParameterXML("TableName", trnDataTypeVarChar, 100, strTableName)
   strSQL = strSQL & gTransport.CreateInputParameterXML("HoldingOrErrorTable", trnDataTypeVarChar, 1, "E")
   'lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugConversionUtilityTableCreate", strSQL)
   lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugV8ConversionUtilityTableCreate", strSQL) '13Mar13 TH Quick fix to stop builder versioning the sp (TFS 58757)
   
   strSQL = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site)
   'lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugConversionUtilityPSAndWSPDeleteByLocation", strSQL)
   lngID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugV8ConversionUtilityPSAndWSPDeleteByLocation", strSQL) '13Mar13 TH Quick fix to stop builder versioning the sp (TFS 58757)
   
   strSQL = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site)
   lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strSQL)
   
   If lngDSSMasterSiteID = 0 Or lngLocationID_Site = 0 Then
      MsgBox "Location, Site, DSSMasterSiteid information not set up in the database for dispdata: " & strSiteNumber, vbcritiacal
   Else
      WriteToLogAndLogTable strTableName, g_SessionID, "", lngLocationID_Site, "Starting population of ProductStock and WSupplierProfile."
      strSQL = ""
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTableName & "Select", strSQL)

      intTotal = rs.RecordCount
      intCounter = 0
      lngErr = 0
      On Error GoTo DBEXECUTE_ERROR
      While rs.EOF = False
         lngProductStockID = 0
         lngProductID = 0
         lngDrugID = 0
         lngSiteProductDataID = 0
         blnError = False
         Me.MousePointer = 11
         DoEvents
         intCounter = intCounter + 1
         strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rs.Fields("siscode")) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngProductID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforProductID", strSQL)
         
         strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rs.Fields("siscode")) & _
                     gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)
          
         lngDrugID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pCheckNSVCodeforDrugID", strSQL)
         
         'strSQL = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rs.Fields("siscode"))
         'lngSiteProductDataID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDataByNSV", strSQL)
         
         If (chkInUseOnly = vbChecked And UCase(Trim$(rs.Fields("inuse"))) = "Y") Or chkInUseOnly = vbUnchecked Then
         
            strSQL = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rs.Fields("siscode"))
            Set rsSPD = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strSQL)
            
            If rsSPD.RecordCount = 0 Then
               'nothing in the Siteproductdata
               WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "NSVCode missing from the SiteProductData table."
               lngErr = lngErr + 1
               blnError = True
            ElseIf rsSPD.RecordCount > 1 Then
               'more than one in siteproductdata
               WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "More than one NSVCode in the SiteProductData table."
               lngErr = lngErr + 1
               blnError = True
            Else
               lngSiteProductDataID = rsSPD.Fields("SiteProductDataID")
               If chkTestDescription.Value = vbChecked And Left$(Trim$(rsSPD.Fields("LabelDescription")), intNoOfChars) <> Left$(Trim$(rs.Fields("Description")), intNoOfChars) Then
                  WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "Description mis-match on the first 5 characters. Descriptions: " & Chr(34) & Trim$(rsSPD.Fields("LabelDescription")) & Chr(34) & " and " & Chr(34) & Trim$(rs.Fields("Description")) & Chr(34)
                  lngErr = lngErr + 1
                  blnError = True
               End If
               
               If chkTestConvfact.Value = vbChecked And Val(rsSPD.Fields("convfact")) <> Val(rs.Fields("convfact")) Then
                  WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "Convfact mis-match. Convfacts: " & Chr(34) & Format(Val(rsSPD.Fields("convfact"))) & Chr(34) & " and " & Chr(34) & Format(Val(rs.Fields("convfact"))) & Chr(34)
                  lngErr = lngErr + 1
                  blnError = True
               End If
               
               If chkTestIssueUnits.Value = vbChecked And UCase$(Trim$(rsSPD.Fields("PrintFormV") & "")) <> UCase$(Trim$(rs.Fields("PrintFormV"))) Then
                  WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "PrintFormV mis-match. Issue Units: " & Chr(34) & Trim$(rsSPD.Fields("PrintFormV") & "") & Chr(34) & " and " & Chr(34) & Trim$(rs.Fields("PrintFormV")) & Chr(34)
                  lngErr = lngErr + 1
                  blnError = True
               End If
            End If
            
            If blnError = False Then
               
               With rs
                  'ProductStock first
                  
                  strSQL = gTransport.CreateInputParameterXML("inuse", trnDataTypeVarChar, 1, Iff(UCase(Trim$(.Fields("inuse"))) = "S", "Y", UCase(Trim$(.Fields("inuse"))))) ' 3Aug10 XN F0088717 InUse can not be "S" anymore
                  'strSQL = gTransport.CreateInputParameterXML("inuse", trnDataTypeVarChar, 1, .Fields("inuse")) & _

                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, .Fields("cyto")) & _
                  gTransport.CreateInputParameterXML("formulary", trnDataTypeVarChar, 1, .Fields("formulary")) & _
                  gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, .Fields("warcode")) & _
                  gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, .Fields("warcode2")) & _
                  gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, .Fields("inscode")) & _
                  gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, 6, "") & _
                  gTransport.CreateInputParameterXML("labelformat", trnDataTypeVarChar, 1, .Fields("labelformat")) & _
                  gTransport.CreateInputParameterXML("extralabel", trnDataTypeVarChar, 3, .Fields("extralabel")) & _
                  gTransport.CreateInputParameterXML("expiryminutes", trnDataTypeint, 4, .Fields("expiryminutes")) & _
                  gTransport.CreateInputParameterXML("minissue", trnDataTypeVarChar, 4, .Fields("minissue")) & _
                  gTransport.CreateInputParameterXML("maxissue", trnDataTypeVarChar, 5, .Fields("maxissue")) & _
                  gTransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, .Fields("lastissued"))
                  
                  strSQL = strSQL & gTransport.CreateInputParameterXML("issueWholePack", trnDataTypeVarChar, 1, .Fields("issueWholePack")) & _
                  gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, .Fields("stocklvl")) & _
                  gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, .Fields("sisstock")) & _
                  gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, .Fields("livestockctrl")) & _
                  gTransport.CreateInputParameterXML("Reorderlvl", trnDataTypeVarChar, 8, .Fields("reorderlvl")) & _
                  gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, .Fields("reorderqty")) & _
                  gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, .Fields("ordercycle")) & _
                  gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, .Fields("cyclelength")) & _
                  gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, .Fields("outstanding")) & _
                  gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .Fields("loccode")) & _
                  gTransport.CreateInputParameterXML("loccode2", trnDataTypeVarChar, 3, .Fields("loccode2")) & _
                  gTransport.CreateInputParameterXML("anuse", trnDataTypeVarChar, 9, .Fields("anuse")) & _
                  gTransport.CreateInputParameterXML("usethisperiod", trnDataTypeFloat, 8, .Fields("usethisperiod")) & _
                  gTransport.CreateInputParameterXML("recalcatperiodend", trnDataTypeVarChar, 1, .Fields("recalcatperiodend")) & _
                  gTransport.CreateInputParameterXML("datelastperiodend", trnDataTypeVarChar, 8, .Fields("datelastperiodend")) & _
                  gTransport.CreateInputParameterXML("usagedamping", trnDataTypeFloat, 8, .Fields("usagedamping")) & _
                  gTransport.CreateInputParameterXML("safetyfactor", trnDataTypeFloat, 8, .Fields("safetyfactor"))
            
                  strSQL = strSQL & gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, .Fields("supcode")) & _
                  gTransport.CreateInputParameterXML("altsupcode", trnDataTypeVarChar, 29, .Fields("altsupcode")) & _
                  gTransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, .Fields("lastordered")) & _
                  gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, .Fields("stocktakestatus")) & _
                  gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, .Fields("laststocktakedate")) & _
                  gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, .Fields("laststocktaketime")) & _
                  gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, .Fields("batchtracking")) & _
                  gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, .Fields("cost")) & _
                  gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, .Fields("lossesgains")) & _
                  gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 20, .Fields("ledcode")) & _
                  gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .Fields("pflag")) & _
                  gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, .Fields("message")) & _
                  gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 2, .Fields("UserMsg")) & _
                  gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, .Fields("PILnumber")) & _
                  gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, .Fields("PIL2"))
                  
                  
                  '05Nov14 TH Replaced with below (TFS 103570)
                  'strSQL = strSQL & gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, .Fields("modifieduser")) & _
                  'gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, .Fields("modifiedterminal")) & _
                  'gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, .Fields("modifieddate")) & _
                  'gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, .Fields("modifiedtime")) & _

                  strSQL = strSQL & gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, "ASC") & _
                  gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, "ASC") & _
                  gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, Format(Now, "DDMMYYYY")) & _
                  gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, Format(Now, "HHNNSS"))

                  strSQL = strSQL & gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, .Fields("local")) & _
                  gTransport.CreateInputParameterXML("CIVAS", trnDataTypeVarChar, 1, .Fields("civas")) & _
                  gTransport.CreateInputParameterXML("mgPerml", trnDataTypeFloat, 8, .Fields("mgPerml")) & _
                  gTransport.CreateInputParameterXML("maxInfusionRate", trnDataTypeFloat, 8, .Fields("MaxInfusionRate")) & _
                  gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeFloat, 8, .Fields("InfusionTime")) & _
                  gTransport.CreateInputParameterXML("Minmgperml", trnDataTypeFloat, 8, .Fields("MinmgPerml")) & _
                  gTransport.CreateInputParameterXML("Maxmgperml", trnDataTypeFloat, 8, .Fields("MaxmgPerml")) & _
                  gTransport.CreateInputParameterXML("IVContainer", trnDataTypeVarChar, 1, .Fields("IVcontainer"))
                  
                  strSQL = strSQL & gTransport.CreateInputParameterXML("DisplacementVolume", trnDataTypeFloat, 8, .Fields("DisplacementVolume")) & _
                  gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, .Fields("ReconVol")) & _
                  gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, 3, .Fields("ReconAbbr")) & _
                  gTransport.CreateInputParameterXML("Diluent1", trnDataTypeVarChar, 3, .Fields("Diluent1Abbr")) & _
                  gTransport.CreateInputParameterXML("Diluent2", trnDataTypeVarChar, 3, .Fields("Diluent1Abbr")) & _
                  gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, .Fields("convfact")) & _
                  gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, .Fields("dosesperissueunit")) & _
                  gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, .Fields("storespack")) & _
                  gTransport.CreateInputParameterXML("Therapcode", trnDataTypeVarChar, 2, .Fields("therapcode"))
                  '28Sep12 TH Added fileds from v8 for DDD, UserFields and HI Product.
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID) & _
                  gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, .Fields("DDDValue")) & _
                  gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, .Fields("DDDUnits")) & _
                  gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .Fields("UserField1")) & _
                  gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .Fields("UserField2")) & _
                  gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, .Fields("UserField3")) & _
                  gTransport.CreateInputParameterXML("HIProduct", trnDataTypeVarChar, 1, .Fields("HIProduct")) & _
                  gTransport.CreateInputParameterXML("PIPCode", trnDataTypeVarChar, 7, .Fields("pipcode")) & _
                  gTransport.CreateInputParameterXML("MasterPIP", trnDataTypeVarChar, 7, .Fields("MasterPip")) & _
                  gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeChar, 4, "") & _
                  gTransport.CreateInputParameterXML("PNExclude", trnDataTypeBit, 1, 0)     '18Sep12 TH Added (TFS)
                  
                  '16Mar13 TH Added fields from v8 for EyeLabel and PSOLabel. (TFS 58981)
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("EyeLabel", trnDataTypeBit, 1, 0) _
                  & gTransport.CreateInputParameterXML("PSOLabel", trnDataTypeBit, 1, 0)
                  
                  '28Oct13 TH Added field for ExpiryWarnDays. (TFS  76688)
                  strSQL = strSQL & _
                  gTransport.CreateInputParameterXML("ExpiryWarnDays", trnDataTypeint, 4, 0)
                  
               End With
               
         
               lngProductStockID = 0
               'do straight insert
               strSQL = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID) _
               & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site) & strSQL
'               strSQL = strSQL & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, lngDrugID)
               lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strSQL)
               
               If lngProductStockID <> 0 And blnError = False Then
                  With rs
                        strSQL = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, .Fields("SisCode")) & _
                                 gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .Fields("supcode")) & _
                                 gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, .Fields("contno")) & _
                                 gTransport.CreateInputParameterXML("ReorderOuter", trnDataTypeVarChar, 6, .Fields("reorderpcksize")) & _
                                 gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, .Fields("sislistprice")) & _
                                 gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, .Fields("contprice")) & _
                                 gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, .Fields("leadtime")) & _
                                 gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, .Fields("lastreconcileprice")) & _
                                 gTransport.CreateInputParameterXML("Tradename", trnDataTypeVarChar, 30, .Fields("tradename")) & _
                                 gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 29, "") & _
                                 gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, .Fields("vatrate")) & _
                                 gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site)
                  End With
                  lngProductStockID = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strSQL)
                     
                     
                 'check the primary barcode if required
               
                  If chkPrimaryBarcode = vbChecked And blnError = False Then
                     lngSiteProductDataAliasID = 0
                     dummyEAN rs.Fields("siscode"), strBarcode
                     If Trim$(rs.Fields("Barcode")) <> Trim$(strBarcode) Then
                     
                        'add to the SiteProductDataAlias
                        strSQL = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, lngSiteProductDataID) & _
                                 gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 255, rs.Fields("Barcode"))
                                
                        'lngSiteProductDataAliasID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugConversionUtilityAlternativeBarcodeAdd", strSQL)
                        lngSiteProductDataAliasID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugV8ConversionUtilityAlternativeBarcodeAdd", strSQL) '13Mar13 TH Quick fix to stop builder versioning the sp (TFS 58757)
                        WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "Alternate Barcode " & rs.Fields("Barcode") & " added to SiteProductDataAlias table."
                     End If
                  End If
               End If
               
   
            End If
            rsSPD.Close
         Else
            WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "Item not in use."
         End If
         rs.MoveNext
         
         If intCounter Mod 100 = 0 Or intTotal = intCounter Then
             txtStatus = "Processing data from table: " & strTableName & " RecordCount: " & Format$(intCounter) & " of " & Format$(intTotal) & " Errors: " & lngErr
             DoEvents
         End If
         
      Wend
        
      WriteToLogAndLogTable strTableName, g_SessionID, "", lngLocationID_Site, "Completed population of ProductStock and WSupplierProfile."
      MsgBox "ProductStock and Wsupplier tables have been populated, please review the Error/log table: " & strTableName & "Error", vbInformation
      
      ' 12Nov14 XN 43683 If error then display in notepad
      If lngErr > 0 Then
          Shell "notepad.exe """ + LogName(strTableName) + """", vbNormalFocus
      End If
   End If
END_RESUME:

      On Error Resume Next
      rs.Close
      Set rs = Nothing
      Set rsSPD = Nothing
      gTransport.Connection.Close
      Set gTransport = Nothing
      Me.MousePointer = 0
      Exit Sub
      
ERR_CONN:
   MsgBox Err.Description & " Process aborted!", vbCritical, "Error: Process aborted"
   Resume END_RESUME
   
DBEXECUTE_ERROR:
   WriteToLogAndLogTable strTableName, g_SessionID, rs.Fields("siscode"), lngLocationID_Site, "Bad Data found in this product " & Right$(Err.Description, 469)
   blnError = True
   lngErr = lngErr + 1
   Resume Next

End Sub
'12nov14 XN 43683 Get the Log file name
Function LogName(strTableName As String) As String
Dim strLogFile As String

   strLogFile = txtDispPath
   If Right(strLogFile, 1) <> "\" Then strLogFile = strLogFile & "\"
   strLogFile = strLogFile & strTableName & ".log"
   
   LogName = strLogFile
End Function
'12nov14 XN 43683 Clear the log file
Sub LogClear(strTableName As String)
Dim strLogFile As String
Dim lngChan    As Long
   strLogFile = LogName(strTableName)
   lngChan = FreeFile
   Open strLogFile For Output As lngChan
   Close #lngChan
End Sub
'22Sep09 PJC Added for handling error table and log
Sub WriteToLogAndLogTable(strTableName As String, lngSession As Long, strSISCode As String, lngLocationID_Site As Long, _
                           strError As String, Optional blnToFileOnly As Boolean = 0)
Dim strSQL              As String
Dim lngRet              As Long
Dim strLog              As String
Dim lngChan             As Long

   If blnToFileOnly = False Then
      strSQL = gTransport.CreateInputParameterXML("sisCode", trnDataTypeVarChar, 7, strSISCode) & _
                  gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site) & _
                  gTransport.CreateInputParameterXML("ErrorText", trnDataTypeVarChar, 500, strError)
   
      lngRet = gTransport.ExecuteInsertSP(lngSession, strTableName & "Error", strSQL)
   End If
   
   'strLogFile = txtDispPath
'   If Right(strLogFile, 1) <> "\" Then strLogFile = strLogFile & "\"
   'strLog = strLogFile & strTableName & ".log" 12nov14 XN 43683
   strLog = LogName(strTableName)
   lngChan = FreeFile
   Open strLog For Append As lngChan

   Print #lngChan, Mid$(date$, 4, 3); Left$(date$, 3); Right$(date$, 4); " ";
   Print #lngChan, Time$; " NSVCode:"; strSISCode; " Message:"; strError

   Close #lngChan

End Sub
'22Sep09 PJC Added for the processing of the Supplementary barcodes
Sub AddSupplimentaryBarcodes()


Dim strText As String
Dim count As Long, idx%, txt$, ans$, idxline$, vector&, Del%, itemlen%, linlen%
Dim ToTlines&, Beg1&, Beg2&, End1&, End2&, IdxedLen&, Alloc%, lins%
Dim strNSVCode As String
Dim strBarcode As String
Dim strSQL  As String
Dim lngDSSMasterSiteID As Long
Dim lngLocationID_Site As Long
Dim strSiteNumber As String
Dim rsSPD As ADODB.Recordset
Dim strGeneratedBarcode As String
Dim lngSiteProductDataAliasID As Long
Dim lngErr As Long


   
   strSiteNumber = Right$("000" & Trim$(txtDispPath), 3)
   
   If MsgBox("You are about to process the Supp Barcode file: " & txtDispPath & "\Barcodes.idx into the SiteProductDataAlias table. Do you want to continue?", vbQuestion + vbYesNo) = vbNo Then Exit Sub
   
   g_SessionID = Val(txtSession.Text)
   If g_SessionID = 0 Then
      MsgBox "Please provide Session ID", vbInformation
      Exit Sub
   End If
   txtStatus = ""
On Error GoTo ERR_SUPP_BARCODES
   Set g_adoCn = New ADODB.Connection
   g_adoCn.ConnectionString = GetConnectionString()
   g_adoCn.Open

   Set gTransport = New PharmacyData.Transport
   'Set gTransport = New T9906PharmacyData000.Transport
   Set gTransport.Connection = g_adoCn
   'Now we need to derive the siteID and the MasterSiteID
   lngLocationID_Site = GetLocationID_Site(strSiteNumber)
   
   'need the master siteID
   strSQL = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngLocationID_Site)
   lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strSQL)

   'Pop it in the SiteProductdataAlias table if required.
   If lngDSSMasterSiteID = 0 Or lngLocationID_Site = 0 Then
      MsgBox "Location, Site, DSSMasterSiteid information not set up in the database for dispdata: " & strSiteNumber, vbcritiacal
   Else
      WriteToLogAndLogTable "SiteProductDataAlias", g_SessionID, "", 0, "Starting to Process Supplementary Barcode File" & Trim$(txtDispPath) & "\BarCodes.IDX", True
      idx = FreeFile
      Open Trim$(txtDispPath) & "\BarCodes.IDX" For Binary Access Read Write Lock Read Write As #idx
      
      getidxline idx, 1, idxminlen + 2, idxline$, vector&, Del ' first 2 chars in file
      itemlen = Val(idxline$)                          ' length of index items
      linlen = itemlen + idxminlen
    
      getidxline idx, 1, linlen, idxline$, ToTlines&, Del      ' total data lines in file
      Beg1& = 3
      End2& = ToTlines& + 2
                                                                              
      getidxline idx, 2, linlen, idxline$, IdxedLen&, Del
      End1& = IdxedLen& + 2
      Beg2& = End1& + 1
      Me.MousePointer = 11
      For count = Beg1& To End2&
         strNSVCode = ""
         strBarcode = ""
         getidxline idx, count, linlen, idxline$, IdxedLen&, Del
         If Del = 0 Then
            'Debug.Print idxline$ & "___" & Format(Len(idxline$))
            If Len(idxline$) = 15 Then
               strNSVCode = Left(idxline$, 7)
               strBarcode = Mid(idxline$, 8)
            ElseIf Len(idxline$) > 15 Then
               
               'MsgBox idxline$
               strNSVCode = Left(idxline$, 7)
               strBarcode = Mid(idxline$, 8, 13)
            Else
               MsgBox idxline$
            End If
            'Debug.Print strNSVCode & "     " & strBarcode
            'Debug.Print ""
         'AAANNNANNNNNNNNnnnnnSSSSS
         Else
            MsgBox "DELETED?"
         End If
         If strNSVCode <> "" And strBarcode <> "" Then
            dummyEAN strNSVCode, strGeneratedBarcode
            If strBarcode <> Trim$(strGeneratedBarcode) Then
            
               'Check the Siteproductdata table for each NSVCode from the index in the Sites list of NSVCodes.
      
               strSQL = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
               Set rsSPD = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataByNSV", strSQL)
               
               If rsSPD.RecordCount = 1 Then
                  strSQL = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, rsSPD.Fields("SiteProductDataID")) & _
                  gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 255, strBarcode)
                  'lngSiteProductDataAliasID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugConversionUtilityAlternativeBarcodeAdd", strSQL)
                  lngSiteProductDataAliasID = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWDrugV8ConversionUtilityAlternativeBarcodeAdd", strSQL) '13Mar13 TH Quick fix to stop builder versioning the sp (TFS 58757)
                  WriteToLogAndLogTable "SiteProductDataAlias", g_SessionID, strNSVCode, 0, "Supplementary Barcode " & strBarcode & " added to SiteProductDataAlias table. lngSiteProductDataAliasID = " & lngSiteProductDataAliasID, True
               Else
                  WriteToLogAndLogTable "SiteProductDataAlias", g_SessionID, strNSVCode, 0, "Error: Could not find NSVCode in SiteproductDatatable with Supplementary Barcode " & strBarcode & ". BarCode NOT added to SiteProductDataAlias table.", True
                  lngError = lngError + 1
               End If
               rsSPD.Close
            End If
         End If
         If count Mod 100 = 0 Or count = End2& Then
            txtStatus = "Processing Index File: " & Trim$(txtDispPath) & "\BarCodes.IDX  NSVCode: " & strNSVCode & " BarCode: " & strBarcode & " RecordCount: " & Format$(count - 2, "0000") & " of " & Format$(End2& - 2, "0000") & " Errors: " & lngError
            DoEvents
         End If
      Next
      WriteToLogAndLogTable "SiteProductDataAlias", g_SessionID, "", 0, "Completed processing Supplementary Barcode File" & Trim$(txtDispPath) & "\BarCodes.IDX", True
      MsgBox "Completed Processing Supplementary BarCodes Please review the log file: " & Trim$(txtDispPath) & "\SiteProductDataAlias.Log", vbInformation
   
   End If
   
END_RESUME:
On Error Resume Next
   Close #idx
   rsSPD.Close
   Set rsSPD = Nothing
   Me.MousePointer = 0
   Exit Sub
   
ERR_SUPP_BARCODES:
   MsgBox Err.Description, vbCritical
   Resume END_RESUME

End Sub



