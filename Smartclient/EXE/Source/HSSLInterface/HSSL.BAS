Attribute VB_Name = "HSSL"
'----------------------------------------------------------------------------------------
'                                  HSSL Interface
'----------------------------------------------------------------------------------------
'Modification History
'14Dec01 TH  OrderlineParse: Added local code as printable element (#53478)
'14Dec01 TH  Incremented release number
'14Dec01 TH  Built for testing
'24Jul02 TH  Changed above mod as using wrong code (#53478)
'13Nov08 CKJ Ported from V9.8 to V10.0
'            Set DefBool which identified untyped params in BuildOrderFiles
'              and untyped array sitenos()
'            Added MSCAPI class
'            Removed unused components & references
'              MSDE.DLL Microsoft Data Environment 1.0
'              FPole.ocx 1.0 (Fox Pro OLE Type Library)
'              OLE Automation
'              High Edit Pro control (second reference)
'            Removed unused modules
'              debug.frm
'              FTPfrm.frm
'              WDCTFRM.FRM
'              Wdctimp.bas
'              ContractEditor
'            Removed unused procedures
'              DCTPrintExceptions
'              ParseDataItems
'              ReadWSLDefaults (note duplicated in HSSLPTR.bas)
'              ShowInfo
'              LoadBNF
'              EditDirections
'            Removed PhaRTL & brought in the CAPI authentication
'            Renamed HSSL.exe to HSSLInterface.exe
' 09Apr10 XN F0068649 EDI orders have seprate max number of lines per an order
' 24Apr13 XN Main: Changed connection string encryption seed to work on any PC (60910)
'
'Mods:
'  Consider using alternative to C:\ for files as terminal may be locked down at the root
'    => localpath in a future version
'  Config settings used to be on high level password
'/ Print message identical whether printing or not
'  Shutdown of program does not destroy objects cleanly
'----------------------------------------------------------------------------------------

Option Explicit
DefBool A-Z

''Declare Function HEPrintDocParamHwndAbortDlg Lib "HEVB.VBX" (ByVal Hwnd%, ByVal iStartPage%, ByVal iEndPage%, ByVal hWndHead%, ByVal hWndFoot%, ByVal lpDocTitle$, ByVal iPageCounter%) As Integer

Type HSSL_Header
   Marker As String * 1         'constant 'H'
   HSSOrdNo As String * 9       'for future use
   CustCode As String * 8
   custordno As String * 10
   DateOfOrder As String * 6    'ddmmyy
   DateRequired As String * 6   'Default to order date
   ContactNo As String * 20
   numoflines As String * 3
   OrderValue As String * 8     'for future use
   'OrderGST As String * 8       'for future use
End Type

Type HSSL_Line
   Marker As String * 1         'Constant "L"
   lineno As String * 3         '1-999
   ProdCode As String * 15      'Health Support Code
   OrderedQty As String * 8     'no fractions
   DeliveredQty As String * 8   'for future use
   BackOrderQty As String * 8   'for future use
   DueDate As String * 6        'for future use
   ExpenseCode As String * 14
   ExtraDesc As String * 50
   UnitPrice As String * 8      '9999999 asssumes last two decimals
   LineValue As String * 8
End Type

Type HSSL_Trailer
   Marker As String * 1
   NumOfOrders As String * 3
   TotalLines As String * 6
End Type

Global Const AppIniFile$ = "\HSSL.INI"
'Global Const AppVerNo$ = "Version 1.0b Beta"   '14Dec01 TH incremented release no
'Global Const AppVerNo$ = "Version 1.2b Beta"   '11Dec03 TH Moved from 1.1b to 1.2b
'Global Const AppVerNo$ = "Version 2 Beta"      '11Dec03 TH Moved from 1.1b to 1.2b
Global Const AppVerNo$ = "Version 10"           '14Nov08 CKJ converted to V10

Global Const modulename$ = "HSSL.BAS"
Global Const ASCOrdFile$ = "c:\hsslordr.txt"
Global Const ASCS29File$ = "c:\hssls29s.txt"
Global Const ASCCdFile$ = "c:\hsslcds.txt"

Global AppTitle$
Global AppPrintConfirmation%

'for compatability with orderlib.bas
Global supnotes$, ordernum$, OSite$
Global Reprintno%, Storepasslvl%, edittype%
Global sitenos() As Integer      '13Nov08 CKJ Added type declaration
Global sitepth$()
'---

Global HsslCdCode$, HsslS29Code$
Global HostIPAddr$, FTPUserName$, FTPPassword$
Global HSSLOrdFile$, HsslS29File$, HsslCdFile$
Global HSSLCustCode$, HSSLContactCode$

Global g_adoCn As ADODB.Connection  'V93 SQL
Global g_SessionID As Long          '   "
Global gTransport As PharmacyData.Transport
Global gRequestID_Prescription As Long
Global gRequestID_Dispensing As Long
Global gEntityID_User As Long

Global lngReprintno As Long
Global catno As String

Dim CDProds&()
Dim S29Prods&()

Dim ord As orderstruct
Dim ShowDebug%
Dim fullname$
'

''Dim stocklini$
''Dim PageLen As Integer
''Dim HdrALen As Integer
''Dim HdrBLen As Integer
''Dim DrugLen As Integer
''Dim BCodeLen As Integer
''Dim SectLen As Integer
''Dim FootLen As Integer
''Dim SignLen As Integer


