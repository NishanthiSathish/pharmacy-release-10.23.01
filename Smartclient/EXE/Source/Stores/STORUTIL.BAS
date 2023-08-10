Attribute VB_Name = "Storutil"
'DOStoWIN V1.0 (c) ASCribe 1996
'                            Ordering Program Utilities
'03Oct06 TH BelowDangerLevel: Factor Overdue into return criteria - was missed from original port (SC-06-0900)#
'09Sep08 TH large merge from v8 (with supporting code for list view) for enhanced ROQROL (F0026641)
'21Nov08 TH Enhanced subclassing to handle forecolor change on list view
'28Apr09 TH DoEOPCalcs: This was not merged previously :16Jan07 PJC Now checks on blnRTfReport flag for locking. (RR enh) - this means it locks huge swathes of the drug fiel for the
'           New ROQROL preview screen and worse than that it then did not clear the locks afterwards
'09Apr10 XN F0068649 EDI orders have seprate max number of lines per an order
'14Apr10 TH OrderingUtils: Added (F0056463)
'14Apr10 TH UpdateDefaultsInfo: Ported 31Aug05 PJC Added (F0056463)
'14Apr10 TH AmendDefaults: Ported and altered indexes   '31Aug05 PJC Added Reconciliation Threshold (F0056463)
'26Apr10 XN F0058248 Added progress bar updates
'17May10 TH UpdateDefaultsInfo,OrderingUtils: Removed suffix on NSVReconciliation setting - this was never being read back so effectively the editor couldnt be used (F0074613)
'16Jun10 XN Added completed message to end of update annual usage progress (F0058248)
'29Sep10 TH EnhancedRoqAndRol: Now do not continue if user cancels on first option box (F0097340)
'02Nov10 AJK OrderingUtils: F0086901 Added date invoiced to OrderLog calls
'02Jun11 CKJ TgSetMarqueeColor: unused, removed
'            TgSetSelectedLineColor: removed proc & all references to it. Was called but had no active lines.
'17Jun11 CKJ Set DefBool instead of defInt, revealing undefined param;
'            OrderingUtils: Added as integer to param sitepaths
'26Sep12 TH  Logviewer: Added P as valid char for PN Edit log (TFS 45179 )
'15Nov13 XN  WriteRoqAndRolLabutils: Moved labutils.log to WPharmacyLog table 56701
'26Jun14 TH  PrintRoqAndRol: Changed progressbar min value as was invalid max value on this if only 1 item in array (TFS 94282)
'07Apr16 XN  LogViewer: Removed (S)tock maintenance and (N)egative stock lookup options as moved to DB (123082)
'06Dec16 TH  ExportRoqandRol: Refactored RTF Handling (TFS 157969)
'06Dec16 TH  PrintOrderReports: Refactored RTF Handling (TFS 157969)
'06Dec16 TH  PrintRoqAndRol: Refactored RTF Handling (TFS 157969)
'05Jan17 TH  PrintRoqAndRol: Moved line from below to utilise check (Hosted) (TFS 157969)
'07Jan17 TH  PrintRoqAndRol: Replaced checks for DB only (Hosted) (TFS 157969)
'17May17 TH  ExportRoqandRol: Enable template files to be hosted (TFS 174881)


DefBool A-Z
Option Explicit

Const modulename$ = "STORUTIL.BAS"

Dim RoqAndRolLines() As Long '21Apr08 TH Merge from v8

Dim ord As orderstruct       '{SP2} This should not be needed here

'09Sep08 TH Added - large amount of code used form coding website to allow background color change of individual row in list view.

' bas module code
' hook system and color the backcolor of rows different colors
' as with hooking if you unload using the stop button of Visual Basic
' and you don't use the unloadquerry (the X on the form)
' then windows will crash
'
  
    Public Const GWL_EXSTYLE = -20
    Public Const GWL_HINSTANCE = -6
    Public Const GWL_HWNDPARENT = -8
    Public Const GWL_USERDATA = -21
    Public Const GWL_WNDPROC = -4
    Public Const DWL_DLGPROC = 4
    Public Const DWL_MSGRESULT = 0
    Public Const DWL_USER = 8

    Public Const NM_CUSTOMDRAW = (-12&)
    Public Const WM_NOTIFY As Long = &H4E&
    Public Const CDDS_PREPAINT As Long = &H1&
    Public Const CDRF_NOTIFYITEMDRAW As Long = &H20&
    Public Const CDDS_ITEM As Long = &H10000
    Public Const CDDS_ITEMPREPAINT As Long = CDDS_ITEM Or CDDS_PREPAINT
    Public Const CDRF_NEWFONT As Long = &H2&
    Public Const CDDS_SUBITEM = &H20000
    
  Public Type NMHDR
    hWndFrom As Long   ' Window handle of control sending message
    idFrom As Long        ' Identifier of control sending message
    Code  As Long          ' Specifies the notification code
  End Type
   
  ' sub struct of the NMCUSTOMDRAW struct
  Public Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
  End Type
   
  ' generic customdraw struct
  Public Type NMCUSTOMDRAW
    hdr As NMHDR
    dwDrawStage As Long
    hdc As Long
    rc As RECT
    dwItemSpec As Long
    uItemState As Long
    lItemlParam As Long
  End Type
  
  '21Nov08 TH Added
  Public Type TwoLongs
   lngForeColor As Long
   lngBackColor As Long
   End Type

  ' listview specific customdraw struct
  Public Type NMLVCUSTOMDRAW
    nmcd As NMCUSTOMDRAW
    clrText As Long
    clrTextBk As Long
    ' if IE >= 4.0 this member of the struct can be used
    'iSubItem As Integer
  End Type

  Public g_addProcOld As Long
  Public g_MaxItems As Long
  'Public clr() As Long    '21Nov08 TH Removed
  Public clr() As TwoLongs '21Nov08 TH Added

Public Declare Function SetWindowLong Lib "user32.dll" Alias _
"SetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long, _
ByVal dwNewLong As Long) As Long

  
 Public Declare Sub CopyMemory Lib "kernel32.dll" Alias "RtlMoveMemory" _
  (Destination As Any, Source As Any, ByVal length As Long)
  

Public Function WindowProc(ByVal Hwnd As Long, _
ByVal iMsg As Long, ByVal wParam As Long, _
ByVal lParam As Long) As Long
'09Sep08 TH Added - from coding website to allow background color change of individual row in list view.

  Select Case iMsg
    Case WM_NOTIFY
      Dim udtNMHDR As NMHDR
      CopyMemory udtNMHDR, ByVal lParam, 12&
      
      With udtNMHDR
         If .Code = NM_CUSTOMDRAW Then
            Dim udtNMLVCUSTOMDRAW As NMLVCUSTOMDRAW
            CopyMemory udtNMLVCUSTOMDRAW, ByVal lParam, Len(udtNMLVCUSTOMDRAW)
            With udtNMLVCUSTOMDRAW.nmcd
               Select Case .dwDrawStage
                  Case CDDS_PREPAINT
                     WindowProc = CDRF_NOTIFYITEMDRAW
                     Exit Function
                  '21Nov08 TH Replaced with block below
                 ' Case CDDS_ITEMPREPAINT
''                     If clr(.dwItemSpec) <> 0 Then
''                         'change the color of the text display if wanted
''                         'udtNMLVCUSTOMDRAW.clrText = vbBlue
''                         udtNMLVCUSTOMDRAW.clrTextBk = clr(.dwItemSpec)
''                         CopyMemory ByVal lParam, udtNMLVCUSTOMDRAW, Len(udtNMLVCUSTOMDRAW)
''                     End If
''                     WindowProc = CDRF_NEWFONT
''                     Exit Function
                  Case (CDDS_ITEMPREPAINT Or CDDS_SUBITEM)
                     'FORECOLOR
                     If clr(.dwItemSpec).lngForeColor <> 0 Then
                     udtNMLVCUSTOMDRAW.clrText = clr(.dwItemSpec).lngForeColor
                     ' udtNMLVCUSTOMDRAW.iSubItem = 2
                     CopyMemory ByVal lParam, udtNMLVCUSTOMDRAW, Len(udtNMLVCUSTOMDRAW)
                     End If
                     'BACKCOLOR
                     If clr(.dwItemSpec).lngBackColor <> 0 Then
                     udtNMLVCUSTOMDRAW.clrTextBk = clr(.dwItemSpec).lngBackColor
                     ' udtNMLVCUSTOMDRAW.iSubItem = 2
                     CopyMemory ByVal lParam, udtNMLVCUSTOMDRAW, Len(udtNMLVCUSTOMDRAW)
                     End If
                     WindowProc = CDRF_NEWFONT
                     Exit Function
               End Select
            End With
         End If
      End With
  End Select
  WindowProc = CallWindowProc(g_addProcOld, Hwnd, iMsg, wParam, lParam)
End Function

Public Sub SetLIBackColor(lv As ListView, nitem As Integer, BkColor As Long)
'09Sep08 TH Added - from coding website to allow background color change of individual row in list view.
'21Nov08 TH Enhaced to handle forecolor
   clr(nitem - 1).lngBackColor = BkColor
   lv.Refresh
End Sub

Public Sub SetLIForeColor(lv As ListView, nitem As Integer, ForeColor As Long)
'09Sep08 TH Added - from coding website to allow background color change of individual row in list view.
'21Nov08 TH Enhaced to handle forecolor
   clr(nitem - 1).lngForeColor = ForeColor
   lv.Refresh
End Sub

Sub negstock(filno%, numprinted%)

Dim temp$, desc$
Dim strParameters As String
Dim rsNegStock As ADODB.Recordset
Dim intpage As Integer
Dim intNum As Integer


   intpage = Val(TxtD(dispdata$ & "\winord.ini", "defaults", "60", "NegStockLines", 0))
   intNum = 6 'compensate for header on first page
   
   numprinted = 0
   UpdateBar 0, 0, 0, 0
    
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsNegStock = gTransport.ExecuteSelectSP(g_SessionID, "pWProductNegStock", strParameters)
   If rsNegStock.RecordCount > 0 Then
      Do While Not rsNegStock.EOF
         UpdateBar 0, (rsNegStock.RecordCount), (numprinted), ProgressBarScale
         desc$ = GetField(rsNegStock!Description) ' desc$ = RSGetStoresDescription(rsNegStock)  XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         temp$ = GetField(rsNegStock!SisCode) & " " & desc$ + GetField(rsNegStock!stocklvl) & " " & GetField(rsNegStock!PrintformV) & "[cr]" '11Dec98 TH Added NSV Code to report
         intNum = intNum + 1
         If intNum > intpage Then
            intNum = 1
            temp$ = temp$ & "[FF][CR]"
         End If
         
         PrinterParse temp$
         Put #filno, , temp$
         numprinted = numprinted + 1
         rsNegStock.MoveNext
      Loop
   End If
   rsNegStock.Close
   Set rsNegStock = Nothing

End Sub


Sub OrderingUtils(sitepaths As Integer, ans$, finished%)

'17May10 TH Removed suffix for NSVReconcilliation as this was never read back out. (F0074613)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'17Jun11 CKJ Added as integer to param sitepaths


Dim Ordno$, dat$, site$, hdr$, msg$, cycle$, cyclelength$
Dim edtype%, foundPtr&, nod&, F&, fs%, orddatchan%, vatchan% 'orderno%,
Dim loopvar%
Dim pointer&, X&
Dim lngOrderno As Long
Dim rsORderCycleProducts As ADODB.Recordset
Dim strParams As String
Dim strFile As String

   strFile = "\workingdefaults"
    
   ChangeTable "Blank", False '14Aug12 TH Added Param
   MainScreen.LblGrid.Caption = ""
   PositionLblGrid
    
   Select Case ans$
      Case "1"
           PrintOrderReports Val(ans$)

      Case "2"
           MainScreen.FrmGauge.Visible = True
           MainScreen.Progress.Visible = True
           MainScreen.Progress.Value = 0
           PrintOrderReports Val(ans$)
   
      Case "3"
           MainScreen.FrmGauge.Visible = True
           MainScreen.Progress.Visible = True
           MainScreen.Progress.Value = 0
           PrintOrderReports Val(ans$)
   
      Case "4"
         
         AmendSuppliers True, "", 0
   
      Case "5"
         amenddefaults
         If Trim$(Ques.Tag) = "-1" Then
            k.escd = False
         Else
            ans$ = "Y"
            Confirm "Escaped", "exit without saving", ans$, k
            If ans$ = "Y" Then
               k.escd = True
               ans$ = ""
            Else
               k.escd = False
            End If
         End If
          
         If Not k.escd Then
            updatedefaultsinfo Ordno$
            getorderno 1, lngOrderno, 0
            If Val(Ordno$) >= lngOrderno Then
               lngOrderno = Val(Ordno$)
               getorderno 1, lngOrderno, 2
            Else
               popmessagecr "INVALID", "No changes made: CANNOT decrease order number"
               k.escd = True
            End If
         End If
    
         If Not k.escd Then
            GoSub saveorddata
            GoSub savevatrates
         Else
            ReadOrdData
         End If
    
         Unload Ques
    
      Case "6"
         MainScreen.FrmGauge.Caption = "Calculating..."
         'PrintOrderReports 4
         EnhancedRoqAndRol '09Sep08 TH Merge
         
      Case "7"
         popmessagecr "!n!bREQUIRES SINGLE USE OF THE SYSTEM", "Are all users logged off the system  Y/N  "
         ans$ = "N"
         If ans$ = "Y" Then finished = 1
   
      Case "8"
         MainScreen.FrmGauge.Caption = "Processing..."
         edtype = 1
         getnumofords edtype, pointer&, False
         UpdateBar 0, 0, 0, 0
         For X& = 2 To pointer&
            UpdateBar 2, (pointer&), (X&), ProgressBarScale
            getorder ord, X&, edtype, False
            If ord.status = "2" Then
               dat$ = thedate(False, True)
               LookupDrug ord.Code, d, 0
               'Orderlog ord.num, ord.Code, UserID$, ord.orddate, dat$ & thedate(0, -2), ord.qtyordered, "0", "", ord.supcode, "N", sitepaths, "", d.vatrate, "", "", "" '    "
               'Orderlog ord.num, ord.Code, UserID$, ord.orddate, dat$ & thedate(0, -2), ord.qtyordered, "0", "", ord.supcode, "N", sitepaths, "", d.vatrate, "", "", "", ""   '02Nov10 AJK F0086901 Added paydate
               Orderlog ord.num, ord.Code, UserID$, ord.orddate, dat$ & thedate(0, -2), ord.qtyordered, "0", "", ord.supcode, "N", sitepaths, "", d.vatrate, "", "", "", "", ord.PSORequestID '02Mar14 TH Added PSORequestID
               getorder ord, X&, edtype, True
               ord.orddate = ""
               ord.num = ""
               ord.status = "1"
               ord.internalmethod = ""
               ord.internalsiteno = ""
               X& = PutOrder(ord, X&, "WOrder")
            End If
         Next
    
      Case "9"
         site$ = ""
         k.escd = False
         setinput 0, k
         asksupplier site$, 0, "SE", "Enter Supplier Code", False, sup, False '15Nov12 TH Added PSO param
         
         If Not k.escd Then
            hdr$ = ""
            msg$ = "Enter order cycle number"
            k.Max = 2
            k.min = 1
            cycle$ = ""
            InputWin hdr$, msg$, cycle$, k
         End If
         If Not k.escd Then
            hdr$ = ""
            msg$ = "Enter order days between ordering"
            k.Max = 3
            k.min = 1
            InputWin hdr$, msg$, cyclelength$, k
         End If
         If Not k.escd Then
            Screen.MousePointer = HOURGLASS
            MainScreen.FrmGauge.Caption = "Processing Order Cycles..."
            MainScreen.Progress.Visible = True
            ''SQL getnod nod
            F = 0
            fs = 0
            UpdateBar 0, 0, 0, 0
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                         gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, site$)
            Set rsORderCycleProducts = gTransport.ExecuteSelectSP(g_SessionID, "pWProductbySupCodeforOrderCycle", strParams)
            If rsORderCycleProducts.RecordCount > 0 Then
            Do While Not rsORderCycleProducts.EOF
               F = F + 1
               UpdateBar 0, (rsORderCycleProducts.RecordCount), (F), ProgressBarScale
               ''getdrug d, F&, foundPtr&, False
               ''If UCase$(d.supcode) = UCase$(Left$(site$ + Space$(5), 5)) Then
                  getdrug d, GetField(rsORderCycleProducts!productstockID), foundPtr&, True
                  If foundPtr& > 0 Then
                     d.ordercycle = LTrim$(cycle$)
                     d.cyclelength = Val(cyclelength$)
                     fs = fs + 1
                     putdrug d  '', foundPtr&
                  End If
              '' End If
               rsORderCycleProducts.MoveNext
            Loop ''Until F >= nod
            End If
            msg$ = "Processed " & Str$(rsORderCycleProducts.RecordCount) & " drugs" & Chr$(13) & Chr$(13)
            msg$ = msg$ & "Updated order cycle information for " + Str$(fs) + " drugs."
            rsORderCycleProducts.Close
            Set rsORderCycleProducts = Nothing
            Screen.MousePointer = STDCURSOR
            popmessagecr "", msg$
         End If
          
         Screen.MousePointer = STDCURSOR
    
       Case "10"
          GoSub editdefaults
          GoSub savevatrates
          
       End Select
    
    MainScreen.Progress.Visible = False
    MainScreen.FrmGauge.Visible = False
    
    Exit Sub
    
