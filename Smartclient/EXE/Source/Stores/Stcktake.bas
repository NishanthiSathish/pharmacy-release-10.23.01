Attribute VB_Name = "StckTake"
'------------------------------------------------------------------------------------
'             Stock Take Module
'
'This module is a handler for the stock take form which must not be called directly
'
'20Nov98 TH LoadStockTake: Added check for new multisite stocklist report
'13Jan98 CKJ Simplified; always use multi site report
'            Moved DB check from within the form.
'            NB Use /UpdateWSLIST.mdb on the command line ONLY if backup has been taken
'
'Fields added to drugparameters:
'   stocktakestatus As String * 1   '0/1/2    0 to be done, 1 pending, 2 done
'   laststocktakedate As String * 8 'date as ddmmccyy, only updated at stocktakestatus 2
'   laststocktaketime As String * 6 'time as hhmmss    only updated at stocktakestatus 2
'
'17May99 CKJ StockTakeAdjustLevel: corrected Translog, added '-' to Qty
'06Jul99 TH  StockTakeAdjustLevel: Use findrdrug and not getdrug to authorise, as code in mdb may be localcode not NSV
'14Jul99 SF  StockTakeAdjustLevel: fix to allow lookup on local code.  This assumes only NSV code and local code will be used on lookup
'22Jul99 TH  StockTakeAdjustLevel: now looks up localcode regardless of mask. If this is not found it then searches on nsvcode.
'05Aug99 TH  StockTakeAdjustLevel: Search on nsvcode properly
'22Sep99 TH  StockTakeAdjustLevel: Changed message if system figures are now different to allow the input of the stocktake figure if user is sure it is correct
'                                  Previously stock takes could not be put into the system if the stock level had changed after the stocktake had been created.
'27Sep99 TH  StockTakeAdjustLevel: Enhanced Message
'30Oct00 AW  StockTake enhancement
'            new global added
'            stocktakeadjustlevel, lvwMainScreenfetch: code added to display stocktake in packs
'29May01 TH  StockTakeAdjustLevel: Added new search parameter to userlogviewer calls
'24sep01 CKJ Merged:
'01Sep01 TH  Replaced stocktakeinpacks ini file setting to conform to other ini switches (as boolean)
'01Sep01 TH  StockTakeAdjustLevel: Convert qty back to issue units if using StockTakeinPacks setting. (#52438)
'18Mar02 TH  StockTakeAdjustLevel: Merge error from above, one line should have been removed but was missed - This meant that when stock taking in packs
'            if the system level had changed since the stock take was created the stock change could double factor in the packsize (convfact) (#59749)
'21Nov02 TH  StockTakeAdjustLevel: Changed the logic that identifies an item cannot be found. This had been damaged by the int to lng conversion (#64768)
'06Mar07 CKJ Moved GetNewParentHWnd() from StoreAsc.bas
'20Nov07 CKJ Ported SetFocusTo from V9.9
'26May11 TH  Made StockinPacks Global. Was declared twice and references did not work.(F0111999)
'15Jul11 CKJ Removed CheckPath - deprecated
'22Jan13 CKJ Added wildcard & comma separated list of locations to new stock take  TFS53365
'            Removed superfluous code
'28Jan13 CKJ Changed length of stock take name from 20 chars to 64 as Const. This allows NSVcode+sp+drugname   TFS54468

'mods wanted;
' AskSiteCode - limit this to certain password holders - now deprecated & removed (29Jan13 CKJ)
' password control of amend/authorise
' enable multisite operation once tested - now deprecated & removed (29Jan13 CKJ)
'------------------------------------------------------------------------------------

Option Explicit
DefInt A-Z

'Dim intStockInPacks% '01Sep01 TH Replaced
Global intStockInPacks% '26May11 TH Made Global (F0111999)
'Dim m_StkLvl1 As Long  '06mar07 CKJ Removed as not used
'Dim m_StkLvl2 As Long  '   "
Dim m_Mode As Integer
'Dim m_lngRow As Long  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing

Global Const STNAMELEN = 64               '28Jan13 CKJ
Type StockTakeLine
   NSVCode As String * 7
   StockTakeName As String * STNAMELEN    '28Jan13 CKJ was 20
   StockLevel1 As String * 9
   StockLevel2 As String * 9
   StockTotal As String * 9
End Type

Global Const PROJECT = "Stock Take"
'

'06mar07 CKJ Removed as not used
'Function GetStockLevel1() As Long
' GetStockLevel1 = m_StkLvl1
'End Function
'Function GetStockLevel2() As Long
' GetStockLevel2 = m_StkLvl2
'End Function
'Sub SetStockLevel1(ByVal lngStockLevel1 As Long)
' m_StkLvl1 = lngStockLevel1
'End Sub
'Sub SetStockLevel2(ByVal lngStockLevel2 As Long)
' m_StkLvl2 = lngStockLevel2
'End Sub

Function GetMStockTakeMode() As Integer

   GetMStockTakeMode = m_Mode
  
End Function

Sub SetMStockTakeMode(ByVal intmode As Integer)
   
   m_Mode = intmode
    
End Sub

'21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing
'Function GetStockRow() As Long
'
'  GetStockRow = m_lngRow
'
'End Function
'
'Sub setStockRow(ByVal lngRow As Long)
'
'   m_lngRow = lngRow
'
'End Sub