Sub BuildOrderFiles(DoCds As Integer, DoS29s As Integer)
'
' DBP 20Jun98 - Quick Fix: The order qty comming through from orders
'               automatically raised is blank.  The interim fix for this
'               is to use the qty from the QtyOutstanding field if the
'               QtyOrdered is blank.  The real problem within automatic
'               order creation should be fixed; however, no time for this
'               at the moment.
'13Nov08 CKJ Corrected definition - added type declaration
                                                   
Dim HsslHdr As HSSL_Header
Dim HsslLine As HSSL_Line
Dim HsslEnd As HSSL_Trailer

Dim loopvar1%, match%, FoundSup%, chan%, ErrNum%, Loopvar2%, TotalLines%, founddrug&, edittype%, NumOfOrders%, lineno%     '26Jul02 Th Converted founddrug to long
Dim supcode$, dbg$, OwnSiteNo$, currentsup$, item$, LocalFile$, NoOrdersMsg$, temp$, desc$, LastOrderNum$, cost$
Dim pointer&, x&, ordptr&
Dim ordqty!
ReDim OrderLines%(1)
ReDim OrderVal!(1)
Dim rsOrders As ADODB.Recordset
Dim strParams As String

   DoS29s = False
   DoCds = False

   For loopvar1 = 1 To 2
      
      Do While MultiList.LstUnselected.ListCount
         MultiList.LstUnselected.RemoveItem 0
      Loop
   
      If loopvar1 = 1 Then
            supcode$ = HsslS29Code$
            LocalFile$ = ASCS29File$
            NoOrdersMsg$ = "No S29 items found to be ordered."
            HSSLScreenOutput "Searching for S29 items..."
         Else
            supcode$ = HsslCdCode$
            LocalFile$ = ASCCdFile$
            NoOrdersMsg$ = "No CD items found to be ordered."
            HSSLScreenOutput "Searching for CD items..."
         End If

      edittype = 1
      currentsup$ = ""
      FoundSup = 0
      OwnSiteNo$ = Right$("000" + LTrim$(Str$(SiteNumber)), 3)
      LastOrderNum$ = ""
      NumOfOrders = 0

      If ShowDebug Then popmessagecr "Debug", "Using drive - " & CurDir$ & cr$ & "Using " & dispdata$
      'getnumofords 1, pointer&, False
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("InternalMethod", trnDataTypeVarChar, 1, "E") & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, UCase$(Trim$(supcode$))) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "2")
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbySiteandInternalMethodandSupcodeandStatus", strParams)
      If rsOrders.RecordCount > 0 Then
         rsOrders.MoveFirst
         Do While Not rsOrders.EOF
         'For x& = 2 To pointer&
            'getorder ord, x&, 1, False        ' (no idx)
            ord = FillOrdFromRS(rsOrders, "WOrder")
            ordqty! = Val(ord.qtyordered)
            If RTrim$(ord.qtyordered) = "" Then
               ordqty! = Val(ord.outstanding)
            End If
   
            If ShowDebug Then
               match% = ord.status = "2" And UCase$(ord.internalmethod) = "E" And UCase$(Trim$(ord.supcode)) = UCase$(Trim$(supcode$))
               dbg$ = "Order Number = " & ord.num & cr$
               dbg$ = dbg$ & "Order Status = " & ord.status & cr$
               dbg$ = dbg$ & "Internal Method = " & ord.internalmethod & cr$
               dbg$ = dbg$ & "Order Supplier Code = ¦" & UCase$(Trim$(ord.supcode)) & "¦" & cr$
               If match Then
                  dbg$ = dbg$ & "Match found"
               Else
                  dbg$ = dbg$ & "No Match found"
               End If
               popmessagecr "Debug", dbg$
            End If
            If ord.status = "2" And UCase$(ord.internalmethod) = "E" And UCase$(Trim$(ord.supcode)) = UCase$(Trim$(supcode$)) Then
               d.SisCode = ord.Code
               getdrug d, 0, founddrug, False
               If Val(d.contprice) > 0 Then
                  cost$ = d.contprice
               Else
                  If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then '21Jul95 CKJ
                     cost$ = d.sislistprice 'price last paid
                  Else
                     cost$ = d.cost
                  End If
               End If
               
               If Trim$(d.local) = "" Then
                  HSSLScreenOutput " ...ERROR: " & d.SisCode & " does not have the HSSL Product code stored in the Local Field,"
                  HSSLScreenOutput "                 this item will not be ordered until this  is corrected."
               Else
                  'Item$ = UCase$(OwnSiteNo$ & ord.supcode & ord.num & Str$(x&))
                  item$ = UCase$(OwnSiteNo$ & ord.supcode & ord.num & Str$(ord.OrderID))
                  MultiList.LstUnselected.AddItem item$
            
                  If Trim$(ord.num) = LastOrderNum$ Then
                     OrderLines(NumOfOrders) = OrderLines(NumOfOrders) + 1
                     'OrderVal!(NumOfOrders) = OrderVal!(NumOfOrders) + (Val(cost$) * Val(ord.QtyOrdered))
                     OrderVal!(NumOfOrders) = OrderVal!(NumOfOrders) + (Val(cost$) * ordqty!)
                  Else
                     NumOfOrders = NumOfOrders + 1
                     ReDim Preserve OrderLines(NumOfOrders)
                     ReDim Preserve OrderVal!(NumOfOrders)
                     OrderLines(NumOfOrders) = 1
                     'OrderVal!(NumOfOrders) = (Val(cost$) * Val(ord.QtyOrdered))
                     OrderVal!(NumOfOrders) = (Val(cost$) * ordqty!)
                  End If
               
                  LastOrderNum$ = Trim$(ord.num)

               End If

            End If
            'Next
            rsOrders.MoveNext 'oops, quite important this really !!
         Loop
      End If

      TotalLines = MultiList.LstUnselected.ListCount
      If TotalLines > 0 Then
         NumOfOrders = 0
         LastOrderNum$ = ""

         chan = FreeFile
         Do
            On Error GoTo LockError
            ErrNum = 0
            Open LocalFile$ For Output Lock Read Write As #chan
            Err70msg ErrNum, LocalFile$
         Loop While ErrNum
         On Error GoTo 0
         
         If loopvar1 = 1 Then
            ReDim S29Prods&(0 To TotalLines - 1)
         Else
            ReDim CDProds&(0 To TotalLines - 1)
         End If

         'Write the order lines
         For Loopvar2 = 0 To (TotalLines - 1)

            ordptr& = Val(Mid$(MultiList.LstUnselected.List(Loopvar2), 14))
            getorder ord, ordptr&, edittype, False

            ordqty! = Val(ord.qtyordered)
            If RTrim$(ord.qtyordered) = "" Then
               ordqty! = Val(ord.outstanding)
            End If

            If Trim$(ord.num) <> LastOrderNum$ Then
                        
               NumOfOrders = NumOfOrders + 1
               lineno = 0
               
               'Write the Header line
               r.record = ""
               LSet HsslHdr = r

               HsslHdr.Marker = "H"
               HsslHdr.CustCode = HSSLCustCode$
               HsslHdr.custordno = Trim$(ord.num)
               HsslHdr.DateOfOrder = Format$(date, "ddmmyy")
               HsslHdr.DateRequired = HsslHdr.DateOfOrder
               HsslHdr.ContactNo = HSSLContactCode$
               HsslHdr.numoflines = Right$(Space$(Len(HsslHdr.numoflines)) & Format$(OrderLines(NumOfOrders), "#;-#;0"), Len(HsslHdr.numoflines))
               HsslHdr.OrderValue = Right$(Space$(Len(HsslHdr.OrderValue)) & Format$(OrderVal!(NumOfOrders), "#;-#;0"), Len(HsslHdr.OrderValue))
               LSet r = HsslHdr
               temp$ = Left$(r.record, Len(HsslHdr))
               Print #chan, temp$

            End If
                  
            LastOrderNum$ = Trim$(ord.num)

            'Add item to list of items to be printed
            If loopvar1 = 1 Then
               S29Prods&(Loopvar2) = ordptr&
               DoS29s = True
            Else
               CDProds&(Loopvar2) = ordptr&
               DoCds = True
            End If

            d.SisCode = ord.Code
            getdrug d, 0, founddrug, False
            desc$ = Trim$(d.LabelDescription)  ' desc$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
            plingparse desc$, "!"
            
            HSSLScreenOutput " ...Adding " & desc$
            'Blank HSSL line record
            
            r.record = ""
            LSet HsslLine = r
            
            lineno = lineno + 1
            HsslLine.Marker = "L"
            HsslLine.lineno = Right$(Space$(Len(HsslLine.lineno)) & Format$(lineno, "#;-#;0"), Len(HsslLine.lineno))
            HsslLine.ProdCode = Trim$(d.local)
            'HsslLine.OrderedQty = Right$(Space$(Len(HsslLine.OrderedQty)) & Format$(Val(ord.QtyOrdered) * Val(d.convfact), String$(Len(HsslLine.OrderedQty), "#,-#,0")), Len(HsslLine.OrderedQty))
            HsslLine.OrderedQty = Right$(Space$(Len(HsslLine.OrderedQty)) & Format$(ordqty! * Val(d.convfact), String$(Len(HsslLine.OrderedQty), "#,-#,0")), Len(HsslLine.OrderedQty))
            HsslLine.ExpenseCode = Trim$(Left$(d.ledcode, Len(HsslLine.ExpenseCode)))
            HsslLine.ExtraDesc = Left$(desc$, Len(HsslLine.ExtraDesc))
                  
            If Val(d.contprice) > 0 Then
               cost$ = d.contprice
            Else
               If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then '21Jul95 CKJ
                     cost$ = d.sislistprice 'price last paid
                  Else
                     cost$ = d.cost
                  End If
            End If
                  
            HsslLine.UnitPrice = Right$(Space$(Len(HsslLine.UnitPrice)) & Format$(Val(cost$) / Val(d.convfact), "#;#;0"), Len(HsslLine.UnitPrice))
            'HsslLine.LineValue = Right$(Space$(Len(HsslLine.LineValue)) & Format$(Val(cost$) * Val(ord.QtyOrdered), "#;-#;0"), Len(HsslLine.LineValue))
            HsslLine.LineValue = Right$(Space$(Len(HsslLine.LineValue)) & Format$(Val(cost$) * ordqty!, "#;-#;0"), Len(HsslLine.LineValue))

            LSet r = HsslLine
            temp$ = Left$(r.record, Len(HsslLine))
            Print #chan, temp$
            
         Next

         'Write the trailer line
         HsslEnd.Marker = "T"
         HsslEnd.NumOfOrders = Right$(Space$(Len(HsslEnd.NumOfOrders)) & Format$(NumOfOrders, "#;-#;0"), Len(HsslEnd.NumOfOrders))
         HsslEnd.TotalLines = Right$(Space$(Len(HsslEnd.TotalLines)) & Format$(TotalLines, "#;-#;0"), Len(HsslEnd.TotalLines))
         
         LSet r = HsslEnd
         temp$ = Left$(r.record, Len(HsslEnd))
         Print #chan, temp$
               
         'close the interface file
         Close #chan

      Else
         HSSLScreenOutput NoOrdersMsg$
      End If
        
      Unload MultiList

   Next   'CDs or S29s Loop