saveorddata:
''       orddatchan = FreeFile
''       Open dispdata$ + "\order.dat" For Output As #orddatchan Len = 256
''       Write #orddatchan, preprint$
''       Write #orddatchan, ordnumprefix$
''       Write #orddatchan, ownname$
''       Write #orddatchan, overdue$
''       Write #orddatchan, ordmessage$
''       Write #orddatchan, ordcontact$
''       Write #orddatchan, maxnumoflines
''       Write #orddatchan, tp$
''       Write #orddatchan, picknumoflines
''       Write #orddatchan, delreceipt
''       Write #orddatchan, delreconcile
''       Write #orddatchan, FullPageCS
''       Write #orddatchan, NSVcarriage$
''       Write #orddatchan, NSVdiscount$
''       Write #orddatchan, AskBatchNum
''       Write #orddatchan, Delrequis
''       Write #orddatchan, OrdPrintPrice
''       Write #orddatchan, OrdPrintLin
''       Write #orddatchan, ProgressBarScale
''       Write #orddatchan, PrintToScreen$
''       Write #orddatchan, PrintStockCost
''       Write #orddatchan, PrintCanceledOrder$
''       Write #orddatchan, PrintInPacks
''       Write #orddatchan, AdjCostCentre$
''       Write #orddatchan, WSStores%
''       Write #orddatchan, NSVReconciliation$
''       Write #orddatchan, EOPMargin%
''       Write #orddatchan, edimaxnumoflines
''       Close #orddatchan
''    Return
strFile = "\workingdefaults"
   WritePrivateIniFile "", "preprint", preprint$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordnumprefix", ordnumprefix$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ownname", ownname$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "overdue", overdue$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordmessage", ordmessage$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordcontact", ordcontact$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "maxnumoflines", Format$(maxnumoflines), dispdata$ & strFile, 0
   WritePrivateIniFile "", "tp", tp$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "picknumoflines", Format$(picknumoflines), dispdata$ & strFile, 0
   WritePrivateIniFile "", "delreceipt", Format$(delreceipt), dispdata$ & strFile, 0
   WritePrivateIniFile "", "delreconcile", Format$(delreconcile), dispdata$ & strFile, 0
   WritePrivateIniFile "", "FullPageCS", Format$(FullPageCS), dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVcarriage", NSVcarriage$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVdiscount", NSVdiscount$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "AskBatchNum", Format$(AskBatchNum), dispdata$ & strFile, 0
   WritePrivateIniFile "", "Delrequis", Format$(Delrequis), dispdata$ & strFile, 0
   WritePrivateIniFile "", "OrdPrintPrice", Format$(OrdPrintPrice), dispdata$ & strFile, 0
   WritePrivateIniFile "", "OrdPrintLin", Format$(OrdPrintLin), dispdata$ & strFile, 0
   WritePrivateIniFile "", "ProgressBarScale", Format$(ProgressBarScale), dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintStockCost", Format$(PrintStockCost), dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintToScreen", PrintToScreen$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintCanceledOrder", PrintCanceledOrder$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintInPacks", Format$(PrintInPacks), dispdata$ & strFile, 0
   WritePrivateIniFile "", "AdjCostCentre", AdjCostCentre$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "WSStores", Format$(WSStores%), dispdata$ & strFile, 0
   'WritePrivateIniFile "", "NSVReconciliation$", NSVReconciliation$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVReconciliation", NSVReconciliation$, dispdata$ & strFile, 0  '17May10 TH Removed suffix (F0074613)
   WritePrivateIniFile "", "EOPMargin", Format$(EOPMargin%), dispdata$ & strFile, 0
   WritePrivateIniFile "", "edimaxnumoflines", Format$(edimaxnumoflines), dispdata$ & strFile, 0    ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
   WritePrivateIniFile "", "ReconcilThresholdVal", ReconcilThresholdVal$, dispdata$ & strFile, 0  '14Apr10 TH Added (F0056463)
   Return
    
editdefaults:
    '----VAT default editor----
    '17 Jan 92 ASC
    '25Jan94 CKJ Added pseudofields
    '10Feb94 CKJ Added AskBatchNum
    
    '   pickwindow 23, 53, "!n!iSystem Defaults - System Manager Only", 4
    '   k.helpnum = 0
    '   printwcr ""
    '   printw "   Add VAT to issue transactions (Y/N)     "
    '   If TransLogVAT Then ans$ = "Y" Else ans$ = "N"
    '   getyesornocr ans$, k
    '   If Not k.escd Then TransLogVAT = (ans$ = "Y")
    '
    '   printwcr ""
    '   printw "   Add VAT to receipt transactions (Y/N)   "
    '   If OrderLogVAT Then ans$ = "Y" Else ans$ = "N"
    '   k.helpnum = 0
     '  getyesornocr ans$, k
     ''  If Not k.escd Then OrderLogVAT = (ans$ = "Y")
     '
     '  printwcr ""
     '  printw "   % Above allowed for reconciliation      "
     '  k.max = 6
     '  k.decimals = True
      ' k.helpnum = 0
      ' ans$ = LTrim$(Str$((Highfact! - 1) * 100))
    '   inputline ans$, k
    '   If Not k.escd Then Highfact! = 1 + (Val(ans$) / 100)
    '
    '   printwcr ""
    '   printw "   % Below allowed for reconciliation      "
    '   k.max = 6
    '   k.decimals = True
    '   k.helpnum = 0
    '   ans$ = LTrim$(Str$((1 - Lowfact!) * 100))
    '   inputline ans$, k
    '   If Not k.escd Then Lowfact! = 1 - (Val(ans$) / 100)
    '
    '   printwcr ""
    '   printw "   Check prices and amend on receipt       "
    '   ans$ = entercostonreceipt$
    '   k.helpnum = 0
    '   getyesornocr ans$, k
    '   If Not k.escd Then entercostonreceipt$ = ans$
    '
    '   printwcr ""
    '   printw "   Print 'to follows' on picking ticket    "
    '   xpos = POS(0) - 1
    '   If tofollow Then ans$ = "Y" Else ans$ = "N"
    '   k.helpnum = 0
    '   getyesornocr ans$, k
    '   If Not k.escd Then tofollow = (ans$ = "Y")
    '
    '   printwcr ""
    '   For x = 0 To 9
    '      If VAT(x) = 0 Then VAT(x) = 1
    '      printwcr ""
    '      printw "   VAT rate"
    '      Print x; Space$(15);
    '      ans$ = LTrim$(Str$(VAT(x)))
    '      k.max = 5
    '      k.decimals = True
    '      k.helpnum = 0
    '      inputline ans$, k
    '      If Not k.escd Then VAT(x) = Val(ans$)
    '      LOCATE , xpos
    '      Print (VAT(x) - 1) * 100; "%";
    '   Next
    '
    '   printwcr ""
    '   printwcr ""
    '   printw "   Pseudo order number for drug editing    "
    '   k.helpnum = 0
    '   k.nums = True
    '   k.max = 4
    '   k.min = 4
    '   ans$ = UtilOrdNum$
    '   If trim$(ans$) = "" Then ans$ = "0000"
    '   inputline ans$, k
    '   If Not k.escd Then UtilOrdNum$ = ans$
    '
    '   printwcr ""
    '   printw "   Pseudo supplier code for drug editing   "
    '   k.helpnum = 0
    '   k.max = 5
    '   k.min = 0
    '   ans$ = UtilSupplier$
    '   inputline ans$, k
    '   If Not k.escd Then UtilSupplier$ = UCase$(ans$)
    '
    '   printwcr ""
    '   printw "   Reason code when creating a new drug    "
    '   k.helpnum = 0
    '   k.max = 2
    '   k.min = 0
    '   ans$ = UtilReasonNew$
    '   inputline ans$, k
    '   If Not k.escd Then UtilReasonNew$ = UCase$(ans$)
    '
    '   printwcr ""
    '   printw "   Reason code when amending a drug        "
    '   k.helpnum = 0
    '   k.max = 2
    '   k.min = 0
    '   ans$ = UtilReasonMod$
    '   inputline ans$, k
    '   If Not k.escd Then UtilReasonMod$ = UCase$(ans$)
    '
    '   closewindow
    Return
    
    '-----------------------------------------------------------------------------
savevatrates:
'ASC 16.01.92 Save VAT defaults
'25Jan94 CKJ Added pseudo codes
   'vatchan = FreeFile
   'Open dispdata$ + "\storevat.def" For Output As #vatchan
''   Print #vatchan, TransLogVAT
''   Print #vatchan, OrderLogVAT
''   Print #vatchan, Highfact!
''   Print #vatchan, Lowfact!
''   Print #vatchan, entercostonreceipt$
''   Print #vatchan, tofollow%
''   For loopvar = 0 To 9
''      Print #vatchan, VAT(loopvar)
''   Next loopvar
''   Print #vatchan, UtilOrdNum$
''   Print #vatchan, UtilSupplier$
''   Print #vatchan, UtilReasonNew$
''   Print #vatchan, UtilReasonMod$
   'Close #vatchan
   WritePrivateIniFile "", "TransLogVAT", Format$(TransLogVAT), dispdata$ & strFile, 0
   WritePrivateIniFile "", "OrderLogVAT", Format$(OrderLogVAT), dispdata$ & strFile, 0
   WritePrivateIniFile "", "Highfact", Format$(Highfact!), dispdata$ & strFile, 0
   WritePrivateIniFile "", "Lowfact", Format$(Lowfact!), dispdata$ & strFile, 0
   WritePrivateIniFile "", "entercostonreceipt", entercostonreceipt$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "tofollow%", Format$(tofollow%), dispdata$ & strFile, 0
   For loopvar = 0 To 9
      WritePrivateIniFile "", "VAT(" & Format$(loopvar) & ")", Format$(VAT(loopvar)), dispdata$ & strFile, 0
   Next
   WritePrivateIniFile "", "UtilOrdNum", UtilOrdNum$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "UtilSupplier", UtilSupplier$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "UtilReasonNew", UtilReasonNew$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "UtilReasonMod", UtilReasonMod$, dispdata$ & strFile, 0
   
Return

End Sub

Sub CheckWorkingDefaults(Index%, msg$, NewIndex%)
'19Feb98 EAC Added VAT percentages in LblInfo
'21Dec98 CFY Removed checks that are carried out on the batch number/expiry field as this is now
'            redundant in working defaults

   Select Case Index
      Case 0
         If Trim$(Ques.txtQ(3).text) = "" Then
               msg$ = msg$ & "Please specify the Supplier code for this site.[cr]"
               If NewIndex = 0 Then NewIndex = 3
            End If

         If Trim$(Ques.txtQ(6).text) = "" Then
               msg$ = msg$ & "Please specify whether or not to use preprint stationary for this site.[cr]"
               If NewIndex = 0 Then NewIndex = 6
            End If

         If (Val(Ques.txtQ(9).text) > 0) And (Val(Ques.txtQ(10).text) > 0) Then
               msg$ = msg$ & "No. of days for deletion after payment date and No. of days after receipt are mutally exclusive.[cr]Please set one of them to be zero days.[cr]"
               If NewIndex = 0 Then NewIndex = 9
            End If

         If Trim$(Ques.txtQ(13).text) = "" Then
               msg$ = msg$ & "Please specify whether or not to use one page per Finance coding slip.[cr]"
               If NewIndex = 0 Then NewIndex = 13
            End If

         'If Trim$(Ques.txtQ(14).Text) = "" Then
         '         msg$ = msg$ & "Please specify the pseudo NSV code for carriage costs at this site." & Chr$(13)
         '         Ques.Tag = ""
         '         If newindex = 0 Then newindex = 14
         '   End If

         'If Trim$(Ques.txtQ(15).Text) = "" Then
         '         msg$ = msg$ & "Please specify the pseudo NSV code for discounts at this site." & Chr$(13)
         '         Ques.Tag = ""
         '         If newindex = 0 Then newindex = 15
         '   End If

         'If Trim$(Ques.txtQ(16).Text) = "" Then                                                                                '21Dec98 CFY Removed
         '         msg$ = msg$ & "Please specify if expiry date and batch numbers will be entered for this site." & Chr$(13)    '         "
         '         Ques.Tag = ""                                                                                                '         "
         '         If newindex = 0 Then newindex = 16                                                                           '         "
         '   End If                                                                                                             '         "

         If Trim$(Ques.txtQ(17).text) = "" Then
               msg$ = msg$ & "Please specify if prices are printed on orders for this site.[cr]"
               If NewIndex = 0 Then NewIndex = 17
            End If

         If Trim$(Ques.txtQ(18).text) = "" Then
               msg$ = msg$ & "Please specify if blank lines will be printed between items for this site.[cr]"
               If NewIndex = 0 Then NewIndex = 18
            End If

         If Trim$(Ques.txtQ(19).text) = "" Then
               msg$ = msg$ & "Please specify if VAT will be added to issue transactions for this site.[cr]"
               If NewIndex = 0 Then NewIndex = 19
            End If
            
         If Trim$(Ques.txtQ(23).text) = "" Then
            msg$ = msg$ & "Please specify if prices will be amended on receipt for this site.[cr]"
            If NewIndex = 0 Then NewIndex = 23
         End If

         If Val(Ques.txtQ(42).text) < 1 Or Val(Ques.txtQ(43).text) > 50 Then
               msg$ = msg$ & "Progress Bar granularity must be between 1 and 50[cr]"
               If NewIndex = 0 Then NewIndex = 43
            End If

         If Trim$(Ques.txtQ(43).text) = "" Then
               msg$ = msg$ & "Please specify if printer output is to be redirect to the screen.[cr]"
               If NewIndex = 0 Then NewIndex = 44
            End If

         If Trim$(Ques.txtQ(44).text) = "" Then
               msg$ = msg$ & "Please specify if costs will be printed on Ward Stock Labels.[cr]"
               If NewIndex = 0 Then NewIndex = 45
            End If

         If Trim$(Ques.txtQ(45).text) = "" Then
               msg$ = msg$ & "Please specify if confirmation of Order cancellations is required.[cr]"
               If NewIndex = 0 Then NewIndex = 46
            End If
            
        ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
        If Val(Ques.txtQ(50).text) < 1 Then
                msg$ = msg$ & "Please enter valid EDI maximum lines printed on order (min 1)."
               If NewIndex = 0 Then NewIndex = 50
        End If

         If Len(msg$) Then Ques.Tag = ""                                                                   '02apr04 CKJ don't set in every IF clause
         replace msg$, "[cr]", cr, 0                                                                       '   "

      Case 26 To 35
         Ques.lblInfo(Index).Caption = Format$(100 * (Val(Ques.txtQ(Index)) - 1)) & "%"                    '19FEb98 EAC added line

      End Select

