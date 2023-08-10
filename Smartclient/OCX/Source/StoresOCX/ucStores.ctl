VERSION 5.00
Begin VB.UserControl ucStores 
   ClientHeight    =   3600
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4800
   ScaleHeight     =   3600
   ScaleWidth      =   4800
End
Attribute VB_Name = "ucStores"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

Private Function SetConnection(ByVal sessionID As Long, ByVal AscribeSiteNumber As Long, ByVal URLToken As String) As Boolean
 '09May05 CKJ Main procedure to initialise the database connection
'21Nov05 CKJ Changed from Public to Private. Only one interface is now required.
'18Jul08 CKJ Replaced V9 Phartl with V10 .NET crypto
'28Jun12 AJK 36929 Changed ConnectionString to UnencryptedData
'                  Get unencrpyted data generically and then decide if to create a web or direct data connection
'07Jan14 TH  Added read of stores defaults(TFS TFS 78033)
'25Feb15 TH  Ensure User details are loaded for translog write (TFS 111081)
'17May16 XN  149374 Added ConvertTobase64
'Dim objPhaRTL As PHARTL10.Security
'Dim ConnectionString As String '28Jun12 AJK 36929 Replaced with UnencrpytedData

Dim UnencryptedData As String '28Jun12 AJK 36929 Replacement for ConnectionString
Dim valid As Boolean
Dim phase As Single
Dim strDetail As String
'Dim strURL As String
'Dim strToken As String
Dim ErrNumber As Long, ErrDescription As String
'Dim HttpRequest As WinHttpRequest
'Dim posn As Integer
'Dim success As Boolean
'Dim strSeed As String
'Dim strCypher As String
'Dim strCypherHex As String
Dim blnUseWebConn As Boolean '28Jun12 AJK 36929 Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String '28Jun12 AJK 36929 Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String '28Jun12 AJK 36929 Added to store the unencrypted token
Dim rs As ADODB.Recordset '25Feb15 TH TFS (TFS 111081)

Const ErrSource As String = "SetConnection"

   On Error GoTo ErrorHandler

   phase = 1
   If sessionID = 0 Then Err.Raise 32767, ErrSource, "Invalid SessionID (Zero)"