Exit Sub

LockError:
   Select Case Err
      Case 70, 63
         Resume Next
      End Select
   
   ErrNum = Err
   popmsg "Error", "Halt in BuildOrderFiles with error " & ErrNum & " ; " & Error$(ErrNum), 16, "", 0
   Exit Sub
End

End Sub

Sub CheckHSSLSettings(CtrlIndex%)

Dim msg$, supcode$

   Select Case CtrlIndex
      Case 0         'OK button selected
         If Trim$(Ques.txtQ(11).text) <> "" And Trim$(Ques.lblInfo(2).Caption) <> "" And Trim$(Ques.lblInfo(3).Caption) <> "" And Trim$(Ques.txtQ(6).text) <> "" And Trim$(Ques.txtQ(7).text) <> "" And Trim$(Ques.txtQ(8).text) <> "" And Trim$(Ques.txtQ(11).text) <> "" And Trim$(Ques.txtQ(12).text) <> "" Then
               SaveHSSLDefaults
            Else
               Ques.Tag = ""
               popmessagecr "!" & AppTitle$, "Could not save the defaults - some entries are missing."
            End If

      Case 2, 3
         Select Case CtrlIndex
            Case 2
               msg$ = "Select supplier code for HSSL S29 Drug Orders."
            Case 3
               msg$ = "Select supplier code for HSSL Controlled Drug Orders."
         End Select

         asksupplier supcode$, 0, "SE", msg$, False, sup
         
         If Trim$(supcode$) <> "" Then Ques.lblInfo(CtrlIndex).Caption = supcode$

      Case 6 To 8, 11
         If Trim$(Ques.txtQ(CtrlIndex).text) = "" Then
               Select Case CtrlIndex
                  Case 6
                     msg$ = "You must enter the TCP/IP address of the HSSL Host machine."
                  Case 7
                     msg$ = "You must enter a FTP user name."
                  Case 8
                     msg$ = "You must enter a password."
                  Case 11
                     msg$ = "You must enter a HSSL Customer Number."
               End Select
               popmessagecr "!" & AppTitle$, msg$
            End If
      Case Else
   End Select