'29Jan13 CKJ Deprecated. Sitecode (aka SiteNumber) must be own Dispadata.xxx
'Sub AskSiteCode(Code$)
''14Jan99 CKJ Replaces the original InputWin
''Returns selected site code as "043" or similar, or "" if escaped
''Only asks if more than one site is configured in siteinfo.ini
''otherwise returns own site number
'
'
'Dim temp$, numofsites%, count%, pathfound%
'
'   k.escd = False
'   numofsites = UBound(sitenos%)
'
'   '!!**
'   numofsites = 0   '20Jan99 CKJ Temporarily prevent multi-site working as this has not been fully tested
'
'   If numofsites = 0 Then
'      Code$ = Right$(dispdata$, 3)
'   Else
'      Code$ = ""
'      LstBoxFrm.Caption = "Stock Take"
'      LstBoxFrm.lblTitle = cr & "Select the Site where the Stock Take is to take place" & cr
'      LstBoxFrm.lblHead = "  Site" & TB & "Name"
'      For count = 0 To numofsites
'         temp$ = "  " & Right$(sitepth$(count), 3) & TB & siteabb$(count)
''         CheckPath sitepth$(count), pathfound          'checks to see if a path is available      '15Jul11 CKJ removed
''         If Not pathfound Then temp$ = temp$ & TB & "Not connected to this workstation"
'         LstBoxFrm.LstBox.AddItem temp$
'      Next
'
'      LstBoxShow
'
'      If LstBoxFrm.LstBox.ListIndex > -1 Then
'         Code$ = Trim$(Left$(LstBoxFrm.Tag, 5))
'      Else
'         k.escd = True
'      End If
'      Unload LstBoxFrm
'   End If
'
'End Sub

Sub LoadStockTake()


Dim proceed%, found%, x%, ans$, temp$

   intStockInPacks = TrueFalse(TxtD$(dispdata$ & "\winord.ini", "StockTake", "N", "StockInPacks", 0))      '01Sep01 TH Replaced

   proceed = True

   If Not fileexists(dispdata$ & "\MSTKLIST.RPT") Then        '13Jan98 CKJ was "\stcklist.rpt")
      popmessagecr "!Error", "Crystal report file MSTKLIST.RPT missing from directory " & dispdata$ & cr & cr & "Cannot load the Stock Take Utility."     '20Nov98 TH
      proceed = False
   End If

   If Not fileexists(dispdata$ & "\stckdiff.rpt") Then
      popmessagecr "!Error", "Crystal report file STCKDIFF.RPT missing from directory " & dispdata$ & cr & cr & "Cannot load the Stock Take Utility."
      proceed = False
   End If

   If proceed Then
      StockTake.Show 1
      Unload StockTake
      SetDispdata 0
      ScreenRefresh
   End If

End Sub

Function ReviewStockTakeSettings(ByVal Method%, ByVal MethodText$, ByVal MaxNumber As Long, ByVal Includes$) As String
'
'Method 1 Random, 2 Location, 3 BNF
'MethodText is Location code or BNF code
'MaxNumber is 0 for no restriction
'Includes = "000" to "111", "<Inc NonStock><Inc Not In Use><Inc Not on Live StockControl>"
'
'17Jan13 CKJ Changed maxnumber% to long
'21Jan13 CKJ Added support for multiple location codes with wildcards  TFS53365