End Sub


Sub DoEOPCalcs(filno%, numprinted%, monthend%, ForPrinting%, change%, blnRTfReport As Integer, strStocked As String, strSupplierCode As String, strLocCode As String, strSortOrder As String)
'Still TO DO
'-----------------------------------------------------------------------------
'  Calculates   1) projected annual usage
'               2) re-orderlevel
'               3) re-orderqty
'-----------------------------------------------------------------------------
'28Apr09 TH This was not merged previously :16Jan07 PJC Now checks on blnRTfReport flag for locking. (RR enh) - this means it locks huge swathes of the drug fiel for the
'           New ROQROL preview screen and worse than that it then did not clear the locks afterwards


Dim nod&, loopvar&, valid%, setroq%, setrol%     '01Jun02 ALL/ATW      foundPtr&,
Dim temp$, desc As String * 35, tmp$, dat$, tday$, yeye$
Dim ye!, LeadTime!, ndbd&, Rol&, Roq&
Dim dcopy As DrugParameters                      '04Apr04 CKJ {SP1} removes need for module level R but really should unlock
''Dim objDataAccess As clsDataAccess
Dim rsProducts As ADODB.Recordset
Dim strParams As String
Dim blnProcessRTFRoqRol As Integer               '16Jan07 PJC Added (RR enh)
Dim strLine As String                            '       "
Dim intNumberForRoqRol As Integer                '       "
Dim fil As Integer                               '       "
Dim idxlen As Integer                            '       "
Dim cont&                                        '       "
Dim found&                                       '       "
Dim intloop As Integer
Dim RoqAndRolLinestemp() As Long
   'numprinted = 0
   'UpdateBar 0, 0, 0, 0

   'MainScreen.FrmGauge.Caption = "Processing Products ..."
   Progress.lblInfo = "Processing Products ..."
   Progress.Show 0
   
   'Select all the items from this site and then cycle through them
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsProducts = gTransport.ExecuteSelectSP(g_SessionID, "pDrugsBySite", strParams)
   If Not rsProducts.EOF Then
      loopvar = 1
      
      If blnRTfReport Then                                                                                                                       '16Jan07 PJC Added. If using the RTF report then set up the index file for the sorting. (RR enh)
         'fil = FreeFile                                                                                                                       '          "
         'Open dispdata$ + "\roqrol.idx" For Binary Access Read Write Lock Read Write As #fil                                                  '          "
         Select Case strSortOrder                                                                                                             '          "
            Case "SLD"                                                                                                                        '          "
               'idxlen = 5 + 3 + 56
               rsProducts.Sort = "supcode,loccode,description"
            Case "SD"                                                                                                                         '          "
               'idxlen = 5 + 56
               rsProducts.Sort = "supcode,description"
            Case "LD"                                                                                                                         '          "
               idxlen = 3 + 56
               rsProducts.Sort = "loccode,description"
            Case Else                                                                                                                         '          "
               idxlen = 56
               rsProducts.Sort = "description"
         End Select                                                                                                                           '          "
         'idxlen = idxlen + 7                                                                                                                  '          "
         'putidxline fil, 1, idxlen, pad$(Format$(idxlen - 7), idxlen - 7), 0, False                                                           '          "
         'putidxline fil, 2, idxlen, Space$(idxlen - 7), 0, False
         
         'intNumberForRoqRol = 1
         ''ReDim RoqAndRolLines(intNumberForRoqRol, 2)
      End If                                                                                                                                  '          "

      Do While Not rsProducts.EOF
         ''UpdateBar 0, (rsProducts.RecordCount), (loopvar), ProgressBarScale
         Progress.Percent = (loopvar / (rsProducts.RecordCount)) * 100
         'getdrug d, (loopvar), 0, True 'foundPtr&, True   '<------LOCK   '01Jun02 ALL/ATW SQL NEED ROW LOCK HERE ???
         'getdrug d, RtrimGetField(rsProducts!productstockID), 0, True 'foundPtr&, True   '<------LOCK   '01Jun02 ALL/ATW SQL NEED ROW LOCK HERE ???
         getdrug d, RtrimGetField(rsProducts!productstockID), 0, (blnRTfReport = False)   '16Jan07 PJC Replaced above, now checks on blnRTfReport flag. (RR enh) '28Apr09 TH This was not merged previously - oh dear
         ''d = FillDrugFromRS(rsProducts)
         ''CastRecordsetToProduct rsProducts, d
         'SQL LOCK GETDRUG WITH LOCK !!!!
         
         If UCase$(d.recalcatperiodend) <> "N" Or TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "AnnualUsageForAllItems", 0)) = True Then
            LSet dcopy = d  'preserves if no changes required
            DoEOPAnnualUseCalc d
            'parsedate Trim$(d.datelastperiodend), dat$, "1", valid
            'tday$ = thedate(True, True)
            'datetodays dat$, tday$, ndbd&, ye!, yeye$, valid
            'If ndbd& > 20 Then
            '   If Val(d.anuse) > 1 Then
            '      d.anuse = LTrim$(Str$(1! * ((d.usethisperiod / ndbd&) * 365 * (1 - d.usagedamping)) + (Val(d.anuse) * d.usagedamping)))
            '   Else
            '      d.anuse = LTrim$(Str$(1! * (d.usethisperiod / ndbd&) * 365))
            '   End If
            '   d.datelastperiodend = thedate(False, True)
            '   d.usethisperiod = 0
            'End If
         End If
         If UCase$(d.recalcatperiodend) <> "N" Then
            If Not monthend Then
               If Val(d.anuse) > 0 Then
               
                  blnProcessRTFRoqRol = False                                                                                       '16Jan07 PJC Added (RR enh)
                  If blnRTfReport = True Then                                                                                       '            "
                     If strStocked = "" Or strStocked = Trim$(d.sisstock) Then                                                   '            "
                        If Trim$(strSupplierCode) = "A" Or UCase$(Trim$(strSupplierCode)) = UCase$(Trim$(d.supcode)) Then     '            "
                           If strLocCode = "" Or UCase$(strLocCode) = Trim$(UCase$(d.loccode)) Then                        '            "
                              blnProcessRTFRoqRol = True                                                                '            "
                           End If                                                                                       '            "
                        End If                                                                                             '            "
                     End If                                                                                                   '            "
                  End If                                                                                                         '            "

                  'If Val(d.leadtime) < 5 Then leadtime! = 5 Else leadtime! = Val(d.leadtime)
                  'rol& = (Val(d.anuse) / 365 * leadtime!) * d.safetyfactor
                  'If rol& < 1 Then rol& = 1
                  'roq& = 2 * rol& * d.safetyfactor
                  'If rol& < Val(d.convfact) Then
                  '   If Val(d.convfact) < 100 Then
                  '      rol& = Val(d.convfact)
                  '   Else
                  '      rol& = 100
                  '   End If
                  '   roq& = Val(d.convfact)
                  'End If
                  temp$ = ""
                  If Val(d.convfact) > 0 Then
                     DoEOPRoqAndRolCalc d, setroq, setrol, Roq&, Rol&
                     'setroq = False
                     'setrol = False
                     'If Int((roq& / Val(d.convfact) + 0.5)) < 1 Then roq& = Val(d.convfact)
                     'roq& = Int((roq& / Val(d.convfact) + 0.5))
                     'If (Val(d.reorderqty) < roq& * (1 - (EOPMargin% / 100))) Or (Val(d.reorderqty) > roq& * (1 + (EOPMargin% / 100))) Then   '   "
                     '      setroq = True
                     '   End If
                     'If Val(d.reorderlvl) < rol& * (1 - (EOPMargin% / 100)) Or Val(d.reorderlvl) > rol& * (1 + (EOPMargin% / 100)) Then   '25Feb00 TH Replaced with below
                     '      setrol = True                                                                                                  '   "
                     '   End If
                     If (setrol Or setroq) And ForPrinting Then
                           desc$ = Left$(d.DrugDescription, 35) ' desc$ = Left$(d.DrugDescription, 35) XN 4Jun15 98073 New local stores description
                           plingparse desc$, "!"
                           Select Case setrol                                                                                       '25Feb00 TH Replaced to ensure only those figures
                              Case -1: temp$ = desc$ + "  " + d.reorderlvl + " " + Left$(Str$(Rol&) + Space$(8), 8) + Left$(d.PrintformV + Space$(5), 5)  '   "       due to change go to the report
                              Case Else: temp$ = desc$ + Space$(24)                                                                 '   "
                           End Select                                                                                               '   "
                           Select Case setroq                                                                                       '25Feb00 TH
                              Case -1: tmp$ = "  " + Left$(d.reorderqty & Space$(6), 6) + " " + Left$(Str$(Roq&) + Space$(8), 8) + "X " + Left$(d.convfact + Space$(5), 5) & "      " + Left$(d.LeadTime + Space$(3), 3)     '25Feb00 TH
                              Case Else: tmp$ = Space$(34) + Left$(d.LeadTime + Space$(3), 3)                                                     '   "
                           End Select                                                                                               '   "
                           temp$ = temp$ & tmp$ + Left$(Str$(Int(Val(d.anuse) * 10) / 10) + Space$(8), 8) + " " + d.ordercycle + " " + Str$(d.cyclelength) & "[cr]"
                           numprinted = numprinted + 1
                        End If
                        If setroq Then d.reorderqty = LTrim$(Str$(Roq&))
                        If setrol Then d.reorderlvl = LTrim$(Str$(Rol&))
                        
                        If blnProcessRTFRoqRol = True And (setrol = True Or setroq = True) Then        '16Jan07 PJC If the product is included in the report (RR enh)
                           'Select Case strSortOrder                                                    '            and the Roq or Rol has changed then include it in the index (RR enh).
                           '   Case "SLD"                                                               '          "
                           '      strLine = d.supcode & d.loccode & d.Description                       '          "
                           '   Case "SD"                                                                '          "
                           '      strLine = d.supcode & d.Description                                   '          "
                           '   Case "LD"                                                                '          "
                           '      strLine = d.loccode & d.Description                                   '          "
                           '   Case Else                                                                '          "
                           '      strLine = d.Description                                               '          "
                           'End Select                                                                  '          "
                           'intNumberForRoqRol = intNumberForRoqRol + 1                                 '          "
                           'putidxline fil, intNumberForRoqRol + 2, idxlen, strLine, loopvar, False     '
                           On Error GoTo ERR_ROQROL
                           'If intNumberForRoqRol > 1 Then
                           intNumberForRoqRol = intNumberForRoqRol + 1
                           If intNumberForRoqRol = 1 Then
                              ReDim RoqAndRolLinestemp(intNumberForRoqRol)
                           Else
                              ReDim Preserve RoqAndRolLinestemp(intNumberForRoqRol)
                           End If
                           RoqAndRolLinestemp(intNumberForRoqRol) = d.productstockID ' found&     '        "                                 '                "
                           'RoqAndRolLines(intNumberForRoqRol, 2) = -1         '        "                                 '                "
                           On Error GoTo 0                                                                               '                "
                           'intNumberForRoqRol = intNumberForRoqRol + 1                                                   '                "

                        End If                                                                         '          "


                     Else
                        If ForPrinting Then
                           'temp$ = "Pack size not entered for" + GetStoresDescription() & "[cr]" XN 4Jun15 98073 New local stores description
                                                   temp$ = "Pack size not entered for" + d.DrugDescription & "[cr]"
                           numprinted = numprinted + 1
                        End If
                     End If
                     If Trim$(temp$) <> "" And Not blnRTfReport Then                                  '16Jan07 PJC Fence posted for the new ROQ and ROL report (RR enh)
                     'If Trim$(temp$) <> "" Then          '08Oct98 CFY Added                          '           "

                        PrinterParse temp$
                        Put #filno, , temp
                     End If
                  End If
               End If
            If Not change Then
               LSet d = dcopy
            End If
         End If
         If Val(d.anuse) < 0 Then d.anuse = "0"
         If blnRTfReport = False Then                              '16Jan07 PJC Fence post (RR enh)
            putdrug d            '<------UNLOCK
         End If                                                 '16Jan07 PJC Fence post (RR enh)

         loopvar = loopvar + 1
         rsProducts.MoveNext
      Loop
   End If
   rsProducts.Close
   Set rsProducts = Nothing
   If intNumberForRoqRol > 0 Then
      ReDim RoqAndRolLines(UBound(RoqAndRolLinestemp), 2)
      For intloop = 1 To intNumberForRoqRol
      RoqAndRolLines(intloop, 1) = RoqAndRolLinestemp(intloop)
      RoqAndRolLines(intloop, 2) = -1
      Next
   End If
   Unload Progress
   
   
   
ERR_CLEANUP:                                                                                              '16Jan07 PJC Added (RR enh)
   On Error Resume Next                                                                                   '       "
                                                                                                '       "
   Exit Sub                                                                                               '       "

   '16Jan07 PJC Added error handling below (RR enh)
