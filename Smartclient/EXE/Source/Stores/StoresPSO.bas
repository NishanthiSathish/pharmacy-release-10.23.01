Attribute VB_Name = "StoresPSO"
'03Sep12 TH For PSO reference mean we now require a dummy patient structure and global pid
'           This is purely to allow us to run the Label IO Library necessary to update
'           a PSO patient pmr on receipt of a PSO Order
'12Nov15 TH Receive_eHUBPOD: Added Trim to ensure correct check on new description (TFS 132827)
'01Feb16 TH Invoice_eHUB: Changed input call to asksupplier (TFS 138644)
'05Feb16 TH DisplayHUBExtraInfo: Written based on DisplayEDIExtraInfo, seperate proc as likely to diverge (TFS 138638)
'05Feb16 TH SetHUBItemArchivable:Written based on SetMediateItemArchivable, seperate proc as likely to diverge (TFS 138638)
'07Feb16 TH ReadHUBInvoices: Refactored after discussion with Sue and Andrew Simons
'                            After initially writing simpler for of auto invoicing, have decide now to repliacte as first pass the exact mechanism
'                            used by EDI to handle exceptions and archiving of invoice data. (TFS 128638)
'07Feb16 TH ReadHUBInvoices: Modified IO to HubInvoice and Archive tables
'08Feb16 TH ProcessHubInvInfo: Mod to ensure the exceptions are captured in the table correctly (TFS 138638)
'08Feb16 TH ReadHUBInvoices: Modified exception handling to use full datetime (TFS 138628)
'08Feb16 TH ReadHUBInvoices: Only offer to print exceptions if there are any to print (TFS 144215)
'18Feb16 TH CheckHubInvInfo: Added orderID param to get pat details in main sub (TFS 138645)
'18Feb16 TH CheckHubInvInfo: Modifications and rework after initial testing (TFS 138645)
'18Feb16 TH ReadHUBInvoices: Modifications and rework after initial testing (TFS 138645)
'19Feb16 TH ReadHUBInvoices: Altered IO for hub archiving as was incorrect. (TFS) -- Paydate handling needs review
'22Feb16 TH ReadHUBInvoices: cache file name value as the listbox will now been unloaded (TFS 146047)
'22Feb16 TH CheckHubInvInfo: Removed HUB Receipt check after discussion with Sue and Andrew (TFS 146056)
'25Feb16 TH ReadHUBInvoices: Changed cursor handling
'02Mar16 TH ProcessHubInvInfo: Changed Paydate to genuine date - previously it was sending strPaydate into DB and was being mangled (TFS 146872)
'02Mar16 TH General pre-review/merge tidy up.
'07Mar16 TH Mods after code review (TFS 138645)
'14Nov16 TH ReadHUBInvoices: Modified to get reports from the DB then store locally rather than to use fileshare version (TFS 157972)
'06Dec16 TH ReadHUBInvoices: Replaced RTF Handling (TFS 157969)
'04Jan17 TH ReadHUBInvoices: Use Local File Parsing for new RTF handling (TFS 157969)
'05Jan17 TH ReadHUBInvoices: Refacted RTF Handling (TFS 157969)


Type WPatient
   EntityID As Long
   recno As String         '* 10    ' internal lookup code - used for Xref in Tpn etc: Now is PK as a string
   title As String         '* 5     ' *10 in SQL
   surname As String       '* 20    ' trimmed & left justified
   forename As String      '* 15    ' trimmed & left justified
   dob As String           '* 8     ' as  ddmmyyyy  only
   sex As String           '* 1     ' M F or space
End Type

Global pid As WPatient
Global g_blnSplitDose As Boolean
Global RxOffset&

Dim HUBInvLowerDiff!, HUBInvUpperDiff!
Dim HUBInvLowerDiffOC!, HUBInvUpperDiffOC!
Dim HUBImportPath$

Dim m_strHubSupcode As String

Type HubInvoiceHeader
   SupplierANA             As String * 13
   LocalSupCode            As String * 5
   'SupplierDocNum          As String * 20
   InvoiceNumber           As String * 20
   SupplierVatNum          As String * 17
   HospOrdRef              As String * 41
   PurchaseOrderNumber     As String * 16
   HospAccount             As String * 13
   'InvoiceDate    As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   'TaxPointDate   As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   'PayDueByDate   As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   InvoiceDate             As Date
   TaxPointDate            As Date
   PayDueByDate            As Date
   HeaderContNum           As String * 35
   HeaderComment           As String * 40
   'numlines                As String * 4
   numlines                As Integer
End Type

Type HubInvoiceLine
   NSVCode                    As String * 7
   DMandDReference            As String * 20
   SuppliersCode              As String * 17
   SuppliersDesc              As String * 40
   SuppliersPkSiz             As String * 8
   QtyInvoiced                As String * 9       'Number of units purchased
   UnitPrice                  As String * 15      'Price for one unit
   GoodsPrice                 As String * 15      'Unit price x quantity
   LineVat                    As String * 15      'Total VAT on this item
   LineVatCode                As String * 1       'SZ(XAO) std zero (exempt mixed other)
   LineVatRate                As String * 5       'xx.xx% VAT
   LineDiscount               As String * 15      'AAH discount
   LineAddition               As String * 15      'fixed amount added to order line
   LineTotal                  As String * 15      'Goods price + line VAT
   LineContNum                As String * 35      'contract number
   LineComment                As String * 40
   ASCIssuePrice              As String * 9       'TH Extended type to store fields for exceptions/archive table
   ASCPriceLastPaid           As String * 9
   ASCContractPrice           As String * 9
   ASCPriceLastReconciled     As String * 9
   ASCContractNumber          As String * 10
End Type



Function PBSKeepDate() As Boolean
'03Sep12 TH Stubbage

   PBSKeepDate = False
   
End Function



Sub SetFocusTo(ctrl As Control)
'03Sep12 TH Stubbage

   On Error Resume Next
   If ctrl.Visible Then
      ctrl.SetFocus
   End If
   On Error GoTo 0

End Sub

Public Function txtUC(ctrlname As String, Optional ctrlindex As Variant) As TextBox
'03Sep12 TH Stubbage
 
End Function

Public Function isPSOOrder(ByVal lngOrderNumber As Long) As Boolean
'20Nov12 TH Written to determine if a order number relates to a PSO order or not

Dim lngOutput As Long
Dim strParams As String

   lngOutput = 0
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNum", trnDataTypeint, 4, lngOrderNumber)
               
   lngOutput = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderbyNumIsPSO", strParams)
   
   isPSOOrder = (lngOutput > 0)
   
   
   
End Function
Sub Receive_eHUBPOD()
'23Apr14 TH Written
'Main entry into POD receipt functionality
'We need to check and load the file.
'Store key fields
'Iteratively move through the file and collect data to make the actual receipt
'On completion archive the file and remove it from the active folder
'26Aug14 TH Added more description on list selection and moved everything into loop
'29Aug14 TH Added hourglassing to make it more obvious we are doing something (TFS 96816)
'29Aug14 TH Set default to cancel on main file uplaod selection box (TFS 96816)
'16Nov14 TH Added extra details for message (TFS 102722)
'23Dec14 TH Added elements for over receipt msg (TFS 102722)
'23Dec14 TH Get as much pat info that we can from the POD for msg - no order available (TFS 102725)
'12Nov15 TH Added Trim to ensure correct check on new description (TFS 132827)