Dim msg$, nod&, DoIt%, Selected%, total%, include%, Suitable%    '01Jun02 ALL/ATW
Dim dlocal As DrugParameters
Dim foundPtr As Long '01Jun02 ALL/ATW
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim strSisstock As String
Dim strInUse As String
Dim strLivestockctrl As String
Dim strLocCodes As String        'up to 100 chars
'Dim strBNF As String
Dim strNSVCode As String
Dim ptr As Integer

   Screen.MousePointer = HOURGLASS
   MethodText$ = Trim$(UCase$(MethodText$))
   'If Method = 3 Then Parsebnfcode MethodText$
   nod = GetNod()
   If Mid$(Includes$, 1, 1) = "0" Then strSisstock = "Y"      '0xx' non stock
   If Mid$(Includes$, 2, 1) = "0" Then strInUse = "Y"         'x0x' not in use
   If Mid$(Includes$, 3, 1) = "0" Then strLivestockctrl = "Y" 'xx0' not on live stock control
   
   Select Case Method
      Case 2              'Location
         '18Jan13 CKJ Now allows comma separated list of items, with optional * or % wildcards
         replace MethodText$, "*", "%", 0
         'filter out illegal chars & empty entries
         For ptr = 1 To Len(MethodText$)
            Select Case Mid$(MethodText$, ptr, 1)
               Case "a" To "z", "A" To "Z", "0" To "9", "%", "*", "&", ",", "-"
                  'valid, no action
               Case Else
                  Mid$(MethodText$, ptr, 1) = ","
               End Select
         Next
         replace MethodText$, ",,", ",", 0
         If Len(MethodText$) Then
            If Left$(MethodText$, 1) = "," Then MethodText$ = Mid$(MethodText$, 2)
         End If
         If Len(MethodText$) Then
            If Right$(MethodText$, 1) = "," Then MethodText$ = Left$(MethodText$, Len(MethodText$) - 1)
         End If
         strLocCodes = MethodText$
      
      Case 3              'BNF
         'strBNF = MethodText$
         popmessagecr "!", "BNF filter no longer supported"
         Exit Function
      
      Case 4              'NSVCODE
         strNSVCode = MethodText$
      End Select
   
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Sisstock", trnDataTypeVarChar, 1, strSisstock) & _
               gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, strInUse) & _
               gTransport.CreateInputParameterXML("Livestockctrl", trnDataTypeVarChar, 1, strLivestockctrl) & _
               gTransport.CreateInputParameterXML("Loccode", trnDataTypeVarChar, 100, strLocCodes) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
   Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWProductbyCriteriaForStockTakePreview", strParams)
   
   If Not rsStockTake Is Nothing Then     'use returned recordset
      If rsStockTake.State = adStateOpen Then
         If rsStockTake.RecordCount <> 0 Then
            Do While Not rsStockTake.EOF
               Suitable = Method
               total = total + 1
               If dlocal.stocktakestatus = "0" Then Selected = Selected + 1
               If RtrimGetField(rsStockTake!stocktakestatus) = "0" Then Selected = Selected + 1
               rsStockTake.MoveNext
            Loop
         End If
      End If
   End If

   If MaxNumber > 0 And Selected > MaxNumber Then
      msg$ = msg$ & " A limit of " & Format$(MaxNumber) & " items maximum from" & crlf
      msg$ = msg$ & "  " & Format$(Selected) & " items which are available for stocktake" & crlf
      Selected = MaxNumber
   Else
      msg$ = msg$ & " " & Format$(Selected) & " items are available for stocktake" & crlf
   End If
   
   msg$ = msg$ & "  " & Format$(total) & " items match the chosen criteria." & crlf
   msg$ = msg$ & "  The product file contains " & Format$(nod) & " items in total." & crlf
   ReviewStockTakeSettings = msg$
   Screen.MousePointer = STDCURSOR

End Function

Sub StockTakeAdjustLevel(ByVal STname$, ByVal ItemCode$, Value As String, ByVal intIndex As Integer)
'
'Sequence as follows:
' 1)  Create StockTake
' 1a) Print it
' 2)  Issue/Return/Receive goods
' 3)  Perform the Stock Take
' 4)  Issue/Return/Receive goods
' 5)  Authorise the StockTake
'
'If 2 or 4 have occurred then we cannot be sure from this procedure that the stock take is OK
'
'SysWas StkTake SysNow
'  10     10     10        All OK, authorise
'
'  10      8     10        None issued in the meantime; ask OK to reduce stock level by 2 widgets
'
'  10      8      8        Probably 2 issued before stocktake - show transactions
'  10     10      8        Probably 2 issued after the stocktake - show transactions
'  10      8      7        Some issued in the meantime, but still does not match - show transactions
'                           Likely cause; All correct ie was 10, issue 2, stocktake, issue 1, authorise
'
'17May99 CKJ corrected Translog, added '-' to Qty as it returned when it should have issued
'06Jul99 TH  Use findrdrug and not getdrug to authorise, as code in mdb may be localcode not NSV
'14Jul99 SF  fix to allow lookup on local code.  This assumes only NSV code and local code will be used on lookup
'22Jul99 TH  now looks up localcode regardless of mask. If this is not found it then searches on nsvcode.
'05Aug99 TH  Search on nsvcode properly
'22Sep99 TH  Changed message if system figures are now different to allow the input of the stocktake figure if user is sure it is correct
'            Previously stock takes could not be put into the system if the stock level had changed after the stocktake had been created.
'27Sep99 TH  Enhanced Message
'30Oct00 AW  Added code to display stocktake in packs
'29May01 TH  Added search parameter to call to logviewer
'01Sep01 TH  Convert qty back to issue units if using StockTakeinPacks setting.(#52438)
'18Mar02 TH  Merge error from above, one line should have been removed but was missed - This meant that when stock taking in packs if the system
'            level had changed since the stock take was created the stock change could double factor in the packsize (convfact) (#59749)
'21Nov02 TH  Changed the logic that identifies an item cannot be found. This had been damaged by the int to lng conversion (#64768)
'29Jan13 CKJ Removed first param ByVal SiteCode$ - deprecated & not now used

Dim SQL$, criteria$, msg$, SysLvlWas$, SysLvlNow$, StkTakLvl$, Units$, valid%, ans$, escd%  '01Jun02 ALL/ATW
Dim Qty!, dircode$, ward$, trantype$, IssType$, issueunitcost$, reason$, locked%, status%
Dim tempstock!  '16Oct00 AW added
Dim TempStkLvl$  '01Sep01 TH added
Dim foundPtr As Long  '01Jun02 ALL/ATW
Dim blnFound As Integer  '01Jun02 ALL/ATW
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim lngOK As Long
Dim lngTransPointer As Long
Dim blnAuthorised As Boolean
Dim strDescription As String

   blnAuthorised = False
   'dircode$ = "StockTake"   'reason code
   'adjustment cost centre
   ward$ = TxtD(dispdata$ & "\winord.ini", "StockTake", "", "AdjCostCentre", 0)
   trantype$ = "S"          '
   IssType$ = "S"           '

   'If SiteCode$ = "" Or STname$ = "" Or ItemCode$ = "" Then Exit Sub
   If STname$ = "" Or ItemCode$ = "" Then Exit Sub    '29Jan13 CKJ SiteCode removed
   If ward$ = "" Then
      
      msg$ = "Cost Centre for Stock Take Adjustments has not been set up" & cr & cr
      msg$ = msg$ & "Please ask your Supervisor to add the following to the WINORD.INI file" & cr & cr
      msg$ = msg$ & "    [StockTake]" & cr
      msg$ = msg$ & "    AdjCostCentre=XYZ" & cr & cr
      msg$ = msg$ & "where XYZ is replaced with the cost centre you wish to use."
      popmessagecr ".", msg$
      Exit Sub
   End If

