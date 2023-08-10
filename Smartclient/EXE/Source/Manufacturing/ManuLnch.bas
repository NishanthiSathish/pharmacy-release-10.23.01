Attribute VB_Name = "ManuLnch"
'-----------------------------------------------------------------------------------
'                             Launch Manufacturing
'-----------------------------------------------------------------------------------
'15Aug12 CKJ Changed gTransport so it can be either transport layer   TFS36929
'09Feb17 XN  Main: added cached URL so frmWebClient has a web server name (176200)
'-----------------------------------------------------------------------------------

Option Explicit
DefBool A-Z

'Global g_adoCn As ADODB.Connection  'V93 SQL   '15Aug12 CKJ
Global g_SessionID As Long          '   "

'15Aug12 CKJ Changed type to object for gTransport so it can be either transport layer   TFS36929
'Global gTransport As PharmacyData.Transport
Global gTransport As Object

Global g_Command As String
Global gEntityID_User As Long
Global Labrf(50) As Long
Global UserControlIsAlive As String
Global StopEvents As Boolean
Global Manupasslvl As Integer
'
Global Const PROJECT = "Manufacturing"
'

Public Sub Main()

'24Aug10 TH Added mod to initialise InternalOrderNumber element (UHB)(F0077942)
'09Feb17 XN added cached URL so frmWebClient has a web server name (176200)

'Dim Phartl As PHARTL10.Security          '12Aug08 CKJ removed
''Dim objDataAccess As clsDataAccess
Dim strParams As String
Dim Commanda$
Dim SaveTitle$
Dim rs As ADODB.Recordset
Dim phase As Single
Dim Detail As String
Dim UnencryptedData As String       '15Aug12 CKJ Replacement for ConnectionString      (TFS36929)
Dim blnUseWebConn As Boolean        '   "        Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String    '   "        Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String   '   "        Added to store the unencrypted token

   ''MousePointer = 11
   g_SessionID = Val(Mid$(Command$, (InStr(1, Command$, "/SID", vbBinaryCompare)) + 4))
   SiteNumber = Val(Left$(Command$, InStr(1, Command$, "/SID", vbBinaryCompare)))