End Sub

Sub CreateOrderFiles(DoS29s%, DoCds%)

Dim printed%
   
   BuildOrderFiles DoCds, DoS29s
   
   DoEvents
   'FreeLocks

   If DoS29s Then
         HSSLScreenOutput ""
         If AppPrintConfirmation Then
               HSSLScreenOutput "Printing confirmation sheets for S29 orders."
            Else
               HSSLScreenOutput "Processing S29 orders."
            End If
         PrintHSSLConfirmationSheet 1, printed%
         DoS29s = printed%
         If Not printed Then
               HSSLScreenOutput "Printing cancelled - S29 orders will not be sent."
               Kill ASCS29File$
            End If
      End If

   If DoCds Then
         HSSLScreenOutput ""
         If AppPrintConfirmation Then
               HSSLScreenOutput "Printing confirmation sheets for CD orders."
            Else
               'HSSLScreenOutput "Printing confirmation sheets for CD orders."
               HSSLScreenOutput "Processing CD orders."                                      '14Nov08 CKJ amended
            End If
         PrintHSSLConfirmationSheet 2, printed%
         DoCds = printed%
         If Not printed Then
               HSSLScreenOutput "Printing cancelled - CD orders will not be sent."
               Kill ASCCdFile$
            End If
      End If

End Sub

Sub DoseFromKg(dummy$)

End Sub

Sub DoseFromMsq(dummy$)

End Sub

Sub getprintpath(dummy1$, dummy2%)

End Sub

Sub HSSLScreenOutput(msg As String)

   PWLFrm.LstDisplay.AddItem msg$
   PWLFrm.LstDisplay.ListIndex = PWLFrm.LstDisplay.ListCount - 1

End Sub

Sub HSSLSetup()

   QuesCallbackMode = 1
   
   Ques.Caption = "Setup Details"
   
   QuesMakeCtrl 1, 0
   Ques.lblDesc(1).Caption = "HSSL Supplier Codes"
   Ques.lblDesc(1).FontUnderline = True
   
   QuesMakeCtrl 2, 2
   Ques.lblDesc(2) = "Supplier Code for S29 Drug Orders."
   Ques.lblInfo(2) = Trim$(HsslS29Code$)
   QuesSetCtrl Ques.cmdQ(2), 0, 0, "Change"
   
   QuesMakeCtrl 3, 2
   Ques.lblDesc(3) = "Supplier Code for Controlled Drug Orders."
   Ques.lblInfo(3) = Trim$(HsslCdCode$)
   QuesSetCtrl Ques.cmdQ(3), 0, 0, "Change"

   
   QuesMakeCtrl 5, 0
   Ques.lblDesc(5).Caption = "FTP Settings"
   Ques.lblDesc(5).FontUnderline = True

   QuesMakeCtrl 6, 1
   Ques.lblDesc(6) = "Remote FTP Machine IP Address"
   QuesSetCtrl Ques.txtQ(6), 11, 15, Trim$(HostIPAddr$)

   QuesMakeCtrl 7, 1
   Ques.lblDesc(7) = "Remote FTP User Name"
   QuesSetCtrl Ques.txtQ(7), 0, 15, Trim$(FTPUserName$)
   'QuesSetCtrl Ques.txtQ(7), 0, 50, Trim$(FTPUserName$)

   QuesMakeCtrl 8, 1
   Ques.lblDesc(8) = "Remote FTP Password"
   QuesSetCtrl Ques.txtQ(8), 0, 15, Trim$(FTPPassword$)

   QuesMakeCtrl 10, 0
   Ques.lblDesc(10).Caption = "HSSL Order Settings"
   Ques.lblDesc(10).FontUnderline = True

   QuesMakeCtrl 11, 1
   Ques.lblDesc(11) = "HSSL Customer Number"
   QuesSetCtrl Ques.txtQ(11), 0, 8, Trim$(HSSLCustCode$)

   QuesMakeCtrl 12, 1
   Ques.lblDesc(12) = "HSSL Contact/User Code"
   QuesSetCtrl Ques.txtQ(12), 0, 20, Trim$(HSSLContactCode$)

   QuesShow 12
   Unload Ques