''   criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
''   SQL$ = "SELECT * FROM StockTake" & criteria$ & " AND NSVCode = '" & ItemCode$ & "';"
''   Set dyn = WSDB.CreateDynaset(SQL$)

   'Lock the record here if possible
   
'29Jan13 CKJ Removed SiteCode
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'               gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
'               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, ItemCode$)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, ItemCode$)
   Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLine", strParams)

   If Not rsStockTake.EOF Then
      valid = True
      If IsNull(rsStockTake!StockLevel) Then valid = False
      If Trim$(GetField(rsStockTake!StockLevel)) = "" Then valid = False
      If Not valid Then
         findrdrug "=" & ItemCode$, 1, d, 0, blnFound, 2, False, False
         If blnFound = 0 Then
            d.SisCode = ItemCode$
            getdrug d, 0, foundPtr&, False
         End If
         strDescription = d.DrugDescription	' strDescription = GetStoresDescription()   XN 4Jun15 98073 New local stores description
         plingparse strDescription, "!"
         popmessagecr "!", "Stock level has not been entered for " & Trim$(strDescription)
      ElseIf GetField(rsStockTake!status) = "2" Then
         popmessagecr "!", RtrimGetField(rsStockTake!Description) & crlf & crlf & "This line has already been authorised"
      ElseIf GetField(rsStockTake!status) <> "1" Then
         popmessagecr "!", RtrimGetField(rsStockTake!Description) & crlf & crlf & "This line is not ready to be authorised"  'belt & braces
      Else
         findrdrug "=" & ItemCode$, 1, d, 0, blnFound, 2, False, False
         If blnFound = 0 Then
            d.SisCode = ItemCode$
            getdrug d, 0, foundPtr&, False
         End If
         If (foundPtr& = 0) And (blnFound = False) Then
            popmessagecr "!", "Cannot authorise this line," & cr & cr & "Product '" & ItemCode$ & "' not found"
         Else
            '''getdrug d, (foundPtr&), foundPtr&, True                    'Lock Drug '01Jun02 ALL/ATW
            getdrug d, (foundPtr&), foundPtr&, False  '11Jul06 TH Dont lock here !!
            '''locked = True
            If intStockInPacks = True Then
               If Trim$(d.stocklvl) = "" Then
                  tempstock! = 0
               Else
                  tempstock! = CDbl(d.stocklvl) / CDbl(d.convfact)            'show all data
               End If
               SysLvlNow$ = NoExp(tempstock!)
               msg$ = Trim$(GetField(rsStockTake!Description)) & cr & cr
               msg$ = msg$
            Else
               SysLvlNow$ = Trim$(d.stocklvl)
               SysLvlWas$ = GetField(rsStockTake!SystemLevel)
               StkTakLvl$ = rsStockTake!StockLevel

               Units$ = Trim$(GetField(rsStockTake!IssueUnits))
               msg$ = Trim$(GetField(rsStockTake!Description)) & cr & cr
               msg$ = msg$ & "Pack size: " & GetField(rsStockTake!PackSize) & " " & Units$ & "    " & money(5) & Format$(GetField(rsStockTake!issueprice), "0.00##") & cr & cr
            End If
            SysLvlWas$ = GetField(rsStockTake!SystemLevel)
            StkTakLvl$ = rsStockTake!StockLevel

            Units$ = Trim$(GetField(rsStockTake!IssueUnits))
            
            If SysLvlNow$ = SysLvlWas$ And SysLvlWas$ = StkTakLvl$ Then     'fully OK
               strParams = gTransport.CreateInputParameterXML("WStockTakeID", trnDataTypeint, 4, rsStockTake!WStockTakeID) & _
                           gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, rsStockTake!SiteNumber) & _
                           gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, rsStockTake!StockTakeName) & _
                           gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, rsStockTake!createddate) & _
                           gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, rsStockTake!CreatedUser) & _
                           gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, rsStockTake!createdterminal()) & _
                           gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, rsStockTake!modifieddate) & _
                           gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, rsStockTake!modifieduser) & _
                           gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, rsStockTake!modifiedterminal) & _
                           gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, "2") & _
                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rsStockTake!NSVCode) & _
                           gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, rsStockTake!Description) & _
                           gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, rsStockTake!PackSize) & _
                           gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, rsStockTake!issueprice) & _
                           gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, rsStockTake!SystemLevel) & _
                           gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, rsStockTake!IssueUnits) & _
                           gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, rsStockTake!Location1) & _
                           gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, rsStockTake!StockLevel1) & _
                           gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, rsStockTake!Location2) & _
                           gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, rsStockTake!StockLevel2) & _
                           gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, rsStockTake!StockLevel) & _
                           gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, rsStockTake!ClosedStockTake) & _
                           gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, rsStockTake!notes) & _
                           gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 8, Now)
                   
               strParams = strParams & gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, UserID$) & _
                                       gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                                       gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, "0") & _
                                       gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, SysLvlNow$) & _
                                       gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, Null)
               lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WStockTake", strParams)
               getdrug d, (foundPtr&), foundPtr&, True   '11jul06 TH Added - lock for immediate write
               d.stocktakestatus = "2"                      '0/1/2    0 to be done, 1 pending, 2 done
               d.laststocktakedate = thedate(False, True)   'ddmmyyyy
               d.laststocktaketime = thedate(False, -2)     'hhmmss
               putdrug d '', foundPtr&                             'Unlock  '01Jun02 ALL/ATW
               locked = False
               'refresh here
               blnAuthorised = True
               
            ElseIf SysLvlNow$ = SysLvlWas$ And SysLvlWas$ <> StkTakLvl$ Then    'System levels are OK
               Qty! = Val(StkTakLvl$) - Val(SysLvlWas$)           '@~@~ dp!()
               TempStkLvl$ = StkTakLvl$
               'If strStockInPacks$ = "Y" And Val(d.convfact) > 0 Then         '01Sep01 TH Convert back to issue units
               If intStockInPacks And Val(d.convfact) > 0 Then              '01Sep01 TH Replaced
                  Qty! = Qty! * Val(d.convfact)                            '   "
                  SysLvlNow$ = Format$(Val(SysLvlNow$) * Val(d.convfact))  '   "
                  StkTakLvl$ = Format$(Val(StkTakLvl$) * Val(d.convfact))  '   "
               End If                                                      '   "
               msg$ = msg$ & "System stock level:  " & SysLvlNow$ & " " & Units$ & cr
               msg$ = msg$ & "Stock take level:      " & StkTakLvl$ & " " & Units$ & cr & cr
               msg$ = msg$ & "Do you wish to "
               'msg$ = msg$ & Iff(Val(StkTakLvl$) > Val(SysLvlWas$), "Increase", "Reduce")   '15Aug01 TH Replaced
               msg$ = msg$ & Iff(Val(TempStkLvl$) > Val(SysLvlWas$), "Increase", "Reduce")   '   "
               msg$ = msg$ & " the system stock level by "
               msg$ = msg$ & Abs(Qty!) & " " & Units$ & "?"
               popmsg "EMIS Health", msg$, MB_YESNOCANCEL + MB_DEFBUTTON2 + MB_ICONQUESTION, ans$, escd
               If ans$ = "Y" Then
                  AskReasonCode "Stock Take Adjustment", reason$
                  If Not k.escd Then
                     If Qty! <> 0 Then
                        Translog d, foundPtr&, UserID$, "", -Qty!, reason$, ward$, "", trantype$, SiteNumber, IssType$, issueunitcost$  '   " '01Jun02 ALL/ATW
                        lngTransPointer = GetCurrentTransPointer()
                     'Else                         '07Nov05 TH Removed
                     '   lngTransPointer = Null    '    "
                     End If
                     strParams = gTransport.CreateInputParameterXML("WStockTakeID", trnDataTypeint, 4, rsStockTake!WStockTakeID) & _
                                 gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, rsStockTake!SiteNumber) & _
                                 gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, rsStockTake!StockTakeName) & _
                                 gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, rsStockTake!createddate) & _
                                 gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, rsStockTake!CreatedUser) & _
                                 gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, rsStockTake!createdterminal()) & _
                                 gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, rsStockTake!modifieddate) & _
                                 gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, rsStockTake!modifieduser) & _
                                 gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, rsStockTake!modifiedterminal) & _
                                 gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, "2") & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rsStockTake!NSVCode) & _
                                 gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, rsStockTake!Description) & _
                                 gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, rsStockTake!PackSize) & _
                                 gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, rsStockTake!issueprice) & _
                                 gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, rsStockTake!SystemLevel) & _
                                 gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, rsStockTake!IssueUnits) & _
                                 gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, rsStockTake!Location1) & _
                                 gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, rsStockTake!StockLevel1) & _
                                 gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, rsStockTake!Location2) & _
                                 gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, rsStockTake!StockLevel2) & _
                                 gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, rsStockTake!StockLevel) & _
                                 gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, rsStockTake!ClosedStockTake) & _
                                 gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, rsStockTake!notes) & _
                                 gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 8, Now)
                      
                     strParams = strParams & gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, UserID$) & _
                                             gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                                             gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, Format$(Qty!)) & _
                                             gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, SysLvlNow$)
                     '07Nov05 Added block
                     If Qty! <> 0 Then
                        strParams = strParams & gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, lngTransPointer)
                     Else
                        strParams = strParams & gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, Null)
                     End If
                     lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WStockTake", strParams)
                     getdrug d, (foundPtr&), foundPtr&, True   '11jul06 TH Added - lock for immediate write
                     d.stocktakestatus = "2"                      '0/1/2    0 to be done, 1 pending, 2 done
                     d.laststocktakedate = thedate(False, True)   'ddmmyyyy
                     d.laststocktaketime = thedate(False, -2)     'hhmmss
                     putdrug d '', foundPtr&                              'Unlock  '01Jun02 ALL/ATW
                     locked = False
                     blnAuthorised = True