''   If AscribeSiteNumber = 0 Then Err.Raise 32767, ErrSource, "Invalid AscribeSiteNumber (Zero)"
   
   If AscribeSiteNumber = 0 Then
      strDetail = "- Invalid SiteNumber (Zero)"
   Else
      g_SessionID = sessionID
      SiteNumber = AscribeSiteNumber
           
      If Val(Right$(date$, 4)) < Val(CopyrightYear) Then
         Err.Raise 32767, ErrSource, "The clock in this computer has been set to " & date$ & cr & "Please correct the date on this computer"
      End If
           
      valid = False
      If Not gTransport Is Nothing Then
         'If Not gTransport.Connection Is Nothing Then
         '   If gTransport.Connection.state = adStateOpen Then
         If Not gTransportConnectionIsNothing() Then
            If gTransportConnectionState() = adStateOpen Then
               'gTransport.ADOSetConnectionTimeOut 5               '10aug12 CKJ not right in old world, definitely not right in web
               valid = True
            End If
         End If
      End If
       
      If Not valid Then
         '28Jun12 AJK 36929 Get unencrpyted data generically and then decide if to create a web or direct data connection
         UnencryptedData = ParseURLToken(sessionID, URLToken, phase, strDetail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
         'UnencryptedData = "provider=sqloledb;server=devdb6-2008R2;database=XN_Regression;uid=icwsys;password=ascribe;"
         
         If blnUseWebConn Then
            Set gTransport = New PharmacyWebData.Transport
            gTransport.UnencryptedKey = UnencryptedData
            gTransport.URLToken = strUnencryptedToken
            gTransport.ProxyURL = strWebDataProxyURL
            'frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
            'gTransport.BlankTag = frmBlank.Tag
            'AJK TODO
         Else
            'ConnectionString = ParseURLToken(sessionID, URLToken, phase, strDetail)
            '~~~~~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
            'ConnectionString = "provider=sqloledb;server=servername\instance;database=DBName;uid=user;password=pwd;"
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            If UnencryptedData <> "" Then
               phase = 4
               Set gTransport = New PharmacyData.Transport
               phase = 5
               Set gTransport.Connection = New ADODB.Connection
               phase = 6
               gTransport.Connection.open UnencryptedData
            End If
         End If
         '28Jun12 AJK 36929 END
         
         If (UnencryptedData <> "") Then
            phase = 7
            gDispSite = GetLocationID_Site(SiteNumber)
            
            phase = 8
            ReadSiteInfo
            ReadOrdData    '07Jan14 TH Added (TFS TFS 78033)
            
            StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", 0)
            If Trim$(StockExt$) = "" Then
               StockList$ = dispdata$
               gWardStockSite = gDispSite
            Else
               StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
               strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, Val(StockExt$))
               gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
            End If
            
            '19Feb15 TH Added some heap items (TFS 111720)
            Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0  '19Mar09 TH Added For UHB Interfacing
            Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '22Jul10 TH Added (UHB)(F0077942)
            Heap 10, gPRNheapID, "OrderLineNumber", "", 0  '07Sep10 TH initialise linenumber onto the heap (F0054531)
                          
            '25Feb15 TH Ensure User details are loaded for translog write (TFS 111081)
            gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
            strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
            If Not rs Is Nothing Then
               If rs.State = adStateOpen Then
                  If rs.RecordCount <> 0 Then
                     UserID = RtrimGetField(rs!initials)
                     UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
                     acclevels$ = "1000000000" 'default access, because we couldn't be here unless the user has role "Pharmacy"
                     '**!!** escalate access if extra policies set up - eg use a custom policy
                  End If
                  rs.Close
               End If
               Set rs = Nothing
            End If
            'TFS 111081 ----
            
            App.HelpFile = AppPathNoSlash() & "\ASCSHELL.HLP"
   
            '19Nov07 TH Added
            'If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "N", "AllowPatientPrinting", 0)) Then
            '   lblPatprint.Visible = True
            'End If
            'fraIVdetails.BackColor = White '19May08 TH Added
            valid = True
         End If
      End If
   End If
   
   If Not valid Then popmessagecr "Ward Stock", "Ward Stock OCX cannot connect to the Database. connection failed at phase " & CStr(phase)
   
   
Cleanup:
   If ErrNumber Then
      On Error Resume Next
      'gTransport.Connection.Close
      gTransportConnectionClose              '08Aug12 CKJ
      'Set gTransport.Connection = Nothing
      SetgTransportConnectionToNothing       '08Aug12 CKJ
      Set gTransport = Nothing
      On Error GoTo 0
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource & " (Phase=" & Format$(phase, "0.#") & ")"   '17Aug12 CKJ added  "0.#"
   End If
   
   If valid Then
      'lblStatus(0).Caption = " Connected "
   Else
      'UserControlEnable False
      ''lblStatus(0).Caption = " Unable to connect " & strDetail & " (Phase=" & Format$(phase, "0.#") & ")"   '17Aug12 CKJ added  "0.#"
      'DoAction.Caption = "RefreshView-Inactive"       '06oct05 CKJ added
   End If
                  
   UnsavedChanges = False
   SetConnection = valid
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
'   ErrSource = Err.Source
   ErrDescription = Err.Description
   popmessagecr "Ward Stock", "Ward Stock OCX cannot connect to the Database. connection Error (" & CStr(ErrNumber) & ") " & ErrDescription
Resume Cleanup

End Function
Public Function WardStockAction(ByVal sessionID As Long, _
                                 ByVal AscribeSiteNumber As Long, _
                                 ByVal WardStockListLineID As Long, _
                                 ByVal Mode As String, _
                                 ByVal blnBarcode As Boolean, _
                                 ByVal blnTopupCheck As Boolean, _
                                 ByVal URLToken As String _
                                ) As Boolean


'09Jul14 TH Written for legacy compatibility with new WardStockList Applications
'05Aug16 KR Bug 159577: Pharmacy Stock lists - issuing of Stores only products

Dim success As Boolean