End Sub

Sub Main()
'14Nov08 CKJ Swapped PhaRTL for Token handling
'24Apr13 XN  Changed connection string encryption seed to work on any PC (60910)

Dim ans$, SaveTitle$, StockList$, StockExt$
Dim valid%, passwordlvl%, escd%, found%

'Dim Phartl As PHARTL10.Security    '14Nov08 CKJ removed
Dim strParams As String
Dim rs As ADODB.Recordset

Dim phase As Single
Dim Detail As String

   If App.PrevInstance Then
         Close
         End
      End If
   
'   frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)      '14Nov08 CKJ added
   frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
   
''   If Not fileexists(dispdata$ + stockmdb$) Then
''         popmsg AppTitle$, "Stock Control Database file is missing." & Chr$(13) & "Please inform your System Manager" & Chr$(13) & Chr$(13) & "This program will now terminate.", 16, ans$, escd%
''         Close
''         End
''      End If
''
''    StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
''    If Trim$(StockExt$) = "" Then
''            StockList$ = dispdata$
''        Else
''            StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
''        End If
''    Set WSDB = OpenDatabase(StockList$ + stockmdb$)
''    Set SUPDB = OpenDatabase(dispdata$ + stockmdb$)
''
''   askpassword valid%, fullname$, AppTitle$

''   If Not valid Then End
''
''   passwordlvl = Val(Mid$(acclevels$, 6, 1))
''
''   Select Case passwordlvl
''      Case 3
''         PWLFrm.MnuSetupTop.Enabled = False
''      Case 8
''         PWLFrm.MnuSetupTop.Enabled = True
''      Case Else
''         popmsg modulename$, "Sorry - your password does not have authority to use this Interface.", 64, ans$, escd%
''         End
''   End Select
   
   g_SessionID = Val(Mid$(Command$, (InStr(1, Command$, "/SID", vbBinaryCompare)) + 4))
   SiteNumber = Val(Left$(Command$, InStr(1, Command$, "/SID", vbBinaryCompare)))
   
'~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~
'SiteNumber =
'g_SessionID =
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
           
   'Set Phartl = New PHARTL10.Security    '14Nov08 CKJ removed

   Set gTransport = New PharmacyData.Transport
   Set g_adoCn = New ADODB.Connection
   'g_adoCn.ConnectionString = Phartl.GetConnectionString(g_SessionID)                          '14Nov08 CKJ removed
   phase = 1                                                                                    '   "        added block
   g_adoCn.ConnectionString = ParseCommandURLToken(g_SessionID, (Command), phase, Detail)
   If Len(Detail) Then
      MsgBox "Unable to connect to database" & cr & "Phase " & Format$(phase) & "  " & Detail, vbCritical + vbOKOnly, "HSSL Interface"
      Close
      End
   End If

   g_adoCn.Open
   'Set Phartl = Nothing                  '14Nov08 CKJ removed
   Set gTransport.Connection = g_adoCn
     
   If SiteNumber = 0 Then
      MsgBox "Application has been called with no site number." & _
      crlf & "Please check with your system supervisor." & _
      crlf & crlf & "This application cannot continue"
      Close
      End
   End If
   
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
      
   gTransport.ADOSetConnectionTimeOut (TxtD(dispdata$ & "\siteinfo.ini", "Connection", "5000", "ConnectionTimeout", found))
   
   ReadSiteInfo
   ReadHSSLDefaults
   ReadOrdData
   
''   StockExt$ = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StockDataExt", found)
''   If Trim$(StockExt$) = "" Then
''      StockList$ = dispdata$
''      gWardStockSite = gDispSite
''   Else
''      StockList$ = Left$(dispdata$, Len(dispdata$) - 3) & Right$("000" & StockExt$, 3)
''      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, Val(StockExt$))
''      gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
''   End If
   
   App.HelpFile = "Stores.hlp"
   
   Storepasslvl = Val(Mid$(Command$, (InStr(1, Command$, "/STRPASS", vbBinaryCompare)) + 8, 1))

   If InStr(UCase$(Command$), "/DEBUG") Then ShowDebug = True

   PWLFrm.Caption = AppTitle$ & " " & AppVerNo$
   PWLFrm.Show 0

End Sub

Sub OrderLineParse(ord As orderstruct, RTFTxt$, devno%, printsis%, printtn%, linenum%, PtotordCost!, PtotordVat!, PforPrinting!, VatForPrinting!, CalculateCosts%)

'06Jan98 EAC Written for flexible RTF printing
'14Dec01 TH Added local code as printable element (#53478)
'24Jul02 TH Changed above mod as using wrong code (#53478)