''                     If Qty! <> 0 Then
''                        'Translog                  patid                      cons
''                        'Translog d, found, UserID$, "", Qty!, reason$, ward$, "", trantype$, SiteNumber, isstype$, issueunitcost$  '17May99 CKJ corrected
''                        Translog d, foundPtr&, UserID$, "", -Qty!, reason$, ward$, "", trantype$, SiteNumber, IssType$, issueunitcost$  '   " '01Jun02 ALL/ATW
''                     End If
                     'refresh here
                  End If
               ElseIf ans$ = "N" Then
                  '@~@~ ask what figure to use?
               ElseIf ans$ = "" Then
                  k.escd = True   '08Mar05 TH Added to pick up escape on multiple authorise
               End If
            Else                                                  'System levels differ
               If intStockInPacks And Val(d.convfact) > 0 Then              '01Sep01 TH Replaced
                  SysLvlNow$ = Format$(Val(SysLvlNow$) * Val(d.convfact))  '   "
                  StkTakLvl$ = Format$(Val(StkTakLvl$) * Val(d.convfact))  '   "
                  SysLvlWas$ = Format$(Val(SysLvlWas$) * Val(d.convfact))  '   "
               End If                                                      '   "
               msg$ = msg$ & "CAUTION: Stock level has changed since start of stock take" & cr & cr
               msg$ = msg$ & "System level was:   " & SysLvlWas$ & " " & Units$ & Format$(GetField(rsStockTake!createddate), " \a\t hh:mm \o\n dd mmm yyyy") & cr
               msg$ = msg$ & "Stock take level:    " & StkTakLvl$ & " " & Units$ & Format$(GetField(rsStockTake!modifieddate), " \a\t hh:mm \o\n dd mmm yyyy") & cr
               msg$ = msg$ & "System level now:  " & SysLvlNow$ & " " & Units$ & Format$(Now, " \a\t hh:mm \o\n dd mmm yyyy") & cr & cr
               popmsg "EMIS Health", msg$ & "Do you wish to review stock movements during this period?", MB_YESNOCANCEL + MB_ICONEXCLAMATION, ans$, k.escd
               If Not k.escd Then
                  If ans$ = "Y" Then
                     'UserLogViewer "", "T", Format$(GetField(rsStockTake!createddate), "dd mmm yyyy"), d.SisCode, "0", 3  '29May01 TH Added search parameter
                     'UserLogViewer "", "O", Format$(GetField(rsStockTake!createddate), "dd mmm yyyy"), d.SisCode, "0", 0  '29May01 TH
                     UserLogViewer "", "C", Format$(GetField(rsStockTake!createddate), "dd mmm yyyy"), d.SisCode, "0", 3
                  End If

                  'popmsg "ASCribe", msg$ & "Are you confident that the stock level of " & SysLvlNow$ & " " & units$ & " is actually correct?", MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2, ans$, k.escd
                  Qty! = Val(StkTakLvl$) - Val(SysLvlNow$) '27Sep99 TH Moved from below so as to be referenced in msg
                  'If intStockInPacks And Val(d.convfact) > 0 Then Qty! = Qty! * Val(d.convfact)'01Sep01 TH Convert back to issue units    '01Sep01 TH Replaced  '18Mar02 TH Really replaced - This had been left in probably due
                                                                                                                                                                 '           to a merge error, with predictably bad results (#59749)
                  msg$ = msg$ & "Are you confident that the stock take level of " & StkTakLvl$ & " " & Units$ & " is actually correct?" & cr & cr  '27Sep99 TH Enhanced Message
                  msg$ = msg$ & "This will "                                                                                                       '   "
                  msg$ = msg$ & Iff(Val(StkTakLvl$) > Val(SysLvlNow$), "Increase", "Reduce")                                                       '   "
                  msg$ = msg$ & " the system stock level by "                                                                                      '   "
                  msg$ = msg$ & Abs(Qty!) & " " & Units$ & cr                                                                                      '   "
                  popmsg "EMIS Health", msg$, MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2, ans$, k.escd      '22Sep99 TH
                  If ans$ = "Y" Then
