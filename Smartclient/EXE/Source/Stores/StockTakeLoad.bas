Attribute VB_Name = "StockTakeLoad"
'---------------------------------------------------------------------------------
'                               Stock Take Loader
'---------------------------------------------------------------------------------
'13oct08 CKJ Token handling corrected (F0035499)
'15Aug12 CKJ Changed gTransport so it can be either transport layer   TFS36929
'24Apr13 XN  stkLaunch: Changed connection string encryption seed to work on any PC (60910)

Option Explicit
DefBool A-Z

Public Function PyxisSetup(bln1 As Boolean) As Boolean
'stub
   PyxisSetup = False
End Function

Public Function OnPyxisWard(str1 As String) As Boolean
'stub
   OnPyxisWard = False
End Function

Public Sub CreatePyxisEvent(int2 As Integer, int1 As Integer, str1 As String, NSV As String, Qty As Single, strCode As String)
'stub
End Sub

Sub UpdatePanels(ord As orderstruct, edittype%)
'Stub
End Sub

Sub Main()
   
   stkLaunch
   StockTake.Caption = "Stock Take Utility"
   StockTake.Show 0
   '06Jan05 TH Added to fulfil the stuff usually done in the main startup routines
   
End Sub

Private Sub stkLaunch()

'05Aug10 TH  Added call to initialise print element for output interface (UHB)(F0077942)
'21Jun11 TH  Reinstated command line read for password level (F0118256)
'24Apr13 XN  Changed connection string encryption seed to work on any PC (60910)

Dim StockExt$, StockList$
Dim SaveTitle As String
Dim found%, valid%
Dim tmp$
'Dim Phartl As PHARTL10.Security    '12Aug08 CKJ removed
Dim strParams As String
Dim rs As ADODB.Recordset
Dim phase As Single
Dim Detail As String
Dim UnencryptedData As String       '15Aug12 CKJ Replacement for ConnectionString      (TFS36929)
Dim blnUseWebConn As Boolean        '   "        Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String    '   "        Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String   '   "        Added to store the unencrypted token
Dim msg As String

   g_SessionID = Val(Mid$(Command$, (InStr(1, Command$, "/SID", vbBinaryCompare)) + 4))
   SiteNumber = Val(Left$(Command$, InStr(1, Command$, "/SID", vbBinaryCompare)))
   
'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
'SiteNumber = 884
'g_SessionID = 2061
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   If App.PrevInstance Then
      SaveTitle$ = App.title
      App.title = "...duplicate instance."
      MainScreen.Caption = "...duplicate instance."
      AppActivate SaveTitle$
      SendKeys "% R", True
      End
   End If
    