Dim startpos&, endpos&, openbracepos&, closebracepos&
Dim temp$
Dim Changed%, found&, numofouters%   '26Jul02 TH Converted found to long
      
   startpos& = 1
   endpos& = Len(RTFTxt$)

   d.SisCode = ord.Code
   getdrug d, 0, found, False

   If OrdPrintPrice And CalculateCosts Then
         PforPrinting! = 0
         PforPrinting! = Val(d.sislistprice)  '3May95 CKJ *Not* dependent on contno
         If Val(d.contprice) > 0 Then PforPrinting! = Val(d.contprice)
         PforPrinting! = dp!((PforPrinting! * Val(ord.outstanding)) / 100)
         VatForPrinting! = PforPrinting! * (VAT(Val(d.vatrate)) - 1)
         PtotordCost! = PtotordCost! + PforPrinting!
         PtotordVat! = PtotordVat! + VatForPrinting!
      End If
   
   Do
      openbracepos& = InStr(startpos&, RTFTxt$, "[")
      If openbracepos& > 0 Then
            If openbracepos& > startpos& Then
                  temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
                  Put #devno, , temp$
               End If
         End If

      If openbracepos& > 0 Then
            startpos& = openbracepos&
            closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
            temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
            
            Select Case LCase$(temp$)
               Case "[1]"
                  'temp$ = Right$("  " & Format$(linenum), 2)
                  temp$ = Format$(linenum)
               Case "[description]"
                  temp$ = Trim$(d.DrugDescription)	' temp$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local site stores description
                  plingparse temp$, "!"
               Case "[nsvcode]"
                  'If printsis Then                   '11Dec03 TH Altered to always print the local code in this element
                  '      temp$ = ord.code             '   "
                  '   Else                            '   "
                  '      temp$ = String$(7, ".")      '   "
                  '   End If                          '   "
                     temp$ = Trim$(d.local)           '   "
               Case "[contract]"
                  temp$ = ""
                  If printtn Then
                        temp$ = "NC"
                        If Len(Trim$(d.contno)) > 0 Then temp$ = Trim$(d.contno)
                     End If
               Case "[qty]"
                  If Val(d.reorderpcksize) <= 1 Then
                        temp$ = Trim$(ord.outstanding)
                     Else
                        defnumofouters (Val(ord.outstanding)), (Val(d.reorderpcksize)), numofouters
                        temp$ = Trim$(Str$(numofouters * Val(d.reorderpcksize)))
                     End If
               Case "[packsize]"
                  temp$ = "x " & d.convfact & " " & Trim$(LCase$(d.PrintformV))
               Case "[tradename]"
                  temp$ = ""
                  If printtn Then temp$ = Trim$(d.tradename)
               Case "[itemcost]"
                  temp$ = ""
                  If PforPrinting! > 0 And OrdPrintPrice Then temp$ = Format$(PforPrinting!, "0.00")
               Case "[itemvat]"
                  temp$ = ""
                  If PforPrinting! > 0 And OrdPrintPrice Then temp$ = Format$(VatForPrinting!, "0.00")
               Case "[bin]"
                  temp$ = Trim$(d.loccode)
               Case "[loccode]"             '14Dec01 TH Added local code element (#53478)
                  'temp$ = Trim$(d.code)     '   "  '24Jul02 TH Changed
                  temp$ = Trim$(d.local)            '   "

               Case Else
                  ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
            End Select
            Put #devno, , temp$
         End If
      
      startpos& = closebracepos& + 1

   Loop While (openbracepos& > 0)

   temp$ = "\par }"
   Put #devno, , temp$

End Sub

Function PresentPrescriptionID&()

End Function

Sub PrintHSSLConfirmationSheet(Mode%, printedok%)

Const RTFfile$ = "\orddata.rtf"
Const Extrafile$ = "\ordextra.rtf"

Dim RTFTxt$, FILE$, temp$, printedordno$, ordernumb$, desc$, NSV$, title$, dataline$, extraline$
Dim msg$, ans$, SisCode$, dateord$, daterec$, qtyord$, qtyrec$, cost$, contract$, LastOrderNum$, NextOrderNum$
Dim success%, filno%, posn%, lastposn%, endposn%, orderno%, lineno%, Y%, attop%, pageno%, found%
Dim printtn%, printsis%, F%, numofouters%, founddrug& '26Jul02 TH converted founddrug to long
Dim x&, pointer&
Dim PforPrinting!, VatForPrinting!, PtotordCost!, PtotordVat!
Dim OrdTitle$    '15Jan98 EAC added

Dim ordptr&, supcode$, ordqty$, AuthUserid$