''                     dyn.Edit
''                     dyn!status = "2"                             'authorised
''                     dyn!AuthorisedDate = Now
''                     dyn!AuthorisedUser = UserID$
''                     dyn!AuthorisedTerminal = ASCTerminalNameSQL()
''                     dyn!AuthorisedChange = "0"
''                     dyn!SystemLevelBeforeAuth = SysLvlNow$
''                     dyn.Update                                   '@~@~ err handler needed
                     If Qty! <> 0 Then                                                                                                 '22Sep99 TH
                        Translog d, foundPtr&, UserID$, "", -Qty!, reason$, ward$, "", trantype$, SiteNumber, IssType$, issueunitcost$  '   "  '01Jun02 ALL/ATW
                        lngTransPointer = GetCurrentTransPointer()
                     Else
                        lngTransPointer = 0 '17Jan06 TH Changed from null
                     End If
                     strParams = gTransport.CreateInputParameterXML("WStockTakeID", trnDataTypeint, 4, rsStockTake!WStockTakeID) & _
                                 gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, rsStockTake!SiteNumber) & _
                                 gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, rsStockTake!StockTakeName) & _
                                 gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, rsStockTake!createddate) & _
                                 gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, rsStockTake!CreatedUser) & _
                                 gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, rsStockTake!createdterminal()) & _
                                 gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, rsStockTake!modifieddate) & _
                                 gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, rsStockTake!modifieduser) & _
                                 gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, rsStockTake!modifiedterminal) & _
                                 gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, "2") & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rsStockTake!NSVCode) & _
                                 gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, rsStockTake!Description) & _
                                 gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, rsStockTake!PackSize) & _
                                 gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, rsStockTake!issueprice) & _
                                 gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, rsStockTake!SystemLevel) & _
                                 gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, rsStockTake!IssueUnits) & _
                                 gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, rsStockTake!Location1) & _
                                 gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, rsStockTake!StockLevel1) & _
                                 gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, rsStockTake!Location2) & _
                                 gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, rsStockTake!StockLevel2) & _
                                 gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, rsStockTake!StockLevel) & _
                                 gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, rsStockTake!ClosedStockTake) & _
                                 gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, rsStockTake!notes) & _
                                 gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 8, Now)
                      
                     strParams = strParams & gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, UserID$) & _
                                             gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                                             gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, "0") & _
                                             gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, SysLvlNow$) & _
                                             gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, lngTransPointer)
                     lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WStockTake", strParams)
                     getdrug d, (foundPtr&), foundPtr&, True   '11jul06 TH Added - lock for immediate write
                     d.stocktakestatus = "2"                      '0/1/2    0 to be done, 1 pending, 2 done
                     d.laststocktakedate = thedate(False, True)   'ddmmyyyy
                     d.laststocktaketime = thedate(False, -2)     'hhmmss
                     putdrug d '', foundPtr&                             'Unlock  '01Jun02 ALL/ATW
                     locked = False
                     blnAuthorised = True