ERR_ROQROL:
   'If Err = 14 Then                     '08Mar07 PJC Added overflow error to error handler
   If Err = 14 Or Err = 6 Then           '         "
         popmessagecr ".Roq and Rol Report", "Too many products selected for the Roq and Rol Report, please filter your product selection."
         ReDim RoqAndRolLines(0, 2)
      Else
         popmessagecr ".Roq and Rol Report", "Error: " & Error$
      End If

      Resume ERR_CLEANUP

End Sub
Sub printlivestock(filno%, numprinted%, ans$)

Dim desc As String * 52, temp$
Dim strParameters As String
Dim rsLiveStock As ADODB.Recordset
Dim intpage As Integer
Dim intNum As Integer

   numprinted = 0
   UpdateBar 0, 0, 0, 0
   desc$ = ""
   intpage = Val(TxtD(dispdata$ & "\winord.ini", "defaults", "60", "LiveStockLines", 0))
   intNum = 6 'compensate for header on first page
   
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   If Trim$(ans$) = "1" Then
      Set rsLiveStock = gTransport.ExecuteSelectSP(g_SessionID, "pWProductbyStockDiff", strParameters)
      If rsLiveStock.RecordCount > 0 Then
         rsLiveStock.MoveFirst
         Do While Not rsLiveStock.EOF
            UpdateBar 0, (rsLiveStock.RecordCount), (numprinted), ProgressBarScale
                        desc$ = rsLiveStock!Description         'desc$ = RSGetStoresDescription(rsLiveStock) XN 4Jun15 98073 New local stores description
            temp$ = desc$ & GetField(rsLiveStock!reorderlvl) & GetField(rsLiveStock!stocklvl) & GetField(rsLiveStock!PrintformV) & "[cr]"
            intNum = intNum + 1
            If intNum > intpage Then
               intNum = 1
               temp$ = temp$ & "[FF][CR]"
            End If
            PrinterParse temp$
            Put #filno, , temp$
            numprinted = numprinted + 1
            rsLiveStock.MoveNext
         Loop
      End If
      rsLiveStock.Close
      Set rsLiveStock = Nothing
   Else
      Set rsLiveStock = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLiveStock", strParameters)
      If rsLiveStock.RecordCount > 0 Then
         rsLiveStock.MoveFirst
         Do While Not rsLiveStock.EOF
            UpdateBar 0, (rsLiveStock.RecordCount), (numprinted), ProgressBarScale
            desc$ = rsLiveStock!Description  ' desc$ = RSGetStoresDescription(rsLiveStock) XN 4Jun15 98073 New local stores description
            temp$ = desc$ & GetField(rsLiveStock!reorderlvl) & GetField(rsLiveStock!stocklvl) & GetField(rsLiveStock!PrintformV) & "[cr]"
            intNum = intNum + 1
            If intNum > intpage Then
               intNum = 1
               temp$ = temp$ & "[FF][CR]"
            End If
            PrinterParse temp$
            Put #filno, , temp$
            numprinted = numprinted + 1
            rsLiveStock.MoveNext
         Loop
      End If
      rsLiveStock.Close
      Set rsLiveStock = Nothing
   End If

End Sub

Sub PrintOrderReports(Mode%)
'17Jun98 EAC not all options require printed output, so prevent spurious "No Items to be printed message"
'30Nov98 TH  Added option to print only items with stock differences
'11Dec98 TH  Added Code to titles on negstock report
'12Apr00 CFY Parameter added to wsspool call
'06Dec16 TH  Refactored RTF Handling (TFS 157969)

ReDim mnu$(3), hlp%(3)
Dim temp$, RTFTxt$, FILE$, ans$
Dim success%
Dim linesprinted%, filno%, change%, ForPrinting%, monthend%, count%
Dim openbracepos&, closebracepos&, startpos&
'Dim intNum As Integer
'Dim intpage As Integer

   If Mode = 1 Then
      k.escd = 0
      mnu$(1) = "Show only Stock Differences"
      mnu$(2) = "Show all Drugs"
      frmoptionset -1, "Stock level list for live items"
      For count = 1 To 2
         frmoptionset 1, mnu$(count)   'Action 1 adds a line (same as above)
      Next
      Screen.MousePointer = STDCURSOR
      frmoptionshow "1", ans$               'Preset 1st button 'On'
      Screen.MousePointer = HOURGLASS
      frmoptionset 0, ""  'Unload Form
      If Trim$(ans$) = "" Then k.escd = True
      If k.escd Then Screen.MousePointer = STDCURSOR: Exit Sub
      MainScreen.FrmGauge.Visible = True
      MainScreen.Progress.Visible = True
      MainScreen.Progress.Value = 0
   End If

   MainScreen.FrmGauge.Caption = "Building Report..."
   MainScreen.FrmGauge.Refresh '03Oct06 TH Added
   Screen.MousePointer = HOURGLASS
   
   MakeLocalFile FILE$
   filno = FreeFile
   Open FILE$ For Binary Access Write Lock Read Write As filno          ' for spooling ...
    
    
   'GetTextFile dispdata$ + "\utilreps.rtf", RTFTxt$, success
   GetRTFTextFromDB dispdata$ + "\utilreps.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)


   If Not success Then
      Screen.MousePointer = STDCURSOR
      'popmessagecr "Error", "Could not open the layout file UTILREPS.RTF"
      popmessagecr "Error", "Could not find the layout rtf UTILREPS in database"
      Exit Sub
   End If

   startpos& = 1
   
   ForPrinting = True        '17Jun98 EAC Added
   Do
      openbracepos& = InStr(startpos&, RTFTxt$, "[")
      If openbracepos& > 0 Then
         temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
      Else
         temp$ = Mid$(RTFTxt$, startpos&)
      End If
      Put #filno, , temp$
       
      If openbracepos& > 0 Then
         startpos& = openbracepos&
         closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
         temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
         Select Case LCase$(temp$)
            Case "[header]"
               Select Case Mode
                  Case 1 'Print Stock level for live items
                     temp$ = "Stock level list for live items"
                  Case 2 'Print items below danger level
                     temp$ = "List Items on Order Below Danger Level"
                  Case 3 'Print Items in negative stock
                     temp$ = "Live Stock Control Items with Negative Stock"
                  Case 4
                     temp$ = "End of Period Calculation Results"
               End Select
               PrinterParse temp$
               Put #filno, , temp$
            Case "[data]"
                  
               Select Case Mode
                  
                  Case 1 'Print Stock level for live items
                     temp$ = "[ulineon]Description" + Space$(41) + "Reorder Stock Level[ulineoff][cr][cr]"
                     PrinterParse temp$
                     Put #filno, , temp$
                     printlivestock filno, linesprinted, ans$

                  Case 2 'Print items below danger level
                     temp$ = "[ulineon]Code/Date/order No./Outstanding Qty     Description" + Space$(13) + "Stock level[ulineoff][cr][cr]"
                     PrinterParse temp$
                     Put #filno, , temp$
                     belowdangerlevel filno, linesprinted
                  Case 3 'Print Items in negative stock
                     temp$ = "[ulineon]Code    Description" + Space$(45) + "Stock Level[ulineoff][cr][cr]"  '11Dec98 TH Added Code
                     PrinterParse temp$
                     Put #filno, , temp$
                     negstock filno, linesprinted
                  Case 4
                     temp$ = "   Description                current rol suggested rol  current roq suggested roq ld. time   An.use cyc days[cr]"
                     PrinterParse temp$
                     Put #filno, , temp$

                     mnu$(1) = "Update Annual usages"
                     mnu$(2) = "Report suggested ROL and ROQ changes"
                     mnu$(3) = "Make changes"
                     
                     
                     frmoptionset -1, "Choose Option." 'Action -1 initialises for Radio buttons
                     For count = 1 To 3
                        frmoptionset 1, mnu$(count)   'Action 1 adds a line (same as above)
                     Next
                     
                     Screen.MousePointer = STDCURSOR
                     frmoptionshow "1", ans$               'Preset 1st button 'On'
                     Screen.MousePointer = HOURGLASS
                     
                     frmoptionset 0, ""  'Unload Form
                     If Trim$(ans$) = "" Then k.escd = True

                     If ans$ = "3" Then change = True Else change = False
                     
                     If ans$ = "2" Then
                        ForPrinting = True
                     Else
                        ForPrinting = False
                     End If
                     
                     If ans$ = "1" Then
                        change = True
                        monthend = True
                     Else
                        monthend = False
                     End If
                     
                     If Not k.escd Then
                        DoEOPCalcs filno, linesprinted, monthend%, ForPrinting%, change%, False, "", "", "", ""
                     End If

               End Select
         End Select

      End If
        
      startpos& = closebracepos& + 1

   Loop While (openbracepos& > 0)

   Close #filno
   Screen.MousePointer = STDCURSOR
   
   If ForPrinting Then                   '17Jun98 EAC prevent spurious messages
      If linesprinted = 0 Then
         If Not k.escd Then popmessagecr "Utility Reports", "No lines to be printed"
         Kill FILE$
      Else
         'Print file
         WSspool FILE$, "Stock Control", 1, True, False, ""
      End If
   End If
   
End Sub

Sub belowdangerlevel(filno%, numberprinted%)
'This should be done on a join with limited return fields to improve performance !!!
'03Oct06 TH Factor Overdue into return criteria - was missed from original port (SC-06-0900)