Dim lngFound As Long

   Do
            
      If Mode = 1 Then
         pointer& = UBound(S29Prods&)
      Else
         pointer& = UBound(CDProds&)
      End If
      
      If AppPrintConfirmation Then
         Screen.MousePointer = HOURGLASS
         MakeLocalFile FILE$
         filno = FreeFile
         Open FILE$ For Binary Access Write Lock Read Write As #filno
      
         GetTextFile dispdata$ + RTFfile$, dataline$, success
         If Not success Then
            popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
            printedok = False
            Exit Sub
         End If
         
         GetTextFile dispdata$ + Extrafile$, extraline$, success
         If Not success Then
            popmessagecr "Error", "There was a problem reading the RTF layout file - " & Extrafile$
            printedok = False
            Exit Sub
         End If
      
         'strip the begining of RTF file bracket from the rtf strings
         If LCase$(Left$(dataline$, 5)) = "{\rtf1" Then dataline$ = Mid$(dataline$, 2)
         If LCase$(Left$(extraline$, 5)) = "{\rtf1" Then extraline$ = Mid$(extraline$, 2)
         '---
   
         'write start of rtf file bracket
         temp$ = "{"
         Put #filno, , temp$
      
         Y = 0
         lineno = 0
         attop = True
         pageno = 0
         'Reset costs
         PtotordCost! = 0
         PtotordVat! = 0
         OrdTitle$ = ""
         
         For x& = 0 To pointer&
            If Mode = 1 Then
               ordptr& = S29Prods&(x&)
            Else
               ordptr& = CDProds&(x&)
            End If
            
            If ordptr& > 0 Then
               getorder ord, ordptr&, 1, False   ' (no idx)
               getsupplier ord.supcode, 0, lngFound, sup
               Y = Y + 1
               If attop Then    'ASC 28.05.92
                  If pageno > 0 Then
                     temp$ = "[FF]" '9Feb95 CKJ prevents FF at end of run
                     PrinterParse temp$
                     Put #filno, , temp$
                  End If
                  pageno = pageno + 1
                  
                  printedordno$ = Trim$(ord.num)
                  
                  If pageno > 1 Then OrdTitle$ = OrdTitle$ & ","
                  OrdTitle$ = OrdTitle$ & " " & printedordno$
                  printordertop Trim$(ord.supcode), printedordno$, filno%, printtn%, printsis%, 2
                  attop = False
                  PrintOrdDescriptor filno, printtn
               End If
      
               lineno = lineno + 1
               
               temp$ = "{"
               Put #filno, , temp$
      
               OrderLineParse ord, dataline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, PforPrinting!, VatForPrinting!, True
               If printtn Then OrderLineParse ord, extraline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, PforPrinting!, VatForPrinting!, False
      
               temp$ = "}"
               If OrdPrintLin Then temp$ = "[cr]}"
               PrinterParse temp$
               Put #filno, , temp$
               
               LastOrderNum$ = Trim$(ord.num)
               If x& + 1 <= pointer& Then
                  If Mode = 1 Then
                        ordptr& = S29Prods&(x& + 1)
                     Else
                        ordptr& = CDProds&(x& + 1)
                     End If
                  getorder ord, ordptr&, 1, False   ' (no idx)
                  NextOrderNum$ = Trim$(ord.num)
               Else
                  NextOrderNum$ = LastOrderNum$
               End If
               
               ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
               If lineno >= GetMaxNoOfLinesForOrder(sup.Method) Or (NextOrderNum$ <> LastOrderNum$) Then
                  lineno = 0
                  
                  If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0 '26Jul02 TH Added new parameters
   
                  printordertail filno%, sup.ordmessage
                  attop = True
                  
                  'Reset costs ready for next order
                  PtotordCost! = 0
                  PtotordVat! = 0
               End If
            End If
         Next
      
         If Not attop Then
            If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0 '26Jul02 TH Added new parameters
         
            printordertail filno%, sup.ordmessage
         End If
         
         temp$ = "}"
         Put #filno, , temp$
         Close #filno
      
         printedok = False
            
         Screen.MousePointer = STDCURSOR
         
         'Print file
         WSspool FILE$, "Stock Control", 1, True, False, ""  '14Dec01 TH Added extra parameter (stubbage)
         Do
            printedok = False ' 2Jun93 CKJ
            title$ = "Completed Order(s) " & OrdTitle$  '15Jan98 EAC added ordtitle$
            msg$ = Str$(Y) + " item" + plural((Y)) + " sent to the printer on"
            msg$ = msg$ + Str$(pageno) + " order" + plural((pageno)) + "." + Chr$(13) + Chr$(13)              '   "
            msg$ = msg$ + "    Printed OK?  Y/N  (Esc to abort order)  "
            ans$ = ""
            askwin title$, msg$, ans$, k
            If ans$ = "Y" Then
                  printedok = True
               Else
                  k.escd = True
               End If
            If k.timd Then popmessagecr "!n!i", "Printing needs confirmation" '!!** beep
         Loop Until Not k.timd
      Else
         printedok = True
      End If
   Loop Until printedok Or k.escd
   
   Screen.MousePointer = HOURGLASS
   
   If printedok Then
      lineno = 0
      pageno = 1
      For x& = 0 To pointer&
         lineno = lineno + 1
         If Mode = 1 Then
            ordptr& = S29Prods&(x&)
         Else
            ordptr& = CDProds&(x&)
         End If
         
         getorder ord, ordptr&, 1, True  '<-----LOCK   (no idx)
         ord.status = "3"
         ord.received = ord.outstanding
         ord.qtyordered = ord.outstanding 'ASC 26 Jan 92
         daterec$ = ""
         qtyord$ = ord.outstanding
         qtyrec$ = ordqty$
         AuthUserid$ = ord.invnum  'held here from auth & raise
         ord.invnum = ""
         d.SisCode = ord.Code
         getdrug d, 0, founddrug, False
         If Val(d.contprice) > 0 Then
            ord.cost = d.contprice
         Else
            If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then '21Jul95 CKJ
               ord.cost = d.sislistprice 'price last paid
            Else
               ord.cost = d.cost
            End If
         End If
         PutOrder ord, ordptr&, "WOrder"                 '<----UNLOCK  (no idx)
         Orderlog ord.num, ord.Code, AuthUserid$, ord.orddate, daterec$, qtyord$, qtyrec$, ord.cost, ord.supcode, "O", SiteNumber, contract$, d.vatrate, "", ""
      Next
   End If
   
   Screen.MousePointer = STDCURSOR

End Sub

Sub Ques_Callback(index%)

   Select Case QuesCallbackMode
      Case 1
         CheckHSSLSettings index
      Case Else
   End Select

End Sub

Sub ReadHSSLDefaults()