''                     If Qty! <> 0 Then                                                                                                 '22Sep99 TH
''                        Translog d, foundPtr&, UserID$, "", -Qty!, reason$, ward$, "", trantype$, SiteNumber, IssType$, issueunitcost$  '   "  '01Jun02 ALL/ATW
''                     End If                                                                                                         '   "

                     'refresh here

                  ElseIf ans$ = "N" Then                          'Re-read figures as if starting stocktake now
                     'dyn.Edit
                     'tempdyn!CreatedDate = Now
                     'tempdyn!CreatedUser = UserID$
                     'tempdyn!CreatedTerminal = ASCTerminalName()
                     'tempdyn!ModifiedDate = Null
                     'tempdyn!ModifiedUser = ""
                     'tempdyn!ModifiedTerminal = ""
                     'tempdyn!Status = "0"                    'newly added
                     'tempdyn!SystemLevel = Trim$(d.Stocklvl)
                     'tempdyn!IssuePrice = Left$(Format$(Val(d.cost) / 100), 13)
                     'tempdyn!Location1 = Trim$(d.loccode)         'store bin location for use in Crystal Reports
                     'tempdyn!Location2 = Trim$(d.loccode2)        '  "
                     'dyn.Update                                   '@~@~ err handler needed
                  End If

                  'ans$ = ""
                  'k.max = 9
                  'InputWin "ASCribe", msg$ & "Enter quantity by which to adjust stock level", ans$, k
                  'If Not k.escd Then
                  '      AskReasonCode "Stock Take Adjustment", reason$
                  '      Qty! = Val(ans$)                             '@~@~ dp!()
                  '      dyn.Edit
                  '      dyn!Status = "2"                             'authorised
                  '      dyn!AuthorisedDate = Now
                  '      dyn!AuthorisedUser = userid$
                  '      dyn!AuthorisedTerminal = ASCTerminalName()
                  '      dyn!AuthorisedChange = Format$(Qty!)         '@~@~ trap too long
                  '      dyn!SystemLevelBeforeAuth = SysLvlNow$
                  '      dyn.Update                                   '@~@~ err handler needed
                  '      d.stocktakestatus = "2"                      '0/1/2    0 to be done, 1 pending, 2 done
                  '      d.laststocktakedate = TheDate(False, True)   'ddmmyyyy
                  '      d.laststocktaketime = TheDate(False, -2)     'hhmmss
                  '      putdrug d, found                             'Unlock
                  '      locked = False
                  '      If Qty! <> 0 Then
                  '            'Translog                  patid                      cons
                  '            Translog d, found, userid$, "", Qty!, dircode$, ward$, "", trantype$, sitenumber, isstype$, issueunitcost$
                  '         End If
                  '   End If
               End If
            End If
            '''If locked Then putdrug d '', -foundPtr&                              'Unlock only, no update  '01Jun02 ALL/ATW
            If blnAuthorised Then
               On Error Resume Next
               rsStockTake.Close
               Set rsStockTake = Nothing
               On Error GoTo 0
'29Jan13 CKJ Removed SiteCode
'               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                           gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                           gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
'                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, ItemCode$)
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, ItemCode$)
               Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLine", strParams)
   
               If Not rsStockTake.EOF Then
                  ''StockTake.lvwMainScreenFetchRow SiteCode$, STname$, ItemCode$, (StockTake.LvwMainScreen.SelectedItem.Index), 0, rsStockTake, True
                  'StockTake.lvwMainScreenFetchRow SiteCode$, STname$, ItemCode$, intIndex, 0, rsStockTake, True
                  StockTake.lvwMainScreenFetchRow STname$, ItemCode$, intIndex, 0, rsStockTake, True     '29Jan13 CKJ removed SiteCode
               ''intIndex
               End If
            End If
         End If
      End If
   End If

   On Error Resume Next
   rsStockTake.Close
   Set rsStockTake = Nothing
   On Error GoTo 0
   
   'REfresh the line
   'stockTake.lvwMainScreenFetchRow(SiteCode$,STName$,d.SisCode,lngRow,0,)

Exit Sub

'@~@~ add error handlers here


End Sub


Sub AskStockTakeName(STname$)
'scan mdb for unique names under SiteCode
'offer then in a list box
'return choice in STname or "" if escaped
'29Jan13 CKJ Removed param SiteCode. Now uses own LocationID_Site only

Dim SQL$, count%, criteria$
Dim strParams As String
Dim rsStockTake As ADODB.Recordset

   STname$ = ""
   '29Jan13 CKJ Removed SiteCode & swapped gWardStockSite for gDispSite
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gWardStockSite) & _
'               gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$)
'   Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakebySiteNumberDistinct", strParams)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
   Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakebySiteDistinct", strParams)
   
   If rsStockTake.BOF And rsStockTake.EOF Then               'empty
      popmessagecr "!", "No stock takes are in progress for this site"
   Else
      LstBoxFrm.Caption = "Stock Take"
      LstBoxFrm.lblTitle = cr & "Select a Stock Take to open" & cr
      'LstBoxFrm.lblHead = "  Stocktake Name    " & Space$(STNAMELEN - 20) & TB & "Date Created"  '28Jan13 CKJ added extra space & swapped columns
      LstBoxFrm.lblHead = "Date Created" & TB & "Stocktake Name" & String$(STNAMELEN + 25, Chr$(160))   '28Jan13 CKJ "
      rsStockTake.MoveFirst
      Do While Not rsStockTake.EOF
         'LstBoxFrm.LstBox.AddItem "  " & rsStockTake!StockTakeName & TB & Format$(rsStockTake!NearestDay, "dd mmm yyyy")  '28Jan13 CKJ swapped columns
         LstBoxFrm.LstBox.AddItem "  " & Format$(rsStockTake!NearestDay, "dd mmm yyyy") & TB & rsStockTake!StockTakeName
         rsStockTake.MoveNext
      Loop

      LstBoxShow

      'If LstBoxFrm.LstBox.ListIndex > -1 Then STname$ = Trim$(Left$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB) - 1))   '28Jan13 CKJ swapped columns
      If LstBoxFrm.LstBox.ListIndex > -1 Then STname$ = Trim$(Mid$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB) + 1))
      Unload LstBoxFrm
   End If
   rsStockTake.Close
   Set rsStockTake = Nothing
   k.escd = False

End Sub

Public Function UnAuthorisedStocklines(ByVal strSTname As String) As Boolean
'29Jan13 CKJ Removed first param ByVal strSiteCode As String - deprecated

Dim strParams As String
Dim lngCount As Long

   '29Jan13 CKJ Removed SiteCode
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'               gTransport.CreateInputParameterXML("SiteCode", trnDataTypeVarChar, 5, strSiteCode) & _
'               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, strSTname)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, strSTname)

   'lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWWardstockListCountbySiteNameandUnauthorised", strParams)   '28Jan13 CKJ corrected name
   lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeCountbySiteNameandUnauthorised", strParams)        '   "       TFS54468
   If lngCount > 0 Then
      UnAuthorisedStocklines = True
   Else
      UnAuthorisedStocklines = False
   End If

End Function

Function GetNewParentHWnd() As Long
'10Feb07 CKJ Needed by IPlink to set the parent of the topmost form
'            Since MainScreen is called non modally from sub Main, it appears not to be
'            recognised as the ultimate parent by SetWindowWord() API
'06Mar07 CKJ Moved from StoreAsc.bas to StckTake.bas and set parent window as StockTake

   On Error Resume Next
   GetNewParentHWnd = StockTake.Hwnd
   On Error GoTo 0

End Function
'24Feb13 TH Removed - merge
'Sub SetFocusTo(ctrl As Control)
''19Mar07 CKJ Copied from dispensing
'
'   On Error Resume Next
'   If ctrl.Visible Then
'      ctrl.SetFocus
'   End If
'   On Error GoTo 0
'
'End Sub
Function IsMultiLocStockTake(ByVal SiteID As Long, ByVal StockTakeName As String) As Boolean
'10Mar13 TH Written (TFS 58443)
'           Given a SiteID and StockTakeName, returns whether we have multiple stock locations

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, SiteID) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, StockTakeName)
   IsMultiLocStockTake = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeLocsCountbyStockNameandLocationID", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, "StckTake.IsMultiLocStockTake ", sErrDesc
End Function