Dim loopvar&
Dim temp$
Dim strParameters As String
Dim rsLiveStock As ADODB.Recordset
Dim rsOrders As ADODB.Recordset
Dim blnSkipLine As Boolean
Dim strQuantity As String
Dim intNum As Integer
Dim intpage As Integer

   intpage = Val(TxtD(dispdata$ & "\winord.ini", "defaults", "60", "BelowDangerLevelLines", 0))
   intNum = 6 'compensate for header on first page
   
   loopvar = 0
   numberprinted = 0
   UpdateBar 0, 0, 0, 0
   

   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Overdue", trnDataTypeFloat, 8, CDbl(Val(overdue$))) '03Oct06 TH Factor Overdue (SC-06-0900)
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCodewithStock", strParameters)
   If rsOrders.RecordCount > 0 Then
      Do While Not rsOrders.EOF
         loopvar = loopvar + 1
         UpdateBar 0, (rsOrders.RecordCount), (loopvar), ProgressBarScale

         blnSkipLine = False
         If Len(Trim$(GetField(rsOrders!stocklvl))) < 6 Then
            strQuantity = Space$(6 - Len(Trim$(GetField(rsOrders!stocklvl)))) & Trim$(GetField(rsOrders!stocklvl))
         Else
            strQuantity = Trim$(GetField(rsOrders!stocklvl))
         End If
         'Select Case GetField(rsOrders!status)
         '   Case "1": temp$ = "Amend   " + GetField(rsOrders!Code) & Space$(22) & Left$(RSGetStoresDescription(rsOrders) & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
         '   Case "2": temp$ = "Modem   " + GetField(rsOrders!Code) & Space$(22) & Left$(RSGetStoresDescription(rsOrders) & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
         '   Case "3": temp$ = GetField(rsOrders!Code) & " " & Trim$(GetField(rsOrders!orddate)) & " " & Left$(GetField(rsOrders!num) & Space$(5), 5) & " " & GetField(rsOrders!outstanding) & " " & _
         '   Left$(RSGetStoresDescription(rsOrders) & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
         '   Case Else: blnSkipLine = True
         'End Select  XN 4Jun15 98073 New local stores description
         Select Case GetField(rsOrders!status)
            Case "1": temp$ = "Amend   " + GetField(rsOrders!Code) & Space$(22) & Left$(rsOrders!Description & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
            Case "2": temp$ = "Modem   " + GetField(rsOrders!Code) & Space$(22) & Left$(rsOrders!Description & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
            Case "3": temp$ = GetField(rsOrders!Code) & " " & Trim$(GetField(rsOrders!orddate)) & " " & Left$(GetField(rsOrders!num) & Space$(5), 5) & " " & GetField(rsOrders!outstanding) & " " & _
            Left$(rsOrders!Description & Space$(34), 34) & " " & strQuantity & " " & Trim$(GetField(rsOrders!PrintformV))
            Case Else: blnSkipLine = True
         End Select
         If Not blnSkipLine Then
            intNum = intNum + 1
            
            temp$ = temp$ & "[cr]"
            If intNum > intpage Then
               intNum = 1
               temp$ = temp$ & "[FF][CR]"
            End If
            PrinterParse temp$
            Put #filno, , temp$
            numberprinted = numberprinted + 1
         End If

         rsOrders.MoveNext
      Loop
   End If
   rsOrders.Close
   Set rsOrders = Nothing

End Sub

Sub UpdateBar(min&, Max&, present&, blcksize%)

'----------------------------------------------------------
' blcksize = size of increment in percent between 1% and 50%
'----------------------------------------------------------
Static nextincr%

   If blcksize = 0 Then
         'reset
         MainScreen.Progress.Value = 0
         nextincr = 1
      Else
         'general use
         If nextincr = 0 Then nextincr = 1
         If blcksize < 1 Or blcksize > 50 Then blcksize = 10
         
         If ((present& - min&) / Max&) >= ((nextincr * blcksize) / 100) Then
               MainScreen.Progress.Value = (nextincr * blcksize)
               DoEvents
               nextincr = (nextincr + 1) Mod ((100 / blcksize) + 1)
            End If
      End If
   

End Sub

Sub updatedefaultsinfo(Ordno As String)

'''30Dec97 EAC allow ward requisitions in packs
'''12Aug98 TH  Added reconciliation setting
'''23Sep98 TH  Added code to prevent overflow on low and highfact
'''21Dec98 CFY AskBatchNum now no longer used as now set at drug level.
'14Apr10 TH Ported 31Aug05 PJC Added (F0056463)
'17May10 TH Removed suffix on NSVReconciliation setting - this was never being read back so effectively the editor couldnt be used (F0074613)

Dim CostOnLbls$
Dim X%
Dim strFile As String

   Ordno$ = Ques.txtQ(1).text
   ordnumprefix$ = Ques.txtQ(2).text
   ownname$ = Ques.txtQ(3).text
   overdue$ = Ques.txtQ(4).text
   ordcontact$ = Ques.txtQ(5).text
   preprint$ = Ques.txtQ(6).text
   maxnumoflines = Val(Ques.txtQ(7).text)
   picknumoflines = Val(Ques.txtQ(8).text)
   delreceipt = Val(Ques.txtQ(9).text)
   delreconcile = Val(Ques.txtQ(10).text)
   Delrequis = Val(Ques.txtQ(11).text)
   ordmessage$ = Ques.txtQ(12).text
   If UCase$(Ques.txtQ(13).text) = "Y" Then

         FullPageCS = True
      Else
         FullPageCS = False
      End If
   NSVcarriage$ = Ques.txtQ(14).text
   NSVdiscount$ = Ques.txtQ(15).text
   'If UCase$(Ques.txtQ(16).Text) = "Y" Then          '21Dec98 CFY Removed
   '      AskBatchNum = True                          '        "
   '   Else                                           '        "
   '      AskBatchNum = False                         '        "
   '   End If                                         '        "
   'AskBatchNum = Val(Ques.txtQ(16).Text)             '        "

   If UCase$(Ques.txtQ(17).text) = "Y" Then
         OrdPrintPrice = True
      Else
         OrdPrintPrice = False
      End If
   If UCase$(Ques.txtQ(18).text) = "Y" Then
         OrdPrintLin = True
      Else
         OrdPrintLin = False
      End If
   If UCase$(Ques.txtQ(19).text) = "Y" Then
         TransLogVAT = True
         OrderLogVAT = True
      Else
         TransLogVAT = False
         OrderLogVAT = False
      End If
   'Stop possible overflow
   If Val(Ques.txtQ(21).text) > 30000 Then                                                                           '23Sep98 TH added to prevent overflow
         popmessagecr "!", " Invalid Amount Above Allowed for Reconciliation " & crlf & "Value has been set to 1"    '
         Ques.txtQ(21).text = "1"                                                                                    '
      End If                                                                                                         '
   Highfact! = (Val(Ques.txtQ(21).text) / 100) + 1
   'lowfact! = (Val(Ques.txtQ(23).Text) / 100) + 1
   If Val(Ques.txtQ(22).text) > 30000 Then                                                                           '23Sep98 TH added to prevent overflow
         popmessagecr "!", " Invalid Amount Below Allowed for Reconciliation " & crlf & "Value has been set to 1"    '    '
         Ques.txtQ(22).text = "1"                                                                                    '
      End If                                                                                                         '

   Lowfact! = (100 - Val(Ques.txtQ(22).text)) / 100
   entercostonreceipt$ = Ques.txtQ(23).text

   If UCase$(Ques.txtQ(24).text) = "Y" Then
         tofollow = True
      Else
         tofollow = False
      End If

    For X = 0 To 9
        VAT(X) = Val(Ques.txtQ(26 + X).text)
    Next

   UtilOrdNum$ = Ques.txtQ(37).text
   UtilSupplier$ = Ques.txtQ(38).text
   UtilReasonNew$ = Ques.txtQ(39).text
   UtilReasonMod$ = Ques.txtQ(40).text
   ProgressBarScale = Val(Ques.txtQ(42).text)
   PrintToScreen$ = Ques.txtQ(43).text
   CostOnLbls$ = Ques.txtQ(44).text
   If Trim$(UCase$(CostOnLbls$)) = "Y" Then
            PrintStockCost = True
        Else
            PrintStockCost = False
        End If
    PrintCanceledOrder$ = Ques.txtQ(45).text
    PrintInPacks = (Ques.txtQ(46).text = "Y")   '30Dec97 EAC
    AdjCostCentre$ = Ques.txtQ(47).text
    NSVReconciliation$ = Ques.txtQ(48).text     '12Aug98 TH
   If Val(Ques.txtQ(49).text) > 100 Or Val(Ques.txtQ(49).text) < 1 Then                                                                           '23Sep98 TH added to prevent overflow
         popmessagecr "!", " Invalid Amount For End of Period Margin " & crlf & "Value has been set to 20"    '    '
         Ques.txtQ(49).text = "20"                                                                                    '
      End If                                                                                                        '
   EOPMargin% = Int(Val(Ques.txtQ(49).text))        '25Feb00 TH
   edimaxnumoflines = Int(Val(Ques.txtQ(50).text))
   ReconcilThresholdVal$ = Ques.txtQ(51).text       '14Apr10 TH Ported 31Aug05 PJC Added (F0056463)
   
   'Now write to the config settings
   strFile = "\workingdefaults"
   WritePrivateIniFile "", "preprint", preprint$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordnumprefix", ordnumprefix$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ownname", ownname$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "overdue", overdue$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordmessage", ordmessage$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "ordcontact", ordcontact$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "maxnumoflines", Format$(maxnumoflines), dispdata$ & strFile, 0
   WritePrivateIniFile "", "tp", tp$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "picknumoflines", Format$(picknumoflines), dispdata$ & strFile, 0
   WritePrivateIniFile "", "delreceipt", Format$(delreceipt), dispdata$ & strFile, 0
   WritePrivateIniFile "", "delreconcile", Format$(delreconcile), dispdata$ & strFile, 0
   WritePrivateIniFile "", "FullPageCS", Format$(FullPageCS), dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVcarriage", NSVcarriage$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVdiscount", NSVdiscount$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "AskBatchNum", Format$(AskBatchNum), dispdata$ & strFile, 0
   WritePrivateIniFile "", "Delrequis", Format$(Delrequis), dispdata$ & strFile, 0
   WritePrivateIniFile "", "OrdPrintPrice", Format$(OrdPrintPrice), dispdata$ & strFile, 0
   WritePrivateIniFile "", "OrdPrintLin", Format$(OrdPrintLin), dispdata$ & strFile, 0
   WritePrivateIniFile "", "ProgressBarScale", Format$(ProgressBarScale), dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintStockCost", Format$(PrintStockCost), dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintToScreen", PrintToScreen$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintCanceledOrder", PrintCanceledOrder$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "PrintInPacks", Format$(PrintInPacks), dispdata$ & strFile, 0
   WritePrivateIniFile "", "AdjCostCentre", AdjCostCentre$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "WSStores", Format$(WSStores%), dispdata$ & strFile, 0
   'WritePrivateIniFile "", "NSVReconciliation$", NSVReconciliation$, dispdata$ & strFile, 0
   WritePrivateIniFile "", "NSVReconciliation", NSVReconciliation$, dispdata$ & strFile, 0     '17May10 TH Removed suffix (F0074613)
   WritePrivateIniFile "", "EOPMargin", Format$(EOPMargin%), dispdata$ & strFile, 0
   WritePrivateIniFile "", "edimaxnumoflines", Format$(edimaxnumoflines), dispdata$ & strFile, 0    ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
   WritePrivateIniFile "", "ReconcilThresholdVal", ReconcilThresholdVal$, dispdata$ & strFile, 0    '14Apr10 TH Added (F0056463)
End Sub

Sub amenddefaults()

' 3May95 CKJ Widened prefix, ucase(ownname), OrdPrint Price corrected
'23Oct97 EAC Allow receipt of item with negative stock
'30Dec97 EAC Add option to allow ward requistions to be printed as "8x100"
'19Feb98 EAC sorted mask types and lengths, added %'s to Vat amounts
'25Feb98 EAC Stock Transfer Mods
'20Apr98 CFY Added fix to stop rounding error occuring during display of '% above/below reconciliation'
'11Aug98 TH  Added Psuedo code for variable reconciliation
'21Dec98 CFY AskBatchNum now no longer used as now set at drug level.
'14Apr10 TH Ported and altered indexes   '31Aug05 PJC Added Reconciliation Threshold (F0056463)

Dim X%  ''orderno%,
Dim Ordno$, BarScale$, CostOnLbls$, PrintPacks$  '30Dec97 EAC added PrintPacks$
Dim TempInt%         '20Apr98 CFY Added
Dim lngOrderno As Long

   QuesCallbackMode = 2
   
   getorderno 1, lngOrderno, 0
   Ordno$ = Trim$(Str$(lngOrderno))
   
   Ques.Caption = "Set/Amend Working Defaults"
   
   QuesMakeCtrl 1, 1
   Ques.lblDesc(1) = "1) Order number for next order                 "
   'QuesSetCtrl Ques.txtQ(1), 1, 4, Trim$(Ordno$)                               '19Feb98 EAC changed length  to 4
   QuesSetCtrl Ques.txtQ(1), 1, 9, Trim$(Ordno$)  '06Mar06 TH Changed length to 9
   
   QuesMakeCtrl 2, 1
   Ques.lblDesc(2) = "2) Order number prefix                         "
   QuesSetCtrl Ques.txtQ(2), 0, 5, Trim$(ordnumprefix$)                        '19Feb98 EAC changed length to 5
   
   QuesMakeCtrl 3, 1
   Ques.lblDesc(3) = "3) The Supplier code for your own address      "
   QuesSetCtrl Ques.txtQ(3), 0, Len(sup.Code), Trim$(ownname$)
   
   QuesMakeCtrl 4, 1
   Ques.lblDesc(4) = "4) Fraction of reorder level for overdue alarm  "
   QuesSetCtrl Ques.txtQ(4), 3, 4, Trim$(overdue$)                             '19Feb98 EAC changed mask type to 3, length to 4
   
   QuesMakeCtrl 5, 1
   Ques.lblDesc(5) = "5) Contact person                              "
   QuesSetCtrl Ques.txtQ(5), 0, 30, Trim$(ordcontact$)                         '19Feb98 EAC allow 30 chars for contact
   
   QuesMakeCtrl 6, 1
   Ques.lblDesc(6) = "6) Pre-printed order stationery Y/N            "
   QuesSetCtrl Ques.txtQ(6), 2, 1, Trim$(preprint$)                            '19Feb98 EAC changed mask type to 2
   
   QuesMakeCtrl 7, 1
   Ques.lblDesc(7) = "7) Maximum lines printed on order             "
   QuesSetCtrl Ques.txtQ(7), 1, 2, Trim$(Str$(maxnumoflines))
   
   QuesMakeCtrl 8, 1
   Ques.lblDesc(8) = "8) Number of lines per page (Picking ticket)  "
   QuesSetCtrl Ques.txtQ(8), 1, 2, Trim$(Str$(picknumoflines))
   
   QuesMakeCtrl 9, 1
   Ques.lblDesc(9) = "9) No. days for deletion after receipt        "
   QuesSetCtrl Ques.txtQ(9), 1, 3, Trim$(Str$(delreceipt))
   
   QuesMakeCtrl 10, 1
   Ques.lblDesc(10) = "10) No. days for deletion after payment date   "
   QuesSetCtrl Ques.txtQ(10), 1, 3, Trim$(Str$(delreconcile))
   
   QuesMakeCtrl 11, 1
   Ques.lblDesc(11) = "11) No. days for del. after requisition issued "
   QuesSetCtrl Ques.txtQ(11), 1, 3, Trim$(Str$(Delrequis))
   
   QuesMakeCtrl 12, 1
   Ques.lblDesc(12) = "12) Standard message on orders"
   QuesSetCtrl Ques.txtQ(12), 0, 70, Trim$(ordmessage$)                        '19Feb98 EAC changed length to 70
   
   QuesMakeCtrl 13, 1
   Ques.lblDesc(13) = "13) Use whole page per Finance coding slip      "
   If FullPageCS Then
         QuesSetCtrl Ques.txtQ(13), 2, 1, "Y"
      Else
         QuesSetCtrl Ques.txtQ(13), 2, 1, "N"
      End If
   
   QuesMakeCtrl 14, 1
   Ques.lblDesc(14) = "14) Pseudo NSV code for carriage costs          "
   'QuesSetCtrl Ques.txtQ(14), 0, Len(NSVcarriage$), Trim$(NSVcarriage$)
   QuesSetCtrl Ques.txtQ(14), 0, 7, Trim$(NSVcarriage$) '08Nov06 TH set code length explicitly
   
   QuesMakeCtrl 15, 1
   Ques.lblDesc(15) = "15) Pseudo NSV code for discounts               "
   'QuesSetCtrl Ques.txtQ(15), 0, Len(NSVdiscount$), Trim$(NSVdiscount$)
   QuesSetCtrl Ques.txtQ(15), 0, 7, Trim$(NSVdiscount$) '08Nov06 TH set code length explicitly
   
   'QuesMakeCtrl 16, 1
   'Ques.lblDesc(16) = "16) Enter expiry date & batch no. on receipt    "
   'If AskBatchNum Then                                           'o CFY Removed
   '      QuesSetCtrl Ques.txtQ(16), 2, 1, "Y"                    '         "
   '   Else                                                       '         "
   '      QuesSetCtrl Ques.txtQ(16), 2, 1, "N"                    '         "
   '   End If                                                     '         "
   
   QuesMakeCtrl 17, 1
   Ques.lblDesc(17) = "17) Print prices on orders"
   If OrdPrintPrice Then
         QuesSetCtrl Ques.txtQ(17), 2, 1, "Y"
      Else
         QuesSetCtrl Ques.txtQ(17), 2, 1, "N"
      End If
   
   
   QuesMakeCtrl 18, 1
   Ques.lblDesc(18) = "18) Print blank line between items on orders"
   If OrdPrintLin Then
         QuesSetCtrl Ques.txtQ(18), 2, 1, "Y"
      Else
         QuesSetCtrl Ques.txtQ(18), 2, 1, "N"
      End If
   
   QuesMakeCtrl 19, 1
   Ques.lblDesc(19) = "19) Add " & money(9) & " to transactions (Y/N)"
   If TransLogVAT Then
         QuesSetCtrl Ques.txtQ(19), 2, 1, "Y"
      Else
         QuesSetCtrl Ques.txtQ(19), 2, 1, "N"
      End If
   
   'QuesMakeCtrl 20, 1
   'Ques.lblDesc(20) = "20) Add VAT to receipt transactions (Y/N)"
   'If OrderLogVAT Then
   '        QuesSetCtrl Ques.txtQ(20), 2, 1, "Y"
   '    Else
   '        QuesSetCtrl Ques.txtQ(20), 2, 1, "N"
   '    End If
   
   QuesMakeCtrl 21, 1
   Ques.lblDesc(21) = "20) % Above allowed for reconciliation"
   
   'QuesSetCtrl Ques.txtQ(21), 1, 6, Trim$(Str$(Int((highfact! - 1) * 100)))     '20Apr98 CFY Removed and replaced with lines below
   TempInt = (Highfact! - 1) * 100                                               '
   QuesSetCtrl Ques.txtQ(21), 1, 6, Trim$(Str$(TempInt))                         '
   
   QuesMakeCtrl 22, 1
   Ques.lblDesc(22) = "21) % Below allowed for reconciliation"
   'QuesSetCtrl Ques.txtQ(22), 1, 6, Trim$(Str$(Int((1 - LowFact!) * 100)))      '20Apr98 CFY Removed and replaced with lines below
   TempInt = (1 - Lowfact!) * 100                                                '
   QuesSetCtrl Ques.txtQ(22), 1, 6, Trim$(Str$(TempInt))                         '
   
   QuesMakeCtrl 23, 1
   Ques.lblDesc(23) = "22) Check prices and amend on receipt"
   QuesSetCtrl Ques.txtQ(23), 2, 1, Trim$(entercostonreceipt$)
   
   QuesMakeCtrl 24, 1
   Ques.lblDesc(24) = "23) Print 'to follows' on picking ticket"
   If tofollow Then
         QuesSetCtrl Ques.txtQ(24), 2, 1, "Y"
      Else
         QuesSetCtrl Ques.txtQ(24), 2, 1, "N"
      End If
   
   QuesMakeCtrl 25, 0
   Ques.lblDesc(25) = "24) " & money(9) & " Rates"
   For X = 0 To 9
      If VAT(X) = 0 Then VAT(X) = 1
      QuesMakeCtrl (26 + X), 1
      Ques.lblDesc(26 + X) = "          " & money(9) & " rate " & Trim$(Str$(X))
      QuesSetCtrl Ques.txtQ(26 + X), 3, 6, Trim$(Str$(VAT(X)))                    '19Feb98 EAC changed mask type to 3
      'Ques.lblInfo(26 + x).Caption = Format$(100 * (VAT(x) - 1)) & "%"            '19FEb98 EAC added line
      Ques.lblInfo(26 + X).Caption = Format$(round(100 * (VAT(X) - 1), 2)) & "%"            '03Oct08 TH (F0024736)
   Next
   
   QuesMakeCtrl 37, 1
   Ques.lblDesc(37) = "25) Pseudo order number for item editing"
   QuesSetCtrl Ques.txtQ(37), 0, 4, Trim$(UtilOrdNum$)
                                                                                    
   QuesMakeCtrl 38, 1
   Ques.lblDesc(38) = "26) Pseudo supplier code for item editing"
   QuesSetCtrl Ques.txtQ(38), 0, 5, Trim$(UtilSupplier$)
   
   QuesMakeCtrl 39, 1
   Ques.lblDesc(39) = "27) Reason code when creating a new item"
   QuesSetCtrl Ques.txtQ(39), 0, 2, Trim$(UtilReasonNew$)
   
   QuesMakeCtrl 40, 1
   Ques.lblDesc(40) = "28) Reason code when amending a item"
   QuesSetCtrl Ques.txtQ(40), 0, 2, Trim$(UtilReasonMod$)
   
   BarScale$ = Trim$(Str$(ProgressBarScale))
   QuesMakeCtrl 42, 1
   Ques.lblDesc(42) = "29) Progress Bar Granularity (%)"
   QuesSetCtrl Ques.txtQ(42), 0, 2, Trim$(BarScale$)
   
   QuesMakeCtrl 43, 1
   Ques.lblDesc(43) = "30) Print to Screen"
   Ques.lblInfo(43) = "(Use to test Printer Layout changes)"
   QuesSetCtrl Ques.txtQ(43), 2, 1, Trim$(PrintToScreen$)
   
   If PrintStockCost Then
         CostOnLbls$ = "Y"
      Else
         CostOnLbls$ = "N"
      End If
   QuesMakeCtrl 44, 1
   Ques.lblDesc(44) = "31) Print Costs on Ward Stock Labels"
   QuesSetCtrl Ques.txtQ(44), 2, 1, Trim$(CostOnLbls$)
   
   QuesMakeCtrl 45, 1
   Ques.lblDesc(45) = "32) Print confirmation for cancelled orders"
   QuesSetCtrl Ques.txtQ(45), 2, 1, Trim$(PrintCanceledOrder$)
   
   '30Dec97 EAC
   If PrintInPacks Then
         PrintPacks$ = "Y"
      Else
         PrintPacks$ = "N"
      End If
   QuesMakeCtrl 46, 1
   Ques.lblDesc(46) = "33) Print Ward Requisitions in packs"
   QuesSetCtrl Ques.txtQ(46), 2, 1, PrintPacks$
   '---

   '25Feb98 EAC Stock Transfer Mods
   QuesMakeCtrl 47, 1
   Ques.lblDesc(47) = "34) Adjustment cost centre for Stock Transfers"
   QuesSetCtrl Ques.txtQ(47), -1, 5, AdjCostCentre$

   '11Aug98 TH Psuedo code for variable reconciliation
   QuesMakeCtrl 48, 1
   'Ques.lblDesc(48) = "48) Pseudo NSV code for reconciliation         '25Feb00 TH Altered number shown on screen
   Ques.lblDesc(48) = "35) Pseudo NSV code for reconciliation"
   QuesSetCtrl Ques.txtQ(48), 0, 7, Trim$(NSVReconciliation$)
   
   '25Feb00 TH Added EOP Margin
   QuesMakeCtrl 49, 1
   Ques.lblDesc(49) = "36) Margin for End of Period Calculations        "
   QuesSetCtrl Ques.txtQ(49), 0, 7, Trim$(Str$(EOPMargin%))
   'QuesShow 48   '25Feb00 TH Replaced with below
      
   ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
   QuesMakeCtrl 50, 1
   Ques.lblDesc(50) = "37) EDI Maximum lines printed on order             "
   QuesSetCtrl Ques.txtQ(50), 1, 2, Trim$(Str$(edimaxnumoflines))
   
   '14Apr10 TH Ported and altered indexes   '31Aug05 PJC Added Reconciliation Threshold (F0056463)
   QuesMakeCtrl 51, 1
   Ques.lblDesc(51) = "38) Reconciliation Threshold Value (" & money(7) & ")    "
   Ques.lblInfo(51) = "(Empty - no threshold, 0.00 - zero tolerance)"
   QuesSetCtrl Ques.txtQ(51), 3, 7, Trim$(ReconcilThresholdVal$)
   
   QuesShow 51
   
End Sub

Sub EnhancedRoqAndRol()
'16Jan07 PJC created. Gathers the information for the rtf Roq and Rol report and displays the form (RR enh)
'09Sep08 TH  Merged from v8
'16Jun10 XN Added completed message to end of update annual usage progress (F0058248)
'29Sep10 TH Now do not continue if user cancels on first option box (F0097340)
'29Sep10 TH Added to set the cursor correctly - tidying up.

Dim found As Long
Dim site$
Dim strStocked As String
Dim strSortOrder As String
Dim frm As Form
Dim strLocCode As String
ReDim mnu$(2), hlp%(2)
Dim intCount As Integer
Dim ans$
Dim blnlocked As Integer

   setinput 0, k
   k.escd = False

   mnu$(1) = "Update Annual usages"
   mnu$(2) = "Report suggested ROL and ROQ changes"
   
   frmoptionset -1, "Choose Option." 'Action -1 initialises for Radio buttons
   For intCount = 1 To 2
      frmoptionset 1, mnu$(intCount)   'Action 1 adds a line (same as above)
   Next
   
   frmoptionshow "1", ans$               'Preset 1st button 'On'
   
   frmoptionset 0, ""  'Unload Form
   If Trim$(ans$) = "" Then k.escd = True
   
   If Not k.escd Then '29Sep10 TH (F0097340)
   
      'If ans$ = "1" And Not k.escd Then
      If ans$ = "1" Then  '29Sep10 TH moved above
         DoEOPCalcs 0, 0, True, False, True, False, "", "", "", ""
         popmessagecr "Completed", "Updating annual usages completed." ' 16Jun10 XN Added completed message to end of update annual usage progress (F0058248)
      Else
         AcquireLock dispdata$ & "\roqrol.LCK", -2, blnlocked                                                                                       '          "
         If blnlocked Then                                                                                                                          '          "
   
            'go though the process for the new roq and rol
            ReDim mnu$(3), hlp%(3)
            mnu$(1) = "Both Stocked Items and Non-Stocked Items"
            mnu$(2) = "Stocked Items"
            mnu$(3) = "Non-Stocked Items"
         
            setinput 0, k
            k.escd = False
            
            frmoptionset -1, "Choose Item types."
            For intCount = 1 To 3
               frmoptionset 1, mnu$(intCount)
            Next
            
            Screen.MousePointer = STDCURSOR
            
            frmoptionshow "1", ans$
            Screen.MousePointer = HOURGLASS
            frmoptionset 0, ""  'Unload Form
            If Trim$(ans$) = "" Then k.escd = True
            If Not k.escd Then
               If Trim$(ans$) = "" Then
                  k.escd = True
               Else
                  strStocked = ""
                  Select Case Trim$(ans$)
                     Case "2"
                        strStocked = "Y"
                     Case "3"
                        strStocked = "N"
                  End Select
               End If
            
               site$ = ""
               k.escd = False
               setinput 0, k
               asksupplier site$, 1, "SE", "Select Supplier Code", False, sup, False '15Nov12 TH Added PSO param
               If Not k.escd Then
      
                  site$ = Trim$(UCase$(site$))
                  'getsupplier site$, False, found, False, sup
                  getsupplier site$, 0, found, sup
                  If site$ = "" Then site$ = "A"
         
                  If found = 0 And site$ <> "A" Then
                     ans$ = "N"
                     k.helpnum = 0
                     Confirm "!n!bSupplier/Site Code '" & site$ & "' not found", "use code '" & site$ & "'", ans$, k
                     If ans$ = "N" Then k.escd = True
                  End If
         
                  If Not k.escd Then
                     setinput 0, k
                     k.escd = False
                     k.Max = 3
                     strLocCode = ""
                     InputWin "Enter product location code", "Enter product location code (leave blank for all locations)", strLocCode, k
                     strLocCode = Trim$(strLocCode)
                  
                     If Not k.escd Then
                        'ask about sort order
                        ReDim mnu$(2)
                        ReDim hlp%(2)
                        
                        mnu$(1) = "Sort by Drug Description only"
                        mnu$(2) = "Sort by Location Code then Drug Description"
                        If site$ = "A" Then
                           ReDim Preserve mnu$(4)
                           ReDim Preserve hlp%(4)
                           mnu$(3) = "Sort by Supplier, Location then Drug Description"
                           mnu$(4) = "Sort by Supplier then Drug Description"
                        End If
      
                        frmoptionset -1, "Sort Items by." 'Action -1 initialises for Radio buttons
                        For intCount = 1 To UBound(mnu$)
                           frmoptionset 1, mnu$(intCount)   'Action 1 adds a line (same as above)
                        Next
      
                        Screen.MousePointer = STDCURSOR
      
                        frmoptionshow "1", ans$
                        Screen.MousePointer = HOURGLASS
                        frmoptionset 0, ""  'Unload Form
                        If Trim$(ans$) = "" Then k.escd = True
                        If Not k.escd Then
                           Select Case Val(Trim$(ans$))
                              Case 3
                                 strSortOrder = "SLD"
                              Case 4
                                 strSortOrder = "SD"
                              Case 2
                                 strSortOrder = "LD"
                              Case Else
                                 strSortOrder = "D"
                           End Select
                           ReDim RoqAndRolLines(0, 2)
                           DoEOPCalcs 0, 0, False, False, False, True, strStocked, site$, strLocCode, strSortOrder
                           If UBound(RoqAndRolLines) > 0 Then
                              Set frm = New RoqAndRol
                              frm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                              Unload frm
                              Set frm = Nothing
                              ReDim RoqAndRolLines(0, 2)
                           Else
                              Screen.MousePointer = STDCURSOR '29Sep10 TH Added
                              popmessagecr "Roq and Rol Report", "No data found on the selected criteria."
                           End If
                           ScreenRefresh
                        End If
                     End If
                  End If
               End If
            End If
         Else
            popmessagecr "Error", "Another terminal is currently performing Roq and Rol reporting." & crlf$ & crlf$ & "Please try again later."
         End If
      End If
   End If '29Sep10 TH

   If blnlocked Then
      'release lock to allow other terminals to use
      AcquireLock dispdata$ & "\roqrol.LCK", False, blnlocked
   End If
   
   Screen.MousePointer = STDCURSOR

End Sub

Sub DoEOPAnnualUseCalc(d As DrugParameters)
'16Jan07 PJC created sub from the annual use update section in DoEOPCalcs (RR enh)
'09Sep08 TH  Merged from v8

Dim dat$, tday$, ndbd&, ye!, yeye$, valid%

   parsedate Trim$(d.datelastperiodend), dat$, "1", valid
   
   tday$ = thedate(True, True)
   datetodays dat$, tday$, ndbd&, ye!, yeye$, valid
   
   If ndbd& > 20 Then
      If Val(d.anuse) > 1 Then
         d.anuse = LTrim$(Str$(1! * ((d.usethisperiod / ndbd&) * 365 * (1 - d.usagedamping)) + (Val(d.anuse) * d.usagedamping)))
      Else
         d.anuse = LTrim$(Str$(1! * (d.usethisperiod / ndbd&) * 365))
      End If
      d.datelastperiodend = thedate(False, True)
      d.usethisperiod = 0
   End If

End Sub

Sub DoEOPRoqAndRolCalc(d As DrugParameters, setroq%, setrol%, Roq&, Rol&)
'16Jan07 PJC created sub from the roq and rol calculation/update section in DoEOPCalcs (RR enh)
'09Sep08 TH  Merged from v8

Dim LeadTime!


   If Val(d.LeadTime) < 5 Then LeadTime! = 5 Else LeadTime! = Val(d.LeadTime)
   Rol& = (Val(d.anuse) / 365 * LeadTime!) * d.safetyfactor
   If Rol& < 1 Then Rol& = 1
   Roq& = 2 * Rol& * d.safetyfactor

   If Rol& < Val(d.convfact) Then
      If Val(d.convfact) < 100 Then
         Rol& = Val(d.convfact)
      Else
         Rol& = 100
      End If
      Roq& = Val(d.convfact)
   End If
   If Val(d.convfact) > 0 Then
      setroq = False
      setrol = False
      If Int((Roq& / Val(d.convfact) + 0.5)) < 1 Then Roq& = Val(d.convfact)
      Roq& = Int((Roq& / Val(d.convfact) + 0.5))
      'If Val(d.reorderqty) < roq& * .8 Or Val(d.reorderqty) > roq& * 1.2 Then                                             '25Feb00 TH Replaced with below
      If (Val(d.reorderqty) < Roq& * (1 - (EOPMargin% / 100))) Or (Val(d.reorderqty) > Roq& * (1 + (EOPMargin% / 100))) Then   '   "
         setroq = True
      End If
      'If Val(d.reorderlvl) < rol& * .8 Or Val(d.reorderlvl) > rol& * 1.2 Then
      If Val(d.reorderlvl) < Rol& * (1 - (EOPMargin% / 100)) Or Val(d.reorderlvl) > Rol& * (1 + (EOPMargin% / 100)) Then   '25Feb00 TH Replaced with below
         setrol = True                                                                                                  '   "
      End If
   End If
End Sub

Function NumberOfRoqAndRolLines() As Integer
'16Jan07 PJC created to return the number of lines in the array. Used to the true grid on the roq and rol form. (RR enh)
'09Sep08 TH  Merged from v8
   NumberOfRoqAndRolLines = UBound(RoqAndRolLines)
End Function

Sub fillrqroltable(frm As Form)
'09Sep08 TH  Merged from v8
Dim intloop As Integer
Dim lngPtr As Long
Dim found&
Dim strValue As String
Dim lngRoq As Long
Dim lngRol As Long
Dim strKey As String
Dim lvwRoqRolItem       As ListItem
Dim lvwSubItem    As ListSubItem

frm.lvwRoqRol.ListItems.Clear

For intloop = 1 To UBound(RoqAndRolLines)
      lngPtr = RoqAndRolLines(intloop, 1)                             '        "
      getdrug d, lngPtr, found&, False                               '        "

      If found& Then
         strKey = "R" & CStr(intloop)
         Set lvwRoqRolItem = frm.lvwRoqRol.ListItems.Add(, strKey & ":C1", Trim$(d.supcode))
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C2", Trim$(d.loccode)
         strValue = trimz$(d.DrugDescription) 'strValue = trimz$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
               plingparse strValue, "!"
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C3", strValue
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C4", Trim$(d.SisCode)
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C5", Trim$(d.sisstock)
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C6", Trim$(d.reorderlvl)
         RoqAndRolCalc d, lngRoq, lngRol
         strValue = Format$(lngRol) & " " & Trim$(d.PrintformV)
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C7", strValue
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C8", Trim$(d.reorderqty)
         RoqAndRolCalc d, lngRoq, lngRol
         strValue = Format$(lngRoq) & " x " & Trim$(d.convfact)
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C9", strValue
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C10", Trim$(d.LeadTime)
         DoEOPAnnualUseCalc d
         strValue = Format$(d.anuse, "#0")
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C11", strValue
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C12", Trim$(d.stocklvl)
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C13", Trim$(d.cyclelength)
         strValue = Iff(RoqAndRolLines(intloop, 2) = -1, "Y", "N")
         lvwRoqRolItem.ListSubItems.Add , strKey & ":C14", strValue
      End If
   Next
   
End Sub
Sub RoqAndRolCalc(d As DrugParameters, lngRoq As Long, lngRol As Long)
'16Jan07 PJC created (RR enh)
'09Sep08 TH  Merged from v8
Dim blnSetRoq As Integer
Dim blnSetRol As Integer

   lngRoq = 0
   lngRol = 0
   DoEOPAnnualUseCalc d
   DoEOPRoqAndRolCalc d, blnSetRoq, blnSetRol, lngRoq, lngRol
   If Not blnSetRoq Then lngRoq = Val(d.reorderqty)
   If Not blnSetRol Then lngRol = Val(d.reorderlvl)

End Sub

Sub PrintRoqAndRol(blnPrint As Integer, blnUpdate As Integer, intLinesPerPage As Integer, blnIncludeNonUpdates As Integer, ByRef progressBar As progressBar)
'16Jan07 PJC created (RR enh)
'08Mar07 PJC Added Check on missing rft files
'08Mar07 PJC RoqAndRolLines array now stores position of drug.
'            Moved the locking of the drug, now loked for a shorter period.
'09Sep08 TH  Merged from v8
'26Apr10 XN  Added progress bar updates F0058248
'26Jun14 TH  Changed progressbar min value as was invalid max value on this if only 1 item in array (TFS 94282)
'06Dec16 TH  Refactored RTF Handling (TFS 157969)
'05Jan17 TH  Moved line from below to utilise check (Hosted) (TFS 157969)
'07Jan17 TH  Replaced checks for DB only (Hosted)

Dim intCount As Integer
Dim foundPtr&
Dim strFile As String
Dim strLine As String
Dim strLineParsed As String
Dim filno%
Dim strTempFile As String
Dim intSuccess As Integer
Dim lngRol As Long
Dim lngRoq As Long
Dim strHeadLine As String
Dim strTop As String
Dim intLineCount As Integer
Dim intPageCount As Integer
Dim strPreParseTop As String
Dim dcopy As DrugParameters

   Const procname$ = "PrintRoqAndRol"

   
   If blnPrint Then
      strTempFile = dispdata$ & "\RqRlData.rtf"
      GetRTFTextFromDB strTempFile, strLine, intSuccess '05Jan17 TH Moved from below to utilise check (Hosted)
      'If fileexists(strTempFile) = False Then                                                                    '08Mar07 PJC Added Check on missing rft files
      If Not intSuccess Then                                                                     '08Mar07 PJC Added Check on missing rft files
         'popmessagecr ".Error", "Missing Roq and Rol line rtf print file " & strTempFile & "."                '         "
         popmessagecr ".Error", "Missing Roq and Rol line rtf print record " & strTempFile & "."                '         "
         Exit Sub                                                                                             '         "
      End If                                                                                                  '         "

      'GetTextFile strTempFile, strLine, intSuccess
      'GetRTFTextFromDB strTempFile, strLine, intSuccess  '06Dec16 TH Replaced (TFS 157969)

''      If intSuccess = False Then
''         popmessagecr ".Error", "Problem loading the Roq and Rol line rtf print file " & strTempFile & "."
''         Exit Sub
''      End If

      If Left$(strLine, 6) = "{\rtf1" Then strLine = Mid$(strLine, 2)
      striprtf strLine

      If InStr(strLine, "{\info{") > 0 Then                         ' Put this in to strip the rft
         strLine = Mid$(strLine, InStr(strLine, "{\info{"))      ' back to the info section as a HIEDIT GPF
      End If                                                     ' appeared for large reports.
         
      strTempFile = dispdata$ & "\RqRlTop.rtf"
      '07Jan17 TH REplaced checks for DB only (Hosted)
      'If fileexists(strTempFile) = False Then                                                                    '08Mar07 PJC Added Check on missing rft files
      '   popmessagecr ".Error", "Missing Roq and Rol Top rtf print file " & strTempFile & "."                 '         "
      '   Exit Sub                                                                                             '         "
      'End If                                                                                                  '         "
      'GetTextFile strTempFile, strTop, intSuccess
      GetRTFTextFromDB strTempFile, strTop, intSuccess  '06Dec16 TH Replaced (TFS 157969)

      If intSuccess = False Then
         'popmessagecr ".Error", "Problem loading the Roq and Rol Top rtf print file " & strTempFile & "."
         popmessagecr ".Error", "Problem loading the Roq and Rol Top rtf from database."
         Exit Sub
      End If
   
      strTop = Mid$(strTop, 1, Len(strTop) - 1) 'get rid of end "}" that terminates rtf file if left in
      
      MakeLocalFile strFile
      filno = FreeFile
      
      Open strFile For Binary Access Write Lock Write As filno
      DoEvents ' to release the cursor
      intPageCount = 1
      Heap 10, gPRNheapID, "rrPageNo", Format$(intPageCount), 0
               
      strPreParseTop = strTop
      PrinterParse strTop
      Put #filno, , strTop
      striprtf strTop

   End If


   '26Apr10 XN  F0058248 Added progress bar updates
   progressBar.Visible = True
   'progressBar.min = 1
   progressBar.min = 0  '26Jun14 TH Altered as was invalid max value on this if only 1 item in array (TFS 94282)
   progressBar.Max = UBound(RoqAndRolLines)
   'End of F0058248
   Screen.MousePointer = HOURGLASS
   For intCount = 1 To UBound(RoqAndRolLines)
      progressBar.Value = intCount  '26Apr10 XN F0058248 Added progress bar updates
      DoEvents                      '26Apr10 XN F0058248 Added progress bar updates
      
      'If blnIncludeNonUpdates Or (Not blnIncludeNonUpdates And Trim$(RoqAndRolLines(intCount, 2)) = "Y") Then     '08Mar07 PJC RoqAndRolLines array now stores position of drug.
      If blnIncludeNonUpdates Or (Not blnIncludeNonUpdates And RoqAndRolLines(intCount, 2) = -1) Then              '          "
         'd.siscode = Trim$(RoqAndRolLines(intCount, 1))                                                        '          "
         'getdrug d, 0, foundPtr&, blnUpdate = True And Trim$(RoqAndRolLines(intCount, 2)) = "Y"                '          "
         getdrug d, CLng(RoqAndRolLines(intCount, 1)), foundPtr&, False                                         '          "
         If foundPtr& <> 0 Then
            LSet dcopy = d
            If blnPrint Then
               If intLineCount = intLinesPerPage Then      'need a new page of the report
                  intLineCount = 0
                  strLineParsed = "[FF]"
                  PrinterParse strLineParsed
                  Put #filno, , strLineParsed

                  intPageCount = intPageCount + 1
                  Heap 10, gPRNheapID, "rrPageNo", Format$(intPageCount), 0
                  strTop = strPreParseTop
                  PrinterParse strTop
                  Put #filno, , strTop
               End If
               strLineParsed = strLine
               FillHeapDrugInfo gPRNheapID, d, 0
            End If
            If blnUpdate = True And RoqAndRolLines(intCount, 2) = -1 Then                                     '08Mar07 PJC Moved the locking of the drug from above
               getdrug d, CLng(RoqAndRolLines(intCount, 1)), foundPtr&, True                               '         "
            End If                                                                                         '         "
            RoqAndRolCalc d, lngRoq, lngRol 'Annual use is calculated here in d.anuse
      
            If blnPrint Then
               Heap 10, gPRNheapID, "rrsugreorderlevel", Format$(lngRol), 0
               Heap 10, gPRNheapID, "rrsugreorderquantity", Format$(lngRoq), 0
               Heap 10, gPRNheapID, "rrsugAnnualUseInt", Format$(d.anuse, "#0"), 0
               Heap 10, gPRNheapID, "rrsugAnnualUse", d.anuse, 0
               'Heap 10, gPRNHeapID, "rrupdateflag", Trim$(RoqAndRolLines(intCount, 2)), 0                 '08Mar07 PJC RoqAndRolLines array now stores position of drug.
               Heap 10, gPRNheapID, "rrupdateflag", Iff(RoqAndRolLines(intCount, 2) = -1, "Y", "N"), 0     '         "
               PrinterParse strLineParsed
               Put #filno, , strLineParsed
               intLineCount = intLineCount + 1
            End If

            'If blnUpdate = True And Trim$(RoqAndRolLines(intCount, 2)) = "Y" Then                            '08Mar07 PJC RoqAndRolLines array now stores position of drug.
            If blnUpdate = True And RoqAndRolLines(intCount, 2) = -1 Then                                     '         "
               d.reorderlvl = Format$(lngRol)
               d.reorderqty = Format$(lngRoq)
               putdrug d
               WriteRoqAndRolLabutils d, dcopy
            End If
         Else
            popmessagecr ".Error", d.SisCode & " : Item Not Found in drug file."
         End If
      End If
   Next
   progressBar.Visible = False  '26Apr10 XN F0058248 Added progress bar updates

   Screen.MousePointer = STDCURSOR
   If blnPrint Then
      strLineParsed = "}"
      Put #filno, , strLineParsed
      Close #filno
   
      WSspool strFile, "Roq and Rol", 1, True, False, "RoqAndRol"
   End If

   ClearRoqAndRollFromHeap

   If blnUpdate Then
      popmessagecr "#Roq and Rol", "Re-order level, Re-order quantity and Annual use update complete."
   End If

End Sub

Sub WriteRoqAndRolLabutils(dNew As DrugParameters, dOld As DrugParameters)
'16Jan07 PJC created (RR enh)
'09Sep08 TH  Merged from v8
'15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
Dim strInfo As String

   strInfo = pad$("Annual Use", 25) & " " & "Was : '" & Trim$(dOld.anuse) & "'"
   strInfo = strInfo & " Now : '" & Trim$(dNew.anuse) & "'"
   If Trim$(dNew.anuse) <> Trim$(dOld.anuse) Then
      'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & " " & strInfo
      WriteLogSQL strInfo, "labutils", 0, 0, d.SisCode  ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
   End If

   strInfo = pad$("Reorder Level", 25) & " " & "Was : '" & Trim$(dOld.reorderlvl) & "'"
   strInfo = strInfo & " Now : '" & Trim$(dNew.reorderlvl) & "'"
   If Trim$(dNew.reorderlvl) <> Trim$(dOld.reorderlvl) Then
      'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & " " & strInfo
      WriteLogSQL strInfo, "labutils", 0, 0, d.SisCode  ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
   End If
   
   strInfo = pad$("Reorder Quantity", 25) & " " & "Was : '" & Trim$(dOld.reorderqty) & "'"
   strInfo = strInfo & " Now : '" & Trim$(dNew.reorderqty) & "'"
   If Trim$(dNew.reorderqty) <> Trim$(dOld.reorderqty) Then
      'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & " " & strInfo
      WriteLogSQL strInfo, "labutils", 0, 0, d.SisCode  ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
   End If

   strInfo = pad$("Start of Period", 25) & " " & "Was : '" & Trim$(dOld.datelastperiodend) & "'"
   strInfo = strInfo & " Now : '" & Trim$(dNew.datelastperiodend) & "'"
   If Trim$(dNew.datelastperiodend) <> Trim$(dOld.datelastperiodend) Then
      'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & " " & strInfo
      WriteLogSQL strInfo, "labutils", 0, 0, d.SisCode  ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
   End If

   strInfo = pad$("Use This Period", 25) & " " & "Was : '" & Format$(dOld.usethisperiod) & "'"
   strInfo = strInfo & " Now : '" & Format$(dNew.usethisperiod) & "'"
   If dNew.usethisperiod <> dOld.usethisperiod Then
      'WriteLog rootpath$ + "\labutils.log", siteNumber, UserID$, d.SisCode & " " & strInfo
      WriteLogSQL strInfo, "labutils", 0, 0, d.SisCode  ' 15Nov13 XN Moved labutils.log to WPharmacyLog table 56701
   End If

End Sub

Sub ClearRoqAndRollFromHeap()
'16Jan07 PJC created (RR enh)
'09Sep08 TH  Merged from v8
   Heap 12, gPRNheapID, "rrsugreorderlevel", "", 0
   Heap 12, gPRNheapID, "rrsugreorderquantity", "", 0
   Heap 12, gPRNheapID, "rrsugAnnualUse", "", 0
   Heap 12, gPRNheapID, "rrsugAnnualUseInt", "", 0
   Heap 12, gPRNheapID, "rrupdateflag", "", 0
   Heap 12, gPRNheapID, "rrPageCount", "", 0

End Sub

Sub UpdateRoqAndRolArray(lngRow As Long, strValue As String)
'16Jan07 PJC Created (RR enh)
'08Mar07 PJC RoqAndRolLines array now stores position of drug.
'09Sep08 TH  Merged from v8

   'RoqAndRolLines(lngRow, 2) = strValue                    '08Mar07 PJC RoqAndRolLines array now stores position of drug.
   RoqAndRolLines(lngRow, 2) = Iff(strValue = "Y", -1, 0)   '        "
End Sub

Sub ExportRoqAndRol(frm As RoqAndRol, blnIncludeNonUpdates As Integer)
'16Jan07 PJC created (RR enh)
'08Mar07 PJC RoqAndRolLines array now stores position of drug.
'06Dec16 TH  Refactored RTF Handling (TFS 157969)
'17May17 TH  Enable template files to be hosted (TFS 174881)

'09Sep08 TH  Merged from v8
Dim intCount As Integer
Dim foundPtr&
Dim strFile As String
Dim strLine As String
Dim strLineParsed As String
Dim filno%
Dim strTempFile As String
Dim intSuccess As Integer
Dim strAnUse As String
Dim lngRol As Long
Dim lngRoq As Long
Dim strHeadLine As String
Dim strFilePath As String

   Const procname$ = "ExportRoqAndRol"

   'strTempFile = dispdata$ & "\" & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "HdrRqRl.txt", "CSVHeaderFile", 0))
   strTempFile = dispdata$ & "\" & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "HdrRqRl.rtf", "CSVHeaderFile", 0))
   'We will pretend the extension is rtf in order to get through the main libraries (TFS 174881)
   strTempFile = Trim$(strTempFile)
   If Mid$(strTempFile, (Len(strTempFile) - 4), 1) = "." Then
        strTempFile = Left$(strTempFile, Len(strTempFile) - 4) & ".rtf"
   End If
   'If fileexists(strTempFile) = False Then
   If RTFExistsInDatabase(strTempFile) = False Then '17May17 TH  Enable template files to be hosted (TFS 174881)
         popmessagecr ".Error", "Roq and Rol Export format file  " & strTempFile & " missing."
      Else
         'GetTextFile strTempFile, strHeadLine, intSuccess
         GetRTFTextFromDB strTempFile, strHeadLine, intSuccess  '06Dec16 TH Replaced (TFS 157969)

         
         If intSuccess = False Then
               popmessagecr ".Error", "Problem loading the Roq and Rol Export header file " & strTempFile & "."
            End If
      End If

   'strTempFile = dispdata$ & "\" & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "CSVRqRl.txt", "CSVFormatFile", 0))
   strTempFile = dispdata$ & "\" & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "CSVRqRl.rtf", "CSVFormatFile", 0))
   
   'We will pretend the extension is rtf in order to get through the main libraries (TFS 174881)
   strTempFile = Trim$(strTempFile)
   If Mid$(strTempFile, (Len(strTempFile) - 4), 1) = "." Then
        strTempFile = Left$(strTempFile, Len(strTempFile) - 4) & ".rtf"
   End If
   'If fileexists(strTempFile) = False Then
   If RTFExistsInDatabase(strTempFile) = False Then '17May17 TH  Enable template files to be hosted (TFS 174881)
         popmessagecr ".Error", "Roq and Rol Export format file  " & strTempFile & " missing."
         Exit Sub
      End If

   'GetTextFile strTempFile, strLine, intSuccess
   GetRTFTextFromDB strTempFile, strLine, intSuccess  '06Dec16 TH Replaced (TFS 157969)

   If intSuccess = False Then
         popmessagecr ".Error", "Problem loading the Roq and Rol Export format file " & strTempFile & "."
         Exit Sub
      End If
   
   MakeLocalFile strFile
   filno = FreeFile
   Screen.MousePointer = HOURGLASS
   On Error GoTo Err_Dialog
   Open strFile For Output Access Write Lock Write As filno
   DoEvents ' to release the cursor
   Print #filno, strHeadLine

   For intCount = 1 To UBound(RoqAndRolLines)
      'If blnIncludeNonUpdates Or (Not blnIncludeNonUpdates And Trim$(RoqAndRolLines(intCount, 2)) = "Y") Then   '08Mar07 PJC RoqAndRolLines array now stores position of drug.
      If blnIncludeNonUpdates Or (Not blnIncludeNonUpdates And RoqAndRolLines(intCount, 2) = -1) Then            '         "
            'd.siscode = Trim$(RoqAndRolLines(intCount, 1))                                                      '         "
            'getdrug d, 0, foundPtr&, False                                                                      '         "
            getdrug d, CLng(RoqAndRolLines(intCount, 1)), foundPtr&, False                                       '         "
            If foundPtr& <> 0 Then
                  strLineParsed = strLine
                  FillHeapDrugInfo gPRNheapID, d, 0
      
                  RoqAndRolCalc d, lngRoq, lngRol
      
                  Heap 10, gPRNheapID, "rrsugreorderlevel", Format$(lngRol), 0
                  Heap 10, gPRNheapID, "rrsugreorderquantity", Format$(lngRoq), 0
                  Heap 10, gPRNheapID, "rrsugAnnualUse", d.anuse, 0
                  Heap 10, gPRNheapID, "rrsugAnnualUseInt", Format$(d.anuse, "#0"), 0
                  'Heap 10, gPRNHeapID, "rrupdateflag", Trim$(RoqAndRolLines(intCount, 2)), 0                 '08Mar07 PJC RoqAndRolLines array now stores position of drug.
                  Heap 10, gPRNheapID, "rrupdateflag", Iff(RoqAndRolLines(intCount, 2) = -1, "Y", "N"), 0     '         "
                  ParseItems gPRNheapID, strLineParsed, 0
                  
                  Print #filno, strLineParsed
               Else
                  popmessagecr ".Error", d.SisCode & " : Item Not Found in drug file."
               End If
         End If
   Next
   Close #filno
   On Error GoTo 0
   Screen.MousePointer = STDCURSOR

   ClearRoqAndRollFromHeap

   'save the file to the required location
   frm.dlgRoqAndRol.Flags = &H4&
   frm.dlgRoqAndRol.CancelError = True
   Do
      strFilePath = Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", dispdata$ & "\", "ExportLocation", 0))
      frm.dlgRoqAndRol.InitDir = strFilePath
      frm.dlgRoqAndRol.Filter = Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "CSV (*.CSV)|*.CSV", "ExportFilter", 0))
      strFilePath = strFilePath & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", "RR", "ExportPrefix", 0))
      strFilePath = strFilePath & Format$(Now, "yy") & Format$(Now, "mm") & Format$(Now, "dd") & Trim$(TxtD$(dispdata$ & "\winord.ini", "RoqAndRol", ".CSV", "ExportExtension", 0))
      frm.dlgRoqAndRol.filename = strFilePath
      On Error GoTo Err_Dialog
      frm.dlgRoqAndRol.Action = 2
      On Error GoTo 0
   
      If frm.dlgRoqAndRol.filename = "" Then
            popmessagecr "!Roq and Rol Export", "No file selected for exporting."
         End If
      If fileexists(Trim$(frm.dlgRoqAndRol.filename)) = True Then
            popmessagecr "!Roq and Rol Export", "File already exists."
            frm.dlgRoqAndRol.filename = ""
         End If
   Loop While frm.dlgRoqAndRol.filename = ""
   strTempFile = frm.dlgRoqAndRol.filename
   On Error GoTo Err_Dialog
   FileCopy strFile, strTempFile
   On Error GoTo 0