Dim found%

   AppTitle$ = TxtD$(dispdata$ & AppIniFile$, "", "HSSL Interface", "AppTitle", found)
   AppPrintConfirmation = TrueFalse(TxtD$(dispdata$ & AppIniFile$, "", "-1", "PrintOrderConfirmation", found))

   HsslCdCode$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "CDSupCode", found)
   HsslS29Code$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "S29SupCode", found)
   
   HostIPAddr$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "FTPIPAddress", found)
   FTPUserName$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "FTPUserName", found)
   FTPPassword$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "FTPPassword", found)
   
   HSSLCustCode$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "HSSLCustomerCode", found)
   HSSLContactCode$ = TxtD$(dispdata$ & AppIniFile$, "defaults", "", "HSSLContactCode", found)

End Sub

Sub SaveHSSLDefaults()

Dim FocusSet%, loopvar%, success%, escd%
Dim msg$, IniEntry$, initext$, ans$

   FocusSet = False
   
   If Trim$(Ques.lblInfo(2).Caption) = "" Then
         msg$ = msg$ & "You must define the supplier code for HSSL S29 Orders." & cr$
         If FocusSet = False Then Ques.cmdQ(3).SetFocus: FocusSet = True
      End If

   If Trim$(Ques.lblInfo(3).Caption) = "" Then
         msg$ = msg$ & "You must define the supplier code for HSSL CD Orders." & cr$
         If FocusSet = False Then Ques.cmdQ(2).SetFocus: FocusSet = True
      End If
   
   If Trim$(Ques.txtQ(6).text) = "" Then
         msg$ = msg$ & "You must define the IP address of the HSSL FTP host machine." & cr$
         If FocusSet = False Then Ques.cmdQ(6).SetFocus: FocusSet = True
      End If
   
   If Trim$(Ques.txtQ(7).text) = "" Then
         msg$ = msg$ & "You must specify the FTP user name." & cr$
         If FocusSet = False Then Ques.cmdQ(6).SetFocus: FocusSet = True
      End If
   
   If Trim$(Ques.txtQ(8).text) = "" Then
         msg$ = msg$ & "You must specify the FTP password." & cr$
         If FocusSet = False Then Ques.cmdQ(6).SetFocus: FocusSet = True
      End If

   
   If Trim$(msg$) = "" Then
         For loopvar = 2 To 12
            Select Case loopvar
               Case 2
                  IniEntry$ = "S29SupCode"
                  initext$ = Trim$(Ques.lblInfo(2).Caption)
                  HsslS29Code$ = initext$
               Case 3
                  IniEntry$ = "CDSupCode"
                  initext$ = Trim$(Ques.lblInfo(3).Caption)
                  HsslCdCode$ = initext$
               Case 6
                  IniEntry$ = "FTPIPAddress"
                  initext$ = Trim$(Ques.txtQ(6).text)
                  HostIPAddr$ = initext$
               Case 7
                  IniEntry$ = "FTPUsername"
                  initext$ = Trim$(Ques.txtQ(7).text)
                  FTPUserName$ = initext$
               Case 8
                  IniEntry$ = "FTPPassword"
                  initext$ = Trim$(Ques.txtQ(8).text)
                  FTPPassword$ = initext$
               Case 11
                  IniEntry$ = "HSSLCustomerCode"
                  initext$ = Trim$(Ques.txtQ(11).text)
                  HSSLCustCode$ = initext$
               Case 12
                  IniEntry$ = "HSSLContactCode"
                  initext$ = Trim$(Ques.txtQ(12).text)
                  HSSLContactCode$ = initext$
            End Select
            'WritePrivateIniFile "Defaults", IniEntry$, Chr$(34) & initext$ & Chr$(34), dispdata$ & AppIniFile$, success%
            WritePrivateIniFile "Defaults", IniEntry$, initext$, dispdata$ & AppIniFile$, success%
            'If Not success Then popmsg "Error", "Could not save settings in file " & dispdata$ & AppIniFile$, 16, ans$, escd%
            If success = 0 Then popmsg "Error", "Could not save settings in file " & dispdata$ & AppIniFile$, 16, ans$, escd%
         Next
         FlushIniCache
         
         Ques.Hide
      Else
         popmsg "Error", msg$, 16, ans$, escd%
         Ques.Tag = False
      End If
End Sub

Sub PutRecordFailure(ByVal ErrNo As Long, ByVal ErrDescription As String)
'14Nov08 CKJ Removed Public from decalaration

Dim strmsg As String

   strmsg = "Error Number = " & Format$(ErrNo) & "   " & ErrDescription

   popmessagecr "", strmsg & crlf & crlf & "A critical Error has occurred. This application can no longer continue"
   Close
   End

End Sub

''Sub ReadWSLDefaults()
''
''Dim found%
''
''   stocklini$ = dispdata$ + "\stockl.ini"
''   'usable lines per page excluding the footer (if used)
''   PageLen = Val(TxtD$(stocklini$, "", "60", "PageLen", found))
''   'lines used in 1st page header
''   HdrALen = Val(TxtD$(stocklini$, "", "10", "HdrALen", found))
''   'lines used in subsequent page headers
''   HdrBLen = Val(TxtD$(stocklini$, "", "5", "HdrBLen", found))
''   'lines used per drug
''   DrugLen = Val(TxtD$(stocklini$, "", "2", "DrugLen", found))
''   'lines used per drug
''   BCodeLen = Val(TxtD$(stocklini$, "", "3", "BCodeLen", found))
''   'lines used per section name
''   SectLen = Val(TxtD$(stocklini$, "", "3", "SectLen", found))
''   'lines used in footer
''   FootLen = Val(TxtD$(stocklini$, "", "3", "FootLen", found))
''   'lines used in signature block
''   SignLen = Val(TxtD$(stocklini$, "", "15", "SignLen", found))
''
''End Sub