Dim strImportPath As String
Dim strFile As String
Dim chan As Integer
Dim strxXML As String
Dim strOrderNum As String
Dim xmldoc As MSXML2.DOMDocument26
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
Dim xmlOrderNode As MSXML2.IXMLDOMElement
Dim xmlDelItemNodeList As MSXML2.IXMLDOMNodeList
Dim xmlDelItemnode As MSXML2.IXMLDOMElement
Dim xmlRecQtyNode As MSXML2.IXMLDOMElement
Dim strQty As String
Dim xmlCodenode As MSXML2.IXMLDOMElement
Dim xmlCodeNodeList As MSXML2.IXMLDOMNodeList
Dim xmlSystemcodenode As MSXML2.IXMLDOMElement
Dim xmlNSVcodenode As MSXML2.IXMLDOMElement
Dim strParams As String
Dim ord As orderstruct
Dim lngWorderID As Long
Dim strArchivePath As String
Dim strArchiveFile As String
Dim blnFilesPresent As Boolean
Dim strName As String, strCasenum As String, strNHNumber As String
Dim strSurname As String, strForename As String, strDOB As String '23Dec14 TH Added elements
Dim xmlPatNodeList As MSXML2.IXMLDOMNodeList
Dim xmlPatNode As MSXML2.IXMLDOMElement
Dim xmlNHSNBRnode As MSXML2.IXMLDOMElement
Dim xmlcasenumnode As MSXML2.IXMLDOMElement
Dim lngBatchWReconcilID As Long '23Feb16 TH

   lngBatchWReconcilID = 0 '23Feb16 TH set
   
   strImportPath = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", strImportPath, "HubPODImportPath", 0)
   
   strFile = Dir(strImportPath & "\*.xml")
   Do While strFile <> ""
      'If strFile <> "" Then
      blnFilesPresent = True
      Unload LstBoxFrm 'Ensure we start with a blank list
      LstBoxFrm.Caption = "Select File to Import from eHub"
      LstBoxFrm.lblTitle.Caption = crlf & "Click OK to import and update delivery information"
      Do
        'OK parse the file Name and display in list box to user
        LstBoxFrm.LstBox.AddItem Left$(strFile, Len(strFile) - 4)
        strFile = Dir$
      Loop While strFile <> ""
      LstBoxFrm.cmdOK.default = False
      LstBoxFrm.cmdCancel.default = True
      LstBoxShow
      strFile = Trim$(LstBoxFrm.Tag)
      strWard = strFile
      If strFile <> "" Then strFile = strImportPath & "\" & strFile & ".xml" 'rebuild file with path
      
      If Trim$(strFile) = "" Then
         Unload LstBoxFrm  '27Aug14 TH Added to clear items (TFS 98757)
         Exit Sub
      Else
         Screen.MousePointer = HOURGLASS
         'Now begin the fun - Can we load the file into the dom
         chan = FreeFile
         Open strFile For Binary Lock Read Write As #chan
         
         strxXML = Space$(LOF(chan))
         Get #chan, , strxXML
         Close #chan
   
         Set xmldoc = New MSXML2.DOMDocument
       
         If Left$(strxXML, 3) = "?" Then strxXML = Right(strxXML, Len(strxXML) - 3) '17Nov14 TH Remove BOM
         
         If xmldoc.loadXML(strxXML) Then
            'Screen.MousePointer = STDCURSOR
                    
            Set xmlNodeList = xmldoc.selectNodes("PoDMessage/eHubPoDItem")
            
            For Each xmlnode In xmlNodeList
               'Get Order Number
               Set xmlOrderNode = xmlnode.selectSingleNode("PurchaseOrderNumber")
               strOrderNum = xmlOrderNode.getAttribute("value")
               Set xmlOrderNode = Nothing
               'Other things are specifc to the type of order node
               Set xmlDelItemNodeList = xmlnode.selectNodes("DeliveryDetail")
               For Each xmlDelItemnode In xmlDelItemNodeList
                  Set xmlRecQtyNode = xmlDelItemnode.selectSingleNode("ItemsDeliveredCount")
                  strQty = xmlRecQtyNode.text
                  Set xmlRecQtyNode = Nothing
                  If InStr(xmlDelItemnode.xml, "<Service>") > 0 Then
                     'service
                     'Identify the item
                     Set xmlCodeNodeList = xmlDelItemnode.selectNodes("ItemDelivered/Service/RequestedService/Procedure/type/coding")
                     For Each xmlCodenode In xmlCodeNodeList
                        Set xmlSystemcodenode = xmlCodenode.selectSingleNode("system")
                        If xmlSystemcodenode.getAttribute("value") = "NSVCode" Then
                           Set xmlNSVcodenode = xmlCodenode.selectSingleNode("code")
                           strNSVCode = xmlNSVcodenode.getAttribute("value")
                           Set xmlNSVcodenode = Nothing
                        End If
                        Set xmlSystemcodenode = Nothing
                     Next
                  
                     Set xmlCodeNodeList = Nothing
                     ''DEBUG popmessagecr "", "Service Qty" & strQty & " NSVCODE = " & strNSVCode
                  
                  ElseIf InStr(xmlDelItemnode.xml, "<Equipment>") > 0 Then
                     'equipment
                     Set xmlCodeNodeList = xmlDelItemnode.selectNodes("ItemDelivered/Equipment/Device/type/coding")
                     For Each xmlCodenode In xmlCodeNodeList
                        Set xmlSystemcodenode = xmlCodenode.selectSingleNode("system")
                        If xmlSystemcodenode.getAttribute("value") = "NSVCode" Then
                           Set xmlNSVcodenode = xmlCodenode.selectSingleNode("code")
                           strNSVCode = xmlNSVcodenode.getAttribute("value")
                           Set xmlNSVcodenode = Nothing
                        End If
                        Set xmlSystemcodenode = Nothing
                     Next
                     Set xmlCodeNodeList = Nothing
                     
                     ''DEBUG popmessagecr "", "equipment Qty" & strQty & " NSVCODE = " & strNSVCode
                  Else
                     'medicinal
                     Set xmlCodeNodeList = xmlDelItemnode.selectNodes("ItemDelivered/Medicine/Medication/Medication/code/coding")
                     For Each xmlCodenode In xmlCodeNodeList
                        Set xmlSystemcodenode = xmlCodenode.selectSingleNode("system")
                        If xmlSystemcodenode.getAttribute("value") = "NSVCode" Then
                           Set xmlNSVcodenode = xmlCodenode.selectSingleNode("code")
                           strNSVCode = xmlNSVcodenode.getAttribute("value")
                           Set xmlNSVcodenode = Nothing
                        End If
                        Set xmlSystemcodenode = Nothing
                     Next
                     Set xmlCodeNodeList = Nothing
                     
                     ''DEBUG popmessagecr "", "medicinal Qty" & strQty & " NSVCODE = " & strNSVCode
                  End If
                  'Get Drug
                  If strNSVCode <> "" Then
                     d.SisCode = strNSVCode
                     getdrug d, 0, 0, False
                     
                     'Get OrderLine
                     'First we Need the ID
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("OrderNumber", trnDataTypeint, 4, Val(strOrderNum)) & _
                                 gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode) & _
                                 gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3")
                     lngWorderID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderIDByOrderNumberSiteStatusAndNSVCode", strParams)
                     'Get Order
                     If lngWorderID = 0 Then
                        '23Dec14 TH get as much pat info that we can from the POD for msg (TFS 102725)
                        Set xmlPatNodeList = xmlnode.selectNodes("PatientIdentifier")
                        For Each xmlPatNode In xmlPatNodeList
                           Set xmlSystemPatnode = xmlPatNode.selectSingleNode("system")
                           If xmlSystemPatnode.getAttribute("value") = "NHSNBR" Then
                              Set xmlNHSNBRnode = xmlPatNode.selectSingleNode("value")
                              strNHNumber = xmlNHSNBRnode.getAttribute("value")
                              Set xmlNHSNBRnode = Nothing
                           ElseIf xmlSystemPatnode.getAttribute("value") = "Case Number" Then
                              Set xmlcasenumnode = xmlPatNode.selectSingleNode("value")
                              strCasenum = xmlcasenumnode.getAttribute("value")
                              Set xmlcasenumnode = Nothing
                           End If
                           Set xmlSystemPatnode = Nothing
                        Next
                        Set xmlPatNodeList = Nothing
                        
                        Screen.MousePointer = STDCURSOR
                        popmessagecr "eHub POD Upload", "Order Number : " & strOrderNum & crlf & _
                        "For patient " & crlf & _
                        "Case Num: " & strCasenum & crlf & "NH Number: " & strNHNumber & crlf & _
                        "Order for " & Trim$(Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription)) & " (" & d.SisCode & ") is not available for receipting and cannot be automatically processed"
                        '"Order for " & Trim$(Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription)) & " (" & d.SisCode & ") is not available for receipting and cannot be automatically processed" '12Nov15 TH  Replaced above, added Trim to ensure correct check on new description (TFS 132827)
                        Screen.MousePointer = HOURGLASS
                     Else
                        getorder ord, lngWorderID, 3, False
                        
                        strQty = Str$(dp!(Val(strQty) / d.convfact)) '26Aug14 TH Factor this to ensure we will recieve in packs
                        
                        'Check that there is enough outstanding. W cannot over receive on a PSO
                        If Val(strQty) > ord.outstanding Then
                           '16Nov14 TH Added extra details for message (TFS 102722)
                           FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0
                           Heap 11, gPRNheapID, "psoNameDOB", strName, 0
                           Heap 11, gPRNheapID, "psoCasenumber", strCasenum, 0
                           Heap 11, gPRNheapID, "psoNHnumber", strNHNumber, 0
                           Heap 11, gPRNheapID, "psoSurname", strSurname, 0      '23Dec14 TH Added elements
                           Heap 11, gPRNheapID, "psoForename", strForename, 0    '  "
                           Heap 11, gPRNheapID, "psoDOB", strDOB, 0              '  "
                           Screen.MousePointer = STDCURSOR
                           'popmessagecr "eHub POD Upload", "Order for " & Trim$(d.storesdescription) & " (" & d.SisCode & ")." & crlf & _ XN 9Jun15 98073 New local stores description
                           'popmessagecr "eHub POD Upload", "Order for " & Trim$(Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription)) & " (" & d.SisCode & ")." & crlf
                           '12Nov15 TH  Replaced above, added Trim to ensure correct check on new description (TFS 132827)
                           popmessagecr "eHub POD Upload", "Order for " & Trim$(Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription)) & " (" & d.SisCode & ")." & crlf & _
                           "Order Number : " & strOrderNum & crlf & _
                           "Quantity on Proof of Delivery  : " & strQty & crlf & _
                           "Quantity outstanding on order  : " & Format$(ord.outstanding) & crlf & _
                           "For patient: " & Trim$(strForename) & " " & Trim$(strSurname) & crlf & "DOB: " & strDOB & crlf & _
                           "Case Num: " & strCasenum & crlf & "NH Number: " & strNHNumber & _
                           crlf & crlf & "The file is trying to receive more than currently outstanding on this order." & crlf & "You cannot receive more than has been ordered for a Patient Specific Order" & crlf & " Nothing will be receipted from this file for this order line."
                           Screen.MousePointer = HOURGLASS
                        Else
                           
                           If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "N", "HUBBatchInvoiceAmalgamation", 0)) Then
                              'We have batch information. Now we will check to see if we have a reconcil record for this item
                              'on this order.If so then we will ask if this is to be amalgamated on the invoice line or not
                              'If so we store the ID and use it on the actual receipt.
                              lngBatchWReconcilID = CheckBatchReconcilReceipts(ord.num, ord.Code, True)
                           End If
                           
                           'Get Receipt Qty - Done above
                           'Receive as PSO
                           'OK We need a way of "injecting" the cost in here (if est cost is available I thinnk we should just use this as blanket - even retaining for part receipts
                           
                           'receiveitem SiteNumber, ord, strQty, lngWorderID, True, 0
                           receiveitem SiteNumber, ord, strQty, lngWorderID, True, lngBatchWReconcilID
                           lngBatchWReconcilID = 0
                        End If
                     End If
                  End If
               Next
            Next
         Else
            Screen.MousePointer = STDCURSOR
            popmessagecr "eHub POD Upload", " There is a problem loading file : " & strFile
            Screen.MousePointer = HOURGLASS
         End If
         'Archive the file
         strArchivePath = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "HubPODArchivePath", 0)
         If Trim$(strArchivePath) <> "" Then
            strFile = Trim$(LstBoxFrm.Tag)
            strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & "_eHubPOD.xml"
            If fileexists(strArchivePath & "\" & strArchiveFile) Then
               'OK. Lets find another alternative
               For intloop = 65 To 90 Step 1
                  strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & Chr$(intloop) & "_eHubPOD.xml"
                  If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
                     blnNameOK = True
                     Exit For
                  End If
               Next
            Else
               blnNameOK = True
            End If
            If blnNameOK = True Then
               'Good to go. Copy then kill
               FileCopy strImportPath & "\" & strFile & ".xml", strArchivePath & "\" & strArchiveFile
               Kill strImportPath & "\" & strFile & ".xml"
            Else
               Screen.MousePointer = STDCURSOR
               popmessagecr "EMIS Health", "There are too many archive files" & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
               Screen.MousePointer = HOURGLASS
            End If
         Else
            Screen.MousePointer = STDCURSOR
            popmessagecr "EMIS Health", "The EHUB POD Archive path was not been configured." & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
            Screen.MousePointer = HOURGLASS
         End If
      End If
      Unload LstBoxFrm  '27Aug14 TH Added to clear items (TFS 98757)
      strFile = Dir(strImportPath & "\*.xml")
      
   Loop
   'Else
   '  popmessagecr "Ascribe", "No Files are ready for import"
   'End If
   Screen.MousePointer = STDCURSOR
   
   
   If blnFilesPresent Then
      popmessagecr "EMIS Health", "No files remain for import"
   Else
      popmessagecr "EMIS Health", "No files are present for import"
   End If
   

End Sub
Sub Invoice_EHub()
'01Feb16 TH Changed input call to asksupplier (TFS 138644)

Dim HubSup As supplierstruct

   clearsup HubSup
   'asksupplier "", 0, "E", "Select Home Care Supplier", False, HubSup, True '15Nov12 TH Added PSO param
   asksupplier "", 0, "E", "Select Home Care Supplier", False, HubSup, PSO '01Feb16 TH Changed input (TFS 138644)
   If Trim$(HubSup.Code) <> "" Then
      ReadHubInvoices HubSup.Code, True
   End If
End Sub
Sub ReadHubInvoices(i_strSupcode As String, DisplayNoData%)
'2014 Original Write of Hub Invoicing roughly based on EDI Invoicing
'07Feb16 TH Refactored after discussion with Sue and Andrew Simons
'           After initially writing simpler for of auto invoicing, have decide now to replicate as first pass the exact mechanism
'           used by EDI to handle exceptions and archiving of invoice data. (TFS 138638)
'07Feb16 TH Modified IO to HubInvoice and Archive tables
'08Feb16 TH Modified exception handling to use full datetime (TFS 138628)
'08Feb16 TH Only offer to print exceptions if there are any to print (TFS 144215)
'18Feb16 TH Modifactions and rework after initial testing (TFS)
'19Feb16 TH Altered IO for hub archiving as was incorrect. (TFS) -- Paydate handling needs review
'22Feb16 TH cache file name value as the listbox will now been unloaded (TFS 146047)
'22Feb16 TH Removed HUB Receipt check after discussion with Sue and Andrew (TFS 146056)
'25Feb16 TH Changed cursor handling
'14Nov16 TH Modified to get reports from the DB then store locally rather than to use fileshare version (TFS 157972)
'06Dec16 TH Replaced RTF Handling (TFS 157969)
'04Jan17 TH Use Local File Parsing for new RTF handling (TFS 157969)
'05Jan17 TH Refacted RTF Handling (TFS 157969)

Const procname$ = "ReadHubInvoices"


Dim filelock$, InvFile$, MOrderNo$, msg$, ans$
Dim MInvoiceNo$, MPayDate$, SQL$
Dim valid%, invHdl%, ErrNo%, loopvar%, Reconcile%, success%
Dim strParams As String
Dim rsHUB As ADODB.Recordset
Dim blnArchiveError As Boolean
Dim lngWHubInvoiceArchiveID As Long
Dim lngWHubInvoiceID As Long          '05Feb16 TH replaced
Dim lngOK As Long
Dim strDate As String
Dim crxApp As CRAXDDRT.Application
Dim crxRpt As CRAXDDRT.Report
Dim crxTables As CRAXDDRT.DatabaseTables
Dim crxTable As CRAXDDRT.DatabaseTable
Dim strTemp As String
Dim strDetailLine As String
Dim strRTFLayout As String
Dim strContext As String
Dim strRTFTxt As String
Dim strPgHdr As String
Dim strPgItem As String
Dim strPgEnd As String
Dim strTmpFile As String
Dim intTmpFileNo As Integer
Dim blnRejectWholeInvoice As Boolean '12Jan07 PJC Added (#EDI) '24Sep09 PJC ported (F0053407)
Dim blnHasError As Boolean           '12Jan07 PJC Added (#EDI) '24Sep09 PJC ported (F0053407)
Dim rsTemp As ADODB.Recordset '27May10 AJK Added F0061692
Dim hubord As orderstruct

Dim HubInvLines() As HubInvoiceLine
Dim HubInvHeader As HubInvoiceHeader
Dim xmldoc As MSXML2.DOMDocument26
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
Dim xmlOrderNode As MSXML2.IXMLDOMElement
Dim xmlLineList As MSXML2.IXMLDOMNodeList
Dim xmlLineNode As MSXML2.IXMLDOMElement
Dim xmlRecQtyNode As MSXML2.IXMLDOMElement
Dim strQty As String
Dim xmlCodenode As MSXML2.IXMLDOMElement
Dim xmlCodeNodeList As MSXML2.IXMLDOMNodeList
Dim xmlSystemcodenode As MSXML2.IXMLDOMElement
Dim xmlNSVcodenode As MSXML2.IXMLDOMElement
Dim intLineNumber As Integer
Dim dtePayDate As Date

Dim ord As orderstruct
Dim blnSupplierMismatch As Boolean

Dim chan As Integer
Dim strxXML As String

Dim blnDelete As Boolean        '28Jan16 TH Added
Dim strAns As String
Dim strReceiptMsg As String
Dim lngNotReceivedOrderID As Long
Dim strName As String
Dim strCasenum As String
Dim strNHNumber As String
Dim strSurname As String
Dim strForename As String
Dim strDOB As String
Dim strImportFileName As String
Dim blnNoCrystalReport As Boolean '14Nov16 TH Added to stop crystal when there is no report available (TFS 157972)
Dim strReportName As String  '14Nov16 TH Used in Crystal DB mod (TFS 157972)
Dim intSuccess As Integer '05Jan17 TH Added

   blnSupplierMismatch = False
   ReadHUBDefaults i_strSupcode
   If i_strSupcode = "NOHUBFILE" Then Exit Sub
   Screen.MousePointer = 11

   filelock$ = dispdata$ & "\" & TxtD(dispdata$ & "\PSO.INI", "HubInvoiceImport", "HUBOR3C.LCK", "HubInvoiceLock", 0)
   AcquireLock filelock$, -2, valid  ' exclusive, keep trying

   If Not valid Then
      Screen.MousePointer = 0
      popmessagecr "Error", "Another terminal is currently performing eHub invoicing functions." & crlf$ & crlf$ & "Please try again later."
      Exit Sub
   End If
   
   blnRejectWholeInvoice = TrueFalse(TxtD(dispdata$ & "\PSO.INI", "HubInvoiceImport", "N", "RejectAllHubInvoiceIfError", 0))

   strArchivePath = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "HubInvoiceArchivePath", 0)
      
   
   'Load the XML File(s)
   Do
      blnDelete = False '05Feb16 TH Reset
      strFile = Dir(HUBImportPath$ & "\*.xml")
      If strFile <> "" Then
         
        Unload LstBoxFrm 'Ensure we start with a blank list
        LstBoxFrm.Caption = "Select File to Import"
        Do
          'OK parse the file Name and display in list box to user
          LstBoxFrm.LstBox.AddItem Left$(strFile, Len(strFile) - 4)
          strFile = Dir$
        Loop While strFile <> ""
        LstBoxFrm.lblHead = "Invoice File"
               
        LstBoxShow "&Delete"  '26Jan16 TH Added Delete button string. This acts both as a flag and the extra button caption
        strFile = Trim$(LstBoxFrm.Tag)
        If Trim$(LstBoxFrm.cmdExtra.Tag) = "selected" Then
            blnDelete = True
            '05Feb16 TH Moved code from below so that we can loop on deleteion of file
            'File flagged for deletion - double check here
            strAns = "N"
            askwin "eHub Invoice Upload", "Are you sure you wish to remove this eHub Invoice : " & Trim$(strWard), strAns, k
            If strAns = "Y" And k.escd = False Then
               'If we are deleting then we move to the archive and mark as deleted
               If Trim$(strArchivePath) <> "" Then
                  strFile = Trim$(LstBoxFrm.Tag)
                  strArchiveFile = strArchiveFile & "_" & Format(Now, "DDMMYYYY HHMM") & "_eHubInvoice_DELETED.xml"
                  If fileexists(strArchivePath & "\" & strArchiveFile) Then
                     'OK. Lets find another alternative
                     For intloop = 65 To 90 Step 1
                        strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & Chr$(intloop) & "_eHubInvoice_DELETED.xml"
                        If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
                           blnNameOK = True
                           Exit For
                        End If
                     Next
                  Else
                     blnNameOK = True
                  End If
                  If blnNameOK = True Then
                     'Good to go. Copy then kill
                     FileCopy HUBImportPath$ & "\" & strFile & ".xml", strArchivePath & "\" & strArchiveFile
                     Kill HUBImportPath$ & "\" & strFile & ".xml"
                  Else
                     popmessagecr "EMIS Health", "There are too many archive files" & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
                  End If
               Else
                   popmessagecr "EMIS Health", "The EHUB Invoice Archive path was not been configured." & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
               End If
            End If
            'Exit Sub 'Cheap way out 'Now we stay and loop for another selection
        End If
        strImportFileName = Trim$(LstBoxFrm.Tag) '22Feb16 TH cach value as the listbox will now been unloaded (TFS 146047)
        Unload LstBoxFrm '19Feb16 TH Clean up (TFS)
        strWard = strFile
        If strFile <> "" Then strFile = HUBImportPath$ & "\" & strFile & ".xml" 'rebuild file with path
      Else
         Screen.MousePointer = STDCURSOR
        'popmessagecr "EMIS Health", "No Files are ready for import"
        popmessagecr "EMIS Health", "No eHub pharmacy invoice files are ready for import" '19Feb16 TH To extend caption (TFS 145639)
      End If
   Loop While blnDelete 'If we removed a file we can loop around now for another pass
   
   If Trim$(strFile) = "" Then
      AcquireLock filelock$, False, valid '19Feb16 TH Added

      Exit Sub
   '05Feb16 TH Moved up to allow second pass on file deletion
   'ElseIf blnDelete Then
   '   'File flagged for deletion - double check here
   '   strAns = "N"
   '   askwin "eHub Invoice Upload", "Are you sure you wish to remove this eHub Invoice : " & Trim$(strWard), strAns, k
   '   If strAns = "Y" And k.escd = False Then
   '      'If we are deleting then we move to the archive and mark as deleted
   '      If Trim$(strArchivePath) <> "" Then
   '         strFile = Trim$(LstBoxFrm.Tag)
   '         strArchiveFile = strArchiveFile & "_" & Format(Now, "DDMMYYYY HHMM") & "_eHubInvoice_DELETED.xml"
   '         If fileexists(strArchivePath & "\" & strArchiveFile) Then
   '            'OK. Lets find another alternative
   '            For intloop = 65 To 90 Step 1
   '               strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & Chr$(intloop) & "_eHubInvoice_DELETED.xml"
   '               If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
   '                  blnNameOK = True
   '                  Exit For
   '               End If
   '            Next
   '         Else
   '            blnNameOK = True
   '         End If
   '         If blnNameOK = True Then
   '            'Good to go. Copy then kill
   '            FileCopy HUBImportPath$ & "\" & strFile & ".xml", strArchivePath & "\" & strArchiveFile
   '            Kill HUBImportPath$ & "\" & strFile & ".xml"
   '         Else
   '            popmessagecr "EMIS Health", "There are too many archive files" & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
   '         End If
   '      Else
   '          popmessagecr "EMIS Health", "The EHUB Invoice Archive path was not been configured." & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
   '      End If
   '   End If
   '   Exit Sub 'Cheap way out
      
   Else
      Screen.MousePointer = HOURGLASS
      'Now begin the fun - Can we load the file into the dom
      chan = FreeFile
      Open strFile For Binary Lock Read Write As #chan
      
      strxXML = Space$(LOF(chan))
      Get #chan, , strxXML
      Close #chan

      Set xmldoc = New MSXML2.DOMDocument
    
      If xmldoc.loadXML(strxXML) Then
         Screen.MousePointer = STDCURSOR
         
         'read HubInvHeader
         'read in the HubInvLines
         Set xmlNodeList = xmldoc.selectNodes("InvoiceMessage/eHubInvoiceHeader")

         For Each xmlnode In xmlNodeList
            'Get Header Info - only one in the trial !!!
            'First do a check on supplier
            'Set xmlOrderNode = xmlnode.selectSingleNode("Hospital/Organisation/Identifier/Value")
            'Set xmlOrderNode = xmlnode.selectSingleNode("Hospital/Organization/identifier/value") '04Feb16 TH Changed case using sample msg
            Set xmlOrderNode = xmlnode.selectSingleNode("HomeCareProvider/Organization/identifier/value") '04Feb16 TH Changed case using sample msg
            
            If UCase$(Trim$(xmlOrderNode.getAttribute("value"))) <> UCase$(Trim$(i_strSupcode)) Then blnSupplierMismatch = True
            HubInvHeader.LocalSupCode = UCase$(Trim$(xmlOrderNode.getAttribute("value"))) '12Feb16 TH Aded to record the supplier for the DB
            Set xmlOrderNode = Nothing
            Set xmlOrderNode = xmlnode.selectSingleNode("PurchaseOrderNumber")
            HubInvHeader.PurchaseOrderNumber = xmlOrderNode.getAttribute("value")
            Set xmlOrderNode = Nothing
            Set xmlOrderNode = xmlnode.selectSingleNode("InvoiceNumber")
            HubInvHeader.InvoiceNumber = xmlOrderNode.text
            Set xmlOrderNode = Nothing
            Set xmlOrderNode = xmlnode.selectSingleNode("PaymentDueByDate")
            HubInvHeader.PayDueByDate = xmlOrderNode.text
            Set xmlOrderNode = Nothing
            Set xmlOrderNode = xmlnode.selectSingleNode("InvoiceDate")
            HubInvHeader.InvoiceDate = xmlOrderNode.text
            Set xmlOrderNode = Nothing
            Set xmlOrderNode = xmlnode.selectSingleNode("NumberOfLines")
            HubInvHeader.numlines = xmlOrderNode.text
            Set xmlOrderNode = Nothing
           If Not blnSupplierMismatch Then
               intLineNumber = 1
               Set xmlLineList = xmldoc.selectNodes("InvoiceMessage/eHubInvoiceLine")
               For Each xmlLineNode In xmlLineList
                  ReDim Preserve HubInvLines(intLineNumber)
                  
                  
''                  Set xmlCodeNodeList = xmlLineList.selectNodes("code/coding")
''                  For Each xmlCodenode In xmlCodeNodeList
''                     Set xmlSystemcodenode = xmlCodenode.selectSingleNode("system")
''                     If xmlSystemcodenode.getAttribute("value") = "NSVCode" Then
''                        Set xmlNSVcodenode = xmlCodenode.selectSingleNode("code")
''                        HubInvLines(intLineNumber).NSVCode = xmlNSVcodenode.getAttribute("value")
''                        Set xmlNSVcodenode = Nothing
''                     End If
''                     Set xmlSystemcodenode = Nothing
''                  Next
''                  Set xmlCodeNodeList = Nothing

                  Set xmlOrderNode = xmlLineNode.selectSingleNode("NSVCode/coding/code")
                  HubInvLines(intLineNumber).NSVCode = xmlOrderNode.getAttribute("value")
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("QuantityInvoiced")
                  HubInvLines(intLineNumber).QtyInvoiced = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("UnitPrice")
                  HubInvLines(intLineNumber).UnitPrice = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("LineTotal")
                  HubInvLines(intLineNumber).LineTotal = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("LineVAT")
                  HubInvLines(intLineNumber).LineVat = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("LineVATRate")
                  HubInvLines(intLineNumber).LineVatRate = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("LineVATCode")
                  HubInvLines(intLineNumber).LineVatCode = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  Set xmlOrderNode = xmlLineNode.selectSingleNode("ExtendedPrice")
                  HubInvLines(intLineNumber).GoodsPrice = xmlOrderNode.text
                  Set xmlOrderNode = Nothing
                  
                  intLineNumber = intLineNumber + 1
               Next
               Set xmlCodeNodeList = Nothing
               
               If HubInvHeader.numlines <> (intLineNumber - 1) Then
                  'Here we have different number of lines in the file to the number of lines in the header
                  'Flag as error and dont continue.
                  Screen.MousePointer = STDCURSOR
                  popmessagecr "eHub Invoice Upload", " There is a problem loading file : " & strFile & crlf & " The number of lines in the header does not match the actual content."
                  AcquireLock filelock$, False, valid
                  Exit Sub  'Cheap way out of process
               End If
            End If
 
         Next
         
      Else
         Screen.MousePointer = STDCURSOR
         popmessagecr "eHub Invoice Upload", " There is a problem loading file : " & strFile
         AcquireLock filelock$, False, valid '19Feb16 TH Added
         Exit Sub 'Cheap way out of process
      End If
      
      '18Feb16 TH Moved archiving of the file below (TFS)
      'Archive the file
      'If Trim$(strArchivePath) <> "" Then
      '   strFile = Trim$(LstBoxFrm.Tag)
      '   strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & "_eHubInvoice.xml"
      '   If fileexists(strArchivePath & "\" & strArchiveFile) Then
      '      'OK. Lets find another alternative
      '      For intloop = 65 To 90 Step 1
      '         strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & Chr$(intloop) & "_eHubInvoice.xml"
      '         If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
      '            blnNameOK = True
      '            Exit For
      '         End If
      '      Next
      '   Else
      '      blnNameOK = True
      '   End If
      '   If blnNameOK = True Then
      '      'Good to go. Copy then kill
      '      FileCopy HUBImportPath$ & "\" & strFile & ".xml", strArchivePath & "\" & strArchiveFile
      '      Kill HUBImportPath$ & "\" & strFile & ".xml"
      '   Else
      '      popmessagecr "EMIS Health", "There are too many archive files" & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
      '   End If
      'Else
      '    popmessagecr "EMIS Health", "The EHUB Invoice Archive path was not been configured." & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
      'End If
   End If
   
   
   
   If blnSupplierMismatch Then
      Screen.MousePointer = STDCURSOR
      popmessagecr "eHub Invoicing", "The selected supplier does not match the supplier identified in the Invoice file"
   Else
   
   
   'main loop

      On Error GoTo ReadInvReadErr
      
      Screen.MousePointer = HOURGLASS '25Feb16 TH Added
      Reconcile = True

      ReDim Errs(Val(HubInvHeader.numlines)) As String * 3
      ReDim recnos&(Val(HubInvHeader.numlines))
      strReceiptMsg = ""
      lngNotReceivedOrderID = 0
      For loopvar = 1 To Val(HubInvHeader.numlines)
         CheckHubInvInfo HubInvLines(loopvar), Errs$(loopvar), HubInvHeader.PurchaseOrderNumber, recnos&(loopvar), strReceiptMsg, lngNotReceivedOrderID
      Next
      
      'TFS 138645  Here we show any msg if there are invoice rows for items not received. We then back out.
      If Trim$(strReceiptMsg) <> "" Then '22Feb16 TH This will now never happen (146056)
      
         On Error Resume Next
         strNHNumber = "Unknown"
         strCasenum = "Unknown"
         FillHeapPSOrderInfo gPRNheapID, lngNotReceivedOrderID, 1, 0
         Heap 11, gPRNheapID, "psoNameDOB", strName, 0
         Heap 11, gPRNheapID, "psoCasenumber", strCasenum, 0
         Heap 11, gPRNheapID, "psoNHnumber", strNHNumber, 0
         Heap 11, gPRNheapID, "psoSurname", strSurname, 0      '23Dec14 TH Added elements
         Heap 11, gPRNheapID, "psoForename", strForename, 0    '  "
         Heap 11, gPRNheapID, "psoDOB", strDOB, 0              '  "
         strReceiptMsg = "Insufficient stock has been received for this invoice to be processed." & _
                         crlf & "Patient: " & Trim$(strForename) & " " & Trim$(strSurname) & crlf & "DOB: " & strDOB & crlf & _
                         "Case Num: " & strCasenum & crlf & "NH Number: " & strNHNumber & _
                         crlf & strReceiptMsg
                         
         '04Feb16 TH After discusion with AS we do not create exceptions here - leave the file in situ.
         'For loopvar = 1 To Val(HubInvHeader.numlines)                                                                            '        "   If one or more invoice lines have been identified as an error
         '   'if we do have an error on any invioce line then set any non-error lines to an error                            '        "   then invoice lines not in error are set to IV9 error code
         '   If blnHasError And trimz$(Errs$(loopvar)) = "" Then                                                             '        "   effectively removing the while invioce.
         '      Errs$(loopvar) = "IV7"                                                                                    '        "
         '   End If                                                                                                       '        "
         '   ProcessHubInvInfo HubInvLines(loopvar), HubInvHeader.LocalSupCode, HubInvHeader.PurchaseOrderNumber, HubInvHeader.InvoiceNumber, MPayDate$, Errs$(loopvar), recnos&(loopvar)   '        "
         'Next
         popmessagecr "eHub Invoicing", strReceiptMsg
      Else
      
         '18Feb16 TH Moved archiving here so we wont archive on errors above
         If Trim$(strArchivePath) <> "" Then
            'strFile = Trim$(LstBoxFrm.Tag)
            strFile = strImportFileName  '22Feb16 TH Reload from cached value as the listbox has now been unloaded (TFS 146047)
            strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & "_eHubInvoice.xml"
            If fileexists(strArchivePath & "\" & strArchiveFile) Then
               'OK. Lets find another alternative
               For intloop = 65 To 90 Step 1
                  strArchiveFile = strFile & "_" & Format(Now, "DDMMYYYY HHMM") & Chr$(intloop) & "_eHubInvoice.xml"
                  If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
                     blnNameOK = True
                     Exit For
                  End If
               Next
            Else
               blnNameOK = True
            End If
            If blnNameOK = True Then
               'Good to go. Copy then kill
               FileCopy HUBImportPath$ & "\" & strFile & ".xml", strArchivePath & "\" & strArchiveFile
               Kill HUBImportPath$ & "\" & strFile & ".xml"
            Else
               popmessagecr "EMIS Health", "There are too many archive files" & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
            End If
         Else
             popmessagecr "EMIS Health", "The EHUB Invoice Archive path was not been configured." & crlf & crlf & "The import file " & strFile & ".xml cannot be removed and archived."
         End If
         
         
         blnHasError = False    '20Oct06 PJC Added (#EDI) '24Sep09 PJC ported
         If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "HubInvoiceImport", "N", "UseInvoiceDate", 0)) Then                              '31May09 TH (F0025467)  '30Mar10 CKJ Corrected spelling  [RCN P0007 F0025467]
            MPayDate$ = Left$(HubInvHeader.InvoiceDate, 2) & Mid$(HubInvHeader.InvoiceDate, 4, 2) & Right$(HubInvHeader.InvoiceDate, 4)       '  "
         Else                                                                                                                 '  "
            MPayDate$ = Left$(HubInvHeader.PayDueByDate, 2) & Mid$(HubInvHeader.PayDueByDate, 4, 2) & Right$(HubInvHeader.PayDueByDate, 4) '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
         End If                                                                                                               '  "
         For loopvar = 1 To Val(HubInvHeader.numlines)
            'We arent checking trailer totals here like in EDI !!
            'ProcessInvInfo InvLine(loopVar), MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$, Errs$(loopVar), recnos&(loopVar)                                                                                     '12Jan07 PJC Removed and replaced by switch '24Sep09 PJC ported (F0053407)
            If blnRejectWholeInvoice = False Then                                                                                                                                                              '            If the whole invioce is not rejected when one line is in error then continue as before.
               'ProcessInvInfo InvLine(loopvar), MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$, Errs$(loopvar), recnos&(loopvar)                                                                                '        "   Otherwise check the status of the order line is 4
               ProcessHubInvInfo HubInvLines(loopvar), HubInvHeader.LocalSupCode, HubInvHeader.PurchaseOrderNumber, HubInvHeader.InvoiceNumber, MPayDate$, Errs$(loopvar), recnos&(loopvar)                                                                                '        "   Otherwise check the status of the order line is 4
            Else                                                                                                                                                                                            '        "
               If recnos&(loopvar) <> 0 Then                                                                                                                                                                '08Mar07 PJC Dont attempt to get the order at this point if the item on the invoice was not found on the original order i.e.  a zero order position. ('24Sep09 PJC ported with F0053407)
                  getorder ord, recnos&(loopvar), 4, False                                                                                                                                               '        "
                  If ord.status <> "4" Then                                                                                                                                                              '        "
                     WriteLog dispdata$ & "\hub.log", SiteNumber%, "---", procname$ & "Order has not been received : " & HubInvHeader.InvoiceNumber & " , NSVCode : " & Trim$(HubInvLines(loopvar).NSVCode)     '        "
                     Errs$(loopvar) = "IV6"                                                                                                                                                           '        "
                  End If                                                                                                                                                                              '        "
               End If                                                                                                                                                                                    '08Mar07 PJC Added '24Sep09 PJC ported
            End If                                                                                                                                                                                          '        "
   
            'Test if there has been an error on a line and blnRejectWholeInvoice is set.
            If blnRejectWholeInvoice And trimz$(Errs$(loopvar)) <> "" Then                '12Jan07 PJC Set a flag to mark one or more lines are in error. '24Sep09 PJC ported (F0053407)
               blnHasError = True                                                      '         "
            End If                                                                     '         "
         Next
   
         If blnRejectWholeInvoice Then                                                                                            '12Jan07 PJC Added loop for the rejection of the Whole invoice.  '24Sep09 PJC ported  (F0053407)
            For loopvar = 1 To Val(HubInvHeader.numlines)                                                                            '        "   If one or more invoice lines have been identified as an error
               'if we do have an error on any invioce line then set any non-error lines to an error                            '        "   then invoice lines not in error are set to IV9 error code
               If blnHasError And trimz$(Errs$(loopvar)) = "" Then                                                             '        "   effectively removing the while invioce.
                  Errs$(loopvar) = "IV9"                                                                                    '        "
               End If                                                                                                       '        "
               ProcessHubInvInfo HubInvLines(loopvar), HubInvHeader.LocalSupCode, HubInvHeader.PurchaseOrderNumber, HubInvHeader.InvoiceNumber, MPayDate$, Errs$(loopvar), recnos&(loopvar)   '        "
            Next                                                                                                               '        "
         End If                                                                                                                '        "
      
      'End If '18Feb16 TH Moved below (TFS)

      
      