Resume_Dialog:
   On Error Resume Next
   Kill strFile
   Close #filno
   On Error GoTo 0
   Exit Sub

Err_Dialog:
   If Err = 32755 Then                 'cancel on the dialog
         Resume Resume_Dialog
      Else
         Screen.MousePointer = STDCURSOR
         popmessagecr ".Roq and Rol Export", "Error: " & Error$ & " in procedure " & procname$ & ". Export cancelled."
         Resume Resume_Dialog
      End If
   
End Sub

Sub LogViewer()
'-----------------------------------------------------------------------------
'                       LOGFILE VIEWER & EDITOR V1.0
'                       ----------------------------
'24Mar94 CKJ Orderlog viewer added
'31Mar94 CKJ Transaction viewer added
' 9Aug95 CKJ Extract transactions to a file
'14Sep95 CKJ View Labutils.log, editors.log & others too
'            Can also change output name in one session
'DOStoWIN V1.0 (c) ASCribe 1996
' 5Aug97 CKJ Converted from DOS, crude port with no refinements yet
'            Does not include viewer for individual transactions
'            NB No error handling yet and cannot interrupt the search.
'15Oct97 CKJ Corrected old translog name from 'TLOG' to 'TRAN'
'            and replaced fixed path with global variables
'29oct03 CKJ Removed transactionID from new style transactions