Dim rs As ADODB.Recordset
Dim strParam As String
Static SiteNumber As Long
Dim drug As drugdetails
Dim lngIssueQuantity As Long '28Jan15 TH Added
Dim intStores As Integer '05Aug16 KR Added

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "RefreshState"

   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form

   lngIssueQuantity = 0
   
   '23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   Set gTransport = Nothing
   'If gTransport Is Nothing Then                                     'transport object doesn't exist
   '   'no action                                                     ' we'll create it in the next block below
   'Else                                                              'transport object is alive
   '   'If gTransport.Connection Is Nothing Then                      'but not connected
   '   If gTransportConnectionIsNothing() Then                        'but not connected                  '08Aug12 CKJ
   '      Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
   '   Else                                                           'it is connected
   '      'If gTransport.Connection.state = adStateOpen Then          'open & ready for use
   '      If gTransportConnectionState() = adStateOpen Then           'open & ready for use               '08Aug12 CKJ
   '         'no action                                               ' no further action, just use it
   '      Else                                                        'but not properly open
   '         'gTransport.Connection.Close                             ' attempt to close (may be connecting, handling an error etc)
   '         'Set gTransport.Connection = Nothing                     ' disconnect
   '         gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc) '08Aug12 CKJ
   '         SetgTransportConnectionToNothing                         ' disconnect                                                  '08Aug12 CKJ
   '         Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
   '      End If
   '   End If'

   '   '**!!** consider ClosePatsubs etc to reset globals
   'End If
      
   ''On Error GoTo ErrHandler
   
   ' 22Jan13 XN 53975 If session changes then clear user details
   If (g_SessionID <> sessionID) Or (SiteNumber <> AscribeSiteNumber) Then
      gEntityID_User = 0
      UserID = ""
      UserFullName = ""
   End If

   g_URLToken = URLToken  ' added cached URL so frmWebClient has a web server name (F0033906)
   success = True
   If (gTransport Is Nothing) Or sessionID <> g_SessionID Or (SiteNumber <> AscribeSiteNumber) Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      If UnsavedChanges Then
         popmessagecr "!Please Note:", "Changes from previous session have been discarded"
      End If
      'UserControlEnable False
      If sessionID <> 0 And g_SessionID = 0 Then
         'lblStatus(0).Caption = " Connecting ... "
      'ElseIf sessionID <> g_SessionID Then
         'lblStatus(0).Caption = " SessionID changed ... "
      'Else
         'lblStatus(0).Caption = " Reconnecting ... "
      End If
      
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
      
      'success = SetConnection(SessionID, SiteNumber)
      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)         '18Jul08 CKJ added param URLtoken
   End If
   
   If success Then
      'OK we are in, we have a connection and the site settings are loaded. Now lets begin the Action
      Select Case Mode
      Case "I", "R"
         'ward$ = strWardCode
         
         '05Aug16 KR Added.  Ensure the Stores value is initialised
         intStores = Val(TxtD(dispdata$ & "\winord.ini", "WardStock", "0", "AllowStoresOnly", 0))
         StoresValue 1, intStores
         
         LoadWardLineIntoDrugDetails WardStockListLineID, drug
         
         PrepareIssue 1, drug, IIf(Mode = "R", -1, 0), WardStockListLineID, True, blnTopupCheck, lngIssueQuantity
      
      
      End Select
      
   
   End If
   
   WardStockAction = Iff(lngIssueQuantity <> 0, True, False)
   
   'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

End Function

Public Function WardStockActionForUnsavedLine(ByVal sessionID As Long, _
                                              ByVal AscribeSiteNumber As Long, _
                                              ByVal LineDescription As String, _
                                              ByVal NSVCode As String, _
                                              ByVal PackSize As String, _
                                              ByVal PrintLabel As String, _
                                              ByVal TopupLevel As String, _
                                              ByVal strWardCode As String, _
                                              ByVal Mode As String, _
                                              ByVal blnTopupCheck As Boolean, _
                                              ByVal URLToken As String _
                                             ) As Long


'09Jul14 TH Written for legacy compatibility with new WardStockList Applications
'05Aug16 KR Bug 159577: Pharmacy Stock lists - issuing of Stores only products


Dim success As Boolean

