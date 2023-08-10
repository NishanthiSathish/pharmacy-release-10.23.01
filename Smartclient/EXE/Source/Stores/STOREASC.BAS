Attribute VB_Name = "StoreASC"


'22Apr02 SF/TH ResetMenuOptions: disables shelf stock and goods received report
'25Apr02 TH/SF RecordExpiry: Redone date validation to handle "t" etc on second pass
'26Apr02 SF    MinOrderValue: mods to use the given supplier code than that held against the product.  Not commented as original not released to site.
'10May02 SF    EditOrd: now strores the location code in the order (enh#1555)
'10May02 SF    MinOrderValue:, ShelfStockList: mods from internal testing (enh#1555).  Not commented as original not released to site.
'21May02 SF    AddToOrder: now allows part packs to be entered for supplementary orders (enh #1371)
'21May02 SF    Editord: added additional dummy parameter to EditAmend: (enh#1371)
'31May02 TH    ReturnToStore: Added new parameter to CreateDeliveryNoteRecord call
'28Jun02 TH    RecordExpiry: Ensure correct format of expiry date goes to logs (#61570)
'04Jul02 TH    AddToOrder: Reset k after entry of order number - stopped entry of suppliers message (#61545)
'15Jul02 TH    ToFollowsPrint: Changed index used -  now search on picktickno idex rather than reqnum as reqnum idx entry may be missing  (#59661)
'26Jul02 SF    AddToOrder: temp removed mod (enh #1371) until decision been made how to handle part packs throughout the system
'01Aug02 SF    SetMenuOptions: added setup for .MnuInfo(7) (#62527)
'05Sep02 SF    Editord: now allows cancelling out of amend orders when checking for preferred supplier (event #61536)
'04Jun03 TH    ReturnToStore: Added to mask to prevent rubbish qty input (#68693)
'12Jun03 TH    ReturnToStore: Reinstated line to ensure Stypes can still print Delivery notes
'                             - This should never have been included as this fault had been removed from the list
'01oct03 CKJ added brackets on ASCver()
'28Jan04 TH    receiveitem: Added blanking of new ord date field
'28Jan04 TH    SupplierOrderChecks: Written to do a check to see if there are still outstanding
'31Mar04 CKJ {SP1}
'13May04 CKJ SupplierOrderChecks: commented out
'16May04 TH    ReturnToStore: Use supplier code for delivery note if  wardcode is blank (#67791)
'16May04 TH    Receiveitem: Added Mods to prevent double issue when receipt has timed out and the line has been received elsewhere
'                           - strengthened locking during receipt process (#59077)
'16May04 TH    Main: Added mod to read passed passlvl from dispensary to check if price should be suppressed (UMMC price hide)
'16May04 TH    CheckExitVal: Mods to record picking ticket number (enh1549)
'16May04 TH    ShelfStockList: If configured sort on supplier code (#63766)
'16May04 TH                    Now use the drug location not the loccation from the order (#71558)
'16May04 TH    scanorders: Added to record Picking Ticket Number (enh1549)
'28May04 CKJ IssuePick: Close index
'            CloseOrderFiles: written
'            ChangeTable: CloseOrderFiles if Blank layout requested
'28May04 TH  ToFollowsPrint: Added Locking through acquire lock on prntpck5 to prevent possible deadlock (Glasgow)
'02Oct06 TH  Editord: Added check to prevent BNF search firing on blank search string (as there is no BNF search anymore) (SC-06-0768)
'10Feb07 CKJ Mechdisp handling added
'25Jun08 TH  IssuePick: Added dispdata reset - failsafe to ensure correct dispdata is assigned if an error occurs

'------ V10 Consolidation : Welcome to our new world (looks like the old one I know, but keep the faith !!)

'29Aug08 TH Storesmain: Debug back door to miss new security
'29Aug08 TH AddtoOrder: Mismerge in 9.8.60 oops - wouldnt update date last ordered and fired inappropriate msg. (F0028300)
'13oct08 CKJ Merged from V8.8: 01Aug08 TH/CKJ (F0023465) Receiveitem: Remove check on k.escd to stop potential "double receipt" - ie update of drug with no subsequent update of order
'12Nov08 CKJ CheckExitVal: removed validchars=YNX. superuser facility deprecated since at least 2000 (F0038457)

'------ RCN P009 : The Journey continues ....

'19Mar09 TH  Storesmain: Added sitenumber to heap for UHB Interfacing (F0032689)
'26Mar09 TH  Receiveitem: Added batchnum, expiry to "R" type orderlogs and added olToFollow to heap for UHB interfacing (F0032689)
'

'------ RCN P070
'07Jan10 CKJ corrected use of OTblMaxCols and the associated lines() array
'            OTblMaxCols is not now read from config, as it has to match the code below.
'15Jan10 XN  Added methods SetRobotLoadingMenuOption and GetRobotLocationCode (F0042698)
 
'-----  RCN P007
'28Mar10 TH  WriteLogSQL Removed. Moved to Corelib for use across suite (as Chris required)
'
'-----  RCN P158
'08Apr10 XN  Enabled correct value sorting on the Received Goods screen
'13Apr10 TH  EditOrd: Ported and converted (F0044679) 02Jul08 TH We need to check if this is already on order for the default supplier. If it is we warn and leave (F0020068)
'08Jun10 XN  Sets colour of tool bar from config setting, and set the site number in the title bar (F0085853)
'14Jun10 XN  SetSiteToolBarColour fix error if setting was Hex
'11Aug10 CKJ ChangeTable: Added IPLinkShutDown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
'-----------
'22Jul10 TH  Scanorders: Added code to set printable elements for interfacing (UHB)(F0077942)
'22Jul10 TH  Storesmain: Added initialisation of InternalOrderNumber element for interfacing (UHB)(F0077942)
'17Sep10 TH  Mainoptions: Cache the order num in case the user escapes at the entry box (incase there is a valid order in there, like on a right click (F0096620)
'06Sep10 TH  Receiveitem: Added DeliveryReference For UMMC (FINV). THe number is read from previous capture (F0054531)
'            (if applicable) and then sent into the orderlog call for recording in the DB. The reference is also stored in the WOrder and WReconcil tables (F0054531)
'06Sep10 TH  Scanorders: When the user selects a specific order from the display we may need to get a delivery note number. Call to capture this if required for UMMC (FINV) (F0054531)
'07Sep10 TH  Storesmain: initialise linenumber onto the heap for UMMC (FINV) (F0054531)
'02Nov10 AJK AddToOrder: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK CheckExitVal: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Issuepick: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK receiveitem: F0086901 Added date invoiced to OrderLog calls
'-----  RCN P650
'27May11 XN  MinOrderValue_LstBoxFrm_KeyUp: F087364 Amend Orders to have F4 screen

'reorders allsorts when probably shouldn't - d.outstanding done
'cyclical not working - orders neg qtys - done
'full description needed on printouts - done
'supplier names on printouts
'supllier names on coding slips
'outstanding not calc'ed properly - goes neg - done
'missing one supplier on each pause on display for auth & raise
'last page PgDn doesnt work correctly - done
'dont forget printers between picking ticket prints - done
'run don't chain - done

'01Jun11 CKJ Removed DispPgNo. This used to be current 'page no' in DOS, where 20 lines per page were in view.
'              Has no meaning now, and is always zero. However scattered so frequently that it is impractical
'              to comment every line. For changes do a 'diff' with previous version in TFS.
'              Most often found as DispPgNo * OInfoMaxLen, so removed entire clause where appropriate.
'            Removed "Microsoft Data Environment Instance 1.0 (SP4)" from project references
'              as it is not explicitly called. File is "C:\Program Files\Common Files\Designer\MSDERUN.DLL"
'            Changed DefInt to DefBool uncovering untyped params/vars in AddToOrder, issuepick,receiveitem
'              GetTableName, checkgrnfile, MainOptions, DisplayOrders, issuepick, ReturnToStore, updateprice
'              Set gWardStockSite As Long, note that previously this was an implicit Integer
'02Jun11 CKJ OMarked() array is a relic from TrueGrid days - not always in sync with listview
'             removed and the few places which actively used it now looks at lvwMainScreen instead
'06Jul11 CKJ DoseFromKg, DoseFromMsq, EditDirections, ShowInfo, ShowBNF: deleted stubs
'            checkgrnfile: deleted as FTU is obsolete. "checkgrn.rtf" layout was still editable, so removed it
'            XShelfStockList: deleted as ShelfStockList replaces it
'22Jul11 XN  ChangeTable: Clear sort order on main grid MainScreen.m_LastColumnSorted (F0102524), (F0102526), (F0102527)
'04Jan12 TH  StoresMain: Allow for mismatches with URLS (certain web sites) since a URL is now passed on the command line (thanks whoever did that !!!) TFS22012
'22Jun12 CKJ EditPatmedLayouts: alternative label layouts - large labels etc                     TFS36547
'            EditPatmedLayouts: Added list of standard label layouts for which an RTF exists     TFS37022
'              Removed deprecated "General prescription label layout" & "PRN prescription label layout"
'04Jul12 TH  Extended Maxcols for DLO
'05Jul12 CKJ Allow editing of toolbar colour & background image     TFS26714
'16Jul12 CKJ Corrected typo in rtf filename     TFS38686
'14Aug12 TH  MainOptions: Added Param (TFS 42771,42773)
'15Aug12 CKJ Changed gTransport so it can be either transport layer   TFS36929
'03Sep12 TH  ReceiveItem: Main PSO work for PSO receipt (TFS 42771)
'14Oct05 TH  MainOptions: Added to ensure correct sizing of table (TFS 51480)
'14Nov12 TH  SetMenuOptions: PSO Switch and menu handling (TFS 41433)
'16Nov12 TH  CheckExitVal: No F2 Supplier Swap for PSO and provide suitable msg (TFS 41373)
'19Nov12 TH  EnterActualReceive: PSO enhancements to include patient details on PSO receipt line (TFS 48806)
'24Jan13 CKJ SetSiteToolBarColourByForm: Added TFS54244
'19Feb13 TH  ReceiveItem: Always reconcile PSO regardless of pricing flag (Free receipt)
'06Mar13 TH  ReceiveItem: Fencepost batchtraking check Replaced above. This must have been missed in a merge TFS 58220
'10Mar13 TH  ReceiveItem: Fencepost batchtraking check for PSO. Missed this when fixing DLO. Silly boy (TFS 58632)
'21Mar13 TH  FillHeapPSOrderInfo: Changed date formats (TFS 59487)
'22Mar13 TH  FillHeapPSOrderInfo: Further change to handle unrecorded DOB (TFS 59559)
'24Mar13 TH  ReceiveItem: Check PSO here for cancelled prescriptions (TFS 59469)
'25Mar13 TH  CheckExitVal: Changed spelling on PSO Msg (TFS 59617)
'05Aug13 TH  Editord: Use actual Requisiton Number on req search - otherwise if there are multiple lines on diff reqs this will lead to
'                     problems editing and duplication (TFS 70742)
'07Aug13 TH  Editord: Fix missing prefix on IO call (TFS 70916)

'14Jun13 TH  EnterBatchno: Added new param to RecordExpiry (TFS 39884)
'14Jun13 TH  RecordExpiry: Added Expiry Date Checks - includes new parameter (TFS 39884)
'25Jul13 TH  RecordExpiry: Use days not minutes in comparison (TFS 69692)
'07Oct13 TH  CheckExitVal: Pick up stores only products on F7 issue all (TFS F0170257)
'08Jan15 TH  CheckExitVal: Added mods to ensure Ward Lists are updated from F7 update all (TFS 104036)
'16Feb15 TH  SetMenuOptions: WardStock switch with new web version (TFS 109033)
'23Apr14 XN  AddToOrder: commented out code as the 0 = 1 condition means the code will never execute
'14Apr14 TH  ScanOrders: Changed nature of fencepost to stop invalid issues being processed incorrectly, moved wslist update to within issued fencepost (TFS 88873)
'09May14 TH  ScanOrders: Reverted above mod but retained bar on Wslist update if no issue - although the above change seemed sensible, it then excluded zero issues (to force to follows) (TFS 90576)
'24Mar14 XN  GetRobotLocationCode: Changed RobotLoaderReplyComponent to PharmacyReplyComponent (TFS86905)
'05Sep14 TH  ReceiveItem: Changed pickno data type - was erroring on ticket numbers outside of int range.(TFS 99425)
'26Jan15 TH  ReceiveItem: Set the date as issued date for PSO Label update. Not the genuine date but the best approx we have.(TFS 109430)
'10Feb15 TH  EnterActualReceive: Blank the input so user must deliberately enter qty (TFS 82279)
'29Jul15 TH  Editord: Dont use requisition num to look up on anything other than initial PT (TFS 72776)
'29Jul15 TH  IssuePick: Deal with possible exponential (TFS 102570)
'05Aug15 TH  EnterActualReceive: Stop fractional receipt of orders when fraction not resolvable to 2 dec places (TFS 46785)
'12Aug15 TH  EnterActualReceive: Removed inappropriate division by convfact from fractional receipt checks (TFS 126106)
'13Aug15 TH  EnterActualReceive: Stop receipt of fractional issue unit (TFS 126355)
'04Sep15 TH  ReceiveItem: Fix costing fault on batch amalgamation for invoice (TFS 128729)
'29Sep15 TH  MainOptions: Ensure there is no possibility of previous supplier being used on receipt display (TFS 127190)
'06Apr16 XN  EditStockLabel: trimed LocalDescription before comparing it to "" 149885
'16Aug26 XN  issuepick: 160233 PrintDeliveryNote comes from Ward stock list now
'                        receiveitem: 160233 PrintDeliveryNote comes from Ward stock list now
'                        ReturnToStore: 160233 PrintDeliveryNote comes from Ward stock list now
'06Dec16 TH  AddtoOrder: Replaced RTF handling (TFS 157969)
'06Dec16 TH  OrdersPrint: Replaced RTF handling (TFS 157969)
'06Dec16 TH  Printcancellation: Replaced RTF handling (TFS 157969)
'06Dec16 TH  ShelfStockList: Replaced RTF handling (TFS 157969)
'04Jan17 TH  OrdersPrint: Ensure rtf Handling uses local file (TFS 157969)
'04Jan17 TH  ToFollowsPrint: Use Local file parsing for RTF handling (TFS 157969)
'04Jan17 TH  EditAlternativeLabels: Use DB parsing (TFS 157969)
'04Jan17 TH  EditStockLabel: Switch to use DB Parsing (TFS 157969)
'05Jan17 TH  OrdersPrint: Refactored RTF handling (TFS 157969)
'05Jan17 TH  ShelfStockList: Refactored RTF handling (TFS 157969)
'05Jan17 TH  ToFollowsPrint: Refactored RTF Handling (TFS 157969)
'05Jan17 TH  EditStockLabel: Replaced RTF Handling (TFS 157969)
'06Jan17 TH  EditStockLabel: Overhauled RTF handling (TFS 157969)
'10Jan17 TH  EditPatmedLayouts: Convert routines to use rtfs from database (TFS 157969)
'10Jan17 TH  EditAlternativeLabels: Converted to use DB stored RTF (TFS 157969)
'13Jan17 TH  SetLicenseOptions: Now we use new settings as the license file is defunct (Hosted) (TFS 156988)
'18Jan17 TH  ToFollowsPrint: Added message to make it explicit to the user when nothing to print (avoid confusion) (TFS 173942)
'02Feb17 TH  EditAlternativeLabels: Added section to allow inclusion of local file (not from DB) (TFS 175474)
'06Feb17 TH  EditPatmedLayouts: Use correct template for main PIL template (TFS 175775)
'13Feb17 TH  PrintCancellation: Added Release lock on main exit and none standard exit (TFS 176185,177040)
'14Feb17 TH  PrintCancellation: Moved get order so we can check to ensure it hasnt been deleted before we have locked
'            This can stop possible double deletion (TFS 177177)
'21Feb17 TH  PrintCancellation: Reverted above pending review - this is an existing issue NOT a hosted issue. (TFS 177177)
'14Jul17 TH  CheckExitVal: Moved batch recording to preceed translog entry - this ensures batch info against the correct item in log (TFS 189040)
'20Nov18 AF  TFS 231441 - Destroy existing heap only if user commits to authorise a new order. This call was being made too early on method MainOptions. Sendkeys overriden to fix the bug 'permission denied' on more recent OSs.
 

Option Explicit
DefBool A-Z

'Const reasonfile$ = "\reason.dat"
Const reasonfile$ = "reason"
Const modulename$ = "STOREASC.BAS"

Global Const OInfoMaxLen = 20 '16 '4 '32 '16
'Global Const OMaxArraySize = 3000 '21Aug06 TH Removed (DR-06-0620)

'Global Const OTblMaxCols% = 9       '07Jan10 CKJ This value is determined by the version of Stores and cannot be a config option
'Global Const OTblMaxCols% = 10       '04Jul12 TH  Extended for DLO
Global Const OTblMaxCols% = 12       '14Aug12 TH  Extended for PSO

Global OInfoStore() As String
Global ONumToDisplay As Long
'Global OMarked() As Integer                 '02Jun11 CKJ Relic from TrueGrid days - not always in sync with listview
Global ODisplayColWidths() As Integer
Global OColumnType() As String
'Global pagepos() As Long        '27Jun11 CKJ Unused. Removed.
'Global pageindexpos() As Long   '27Jun11 CKJ Unused. Removed.
'Global TGPageNo As Integer      '27Jun11 CKJ Unused. Removed.
Global PartsOrder As Integer  '12Nov98 TH
Global StockValCode%, StockValDisplay$
Global StoreValCode%, StoreValDisplay$
Global Edittype As Integer                                       '31Mar04 CKJ added type declaration
Global Storepasslvl%
Global sitenos() As Integer                                      '31Mar04 CKJ added type declaration
Global siteabb$(), sitepth$()
Global ordernum$
Global osite$
Global supnotes$
Global freeflag%
'Global g_adoCn As ADODB.Connection  'V93 SQL  '15Aug12 CKJ not needed now
Global g_adoConnectionString As String         '15Aug12 CKJ replacement (backwards compatibility only)
Global g_SessionID As Long          '   "

'15Aug12 CKJ Changed type to object for gTransport so it can be either transport layer   TFS36929
'Global gTransport As PharmacyData.Transport
Global gTransport As Object

Global g_Command As String
''Global gDispSite As Long  'Dispensary site ID marker
Global gWardStockSite As Long  'WardStock SiteID marker '01Jun11 CKJ Added as long (NB previously implicit Integer)

'Global ORecNo&(21), OASCcode$(21), Oordering$(21) 'record number for current line     '27Jun11 CKJ All deprecated

Dim EnterReqCode%, EnterReqDisplay$
Dim AmendOrdersCode%, AmendOrdersDisplay$
Dim SupplierRetCode%, SupplierRetDisplay$
Dim ord As orderstruct, tempord As orderstruct
'Dim td As dateandtime, dt As dateandtime
Dim ordered&
Dim foundanorder As Integer                                      '31Mar04 CKJ added type declarations
Dim notyetordered As Integer                                     '   "
'Dim newscreen As Integer, samepage As Integer                   '{SP2} seem pointless - remove?      '27Jun11 CKJ confirmed unused. removed.
Dim supcode$
Dim gRobotLocationCode As String                ' Cached form of the method GetRobotLocationCode empty string if system does not handle robots

Global gRequestID_Prescription As Long
Global gRequestID_Dispensing As Long
Global gEntityID_User As Long

Dim m_blnPSO As Boolean

Type AltLabel
   Description    As String * 30
   Context        As String * 8
   inuse          As Boolean
End Type

Dim m_PrescriptionID As Long '03Sep12 TH Added for PSO


'Function SupplierOrderChecks (ByVal strSupCode As String, ByVal strSupType As String) As String
''28Jan04 TH Written to do a check to see if there are still outstanding
''requisition records for a given supplier
'Dim pointer&, X&, cont&
'Dim ord As orderstruct
'Dim strMessage As String
'Dim strOrderCheckMsg As String
'Dim strResult As String
'
'   getnumofords 7, pointer&, False
'   X& = 1
'   cont& = 0
'
'first orders.
'   strResult = ""
'
'   Do
'      scanordreqindex 7, Trim$(strSupCode), cont&, X&
'      If X& <> 0 Then
'         getorder ord, X&, 7, False    ' (no idx)
'         If ord.status <> "D" And UCase$(Trim$(strSupCode)) = UCase$(Trim$(ord.supcode)) Then
'            'set message
'            strMessage = txtd(dispdata$ & "\winord.ini", "", "You should ensure these are managed before setting site to out of use !", "SupplierNoReqsMsg", 0)
'            If UCase$(Trim$(strSupType)) <> "W" And UCase$(Trim$(strSupType)) <> "L" Then
'               strOrderCheckMsg = txtd(dispdata$ & "\winord.ini", "", "Please ensure there are no outstanding Orders or Invoices for this Supplier !", "SupplierNoOrdsMsg", 0)
'            End If
'            strResult = "There are live Requisitions for this supplier." & CRLF & CRLF & strMessage
'            If strOrderCheckMsg <> "" Then strResult = strResult & CRLF & CRLF & strOrderCheckMsg
'         End If
'      End If
'   Loop Until X& = 0
'
'   SupplierOrderChecks = strResult
'
'End Function

Public Sub Sendkeys(text As Variant, Optional wait As Boolean = False)
   Dim WshShell As Object
   Set WshShell = CreateObject("wscript.shell")
   WshShell.Sendkeys CStr(text), wait
   Set WshShell = Nothing
End Sub

Sub AddToOrder(NSV$, sitepaths As Integer)
'-----------------------------------------------------------------------------
' Enter a supplementary order
'21May02 SF  now allows part packs to be entered for supplementary orders (enh #1371)
'04Jul02 TH  Reset k after entry of order number - stopped entry of suppliers message (#61545)
'26Jul02 SF  temp removed mod (enh #1371) until decision been made how to handle part packs throughout the system
'-----------------------------------------------------------------------------
'29Aug08 TH Mismerge in 9.8.60 oops - wouldnt update date last ordered and fired inappropriate msg. (F0028300)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitepaths param
'15May12 TH  Mods to record contract information in the WOrderlog (TFS 30860)
'23Apr14 XN  commented out code as the 0 = 1 condition means the code will never execute
'06Dec16 TH  Replaced RTF handling (TFS 157969)

'Rem $STATIC
' ask supplier & ordernumber

Dim tempord As orderstruct
Dim ans$, supcode$, reason$, reasonfile$, expn$, msg$, ordqty$
Dim FILE$, RTFTxt$, temp$, Code$, Description$
Dim OK%, preptd%, copies%, filno%, printtn%, printsis%, printedok%, success%, edtype%  'foundsup%,
Dim found&, pointer&
Dim PtotordCost!, PtotordVat!, pforprinting!, VatForPrinting!      '16Feb98 EAC/CY added these
Dim cont&, lastfnd& '19Oct99 TH
Dim FoundInEdType As Integer           '12Nov99 CKJ/AE Added
Dim extraline$                         '21Feb00 SF added
Dim strParameters As String
Dim rsOrders As ADODB.Recordset
Dim lngResult As Long
Dim strDescription As String
Dim blnFound As Integer '01Jun02 ALL/ATW
Dim lngFoundSup As Long
Dim strTemp As String
Dim strSpecialmsg As String
Dim dlocal As DrugParameters  '03Jun08 TH Ported form v8 (F0015752)
Dim foundPtr As Long          '  "
Dim lngOrderno As Long '30Sep10 TH Added

Dim strContractNumber As String   '15May12 TH Added (TFS 30860)
Dim strContractPrice As String    '    "
Dim blncontract As Boolean        '    "

   k.escd = False
                        
   If Not k.escd Then
      edtype = 3
      FoundInEdType = 0
      osite$ = ""
      'Get the last Order for this orderNumber
      strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, Format$(edtype)) & _
                      gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                      gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                      gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(ordernum$)) & _
                      gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                      gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                      gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParameters)
      If Not rsOrders.EOF Then
         rsOrders.MoveLast
         osite$ = GetField(rsOrders!supcode)
         'Do While Not rsOrders.EOF                                                                   '19Oct99 TH  Get last recno on this order no.
         '   'scanordreqindex edtype, ordernum$, cont&, found&       ' not received           from raised or received orders
         '   If found& Then
         '      lastfnd& = GreaterOf(lastfnd&, found&)                       '   "
         '      FoundInEdType = 3                                            '12Nov99 CKJ/AE Explicitly set type
         '   End If
         '   rsOrders.MoveNext
         'Loop
      End If
      rsOrders.Close
      Set rsOrders = Nothing
      If osite$ = "" Then
         edtype = 4
         strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                         gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, Format$(edtype)) & _
                         gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                         gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(ordernum$)) & _
                         gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                         gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                         gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteria", strParameters)
         If Not rsOrders.EOF Then
            rsOrders.MoveLast
            osite$ = GetField(rsOrders!supcode)
         End If
         rsOrders.Close
         Set rsOrders = Nothing
      End If
      'Do
      '   scanordreqindex edtype, ordernum$, cont&, found& ' recd, not reconciled
      '   If found& > lastfnd& Then
      '      lastfnd& = found&
      '      FoundInEdType = 4                                            'Explicitly set type
      '   End If
      'Loop While found&
      'found& = lastfnd&
      'End If
      'If found& Then
      '   getorder ord, found&, FoundInEdType, False                   'use explicit edit type
      '   osite$ = ord.supcode
      'Else
      If osite$ = "" Then
         popmessagecr "Order " & Trim$(ordernum$), "There are no items for this order number" & Chr$(10) & "waiting to be received or reconciled." + Chr$(10) + "A supplementary order cannot be raised."
         k.escd = True
         If ans$ = Chr$(228) Then
            popmessagecr "", "  ** For Use By System Supervisor Only **" + Chr$(10) + Chr$(10) + "  Enter supplier code: "
            k.escd = False             'raising of any order number
            asksupplier ord.supcode, 1, AmendOrdersDisplay$, "Enter Supplier Code", False, sup, False '15Nov12 TH Added PSO param
         End If
      End If
      If Not k.escd Then
         getsupplier osite$, 0, lngFoundSup, sup
         If lngFoundSup Then
            supcode$ = sup.Code
         Else
            popmessagecr "!n!i", "Supplier code '" + ord.supcode + "' not found"
            k.escd = True
         End If
      End If
   End If
   
   If Not k.escd Then
      findrdrug NSV$, True, d, False, blnFound, False, False, False
      If Not blnFound Then ' fnddrug = 0 Then
         k.escd = True
         popmessagecr "Exiting", "Could not find item in drug file."
      Else
         getdrug d, (False), 0, False ' fnddrug, False
         'getdrugsup d, (False), 0, False, supcode$ '15May12 TH Otherwise will not pick up correct contract info
      End If
   End If

   If Not k.escd Then
      If Val(d.reorderpcksize) Then popmessagecr "", "  Note: Re-order outer size = " + d.reorderpcksize
      Do
         k.Max = 4
         k.nums = True
         k.helpnum = 370
         ordqty$ = ""
         strDescription = d.DrugDescription     ' strDescription = GetStoresDescription() XN 4Jun15 98073 New local stores description
         plingparse strDescription, "!"
         ''inputwin "Supplementary Order", strDescription & crlf & crlf & "Extra quantity to order (x " & Trim$(d.convfact) & " " & Trim$(d.PrintformV) & ")", ordqty$, k
         'Use Enhance txtwin here now 31May05 TH Replaces above
         Unload frmEnhTxtWin
         frmEnhTxtWin.Caption = "Supplementary Order"
         frmEnhTxtWin.lblbox.Caption = strDescription & crlf & crlf & "Extra quantity to order"
         frmEnhTxtWin.lblExtra.Caption = " x " & d.convfact & " " & d.PrintformV
         frmEnhTxtWin.lblExtra.Left = 1500
         frmEnhTxtWin.lblExtra.Visible = True
         frmEnhTxtWin.txtBox.text = ordqty$
         frmEnhTxtWin.txtBox.Top = (frmEnhTxtWin.lblExtra.Top - 70)
         frmEnhTxtWin.txtBox.Width = 1000
         frmEnhTxtWin.txtBox.SelStart = 0
         frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
         HorizCentreForm frmEnhTxtWin
         frmEnhTxtWin.lblExtra.Visible = True
         ShowFrmEnhTxtWin
         If Not k.escd Then ordqty$ = frmEnhTxtWin.txtBox.text
         
         If k.exitval = 13 And Val(ordqty$) = 0 Then
            popmessagecr "!n!i", "Please enter a quantity"
         End If
      Loop Until Val(ordqty$) > 0 Or k.escd
      k.Max = 0
      k.nums = False
   End If
            
   If Not k.escd Then
      AskReasonCode "Supplementary Order", reason$
   End If

'  XN 23Apr14 commented out the following code as the 0 = 1 condition means the code will never execute
'   If 0 = 1 And Not k.escd Then
'      Do
'         OK = False
'         k.Max = 2
'         reason$ = ""
'         k.helpnum = 0
'         inputwin "Supplementary Order", "Enter reason for extra order", reason$, k
'         reason$ = UCase$(Trim$(reason$))
'         If k.exitval = -84 Then '^F1
'            'dispdata$ +
'            displaymacrofile reasonfile$, "Finance Reason Codes", Code$, Description$, True
'         ElseIf k.exitval = 13 Then
'            If Len(reason$) Then
'               'Check that the code is extant in the table
'               strParameters = gTransport.CreateInputParameterXML("Site", trnDataTypeint, 4, gDispSite) & _
'                               gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, reasonfile$) & _
'                               gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 5, reason$)
'               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupsSelectValue", strParameters)
'               If rsOrders.EOF Then
'                  expn$ = ""
'               Else
'                  expn$ = GetField(rsOrders!Value)
'               End If
'               rsOrders.Close
'               Set rsOrders = Nothing
'               If expn$ <> "< Invalid code >" And Trim$(expn$) <> "" Then OK = True
'            Else
'               popmessagecr "!n!iWarning", "A reason for the extra order must be entered"
'            End If
'            If OK Then
'               popmessagecr "Supplementary Order", expn$
'            End If
'         End If
'      Loop Until k.escd Or OK
'   End If

   If Not k.escd Then
      editspecialmsg "Supplementary Order"
      strSpecialmsg = getspecialmsg()
   End If
    
   If Not k.escd Then
      msg$ = ""
      k.Max = 57
      InputWin "Supplementary Order", "Enter notes to print on office copy", msg$, k
   End If
    
   If Not k.escd Then
      Do
         ans$ = ""
         k.helpnum = 0
         'Confirm "Supplementary Order", "raise this order?   Y/N", ans$, k
         strTemp = "raise this order for " & ordqty$ & " x " & Trim$(d.convfact) & " of " & Trim$(strDescription)
         Confirm "Supplementary Order", strTemp, ans$, k  '#79802
      Loop Until Trim$(UCase$(ans$)) = "Y" Or Trim$(UCase$(ans$)) = "N" Or k.escd
   End If

   If Not k.escd And Trim$(UCase$(ans$)) = "Y" Then   ' Print it
      blankorder ord
      ord.num = ordernum$
      ord.orddate = thedate(False, True)
      ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
      ord.Code = d.SisCode
      ord.outstanding = ordqty$
      ord.qtyordered = ordqty$
      ord.received = ordqty$
      ord.supcode = supcode$
      ord.status = "3"
      ord.invnum = reason$
      If Val(d.contprice) > 0 Then
         ord.cost = d.contprice
      Else
         If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then
            ord.cost = d.sislistprice 'price last paid
         Else
            ord.cost = d.cost
         End If
      End If
      'SQL ForgetPrinterList
      If preprint$ = "Y" Then preptd = True Else preptd = False
      'GetTextFile dispdata$ + "\orddata.rtf", RTFTxt$, success
      GetRTFTextFromDB dispdata$ + "\orddata.rtf", RTFTxt$, success '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - ORDDATA.RTF"
         Exit Sub
      End If

      'GetTextFile dispdata$ & "\OrdExtra.rtf", extraline$, success
      GetRTFTextFromDB dispdata$ & "\OrdExtra.rtf", extraline$, success '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - ORDEXTRA.RTF"
         printedok = False
         Exit Sub
      End If
      If LCase$(Left$(extraline$, 5)) = "{\rtf1" Then extraline$ = Mid$(extraline$, 2)
         Do
            For copies = 1 To 2
               MakeLocalFile FILE$
               filno = FreeFile
               Open FILE$ For Binary Access Write Lock Read Write As #filno

               temp$ = "{"
               Put #filno, , temp$
               '17Nov05 TH Added
               If copies = 1 Then
                  setspecialmsg strSpecialmsg
               Else
                  setspecialmsg msg$
               End If
               '-------------
               printordertop supcode$, ordernum$ + "/S", filno, printtn, printsis, 0, False '20Aug12 TH PSO - not allowed for supplemental orders
               PrintOrdDescriptor filno, printtn, False

               temp$ = "    " & String$(40, "*") & "[cr]"
               temp$ = temp$ & "    **  SUPPLEMENTARY ORDER  **[cr]"
               temp$ = temp$ & "    " & String$(40, "*") & "[cr]"
               If copies = 2 Then
                  temp$ = temp$ & "[cr]"
                  temp$ = temp$ & "  << DUPLICATE COPY TO BE RETAINED BY THE OFFICE >>  [cr]"
               End If
               temp$ = temp$ & "[cr]"
               PrinterParse temp$
               Put #filno, , temp$
               
               PtotordCost! = 0
               PtotordVat! = 0

               OrderLineParse ord, RTFTxt$, filno%, printsis%, printtn%, 1, PtotordCost!, PtotordVat!, pforprinting!, VatForPrinting!, True, False '14Nov12 TH Added param - PSO not on supplemental order
               If printtn Or OrdPrintPrice Then OrderLineParse ord, extraline$, filno%, printsis, printtn%, 1, PtotordCost, PtotordVat!, pforprinting!, VatForPrinting!, False, False '14Nov12 TH Added param - PSO not on supplemental order
               If copies = 1 Then
                  temp$ = "[cr]    Office reference"
               Else
                  temp$ = "[cr]    Supplementary order"
               End If
               temp$ = temp$ & " code :  " & reason$ & "[cr]"
               PrinterParse temp$
               Put #filno, , temp$
               If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
                  PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
               End If
               printordertail filno%, sup.ordmessage, False
               Close #filno

               'Print file
               WSspool FILE$, "Stock Control", 1, True, False, "PurchOrd"
                
            Next

            Do
               printedok = 1
               ans$ = UCase$(TxtD$(dispdata$ & "\winord.ini", "defaults", "", "SuppOrdersPrintedOkDefault", success))
               k.escd = False
               askwin "Completed", "Printed OK? Y/N (Esc to abort order)  ", ans$, k
               Select Case Trim$(UCase$(ans$))
                  Case "Y"
                     printedok = True
                  Case "N"
                     printedok = False
               End Select
               'you've just pressed Esc - just ask to make sure
               If printedok = 1 And UCase$(TxtD$(dispdata$ & "\winord.ini", "defaults", "", "SuppOrdersAskIfCancel", success)) = "Y" Then
                  ans$ = UCase$(TxtD$(dispdata$ & "\winord.ini", "defaults", "", "SuppOrdersPrintedOkDefault", success))
                  askwin "Abort Order", "Are you sure? Y/N", ans$, k
                  If Trim$(UCase$(ans$)) = "Y" Then
                     k.escd = True
                     printedok = False
                  End If
               ElseIf printedok = 1 Then
                  printedok = False
               End If
               If k.timd Then popmessagecr "!n!i", "Printing needs confirmation" '!!** beep
            Loop Until Not k.timd And printedok <> 1
         Loop Until printedok Or k.escd
            
         If printedok Then
            ''getnumofords 3, pointer&, True
            ''getorder tempord, pointer&, 3, True   ' ----> LOCK (no idx)
            blankorder ord
            ord.num = ordernum$
            ord.orddate = thedate(False, True) '03May98 CKJ Y2K
            ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
            ord.Code = d.SisCode
            ord.outstanding = ordqty$
            ord.qtyordered = ordqty$
            ord.received = ordqty$
            ord.supcode = supcode$
            ord.status = "3"
            ord.invnum = reason$
            If Val(d.contprice) > 0 Then
                ord.cost = d.contprice
                strContractPrice = d.contprice
                strContractNumber = d.contno
            Else
               If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then
                  ord.cost = d.sislistprice 'price last paid
               Else
                  ord.cost = d.cost
               End If
               strContractPrice = ""
               strContractNumber = ""
            End If
            lngResult = PutOrder(ord, 0, "WOrder")          '------> UNLOCK (idx)
            '30Sep10 TH added header and footer for UMMC FINV after unit test, also needed for UHB
            lngOrderno = Val(ordernum$)
            'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D"
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D", False '03Mar14 TH Added Param
            Heap 10, gPRNheapID, "OrderLineNumber", "1", 0
            '-------
            'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ordqty$, "", ord.cost, ord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", "" '    "
            
            '14May12 Added section to record Contract Information (TFS 30860)
            dlocal.SisCode = d.SisCode
            getdrug dlocal, 0, foundPtr, False
            If dlocal.supcode <> ord.supcode Then 'This is being ordered from a secondary supplier
               If Val(dlocal.contprice) > 0 Then  'there is contract info for the primary supplier
                  If Not (Val(strContractPrice) > 0) Then
                     'secondary supplier has no contract, primary does, we flag this order. This also covers manual entry
                     blncontract = True
                  End If
               End If
            End If
            setContractData strContractNumber, strContractPrice, blncontract
            
            'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ordqty$, "", ord.cost, ord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", "", ""  '02Nov10 AJK F0086901 Added paydate
            Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ordqty$, "", ord.cost, ord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", "", "", ord.PSORequestID '04Mar14 TH Added PSORequestID
                         
            'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D" '30Sep10 TH added
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D", False '03Mar14 TH Added Param
                         
            dlocal.SisCode = d.SisCode          '29Aug08 TH Mismerge in 9.8.60 oops (F0028300)
            getdrug dlocal, 0, foundPtr, True                                                         '15Jan07 PJC Update the last ordered date for a Supplementary Order (#89426)'03Jun08 TH Ported form v8 (F0015752)
            If foundPtr = 0 Then '                                                                    '            "
               popmessagecr "!n!b", "Unable to find drug in drug file. Cannot save your changes."     '            "
            Else                                                                                      '            "
               dlocal.lastordered = Format$(Now, "ddmmyyyy")                                          '            "
               putdrug dlocal                                                                         '            "
            End If                                                                                    '            "
            
            setContractData "", "", False '15May12 TH (TFS 30860)
            
         End If
         'SQL ForgetPrinterList
      End If
   'End If
   setspecialmsg "" '17Nov05 TH Added
   
End Sub

Sub AskReasonCode(text$, reason$)
' 7Jul94 CKJ Written. Takes text$ = "extra order" etc
'            Returns reason$ or k.escd (shared)
'            Uses dispdata$, reasonfile$, k
'            Max length for text$ is 16 chars
'            Place cusor before calling, ensure screen/window is > 38 wide
Dim Description$

   displaymacrofile "Reason", "Enter reason code for " + text$, reason$, Description$, True
   k.escd = False
   If Trim$(reason$) = "" Then
      k.escd = True
      popmessagecr "!", "No Reason Code selected - exiting."
   End If

End Sub
Sub AskReasonCodeSQL(text$, reason$)
' 7Jul94 CKJ Written. Takes text$ = "extra order" etc
'            Returns reason$ or k.escd (shared)
'            Uses dispdata$, reasonfile$, k
'            Max length for text$ is 16 chars
'            Place cusor before calling, ensure screen/window is > 38 wide
'14Jan02 TH  Removed title of popmessage as is not generic enough (#47611)

Dim Description$
Dim strFilename As String
   strFilename = "Reason"
   displaymacrofile strFilename, "Enter reason code for " + text$, reason$, Description$, True
   k.escd = False
   If Trim$(reason$) = "" Then
      k.escd = True
      popmessagecr "!", "No Reason Code selected - exiting."                     '     "
   End If

End Sub

Sub ChangeTable(SectionHdr As String, ByVal blnPSO As Boolean)

'23Dec97 EAC clear list box before displaying
'            don't preserve previous column widths
'07Jan98 EAC eliminate the extra column that sometimes appeared
'26Oct99 AE  Disable F8 receive free if entering costs on recipt
'09Nov99 AE  Set ToolBar contexts to allow buttons to work.
'23Jan02 TH  Added extra width to compensate for scrollbar in wardstocks (#51039)
'28May04 CKJ CloseOrderFiles if Blank layout requested
'11Aug10 CKJ Added IPLinkShutDown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
'22Jul11 XN  Clear sort order on main grid MainScreen.m_LastColumnSorted (F0102524), (F0102526), (F0102527)
'14Aug12 TH  Added PSO flag param to set and clear PSO functionality (TFS 42771,42773)
'28Nov12 TH  Added PSO Toolbar contexts (TFS 50159,50162)
'08Jan13 TH  Added both flavours of Reconcilliation (TFS 50159,51365)

Static LastSectHdr As String

Dim loopvar As Integer
Dim tblwidth As Integer
Dim numofcols As Integer
Dim found As Integer
Dim numofsegs As Integer
Dim colwidth As Integer         '31Mar04 CKJ added type declaration
Dim colformat As Integer
Dim displaytxtbox As Integer
Dim displaygauge As Integer
Dim displaylist As Integer
Dim hdrline As String, widthline As String, lineformat As String, columntypeline As String
Dim heading As String
Dim prompt As String
Dim gridtxt As String
Dim lbltext As String
Dim lngpanleWidth As Long
Dim intExtraWidth As Integer
Dim sglColModifier As Single
Dim StrSectionHdr As String


   setPSO (IIf(UCase(SectionHdr$) = "BLANK", False, blnPSO))

   ''sglColModifier = Val(txtd$(dispdata$ + "\winord.ini", "", "1", "ColumnModifier", found))
   MainScreen.lvwMainScreen.Width = 0 '11Oct05 th added
   sglColModifier = Val(terminal("ColumnModifier", "1"))

   ReDim ODisplayColWidths(OTblMaxCols)   '23Dec97 Removed Preserve statement

   MainScreen.LstDisplay.Visible = False
   MainScreen.TxtInput.text = ""
   MainScreen.m_LastColumnSorted = 0      ' 22Jul11 XN Clear sort order on main grid MainScreen.m_LastColumnSorted (F0102524), (F0102526), (F0102527)

   'MainScreen.Caption = SectionHdr                 'Debug only: use to find the section header
      
   'check to see if section header is same as last used
   If UCase$(SectionHdr$) <> UCase$(LastSectHdr$) Then
      HeaderDisplay MainScreen, MainScreen.lvwMainScreen, Remove, 50
      MainScreen.lvwMainScreen.Visible = False
      BlankOrderInfoScreens

      'read the number of columns
      numofcols = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "noofcols", found))
   
      'resize array to be correct size
      If numofcols > 0 Then
         ReDim colheadings(1 To numofcols) As String
         ReDim OColumnType(1 To numofcols) As String
      Else
         ReDim colheadings(1) As String
         ReDim OColumnType(1) As String
      End If
      
      'Make text box and label invisible
      MainScreen.LblInput.Visible = False
      MainScreen.LblGrid.Caption = ""
      MainScreen.TxtInput.Visible = False
      MainScreen.FrmGauge.Visible = False
      MainScreen.Progress.Visible = False
      MainScreen.LstDisplay.Visible = False
      MainScreen.lvwMainScreen.ListItems.Clear

      'set column headings and widths for each column
      MainScreen.lvwMainScreen.View = lvwReport
      MainScreen.lvwMainScreen.ListItems.Clear
      MainScreen.lvwMainScreen.ColumnHeaders.Clear
      tblwidth = 0
      
      If numofcols > 0 Then
         For loopvar = 1 To numofcols
            hdrline$ = "heading" + Trim$(Str$(loopvar))
            widthline$ = "width" + Trim$(Str$(loopvar))
            lineformat$ = "format" + Trim$(Str$(loopvar))
            columntypeline$ = "type" + Trim$(Str$(loopvar))
            heading$ = TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", hdrline$, found)
            'SQL MainScreen.lvwMainScreen.ColumnName(loopvar) = heading$
            colwidth = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", widthline$, found))
            colwidth = colwidth * sglColModifier
            'SQL MainScreen.lvwMainScreen.ColumnWidth(loopvar) = colwidth
            colformat = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", lineformat$, found))
''                  If colformat = 0 Then
''                        'SQL MainScreen.lvwMainScreen.ColumnStyle(loopvar) = 1
''                     Else
''                        'SQL MainScreen.lvwMainScreen.ColumnStyle(loopvar) = colformat
''                     End If
            tblwidth = tblwidth + (colwidth * 80)
            OColumnType(loopvar) = LCase$(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "text", columntypeline$, found))   '06Jul11 CKJ added lcase()
            MainScreen.lvwMainScreen.ColumnHeaders.Add , "H:" & Format$(loopvar), heading$, (colwidth * 80)
            If loopvar > 1 And OColumnType(loopvar) <> "text" Then                           '06Jul11 CKJ added ////
               MainScreen.lvwMainScreen.ColumnHeaders(loopvar).Alignment = lvwColumnRight    '   "
            End If
         Next
         MainScreen.lvwMainScreen.GridLines = True
         'MainScreen.lvwMainScreen.ColumnHeaders.item.Alignment = lvwColumnCenter
         '&H80000002&
         'Move the TrueGrid to the Centre of the Picture Box
         MainScreen.lvwMainScreen.Top = (MainScreen.PicLayout.ScaleHeight / 2) - (MainScreen.lvwMainScreen.Height / 2)
         'MainScreen.lvwMainScreen.top = (MainScreen.PicLayout.ScaleHeight / 1.5) - (MainScreen.lvwMainScreen.Height / 1.5)
         MainScreen.lvwMainScreen.Left = (MainScreen.PicLayout.ScaleWidth / 2) + (MainScreen.lvwMainScreen.Width / 2)
      End If
         
      'set width of the form
      If numofcols > 0 Then
         ''intExtraWidth = 270
         MainScreen.lvwMainScreen.Width = tblwidth + 80 '' intExtraWidth ''+ 80 ''+ intExtraWidth '   "    TH Added to compensate for scrollbar in wardstocks (#51039)
         'centre table within form
         MainScreen.lvwMainScreen.Left = (MainScreen.ScaleWidth - MainScreen.lvwMainScreen.Width) / 2
      End If
      
      If numofcols > 0 Then
         HeaderDisplay MainScreen, MainScreen.lvwMainScreen, Create, 50
      Else
         HeaderDisplay MainScreen, MainScreen.lvwMainScreen, Remove, 50
      End If

      'read the number of segments from the ini file
      numofsegs = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "nooflabels", found))
   
      'allocate enough space for the help labels
      If numofsegs > 0 Then
         MainScreen.LblHelpPrompt.Visible = True
      End If

      'display text box if appropriate
      displaytxtbox = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "TxtBoxVisible", found))
      If displaytxtbox = True Then
         MainScreen.TxtInput.Left = (Screen.Width / 2) '- (MainScreen.TxtInput.Width / 2)
         MainScreen.TxtInput.Top = MainScreen.lvwMainScreen.Top + MainScreen.lvwMainScreen.Height + 200
         lbltext$ = MainScreen.LblInput.Caption
         MainScreen.LblInput.Left = MainScreen.TxtInput.Left - txtwidth(MainScreen.LblInput, lbltext$) - 200
         MainScreen.LblInput.Top = MainScreen.TxtInput.Top
         MainScreen.LblInput.Visible = True
         MainScreen.TxtInput.Visible = True
      End If

      'display gauge if appropriate
      displaygauge = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "ProgressGaugeVisible", found))
      If displaygauge = True Then
         CentreControl MainScreen.FrmGauge, MainScreen
         MainScreen.FrmGauge.Visible = True
         MainScreen.Progress.Visible = True
      End If

      'display listbox if appropriate
      displaylist = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "LstBoxVisible", found))
      If displaylist = True Then
         CentreControl MainScreen.LstDisplay, MainScreen
         MainScreen.LstDisplay.Clear            '23Dec97 EAC clear list before display
         MainScreen.LstDisplay.Visible = True
      End If

      'save the Section Header name
      LastSectHdr$ = SectionHdr$
   End If 'sectionhdr$ <> LastSectHdr$

   If Storepasslvl = 0 And WardStockPasslvl = 0 Then
      SetToolBarView MainScreen, "NoPass"
   Else
      If Right$(UCase$(SectionHdr$), 3) = "PSO" Then '28Nov12 TH PSO (TFS 50159) Set toolbars correctly for PSO
         SetToolBarView MainScreen, Left$(SectionHdr$, Len(SectionHdr$) - 3)
      Else
         SetToolBarView MainScreen, SectionHdr$
      End If
   End If

   MainScreen.lvwMainScreen.Checkboxes = False
   'Set Tool bar contexts appropriately
   Select Case UCase(SectionHdr$)                                             '09Nov99 AE Added to allow buttons to work
      'Case "MAIN", "RECEIVE GOODS", "WARDSTOCKLIST", "ISSUE PICKING", "RECEIVE GOODSPSO" '28Nov12 TH Added PSO (TFS 50159,50162)
      Case "MAIN", "RECEIVE GOODS", "WARDSTOCKLIST", "ISSUE PICKING", "RECEIVE GOODSPSO", "RECONCILE", "RECONCILEPSO" '08Jan13 TH Added both flavours of Reconcilliation (TFS 50159,50162,51365)
         SetToolBarcontext 1
         SetToolBarLinkCntrl MainScreen.lvwMainScreen
                                                                             
      Case "AMEND", "AMENDPSO" '28Nov12 TH Added PSO (TFS 50159)
         SetToolBarcontext 1
         SetToolBarLinkCntrl MainScreen.lvwMainScreen
         ''MainScreen.lvwMainScreen.Checkboxes = True
      Case "BLANK", "AUTOMATIC ORDERS", "WSPRINTING"
         SetToolBarcontext 0                                                  'reset to default
         SetToolBarLinkCntrl Nothing
      End Select

   'display title for grid if appropriate
   gridtxt$ = Trim$(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "GridTitle", found))
   If Trim$(gridtxt$) <> "" Then
      MainScreen.LblGrid.Caption = gridtxt$
      PositionLblGrid
   End If
   
   For loopvar = 1 To 10
      MainScreen.LblHelpPrompt.Panels(loopvar).Visible = False
   Next
   StrSectionHdr = SectionHdr$
   Select Case UCase(SectionHdr$)
      Case "RECEIVE GOODS"
         If Edittype = -3 And (Val(TxtD$(dispdata$ + "\winord.ini", "Supplementary Orders", "", "nooflabels", found)) > 0) Then SectionHdr$ = "Supplementary Orders"
      End Select
   
   numofsegs = Val(TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", "nooflabels", found))
   If numofsegs > 0 Then
      lngpanleWidth = MainScreen.Width / numofsegs
      For loopvar = 1 To numofsegs
         hdrline$ = "label" + Trim$(Str$(loopvar))
         prompt$ = TxtD$(dispdata$ + "\winord.ini", SectionHdr$, "", hdrline$, found)
         MainScreen.LblHelpPrompt.Panels(loopvar).text = prompt$
         MainScreen.LblHelpPrompt.Panels(loopvar).Visible = True
         MainScreen.LblHelpPrompt.Panels(loopvar).Width = lngpanleWidth
      Next
   End If
   SectionHdr$ = StrSectionHdr

   If numofcols > 0 Then
      MainScreen.lvwMainScreen.Visible = True
      Select Case UCase$(SectionHdr$)
         Case "AMEND", "MAIN", "RECEIVE GOODS", "ISSUE PICKING", "RECONCILE", "AMENDPSO", "RECEIVE GOODSPSO", "RECONCILEPSO" '30Aug12 TH Added PSO (TFS 42771,42773,51365)
            'Display the new infopanels
            'Size picinfo1
            MainScreen.PicInfo1.Left = MainScreen.lvwMainScreen.Left
            MainScreen.PicInfo1.Width = (MainScreen.lvwMainScreen.Width - 200) / 2
            MainScreen.PicInfo1.Top = (MainScreen.lvwMainScreen.Top + MainScreen.lvwMainScreen.Height + 700)
            MainScreen.PicInfo1.Height = 400
                        
            'Size picinfo2
            MainScreen.PicInfo2.Left = MainScreen.lvwMainScreen.Left + (MainScreen.lvwMainScreen.Width / 2) + 100
            MainScreen.PicInfo2.Width = (MainScreen.lvwMainScreen.Width - 200) / 2
            MainScreen.PicInfo2.Top = (MainScreen.lvwMainScreen.Top + MainScreen.lvwMainScreen.Height + 700)
            MainScreen.PicInfo2.Height = 400
         Case Else
            BlankOrderInfoScreens
         End Select
   End If
   
   '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
   If TrueFalse(TxtD(dispdata$ & "\mechdisp.ini", "Common", "Y", "CloseLinkOnStateChange", 0)) Then IPLinkShutdown
   
End Sub

Sub CheckExitVal(exitval%, findrecnum%, drug$, recnum&)
'10Dec97 EAC Ensure d.outstanding is updated in NSVworths
'15Dec97 CKJ/EAC picking ticket issue from WSlist now writes 'S' type transaction
'29Dec97 EAC Use Stores drug description
'02Feb98 EAC Correct F7 issue all when Printing Ward requisitions in packs
'12Feb98 EAC/CKJ Prevent Issueing into negative if appropriate during F7 issue all
'13Feb98 CKJ corrected above mod
'26Mar98 CFY Fixed problem when using F2 to set the QTY = ToFollow which sometimes an error
'            because the file pointer was not being set correctly.
'25Jun98 EAC prevent rounding error when issueing.
'29Jan99 TH  Code to Allow manually entered price of zero to be received when receiving all
'22Feb99 TH  set auto (to allow for entry of price when receiving all) for call to updateprice
'23Feb99 TH  Use k.escd as flag so as not to reinitialise receive screen
'25Feb99 TH  Added Prompt for batch entry when issue all
'18Jul99 TH  Check Supplier code against supfile to see if change is valid
'12Nov99 TH  Correct mousepointer for batch entry on F7
'12Nov99 TH  Dont receive item if cancelled out of batch entry
'22Nov00 EAC/CY Allow items to marked as in dispute
'15Jan02 TH  Now record date of deletion in recdate to make sure log viewer works correctly with these items (#55167)
'15Jan02 TH  Added time to the orderlog (#53214)
'16May04 TH  Mods to record picking ticket number (enh1549)
'17May05 TH  Added suffix to F2 supplier list (#80169)
'12Nov08 CKJ removed validchars=YNX. superuser facility deprecated since at least 2000 (F0038457)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'06Jul11 CKJ Removed -61 further info - now called directly
'06Jul11 CKJ Removed -64 delete line  - now called directly
'28Jun12 TH  Ensure display is correct after F2 change (TFS 37386)
'16Nov12 TH  No F2 Supplier Swap for PSO and provide suitable msg (TFS 41373)
'25Mar13 TH  Changed spelling on PSO Msg (TFS 59617)
'07Oct13 TH  Pick up stores only products on F7 issue all (TFS F0170257)
'14Nov13 TH  Allow stores only auto issue - F7 (TFS 78048)
'08Jan15 TH  Added mods to ensure Ward Lists are updated from F7 update all (TFS 104036)
'14Jul17 TH  Moved batch recording to preceed translog entry - this ensures batch info against the correct item in log (TFS 189040)

'//// Never called with exitval -105 or -68
'//// Should it be driven by row with marquee or a specified row?

Dim pointer&, cont&, X&
Dim Numoflines%, printedok%, dodeletion%      'deletenow%,
'27Jun11 CKJ removed linnum%
Dim ScreenRow As Long, loopvar%, posn%, FoundSup%
Dim qtyissue!, totalqty!, orderqty! '10Dec97 EAC added orderqty!
Dim issuecost$, ans$, dateord$, daterec$, oldsupcode$, rowline$, override$, temp$, desc$
Dim transtype$
Dim OkToIssue%, showerror%                     '12Feb98 EAC/CKJ added
Dim temp1!, temp2!                              '25Jun98 EAC added
Dim auto As Integer
Dim strTmpdat As String   '09Jan02 TH Added for X types

Dim findPtr As Long, blnFound As Integer  '01Jun02 ALL/ATW
Dim lngFoundSup As Long
Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim strAlternativeSuppliers As String '17May05 TH
Dim lclDrug As DrugParameters

Dim blnAllOneSupplier As Boolean
Dim lngLoop As Integer
Dim strAdditional As String
Dim strDescription As String
Dim lngOrderID As Long
Dim lngBatchWReconcilID As Long '26Oct06 TH
Dim strAns As String    '31May09 TH Added (F0041582)
Dim strMsg As String    '    "
Dim lngOK As Long '28Jun12 TH Added (TFS)

   ReDim Cols$(OTblMaxCols + 1)
   ReDim TmpCols$(OTblMaxCols + 1)
   ReDim lines$(29)                       '//// why 29 alternative suppliers?

   ScreenRow = MainLVWMarqueeRowIndex()   'note - may not be highlighted
   If ScreenRow = 0 Then Exit Sub         'no row selected (or no rows)
   If MainScreen.lvwMainScreen.ListItems(ScreenRow).Selected = False Then Exit Sub  'check it is highlighted
   rowline$ = OInfoStore(ScreenRow)
   deflines rowline$, Cols$(), "|(*)", 1, Numoflines
   If findrecnum And ONumToDisplay > 0 Then
      recnum& = Val(Cols$(OTblMaxCols + 1))
      drug$ = Cols$(1)      '//// not necessarily - edittype 3 : Only used on -64 - probably should remove
   End If

   Select Case exitval
      Case -65                           'Receive whole order or issue whole picking ticket
         Select Case Edittype            '-------------------------------------------------
            Case 3, 6
               If ordernum$ = "A" Then
                  popmessagecr "!n!b", "Cannot process whole order unless number is specified"
                  k.escd = True       '23Feb99 TH Flag so as not to reinitialise receive screen
               Else
                  Screen.MousePointer = HOURGLASS
                  If Edittype = 6 Then
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "6") & _
                                 gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, "") & _
                                 gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                                 gTransport.CreateInputParameterXML("Num", trnDataTypeVarChar, 10, "") & _
                                 gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, Val(ordernum$)) & _
                                 gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                     Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteria", strParams)
                  Else
                     If OrderIncludesBatchTrackItems(Val(ordernum$)) Then  '31May09 TH Added (F0041582)
                        strMsg = TxtD(dispdata$ & "\winord.ini", "ReceiveItem", "You are about to receive an order for which Batch information is required for 1 or more products." & vbCr & "Do you wish to continue ?", "BatchReceiptWarningMessage", 0)
                        askwin "!Batch Receipt", strMsg, strAns, k
                        If strAns <> "Y" Then k.escd = True
                     End If
                     If Not k.escd Then
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3") & _
                                    gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, "") & _
                                    gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                                    gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(ordernum$)) & _
                                    gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, Val(ordernum$)) & _
                                    gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                        Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
                     End If
                  End If
                  If Not k.escd Then
                     If rsOrders.RecordCount > 0 Then
                        Do While Not rsOrders.EOF
                        If Edittype = 3 Then
                           X& = rsOrders!WOrderID
                           ord = FillOrdFromRS(rsOrders, "WOrder")
                        Else
                           X& = rsOrders!WRequisID
                           ord = FillOrdFromRS(rsOrders, "WRequis")
                        End If
                        If ord.status = LTrim$(Str$(Edittype)) Then
                           If Edittype = 3 And Val(ord.num) = Val(ordernum$) And Val(ord.received) > 0 And (Val(ord.cost) > 0 Or Trim$(UCase$(ord.pflag)) = "M") Then
                              Screen.MousePointer = STDCURSOR
                              EnterBatchNo ord, True, ord.received, lngBatchWReconcilID
                              Screen.MousePointer = HOURGLASS
                              If entercostonreceipt$ = "N" Then
                                 auto = True
                              Else
                                 auto = False
                              End If
   
                              If MainScreen.LstDisplay.Tag = "ESC" Then '12Nov99 TH  Dont receive if cancelled out of batch entry
                                 MainScreen.LstDisplay.Tag = ""      '   "
                              Else                                   '   "
                                 receiveitem SiteNumber, ord, ord.received, (X&), auto, 0     '   "
                              End If                                 '   "
                           ElseIf Edittype = 6 And ord.pickno = Val(ordernum$) Then
                              findPtr& = 0                                                                                     '01Jun02 ALL/ATW
                              'findrdrug ord.Code, False, d, findPtr, blnFound, 2, False, False  '!!**why not getdrug
                              findrdrug ord.Code, True, d, findPtr, blnFound, 2, False, False  '14Nov13 TH Allow stores only auto issue (TFS 78048)
                              If findPtr& > 0 Then                               '!!**13Jul99 SF/CFY shouldn't this use found? '01Jun02 ALL/ATW
                                 desc$ = d.DrugDescription 'desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
                                 plingparse desc$, "!"
                                 '@CJ what if sup not found?
                                 getsupplier ord.supcode, 0, 0, sup
                                 OkToIssue = True
                                 showerror = False
                                 If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks Then
                                    If Val(d.stocklvl) < 1! * Val(ord.received) * Val(d.convfact) Then showerror = True
                                 Else
                                    If Val(d.stocklvl) < 1! * Val(ord.received) Then showerror = True
                                 End If
   
                                 If showerror Then
                                    Screen.MousePointer = STDCURSOR
                                    If TrueFalse(TxtD$(dispdata$ & "\patmed.ini", "", "N", "NoNegIssues", blnFound)) Then
                                       popmessagecr "!Aborted Issue", "Could not issue " & d.SisCode & cr & Trim$(desc$) & cr & cr & "Not enough in stock."
                                       OkToIssue = False
                                    Else
                                       popmessagecr "!WARNING", "Insufficient " & desc$ & cr & cr & "Issuing now but Check stock level of " & d.SisCode
                                    End If
                                    Screen.MousePointer = HOURGLASS
                                 End If
   
                                 If UCase$(d.inuse) = "N" Then               '13Feb98 CKJ corrected from <>
                                    Screen.MousePointer = STDCURSOR
                                    popmessagecr "!", "NOT IN USE" & cr & "Issue attempted for " & d.SisCode & cr & Trim$(desc$)
                                    Screen.MousePointer = HOURGLASS
                                    OkToIssue = False
                                 End If
                                                   
                                 If OkToIssue Then                 '12Feb98 EAC/CKJ added check
                                       '!!** should LOCK
                                       If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks Then
                                          If Val(ord.received) = 0 Then
                                             qtyissue! = 0
                                          Else
                                             temp1! = dp!(Val(ord.received) * Val(d.convfact))
                                             temp2! = CLng(dp!(Val(ord.received) * Val(d.convfact)))
                                             If Abs((temp2! - temp1!) / temp1!) < (1 / 1000) Then
                                                qtyissue! = temp2!
                                             Else
                                                qtyissue! = temp1!
                                             End If
                                          End If
                                                               
                                          If Val(ord.outstanding) = 0 Then
                                             totalqty! = 0
                                          Else
                                             temp1! = dp!(Val(ord.outstanding) * Val(d.convfact))
                                             temp2! = CLng(dp!(Val(ord.outstanding) * Val(d.convfact)))
                                             If Abs((temp2! - temp1!) / temp1!) < (1 / 1000) Then
                                                totalqty! = temp2!
                                             Else
                                                totalqty! = temp1!
                                             End If
                                          End If
                                          transtype$ = "P"
                                       Else
                                          qtyissue! = 1! * Val(ord.received)
                                          totalqty! = 1! * Val(ord.outstanding)
                                          transtype$ = "S"
                                       End If
                                       If qtyissue! > 0 Then '2Jun93 CKJ
                                          PutCustOrdNo ord.custordno                '18Apr00 CFY Added
                                          PutPickNo Format$(ord.pickno)           '16May04 TH Added (enh1549)
                                          
                                          '08Jan15 TH Added mods to ensure Ward Lists are updated from F7 update all (TFS 104036)
                                          'put the wardstockline ID
                                          PutWardListID ord.WWardProductListLineID '08Jan15 TH
                                          
                                          TakeStockFromBatch d.SisCode, (qtyissue!), "", "", auto, False '14Jul17 TH Moved here to preceed translog entry - this ensures batch inof against the correct item in log (TFS 189040)
                                       
                                          Translog d, 0, UserID$, "", qtyissue!, (ord.supcode), ord.supcode, ord.num, transtype$, SiteNumber, "P", issuecost$  '15Dec97 CKJ/EAC changed to 'S' for WSlist
                                          
                                          'Clear it
                                          PutWardListID 0 '08Jan15 TH
                                          'Update the wardstockline if appropriate
                                          If ord.WWardProductListLineID > 0 Then UpdateWardStockListIssueData d.SisCode, sup.wardcode, "REQ", CLng(qtyissue!), ord.WWardProductListLineID '08Jan15 TH
                                          
                                          PutPickNo ""                            '16May04 TH Added (enh1549)
                                       End If
                                       issuepick issuecost$, SiteNumber, d, qtyissue!, totalqty!, X&
                                       '!!** should UNLOCK
   
                                       '25Feb99 TH Prompt for batch entry when issue all 'SQL! Check order of process for locking and potential rollback !!!!
                                       'If qtyissue! > 0 Then '25Feb99 TH
                                       '   TakeStockFromBatch d.SisCode, (qtyissue!), "", "", auto, False
                                       'End If
                                    End If
                                 End If
                              End If
                           End If
                           rsOrders.MoveNext
                        Loop
                     End If
                  End If '31May09 TH Added (F0041582)
                  
                  Screen.MousePointer = STDCURSOR
                  
               End If
         End Select
      
'06Jul11 CKJ No longer called this way
'      Case -61     'further info
'         furtherinfo edittype, drug$, recnum&
        
'      Case -105 '16Jul93 CKJ Added           '//// not actually reachable - no calls to -105 exist
'         getorder ord, recnum&, edittype, False  ' (no idx)
'         poporder ord, dispdata$ + " record" + Str$(recnum&)
        
      'Case -64          ' F6 moved to deletesinglerow
    
      Case -60     'F2
         Select Case Abs(Edittype)
            Case 1, 5, 9
               If Not (Edittype = 1 And getPSO()) Then '16Nov12TH No Swap for PSO (TFS 41373)
                  'should this really be allowed for requisition !!** e.g. internal
                  getorder ord, recnum&, Edittype, False   ' (no idx)
                  d.SisCode = ord.Code
                  getdrug d, 0, findPtr&, False   '01Jun02 ALL/ATW
                  temp$ = Trim$(d.altsupcode) 'SQL NEED TO GET LIST !                  '//// not used?
                  strAlternativeSuppliers = GetAltenativeSupplierString(d.SisCode)
                  deflines strAlternativeSuppliers, lines$(), ",", 1, Numoflines '11Feb05 TH Added (#77747)
                  Select Case Abs(Edittype)
                     Case 1: MainScreen.LblGrid.Caption = "Amend Orders"
                     'Case 2: MainScreen.LblGrid.Caption = "Enter/Amend Credits"
                     Case 9: MainScreen.LblGrid.Caption = "Enter/Amend Credits" '02Jan07 TH Replaced above line
                     Case 5: MainScreen.LblGrid.Caption = "Enter/Amend Requisitions"
                  End Select
                  EnhLstFrm.Caption = "Select Alternative Supplier"
                  EnhLstFrm.lblHead = "Code   " & TB & "Name" & Space$(20)
            
                  'add alternate suppliers to list
                  For loopvar = 1 To Numoflines
                     getsupplier lines$(loopvar), 0, lngFoundSup, sup
                     
                     If lngFoundSup > 0 Then
                        '17May05 TH Added section (#80169)
                        If Trim$(LCase$(d.supcode)) = Trim$(LCase$(sup.Code)) Then
                           strAdditional = " (Primary)"
                        Else
                           strAdditional = " (Secondary)"
                        End If
                        EnhLstFrm.LstBox.AddItem sup.Code & TB & sup.name & strAdditional '17May05 TH Added suffix (#80169)
                     End If
                  Next
                        
                  EnhLstFrm.Tag = "1"
                  EnhLstFrm.CmdDropDown.Visible = True
                  EnhLstFrm.CmdDropDown.Enabled = True
                  EnhLstBoxShow
                  
                  If UCase$(Trim$(EnhLstFrm.LstBox.Tag)) = "" Then
                     k.escd = True
                  Else
                     k.escd = False
                     temp$ = EnhLstFrm.LstBox.Tag
                     posn = InStr(temp$, Chr$(9))
                     If posn = 0 Then
                        supcode$ = Trim$(UCase$(temp$))
                     Else
                        supcode$ = Mid$(temp$, 1, posn - 1)
                     End If
                     'Check supcode here
                     getsupplier supcode$, 0, lngFoundSup, sup                                 '18Jul99 TH  Check Supplier code against supfile
                     If lngFoundSup < 1 Then                                                         '  "
                        popmessagecr "!n!b", " Supplier " & supcode$ & " cannot be found "      '  "
                        k.escd = True                                                           '  "
                     End If                                                                     '  "
                  End If
                  Unload EnhLstFrm
                  
                  k.helpnum = 380
                  If Not k.escd Then
                     'OK - now apparently we need the lot, not just an individual line
                     For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
                        'Check is selected
                        If MainScreen.lvwMainScreen.ListItems(lngLoop).Selected Then
                           'Get the order from the screen line
                           deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, 0
                           lngOrderID = Val(Trim$(lines$(OTblMaxCols + 1)))
                           getorder ord, lngOrderID, Edittype, True
                                     
                           'x& = Val(Cols$(OTblMaxCols + 1))
                           'getorder ord, recnum&, edittype, True  '<----LOCK  (no idx)
                           oldsupcode$ = ord.supcode
                           ord.supcode = supcode$
                           recnum& = PutOrder(ord, lngOrderID, GetTableName(Edittype))                 '<----UNLOCK (no idx)
                           If Trim$(UCase$(oldsupcode$)) <> Trim$(UCase$(supcode$)) Then osite$ = "A" '(#77747)
                           'update screen
                           'We need to find out if this item is oncontract for this supplier
                           lclDrug.SisCode = ord.Code
                           getdrugsup lclDrug, 0, 0, False, supcode$
                           If Trim$(lclDrug.contno) <> "" Then
                              lines$(8) = "C"
                           Else
                              lines$(8) = ""
                           End If
                           lines$(6) = Trim$(supcode$)
                           OInfoStore(lngLoop) = Cols$(1)
                           For loopvar = 2 To OTblMaxCols + 1
                              OInfoStore(lngLoop) = OInfoStore(lngLoop) & "|" & lines$(loopvar)          '//// caution if we change the array composition
                           Next
                        End If
                     Next
                     
                     '02Mar05 TH Added section
                     blnAllOneSupplier = False
                     If osite$ = "A" And (Edittype = 1 Or Edittype = 9) Then
                        'Check through the lot (except the changed line) and see if we now have everything for just one supplier
                        blnAllOneSupplier = True
                        For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
                           If lngLoop <> ScreenRow Then
                              rowline$ = OInfoStore(lngLoop)
                              deflines rowline$, TmpCols$(), "|(*)", 1, Numoflines
                              If Trim$(UCase$(supcode$)) <> Trim$(UCase$(TmpCols$(6))) Then
                                 blnAllOneSupplier = False
                                 Exit For
                              End If
                           End If
                        Next
                     End If
                     If blnAllOneSupplier Then
                        osite$ = supcode$
                        Select Case Abs(Edittype)
                           Case 9:    MainScreen.LblGrid.Caption = "Enter/Amend Credits to Supplier " & Trim$(osite$)
                           Case 5:    MainScreen.LblGrid.Caption = "Enter/Amend Requisitions for " & Trim$(osite$)
                           Case Else: MainScreen.LblGrid.Caption = "Amend Orders to Supplier " & Trim$(osite$)
                           End Select
                     End If
                                                
                     If MainScreen.lvwMainScreen.SelectedItem.Index > 0 Then
                        RefreshLVWMainScreen True, False
                        UpdatePanels ord, Edittype '01Jun05 TH Added
                     End If
                  End If
                  k.escd = False
               Else   '16Nov12 TH PSO (TFS 41373)
                  'popmessagecr "Patient Specif Ordering", "Changing supplier is not available for a patient specific order"
                  popmessagecr "Patient Specific Ordering", "Changing supplier is not available for a patient specific order" '25Mar13 TH Changed spelling (TFS 59617)
               End If
            Case 3 'Reset qty to receive
               If Edittype < 0 Then
                  'Not available on supplemental orders
               Else
                  If ordernum$ = "A" Then
                     popmessagecr "!n!b", "Cannot process unless order number is specified"
                     k.escd = True
                  Else
                     ans$ = "N"
                     k.helpnum = 0 '!!**
                     k.escd = False
                     Confirm "?Prepare to follows for automatic receive", "make receive quantity the same as outstanding", ans$, k
                  
                     If ans$ = "Y" And Not k.escd Then
                        Screen.MousePointer = HOURGLASS
                        X& = Val(Cols$(OTblMaxCols + 1)) '26Mar98 CFY
                        getorder ord, X&, Edittype, False
                        If ord.status = "3" And Val(ord.num) = Val(ordernum$) And Val(ord.received) = 0 Then
                           If Trim$(ord.internalsiteno) = "" And Trim$(ord.internalmethod) = "" Then
                              getorder ord, X&, Edittype, True    ' (no idx)
                              ord.received = ord.outstanding
                              'x& = PutOrder(ord, x&, GetTableName(edittype))
                              lngOK = PutOrder(ord, X&, GetTableName(Edittype)) '28Jun12 TH Replaced (TFS 37386)
                              
                              '11Jul11 CKJ Moved block inside call to CheckExitVal() to avoid duplication
                              'CurRow& = MainScreen.lvwMainScreen.SelectedItem.Index
                              'deflines OInfoStore(CurRow&), lines$(), "|(*)", 1, Numoflines
                              'orderptr& = Val(lines$(OTblMaxCols + 1))
                              'getorder ord, orderptr&, Abs(edittype), False
                              AddLineToDisplay Edittype, X&, 0, ScreenRow, sup.ptn, False '17sep10 TH Added param (F0096592)
                              RefreshLVWMainScreen True, False

                           Else
                              k.escd = True
                           End If
                        End If
                        Screen.MousePointer = STDCURSOR
                     End If
                  End If
               End If
            Case Else
               popmessagecr "", "Cannot change supplier after order placed"
         End Select
   
      'Case -63       'Urgency code or In Dispute flag   11Jul11 CKJ Moved to separate proc ActionF5Key
        
'      Case -68    '//// not actually reachable, no calls to -68 exist
'         If edittype = 3 And ordernum$ <> "A" Then '!!** AND Storepasslvl = 8 THEN   ' add to order
'            AddToOrder drug$, SiteNumber
'            k.escd = False
'         End If
   End Select

   'If findrecnum Then : printorder OrderNum$, 0, indexpos&, endoffile%, pagenum, OASCcode$(), ORecno&()

End Sub

Sub ActionKeyF5(ByVal Edittype As Integer)
'11Jul11 CKJ Moved from CheckExitVal to simplify
'            Currently handles setting Urgency Code and the In-Dispute Flag

Dim ScreenRow As Long
Dim rowline As String
Dim Numoflines As Integer
Dim recnum As Long
Dim ans As String
Dim loopvar As Integer
Dim Cols(OTblMaxCols + 1) As String

   Select Case Edittype
      Case 1, 4, -4, 5
         ScreenRow = MainLVWSingleSelectedItemIndex()
      Case Else
         popmessagecr "#", "Please select an item"
      End Select

   If ScreenRow = 0 Then Exit Sub
   
   rowline$ = OInfoStore(ScreenRow)
   deflines rowline$, Cols$(), "|(*)", 1, Numoflines
   recnum& = Val(Cols$(OTblMaxCols + 1))

   If Edittype = 1 Or Edittype = 5 Then        'Enter Urgency code
      getorder ord, recnum&, Edittype, False   ' (no idx)
      setinput 0, k
      k.helpnum = 382
      k.Max = 1
      ans$ = "U"
      InputWin "Urgency", "Enter Urgency code ", ans$, k
      If Not k.escd Then
         getorder ord, recnum&, Edittype, True  '<----LOCK  (no idx)
         ord.urgency = ans$
         recnum& = PutOrder(ord, recnum&, GetTableName(Edittype))                   '<----UNLOCK (no idx)
         'update screen    '//// consider alternative
         Cols$(2) = Trim$(ans$)
         OInfoStore(ScreenRow) = Cols$(1)
         For loopvar = 2 To OTblMaxCols + 1
            OInfoStore(ScreenRow) = OInfoStore(ScreenRow) & "|" & Cols$(loopvar) '//// caution if we change the array composition
         Next
         RefreshlvwMainScreenRow ScreenRow, False     '11Jul11CKJ was RefreshLVWMainScreen True, False which put cursor to row 1
      End If
      k.escd = False
   End If
   
   '22Nov00 EAC/CY Added      'Set In Dispute Flag
   If Abs(Edittype) = 4 Then
      If ordernum$ <> "A" Then
         getorder ord, recnum&, Edittype, True  '<----LOCK  (no idx)
         If Trim$(ord.Indispute) = "" Then
            ord.Indispute = "Y"
         Else
            ord.Indispute = " "
         End If
         ord.invnum = invoicenum$
         ord.IndisputeUser = UserID$            'record the last user to make a change
         recnum& = PutOrder(ord, recnum&, GetTableName(Edittype))                '<----UNLOCK (no idx)
               
         'Cols$(OTblMaxCols) = ord.Indispute    '07Jan10 CKJ Corrected to allow addition of robot flag column
         Cols$(8) = ord.Indispute               '            InDispute is not automatically the last column, but is fixed by code in column 8     (F0030035)
         OInfoStore(ScreenRow) = Cols$(1)
         For loopvar = 2 To OTblMaxCols + 1
            OInfoStore(ScreenRow) = OInfoStore(ScreenRow) & "|" & Cols$(loopvar) '//// caution if we change the array composition
         Next
         RefreshlvwMainScreenRow ScreenRow, False
      Else
         popmessagecr "#", Iff(Edittype > 0, "Order", "Credit Note") & " Number must be entered to set Dispute Status"
      End If
   End If
            
End Sub

Sub DeleteSingleRow(ByVal recnum As Long, drug$)
'11Jul11 CKJ Moved from CheckExitVal -64 & simplified.
'            Now requires a record number for deletion of a single order
'16Jul12 TH  Changed DLO deletion Msg (TFS 38663)
'13Mar13 TH  Get drug for description for msg box text  (TFS 58674)

Dim txed%, printedok%, dodeletion%
Dim ans$, dateord$, daterec$, override$
Dim orderqty!, strTmpdat As String
Dim strDescription As String
Dim blnDLO As Boolean
Dim strParams As String  '28Jun12 TH DLO
Dim lngResult As Long '28Jun12 TH DLO
Dim lclDrug As DrugParameters
Dim strDesc As String
Dim lngFound As Long


   If recnum& > 0 Then
      k.escd = False
      If Edittype = 1 Or Edittype = 5 Or Edittype = 9 Then '!!** what log type for 9?
         ans$ = "Y"
         If Edittype = 5 Then
            ans$ = "N"
            getorder ord, recnum&, Edittype, False  '26Aug05 TH Added to get correct Description (#82442)
            LookupDrug ord.Code, d, 0               '    "
            strDescription = d.DrugDescription 'strDescription = GetStoresDescription() XN 4Jun15 98073 New local stores description
            plingparse strDescription, "!"
            Confirm "DELETING", "delete requisitioned item " & Trim$(strDescription) & "  ", ans$, k
         End If
         
         If ans$ = "Y" And Not k.escd Then
            getorder ord, recnum&, Edittype, True   '<-LOCK record for deletion (no idx)
            ord.status = "D"
            recnum& = PutOrder(ord, recnum&, GetTableName(Edittype))                  '<-UNLOCK & replace record  (del idx)
            LookupDrug ord.Code, d, 0  '(found) '14Jan94 CKJ Added '01Jun02 ALL/ATW
            If Edittype = 5 Then
               getsupplier Trim$(ord.supcode), 0, 0, sup
               If (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then
                  orderqty! = (Val(ord.outstanding) / Val(d.convfact)) * -1
               Else
                  orderqty! = Val(ord.outstanding) * -1
               End If
               updateoutstanding orderqty!, d
            End If
            Select Case ord.internalmethod
               Case "I", "M"
                  strTmpdat = thedate(False, True)        '08Jan02 TH Add time to log
                  strTmpdat = strTmpdat & thedate(0, -2)  '   "
                  'Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, "", "", ord.supcode, "X", sitenumber, "", d.vatrate '14Jan94 CKJ VAT   '15Jan02 TH No record date of deletion in recdate to make sure
                  'Orderlog ord.num, ord.Code, UserID$, ord.orddate, strTmpdat, ord.outstanding, "", "", ord.supcode, "X", SiteNumber, "", d.vatrate, "", "", "" '14Jan94 CKJ VAT       '   "       log viewer works correctly with these items (#55167)
                  'Orderlog ord.num, ord.Code, UserID$, ord.orddate, strTmpdat, ord.outstanding, "", "", ord.supcode, "X", SiteNumber, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                  Orderlog ord.num, ord.Code, UserID$, ord.orddate, strTmpdat, ord.outstanding, "", "", ord.supcode, "X", SiteNumber, "", d.vatrate, "", "", "", "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
               End Select '!!** log if requis? No
         End If
         
      Else  '--------------Delete order already raised        edittypes 3 & 6
         If Storepasslvl >= 6 Then  'Was = 8 ASC 31Aug93
            ans$ = "N"
            setinput 0, k
            
            lclDrug.SisCode = drug$
            lngFound = 0
            getdrug lclDrug, 0, lngFound, False
            If lngFound > 0 Then
               'strDesc = lclDrug.storesdescription     XN 4Jun15 98073 New local stores description
               'If Trim$(strDesc) <> "" Then strDesc = lclDrug.Description
                           strDesc = lclDrug.DrugDescription
               plingparse strDesc, "!"
            Else
               strDesc = ""
            End If
            
            Confirm "Confirm Deletion", "delete " & Trim$(drug$) & IIf(Len(Trim$(strDesc)) > 0, " (" & Trim$(strDesc) & ")", "") & " from order", ans$, k      '//// review sequence - prints then may not delete
            
            If ans$ = "Y" And Not k.escd Then
               If PrintCanceledOrder$ = "Y" Then
                  printedok = Printcancellation(recnum&, Edittype)
               Else
                  printedok = True
               End If
               
               If printedok Then
                  getorder ord, recnum&, Edittype, True         '<-LOCK record for deletion (no idx)
                  txed = (Val(ord.outstanding) + Val(ord.received) > Val(ord.qtyordered) And ord.internalmethod = "I") ' T/F
                  dodeletion = True
                  If txed Then
                  
                     If Storepasslvl <> 9 Then
                        popmessagecr "!n!b", "Cannot delete: already issued from store"      '11Jul11 CKJ Moved inside IF
                        dodeletion = False
                     Else
                        setinput 0, k
                        k.escd = False
                        askwin "Delete Transmitted Internal Order", "Are you sure you want to override the system and delete this order?", override$, k   '//// worth logging?
                        If Trim$(UCase$(override$)) = "Y" And Not k.escd Then
                           dodeletion = True
                        Else
                           dodeletion = False
                        End If
                     End If
                  End If
                  
                  'DLO Check here
                  If ord.DLO Then
                     setinput 0, k
                        k.escd = False
                        'askwin "Delete Direct Location Order", "This is a Direct Location Order. Are you sure you wish to delete this order." & crlf & "If you continue you will also delete any associated pending orders." & crlf & "Any associated receipts will not be automatically issued.", override$, k  '//// worth logging?
                        '16Jul12 TH Replaced above (TFS 38663)
                        d.SisCode = ord.Code     '13Mar13 TH Added  (TFS 58674)
                        getdrug d, 0, 0, False   '     "
                        strDescription = d.DrugDescription 'strDescription = GetStoresDescription()  XN 4Jun15 98073 New local stores description
                        plingparse strDescription, "!"
                        askwin "Delete Direct Location Order", Trim$(strDescription) & " is a DLO item" & crlf & crlf & "If you continue you will also delete any associated pending orders" & crlf & crlf & "If you continue you will also delete any associated pending orders." & crlf & "Any associated receipts will not be automatically issued", override$, k '//// worth logging?
                        '16Jul12 TH End
                        
                        If Trim$(UCase$(override$)) = "Y" And Not k.escd Then
                           dodeletion = True
                        Else
                           dodeletion = False
                        End If
                  End If
                                               
                  If dodeletion Then
                     ord.status = "D"
                     If Edittype = 6 Then '1Jun93 CKJ  'ASC/CKJ ? should this be 7 ?!!** No I dont think so - since issue picking tickets is edittype 6
                        d.SisCode = ord.Code
                        getdrug d, 0, 0, False
                        getsupplier Trim$(ord.supcode), 0, 0, sup
                        If (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then
                           orderqty! = (Val(ord.outstanding) / Val(d.convfact)) * -1
                        Else
                           orderqty! = Val(ord.outstanding) * -1
                        End If
                        updateoutstanding orderqty!, d
                     End If
                  End If
                  
                  recnum& = PutOrder(ord, recnum&, GetTableName(Edittype))                        '<-UNLOCK record and replace with last record (del idx)
                  If txed And dodeletion Then  ' ans$="X" superuser level
                     popmessagecr "!n!bWARNING", "Item which was issued from the Store has now been deleted"
                  End If
                  
                  dateord$ = thedate(False, True)  '03May98 CKJ Y2K
                  dateord$ = dateord$ & thedate(0, -2)    '15Jan02 TH Added time to the log (#53214)
                  LookupDrug ord.Code, d, 0 '  (found) '01Jun02 ALL/ATW
                  '!!** date deleted should be daterec and leave orderdate alone
                  'Orderlog ord.num, ord.Code, UserID$, dateord$, daterec$, ord.outstanding, "", ord.cost, ord.supcode, "N", SiteNumber, "", d.vatrate, "", "", "" '14Jan94 CKJ VAT  not type N for del requis
                  'Orderlog ord.num, ord.Code, UserID$, dateord$, daterec$, ord.outstanding, "", ord.cost, ord.supcode, "N", SiteNumber, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                  Orderlog ord.num, ord.Code, UserID$, dateord$, daterec$, ord.outstanding, "", ord.cost, ord.supcode, "N", SiteNumber, "", d.vatrate, "", "", "", "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                  If dodeletion And ord.DLO Then
                     '22Jun12 TH Here we need to remove any pending (Status 1) orders for this DLO
                     'Do by cached pickno,qty , DLO flag, Siscode, may need new sp. then set status "D"
                     '28Jun12 TH
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1") & _
                                 gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, ord.Code) & _
                                 gTransport.CreateInputParameterXML("Qty", trnDataTypeVarChar, 13, CStr(dp!(orderqty! * -1))) & _
                                 gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, ord.pickno)
                     lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWOrderDeleteFromDLO", strParams)
                     'orderqty!
                  
                  End If
               End If
            End If
         Else
            nopass
         End If
         k.escd = False
      End If
   End If
   
End Sub

Sub Clearprintedorders()

   ONumToDisplay = 0
   ' SQL
   MainScreen.lvwMainScreen.ListItems.Clear
   ''ReDim OInfoStore(1) 'SQLOCT
   '//// sets onumtodisplay but leaves array - bad when used with UBound(OInfoStore)
   
   OrderStartPos& = 0

End Sub

Sub DisplayOrders(Edittype As Integer, ByVal blnPSO As Boolean)
'21May92 CKJ Added k.decimals to Amend/Add
'uses edittypes 1 3 5 6 9
'!!** paydate & invoicenum need to be displayed

'{SP2} most params are not actually used - either use them or delete them
'01Jun11 CKJ Added as integer to edittype param
'27Jun11 CKJ Params list was DisplayOrders(ordernum$, edittype As Integer, site$, sitepaths%, paydate$, invoicenum$, OASCcode$(), ORecNo&(), Oordering$())
'            removed all unused params, allowing removal of global arrays & variables.
'            Note that paydate$ & invoicenum$ are already global, and not passed as params from here
'            EditType is also global, but could theoretically be overridden. Except it hasn't been.
'14Aug12 TH  Added PSO flag Parameter
'03Sep12 TH  Extensive PSO Support for Reconcil screens (TFS 42773)

   Select Case Abs(Edittype)
      Case 1: ChangeTable "Amend" & Iff(blnPSO, "PSO", ""), blnPSO
      Case 10: ChangeTable "Amend", blnPSO
      Case 9:     ChangeTable "Main", blnPSO
      Case 3:     ChangeTable "Receive Goods" & Iff(blnPSO, "PSO", ""), blnPSO
      Case 5, 6:  ChangeTable "Issue Picking", blnPSO
      Case 4:     ChangeTable "Reconcile" & Iff(blnPSO, "PSO", ""), blnPSO
      End Select
    
   Printorder 0, blnPSO '03Sep12 TH Added PSO Support (TFS 42773,42771)'0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
   
   If ONumToDisplay > 0 Then
      ' SQL MainScreen.lvwMainScreen.RowIndex = 1
      'If (MainScreen.TxtInput.Visible) Or (edittype = 4) Then
      '   MainScreen.lvwMainScreen.Visible = True
      '   MainScreen.lvwMainScreen.SetFocus
      'End If
      If (MainScreen.TxtInput.Visible) Then MainScreen.lvwMainScreen.SetFocus
   End If

End Sub

Sub Editord(ByRef drug$, newaddition%, ByRef partorder As Integer, ByRef WOrderID As Long, ByVal SelectedOrder As Long, ByVal blnFromlstView As Boolean)
'10Dec97 EAC ensure that d.outstanding is updated in NSVworths
'29Dec97 EAC Use Stores drug description
'05Mar98 ASC Now displays items from non preferred supplier on current order.
'23Jun98 EAC added dp! to prevent e numbers occuring when calculating order qty
'30Jun99 CFY Added call to getdrugsup
'01Mar00 TH  Added CreatedUser to Requisition for information screens
'18Apr00 CFY Stores customers own order number against order line for requisition items.
'19Jul00 JN  Event 45634 - stores order quantity (ord.qtyordered) now properly stored when amending an order
'11Aug00 JN  Event 45634 - makes ord.received reflect ord.outstanding so cost changes when order qty changes
'07Feb00 AW  Event 49273 - change exponential to standard number
'01Sep01 TH  Replaced parameter in call to checktofollows (#52924)
'14Jan02 TH  Added check on alternative suppliers so that if item is available from alt sup the user is not
'    "       prompted to change to default sup. (#57732)
'16Jan02 TH  Added code to allow for change to default supplier on edit of status 1 orders (#51913)
'13Feb02 TH  If the addition or amendment of a requisition is aborted from checklevels the specific record is now
'    "       unlocked correctly and marked as deleted in the case of a new req. before exiting (#59023)
'10May02 SF  now strores the location code in the order (enh#1555)
'21May02 SF added additional dummy parameter to EditAmend: (enh#1371)
'05Sep02 SF now allows cancelling out of amend orders when checking for preferred supplier (event #61536)
'02Oct06 TH Added check to prevent BNF search firing on blank search string (as there is no BNF search anymore) (SC-06-0768)
'13Apr10 TH Ported and converted (F0044679) 02Jul08 TH We need to check if this is already on order for the default supplier. If it is we warn and leave (F0020068)
'11Dec12 TH Added param to allow different checks if from lstview
'05Aug13 TH Use actual Requisiton Number on req search - otherwise if there are multiple lines on diff reqs this will lead to
'           problems editing and duplication (TFS 70742)
'07Aug13 TH Fix missing prefix on IO call (TFS 70916)
'29Jul15 TH Dont use requisition num to look up on anything other than initial PT (TFS 72776)


Dim newdrug%, amendrequis%, numofouters%, errored%, findsup%, FoundSup%    'found, '01Jun02 ALL/ATW  '27Jun11 CKJ removed linnum%
Dim pointer&
Dim desc$, ordqty$, price$, retcode$
Dim orderqty!       '10Dec97 EAC added
Dim ans$, MakeThisSupplier% '05Mar98 ASC/EAC
Dim unitsordered$    '19Jul00 JN Added
Dim blnChangetoDefaultSup As Integer '16Jan02 TH Added for change on edit  (#51913)
Dim intAltSups As Integer, intloop As Integer '14Jan02 TH Added (#57732)
ReDim strAltSups(10) As String                '   "
Dim lngFoundSup As Long
Dim strParams As String
Dim strTemp As String
Dim strDescription As String

Dim blnFound As Integer   '01Jun02 ALL/ATW
'V93
Dim strSql As String
'Dim oDataAccess    As clsDataAccess
Dim rsOrders    As ADODB.Recordset
Dim strTable As String
'V93------
Dim strCode As String
Dim strNum As String
Dim strSupCode As String
Dim lngPickno As Long
Dim strStatus As String
'Dim strCode As String
Dim lclsup As supplierstruct
Dim strDesc As String
Dim strMsg As String
Dim lngPreselectedrow As Long
Dim sglOutstanding As Single
Dim rsOrderCheck As ADODB.Recordset '14Apr10 Th Added (F)
                              
   strCode = ""
   strNum = ""
   strSupCode = ""
   lngPickno = 0
   strStatus = ""
   notyetordered = 0  '27Sep04 TH Added
   
   If k.exitval = 13 Or (k.exitval = -66 And Edittype = 6) Then   'if return pressed after drug code entered      '//// can get here with no drug code input box
      If InStr(drug$, Chr(160)) > 0 Then
         If (Edittype = 3 Or Edittype = 1) Then  '088Nov05 TH This is too hacky - should just send in the linenumber if we are going to use this !!!!
            lngPreselectedrow = Val(Trim$(Right$(drug$, (Len(drug$)) - (InStr(drug$, Chr(160))))))
         Else
            strSupCode = Trim$(Right$(drug$, (Len(drug$)) - (InStr(drug$, Chr(160)))))
         End If
         drug$ = Left$(drug$, (InStr(drug$, Chr(160)) - 1))
      End If
      If Trim$(drug$) = "" Then  '02Oct06 TH Added to prevent BNF search firing (as there is no BNF search anymore) (SC-06-0768)
         blnFound = 0            '   "
      Else                       '   "
         d.Code = drug$ '???
         findrdrug drug$, True, d, 0, blnFound, newdrug%, False, False
      End If                     '   "
      If blnFound <> 0 Then
         desc$ = d.DrugDescription 'desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         drug$ = d.SisCode
         If Edittype = 5 And UCase$(d.inuse) = "N" Then
            popmessagecr ".DRUG NOT IN USE", desc$ & " is not in use." & Chr$(13) & Chr$(13) & "Please check with your System Supervisor."
            Exit Sub
         End If
         strTable = GetTableName(Edittype)
                     
         'checks to see if already on order
         Select Case Edittype
            Case 3
               strCode = d.SisCode
               If (Trim$(ordernum$) <> "") And (Trim$(ordernum$) <> "A") Then
                  strNum = Trim$(ordernum$)
               End If
               If (Trim$(strNum) = "") And (Trim$(ordernum$) = "A") And (Val(SelectedOrder) > 0) Then strNum = Trim$(Format$(SelectedOrder)) '05Jun08 TH Added (F0015293)
''               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                           gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, CStr(edittype)) & _
''                           gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupcode) & _
''                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, strCode) & _
''                           gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(strNum)) & _
''                           gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, lngPickno) & _
''                           gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
''                           gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
''               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
            Case Else
               If osite$ = "A" Then
                  If Trim$(ordernum$) = "" Or Trim$(ordernum$) = "A" Then
                     strCode = d.SisCode
                  Else
                     strCode = d.SisCode
                     'lngPickno = CLng(ordernum$)
                     lngPickno = Val(ordernum$)  '26Aug05 TH Replaced
                  End If
                  If Edittype = 1 And lngPreselectedrow = 0 Then strSupCode = Trim$(d.supcode) '09Nov05 TH This is used to focus on any line from the default supplier if we are in the all screen
                  
               Else
                  strCode = d.SisCode
                  strSupCode = Trim$(osite$)
               End If
''               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                           gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, CStr(edittype)) & _
''                           gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupcode) & _
''                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, strCode) & _
''                           gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, Val(strNum)) & _
''                           gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, lngPickno) & _
''                           gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
''                           gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
''               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byCriteria", strParams)
         End Select
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, CStr(Edittype)) & _
                           gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupCode) & _
                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, strCode)
         If strTable = "WRequis" Then
            'strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, strNum)
            'strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, ordernum$) '05Aug13 TH Use actual Requisiton Number (TFS 70742)
            '29Jul15 TH Replaced above - dont use requisition num to look up on anything other than initial PT (TFS 72776)
            If Edittype = 5 Then
               strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, ordernum$)
            Else
               strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, "")
            End If
            '29Jul15 TH ---
         Else
            strParams = strParams & gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, Val(strNum))
         End If
         strParams = strParams & gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, lngPickno) & _
                                 gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                 gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
         ''If edittype = 3 Or edittype = 1 Then
             Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byCriteria", strParams)
         ''Else
         ''    Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byCriteria", strParams)
         ''End If
         ordered& = 0
         If lngPreselectedrow <> 0 Then
            If Not rsOrders.EOF Then ordered& = rsOrders.fields(strTable & "ID") '10Nov06 TH Give it a default to run with if the current line is NOT one being processed
            Do While Not rsOrders.EOF
               If lngPreselectedrow = rsOrders.fields(strTable & "ID") Then ordered& = lngPreselectedrow
               rsOrders.MoveNext
            Loop
         Else
            
            If Not rsOrders.EOF Then
               '07Jun12 Now we need to exclude DLO Orders
               If Edittype <> 1 Then 'Or (edittype = 1 And Not rsOrders.Fields("DLO")) Then
                  If (Edittype = 3 Or Edittype = 4) Then
                     If getPSO() Then
                        Do While Not rsOrders.EOF
                           'If Not rsOrders.Fields("DLO") Then ordered& = rsOrders.Fields(strTable & "ID")
                           If (RtrimGetField(rsOrders.fields("PSORequestID")) > 0) Then ordered& = rsOrders.fields(strTable & "ID") '21Nov12 TH PSO also needs excluding (TFS)
                           rsOrders.MoveNext
                        Loop
                     Else
                        Do While Not rsOrders.EOF
                           'If Not rsOrders.Fields("DLO") Then ordered& = rsOrders.Fields(strTable & "ID")
                           If (RtrimGetField(rsOrders.fields("PSORequestID")) < 1) Then ordered& = rsOrders.fields(strTable & "ID") '21Nov12 TH PSO also needs excluding (TFS)
                           rsOrders.MoveNext
                        Loop
                     End If
                  Else
                     ordered& = rsOrders.fields(strTable & "ID")
                  End If
               Else
                  rsOrders.MoveFirst
                  Do While Not rsOrders.EOF
                     'If Not rsOrders.Fields("DLO") Then ordered& = rsOrders.Fields(strTable & "ID")
                     If (Not rsOrders.fields("DLO")) And (rsOrders.fields("PSORequestID") < 1) Then ordered& = rsOrders.fields(strTable & "ID") '21Nov12 TH PSO also needs excluding (TFS)
                     rsOrders.MoveNext
                  Loop
               End If
            End If
         End If
         Set rsOrders = Nothing
         newaddition = False
         If Not k.escd Then
            If ordered& > 0 Then     ' 13Jul91 CKJ  replacement for lines above 'NB ordered set in ScanOrders
               getorder ord, ordered&, Edittype, False      ' (no idx)
               notyetordered = True
               If ((ord.status = "3" And Edittype = 3) Or (ord.status = "6" And Edittype = 6)) And ordered& <> 0 Then
                  Scanorders d, Edittype, ordernum$, SiteNumber, partorder, notyetordered, ordered&, SelectedOrder, blnFromlstView '05Jun08 TH Added param  '27Jun11 CKJ removed linnum
                  WOrderID = ordered& '13Feb07 TH Added to help navigate the screen
               End If
            Else
               blankorder ord '22Feb06 TH Added to flush the Order type (SC-06-0238)
               'If Abs(edittype) <> 3 Then newaddition = True
               If (Edittype = 1) And Trim$(d.SisCode) <> "" Then
                  'check here for other lines on order to other sups.
                  strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                              gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                              gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                              gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode)
                  If strTable = "WRequis" Then
                     strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, strNum)
                  Else
                     strParams = strParams & gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, Val(strNum))
                  End If
                  strParams = strParams & gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                                          gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                          gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
                  Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byCriteria", strParams)
                  If rsOrders.RecordCount > 0 Then
                     Do While Not rsOrders.EOF
                        If RtrimGetField(rsOrders!PSORequestID) < 1 Then '21Nov12 TH Exclude PSO stuff from these checks (TFS)
                           If ((RtrimGetField(rsOrders!supcode) <> strSupCode) Or strSupCode = "") And (RtrimGetField(rsOrders!status) = "1") Then
                              getsupplier (RtrimGetField(rsOrders!supcode)), 0, 0, lclsup
                              strDesc = Trim$(d.DrugDescription)        ' strDesc = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
                              plingparse strDesc, "!"
                              popmessagecr "!WARNING", RtrimGetField(rsOrders!outstanding) & " x " & Trim$(d.convfact) & " of " & strDesc & " ordered from " & RtrimGetField(rsOrders!supcode) & Iff(Trim$(lclsup.name) <> "", " (" & Trim$(lclsup.name) & ") ", "") & ". Order not yet raised."
                           ElseIf (RtrimGetField(rsOrders!status) = "3") Then
                              getsupplier (RtrimGetField(rsOrders!supcode)), 0, 0, lclsup
                              strDesc = Trim$(d.DrugDescription)        ' strDesc = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
                              plingparse strDesc, "!"
                              popmessagecr "!WARNING", RtrimGetField(rsOrders!outstanding) & " x " & Trim$(d.convfact) & " of " & strDesc & " ordered from " & RtrimGetField(rsOrders!supcode) & Iff(Trim$(lclsup.name) <> "", " (" & Trim$(lclsup.name) & ") ", "") & " Order Number " & RtrimGetField(rsOrders!num) & " . Order raised, goods not yet received."
                           End If
                        End If
                        rsOrders.MoveNext
                     Loop
                  End If
                  rsOrders.Close
                  Set rsOrders = Nothing
               End If
            End If
        
            If (ordered& = 0) And (Edittype = 3) Then
               ''popmessagecr "NOT ON ORDER", "To receive this item an order must be raised" '16Oct05 TH (#83787) Replaced
               popmessagecr "!Order Receipt", "This Order Line may (1) not have been part of the original order" & _
               crlf & " or (2) already have been received or part received since beginning this Receipt." & _
               crlf & crlf & "Please check the Order Logs for Confirmation" '02Apr07 TH Enhanced msg
                  
               k.escd = True
            End If
            
            If (ordered& = 0) And (Edittype = 6) Then  '08Jan13 TH Added section (TFS 51950)
               popmessagecr "!Issue Picking Ticket", "Picking Ticket cannot be issued. Item may not be on Picking Ticket"
               k.escd = True
            End If

            If Edittype = 1 Or Edittype = 5 Or Edittype = 9 Or Edittype = 10 Then
               If UCase$(osite$) = "A" Then
                  getsupplier d.supcode, findsup%, lngFoundSup, sup
               Else
                  getsupplier osite$, findsup%, lngFoundSup, sup
               End If
                        
               getdrugsup d, 0, 0, False, sup.Code
                        
               If Trim$(sup.suppliertype) = "" Then
                  popmessagecr "Aborting", "Supplier type not defined for supplier " + sup.Code + " " + sup.name + Chr$(13) + "Ask your System Administrator to define the supplier type for this supplier."
                  k.escd = True
                  Exit Sub
               End If

               If Edittype = 5 And Trim$(ord.num) = ordernum$ And Trim$(ord.supcode) = osite$ Then
                   amendrequis = True
               Else
                   amendrequis = False
               End If
               If Edittype = 1 Or Edittype = 10 Or amendrequis Then
                  If notyetordered Then
                     If amendrequis And Not PrintInPacks Then '13Sep06 TH Removed
                     '   ordqty$ = ""
                        ordqty$ = Format$(Val(ord.outstanding) / Val(d.convfact))
                     Else
                        'If ordered& > 0 And (Not edittype = 1) Then  '27Sep05 TH
                        ordqty$ = RTrim$(ord.outstanding)
                        'Else                                         '    "
                        '   ordqty$ = ""                              '    "
                        'End If                                       '    "
                     End If
                  Else
                     ordqty$ = RTrim$(d.reorderqty)
                  End If
               Else
                   ordqty$ = ""
               End If

               If Edittype <> 5 Then '13Sep06 TH do not factor on outers for reqs !!
                  numofouters = 0
                  If Val(d.reorderpcksize) > 0 Then
                     defnumofouters (Val(ordqty$)), (Val(d.reorderpcksize)), numofouters
                  End If
                  If numofouters > 0 Then
                     ordqty$ = LTrim$(Str$(Val(d.reorderpcksize) * numofouters))
                  End If
               End If
               '13Jan98 EAC handle amending of Credit notes
               If Edittype = 9 Then
                  If ordered& > 0 Then ordqty$ = Trim$(ord.outstanding)
               End If
               '---
               
               ordqty$ = Format$(Val(ordqty$) * Val(d.convfact))
               EnterAmend ordqty$, d.convfact, ""
               unitsordered$ = Format$(Val(ordqty$) / Val(d.convfact))
               If Edittype = 5 Then
                  If UCase$(sup.suppliertype) = "S" Or UCase$(sup.suppliertype) = "E" Or PrintInPacks Then ordqty$ = Format$(dp!(Val(ordqty$) / Val(d.convfact)))       '23Jun98 EAC added dp! to prevent e numbers occuring
               Else
                  ordqty$ = Format$(Val(ordqty$) / Val(d.convfact))
               End If
               If Edittype = 9 Then
                  k.Max = 9
                  k.min = 1
                  k.decimals = True
                  k.helpnum = 372
                  price$ = Str$(dp!(Val(d.cost) / 100))
                  poundsandpence price$, False
                  price$ = LTrim$(price$)
                  getsupplier sup.Code, findsup%, lngFoundSup, sup
                  If Trim$(sup.suppliertype) = "" Then
                     popmessagecr "Aborting", "Supplier type not defined for supplier " + sup.Code + " " + sup.name + Chr$(13) + "Ask your System Administrator to define the supplier type for this supplier."
                     k.escd = True
                  End If

                  If Not k.escd Then
                     Unload frmEnhTxtWin
                     
                     frmEnhTxtWin.txtBox.Left = 400
                     frmEnhTxtWin.txtBox = price$   'Format(Val(ans$), "0.00")'ans$
                     frmEnhTxtWin.Caption = "Credit note price entry"
                     strTemp = d.DrugDescription 'strTemp = GetStoresDescription()  XN 4Jun15 98073 New local stores description
                     plingparse strTemp, "!"
                     'If Val(Trim$(ans$)) < 0 Then
                     '   strTemp = Trim$(strTemp) & crlf & crlf & " Unit cost      " + "x " + d.convfact + " " + d.PrintformV
                     'Else
                     strTemp = Trim$(strTemp) & crlf & crlf & " Unit cost for  " & Trim$(d.convfact) & " " & Trim$(d.PrintformV)
                     'End If
                     frmEnhTxtWin.lblbox.Caption = strTemp & crlf & crlf & crlf & " " & money(5)
                     frmEnhTxtWin.txtBox.SelStart = 0
                     frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
                     frmEnhTxtWin.txtBox.Width = Int(frmEnhTxtWin.txtBox.Width / 1.5) '01May05 TH
                     HorizCentreForm frmEnhTxtWin
                     frmEnhTxtWin.txtBox.Top = (frmEnhTxtWin.lblExtra.Top + 140)
                     k.escd = False    '08Mar02 TH (#56352,54364)
                     k.Max = 20        '   "
                     k.nums = True     '   "
                     k.decimals = True '   "  'SQL Remove ? - seems daft !          '////

                     ShowFrmEnhTxtWin                   '    "
                     If Not k.escd Then
                        ans$ = Trim$(frmEnhTxtWin.txtBox)
                        price$ = ans$ '03Nov05 TH (#84228)
'''                     If Val(Trim$(ans$)) < 0 Then
'''                        inputwin "Enter Cost", "Unit cost            " + "x " + d.convfact + " " + d.PrintformV, price$, k
'''                     Else
'''                        inputwin "Enter Cost", "Unit cost            " + d.PrintformV, price$, k
'''                     End If
                        AskReasonCodeSQL "return of goods", retcode$
                     End If
                  End If
               End If
        
               If Not k.escd And (Edittype = 1 Or Edittype = 9 Or Edittype = 10) And RTrim$(d.supcode) <> osite$ And osite$ <> "A" Then
                  intAltSups = 0
                  intAltSups = IsAlternativeSupplier(d.SisCode, osite$)
                  If intAltSups Then MakeThisSupplier = True
                  If Not intAltSups Then
                     ans$ = "N"
                     strDescription = d.DrugDescription 'strDescription = GetStoresDescription() XN 4Jun15 98073 New local stores description
                     plingparse strDescription, "!"
                     getsupplier d.supcode, 0, 0, lclsup
                     'strMsg = "The default supplier for " & Trim$(strDescription) & " is " & Trim$(lclsup.name) & crlf & crlf & "OK  to order from this non-preferred supplier ?" 21Jan15 XN 43087 Text change
                     strMsg = "The default supplier for " & Trim$(strDescription) & " is " & Trim$(lclsup.name) & crlf & crlf & "OK  to continue with this non-preferred supplier ?"
                     'Confirm "This supplier is not the default for " & Trim$(strDescription), "set this item (" & Trim$(strDescription) & ")  to this non-preferred supplier", ans$, k
                     askwin "!This supplier is not the default", strMsg, ans$, k
                     If ans$ <> "N" And Not k.escd Then
                        MakeThisSupplier = True
                     ElseIf Not k.escd Then
                        '14Apr10 TH Added Block
                        If Trim$(d.supcode) = "" Then                                                                                                                        '12Jan07 PJC Handles empty supplier codes in the drug file (#87151)
                           popmessagecr "!n!iABORTING", "The drug file supplier code associated with item " & Trim$(desc$) & " (NSVCode: " & d.SisCode & ") is empty."     '           "
                           k.escd = True                                                                                                                                   '           "
                        Else
                           '13Apr10 TH Ported and converted (F0044679) 02Jul08 TH We need to check if this is already on order for the default supplier. If it is we warn and leave (F0020068)
                           strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1") & _
                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, d.supcode) & _
                                    gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode) & _
                                    gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                                    gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                                    gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                    gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                                 
                           Set rsOrderCheck = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderByCriteria", strSql)
                           If rsOrderCheck.RecordCount > 0 Then
                              strMsg = "This item is already on order (not yet raised) for the default supplier :" & Trim$(lclsup.name) & " (" & Trim$(lclsup.Code) & ")"
                              strMsg = strMsg & crlf & "Quantity : " & ord.qtyordered & " * (" & Trim$(Format$(d.convfact)) & " " & Trim$(d.PrintformV) & ")"
                              strMsg = strMsg & crlf & "Please check this line and amend as appropriate"
                              popmessagecr "!Amend order", strMsg
                              k.escd = True
                           End If
                           rsOrderCheck.Close
                           Set rsOrderCheck = Nothing
                           
                           If Not k.escd Then
                              popmessagecr "", "This item will now be displayed for supplier " + d.supcode
                              blnChangetoDefaultSup = True
                           End If
                        End If
                        '-------------
                        'popmessagecr "", "This item will now be displayed for supplier " + d.supcode '14Apr10 TH Replaced by above
                        'blnChangetoDefaultSup = True
                     End If                                                                                                 '     "
                  End If
               End If
            End If
        
            If Not k.escd Then
               errored = False
               If UCase$(osite$) = "A" And Edittype <> 1 And Edittype <> 3 And Edittype <> 4 And Edittype <> 6 And Edittype <> 9 And Edittype <> 10 Then  '25Nov98 TH
                   popmessagecr "!n!iABORTING", "To enter new orders the site must be entered"
                   errored = True
               End If
               If UCase$(ordernum$) = "A" And Edittype <> 1 And Edittype <> 3 And Edittype <> 4 And Edittype <> 9 And Edittype <> 10 Then '25Nov98 TH
                  If Edittype = 6 Then
                     popmessagecr "!n!iABORTING", "Picking ticket number must be entered" ', for this item  =" + STR$(ord.pickno)
                     errored = True
                  Else
                     popmessagecr "!n!iABORTING", "To enter new orders the requisition number must be entered"
                     errored = True
                  End If
                  k.escd = True
               End If
               If Edittype = 5 And (Trim$(ord.num) <> ordernum$ Or Trim$(ord.supcode) <> osite$) Then ordered& = 0 'ASC 11May93
               If (ordered& = 0 And Val(ordqty$) > 0 And (Edittype = 1 Or Edittype = 5 Or Edittype = 9 Or Edittype = 10)) Then    '25Nov98 TH
                '>>>>>>> add an item---------------------------------------------
                  If Not errored Then
                     newaddition = True
                     pointer& = 0 'Force addition
                     blankorder ord
                     ord.Code = d.SisCode
                     ord.loccode = d.loccode
                     ord.outstanding = ExpandExp$(ordqty$)
                     ord.qtyordered = ordqty$
                     If Edittype = 5 Then
                        'check to follows here and allow abort
                        k.escd = False
                                                ' checktofollows sup, d.SisCode, d.Description, d.convfact, k    XN 4Jun15 98073 New local stores description
                        checktofollows sup, d.SisCode, d.LabelDescription, d.convfact, k
                        If k.escd Then                       '13Feb02 TH If abort req then set to delete and write record  (#59023)
                           ord.status = "D"                  '     "     (release file and get out) - no need for indexes
                           pointer& = PutOrder(ord, (pointer&), "WRequis") 'V93
                           Exit Sub
                        End If
                        
                        
                        
                        ord.supcode = osite$
                        getsupplier Trim$(ord.supcode), 0, lngFoundSup, sup
                        '02Jul12 TH Check DLO Status, if DLO possible then ask the user whether they wish to raise it as DLO or not
                        If TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0)) And CheckDLOItem(d.SisCode, osite$, 0) And sup.PrintPickTicket = "Y" Then '29May12 TH Added  '22Nov12 TH TFS 49691 Ensure default is off
                           ans$ = "N"
                           strMsg = Trim$(strDescription) & crlf & crlf & "It is  possible to create a requisition for direct location ordering for this item." & crlf & crlf & "Do you wish to order this item automatically and issue on receipt ?"
                           askwin "!Direct Location Order", strMsg, ans$, k
                           If ans$ <> "N" And Not k.escd Then
                              ord.DLO = True
                              ord.DLOWard = sup.Code
                           End If
                        End If
                        
                        If (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then
                           orderqty! = Val(ordqty$) / Val(d.convfact)
                        Else
                           orderqty! = Val(ordqty$)
                        End If
                        updateoutstanding orderqty!, d
                        ord.CreatedUser = UserID$
                        ord.custordno = GetCustOrdNo()
                     Else
                        If osite$ <> "A" And osite$ <> "" And MakeThisSupplier Then
                           ord.supcode = osite$
                        Else
                           ord.supcode = d.supcode
                        End If
                     End If
                     If Edittype = 10 Then
                        ord.status = "F"
                     Else
                        ord.status = LTrim$(Str$(Edittype))
                     End If
                     ord.orddate = thedate(False, True)
                     ord.ordtime = thedate(0, -2)  '11Oct05 TH Added

                     If Edittype = 1 Or Edittype = 9 Or Edittype = 10 Then
                        ord.num = ""
                     Else
                        ord.num = ordernum$  'is this needed ASC 03Aug91 yes 16 AUG ASC when entering manually
                     End If
                     If Edittype = 9 Then
                        ord.invnum = retcode$
                        ord.cost = Trim$(Str$(Int(Val(price$) * 100)))
                        ord.received = ord.outstanding
                     End If
                     'V93
                     Select Case Edittype
                        Case 1, 2, 3, 9
                          pointer& = PutOrder(ord, 0, "WOrder")
                          'strTable = "WRequis"
                        Case Else
                          pointer& = PutOrder(ord, 0, "WRequis")  'V93
                          'strTable = "Requis"
                     End Select
                  End If
               Else
               '>>>>>>>> amend an item------------------------------------------
                  If Val(ordqty$) > 0 And (Edittype = 1 Or Edittype = 9 Or Edittype = 10 Or amendrequis) Then
                     If Val(ord.outstanding) <> Val(ordqty$) Then
                        If Edittype = 5 And (ord.internalmethod <> " " Or ord.tofollow = "1") Then
                           popmessagecr "!n!iAmending of internal orders or 'to follows' is not allowed", "To amend please delete the requisition & re-raise."
                        Else
                           getorder ord, ordered&, Edittype, True      '<----LOCK    (no idx)
                           If Edittype = 5 Then  '23Jun93 CKJ Now updates outstanding
                              getsupplier Trim$(ord.supcode), 0, lngFoundSup, sup
                              If Val(ord.outstanding) < Val(ordqty$) Then
                                 'check to follows here and allow abort
                                 k.escd = False
                                                                 'checktofollows sup, d.SisCode, d.Description, d.convfact, k    XN 4Jun15 98073 New local stores description
                                                                 checktofollows sup, d.SisCode, d.LabelDescription, d.convfact, k
                                 If k.escd Then                          '13Feb02 TH Replace above -If abort amend then   (#59023)
                                    'PutOrder ord, ordered&, "Requis" 'V93           '     "     putorder (release file and get out)
                                    PutOrder ord, ordered&, "WRequis" 'V93     '07Aug13 TH The above line read WRequis until somewhere around 10.9. Somehow the prefix got removed and
                                                                               '           I dont know when and how (stray key stroke not picked up in check in ?) (TFS 70916)
                                    Exit Sub
                                 End If
                              End If
                              '13Sep06 TH added printinpacks check
                              If sup.suppliertype = "W" Or sup.suppliertype = "L" Then
                                 orderqty! = (Val(ordqty$) - Val(ord.outstanding)) / Val(d.convfact)
                                 '13Sep06 TH added printinpacks check
                                 If PrintInPacks Then
                                    sglOutstanding = (Val(ordqty$) - Val(ord.outstanding))
                                 Else
                                    sglOutstanding = orderqty
                                 End If
                              Else
                                 orderqty! = Val(ordqty$) - Val(ord.outstanding)
                                 sglOutstanding = orderqty
                              End If
                              '13Sep06 TH added printinpacks check
                              'updateoutstanding orderqty!, d
                              updateoutstanding sglOutstanding, d
                           End If
                           ord.outstanding = ExpandExp$(ordqty$)
                           ord.received = ord.outstanding
                           ord.qtyordered = LTrim$(unitsordered$)
                           drug$ = drug$ & Chr(160) & ord.OrderID  '10Aug05 TH Added as frig to pass back the code of the amended item
                           If blnChangetoDefaultSup Then
                             ord.supcode = d.supcode
                             newaddition = 2                  'Use as flag for screen refresh
                           Else                                               '03Jun08 TH Added
                              If Edittype = 1 Then WOrderID = ord.OrderID     '     "
                           End If
                           'V93
                           Select Case Abs(Edittype)
                              Case 0
                                 popmessagecr "ERROR", "Edit type not set report to system manager"
                              Case 1, 2, 3, 9
                                 ordered& = PutOrder(ord, ordered&, "WOrder")  'v93
                              Case 4
                                 ordered& = PutOrder(ord, ordered&, "WReconcil")  'v93
                              Case Else   '5 amend  6 pick tkt printed  7 pick tkt issued  8 delivery note
                                 ordered& = PutOrder(ord, ordered&, "WRequis")  'v93
                           End Select
                        End If
                     Else
                        '03Jun08 TH Added new section to allow for edit of line to switch to default sup even if not altered (F0015768/F0015286)
                        
                        If blnChangetoDefaultSup And Edittype = 1 Then
                           getorder ord, ordered&, Edittype, True
                           ord.supcode = d.supcode
                           pointer& = PutOrder(ord, ord.OrderID, "WOrder")
                           WOrderID = 0
                           newaddition = 2                  'Use as flag for screen refresh
                        Else
                           WOrderID = ord.OrderID
                        End If
                     End If
                  End If
               End If
            Else
            'k.escd = False
            End If
         End If
      Else
         k.escd = True
      End If
      'k.escd = True
   End If

    'Loop Until k.escd = True
    If errored Then partorder = -2 '26Aug05 TH Added as flag so we dont need to rewrite displays
    
End Sub

Sub EnterActualReceive(ordqty$, d As DrugParameters, ord As orderstruct, ByRef lngBatchWReconcilID As Long)
'28Dec93 CKJ moved from orderlib
'29Dec97 EAC Use Stores drug description
'20Oct99 TH Make messagesitems received for free more explicit
'18Jan02 TH Fill issue box with outstanding if there was a prior partial receipt (#50094)
'19Nov12 TH PSO enhancements to include patient details on PSO receipt line (TFS 48806))
'10Feb15 TH Blank the input so user must deliberately enter qty (TFS 82279)
'05Aug15 TH Stop fractional receipt of orders when fraction not resolvable to 2 dec places (TFS 46785)
'12Aug15 TH Removed inappropriate division by convfact from fractional receipt checks (TFS 126106)
'13Aug15 TH Stop receipt of fractional issue unit (TFS 126355)

Dim desc$, msg$
Dim intMousewas As Integer
Dim strPatName As String
Dim strTemp As String
Dim strPatCasenumber As String
Dim strPatDOB As String
Dim strPatNHNumber As String

   setinput 0, k
   '29Dec97 EAC Use Stores drug description
   'desc$ = Trim$(d.description)
   desc$ = Trim$(d.DrugDescription)     ' desc$ = Trim$(GetStoresDescription())  XN 4Jun15 98073 New local stores description
   '---
   plingparse desc$, "!"
   msg$ = Chr$(13) + "  " + desc$ + Chr$(13) + "  Order Number        "
   msg$ = msg$ + ord.num
   If getPSO() Then
      Heap 11, gPRNheapID, "psoForename", strTemp, 0
      strPatName = Trim$(strTemp)
      Heap 11, gPRNheapID, "psoSurname", strTemp, 0
      strPatName = strPatName & " " & Trim$(strTemp)
      Heap 11, gPRNheapID, "psoDOB", strTemp, 0
      strPatDOB = Trim$(strTemp)
      Heap 11, gPRNheapID, "psoCasenumber", strTemp, 0
      strPatCasenumber = Trim$(strTemp)
      Heap 11, gPRNheapID, "psoNHNumber", strTemp, 0
      strPatNHNumber = Trim$(strTemp)
      msg$ = msg$ & crlf & crlf & "  For Patient : " & strPatName & crlf & "  DOB : " & strPatDOB & crlf & "  Case Num : " & strPatCasenumber & crlf & "  NH Number : " & strPatNHNumber & crlf
      frmEnhTxtWin.lblExtra.Top = 2000 '970
   End If
   msg$ = msg$ + Chr$(13) + Chr$(13) + "  Quantity received"
   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "NoDefaultReceiptQty", 0)) Then   '10Feb15 TH Blank the input so user must deliberately enter qty (TFS 82279)
      ordqty$ = ""                                                                                 '  "
   Else                                                                                            '  "
      ordqty$ = Trim$(ord.received)
      If Val(ordqty$) = 0 Then ordqty$ = Trim$(ord.outstanding) '18Jan02 TH Added to prompt for expected amt after partial rec. (#50094)
      If Val(ordqty$) = 0 Then ordqty$ = ""
   End If                                                                                          '  "
   k.Max = 5
   k.helpnum = 400
   
   k.decimals = True
   
      '26Oct99 AE Removed as other mods have been made to do this
   'If freeflag Then                                           '20Oct99 TH Make items received for free more explicit
   '      msg$ = msg$ & Chr(13) & "  AT ZERO COST" & Chr(13)   '   "
   '      ttl$ = "Enter Quantity Recieved FOR ZERO COST"       '   "
   '   Else                                                    '   "
   '      ttl$ = "Enter Quantity Received"                     '   "
   '   End If                                                  '   "
   
   
''   inputwin "Enter Quantity Received", msg$, ordqty$, k      '20Oct99 TH Replaced with below '26Oct99 AE removed
   Unload frmEnhTxtWin
   'frmEnhTxtWin.Tag = "reconcil"      'updated if checkbox is checked
   frmEnhTxtWin.Check1.Visible = False
   frmEnhTxtWin.Caption = "Enter Quantity Received"
   If getPSO() Then
      'msg$ = msg$ & crlf & crlf & "For Patient: " & crlf & "DOB" & "Casenumber" & crlf & "NHSNumber" & crlf
      frmEnhTxtWin.lblExtra.Top = 2220 '970
   End If
   frmEnhTxtWin.lblbox.Caption = msg$
   frmEnhTxtWin.lblExtra.Caption = " x " + d.convfact + d.PrintformV
   frmEnhTxtWin.txtBox = ordqty$
   frmEnhTxtWin.txtBox.Top = (frmEnhTxtWin.lblExtra.Top - 70)
   frmEnhTxtWin.txtBox.Left = 2000
   frmEnhTxtWin.txtBox.SelStart = 0
   frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
   HorizCentreForm frmEnhTxtWin

   k.escd = False
   intMousewas = Screen.MousePointer
   Screen.MousePointer = 0
   ShowFrmEnhTxtWin
   Screen.MousePointer = intMousewas
   frmEnhTxtWin.Tag = ""
   ordqty$ = Trim$(frmEnhTxtWin.txtBox)
   
   '05Aug15 TH Added section (TFS 46785)
   If Trim$(ordqty$) <> "" And (Not k.escd) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "StopUncontrolledFractionalReceipting", 0)) Then
      If Edittype = 3 And (Val(Format(Val(ordqty$), "#.##")) <> Val(Format(Val(ordqty$), "#.#######"))) Then '12Aug15 TH Removed division by convfact (TFS 126106)
         'Here we have something that cant be expressed as a pack to 2 dec places. We must disallow this posibility
         'popmessagecr "", "Receiving " & Format((Val(ordqty$) / Val(d.convfact)), "#.#######") & " pack(s) is not allowed as this will lead to balancing errors. Please check and alter receipt quantity."
         popmessagecr "", "Receiving " & Format(Val(ordqty$), "#.#######") & " pack(s) is not allowed as this will lead to balancing errors. Please check and alter receipt quantity."  '12Aug15 TH Removed division by convfact (TFS 126106)
         k.escd = True
      ElseIf Edittype = 3 And (Val(Format((Val(ordqty$) * Val(d.convfact)), "#")) <> Val(Format((Val(ordqty$) * Val(d.convfact)), "#.#######"))) Then        '13Aug15 TH Stop receipt of fractional issue unit (TFS 126355)
         popmessagecr "", "Receiving fractional issue Units is not allowed as this will lead to balancing errors. Please check and alter receipt quantity."  '13Aug15 TH
         k.escd = True
      End If                                                                                                  '      "
   End If
   '05Aug15 TH ----
   
   Unload frmEnhTxtWin

   'InputWin ttl$, msg$, ordqty$, k                                                          '26Oct99 AE reinstated

   If Not k.escd And Val(ordqty$) > 0 Then EnterBatchNo ord, False, ordqty$, lngBatchWReconcilID  '27Dec93 CKJ Added !!**   '30Mar99 CFY Additional parametr added
   If MainScreen.LstDisplay.Tag = "ESC" Then
      MainScreen.LstDisplay.Tag = ""
      k.escd = True
   End If

End Sub

Sub EnterBatchNo(ord As orderstruct, NeedsWindow%, Qty$, ByRef lngBatchWReconcilID As Long)
'27Dec93 CKJ Asks for Batch No => 'InvNum', expiry date => 'paydate'
'23May96 CKJ Added 'M'illenium fix
'29Dec97 EAC Use Stores drug description
'12Jan98 EAC millenium fix for entry of batch dates
'30Oct98 EAC No longer prompt with previous batch number /expiry for part receipts
'21Dec98 CFY Re-Written. The type of batchtracking that is carried out is now designated at the
'            drug record level using the field d.batchtracking. The following types have been
'            implemented so far:
'                 1  - No Batch Tracking
'                 2  - Record Batchnumber on receipt
'                 3  - Record Batchnumber and expiry date on receipt
'                 4  - Record Batchnumber and expiry date on receipt and confirm on Issue
'30Mar99 CFY Additional parameter added - Qty, to allow partial receipt.
'15Apr99 CFY Whoops! Removed debug line which set d.batchtracking to 4
'30Jun99 CFY Added call to getdrugsup
'12Nov99 TH  Use lstdisplay.tag as flag for escaped on receiving orders
'18Jan02 TH  Added qty$ parameter to RecordBatchNo procedure (#50094)
'26Oct06 TH  Added parameter to allow amalgamation of batch receipts into same invoice line
'14Jun13 TH  Added new param to RecordExpiry (TFS 39884)

Dim foundPtr&    '01Jun02 ALL/ATW
Dim expiry$, batchno$
Dim strAns As String       '26Oct06 TH
Dim strMsg As String       '    "
Dim strProduct As String   '    "
   MainScreen.LstDisplay.Tag = ""   '12Nov99 TH Reset Flag for receiving orders
   batchno$ = ""
   expiry$ = ""
   k.escd = False
   d.SisCode = ord.Code
   getdrugsup d, 0, foundPtr&, False, ord.supcode   '         "  '01Jun02 ALL/ATW
   If foundPtr& Then                                             '01Jun02 ALL/ATW
      Select Case Val(d.batchtracking)
         Case 1:
            'Do Nothing
         Case 2:
            RecordBatchNo batchno$, Qty$    '18Jan02 TH Added qty$ parameter (#50094)
         Case 3:
            RecordBatchNo batchno$, Qty$    '18Jan02 TH     "
            RecordExpiry ord, NeedsWindow%, expiry$, d.ExpiryWarnDays  '14Jun13 TH Added param (TFS 39884)
         Case 4:
            RecordBatchNo batchno$, Qty$    '18Jan02 TH     "
            RecordExpiry ord, NeedsWindow%, expiry$, d.ExpiryWarnDays  '14Jun13 TH Added param (TFS 39884))
            If Trim$(batchno$) <> "" Then
               AddStockOfBatch ord.Code, expiry$, Val(Qty$), batchno$
            End If
      End Select
      '26Oct06 TH '15Mar07 TH Added a setting so this is off by default now.
      If Trim$(batchno$) <> "" And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "BatchInvoiceAmalgamation", 0)) Then
         'We have batch information. Now we will check to see if we have a reconcil record for this item
         'on this order.If so then we will ask if this is to be amalgamated on the invoice line or not
         'If so we store the ID and use it on the actual receipt.
         lngBatchWReconcilID = CheckBatchReconcilReceipts(ord.num, ord.Code, True)
         If lngBatchWReconcilID > 0 Then
            'pop the question
            strAns = "N" 'Default
            'strProduct = d.storesdescription XN 4Jun15 98073 New local stores description
            'If Trim$(strProduct) = "" Then strProduct = d.Description
                        strProduct = d.DrugDescription
            plingparse strProduct, "!"
            strMsg = "A previous receipt record for " & strProduct & crlf & _
                     "on order number " & Format$(ord.num) & " has been detected." & crlf & _
                     "Do you wish to amalgamate this receipt onto the same invoice line ?"
            askwin "Batch Receipt - Invoice Amalgamation", strMsg, strAns, k
            If strAns <> "Y" Or k.escd Then
               lngBatchWReconcilID = 0 'If no then make sure this is empty
            End If
         End If
      End If
      '---------------
   Else
      popmessagecr "", "NSVCode " & Trim$(d.SisCode) & " not found in drug file"
   End If
   
   If k.escd% Then MainScreen.LstDisplay.Tag = "ESC"   '12Nov99 TH Flag escaped for receiving orders
   k.escd = False  'WHY ?
 
End Sub

Sub EnterCustOrdNo(blnReturn As Integer)
'18Apr00 CFY Written
'        Prompts user to enter customers order number if feature is enabled. Number is then stored for later use.
'19Apr00 CFY Now calls PutCusOrdNo rather than setting directly.
'25Feb02 TH  Added new input parameter to identify returns and check whether to offer prompt if set up so to do. (enh1585)

Dim sAns As String
Dim blnPrompt As Integer  '25Feb02 TH Added
   blnPrompt = False
   PutCustOrdNo ""
   If blnReturn Then                                                                                         '25Feb02 TH Added
      blnPrompt = TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNoReturn", 0)) '    "
   Else                                                                                                   '    "
      blnPrompt = TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0))       '    "
   End If                                                                                                 '    "
   'If TrueFalse(txtd(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Then     '25Feb02 Removed - replaced with new variable above
   If blnPrompt Then
      k.escd = False
      k.Max = Len(ord.custordno)
      
      InputWin "Requisitions", "Enter customers order number", sAns, k
      If Not k.escd Then
         PutCustOrdNo Trim$(sAns)
      End If
   End If

End Sub

Sub FillHeapOrdInfo(ByVal HeapID As Integer, ord As orderstruct, success As Integer)
'30Mar00 CFY Written. Code taken from FillHeapDrugInfo.
'17Apr00 CFY Added trimz around time fields as VB falls over if format$ is asked to format a time field containing nulls.
'18Apr00 CFY Corrected dat formatting problem
'05Jul12 TH  Added 2 new DLO Elements

Dim act%
Dim id%
Dim LineCost$
Dim localDrug As DrugParameters
Dim lngFound As Long

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
      Heap act, id, "oNSVCode", Trim$(ord.Code), 0
      Heap act, id, "oOutstanding", Trim$(ord.outstanding), 0
      
      Heap act, id, "oOrdDate", Left$(ord.orddate, 2) & "/" & Mid$(ord.orddate, 3, 2) & "/" & Right$(ord.orddate, 4), 0
      Heap act, id, "oOrdTime", Format$(trimz(ord.ordtime), "hh:mm:ss"), 0
      Heap act, id, "oLocCode", Trim$(ord.loccode), 0
      Heap act, id, "oSupCode", Trim$(ord.supcode), 0
      Heap act, id, "oStatus", Trim$(ord.status), 0
      Heap act, id, "oNumPrefix", Trim$(ord.numprefix), 0
      Heap act, id, "oNum", Trim$(ord.num), 0
      Heap act, id, "oCost", Trim$(ord.cost), 0
      Heap act, id, "oPickNo", Format$(ord.pickno), 0
      Heap act, id, "oReceived", Trim$(ord.received), 0
      Heap act, id, "oRecdate", Left$(ord.recdate, 2) & "/" & Mid$(ord.recdate, 3, 2) & "/" & Right$(ord.recdate, 4), 0
      Heap act, id, "oRecTime", Format$(trimz(ord.rectime), "hh:mm:ss"), 0
      Heap act, id, "oInvNum", Trim$(ord.invnum), 0
      Heap act, id, "oPayDate", Left$(ord.paydate, 2) & "/" & Mid$(ord.paydate, 3, 2) & "/" & Right$(ord.paydate, 4), 0
      Heap act, id, "oQtyOrdered", Trim$(ord.qtyordered), 0
      Heap act, id, "oUrgency", Trim$(ord.urgency), 0
      Heap act, id, "oToFollow", Trim$(ord.tofollow), 0
      Heap act, id, "oIntSiteNo", Trim$(ord.internalsiteno), 0
      Heap act, id, "oIntMethod", Trim$(ord.internalmethod), 0
      Heap act, id, "oSupType", Trim$(ord.suppliertype), 0
      Heap act, id, "oCreatedUser", Trim$(ord.CreatedUser), 0
      If Val(ord.status) = 3 Or Val(ord.status) = 4 Then
          LineCost$ = Str$(dp!(Val(ord.cost) / 100)) '23Jun93 CKJ dp
          poundsandpence LineCost$, False
          localDrug.SisCode = ord.Code
          getdrug localDrug, 0, lngFound, False
          If lngFound Then
             Heap act, id, "oPurchasePrice", money(5) & Trim$(LineCost$) & " per " & Trim$(localDrug.convfact) & " " & Trim$(localDrug.PrintformV), 0
          Else
             Heap act, id, "oPurchasePrice", "", 0
          End If
      Else
         Heap act, id, "oPurchasePrice", "", 0
      End If
      '05Jul12 TH DLO Mods
      Heap act, id, "oDLO", IIf(ord.DLO, "DLO", ""), 0
      Heap act, id, "oDLOYN", IIf(ord.DLO, TxtD(dispdata$ & "\Winord.ini", "DLO", "True", "DLOHeapTrue", 0), TxtD(dispdata$ & "\Winord.ini", "DLO", "False", "DLOHeapFalse", 0)), 0
      Heap act, id, "oDLOWard", Trim$(ord.DLOWard), 0
      
      success = True
   End If

End Sub

''Sub XFindOutStanding()
'''---------------------------------------------------------------------------------
'''goes through requis file and adds outstanding qty to d.outstanding for each drug
'''
'''10Dec97 EAC called from high level Utilities menu
'''            give oppotunity to back out before recalculating
'''15Dec97 CKJ Added Acquirelocks
'''30Nov01 CKJ Added safety check for record being all nulls
'''            Writes c:\blankprd.log
'''---------------------------------------------------------------------------------
'''SQL TODO
''
''Const Title$ = "Update Outstanding Requisitions" '10Dec97 EAC
''
''Dim pointer&, loopvar&, nod&, foundPtr&, x& ', find%    '01Jun02 ALL/ATW
''Dim ord As orderstruct
'''10Dec97 EAC
''Dim ans$, outstanding!, filelock$, locked5%, locked7% ' foundsup%,
''Dim blnFatalError As Integer                                                 '30Nov01 CKJ
''Dim strMsg As String
''Dim lngFoundsup As Long
''Dim rsDrugs As ADODB.Recordset
''
''   blnFatalError = False
''   locked5 = False
''   locked7 = False
''   filelock$ = dispdata$ & "\PRNTPCK"
''   askwin Title$, "OK to update the outstanding amounts for all drugs?", ans$, k
''   If ans$ = "Y" And Not k.escd Then
''         AcquireLock filelock$ & "5.LCK", -2, locked5                  ' exclusive, keep trying
''         If locked5 Then AcquireLock filelock$ & "7.LCK", -2, locked7  ' exclusive, keep trying
''      End If
''
''   If locked5 And locked7 Then
''         Screen.MousePointer = HOURGLASS
''
''         'set value of progress gauge and frame caption
''         ChangeTable "Automatic Orders"
''         MainScreen.LblGrid.Caption = Title$
''         MainScreen.Progress.Value = 0
''         MainScreen.FrmGauge.Caption = "Setting all drugs to zero....    "
''
''         'getnod nod
''         'Get all drugs, but just ID and outstanding fields (and site implicitly)
''         Set rsDrugs = gTransport.ExecuteSelectSP(g_SessionID, "DrugOutstandingbySiteSelect", "")
''
''         If rsDrugs.RecordCount > 0 Then
''
''
''
''         UpdateBar 0, 0, 0, 0
''         ''For x = 1 To rsDrugs.RecordCount
''         Do While Not rsDrugs.EOF
''            UpdateBar 1, (rsDrugs.RecordCount), (x), ProgressBarScale
''            getdrug d, GetField(rsDrugs!WDrugsID), foundPtr&, True      '< LOCK   '01Jun02 ALL/ATW
''            If foundPtr& Then                            '01Jun02 ALL/ATW
''               LSet R = d                                                 '30Nov01 CKJ Added safety check for record being nulls
''               If R.record = String$(1024, 0) Then                        '   "
''                  putdrugSQL d, -x            '< UNLOCK WITHOUT WRITING   '   "
''                  blnFatalError = True                                 '   "
''                  Screen.MousePointer = STDCURSOR                      '   "
''                  strMsg = "Blank record encountered in drug file at position " & Format$(x) & ", inform Supervisor and ASC Support immediately"
''                  MsgBox strMsg, MB_ICONSTOP, "HALTED - SERIOUS ERROR ENCOUNTERED (1)"
''                  WriteLog "c:\blankprd.log", 0, UserID$, "Terminal: " & ASCTerminalNameSQL() & " " & dispdata$ & "\Prodinfo record " & Format$(x) & " all null chars when blanking d.outstanding"
''                  Exit Do                                            '   "
''               Else
''                  d.outstanding = 0
''                  putdrugSQL d, x              '< UNLOCK
''               End If                                                  '   "
''            End If
''            rsDrugs.MoveNext
''         ''Next
''         Loop
''
''         If blnFatalError Then                                               '30Nov01 CKJ Only proceed if passed checking
''               MainScreen.FrmGauge.Caption = ""                              '   "
''               UpdateBar 0, 0, 0, 0                                          '   "
''               ChangeTable "Blank"                                           '   "
''            Else                                                             '   "
''               'set value of progress gauge and frame caption
''               MainScreen.FrmGauge.Caption = "Adding outstanding items....    "
''               UpdateBar 0, 0, 0, 0
''
''               getnumofords 6, pointer&, False
''               For loopvar& = 1 To pointer&
''                  UpdateBar 1, pointer&, loopvar&, ProgressBarScale
''                  getorder ord, loopvar&, 5, False            ' (no idx)
''                  d.siscode = ord.Code
''                  'getdrug d, find, found, false
''                  getdrug d, 0, foundPtr&, True 'find, foundPtr&, True '< LOCK   '01Jun02 ALL/ATW
''                  If foundPtr& Then                          '01Jun02 ALL/ATW
''                        LSet R = d                                                 '30Nov01 CKJ Added safety check for record being nulls
''                        If R.record = String$(1024, 0) Then                        '   "
''                              putdrug d, -foundPtr&        '< UNLOCK WITHOUT WRITING   '   "
''                              blnFatalError = True                                 '   "
''                              Screen.MousePointer = STDCURSOR                      '   "
''                              strMsg = "Blank record encountered in drug file at position " & Format$(foundPtr&) & ", inform Supervisor and ASC Support immediately"
''                              MsgBox strMsg, MB_ICONSTOP, "HALTED - SERIOUS ERROR ENCOUNTERED (2)"
''                              WriteLog "c:\blankprd.log", 0, UserID$, "Terminal: " & ASCTerminalNameSQL() & " " & dispdata$ & "\Prodinfo record " & Format$(foundPtr&) & " all null chars when updating d.outstanding for requisition " & Format$(loopvar&) & ", NSVcode " & ord.Code
''                              Exit For                                             '   "
''                           Else
''                              '10Dec97 EAC Delivery Notes not included as when the picking ticket was issued the outstanding amount was updated therefore
''                              '            added and ord.status <> "7"
''                              If ord.status <> "R" And ord.status <> "7" And ord.status <> "D" Then    'ASC 4Aug92 added now that deletions are done over night  '16Jan98 EAC added Status <> "D"
''                                    'outstanding(found) = LTRIM$(STR$(VAL(outstanding(found)) + VAL(ord.outstanding)))
''                                    '10Dec97 EAC ensure that d.outstanding is updated in NSVworths
''                                    getsupplier Trim$(ord.supcode), 0, lngFoundsup, sup
''                                    If lngFoundsup And (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then     '16Jan98 EAC Added PrintinPacks
''                                          outstanding! = Val(ord.outstanding) / Val(d.convfact)
''                                       Else
''                                          outstanding! = Val(ord.outstanding)
''                                       End If
''                                    d.outstanding = d.outstanding + outstanding!
''                                 End If
''                              putdrugSQL d, foundPtr&             '< UNLOCK    '01Jun02 ALL/ATW
''                           End If
''                     End If
''               Next
''               Screen.MousePointer = STDCURSOR
''
''               If Not blnFatalError Then                                           '30Nov01 CKJ Added
''                     popmessagecr Title$, "The outstanding amounts have been calculated for all drugs."
''                     ChangeTable "Blank"
''                  End If                                                           '30Nov01 CKJ Added
''            End If
''      End If                                                                       '   "
''
''   If locked5 Then AcquireLock filelock$ & "5.LCK", 0, 0  ' release
''   If locked7 Then AcquireLock filelock$ & "7.LCK", 0, 0  ' release
''   k.escd = False  'reset before exiting sub
''
''End Sub

Sub FindOutStanding()
'---------------------------------------------------------------------------------
'goes through requis file and adds outstanding qty to d.outstanding for each drug
'
'10Dec97 EAC called from high level Utilities menu
'            give oppotunity to back out before recalculating
'15Dec97 CKJ Added Acquirelocks
'30Nov01 CKJ Added safety check for record being all nulls
'            Writes c:\blankprd.log
'---------------------------------------------------------------------------------

Const title$ = "Update Outstanding Requisitions" '10Dec97 EAC

Dim pointer&, loopvar&, nod&, foundPtr&, X& ', find%    '01Jun02 ALL/ATW
Dim ord As orderstruct
Dim ans$, outstanding!, filelock$, locked5%, locked7%  'foundsup%,
Dim blnFatalError As Integer
Dim strMsg As String
Dim rsProducts As ADODB.Recordset
Dim rsOrders As ADODB.Recordset
''Dim objDataAccess As clsDataAccess
''Dim strParams As String
Dim lngFoundSup As Long
Dim strParams As String
Dim lngOK As Long


   blnFatalError = False
   locked5 = False
   locked7 = False
   filelock$ = dispdata$ & "\PRNTPCK"  'SQL Keep this locking ? Might not be a bad idea.
   askwin title$, "OK to update the outstanding amounts for all drugs?", ans$, k
   If ans$ = "Y" And Not k.escd Then
      AcquireLock filelock$ & "5.LCK", -2, locked5                  ' exclusive, keep trying
      If locked5 Then AcquireLock filelock$ & "7.LCK", -2, locked7  ' exclusive, keep trying
   End If

   If locked5 And locked7 Then
      Screen.MousePointer = HOURGLASS
   
      'set value of progress gauge and frame caption
      ChangeTable "Automatic Orders", False '14Aug12 TH Added Param
      MainScreen.LblGrid.Caption = title$
      MainScreen.Progress.Value = 0
      MainScreen.FrmGauge.Caption = "Setting all drugs to zero....    "
   
      ''getnod nod
      UpdateBar 0, 0, 0, 0
      'For x = 1 To nod
      'Set objDataAccess = New clsDataAccess
      'strParams = objDataAccess.CreateInputParameterXML("Site", trnDataTypeInt, 4, sitenumber)
      'Set rsProducts = objDataAccess.ADOExecuteSelectSP(g_SessionID, "pDrugsBySite", strParams)
      ''Set rsProducts = gTransport.ExecuteSelectSP(g_SessionID, "pDrugOutstandingbySite", "") ''SQL ATTENTION NEEDED !
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      'Set rsProducts = gTransport.ExecuteSelectSP(g_SessionID, "pWproductStockIDBySite", strParams)
      lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWproductStockSetOutstandingtozero", strParams)
      
      ''Set objDataAccess = Nothing
''      If Not rsProducts.EOF Then
''         loopvar = 1
''         Do While Not rsProducts.EOF
''            UpdateBar 1, (rsProducts.RecordCount), loopvar, ProgressBarScale
''            getdrug d, x, foundPtr&, True      '< LOCK   '01Jun02 ALL/ATW
''            getdrug d, GetField(rsProducts!WDrugsID), foundPtr&, True  '< LOCK  ''SQL ATTENTION NEEDED !
''            getdrug d, GetField(rsProducts!DrugParametersID), foundPtr&, True  '< LOCK
''            getdrug d, GetField(rsProducts!ProductStockID), foundPtr&, True  '< LOCK
''            d = FillDrugFromRS(rsProducts)
''            CastRecordsetToProduct rsProducts, d '18Oct04 TH
''            d.outstanding = 0
''            putdrugSQL d, GetField(rsProducts!DrugParametersID)            '< UNLOCK ''SQL ATTENTION NEEDED !
''            putdrug d                                          '   "
''
''            loopvar = loopvar + 1
''            rsProducts.MoveNext
''         Loop
''      End If
''      rsProducts.Close
''      Set rsProducts = Nothing
         
      If blnFatalError Then                                               '30Nov01 CKJ Only proceed if passed checking
         MainScreen.FrmGauge.Caption = ""                              '   "
         UpdateBar 0, 0, 0, 0                                          '   "
         ChangeTable "Blank", False '14Aug12 TH Added Param                                         '   "
      Else                                                             '   "
         'set value of progress gauge and frame caption
         MainScreen.FrmGauge.Caption = "Adding outstanding items....    "
         UpdateBar 0, 0, 0, 0
         
         'getnumofords 6, pointer&, False
         'Get the required orders using a suitable sp then cycle through
         ''Set objDataAccess = New clsDataAccess
         'strParams = objDataAccess.CreateInputParameterXML("Site", trnDataTypeInt, 4, sitenumber)
         'Set rsProducts = objDataAccess.ADOExecuteSelectSP(g_SessionID, "pDrugsBySite", strParams)
         '''Set rsProducts = gTransport.ExecuteSelectSP(g_SessionID, "pDrugsBySite", "")
         
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
         '& _ gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "6")
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisforOutstanding", strParams)

         ''Set objDataAccess = Nothing
         If rsOrders.RecordCount > 0 Then
            Do While Not rsOrders.EOF
            ''For loopvar& = 1 To pointer&
               UpdateBar 1, rsOrders.RecordCount, loopvar&, ProgressBarScale
               ord = FillOrdFromRS(rsOrders, "WRequis")
               d.SisCode = ord.Code
               'getdrug d, find, found, false
               getdrug d, 0, foundPtr&, True 'find, foundPtr&, True '< LOCK   '01Jun02 ALL/ATW
               If foundPtr& Then                          '01Jun02 ALL/ATW
                  LSet r = d                                                 '30Nov01 CKJ Added safety check for record being nulls
                  'If ord.status <> "R" And ord.status <> "7" And ord.status <> "D" Then    'ASC 4Aug92 added now that deletions are done over night  '16Jan98 EAC added Status <> "D"
                     getsupplier Trim$(ord.supcode), 0, lngFoundSup, sup
                     If (lngFoundSup > 0) And (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then     '16Jan98 EAC Added PrintinPacks
                        outstanding! = Val(ord.outstanding) / Val(d.convfact)
                     Else
                        outstanding! = Val(ord.outstanding)
                     End If
                     d.outstanding = d.outstanding + outstanding!
                  'End If
               
                  ''putdrugSQL d, foundPtr&              '< UNLOCK    '01Jun02 ALL/ATW
                  putdrug d
               End If '11Nov05 TH Moved from above putdrug
               rsOrders.MoveNext
               loopvar& = loopvar& + 1
            Loop
         End If
         rsOrders.Close
         Set rsOrders = Nothing
         Screen.MousePointer = STDCURSOR
      
         If Not blnFatalError Then                                           '30Nov01 CKJ Added
            popmessagecr title$, "The outstanding amounts have been calculated for all drugs."
            ChangeTable "Blank", False '14Aug12 TH Added Param
         End If                                                           '30Nov01 CKJ Added
      End If
   End If                                                                       '   "

   If locked5 Then AcquireLock filelock$ & "5.LCK", 0, 0  ' release
   If locked7 Then AcquireLock filelock$ & "7.LCK", 0, 0  ' release
   k.escd = False  'reset before exiting sub

End Sub

Function GetLocalCode$()

'14Jan98 EAC Written
'23Jul98 TH Added code to trap rogue d.local fields full of terminators

   If Trim$(d.local) = "" Then
      GetLocalCode$ = Trim$(d.SisCode)
   Else
      '23Jul98 TH added
      If Not Asc(Trim$(d.local)) <> 0 Then
         GetLocalCode$ = Trim$(d.SisCode)
      Else
         GetLocalCode$ = Trim$(d.local)
      End If
   End If

End Function

Sub issuepick(issuecost$, sitepaths As Integer, d As DrugParameters, Qty!, totalqty!, foundorder&)
' 1Jun93 ASC/CKJ fixed OVERFLOW when issuing zero & stock level is zero
' 6Jan95 CKJ Interoperability
' 5Mar95 CKJ Added ord.recdate to picking ticket issues
'14Oct97 EAC corrected updating of amount outstanding for part issues.
'10Dec97 EAC ensure d.outstanding is in NSVworths
'02Dec98 TH  Added check against site default to set issue to delete if delivery notes not needed
'07Dec98 TH  Merge From 806 03/04Dec98 TH : Ensure site defaults for not printing picket tickets are enforced
'04May99 TH  Index logging Merged from 8066
'13Jul99 SF/CFY added error trapping to attempt to catch the division by zero error
'05Aug99 TH  Logging code to try and catch rogue inters
'15Jan02 TH  Added time to orderlog (#53214)
'28May04 CKJ Close index
'25Jun08 TH  Added dispdata reset - failsafe to ensure correct dispdata is assigned if an error occurs
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitepaths param
'29Jul15 TH  Deal with possible exponential (TFS 102570)
'16Aug16 XN 160233 PrintDeliveryNote comes from Ward stock list now
'
'Note: 'Sup' must be current before calling
        
Dim oldoutstanding!, newoutstanding!, outstandingchange!
Dim pointer&
Dim tempord As orderstruct
Dim strSql As String
Dim blnOrderFound As Boolean
Dim rsOrders As ADODB.Recordset
Dim blnDLO As Boolean   '22Jun12 TH Added DLO

   On Error GoTo issuePickErr    '13Jul99 SF/CFY added

   Edittype = 6

   'Issue part of item ordered
   '--------------------------
   If Qty! <> totalqty! Or Qty! = 0 Then    '10th July ASC
      getorder ord, (foundorder&), Edittype, True         '<-LOCK record   (no idx)
      '20Mar93 ASC
      oldoutstanding! = Val(ord.outstanding) 'ASC
      If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks Then  '30Dec97 EAC
         ord.outstanding = LTrim$(Str$(dp!((totalqty! - Qty!) / Val(d.convfact))))
      Else
         ord.outstanding = LTrim$(Str$(dp!((totalqty! - Qty!))))
      End If
      newoutstanding! = Val(ord.outstanding) 'ASC
      outstandingchange! = newoutstanding! - oldoutstanding! 'ASC
         
      '30Dec97 EAC Prevent from dividing when Printing in Packs
      If Not PrintInPacks And (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") Then outstandingchange! = outstandingchange! / Val(d.convfact)   '14Oct97 EAC - correct for W,L type requisitions where orders are not in NSV's worths
      updateoutstanding outstandingchange!, d
      'makes this into a requisition for outstanding qty
      ord.status = "5"
      '7Jun93  ASC
      ord.tofollow = "1"
      foundorder& = PutOrder(ord, (foundorder&), "WRequis")                        '<-UNLOCK record (no idx)
      ord.tofollow = ""
      LSet tempord = ord '2Jun93 CKJ moved
      GoSub updateorderer

      'ASC 26Mar93 Add a record for delivery note printing
      '---------------------------------------------------
      'check setting
      'If Not UCase$(sup.PrintDeliveryNote) = "N" Then        '02Dec98 TH
      ''getnumofords 6, pointer&, True
      ''getorder ord, (pointer&), 5, True    '<-LOCK
      LSet ord = tempord
      'If UCase$(sup.PrintDeliveryNote) <> "N" Then         16Aug16 XN 160233 PrintDeliveryNote comes from Ward stock list now '03Dec98 TH check site setting
      'If IfRequiresDeliveryNote(ord.WWardProductListLineID) Then
      If IfRequiresDeliveryNote(ord.WWardProductListLineID, sup) Then '16Apr17 TH Allow none list reqs to print if required (TFS 181524)
         ord.status = "7"
      Else                                                     '03Dec98 TH
         If ord.internalmethod = "M" Then                      '03Dec98 TH
            ord.status = "8"              '==> SiteLink     '03Dec98 TH
         Else                                               '03Dec98 TH
            ord.status = "R"                                '03Dec98 TH
         End If                                             '03Dec98 TH
      End If                                                   '03Dec98 TH
      '!!** check d is the right one
      If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Then   '30Dec97 EAC added PrintInPacks
         ord.received = LTrim$(Str$(dp!(Qty!))) 'ASC Used for issued when status="7" 26May93 convfact added
      Else
         ord.received = LTrim$(Str$(dp!(Qty! / Val(d.convfact)))) 'ASC Used for issued when status="7" 26May93 convfact added
      End If
         
      'ord.outstanding = LTRIM$(STR$(VAL(ord.outstanding) - VAL(ord.received)))  !!** removed - calc done above 2Jun93 CKJ
      'ord.cost = LTrim$(Str$(dp!(Val(issuecost$))))
      ord.cost = LTrim$(ExpandExp$(Str$(dp!(Val(issuecost$))))) '29Jul15 TH Replaced above (TFS 102570)
      'ord.recdate = thedate(False, False) '5Mar95 CKJ Added
      'ord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
      ord.recdate = thedate(False, True)   '03May98 CKJ Y2K
      
      '22Jun12 TH Added DLO
      blnDLO = False
      If ord.DLO Then blnDLO = True
      ord.DLO = False
      ord.DLOWard = ""
      '22Jun12 TH
      
      pointer& = PutOrder(ord, 0, "WRequis")             '<-UNLOCK 'Force Insert
      
      If blnDLO Then '22Jun12 TH Added DLO
         popmessagecr "!EMIS Health", "You have chosen to issue a DLO line. This item can no longer be automatically issued on receipt."
      End If
      
      'updateordreqindex 5, "", Ord.code, "", Ord.num, (pointer&)
      '21Aug95 ASC
      'updateordreqindex 7, "", "", "", Ord.supcode, (pointer&)
      ''If ord.Status <> "R" Then                                         '03Dec98 TH
      ''      updateordreqindex 5, "", ord.code, "", ord.num, (pointer&)
      ''      If ReadPrivateIniFile(dispdata$ & "\winord.ini", "Logging", "PickingTickets") = "Y" Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, date & Time & " supcode : " & tempord.supcode & " recnum : " & Str$(pointer&) & " Adding index record from CreateRequisitionRec": IndexDebug = True '05Feb99 TH Debuggery '04May99 TH Merged from 8066
      ''      updateordreqindex 7, "", "", "", ord.supcode, (pointer&)
      ''      If IndexDebug Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, "Successful"   '06Feb99 TH Debuggery '04May99 TH Merge
      ''   Else                                                        '03Dec98 TH
      ''      updateordreqindex 5, "", ord.code, "", "", (pointer&)    '03Dec98 TH
      ''   End If                                                      '03Dec98 TH
      'End If                                              '03Dec98 TH

         '---
      'End If                                          '02Dec98 TH
      'endchek

   Else  '>>>>>>>>>>>>Issue whole quantity
      getorder ord, (foundorder&), Edittype, True  '<-LOCK record (no idx)
      'If UCase$(sup.PrintDeliveryNote) <> "N" Then           16Aug16 XN 160233 PrintDeliveryNote comes from Ward stock list now     '03Dec98 TH
      'If IfRequiresDeliveryNote(ord.WWardProductListLineID) Then
      If IfRequiresDeliveryNote(ord.WWardProductListLineID, sup) Then '16Apr17 TH Allow none list reqs to print if required (TFS 181524)
         ord.status = "7"
      Else                                                     '   "
         If ord.internalmethod = "M" Then                      '   "
            ord.status = "8"              '==> SiteLink     '   "
         Else                                               '   "
            ord.status = "R"                                '   "
         End If                                             '   "
      End If                                                   '   "
      ord.tofollow = ""  '10Jun93 CKJ
      'updateoutstanding -1! * Val(ord.outstanding), d 'ASC 20Mar93 10Dec97 EAC Commented out
      If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Then     '30Dec97 EAC added PrintInPacks
         ord.received = LTrim$(Str$(dp!(Qty!))) 'ASC Used for issued when status="7" 26May93 convfact added
         updateoutstanding -1! * (Val(ord.outstanding) / Val(d.convfact)), d 'ASC 20Mar93 10Dec97 EAC
      Else
         ord.received = LTrim$(Str$(dp!(Qty! / Val(d.convfact)))) 'ASC Used for issued when status="7" 26May93 convfact added
         updateoutstanding -1! * Val(ord.outstanding), d 'ASC 20Mar93 10Dec97 EAC
      End If
      'ord.cost = LTrim$(Str$(dp!(Val(issuecost$))))
      ord.cost = LTrim$(ExpandExp$(Str$(dp!(Val(issuecost$))))) '29Jul15 TH Replaced above (TFS 102570)
      ord.outstanding = "0"
      'ord.recdate = thedate(False, False) '5Mar95 CKJ Added
      'ord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
      ord.recdate = thedate(False, True)   '03May98 CKJ Y2K
      foundorder& = PutOrder(ord, (foundorder&), "WRequis")               '<-UNLOCK & replace record
      ''If ord.Status = "R" Then                                           '03Dec98 TH
      ''      'updateordreqindex 5, "", "", Ord.num, "", (pointer&)        '   "
      ''      'updateordreqindex 7, "", "", Ord.supcode, "", (pointer&)    '   "
      ''      updateordreqindex 5, "", "", ord.num, "", (foundorder&)      '04Dec98 TH
      ''      If ReadPrivateIniFile(dispdata$ & "\winord.ini", "Logging", "PickingTickets") = "Y" Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, date & Time & " supcode : " & tempord.supcode & " recnum : " & Str$(foundorder&) & " Adding index record from CreateRequisitionRec": IndexDebug = True '05Feb99 TH Debuggery '04May99 TH Merged from 8066
      ''      updateordreqindex 7, "", "", ord.supcode, "", (foundorder&)  '   "
      ''      If IndexDebug Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, "Successful"   '06Feb99 TH Debuggery  '04May99 TH Merge
      ''   End If                                                          '03Dec98 TH

      GoSub updateorderer
   End If

issuePickEnd:
   On Error GoTo 0
Exit Sub

'------------------------------------------------------------
updateorderer:

'ASC 27Mar93 update orderers machine for internalmethod = "I"
'If internalmethod = "M" then info contained in requis.asc
'status = 8 after delivery notes printed.
'------------------------------------------------------------
Dim saveedittype As Integer '15Mar12 TH (TFS 29264)
Dim searchordernum$, searchsis$
Dim cont&, found&
Dim presenttotalvalue!, newtotalvalue!, totqty!

   'issueing of internal orders
   'IF ord.internalmethod = "I" AND totalqty! > 0 AND qty! > 0 THEN
   If ord.internalmethod = "I" And Qty! > 0 Then  ' 12Jul93 CKJ do if any issued
      saveedittype = Edittype
      searchordernum$ = ord.num
      searchsis$ = ord.Code
      LSet tempord = ord
      'Look on orderers machine for order to add price and qty
      '-------------------------------------------------------
      'dispdata$ = "\dispdata." + RIGHT$("000" + trim$(ord.internalsiteno), 3)  '1Jun93 CKJ removed rtrim
      SetDispdata Val(ord.internalsiteno)   '6Jan95 CKJ

      Edittype = 3
      cont& = 0 '19Apr93 CKJ
      strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3") & _
                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                     gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, searchsis$) & _
                     gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(searchordernum$)) & _
                     gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                  
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderByCriteria", strSql)

      'If the orderer has deleted the item ordered create a new record
      '---------------------------------------------------------------
      ''If found& = 0 Then
      If Not rsOrders Is Nothing Then
         If rsOrders.State = adStateOpen Then
            If rsOrders.RecordCount <> 0 Then
               blnOrderFound = True
               'ord = FillOrdFromRS(rsOrders, "WOrder")
               getorder ord, RtrimGetField(rsOrders!WOrderID), 3, True '10Jan07 TH Lock Now
            Else
               
            End If
         End If
       End If
      If Not blnOrderFound Then
         LSet ord = tempord 'pick up all info from requis.asc
         ord.OrderID = 0 'SQL Ensure this will be inserted !!!
         ord.status = "3"
         ord.pickno = 0
         ord.supcode = "INTER"
         ord.orddate = thedate(False, True)   '03May98 CKJ Y2K
         ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
         ord.internalmethod = "I"
         ord.internalsiteno = LTrim$(Str$(sitepaths))
         ord.outstanding = LTrim$(Str$(Val(ord.outstanding) + Val(ord.received)))
         ord.received = "0"        '14Jul93 ASC/CKJ added
         ''''found& = PutOrder(ord, 0, "WOrder")              '<-UNLOCK
         LookupDrug ord.Code, d, (found) '14Jan94 CKJ Added
         'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", ord.supcode, "O", sitepaths, "", d.vatrate, "", "", ""
         'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", ord.supcode, "O", sitepaths, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
         Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", ord.supcode, "O", sitepaths, "", d.vatrate, "", "", "", "", ord.PSORequestID '04Mar14 TH Added PSORequestID
      End If
      'get the corresponding order from the orderer and update the price and
      'recieve qty (rembember one order for one item may be issued in two or
      'more parts) before orderer receives goods
      rsOrders.Close
      Set rsOrders = Nothing
      '''getorder ord, (found&), edittype, True  '<-LOCK
      'SQL TO DO if ord.OrderID > 0 then LockeEcord here !!
      presenttotalvalue! = Val(ord.received) * Val(ord.cost)
      'NB The d.convfact is CORRECT: it is the stores pack size (qty! issued in tabs)
      If (sup.suppliertype = "W" Or sup.suppliertype = "L") And Not PrintInPacks Then   '30Dec97 EAC added PrintInPacks
         newtotalvalue! = dp!(Qty!) * Val(issuecost$)  '23Jun93 CKJ dp
         totqty! = dp!(Qty!) + Val(ord.received)       '23Jun93 CKJ dp
      Else
         newtotalvalue! = dp!(Qty! / Val(d.convfact)) * Val(issuecost$) '23Jun93 CKJ dp
         totqty! = dp!(Qty! / Val(d.convfact)) + Val(ord.received)      '23Jun93 CKJ dp
      End If
      ord.cost = LTrim$(Str$(dp!((presenttotalvalue! + newtotalvalue!) / totqty!)))
      ord.received = LTrim$(Str$(dp!(totqty!)))
      'set ord.outstanding too? No, it remains outstanding until actually received
      'found& = PutOrder(ord, (found&), "Orders")                  '<-UNLOCK
      found& = PutOrder(ord, ord.OrderID, "WOrder")
      'dispdata$ = "\dispdata." + RIGHT$("000" + LTRIM$(STR$(sitepaths)), 3)
      'dispdata$ = sitepth$(0)                  '6Jan95 CKJ
      SetDispdata (0)
      Edittype = saveedittype
   End If
Return


issuePickErr:
   SetDispdata (0) '25Jun08 TH Added - failsafe to ensure correct dispdata is assigned if an error occurs
   popmessagecr ".EMIS Health", "Error: " & Format$(Err) & " " & Error$ & cr & cr & "NSV code: " & d.SisCode & cr & "ROP: " & d.convfact & cr & "Qty: " & Format$(Qty!) & cr & "TotQty: " & Format$(totqty!) & cr & dispdata$ & cr & cr & "See your system supervisor"
   WriteLog dispdata$ & "\picktick.log", 0, UserID$, "Error: " & Format$(Err) & " " & Error$ & cr & cr & "NSV code: " & d.SisCode & cr & "ROP: " & d.convfact & cr & "Qty: " & Format$(Qty!) & cr & "TotQty: " & Format$(totqty!) & "  " & dispdata$
Resume issuePickEnd

'13Jul99 SF/CFY -----
End Sub


Sub MainOptions(mnuans$, sitepaths As Integer, ByVal blnPSO As Boolean)
'05Mar98 ASC/EAC moved gauge update code to procedure CheckLevels
'05May98 CKJ Removed paydate$ & invoicenum$ from DisplayOrders param list,
'            as these are only used in reconciliation
'            These can now be added as a second line to lblGrid, separated by 'cr'
'13Aug98 SF      Now displays supplier code in amend orders caption
'30Oct98 EAC add titles to screens for individual requisitions/picking tickets
'19Nov98 TH  Code to put supplier name and code on amend order screen
'26Jan99 TH  Replaced Tag with global to avoid referencing problems
'11Oct99 CKJ Removed Findsupplier
'18Apr00 CFY Now prompts user for Customers own order number if feature is enabled
'05Jul00 TH  Clear txtinput for supplemantary orders
'14Jan02 TH  Replaced sort on indexes (before auto order) so it uses post 8.1 indexes (hmmm - just general tidy up) (#58205)
'25Feb02 TH  Added parameter for entercustordno (enh1585)
'17Sep10 TH  Cache the order num in case the user escapes at the entry box (incase there is a valid order in there, like on a right click (F0096620)
'01Jun11 CKJ Added as integer to sitepaths param
'16Jul12 TH  Changed wording of DLO msg (TFS 38658)
'14Aug12 TH  Added PSO Flag Parameter (TFS 41431,42771,42773)
'14Oct05 TH  Added to ensure correct sizing of table (TFS 51480)
'29Sep15 TH  Ensure there is no possibility of previous supplier being used on receipt display (TFS 127190)

ReDim lines$(OTblMaxCols + 1)
Dim ked As kbdcontrol            '{SP2} Why?
Dim ans$, cycle$, cyc$           '27Jun11 CKJ removed OASCcode$(), ORecNo&(), Oordering$()
Dim cyl%, phase%, char%, valid%, ch%, exitloop%
Dim sup As supplierstruct '16Nov98 TH         {SP2} not convinced this is in scope
Dim temp$
Dim sCustOrdNo As String
Dim lngOrderID As Long
Dim strCachedOrdernum As String '17Sep10 TH Added (F0096620)
'Dim Lines() As String
Dim strDLOWard As String  '20Jun12 TH DLO
Dim strTmpordernum  As String '13Jul12 TH Added (TFS)

   setinput 0, k
   k.escd = False
   
   Select Case mnuans$
      Case "1"  'Process Automatic orders
         ChangeTable "Blank", False '14Aug12 TH Added Param (TFS 42771,42773)
         
         Edittype = 1
         
         ans$ = ""
         setinput 0, ked
         ked.helpnum = 10
         ked.validchars = "12"
         'frmoptionset -1, "Create Automatic Stock Orders"
         frmoptionset -1, "Automatic Order creation" '10Aug05 TH (#81783)
         frmoptionset 1, "Re-order level method"
         frmoptionset 1, "Cyclical Ordering"
         frmoptionshow "1", ans$
         frmoptionset 0, ""

         If Trim$(ans$) = "" Then ked.escd = True
         ked.validchars = ""
      
         If Not ked.escd Then
            cycle$ = ""

            If ans$ = "2" Then
               k.Max = 20
               InputWin "", "Enter order cycle number(s)   ", cycle$, k
               cyc$ = ""
               cyl = Len(cycle$)
               phase = 0
               If cyl = 0 Then
                  k.escd = True
               Else
                  For ch = 1 To cyl
                     char = Asc(UCase$(Mid$(cycle$, ch, 1)))
                     valid = False
                     Select Case char
                        Case 48 To 57, 65 To 90: valid = True '0-9, A-Z
                        End Select
                     If valid Then
                        Select Case phase
                           Case 0, 1
                              cyc$ = cyc$ + Chr$(char)
                              phase = phase + 1
                        End Select
                     Else
                        If phase > 0 Then
                           phase = 0
                           cyc$ = cyc$ + ","
                        End If
                     End If
                  Next
               End If
            End If
                    
            Screen.MousePointer = HOURGLASS

            If Not k.escd Then
               checklevels cyc$
            End If
            Screen.MousePointer = STDCURSOR
         End If
         ChangeTable "Blank", False '14Aug12 TH Added Param
    
      Case "2" 'Amend orders
         Edittype = 1
         osite$ = "A"
         entersite Edittype, AmendOrdersDisplay$, AmendOrdersCode%, blnPSO '15Nov12 TH Added PSO parameter
         If Not k.escd Then
            MainScreen.MousePointer = HOURGLASS
            blankorder ord
            Clearprintedorders
            If freestock Then Edittype = 10 '25Nov98 TH
            DisplayOrders Edittype, blnPSO  '27Jun11 CKJ Removed unused args: ordernum$, , osite$, sitepaths%, "", "", OASCcode$(), ORecNo&(), Oordering$()
            'ChangeTable "Blank"
            If freestock Then temp$ = " Free"     '26Nov98 TH
            If blnPSO Then temp$ = " Patient Specific"
            MainScreen.LblGrid.Caption = "Amend Orders to Supplier " & Trim$(osite$)  '13Aug98 SF
            'If MainScreen.lvwMainScreen.Tag <> "" Then
            If scrnmsg$ <> "" Then '26Jan99 TH replaced
               MainScreen.LblGrid.Caption = "Amend" & temp$ & " Orders to Supplier " & Trim$(scrnmsg$)     '26Jan99 TH replaced
            Else                                                                                           '19Nov98 TH
               MainScreen.LblGrid.Caption = "Amend" & temp$ & " Orders to Supplier " & Trim$(osite$)                  '19Nov98 TH
            End If                                                                                         '19Nov98 TH
            PositionLblGrid
            MainLVWHighlightSingleRowByIndex 1
            MainScreenSetTextAndPanels Edittype
            MainScreen.lvwMainScreen.SetFocus
            MainScreen.MousePointer = STDCURSOR
         End If
         'MainScreen.lvwMainScreen.Tag = ""        '19Nov98 TH
         scrnmsg$ = "" '26Jan99 TH replaced
         
      Case "3" 'Authorise and raise
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Edittype = 1
         Do While Not exitloop
            'SQL ForgetPrinterList
            On Error Resume Next 'TH Blackhat fix #77960
            Unload LstBoxFrm
            On Error GoTo 0      '   "
            Selectforsupplier 1, sitepaths, exitloop, blnPSO
         Loop
         k.escd = False

      Case "4" 'Receive Goods
         Edittype = 3
         osite$ = "A"
         strCachedOrdernum = ordernum$ '17Sep10 TH Added (F0096620)
         enterorder Edittype, False, blnPSO
         
         If Not k.escd Then
            MainScreen.MousePointer = HOURGLASS
            'ChangeTable "blank", False  '14Aug12 TH Added Param  '14Oct05 TH Added to ensure correct sizing of table (TFS 51480)
            ChangeTable "blank", blnPSO  '21Aug12 TH Now use PSO
            Clearprintedorders
            scrnmsg$ = "" '29Sep15 TH Ensure there is no possibility of previous supplier being used (TFS 127190)
            'DisplayOrders edittype, False  '27Jun11 CKJ Removed unused args: ordernum$, , "A", SiteNumber, "", "", OASCcode$(), ORecNo&(), Oordering$()
            DisplayOrders Edittype, blnPSO  '21Aug12 TH Now use PSO
            If Trim$(scrnmsg$) <> "" Then  '26Jan99 TH Replaced
               If Trim$(ordernum$) <> "A" Then MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " for Order " & Trim$(ordernum$) & " - Supplier " & Trim$(scrnmsg$)  '26Jan99 TH
            Else
               If Trim$(ordernum$) <> "A" Then MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " for Order " & Trim$(ordernum$)
            End If
            '-DLO For
            'strDLOWard = Trim$(GetOrderDLOWard(clng(ordernum$)))
            strDLOWard = Trim$(GetOrderDLOWard(Val(ordernum$))) '28Jun12 TH (TFS) Replace above
            If strDLOWard <> "" Then
               MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & crlf & "Direct Location Order for " & strDLOWard
               PositionLblGrid '28Jun12 TH Added
            End If
            
            '16Aug11 TH Do we have a delivery note ref number in reference. If so we display
            If Trim$(getDeliveryNoteReference()) <> "" And Trim$(ordernum$) <> "A" Then
               MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & crlf & "Delivery ref : " & Trim$(getDeliveryNoteReference())
               PositionLblGrid
            End If
            scrnmsg$ = ""   '26Jan99 TH
            PositionLblGrid
            MainLVWHighlightSingleRowByIndex 1
            MainScreenSetTextAndPanels Edittype
            MainScreen.TxtInput.SetFocus
            MainScreen.MousePointer = STDCURSOR
         Else                                '17Sep10 TH Added (F0096620)
            ordernum$ = strCachedOrdernum    '      "
         End If
    
      Case "5"  'Enter amend requisitions
         Edittype = 5
         entersite Edittype, EnterReqDisplay$, EnterReqCode%, False '15Nov12 TH Added PSO param
         If Not k.escd Then
            'EnterCustOrdNo                            '18Apr00 CFY Added
            ChangeTable "blank", False  '14Aug12 TH Added Param  '04May06 TH Added
            If osite$ <> "A" Then EnterCustOrdNo False    '25Feb02 TH Added parameter (enh1585)'26Aug05 TH added check (#80780)
            MainScreen.MousePointer = HOURGLASS
            Clearprintedorders
            DisplayOrders Edittype, False  '27Jun11 CKJ Removed unused args: ordernum$, , osite$, sitepaths, "", "", OASCcode$(), ORecNo&(), Oordering$()
            MainScreen.lvwMainScreen.SetFocus
            MainScreen.LblGrid.Caption = "Amend Requisitions"
            If Trim$(osite$) <> "" And osite$ <> "A" Then
               If scrnmsg$ <> "" Then
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " for " & scrnmsg$ & " "
               Else
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " (" & osite$ & ") "
               End If
            End If
            If Trim$(ordernum$) <> "A" And Trim$(ordernum$) <> "F" Then
               MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " for Requisition " & Trim$(ordernum$)   '30Oct98 EAC add titles to screens for individual requisitions/picking tickets
               sCustOrdNo = GetCustOrdNo()                                                                                          '18Apr00 CFY Added
               If Trim$(sCustOrdNo) <> "" Then                                                                                      '         "
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & crlf & "Customer Order No: " & Format$(sCustOrdNo)   '         "
               End If                                                                                                            '         "
            End If
            
            PositionLblGrid
            MainLVWHighlightSingleRowByIndex 1
            MainScreenSetTextAndPanels Edittype
            MainScreen.MousePointer = STDCURSOR
         End If
    
      Case "6"       'Print picking tickets
         Edittype = 5
         Do While Not exitloop
            printpick sitepaths, 5, "", "", exitloop%
         Loop
    
      Case "7"       'Issue Picking Tickets
         Edittype = 6
         strTmpordernum = ordernum$
         enterorder Edittype, True, False

         If Not k.escd Then
            MainScreen.MousePointer = HOURGLASS
            '''Clearprintedorders
            '''DisplayOrders ordernum$, edittype, "A", SiteNumber, "", "", OASCcode$(), ORecNo&(), Oordering$()
            ''If Trim$(ordernum$) <> "A" And Trim$(ordernum$) <> "F" Then MainScreen.LblGrid.Caption = "Issue Items from Picking Ticket No. " & Trim$(ordernum$) '30Oct98 EAC add titles to screens for individual requisitions/picking tickets
            If Trim$(ordernum$) <> "A" And Trim$(ordernum$) <> "F" Then
               sup = getSupFromOrderNum(ordernum$, "WRequis")
               If Trim$(sup.name) <> "" Then
                  MainScreen.LblGrid.Caption = "Issue Items from Picking Ticket No. " & Trim$(ordernum$) & " (" & Trim$(sup.name) & ")"
               Else
                  MainScreen.LblGrid.Caption = "Issue Items from Picking Ticket No. " & Trim$(ordernum$)
               End If
               If GetPickingTicketDLO(CLng(ordernum$)) Then
                  
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " - Direct Location Order"
                  'popmessagecr "!Ascribe", "This is a DLO Picking Ticket - Items should only be issued automatically upon receipt"
                  popmessagecr "!EMIS Health", "This is a DLO Picking Ticket - items will be issued automatically upon receipt"  '16Jul12 TH(TFS 38658)
               End If
               
            End If
            
            MainLVWHighlightSingleRowByIndex 1
            MainScreenSetTextAndPanels Edittype
            MainScreen.lvwMainScreen.SetFocus
            MainScreen.MousePointer = STDCURSOR
         Else
            ordernum$ = strTmpordernum  '13Jul12 TH Added (TFS)
         End If
    
      Case "8" 'Print delivery notes
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Edittype = 7
         Do While Not exitloop
            printpick sitepaths, 7, "", "", exitloop
         Loop
    
      Case "9" 'Return to supplier
         Edittype = 9
         'entersite edittype, SupplierRetDisplay%, SupplierRetCode%
         entersite Edittype, SupplierRetDisplay$, SupplierRetCode%, False '15Nov12 TH Added PSO param
         If Not k.escd Then
            MainScreen.MousePointer = HOURGLASS
            Clearprintedorders
            DisplayOrders Edittype, False  '27Jun11 CKJ Removed unused args: "A", , osite$, sitepaths%, "", "", OASCcode$(), ORecNo&(), Oordering$()
            'MainScreen.LblGrid.Caption = "Enter/Amend Credits to Supplier " & Trim$(OSite$)           '19Feb99 TH Replaced
            If scrnmsg$ <> "" Then                                                                     '   "
               MainScreen.LblGrid.Caption = "Enter/Amend Credits to Supplier " & Trim$(scrnmsg$)    '   "
            Else                                                                                    '   "
               MainScreen.LblGrid.Caption = "Enter/Amend Credits to Supplier " & Trim$(osite$)      '   "
            End If
            
            scrnmsg$ = ""                                                                             '   "
            PositionLblGrid
            MainLVWHighlightSingleRowByIndex 1
            MainScreenSetTextAndPanels Edittype
            MainScreen.lvwMainScreen.SetFocus
            MainScreen.MousePointer = STDCURSOR
         End If
    
      Case "10" 'Print credit notes
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Edittype = 9
         Do While Not exitloop
            'findsupplier foundsup, supcode$, False, False, sup      '11Oct99 CKJ Removed
            getsupplier supcode$, 0, 0, sup            '   "        added

            printpick sitepaths, 9, "", "", exitloop
         Loop

      Case "11"  'Return to store
         ChangeTable "blank", False '14Aug12 TH Added Param
         Edittype = 0
         ReturnToStore sitepaths
   
      Case "12"  'Authorize supplementary order
         osite$ = "A"
         Edittype = -3
         Clearprintedorders
         'Remove panels and clear the input box
         BlankOrderInfoScreens
         MainScreen.TxtInput.text = ""
         
         enterorder Edittype, True, False
         
         If Not k.escd Then
            If ordernum$ = "A" Then
               popmessagecr "!Supplementary Order", "No order number entered"
               ChangeTable "Blank", False '14Aug12 TH Added Param
            Else
               '22Jun12 TH Check if "DLO" Order
               If Trim$(GetOrderDLOWard(Val(ordernum$))) <> "" Then
                  popmessagecr "!EMIS Health", "Order : " & ordernum$ & " is a Direct Location Order. You cannot add to a Direct Location Order"
                  ChangeTable "Blank", False '14Aug12 TH Added Param
               Else
                  MainScreen.LblGrid.Caption = "Add Supplementary Items for Order " & Trim$(ordernum$)
                  sup = getSupFromOrderNum(ordernum$, "WOrder")
                  If Trim$(sup.Code) = "" Then sup = getSupFromOrderNum(ordernum$, "WReconcil")
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " (" & Trim$(sup.name) & ")"
                  MainScreen.lvwMainScreen.SetFocus
                  MainLVWHighlightSingleRowByIndex 1
                  MainScreenSetTextAndPanels Edittype
               End If
            End If
         Else
            ChangeTable "Blank", False '14Aug12 TH Added Param
         End If
         'AddToOrder sitepaths
   
      End Select
    
End Sub

Sub MinOrderValue(ByVal i_strPrimarySupplierCode As String, ByRef blnAutoSelect As Boolean)
'22Apr02 SF added (enh#1555)
'           Lists all stocked products with the same primary supplier as the given NSVCode and sorts
'           by stock level in ascending order then reorder level in descending order.
'26Apr02 SF mods to use the given supplier code than that held against the product.  Not commented as original not released to site.
'27May11 XN F087364 Allowed amend orders screen to display F4 screen (using callback to MinOrderValue_LstBoxFrm_KeyUp)

Const cCaption = "Minimum Order Value"
Const cDefaultLinesToDisplay = "50"

Dim udtDrug As DrugParameters
Dim udtSupplier As supplierstruct
Dim strSelection() As String
Dim strLine As String, strEntry As String, strProduct As String, strPrimarySupplierCode As String, strPrimarySupplierName As String
Dim strError As String
Dim lngCount As Long, lngNod As Long, intMatch  As Integer, intHeapID As Integer, intSuccess As Integer, intLinesToDisplay As Integer '01Jun02 ALL/ATW    intFound As Integer,
Dim lngReorderLvl As Long, lngStockLvl As Long
Dim foundPtr As Long    '01Jun02 ALL/ATW
Dim blnFound As Integer '01Jun02 ALL/ATW
Dim lngFoundSup As Long
Dim rsDrugs As ADODB.Recordset
Dim strParams As String

   ' initialise the heap for storage
   Heap 1, intHeapID, "", "", intSuccess
   If Not intSuccess Then
      popmessagecr "#" & cCaption, "Cannot create heap for storage"
      Exit Sub
   End If

   On Error GoTo mov_ErrorHandler

   Screen.MousePointer = HOURGLASS
   
   strPrimarySupplierCode = Trim$(UCase$(i_strPrimarySupplierCode))
   getsupplier strPrimarySupplierCode, 0, lngFoundSup, udtSupplier
   If lngFoundSup > 0 Then
      strPrimarySupplierName = " (" & Trim$(udtSupplier.fullname) & ")"
   Else
      strPrimarySupplierName = " (*** Supplier information not found ***)"
   End If

   ' number of products
   'SQL getnod lngNod                                     '01Jun02 ALL/ATW

   ' build up a list of relevant products
   intMatch = 0
   intSuccess = True
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strPrimarySupplierCode)
               
   Set rsDrugs = gTransport.ExecuteSelectSP(g_SessionID, "pWProductsbyLocationID_SiteandSupcodeForMinOrderValue", strParams)
   If rsDrugs.RecordCount > 0 Then
      rsDrugs.MoveFirst
      Do While Not rsDrugs.EOF
         ''For lngCount = 1 To lngNod                        '01Jun02 ALL/ATW
         lngCount = rsDrugs!productstockID
         getdrug udtDrug, lngCount, foundPtr&, False   '01Jun02 ALL/ATW
         ''If (udtDrug.inuse <> "N") And (udtDrug.sisstock = "Y") And (Trim$(UCase$(udtDrug.supcode)) = strPrimarySupplierCode) Then
         lngReorderLvl = Val(udtDrug.reorderlvl)
         lngStockLvl = Val(udtDrug.stocklvl)

         ' work out priority band
         If lngReorderLvl = 0 Then
          ' lowest priority
            strEntry = "9999"
         ElseIf lngStockLvl < 1 Then
            ' highest priority
            strEntry = "0000"
         Else
            ' somewhere in the middle
            strEntry = Format$(Int(5000 * (lngReorderLvl / lngStockLvl)), "0000")
            If Val(strEntry) > 9999 Then strEntry = "9999"
            If Val(strEntry) < 1 Then strEntry = "0000"
         End If
         intMatch = intMatch + 1
         strEntry = strEntry & udtDrug.SisCode
          
         ' build up the line to display
         'strProduct = Trim$(udtDrug.storesdescription) XN 4Jun15 98073 New local stores description
         'If Len(strProduct) = 0 Then strProduct = Trim$(udtDrug.Description)
                 strProduct = Trim$(udtDrug.DrugDescription)
         plingparse strProduct, "!"
            
         strLine = udtDrug.SisCode & TB & strProduct & TB & Format$(udtDrug.convfact) & TB & Format$(udtDrug.stocklvl) & TB & Format$(udtDrug.reorderlvl) & TB & Format$(Val(udtDrug.cost) / 100, "#0.00") & TB
         'strLine = strEntry & TB & strLine    ' debug ratios only
      
         ' add the line to the heap
         Heap 10, intHeapID, strEntry, strLine, intSuccess
            
         If Not intSuccess Then
            ' a problem adding to heap so exit
            intMatch = 0
            Exit Do
         End If
         '' End If
         ''Next
         rsDrugs.MoveNext
      Loop
   End If
   rsDrugs.Close
   Set rsDrugs = Nothing

   If intMatch > 0 Then
      ' build up the header information to display
      '16Oct05 TH Move title to caption bar
      LstBoxFrm.Caption = "Other products available with the primary supplier: " & strPrimarySupplierCode & strPrimarySupplierName
      'LstBoxFrm.lblTitle = cr & "Other products available with the primary supplier: " & strPrimarySupplierCode & strPrimarySupplierName & cr
      LstBoxFrm.lblTitle = ""
      LstBoxFrm.lblHead = "NSVCode  " & TB & "Description " & Space$(50) & TB & "Pack Size" & TB & "Stock Level  " & TB & "Reorder Level" & TB
      LstBoxFrm.lblHead = LstBoxFrm.lblHead & "Pack Size Cost (" & money$(5) & ")" & Space$(80) & TB '09May05 TH Added 50 spaces to boost width (#79789)
      ' number of lines to display
      intLinesToDisplay = Val(TxtD$(dispdata$ & "\Winord.ini", "Defaults", cDefaultLinesToDisplay, "LowStockDisplayMaxLines", blnFound))
      If intMatch > intLinesToDisplay Then
         ' restrict display to the n lines
         intMatch = intLinesToDisplay
      End If

      ' XN 27May11 F087364 Allowed amend orders screen to display F4 screen (using callback to MinOrderValue_LstBoxFrm_KeyUp)
      LstBoxFrm.SetKeyUpCallBackProc AddressOf MinOrderValue_LstBoxFrm_KeyUp
          
      ' build up product list to display
      strEntry = ""
      For lngCount = 1 To intMatch
         Heap 13, intHeapID, strEntry, strLine, intSuccess             ' get next heap entry
         If intSuccess Then
            LstBoxFrm.LstBox.AddItem strLine
         Else
            ' signifies end of heap entries
            Exit For
         End If
      Next
            
      ' display to the user
      Screen.MousePointer = STDCURSOR
      LstBoxShow
      If LstBoxFrm.LstBox.ListIndex > -1 Then
         ReDim strSelection(6)
         strLine = LstBoxFrm.LstBox.text
         deflines strLine, strSelection(), TB, 1, 0
         If TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "Defaults", "Y", "MinOrderValueAutoSelect", blnFound)) Then
            ' NSV Code
            strLine = strSelection(1)
            'set a Flag for auto selection
            blnAutoSelect = True
         Else
            ' copy selected NSV Code to the clipboard
            ReDim strSelection(6)
            strLine = LstBoxFrm.LstBox.text
            deflines strLine, strSelection(), TB, 1, 0
            Clipboard.SetText strSelection(1)                  ' NSV Code
            strLine = strSelection(2)                          ' Description
            popmessagecr "#" & cCaption, strLine & " copied to clipboard"
         End If
      End If
          
      Unload LstBoxFrm
      If blnAutoSelect Then
         MainScreen.TxtInput.text = strLine
         'MainScreen.TxtInput_KeyDown
      End If

   Else                                      ' no display to the user
      Screen.MousePointer = STDCURSOR
      If Not intSuccess Then                 ' no products to display
         popmessagecr "." & cCaption, "Too much data to store, cannot display the list"
      Else                                   ' error
         popmessagecr "#" & cCaption, "No other products stocked under the primary supplier: " & strPrimarySupplierCode & strPrimarySupplierName
      End If
   End If


mov_CleanUp:
    Heap 2, intHeapID, "", "", intSuccess    ' destroy the heap
    On Error GoTo 0
    Exit Sub

mov_ErrorHandler:
    Screen.MousePointer = STDCURSOR
    strError = Error$
    If Err = 14 Then
         popmessagecr "." & cCaption, "Too many products to display"
      Else
         popmessagecr "." & cCaption, "Error: " & strError & Space$(50)
      End If
    Resume mov_CleanUp

End Sub

Private Sub MinOrderValue_LstBoxFrm_KeyUp(ByVal KeyCode As Long, ByVal Shift As Long, ByVal nUnused3 As Long, ByVal nUnused4 As Long)
' XN 27May11 F087364
' Called (via call back when LstBoxFrm KeyUp event is fired.
' If the key pressed is F4 then displays the drug enquiry form

Dim strSelection(6) As String
Dim strNSVCode      As String
Dim blnFound        As Integer
    
   If (KeyCode = KEY_F4) Then
      If LstBoxFrm.LstBox.ListIndex > -1 Then
         deflines LstBoxFrm.LstBox.text, strSelection(), TB, 1, 0
         strNSVCode = strSelection(1)
         DisplayDrugEnquiry strNSVCode, SiteNumber    '08Jul11 XN was gDispSite
      End If
   End If
    
End Sub

Sub OrdersPrint(OrdNum As String, sup As supplierstruct, Edittype As Integer, SortType As Integer, ByVal strCaption As String)
'06Dec16 TH  Replaced RTF handling (TFS 157969)
'04Jan17 TH  Ensure rtf Handling uses local file (TFS 157969)
'05Jan17 TH  Refactored RTF handling (TFS 157969)
Const cMaxLines = 300

Dim X&, pointer&, recnum&
Dim rTotalCost As Single, rCost As Single
Dim Selected As Integer, success As Integer
Dim iTmpFileNo As Integer, iRecCount As Integer, iSortKeyLen As Integer '', iFoundSup As Integer
Dim sMsg As String, sErrMsg As String, sSortString As String, sTmpFile As String, sRTFTxt As String, sRTFLayout As String
Dim sPgHdr As String, sPgItem As String, sPgEnd As String, sDetailLine As String, sContext As String
Dim ord As orderstruct
Dim rTotalCostIncOnCost As Single, rCostIncOnCost As Single

Dim foundPtr As Long
Dim rsDrugs        As ADODB.Recordset
Dim rsOrders       As ADODB.Recordset
Dim strSql         As String
Dim intSuccess As Integer '05Jan17 TH

   'Pre-Condition check. Should never happen !!!
   If (Edittype <> 1) And (Edittype <> 4) Then
      sMsg = "Internal Error. " & crlf & crlf & "Storeasc: OrdersPrint has been called with an invalid edittype"
      sMsg = sMsg & "Please contact your System Supervisor"
      popmessagecr "!", sMsg
      Exit Sub                   '<== WAY OUT!!
   End If
   
   Screen.MousePointer = HOURGLASS
   
   'Check rtf layout exists, if so read into memory and split into components
   Select Case Edittype
      Case 1
         sRTFLayout = "\PreOrder.rtf"
         sContext = "PreOrder"
      Case 4
         sRTFLayout = "\GdsRcvd.rtf"
         sContext = "GdsRcvd"
   End Select
   GetRTFTextFromDB dispdata$ & sRTFLayout, sRTFTxt, intSuccess '05Jan17 TH Moved from below to utilise check (Hosted)
   'If fileexists(dispdata$ & sRTFLayout) Then
   If intSuccess Then
      'GetTextFile dispdata$ & sRTFLayout, sRTFTxt, 0
      'GetRTFTextFromDB dispdata$ & sRTFLayout, sRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)
      SplitFile sRTFTxt, sPgHdr, sPgItem, sPgEnd
   Else
      'popmessagecr "!", "Could not print report. File " & dispdata$ & sRTFLayout & " not found"
      popmessagecr "!", "Could not print report. RTF " & sRTFLayout & " not found in database"
      Exit Sub                   '<== WAY OUT!!
   End If
   
   '''getnumofords edittype, pointer&, False
   
   'Just in case we don't have enough memory banks left in the computron.
   'Reserve a moderate amount of space to start of with so that we don't have to redim preserve for every record
   'we find.
   On Error GoTo OrderPrint_Err
   ReDim LinesForPrint(cMaxLines) As String
   On Error GoTo 0

   'Loop through the index and store the records we're interested in.
   iRecCount = 0
   
   Select Case Edittype
      Case 1
         'strSql = gTransport.CreateInputParameterXML("Status", trnDataTypeInt, 4, edittype) & _
         '         gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, sup.Code)
         strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1") & _
                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, sup.Code) & _
                  gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                  gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(OrdNum)) & _
                  gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
               
         'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderByStatusandSupcode", strSql)
          Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderByCriteria", strSql)
      Case 4
         'If Val(OrdNum) > 0 Then
         strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "4") & _
                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                  gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(OrdNum)) & _
                  gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
         'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconilbyStatusandNumwithQty", strSql)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteria", strSql)
''         Else:
''            'strSql = gTransport.CreateInputParameterXML("Status", trnDataTypeInt, 4, edittype)
''            strSql = gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "4") & _
''                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
''                     gTransport.CreateInputParameterXML("Num", trnDataTypeVarChar, 10, 0) & _
''                     gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
''                     gTransport.CreateInputParameterXML("StartID", trnDataTypeInt, 4, 0) & _
''                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeInt, 4, 0)
''            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaINVOICE", strSql)
''         End If
   End Select
   ''strSQL = "Select * from [Order]"
   ''If gTransport.GetRecordset(strSQL, rsOrders) Then
  '' Set gTransport = Nothing
   ''If rsOrders.RecordCount > 0 Then
      
   If rsOrders.RecordCount > 0 Then
      rsOrders.MoveFirst
      Do While Not rsOrders.EOF
         Select Case Edittype
            Case 1: ord = FillOrdFromRS(rsOrders, "WOrder")
            Case 4: ord = FillOrdFromRS(rsOrders, "WReconcil")
         End Select
            '''Do While x& <= pointer&
         ''x& = x& + 1
         If Edittype = 4 Then
            X& = rsOrders!WReconcilID
         Else
            X& = rsOrders!WOrderID
         End If
            '''getorder ord, x&, edittype, False
            Selected = False
            If ord.status = LTrim$(Str$(Edittype)) Then
               Selected = True
               If Edittype = 1 Then
                  If sup.Code <> ord.supcode Then
                     Selected = False
                  End If
               End If
               If Edittype = 4 Then
                  If Val(ord.qtyordered) < 0 Then                       'Check that its not a credit
                     Selected = False
                  End If
                  If Trim$(OrdNum) <> "" Then                           'Check if the order number matches
                     If Trim$(OrdNum) <> trimz(ord.num) Then
                        Selected = False
                     End If
                  End If
               End If
            End If
            
      If Selected Then
         iRecCount = iRecCount + 1
         
         'Memory check again. If we didn't reserve enough space to start then allocate a little more...
         On Error GoTo OrderPrint_Err
         If iRecCount > cMaxLines Then
            ReDim Preserve LinesForPrint(iRecCount)
         End If
         LinesForPrint(iRecCount) = Format$(X&)

         'Prepend line with sort information
         Select Case SortType
            Case 1   'SupplierCode
               sSortString = ord.supcode
               iSortKeyLen = Len(ord.supcode)
            Case 2   'OrderNumber
               sSortString = ord.num
               iSortKeyLen = Len(ord.num)
            Case 3   'Product Description
               d.SisCode = ord.Code
               getdrug d, 0, foundPtr&, False    '01Jun02 ALL/ATW
               iSortKeyLen = Len(d.LabelDescription)    ' iSortKeyLen = Len(d.Description) XN 4Jun15 98073 New local stores description
               If foundPtr& > 0 Then             '01Jun02 ALL/ATW
                  sSortString = d.LabelDescription              ' sSortString = d.Description XN 4Jun15 98073 New local stores description
               Else
                  sMsg = trimz(ord.Code) & " Could not be found in product file"
               End If
            Case 4   'Location Code
               d.SisCode = ord.Code
               getdrug d, 0, foundPtr&, False           '01Jun02 ALL/ATW
               iSortKeyLen = Len(d.loccode)
               If foundPtr& > 0 Then                    '01Jun02 ALL/ATW
                  sSortString = d.loccode
               Else
                  sMsg = trimz(ord.Code) & " Could not be found in product file"
               End If
         End Select
            
         LinesForPrint(iRecCount) = pad(trimz(sSortString), iSortKeyLen) & LinesForPrint(iRecCount)

         'Build error message if necessary
         If Trim$(sMsg) <> "" Then
            sErrMsg = sErrMsg & sMsg & crlf
            sMsg = ""
         End If
      
         On Error GoTo 0
            End If
         rsOrders.MoveNext
         Loop
    End If
''   End If

   If iRecCount > 0 Then
      'Sort Lines to be printed
      shellsort LinesForPrint(), iRecCount, 1, ""
   
      'Print it .....
      MakeLocalFile sTmpFile                                                  'Tmp file used to
      iTmpFileNo = FreeFile                                                   'build report
      Open sTmpFile For Binary Access Write Lock Read Write As iTmpFileNo
      
      'Header Info
      FillHeapSupplierInfo gPRNheapID, sup, success
      ParseItems gPRNheapID, sPgHdr, 0
      Put iTmpFileNo, , sPgHdr
      
      'Main detail line
      For X& = 1 To iRecCount
         recnum& = Val(Mid$(LinesForPrint(X&), iSortKeyLen + 1))
         If recnum& = 0 Then Stop                     '//// can't just STOP
         getorder ord, recnum&, Edittype, False

         FillHeapOrdInfo gPRNheapID, ord, success
         getsupplier ord.supcode, 0, 0, sup
         FillHeapSupplierInfo gPRNheapID, sup, success
         d.SisCode = ord.Code
         getdrug d, 0, 0, False   ' iDrugFound, False  '01Jun02 ALL/ATW
         FillHeapDrugInfo gPRNheapID, d, success

         rCost = (TheCost(d, Edittype) * Val(ord.outstanding)) / 100#
         rTotalCost = rTotalCost + rCost
         Heap 10, gPRNheapID, "LineCost", Format$(rCost, "0.00"), 0

         '22Apr02 SF applies on cost (enh#1555)
         rCostIncOnCost = (TheCost(d, Edittype) * Val(ord.outstanding)) / 100#
         If Val(sup.onCost) > 0 Then
               rCostIncOnCost = rCostIncOnCost + (rCostIncOnCost * (Val(sup.onCost) / 100))
            End If
         Heap 10, gPRNheapID, "LineCostIncOnCost", Format$(rCostIncOnCost, "0.00"), 0
         rTotalCostIncOnCost = rTotalCostIncOnCost + rCostIncOnCost
         '22Apr02 SF -----

         sDetailLine = sPgItem
         ParseItems gPRNheapID, sDetailLine, 0
         Put iTmpFileNo, , sDetailLine
      Next

      'Footer
      Heap 10, gPRNheapID, "TotalItems", Format$(iRecCount), 0
      Heap 10, gPRNheapID, "TotalCost", Format$(rTotalCost, "0.00"), 0
      Heap 10, gPRNheapID, "TotalCostIncOnCost", Format$(rTotalCostIncOnCost, "0.00"), 0      '22Apr02 SF added to include OnCost (enh#1555)
      ParseItems gPRNheapID, sPgEnd, 0
   
      Put iTmpFileNo, , sPgEnd
      
      'Print and cleanup
      Close iTmpFileNo
      'ParseThenPrint sContext, sTmpFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
      ParseThenPrint sContext, sTmpFile, 1, 0, False, True '04Jan17 TH Use local file
      On Error Resume Next
      Kill sTmpFile
      On Error GoTo 0
   Else
      Screen.MousePointer = STDCURSOR
      popmessagecr "#" & strCaption, "No items in given criteria to print"
   End If

OrderPrint_Exit:
   Screen.MousePointer = STDCURSOR
   Exit Sub

OrderPrint_Err:
   sMsg = "An error has occured in routine: StoreASC: OrdersPrint" & crlf
   sMsg = Format$(Err) & ": " & Trim$(Error$) & crlf & crlf
   sMsg = "Please contact your System Supervisor"
   popmessagecr ".", sMsg
   GoTo OrderPrint_Exit

End Sub

Sub PositionLblGrid()
'05May98 CKJ Added handling for 2 lines

Dim CtrlTop%, CtrlLeft%
Dim txt$, lines%, posn%

   txt$ = MainScreen.LblGrid.Caption
   posn = 0                                          '05May98 CKJ Added handling for 2 lines
   lines = 1                                         '   "
   Do                                                '   "
      posn = InStr(posn + 1, txt$, cr)               '   "
      If posn Then lines = lines + 1                 '   "
   Loop While posn                                   '   "
   CtrlTop = MainScreen.lvwMainScreen.Top - lines * TxtHeight(MainScreen.LblGrid) - 200
   On Error Resume Next
   If MainScreen.lblHeading.Item(1).Visible = True Then
      CtrlTop = CtrlTop - MainScreen.lblHeading.Item(1).Height '04Feb05 TH
   End If
   On Error GoTo 0
   If CtrlTop < TxtHeight(MainScreen.LblGrid) Then CtrlTop = TxtHeight(MainScreen.LblGrid) + 100
   CtrlLeft = (Screen.Width / 2) - (txtwidth(MainScreen.LblGrid, txt$) / 2)
   MainScreen.LblGrid.Move CtrlLeft, CtrlTop

End Sub


Function PresentPrescriptionID&()

'stub procedure for call to PresentPrescriptionID&() in Translog

   PresentPrescriptionID& = m_PrescriptionID

End Function
Sub setPrescriptionID(ByVal PrescriptionID As Long)
'03Sep12 TH Added for PSO

   m_PrescriptionID = PrescriptionID
   
End Sub

Function Printcancellation%(ordptr As Long, Edittype As Integer)

'07Dec97 EAC PrintCancelation: Ask user if they wish to continue with deletion if supplier not found
'29Dec97 EAC Use Stores drug description
'19Feb98 EAC Use new order printing routines
'05Aug98 TH  Added code to ensure only the numerical content of order number is sent to printordertop
'12Apr00 CFY Parameter added to wsspool call
'06Dec16 TH  Replaced RTF Handling (TFS 157969)
'13Feb17 TH  Added Release lock on main exit and none standard exit (TFS 176185,177040)
'14Feb17 TH  Moved get order so we can check to ensure it hasnt been deleted before we have locked
'            Thia can stop possible double deletion (TFS 177177)
'21Feb17 TH  Reverted above pending review - this is an existing issue NOT a hosted issue. (TFS 177177)

Dim tempord As orderstruct
Dim FILE$, RTFfile$, filelock$, RTFTxt$, temp$, printedordno$, title$, msg$, ans$
Dim filno%, foundPtr%, valid%, success%, Y% ' found%,
Dim pageno%, printtn%, printsis%, printedok%
Dim pforprinting!, VatForPrinting!, PtotordCost!, PtotordVat!
Dim temp1$
Dim lngFound As Long
    
   getorder tempord, ordptr&, Edittype, False '14Feb17 TH Moved below '21Feb17 TH Reverted pending review
   
   getsupplier tempord.supcode, foundPtr, lngFound, sup
   supcode$ = sup.Code

   If lngFound Then
      Select Case sup.Method
         'Case "D", "F", "E" 'direct by paper order '03Jun08 TH Added EDI (F0015847)
         Case "D", "F", "E", "H" '28Jul14 TH Added Hub method
            'also Fax order - same procedure to build order - uses different rtf file
            filelock$ = dispdata$ + "\PRNTORD" + Trim$(Str$(Edittype)) + ".LCK"  '19Feb94 CKJ
            AcquireLock filelock$, -2, valid  ' exclusive, keep trying

            Select Case sup.Method
               'Case "D", "E" '03Jun08 TH Added EDI (F0015847)
               Case "D", "E", "H" '28Jul14 TH Added Hub method
                   RTFfile$ = "\orddata.rtf"
               Case "F"
                   RTFfile$ = "\faxdata.rtf"
               Case Else
            End Select
      
            If valid Then
               '!!** getorderno 1, orderno, 3  'Lock order number file ASC 17.06.92
               'GetOrderNo 1, orderno%, False
               'ordernumb$ = LTrim$(Str$(orderno%))

               Do
                  'popmessage "!n!b", "Spooling...", True
                  MakeLocalFile FILE$
                  filno = FreeFile
                  'Open file$ For Output As #filno Len = 256           ' for spooling ...
                  'Print #filno, Chr$(27); "@"
                  Open FILE$ For Binary Access Write Lock Read Write As #filno

                  'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
                  GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success '06Dec16 TH Replaced (TFS 157969)

                  If Not success Then
                     AcquireLock filelock$, 0, valid '13Feb17 TH Release lock (TFS 176185)
                     popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
                     Exit Function
                  End If
                  striprtf RTFTxt$
                  temp$ = "{"
                  Put #filno, , temp$
                  printedordno$ = tempord.num
                  temp1$ = Str$(Val(printedordno$)) '05Aug98 TH Added to ensure correct number is sent
                  printedordno$ = Trim$(temp1$)     '
                  printordertop supcode$, printedordno$, filno%, printtn%, printsis%, 1, False '20Aug12 TH PSO (allow cancellation print - probably should - need to check with Andrew)
                  'print descriptor line
                  PrintOrdDescriptor filno, printtn, False '20Aug12 TH PSO (as above)

                  'nn)_NSVCODE_[56 character description . . . . . . . . . . . . . . .]_Qtyorderd_x_Convf_Pform
                  '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
            
                  '19Feb98 EAC Use new order printing routines
                  OrderLineParse tempord, RTFTxt$, filno%, printsis%, printtn%, 1, PtotordCost!, PtotordVat!, pforprinting!, VatForPrinting!, True, False '14Nov12 TH Added PSO param
                
                  If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
                     '26Apr02 SF
                     'PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!
                     PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
                     '26Apr02 SF -----
                  End If
                  '---
                  printordertail filno%, sup.ordmessage, False '20Aug12 TH PSO (as above)
                  temp$ = "}"
                  Put #filno, , temp$

                  Close #filno

                  printedok = False
                  'if this supplier is contacted by fax then show printer dialog to allow fax selection
                  'If sup.method = "F" Then ok = HEPrintSetupDlg(highedit.HE.hWnd)
                  'Print file
                  If sup.Method = "F" Then
                     SetPrinterOptions
                     WSspool FILE$, "Stock Control", 1, False, False, ""
                     SetPrinterOptions
                     WSspool FILE$, "Stock Control", 1, True, False, ""
                  Else
                     WSspool FILE$, "Stock Control", 1, True, False, ""
                  End If
                                
                  Do
                     Y = 1
                     pageno = 1
                     k.escd = False
                     printedok = False ' 2Jun93 CKJ
                     'pickwindow 5, 50, "!n!bCompleted", 4
                     title$ = "Completed"
                     'printw "   " + Str$(y) + " item" + plural((y)) + " sent to the printer on"  '23May96 CKJ Added ()
                     'printwcr Str$(pageno) + " order" + plural((pageno)) + "."                   '   "
                     'Print
                     'printw "    Printed OK?  Y/N  (Esc to abort order)  "
                     msg$ = Str$(Y) + " item" + plural((Y)) + " sent to the printer on"
                     msg$ = msg$ + Str$(pageno) + " order" + plural((pageno)) + "." + Chr$(13) + Chr$(13)              '   "
                     msg$ = msg$ + "    Printed OK?  Y/N  (Esc to abort order)  "
                     ans$ = ""
                     'getyesornocr ans$, k
                     'confirm title$, msg$, ans$, k
                     askwin title$, msg$, ans$, k
                     If ans$ = "Y" Then
                       printedok = True
                     ElseIf ans$ = "N" Then
                       printedok = False
                     Else
                       k.escd = True
                     End If
                     If k.timd Then popmessagecr "!n!i", "Printing needs confirmation" '!!** beep
                  Loop Until Not k.timd
               Loop Until printedok Or k.escd
    
               AcquireLock filelock$, 0, valid '13Feb17 TH Release lock (TFS 176185)
            End If
         Case Else
            'do nothing
            printedok = True
      End Select
        
   '07Dec97 EAC Ask user if they wish to continue with deletion if supplier not found
   Else
      k.escd = False
      msg$ = Trim$(tempord.supcode) & " is not defined in the Locations file. A cancelation form can not be printed for this item." & cr$ & cr$
      msg$ = msg$ & "Do you still wish to delete this item?"
      askwin "Delete Item", msg$, ans$, k
      If ans$ = "Y" And Not k.escd Then
         printedok = True
      Else
         printedok = False
      End If
   '---
   End If

   Printcancellation = printedok

End Function

Sub Ques_Callback(Index As Integer)

Const procname$ = "Ques_Callback"

Dim NewIndex%
Dim msg$

   Select Case QuesCallbackMode
      Case 11 'Amend Supplier Details
         'CheckSiteTemplate Index, msg$, NewIndex%  23Jul97 EAC
         Supplier_Callback Index
      Case 2 'Set Working Defaults
         CheckWorkingDefaults Index, msg$, NewIndex%
      Case 3 'Mediate EDI Link Settings
         CheckMediateSettings Index
      Case 16: SupProfile_CallBack Index '09Oct06 TH Added
      Case 17: CheckHubInvoiceSettings Index  '22Jun14 TH Added
      Case Else
         popmessagecr "Error", "Module : " & modulename$ & Chr$(13) & "Procedure : " & procname$ & Chr$(13) & "Undefined callback number : " & Str$(QuesCallbackMode) & Chr$(13) & Chr$(13) & "Please report this error to EMIS Health."
   End Select

   If Trim$(msg$) <> "" Then
      popmessagecr "Fields missing", msg$
      Ques.txtQ(NewIndex).SetFocus
   End If

End Sub

Function ReadAskSupplierDefaults%(Section$, Setting%)

Dim temp$, txt$
Dim found%

   Select Case Setting%
      Case 0
         temp$ = "FirstLine"
      Case Else
         temp$ = "Display"
   End Select

   txt$ = UCase$(TxtD$(dispdata$ & "\winord.ini", Section$, "", temp$, found))

   Select Case Setting
      Case 0
         Select Case txt$
            Case "ALL"
               ReadAskSupplierDefaults% = 1
            Case "NEW"
               ReadAskSupplierDefaults% = 2
            Case "NONE"
               ReadAskSupplierDefaults% = 3
            Case Else
               ReadAskSupplierDefaults% = 0   'No extra option displayed
         End Select
      Case Else
         Select Case txt$
            Case "SUPPLIERS"
               ReadAskSupplierDefaults% = 1
            Case "WARDS"
               ReadAskSupplierDefaults% = 2
            Case Else
               ReadAskSupplierDefaults% = 0
         End Select
   End Select
   
End Function

Sub receiveitem(sitepaths As Integer, ByRef ord As orderstruct, QtyReceived$, foundorder&, ByRef auto As Integer, ByVal lngBatchWReconcilID As Long)
' 8Feb94 CKJ Added BatchNum$ & ExpiryDate$
'21Dec98 CFY Now no longer uses the global variable AskBatchNum to determine whether to record
'            batch information in the order log. Instead the decision to do this is dependant upon
'            the drug using the field d.batchtracking.
'28Jan99 TH  Added procedure to allow for receiving more than ordered (on ini setting)
'            Added code to allow for receiving free items
'29Jan99 TH  *** Using auto as flag (set to 4) to mark over recieve is unsuccessfull
'23Feb99 TH  Changed filter for free goods going to reconciliation
'05Mar99 TH  Changes to ensure price is update correctly and price on receipt prompted only once
'            when receiving more than ordering
'22Jun99 TH  Update stock value correctly when receiving free items
'21Oct99 TH  Do not allow the possibility of over receipt on internal orders
'18Nov99 AE  Allow recipt of part internal orders if doing batch tracking, by updating ord.recieved
'            with the unreceived amount rather than setting it to zero by default.
'19Nov99 AE  Moved line which zeros ord.cost inside IF. This prevents transactions for the second and
'            subsequent recipts of a part internal order from being written at zero cost.
'15May00 EAC Updated parameter list for UpdatePrice calls
'18Aug00 TH  Ensure check on k.escd after updateprice for over receipt orders and trap to ensure order not received if this is the case
'18Aug00 TH  Explicitly set cost to zero in over receipt if freeflag is set.
'17Jan01 TH  Allow part receipt of internal if only part sent from store
'19Jan01 TH  Changed and inverted the way the logic was written on creation of reconcilliation record / log of receipt
'            to ease maintenance and make it more readable and also ensure log of receipt is always correctly written
'01Sep01 TH  Cannot receive more of an internal order than the store has issued (#51651)
'15Jan02 TH  Add Time received to orderlog (#53214)
'25Feb02 TH  Mod to allow for part receipt of internal orders with a suitable message (This can be configured) (enh1487) (#55087)
'28Jan04 TH  Added blanking of new ord date field
'16May04 TH  Added Mods to prevent double issue when receipt has timed out and the line has been received elsewhere - strengthened locking during receipt process (#59077)
'13oct08 CKJ Merged: 01Aug08 TH/CKJ (F0023465) remove check on k.escd to stop potential "double receipt" - ie update of drug with no subsequent update of order
'26Mar09 TH  Added batchnum, expiry to "R" type orderlogs and added olToFollow to heap for UHB interfacing (F0032689)
'09Apr09 TH  Changes after CKJ review
'04Aug09 TH  Added Double Receipt Logging top track thread of receipt process.
'06Sep10 TH  Added DeliveryReference For UMMC (FINV). THe number is read from previous capture (if applicable) and then sent into the orderlog call for recording in the DB. (F0054531)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitepaths & linnum params plus var declarations
'27Jun11 CKJ Removed param linnum since it has no useful role
'16Jul12 TH  Replaced Over receipt message for DLO  (TFS 38661)
'03Sep12 TH  Main PSO work for PSO receipt (TFS 42771)
'19Feb13 TH  Always reconcile PSO regardless of pricing flag (Free receipt)
'06Mar13 TH  Fencepost batchtraking check Replaced above. This must have been missed in a merge TFS 58220
'10Mar13 TH  Fencepost batchtraking check for PSO. Missed this when fixing DLO. Silly boy (TFS 58632)
'24Mar13 TH  Check PSO here for cancelled prescriptions (TFS 59469)
'05Sep14 TH  Changed pickno data type - was erroring on ticket numbers outside of int range.(TFS 99425)
'26Jan15 TH  Set the date as issued date for PSO Label update. Not the genuine date but the best approx we have.(TFS 109430)
'04Sep15 TH  Fix costing fault on batch amalgamation for invoice (TFS 128729)
'16Aug16 XN  160233 PrintDeliveryNote comes from Ward stock list now

Dim failed As Integer, autoenter As Integer, found As Integer   '01Jun11 CKJ Added as integer to all
Dim BatchNum$, ExpiryDate$, purprice$, outstanding$
Dim ordoutstanding!
Dim tempord As orderstruct
Dim pointer&, ans%, rordqty$, rord As orderstruct, reason$, ordsave As orderstruct
Dim overreceive$, totalqty$
Dim msg$                                                       '18Nov99 AE Added
Dim blnAbort As Integer '16May04 TH Added (#59077)
Dim lngOK As Long 'SQL dummy return value
Dim strMsg As String
Dim strTitle As String
Dim strOriginalCost As String
Dim strOrdOutstanding As String
Dim blnOverReceive As Boolean
Dim lngOrderPointer As Long
Dim strWarMsg As String
Dim strWarMsg2 As String
Dim strOverRec As String
Dim strStoresDesc As String
Dim strAns As String
Dim Batchord As orderstruct         '25Oct06 TH Added
Dim strBatchGroupAbort As String    '     "
Dim lngLogThreadID As Long   '04Aug09 TH Added for logging ()
Dim strDeliveryReference As String  '06Sep10 TH (F0054531)
'27Jun11 CKJ removed newlinnum As Integer, LineCost$
Dim rsDLOOrders As ADODB.Recordset '20Jun12 TH DLO Added
Dim DLOSup As supplierstruct       '    "
Dim DLOOrd As orderstruct
Dim itemunitcost$
Dim strSql As String
Dim blnDLOOrderFound As Boolean
Dim lclL As WLabel
Dim blnOK As Boolean
Dim intValid As Integer
Dim strTemp As String
Dim Qty!, converter!
Dim strForename As String   '24Mar13 TH (TFS 59469)
Dim strSurname As String    '   "
Dim strDOB As String        '   "
Dim strNHNumber As String   '   "
Dim strCasenum As String    '   "
Dim strPSOMsg As String     '   "
Dim strDrugDesc As String   '   "


   failed = False
   'BatchNum$ = ord.invnum
   BatchNum$ = ord.batchnumber '08Mar07 TH Added
   ExpiryDate$ = ord.paydate
   strOrdOutstanding = ord.outstanding    '11Sep05 TH Added (this is used to compare with the order reloaded from disk on locking - though here only for over receipted orders)
   strBatchGroupAbort = "" '26Oct06 TH Added
   strDeliveryReference = getDeliveryNoteReference() '06Sep10 TH Added For UMMC (F0054531)
   
   If (Val(QtyReceived$) > Val(ord.outstanding)) Or (Val(QtyReceived$) > Val(ord.received) And UCase$(ord.internalmethod) = "I") Then  'Cannot overreceive a part internal order
      If Not auto Then      'Allow for more received than ordered
         blnOverReceive = TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Receive Goods", "N", "overreceive", 0)) '11Sep05 TH Replaced above
         If (Not blnOverReceive) Or (UCase$(ord.internalmethod)) = "I" Then   '11Sep05 TH Replaced above
            If Not auto Then                                                       '    "
               If UCase$(ord.internalmethod) = "I" Then                         '    "
                  msg$ = "Cannot receive more than store has issued"         '    "
               Else                                                          '    "
                  msg$ = "Cannot receive more than ordered."                 '    "
               End If                                                        '    "
               popmessagecr "", msg$                                            '    "
            End If                                                              '    "
            failed = True
            auto = 4 '29Jan99 TH Use auto as flag
            k.escd = True '11Sep05 TH Added
         '28Jun12 TH Added DLO Check
         ElseIf (ord.DLO Or (ord.PSORequestID > 0)) Then '02Sep12TH Added PSO check
            'msg$ = "Cannot receive more than ordered for direct location order."                 '    "
            msg$ = "Cannot receive more than ordered for a " & Iff(ord.DLO, "Direct Location Order", "Patient Specific Order") '16Jul12 TH Replaced above (TFS 38661)
            popmessagecr "", msg$                                            '    "
            failed = True
            auto = 4 '29Jan99 TH Use auto as flag
            k.escd = True '11Sep05 TH Added
         Else
            '17Oct05 TH Changed over receipt box (#80437)
            ''ans% = MessageBox("You Are Attempting to Receive more than Ordered - Are you sure you wish to proceed ?", 3, "")  '    "
            strStoresDesc = Trim$(d.DrugDescription)    ' strStoresDesc = Trim$(GetStoresDescription())  XN 4Jun15 98073 New local stores description
            plingparse strStoresDesc, "!"
            strOverRec = "You Are Attempting to Receive on order number " & Format$(ord.num) & " more" & crlf & strStoresDesc & " than was Ordered." & _
                        crlf & "Quantity outstanding is " & ord.outstanding & crlf & "Quantity entered to receive " & QtyReceived$ & crlf & crlf & "Are you sure you wish to proceed ?'"
            strAns = "Y"
            askwin "!Order Receipt", strOverRec, strAns, k
            
            'If ans% <> 6 Then
            If strAns <> "Y" Or k.escd Then
               failed = True
               blnAbort = True
               k.escd = True  '11Sep05 TH Added
            End If
            'If ans% = 6 Then
            If strAns = "Y" Then
               'receive extra as with supplementary order receive rest as normal                                             '    "
               rordqty$ = Str$(Val(QtyReceived$) - Val(ord.outstanding))  'outstanding already updated
               totalqty$ = QtyReceived$    '05Mar99 TH
               QtyReceived$ = Str$(Val(ord.outstanding))                                                                     '    "
               'Create a new order record for the over receipt - as prices could change this needs to be within a transaction !
               blankorder rord                                                                                               '    "
               rord.num = ord.num                                                                                            '    "
               rord.orddate = thedate(False, True) '03May98 CKJ Y2K
               rord.ordtime = thedate(0, -2)  '11Oct05 TH Added
               rord.Code = ord.Code                                                                                          '    "
               rord.outstanding = "0"                                                                                        '    "
               rord.qtyordered = rordqty$                                                                                    '    "
               rord.received = rordqty$                                                                                      '    "
               rord.supcode = ord.supcode                                                                                    '    "
               rord.status = "R"                                                                                             '    "
               rord.invnum = reason$                                                                                         '    "
               If freeflag Then ord.cost = "0"   '18Aug00 TH Set cost to zero if free order
               rord.cost = ord.cost '11Sep05 TH Added
               If Val(totalqty$) > 0 Then                                                                                    '05Mar99 TH Added to properly update price allow for cost
                  ''updateprice 3, ord.code, (totalqty$), ord, purprice$, autoenter, "", 0, "", ""  '06Apr05 TH Added Parameters                                       '           on receipt for the WHOLE order (If done here  '15May00 EAC added ,""
                  'OK Here we are now going to receive the whole order (and thus release the lock)
                  'then we will produce the extra over receive amount orders and logs
                  '(we are essentially reversing the original process here so we can lock the original row
                  'for the receipt process before adding the extra receipt records)
                  'updateprice 3, ord.code, (totalqty$), ord, purprice$, autoenter, "", 0, "", ""  '11May05 TH Now send in the original orderpointer to lock this and prevent a receipt against the original line !                                       '           on receipt for the WHOLE order (If done here  '15May00 EAC added ,""
                  lngOrderPointer = foundorder& 'This is now passed into Updateprice so the record can be locked there
                  'LSet tempord = ord
                  LSet tempord = rord
                  '04Aug09 TH Begin logging here. We may also get a thread ID to help traxk the next few writes
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLoggingThread", 0)) Then GetPointerSQL rootpath$ & "\LogThreadID", lngLogThreadID, True
                     WriteLogSQL "ReceiveItem: Beginning Over Receipt", "DoubleRecLog", 1, lngLogThreadID
                  End If
                  '-------
                  '11Sep05 TH Replaced with line below
                  'updateprice 3, ord.code, (QtyReceived$), tempord, purprice$, autoenter, "", lngOrderPointer, strWarMsg, strWarMsg2, ord.outstanding'06May05 TH Now send in the original orderpointer to lock this and prevent a receipt against the original line !
                   updateprice 3, ord.Code, (totalqty$), tempord, purprice$, autoenter, "", "", "", lngOrderPointer, strWarMsg, strWarMsg2, ord.outstanding, lngLogThreadID '11May05 TH Now send in the original orderpointer to lock this and prevent a receipt against the original line !
                  
                  If lngOrderPointer = 0 Then
                     blnAbort = True
                     k.escd = True    '15May05 TH Added to ensure the receipt process is now absolutely bypassed
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Order has not been updated and drug not written, abort flags set", "DoubleRecLog", 0, lngLogThreadID
                     End If
                     '-------
                  End If
                  'If k.escd Then blnAbort = True '11Sep05 TH Added k.escd = True    '11Sep05 TH Removed as a valerror in updateprice could set this
                                                                                     '           inside an order lock. However, this should still be handled with
                                                                                     '           the previous line
                  If Not blnAbort Then
                     ord.status = "R"
                     ''updateordreqindex 3, ord.Code, "", ord.num, "", (foundorder&)
                     ord.received = QtyReceived$ 'is this needed ?  11Sep05 TH Yes it is (here anyway)
                     ord.outstanding = "0"
                     ord.invnum = BatchNum$
                     ord.paydate = ExpiryDate$
                     ord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
      
                     PutOrder ord, (foundorder&), "WOrder"          '<---UNLOCK   (no idx)
                      '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Over Receipt. Order Line unlocked and updated, WOrderID =" & Format$(foundorder&), "DoubleRecLog", 6, lngLogThreadID
                     End If
                     '-------
                     ''PutOrder foundorder&           '<---UNLOCK   (no idx)
                     Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '09Apr09 TH Moved here after CKJ review
                     'Now we do the logs and reconciliation record for the main amount
                     'If (Trim$(UCase$(d.pflag)) = "N" And (Trim$(ord.cost) <> "" And Val(ord.cost) = 0)) Or (Trim$(UCase$(d.pflag)) = "N" And freeflag) Then   '   "
                     If (Val(ord.PSORequestID) < 1) And ((Trim$(UCase$(d.pflag)) = "N" And (Trim$(ord.cost) <> "" And Val(ord.cost) = 0)) Or (Trim$(UCase$(d.pflag)) = "N" And freeflag)) Then  '19Feb13 TH Always reconcile for PSO
                        ord.recdate = thedate(False, True) '03May98 CKJ Y2K     '  Ensure free items with "no reconcile" flag
                        ord.received = QtyReceived$                             '  have no reconcil record written, but are stil logged as receipts !
                        ord.cost = "0"
                        ord.paydate = ""
                        ord.Reconciledate = ""   '28Jan04 TH Added
                        ord.invnum = ""
                        LookupDrug ord.Code, d, (found) '14Jan94 CKJ Added
                        'Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, qtyreceived$, ord.cost, ord.supcode, "R", sitepaths, batchnum$, d.vatrate '12Dec00 TH      '15Jan02 TH Add Time received to log (#53214)
                        ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate  '    "
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", "" '    "
                        'Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '26Mar09 TH Added
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Over Receipt. Receipt OrderLog Written, no reconcil required", "DoubleRecLog", 8, lngLogThreadID
                        End If
                     Else                                                       '    "
                        'getnumofords 4, pointer&, -1                            '
                        LSet tempord = ord
                        'getorder ord, (pointer&), 4, True '<-LOCK place to write
                        LSet ord = tempord
                        If freeflag Then          '28Jan99 TH  Added to allow for free receive
                           ord.cost = "0"      '  "
                        Else                   '  "
                           ord.cost = Trim$(purprice$)   '21Jun93 CKJ Added. Previously the price at ordering was used
                        End If                 '  "
                        'ord.recdate = thedate(False, False)
                        'ord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
                        ord.recdate = thedate(False, True) '03May98 CKJ Y2K
                        ord.received = QtyReceived$
                        ord.paydate = ""
                        ord.Reconciledate = ""   '28Jan04 TH Added
                        ord.invnum = ""
                        'ord.ward = ""                     '05may98 CKJ ward field not required
                        ord.status = "4"
                        ord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
                        PutOrder ord, (pointer&), "WReconcil"               '<-UNLOCK replace (idx rebuilt below)
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Over Receipt. Reconciliation record written", "DoubleRecLog", 7, lngLogThreadID
                        End If
                        '''updateordreqindex 4, "", ord.Code, "", ord.num, (pointer&)
                        LookupDrug ord.Code, d, (found) '14Jan94 CKJ Added
                        '!!** why is qty ordered set to outstanding which is usually 0 unless there are to follows?
                        'Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, qtyreceived$, ord.cost, ord.supcode, "R", sitepaths, batchnum$, d.vatrate '14Jan94 CKJ VAT  '15Jan02 TH Add Time received to log (#53214)
                        ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate  '     "
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", "" '     "
                        'Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '26Mar09 TH Added
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '     "
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Over Receipt. Receipt OrderLog Written", "DoubleRecLog", 8, lngLogThreadID
                        End If
                     End If                                                     '    "

                     '**** 19Jan01 TH End of block
         
                     'If AskBatchNum Then             '21Dec98 CFY Replaced
                     If Val(d.batchtracking) > 1 Then '     "
                        'Orderlog ord.num, ord.code, userid$, ExpiryDate$, ord.recdate, ord.qtyordered, qtyreceived$, ord.cost, ord.supcode, "Q", sitepaths, batchnum$, d.vatrate  '24Feb94 CKJ Added  '15Jan02 TH Add Time received to log (#53214)
                        'Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                        'Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                     End If
                     ord.received = "0" 'ASC 30Aug93
                  Else
                     If strWarMsg <> "" Then popmessagecr "!n!bWARNING", strWarMsg
                     k.escd = True
                  End If
               End If                                                                                                     '           is trapped further down
               'rord.cost = ord.cost                                                                                         '05Mar99 TH Replaced with below
               If k.escd Then                                                        '18Aug00 TH  Now close off if user has escaped on entering the price
                  failed = True                                                    '18Aug00 TH  Only get the order and increment the pointer at this point
                  blnAbort = True
               Else                                                               '18Aug00 TH  because now the receipt is definite
                  ''getnumofords 3, pointer&, True                                '18Aug00 TH
                  ''getorder ordsave, 0, 3, True   ' ----> LOCK (no idx)   '18Aug00 TH  'SQL Force insert
                  rord.cost = purprice$
                  rord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
                  blankorder ordsave
                  LSet ordsave = rord                                           '18Aug00 TH
                  'putorder rord, pointer&          '------> UNLOCK (idx)       '18Aug00 TH
                  ''PutOrder ordsave, pointer&, "WOrder"         '------> UNLOCK (idx)     '18Aug00 TH                                                '    "
                  PutOrder ordsave, 0, "WOrder" '01Jun05 TH Added to force insert
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     WriteLogSQL "Receiveitem: Over Receipt. Receipt Order for extra saved", "DoubleRecLog", 9, lngLogThreadID
                  End If 'v93 removed updateordreqindex 3, "", rord.code, "", rord.num, pointer&
                  Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '09Apr09 TH Moved here after CKJ review
                     
                  LookupDrug rord.Code, d, (found)                                                                              '    "
                  'Orderlog rord.num, rord.code, userid$, rord.orddate, "", rordqty$, "", rord.cost, rord.supcode, "D", sitepaths, reason$, d.vatrate   '14Jan94 CKJ VAT  '15Jan02 TH Add Time received to log (#53214)
                  'Orderlog rord.num, rord.Code, UserID$, rord.orddate & thedate(0, -2), "", rordqty$, "", rord.cost, rord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", strDeliveryReference
                  'Orderlog rord.num, rord.Code, UserID$, rord.orddate & thedate(0, -2), "", rordqty$, "", rord.cost, rord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                  Orderlog rord.num, rord.Code, UserID$, rord.orddate & thedate(0, -2), "", rordqty$, "", rord.cost, rord.supcode, "D", sitepaths, reason$, d.vatrate, "", "", strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     WriteLogSQL "Receiveitem: Over Receipt. Order OrderLog for extra saved", "DoubleRecLog", 10, lngLogThreadID
                  End If
                  'v93 removed updateordreqindex 3, "", rord.code, "", rord.num, pointer&
                                                                                                                                         '    "
                           

                  'If (Trim$(UCase$(d.pflag)) = "N" And (Trim$(ord.cost) <> "" And Val(ord.cost) = 0)) Or (Trim$(UCase$(d.pflag)) = "N" And freeflag) Then    '15Jan00 TH
                  If (Val(ord.PSORequestID) < 1) And ((Trim$(UCase$(d.pflag)) = "N" And (Trim$(ord.cost) <> "" And Val(ord.cost) = 0)) Or (Trim$(UCase$(d.pflag)) = "N" And freeflag)) Then    '19Feb13 TH Always reconcile PSO
                     rord.recdate = thedate(False, True)                  ' These are items that will not be reconciled
                     rord.received = rordqty$                             ' Therefore no record in reconcil.v8 will be created
                     rord.cost = "0"
                     rord.paydate = ""
                     rord.Reconciledate = ""   '28Jan04 TH Added
                     rord.invnum = ""
                     LookupDrug ord.Code, d, (found)
                     'Orderlog rord.num, rord.code, userid$, rord.orddate, rord.recdate, rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, batchnum$, d.vatrate                  '15Jan02 TH Add Time received to log (#53214)
                     ''Orderlog rord.num, rord.Code, UserID$, rord.orddate, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate  '    "
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", "" '    "
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                     Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Over Receipt. Receipt OrderLog for extra saved", "DoubleRecLog", 12, lngLogThreadID
                     End If
                     '-------
                  Else
                     ''getnumofords 4, pointer&, -1                                         ' These are items that will not be reconciled
                     LSet tempord = rord                                                  ' Therefore a record in reconcil.v8 must be created
                     ''getorder rord, 0, 4, True '<-LOCK place to write
                     LSet rord = tempord
                     If freeflag Then          'Added to allow for free receive
                        rord.cost = "0"     '  "
                     Else                   '  "
                        rord.cost = Trim$(purprice$)
                     End If
                     rord.Code = ord.Code
                     rord.num = ord.num
                     rord.recdate = thedate(False, True) '03May98 CKJ Y2K
                     rord.received = rordqty$
                     rord.paydate = ""
                     rord.Reconciledate = ""   '28Jan04 TH Added
                     rord.invnum = ""
                     rord.status = "4"
                     rord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
                     'PutOrder rord, (pointer&), "Order"
                     PutOrder rord, 0, "WReconcil"  '<-UNLOCK replace (idx rebuilt below)'Force Insert
                     '04Aug09 TH Added Double Receipt Logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Reconciliation record written", "DoubleRecLog", 7, lngLogThreadID
                     End If
                     '-------
                     'v93 removed updateordreqindex 4, "", rord.code, "", rord.num, (pointer&)
                     LookupDrug rord.Code, d, (found) '14Jan94 CKJ Added
                     '!!** why is qty ordered set to outstanding which is usually 0 unless there are to follows?
                     'Orderlog rord.num, rord.code, userid$, rord.orddate, rord.recdate, rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, batchnum$, d.vatrate '14Jan94 CKJ VAT  '15Jan02 TH Add Time received to log (#53214)
                     ''Orderlog rord.num, rord.Code, UserID$, rord.orddate, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate   '    "
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", "" '    "
                     'Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '26Mar09 TH Added
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                     'Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                     Orderlog rord.num, rord.Code, UserID$, rord.orddate & rord.ordtime, rord.recdate & thedate(0, -2), rord.outstanding, rordqty$, rord.cost, rord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID  '04Mar14 TH Added PSORequestID
                     rord.received = "0"                                                                             '    "
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Over Receipt. Receipt OrderLog for extra saved", "DoubleRecLog", 11, lngLogThreadID
                     End If
                     '-------
                  End If

                  '************** 19Jan01 TH End of block
                                                                                                                              '    "
                  'If AskBatchNum Then             '21Dec98 CFY Replaced                                                      '    "
                  If Val(d.batchtracking) > 1 Then '     "                                                                    '    "
                     'Orderlog rord.num, rord.code, userid$, ExpiryDate$, rord.recdate, rord.qtyordered, qtyreceived$, ord.cost, ord.supcode, "Q", sitepaths, batchnum$, d.vatrate  '24Feb94 CKJ Added  '15Jan02 TH Add Time received to log (#53214)
                     'Orderlog rord.num, rord.Code, UserID$, ExpiryDate$, rord.recdate & thedate(0, -2), rord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference   '    "
                     'Orderlog rord.num, rord.Code, UserID$, ExpiryDate$, rord.recdate & thedate(0, -2), rord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, ""   '02Nov10 AJK F0086901 Added paydate
                     Orderlog rord.num, rord.Code, UserID$, ExpiryDate$, rord.recdate & thedate(0, -2), rord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID   '04Mar14 TH Added PSORequestID
                  End If                                                                                                   '    "
                  rord.received = "0"                                                                             '    "
                  '---------------------------
                  'k.escd = True   '11Sep05 TH Removed
                  blnAbort = True
               End If                                                                        '18Aug00 TH
            End If
         End If
      End If
         'failed = True     'Removed 28Jan99 TH
   'End If
   Else
      '24Mar13 TH Check PSO here (TFS 59469)
      If ord.PSORequestID > 0 Then
         If IsParentPrescriptionCancelled(ord.PSORequestID) Then
            'we will need the patient details here
            FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0
            d.SisCode = ord.Code
            getdrugsup d, 0, 0, False, ord.supcode
            'strDrugDesc = d.storesdescription  XN 4Jun15 98073 New local stores description
            'If Trim$(strDrugDesc) = "" Then strDrugDesc = d.Description
                        strDrugDesc = d.DrugDescription
            plingparse strDrugDesc, "!"
            Heap 11, gPRNheapID, "psoForeName", strForename, 0
            Heap 11, gPRNheapID, "psoSurName", strSurname, 0
            Heap 11, gPRNheapID, "psoDOB", strDOB, 0
            Heap 11, gPRNheapID, "psoCasenumber", strCasenum, 0
            Heap 11, gPRNheapID, "psoNHnumber", strNHNumber, 0
            'strPSOMsg = "This prescription has been cancelled." & crlf & "Product : " & Trim$(strDrugDesc) & crlf & _
            '"For patient : " & Trim$(strForename) & " " & Trim$(strSurname) & crlf & "DOB : " & strDOB & crlf & _
            '"Case Num : " & strCasenum & crlf & "NH Number : " & strNHNumber & crlf & crlf & "Do you wish to continue ? "
            '25Mar13 TH Replaced after email with clarifications
            strPSOMsg = "This prescription is not current." & crlf & crlf & "Product: " & Trim$(strDrugDesc) & crlf & _
            "For patient: " & Trim$(strForename) & " " & Trim$(strSurname) & crlf & "DOB: " & strDOB & crlf & _
            "Case Num: " & strCasenum & crlf & "NH Number: " & strNHNumber & crlf & crlf & "Do you wish to continue? "
            
            ClearHeapPSOrderInfo gPRNheapID
            strAns = "N"
            askwin "!Patient Specific Order Receipt", strPSOMsg, strAns, k
            If k.escd Or strAns = "N" Then blnAbort = True
         End If
      End If
      '24Mar13 TH -----
      
      If Not blnAbort Then
         If Val(QtyReceived$) < 0 Then
            If Not auto Then popmessagecr "", "Cannot receive negative quantities"
            failed = True
         End If

         'Receive an item
         '---------------
         If Not failed Then
            'getorder ord, (foundorder&), 3, False                                                                                    '16May04 TH Added lock here (#59077)
            '14Apr05 TH Now defer locking to inside updateprice
            ''getorder ord, (foundorder&), 3, True                                                                                      '   "
            ''If ord.status <> "3" Then                                                                                                 '   "       Added as way out if rec
            ''      popmessagecr "!Ascribe", "This Order Line Has already been recieved. Please check the Order Logs for Confirmation"  '   "       previously locked and then
            ''      putorder ord, (foundorder&)                                                                                         '   "       received
            ''      blnAbort = True                                                                                                     '   "
            ''   End If
            ''   "
            '14Apr05 ----------
            If entercostonreceipt$ = "N" Or auto Then
               autoenter = True
            Else
               autoenter = False
            End If
            ordoutstanding! = Val(ord.outstanding)
            '-------------------------------------
            k.escd = False
            If Not blnAbort Then        '16May04 TH Dont change any prices if aborted  (#59077)
               If Val(QtyReceived$) > 0 And purprice$ = "" Then   '05Mar99 TH Trapped if handled in over order abve
                  If freeflag Then      '22Jun99 TH Update stock value correctly when receiving free items
                     strOriginalCost = ord.cost
                     ord.cost = "0"
                  End If
                  LSet tempord = ord
                  'updateprice 3, ord.code, (QtyReceived$), ord, purprice$, autoenter, "" '!!** purprice never used! '15MAy00 EAC added ,""
                  lngOrderPointer = foundorder& 'This is now passed into Updateprice so the record can be locked there
                  '04Aug09 TH Begin logging here. We may also get a thread ID to help traxk the next few writes
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLoggingThread", 0)) Then GetPointerSQL rootpath$ & "\LogThreadID", lngLogThreadID, True
                     WriteLogSQL "ReceiveItem: Beginning Standard Receipt", "DoubleRecLog", 1, lngLogThreadID
                  End If
                  '-------
                  updateprice 3, ord.Code, (QtyReceived$), tempord, purprice$, autoenter, "", "", "", lngOrderPointer, strWarMsg, strWarMsg2, ord.outstanding, lngLogThreadID '06Oct04 TH Replaced above line '14Apr05 TH added new parameters to allow locking in updateprice and
                                                                                                                                                                     '           defered modal messages to be displayed outside of any lock
                  If lngOrderPointer = 0 Then
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Order has not been updated and drug not written, abort flags set", "DoubleRecLog", 0, lngLogThreadID
                     End If
                     '-------
                     blnAbort = True
                     k.escd = True    '15May05 TH Added to ensure the receipt process is now absolutely bypassed
                  End If
               Else
                  blnAbort = True '11Jul06 TH Added - we must set this here because we have not locked the record and we must therefore leave
               End If                      '16May04 TH
      
            'If (Not k.escd) And (Not blnAbort) Then    '   "
            If (Not blnAbort) Then  '01Aug08 TH/CKJ (F0023465) remove check on k.escd to stop potential "double receipt" - ie update of drug with no subsequent update of order
               If k.escd Then WriteLog dispdata$ & "\DblRec.log", SiteNumber%, UserID$, "k.escd True in receiveitem unexpectedly - Possible trap of double receipt (F0023465)"

                  msg$ = "" '06May05 TH Added
                  'getorder ord, (foundorder&), 3, True   '<---LOCK     (no idx) '!!** move above??   '16May04 TH Moved lock above (#59077)
                  If Val(QtyReceived$) = Val(ord.outstanding) Then
                     'If Val(qtyreceived$) = Val(ord.outstanding) Or overreceive Then    '28Jan99 TH
                     'receive all outstanding
                     '-----------------------
                     ord.status = "R"
                     ''updateordreqindex 3, ord.Code, "", ord.num, "", (foundorder&)
                     ord.received = QtyReceived$ 'is this needed ?
                     ord.outstanding = "0"
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: All Outstanding Qty to be received", "DoubleRecLog", 5, lngLogThreadID
                     End If
                     '-------
                  Else
                     'receive part of order
                     '---------------------
                     outstanding$ = ord.outstanding  '!!** never used
                     ord.outstanding = LTrim$(Str$(Val(ord.outstanding) - Val(QtyReceived$)))
                     Select Case ord.internalmethod
                        Case "I", "M"
                           '
                           'ord.received = "0"   ' !!** won't be zero if only rec'd part of what was issued
                           If Val(d.batchtracking) > 1 Then                                                                        '18Nov99 AE corrected.  Allow recipt of part internal orders
                              ord.received = Format$(dp!(Val(ord.received) - Val(QtyReceived$)))                                'only for purposes of reciving different batch numbers.
                           Else                                                                                                 '      "
                              If (Val(ord.received) = Val(QtyReceived$)) Then       '17Jan01 TH Allow part receipt of internal if only part sent from store
                                 ord.received = "0"                              '17Jan01 TH
                                 ord.cost = ""                                   '17Jan01 TH
                              Else                                               '17Jan01 TH
                              'If Val(ord.received) <> 0 Then  '23Jul04 TH  (#61824)  '29Sep04 TH Removed after problems found on site
                                 If Val(ord.received) <> 0 Then   '19Sep05 PJC Reinstated line above. (#61824)
                                    msg$ = "You have received only part of an internal order. " & cr$                                 '      "
                                    'msg$ = msg$ & "The rest of the order should be deleted and the Issuing Site must" & cr$           '      "  '25Feb02 TH removed and added sections of default message (enh1487)
                                    msg$ = msg$ & "Store has issued more than is currently being received" & cr$
                                    'msg$ = msg$ & "return the unissued items into stock to ensure stock levels balance." & cr$        '      "  '     "
                                    msg$ = msg$ & "Please check that this is correct" & cr$                                                      '     "
                                    msg$ = TxtD$(dispdata$ & "\winord.ini", "defaults", msg$, "PartInternalReceiveMsg", 0)  '25Feb02 TH Added configurable message
                                    'If UCase$(msg$) <> "N" Then popmessagecr "!Internal Orders", msg$                       '   "       (or none at all) '14Apr05 TH Defer all modal msgs to outside of locking                                 '      "
                                    If UCase$(msg$) = "N" Then msg$ = "" '06May05 TH Added
                                    'ord.received = "0"                                                 '25Feb02 TH Replaced to allow the receipt of the remainder  (#55087)
                                    ord.received = Format$(dp!(Val(ord.received) - Val(QtyReceived$)))  '    "
                                    'Else                      '23Jul04 TH Mod to allow for receipt of part of a pack from the stores   '29Sep04 TH Removed after problems found on site
                                    '   ord.received = "0"     '  "        Which was opened up with (#61824)                            '      "
                                    '   ord.cost = ""          '  "                                                                     '      "
                                    'End If                    '  "                                                                     '      "
                                 Else                      '19Sep05 PJC Reinstated code from above, to allow for receipt of part of a pack from the stores (#61824)
                                    ord.received = "0"     '  "        Which was opened up with (#61824)                            '      "
                                    ord.cost = ""          '  "                                                                     '      "
                                 End If                    '  "                                                                     '      "
                                 'ord.cost = ""        '25Feb02 TH Removed  (#55087)                                                                            '19Nov99 AE Moved inside if
                              End If                                             '17Jan01 TH
                           End If                                                                                                     '      "
   
                        Case Else
                           ord.received = "0" 'ASC 30Aug93 Added to make F7 not receive amended lines
                     End Select
                     '04Aug09 TH Added Double Receipt logging
                     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                        WriteLogSQL "Receiveitem: Part of Order Qty to be received", "DoubleRecLog", 5, lngLogThreadID
                     End If
                     '-------
                  End If
                  ord.invnum = BatchNum$
                  ord.paydate = ExpiryDate$
                  ord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
                  
                  lngOK = PutOrder(ord, (foundorder&), "WOrder")          '<---UNLOCK   (no idx) 'SQL Need update to correctly return the ID
                  'If UCase$(msg$) <> "N" Then popmessagecr "!Internal Orders", msg$  '14Apr05 TH Moved from above
                  'If Trim$(msg$) <> "" Then popmessagecr "!Internal Orders", msg$   '06May05 TH Added '06Jan06 TH moved below transactional operations
                  '04Aug09 TH Added Double Receipt logging
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     WriteLogSQL "Receiveitem: Order Line unlocked and updated, WOrderID =" & Format$(foundorder&), "DoubleRecLog", 6, lngLogThreadID
                  End If
                  '-------
                  If Val(QtyReceived$) > 0 Then   'ASC 30Aug93
                     'Add reconciliation transaction
                     '------------------------------
   
                     '**** donot do this if drug flag says no and ord.cost=0 and trim ord.cost <>""
                     'If d.pflag <> "N" or (Trim$(ord.cost) <> "" And Val(ord.cost) = 0) Then    '01Feb99 TH                     '23Feb99 TH replaced to take better account of free items
                     '19Jan01 TH Replaced with block below
                     'If Trim$(UCase$(d.pflag)) <> "N" Or Not (Trim$(ord.cost) <> "" And Val(ord.cost) = 0) Or (Trim$(UCase$(d.pflag)) <> "N" And freeflag) Then  '   "
                     '      getnumofords 4, pointer&, -1
                     '      LSet tempord = ord
                     '      getorder ord, (pointer&), 4, True '<-LOCK place to write
                     '      LSet ord = tempord
                     '      If freeflag Then          '28Jan99 TH  Added to allow for free receive
                     '            ord.cost = "0"      '  "
                     '         Else                   '  "
                     '            ord.cost = Trim$(purprice$)   '21Jun93 CKJ Added. Previously the price at ordering was used
                     '         End If                 '  "
                     '      'ord.recdate = thedate(False, False)
                     '      'ord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
                     '      ord.recdate = TheDate(False, True) '03May98 CKJ Y2K
                     '      ord.received = qtyreceived$
                     '      ord.paydate = ""
                     '      ord.invnum = ""
                     '      'ord.ward = ""                     '05may98 CKJ ward field not required
                     '      ord.status = "4"
                     '      putorder ord, (pointer&)                '<-UNLOCK replace (idx rebuilt below)
                     '      updateordreqindex 4, "", ord.code, "", ord.num, (pointer&)
                     '
                     '      LookupDrug ord.code, d, (found) '14Jan94 CKJ Added
                     '      '!!** why is qty ordered set to outstanding which is usually 0 unless there are to follows?
                     '      Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, qtyreceived$, ord.cost, ord.supcode, "R", sitepaths, batchnum$, d.vatrate '14Jan94 CKJ VAT
                     '   End If  '01Feb99 TH
   
                     If (Val(ord.PSORequestID) < 1) And ((Trim$(UCase$(d.pflag)) = "N" And (Trim$(ord.cost) <> "" And Val(ord.cost) = 0)) Or (Trim$(UCase$(d.pflag)) = "N" And freeflag)) Then   '19Feb13 TH Always reoncile PSO
                        ord.recdate = thedate(False, True) '03May98 CKJ Y2K     '  Ensure free items with "no reconcile" flag
                        ord.received = QtyReceived$                             '  have no reconcil record written, but are stil logged as receipts !
                        ord.cost = "0"
                        ord.paydate = ""
                        ord.Reconciledate = ""   '28Jan04 TH Added
                        ord.invnum = ""
                        LookupDrug ord.Code, d, (found) '14Jan94 CKJ Added
                        'Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, qtyreceived$, ord.cost, ord.supcode, "R", sitepaths, batchnum$, d.vatrate '12Dec00 TH      '15Jan02 TH Add Time received to log (#53214)
                        ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate  '    "
                        Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '26Mar09 TH Added
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", ""  '    "
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID   '04Mar14 TH Added PSORequestID
                        '04Aug09 TH Added Double Receipt Logging
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Receipt OrderLog Written, no reconcil required", "DoubleRecLog", 8, lngLogThreadID
                        End If
                        '-------
                     Else                                                       '    "
                        ''getnumofords 4, pointer&, -1                            '
                        ''LSet tempord = ord
                        ''getorder ord, (pointer&), 4, True  '<-LOCK place to write
                        ''LSet ord = tempord
                        '26Oct06 TH Added
                        pointer& = 0 'SQL Force Insert
                        If lngBatchWReconcilID > 0 Then
                           'Here we must look up previous reconcil records if appropriate to get the pointer,cost and qtyReceived
                           'Once we find the order we will lock it !!!!
                           getorder Batchord, lngBatchWReconcilID, 4, True
                           If Batchord.status <> 4 Then 'someone has been "in like flyn"
                              'unlock the order ,go the usual way and prepare a msg
                              lngBatchWReconcilID = PutOrder(Batchord, (lngBatchWReconcilID), "WReconcil")
                              strBatchGroupAbort = "Unable to amalgamate invoice records, status may have changed, the receipt will now be shown seperately on the invoice"
                           Else
                              '04Sep15 TH (TFS 128729)This was wrong ! In ordering we use a pack cost NOT a total cost, so adding the cost is
                              'incorrect and adding value to the log and the invoice record that is NOT reflected in the actual receipt cost
                              'this means the line will go out of balance with an incorrect invoice record when matched correctly
                              'The average pack cost between the old and new lines needs to be recorded here
                              'If Not freeflag Then
                              '   ord.cost = Format$(dp!(Val(Batchord.cost) + (Val(purprice$))))
                              'End If
                              '04Sep15 Replacement for above 3 lines
                              If Not freeflag Then
                                 ord.cost = Format$(dp!(Val(Batchord.cost) * dp!(Val(Batchord.received)) + (Val(purprice$) * Val(QtyReceived$)))) / (Val(Batchord.received) + Val(QtyReceived$))
                              End If
                              ord.received = Format$(dp!(Val(Batchord.received) + Val(QtyReceived$)))
                              pointer& = Batchord.OrderID 'We will almalgamate on the existing invoice line
                           End If
                        End If
                        If pointer& = 0 Then
                        '--------------
                           If freeflag Then          '28Jan99 TH  Added to allow for free receive
                              ord.cost = "0"      '  "
                           Else                   '  "
                              ord.cost = Trim$(purprice$)   '21Jun93 CKJ Added. Previously the price at ordering was used
                           End If                 '  "
                           'ord.recdate = thedate(False, False)
                           'ord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
                           'ord.recdate = thedate(False, True) '03May98 CKJ Y2K '22Feb07 TH Now handled below
                           ord.received = QtyReceived$ '05Mar07 TH Reinstated - must have been removed by accident in the amalgamation mod.
                        End If
                        ord.recdate = thedate(False, True) '22Feb07 TH Added- now uses latest recdate for same day partial batch merges
                        ord.paydate = ""
                        ord.Reconciledate = ""   '28Jan04 TH Added
                        ord.invnum = ""
                        'ord.ward = ""                     '05may98 CKJ ward field not required
                        ord.status = "4"
                        ord.DeliveryNoteReference = strDeliveryReference  '06Sep10 TH Added (F0054531)
                        'PutOrder ord, (pointer&), "Order"               '<-UNLOCK replace (idx rebuilt below)
                        'pointer& = 0 'SQL Force Insert '25Oct06 TH Moved above
                        pointer& = PutOrder(ord, (pointer&), "WReconcil")   'v93 Removed  updateordreqindex 4, "", ord.code, "", ord.num, (pointer&)
                        '04Aug09 TH Added Double Receipt Logging
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Reconciliation record written", "DoubleRecLog", 7, lngLogThreadID
                        End If
                        '-------
                        LookupDrug ord.Code, d, (found) '14Jan94 CKJ Added
                        '!!** why is qty ordered set to outstanding which is usually 0 unless there are to follows?
                        'Orderlog ord.num, ord.code, userid$, ord.orddate, ord.recdate, ord.outstanding, qtyreceived$, ord.cost, ord.supcode, "R", sitepaths, batchnum$, d.vatrate '14Jan94 CKJ VAT  '15Jan02 TH Add Time received to log (#53214)
                        ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate  '     "
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, "", ""  '     "
                        Heap 10, gPRNheapID, "olToFollow", Iff(ord.outstanding > 0, "Y", "N"), 0 '26Mar09 TH Added
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference '26Mar09 TH Added batchnum, expiry for UHB
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, ord.recdate & thedate(0, -2), ord.outstanding, QtyReceived$, ord.cost, ord.supcode, "R", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID   '04Mar14 TH Added PSORequestID
                        '04Aug09 TH Added Double Receipt Logging
                        If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                           WriteLogSQL "Receiveitem: Receipt OrderLog Written", "DoubleRecLog", 8, lngLogThreadID
                        End If
                        '-------
                     End If                                                     '    "
   
                     '**** 19Jan01 TH End of block
   
                     'If AskBatchNum Then             '21Dec98 CFY Replaced
                     If Val(d.batchtracking) > 1 Then '     "
                        'Orderlog ord.num, ord.code, userid$, ExpiryDate$, ord.recdate, ord.qtyordered, qtyreceived$, ord.cost, ord.supcode, "Q", sitepaths, batchnum$, d.vatrate  '24Feb94 CKJ Added  '15Jan02 TH Add Time received to log (#53214)
                        'Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference     '     "
                        'Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, ""      '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ExpiryDate$, ord.recdate & thedate(0, -2), ord.qtyordered, QtyReceived$, ord.cost, ord.supcode, "Q", sitepaths, BatchNum$, d.vatrate, BatchNum$, ExpiryDate$, strDeliveryReference, "", ord.PSORequestID   '04Mar14 TH Added PSORequestID
                     End If
                     ord.received = "0" 'ASC 30Aug93
                     '20Jun12 TH DLO STuff Again
                     If ord.DLO Then
                        'OK here we need to auto issue based on the qty recieved
                        
                        'Look up the requisition '05Sep14 Change pickno data type !!( TFS 99425)
                        strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "6") & _
                        gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, ord.DLOWard) & _
                        gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, ord.Code) & _
                        gTransport.CreateInputParameterXML("RequistionNum", trnDataTypeVarChar, 10, "") & _
                        gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, ord.pickno) & _
                        gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                                    
                        Set rsDLOOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisByCriteria", strSql)

                        blnDLOOrderFound = False
                        If Not rsDLOOrders Is Nothing Then
                           If rsDLOOrders.State = adStateOpen Then
                              If rsDLOOrders.RecordCount <> 0 Then
                                 blnDLOOrderFound = True
                                 'ord = FillOrdFromRS(rsOrders, "WOrder")
                                 getorder DLOOrd, RtrimGetField(rsDLOOrders!WRequisID), 6, True '10Jan07 TH Lock Now
                                 
                              End If
                           End If
                         End If
                        rsDLOOrders.Close
                        Set rsDLOOrders = Nothing
                        'If Not blnDLOOrderFound Then
                        If blnDLOOrderFound Then
                           'Look up the supplier
                           getsupplier ord.DLOWard, 0, 0, DLOSup
                           
                           'oldoutstanding! = Val(DLOOrd.outstanding) 'ASC
                           '05Jul12 TH Reinstated as this is used to identify wether the reqisition can be completed
                           If PrintInPacks Then
                              DLOOrd.outstanding = LTrim$(Str$(dp!(Val(DLOOrd.outstanding) - Val(QtyReceived$)))) 'LTrim$(Str$(dp!((DLOord.outstanding - Qty!) / Val(d.convfact))))
                           Else
                              DLOOrd.outstanding = LTrim$(Str$(dp!(Val(DLOOrd.outstanding) - (Val(QtyReceived$) * d.convfact)))) 'LTrim$(Str$(dp!((totalqty! - Qty!))))
                           End If
                           
                           If PrintInPacks Then  '02Jul12 TH Altered after unit test
                              DLOOrd.received = LTrim$(Str$(dp!(Val(DLOOrd.received) - Val(QtyReceived$)))) 'LTrim$(Str$(dp!((DLOord.outstanding - Qty!) / Val(d.convfact))))
                           Else
                              DLOOrd.received = LTrim$(Str$(dp!(Val(DLOOrd.received) - (Val(QtyReceived$) * d.convfact)))) 'LTrim$(Str$(dp!((totalqty! - Qty!))))
                           End If
                           'newoutstanding! = Val(ord.outstanding) 'ASC
                           'outstandingchange! = newoutstanding! - oldoutstanding! 'ASC
                              
                           '30Dec97 EAC Prevent from dividing when Printing in Packs
                           If PrintInPacks Then
                              updateoutstanding Val(QtyReceived$), d
                           Else
                              updateoutstanding Val(QtyReceived$) * d.convfact, d
                           End If
                           'outstandingchange! = outstandingchange! / Val(d.convfact)   '14Oct97 EAC - correct for W,L type requisitions where orders are not in NSV's worths
                           'updateoutstanding outstandingchange!, d
                           'Update status if 0 outstanding
                           If Val(DLOOrd.outstanding) = 0 Then
                              DLOOrd.status = "D"
                           End If
                           PutOrder DLOOrd, DLOOrd.OrderID, "WRequis"
                           setbatchnum BatchNum$
                           setexpirydate ExpiryDate$
                           Translog d, 0, UserID, "", Val(QtyReceived$) * d.convfact, "", DLOSup.Code, "", "S", SiteNumber, "S", itemunitcost$
                           'If d.batchtracking = 4 Then
                           If Val(d.batchtracking) = 4 Then '06Mar13 TH Replaced above. This must have been missed in a merge TFS 58220
                              TakeStockFromBatchbyBatchNumber ord.Code, Val(QtyReceived$), BatchNum$, ExpiryDate$
                           End If
                           'UpdateWardStockListIssueData d.SisCode, DLOSup.wardcode, "REQ", CInt(Val(QtyReceived$) * d.convfact) '27Jun11 TH Added
                           'UpdateWardStockListIssueData d.SisCode, DLOSup.wardcode, "REQ", CLng(Val(QtyReceived$) * d.convfact) '11Apr14 TH Now coerce param to long (TFS 88720)
                           UpdateWardStockListIssueData d.SisCode, DLOSup.wardcode, "REQ", CLng(Val(QtyReceived$) * d.convfact), DLOOrd.WWardProductListLineID '18Dec14 TH Now send the line ID (if present) so we can update the stock list correctly
                           setbatchnum ""
                           'If UCase$(DLOSup.PrintDeliveryNote) = "Y" Then  16Aug16 XN 160233 PrintDeliveryNote comes from Ward stock list now
                           'If IfRequiresDeliveryNote(DLOOrd.WWardProductListLineID) Then
                           If IfRequiresDeliveryNote(DLOOrd.WWardProductListLineID, DLOSup) Then '16Apr17 TH Allow none list reqs to print if required (TFS 181524)
                              If PrintInPacks Then 'quantity! = quantity! / Val(d.convfact)  '12Jun98 EAC handle qty print on picks/del notes in Print In Packs turned on
                                 CreateDeliveryNoteRecordSQL Val(QtyReceived$), itemunitcost$, DLOSup.wardcode, DLOOrd.pickno, True
                              Else
                                 CreateDeliveryNoteRecordSQL Val(QtyReceived$) * d.convfact, itemunitcost$, DLOSup.wardcode, DLOOrd.pickno, True
                              End If
                           End If
                           'create delivery note if required
                           'Update WStock list
                        Else
                        'msg
                           popmessagecr "!EMIS Health", "This is a DLO receipt but no linked requisition can be found. This means no automatic issue will be possible"
                        End If
                     '03Sep12 TH  Main PSO work for PSO receipt (TFS 42771) Update any associated label and issue out the stock and batch received
                     ElseIf ord.PSORequestID > 0 Then
                        'Here we have a PSO Receipt. We need to update any linked label with the qty issued and date and we need to issue the item to the patient
                        blnOK = GetLabelNL(ord.PSORequestID, lclL)
                        If lclL.RequestID = ord.PSORequestID Then
                           'Update the label and record data for use in the translog
                           'parsedate (lclL.lastdate), strTemp, "3", intValid
                           parsedate LastSavedDateTimeToLastDate(lclL.lastSavedDateTime), strTemp, "3", intValid '24Feb13 TH Merge
                           Qty! = dp!(Val(QtyReceived$) * d.convfact)
                           If Not intValid Or strTemp <> thedate(False, True) Then
                              lclL.lastqty = Qty!
                           Else
                              lclL.lastqty = dp!(lclL.lastqty + Qty!) '25Aug93 added dp! ASC
                           End If                  '25Mar03 TH Added (PBSv4)
         
                           lclL.Nodissued = lclL.Nodissued + Qty!
                           If d.dosesperissueunit > 0 Then      '   "
                              converter! = d.dosesperissueunit
                              lclL.RxNodIssued = lclL.RxNodIssued + (Qty! * converter!)
                           Else
                              lclL.RxNodIssued = lclL.RxNodIssued + Qty!
                           End If
                           
                           lclL.lastSavedDateTime = Now  '26Jan15 TH Set the date as issued date. Not the genuine date but the best approx we have.(TFS 109430)
                           
                           blnOK = PutLabelNL(lclL)
                           setbatchnum BatchNum$
                           setexpirydate ExpiryDate$
                           setLabelRequestID ord.PSORequestID '03Sep12 TH Set for PSO
                           setPrescriptionID lclL.PrescriptionID
                           
                           TranslogPSOrderInfo ord.OrderID, False '03Sep12 TH This is used to preset pat stuff for log
                           Translog d, 0, UserID, lclL.patid, Val(QtyReceived$) * d.convfact, lclL.dircode, lclL.wardcode, lclL.ConsCode, lclL.IssType, SiteNumber, lclL.IssType, itemunitcost$
                           
                           'If d.batchtracking = 4 Then
                           If Val(d.batchtracking) = 4 Then '10Mar13 TH Replaced above. Missed this when fixing DLO. Silly boy (TFS 58632)
                              TakeStockFromBatchbyBatchNumber ord.Code, Val(QtyReceived$), BatchNum$, ExpiryDate$
                           End If
                           
                           setbatchnum ""
                           TranslogPSOrderInfo 0, True '03Sep12 TH Clear PSO stuff for next translog write
                           setLabelRequestID 0
                           setPrescriptionID 0
                           
                           If Not blnOK Then
                              popmessagecr "!EMIS Health", "This is a PSO receipt but there was a problem updating the linked dispensing. This means no change to the patients pmr will be possible"
                           End If
                        Else
                           popmessagecr "!EMIS Health", "This is a PSO receipt but no linked dispensing can be found. This means no automatic issue will be possible"
                        End If
                        '03Sep12 TH  Main PSO work for PSO receipt (TFS 42771) END
                     
                     End If
                                 
                  End If
                  '06Jan06 TH This is the end of the transactional bound operation so we commit here
                  If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingRec", 0)) Then
                     gTransportConnectionExecute "Commit Transaction"      '15Aug12 CKJ
                  End If
                  
                  If Trim$(msg$) <> "" Then popmessagecr "!Internal Orders", msg$   '06Jan06 TH Moved from above

                  '14Apr05 TH Added. These are messages that previously where displayed modally within updateprice and therefore within record locks. Now these are defered till after the locks are released
                  If strWarMsg <> "" Then popmessagecr "!n!bWARNING", strWarMsg
                  If strWarMsg2 <> "" Then popmessagecr "!n!bWARNING contact supervisor", strWarMsg2
                  '14Apr05 TH
                  
'27Jun11 CKJ unused. removed.
'                  'Reprint line
'                  '------------
'                  If Not newscreen And Not auto Then
'                     For newlinnum = 1 To 21
'                        If ORecNo&(newlinnum) = foundorder& Then Exit For
'                     Next newlinnum
'
'                     If newlinnum < 21 Then
'                        linnum = newlinnum
'                        'popmessagecr "Eddie", "use an additem to add received goods to table"                '27May04 CKJ
'                        popmessagecr "", "use an additem to add received goods to table"                      '   "
'                        LineCost$ = Str$(dp!(Val(ord.cost) * Val(ord.received) / 100)) '23Jun93 CKJ dp
'                        poundsandpence LineCost$, True
'                     End If
'                  End If
               
               Else                                                 '16May04 TH (#59077)
                  '**** putorder 'unlock !!!                        '    "
                  ''If Not blnAbort Then putorder ord, (foundorder&)  '    "   ''06Apr05 TH Should now never lock if escape from updateprice
                  If strWarMsg <> "" Then popmessagecr "!n!bWARNING", strWarMsg
                  If lngOrderPointer = 0 Then k.escd = False '15May05 TH unset this so as to reset the grid
               End If                                               '    "
            End If
         End If                                               '    "
      End If
   End If
   If Trim$(strBatchGroupAbort) <> "" Then popmessagecr "!n!bWARNING", strBatchGroupAbort '26Oct06 TH
   Heap 10, gPRNheapID, "olToFollow", "", 0 '26Mar09 TH Added '26Mar09 TH Added
End Sub

Sub RecordBatchNo(batchno$, i_strQty As String)
'21Dec98 CFY Written
'30Mar99 CFY Added extra information to user prompt
'22Jul99 TH  Store batchnumber in ord.invnum here so that it can be logged correctly later
'18Jan02 TH  Added qty$ as new parameter to properly reflect amount ordered at
'   "        this time, which is flagged here to the user  (#50094)

Dim desc$, msg$
   
   k.helpnum = 0
   'k.Max = 12
   k.Max = 25 '23Oct06 TH Extended field
   
   '30Mar99 CFY Added block
   desc$ = d.DrugDescription    ' desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
   plingparse desc$, "!"                                                                                          '       "
   msg$ = cr & "  " & desc$ & cr & "  Order number         " & ord.num & cr                                       '       "
   'msg$ = msg$ & "  Quantity received    " & Trim$(ord.received) & " x " & d.convfact & d.PrintformV & cr & cr     '18Jan02 TH Replaced with below (#50094)
   msg$ = msg$ & "  Quantity received    " & Trim$(i_strQty) & " x " & d.convfact & d.PrintformV & cr & cr          '       "
   msg$ = msg$ & "Enter Batch Number "                                                                            '       "

   InputWin "EMIS Health", msg$, batchno$, k
   
   If Len(batchno$) > 12 Then             '22Jul99 TH Store batchnumber in invnum here so that it can be logged correctly
         ord.invnum = Left(batchno$, 12)  '   "
      Else                                '   "
         ord.invnum = batchno$            '   "
         
      End If                              '   "
   ord.batchnumber = batchno$   '08Mar07 TH Added
   

End Sub

Sub RecordExpiry(ord As orderstruct, NeedsWindow%, expiry$, ByVal intExpiryWarnDays As Integer)
'21Dec98 CFY Written
'11Apr02 TH  Various changes; Extended input length so user can use fuller range (date is later formatted for file),
'            Date Formatting altered to ensure the output is a valid date for the batch stock tbl in the mdb,
'            Ensure title is not concatenated on repeat loop after invalid entry (#60239)
'25Apr02 TH/SF Redone date validation to handle "t" etc on second pass
'28Jun02 TH  Ensure correct format of expiry date goes to logs (#61570)
'14Jun13 TH  Added Expiry Date Checks - includes new parameter (TFS 39884)
'19Jun13 TH  Stop firing of expiry check until final pass (TFS 66867)
'25Jul13 TH  Use days not minutes in comparison (TFS 69692)

Dim msg$, desc$
Dim valid%
Dim strFormat As String, strTmpDate As String  '11Apr02 TH Added
Dim blnDone As Integer '25Apr02 TH/SF
Dim ndbd&                                          '14Jun13 TH Added (TFS 39884)
Dim strlimitDate As String                         '     "
Dim limitdt As DateAndTime, dt As DateAndTime      '     "
Dim strStartDate As String                         '     "
Dim strEndDate  As String                          '     "
Dim strExpiryMsg As String                         '     "

   msg$ = ""
   If NeedsWindow% Then
         desc$ = d.DrugDescription      ' desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         msg$ = cr & "  " & desc$ & cr & "  Order number         " & ord.num & cr & "  Quantity received    " & Trim$(ord.received) & " x " & d.convfact & d.PrintformV & cr & cr
      End If
   msg$ = msg$ & "  Enter Batch Expiry Date  dd/mm/yyyy"   '25Apr02 TH/SF Move outside loop
   Do
      k.helpnum = 0
      'k.max = 10       '11Apr02 TH Extended input
      k.Max = 15        '   "
      'Expiry$ = ""
      'If InStr(msg$, "Enter Batch Expiry Date") = 0 Then msg$ = msg$ & "  Enter Batch Expiry Date   "   '11Apr02 TH Added check to stop concatenation on loop

      InputWin "EMIS Health", msg$, expiry$, k
      If Not k.escd Then
            '11Apr02 TH Replaced block (#60239)
            ''If trimz(Expiry$) <> "" Then
            ''   strFormat = "1"
            ''      parsedate Expiry$, strTmpDate, strFormat, valid%
            ''      If valid% Then
            ''         If strFormat = "0" Then
            ''               valid = False
            ''               BadDate
            ''            Else
            ''               parsedate (Expiry$), Expiry$, "3", valid
            ''               ord.paydate = Expiry$
            ''               parsedate (Expiry$), Expiry$, "1-", valid
            ''            End If
            ''         Else
            ''            BadDate
            ''        End If
            ''   End If
            
               
               strFormat = "1"                                                                    '25Apr02 TH/SF Redone to handle "t" etc on second pass
               parsedate expiry$, strTmpDate, strFormat, valid        '03May98 CKJ Y2K ddmmyyyy   '    "
               If valid And strFormat <> "0" Then                                                 '    "
                  If expiry$ = strTmpDate Then                                                 '    "
                     blnDone = True                                                         '    "
                     parsedate (expiry$), expiry$, "3", valid  '28Jun02 TH added to ensure correct format goes to logs (#61570)
                     ord.paydate = expiry$                                                  '    "
                     parsedate (expiry$), expiry$, "1-", valid                              '    "
                  End If                                                                    '    "
                  expiry$ = strTmpDate                                                         '    "
               Else                                                                            '    "
                  BadDate                                                                      '    "
                  expiry$ = ""                                                                 '    "
               End If                                                                          '    "
               '14Jun13 TH Expiry Date Checks (TFS 39884)
               'If expiry$ <> "" And blnDone Then
               If expiry$ <> "" And blnDone And valid Then  '19Jun13 TH Added to stop firing until final pass (TFS 66867)
                  '14Jun13 TH Now we have a date we need to check and possibly warn the user
                  parsedate (expiry$), strStartDate, ("dd mm yyyy"), 0
                  StringToDate Format$(Now, "dd/mm/YYYY"), dt
                  datetomins dt
                  'limitdt.mint = ((intExpiryWarnDays) * 1440)
                  limitdt.day = intExpiryWarnDays   '25Jul13 TH Use days not minutes (TFS 69692)
                  AddExpiry dt, limitdt
                  DateToString dt, strlimitDate      'dd/mm/ccyy
                  parsedate (strlimitDate), strEndDate, ("dd mm yyyy"), 0
                  datetodays strEndDate, strStartDate, ndbd&, 0, "", 0
                  If ndbd& <= 0 Then
                     strExpiryMsg = "The expiry entered is below the minimum acceptable period. Please review. "
                     strExpiryMsg = TxtD(dispdata$ & "\winord.ini", "Receipt", strExpiryMsg, "ExpiryWarningMessage", 0)
                     popmessagecr "!", strExpiryMsg
                  End If
               End If
            'If Expiry$ = "" Then
            '      ord.paydate = ""
            '      Valid = True
            '   Else
            '      parsedate (Expiry$), Expiry$, "3", Valid
            '      If Valid Then
            '            ord.paydate = Expiry$
            '            parsedate (Expiry$), Expiry$, "1-", Valid
            '         Else
            '            BadDate
            '         End If
            '   End If
            '----------------------'11Apr02 TH
         End If
   Loop Until k.escd Or blnDone

End Sub

Sub ResetMenuOptions()
'23Feb99 JP New function added to reset all menu options when logging in
'22Apr02 SF/TH disables shelf stock and goods received report
'//// doesn't seem to be executable
   
   MainScreen.MnuPrgm.Enabled = True
   MainScreen.MnuProgram(0).Enabled = True
   MainScreen.MnuProgram(2).Enabled = True
   MainScreen.MnuProgram(4).Enabled = True
   
   MainScreen.MnuOrders.Enabled = True
   MainScreen.MnuOrdersCreate.Enabled = False
   MainScreen.MnuOrdersAmend.Enabled = False
   MainScreen.MnuOrdersAuth.Enabled = False
   MainScreen.MnuOrdersSupp.Enabled = False
   MainScreen.MnuOrdersReceive.Enabled = False
   MainScreen.MnuOrdersCredit.Enabled = False
   MainScreen.MnuOrdersAuthCred.Enabled = False
   MainScreen.MnuRepOrds.Enabled = False
   MainScreen.MnuOrdersModem = False
   SetRobotLoadingMenuOption False              '07Jan10 CKJ added
   
   '22Apr02 SF/TH added
   MainScreen.MnuGoodsRcvd.Enabled = False
   MainScreen.mnuStockList.Enabled = False
   '22Apr02 SF ----

   MainScreen.MnuReq.Enabled = True
   MainScreen.MnuReqEnter.Enabled = False
   MainScreen.MnuToFollows.Enabled = False
   MainScreen.MnuReqPrintPick.Enabled = False
   MainScreen.MnuReqIssue.Enabled = False
   MainScreen.MnuReqDelivery.Enabled = False
   MainScreen.MnuReqReturn.Enabled = False
   MainScreen.MnuRepReqs.Enabled = False
   
   MainScreen.MnuFin.Enabled = True
   MainScreen.MnuFinRecon.Enabled = False
   MainScreen.MnuFinConfirm.Enabled = False
   MainScreen.MnuFinAP = False
   MainScreen.MnuFinSlips.Enabled = False
   MainScreen.MnuFinMonthEnd.Enabled = False
   MainScreen.MnuFinAdj.Enabled = False
   MainScreen.MnuFinDirect.Enabled = False
   MainScreen.MnuFinGL.Enabled = False

   MnuInfoEnabled False                         '13Mar07 CKJ replace above with single call

   MainScreen.MnuWS.Enabled = True
   MainScreen.MnuWardStock(0).Enabled = False
   MainScreen.MnuWardStock(1).Enabled = False
   MainScreen.MnuWardStock(3).Enabled = False
   MainScreen.MnuWardStock(5).Enabled = False
   MainScreen.MnuWardStock(6).Enabled = False
   MainScreen.MnuWardStock(7).Enabled = False
   MainScreen.MnuWardStock(9).Enabled = False
   MainScreen.MnuWardStock(10).Enabled = False
   MainScreen.MnuWardStock(12).Enabled = False
   
   MainScreen.MnuUtil.Enabled = True
   MainScreen.MnuUtilLevel.Enabled = False
   MainScreen.MnuUtilDang.Enabled = False
   MainScreen.MnuUtilNeg.Enabled = False
   MainScreen.MnuUtilAmend.Enabled = False
   MainScreen.MnuUtilDefs.Enabled = False
   MainScreen.MnuUtilCalcs.Enabled = False
   MainScreen.MnuUtilTidy.Enabled = False
   MainScreen.MnuUtilOut.Enabled = False
   MainScreen.MnuUtilCycle.Enabled = False
   MainScreen.MnuUtilContPrice.Enabled = False
   MainScreen.MnuUtilRestore.Enabled = False
   MainScreen.MnuEdiHdr.Enabled = False
   MainScreen.MnuUtilStckTake.Enabled = False
   MainScreen.MnuWSLayouts.Enabled = False
   
   MainScreen.MnuHlp.Enabled = True
   MainScreen.mnuHelp(0).Enabled = True
   MainScreen.mnuHelp(1).Enabled = True
   MainScreen.mnuHelp(2).Enabled = True
   MainScreen.mnuHelp(4).Enabled = True

End Sub

Sub ReturnToStore(sitepaths As Integer)
' 3Jun93 ASC
' 5Jul95 CKJ Added minor bits, but really would like full checking,
' eg validate order numbers, site code, add reason code etc
'27Aug96 EAC code to differentiate between returns to ward and store
'23Dec97 EAC  changed Issue action parameter from 1 to 5
'29Dec97 EAC Use Stores drug description
'15Feb99 SF  If list type chosen then user must select cost centre for that list
'17May99 AE  Changed formatting of d.stocklvl on screen
'16Jan02 TH  Added block to add to Delivery note if requested (#46670)
'20Mar02 TH  Altered Delivery Note mod after testing (#46670)
'31May02 TH  Added new parameter to CreateDeliveryNoteRecord call
'04Jun03 TH  Added to mask to prevent rubbish qty input (#68693)
'12Jun03 TH  Reinstated line to ensure Stypes can still print Delivery notes
'            - This should never have been included as this fault had been removed from the list
'16May04 TH  Use supplier code for delivery note if  wardcode is blank (#67791)
'01Jun11 CKJ Added as integer to sitepaths param & to Dim founddrug, issued
'16Aug16 XN  160233 PrintDeliveryNote comes from Ward stock list now

Dim drug$, desc$, ordernum$, ret$, ans$, issuecost$, title$, msg$, BatchNum$, expdate$, Form$
Dim founddrug As Integer, issued As Integer, Find%, duplicates%, NumLabels%   ', foundsup%
Dim Qty!
Dim escd%   '15Feb99 SF added
Dim strSupplierCode As String  '16May04 TH Added
Dim lngFoundSup As Long

   EnterDrug drug$, "Return to Store"
   If Not k.escd Then
      findrdrug drug$, True, d, 0, founddrug, 2, False, False
      If founddrug Then
         desc$ = Trim$(d.DrugDescription)       ' desc$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         'w = Len(desc$) + 2     '01Jun11 CKJ unused
         'If w < 40 Then w = 40  '   "
         title$ = "Return to Store: " + d.SisCode

         msg$ = Chr$(13) & "  " & desc$ & Chr$(13) & Chr$(13) + "Current stock level : " & TB$ & FormatVal$(d.stocklvl, 2, 4) + " " + d.PrintformV   '17May99 AE changed trim$ to FormatVal$
         If Val(d.convfact) <> 1 Then msg$ = msg$ & Chr$(13) & "Handled in units of : " & TB$ & Trim$(d.convfact) + " " + d.PrintformV + Chr$(13)
         popmessagecr title$, msg$

         If Not k.escd Then
             msg$ = "Enter Order number"
             msg$ = desc$ & crlf & crlf & "Enter Order number"
             setinput 0, k
             k.Max = 4
             k.nums = True
             ordernum$ = ""
             InputWin title$, msg$, ordernum$, k
         End If

         If Not k.escd Then asksupplier supcode$, StoreValCode%, StoreValDisplay$, "Select Supplier for Return.", False, sup, False  '15Nov12 TH Added PSO param
               
         If Not k.escd Then
            getsupplier supcode$, Find%, lngFoundSup, sup
            If lngFoundSup = 0 Then k.escd = True
            If lngFoundSup > 0 And sup.suppliertype = "L" Then
               supcode$ = Trim$(sup.wardcode)
               If supcode$ = "" Then
                  Do
                     askward "Cost Centre Required", supcode$, escd%, "W"
                     If Not escd% Then
                        getsupplier supcode$, 0, lngFoundSup, sup
                        If sup.suppliertype <> "W" Then
                           popmessagecr "#", supcode$ & " is not a set up as a ward" & cr & "You will need to select a ward."
                           supcode$ = ""
                        End If
                     Else
                        k.escd = True
                     End If
                  Loop Until (sup.suppliertype = "W" And Trim$(supcode$) <> "") Or escd%
               End If
            End If
         End If
      

         If Not k.escd Then
            If Trim$(UCase$(sup.suppliertype)) <> "W" And Trim$(UCase$(sup.suppliertype)) <> "L" Then
               Form$ = " x " & Trim$(d.convfact)
            End If
            Form$ = Form$ & " " & Trim$(d.PrintformV)
            'msg$ = "Enter qty to be returned (" & Form$ & ")"
            msg$ = desc$ & crlf & crlf & "Enter qty to be returned (" & Form$ & ")"
            setinput 0, k
            k.Max = 9
            ret$ = ""
            k.decimals = True
            k.nums = True
            InputWin title$, msg$, ret$, k
            k.decimals = False
            k.nums = False

            If Trim$(UCase$(sup.suppliertype)) <> "W" And Trim$(UCase$(sup.suppliertype)) <> "L" Then
               Qty! = -1! * Val(d.convfact) * Val(ret$)
            Else
               Qty! = -1! * Val(ret$)
            End If
         End If

         If Not k.escd And Qty! <> 0 Then
            setinput 0, k
            ans$ = "N"
            If Trim$(UCase$(sup.suppliertype)) <> "W" And Trim$(UCase$(sup.suppliertype)) <> "L" Then
               askwin "Adjust", desc$ & cr$ & Chr$(13) & "Ok to Return " + ret$ + " x " + Trim$(d.convfact) + " " + d.PrintformV, ans$, k
            Else
               askwin "Adjust", desc$ & cr$ & Chr$(13) & "Ok to Return " + ret$ + " " + d.PrintformV, ans$, k
            End If
            If ans$ = "Y" And Not k.escd Then
               'Store should really be told cost by dispensary !!**
               If Trim$(UCase$(sup.suppliertype)) <> "W" And Trim$(UCase$(sup.suppliertype)) <> "L" Then
                  Issue k, Qty!, Abs(Qty!), d, UserID$, "", UCase$(supcode$), issued, "P", UCase$(supcode$), ordernum$, sitepaths, "P", issuecost$, BatchNum$, expdate$, duplicates%, NumLabels%, 1
               Else
                  Issue k, Qty!, Abs(Qty!), d, UserID$, "", UCase$(supcode$), issued, "S", UCase$(supcode$), ordernum$, sitepaths, "S", issuecost$, BatchNum$, expdate$, duplicates%, NumLabels%, 5   '23Dec97 EAC changed 1 to 5
               End If
               'If UCase$(sup.PrintDeliveryNote) = "Y" Then   16Aug16 XN 160233 PrintDeliveryNote comes from Ward stock list now '04Jun03 TH Disallow Delivery notes if returning to a Store type. '12Jun03 TH Reinstated - This should never have been
               If IfRequiresDeliveryNoteByWardCodeNSVCodeAndSite(supcode$, d.SisCode) Then
                  Confirm "Return", "to show this item on a Delivery note", ans$, k
                  If Not k.escd And UCase$(Trim$(ans$)) = "Y" Then
                     If Trim$(sup.wardcode) <> "" Then
                        strSupplierCode = sup.wardcode
                     Else
                        strSupplierCode = sup.Code
                     End If
                     'If Trim$(UCase$(sup.suppliertype)) <> "W" And Trim$(UCase$(sup.suppliertype)) <> "L" Then    '20Mar02 TH Changed after testing (#46670)
                     If PrintInPacks Then                                                                          '     "
                        CreateDeliveryNoteRecordSQL dp!(Qty! / (Val(d.convfact))), issuecost$, strSupplierCode, 0, False '16May04 TH Use supplier code if  wardcode is blank
                     Else
                        CreateDeliveryNoteRecordSQL Qty!, issuecost$, strSupplierCode, 0, False
                     End If
                  End If
               End If
            End If
         End If
      Else
         popmessagecr "Return to Store", "Item not found"
      End If
   End If

End Sub


Sub SetLicenseOptions()
'22Oct97 EAC Update to cope with passwording for Mediate
'13Jan17 TH Now we use new settings as the license file is defunct (Hosted) (TFS 156988)
  
   

''    LX MainScreen.MnuOrders, "", 2, 0               'Main Menu : Ordering Menu
''    LX MainScreen.MnuOrdersModem, "", 2, 0          'Main Menu : Edi Option
''    LX MainScreen.MnuMedi, "", 2, 0                 'EDI Menu : Mediate Option
''    LX MainScreen.MnuTEDI, "", 2, 0                 'EDI Menu : Texsol Option
   'If fileexists(dispdata$ & "\ascribe.lx") Then '13Jan17 TH We no longer use the license file (Hosted) (TFS 156988)
      'LX MainScreen.MnuMediate(0), "", 2, 0           'Mediate Menu : Create EDI Order option
      'LX MainScreen.MnuMediate(1), "", 2, 0           'Mediate Menu : Read Prices With Order option
      'LX MainScreen.MnuMediate(2), "", 2, 0           'Mediate Menu : Read Invoices option
      'LX MainScreen.mnuEdi(0), "", 2, 0
      '13Jan17 TH Now we use new settings as the license file is defunct (Hosted) (TFS 156988)
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "License", "N", "MnuMediate0", 0)) Then MainScreen.MnuMediate(0).Enabled = True
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "License", "N", "MnuMediate1", 0)) Then MainScreen.MnuMediate(1).Enabled = True
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "License", "N", "MnuMediate2", 0)) Then MainScreen.MnuMediate(2).Enabled = True
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "License", "N", "mnuEdi0", 0)) Then MainScreen.mnuEdi(0).Enabled = True
   'End If
''    LX MainScreen.MnuReq, "", 2, 0                  'Main Menu : Ordering Menu
''    LX MainScreen.MnuFin, "", 2, 0                  'Main Menu : Ordering Menu
''    LX MainScreen.MnuFinAP, "", 2, 0                'Main Menu : Ordering Menu
''    LX MainScreen.MnuFinGL, "", 2, 0                'Main Menu : Ordering Menu
''    LX MainScreen.MnuInfoTop, "", 2, 0                 'Main Menu : Ordering Menu
''    LX MainScreen.MnuWS, "", 2, 0                   'Main Menu : Ordering Menu
''    LX MainScreen.MnuUtil, "", 2, 0                 'Main Menu : Ordering Menu
''
''    LX MainScreen.MnuEdiHdr, "", 0, 0               'Utilities Menu : Edi Line
'SQL    LX MainScreen.mnuEdi(0), "", 0, 0               'Utilities Menu : Edi : Mediate Options
'SQL    LX MainScreen.mnuEdi(1), "", 0, 0               'Utilities Menu : Edi : Texsol Options

End Sub

Sub SetMenuOptions()
'22Oct97 EAC - update passwording to cope with Mediate.
'03Dec97 EAC - updated passwording to cope with Adhoc Issue/Return
'              updated passwording to cope with Login menu option
'10Dec97 EAC - update to cope with new utilities option to update d.outstanding
'05Mar98 ASC - Added new menu options for reprinting
'10jul98 EAC - Prevent low level ward stock users from accessing some menu options
'11Nov99 TH    Enable mediate option only if licensed to do so
'30Mar00 CFY Mods to set menu's for pre-order print and goods received report.
'02May00 CKJ Reinstated line lost during the 30Mar00 edit
'15Sep00 TH/CFY  Enable set up of mediate/texsol if standard option is available
'22Nov00 EAC/CY Handle in-dispute items and allow reprints of dispute note
'06Apr01 CFY Added new menu option for to-follows print.
'29May01 TH  Disable WS Delete option for wstock lvl < 2
'18Jan02 TH  Various changes to reflect new menus for mediate (%EDI%)
'23Jan02 TH  Added stuff for ward lvl 5, now mirrors 1 but will allow temp insertion (not saved at end of session) (#52055)
'27Feb02 TH  Added new Cut menu option in WSLists (enh1463)
'16Apr02 TH  Changes to ensure levels for search and replace/delete are set correctly (enh1477)
'01Aug02 SF  added setup for .MnuInfo(7)
'13Mar07 CKJ added MnuInfo 8 & 9 for Robot messages
'07Jan10 CKJ added Robot loading menu
'14Nov12 TH  PSO Switch and menu handling (TFS 41433)
'16Feb15 TH  WardStock switch with new web version (TFS 109033)
'25Feb16 TH  Added support for Hub invoicing

Dim intIndex As Integer

    If Storepasslvl < 2 Or Storepasslvl = 5 Then
      SetFindDrugLowPassLevel True '16May TH Moved here to cover all login avenues
    Else
      SetFindDrugLowPassLevel False
    End If
    
    '05Jul12 TH Added (TFS 37704)
    If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0)) Then
      MainScreen.MnuDLOReqTop.Visible = False
    End If
    
    '16Feb15 TH  WardStock switch with new web version (TFS 109033)
    If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "N", "UseOldWardStock", 0)) Then
      For intIndex = 2 To 10
         MainScreen.MnuWardStock(intIndex).Visible = False
      Next
      'MainScreen.MnuWardStock(12).Visible = False '17Feb15 TH now reversed as we need this functionailty to be retained
      MainScreen.MnuWardStock(8).Visible = True    '  "        include the divider
      MainScreen.MnuUtilAmend.Visible = False     '20Feb15 TH We must also remove the old supplier/ward/list editor (TFS 109033)
    End If
    
    Select Case Storepasslvl
        Case 0
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = False        '05Mar98 ASC/EAC MainScreen.MnuOrdersCreate.Enabled = False
            MainScreen.MnuOrdersAmend.Enabled = False
            MainScreen.mnuPSOAmend.Enabled = False     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = False  '30Mar00 CFY Added
            MainScreen.MnuOrdersAuth.Enabled = False
            MainScreen.mnuPSOAuth.Enabled = False        '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuOrdersReceive.Enabled = False
            MainScreen.MnuGoodsRcvd.Enabled = False      '30Mar00 CFY Added
            MainScreen.mnuPSORec.Enabled = False         '14Nov12 TH Added (TFS 41433)
            MainScreen.mnuPSOHubRec.Enabled = False      '23Apr14 TH Added eHUB
            MainScreen.mnuStockList.Enabled = False      '22Apr02 SF added
            MainScreen.MnuOrdersCredit.Enabled = False
            MainScreen.MnuOrdersAuthCred.Enabled = False
            MainScreen.MnuOrdersSupp.Enabled = False
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = False        '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = False
            MainScreen.MnuToFollows.Enabled = False      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = False
            MainScreen.MnuReqIssue.Enabled = False
            MainScreen.MnuReqDelivery.Enabled = False
            MainScreen.MnuReqReturn.Enabled = False
            MainScreen.MnuFin.Enabled = True
            MainScreen.MnuFinRecon.Enabled = False
            MainScreen.mnuPSOInv.Enabled = False         '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuFinConfirm.Enabled = False
            MainScreen.MnuFinDispNotes.Enabled = False
            MainScreen.MnuFinSlips.Enabled = False
            MainScreen.MnuFinAdj.Enabled = False
            MainScreen.MnuFinMonthEnd.Enabled = False
            MainScreen.mnufinreprints.Enabled = False
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = False
            MainScreen.MnuUtilDang.Enabled = False
            MainScreen.MnuUtilNeg.Enabled = False
            MainScreen.MnuUtilAmend.Enabled = False
            MainScreen.MnuUtilDefs.Enabled = False
            MainScreen.MnuUtilCalcs.Enabled = False
            MainScreen.MnuUtilTidy.Enabled = False
            MainScreen.MnuUtilOut.Enabled = False '10Dec97 EAC
            MainScreen.MnuUtilRestore.Enabled = False
            MainScreen.MnuUtilCycle.Enabled = False
            MainScreen.MnuUtilStckTake.Enabled = False
            MainScreen.MnuUtilContPrice.Enabled = False
            MainScreen.MnuWSLayouts.Enabled = False
            MainScreen.MnuMediate(0).Enabled = False
            MainScreen.MnuMediate(1).Enabled = False
            MainScreen.MnuMediate(2).Enabled = False
            MainScreen.MnuEdiHdr.Enabled = False
            MainScreen.mnuHelp(0).Enabled = False
            MainScreen.mnuHelp(1).Enabled = False
            MainScreen.mnuHelp(2).Enabled = False
            MainScreen.mnuHelp(4).Enabled = False
            
            MnuInfoEnabled False                         '13Mar07 CKJ replace above with single call
            
            MainScreen.mnuPSOHubInv.Enabled = False          '25Feb16 TH Added
            MainScreen.mnuPSOHubInvSettings.Enabled = False
            
            MainScreen.MnuProgram(0).Enabled = False
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
        
        Case 1
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
        Case 2
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True            '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added
            MainScreen.MnuOrdersAuth.Enabled = True         '02May00 CKJ Reinstated line lost during the 30Mar00 edit below
            MainScreen.mnuPSOAuth.Enabled = True        '14Nov12 TH Added
            MainScreen.MnuPreOrderPrint.Enabled = True      '30Mar00 CFY Added
            MainScreen.MnuOrdersCredit.Enabled = True
            MainScreen.MnuOrdersAuthCred.Enabled = True
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True            '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
        Case 3
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True            '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = True
            MainScreen.MnuOrdersReceive.Enabled = True
            MainScreen.mnuPSORec.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.mnuPSOHubRec.Enabled = True      '23Apr14 TH Added eHUB
            MainScreen.MnuGoodsRcvd.Enabled = True          '30Mar00 CFY Added
            MainScreen.mnuStockList.Enabled = True      '22Apr02 SF added
            MainScreen.MnuOrdersCredit.Enabled = True
            MainScreen.MnuOrdersAuthCred.Enabled = True
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True            '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
        Case 4, 5
            MainScreen.MnuFin.Enabled = True
            MainScreen.MnuFinRecon.Enabled = True
            MainScreen.mnuPSOInv.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuFinConfirm.Enabled = True
            MainScreen.MnuFinSlips.Enabled = True
            MainScreen.MnuFinAdj.Enabled = True
            MainScreen.MnuFinMonthEnd.Enabled = True
            
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
            MainScreen.mnuPSOHubInv.Enabled = True          '25Feb16 TH Added
            MainScreen.mnuPSOHubInvSettings.Enabled = True
            
        Case 6
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = True      '30Mar00 CFY Added
            MainScreen.MnuOrdersCredit.Enabled = True
            MainScreen.MnuOrdersAuthCred.Enabled = True
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '25Mar02 TH Added (enh1477)
            
        Case 7
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = True      '30Mar00 CFY Added
            MainScreen.MnuOrdersAuth.Enabled = True
            MainScreen.mnuPSOAuth.Enabled = True        '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuOrdersReceive.Enabled = True
            MainScreen.mnuPSORec.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.mnuPSOHubRec.Enabled = True      '23Apr14 TH Added eHUB
            MainScreen.MnuGoodsRcvd.Enabled = True          '30Mar00 CFY Added
            MainScreen.mnuStockList.Enabled = True      '22Apr02 SF added
            MainScreen.MnuOrdersCredit.Enabled = True
            MainScreen.MnuOrdersAuthCred.Enabled = True
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
        Case 8
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = True      '30Mar00 CFY Added
            MainScreen.MnuOrdersAuth.Enabled = True
            MainScreen.mnuPSOAuth.Enabled = True        '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuOrdersReceive.Enabled = True
            MainScreen.mnuPSORec.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.mnuPSOHubRec.Enabled = True       '23Apr14 TH Added eHUB
            MainScreen.MnuGoodsRcvd.Enabled = True          '30Mar00 CFY Added
            MainScreen.mnuStockList.Enabled = True      '22Apr02 SF added
            MainScreen.MnuOrdersCredit.Enabled = True
            MainScreen.MnuOrdersAuthCred.Enabled = True
            MainScreen.MnuOrdersSupp.Enabled = True
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            MainScreen.MnuFin.Enabled = True
            MainScreen.MnuFinRecon.Enabled = True
            MainScreen.mnuPSOInv.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuFinConfirm.Enabled = True
            MainScreen.MnuFinDispNotes.Enabled = True            '22Nov00 EAC/CY Added
            MainScreen.MnuFinSlips.Enabled = True
            MainScreen.MnuFinAdj.Enabled = True
            MainScreen.MnuFinMonthEnd.Enabled = True
            MainScreen.mnufinreprints.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.MnuUtilAmend.Enabled = True
            MainScreen.MnuUtilDefs.Enabled = True
            MainScreen.MnuUtilCalcs.Enabled = True
            MainScreen.MnuUtilOut.Enabled = True '10Dec97 EAC
            MainScreen.MnuUtilTidy.Enabled = True
            MainScreen.MnuUtilRestore.Enabled = True
            MainScreen.MnuUtilCycle.Enabled = True
            MainScreen.MnuUtilStckTake.Enabled = True
            MainScreen.MnuUtilContPrice.Enabled = True
            MainScreen.MnuWSLayouts.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.mnuPSOHubInv.Enabled = True          '25Feb16 TH Added
            MainScreen.mnuPSOHubInvSettings.Enabled = True
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
        Case 9
            MainScreen.MnuOrders.Enabled = True
            MainScreen.MnuRepOrds.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuOrdersCreate.Enabled = True
            MainScreen.MnuOrdersAmend.Enabled = True
            MainScreen.mnuPSOAmend.Enabled = True     '14Nov12 TH Added (TFS 41433)
            MainScreen.MnuPreOrderPrint.Enabled = True               '30Mar00 CFY Added
            MainScreen.MnuOrdersReceive.Enabled = True
            MainScreen.mnuPSORec.Enabled = True         '14Nov12 TH Added (TFS 41433)
            MainScreen.mnuPSOHubRec.Enabled = True      '23Apr14 TH Added eHUB
            MainScreen.MnuGoodsRcvd.Enabled = True                   '30Mar00 CFY Added
            MainScreen.mnuStockList.Enabled = True      '22Apr02 SF added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            MainScreen.MnuFin.Enabled = True
            MainScreen.MnuFinSlips.Enabled = True
            MainScreen.MnuFinAdj.Enabled = True
            MainScreen.MnuFinMonthEnd.Enabled = True
            MainScreen.MnuFinDirect.Enabled = True
            
            MainScreen.MnuUtil.Enabled = True
            MainScreen.MnuUtilLevel.Enabled = True
            MainScreen.MnuUtilDang.Enabled = True
            MainScreen.MnuUtilNeg.Enabled = True
            MainScreen.mnuHelp(0).Enabled = True
            MainScreen.mnuHelp(1).Enabled = True
            MainScreen.mnuHelp(2).Enabled = True
            MainScreen.mnuHelp(4).Enabled = True
            MnuInfoEnabled True                          '13Mar07 CKJ replace above with single call
            
            MainScreen.mnuPSOHubInv.Enabled = True          '25Feb16 TH Added
            MainScreen.mnuPSOHubInvSettings.Enabled = True
            
            MainScreen.MnuProgram(0).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False   '16Apr02 TH Added (enh1477)
            
      Case Else
            popmessagecr "Error", "Access level for Stock Control module is not in the defined range."
            storesEnd
      End Select

    Select Case WardStockPasslvl
        Case 0  'no access to Ward Stock
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = False
            MainScreen.MnuWardStock(1).Enabled = False
            MainScreen.MnuWardStock(3).Enabled = False
            MainScreen.MnuWardStock(5).Enabled = False
            MainScreen.MnuWardStock(6).Enabled = False
            MainScreen.MnuWardStock(7).Enabled = False
            MainScreen.MnuWardStock(9).Enabled = False
            MainScreen.MnuWardStock(10).Enabled = False
            MainScreen.MnuWardStock(12).Enabled = False
            MainScreen.MnuWSOSaveAs.Enabled = False
            MainScreen.MnuWSODelete.Enabled = False '29May01 TH
        Case 1  'issue and return : can't save changes
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = True
            MainScreen.MnuWardStock(1).Enabled = True
            MainScreen.MnuWardStock(3).Enabled = True
            MainScreen.MnuWardStock(5).Enabled = False
            MainScreen.MnuWardStock(6).Enabled = False
            MainScreen.MnuWardStock(7).Enabled = False
            MainScreen.MnuWardStock(9).Enabled = False
            MainScreen.MnuWardStock(10).Enabled = False
            MainScreen.MnuWardStock(12).Enabled = True
            '10Jul98 EAC added
            MainScreen.MnuWSOBlockDel.Enabled = False
            MainScreen.MnuWSOSort.Enabled = False
            MainScreen.MnuWSOCopy.Enabled = False
            MainScreen.MnuWSOCut.Enabled = False     '27Feb02 TH Added
            MainScreen.MnuWSOBlkInsert.Enabled = False
            MainScreen.MnuWSOChange.Enabled = False
            MainScreen.MnuWSOSaveAs.Enabled = False
            '---
            MainScreen.MnuWSODelete.Enabled = False '29May01 TH
            MainScreen.MnuWSOInsert.Enabled = False '05Jan06 TH
            'SQL TH Added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            '--------------
        Case 2  'everything except edit NSVCodes and S&R Across Wards
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = True
            MainScreen.MnuWardStock(1).Enabled = True
            MainScreen.MnuWardStock(3).Enabled = True
            MainScreen.MnuWardStock(5).Enabled = True
            MainScreen.MnuWardStock(6).Enabled = True
            MainScreen.MnuWardStock(7).Enabled = True
            MainScreen.MnuWardStock(9).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False
            MainScreen.MnuWardStock(12).Enabled = True
            '10Jul98 EAC added
            MainScreen.MnuWSOBlockDel.Enabled = True
            MainScreen.MnuWSOSort.Enabled = True
            MainScreen.MnuWSOCopy.Enabled = True
            MainScreen.MnuWSOCut.Enabled = True     '27Feb02 TH Added
            MainScreen.MnuWSOBlkInsert.Enabled = True
            MainScreen.MnuWSOChange.Enabled = True
            MainScreen.MnuWSOSaveAs.Enabled = True
            '---
            'SQL TH Added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            '--------------
        Case 3  'as (2) but can edit NSVcodes
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = True
            MainScreen.MnuWardStock(1).Enabled = True
            MainScreen.MnuWardStock(3).Enabled = True
            MainScreen.MnuWardStock(5).Enabled = True
            MainScreen.MnuWardStock(6).Enabled = True
            MainScreen.MnuWardStock(7).Enabled = True
            MainScreen.MnuWardStock(9).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = False
            MainScreen.MnuWardStock(12).Enabled = True
            '10Jul98 EAC added
            MainScreen.MnuWSOBlockDel.Enabled = True
            MainScreen.MnuWSOSort.Enabled = True
            MainScreen.MnuWSOCopy.Enabled = True
            MainScreen.MnuWSOCut.Enabled = True     '27Feb02 TH Added
            MainScreen.MnuWSOBlkInsert.Enabled = True
            MainScreen.MnuWSOChange.Enabled = True
            MainScreen.MnuWSOSaveAs.Enabled = True
            '---
            'SQL TH Added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            '--------------
        Case 4  'as (3) but with S&R and deletion of Ward Stock Lists
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = True
            MainScreen.MnuWardStock(1).Enabled = True
            MainScreen.MnuWardStock(3).Enabled = True
            MainScreen.MnuWardStock(5).Enabled = True
            MainScreen.MnuWardStock(6).Enabled = True
            MainScreen.MnuWardStock(7).Enabled = True
            MainScreen.MnuWardStock(9).Enabled = True
            MainScreen.MnuWardStock(10).Enabled = True
            MainScreen.MnuWardStock(12).Enabled = True
            '10Jul98 EAC added
            MainScreen.MnuWSOSaveAs.Enabled = True
            MainScreen.MnuWSOBlockDel.Enabled = True
            MainScreen.MnuWSOSort.Enabled = True
            MainScreen.MnuWSOCopy.Enabled = True
            MainScreen.MnuWSOCut.Enabled = True     '27Feb02 TH Added
            MainScreen.MnuWSOBlkInsert.Enabled = True
            MainScreen.MnuWSOChange.Enabled = True
            '---
            'SQL TH Added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            '--------------
        Case 5  'Ad-hoc Issues: can only issue what is on ward list
            MainScreen.MnuWS.Enabled = True
            MainScreen.MnuWardStock(0).Enabled = True
            MainScreen.MnuWardStock(1).Enabled = True

            '23Jan02 TH Added block - lvl now mirrors 1 but will allow temp insertion (not saved at end of session) (#52055)
            MainScreen.MnuWardStock(3).Enabled = True
            MainScreen.MnuWardStock(5).Enabled = False
            MainScreen.MnuWardStock(6).Enabled = False
            MainScreen.MnuWardStock(7).Enabled = False
            MainScreen.MnuWardStock(9).Enabled = False
            MainScreen.MnuWardStock(10).Enabled = False
            MainScreen.MnuWardStock(12).Enabled = True
            MainScreen.MnuWSOBlockDel.Enabled = False
            MainScreen.MnuWSOSort.Enabled = False
            MainScreen.MnuWSOCopy.Enabled = False
            MainScreen.MnuWSOCut.Enabled = False     '16Apr02 TH Added
            MainScreen.MnuWSOBlkInsert.Enabled = False
            MainScreen.MnuWSOChange.Enabled = False
            MainScreen.MnuWSOSaveAs.Enabled = False
            MainScreen.MnuWSODelete.Enabled = False
            '-----------------------------------------------
            'SQL TH Added
            MainScreen.MnuReq.Enabled = True
            MainScreen.MnuRepReqs.Enabled = True '05Mar98 ASC/EAC
            MainScreen.MnuReqEnter.Enabled = True
            MainScreen.MnuToFollows.Enabled = True      '06Apr00 CFY Added
            MainScreen.MnuReqPrintPick.Enabled = True
            MainScreen.MnuReqIssue.Enabled = True
            MainScreen.MnuReqDelivery.Enabled = True
            MainScreen.MnuReqReturn.Enabled = True
            '--------------
        Case 6  'Reserved
        Case 7  'Reserved
        Case 8  'Reserved
        Case 9  'Reserved
        Case Else
            popmessagecr "Error", "Access level for Ward Stock module is not in the defined range."
            storesEnd
    End Select
    
    If Not TrueFalse(TxtD(dispdata$ & "\PSO.ini", "PSO", "N", "AllowPSO", 0)) Then '14Nov12 TH PSO Switch (TFS 41433)
      MainScreen.mnuPSOAuth.Enabled = False
      MainScreen.mnuPSOInv.Enabled = False
      MainScreen.mnuPSOAmend.Enabled = False
      MainScreen.mnuPSORec.Enabled = False
      MainScreen.mnuPSOOrderEditors.Enabled = False
    End If
    
    '23Apr14 TH Added eHUB
    If Not TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "N", "AllowHubPOD", 0)) Then
      MainScreen.mnuPSOHubRec.Enabled = False
    End If
    
    If Not TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "N", "AllowHubInvoicing", 0)) Then
      MainScreen.mnuPSOHubInv.Enabled = False
      MainScreen.mnuPSOHubInvSettings.Enabled = False
    End If
    
    '23Aug13 TH Added (TFS 71582)
    If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "ContractUpdate", "Y", "UseNewContractEditor", 0)) Then
       MainScreen.MnuUtilContPrice.Visible = False
    End If
    
    SetRobotLoadingMenuOption True               '07Jan10 CKJ Enabled only if interface is present and user can receive goods

End Sub

Sub SetPrintCodingMode()
'12Feb01 JKU Added

'This sub sets the Print Coding Slip option in the Finance Menu

   If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "defaults", "N", "SuppressCodingSlip", 0)) Then
      'If the setting exists and set to 1, turn off option
      MainScreen.MnuFinSlips.Enabled = False
      MainScreen.MnuFinSlips.Visible = False
   End If

End Sub

Sub ShelfStockList()

'06Dec16 TH  Replaced RTF Handling (TFS 157969)
'05Jan17 TH  Refactored RTF handling (TFS 157969)

Const cCaption = "Shelf Stocking List"

Dim udtDrug As DrugParameters
Dim udtOrder As orderstruct
Dim strLines() As String, strCurrentLine() As String
Dim strText As String, strAns As String, strDateFrom As String, strReceiptDate As String, strError As String
Dim strRTFTxt As String, strPgHdr As String, strPgItem As String, strPgEnd As String, strTmpFile As String, strDetailLine As String
Dim lngNumberOfOrders As Long, lngCount As Long
Dim intCount As Integer, intValid As Integer, intLines  As Integer, intChan As Integer, intDone As Integer
Dim rsReconcil    As ADODB.Recordset
Dim strParams As String
Dim intSuccess As Integer '05Jan17 TH Added


   ''On Error GoTo ss_ErrorHandler

   ' load template file and split into the relevant sections
   GetRTFTextFromDB dispdata$ & "\sstklst.rtf", strRTFTxt, intSuccess '05Jan17 TH Moved from below to utilise check (Hosted)
   'If fileexists(dispdata$ & "\SSTKLST.RTF") Then
   If intSuccess Then
      'GetTextFile dispdata$ & "\sstklst.rtf", strRTFTxt, 0
      'GetRTFTextFromDB dispdata$ & "\sstklst.rtf", strRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)
   
      SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
   Else
      'popmessagecr "#" & cCaption, "File: " & dispdata$ & "\SSTKLST.RTF does not exist" & cr & "Cannot print the report"
      popmessagecr "#" & cCaption, "RTF: SSTKLST.RTF does not exist in database" & cr & "Cannot print the report"
      Exit Sub
   End If

   ' get the date to run from off the user
   intDone = False
   strText = "Enter a valid date for the report to run from"
   strAns = Format$(Now, "dd/mm/yyyy")
   Do
      InputWin cCaption, strText, strAns, k
      parsedate strAns, strDateFrom, "dd/mm/yyyy", intValid
      If Not k.escd Then
         If intValid Then
            If strAns = strDateFrom Then intDone = True
            strAns = strDateFrom
         Else
            strAns = ""
            BadDate
         End If
      End If
   Loop Until k.escd Or intDone
    
   If (Not k.escd) Then
            
      ' put date entered into format for comparisons later
      parsedate strDateFrom, strDateFrom, "yyyymmdd", intValid
      
      ' Scan through all orders
      Screen.MousePointer = HOURGLASS
      ReDim strCurrentLine(2)
      ReDim strLines(200)
      intLines = 0
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "4") & _
                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                  gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 1, 0) & _
                  gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 1, 0)
                  
      Set rsReconcil = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilByCriteria", strParams)
      If Not rsReconcil.EOF Then
         rsReconcil.MoveFirst
         Do While Not rsReconcil.EOF
            udtOrder = FillOrdFromRS(rsReconcil, "WReconcil")

            ' if a receipt and in date ranges then store the record
            strReceiptDate = Right$(udtOrder.recdate, 4) & Mid$(udtOrder.recdate, 3, 2) & Left$(udtOrder.recdate, 2)

            'If (udtOrder.status = "4") And (udtOrder.ShelfPrinted <> "Y") And (strReceiptDate >= strDateFrom) Then
            If (udtOrder.status = "4") And (udtOrder.ShelfPrinted <> "Y") And (strReceiptDate >= strDateFrom) And (udtOrder.PSORequestID < 1) Then  '25Feb13 TH Exclude PSO orders (TFS 57349)
               intLines = intLines + 1
               If intLines > 200 Then ReDim Preserve strLines(intLines)
               ' build up information and add to the array
               BlankWProduct udtDrug
               udtDrug.SisCode = udtOrder.Code
               getdrug udtDrug, 0, 0, False
               strText = Format$(GetField(rsReconcil!WReconcilID)) & "," & Trim$(udtDrug.loccode)
               strText = strText & "," & udtOrder.supcode      '
               strLines(intLines) = strText
            End If
            
            rsReconcil.MoveNext
         Loop
      End If
      rsReconcil.Close
      Set rsReconcil = Nothing

      ' decide if any items to print
      If intLines > 0 Then
         ' sort by location code
         shellsort strLines(), intLines, 2, ","
         
         If TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "", "N", "ShelfStockListBySupplier", 0)) Then
            shellsort strLines(), intLines, 3, ","
         End If
            
         ' build up report in a temporary file
         MakeLocalFile strTmpFile
         intChan = FreeFile
         Open strTmpFile For Binary Access Write Lock Read Write As intChan
         
         ' write the header
         FillHeapStandardInfo gPRNheapID
         ParseItems gPRNheapID, strPgHdr, 0
         Put intChan, , strPgHdr
             
         ' write the details
         For intCount = 1 To intLines
            deflines strLines(intCount), strCurrentLine(), ",", 1, 0

            ' get order information
            getorder udtOrder, CLng(strCurrentLine(1)), 4, False
            FillHeapOrdInfo gPRNheapID, udtOrder, 0

            ' get product information
            BlankWProduct udtDrug
            udtDrug.SisCode = udtOrder.Code
            getdrug udtDrug, 0, 0, False
            FillHeapDrugInfo gPRNheapID, udtDrug, 0

            ' write current line
            strDetailLine = strPgItem
            ParseItems gPRNheapID, strDetailLine, 0
            Put intChan, , strDetailLine
         Next

         ' write the footer
         Put intChan, , strPgEnd
         Close intChan
         
          
         ' print the report
         Do
            'ParseThenPrint "ShelfStockList", strTmpFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
            ParseThenPrint "ShelfStockList", strTmpFile, 1, 0, False, True '04Jan17 TH Use local file
            askwin cCaption, "Has the report printed?", strAns, k
         Loop Until (strAns = "Y") Or (k.escd)
         Kill strTmpFile

                  
         ' mark records so they won't be printed again
         If (Not k.escd) Then
            For intCount = 1 To intLines
               lngCount = CLng(Left$(strLines(intCount), InStr(strLines(intCount), ",")))
               getorder udtOrder, lngCount, 4, True
               udtOrder.ShelfPrinted = "Y"
               lngCount = PutOrder(udtOrder, lngCount, "WReconcil")
            Next
         End If
                    
      Else
         ' no records to print
         Screen.MousePointer = STDCURSOR
         popmessagecr "#" & cCaption, "No items in given criteria to print"
      End If
   End If


ss_CleanUp:
    Screen.MousePointer = STDCURSOR
    On Error GoTo 0
    Exit Sub

ss_ErrorHandler:
    
    Screen.MousePointer = STDCURSOR
    strError = Error$
    popmessagecr cCaption, "Error: " & strError
    Resume ss_CleanUp

End Sub

Function TheCost(d As DrugParameters, ByVal Edittype) As Single
'30Mar00 CFY Added

   If Val(d.contprice) > 0 Then
      TheCost! = Val(d.contprice)
   Else
      If (Edittype = 3 And Val(d.sislistprice) > 0) Or (Edittype = 1 And d.sisstock = "N" > 0) Then '22Feb99 TH Replaced
         TheCost! = Val(d.sislistprice)
      Else
         TheCost! = Val(d.cost)                      '!!** not true except edittype 1
      End If
   End If
   
End Function

Sub ToFollowsPrint(i_intSortOrder As Integer)
'06Apr00 CFY Written
'Description: Produces an RTF report of all items currently To_follow. The report can be generated with the following
'             sort orders:
'
'              1     By Supplier code
'              2     By Product description
'
'15Jan02 CKJ Corrected two errors. Loop missed last item in index, and
'            included all items with the to follow flag set regardless of order status.
'15Jul02 TH Changed index used -  now search on picktickno idex rather than reqnum as reqnum idx entry may be missing  (#59661)
'28May04 TH Added Locking through acquire lock on prntpck5 to prevent possible deadlock (Glasgow)
'06Dec16 TH Replaced RTF Handling (TFS 157969)
'04Jan17 TH Use Local file parsing for RTF handling (TFS 157969)
'05Jan17 TH Refactored RTF Handling (TFS 157969)
'18Jan17 TH Added message to make it explicit to the user when nothing to print (avoid confusion) (TFS 173942)

Const cMaxLines = 300

Dim X&, cont&, found&, recnum&
Dim success As Integer
Dim iTmpFileNo  As Integer, iRecCount As Integer, iSortKeyLen As Integer, iFoundSup As Integer   '01Jun02 ALL/ATW  iDrugFound As Integer,
Dim sMsg As String, sErrMsg As String, sSortString As String, sTmpFile As String, strRTFTxt As String, strRTFLayout As String
Dim strPgHdr As String, strPgItem As String, strPgEnd As String, sDetailLine As String, strContext As String
Dim ord As orderstruct
Dim DrugPtr As Long
Dim blnlocked As Integer, strFilelock As String  '28May04 TH Added
Dim lngFoundSup As Long
Dim strParams As String
Dim rsToFollows As ADODB.Recordset
Dim intSuccess As Integer '05Jan17 TH Added

   Screen.MousePointer = HOURGLASS
   
   'Check rtf layout exists, if so read into memory and split into components
   strRTFLayout = "\ToFollow.rtf"
   strContext = "ToFollow"
   
   GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, intSuccess '05Jan17 TH Moved from below to utilise check (Hosted)
   'If fileexists(dispdata$ & strRTFLayout) Then
   If intSuccess Then
      'GetTextFile dispdata$ & strRTFLayout, strRTFTxt, 0
      GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)

      SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
   Else
      'popmessagecr "!", "Could not print report. File " & dispdata$ & strRTFLayout & " not found"
      popmessagecr "!", "Could not print report. RTF " & strRTFLayout & " not found in database"
      Exit Sub                   '<== WAY OUT!!
   End If
   
      
   'Just in case we don't have enough memory banks left in the computron.
   'Reserve a moderate amount of space to start of with so that we don't have to redim preserve for every record
   'we find.
   On Error GoTo ToFollows_Err
   ReDim LinesForPrint(cMaxLines) As String
   On Error GoTo 0

   strFilelock = dispdata$ + "\PRNTPCK5.LCK"    '28May04 TH Added to ensure this falls into the same locking regime as printing PTs
   AcquireLock strFilelock, -2, blnlocked       ' exclusive, keep trying         '    "
   
   If blnlocked Then
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      Set rsToFollows = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisForToFollowsReport", strParams)
      If rsToFollows.RecordCount > 0 Then
         rsToFollows.MoveFirst
         Do While Not rsToFollows.EOF                                                   '   "
            iRecCount = iRecCount + 1
      
            ' Memory check again. If we didn't reserve enough space to start then allocate a little more...
            On Error GoTo ToFollows_Err
            If iRecCount > cMaxLines Then ReDim Preserve LinesForPrint(iRecCount)
            
            LinesForPrint(iRecCount) = Format$(GetField(rsToFollows!WRequisID))
            
            'Prepend line with sort information
            Select Case i_intSortOrder
               Case 1   'SupplierCode
                  sSortString = Left(GetField(rsToFollows!supcode) & Space$(5), 5)
                  iSortKeyLen = 5 ''Len(sSortString)
               Case 2   'Product Description
                  iSortKeyLen = 56 ''Len(GetField(rsToFollows!Description))
                  If Not IsNull(rsToFollows!Description) Then
                     sSortString = Left$(GetField(rsToFollows!Description) & Space$(56), 56)
                  Else
                     sMsg = RtrimGetField(rsToFollows!Code) & " Could not be found in product file"
                  End If
            End Select
                  
            LinesForPrint(iRecCount) = pad(trimz(sSortString), iSortKeyLen) & LinesForPrint(iRecCount)

            'Build error message if necessary
            If Trim$(sMsg) <> "" Then
               sErrMsg = sErrMsg & sMsg & crlf
               sMsg = ""
            End If
            rsToFollows.MoveNext
         Loop
      End If
      rsToFollows.Close
      Set rsToFollows = Nothing
   End If
   
   AcquireLock strFilelock, 0, 0 '28May04 TH Release lock after using index

            
   If iRecCount > 0 Then
      'Sort Lines to be printed
      shellsort LinesForPrint(), iRecCount, 1, ""
      
      'Print it .....
      MakeLocalFile sTmpFile                                                  'Tmp file used to
      iTmpFileNo = FreeFile                                                   'build report
      Open sTmpFile For Binary Access Write Lock Read Write As iTmpFileNo
      
      'Header Info
      ParseItems gPRNheapID, strPgHdr, 0
      Put iTmpFileNo, , strPgHdr
      
      'Main detail line
      For X& = 1 To iRecCount
         
         recnum& = Val(Mid$(LinesForPrint(X&), iSortKeyLen + 1))
         getorder ord, recnum&, 5, False
      
         FillHeapOrdInfo gPRNheapID, ord, success
         getsupplier ord.supcode, 0, lngFoundSup, sup
         FillHeapSupplierInfo gPRNheapID, sup, success
         d.SisCode = ord.Code
         getdrug d, 0, DrugPtr, False  '01Jun02 ALL/ATW
         FillHeapDrugInfo gPRNheapID, d, success
      
         sDetailLine = strPgItem
         ParseItems gPRNheapID, sDetailLine, 0
         Put iTmpFileNo, , sDetailLine
      Next
      
      'Footer
      Heap 10, gPRNheapID, "TotalItems", Format$(iRecCount), 0
      ParseItems gPRNheapID, strPgEnd, 0
      
      Put iTmpFileNo, , strPgEnd
      
      'Print and cleanup
      Close iTmpFileNo
      'ParseThenPrint strContext, sTmpFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
      ParseThenPrint strContext, sTmpFile, 1, 0, False, True '04Jan17 TH Use Local file parsing
      On Error Resume Next
      Kill sTmpFile
      On Error GoTo 0
   Else '18Jan17 TH Added message to make it explicit to the user (avoid confusion) (TFS 173942)
      popmessagecr "To Follows Print", "There are no to follows to print"
   End If

ToFollowsPrint_Exit:
   Screen.MousePointer = STDCURSOR
   Exit Sub

ToFollows_Err:
   sMsg = "An error has occured in routine: StoreASC: OrdersPrint" & crlf
   sMsg = sMsg & Format$(Err) & ": " & Trim$(Error$) & crlf & crlf
   sMsg = sMsg & "Please contact your System Supervisor"
   popmessagecr ".", sMsg
   Resume ToFollowsPrint_Exit


End Sub
Function GetTableName(Edittype As Integer) As String
'v93 Written
'01Jun11 CKJ Added as integer to param

Dim strReturn As String
   Select Case Abs(Edittype)
      Case 1, 2, 3, 9
         strReturn = "WOrder"
      Case 4
         strReturn = "WReconcil"
      Case Else
         strReturn = "WRequis"
   End Select
   
   GetTableName = strReturn
   
End Function
Sub Scanorders(ByRef d As DrugParameters, ByVal Edittype As Integer, ByRef ordernum$, ByVal sitepaths%, ByRef partorder As Integer, ByVal notyetordered%, ByVal foundorder&, ByVal SelectedOrder As Long, ByVal blnFromlstView As Boolean)
'22Jul10 TH  Added code to set printable elements for interfacing (UHB)(F0077942)
'06Sep10 TH  When the user selects a specific order from the display we may need to get a delivery note number. Call to capture this if required for UMMC (FINV) (F0054531)
'27Jun11 CKJ Removed param linnum
'28Jun12 TH  Added DLO Information to Caption
'16Jul12 TH  Replaced msg on DLO question (TFS 38662)
'14Apr14 TH  Changed nature of fencepost to stop invalid issues being processed incorrectly, moved wslist update to within issued fencepost (TFS 88873)
'09May14 TH  Reverted above mod but retained bar on Wslist update if no issue - although the above change seemed sensible, it then excluded zero issues (to force to follows) (TFS 90576)

Dim wrongorder As Boolean
Dim lines$()
Dim Numoflines As Integer
Dim curpointer&
'Dim foundorder&
Dim foundthisorder As Boolean
Dim thisorder As Boolean
Dim cont&
Dim SavedPointer&
Dim loopvar As Integer
Dim Process$
Dim transmitted As Boolean
Dim copyentercostonrec$
Dim QtyReceived$
''Dim auto As Boolean
Dim auto As Integer
Dim ordsupcode$
''Dim Find%, foundsup%
Dim Qty!, totalqty!
Dim Action As Integer, issued As Integer
Dim issuecost$, BatchNum$, expdate$
Dim duplicates As Integer, NumLabels As Integer, issuedone As Integer
Dim lngFoundSup As Long
Dim strTemp As String
Dim msg$
Dim strAns As String
Dim lngBatchWReconcilID As Long '26Oct06 TH Added
Dim strDLOWard As String '28Jun12 TH DLO
Dim strDesc As String '16Jul12 TH (TFS 38662)
Dim blnPSO As Boolean '21Aug12 TH Added PSO

'05Jun08 TH Added param to select only the ordernumber from the receipt screen
   '23Aug05 TH Added chunk - seems to have been missing after port. Hope it wasnt on purpose!
   'No these checks need to be done outside and will represent seperate hits on the DB
   '!!!!!! Still TO DO !!!
   If (ord.status = "1" And Edittype = 1) Or (ord.status = "5" And Edittype = 5) Or (ord.status = "F" And Edittype = 10) Then  '26Nov98 TH for free ordering
      If ord.status = "1" And Edittype = 1 Then
         'toptext$ = "WARNING"
         'message$ = "Ordered (Order not yet raised)"
         'messag1$ = ""
         popmessagecr "!WARNING", "Ordered (Order not yet raised)"
         notyetordered = True
      End If
      If ((ord.status = "1" And Edittype = 1) Or (ord.status = "F" And Edittype = 10)) And Trim$(ord.supcode) <> Trim$(osite$) And osite$ <> "A" Then   '10Jan02 TH Replaced above. Even if the item is for a different supplier
        '' printwarning = False                                                                                                                        '    "      this wont necessarily mean there isnt an order further in the
      Else                                                                                                                                           '    "      file. Therefore KEEP SEARCHING instead of leaving straight away
         ordered& = foundorder&                                                                                                                      '    "      as previous. (#48164)
      End If
      ''blnprintwarning2 = True
   End If
            
   If ord.status = "2" And Edittype = 1 Then
      'toptext$ = "WARNING"
      'message$ = "Ordered (Transmission not yet confirmed)"
      'messag1$ = "for " + RTrim$(ord.outstanding) + " x " + d.convfact + " " + d.PrintformV + " on " + Left$(ord.orddate, 2) + "/" + Mid$(ord.orddate, 3, 2) + "/" + Mid$(ord.orddate, 5) + " Ord.No. " + ord.num  '07Apr99 AE corrected date parsing
      ''printwarning = True
      popmessagecr "!WARNING", "Ordered (Transmission not yet confirmed)" & crlf & "for " + RTrim$(ord.outstanding) + " x " + d.convfact + " " + d.PrintformV + " on " + Left$(ord.orddate, 2) + "/" + Mid$(ord.orddate, 3, 2) + "/" + Mid$(ord.orddate, 5) + " Ord.No. " + ord.num
   End If
    
   If ord.status = "3" And Edittype = 1 Then
      'optext$ = "WARNING"
      'message$ = "Order raised goods not yet received"
      'messag1$ = "for " + RTrim$(ord.outstanding) + " x " + d.convfact + " " + d.PrintformV + " on " + Left$(ord.orddate, 2) + "/" + Mid$(ord.orddate, 3, 2) + "/" + Mid$(ord.orddate, 5) + " Ord.No. " + ord.num   '07Apr99 AE corrected date parsing
      ''printwarning = True
      popmessagecr "!WARNING", "Order raised goods not yet received" & crlf & "for " + RTrim$(ord.outstanding) + " x " + d.convfact + " " + d.PrintformV + " on " + Left$(ord.orddate, 2) + "/" + Mid$(ord.orddate, 3, 2) + "/" + Mid$(ord.orddate, 5) + " Ord.No. " + ord.num

   End If
   '-------------------------

   If ord.status = "6" And Edittype = 6 Then
      If d.inuse <> "N" And Trim$(ordernum$) <> "A" And ord.pickno = Val(ordernum$) Then
         '22Jun12 TH Check if DLO and allow abort (by default)
         If ord.DLO Then
            strAns = "N"
            strDesc = d.DrugDescription ' strDesc = GetStoresDescription() XN 4Jun15 98073 New local stores description
            plingparse strDesc, "!"
            'askwin "?Ascribe", "This is a DLO item. If you Issue this item it will not automatically Issued on receipt. Do you wish to continue", strAns, k
            askwin "?EMIS Health", Trim$(strDesc) & " is a DLO item" & crlf & crlf & "If you issue it here it will not be automatically issued upon receipt" & crlf & crlf & "Do you wish to continue ?", strAns, k  '16Jul12 TH Replaced (TFS 38662)
            If strAns = "N" Then
               k.escd = True
            End If
         End If
         If Not k.escd Then
            ordsupcode$ = ord.supcode
            getsupplier ordsupcode$, 0, lngFoundSup, sup
            If Trim$(sup.suppliertype) = "" Then
               popmessagecr "ABORTING", "Aborting Issue." + Chr$(13) + "No supplier type defined for supplier " + sup.Code + ", " + sup.name + Chr$(13) + "Please ask your system administrator to define the supplier type for this supplier."
               k.escd = True
            End If
            If Not k.escd Then
               'If Not (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") Then
               PutCustOrdNo ord.custordno               '18Apr00 CFY Added
               PutPickNo Format$(ord.pickno)           '16May04 TH Added (enh1549)
               PutWardListID ord.WWardProductListLineID    '30Dec14 TH Added for ward stock reporting
               If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks Then   '30Dec97 EAC added PrintinPacks
                  Qty! = CLng(1! * Val(ord.received) * Val(d.convfact))                '26Jun98 EAC handle rounding errors - added CLng
                  totalqty! = CLng(1! * Val(ord.outstanding) * Val(d.convfact))        '26Jun98 EAC handle rounding errors - added CLng
                  Action = GetPrintStockLabelsByDefault()
                  If sup.suppliertype = "S" And sup.Method = "I" Then Heap 10, gPRNheapID, "InternalOrderNumber", Format$(ord.num), 0  '22Jul10 TH Added (UHB)(F0077942)
                  Issue k, Qty!, Abs(totalqty!), d, UserID$, "", ordsupcode$, issued, "P", ord.supcode, ord.num, sitepaths, "P", issuecost$, BatchNum$, expdate$, duplicates, NumLabels%, Action
                  Heap 10, gPRNheapID, "InternalOrderNumber", "", 0 '22Jul10 TH Added (UHB)(F0077942)
               Else
                  Qty! = 1! * Val(ord.received)
                  totalqty! = 1! * Val(ord.outstanding)
                  Action = GetPrintStockLabelsByDefault()
                  Issue k, Qty!, Abs(totalqty!), d, UserID$, "", ordsupcode$, issued, "S", ord.supcode, ord.num, sitepaths, "P", issuecost$, BatchNum$, expdate$, duplicates, NumLabels%, Action
               End If
               PutPickNo ""           '16May04 TH Added (enh1549)
               PutWardListID 0    '30Dec14 TH Cleared
               '10Jul11 TH Added to record wslist details if required (F0065354)
               'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "REQ", CInt(Qty) '27Jun11 TH Added
               'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "REQ", CLng(Qty) '11Apr14 TH Coerce to long (TFS 88720)
               
               If Action = 7 Or Action = 8 Then PrintStockLabelsSQL Qty!, d.SisCode, ord.supcode, NumLabels, duplicates
            End If
         
            'If issued Or Not k.escd Then '3Jun93 CKJ why 'not k.escd'?
            'If issued And (Not k.escd) Then '14Apr14 TH Changed nature of fencepost to stop invalid issues being processed incorrectly (TFS 88873)
            If issued Or Not k.escd Then '09May14 TH Reverted - although the above change seemed sensible, it then excluded zero issues (to force to follows) (TFS 90576)
               issuepick issuecost$, sitepaths, d, Qty!, totalqty!, foundorder&
               'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "REQ", CLng(Qty)  '14Apr14 TH Moved from above
               If issued Then UpdateWardStockListIssueData d.SisCode, sup.wardcode, "REQ", CLng(Qty), ord.WWardProductListLineID '18Dec14 TH Now send the line ID (if present) so we can update the stock list correctly  '09May14 TH Only update WStock if issued
               issuedone = True
            End If
            '!!** should UNLOCK
         End If
      Else
         If d.inuse = "N" Then popmessagecr "NOT IN USE", "Issue attempted"
      End If
   End If
   If ord.status = "3" And Edittype = 3 Then
      ReDim lines$(OTblMaxCols + 1)
      foundanorder = True
      If Val(ord.num) = Val(ordernum$) Or Trim$(ordernum$) = "A" Then            '//// CHECK !
         wrongorder = False                                                                          '   "       This is an extra check to ensure the correct record is
         If ONumToDisplay > 0 Then                                                                   '   "       being processed because it is possible to have two or more orderlines
            deflines OInfoStore(MainScreen.lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, Numoflines  '   "       for the same item on the same order for the same supplier, and
            curpointer& = Val(lines$(OTblMaxCols + 1))                                            '   "       in these cases the line highlighted on the screen may not be the
'10Nov06 TH Removed should be covered by earlier check - this was stopping receipt of items launched from text input rather than driven by the lstbox (as per barcode receipt for eg)
''            If curpointer <> foundorder& Then
''               wrongorder = True                                                                   '   "       one now being processed at this point.
''            End If
            '05Jun08 TH Added block
            If blnFromlstView And SelectedOrder = 0 Then
               If curpointer <> foundorder& Then
                  wrongorder = True                                                                   '   "       one now being processed at this point.
               End If
            
            Else
               If (SelectedOrder > 0) And (ord.num <> SelectedOrder) Then
                  
                     wrongorder = True
               Else
                  If getPSO() And ord.PSORequestID = 0 Then '11Dec12 TH Added PSO check (TFS 52518)
                     wrongorder = True
                  Else
                     wrongorder = False
                  End If
               End If
            End If
            '--------------
         End If                                                                                   '   "
         If (Not foundthisorder) And (Not wrongorder) Then   '   "
            foundthisorder = True
            thisorder = True '1st time found this item on this order
            cont& = 0
            If Trim$(ordernum$) = "A" Then
               ordernum$ = ord.num
               If Trim$(ord.supcode) <> "" Then getsupplier ord.supcode, 0, 0, sup
               'msg$ = "Change order to be received to  " & Trim$(ordernum$) & " from Supplier " & sup.Code & " (" & Trim$(sup.name) & ")  Press [Return] to continue..."
               msg$ = "Press [Return] or click on OK button to receive Order " & Trim$(ordernum$) & " from Supplier " & sup.Code & " (" & Trim$(sup.name) & ")" '12Aug05 TH altered (#81986)
               'popmessagecr "!n!b", "Order number now set to " + ordernum$ + "  Press [Return] to continue..."
               'popmessagecr "!n!b", msg$  '14Jul05 TH Updated (#81578)
               blnPSO = getPSO() '28Nov12 TH moved here from below so as to caption the msg differently (TFS 51060)
               'popmsg "Receive Goods", msg$, 33, strAns, 0
               popmsg "Receive" & IIf(blnPSO, " Patient Specific", "") & " Goods", msg$, 33, strAns, 0 '28Nov12 TH Added for PSO(TFS 51060)
               If strAns <> "Y" Or k.escd Then
                  ordernum$ = "A"
                  'Clearprintedorders
                  'printorder 0
                  Exit Sub
               Else
                  '06Sep10 TH Here we are going for a specific order, so we may need to get a delivery note number (F0054531)
                  EnterDeliveryReference ordernum$
                  If k.escd Then             '28Sep10 TH Added
                     ordernum$ = "A"         '    "
                     Exit Sub                '    "
                  End If                     '    "
               End If
               deflines OInfoStore(MainScreen.lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, Numoflines
               SavedPointer& = Val(lines$(OTblMaxCols + 1))
               Clearprintedorders
               'ChangeTable "blank", False  '14Aug12 TH Added Param           '11Oct05 TH rather expensive fudge to get table resized if necessary
               'blnPSO = getPSO()  '28Nov12 TH Moved up (TFS 51060) (TFS 51427)
               ChangeTable "blank", getPSO()
               setPSO blnPSO
               ChangeTable "Receive Goods" & Iff(blnPSO, "PSO", ""), blnPSO '14Aug12 TH Added Param   '    "
               Printorder 0, blnPSO '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
               If Trim$(ord.supcode) <> "" Then
                  getsupplier ord.supcode, 0, 0, sup
                  'MainScreen.LblGrid.Caption = "Receive Goods for Order " & ordernum$ & " from Supplier " & sup.Code & " (" & Trim$(sup.name) & ")"
                  MainScreen.LblGrid.Caption = "Receive" & IIf(blnPSO, " Patient Specific", "") & " Goods for Order " & ordernum$ & " from Supplier " & sup.Code & " (" & Trim$(sup.name) & ")" '28Nov12 TH PSO (TFS 51060)
               Else
                  'MainScreen.LblGrid.Caption = "Receive Goods for Order " & ordernum$
                  MainScreen.LblGrid.Caption = "Receive" & IIf(blnPSO, " Patient Specific", "") & " Goods for Order " & ordernum$ '28Nov12 TH PSO (TFS 51060)
               End If
               '28Jun12 TH Need to Add DLO Stuff to Caption here
               strDLOWard = Trim$(GetOrderDLOWard(Val(ordernum$))) '28Jun12 TH (TFS) Replace above
               If strDLOWard <> "" Then
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & crlf & "Direct Location Order for " & strDLOWard
                  PositionLblGrid
               End If
               
               '16Aug11 TH Added
               If Trim$(getDeliveryNoteReference()) <> "" And Trim$(ordernum$) <> "A" Then
                  MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & crlf & "Delivery ref : " & Trim$(getDeliveryNoteReference())
                  PositionLblGrid
               End If
               If ONumToDisplay > 0 Then
                  For loopvar = 1 To ONumToDisplay
                     deflines OInfoStore(loopvar), lines$(), "|(*)", 1, Numoflines
                     curpointer& = Val(lines$(OTblMaxCols + 1))
                     If curpointer& = SavedPointer& Then
                        ''MainScreen.lvwMainScreen.SelectedItem.Index = loopvar
                        MainScreen.lvwMainScreen.ListItems(loopvar).Selected = True
                        getorder ord, curpointer&, Edittype, False
                        d.SisCode = ord.Code
                        getdrug d, 0, 0, False ' found%, False  '01Jun02 ALL/ATW
                        'Update panels
                        MainScreen.TxtInput.text = ord.Code
                        UpdatePanels ord, Abs(Edittype)
                        Exit For
                     End If
                  Next
               End If
            End If
         Else
            thisorder = 2  'found this order on the second pass
         End If
      ElseIf foundthisorder Then
         Process$ = "N"
         Confirm "!n!bFound on another order number", "receive this item from order " + ord.num, Process$, k
         If Process$ <> "N" And Not k.escd Then
            thisorder = True
            ordernum$ = ord.num
         Else
            thisorder = False
         End If
      End If

      transmitted = True
      Select Case ord.internalmethod
         Case "I", "M"
            If Val(ord.received) = 0 And Not Val(ord.outstanding) > 0 Then transmitted = False  '   "       of internal order
      End Select

      If foundthisorder And thisorder = True Then
         If transmitted Or Storepasslvl >= 9 Then
            copyentercostonrec$ = entercostonreceipt$
            If Not transmitted Then
               popmessagecr "!n!iStore has not transmitted cost", "Please check that the store has issued this item"
               entercostonreceipt$ = "Y"                        ' force price entry
            End If
            If Not k.escd Then
               '#78548 Put a check in here for stock levels ?
               If UCase$(d.livestockctrl) = "Y" And Val(d.stocklvl) < 0 Then
                  '''Beep
                  '''Beep
                  strTemp = d.DrugDescription   ' strTemp = GetStoresDescription() XN 4Jun15 98073 New local stores description
                  plingparse strTemp, "!"
                  popmessagecr "!n!iCannot receive stock", "Stock level negative for " & Trim$(strTemp) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                  k.escd = True
               End If
               If Not k.escd Then EnterActualReceive QtyReceived$, d, ord, lngBatchWReconcilID
            End If
            If Not k.escd Then
               If Val(QtyReceived$) < Val(ord.outstanding) Then
                  partorder = True
               Else
                  partorder = False
               End If
               auto = False
               
               receiveitem sitepaths, ord, QtyReceived$, foundorder&, auto, lngBatchWReconcilID
               If auto = 4 Then
                  partorder = True
               End If
               
            End If
            entercostonreceipt$ = copyentercostonrec$

         Else
            If Not transmitted And Edittype = 3 Then
               popmessagecr "!n!bPlease try later", "Waiting for store to issue and transmit costs for order " + ord.num
               If Storepasslvl < 9 Then 'was 8
                  k.escd = True
               End If
            End If
         End If
      End If
      If thisorder = 2 Then thisorder = True
   End If
End Sub
Public Function getSupFromOrderNum(ByVal strOrderNum As String, ByVal strTable As String) As supplierstruct
Dim strParams As String
Dim rsSupplier As ADODB.Recordset
Dim lclSupplier As supplierstruct

   clearsup lclSupplier
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(strOrderNum))
   Set rsSupplier = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierby" & strTable & "Number", strParams)
   If rsSupplier.RecordCount > 0 Then
      lclSupplier = FillSupFromRS(rsSupplier)
   End If
   rsSupplier.Close
   Set rsSupplier = Nothing
   getSupFromOrderNum = lclSupplier
   

End Function
Private Function IsAlternativeSupplier(ByVal strNSVCode As String, ByVal strSupCode As String) As Boolean
Dim strParams As String
Dim intReturn As Integer

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strSupCode)
   intReturn = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWSupplierProfileForIsAlternativeSupplier", strParams)
   If intReturn > 0 Then
      IsAlternativeSupplier = True
   Else
      IsAlternativeSupplier = False
   End If

End Function

Sub StoresMain()

'06Jan98 EAC Read Edi settings on low level passwords
'05Mar98 ASC Call to new procedure TidyUpReprints added
'09Apr98 CFY Requisitions now only lists wards and not lists as it used to
'17Apr98 CFY Added condition to switch off the tidyupreprints procedure
'            using the command line switch 'skiptidy'
'21Jan99 EAC Stock label printing
'30Jun99 CFY Code added to open the Supplier profile database
'09Nov99 AE  Initialise toolbar context to zero (default)
'14Jun00 AW  GST changes
'12Feb01 JKU Added disable Print Coding Slip option
'01oct03 CKJ added brackets on ASCver()
'16May04 TH  Added mod to read passed passlvl from dispensary to check if price should be suppressed (UMMC price hide)
'29Aug08 TH  Debug back door to miss new security
'19Mar09 TH  Added sitenumber to heap for UHB Interfacing (F0032689)
'08Jun10 XN  Sets colour of tool bar from config setting, and set the site number in the title bar (F0085853)
'22Jul10 TH  Added initialisation of InternalOrderNumber element for interfacing (UHB)(F0077942)
'07Sep10 TH  initialise linenumber onto the heap for UMMC (FINV) (F0054531)
'04Jan12 TH  Allow for mismatches with URLS (certain web sites) since a URL is now passed on the command line (thanks whoever did that !!!) TFS22012

Dim StockExt$, StockList$
Dim SaveTitle As String
Dim found%, valid%
Dim tmp$
Dim strParams As String
Dim Commanda$
Dim rs As ADODB.Recordset
Dim phase As Single
Dim UnencryptedData As String       '15Aug12 CKJ Replacement for ConnectionString      (TFS36929)
Dim blnUseWebConn As Boolean        '   "        Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String    '   "        Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String   '   "        Added to store the unencrypted token

   MainScreen.Caption = "Stock Control"
   
   'If InStr(1, Command$, "/de", 1) = 0 And InStr(1, Command$, "/lv0", 1) = 0 Then MainScreen.Show 0  '24Aug05 TH Added to stop screen launch on site drug enquiry
   If InStr(1, Command$, "///de", 1) = 0 And InStr(1, Command$, "///lv0", 1) = 0 Then MainScreen.Show 0  '04Jan12 TH Altered to allow for mismatches with URLS since a URL is now passed ion the command line (thanks whoever did that !!!) TFS22012
   
   g_SessionID = Val(Mid$(Command$, (InStr(1, Command$, "/SID", vbBinaryCompare)) + 4))
   SiteNumber = Val(Left$(Command$, InStr(1, Command$, "/SID", vbBinaryCompare)))
      
'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
'g_SessionID = 28784 '665853003  '28784
'SiteNumber = 200 '426
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   If App.PrevInstance Then
      SaveTitle$ = App.title
      App.title = "...duplicate instance."
      MainScreen.Caption = "...duplicate instance."
      AppActivate SaveTitle$
      Sendkeys "% R", True
      storesEnd
   End If
      
   g_Command = Command$
   'Set g_adoCn = New ADODB.Connection '15Aug12 CKJ
   
   phase = 1
   'g_adoCn.ConnectionString = ParseCommandURLToken(g_SessionID, g_Command, phase, tmp, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
   UnencryptedData = ParseCommandURLToken(g_SessionID, g_Command, phase, tmp, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
   If blnUseWebConn Then
      Set gTransport = New PharmacyWebData.Transport
      gTransport.UnencryptedKey = UnencryptedData
      gTransport.URLToken = strUnencryptedToken
      gTransport.ProxyURL = strWebDataProxyURL
   Else
      If Len(tmp) Then
         MsgBox "Unable to connect to database" & cr & "Phase " & Format$(phase, "0.#") & "  " & tmp, vbCritical + vbOKOnly, "Stores Module"   '17Aug12 CKJ added  "0.#"
         Close
         storesEnd
      End If
      '~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
      'UnencryptedData = "provider=sqloledb;server=localhost;database=Regression_Testing;uid=icwsys;password=;"
      '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      g_adoConnectionString = UnencryptedData
      Set gTransport = New PharmacyData.Transport
      Set gTransport.Connection = New ADODB.Connection
      gTransport.Connection.open g_adoConnectionString
   End If
        
   If SiteNumber = 0 Then
      MsgBox "Application has been called with no site number." & _
      crlf & "Please check with your system superviser." & _
      crlf & crlf & "This application cannot continue"
      Close
      storesEnd
   End If
   
   ''SQL  acclevels$ = "9999989999" '"9999999999" '"9999989999"
   
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
   ReadSiteInfo
   
   '16Aug12 CKJ removed the call as already handled in readsiteinfo above
   'gTransport.ADOSetConnectionTimeOut (TxtD(dispdata$ & "\siteinfo.ini", "Connection", "5000", "ConnectionTimeout", found))
   
''   If Trim$(ASCTerminalName()) = "" Then
''      MsgBox "You terminal has not been correctly designated." & _
''      crlf & "Please check with your system superviser." & _
''      crlf & crlf & "This application cannot continue"
''      Close
''      End
''   End If
   MainScreen.Caption = "Stock Control - " & hospname1$ & " " & hospname2$ & " - " & CStr(SiteNumber)   '08Jun10 XN  Set site number in main title bar (F0085853)
   
   SetToolBarIniFile MainScreen, dispdata$ & "\winordtb.ini"   '05jan99 CKJ
   
   '09Nov99 AE  Added to ensure toolbarcontext is initialised
   SetToolBarcontext 0
   SetToolBarLinkCntrl Nothing
   SetSiteToolBarColour '08Jun10 XN  Sets colour of tool bar from config setting (F0085853)
   SetBackgroundImage MainScreen    '05Jul12 CKJ added
   
   Screen.MousePointer = HOURGLASS

   ReadOrdData
   loadvatrates
   ReadSites

   If SlaveModeEnabled() Then                              '29oct03 CKJ added block
      If InStr(1, Command$, "/de", 1) Then              'In F4 Drug Enquiry mode from PMR
         'do nothing here                            '
      ElseIf OCXlaunch() Then                        ' /OCX on command line
         LaunchfromOCX "O"                           ' so do it for module type "XO" [NB "XE" not supported]
         MainScreen.MnuProgram(2).Visible = False    'remove login
         MainScreen.MnuProgram(2).Enabled = False    '
         MainScreen.MnuProgram(3).Visible = False    'and separator
         MainScreen.MnuProgram(3).Enabled = False    '
      Else                                           '
         Screen.MousePointer = STDCURSOR             '
         tmp$ = "This Application can only be used in conjunction with HAP." & cr & "Direct access to this Application is not available"
         popmessagecr "!", TxtD$(dispdata$ & "\ascribe.ini", "PID", tmp$, "SlaveMessage", 0)
         Close                                       '
         storesEnd                                         '
      End If                                         '
   Else                                                 '---
      If InStr(1, Command$, "///de", 1) = 0 Then                  '26Dec98 ASC
         '''askpassword valid, UserFullName$, "Stock Control"
      Else                                                                                                                                                                    '16May04 TH Added
         If InStr(1, Command$, "///pl", 1) > 0 Then                                                                                                                             '   "
           If Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) < 3 Or Val(Mid$(Command$, InStr(1, Command$, "/pl", 1) + 3, 1)) = 4 Then SetFindDrugLowPassLevel True  '   "
         End If                                                                                                                                                               '   "
      End If                                                    '     "
   End If
   
   StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
   If Trim$(StockExt$) = "" Then
      StockList$ = dispdata$
      gWardStockSite = gDispSite
   Else
      StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, Val(StockExt$))
      gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
   End If
   App.HelpFile = "Stores.hlp"
   
   'Storepasslvl = Val(Mid$(acclevels$, 6, 1))
   
   Storepasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/STRPASS", vbBinaryCompare)) + 8, 1))
   WardStockPasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/WRDPASS", vbBinaryCompare)) + 8, 1))

'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
'Storepasslvl = 8
'WardStockPasslvl = 3 '4 '3 '1
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   ' Gets the location code for items the robot handles
   gRobotLocationCode = GetRobotLocationCode()
    
   SetLicenseOptions
   SetMenuOptions
   
   '12Feb01 JKU Disable Print Coding Slip option if necessary
   If MainScreen.MnuFin.Enabled Then SetPrintCodingMode

   EnterReqCode% = ReadAskSupplierDefaults("Requisitions", 0)
   Select Case ReadAskSupplierDefaults("Requisitions", 1)
      Case 0: EnterReqDisplay$ = "SEWL"
      Case 1: EnterReqDisplay$ = "SE"
      Case 2: EnterReqDisplay$ = "W"           '09Apr98 CFY was 'WL'
      Case Else
      End Select
   
   AmendOrdersCode% = ReadAskSupplierDefaults("Amend Orders", 0)
   Select Case ReadAskSupplierDefaults("Amend Orders", 1)
      Case 0: AmendOrdersDisplay$ = "SEWL"
      Case 1: AmendOrdersDisplay$ = "SE"
      Case 2: AmendOrdersDisplay$ = "WL"
      End Select
   
   SupplierRetCode% = ReadAskSupplierDefaults("Return to Supplier", 0)
   Select Case ReadAskSupplierDefaults("Return to Supplier", 1)
      Case 0: SupplierRetDisplay$ = "SEWL"
      Case 1: SupplierRetDisplay$ = "SE"
      Case 2: SupplierRetDisplay$ = "WL"
      End Select
   
   StockValCode% = ReadAskSupplierDefaults("Stock Value Adj", 0)
   Select Case ReadAskSupplierDefaults("Stock Value Adj", 1)
      Case 0: StockValDisplay$ = "SEWL"
      Case 1: StockValDisplay$ = "SE"
      Case 2: StockValDisplay$ = "WL"
      End Select
   
   StoreValCode% = ReadAskSupplierDefaults("Return to Store", 0)
   Select Case ReadAskSupplierDefaults("Return to Store", 1)
      Case 0: StoreValDisplay$ = "SEWL"
      Case 1: StoreValDisplay$ = "SE"
      Case 2: StoreValDisplay$ = "WL"
      End Select
   
   'display the default table
   ChangeTable "blank", False '14Aug12 TH Added Param
    
   'don't show gauge
   MainScreen.FrmGauge.Visible = False
   MainScreen.Progress.Visible = False

   'If InStr(Command$, "skiptidy") = 0 Then           '17Apr98 CFY Added
   '   TidyUpReprints  '05Mar98 ASC
   'End If                                          '17Apr98 CFY Added
   
   Screen.MousePointer = 0
   If InStr(1, Command$, "///de", 1) Then              '26Dec98 AS
      SiteDrugEnquiry                             '    "
   End If                                         '    "
      
   If InStr(1, Command$, "///lv0", 1) Then
      If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", "UseNewLogView", 0)) Then
         If InStr(1, Command$, "///lk", 1) Then frmLogView.txtSite.Enabled = False '25Apr12 TH TFS 26711
         frmLogView.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      Else
         UserLogViewer "LDFS", "", "", "", "", 0
      End If
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///editors", 1) Then
      MainScreen.Visible = False
      Editors 0
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///printereditors", 1) Then
      MainScreen.Visible = False
      PrinterEditorsMain
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///labeleditors", 1) Then
      MainScreen.Visible = False
      EditPatmedLayouts
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///ffreadonly", 1) Then
      MainScreen.Visible = False
      Editors -5
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///fffull", 1) Then
      MainScreen.Visible = False
      Editors 5
      Close
      storesEnd
   End If
   
   If InStr(1, Command$, "///batchmanagement", 1) Then
      MainScreen.Visible = False
      BatchManagementMain
      Close
      storesEnd
   End If

   '21Jun11 TH Added section (F0102523)
   If InStr(1, Command$, "///logview", 1) Then
      MainScreen.Visible = False
      LogViewer
      Close
      storesEnd
   End If

   MainScreen.lvwMainScreen.Height = Val((terminal$("ScreenViewHeight", "4935")))

   SetupStockLabels     '21Jan99 EAC Setup stock label printing

   Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0  '19Mar09 TH Added For UHB Interfacing
   Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '22Jul10 TH Added (UHB)(F0077942)
   Heap 10, gPRNheapID, "OrderLineNumber", "", 0  '07Sep10 TH initialise linenumber onto the heap (F0054531)
   
End Sub
        
Sub EditPatmedLayouts()
'24Jul97 CKJ/ASC Moved from Patmed & extended
'            Allow separate layouts for eye labels etc
'            NB: some files in dispdata & some in patdata - is this correct??
' 8Dec97 CKJ Moved discharge letter files to EditLayouts (and from patdata to dispdata)
'19Jan98 CKJ Added layouts for FF labels, Patlabel & work label
'20Jul98 EAC make Dispensary Label Editor Language aware
'22Jan99 EAC add Stock Label Editor
'18Aug05 CKJ Added shelf label
'25Jun12 CKJ Added Alternative label layout editor                            TFS36547
'            Added list of standard label layouts for which an RTF exists     TFS37022
'            Removed deprecated "General prescription label layout" & "PRN prescription label layout"
'30Jul12 TH  Changed default patlbl edit as otherwise got an inappropriate msg. Now use standard functionality. (TFS 39940)
'15Jan13 TH  Added PIL rtf edits (TFS 51367)
'18Jan13 TH  Increased menu array for PIL (TFS 53650)
'10Jan17 TH  Convert routines to use rtfs from database
'06Feb17 TH  Use correct template for main PIL template (TFS 175775)


'mods needed
' create blank layout if file missing

Dim ans$, pathfile$
ReDim Menu$(10), menuhlp%(10)      '17Jun14 TH 9 to 10 for extnd lbls'18Jan13 TH increased for PIL (TFS 53650)      '22Jan99 EAC increased from 6 to 7  '18Aug05 CKJ 7 to 8
Dim txt As String
Dim iLoop As Integer
Dim sLbl As String

Dim strPatlblFile As String
Dim blnSuccess As Boolean

'Dim strRTFTextCopy As String '10Jan17 TH Added (Hosted)
Dim strRTFText As String
Dim lngOK As Long

   Menu$(1) = "Dispensing - Standard label layouts ..."           '25Jun12 CKJ altered wording
   Menu$(2) = "Dispensing - Alternative label layouts ..."        '25Jun12 CKJ added
   'Menu$(3) = "General prescription label layout"                '22Jun12 CKJ/AS deprecated - V8 Prescriber only option
   'Menu$(4) = "PRN prescription label layout"                        "     "
   Menu$(3) = "Patient label layouts ..."   '12Apr12 TH Altered
   Menu$(4) = "Free format/extra label layout"
   Menu$(5) = "Manufacturing work label layout"
   Menu$(6) = "Stock label layouts ..."                       '22Jan99 EAC Added
   Menu$(7) = "Shelf-edge label layout"                       '18Aug05 CKJ
   Menu$(8) = "Patient Information Leaflet - Main layout"
   Menu$(9) = "Patient Information Leaflet - Detail layout"
   Menu$(10) = "Dispensing - Extended label layouts ..."
   inputmenu Menu$(), menuhlp(), ans$, k

   Select Case Val(ans$)
      Case 1             'ask for label type letter, equivalent to d.labelformat
         '22Jun12 CKJ added block
         For iLoop = 1 To 26
            sLbl = Chr$(64 + iLoop)   'A-Z
            pathfile$ = dispdata$ & "\" & ASCContextName("DispLBL", False, "") & sLbl & ".RTF"
            'If fileexists(pathfile$) Then txt = txt & sLbl & " "
            If RTFExistsInDatabase(pathfile$) Then txt = txt & sLbl & " "
         Next
         txt = "Enter label format code (A-Z)" & cr & "or leave blank for default layout" & cr & cr & "Label format codes used :   " & txt & cr
         '---
         ans$ = ""
         k.Max = 1
         InputWin "Label Format", txt, ans$, k
         If Not k.escd Then                      '!!** Would prefer a list box here
               ans$ = LTrim$(UCase$(ans$))
               Select Case ans$
                  Case "", "A" To "Z"
                     'pathfile$ = dispdata$ & "\DispLBL" & ans$ & ".RTF      'ans$ is A-Z or empty '20Jul98 EAC make Dispensary Label Editor Language aware
                     'pathfile$ = ASCFileName("DispLBL", False, "") & ans$ & ".RTF"    'ans$ is A-Z or empty
                     pathfile$ = ASCContextName("DispLBL", False, "") & ans$ & ".RTF"    'ans$ is A-Z or empty
                     pathfile$ = dispdata$ & "\" & pathfile$
                     'If Not fileexists(pathfile$) Then
                     If Not RTFExistsInDatabase(pathfile$) Then '10Jan17 TH Replaced
                           If ans$ = "" Then
                                 'popmessagecr "WARNING", "Cannot find default layout file DispLBL.RTF"
                                 popmessagecr "WARNING", "Cannot find default layout file " & pathfile$  '20Jul98 EAC
                              Else
                                 'FileCopy dispdata$ & "\DispLBL.RTF", pathfile$
                                 '10Jan17 TH Here we need to load the template and save as the new version
                                 strRTFText = getPharmacyRTFfromSQL(dispdata$, "DispLBL.RTF")
                                 lngOK = WritePharmacyRTFToSQL(pathfile$, ASCContextName("DispLBL", False, "") & ans$ & ".RTF", strRTFText)
                              End If
                        End If
                     'If fileexists(pathfile$) Then
                     If RTFExistsInDatabase(pathfile$) Then '10Jan17 TH Replaced
                           'HEdit 11, dispdata$ & "\DispLBL" & ans$ & ".RTF"     '20Jul98 EAC make language aware
                           'Hedit 11, pathfile$
                           '10Jan17 TH Replaced above line
                           'strRTFText = getPharmacyRTFfromSQL(pathfile$, ASCContextName("DispLBL", False, "") & ans$ & ".RTF")
                           'strRTFTextCopy = strRTFText
                           'Hedit 1, strRTFText
                           'If strRTFTextCopy <> strRTFText Then
                           '   'Now save to DB
                           '   lngOK = WritePharmacyRTFToSQL(pathfile$, ASCContextName("DispLBL", False, "") & ans$ & ".RTF", strRTFText)
                           'End If
                           EditRTFFromDB pathfile$  '10Jan17 TH Replaced Above(Hosted)
                        End If
                  Case Else
                     popmessagecr "Label Format", "Format code must be A to Z or blank"
                  End Select
            End If
      Case 2: EditAlternativeLabels                   '22Jun12 CKJ alternative label layouts - large labels etc
     'Case 3: Hedit 11, dispdata$ & "\RXGEN.RTF"      '22Jun12 CKJ/AS deprecated - V8 Prescriber only option
     'Case 4: Hedit 11, dispdata$ & "\RXPRN.RTF"          "     "
      Case 3: 'Hedit 11, dispdata$ & "\PatLbl.RTF"
              '12Apr12 TH New patient bag labels
              strPatlblFile = ""
              ReDim Menu$(14), menuhlp%(14)
              Menu$(1) = "Default Patient Label"
              Menu$(2) = "Inpatient Patient Label"
              Menu$(3) = "Outpatient Patient Label"
              Menu$(4) = "Leave Patient Label"
              Menu$(5) = "Discharge Patient Label"
              Menu$(6) = "Ward Stock Patient Label"
              Menu$(7) = "Self Med Patient Label"
              Menu$(8) = "Repeat Dispensing Patient Label"
              Menu$(9) = "Repeat Dispensing Inpatient Patient Label"
              Menu$(10) = "Repeat Dispensing Outpatient Patient Label"
              Menu$(11) = "Repeat Dispensing Leave Patient Label"
              Menu$(12) = "Repeat Dispensing Discharge Patient Label"
              Menu$(13) = "Repeat Dispensing Ward Stock Patient Label"
              Menu$(14) = "Repeat Dispensing Self Med Patient Label"
              'Menu$(15) = "New Specific Patient Label"
              inputmenu Menu$(), menuhlp(), ans$, k
              If Not k.escd Then
                  Select Case Val(ans$)
                      'Case 1: Hedit 11, dispdata$ & "\PatLbl.RTF"
                      Case 1: strPatlblFile = "\PatLbl.RTF"  '30Jul12 TH Changed as otherwise got an inappropriate msg. Now use standard functionality. (TFS 39940)
                      Case 2: strPatlblFile = "\PatLbl_I.RTF"
                      Case 3: strPatlblFile = "\PatLbl_O.RTF"
                      Case 4: strPatlblFile = "\PatLbl_L.RTF"
                      Case 5: strPatlblFile = "\PatLbl_D.RTF"
                      Case 6: strPatlblFile = "\PatLbl_W.RTF"
                      Case 7: strPatlblFile = "\PatLbl_S.RTF"
                      Case 8: strPatlblFile = "\PatLbl_RptDisp.RTF"
                      Case 9: strPatlblFile = "\PatLbl_RptDisp_I.RTF"
                      Case 10: strPatlblFile = "\PatLbl_RptDisp_O.RTF"
                      Case 11: strPatlblFile = "\PatLbl_RptDisp_L.RTF"
                      Case 12: strPatlblFile = "\PatLbl_RptDisp_D.RTF"
                      Case 13: strPatlblFile = "\PatLbl_RptDisp_W.RTF"
                      Case 14: strPatlblFile = "\PatLbl_RptDisp_S.RTF"
                      'Case 13: 'New Specific - Here we take the template and resave under new name
                      
                  End Select
                  blnSuccess = True
                  If strPatlblFile <> "" Then
                      'If Not fileexists(dispdata$ & strPatlblFile) Then
                      If Not RTFExistsInDatabase(dispdata$ & strPatlblFile) Then '10Jan17 TH Replaced
                         'we need to get the template file and copy it to the new name, then edit
                         If Val(ans$) = 1 Then
                            'Template we cant function without this
                            blnSuccess = False
                         ElseIf Val(ans$) = 8 Then
                            'FileCopy dispdata$ & "\PatLbl.RTF", dispdata$ & "\PatLbl_RptDisp.RTF"
                            '10Jan17 TH Here we need to load the template and save as the new version
                            strRTFText = getPharmacyRTFfromSQL(dispdata$, "PatLbl.RTF")
                            lngOK = WritePharmacyRTFToSQL(dispdata$ & "\PatLbl_RptDisp.RTF", "\PatLbl_RptDisp.RTF", strRTFText)
                         ElseIf Val(ans$) < 8 Then
                            'New status driven label
                            'FileCopy dispdata$ & "\PatLbl.RTF", dispdata$ & strPatlblFile
                            '10Jan17 TH Here we need to load the template and save as the new version
                            strRTFText = getPharmacyRTFfromSQL(dispdata$, "PatLbl.RTF")
                            lngOK = WritePharmacyRTFToSQL(dispdata$ & strPatlblFile, strPatlblFile, strRTFText)
                         ElseIf Val(ans$) > 8 And Val(ans$) < 15 Then
                            'If fileexists(dispdata$ & "\PatLbl_RptDisp.RTF") Then
                            If RTFExistsInDatabase(dispdata$ & "\PatLbl_RptDisp.RTF") Then '10Jan17 TH Replaced
                               'FileCopy dispdata$ & "\PatLbl_RptDisp.RTF", dispdata$ & strPatlblFile
                               '10Jan17 TH Here we need to load the template and save as the new version
                               strRTFText = getPharmacyRTFfromSQL(dispdata$, "PatLbl_RptDisp.RTF")
                               lngOK = WritePharmacyRTFToSQL(dispdata$ & strPatlblFile, strPatlblFile, strRTFText)
                            'ElseIf fileexists(dispdata$ & "\PatLbl.RTF") Then
                            ElseIf RTFExistsInDatabase(dispdata$ & "\PatLbl.RTF") Then  '10Jan17 TH Replaced
                               'FileCopy dispdata$ & "\PatLbl.RTF", dispdata$ & strPatlblFile
                               '10Jan17 TH Here we need to load the template and save as the new version
                               strRTFText = getPharmacyRTFfromSQL(dispdata$, "PatLbl.RTF")
                               lngOK = WritePharmacyRTFToSQL(dispdata$ & strPatlblFile, strPatlblFile, strRTFText)
                            Else
                               'We cannot find a suitable template
                               blnSuccess = False
                            End If
                         End If
                      End If
                  End If
              
                  If blnSuccess Then
                     'Hedit 11, dispdata$ & strPatlblFile
                     '10Jan17 TH Replaced above (Hosted)
                     'strRTFText = getPharmacyRTFfromSQL(dispdata$, strPatlblFile)
                     'strRTFTextCopy = strRTFText
                     'Hedit 1, strRTFText
                     'If strRTFTextCopy <> strRTFText Then
                     '   'Now save to DB
                     '   lngOK = WritePharmacyRTFToSQL(dispdata$ & strPatlblFile, strPatlblFile, strRTFText)
                     'End If
                     EditRTFFromDB dispdata$ & strPatlblFile  '10Jan17 TH Replaced Above(Hosted)
                  Else
                      popmessagecr ".WARNING", "Cannot find patient label layout rtf 'PatLbl' in database" & cr & "Please contact Support to install a copy"
                  End If
              End If
              
      Case 4
         'Hedit 11, dispdata$ & "\FFlabel.RTF"
         EditRTFFromDB dispdata$ & "\FFlabel.RTF"  '10Jan17 TH Replaced Above(Hosted)
      Case 5
         'Hedit 11, dispdata$ & "\WorkLbl.RTF"
         EditRTFFromDB dispdata$ & "\WorkLbl.RTF"  '10Jan17 TH Replaced Above(Hosted)
         
      Case 6: EditStockLabel                                    '22Jan99 EAC Added
      Case 7                                                    '18Aug05 CKJ added block
         'If Not fileexists(dispdata$ & "\ShelfLbl.rtf") Then
         If Not RTFExistsInDatabase(dispdata$ & "\ShelfLbl.rtf") Then
            popmessagecr ".WARNING", "Cannot find shelf label layout file 'ShelfLbl.rtf'" & cr & "Please contact Support to install a copy"
         Else
            'Hedit 11, dispdata$ & "\ShelfLbl.rtf"
            '10Jan17 TH Replaced above (Hosted)
            EditRTFFromDB dispdata$ & "\ShelfLbl.RTF"  '10Jan17 TH Replaced Above(Hosted)
         End If
      '15Jan13 TH Added PIL edits
      Case 8
         'edit 11, dispdata$ & "\pil.rtf"
         '10Jan17 TH Replaced above (Hosted)
         'EditRTFFromDB dispdata$ & "\ShelfLbl.RTF"  '10Jan17 TH Replaced Above(Hosted)
         EditRTFFromDB dispdata$ & "\pil.RTF"        '06Feb17 TH Use correct template (TFS 175775)
      Case 9
         'Hedit 11, dispdata$ & "\pildets.rtf"
         EditRTFFromDB dispdata$ & "\pildets.RTF"  '10Jan17 TH Replaced Above(Hosted)
      'Case 4: HEdit 11, patdatapath$ & "\disum.rtf"
      'Case 5: HEdit 11, patdatapath$ & "\symsum.rtf"
      
      '17Jun14 TH Added Extended labels (TFS )
      Case 10:
         'ReDim Menu$(2), menuhlp%(2)
         'Menu$(1) = "Extended Label Part 1"
         'Menu$(2) = "Extended Label Part 2"
         'frmoptionset -1, "Edit Extended Label Templates"
         'For iLoop = 1 To 2
         '   frmoptionset 1, Menu$(iLoop)   'Action 1 adds a line (same as above)
         'Next
         'Screen.MousePointer = STDCURSOR
         'frmoptionshow "1", ans$               'Preset 1st button 'On'
         'If ans$ = "1" Then
         '   Hedit 11, dispdata$ & "\ExtdLbl1.rtf"
         'ElseIf ans$ = "2" Then
         '   Hedit 11, dispdata$ & "\ExtdLbl2.rtf"
         'End If
         
         'Hedit 11, dispdata$ & "\ExtdLbl.rtf" '11Aug14 TH Now use only one rtf
         '10Jan17 TH Replaced above line (Hosted)
          EditRTFFromDB dispdata$ & "\ExtdLbl.RTF"  '10Jan17 TH Replaced Above(Hosted)
      End Select

   k.escd = False

End Sub

Sub EditAlternativeLabels()
'22Jun12 CKJ alternative label layouts - large labels etc     TFS36547
'10Jan17 TH Converted to use DB stored RTF (Hosted)
'02Feb17 TH Added section to allow inclusion of local file (not from DB) (TFS 175474)
         
Const UNUSED = "unused"
            
Dim filename As String, menuopt As String, temp As String, ans As String, TmpFile As String
Dim count As Integer, fil As Integer, exited As Integer
Dim iLoop As Integer
Dim Selected As Integer
Dim modified As Boolean
Dim posn As Integer

Dim lines(1 To ALTLABELMAX) As String
Dim TmpLabel As AltLabel
Dim highlight As Integer
Dim strRTFTextCopy As String '10Jan17 TH Added (Hosted)
Dim strRTFText As String
Dim lngOK As Long


   ReDim altlabels(1 To ALTLABELMAX) As AltLabel

   ans = TxtD(dispdata$ & "\patmed.ini", "AltLabels", "", "Settings", 0)   'context|description|inuse^context|description|inuse^[...]^context|description|inuse'
   deflines ans, lines(), "^", 1, count
   If count <> ALTLABELMAX Then
      popmessagecr "!Alternative Label Layouts", "Configuration setting not found - using default settings"
      modified = True
   End If
   
   Screen.MousePointer = HOURGLASS
   For iLoop = 1 To ALTLABELMAX
      ReDim fields(1 To 3) As String         'context|description|inuse'
      deflines lines(iLoop), fields(), "|(*)", 1, 0
      temp = UCase(Trim(fields(1)))
      If Len(temp) = 0 Or InStr(temp, ALTLABELCONTEXTROOT) <> 1 Then temp = ALTLABELCONTEXTROOT & Format$(iLoop, "00")
      altlabels(iLoop).Context = temp
      fields(2) = Trim$(fields(2))
      If Len(fields(2)) = 0 Then fields(2) = UNUSED
      altlabels(iLoop).Description = Left$(fields(2), 30)   'truncate if entered manually & too long
      altlabels(iLoop).inuse = TrueFalse(fields(3))
      If altlabels(iLoop).inuse Then
         'If Not fileexists(dispdata$ & "\" & altlabels(iLoop).Context & ".rtf") Then altlabels(iLoop).inuse = False 'no rtf, so set not in use anyway
         If Not RTFExistsInDatabase(dispdata$ & "\" & altlabels(iLoop).Context & ".rtf") Then altlabels(iLoop).inuse = False 'no rtf, so set not in use anyway '10Jan17 TH Replaced check
      End If
   Next
   highlight = 0

   popmenu 0, "", 0, 0
   popmenu 2, "Edit &Layout[cr]Edit &Description[cr]&Toggle In Use[cr]Move &Up[cr]Move &Down[cr]&Print List", 0, 0
   Screen.MousePointer = STDCURSOR
   
   Do
      Unload LstBoxFrm
      LstBoxFrm.Caption = "Dispensing - Alternative Label Layout Editor"
      LstBoxFrm.lblTitle = cr & "Select item then right click mouse or press Shift-F1 for menu" & cr & "Select item then click [OK] or press [Enter] to edit the layout" & cr
      LstBoxFrm.lblHead = "Description" & Space$(28) & TB & "In Use  " & TB & "Print Context"
   
      For iLoop = 1 To ALTLABELMAX
         LstBoxFrm.LstBox.AddItem altlabels(iLoop).Description & TB & YesNo(altlabels(iLoop).inuse) & TB & altlabels(iLoop).Context
      Next
      LstBoxFrm.LstBox.ListIndex = highlight
      LstBoxFrm.LstBox.Tag = ""

      LstBoxShow

      menuopt = LstBoxFrm.LstBox.Tag
      highlight = LstBoxFrm.LstBox.ListIndex
      Selected = highlight + 1                              '0 for none, 1-ALTLABELMAX
      exited = (Selected = 0) And (Len(menuopt) = 0)
      If Selected > 0 And Len(menuopt) = 0 Then menuopt = "1"
      
      Select Case menuopt
         Case "1"       'Edit label
            If Selected > 0 Then
               filename = dispdata$ & "\" & altlabels(Selected).Context & ".rtf"
               'If Not fileexists(filename) Then
               If Not RTFExistsInDatabase(filename) Then '10Jan17 TH Replaced check
                  'FileCopy dispdata$ & "\DispLBL.RTF", filename
                  '10Jan17 TH Here we need to load the template and save as the new version
                  strRTFText = getPharmacyRTFfromSQL(dispdata$, "DispLBL.RTF")
                  lngOK = WritePharmacyRTFToSQL(dispdata$ & "\DispLBL.RTF", altlabels(Selected).Context & ".rtf", strRTFText)
               End If
               'Hedit 11, filename
               '10Jan17 TH Replaced above line
               strRTFText = getPharmacyRTFfromSQL(filename, altlabels(Selected).Context & ".rtf")
               strRTFTextCopy = strRTFText
               Hedit 1, strRTFText
               If strRTFTextCopy <> strRTFText Then
                  'Now save to DB
                  lngOK = WritePharmacyRTFToSQL(filename, altlabels(Selected).Context & ".rtf", strRTFText)
               End If
            End If

         Case "2"       'Edit description
            If Selected > 0 Then
               ans = RTrim$(altlabels(Selected).Description)
               If ans = UNUSED Then ans = ""
               k.min = 0
               k.Max = 30
               InputWin "Label Layout Description", "Enter description for layout " & altlabels(Selected).Context & cr, ans, k
               If Not k.escd Then
                  ans = RTrim$(ans)
                  replace ans, "|", "", 0    'delimiters
                  replace ans, "^", "", 0
                  If ans = "" Then ans = UNUSED
                  If RTrim(altlabels(Selected).Description) <> ans Then
                     altlabels(Selected).Description = ans
                     modified = True
                  End If
               End If
            End If

         Case "3"       'Toggle InUse
            If Selected > 0 Then
               'If fileexists(dispdata$ & "\" & altlabels(Selected).Context & ".rtf") Or altlabels(Selected).inuse Then   '16Jul12 CKJ Corrected; was ".rtf)"
               If RTFExistsInDatabase(dispdata$ & "\" & altlabels(Selected).Context & ".rtf") Or altlabels(Selected).inuse Then   '10Jan17 TH Replaced check
                  altlabels(Selected).inuse = Not altlabels(Selected).inuse
                  modified = True
               Else
                  popmessagecr "#Toggle In Use", "Layout must be created before it can be set in use"
               End If
            End If

         Case "4", "5"  'Move Up / Down
            If menuopt = "5" And Selected > 0 And Selected < ALTLABELMAX Then Selected = Selected + 1
            If Selected > 1 Then
               LSet TmpLabel = altlabels(Selected)
               LSet altlabels(Selected) = altlabels(Selected - 1)
               LSet altlabels(Selected - 1) = TmpLabel
               highlight = highlight + (menuopt = "4") - (menuopt = "5")
               modified = True
            End If

         Case "6"       'Print List
            'If fileexists(dispdata$ & "\lstprint.rtf") Then
            If RTFExistsInDatabase(dispdata$ & "\lstprint.rtf") Then '10Jan17 TH Replaced check
               Heap 10, gPRNheapID, "ReportTitle", "Dispensing - Alternative Label Layouts", 0
               Heap 10, gPRNheapID, "InternalTitle", "Dispensing - Alternative Label Layouts", 0
               Heap 10, gPRNheapID, "ColumnTitles", " \tab " & "In use" & " \tab " & "Print context" & " \tab " & "Description", 0

               MakeLocalFile TmpFile
               fil = FreeFile
               Open TmpFile For Output As #fil
               For count = 1 To LstBoxFrm.LstBox.ListCount - 1
                  temp = LstBoxFrm.LstBox.List(count)
                  posn = InStr(temp, TB)
                  temp = Mid$(temp, posn + 1) & TB & Left$(temp, posn - 1)
                  replace temp, TB, " \tab ", 0
                  Print #fil, " \tab " & temp & " \par "
               Next
               Close #fil

               'Heap 10, gPRNheapID, "ColumnData", "[#include" & TB & TmpFile & "]", 0
               Heap 10, gPRNheapID, "ColumnData", "[#includx" & TB & TmpFile & "]", 0 '02Feb17 TH Added section to allow inclusion of local file (not from DB) (TFS 175474)
               
               'ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False
               ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False, False '04Jan17 TH Use DB parsing

               On Error Resume Next
               Kill TmpFile
               On Error GoTo 0
            Else
               popmessagecr "", "Could not print list. File '" & dispdata$ & "\lstprint.rtf' not found."
            End If

         End Select

      If modified Then
         Screen.MousePointer = HOURGLASS
         ans = ""
         For iLoop = 1 To ALTLABELMAX
            temp = RTrim$(altlabels(iLoop).Description)
            replace temp, "|", "", 0    'delimiters
            replace temp, "^", "", 0
            ans = ans & altlabels(iLoop).Context & "|" & temp & "|" & Iff(altlabels(iLoop).inuse, "1", "0")
            If iLoop < ALTLABELMAX Then ans = ans & "^"
         Next
         WritePrivateIniFile "AltLabels", "Settings", ans, dispdata$ & "\patmed.ini", 0
         modified = False
         Screen.MousePointer = STDCURSOR
      End If
      
   Loop Until exited

   Unload LstBoxFrm
   popmenu 0, "", 0, 0
            
End Sub

Sub EditStockLabel()
'22Jan99 EAC written
'07Jan15 TH Added description to picker list  TFS 88935
'06Apr16 XN trimed LocalDescription before comparing it to "" 149885
'04Jan17 TH Switch to use DB Parsing (TFS 157969)
'05Jan17 TH Replaced RTF Handling (TFS 157969)
'06Jan17 TH Overhauled RTF handling (TFS 157969)

Dim SQL$, filename$, dc$, wd$, menuopt$, TmpFile1$, temp$, msg$, ans$
Dim id&, loopvar&
Dim filenames$()
Dim ReadOnly%, Action%, count%, fil%, exited%, OK%
Dim RSStockLabels As ADODB.Recordset
Dim strParams As String
Dim lngID As Long  '10Jul11 TH Added (F0118860)
Dim dlookup As DrugParameters    '07Jan15 TH (TFS 88935)
Dim strStoresDesc As String      '  "
Dim intSuccess  As Integer    '05Jan17 TH Added (hosted)
Dim strRTFText As String      '  "
Dim strRTFTextCopy As String
Dim lngOK As Long

   Screen.MousePointer = HOURGLASS

   'Set StckLblDb = OpenDatabase(dispdata$ & "\stcklbls.mdb")

   'ReadOnly% = Val(Mid$(acclevels$, 1, 1)) <> 9
   ReadOnly% = Storepasslvl < 5     '24Apr06 TH Added

   popmenu 0, "", 0, 0
   popmenu 2, "&Edit Layout[cr]&Print list", 0, 0
   If Not ReadOnly Then popmenu 2, "&Amend Codes[cr]&Add Item[cr]De&lete item", 0, 0
   Do
      Unload LstBoxFrm
      LstBoxFrm.Caption = "Stock Label Layout Editor"
      LstBoxFrm.lblTitle = cr & "Select item to edit." & cr & "Press Shift-F1 or click right mouse button for menu" & cr
      LstBoxFrm.lblHead = "Drug Code        " & TB$ & "Ward Code    " & TB$ & "Drug Description" & Space$(100)
   
      LstBoxFrm.LstBox.AddItem "Add a new Layout"
      LstBoxFrm.LstBox.AddItem "Default Stock Label Layout"
   
      'SQL$ = "SELECT DISTINCT * FROM StockLabels ORDER BY WardCode,DrugCode"
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      Set RSStockLabels = gTransport.ExecuteSelectSP(g_SessionID, "pWStockLabelsbySiteID", strParams)
   
      If RSStockLabels.RecordCount > 0 Then
      ReDim filenames$(RSStockLabels.RecordCount + 1)
   
      Do While Not RSStockLabels.EOF
         dc$ = RtrimGetField(RSStockLabels!DrugCode)
         If dc$ = "*******" Then
            dc$ = "All Drugs"
            strStoresDesc = ""
         Else
            dlookup.SisCode = dc$
            getdrug dlookup, 0, 0, False
            strStoresDesc = Iff(Trim$(dlookup.LocalDescription) = "", dlookup.storesdescription, dlookup.LocalDescription) ' dlookup.storesdescription XN 9Jun15 98073 New local stores description
            plingparse strStoresDesc, "!"
         End If
         wd$ = RtrimGetField(RSStockLabels!wardcode)
         If wd$ = "*****" Then wd$ = "All Wards"
   
         LstBoxFrm.LstBox.AddItem dc$ & TB$ & wd$ & TB$ & strStoresDesc
         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListCount - 1) = GetField(RSStockLabels!WStockLabelsID)
         filenames$(LstBoxFrm.LstBox.ListCount - 1) = GetField(RSStockLabels!RTFfilename)
         RSStockLabels.MoveNext
      Loop
      End If
      RSStockLabels.Close
      Set RSStockLabels = Nothing
   
      Screen.MousePointer = STDCURSOR

   'Do
      LstBoxFrm.LstBox.Tag = ""

      LstBoxShow

      menuopt$ = LstBoxFrm.LstBox.Tag
      exited% = (LstBoxFrm.LstBox.ListIndex = -1)

      If menuopt$ = "" And LstBoxFrm.LstBox.ListIndex > -1 Then menuopt$ = "1"

      Select Case menuopt$
         Case "1", "4"   'Edit , Add

            If menuopt$ = "4" Then LstBoxFrm.LstBox.ListIndex = 0
            'If MenuOpt$ = "1" And LstBoxFrm.LstBox.ListIndex = 0 Then LstBoxFrm.LstBox.ListIndex = -1

            Select Case LstBoxFrm.LstBox.ListIndex
               Case -1
                  'Nothing highlighted so do nothing
                  filename$ = ""
               Case 0
                  dc$ = "": wd$ = "": id& = -1
                  filename$ = GetNextStockLabelName(dc$, wd$, id&)
                  If dc$ = "*******" Then dc$ = "All drugs"
                  If wd$ = "*****" Then wd$ = "All wards"
                  LstBoxFrm.LstBox.AddItem dc$ & TB$ & wd$
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListCount - 1) = id&
                  ReDim Preserve filenames$(LstBoxFrm.LstBox.ListCount - 1)
                  filenames$(LstBoxFrm.LstBox.ListCount - 1) = filename$

               Case 1
                  filename$ = "\stklabel.rtf"
               Case Else
                  filename$ = filenames$(LstBoxFrm.LstBox.ListIndex)
               End Select

            If filename$ <> "" Then
                  '06Jan17 TH Here we need to load the rtf from the DB and send in the text
                  'If menuopt$ = "4" Then  'If we adding then we have nothing to load
                  '   strRTFtext = ""
                  'Else
                     strRTFText = getPharmacyRTFfromSQL(dispdata$, filename$) 'We always have something as GetNextStockLabelName preloads a record from the template !
                  'End If
                  'Action = 11 + ReadOnly%
                  'Hedit Action, dispdata$ & filename$
                  strRTFTextCopy = strRTFText
                  Action = 1 + ReadOnly%  '06Jan17 TH Now we send the RTF text in rather than the file
                  Hedit Action, strRTFText
                  'Now we check if the edited text is different and save to DB if so
                  If strRTFTextCopy <> strRTFText Then
                     'Now save to DB
                     lngOK = WritePharmacyRTFToSQL(dispdata$, filename$, strRTFText)
                  End If
               End If

         Case "2"       'Print List
            GetRTFTextFromDB dispdata$ & "\lstprint.rtf", "", intSuccess    '05Jan17 TH Replaced above line (Hosted)
            'If fileexists(dispdata$ & "\lstprint.rtf") Then 'HOSTED TO DO - READ From DB
            If intSuccess Then
                  Heap 10, gPRNheapID, "ReportTitle", "Stock Labels Layouts", 0
                  Heap 10, gPRNheapID, "InternalTitle", "Stock Labels Layouts", 0
                  Heap 10, gPRNheapID, "ColumnTitles", "Drug Code" & " \tab " & "Ward Code" & " \tab " & "Layout File Name", 0

                  MakeLocalFile TmpFile1$
                  fil = FreeFile
                  Open TmpFile1$ For Output As #fil
                  For count = 2 To LstBoxFrm.LstBox.ListCount - 1
                     temp$ = LstBoxFrm.LstBox.List(count)
                     replace temp$, Chr$(9), " \tab ", 0
                     Print #fil, temp$ & " \tab \" & filenames$(count)
                     Print #fil, " \par "
                  Next
                  Close #fil

                  Heap 10, gPRNheapID, "ColumnData", "[#include" & TB & TmpFile1$ & "]", 0
                  'ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False '15Jun11 TH Added parameter (F0088129)
                  ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)

                  On Error Resume Next
                  Kill TmpFile1$
                  On Error GoTo 0
               Else
                  'popmessagecr "", "Could not print list. File '" & dispdata$ & "\lstprint.rtf' not found."
                  popmessagecr "", "Could not print list. RTF 'lstprint.rtf' not found in database."
               End If

         Case "3"       'Amend Codes
            If LstBoxFrm.LstBox.ListIndex > 1 Then

                  dc$ = "": wd$ = ""
                  OK = GetStockLblCodes(dc$, wd$)
                  If OK Then
                        id& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        'Update Using the ID
                        'First Get the Original REcord then replace the stuff we are changing and update the row
                        
                        strParams = gTransport.CreateInputParameterXML("WStockLabelID", trnDataTypeint, 4, id&)

                        'SQL$ = "SELECT WardCode, DrugCode FROM StockLabels WHERE Id = " & Format$(id&)
                        'Set dyn = StckLblDb.CreateDynaset(SQL$)
                        'Set RSStockLabels = gTransport.ExecuteSelectSP(g_SessionID, "WStockLabelbyID", strParams)
                        Set RSStockLabels = gTransport.ExecuteSelectSP(g_SessionID, "pWStockLabelbyID", strParams) '10Jul11 TH Changed spelling of sp (F0118860)
                        
                        If Not RSStockLabels.EOF Then
                           'dyn.Edit
                           'dyn!wardcode = wd$
                           'dyn!DrugCode = dc$
                           'dyn.Update
                           '10Jul11 TH Changed param on rs to SIteID for locationiD_Site
                           strParams = gTransport.CreateInputParameterXML("WStockLabelID", trnDataTypeint, 4, id&) & _
                                       gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, RtrimGetField(RSStockLabels!SiteID)) & _
                                       gTransport.CreateInputParameterXML("DrugCode", trnDataTypeVarChar, 7, dc$) & _
                                       gTransport.CreateInputParameterXML("WardCode", trnDataTypeVarChar, 5, wd$) & _
                                       gTransport.CreateInputParameterXML("RTFFileName", trnDataTypeVarChar, 13, RtrimGetField(RSStockLabels!RTFfilename))
                           
                           lngID = gTransport.ExecuteUpdateSP(g_SessionID, "WStockLabels", strParams) '10Jul11 TH Inexplicably this call was missing (F0118860)
                           
                           If dc$ = "*******" Then dc$ = "All drugs"
                           If wd$ = "*****" Then wd$ = "All wards"
                           LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex) = dc$ & TB$ & wd$
                        Else
                           'popmessagecr "!Amend Codes", "This label was not found in the database. These ammendments will not be saved."
                           popmessagecr "!Amend Codes", "This label was not found in the database. These amendments will not be saved." '10Jul11 TH Changed spelling
                        End If
                        RSStockLabels.Close
                        Set RSStockLabels = Nothing
                     End If
               Else
                  'popmessagecr "Amend Codes", "This item is a default and can not be ammended."
                  popmessagecr "Amend Codes", "This item is a default and can not be amended." '10Jul11 TH Altered spelling
               End If

         Case "5"       'Delete Item
            If LstBoxFrm.LstBox.ListIndex > 1 Then
                  ans$ = "N"
                  msg$ = "Are you sure you want to delete the layout for " & LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)
                  msg$ = msg$ & cr$ & cr$ & "You will not be able to access this layout again if you answer 'Yes'."
                  askwin "Delete Stock Label Layout", msg$, ans$, k
                  If Not k.escd And ans$ = "Y" Then
                        Screen.MousePointer = HOURGLASS
                        id& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        'SQL$ = "DELETE * FROM StockLabels WHERE Id = " & Format$(id&)
                        ''StckLblDb.Execute sql$
                        '10Jul11 TH Changed param on rs to SIteID for locationiD_Site
                        'strParams = gTransport.CreateInputParameterXML("WStockLabelID", trnDataTypeint, 4, id&)
                        
                        lngID = gTransport.ExecuteDeleteSP(g_SessionID, "WStockLabels", id&) '10Jul11 TH Inexplicably this call was missing (F0118860)

                        'Remove file name from array
                        ReDim tempfn$(UBound(filenames$) - 1)
                        For loopvar& = 0 To LstBoxFrm.LstBox.ListIndex - 1
                           tempfn$(loopvar&) = filenames$(loopvar&)
                        Next

                        For loopvar& = LstBoxFrm.LstBox.ListIndex To UBound(tempfn$)
                           tempfn$(loopvar&) = filenames$(loopvar& + 1)
                        Next

                        ReDim filenames$(UBound(tempfn$))
                        For loopvar = 0 To UBound(tempfn$)
                           filenames$(loopvar&) = tempfn$(loopvar&)
                        Next

                        'Remove line from the list box
                        LstBoxFrm.LstBox.RemoveItem (LstBoxFrm.LstBox.ListIndex)
                        LstBoxFrm.Refresh
                        
                        Screen.MousePointer = STDCURSOR
                     End If
               Else
                  popmessagecr "Delete Item", "This item is a default and can not be deleted."
               End If
         End Select

   Loop Until exited%

   Unload LstBoxFrm
   popmenu 0, "", 0, 0

   ''StckLblDb.Close
   ''Set StckLblDb = Nothing

End Sub

Function GetNextStockLabelName(drug$, ward$, id&) As String

'Dim dyn As dynaset
Dim OK As Integer
Dim SQL$, fn$
Dim strParams As String
Dim lngID As Long
Dim strRTFTxt As String
Dim lngOK As Long

   OK = GetStockLblCodes(drug$, ward$)
   If Not OK Then Exit Function
   
   'sql$ = "SELECT * FROM StockLabels WHERE 1=2"
   'Set dyn = StckLblDb.CreateDynaset(sql$)
   'Insert a new row, then immediately Update it once we have the ID
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("DrugCode", trnDataTypeVarChar, 7, drug$) & _
               gTransport.CreateInputParameterXML("WardCode", trnDataTypeVarChar, 5, ward$) & _
               gTransport.CreateInputParameterXML("RTFFileName", trnDataTypeVarChar, 13, "")

   'BeginTrans
   'dyn.AddNew
   lngID = gTransport.ExecuteInsertSP(g_SessionID, "WStockLabels", strParams)
   If lngID Then
   
      'dyn!DrugCode = drug$
      'dyn!wardcode = ward$
      ''id& = dyn!id
      fn$ = "\SL" & Format$(lngID, "000000") & ".rtf"
      'FileCopy dispdata$ & "\stklabel.rtf", dispdata$ & fn$
      '06Jan17 TH Here we need to load the template from the DB, and write under the new Filename
      strRTFTxt = getPharmacyRTFfromSQL(dispdata$, "stklabel.rtf")
      'Now Write back
      lngOK = WritePharmacyRTFToSQL(dispdata$, fn$, strRTFTxt)
      'Do the Update
      strParams = gTransport.CreateInputParameterXML("WStockLabelID", trnDataTypeint, 4, lngID) & _
                  gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("DrugCode", trnDataTypeVarChar, 7, drug$) & _
                  gTransport.CreateInputParameterXML("WardCode", trnDataTypeVarChar, 5, ward$) & _
                  gTransport.CreateInputParameterXML("RTFFileName", trnDataTypeVarChar, 13, fn$)
      lngID = gTransport.ExecuteUpdateSP(g_SessionID, "WStockLabels", strParams)
'      dyn!RTFfilename = fn$
'      On Error GoTo GNSL_Update_Err
'      dyn.Update
'      On Error GoTo 0
   Else
      popmessagecr ".Error", "An error occurred writing to the database." & cr$ & cr$ & "WStockLabel record Could not be inserted." & cr$ & cr$ & "This layout will not be saved."
   End If
   'CommitTrans
GNSL_Update_Resume:
   'dyn.Close
   'Set dyn = Nothing

   GetNextStockLabelName$ = fn$

Exit Function

GNSL_Update_Err:

   'Rollback
   popmessagecr ".Error", "An error occurred writing to the database." & cr$ & cr$ & "Error No: " & Format$(Err) & cr$ & "Error Msg: " & Error$(Err) & cr$ & cr$ & "This layout will not be saved."
   fn$ = ""
Resume GNSL_Update_Resume

End Function

Function GetStockLblCodes(drug$, ward$) As Integer

Dim found%, foundPtr&   ' 01Jun02 ALL/ATW
Dim sup As supplierstruct

   GetStockLblCodes = True

   InputWin "Enter Drug Code", "Enter the drug that this layout will apply to (Leave blank for all drugs)", drug$, k
   If k.escd Then
         GetStockLblCodes = False '13Jul11 TH Added (F)
         Exit Function
      Else
         If Trim$(drug$) <> "" Then
               findrdrug drug$, True, d, foundPtr&, found%, 0, False, False
               If Not found Then
                     GetStockLblCodes = False
                     Exit Function
                  Else
                     drug$ = d.SisCode
                  End If
            Else
               drug$ = "*******"
            End If
      End If
   
   asksupplier ward$, 1, "WL", "Select Ward", False, sup, False '15Nov12 TH Added PSO param
   Select Case ward$
      Case ""                     'Escaped
         GetStockLblCodes = False
         Exit Function
      Case "A"
         ward$ = "*****"
      Case Else
      End Select

   If Trim$(drug$) = "" And Trim$(ward$) = "" Then
         popmessagecr "Stock Labels", "You have asked for the label to apply for all drugs to all wards. The default stock label is used for this situation." & cr$ & cr$ & "A new layout will not be created."
         GetStockLblCodes = False
      End If


End Function

Public Sub PutRecordFailure(ByVal ErrNo As Long, ByVal ErrDescription As String)
'Bye bye Baby bye bye
Dim strMsg As String

   strMsg = "Error Number = " & Format$(ErrNo) & "   " & ErrDescription

   popmessagecr "", strMsg & crlf & crlf & "A critical Error has occurred. This application can no longer continue"
   Close
   storesEnd

End Sub

Sub LX(mnu As Menu, SuppCode$, Action%, Token&)
'Nov-Dec96 CKJ/EAC Licence interface
'Parameters:
' Ctl is a control which has one or more attributes to be set.
'   examples are mnuItem.enabled, mnuItem.visible, frmForm.tag
'   The name of the control is central to the licence operation
' SuppCode$ may be optional - depends on individual controls.
'   It is used to specify a licence element for generic controls.
' Action is applied to the control
'   0 no  action
'   1 set visible
'   2 set enabled
'   4 set tabstop
'   8 set checked
'  16 set text/caption
'  32 set tag
'  These can be added together, where doing so is sensible,
'   eg   3 sets both visible & enabled to T or F
'       48 sets text and tag of a textbox to same value
' Token - to be decided; probably supplementary security
'    leave at zero for now
'16Dec96 CKJ Ready for testing
               
Dim Value$, LinkID$, i%, Filter%

   On Error Resume Next
   
   'LinkID$ = vbGetCtrlName(Ctl.Parent) & "." & vbGetCtrlName(Ctl.)
   LinkID$ = mnu.Parent.name & "." & mnu.name
''   LinkID$ = LinkID$ & "." & Format$(Ctl.Index) 'resume next if 'object not an array'
   LinkID$ = LinkID$ & "." & Format$(mnu.Index) 'resume next if 'object not an array'
   If SuppCode$ <> "" Then LinkID$ = LinkID$ & "." & SuppCode$

   Value$ = fLX(LinkID$, Token&)

   For i = 0 To 5
      Filter = 2 ^ i                                 ' 1  2  4  8 16 32
      Select Case Action And Filter
    Case 1:  mnu.Visible = (Val(Value$) <> 0)   'reduce to boolean
    Case 2:  mnu.Enabled = (Val(Value$) <> 0)
''    Case 4:  Mnu.tabstop = (Val(value$) <> 0)
    Case 8:  mnu.Checked = (Val(Value$) <> 0)
    Case 16
''       Mnu.Text = value$                        'only one will fire successfully
''       Mnu.Caption = value$
    Case 32: mnu.Tag = Value$
    End Select
   Next
   On Error GoTo 0

End Sub

Private Function fLX(LinkID$, Token&) As String
'Licence control procedure
' All handling of the licence file is done here
' - read once, hold as static data & hand out data on demand
' Call at start of program to fill    Ret$ = Flx("", Token&)
' Ret$ is blank on first call, Token& is not used yet.
' NB if routine fails to read a valid set of data program ends.

'Once read into Txt$, each entry is of the format [10]item=value[13]

Static txt$
Dim pathfileext$, success%, tmp$, ret$, posn%, posn1%
            
   success = False
   ret$ = ""
   If txt$ = "" Then                                           'not already loaded
    pathfileext$ = dispdata$ & "\ascribe.lx"
    If fileexists(pathfileext$) Then                      'file found
          GetTextFile pathfileext$, txt$, success
          If success Then
           decodehex txt$
           txt$ = Chr$(10) & txt$ & cr
           'encodehex Txt$
           'PutTextFile pathfileext$, Txt$, success
        End If
       End If
      Else
    success = True
      End If

   If success And LinkID$ <> "" Then
    tmp$ = Chr$(10) & LinkID$ & "="
    posn = InStr(1, txt$, tmp$, 1)                        'case independent
    If posn Then
          posn1% = InStr(posn + Len(tmp$), txt$, cr)      'look for end of string
          fLX$ = Mid$(txt$, posn + Len(tmp$), posn1 - Len(tmp$) - posn)
       End If
      End If

End Function

Sub MnuInfoEnabled(ByVal blnEnable As Boolean)
'13Mar07 CKJ replaces ten blocks of duplicate code (SC-07-0157)
'            The menu heading is enabled for all users, all menu options are enabled/diabled together
'            No functional change from the duplicated code, but avoids adding to the confusion with
'            addition of Robot messages option.
   
   MainScreen.MnuInfoTop.Enabled = True
   MainScreen.mnuInfo(0).Enabled = blnEnable
   MainScreen.mnuInfo(1).Enabled = blnEnable
   '                 (2) separator
   MainScreen.mnuInfo(3).Enabled = blnEnable
   MainScreen.mnuInfo(4).Enabled = blnEnable
   '                 (5) separator
   MainScreen.mnuInfo(6).Enabled = blnEnable
   MainScreen.mnuInfo(7).Enabled = blnEnable
   '                 (8) separator
  ' MainScreen.MnuInfo(9).Enabled = blnEnable
   
End Sub

Sub SetRobotLoadingMenuOption(ByVal Enable As Boolean)
' 15 Jan10 XN Enables the Robot Loading menu item if a robot location
' is present in the Settings table for current site
' So would need settings
'   System: PharmacyReplyComponent
'   Key   : SiteNumber
'   Value : <This instance site number>
'
'   System: PharmacyReplyComponent
'   Key   : Location
'   Value : Robot location code
'
'  Both would need the same section type
    
   If Enable And MainScreen.MnuOrdersReceive.Enabled Then               'only enable if requested, allowed and configured
      MainScreen.MnuRobotLoading.Enabled = (gRobotLocationCode <> "")
   Else
      MainScreen.MnuRobotLoading.Enabled = False
   End If

End Sub

Function GetRobotLocationCode() As String
' 15 Jan10 XN Get the Robot's location code from the settings table
' So would need settings
'   System: PharmacyReplyComponent
'   Key   : SiteNumber
'   Value : <This instance site number>
'
'   System: PharmacyReplyComponent
'   Key   : Location
'   Value : Robot location code
'
'  Both would need the same section type
' 24Mar14 XN 86905 Changed RobotLoaderReplyComponent to PharmacyReplyComponent
    
Dim data As ADODB.Recordset
Dim strParams As String
Dim Section As String

    GetRobotLocationCode = ""
    Section = ""

    On Error GoTo GetRobotLocationCode_Error

    ' First get all robot instance site numbers (to find matching one)
    ' This will give the section name to uses
    'strParams = gTransport.CreateInputParameterXML("System", trnDataTypeVarChar, 50, "RobotLoaderReplyComponent") & _  24Mar14 XN 86905 Changed RobotLoaderReplyComponent to PharmacyReplyComponent
    strParams = gTransport.CreateInputParameterXML("System", trnDataTypeVarChar, 50, "PharmacyReplyComponent") & _
                gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 50, "SiteNumber")
    Set data = gTransport.ExecuteSelectSP(g_SessionID, "pSettingBySystemAndKey", strParams)

    Do While Not data.EOF
        If RtrimGetField(data!Value) = SiteNumber Then Section = data!Section
        data.MoveNext
    Loop
    data.Close

    ' Now get the robot location
    If (Section <> "") Then
        'strParams = gTransport.CreateInputParameterXML("System", trnDataTypeVarChar, 50, "RobotLoaderReplyComponent") & _  24Mar14 XN 86905 Changed RobotLoaderReplyComponent to PharmacyReplyComponent
        strParams = gTransport.CreateInputParameterXML("System", trnDataTypeVarChar, 50, "PharmacyReplyComponent") & _
                    gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 50, Section) & _
                    gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 50, "Location")
        Set data = gTransport.ExecuteSelectSP(g_SessionID, "pSetting", strParams)

        If Not data.EOF Then GetRobotLocationCode = data!Value
        data.Close
    End If

Exit Function

GetRobotLocationCode_Error:
    GetRobotLocationCode = ""

End Function

' Start of 08Jun10 XN F0085853
Sub SetSiteToolBarColour()
' Set toolbar colour  from config setting
' Uses WConfiguration setting
'   Category: D|SITEINFO
'   Section :
'   Key     : StoresMenuBarColour
'
' If the config setting is blank then nothing is changed
' Otherwise the value can be an integer, Hex value in the form &HBBGGRR, or
' text value of either black, blue, cyan, green, magenta, red, white, yellow
' 08Jun10 XN Created (F0085853)
' 14Jun10 XN Fix error if setting was Hex
'24Jan13 CKJ Moved contents to SetSiteToolBarColourByForm  TFS54244
       
   SetSiteToolBarColourByForm MainScreen

End Sub
' End of F0085853

Sub SetSiteToolBarColourByForm(frm As Form)
' Set toolbar colour  from config setting
' Uses WConfiguration setting
'   Category: D|SITEINFO
'   Section :
'   Key     : StoresMenuBarColour
'
' If the config setting is blank then nothing is changed
' Otherwise the value can be an integer, Hex value in the form &HBBGGRR, or
' text value of either black, blue, cyan, green, magenta, red, white, yellow
' 08Jun10 XN Created (F0085853)
' 14Jun10 XN Fix error if setting was Hex
'24Jan13 CKJ Added form to update. Renamed proc from SetSiteToolBarColour  TFS54244

Dim toolbarColour As String
Dim Colour As Long

   On Error GoTo SetSiteToolBarColourByForm_Error
   
   toolbarColour = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StoresMenuBarColour", 0)
   If toolbarColour <> "" Then
      If IsNumeric(toolbarColour) Then
         Colour = CLng(toolbarColour)
      Else
         Select Case LCase$(toolbarColour)
            Case "black":   Colour = ColorConstants.vbBlack
            Case "blue":    Colour = ColorConstants.vbBlue
            Case "cyan":    Colour = ColorConstants.vbCyan
            Case "green":   Colour = ColorConstants.vbGreen
            Case "magenta": Colour = ColorConstants.vbMagenta
            Case "red":     Colour = ColorConstants.vbRed
            Case "white":   Colour = ColorConstants.vbWhite
            Case "yellow":  Colour = ColorConstants.vbYellow
            End Select
      End If
       
      SetToolBarBackColour frm, 1, Colour
   End If
        
SetSiteToolBarColourByForm_Exit:
Exit Sub

SetSiteToolBarColourByForm_Error:
Resume SetSiteToolBarColourByForm_Exit

End Sub

Public Sub BlankOrderInfoScreens()
'06Jul11 CKJ renamed from BlankOrderScreens. Now used everywhere that these panels are blanked
   MainScreen.PicInfo1.Visible = False
   MainScreen.PicInfo2.Visible = False
   MainScreen.PicInfo1.Cls
   MainScreen.PicInfo2.Cls
End Sub

Public Sub setPSO(ByVal blnPSO As Boolean)
'14Aug12 TH Written

   m_blnPSO = blnPSO

End Sub

Public Function getPSO() As Boolean
'14Aug12 TH Written

   getPSO = m_blnPSO

End Function

Sub FillHeapPSOrderInfo(ByVal HeapID As Integer, ByVal WOrderID As Long, ByVal Edittype As Integer, ByRef success As Integer)
'15Aug12 TH Written
'11Feb13 TH Case the forename/surname fields '08Mar13 TH Name changes for PSO (TFS 56646,58429)
'21Mar13 TH Changed date formats (TFS 59487)
'22Mar13 TH further change to handle unrecorded DOB (TFS 59559)

Dim strParams As String
Dim rs As ADODB.Recordset
Dim id As Integer
Dim act As Integer
Dim strForename As String
Dim strFName As String
Dim intloop As Integer
Dim blnUcase As Boolean
Dim strInitials As String  '19Mar13 TH Merge Error
Dim intPosn As Integer     '19Mar13 TH Merge Error
Dim strDOB As String       '22Mar13 TH
Dim valid As Integer       '22Mar13 TH
Dim strLabelTxt As String  '31Aug14 TH Compilation stuff
Dim strDatexml As String   '21Oct14 TH Added

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
      ClearHeapPSOrderInfo id
      'Get the data
      strParams = gTransport.CreateInputParameterXML("WorderID", trnDataTypeint, 4, WOrderID)
      If Edittype > 3 Then
         Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPSOInfobyWReconcilID", strParams)
      Else
         Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPSOInfobyWorderID", strParams)
      End If
      If Not rs.EOF Then
         rs.MoveFirst
         'then fill the heap
         strForename = RtrimGetField(rs!forename)
         If Len(Trim$(strForename)) > 15 Then
            'Bigger than the pharmacy forename - initialise
            strInitials = Left$(strForename, 1)                               'take first initial (may be zero length)
            intPosn = InStr(strForename, " ")                               'two first names?
            If intPosn Then                                            '... yes
               'Can we get the first name and second intitial in ?
               If Len(Trim$(Left$(strForename, intPosn)) & Mid$(strForename, intPosn, 2)) < 16 Then
                  strInitials = Trim$(Left$(strForename, intPosn)) & Mid$(strForename, intPosn, 2)
               Else
                  strInitials = strInitials & Mid$(strForename, intPosn, 2)           '03Dec99 TH Retain first initial
               End If
            End If
            strForename = strInitials
         'Else
         '   pid.forename = WPat.forename
         End If
         blnUcase = True
         strFName = ""
         If Len(Trim$(strForename)) > 0 Then
            strForename = strForename & Space$(15)
            For intloop = 1 To 15
               If blnUcase Then
                   strFName = strFName & UCase$(Mid$(strForename, intloop, 1))
               Else
                   strFName = strFName & LCase$(Mid$(strForename, intloop, 1))
               End If
               If (Asc(UCase$(Mid$(strForename, intloop, 1))) < 65) Or (Asc(UCase$(Mid$(strForename, intloop, 1))) > 90) Then
                  blnUcase = True
               Else
                  blnUcase = False
               End If
            Next
         End If
         strFName = Trim$(strFName)
         Heap act, id, "psoForename", RtrimGetField(rs!forename), 0  '23Apr14 TH Reverted (was formerly truncated as per below)
         Heap act, id, "psolblForename", strFName, 0   '23Apr14 TH Added
         Heap act, id, "psoSurname", UCase$(RtrimGetField(rs!surname)), 0
         'Heap act, id, "psoDOB", RtrimGetField(rs!dob), 0
         
         '22Mar13 TH (TFS 59559)
         strDOB = ""
         parsedate RtrimGetField(rs!dob), strDOB, "1", valid '26Mar13 TH Changed format from 3 to 1
         If Not valid Then strDOB = ""
         '---
         
         'Heap act, id, "psoDOB", Format$(RtrimGetField(rs!dob), "dd/mm/yyyy"), 0  '21Mar13 TH Change date formats (TFS 59487)
         Heap act, id, "psoDOB", strDOB, 0  '22Mar13 TH (TFS 59559)
         If strDOB <> "" Then strDOB = "(" & strDOB & ")" '22Mar13 TH (TFS 59559)
         'Heap act, id, "psoNameDOB", RtrimGetField(rs!surname) & ", " & RtrimGetField(rs!forename) & " (" & Format$(RtrimGetField(rs!dob), "dd/mmm/yyyy") & ")", 0
         'Heap act, id, "psoNameDOB", RtrimGetField(rs!surname) & ", " & strFName & " (" & Format$(RtrimGetField(rs!dob), "dd/mm/yyyy") & ")", 0 '21Mar13 TH Change date formats (TFS 59487)
         Heap act, id, "psoNameDOB", RtrimGetField(rs!surname) & ", " & strFName & " " & strDOB, 0 '22Mar13 TH Remove DOB if not added (TFS 59559)
         Heap act, id, "psoAge", RtrimGetField(rs!Age), 0
         Heap act, id, "psoSex", RtrimGetField(rs!sex), 0
         Heap act, id, "psoRxDesc", RtrimGetField(rs!RxDesc), 0
         'Heap act, id, "psolblText", plingparse(RtrimGetField(rs!lbltext), "!"), 0 '27Aug14 TH Added plingparse (TFS 98741)
         strLabelTxt = RtrimGetField(rs!lbltext)
         replace strLabelTxt, "!", " ", 0
         replace strLabelTxt, Chr(30), " ", 0
         replace strLabelTxt, crlf, " ", 0
         Heap act, id, "psolblText", strLabelTxt, 0 '27Aug14 TH Added plingparse (TFS 98741)
         Heap act, id, "psorxStart", RtrimGetField(rs!rxStart), 0
         'XML Dates for hub integration
         strDatexml = ""
         parsedate RtrimGetField(rs!dob), strDatexml, "ccyy-mm-dd", valid
         If Not valid Then strDatexml = ""
         Heap act, id, "psoDOBxml", strDatexml, 0
         
         strDatexml = ""
         If Len(RtrimGetField(rs!rxStart)) > 10 Then strDatexml = Left$(RtrimGetField(rs!rxStart), 10)
         parsedate strDatexml, strDatexml, "ccyy-mm-dd", valid
         If Not valid Then strDatexml = ""
         Heap act, id, "psorxStartxml", strDatexml, 0
         
         strDatexml = ""
         If Len(RtrimGetField(rs!rxStop)) > 10 Then strDatexml = Left$(RtrimGetField(rs!rxStop), 10)
         parsedate strDatexml, strDatexml, "ccyy-mm-dd", valid
         If Not valid Then strDatexml = ""
         Heap act, id, "psorxStopxml", strDatexml, 0
         Heap act, id, "psorxStop", Iff(RtrimGetField(rs!rxStop) = 0, "", RtrimGetField(rs!rxStop)), 0
         Heap act, id, "psoIssType", RtrimGetField(rs!IssType), 0
         Heap act, id, "psoCons", RtrimGetField(rs!ConsCode), 0
         Heap act, id, "psoConsExp", RtrimGetField(rs!constitle) & " " & RtrimGetField(rs!consforename) & " " & RtrimGetField(rs!conssurname), 0
         'Heap act, id, "psoSpec", RtrimGetField(rs!Spec), 0
         Heap act, id, "psoWard", RtrimGetField(rs!ward), 0
         Heap act, id, "psoWardExp", RtrimGetField(rs!wardname), 0
         Heap act, id, "psoAdd1", RtrimGetField(rs!Address1), 0
         Heap act, id, "psoAdd2", RtrimGetField(rs!Address2), 0
         Heap act, id, "psoAdd3", RtrimGetField(rs!Address3), 0
         Heap act, id, "psoAdd4", RtrimGetField(rs!Address4), 0
         Heap act, id, "psoAddress", RtrimGetField(rs!Address1) & " " & RtrimGetField(rs!Address2) & " " & RtrimGetField(rs!Address3) & " " & RtrimGetField(rs!Address4), 0
         Heap act, id, "psoPostCode", RtrimGetField(rs!PostCode), 0
         Heap act, id, "psoNHNumber", RtrimGetField(rs!HealthCareNumber), 0
         Heap act, id, "psoNHNumberValid", RtrimGetField(rs!HealthCareNumberValid), 0
         Heap act, id, "psoCasenumber", RtrimGetField(rs!Casenumber), 0
         Heap act, id, "psoInfo", RtrimGetField(rs!PSOInfo), 0
         Heap act, id, "psoEpisodeID", RtrimGetField(rs!EpisodeID), 0
         Heap act, id, "psorxID", RtrimGetField(rs!rxID), 0
         Heap act, id, "psospecialty", RtrimGetField(rs!specialty), 0
         success = True
      End If
   
      rs.Close
      Set rs = Nothing
   End If
   

End Sub
Sub ClearHeapPSOrderInfo(ByVal HeapID As Integer)
'15Aug12 TH Written

   Heap 10, HeapID, "psoForename", "", 0
   Heap 10, HeapID, "psoSurname", "", 0
   Heap 10, HeapID, "psoDOB", "", 0
   Heap 10, HeapID, "psoNameDOB", "", 0
   Heap 10, HeapID, "psoAge", "", 0
   Heap 10, HeapID, "psoSex", "", 0
   Heap 10, HeapID, "psoRxDesc", "", 0
   Heap 10, HeapID, "psolblText", "", 0
   Heap 10, HeapID, "psorxStart", "", 0
   Heap 10, HeapID, "psorxStop", "", 0
   Heap 10, HeapID, "psoIssType", "", 0
   Heap 10, HeapID, "psoCons", "", 0
   Heap 10, HeapID, "psoSpec", "", 0
   Heap 10, HeapID, "psoWard", "", 0
   Heap 10, HeapID, "psoAdd1", "", 0
   Heap 10, HeapID, "psoAdd2", "", 0
   Heap 10, HeapID, "psoAdd3", "", 0
   Heap 10, HeapID, "psoAdd4", "", 0
   Heap 10, HeapID, "psoInfo", "", 0
   Heap 10, HeapID, "psoPostCode", "", 0
   Heap 10, HeapID, "psoNHNumber", "", 0
   Heap 10, HeapID, "psoNHNumberValid", "", 0
   Heap 10, HeapID, "psoCasenumber", "", 0
   Heap 10, HeapID, "psoInfo", "", 0
   Heap 10, HeapID, "psoEpisodeID", "", 0
   Heap 10, HeapID, "psorxID", "", 0
   Heap 10, HeapID, "psoWardExp", "", 0
   Heap 10, HeapID, "psoConsExp", "", 0

End Sub
Sub TranslogPSOrderInfo(ByVal WOrderID As Long, ByVal blnClear As Boolean)
'03Sep12 TH Written
'13Nov12 TH Ensure the NH Number is Unformatted for the log (TFS 49019)
Dim strParams As String
Dim rs As ADODB.Recordset

   If blnClear Then
      gTlogCaseno$ = ""
      setNHNumberData "", 0
      gTlogEpisode = 0
      gRequestID_Prescription = 0
      gTlogSpecialty$ = ""
   Else
      'Get the data
      strParams = gTransport.CreateInputParameterXML("WorderID", trnDataTypeint, 4, WOrderID)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPSOInfobyWorderID", strParams)
      
      If Not rs.EOF Then
         rs.MoveFirst
         'then fill the heap
         gTlogCaseno$ = RtrimGetField(rs!Casenumber)
         'setNHNumberData RtrimGetField(rs!HealthCareNumber), Val(RtrimGetField(rs!HealthCareNumberValid))
         setNHNumberData RtrimGetField(rs!HealthCareNumberUnformatted), Val(RtrimGetField(rs!HealthCareNumberValid))
         gTlogEpisode = RtrimGetField(rs!EpisodeID)
         gRequestID_Prescription = RtrimGetField(rs!rxID)
         gTlogSpecialty$ = RtrimGetField(rs!specialty)
      End If
   
      rs.Close
      Set rs = Nothing
   End If
   
   

End Sub

Sub FillHeapeHubInfo(ByVal HeapID As Integer, ByVal WOrderID As Long, ByVal str_eHubsp As String, ByRef success As Integer)
'03Mar14 TH Written for eHub integration project


Dim strParams As String
Dim rs As ADODB.Recordset


   
      'ClearHeapPSOrderInfo id
      'Get the data
      strParams = gTransport.CreateInputParameterXML("WorderID", trnDataTypeint, 4, WOrderID)
      'If Edittype > 3 Then
      '   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPSOInfobyWReconcilID", strParams)
      'Else
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, str_eHubsp, strParams)
      'End If
      If Not rs.EOF Then
         rs.MoveFirst
         'then fill the heap directly from the sp
         CastRecordsetToHeap rs, HeapID, True
         success = True
      End If
   
      rs.Close
      Set rs = Nothing
   
   

End Sub
Function IsExtraLabel() As Boolean
'25Jun14 TH Stubbage
IsExtraLabel = False
End Function