'21Jun11 TH  (F0102523) Ported form v8 stkmaint to allow look up of file based logs.
'            Removed order/translogs, prob needs encancing for other logs, then converting (with writelog (!) to use DB storage
'18Mar12 TH  (TFS) Added PN Edit log to allowable selection
'26Sep12 TH  Added P as valid char for PN Edit log (TFS 45179 )
'07Mar14 TH  Now access new stuff from DB (Labutils) (TFS 75625)
'03Apr14 TH  Added to allow for the fact labutils.log may have been removed (TFS 87805)
'06Apr17 TH  Stopped check on file - allow access to DB only logging.
'06Apr17 TH  Removed Editors log - its now obselete.
            
'-----------------------------------------------------------------------------
Dim Logview As String, logto$, lastlog$, vchan%, oChan%, msg$, LogType$, yyyymm$, search$
Dim length%, FILE$, fil%, pointer&, recno&, recnum$, temp$, posn%, vfile$

'Dim O As orderlogstruct, t As transaction   '5Aug97 CKJ Added
Dim blnRemoveTransactionID As Integer       '29oct03 CKJ
Dim rsLog As ADODB.Recordset
Dim LogName As String

   Logview = "Log File Viewer"
   
   Do
      recno& = 0 '06Apr17 TH re-initialise on multiple passes
      k.escd = False
      lastlog$ = logto$
      k.min = 0
      k.Max = 20
