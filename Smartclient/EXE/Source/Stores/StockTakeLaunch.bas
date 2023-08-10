Attribute VB_Name = "StockTakeLaunch"
Option Explicit

Public Sub StockTakeLaunch()
''Dim StockExt$, StockList$
''Dim SaveTitle As String
''Dim found%, valid%
''Dim tmp$
''Dim Phartl As PHARTL10.Security
''Dim strParams As String
''
''   'SQL this is to come in on the command line setting
''   g_SessionID = 979
''
''   SiteNumber = Val(Command$)
''   '------------------
''
''   If App.PrevInstance Then
''      SaveTitle$ = App.Title
''      App.Title = "...duplicate instance."
''      MainScreen.Caption = "...duplicate instance."
''      AppActivate SaveTitle$
''      SendKeys "% R", True
''      End
''   End If
''
''   g_Command = Command$
''   Set Phartl = New PHARTL10.Security
''
''   Set gTransport = New PharmacyData.Transport
''   Set g_adoCn = New ADODB.Connection
''   g_adoCn.ConnectionString = Phartl.GetConnectionString(g_SessionID)
''   g_adoCn.Open
''   Set Phartl = Nothing
''   Set gTransport.Connection = g_adoCn
''
''
''   'Set objDataAccess = New clsDataAccess
''   'If Not objDataAccess.OpenGlobalConnection(ConnectionString) Then
''   '   MsgBox "Cannot Access Database. Application cannot run"
''   '   End
''   'End If
''
''   'SQL Get base gDispSite
''
''   acclevels$ = "9999989999" '"9999999999" '"9999989999"
''
''   '29Oct97 EAC Removed code to set drive as this is now in ReadSiteInfo
''   strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
''   gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
''   ReadSiteInfo
''
''''   MainScreen.Caption = "ASCribe Stock Control - " & hospname1$ & " " & hospname2$
''
''   SetToolBarIniFile MainScreen, dispdata$ & "\winordtb.ini"   '05jan99 CKJ
''
''   '09Nov99 AE  Added to ensure toolbarcontext is initialised
''   SetToolBarcontext 0
''   SetToolBarLinkCntrl Nothing
''
''   Screen.MousePointer = HOURGLASS
''
''   ReadOrdData
''   loadvatrates
''   ReadSites
''
''''   If SlaveModeEnabled() Then                              '29oct03 CKJ added block
''''      If InStr(1, Command$, "/de", 1) Then              'In F4 Drug Enquiry mode from PMR
''''         'do nothing here                            '
''''      ElseIf OCXlaunch() Then                        ' /OCX on command line
''''         LaunchfromOCX "O"                           ' so do it for module type "XO" [NB "XE" not supported]
''''         MainScreen.MnuProgram(2).Visible = False    'remove login
''''         MainScreen.MnuProgram(2).Enabled = False    '
''''         MainScreen.MnuProgram(3).Visible = False    'and separator
''''         MainScreen.MnuProgram(3).Enabled = False    '
''''      Else                                           '
''''         Screen.MousePointer = STDCURSOR             '
''''         tmp$ = "This Application can only be used in conjunction with ASCribe ICW." & cr & "Direct access to this Application is not available"
''''         popmessagecr "!", txtd$(dispdata$ & "\ascribe.ini", "PID", tmp$, "SlaveMessage", 0)
''''         Close                                       '
''''         End                                         '
''''      End If                                         '
''''   Else                                                 '---
''''      If InStr(1, Command$, "/de", 1) = 0 Then                  '26Dec98 ASC
''''         '''askpassword valid, UserFullName$, "Stock Control"
''''      Else                                                                                                                                                                    '16May04 TH Added
''''         If InStr(1, Command$, "/pl", 1) > 0 Then                                                                                                                             '   "
''''           If Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) < 3 Or Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) = 4 Then SetFindDrugLowPassLevel True  '   "
''''         End If                                                                                                                                                               '   "
''''      End If                                                    '     "
''''   End If
''
''   'SQL If Not fileexists(dispdata$ & stockmdb$) Then
''         'SQL popmessagecr "Error", "Stock Control Database file is missing." & Chr$(13) & "Please inform your System Manager" & Chr$(13) & Chr$(13) & "This program will now terminate."
''         'SQL Close
''         'SQL End
''      'SQL End If
''
''   '27jun97 EAC allow use of StockvalExt setting for Ward Stock Lists
''   'Set WSDB = OpenDatabase(dispdata$ + stockmdb$)
''   StockExt$ = txtd(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
''   If Trim$(StockExt$) = "" Then
''      StockList$ = dispdata$
''      gWardStockSite = gDispSite
''   Else
''      StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
''      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, Val(StockExt$))
''      gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
''   End If
''
''   App.HelpFile = "Stores.hlp"   '28Aug97 CKJ Added
''
''   'acclevels$=
''   'SQL THese need to be infered either from the command line or from the a sessionID link in the DB
''   Storepasslvl = Val(Mid$(acclevels$, 6, 1))
''   'WardStockPasslvl = Val(Mid$(acclevels$, 2, 1))
''   WardStockPasslvl = 4 'SQL DEBUG !!!!!!!!!!!!!!!!!!!!!!
''   ''Storepasslvl = 5
''
''   SetLicenseOptions
''   SetMenuOptions
''
''   'read and check maximum number of colums that will be displayed
''''   OTblMaxCols = Val(txtd$(dispdata$ + "\winord.ini", "defaults", "", "maxcols", found))
''''   If Not (OTblMaxCols > 0) Then
''''      popmessagecr "Error", "Maxcols is not defined in the ini file."
''''      Stop
''''   End If
''
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
''
''   StoreValCode% = ReadAskSupplierDefaults("Return to Store", 0)
''   Select Case ReadAskSupplierDefaults("Return to Store", 1)
''      Case 0: StoreValDisplay$ = "SEWL"
''      Case 1: StoreValDisplay$ = "SE"
''      Case 2: StoreValDisplay$ = "WL"
''      End Select
''
''   'set the display table to its maximum size
''   'SQL MainScreen.lvwMainScreen.Columns = OTblMaxCols
''
''   ''SetupStockLabels
''
End Sub