Dim rs As ADODB.Recordset
Dim strParam As String
Static SiteNumber As Long
Dim drug As drugdetails
Dim intmode As Integer
Dim lngIssueQuantity As Long '28Jan15 TH Added
Dim intStores As Integer '05Aug16 KR Added

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "RefreshState"

   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   lngIssueQuantity = 0
   
   
   '23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   Set gTransport = Nothing
   'If gTransport Is Nothing Then                                     'transport object doesn't exist
   '   'no action                                                     ' we'll create it in the next block below
   'Else                                                              'transport object is alive
   '   'If gTransport.Connection Is Nothing Then                      'but not connected
   '   If gTransportConnectionIsNothing() Then                        'but not connected                  '08Aug12 CKJ
   '      Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
   '   Else                                                           'it is connected
   '      'If gTransport.Connection.state = adStateOpen Then          'open & ready for use
   '      If gTransportConnectionState() = adStateOpen Then           'open & ready for use               '08Aug12 CKJ
   '         'no action                                               ' no further action, just use it
   '      Else                                                        'but not properly open
   '         'gTransport.Connection.Close                             ' attempt to close (may be connecting, handling an error etc)
   '         'Set gTransport.Connection = Nothing                     ' disconnect
   '         gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc) '08Aug12 CKJ
   '         SetgTransportConnectionToNothing                         ' disconnect                                                  '08Aug12 CKJ
   '         Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
   '      End If
   '   End If

   '   '**!!** consider ClosePatsubs etc to reset globals
   'End If
      
   ''On Error GoTo ErrHandler
   
   ' 22Jan13 XN 53975 If session changes then clear user details
   If (g_SessionID <> sessionID) Or (SiteNumber <> AscribeSiteNumber) Then
      gEntityID_User = 0
      UserID = ""
      UserFullName = ""
   End If

   g_URLToken = URLToken  ' added cached URL so frmWebClient has a web server name (F0033906)
   success = True
   If (gTransport Is Nothing) Or (sessionID <> g_SessionID) Or (SiteNumber <> AscribeSiteNumber) Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      If UnsavedChanges Then
         popmessagecr "!Please Note:", "Changes from previous session have been discarded"
      End If
      'UserControlEnable False
      If sessionID <> 0 And g_SessionID = 0 Then
         'lblStatus(0).Caption = " Connecting ... "
      'ElseIf sessionID <> g_SessionID Then
         'lblStatus(0).Caption = " SessionID changed ... "
      'Else
         'lblStatus(0).Caption = " Reconnecting ... "
      End If
      
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
      
      'success = SetConnection(SessionID, SiteNumber)
      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)         '18Jul08 CKJ added param URLtoken
   End If
   
   If success Then
      'OK we are in, we have a connection and the site settings are loaded. Now lets begin the Action
      If Trim$(NSVCode) = "" Then
         drug.drugttl = LineDescription
         drug.catno = "&"
         drug.lastissuedate = ""
      Else
         DrugCode$ = Trim$(NSVCode)
         If trimz$(LineDescription) = "" Then
            desc$ = "Description missing from ward stock database."
         Else
            desc$ = Trim$(LineDescription)
         End If
         drug.drugttl = desc$
         drug.stklevl = Trim$(TopupLevel)
         drug.paksize = trimz$(PackSize)
         If PrintLabel = "~" Then
            drug.prepack = " "
         Else
            drug.prepack = Trim$(PrintLabel)
         End If
         drug.catno = Trim$(NSVCode)
         'drug.lastissue = Trim$(GetField(rsWardStock!lastissue))
         'drug.lastissuedate = Trim$(GetField(rsWardStock!lastissuedate))
         'drug.localcode = Trim$(GetField(rsWardStock!localcode))
         'If Trim$(drug.localcode) = "" Then
         drug.localcode = drug.catno
         'If rsWardStock!lastissuedate = Format(date, "dd/mm/yyyy") Then
         '   drug.dailyissue = Trim$(GetField(rsWardStock!dailyissue))   '29Jan99 TH
         'Else
            drug.dailyissue = "0" 'Trim$(GetField(snap!lastissue))   '29Jan99 TH
         'End If
      End If
      
      Select Case UCase$(Mode)
      Case "I", "R"
         ward$ = strWardCode
         'LoadWardLineIntoDrugDetails WardStockListLineID, drug
         
         '05Aug16 KR Added.  Ensure the Stores value is initialised
         intStores = Val(TxtD(dispdata$ & "\winord.ini", "WardStock", "0", "AllowStoresOnly", 0))
         StoresValue 1, intStores
         
         PrepareIssue IIf(blnBarcode, 3, 1), drug, IIf(Mode = "R", -1, 0), -1, True, blnTopupCheck, lngIssueQuantity
      
      Case Else
         popmessagecr "Ward Stock", "Mode " & Mode & " is not supported"
      End Select
      
   
   End If
   
   WardStockActionForUnsavedLine = lngIssueQuantity
   
   'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