''      msg$ = "Select Output destination" & cr & cr
''      msg$ = msg$ & "  Enter drive, path and file name" & cr
''      msg$ = msg$ & "  'PRN' for default printer" & cr
''      msg$ = msg$ & "  'LPT1', 'LPT2' or 'LPT3' for specific printer" & cr
''      msg$ = msg$ & "  Leave blank for output to screen"
''      inputwin Logview, msg$, logto$, k
      'If k.escd Then Exit Do
 '     If logto$ = "" Then Print "Screen only";
      
      If logto$ <> lastlog$ And lastlog$ <> "" Then
            If oChan Then Close oChan
            oChan = 0
         End If

      'If logto$ <> lastlog$ And logto$ <> "" Then
      '      oChan = FreeFile
      '      On Error GoTo LogViewer_Err
      '      Open logto$ For Append Shared As #oChan
      '      On Error GoTo 0
      '   End If

      If Not k.escd Then
         msg$ = "Enter Log File to view" & cr & cr
         'msg$ = msg$ & " (S)tock maintenance" & cr   '02Apr17 TH Why was this removed ? Because now webside
         msg$ = msg$ & " Escape from (I)ssue prompt" & cr
         msg$ = msg$ & " (R)econciliation out of limits" & cr
         'msg$ = msg$ & " (E)ditors" & cr
         'msg$ = msg$ & " Issues into (N)egative stock" & cr '02Apr17 TH Why was this removed ? Because now webside
         msg$ = msg$ & " (P)N Edit"
         'k.validchars = "SREIN"
         k.validchars = "SREINP"  '26Sep12 TH Added P for PN Edit log (TFS 45179 )
         k.min = 1
         k.Max = 1
         InputWin Logview, msg$, LogType$, k
      End If

      
      If Not k.escd Then
         k.min = 0
         k.Max = 12
         InputWin Logview, "Enter text to search for (press [Return] for all)", search$, k
         search$ = UCase$(search$)
      End If

      If Not k.escd Then
         blnRemoveTransactionID = False                     '29oct03 CKJ
         Select Case LogType$
            Case "S": FILE$ = rootpath$ & "\labutils.log": LogName = "labutils"
            Case "R": FILE$ = rootpath$ & "\reconcil.log": LogName = "reconcil"
            Case "E": FILE$ = dispdata$ & "\editors.log": LogName = "editors"
            Case "I": FILE$ = dispdata$ & "\escissue.log": LogName = "escissue"
            Case "N": FILE$ = dispdata$ & "\negative.log": LogName = "negative"
            Case "P": FILE$ = dispdata$ & "\pnedit.log": LogName = "pnedit"
            Case Else
               Exit Do
         End Select

         'If fileexists(FILE$) Or LogType$ = "S" Then '03Apr14 TH Added (TFS 87805) Allow S types through as the file may have been removed legitimately. '06Apr17 TH Removed check on file share
            Screen.MousePointer = HOURGLASS              '15Oct97 CKJ added
            MakeLocalFile vfile$
            vchan = FreeFile
            Open vfile$ For Output As #vchan             'output channel for viewing
            fil = FreeFile
            'If fileexists(FILE$) Then  '03Apr14 TH Added (TFS 87805)
            If fileexists(FILE$) And Not (TrueFalse(TxtD(dispdata$ & "\siteinfo.ini", "Logging", "Y", "WritelogtoDB", 0))) Then  '13Apr17 TH Only look for files if not set to write to DB
                Open FILE$ For Input Shared As #fil
                pointer& = LOF(fil)
                'Print #vchan, " File size =" & Str$(pointer&) & " bytes" & crlf & crlf;  '02Apr17 TH Removed as now we are not really looking at files
                       
                '!!** would like a progress bar here
                For recno& = 2 To pointer&
                   recnum$ = Trim(Str$(recno&))
                   
                         Line Input #fil, temp$
                   
                   Do
                      posn = InStr(temp$, Chr$(0))
                      If posn Then Mid$(temp$, posn, 1) = " "
                   Loop While posn
                   If InStr(UCase$(temp$), search$) Then
                      Print #vchan, Format$(recno& - 1, "00000  ");
                      
                      If Right$(temp$, 1) = Chr$(13) Then temp$ = Left$(temp$, Len(temp$) - 1)
                      Print #vchan, RTrim$(temp$) & crlf;
                      If oChan Then
                         Print #oChan, RTrim$(temp$)
                      End If
                   End If
                   If EOF(fil) Then Exit For
            
                Next
            Else
               recno& = 1 '06Apr17 TH Initialise for pure DB run
            End If
            
            '07Mar14 TH Now access new stuff from DB (Labutils) (TFS 75625)
            'If LogType$ = "S" Then '02Apr17 TH All logs now in DB (TFS )
               'Set rsLog = ReadLogSQL("labutils")
               Set rsLog = ReadLogSQL(LogName, Iff(InStr(LCase(FILE$), "ascroot") > 0, True, False)) 'Allow cross site log view (TFS 175557)
               If Not rsLog Is Nothing Then
                  If Not rsLog.EOF Then
                     
                     Do While Not rsLog.EOF
                     'build the line
                     temp$ = Format(RtrimGetField(rsLog!DateTime), "dd/mm/yyyy HH:nn:ss") & " " & Format$(RtrimGetField(rsLog!SiteNumber), "000 ") & pad$(RtrimGetField(rsLog!initials), 4) & " " & RtrimGetField(rsLog!NSVCode) & " " & RtrimGetField(rsLog!Detail)
                     If InStr(UCase$(temp$), search$) Then
                        'temp$ = Format$(recno&, "00000  ") & temp$
                        'yes lest process
                        recno& = recno& + 1
                        Print #vchan, Format$(recno& - 1, "00000  ");
                        replace temp$, Chr$(0), "", 0
                        replace temp$, cr, "", 0
                        replace temp$, lf, "", 0
                        replace temp$, crlf, "", 0
                        replace temp$, TB, "", 0
                        If Right$(temp$, 1) = Chr$(13) Then temp$ = Left$(temp$, Len(temp$) - 1)
                        Print #vchan, RTrim$(temp$) & crlf;
                        If oChan Then
                           Print #oChan, RTrim$(temp$)
                        End If
                     End If
                     rsLog.MoveNext
                     Loop
                     '----
                  End If
                  rsLog.Close
                  Set rsLog = Nothing
               End If
            'End If
            '------------------
            Close fil
            Close vchan
            
            Screen.MousePointer = STDCURSOR              '15Oct97 CKJ added
            Hedit 111, vfile$        'edit plain text file
            Kill vfile$
         '06Apr17 TH Removed check on file share
         'Else
         '   popmessagecr "", "File " + FILE$ + " not found"
         'End If
      End If
   Loop While Not k.escd
   
   If oChan Then Close oChan
   k.escd = False   '13Jun98 ASC

Exit Sub

LogViewer_Err:
   popmessagecr "Log File Viewer", "Cannot open output destination:" & cr & Str$(Err) & ": " & Error$
   oChan = 0
Resume Next
End Sub