'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~
'SiteNumber = 503 '272 '426 '503
'g_SessionID = 885 '2158
'767 '885 '281
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   If App.PrevInstance Then
      End
   End If
   
   FrmManufacturing.Show 0
      
   g_Command = Command$
   
   'Set g_adoCn = New ADODB.Connection
   phase = 1
   'g_adoCn.ConnectionString = ParseCommandURLToken(g_SessionID, g_Command, phase, Detail) '12Aug08 CKJ added block
   UnencryptedData = ParseCommandURLToken(g_SessionID, g_Command, phase, Detail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
   If blnUseWebConn Then
      Set gTransport = New PharmacyWebData.Transport
      gTransport.UnencryptedKey = UnencryptedData
      gTransport.URLToken = strUnencryptedToken
      gTransport.ProxyURL = strWebDataProxyURL
   Else
      '~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
      'UnencryptedData = "provider=sqloledb;server=***;database=***;uid=***;password=***;"
      '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
      If Len(Detail) Then
         MsgBox "Unable to connect to database" & cr & "Phase " & Format$(phase ,"0.#") & "  " & Detail, vbCritical + vbOKOnly, "Manufacturing"   '17Aug12 CKJ added  "0.#"
         Close
         End
      End If
         
      Set gTransport = New PharmacyData.Transport
      Set gTransport.Connection = New ADODB.Connection
      gTransport.Connection.open UnencryptedData '15Aug12 CKJ was using g_adoCn
   End If
   
   If SiteNumber = 0 Then
      MsgBox "Application has been called with no site number." & _
         crlf & "Please check with your system superviser." & _
         crlf & crlf & "This application cannot continue"
      Close
      End
   End If
   ''SQL might need to pass this in to alllow read only /high level access
   
   ' added cached URL so frmWebClient has a web server name (176200 XN 9Feb17)
   Dim urlStartPos As Long
   urlStartPos = InStr(1, Command$, "/urltoken=", vbBinaryCompare) + 10
   Dim urlEndPos As Long
   urlEndPos = InStr(urlStartPos, Command$, " ", vbBinaryCompare) - 1
   If urlEndPos = -1 Then urlEndPos = Len(Command$)
   g_URLToken = Trim(Mid$(Command$, urlStartPos, urlEndPos - urlStartPos + 1))
      
   'Manupasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/STRPASS", vbBinaryCompare)) + 8, 1))
   
   acclevels$ = Mid$(Command$, (InStr(1, Command$, "/STRPASS", vbBinaryCompare)) + 8, 1)
   
   'acclevels$ = "9999999999" 'DEBUG ONLY
   'acclevels$ = "8777777777"
   
   
   '29Oct97 EAC Removed code to set drive as this is now in ReadSiteInfo
   strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
   gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
   
   gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
   strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            UserID = RtrimGetField(rs!Initials)
            UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
         End If
         rs.Close
      End If
      Set rs = Nothing
   End If
   ReadSiteInfo
   d.SisCode = ""
   'Put the second Authority flag into a modular level variable. This will be used as a big switch for new functionality
   '26Aug09 TH Added (F0054335)
   
   If InStr(1, Command$, "///bondstore", 1) Then
      LoadBondStore
      gTransportConnectionClose     '15Aug12 CKJ
      Set gTransport = Nothing
      Close
      End
   End If
   
   setSecondAuthorisation (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVAS2ndAuth", 0)))
   
   Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '24Aug10 TH Added to initialise element (UHB)(F0077942)
   
   If Val(Mid$(acclevels$, 1, 1)) = 0 And GetSecondAuthorisation() Then setFormulaArchiveView (True) 'Only available in new world
   
   callmanufacturing d, 9, False '26Aug09 TH Added as was hardcoded with 9 previous ?? 'Put back seems to be required !!!
   'MousePointer = 0
   Close '!!** Sort this out !!!
   On Error Resume Next
   'Close DB Objects and connections
   gTransportConnectionClose     '15Aug12 CKJ
   Set gTransport = Nothing
   'Set g_adoCn = Nothing     '15Aug12 CKJ
   On Error GoTo 0
   End '!!**

End Sub

Public Function OCXlaunch() As Boolean
'stub
   OCXlaunch = False
End Function

Public Function SlaveModeEnabled() As Boolean
'stub
   SlaveModeEnabled = False
End Function

Public Function cmbUC(ctrlname As String, Optional ctrlindex As Variant) As ComboBox
'stub
End Function

Public Function txtUC(ctrlname As String, Optional ctrlindex As Variant) As TextBox
'stub
'txtUC = ""
End Function

Public Function chkUC(ctrlname As String, Optional ctrlindex As Variant) As CheckBox
   'stub
End Function

Public Function lblUC(ctrlname As String, Optional ctrlindex As Variant) As label
   'stub
End Function

Function GetOCXAction() As Integer
'stub
End Function

Public Function fraUC(ctrlname As String, Optional ctrlindex As Variant) As Frame
'stub
End Function

Sub setQuesdefaults(int1 As Integer)
'stub
End Sub

Public Function cmdUC(ctrlname As String, Optional ctrlindex As Variant) As CommandButton
   'stub
End Function

Public Sub SetFocusTo(strdummy As String)
'stub
End Sub

Public Sub PutRecordFailure(ByVal ErrNo As Integer, ByVal ErrDescription As String)
'Bye bye Baby bye bye

   popmessagecr "", "A critical Error has occurred. This application can no longer continue"
   Close
   End

End Sub

Function OCXheap(strVal As String, strDefault As String) As String
'stubbage
   OCXheap = strDefault
End Function

Public Sub CreatePSOrder(a As Long)
'Stubbage
End Sub
Public Function GetPSOSupplierText() As String
'Stubbage
End Function