'07Feb16 TH Removed in refactoring as we will now match the EDI process more exactly, ie first shift to archive, and copy new recs on
'           line by line asis in processinvine
'      First Header
'      dtePaydate = CDate(Left$(MPayDate$, 2) & "/" & Mid$(MPayDate$, 3, 2) & "/" & Right$(MPayDate$, 4))
'
'      For loopvar = 1 To Val(HubInvHeader.numlines)
'         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                   gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 4, gEntityID_User) & _
'                   gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, ASCTerminalName$()) & _
'                   gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, HubInvHeader.PurchaseOrderNumber) & _
'                   gTransport.CreateInputParameterXML("Supplier", trnDataTypeVarChar, 5, HubInvHeader.LocalSupCode) & _
'                   gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, HubInvLines(loopvar).NSVCode) & _
'                   gTransport.CreateInputParameterXML("Paydate", trnDataTypeDateTime, 8, dtePaydate) & _
'                   gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, HubInvHeader.InvoiceNumber) & _
'                   gTransport.CreateInputParameterXML("InvQty", trnDataTypeint, 4, CInt(HubInvLines(loopvar).QtyInvoiced)) & _
'                   gTransport.CreateInputParameterXML("InvContractNo", trnDataTypeVarChar, 35, HubInvHeader.HeaderContNum) & _
'                   gTransport.CreateInputParameterXML("InvLineTotal", trnDataTypeFloat, 8, HubInvLines(loopvar).LineTotal) & _
'                   gTransport.CreateInputParameterXML("InvVATAmount", trnDataTypeFloat, 8, HubInvLines(loopvar).LineVat) & _
'                   gTransport.CreateInputParameterXML("InvLineExVAT", trnDataTypeFloat, 8, (HubInvLines(loopvar).LineTotal - HubInvLines(loopvar).LineVat)) & _
'                   gTransport.CreateInputParameterXML("InvVATCode", trnDataTypeVarChar, 1, HubInvLines(loopvar).LineVatRate) & _
'                   gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, HubInvLines(loopvar).ASCIssuePrice) & _
'                   gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, HubInvLines(loopvar).ASCPriceLastPaid) & _
'                   gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, HubInvLines(loopvar).ASCContractPrice) & _
'                   gTransport.CreateInputParameterXML("ASCPriceLastReconciled", trnDataTypeVarChar, 9, HubInvLines(loopvar).ASCPriceLastReconciled) & _
'                   gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, HubInvLines(loopvar).ASCContractNumber) & _
'                   gTransport.CreateInputParameterXML("ErrorCode", trnDataTypeVarChar, 3, Errs$(loopvar)) & _
'                   gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Null)
'
'
'         'lngWMediateArchiveID = gTransport.ExecuteInsertSP(g_SessionID, "WHubInvoice", strParams)
'         lngWMediateID = gTransport.ExecuteInsertSP(g_SessionID, "WHubInvoice", strParams) '05Feb16 - now upload to allow archiving later, this allows part match invoices to be held before release to AP
'      Next
'------------------
      
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "R")
         Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWHubInvoicebySiteandStatusFlag", strParams)
   
         If Not rsHUB Is Nothing Then     'use returned recordset
            If rsHUB.State = adStateOpen Then
               If rsHUB.RecordCount <> 0 Then
                  blnArchiveError = False
                  Do While Not rsHUB.EOF And Not blnArchiveError
                     'Insert into the mediate Archive
                     '18Feb16 TH Removed superfluous fields
                      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 4, RtrimGetField(rsHUB!EntityID_User)) & _
                      gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, RtrimGetField(rsHUB!terminal)) & _
                      gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, RtrimGetField(rsHUB!orderno)) & _
                      gTransport.CreateInputParameterXML("Supplier", trnDataTypeVarChar, 5, RtrimGetField(rsHUB!Supplier)) & _
                      gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, RtrimGetField(rsHUB!NSVCode)) & _
                      gTransport.CreateInputParameterXML("Paydate", trnDataTypeDateTime, 8, RtrimGetField(rsHUB!paydate)) & _
                      gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, RtrimGetField(rsHUB!InvoiceNo)) & _
                      gTransport.CreateInputParameterXML("InvQty", trnDataTypeint, 4, RtrimGetField(rsHUB!InvQty)) & _
                      gTransport.CreateInputParameterXML("InvContractNo", trnDataTypeVarChar, 35, RtrimGetField(rsHUB!InvContractNo)) & _
                      gTransport.CreateInputParameterXML("InvLineTotal", trnDataTypeFloat, 4, RtrimGetField(rsHUB!InvLineTotal)) & _
                      gTransport.CreateInputParameterXML("InvVATAmount", trnDataTypeFloat, 4, RtrimGetField(rsHUB!InvVATAmount)) & _
                      gTransport.CreateInputParameterXML("InvLineIExVAT", trnDataTypeFloat, 4, RtrimGetField(rsHUB!InvLineExVAT)) & _
                      gTransport.CreateInputParameterXML("InvVATCode", trnDataTypeVarChar, 1, RtrimGetField(rsHUB!InvVATCode)) & _
                      gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, RtrimGetField(rsHUB!ASCIssuePrice))
                      strParams = strParams & gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, RtrimGetField(rsHUB!ASCPriceLastPaid)) & _
                      gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, RtrimGetField(rsHUB!ASCContractPrice)) & _
                      gTransport.CreateInputParameterXML("ASCPriceLastReconciled", trnDataTypeVarChar, 9, RtrimGetField(rsHUB!ASCPriceLastReconciled)) & _
                      gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, RtrimGetField(rsHUB!ASCContractNumber)) & _
                      gTransport.CreateInputParameterXML("ErrorCode", trnDataTypeVarChar, 3, RtrimGetField(rsHUB!ErrorCode)) & _
                      gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, RtrimGetField(rsHUB!StatusFlag)) & _
                      gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, RtrimGetField(rsHUB!date))
         
          
                      lngWHubInvoiceArchiveID = gTransport.ExecuteInsertSP(g_SessionID, "WHubInvoiceArchive", strParams)
                     If lngWHubInvoiceArchiveID = 0 Then blnArchiveError = True
                     rsHUB.MoveNext
                  Loop
               End If
            End If
         End If
   
         If Not blnArchiveError Then
            If Not rsHUB Is Nothing Then     'use returned recordset
               If rsHUB.State = adStateOpen Then
                  If rsHUB.RecordCount <> 0 Then
                     rsHUB.MoveFirst
                     Do While Not rsHUB.EOF
                        'lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WMediate", RtrimGetField(rsHUB!WHUBInvoiceID))
                        lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WHUBINvoice", RtrimGetField(rsHUB!WHUBInvoiceID)) '09Mar16 TH We need to delete from the HUBINvoice table (this would have been a problem with Genfin)
                        rsHUB.MoveNext
                     Loop
                  End If
               End If
            End If
         End If
         rsHUB.Close
         Set rsHUB = Nothing
         On Error GoTo 0
   
         'Screen.MousePointer = STDCURSOR '25Feb16 TH Removed
         
         If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "Y", "InProcessExceptionsReport", 0)) Then
            If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "Y", "TodaysExceptions", 0)) Then
               strDate = Format(date, "dd") & "/" & Format(date, "mm") & "/" & Format(date, "yyyy")
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "I") & _
                           gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Now)
               Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWHubInvoiceforTodaysExceptionsRpt", strParams)
            Else
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
               Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWHubInvoiceforExceptionsRpt", strParams)
      
            End If
            
            '08Feb16 TH Added. Only offer to print exceptions if there are any to print (TFS 144215)
            If rsHUB.RecordCount > 0 Then
               'Confirm "Hub Invoice Exception Report", "print Exception Report", ans$, k
               Screen.MousePointer = STDCURSOR
               'Confirm "eHub Invoice Exception Report", "Print pharmacy eHub invoice exception report", ans$, k  '19Feb16 TH Extend msg stop truncation of caption (TFS 145492)
               Confirm "eHub Invoice Exceptions", "Print pharmacy eHub invoice exception report", ans$, k  '25Feb16 TH Further mod after testing
               Screen.MousePointer = HOURGLASS
               
               If Not k.escd And Trim$(UCase$(ans$)) = "Y" Then
                  'Now we need to do the report
                  'First lets get the recordset we intend to use
                  ''08Feb16 TH Modified exception handling to use full datetime (TFS 138628)
                  'If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "Y", "TodaysExceptions", 0)) Then
                  '   strDate = Format(date, "dd") & "/" & Format(date, "mm") & "/" & Format(date, "yyyy")
                  '   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  '               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "I") & _
                  '               gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Now)
                  '   Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWHubInvoiceforTodaysExceptionsRpt", strParams)
                  'Else
                  '   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
                  '   Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWHubInvoiceforExceptionsRpt", strParams)
                  'End If
                  
                  If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "N", "UseCrystal", 0)) Then '03Feb16 TH Use rtf as default '09Mar16 TH Changed setting
                     Set crxApp = New CRAXDDRT.Application
                     blnNoCrystalReport = False
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "Y", "CrystalDBReports", 0)) Then  '14Nov16 TH Added new section to get reports from the DB (TFS 157972)
                        strReportName = getCrystalFilefromSQL("\hubexcpt.rpt")
                        If strReportName = "" Then
                           Screen.MousePointer = STDCURSOR
                           popmessagecr "Error", "eHub Exceptions Crystal report file missing from Database." & Chr$(13) & Chr$(13) & "Cannot Print Expired Batches Report."   '12Jan99 TH
                           blnNoCrystalReport = True
                        End If
                     Else
                        strReportName = dispdata$ & "\hubexcpt.rpt"
                        If Not fileexists(dispdata$ & "\hubexcpt.rpt") Then
                           Screen.MousePointer = STDCURSOR
                           popmessagecr "!", "Could not print report. File " & dispdata$ & strRTFLayout & " not found"
                           blnNoCrystalReport = True
                        End If
                     End If
                      
                     If Not blnNoCrystalReport Then
                        Set crxRpt = crxApp.OpenReport(strReportName)
                        'rsHUB.Sort = "ScreenPosn"
                        crxRpt.Database.SetDataSource rsHUB
                        If UCase$(PrintToScreen$) = "Y" Then
                           Dim FormReport As New FrmReport
                           FormReport.CRViewer.ReportSource = crxRpt
                           FormReport.CRViewer.ViewReport
                           'FormReport.CRViewer.PrintReport
                           Screen.MousePointer = STDCURSOR
                           FormReport.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                           Unload FormReport
                           Set FormReport = Nothing
                        Else
                           crxRpt.PrintOut
                           Screen.MousePointer = STDCURSOR
                        End If
                     End If
                     rsHUB.Close
                     Set rsHUB = Nothing
                     Set crxRpt = Nothing
                     Set crxApp = Nothing
                  Else
                     'DO rtf here
                     strRTFLayout = "\Hubexcep.rtf"
                     strContext = "Hubexcep"
                     GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, intSuccess '05Jan17 TH Moved here to utilise check (Hosted)
                     'If fileexists(dispdata$ & strRTFLayout) Then
                     If intSuccess Then
                        'GetTextFile dispdata$ & strRTFLayout, strRTFTxt, 0
                        'GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)

                        SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
                        MakeLocalFile strTmpFile                                                  'Tmp file used to
                        intTmpFileNo = FreeFile                                                   'build report
                        Open strTmpFile For Binary Access Write Lock Read Write As intTmpFileNo
                        
                        'Header Info
                        
                        '25Feb16 TH Get the supplier here, the header code has been checked so we know this is OK (TFS 145633)
                        clearsup sup
                        getsupplier HubInvHeader.LocalSupCode, 0, 0, sup
                        
                        FillHeapSupplierInfo gPRNheapID, sup, success
                        ParseItems gPRNheapID, strPgHdr, 0
                        Put intTmpFileNo, , strPgHdr
                        Do While Not rsHUB.EOF
                           'Put relevant info on the heap
                           'Heap 10, gPRNheapID, "iDescription", Trim$(temp$), 0
                           Heap 10, gPRNheapID, "OrderNo", Trim$(GetField(rsHUB!orderno)), 0    '22Sep05 TH Added
                           Heap 10, gPRNheapID, "InvoiceNo", Trim$(GetField(rsHUB!InvoiceNo)), 0
                           Heap 10, gPRNheapID, "InvQty", Trim$(GetField(rsHUB!InvQty)), 0  '18Aug04 TH DIscharge interface
                           Heap 10, gPRNheapID, "NSVCode", Trim$(GetField(rsHUB!NSVCode)), 0  '08Feb16 TH Added as was easier than editing the rtf !
                           '''Heap 10, gPRNheapID, "LocalCode", Trim$(GetField(rsHUB!localcode)), 0
                           strTemp = Format$(Val(GetField(rsHUB!ASCPriceLastReconciled)) / 100, "#0.00")
                           Heap 10, gPRNheapID, "ConvertPrice", strTemp, 0
                           Heap 10, gPRNheapID, "ErrorCode", Trim$(GetField(rsHUB!ErrorCode)), 0
                           Select Case UCase(Trim$(GetField(rsHUB!ErrorCode)))
                              Case "NO1": strTemp = "No matching order was found on the System."
                              Case "IV1": strTemp = "Discount / Addition was posted with the Invoice."
                              Case "IV2": strTemp = "Part of this item is still outstanding."
                              Case "IV3": strTemp = "Not all items ordered on system are present on the Invoice."
                              Case "IV4": strTemp = "Price in Invoice record is outside of Invoice bounds."
                              Case "IV5": strTemp = "VAT rate from hub is different to VAT rate in Pharmacy."
                              Case "IV6": strTemp = "Order had not been received."
                              Case "IV7": strTemp = "Invoice quantity does not match the quantity received."
                              Case "IV8": strTemp = "Invoice quantity is zero."
                              Case Else: strTemp = ""
                           End Select
                           Heap 10, gPRNheapID, "ErrorCodeText", strTemp, 0
                           'Heap act, id, "InvLineTotal", Trim$(GetField(rsHUB!InvLineTotal)), 0
                           BlankWProduct d
                           d.SisCode = RtrimGetField(rsHUB!NSVCode)
                           
                           getdrug d, 0, 0, False
                           FillHeapDrugInfo gPRNheapID, d, 0
                           
                           strDetailLine = strPgItem
                           ParseItems gPRNheapID, strDetailLine, 0
                           Put intTmpFileNo, , strDetailLine
            
                        
                           rsHUB.MoveNext
                        Loop
                        'If we need a footer put parsable elements here
                        ParseItems gPRNheapID, strPgEnd, 0
                     
                        Put intTmpFileNo, , strPgEnd
                        'Print and cleanup
                        Close intTmpFileNo
                        'ParseThenPrint strContext, strTmpFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
                        ParseThenPrint strContext, strTmpFile, 1, 0, False, True '04Jan17 TH Use Local File Parsing (Hosted)
                        On Error Resume Next
                        Kill strTmpFile
                        On Error GoTo 0
                     Else
                        Screen.MousePointer = STDCURSOR
                        'popmessagecr "!", "Could not print report. File " & dispdata$ & strRTFLayout & " not found"
                        popmessagecr "!", "Could not print report. RTF " & strRTFLayout & " not found in database"
                     End If
                  End If
               End If
            Else
               '08Feb16 TH Added.We can tell the user there are no current exceptions (TFS 144215)
               Screen.MousePointer = STDCURSOR
               popmessagecr "eHub Invoicing", "No Exceptions from HUB invoice upload"
            End If
         End If
         'Screen.MousePointer = 11
      End If
   
   End If
   'release lock to allow other terminals to use mediate link
   AcquireLock filelock$, False, valid

   Screen.MousePointer = STDCURSOR

Exit Sub


'---------------------------------------------------------------------------------------------------
'ERROR Handlers
' {SP2} scope for reduction here
'---------------------------------------------------------------------------------------------------

ReadInvOpenErr:
   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to open file : " & InvFile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)

   popmessagecr "Pharmacy Hub Link", msg$

Resume Next


ReadInvReadErr:
   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to read from file : " & InvFile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)

   popmessagecr "Pharmacy Hub Link", msg$

Resume Next

Archive_Err:
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Unable to archive data from Pharmacy Hub to Archive in database" & cr$
   msg$ = msg$ & "Please contact EMIS Health for support."

   popmessagecr "Pharmacy Hub Link", msg$

   success = False
Resume Next


End Sub


Sub HubSupplierSetup()
'07Nov01 TH New sub based on previous settings routine but with the ability to
'           specify settings by supplier

'SQL 01Mar05 TH Removed - editor required elsewhere.
'01Feb16 TH Changed input (TFS 138644)

Dim HubSup As supplierstruct, strSupCode As String


'Present E type suppliers for user selection
   clearsup HubSup
   'asksupplier "", 0, "E", "Select Homecare Supplier", False, HubSup, True '15Nov12 TH Added PSO param
   asksupplier "", 0, "E", "Select Homecare Supplier", False, HubSup, PSO  '01Feb16 TH Changed input (TFS 138644)
   If Trim$(HubSup.Code) <> "" Then

         'Once supplier selected then load the settings associated with this supplier
         'If there is no file for this supplier then create one base on the default EDI.Dat file (done in the read)

         'Set default settings
         strSupCode = HubSup.Code
         ReadHUBDefaults strSupCode
         If strSupCode = "NOHUBFILE" Then Exit Sub
         QuesCallbackMode = 17

         Ques.Caption = "eHub Link Defaults"

         QuesMakeCtrl 1, 2
         Ques.lblDesc(1) = "1) Import Directory"
         QuesSetCtrl Ques.cmdQ(1), 0, 0, "Change"
         Ques.lblInfo(1) = Trim$(HUBImportPath$)

         

         QuesMakeCtrl 2, 0
         Ques.lblDesc(2) = "Off-Contract Settings"

         

         QuesMakeCtrl 3, 1
         Ques.lblDesc(3) = "2) % below allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(3), 1, 3, Format$(HUBInvLowerDiff)
         Ques.lblInfo(3) = "%"

         QuesMakeCtrl 4, 1
         Ques.lblDesc(4) = "3) % above allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(4), 1, 3, Format$(HUBInvUpperDiff)
         Ques.lblInfo(4) = "%"

         '22Nov00 EAC/CY allow seperate variances for on-contract goods
         QuesMakeCtrl 5, 0
         Ques.lblDesc(5) = "On-Contract Settings"

         

         QuesMakeCtrl 6, 1
         Ques.lblDesc(6) = "4) % below allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(6), 1, 3, Format$(HUBInvLowerDiffOC)
         Ques.lblInfo(6) = "%"

         QuesMakeCtrl 7, 1
         Ques.lblDesc(7) = "5) % above allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(7), 1, 3, Format$(HUBInvUpperDiffOC)
         Ques.lblInfo(7) = "%"

         QuesShow 8

         Unload Ques
      End If

End Sub
Sub ReadHUBDefaults(ByRef strSupCode As String)
'16Jan02 TH Added supcode parameter to Sub and use this to get settings, copying default settings into
'    "      new supplier specific settings file - pass back no file error as oParameter (%EDI)

Dim MEDIhdl%, loopagain%, ErrNo%, errored%, retries%
Dim msg$
Dim strHUBSection As String
Dim blnSaveSettings As Boolean


   'OK now we are just using plain configuration settings
   'First we will test the export path setting (this must be present - if not out they go !!
   
   strHUBSection = strSupCode
   
   HUBImportPath = TxtD(dispdata$ & "\PSO.ini", strSupCode, "", "HUBImportPath", 0)
    
   If HUBImportPath = "" Then
      'Now we try and load the defaults
      HUBImportPath = TxtD(dispdata$ & "\PSO.ini", "Default", "", "HUBImportPath", 0)
      If Trim$(HUBImportPath) = "" Then
         popmessagecr "eHub Configuration Error", "Cannot read default configuration settings for eHub" & crlf & crlf & _
                                                 "Please Inform your system administrator"
         strSupCode = "NOHUBFILE"  '16Jan02 TH Flag no file (%EDI%)
         Exit Sub
      Else
         'Load the defaults as normal but then save them as the new supplier
         blnSaveSettings = True
         strHUBSection = "Default"
      End If
   End If
   
   'Now we load the rest of the stuff from the section
   
   HUBInvLowerDiff = Val(TxtD(dispdata$ & "\PSO.ini", strHUBSection, "", "HUBInvLowerDiff", 0))
   HUBInvUpperDiff = Val(TxtD(dispdata$ & "\PSO.ini", strHUBSection, "", "HUBInvUpperDiff", 0))
   HUBImportPath$ = TxtD(dispdata$ & "\PSO.ini", strHUBSection, "", "HUBImportPath", 0)
   HUBInvLowerDiffOC = Val(TxtD(dispdata$ & "\PSO.ini", strHUBSection, "", "HUBInvLowerDiffOC", 0))
   HUBInvUpperDiffOC = Val(TxtD(dispdata$ & "\PSO.ini", strHUBSection, "", "HUBInvUpperDiffOC", 0))
   
   
   If HUBInvLowerDiffOC = 0 Then HUBInvLowerDiffOC = HUBInvLowerDiff
   If HUBInvUpperDiffOC = 0 Then HUBInvUpperDiffOC = HUBInvUpperDiff
   
   If blnSaveSettings Then
      WritePrivateIniFile strSupCode, "HUBInvLowerDiff", Format$(HUBInvLowerDiff), dispdata$ & "\PSO.ini", 0
      WritePrivateIniFile strSupCode, "HUBInvUpperDiff", Format$(HUBInvUpperDiff), dispdata$ & "\PSO.ini", 0
      WritePrivateIniFile strSupCode, "HUBImportPath", HUBImportPath$, dispdata$ & "\PSO.ini", 0
      WritePrivateIniFile strSupCode, "HUBInvLowerDiffOC", Format$(HUBInvLowerDiffOC), dispdata$ & "\PSO.ini", 0
      WritePrivateIniFile strSupCode, "HUBInvUpperDiffOC", Format$(HUBInvUpperDiffOC), dispdata$ & "\PSO.ini", 0
   End If



'If errored Then strSupCode = "NOHUFILE" '02Mar16 TH This never got set.
                 
m_strHubSupcode = strSupCode

End Sub

Sub CheckHubInvoiceSettings(ctrlindex%)
'22Nov00 EAC/CY Allow seperate variances for On-Contract items
'16Jan02 TH  Pass supcode into SaveMediateDeaults call (%EDI%)
'15Jul02 TH  Added last minute catch all as OK was allowing last untabbed item to be missed previously
'02Apr04 CKJ {SP1} removed unused params errmsg$, NewIndex% (CtrlIndex%, errmsg$, NewIndex%)

'Need AN Editor here !!!

Dim escd%
Dim DirName$

   Select Case ctrlindex
      Case 0         'OK button selected
         'Save Hub Defaults
         '15Jul02 TH Added as last minute catch all as OK was allowing one item to be missed previously
         If Val(Ques.txtQ(3)) >= 0 Then HUBInvLowerDiff = Val(Ques.txtQ(3))
         If Val(Ques.txtQ(4)) >= 0 Then HUBInvUpperDiff = Val(Ques.txtQ(4))
         If Val(Ques.txtQ(6)) >= 0 Then HUBInvLowerDiffOC = Val(Ques.txtQ(6))
         If Val(Ques.txtQ(7)) >= 0 Then HUBInvUpperDiffOC = Val(Ques.txtQ(7))
         '----------------------------------------
         SaveHubInvoiceDefaults m_strHubSupcode
      
      Case 1     'change import directories
         DirName$ = Ques.lblInfo(ctrlindex).Caption
         ShowSelDir DirName$, escd%
         If Not escd% Then
               Ques.lblInfo(ctrlindex).Caption = DirName$
               If ctrlindex = 1 Then
                     HUBImportPath$ = DirName$
                  'Else
                  '   MEDIExportPath$ = DirName$
                  End If
            End If
      
      Case 3, 4, 5, 6
         If Ques.txtQ(ctrlindex) >= 0 Then
               Select Case ctrlindex
                  Case 3:  HUBInvLowerDiff = Val(Ques.txtQ(ctrlindex))
                  Case 4:  HUBInvUpperDiff = Val(Ques.txtQ(ctrlindex))
                  Case 6:  HUBInvLowerDiffOC = Val(Ques.txtQ(ctrlindex))
                  Case 7:  HUBInvUpperDiffOC = Val(Ques.txtQ(ctrlindex))
                  End Select
            Else
               popmessagecr "Error", "Please enter a positive value for this field"
               Select Case ctrlindex
                  Case 3:  Ques.txtQ(ctrlindex) = Format$(MediateInvLowerDiff)
                  Case 4:  Ques.txtQ(ctrlindex) = Format$(MediateInvUpperDiff)
                  Case 6: Ques.txtQ(ctrlindex) = Format$(MediateInvLowerDiffOC)
                  Case 7: Ques.txtQ(ctrlindex) = Format$(MediateInvUpperDiffOC)
                  End Select
            End If
      End Select

End Sub

Sub SaveHubInvoiceDefaults(ByVal i_strSupcode As String)


Const procname$ = "SaveHubInvoiceDefaults"
Dim strHUBSection As String

   strHUBSection = i_strSupcode

   
   WritePrivateIniFile strHUBSection, "HUBInvLowerDiff", Format$(HUBInvLowerDiff), dispdata$ & "\PSO.ini", 0
   WritePrivateIniFile strHUBSection, "HUBInvUpperDiff", Format$(HUBInvUpperDiff), dispdata$ & "\PSO.ini", 0
   WritePrivateIniFile strHUBSection, "HUBInvLowerDiffOC", Format$(HUBInvLowerDiffOC), dispdata$ & "\PSO.ini", 0
   WritePrivateIniFile strHUBSection, "HUBInvUpperDiffOC", Format$(HUBInvUpperDiffOC), dispdata$ & "\PSO.ini", 0
   WritePrivateIniFile strHUBSection, "HUBImportPath", HUBImportPath$, dispdata$ & "\PSO.ini", 0
   
   

End Sub

Sub CheckHubInvInfo(InvHubLine As HubInvoiceLine, ByRef errcode As String, InvOrderNo$, ByRef lngOrdRecNo As Long, ByRef strReceiptMsg As String, ByRef lngNotReceivedOrderID As Long)
'11Feb98 EAC Check Invoice Quantity matches received quantity
'25Jun98 EAC stop rounding errors making cost outside of limits
'25Jun98 EAC don't care about contract number when looking for contract price.
'25Jun98 EAC check for zero quantity in the invoice and reject with correct msg
'12Oct99 TH  Changed to search on correct index
'22Nov00 EAC/CY Allow seperate variances for On-Contract items
'05Aug02 TH Added trimming around invoicenumber in scanorder
'07Aug02 TH Added padding around invoicenumber  for <1000 ordernums
'03Oct08 TH Changed our rounding of our vat rate as was excepting 5% as 4.99999% (F0024736)
'28Sep09 PJC removed the 100 multiplier added configurable dp for Round function (F0024736)
'16May10 TH Added val on IV2 order outstanding check (F0069847)
'27May10 AJK F0061692 Added EDILinkCode check
'27Jan15 TH Added receiptmsg param (TFS 138645)
'01Feb16 TH Added handling for receipt check (TFS 138645)
'18Feb16 TH Added orderID param to get pat details in main sub (TFS 138645)
'18Feb16 TH Modifications and rework after initial testing (TFS 138645)
'22Feb16 TH Removed HUB Receipt check after discussion with Sue and Andrew (TFS 146056)

Dim matched%
Dim cont&, fnd&
Dim issueprice!, lowerlimit!, upperlimit!
Dim ourvatrate$, medvatrate$
Dim foundPtr As Long  '01Jun02 ALL/ATW
Dim rsInvoices As ADODB.Recordset
Dim strParams As String
Dim ord As orderstruct
Dim strDrugDescription As String '01Feb16 TH Added (TFS 138645)

   'find order on ASCribe Database and update the information appropriately
   'tofind$ = Trim$(Right$(InvOrderNo$, Len(InvOrderNo$) - 4))
   cont& = 0
   fnd& = 0

   ''Do
   matched = False
   'SQL Need to bring back ids recordset
   'Look up on num here but use a non-standard sp because we only want the ID's
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeint, 4, "4") & _
               gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(InvOrderNo$))
   'Set rsInvoices = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisIDsbyStatusandNum", strParams)
   Set rsInvoices = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyStatusandNum", strParams)
   If Not rsInvoices Is Nothing Then     'use returned recordset
      If rsInvoices.State = adStateOpen Then
         If rsInvoices.RecordCount <> 0 Then
            Do While Not rsInvoices.EOF And Not matched
               fnd& = rsInvoices!WReconcilID
               If fnd& > 0 Then
                  getorder ord, fnd&, 4, False
                  If Val(ord.status) = 4 Then
                     d.SisCode = ord.Code
                     getdrugsup d, 0, foundPtr&, False, ord.supcode
                     '27May10 AJK F0061692 Added EDILinkCode check
                     'If Trim$(InvLine.localcode) = Trim$(d.barcode) Or Trim$(InvLine.localcode) = Trim$(ord.Code) Or (Trim$(InvLine.localcode) = Trim$(d.EDILinkCode) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True) Then
                     If Trim$(InvHubLine.NSVCode) = Trim$(d.SisCode) Then 'Currently we will only match on NSVCode
                        matched = True
                     End If
                  End If
               End If
               rsInvoices.MoveNext
            Loop
         Else
            'we have no receipt record
         End If
      End If
   End If
   ''Loop While fnd& > 0 And Not matched
   rsInvoices.Close
   Set rsInvoices = Nothing
   lngOrdRecNo = fnd&

   If matched And fnd& > 0 Then
         '25Jun98 EAC check for zero quantity in the invoice and reject with correct msg
         If Val(InvHubLine.QtyInvoiced) = 0 Then
            errcode$ = "IV8"
         End If
         
         'If Trim$(d.contprice) <> "" Then                            '12Jan07 PJC Replaced by below.                  (#92613)
         'If Val(d.contprice) > 0 Then                                 '12Jan07 PJC Use the val of the contract price   (#92613)  03Aug07 CKJ ported from 8.7
         '   issueprice! = Val(d.contprice)
         'ElseIf Trim$(d.lastreconcileprice) <> "" Then
         '   issueprice! = Val(d.lastreconcileprice)
         'Else
         '   issueprice! = Val(d.cost)
         'End If
         issueprice! = Val(ord.cost)  '19Feb16 TH Replaced above - for HUB we will only check the invoice against the price the order was raised at (TFS 145946)

         lowerlimit! = issueprice! * (1 - (HUBInvLowerDiff / 100!))
         upperlimit! = issueprice! * (1 + (HUBInvUpperDiff / 100!))
         
         If Trim$(d.contno) <> "" Then
            lowerlimit! = issueprice! * (1 - (HUBInvLowerDiffOC / 100!))
            upperlimit! = issueprice! * (1 + (HUBInvUpperDiffOC / 100!))
         End If
         
         If TransLogVAT Then
            issueprice! = Val(InvHubLine.UnitPrice) * 100! 'NB now in pence!!
         Else
            issueprice! = (Val(InvHubLine.UnitPrice) + ((Val(InvHubLine.LineVatRate) / 100) * Val(InvHubLine.UnitPrice))) * 100!   'NB now in pence!!
         End If
         
         'If issueprice! < lowerlimit! Or issueprice! > upperlimit! Then  '25Jun98 EAC stop rounding errors making cost outside of limits
         If dp!(issueprice!) < dp!(lowerlimit!) Or dp!(issueprice!) > dp!(upperlimit!) Then
            errcode$ = "IV4"
            Exit Sub
         End If
         
         'check that VAT Rate is the same for the Mediate Line and our drug record
         'ourvatrate$ = Format$((VAT(Val(d.vatrate)) - 1), "")
         'ourvatrate$ = Format$(round(100 * (VAT(Val(d.vatrate)) - 1), 2)) '03Oct08 TH was excepting 5% as 4.99999% (F0024736)
         ourvatrate$ = Format$(round((VAT(Val(d.vatrate)) - 1), Val(TxtD(dispdata$ & "\winord.ini", "Hub", "4", "RoundValue", 0))))
         medvatrate$ = Format$((Val(InvHubLine.LineVatRate) / 100), "")
         If medvatrate$ <> ourvatrate$ Then
            errcode$ = "IV5"
            Exit Sub
         End If

         'If Not (ord.received = ord.qtyordered And Val(ord.outstanding) = 0) Then
         '18Feb16 TH REmoved IV2 for HUB as the order may validly be fulfilled by a number of PODs so outstanding amount is allowed.
         'If Not (Val(ord.received) = Val(ord.qtyordered) And Val(ord.outstanding) = 0) Then '16May10 TH Added val (F0069847)
         '   errcode$ = "IV2"
         'End If

         If Not (Val(ord.received) = Val(InvHubLine.QtyInvoiced)) Then
            errcode$ = "IV7"
         End If
         
         '27Jan15 TH Here we are looking explicitly for a row where the receipt qty is less than invoiced.
         '!!!!!! What if the invoice spans multiple receipts. THen we need to check the user can "amalgamate" these otherwise they will be rejected I think
         'After AS Discussion its one POD to one invoice for phase 1
         
         '22Feb16 TH Removed after discussion with Sue and Andrew (TFS 146056)
         ''If Not (Val(ord.received) < Val(InvHubLine.QtyInvoiced)) Then
         'If (Val(ord.received) < Val(InvHubLine.QtyInvoiced)) Then   '18Feb16 TH Fixed (TFS)
         '   strDrugDescription = d.storesdescription
         '   plingparse strDrugDescription, "!"
         '   strReceiptMsg = strReceiptMsg & strDrugDescription & crlf
         '   errcode$ = "IV7"
         '   If lngNotReceivedOrderID = 0 Then lngNotReceivedOrderID = ord.OrderID
         'End If
         
         
      Else
         errcode$ = "NO1"
      End If

End Sub

Sub ProcessHubInvInfo(ByRef InvLine As HubInvoiceLine, ByVal InvSupCode$, ByVal InvOrderNo$, ByVal InvInvoiceNo$, ByVal InvPayDate$, ByRef errcode$, ByVal OrdRecNo&)

'22Oct97 EAC added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'17Dec97 EAC allow for free items
'11Feb98 EAC correct value of adjust! for free items
'26Feb98 EAC Correct adjustment fiqure written to log
'07Dec00 AW  changed invoicenum$ to InvInvoiceNo$, invoicenum$ not set in this module
'15Jan02 TH  Added time for the orderlog (#53214)
'28Jan04 TH  Added update of new reconciledate field
'27May10 AJK F0061692 Check to see if localcode is an EDILinkCode
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'08Feb16 TH  Mod to ensure the exceptions are captured in the table correctly (TFS 138638)
'02Mar16 TH  Changed Paydate to genuine date - previously it was sending strPaydate into DB and was being mangled (TFS 146872)

Const procname$ = "ProcessInvInfo"
Dim adjust!
Dim matched%, DoReconciliation%
Dim purprice$, daterec$, qtyord$, qtyrec$, rectype$, baltype$
Dim localcode$, ans$, msg$

Dim foundPtr As Long
Dim blnFound As Integer
Dim strParams As String
Dim strOrderNo As String
Dim strLocalCode As String
Dim strOPCode As String
Dim strASCIssuePrice As String
Dim strASCPriceLastPaid As String
Dim strASCContractPrice As String
Dim strASCPriceLastReconciled As String
Dim strASCContractNumber As String
Dim lngWHubInvoiceID As Long
Dim strInvQty As String
Dim strInvContractNo As String
Dim strInvLineTotal As String
Dim strInvVATAmount As String
Dim strInvLineExVat As String
Dim strInvVATCode As String
Dim strPaydate As String
Dim strInvoiceNo As String
Dim strDateLastModified As String
Dim strErrorCode As String
Dim strStatusFlag As String
Dim lngOK As Long
'03Aug07 CKJ ported from 8.7
Dim dblGoodsIncVAT As Double
Dim dblGoodsExVAT As Double
Dim dblLineValue As Double
Dim dblGoodsVAT As Double
Dim rsTemp As ADODB.Recordset
Dim ord As orderstruct
Dim dtePayDate As Date   '02Mar16 TH Added (TFS 146872)

   localcode$ = Trim$(InvLine.NSVCode)
   
   strOrderNo = InvOrderNo$
   strLocalCode = Trim$(localcode$)
   strOPCode = InvSupCode$
   BlankWProduct d
   '27May10 AJK F0061692 Check to see if localcode is an EDILinkCode - TH Old way of EDI working - should never happen now as NSVCode should be only ID, but you never know in the future ...
   If Len(Trim$(localcode$)) = 13 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True Then
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
         gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, localcode$)
      Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByEDILinkCode", strParams)
      If rsTemp.RecordCount > 0 Then
         d.SisCode = RtrimGetField(rsTemp!SisCode)
      End If
   End If
   If RTrim$(d.SisCode) = "" Then
      If Len(Trim$(localcode$)) = 7 Then
         d.SisCode = Trim$(localcode$)  'TH At present for HUB this should be the only possibility
      Else
         d.barcode = Trim$(localcode$)
      End If
   End If
   getdrug d, 0, foundPtr, False
   strASCIssuePrice = Format$(Val(d.cost))
   InvLine.ASCIssuePrice = strASCIssuePrice
   strASCPriceLastPaid = Format$(Val(d.sislistprice))
   InvLine.ASCPriceLastPaid = strASCPriceLastPaid
   strASCContractPrice = Format$(Val(d.contprice))
   InvLine.ASCContractPrice = strASCContractPrice
   strASCPriceLastReconciled = Format$(Val(d.lastreconcileprice))
   InvLine.ASCPriceLastReconciled = strASCPriceLastReconciled
   strASCContractNumber = d.contno
   InvLine.ASCContractNumber = strASCContractNumber
   lngWHubInvoiceID = 0
   strErrorCode = ""
            
   
   strInvQty = InvLine.QtyInvoiced
   strInvContractNo = InvLine.LineContNum

   strInvLineTotal = Val(InvLine.GoodsPrice) + (Val(InvLine.GoodsPrice) * (Val(InvLine.LineVatRate) / 100))
   strInvVATAmount = (Val(InvLine.GoodsPrice) * (Val(InvLine.LineVatRate) / 100))
   strInvLineExVat = Val(InvLine.GoodsPrice)
   strInvVATCode = InvLine.LineVatCode
   

   strPaydate = InvPayDate$
   
   '02Mar16 TH Added to ensure we get correct date sent (TFS 146872)
   If Trim$(strPaydate) <> "" Then
      If Len(Trim$(strPaydate)) <> 8 Then
         'This is not a recognised date for us here, so we will just send null
         dtePayDate = Null
      Else
         dtePayDate = CDate(Left$(strPaydate, 2) & "/" & Mid$(strPaydate, 3, 2) & "/" & Mid$(strPaydate, 5, 4))
      End If
   End If
   
   strInvoiceNo = InvInvoiceNo$
   strDateLastModified = Format$(Now, "dd/mm/yyyy")
   If Trim$(strErrorCode) = "" Then strErrorCode = errcode$
   
   If trimz$(errcode$) = "" And trimz$(strErrorCode) = "" Then  '08Feb16 TH Added to ensure the exceptions are captured in the table correctly (TFS 138638)
      strStatusFlag = "A"
   Else
      strStatusFlag = "I"
   End If
   
   If trimz$(errcode$) = "" And trimz$(strErrorCode) = "" Then
      If OrdRecNo& > 0 Then
         getorder ord, OrdRecNo&, 4, True
         DoReconciliation = True
         If ord.status <> "4" Then
            WriteLog dispdata$ & "\Hub.log", SiteNumber%, "---", procname$ & "Order has not been received : " & InvOrderNo$ & " , Local Code : " & Trim$(localcode$)
            strStatusFlag = "I"
            strErrorCode = "IV6"
            DoReconciliation = False
         End If

         If DoReconciliation Then
            'perform automatic reconciliation
            ord.internalmethod = "V"  '!!!!! Yes think so
            If Val(InvLine.QtyInvoiced) = 0 Then
                purprice$ = "0"
            Else
                purprice$ = Format$((Val(InvLine.GoodsPrice) * 100!) / Val(InvLine.QtyInvoiced))
            End If
            d.SisCode = ord.Code
            getdrug d, 0, foundPtr, True     '<== LOCK DRUG
            If Val(InvLine.QtyInvoiced) = 0 Then
               adjust! = 0
            Else
               adjust! = ((Val(InvLine.GoodsPrice) * 100!) - (Val(ord.cost) * Val(ord.received)))
            End If
            d.lastreconcileprice = purprice$
            If Val(ord.cost) <> Val(purprice$) Then adjustissueprice d, adjust!
            daterec$ = thedate(False, True)
            daterec$ = daterec$ & thedate(0, -2)
            qtyord$ = ord.outstanding
            qtyrec$ = ord.received
            
            '03Aug07 CKJ ported block from 8.7
            'store VAT rate
            ord.VATRateCode = d.vatrate
            ord.VATRatePCT = CStr(VAT(Val(d.vatrate)))

            dblLineValue = (Val(purprice$) * Val(InvLine.QtyInvoiced))
            
            dblGoodsIncVAT = dblLineValue * VAT(Val(d.vatrate))
            dblGoodsIncVAT = DblRound(dblGoodsIncVAT, 0, 0)
            dblGoodsIncVAT = dblGoodsIncVAT / 100
            dblGoodsIncVAT = DblRound(dblGoodsIncVAT, 2, 0)
            ord.VATInclusive = Format$(dblGoodsIncVAT)
            
            dblGoodsExVAT = dblLineValue / 100
            dblGoodsExVAT = DblRound(dblGoodsExVAT, 2, 0)
            dblGoodsVAT = dblGoodsIncVAT - dblGoodsExVAT
            dblGoodsVAT = DblRound(dblGoodsVAT, 2, 0)
            ord.VATAmount = Format$(dblGoodsVAT)   '30Jun01 JKU added
            
            rectype$ = "T"
            baltype$ = "B"
            Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$, ord.PSORequestID  '03Mar14 TH Added PSORequestID
            
            If Abs(adjust!) >= 0.0001 Then
               Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$, ord.PSORequestID   '03Mar14 TH Added PSORequestID
            End If
            ord.status = "7"
            ord.cost = purprice$
            ord.invnum = InvInvoiceNo$
            ord.paydate = InvPayDate$
            ord.Reconciledate = Format$(Now, "ddmmyyyy")
            putdrug d           '<== UNLOCK DRUG  '01Jun02 ALL/ATW
            strStatusFlag = "R"
         Else
            ord.internalmethod = "E" '!!!!!!! Should we have a new HUB /None EDI code ???
         End If
         PutOrder ord, OrdRecNo&, "WReconcil"                 'Unlock order
      Else
         WriteLog dispdata$ & "\Hub.log", SiteNumber%, "---", procname$ & "Could not find match for Order No : " & InvOrderNo$ & " , Local Code : " & Trim$(localcode$)
      End If
   End If

   On Error GoTo PIIUpdateErr
         
   '02Mar16 TH Changed Paydate to genuine date - previously it was sending strPaydate in (TFS 146872)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 4, gEntityID_User) & _
               gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, strOrderNo) & _
               gTransport.CreateInputParameterXML("Supplier", trnDataTypeVarChar, 5, strOPCode) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
               gTransport.CreateInputParameterXML("Paydate", trnDataTypeDateTime, 8, dtePayDate) & _
               gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, strInvoiceNo) & _
               gTransport.CreateInputParameterXML("InvQty", trnDataTypeint, 4, strInvQty) & _
               gTransport.CreateInputParameterXML("InvContractNo", trnDataTypeVarChar, 35, strInvContractNo) & _
               gTransport.CreateInputParameterXML("InvLineTotal", trnDataTypeFloat, 4, strInvLineTotal) & _
               gTransport.CreateInputParameterXML("InvVATAmount", trnDataTypeFloat, 4, strInvVATAmount) & _
               gTransport.CreateInputParameterXML("InvLineIExVAT", trnDataTypeFloat, 4, strInvLineExVat) & _
               gTransport.CreateInputParameterXML("InvVATCode", trnDataTypeVarChar, 1, strInvVATCode) & _
               gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, strASCIssuePrice) & _
               gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, strASCPriceLastPaid) & _
               gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, strASCContractPrice) & _
               gTransport.CreateInputParameterXML("ASCPriceLastReconciled", trnDataTypeVarChar, 9, strASCPriceLastReconciled) & _
               gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, strASCContractNumber)

   strParams = strParams & gTransport.CreateInputParameterXML("ErrorCode", trnDataTypeVarChar, 3, strErrorCode) & _
               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, strStatusFlag) & _
               gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Null)

   If lngWHubInvoiceID > 0 Then
      'Update
      strParams = gTransport.CreateInputParameterXML("WMHUBInvoiceID", trnDataTypeint, 4, lngWHubInvoiceID) & strParams
      lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WHUBInvoice", strParams)
   Else
      lngWHubInvoiceID = gTransport.ExecuteInsertSP(g_SessionID, "WHUBInvoice", strParams)
   End If
   On Error GoTo 0

   
Exit Sub

'------------------------------------------------------------
'  Error Handlers
'------------------------------------------------------------

PIIUpdateErr:

   Screen.MousePointer = 0
   popmessagecr procname$ & " : Update Error", "Failed to add/update record in Pharmacy Hub table." & Chr$(13) & "Error number : " & Format$(Err) & cr$ & Error$
   Screen.MousePointer = 11

   Resume Next

End Sub
Function PatientIDFromPSOrderInfo(ByVal WOrderID As Long) As Long
'11Feb13 TH Case the forename/surname fields '08Mar13 TH Name changes for PSO (TFS 56646,58429)
'21Mar13 TH Changed date formats (TFS 59487)
'22Mar13 TH further change to handle unrecorded DOB (TFS 59559)

Dim strParams As String
Dim rs As ADODB.Recordset
Dim PatientID As Long
   
   PatientID = 0
   'Get the data
   strParams = gTransport.CreateInputParameterXML("WorderID", trnDataTypeint, 4, WOrderID)
   
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPSOPatientIDbyWorderID", strParams)
   
   If Not rs.EOF Then
      rs.MoveFirst
      'Get the ID
      PatientID = RtrimGetField(rs!PatientID)
   End If
   rs.Close
   Set rs = Nothing
   
   PatientIDFromPSOrderInfo = PatientID

End Function

Sub DisplayHUBExtraInfo(ord As orderstruct)

'05Feb16 TH Written based on DisplayEDIExtraInfo, seperate proc as likely to diverge (TFS 138638)

Dim ErrMsg$, desc$, title$
Dim errcode As String * 3
Dim rsHUB As ADODB.Recordset
Dim strParams As String

   LookupDrug ord.Code, d, 0
   

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, Trim$(ord.num)) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 22, d.SisCode)
   Set rsHUB = gTransport.ExecuteSelectSP(g_SessionID, "pWMediateSelectbyOrderNoandNSVCode", strParams)

   If Not rsHUB Is Nothing Then     'use returned recordset
      If rsHUB.State = adStateOpen Then
         If rsHUB.RecordCount <> 0 Then
            errcode$ = GetField(rsHUB!ErrorCode)
            Select Case errcode$
               Case "NO1"
                  ErrMsg$ = "No matching order was found on the System."
               Case "IV1"
                  ErrMsg$ = "Discount / Addition was posted with the Invoice."
               Case "IV2"
                  ErrMsg$ = "Part of this item is still outstanding."
               Case "IV3"
                  ErrMsg$ = "Not all items ordered on the system are present on the Invoice."
               Case "IV4"
                  ErrMsg$ = "Price in Invoice record is outside of Invoice bounds."
               Case "IV5"
                  ErrMsg$ = "VAT rate on eTrading is different to VAT rate on Pharmacy system."
               Case "IV6"
                  ErrMsg$ = "Order had not been received."
               '11Feb98 EAC check received amount = invoiced amount
               Case "IV7"
                  ErrMsg$ = "Invoice quantity does not match the quantity received."
               '25Jun98 EAC check for zero quantity in the invoice and reject with correct msg
               Case "IV8"
                  ErrMsg$ = "Invoice quantity is zero."
               '24Sep09 PJC ported F0053407: '12Jan07 PJC invoice lines are rejected because of another invioce line in error (#EDI)
               Case "IV9"
                  ErrMsg$ = "Another part of the invoice is in error."
               Case "PW1"
                  ErrMsg$ = "Price in Price With Orders record is outside of Invoice bounds."
               Case "PW2"
                  ErrMsg$ = "Price With Orders record received with a quantity of zero."
               Case "PW3"
                  ErrMsg$ = "Price With Orders record received for a quantity greater than that ordered."   '30Mar98 EAC added to trap orders for qty less than AAH minimum order
               Case Else
            End Select

            desc$ = d.DrugDescription   ' desc$ = GetStoresDescription()        XN 6Jun15 98073 New local stores description
            plingparse desc$, "!"
      
            Unload LstBoxFrm '08Aug07 TH Added to ensure list box sizes correctly
            
            title$ = "Order No    : " & GetField(rsHUB!orderno) & cr$
            title$ = title$ & "Invoice No  : " & GetField(rsHUB!InvoiceNo) & cr$
            title$ = title$ & "NSVCode     : " & d.SisCode & cr$
            title$ = title$ & "Description : " & desc$ & cr$
            title$ = title$ & "Contract No : " & GetField(rsHUB!ASCContractNumber) & cr$ & cr$
            title$ = title$ & "Automatic Reconciliation Rejection Reason:" & cr$
            title$ = title$ & ErrMsg$ & cr$ & cr$
            LstBoxFrm.Caption = "eHub Supplementary Information"
            LstBoxFrm.lblTitle = title$
            LstBoxFrm.lblHead = Space$(30) & TB$ & Space$(30)
      
            If Trim$(GetField(rsHUB!PWOQty)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO Quantity Ordered" & TB$ & Trim$(GetField(rsHUB!PWOQty))
            If Trim$(GetField(rsHUB!PWOContractNo)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO Contract Number" & TB$ & Trim$(GetField(rsHUB!PWOContractNo))
      
            If GetField(rsMediate!PWOLineExVat) <> 0 Then
               LstBoxFrm.LstBox.AddItem "PWO Item Price (ex VAT)" & TB$ & Format$(GetField(rsHUB!PWOLineExVat), "£#0.00")
               LstBoxFrm.LstBox.AddItem "PWO Item Vat Amount" & TB$ & Format$(GetField(rsHUB!PWOVATAmount), "£0#.00")
               If Trim$(GetField(rsHUB!PWOVatCode)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO VAT Code" & TB$ & Trim$(GetField(rsHUB!PWOVatCode))
               LstBoxFrm.LstBox.AddItem "PWO Item Price (inc VAT)" & TB$ & Trim$(GetField(rsMediate!PWOLineIncVAT))
            End If
      
            LstBoxFrm.LstBox.AddItem "eHub Invoice Quantity" & TB$ & Format$(GetField(rsHUB!InvQty))

            LstBoxFrm.LstBox.AddItem "Invoice Goods Price (ex VAT)" & TB$ & Format$(GetField(rsHUB!InvLineExVAT), "£#0.00")
            LstBoxFrm.LstBox.AddItem "Invoice Goods Vat Amount" & TB$ & Format$(GetField(rsHUB!InvVATAmount), "£0#.00")      '           "
            If Trim$(GetField(rsHUB!InvVATCode)) <> "" Then LstBoxFrm.LstBox.AddItem "Invoice VAT Code" & TB$ & Trim$(GetField(rsHUB!InvVATCode))
            LstBoxFrm.LstBox.AddItem "Invoice Goods Price (inc VAT)" & TB$ & Format$(GetField(rsHUB!InvLineTotal), "£0#.00")
      
            LstBoxFrm.LstBox.AddItem "EMIS Health Issue Price" & TB$ & Format$(Val(GetField(rsHUB!ASCIssuePrice)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Price Last Paid" & TB$ & Format$(Val(GetField(rsHUB!ASCPriceLastPaid)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Contract Price" & TB$ & Format$(Val(GetField(rsHUB!ASCContractPrice)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Price Last Reconciled" & TB$ & Format$(Val(GetField(rsHUB!ASCPriceLastReconciled)) / 100!, "£0.00")
      
            LstBoxFrm.cmdCancel.Enabled = False
            LstBoxFrm.cmdCancel.Visible = False
            LstBoxShow
      
            Unload LstBoxFrm
         End If
      End If
   End If
   rsHUB.Close
   Set rsHUB = Nothing

End Sub

Sub SetHUBItemArchivable(NSVCode$, ordernum$, barcode$, EDILinkCode$)
'05Feb16 TH Written based on SetMediateItemArchivable, seperate proc as likely to diverge (TFS 138638)

Dim strParams As String
Dim lngResult As Long

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode$) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, ordernum$)
               
   lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWReconcilHUBArchive", strParams)
   If lngResult = 0 Then
      If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "HUB", "N", "SuppressHUBArchivableMsg", 0)) Then '05Mar15 TH Added setting to stop msg firing if the site dont use invoicing (eg AWP) (TFS 104228)
         popmessagecr "Error", "Failed to find item " & NSVCode$ & " of order number " & ordernum$ & " in the HUB database" & cr$ & cr$ & "Unable to set this item to be archived."
      End If
      WriteLog dispdata$ & "\HUB.log", SiteNumber%, "---", "Item " & NSVCode$ & " of order number " & ordernum$ & "not found in HUB table. Could not set this item to be archived."
   End If
   

End Sub