'   frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)      '13oct08 CKJ added
   frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
     
   g_Command = Command$
   
   'Set g_adoCn = New ADODB.Connection      '15Aug12 CKJ
   phase = 1                                                                  '12Aug08 CKJ added block
   'g_adoCn.ConnectionString = ParseCommandURLToken(g_SessionID, g_Command, phase, Detail)
   UnencryptedData = ParseCommandURLToken(g_SessionID, g_Command, phase, Detail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
   If blnUseWebConn Then
      Set gTransport = New PharmacyWebData.Transport
      gTransport.UnencryptedKey = UnencryptedData
      gTransport.URLToken = strUnencryptedToken
      gTransport.ProxyURL = strWebDataProxyURL
   Else
      If Len(Detail) Then
         MsgBox "Unable to connect to database" & cr & "Phase " & Format$(phase, "0.#") & "  " & Detail, vbCritical + vbOKOnly, "Stocktake Module"   '17Aug12 CKJ added  "0.#"
         Close
         End
      End If
   
      Set gTransport = New PharmacyData.Transport
      Set gTransport.Connection = New ADODB.Connection
      gTransport.Connection.open UnencryptedData
   End If
   
   'Set objDataAccess = New clsDataAccess
   'If Not objDataAccess.OpenGlobalConnection(ConnectionString) Then
   '   MsgBox "Cannot Access Database. Application cannot run"
   '   End
   'End If
   
   'SQL Get base gDispSite
   
   ''acclevels$ = "9999989999" '"9999999999" '"9999989999"
   
   '29Oct97 EAC Removed code to set drive as this is now in ReadSiteInfo
   strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
   gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
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
   
'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
'UserID = "ASC"
'UserFullName = "Mr Debug Testuser"
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ReadSiteInfo
    
''   MainScreen.Caption = "ASCribe Stock Control - " & hospname1$ & " " & hospname2$
   
   SetToolBarIniFile MainScreen, dispdata$ & "\winordtb.ini"   '05jan99 CKJ
   
   '09Nov99 AE  Added to ensure toolbarcontext is initialised
   SetToolBarcontext 0
   SetToolBarLinkCntrl Nothing
   
   Screen.MousePointer = HOURGLASS

   ReadOrdData
   loadvatrates
   ReadSites

''   If SlaveModeEnabled() Then                              '29oct03 CKJ added block
''      If InStr(1, Command$, "/de", 1) Then              'In F4 Drug Enquiry mode from PMR
''         'do nothing here                            '
''      ElseIf OCXlaunch() Then                        ' /OCX on command line
''         LaunchfromOCX "O"                           ' so do it for module type "XO" [NB "XE" not supported]
''         MainScreen.MnuProgram(2).Visible = False    'remove login
''         MainScreen.MnuProgram(2).Enabled = False    '
''         MainScreen.MnuProgram(3).Visible = False    'and separator
''         MainScreen.MnuProgram(3).Enabled = False    '
''      Else                                           '
''         Screen.MousePointer = STDCURSOR             '
''         tmp$ = "This Application can only be used in conjunction with ASCribe ICW." & cr & "Direct access to this Application is not available"
''         popmessagecr "!", txtd$(dispdata$ & "\ascribe.ini", "PID", tmp$, "SlaveMessage", 0)
''         Close                                       '
''         End                                         '
''      End If                                         '
''   Else                                                 '---
''      If InStr(1, Command$, "/de", 1) = 0 Then                  '26Dec98 ASC
''         '''askpassword valid, UserFullName$, "Stock Control"
''      Else                                                                                                                                                                    '16May04 TH Added
''         If InStr(1, Command$, "/pl", 1) > 0 Then                                                                                                                             '   "
''           If Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) < 3 Or Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) = 4 Then SetFindDrugLowPassLevel True  '   "
''         End If                                                                                                                                                               '   "
''      End If                                                    '     "
''   End If
   
   'SQL If Not fileexists(dispdata$ & stockmdb$) Then
         'SQL popmessagecr "Error", "Stock Control Database file is missing." & Chr$(13) & "Please inform your System Manager" & Chr$(13) & Chr$(13) & "This program will now terminate."
         'SQL Close
         'SQL End
      'SQL End If
   
'29Jan13 CKJ Hangover from when stocktake was a table in ward stock mdb
'            Incorrect now in SQL, but site may still have old setting
'            so check & warn if this is the case.
'   '27jun97 EAC allow use of StockvalExt setting for Ward Stock Lists
'   'Set WSDB = OpenDatabase(dispdata$ + stockmdb$)
'   StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
'   If Trim$(StockExt$) = "" Then
'      StockList$ = dispdata$
'      gWardStockSite = gDispSite
'   Else
'      StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
'      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, Val(StockExt$))
'      gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
'   End If
   StockList$ = dispdata$
   gWardStockSite = gDispSite
   StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
   If Trim$(StockExt$) <> "" Then
      msg = cr & " WARNING: Old setting 'SiteInfo.StockDataExt' found with value '" & StockExt & "'" & cr & " This is no longer supported as it may affect StockTake handling" & cr & cr & " Please contact EMIS Support before using the StockTake Module"
      popmessagecr ".StockTake", msg
      Close
      End
   End If
'--------
      
   App.HelpFile = "Stores.hlp"   '28Aug97 CKJ Added
   
   'acclevels$=
   'SQL THese need to be infered either from the command line or from the a sessionID link in the DB
   ''Storepasslvl = Val(Mid$(acclevels$, 6, 1))
   'WardStockPasslvl = Val(Mid$(acclevels$, 2, 1))
   ''WardStockPasslvl = 4 'SQL DEBUG !!!!!!!!!!!!!!!!!!!!!!
   'Storepasslvl = 8   '21Jun11 TH REmoved and replaced with below (must have been debug line left in - sorry) (F0118256)
   Storepasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/STRPASS", vbBinaryCompare)) + 8, 1))
   WardStockPasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/WRDPASS", vbBinaryCompare)) + 8, 1))
     
   SetLicenseOptions
   SetMenuOptions
   
   Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '05Aug10 TH Added (UHB)(F0077942)
   
   'read and check maximum number of colums that will be displayed
''   OTblMaxCols = Val(txtd$(dispdata$ + "\winord.ini", "defaults", "", "maxcols", found))
''   If Not (OTblMaxCols > 0) Then
''      popmessagecr "Error", "Maxcols is not defined in the ini file."
''      Stop
''   End If
   
''   EnterReqCode% = ReadAskSupplierDefaults("Requisitions", 0)
''   'EnterReqDisplay% = ReadAskSupplierDefaults("Requisitions", 1)
''   Select Case ReadAskSupplierDefaults("Requisitions", 1)
''      Case 0: EnterReqDisplay$ = "SEWL"
''      Case 1: EnterReqDisplay$ = "SE"
''      Case 2: EnterReqDisplay$ = "W"           '09Apr98 CFY was 'WL'
''      Case Else
''      End Select
''
''   AmendOrdersCode% = ReadAskSupplierDefaults("Amend Orders", 0)
''   'AmendOrdersDisplay% = ReadAskSupplierDefaults("Amend Orders", 1)
''   Select Case ReadAskSupplierDefaults("Amend Orders", 1)
''      Case 0: AmendOrdersDisplay$ = "SEWL"
''      Case 1: AmendOrdersDisplay$ = "SE"
''      Case 2: AmendOrdersDisplay$ = "WL"
''      End Select
''
''   SupplierRetCode% = ReadAskSupplierDefaults("Return to Supplier", 0)
''   'SupplierRetDisplay% = ReadAskSupplierDefaults("Return to Supplier", 1)
''   Select Case ReadAskSupplierDefaults("Return to Supplier", 1)
''      Case 0: SupplierRetDisplay$ = "SEWL"
''      Case 1: SupplierRetDisplay$ = "SE"
''      Case 2: SupplierRetDisplay$ = "WL"
''      End Select
''
''   StockValCode% = ReadAskSupplierDefaults("Stock Value Adj", 0)
''   Select Case ReadAskSupplierDefaults("Stock Value Adj", 1)
''      Case 0: StockValDisplay$ = "SEWL"
''      Case 1: StockValDisplay$ = "SE"
''      Case 2: StockValDisplay$ = "WL"
''      End Select
''if
''   StoreValCode% = ReadAskSupplierDefaults("Return to Store", 0)
''   Select Case ReadAskSupplierDefaults("Return to Store", 1)
''      Case 0: StoreValDisplay$ = "SEWL"
''      Case 1: StoreValDisplay$ = "SE"
''      Case 2: StoreValDisplay$ = "WL"
''      End Select
   
   'set the display table to its maximum size
   'SQL MainScreen.lvwMainScreen.Columns = OTblMaxCols
   
   ''SetupStockLabels
   
   Screen.MousePointer = STDCURSOR
   'Me.Show 1
   
End Sub

Sub blankorderscreens()
'stub
End Sub

Public Sub CreatePSOrder(a As Long)
'Stubbage
End Sub
Public Function GetPSOSupplierText() As String
'Stubbage
End Function

Function getTotalRepeats() As Integer
'Stubbage
getTotalRepeats = 0
End Function