End Function
Public Function WardStockExport(ByVal sessionID As Long, _
                                ByVal AscribeSiteNumber As Long, _
                                ByVal strWardCode As String, _
                                ByVal URLToken As String _
                               ) As Long
'23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
'05Aug16 KR Bug 159577: Pharmacy Stock lists - issuing of Stores only products

Dim intStores As Integer '05Aug16 KR Added

   On Error Resume Next
   
   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form

   Set gTransport = Nothing
   'If gTransport Is Nothing Then                                     'transport object doesn't exist
   '   'no action                                                     ' we'll create it in the next block below
   'Else                                                              'transport object is alive
   '   'If gTransport.Connection Is Nothing Then                      'but not connected
   '   If gTransportConnectionIsNothing() Then                        'but not connected                  '08Aug12 CKJ
   '      Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
   '   Else                                                           'it is connected
   '      'If gTransport.Connection.state = adStateOpen Then          'open & ready for use
   '      If gTransportConnectionState() = adStateOpen Then           'open & ready for use               '08Aug12 CKJ
   '         'no action                                               ' no further action, just use it
   '      Else                                                        'but not properly open
   '         'gTransport.Connection.Close                             ' attempt to close (may be connecting, handling an error etc)
   '         'Set gTransport.Connection = Nothing                     ' disconnect
   '         gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc) '08Aug12 CKJ
   '         SetgTransportConnectionToNothing                         ' disconnect                                                  '08Aug12 CKJ
   '         Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
   '      End If
   '   End If

   '   '**!!** consider ClosePatsubs etc to reset globals
   'End If
      
   ''On Error GoTo ErrHandler
   
   ' 22Jan13 XN 53975 If session changes then clear user details
   If (g_SessionID <> sessionID) Or (SiteNumber <> AscribeSiteNumber) Then
      gEntityID_User = 0
      UserID = ""
      UserFullName = ""
   End If

   g_URLToken = URLToken  ' added cached URL so frmWebClient has a web server name (F0033906)
   success = True
   If (gTransport Is Nothing) Or (sessionID <> g_SessionID) Or (SiteNumber <> AscribeSiteNumber) Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      If UnsavedChanges Then
         popmessagecr "!Please Note:", "Changes from previous session have been discarded"
      End If
      'UserControlEnable False
      If sessionID <> 0 And g_SessionID = 0 Then
         'lblStatus(0).Caption = " Connecting ... "
      'ElseIf sessionID <> g_SessionID Then
         'lblStatus(0).Caption = " SessionID changed ... "
      'Else
         'lblStatus(0).Caption = " Reconnecting ... "
      End If
      
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
      
      'success = SetConnection(SessionID, SiteNumber)
      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)         '18Jul08 CKJ added param URLtoken
   End If
   
    If success Then
        '05Aug16 KR Added.  Ensure the Stores value is initialised
        intStores = Val(TxtD(dispdata$ & "\winord.ini", "WardStock", "0", "AllowStoresOnly", 0))
        StoresValue 1, intStores
    
        ExportWardData strWardCode, 1
    End If
    
    'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

End Function

' Reads in a file in binary, and converts it to a base 64 string
' 17May16 XN 149374
Public Function ConvertTobase64(ByVal filename As String) As String
    Dim intFilepointer As Integer
    Dim data() As Byte
    
    intFilepointer = FreeFile
    Open filename For Binary As intFilepointer
    ReDim data(LOF(intFilepointer) - 1)
    Get intFilepointer, , data
    Close intFilepointer
    
    Dim doc As DOMDocument
    Dim root As IXMLDOMElement

    Set doc = New DOMDocument
    Set root = doc.createElement("encode")
    root.datatype = "bin.base64"
    root.nodeTypedValue = data

    ConvertTobase64 = root.text
End Function
