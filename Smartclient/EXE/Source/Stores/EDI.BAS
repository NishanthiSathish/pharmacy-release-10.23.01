Attribute VB_Name = "EDI"
'DOStoWIN V1.0 (c) ASCribe 1996
'                           Mediate EDI Link Program
'                          --------------------------
'
'20Feb95 CKJ Commenced
'18Jul95 CKJ Released for beta test
'18Oct95 CKJ Mediate drive on command line as /DRV=C
'22Oct97 EAC ProcessInvInfo: added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'22Oct97 EAC ProcessPWOInfo: added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'17Dec97 EAC ProcessInvInfo: allow for free items
'11Feb98 EAC CheckInvInfo, DisplayEDIExtraInfo: Check Invoice Quantity matches received quantity
'11Feb98 EAC ProcessInvInfo: correct value of adjust! for free items
'19Dec98 EAC SendEDIOrder: Use new Order printing routines
'04Mar98 EAC SetMediateItemArchivable: changed from snapshot to dynaset
'26Feb98 EAC ProcessInvInfo: Correct adjustment fiqure written to log
'30Mar98 EAC Trap orders where receive qty > order qty and flag with new error msg.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'            NOTE: The EDI interface is NOT year 2000 compliant, and uses yymmdd format dates
'            Awaiting confirmation from AAH as to their plans for this spec.
'25Jun98 EAC CheckInvInfo: stop rounding errors making cost outside of limits
'25Jun98 EAC CheckInvInfo: don't care about contract number when looking for contract price.
'25Jun98 EAC CheckInvInfo: check for zero quantity in the invoice and reject with correct msg
'23Sep98 EAC ProcessInvHdr: prevent Payment date being blank
'07Jun99 EAC SendEdiOrder: Corrected printing of tradenames on Edi orders
'22Sep99 TH  ReadInvoices: Send date string for use in report
'30Sep99 AE  DisplayEDIExtraInfo:Added GetField to prevent "invalid use of null"
'12Oct99 TH  AllItemsInInvoice: CheckInvInfo: ProcessPWOInfo: Changed to search on correct index
'21Feb00 SF  SendEdiOrder: now allows reprinting of the order
'22Nov00 EAC/CY Allow seperate variances for on-contract items.
'07Dec00 AW  ProcessInvInfo: changed invoicenum$ to InvInvoiceNo$, invoicenum$ not set in this module
'25Apr01 AW  Texsolsetup: Corrected spelling of TecSol
'15Jan02 TH  ProcessInvInfo: Added time for the orderlog (#53214)
'16Jan02 TH  ReadInvoices: Added supcode parameter to sub and use this to read correct settings (%EDI%)
'16Jan02 TH  Decs: Changes to variable declarations as this needs to be configurable now (%EDI%)
'16Jan02 TH  EDIMain: Need to know if this is called via an interface. If so then the interface may need
'   "        to be upgraded. Because EDI has been overhauled for multiple suppliers the supplier to be used now
'   "        needs to be passed in. If this is launched manually (ie from a desktop icon) then the icon will now
'   "        need to be changed to include the specific supplier. (%EDI%)
'   "        The command line will be "/ORDER XXXXX" where XXXXX represents the supplier code of the EDI Supplier
'16Jan02 TH  EDIOrder, EDIReadPWO,EDIInvoicingEDI : EDI changes - new wrappers - uses old routines but with supplier
'    "       selector at the start so that EDI ordering can be done supplier specifically (%EDI%)
'16Jan02 TH  ProcessInvHdr: Changed way format of site number is read for consistency (%EDI%)
'16Jan02 TH  ReadMediateDefaults: Added supcode parameter to Sub and use this to get settings, copying default settings into
'    "       new supplier specific settings file - pass back no file error as oParameter (%EDI)
'16Jan02 TH  ReadPWO: Added supcode input parameter so as to get new suppplier specific settings (%EDI%)
'   "        Also changed mousepointer calls to tidy up message boxes
'16Jan02 TH  SaveMediateDefaults: Added supplier parameter to Sub to use when saving settings file (%EDI%)
'16Jan02 TH  SendEdiOrder: Made supplier specific with seperate settings (%EDI%) - Added supplier code parameter
'16Jan02 TH  SetEDISupcode: Written to utilise variable from other areas (%EDI%)
'16Jan02 TH  CheckMediateSettings: Pass supcode into SaveMediateDeaults call (%EDI%)
'23Jan02 TH  ReadInvoices: Stop using the DCT Form report ctr and use stock take one instead. For some reason as yet
'   "        unexplained, the presence of this control was causing a GPF with CE uploads (#55693)
'15Feb02 TH  SendEdiOrder: Changed parameters in Wspool call to try and use correct number for reprint (#50749)
'10May02 SF  SendEdiOrder: added additional dummy parameter to PrintOrdTotal:
'21May02 ATW Enhancements to support TecSol 3.0 invoice format   (#51302)
'05Jun02 TH  ReadInvoices: Removed section dealing with PWOfile (this had been inserted in a merge error between 8.4 and 8.5)
'05Jun02 TH  Decs: Removed modular dim of PWOFile$ (this had been reinstated in a merge error between 8.4 and 8.5)
'15Jul02 TH  EDIOrder: Now uses supswithords for status 2 recs. This should present a pick box containing only (#61880)
'    "       those supplies with EDI orders ready to authorise.
'15Jul02 TH  CheckMediateSettings: Added last minute catch all as OK was allowing last untabbed item to be missed previously (#61880)
'05Aug02 TH  CheckInvInfo: Added trimming around invoicenumber in scanorder
'            GetLocalSupcode: Replaced basically the whole function - just fill it out with what we know !
'            Convert_TCSL300i_MR275i_Header: Added a trim on CustomerOrderNumber field as the type was too big
'            Convert_TCSL300i_MR275i_Trailer: Added mod to blank zero value Discount and addit amounts (needed for comparisons later)
'            SendEDIOrder: Reinstated manual entry for EDI Ordering
'07Aug02 TH  CheckInvInfo: Added padding around invoicenumber  for <1000 ordernums
'07Aug02 TH  Convert_TCSL300i_MR275i_Header: Change to pad HospOrdNum (for binary index search)
'28Jan04 TH  ProcessInvInfo: Added update of new reconciledate field
'31Mar04 CKJ {SP1}
'            Moved unused procs to .\old\edi.rem: edimain, EdiSettings, displayPWORecord, MediateSetup, SaveTexsolDefaults
'            Tecsoltest, TexsolSetup, AllItemsInInvoice
'// V9 //
'03Aug07 CKJ ported selected mods from 8.7
'03Oct08 TH  Changed our rounding of our vat rate as was excepting 5% as 4.99999% (F0024736)
'31May09 TH  ProcessInvHdr: (F0025467) Use Invoicedate for paydate rather than PayDueByDate (on switch - default to existing behaviour)
'24Sep09 PJC Ported (F0053407) '12Jan07 PJC SendEDIOrder,ReadPWO,ReadInvoices: Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380)
'24Sep09 PJC Ported (F0053407) '12Jan07 PJC DisplayEDIExtraInfo: Amended the display of 'PWO Quantity Ordered' and 'Invoice Goods Vat Amount'.  (#88257)
'24Sep09 PJC Ported (F0053407) '12Jan07 PJC ReadInvoices: Now rejects the whole invoice if error occurs to a single invoice line. (#EDI)
'24Sep09 PJC Ported (F0053407) '08Mar07 PJC ReadInvoices: Added check that the pointer is non-zero before the calling GetOrder. (#EDI)
'24Sep09 PJC ProcessInvHdr: (F0053407) Added configurable settings for the slash characters and offset.
'28Sep09 PJC ChkInvInfo: Removed the 100 multiplier added configurable dp for Round function (F0024736)
'// V10 //
'30Mar10 CKJ ProcessInvHdr: Validate InvPayDate and convert ddmmyy to ddmmccyy. Corrected spelling of 'UseInvoiceDate'   [RCN P0007 F0025467]
'11Apr10 TH  SendEDIOrder: Ensure contract number is reset for each item (F0042977)
'16May10 TH  ChkInvInfo: Added val on IV2 order outstanding check (F0069847)
'27May10 AJK SendEDIOrder: F0061692 Use EDILinkCode if it exists as localcode
'27May10 AJK ProcessInvInfo: F0061692 Check to see if localcode is an EDILinkCode
'27May10 AJK CheckInvInfo: F0061692 Added EDILinkCode check
'27May10 AJK SetMediateItemArchivable: F0061692 Added EDILinkCode
'05Aug10 TH  SendEDIOrder: Added batch handling of interface output for UHB Age interface
'02Nov10 AJK ProcessInvInfo: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK SendEDIOrder: F0086901 Added date invoiced to OrderLog calls
'15May12 TH  Mods to record contract information in the WOrderlog (TFS 30860)
'09Aug13 TH  SendEDIOrder: The lookup replacement had broken the link with the underlying order. This has led to a situation where the
'                          output lines are all out by one in terms of the drug specific information (TFS  71076)
'10Jul15 TH  SendEDIOrder: EDI Print Extra info line. If we dont have anything parsable in the extra section then just print it directly and move on (TFS 102796)
'28Jul15 TH  CheckInvInfo: Test against what we raise the order for, not what the cost variance is now (to stop new contracts causing exceptions) (TFS 120821)
'21Jul16 XN  CheckInvInfo: Added EDIProductIdentifier check 126634
'                        DisplayEDIExtraInfo: Added EDIProductIdentifier check 126634
'                        ProcessInvInfo: Did lookup via EDIProductIdentifier 126634
'                        SendEDIOrder: If EDI Barcode is set then send as localcode 126634
'                        ReadInvoices:  Did lookup via EDIProductIdentifier first 126634
'                        SetMediateItemArchivable: Added EDIProductIdentifier 126634
'26Jul16 XN  FinEditOrd: Added EDIProductIdentifier to call to SetMediateItemArchivable
'14Nov16 TH  ReadInvoices: Added section to allow the crystal report to be imported from DB (Hosted), then rebuilt locally for use (TFS 157972)
'06Dec16 TH  SendEDIOrder: Replaced RTF Handling (TFS 157969)
'06Jan17 TH  ReadInvoices: Changes to RTF handling
'13Feb17 TH  SendEDIOrder: In some areas you could exit from here with business lock still retained (TFS 176185)
'14Feb17 TH  ReadInvoices: ReadPWO: Release lock before non standard exit (TFS 176185)
'14Feb17 TH  SendEDIOrder: Release lock here - two more ways out that didnt release the locks (TFS 176185)
'14Feb17 TH  Bounded: Added - release lock (TFS 177178)
'14Feb17 TH  ReadInvHeader: Added - release lock (TFS 177178)
'14Feb17 TH  ReadInvLine: Added - release lock (TFS 177178)
'14Feb17 TH  ReadInvTrailer: Added - release lock (TFS 177178)

'mods
'----
' password protection
' invoice info

Option Explicit
DefInt A-Z
Const MODULE = "EDI."

'AAH Mediate EDI structures
Type MR270Header
   OrdNum         As String * 16
   OrdRef         As String * 41      'Note 1
   LocalSupCode   As String * 13      'Mandatory 'sssxxxxx     ' eg 0430001
   AcctNum        As String * 13
   numlines       As String * 4       'Mandatory
   ContractNum    As String * 35
   orderdate      As String * 6       ' YYMMDD
   DelivDate      As String * 6       ' YYMMDD
   DelivANAnum    As String * 13      'Note 3
   DelivDetails   As String * 40
   crlf           As String * 2       'Mandatory
End Type   '189

Type MR270OrdLin
   localcode      As String * 22      'Mandatory
   qtyordered     As String * 9       'Mandatory 'max 999999999
   Description    As String * 40
   PackSize       As String * 8
   TransferMarker As String * 1       '1 space
   Comment        As String * 40      'Note 2
   ContractNum    As String * 35
   UnitPrice      As String * 9       'œ; 0 0.0001 1.1111 11111.111 999999999
   crlf           As String * 2       'Mandatory
End Type   '166

'Note 1:
' max length of Order Number / Reference field
'  Tradacoms   17 chars
'  TF2/Edifact 35   "
'  AAH         41   "
'  Manual      41   "
'
'Note 2:
' max length of comment field
'  Tradacoms   40 chars
'  TF2/Edifact 40   "
'  AAH         17   "
'  Manual      40   "
'
'Note 3:
' See Mediate functional spec, Appx A2, P3, 13.
'

Type MR275Header
   Doctype        As String * 1       'I' invoice
   SupplierANA    As String * 13
   LocalSupCode   As String * 13
   SupplierDocNum As String * 20
   SupplierVatNum As String * 17
   HospOrdRef     As String * 41
   HospOrdNum     As String * 16
   HospAccount    As String * 13
   InvoiceDate    As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   TaxPointDate   As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   PayDueByDate   As String * 6       'YMMDD  '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   HeaderContNum  As String * 35
   HeaderComment  As String * 40
   numlines       As String * 4
   crlf           As String * 2
End Type  '233

Type MR275InvLin
   EANCode        As String * 13
   localcode      As String * 22
   SuppliersCode  As String * 17
   SuppliersDesc  As String * 40
   SuppliersPkSiz As String * 8
   QtyInvoiced    As String * 9       'Number of units purchased
   UnitPrice      As String * 15      'Price for one unit
   GoodsPrice     As String * 15      'Unit price x quantity
   LineVat        As String * 15      'Total VAT on this item
   LineVatCode    As String * 1       'SZ(XAO) std zero (exempt mixed other)
   LineVatRate    As String * 5       'xx.xx% VAT
   LineDiscount   As String * 15      'AAH discount
   LineAddition   As String * 15      'fixed amount added to order line
   LineTotal      As String * 15      'Goods price + line VAT
   LineContNum    As String * 35      'contract number
   LineComment    As String * 40
   crlf           As String * 2
End Type  ' 282

Type MR275Trailer
   SubTotalGoods  As String * 15
   SubTotalVAT    As String * 15
   AdditAmount    As String * 15
   AdditVAT       As String * 15
   AdditVATcode   As String * 1
   AdditVATrate   As String * 5
   DiscountAmount As String * 15
   TotalGoods     As String * 15
   TotalVAT       As String * 15
   GrandTotal     As String * 15
   crlf           As String * 2
End Type  ' 128

Type MD280iHdr
   orderno        As String * 16
   OrderPCode     As String * 13
   Numoflines     As String * 4
   crlf           As String * 2
End Type

Type MD280iLine
   LinkCode       As String * 8
   localcode      As String * 22
   Qty            As String * 9
   ContractNo     As String * 16
   QRApplies      As String * 1
   PriceExVAT     As String * 15
   VatCode        As String * 1
   VATAmount      As String * 15
   PriceIncVAT    As String * 15
   crlf           As String * 2
End Type

'20May02 ATW Tecsol Version 3 types

Type TCSLEntity
   id As String * 20
   name As String * 35
   ANA As String * 13
End Type

Type TCSL300iHeader
   RecordType As String * 1
   Supplier As TCSLEntity
   SupplierVatNumber As String * 17
   Customer As TCSLEntity
   DeliveryPoint As TCSLEntity
   InvoiceNumber As String * 17
   InvoiceDate As String * 8 ' YYYYMMDD
   TaxPointDate As String * 8
   PaymentDueDate As String * 8
   SettlementDiscountPercentage As String * 5 ' numeric
   CustomerOrderNumber As String * 17
   SupplierOrderNumber As String * 17
   DeliveryNoteNumber As String * 17
   ContractNumber As String * 35
   Comment As String * 40
   NumberOfLines As String * 4 ' Numeric
   crlf As String * 2
End Type

Type TCSL300iLine
   RecordType As String * 1
   LineNumber As String * 4
   CustomerProductCode As String * 30
   SupplierProductCode As String * 30
   EAN As String * 13
   InvoiceQty As String * 9 ' numeric
   Unit As String * 6
   price As String * 14
   LineCost As String * 14
   VatCode As String * 1
   VatPercent As String * 5
   DiscountValue As String * 14
   ProductDescription As String * 100
   PackSizeDescription As String * 20
   ContractNumber As String * 35
   crlf As String * 2
End Type

Type TCSL300iTrailer
   RecordType As String * 1
   TotalLineAmountPreVAT As String * 16
   TotalDiscount As String * 16
   TotalSurcharge As String * 16
   TotalSubsidy As String * 16
   TotalAmountPreVAT As String * 16
   TotalSettlementDiscount As String * 16
   TotalAmountPostSettlement As String * 16
   TotalVAT As String * 16
   GrandTotalPreSettlement As String * 16
   GrandTotalPostSettlement As String * 16
   crlf As String * 2
End Type

'declarations
Const modulename$ = "EDI.BAS"
' 21May02ATW Extra constants
Const INIFILE_WINORD = "\Winord.INI"
Const INISECTION_INVIMPORT = "InvoiceImport"

'Const ToMediate = "\mediate\import\import.mdt"   '16Jan02 TH Changed as this needs to be configurable now (%EDI%)
'Const MediateDefaultsFile$ = "\MEDI.DAT"         '    "
Dim MediateDefaultsFile$ '= "\MEDI.DAT"           '    "
Const ToMediate = "\import.mdt"                   '    "
Const MediateDefaultPath = "\Medi\"    '16Jan02 TH Added (%EDI%)

Dim ord As orderstruct
Dim OrdHdr As MR270Header
Dim OrdLin As MR270OrdLin

Dim OwnSiteNo$
'Dim PWOfile$  '05Jun02 TH Removed (this had been reinstated in a merge error between 8.4 and 8.5)
Dim MediateMdb$, MEDIImportPath$, MEDIExportPath$

'02apr04 CKJ {SP1} Added type declaration chars to all these eight variables - they are used in single precision calcs
Dim MediatePWOLowerDiff!, MediatePWOUpperDiff!, MediateInvLowerDiff!, MediateInvUpperDiff!
Dim MediatePWOLowerDiffOC!, MediatePWOUpperDiffOC!, MediateInvLowerDiffOC!, MediateInvUpperDiffOC!  '22Nov00 EAC/CY added for OnContract variances

Dim m_strEdiSupcode As String '16Jan02 TH (%EDI%)

Dim m_intImportFormat As Integer '  1 = Mediate 2.75, 2 = Tecsol 3.0
Const FORMAT_MEDIATE275 = 1
Const FORMAT_TECSOL300 = 2

Private Function Bounded(ByVal i_strValue As String, ByVal i_intLength As Integer) As String
'  Description :  Return the passed string numeric and choke if significant digits get trimmed.
'
'  Input :     i_strValue     ;  Numeric value in the general format "00000002323"
'              i_intLength    ;  Length of the return
'
'  Output:     Return         ;  Returns the value truncated to the correct number of chars or chokes.
'
'14Feb17 TH Added - release lock (TFS 177178)

Dim intDiff As Integer
Dim filelock$ '14Feb17 TH Added

   If Len(i_strValue) > i_intLength Then
         intDiff = Len(i_strValue) - i_intLength
         If Val(Left$(i_strValue, intDiff)) <> 0 Then
            '14Feb17 TH Added - release lock (TFS 177178)
            filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2C.LCK", "EDIInvoiceLock", 0)
            AcquireLock filelock$, False, 0 '14Feb17 TH Added - release lock (TFS 177178)
               popmessagecr ".Invoice Import", "Down-sizing field resulted in loss of numeric data" & cr & "This program will end. Please contact EMIS Health."
               Close
               storesEnd
            End If
      End If

   Bounded = Right$(String$(i_intLength, "0") & i_strValue, i_intLength)

End Function

Sub CheckInvInfo(InvLine As MR275InvLin, errcode$, InvOrderNo$, OrdRecNo&)
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
'28Jul15 TH Test against what we raise the order for, not what the cost variance is now (to stop new contracts causing exceptions) (TFS 120821)
'21Jul16 XN Added EDIProductIdentifier check 126634

Dim matched%
Dim cont&, fnd&
Dim issueprice!, lowerlimit!, upperlimit!
Dim ourvatrate$, medvatrate$
Dim foundPtr As Long  '01Jun02 ALL/ATW
Dim rsInvoices As ADODB.Recordset
Dim strParams As String

   'find order on ASCribe Database and update the information
   'appropriately
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
   'scanordreqindex 4, Left$(Trim$(InvOrderNo$) & Space$(4), 4), cont&, fnd&      '07Aug02 TH Added padding around invoicenumber  for <1000 ordernums
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
                                         'If TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "UseEDIProductIdentifier", 0))
                                         'TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True)
                     '22Jul16 XN 126634 Added EDIProductIdentifier
                                         If Trim$(InvLine.localcode) = Trim$(d.barcode) Or Trim$(InvLine.localcode) = Trim$(ord.Code) Then
                        matched = True
                                         ElseIf TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) And Trim$(ord.EDIProductIdentifier) <> "" And Trim$(InvLine.localcode) = Trim$(ord.EDIProductIdentifier) Then
                        matched = True
                                         ElseIf TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) And Trim$(ord.EDIProductIdentifier) = "" And Trim$(InvLine.localcode) = Trim$(d.EDILinkCode) Then
                        matched = True
                     End If
                  End If
               End If
               rsInvoices.MoveNext
            Loop
         End If
      End If
   End If
   ''Loop While fnd& > 0 And Not matched
   rsInvoices.Close
   Set rsInvoices = Nothing
   OrdRecNo& = fnd&

   If matched And fnd& > 0 Then
         '25Jun98 EAC check for zero quantity in the invoice and reject with correct msg
         If Val(InvLine.QtyInvoiced) = 0 Then
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
         
         issueprice! = Val(ord.cost)  '28Jul15 TH Replaced above. We are testing against what we raise the order for, not what the cost variance is now (to stop new contracts causing exceptions) (TFS 120821)
         

         lowerlimit! = issueprice! * (1 - (MediateInvLowerDiff / 100!))
         upperlimit! = issueprice! * (1 + (MediateInvUpperDiff / 100!))
         
         If Trim$(d.contno) <> "" Then
            lowerlimit! = issueprice! * (1 - (MediateInvLowerDiffOC / 100!))
            upperlimit! = issueprice! * (1 + (MediateInvUpperDiffOC / 100!))
         End If
         
         If TransLogVAT Then
            issueprice! = Val(InvLine.UnitPrice) * 100! 'NB now in pence!!
         Else
            issueprice! = (Val(InvLine.UnitPrice) + ((Val(InvLine.LineVatRate) / 100) * Val(InvLine.UnitPrice))) * 100!   'NB now in pence!!
         End If
         
         'If issueprice! < lowerlimit! Or issueprice! > upperlimit! Then  '25Jun98 EAC stop rounding errors making cost outside of limits
         If dp!(issueprice!) < dp!(lowerlimit!) Or dp!(issueprice!) > dp!(upperlimit!) Then
            errcode$ = "IV4"
            Exit Sub
         End If
         
         'check that VAT Rate is the same for the Mediate Line and our drug record
         'ourvatrate$ = Format$((VAT(Val(d.vatrate)) - 1), "")
         'ourvatrate$ = Format$(round(100 * (VAT(Val(d.vatrate)) - 1), 2)) '03Oct08 TH was excepting 5% as 4.99999% (F0024736)
         ourvatrate$ = Format$(round((VAT(Val(d.vatrate)) - 1), Val(TxtD(dispdata$ & "\winord.ini", "Mediate", "4", "RoundValue", 0))))        '28Sep09 PJC removed the 100 multiplier added configurable dp for Round function (F0024736)
         medvatrate$ = Format$((Val(InvLine.LineVatRate) / 100), "")
         If medvatrate$ <> ourvatrate$ Then
            errcode$ = "IV5"
            Exit Sub
         End If

         'If Not (ord.received = ord.qtyordered And Val(ord.outstanding) = 0) Then
         If Not (Val(ord.received) = Val(ord.qtyordered) And Val(ord.outstanding) = 0) Then '16May10 TH Added val (F0069847)
            errcode$ = "IV2"
         End If

         If Not (Val(ord.received) = Val(InvLine.QtyInvoiced)) Then
            errcode$ = "IV7"
         End If
      Else
         errcode$ = "NO1"
      End If

End Sub

Sub CheckMediateSettings(ctrlindex%)
'22Nov00 EAC/CY Allow seperate variances for On-Contract items
'16Jan02 TH  Pass supcode into SaveMediateDeaults call (%EDI%)
'15Jul02 TH  Added last minute catch all as OK was allowing last untabbed item to be missed previously
'02Apr04 CKJ {SP1} removed unused params errmsg$, NewIndex% (CtrlIndex%, errmsg$, NewIndex%)

'Need AN Editor here !!!

Dim escd%
Dim DirName$

   Select Case ctrlindex
      Case 0         'OK button selected
         'SaveMediateDefaults
         '15Jul02 TH Added as last minute catch all as OK was allowing one item to be missed previously
         If Val(Ques.txtQ(4)) >= 0 Then MediatePWOLowerDiff = Val(Ques.txtQ(4))
         If Val(Ques.txtQ(5)) >= 0 Then MediatePWOUpperDiff = Val(Ques.txtQ(5))
         If Val(Ques.txtQ(7)) >= 0 Then MediateInvLowerDiff = Val(Ques.txtQ(7))
         If Val(Ques.txtQ(8)) >= 0 Then MediateInvUpperDiff = Val(Ques.txtQ(8))
         If Val(Ques.txtQ(10)) >= 0 Then MediatePWOLowerDiffOC = Val(Ques.txtQ(10))
         If Val(Ques.txtQ(11)) >= 0 Then MediatePWOUpperDiffOC = Val(Ques.txtQ(11))
         If Val(Ques.txtQ(13)) >= 0 Then MediateInvLowerDiffOC = Val(Ques.txtQ(13))
         If Val(Ques.txtQ(14)) >= 0 Then MediateInvUpperDiffOC = Val(Ques.txtQ(14))
         '----------------------------------------
         SaveMediateDefaults m_strEdiSupcode  '16Jan02 TH (%EDI%)
      
      Case 1, 2      'change import/export directories
         DirName$ = Ques.lblInfo(ctrlindex).Caption
         ShowSelDir DirName$, escd%
         If Not escd% Then
               Ques.lblInfo(ctrlindex).Caption = DirName$
               If ctrlindex = 1 Then
                     MEDIImportPath$ = DirName$
                  Else
                     MEDIExportPath$ = DirName$
                  End If
            End If
      
      Case 4, 5, 7, 8, 10, 11, 13, 14
         If Ques.txtQ(ctrlindex) >= 0 Then
               Select Case ctrlindex
                  Case 4:  MediatePWOLowerDiff = Val(Ques.txtQ(ctrlindex))
                  Case 5:  MediatePWOUpperDiff = Val(Ques.txtQ(ctrlindex))
                  Case 7:  MediateInvLowerDiff = Val(Ques.txtQ(ctrlindex))
                  Case 8:  MediateInvUpperDiff = Val(Ques.txtQ(ctrlindex))
                  Case 10: MediatePWOLowerDiffOC = Val(Ques.txtQ(ctrlindex))
                  Case 11: MediatePWOUpperDiffOC = Val(Ques.txtQ(ctrlindex))
                  Case 13: MediateInvLowerDiffOC = Val(Ques.txtQ(ctrlindex))
                  Case 14: MediateInvUpperDiffOC = Val(Ques.txtQ(ctrlindex))
                  End Select
            Else
               popmessagecr "Error", "Please enter a positive value for this field"
               Select Case ctrlindex
                  Case 4:  Ques.txtQ(ctrlindex) = Format$(MediatePWOLowerDiff)
                  Case 5:  Ques.txtQ(ctrlindex) = Format$(MediatePWOUpperDiff)
                  Case 7:  Ques.txtQ(ctrlindex) = Format$(MediateInvLowerDiff)
                  Case 8:  Ques.txtQ(ctrlindex) = Format$(MediateInvUpperDiff)
                  Case 10: Ques.txtQ(ctrlindex) = Format$(MediatePWOLowerDiffOC)
                  Case 11: Ques.txtQ(ctrlindex) = Format$(MediatePWOUpperDiffOC)
                  Case 13: Ques.txtQ(ctrlindex) = Format$(MediateInvLowerDiffOC)
                  Case 14: Ques.txtQ(ctrlindex) = Format$(MediateInvUpperDiffOC)
                  End Select
            End If
      End Select

End Sub

Private Sub Convert_TCSL300i_MR275i_Header(lineFrom As TCSL300iHeader, lineTo As MR275Header)
'  Description :  Converts the Tecsol 3 invoice header to a Mediate 2.75 header
'
' !!NB - ONLY FIELDS THAT ARE USED ARE CONVERTED
'
'05Aug02 TH Added a trim on CustomerOrderNumber field as the type was too big
'07Aug02 TH Change to pad HospOrdNum (for binary index search)

Const ROUTINE = "Convert_TCSL300i_MR275i_Header"
Dim uErr As tErrorState
On Error GoTo CoTCSL300i_MR275i_HeaderErrorHandler:
'__________________________

   lineTo.LocalSupCode = GetLocalSupCode(lineFrom.CustomerOrderNumber)
   lineTo.SupplierANA = lineFrom.Supplier.ANA
   lineTo.SupplierDocNum = lineFrom.InvoiceNumber
   lineTo.SupplierVatNum = lineFrom.SupplierVatNumber
   'lineTo.HospOrdNum = Bounded(lineFrom.CustomerOrderNumber, Len(lineTo.HospOrdNum))       '05Aug02 TH Replaced
   'lineTo.HospOrdNum = Bounded(Trim$(lineFrom.CustomerOrderNumber), Len(lineTo.HospOrdNum)) '   "                      '07Aug02 TH Changed to pad (for binary index search)
   If Len(Trim$(lineFrom.CustomerOrderNumber)) < 5 Then                                                                 '   "
      lineTo.HospOrdNum = Left$(Space$(4 - Len(Trim$(lineFrom.CustomerOrderNumber))) & lineFrom.CustomerOrderNumber, 4) '   "
   Else                                                                                                                 '   "
      lineTo.HospOrdNum = Trim$(lineFrom.CustomerOrderNumber)                                                           '   "
   End If                                                                                                               '   "
   lineTo.InvoiceDate = Right$(lineFrom.InvoiceDate, Len(lineTo.InvoiceDate))
   lineTo.TaxPointDate = Right$(lineFrom.TaxPointDate, Len(lineTo.TaxPointDate))
   lineTo.PayDueByDate = Right$(lineFrom.PaymentDueDate, Len(lineTo.PayDueByDate))
   lineTo.HeaderContNum = lineFrom.ContractNumber
   lineTo.HeaderComment = lineFrom.Comment
   lineTo.numlines = lineFrom.NumberOfLines
'__________________________
Convert_TCSL300i_MR275i_HeaderCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

CoTCSL300i_MR275i_HeaderErrorHandler:
   CaptureErrorState uErr
   Resume Convert_TCSL300i_MR275i_HeaderCleanup:
'__________________________ End of Error Handling
End Sub

Private Sub Convert_TCSL300i_MR275i_Line(lineFrom As TCSL300iLine, lineTo As MR275InvLin)
'  Description :  Back-converts the Tecsol 3 invoice line format to Mediate 2.75
'
' !!NB - ONLY FIELDS THAT ARE USED ARE CONVERTED
'
Const ROUTINE = "TCSL300i_MR275i_Line"
Dim uErr As tErrorState
On Error GoTo TCSL300i_MR275i_LineErrorHandler:
'__________________________
   
   lineTo.EANCode = lineFrom.EAN
   lineTo.localcode = lineFrom.CustomerProductCode
   lineTo.SuppliersCode = lineFrom.SupplierProductCode
   lineTo.SuppliersDesc = lineFrom.ProductDescription
   lineTo.SuppliersPkSiz = lineFrom.PackSizeDescription
   lineTo.QtyInvoiced = Bounded(lineFrom.InvoiceQty, Len(lineTo.QtyInvoiced))
   lineTo.UnitPrice = Bounded(lineFrom.price, Len(lineTo.UnitPrice))
   lineTo.GoodsPrice = Bounded(lineFrom.LineCost, Len(lineTo.GoodsPrice))
   lineTo.LineVatCode = lineFrom.VatCode
   lineTo.LineVatRate = lineFrom.VatPercent
   lineTo.LineContNum = lineFrom.ContractNumber
'__________________________
TCSL300i_MR275i_LineCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

TCSL300i_MR275i_LineErrorHandler:
   CaptureErrorState uErr
   Resume TCSL300i_MR275i_LineCleanup:
'__________________________ End of Error Handling
End Sub

Private Sub Convert_TCSL300i_MR275i_Trailer(lineFrom As TCSL300iTrailer, lineTo As MR275Trailer)
'Description   :  Converts the Tecsol 3 invoice tralier to the Mediate 2.75 trailer
'
' !!NB - ONLY FIELDS THAT ARE USED ARE CONVERTED
'
'05Aug02 TH Added mod to blank zero value Discount and addit amounts (needed for comparisons later)

Const ROUTINE = "TCSL300i_MR275i_Trailer"
Dim uErr As tErrorState
On Error GoTo TCSL300i_MR275i_TrailerErrorHandler:
'__________________________

   lineTo.DiscountAmount = Bounded(lineFrom.TotalDiscount, Len(lineTo.DiscountAmount))
   lineTo.AdditAmount = Bounded(lineFrom.TotalSurcharge, Len(lineTo.AdditAmount))
   If Val(lineTo.DiscountAmount) = 0 Then lineTo.DiscountAmount = ""       '05Aug02 TH Added
   If Val(lineTo.AdditAmount) = 0 Then lineTo.AdditAmount = ""             '   "
'__________________________
TCSL300i_MR275i_TrailerCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

TCSL300i_MR275i_TrailerErrorHandler:
   CaptureErrorState uErr
   Resume TCSL300i_MR275i_TrailerCleanup:
'__________________________ End of Error Handling
End Sub
Sub DisplayEDIExtraInfo(ord As orderstruct)
'24Sep09 PJC ported (F0053407): '12Jan07 PJC Amended the display of 'PWO Quantity Ordered' and 'Invoice Goods Vat Amount'.  (#88257)
'24Sep09 PJC ported (F0053407): '12Jan07 PJC invoice lines are rejected because of another invioce line in error (#EDI)
'27May10 AJK F0061692 Added EDILinkCode check
'21Jul16 XN  Added EDIProductIdentifier check 126634

Dim bcr$, SQL$, ErrMsg$, desc$, title$
Dim localcode As String * 22, errcode As String * 3
'Dim found%
'Dim foundPtr As Long  '01Jun02 ALL/ATW
Dim rsMediate As ADODB.Recordset
Dim strParams As String

   LookupDrug ord.Code, d, 0
   If Trim$(ord.EDIProductIdentifier) <> "" And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) Then
          localcode$ = Trim$(ord.EDIProductIdentifier)
   ElseIf Trim$(d.EDILinkCode) <> "" And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True Then
   'If Trim$(d.EDILinkCode) <> "" And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True Then 21Jul16 XN  Added EDIProductIdentifier check 126634 '27May10 AJK F0061692 Added EDILinkCode check
      localcode$ = Trim$(d.EDILinkCode)
   Else
      DummyEAN d.SisCode, bcr$
      If Trim$(d.barcode) = bcr$ Then        'dummy barcode used
         localcode$ = ord.Code            'AS STRING * 22
      Else                                'assume genuine EAN
         localcode$ = Trim$(d.barcode)    'AS STRING * 22
      End If
   End If

   ''SQL$ = "SELECT * FROM Mediate WHERE (OrderNo = '" & Trim$(ord.num) & "' AND LocalCode = '" & localcode$ & "');"
   ''Set snap = WSDB.CreateSnapshot(SQL$)
   '16Jan07 TH Added SiteID
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, Trim$(ord.num)) & _
               gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 22, localcode$)
   Set rsMediate = gTransport.ExecuteSelectSP(g_SessionID, "pWMediateSelectbyOrderNoandLocalCode", strParams)

   If Not rsMediate Is Nothing Then     'use returned recordset
      If rsMediate.State = adStateOpen Then
         If rsMediate.RecordCount <> 0 Then
         'If Not snap.EOF Then
            errcode$ = GetField(rsMediate!ErrorCode)
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
            
            title$ = "Order No    : " & GetField(rsMediate!orderno) & cr$
            title$ = title$ & "Invoice No  : " & GetField(rsMediate!InvoiceNo) & cr$
            title$ = title$ & "NSVCode     : " & d.SisCode & cr$
            title$ = title$ & "Description : " & desc$ & cr$
            title$ = title$ & "Contract No : " & GetField(rsMediate!ASCContractNumber) & cr$ & cr$
            title$ = title$ & "Automatic Reconciliation Rejection Reason:" & cr$
            title$ = title$ & ErrMsg$ & cr$ & cr$
            LstBoxFrm.Caption = "eTrading Supplementary Information"
            LstBoxFrm.lblTitle = title$
            LstBoxFrm.lblHead = Space$(30) & TB$ & Space$(30)
      
            If Trim$(GetField(rsMediate!PWOQty)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO Quantity Ordered" & TB$ & Trim$(GetField(rsMediate!PWOQty))
            If Trim$(GetField(rsMediate!PWOContractNo)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO Contract Number" & TB$ & Trim$(GetField(rsMediate!PWOContractNo))
      
            If GetField(rsMediate!PWOLineExVat) <> 0 Then
               LstBoxFrm.LstBox.AddItem "PWO Item Price (ex VAT)" & TB$ & Format$(GetField(rsMediate!PWOLineExVat), "£#0.00")
               LstBoxFrm.LstBox.AddItem "PWO Item Vat Amount" & TB$ & Format$(GetField(rsMediate!PWOVATAmount), "£0#.00")
               If Trim$(GetField(rsMediate!PWOVatCode)) <> "" Then LstBoxFrm.LstBox.AddItem "PWO VAT Code" & TB$ & Trim$(GetField(rsMediate!PWOVatCode))
               LstBoxFrm.LstBox.AddItem "PWO Item Price (inc VAT)" & TB$ & Trim$(GetField(rsMediate!PWOLineIncVAT))
            End If
      
            LstBoxFrm.LstBox.AddItem "eTrading Invoice Quantity" & TB$ & Format$(GetField(rsMediate!InvQty))

            LstBoxFrm.LstBox.AddItem "Invoice Goods Price (ex VAT)" & TB$ & Format$(GetField(rsMediate!InvLineExVAT), "£#0.00")
            'LstBoxFrm.LstBox.AddItem "Invoice Goods Vat Amount" & TB$ & Format$(GetField(rsMediate!PWOVATAmount), "£0#.00")     '24Sep09 PJC ported (F0053407): '12Jan07 PJC Now Displays InvVatAmount (#88257)
            LstBoxFrm.LstBox.AddItem "Invoice Goods Vat Amount" & TB$ & Format$(GetField(rsMediate!InvVATAmount), "£0#.00")      '           "
            If Trim$(GetField(rsMediate!InvVATCode)) <> "" Then LstBoxFrm.LstBox.AddItem "Invoice VAT Code" & TB$ & Trim$(GetField(rsMediate!InvVATCode))
            LstBoxFrm.LstBox.AddItem "Invoice Goods Price (inc VAT)" & TB$ & Format$(GetField(rsMediate!InvLineTotal), "£0#.00")
      
            LstBoxFrm.LstBox.AddItem "EMIS Health Issue Price" & TB$ & Format$(Val(GetField(rsMediate!ASCIssuePrice)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Price Last Paid" & TB$ & Format$(Val(GetField(rsMediate!ASCPriceLastPaid)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Contract Price" & TB$ & Format$(Val(GetField(rsMediate!ASCContractPrice)) / 100!, "£0.00")
            LstBoxFrm.LstBox.AddItem "EMIS Health Price Last Reconciled" & TB$ & Format$(Val(GetField(rsMediate!ASCPriceLastReconciled)) / 100!, "£0.00")
      
            LstBoxFrm.cmdCancel.Enabled = False
            LstBoxFrm.cmdCancel.Visible = False
            LstBoxShow
      
            Unload LstBoxFrm
         End If
      End If
   End If
   rsMediate.Close
   Set rsMediate = Nothing

End Sub

Sub DummyEAN(ip As String, op As String)

Dim strInput As String
Dim count%

   op = ""
   
   If Len(ip) = 7 Then
         strInput = UCase$(ip)
         For count = 1 To 3
                  op = op + LTrim$(Str$(Asc(Mid$(strInput, count, 1))))
         Next
         op = op + Mid$(ip, 4, 3) + LTrim$(Str$(Asc(Right$(strInput, 1)))) + "0"
         op = op + eanaddchkdigit$(op)
      End If

End Sub

Sub EDIInvoicing()
'16Jan02 TH EDI changes - uses old routine but with supplier selector at the start
'    "      so that EDI ordering can be done supplier specifically (%EDI%)

Dim EDISup As supplierstruct
'07Nov01 TH EDI changes - uses old routine but with supplier selector at the start
'    "      so that EDI ordering can be done supplier specifically
   clearsup EDISup
   'asksupplier "", 0, "E", "Select EDI Supplier", False, EDISup, False '15Nov12 TH Added PSO param
   asksupplier "", 0, "E_NO_HUB", "Select EDI Supplier", False, EDISup, False '25Feb16 TH Changed filter
   
   If Trim$(EDISup.Code) <> "" Then
      ReadInvoices EDISup.Code, True
   End If

End Sub

Sub EDIReadPWO()
'16Jan02 TH EDI changes - uses old routine but with supplier selector at the start
'    "      so that EDI ordering can be done supplier specifically  (%EDI)

Dim EDISup As supplierstruct

   clearsup EDISup
   asksupplier "", 0, "E", "Select EDI Supplier to Read Prices From", False, EDISup, False '15Nov12 TH Added PSO param
   If Trim$(EDISup.Code) <> "" Then
      ReadPWO EDISup.Code, True
   End If

End Sub

Sub EDISetup()
'07Nov01 TH New sub based on previous settins routine but with the ability to
'           specify settings by supplier

'SQL 01Mar05 TH Removed - editor required elsewhere.

Dim EDISup As supplierstruct, strSupCode As String


'Present E type suppliers for user selection
   clearsup EDISup
   asksupplier "", 0, "E", "Select EDI Supplier", False, EDISup, False '15Nov12 TH Added PSO param
   If Trim$(EDISup.Code) <> "" Then

         'Once supplier selected then load the settings associated with this supplier
         'If there is no file for this supplier then create one base on the default EDI.Dat file (done in the read)

         'Set default settings
         strSupCode = EDISup.Code
         ReadMediateDefaults strSupCode
         If strSupCode = "NOEDIFILE" Then Exit Sub
         QuesCallbackMode = 3

         Ques.Caption = "eTrading Link Defaults"

         QuesMakeCtrl 1, 2
         Ques.lblDesc(1) = "1) Import Directory"
         QuesSetCtrl Ques.cmdQ(1), 0, 0, "Change"
         Ques.lblInfo(1) = Trim$(MEDIImportPath$)

         QuesMakeCtrl 2, 2
         Ques.lblDesc(2) = "2) Export Directory"
         QuesSetCtrl Ques.cmdQ(2), 0, 0, "Change"
         Ques.lblInfo(2) = Trim$(MEDIExportPath$)

         QuesMakeCtrl 3, 0
         Ques.lblDesc(3) = "Off-Contract Settings"

         QuesMakeCtrl 4, 1
         Ques.lblDesc(4) = "3) % below allowed for Price With Order cost"
         QuesSetCtrl Ques.txtQ(4), 1, 3, Format$(MediatePWOLowerDiff)
         Ques.lblInfo(4) = "%"

         QuesMakeCtrl 5, 1
         Ques.lblDesc(5) = "4) % above allowed for Price With Order cost"
         QuesSetCtrl Ques.txtQ(5), 1, 3, Format$(MediatePWOUpperDiff)
         Ques.lblInfo(5) = "%"

         QuesMakeCtrl 7, 1
         Ques.lblDesc(7) = "5) % below allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(7), 1, 3, Format$(MediateInvLowerDiff)
         Ques.lblInfo(7) = "%"

         QuesMakeCtrl 8, 1
         Ques.lblDesc(8) = "6) % above allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(8), 1, 3, Format$(MediateInvUpperDiff)
         Ques.lblInfo(8) = "%"

         '22Nov00 EAC/CY allow seperate variances for on-contract goods
         QuesMakeCtrl 9, 0
         Ques.lblDesc(9) = "On-Contract Settings"

         QuesMakeCtrl 10, 1
         Ques.lblDesc(10) = "7) % below allowed for Price With Order cost"
         QuesSetCtrl Ques.txtQ(10), 1, 3, Format$(MediatePWOLowerDiffOC)
         Ques.lblInfo(10) = "%"

         QuesMakeCtrl 11, 1
         Ques.lblDesc(11) = "8) % above allowed for Price With Order cost"
         QuesSetCtrl Ques.txtQ(11), 1, 3, Format$(MediatePWOUpperDiffOC)
         Ques.lblInfo(11) = "%"

         QuesMakeCtrl 13, 1
         Ques.lblDesc(13) = "9) % below allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(13), 1, 3, Format$(MediateInvLowerDiffOC)
         Ques.lblInfo(13) = "%"

         QuesMakeCtrl 14, 1
         Ques.lblDesc(14) = "10) % above allowed for Invoice cost"
         QuesSetCtrl Ques.txtQ(14), 1, 3, Format$(MediateInvUpperDiffOC)
         Ques.lblInfo(14) = "%"

         QuesShow 14

         Unload Ques
      End If  '07Nov01 TH (%EDI%)

End Sub

Private Function GetLocalSupCode(ByVal i_strOrderNum As String) As String
'24May02 ATW
'  Description :  Fetch the local supplier code from a previously placed order.
'05Aug02 TH No it doesnt !!!!!!!!!!!!! Whatever else it does - it doesnt do what it says !
'05Aug02 TH Replaced basically the whole function - just fill it out with what we know !

'
Const ROUTINE = "GetLocalSupCode"
Dim uErr As tErrorState
On Error GoTo GetLocalSupCodeErrorHandler:
'__________________________
'Local sup code = sss/xxxxx where s = sitenumber and x = supplier code

'Dim strSiteNumber As String
'Dim strOrderNum As String
'Dim strSupplierCode As String

'Dim lngCont As Long
'Dim lngFound As Long

'Dim order As orderstruct

   'strSiteNumber = Left$(i_strOrderNum, 3)
   'strOrderNum = Mid$(i_strOrderNum, 5, 5)
   ' Locate order so we can extract it's Supplier code.
   'scanordreqindex 1, i_strOrderNum, lngCont, lngFound
   '
   'If lngFound = 0 Then
   '      popmessagecr ROUTINE, "Attempted to invoice for non-existent order " & i_strOrderNum & cr & "This application will now close."
   '      End
   '   End If
   '
   'getorder order, lngFound, 1, False
   
   'GetLocalSupCode = strSiteNumber & "/" & strSupplierCode                            '05Aug02 TH Replaced All of above - just fill it out with what we know !
   GetLocalSupCode = Right$("000" & Format$(SiteNumber), 3) & "/" & m_strEdiSupcode    '   "

'__________________________
GetLocalSupCodeCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

GetLocalSupCodeErrorHandler:
   CaptureErrorState uErr
   Resume GetLocalSupCodeCleanup:
'__________________________ End of Error Handling
End Function

Sub EDIOrder()
'16Jan02 TH EDI changes - uses old routine but with supplier selector at the start
'    "      so that EDI ordering can be done supplier specifically (%EDI%)
'15Jul02 TH Now uses supswithords for status 2 recs. This should present a pick box containing only
'    "      those supplies with EDI orders ready to authorise.

Dim EDISup As supplierstruct

   clearsup EDISup
   'asksupplier "", 0, "E", "Select EDI Supplier to Generate Order", False, EDISup  '15Jul02 TH Replaced
   supswithords 2, EDISup.Code, 0, "", False '11Jun12 TH Added param (DLO)                                                  '   "
   getsupplier (EDISup.Code), 0, 0, EDISup
   If Trim$(EDISup.Code) <> "" Then
         SendEDIOrder EDISup.Code
         If Not k.escd Then supsinarray = 0 '21Apr08 TH Assume if not cancelled then we have done a line. Now reload the list (F0015280)
      End If
End Sub

Sub ProcessInvHdr(InvHdr As MR275Header, InvSupCode$, InvOrderNo$, InvInvoiceNo$, InvPayDate$)
'23Sep98 EAC prevent Payment date being blank
'16Jan02 TH Changed way format of site number is read for consistency (%EDI%)
'31May09 TH (F0025467) Use Invoicedate for paydate rather than PayDueByDate (on switch - default to existing behaviour)
'24Sep09 PJC (F0053407) Added configurable settings for the slash characters and offset.
'30Mar10 CKJ Validate date and convert ddmmyy to ddmmccyy. Corrected spelling of 'UseInvoiceDate'   [RCN P0007 F0025467]

Dim strSite As String  '16Jan02 TH added (%EDI%)

Dim strFWDSlash As String              '24Sep09 PJC Added (F0053407)
Dim strBCKSlash As String              '24Sep09 PJC Added (F0053407)
Dim intOrderNumberOffset As Integer    '24Sep09 PJC Added (F0053407)
'Dim IsValid As Boolean                 '30Mar10 CKJ Added
Dim IsValid As Integer                 '01Apr10 TH changed to correct data type

   strFWDSlash = TxtD(dispdata$ & "\winord.ini", "Mediate", "/", "FWDSlash", 0)                    '24Sep09 PJC Added (F0053407)
   strBCKSlash = TxtD(dispdata$ & "\winord.ini", "Mediate", "\", "BCKSlash", 0)                    '24Sep09 PJC Added (F0053407)
   intOrderNumberOffset = TxtD(dispdata$ & "\winord.ini", "Mediate", "1", "OrderNumberOffset", 0)  '24Sep09 PJC Added (F0053407)

   strSite = Right$("000" & Format$(SiteNumber%), 3)
   If InStr(UCase$(InvHdr.HospOrdNum), "PH") Then
         InvOrderNo$ = Trim$(Mid$(InvHdr.HospOrdNum, 3))
      'ElseIf InStr(UCase$(InvHdr.HospOrdNum), Format$(SiteNumber%) & "/") Then   '16Jan02 TH replaced (%EDI%)
      'ElseIf InStr(UCase$(InvHdr.HospOrdNum), strSite & "/") Then                '    "
      ElseIf InStr(UCase$(InvHdr.HospOrdNum), strSite & strFWDSlash) Then         '24Sep09 PJC Replaced above (F0053407)
         'InvOrderNo$ = Trim$(Mid$(InvHdr.HospOrdNum, InStr(UCase$(InvHdr.HospOrdNum), Format$(SiteNumber%) & "\") + Len(Format$(SiteNumber%) & "\") + 1))  '16Jan02 TH replaced (%EDI%)
         'InvOrderNo$ = Trim$(Mid$(InvHdr.HospOrdNum, InStr(UCase$(InvHdr.HospOrdNum), strSite & "\") + Len(strSite & "\") + 1))                             '    "
         InvOrderNo$ = Trim$(Mid$(InvHdr.HospOrdNum, InStr(UCase$(InvHdr.HospOrdNum), strSite & strBCKSlash) + Len(strSite & strBCKSlash) + intOrderNumberOffset))              '24Sep09 PJC Replaced above (F0053407)
      Else
         InvOrderNo$ = Trim$(UCase$(InvHdr.HospOrdNum))
      End If
   InvInvoiceNo$ = Trim$(InvHdr.SupplierDocNum)
   'If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Mediate", "N", "UseInvioceDate", 0)) Then                             '31May09 TH (F0025467)
   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Mediate", "N", "UseInvoiceDate", 0)) Then                              '31May09 TH (F0025467)  '30Mar10 CKJ Corrected spelling  [RCN P0007 F0025467]
      InvPayDate$ = Right$(InvHdr.InvoiceDate, 2) & Mid$(InvHdr.InvoiceDate, 3, 2) & Left$(InvHdr.InvoiceDate, 2)       '  "
   Else                                                                                                                 '  "
      InvPayDate$ = Right$(InvHdr.PayDueByDate, 2) & Mid$(InvHdr.PayDueByDate, 3, 2) & Left$(InvHdr.PayDueByDate, 2) '03May98 CKJ Y2K. !!** NOT Y2K COMPLIANT
   End If                                                                                                               '  "
   
   '30Mar10 CKJ Added block to validate date and convert ddmmyy to ddmmccyy   [RCN P0007 F0025467]
   InvPayDate$ = trimz$(InvPayDate$)
   If Len(InvPayDate$) = 6 And IsDigits(InvPayDate$) Then
      parsedate (InvPayDate$), InvPayDate$, "3", IsValid    'format 3 is ddmmccyy
      If Not IsValid Then InvPayDate$ = ""
   End If
   '---

   If trimz$(InvPayDate$) = "" Then InvPayDate$ = thedate$(False, True)                                           '23Sep98 EAC prevent Payment date being blank
   InvSupCode$ = Trim$(Mid$(InvHdr.LocalSupCode, 5, Len(sup.Code)))

End Sub

Sub ProcessInvInfo(InvLine As MR275InvLin, InvSupCode$, InvOrderNo$, InvInvoiceNo$, InvPayDate$, errcode$, OrdRecNo&)

'22Oct97 EAC added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'17Dec97 EAC allow for free items
'11Feb98 EAC correct value of adjust! for free items
'26Feb98 EAC Correct adjustment fiqure written to log
'07Dec00 AW  changed invoicenum$ to InvInvoiceNo$, invoicenum$ not set in this module
'15Jan02 TH  Added time for the orderlog (#53214)
'28Jan04 TH  Added update of new reconciledate field
'27May10 AJK F0061692 Check to see if localcode is an EDILinkCode
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'21Jul16 XN  Did lookup via EDIProductIdentifier 126634
'22May17 XN  184544 set EDIOrder to true in to log

Const procname$ = "ProcessInvInfo"
Dim adjust!
Dim matched%, DoReconciliation%    '01Jun02 ALL/ATW
Dim SQL$, purprice$, daterec$, qtyord$, qtyrec$, rectype$, baltype$
Dim localcode$, ans$, msg$

Dim foundPtr As Long  '01Jun02 ALL/ATW
Dim blnFound As Integer '01Jun02 ALL/ATW
Dim rsMediate As ADODB.Recordset
Dim strParams As String
Dim strOrderNo As String
Dim strLocalCode As String
Dim strOPCode As String
Dim strASCIssuePrice As String
Dim strASCPriceLastPaid As String
Dim strASCContractPrice As String
Dim strASCPriceLastReconciled As String
Dim strASCContractNumber As String
Dim lngWMediateID As Long
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
Dim strLinkCode As String
Dim intPWOQty As Integer
Dim dblPWOLineExRate As Double
Dim strPWOVatCode As String
Dim dblPWOVATAmount As Double
Dim dblPWOLineIncVAT As Double
Dim strPWOQtyRateApplies As String
Dim strPWOContractNo As String
'03Aug07 CKJ ported from 8.7
Dim dblGoodsIncVAT As Double
Dim dblGoodsExVAT As Double
Dim dblLineValue As Double
Dim dblGoodsVAT As Double
Dim rsTemp As ADODB.Recordset

   localcode$ = Trim$(InvLine.localcode)
   If Trim$(localcode$) = "" Then
      matched = False
      Screen.MousePointer = 0
      msg$ = "EAN Number      : " & Trim$(InvLine.EANCode) & cr$
      msg$ = msg$ & "Supplier's Code : " & Trim$(InvLine.SuppliersCode) & cr$
      msg$ = msg$ & "Description     : " & Trim$(InvLine.SuppliersDesc) & cr$
      msg$ = msg$ & "Pack Size       : " & Trim$(InvLine.SuppliersPkSiz) & cr$ & cr$
      msg$ = msg$ & "Please enter drug code for this item." & cr$
      Do
         setinput 0, k
         k.escd = False
         k.min = 1
         InputWin "Select Matching Item", msg$, ans$, k
         BlankWProduct d
         findrdrug ans$, True, d, 0, blnFound, 2, False, False
         If blnFound Then matched = True
      Loop While Not matched
      localcode$ = d.SisCode
      Screen.MousePointer = 11
   End If

   'must check to see if this entry has been added before in case
   'of a problem with the last time the file was processed
   ''SQL$ = "SELECT * FROM Mediate WHERE (OrderNo = '" & InvOrderNo$ & "' AND LocalCode = '" & localcode$ & "')"
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, InvOrderNo$) & _
               gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 22, localcode$)
   Set rsMediate = gTransport.ExecuteSelectSP(g_SessionID, "pWMediateSelectbyOrderNoandLocalCode", strParams)
   
   ''dyn.LockEdits = False 'Given this dont bother locking !!
   If Not rsMediate Is Nothing Then     'use returned recordset
      If rsMediate.State = adStateOpen Then
         If rsMediate.RecordCount = 0 Then
         ''If dyn.EOF Then
            '!!** Should have already received a PWO record for this invoice line
            ''dyn.AddNew
            strOrderNo = InvOrderNo$
            strLocalCode = Trim$(localcode$)
            strOPCode = InvSupCode$
            BlankWProduct d
            ''27May10 AJK F0061692 Check to see if localcode is an EDILinkCode
            'If Len(Trim$(localcode$)) = 13 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True Then
            '   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
            '      gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, localcode$)
            '   Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByEDILinkCode", strParams)
            '   If rsTemp.RecordCount > 0 Then
            '      d.SisCode = RtrimGetField(rsTemp!SisCode)
            '   End If
            'End If
                        
                        ' 21Jul16 XN Did lookup via EDIProductIdentifier 126634
                        If Len(Trim$(localcode$)) = 13 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) Then
                                strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                                        gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, InvOrderNo$) & _
                                                        gTransport.CreateInputParameterXML("EDIProductIdentifier", trnDataTypeVarChar, 15, Trim$(localcode$))
                                Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderBySiteOrderNumAndEDIProductIdentifier", strParams)
                                If rsTemp.RecordCount > 0 Then
                                        d.SisCode = RtrimGetField(rsTemp!Code)
                                Else
                                        strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                                                gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, localcode$)
                                        Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByEDILinkCode", strParams)
                                        If rsTemp.RecordCount > 0 Then
                                                d.SisCode = RtrimGetField(rsTemp!SisCode)
                                        End If
                                End If
                        End If
            If RTrim$(d.SisCode) = "" Then
               If Len(Trim$(localcode$)) = 7 Then
                  d.SisCode = Trim$(localcode$)
               Else
                  d.barcode = Trim$(localcode$)
               End If
            End If
            getdrug d, 0, foundPtr, False
            strASCIssuePrice = Format$(Val(d.cost))
            strASCPriceLastPaid = Format$(Val(d.sislistprice))
            strASCContractPrice = Format$(Val(d.contprice))
            strASCPriceLastReconciled = Format$(Val(d.lastreconcileprice))
            strASCContractNumber = d.contno
            lngWMediateID = 0
            strErrorCode = ""
            strLinkCode = ""
            intPWOQty = 0
            strPWOContractNo = ""
            strPWOQtyRateApplies = ""
            dblPWOLineExRate = 0
            strPWOVatCode = ""
            dblPWOVATAmount = 0
            dblPWOLineIncVAT = 0
         Else
            ''dyn.Edit
            strOrderNo = RtrimGetField(rsMediate!orderno)
            strLocalCode = RtrimGetField(rsMediate!localcode)
            strOPCode = RtrimGetField(rsMediate!OPCode)
            strASCIssuePrice = RtrimGetField(rsMediate!ASCIssuePrice)
            strASCPriceLastPaid = RtrimGetField(rsMediate!ASCPriceLastPaid)
            strASCContractPrice = RtrimGetField(rsMediate!ASCContractPrice)
            strASCPriceLastReconciled = RtrimGetField(rsMediate!ASCPriceLastReconciled)
            strASCContractNumber = RtrimGetField(rsMediate!ASCContractNumber)
            lngWMediateID = RtrimGetField(rsMediate!WMediateID)
            strErrorCode = GetField(rsMediate!ErrorCode)
            strLinkCode = RtrimGetField(rsMediate!LinkCode)
            intPWOQty = RtrimGetField(rsMediate!PWOQty)
            strPWOContractNo = RtrimGetField(rsMediate!PWOContractNo)
            strPWOQtyRateApplies = RtrimGetField(rsMediate!PWOQtyRateApplies)
            dblPWOLineExRate = RtrimGetField(rsMediate!PWOLineExRate)
            strPWOVatCode = RtrimGetField(rsMediate!PWOVatCode)
            dblPWOVATAmount = RtrimGetField(rsMediate!PWOVATAmount)
            dblPWOLineIncVAT = RtrimGetField(rsMediate!PWOLineIncVAT)
         End If
      End If
   End If

   strInvQty = InvLine.QtyInvoiced
   strInvContractNo = InvLine.LineContNum

   strInvLineTotal = Val(InvLine.GoodsPrice) + (Val(InvLine.GoodsPrice) * (Val(InvLine.LineVatRate) / 100))
   strInvVATAmount = (Val(InvLine.GoodsPrice) * (Val(InvLine.LineVatRate) / 100))
   strInvLineExVat = Val(InvLine.GoodsPrice)
   strInvVATCode = InvLine.LineVatCode
   

   strPaydate = InvPayDate$
   strInvoiceNo = InvInvoiceNo$
   strDateLastModified = Format$(Now, "dd/mm/yyyy")
   If Trim$(strErrorCode) = "" Then strErrorCode = errcode$
   If trimz$(errcode$) = "" And trimz$(strErrorCode) = "" Then
      strStatusFlag = "A"
   Else
      strStatusFlag = "I"
   End If

   If trimz$(errcode$) = "" And trimz$(strErrorCode) = "" Then
      If OrdRecNo& > 0 Then
         getorder ord, OrdRecNo&, 4, True
         DoReconciliation = True
         If ord.status <> "4" Then
            WriteLog dispdata$ & "\mediate.log", SiteNumber%, "---", procname$ & "Order has not been received : " & InvOrderNo$ & " , Local Code : " & Trim$(localcode$)
            strStatusFlag = "I"
            strErrorCode = "IV6"
            DoReconciliation = False
         End If

         If DoReconciliation Then
            'perform automatic reconciliation
            ord.internalmethod = "V"
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
            'store VAT rate                  '20Oct00 JN Added
            ord.VATRateCode = d.vatrate
            ord.VATRatePCT = CStr(VAT(Val(d.vatrate)))

            '20Mar05 TH Added
            dblLineValue = (Val(purprice$) * Val(InvLine.QtyInvoiced))
            
            dblGoodsIncVAT = dblLineValue * VAT(Val(d.vatrate))               '30Jun01 JKU Added
            dblGoodsIncVAT = DblRound(dblGoodsIncVAT, 0, 0)                   '30Jun01 JKU added - round off penny fractions
            dblGoodsIncVAT = dblGoodsIncVAT / 100                             '30Jun01 JKU added
            dblGoodsIncVAT = DblRound(dblGoodsIncVAT, 2, 0)
            ord.VATInclusive = Format$(dblGoodsIncVAT)
            
            dblGoodsExVAT = dblLineValue / 100
            dblGoodsExVAT = DblRound(dblGoodsExVAT, 2, 0)
            dblGoodsVAT = dblGoodsIncVAT - dblGoodsExVAT
            dblGoodsVAT = DblRound(dblGoodsVAT, 2, 0)
            ord.VATAmount = Format$(dblGoodsVAT)   '30Jun01 JKU added
            '---20Mar05 TH
            '---03Aug07 CKJ
            
            rectype$ = "T"
            baltype$ = "B"
            'Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", ""  '07Dec00 AW changed invoicenum$ to InvInvoiceNo$
            'Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$  '02Nov10 AJK F0086901 Added date invoiced
            Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$, ord.PSORequestID, True  ' 22May17 184544 Save EDIOrder to log   '03Mar14 TH Added PSORequestID
            If Abs(adjust!) >= 0.0001 Then
               'Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "" '07Dec00 AW changed invoicenum$ to InvInvoiceNo$
               'Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$ '02Nov10 AJK F0086901 Added date invoiced
               Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$, qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, InvInvoiceNo$, d.vatrate, "", "", "", InvPayDate$, ord.PSORequestID, True  ' 22May17 184544 Save EDIOrder to log  '03Mar14 TH Added PSORequestID
            End If
            ord.status = "7"
            ord.cost = purprice$
            ord.invnum = InvInvoiceNo$
            ord.paydate = InvPayDate$
            ord.Reconciledate = Format$(Now, "ddmmyyyy")
            putdrug d           '<== UNLOCK DRUG  '01Jun02 ALL/ATW
            strStatusFlag = "R"
         Else
            ord.internalmethod = "E"
         End If
         PutOrder ord, OrdRecNo&, "WReconcil"                 'Unlock order
      Else
         WriteLog dispdata$ & "\mediate.log", SiteNumber%, "---", procname$ & "Could not find match for Order No : " & InvOrderNo$ & " , Local Code : " & Trim$(localcode$)
      End If
   End If

   On Error GoTo PIIUpdateErr
   '''dyn.Update
   'SQL Big write to the db here, either update or insert.
''   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
''               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, strOrderNo) & _
''               gTransport.CreateInputParameterXML("OPCode", trnDataTypeVarChar, 13, strOPCode) & _
''               gTransport.CreateInputParameterXML("LinkCode", trnDataTypeVarChar, 22, RtrimGetField(rsMediate!LinkCode)) & _
''               gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 22, strLocalCode) & _
''               gTransport.CreateInputParameterXML("Paydate", trnDataTypeVarChar, 4, RtrimGetField(rsMediate!paydate)) & _
''               gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, RtrimGetField(rsMediate!InvoiceNo)) & _
''               gTransport.CreateInputParameterXML("PWOQty", trnDataTypeint, 4, RtrimGetField(rsMediate!PWOQty)) & _
''               gTransport.CreateInputParameterXML("PWOContractNo", trnDataTypeVarChar, 16, RtrimGetField(rsMediate!PWOContractNo)) & _
''               gTransport.CreateInputParameterXML("PWOQtyRateApplies", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!PWOQtyRateApplies)) & _
''               gTransport.CreateInputParameterXML("PWOLineExRate", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOLineExRate)) & _
''               gTransport.CreateInputParameterXML("PWOVATCode", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!PWOVatCode)) & _
''               gTransport.CreateInputParameterXML("PWOVATAmount", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOVatAmount)) & _
''               gTransport.CreateInputParameterXML("PWOLineIncVAT", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOLineIncVat)) & _
''               gTransport.CreateInputParameterXML("InvQty", trnDataTypeint, 4, strInvQty) & _
''               gTransport.CreateInputParameterXML("InvContractNo", trnDataTypeVarChar, 35, strInvContractNo) & _
''               gTransport.CreateInputParameterXML("InvLineTotal", trnDataTypeFloat, 4, strInvLineTotal) & _
''               gTransport.CreateInputParameterXML("InvVATAmount", trnDataTypeFloat, 4, strInvVATAmount) & _
''               gTransport.CreateInputParameterXML("InvLineIExVAT", trnDataTypeFloat, 4, strInvLineExVat) & _
''               gTransport.CreateInputParameterXML("InvVATCode", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!InvVATCode)) & _
''               gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, strASCIssuePrice) & _
''               gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, strASCPriceLastPaid) & _
''               gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, strASCContractPrice) & _
''               gTransport.CreateInputParameterXML("ASCPriceLastReconciled", trnDataTypeVarChar, 9, strASCPriceLastReconciled) & _
''               gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, strASCContractNumber)
               
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, strOrderNo) & _
               gTransport.CreateInputParameterXML("OPCode", trnDataTypeVarChar, 13, strOPCode) & _
               gTransport.CreateInputParameterXML("LinkCode", trnDataTypeVarChar, 22, strLinkCode) & _
               gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 22, strLocalCode) & _
               gTransport.CreateInputParameterXML("Paydate", trnDataTypeVarChar, 4, strPaydate) & _
               gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, strInvoiceNo) & _
               gTransport.CreateInputParameterXML("PWOQty", trnDataTypeint, 4, intPWOQty) & _
               gTransport.CreateInputParameterXML("PWOContractNo", trnDataTypeVarChar, 16, strPWOContractNo) & _
               gTransport.CreateInputParameterXML("PWOQtyRateApplies", trnDataTypeVarChar, 1, strPWOQtyRateApplies) & _
               gTransport.CreateInputParameterXML("PWOLineExRate", trnDataTypeFloat, 4, dblPWOLineExRate) & _
               gTransport.CreateInputParameterXML("PWOVATCode", trnDataTypeVarChar, 1, strPWOVatCode) & _
               gTransport.CreateInputParameterXML("PWOVATAmount", trnDataTypeFloat, 4, dblPWOVATAmount) & _
               gTransport.CreateInputParameterXML("PWOLineIncVAT", trnDataTypeFloat, 4, dblPWOLineIncVAT) & _
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
               gTransport.CreateInputParameterXML("DateLastModified", trnDataTypeVarChar, 10, strDateLastModified)
  
   If lngWMediateID > 0 Then
      'Update
      strParams = gTransport.CreateInputParameterXML("WMediateID", trnDataTypeint, 4, lngWMediateID) & strParams
      lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WMediate", strParams)
   Else
      lngWMediateID = gTransport.ExecuteInsertSP(g_SessionID, "WMediate", strParams)
   End If
   On Error GoTo 0

   ''dyn.Close

Exit Sub

'------------------------------------------------------------
'  Error Handlers
'------------------------------------------------------------

PIIUpdateErr:

   Screen.MousePointer = 0
   popmessagecr procname$ & " : Update Error", "Failed to add/update record in wMediate table." & Chr$(13) & "Error number : " & Format$(Err) & cr$ & Error$
   Screen.MousePointer = 11

   Resume Next

End Sub

Sub ProcessPWOHdr(PWOHdr As MD280iHdr, PWOOrderNo$, PWOOPCode$)

Dim posn

   posn = InStr(PWOHdr.orderno, "/")
   
   If posn > 0 Then
         PWOOrderNo$ = trimz$(Mid$(PWOHdr.orderno, posn + 1))
      Else
         PWOOrderNo$ = trimz$(Mid$(PWOHdr.orderno, 3))
      End If
   PWOOPCode$ = trimz$(PWOHdr.OrderPCode)

End Sub

Sub ProcessPWOInfo(PWOLine As MD280iLine, PWOOrderNo$, PWOOPCode$)
'22Oct97 EAC added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'30Mar98 EAC trap orders for qty less than AAH minimum order
'12Oct99 TH  Changed to search on correct index

Const procname$ = "ProcessPWOInfo"

''Dim PWODyn As dynaset
''Dim tempd As DrugParameters
Dim fnd&, cont&
Dim matched%
Dim issueprice!, lowerlimit!, upperlimit!, ourprice!
Dim lookup$, SQL$, ascribeprice$
Dim foundPtr As Long, blnFound As Integer   '01Jun02 ALL/ATW
Dim strParams As String
Dim lngWMediateID As Long
Dim strPWOStatusFlag As String
Dim strPWOerrorCode As String
Dim rsOrders As ADODB.Recordset
Dim strQtyOrdered As String
Dim strSiscode As String
Dim strCost As String
Dim strSislistprice As String
Dim strLastReconcilePrice As String
Dim strContno As String
Dim lngRes As Long
Dim strPWOLine As String
Dim strLocalCode As String


   'find drug to which this line refers
   'cleardrug d
   BlankWProduct d
   'found% = 0  '01Jun02 ALL/ATW
   'foundPtr% = 0  '01Jun02 ALL/ATW
   lookup$ = Trim$(PWOLine.localcode)
   findrdrug lookup$, 1, d, foundPtr&, blnFound, 2, False, False
   
   strCost = Format$(Val(d.cost))
   strSislistprice = Format$(Val(d.sislistprice))
   strLastReconcilePrice = Format$(Val(d.lastreconcileprice))
   strContno = d.contno

   'must check to see if this entry has been added before in case
   'of a problem with the last time the file was processed
''   SQL$ = "SELECT * FROM Mediate WHERE (OrderNo = '" & PWOOrderNo$ & "' AND LinkCode = '" & Trim$(PWOLine.LinkCode) & "')"
''   Set PWODyn = WSDB.CreateDynaset(SQL$)
''   PWODyn.LockEdits = False
''
''   'Get the ID then we know whether to do an update or insert later
''
''
''   If PWODyn.EOF Then
''         PWODyn.AddNew
''      Else
''         PWODyn.Edit
''      End If
      
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, PWOOrderNo$) & _
               gTransport.CreateInputParameterXML("LinkCode", trnDataTypeVarChar, 8, Trim$(PWOLine.LinkCode))
   lngWMediateID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWMediatebySiteandOrderNoandlinkCode", strParams)
   
   
'''   PWODyn!orderno = PWOOrderNo$
'''   PWODyn!OPCode = PWOOPCode$
'''   PWODyn!LinkCode = PWOLine.LinkCode
'''   PWODyn!localcode = trimz$(PWOLine.localcode)
'''   PWODyn!PWOQty = Val(PWOLine.Qty)
'''   PWODyn!PWOContractNo = PWOLine.ContractNo
'''   PWODyn!PWOQtyRateApplies = PWOLine.QRApplies
'''   PWODyn!PWOLineExVat = Val(PWOLine.PriceExVAT)
'''   PWODyn!PWOVatCode = PWOLine.VatCode
'''   PWODyn!PWOVatAmount = Val(PWOLine.VATAmount)
'''   PWODyn!PWOLineIncVat = Val(PWOLine.PriceIncVAT)
'''   '22Oct97 EAC added Format(Val()) so that empty fields are written to MDB as 0 for reporting
'''   PWODyn!ASCIssuePrice = Format$(Val(d.cost))
'''   PWODyn!ASCPriceLastPaid = Format$(Val(d.sislistprice))
'''   PWODyn!ASCContractPrice = Format$(Val(d.contprice))
'''   PWODyn!ASCPriceLastReconciled = Format$(Val(d.lastreconcileprice))
'''   '---
'''   PWODyn!ASCContractNumber = d.contno
'''   PWODyn!DateLastModified = Format$(Now, "dd/mm/yyyy")

   'find order on ASCribe Database and update the information
   'appropriately
   cont& = 0
   fnd& = 0

''   Do
   matched = False

   'binarysearchidx PWOOrderNo$, dispdata$ & "\ORDORDNO.IDX", True, cont&, fnd&     '12Oct99 TH Replaced with below
''      scanordreqindex 1, PWOOrderNo$, cont&, fnd&
   'Here we need a select on status,ordernumber and local code (as either barcode or nsvcode) - we need a custom select
   strPWOLine = asciiz(PWOLine.localcode)
   'replace strPWOLine, cr, "", 0
   'replace strPWOLine, lf, "", 0
   'Debugging
''   If InStr(strPWOLine, "201D3073801") > 0 Then
''      Dim i As Integer
''      For i = 1 To Len(strPWOLine)
''         MsgBox Format$(Asc(Mid(strPWOLine, i, 1)))
''      Next
''   End If

   'TO DO
   'OK in test we get unprintable characters coming over - we need to remove these
   'else it will break the transport layer !!!!!!!!!
   EscapeXML strPWOLine '11Jan07 TH Added
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
            gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, PWOOrderNo$) & _
            gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3") & _
            gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 8, Trim$(strPWOLine))
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderForEDIProcessPWOInfo", strParams)
      
      

''      If fnd& > 0 Then
''            getorder ord, fnd&, 3, False
''            If Val(ord.status) = 3 Then
''                  cleardrug tempd
''                  tempd.SisCode = ord.Code
''                  getdrug tempd, 0, foundPtr, False   '01Jun02 ALL/ATW
''                  If trimz$(PWOLine.localcode) = Trim$(tempd.barcode) Or trimz$(PWOLine.localcode) = Trim$(ord.Code) Then matched = True
''               End If
''
''         End If
''   Loop While fnd& > 0 And Not matched
   If Not rsOrders Is Nothing Then     'use returned recordset
      If rsOrders.State = adStateOpen Then
         If rsOrders.RecordCount <> 0 Then
            strSiscode = RtrimGetField(rsOrders!Code)
            fnd& = RtrimGetField(rsOrders!WOrderID)
            strQtyOrdered = RtrimGetField(rsOrders!qtyordered)
            matched = True
         End If
      End If
   End If

   If Val(PWOLine.Qty) = 0 Then  'Stop divide by zero error
      matched = False
''         PWODyn!StatusFlag = "I"
''         PWODyn!errorCode = "PW2"
      strPWOStatusFlag = "I"
      strPWOerrorCode = "PW2"
   End If

   '30Mar98 EAC added to trap orders for qty less than AAH minimum order
''   If matched And Val(PWOLine.Qty) > Val(ord.qtyordered) Then
   If matched And Val(PWOLine.Qty) > Val(strQtyOrdered) Then
      matched = False
''         PWODyn!StatusFlag = "I"
''         PWODyn!errorCode = "PW3"
      strPWOStatusFlag = "I"
      strPWOerrorCode = "PW3"
   End If
   '---

   If matched Then
      If fnd& > 0 Then

         '22Nov00 EAC/CY added
         'd.SisCode = tempd.SisCode
         d.SisCode = strSiscode
         getdrugsup d, 0, foundPtr, False, ord.supcode  '01Jun02 ALL/ATW
         '---
         
         'If ord.pflag ="M" then ascribeprice$=ord.cost else '02Feb99 TH Might be needed for Free EDI items
         If Trim$(d.contno) <> "" And Trim$(d.contprice) <> "" Then
            ascribeprice$ = Trim$(d.contprice)
         ElseIf Trim$(d.lastreconcileprice) <> "" Then
            ascribeprice$ = Trim$(d.lastreconcileprice)
         Else
            ascribeprice$ = Trim$(d.cost)
         End If


         If TransLogVAT Then
            issueprice! = (Val(PWOLine.PriceExVAT) * 100) / Val(PWOLine.Qty)
            ourprice! = Val(ascribeprice$)
         Else
            issueprice! = (Val(PWOLine.PriceIncVAT) * 100) / Val(PWOLine.Qty)
            ourprice! = Val(ascribeprice$) * VAT(Val(d.vatrate))
         End If

         lowerlimit! = ourprice! * (1! - (MediatePWOLowerDiff / 100!))
         upperlimit! = ourprice! * (1! + (MediatePWOUpperDiff / 100!))

         If Trim$(d.contno) <> "" Then
            lowerlimit! = ourprice! * (1! - (MediatePWOLowerDiffOC / 100!))
            upperlimit! = ourprice! * (1! + (MediatePWOUpperDiffOC / 100!))
         End If
         

         getorder ord, fnd&, 3, True  'Lock order
         If issueprice! >= lowerlimit! And issueprice! <= upperlimit! Then
            ord.cost = Format$(issueprice!)
            ord.internalmethod = "V"
''                     PWODyn!StatusFlag = "A"
            strPWOStatusFlag = "A"
         Else
''                     PWODyn!StatusFlag = "I"
''                     PWODyn!errorCode = "PW1"
            strPWOStatusFlag = "I"
            strPWOerrorCode = "PW1"
         End If
         ord.received = Format$(Val(PWOLine.Qty))
         PutOrder ord, fnd&, "WOrder"                 'Unlock order

      Else
         '!!** writelog it?
         WriteLog dispdata$ & "\mediate.log", SiteNumber%, "---", procname$ & " : Could not find match for Order No : " & PWOOrderNo$ & " , NSVCode : " & Trim$(PWOLine.localcode)
''               PWODyn!StatusFlag = "I"
''               PWODyn!errorCode = "NO1"
         strPWOStatusFlag = "I"
         strPWOerrorCode = "NO1"
      End If
   End If
   strLocalCode = trimz$(PWOLine.localcode)  '11Jan07 TH Added and used in DB it below
   EscapeXML strLocalCode                    '     "
   On Error GoTo PMIUpdateErr
   'If matched Then
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, PWOOrderNo$) & _
               gTransport.CreateInputParameterXML("OPCode", trnDataTypeVarChar, 13, PWOOPCode$) & _
               gTransport.CreateInputParameterXML("LinkCode", trnDataTypeVarChar, 8, Trim$(PWOLine.LinkCode)) & _
               gTransport.CreateInputParameterXML("localcode", trnDataTypeVarChar, 22, strLocalCode) & _
               gTransport.CreateInputParameterXML("PWOQty", trnDataTypeint, 4, Val(PWOLine.Qty)) & _
               gTransport.CreateInputParameterXML("PWOContractNo", trnDataTypeVarChar, 16, PWOLine.ContractNo) & _
               gTransport.CreateInputParameterXML("PWOQtyRateApplies", trnDataTypeVarChar, 1, PWOLine.QRApplies) & _
               gTransport.CreateInputParameterXML("PWOLineExVat", trnDataTypeFloat, 8, Val(PWOLine.PriceExVAT)) & _
               gTransport.CreateInputParameterXML("PWOVatCode", trnDataTypeVarChar, 1, PWOLine.VatCode) & _
               gTransport.CreateInputParameterXML("PWOVatAmount", trnDataTypeFloat, 8, Val(PWOLine.VATAmount)) & _
               gTransport.CreateInputParameterXML("PWOLineIncVat", trnDataTypeFloat, 8, Val(PWOLine.PriceIncVAT)) & _
               gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, strCost) & _
               gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, strSislistprice) & _
               gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, strLastReconcilePrice)
               
   strParams = strParams & gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, strContno) & _
               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, strPWOStatusFlag) & _
               gTransport.CreateInputParameterXML("errorCode", trnDataTypeVarChar, 3, strPWOerrorCode) & _
               gTransport.CreateInputParameterXML("DateLastModified", trnDataTypeVarChar, 10, Format$(Now, "dd/mm/yyyy"))
   
   If lngWMediateID > 0 Then
   'update
      strParams = gTransport.CreateInputParameterXML("WMediateID", trnDataTypeint, 4, lngWMediateID) & strParams
      lngRes = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WMediateUpdateForPWOInfo", strParams)
   Else
   'insert - should this ever really happen ?
      'lngRes = gTransport.ExecuteInsertSP(g_SessionID, "WMediate", strParams)
      lngRes = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WMediateInsertForPWOInfo", strParams)
   End If
''   PWODyn.Update
   'Else
   '   'Here we just PWO stuff, plus error codes if required
      
   On Error GoTo 0

''   PWODyn.Close

Exit Sub

'------------------------------------------------------------
'  Error Handlers
'------------------------------------------------------------

PMIUpdateErr:

   popmessagecr procname$ & " : Update Error", "Failed to add/update record in WMediate table." & Chr$(13) & "Error number : " & Format$(Err)

   Resume Next

End Sub

Private Sub ReadInvHeader(ByVal i_intFile, o_Header As MR275Header)
'  Description :  Read an invoice Header from the open file passed as a handle.
'                 Caters to multiple formats and converts to original
'                    Mediate 2.75 format.
'
'  Input :  i_intFile      ;  The file handle
'
'  Output:  o_Header         ;  The Mediate 2.75 Header returned
'
'14Feb17 TH Added - release lock (TFS 177178)

Const ROUTINE = "ReadInvHeader"
Dim uErr As tErrorState
On Error GoTo ReadInvHeaderErrorHandler:
'__________________________

Dim strHeader As String

Dim uTecsol3Header As TCSL300iHeader
Dim intLength As Integer
Dim filelock$  '14Feb17 TH Added (TFS 177178)

   Line Input #i_intFile, strHeader

   r.record = strHeader

   Select Case m_intImportFormat
      Case FORMAT_MEDIATE275
         LSet o_Header = r
         intLength = Len(o_Header)
      Case FORMAT_TECSOL300
         LSet uTecsol3Header = r
         Convert_TCSL300i_MR275i_Header uTecsol3Header, o_Header
         intLength = Len(uTecsol3Header)
      Case Else
   End Select

   If (Len(strHeader) <> intLength - 2) Then
      '14Feb17 TH Added - release lock (TFS 177178)
      filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2C.LCK", "EDIInvoiceLock", 0)
      AcquireLock filelock$, False, 0 '14Feb17 TH Added - release lock (TFS 177178)
         popmessagecr ROUTINE, "Header record missing from Invoices file." & Chr$(13) & "Invalid file format. This program will now end."
         Close
         storesEnd
      End If
'__________________________
ReadInvHeaderCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

ReadInvHeaderErrorHandler:
   CaptureErrorState uErr
   Resume ReadInvHeaderCleanup:
'__________________________ End of Error Handling
End Sub

Private Sub ReadInvLine(ByVal i_intFile As Integer, o_Line As MR275InvLin)
'  Description :  Read an invoice line from the open file passed as a handle.
'                 Caters to multiple formats and converts to original
'                    Mediate 2.75 format.
'
'  Input :  i_intFile      ;  The file handle
'
'  Output:  o_Line         ;  The Mediate 2.75 line returned
'
'14Feb17 TH Added - release lock (TFS 177178)
Const ROUTINE = "ReadInvLine"
Dim uErr As tErrorState
Dim filelock$ '14Feb17 TH Added

On Error GoTo ReadInvLineErrorHandler:
'__________________________

Dim strLine As String

Dim uTecsol3Line As TCSL300iLine
Dim intLength As Integer

   Line Input #i_intFile, strLine

   r.record = strLine

   Select Case m_intImportFormat
      Case FORMAT_MEDIATE275
         LSet o_Line = r
         intLength = Len(o_Line)
      Case FORMAT_TECSOL300
         LSet uTecsol3Line = r
         Convert_TCSL300i_MR275i_Line uTecsol3Line, o_Line
         intLength = Len(uTecsol3Line)
      Case Else
   End Select

   If (Len(strLine) <> intLength - 2) Then
      '14Feb17 TH Added - release lock (TFS 177178)
      filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2C.LCK", "EDIInvoiceLock", 0)
      AcquireLock filelock$, False, 0
         popmessagecr ROUTINE, "Detail record missing from Invoices file." & Chr$(13) & "Invalid file format. This program will now end."
         Close
         storesEnd
      End If

'__________________________
ReadInvLineCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

ReadInvLineErrorHandler:
   CaptureErrorState uErr
   Resume ReadInvLineCleanup:
'__________________________ End of Error Handling
End Sub

Sub ReadInvoices(i_strSupcode As String, DisplayNoData%)
'22Sep99 TH Send date string for use in report
'16Jan02 TH Added supcode parameter to sub and use this to read correct settings (%EDI%)
'23Jan02 TH Stop using the DCT Form report ctr and use stock take one instead. For some reason as yet
'   "       unexplained, the presence of this control was causing a GPF with CE uploads (#55693)
'05Jun02 TH Removed section dealing with PWOfile (this had been inserted in a merge error between 8.4 and 8.5)
'24Sep09 PJC ported: 31Dec04 CKJ fields may be blank or contain 0.0000 when received from AAH
'                    prefer testing strings instead of floating point comparison due to rounding
'24Sep09 PJC ported (F0053407): 12Jan07 PJC Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380)
'24Sep09 PJC ported (F0053407): 12Jan07 PJC Now rejects the whole invoice if error occurs to a single invoice line. (#EDI)
'24Sep09 PJC ported (F0053407): 08Mar07 PJC Added check that the pointer is non-zero before the calling GetOrder. (#EDI)
'21Jul16 XN  Did lookup via EDIProductIdentifier 126634
'14Nov16 TH  Added section to allow the crystal report to be imported from DB (Hosted), then rebuilt locally for use (TFS 157972)
'14Feb17 TH  Added release lock before problematic exits (TFS 176185)
Const procname$ = "ReadInvoices"

Dim InvHdr As MR275Header
Dim InvLine() As MR275InvLin
Dim InvTrailer As MR275Trailer
Dim filelock$, InvFile$, MOrderNo$, msg$, ans$
Dim MInvoiceNo$, MPayDate$, MSupNo$, SQL$
Dim valid%, invHdl%, ErrNo%, loopvar%, Reconcile%, success%
Dim tdate$  '22Sep99 TH
Dim strParams As String
Dim rsMediate As ADODB.Recordset
Dim blnArchiveError As Boolean
Dim lngWMediateArchiveID As Long
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
Dim blnNoCrystalReport As Boolean '14Nov16 TH Added to stop crystal when there is no report available (TFS 157972)
Dim strReportName As String  '14Nov16 TH Used in Crystal DB mod (TFS 157972)
Dim intSuccess As Integer '06Jan17 TH Added (Hosted)

   ReadMediateDefaults i_strSupcode              '16Jan02 TH Added (%EDI%)
   If i_strSupcode = "NOEDIFILE" Then Exit Sub   '   "
   Screen.MousePointer = 11

   'filelock$ = dispdata$ + "\PRNTORD2.LCK"                                                                                         '12Jan07 PJC Replaced below         '24Sep09 PJC ported (F0053407)
   filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2C.LCK", "EDIInvoiceLock", 0)        '12Jan07 PJC Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380) '24Sep09 PJC ported (F0053407)
   AcquireLock filelock$, -2, valid  ' exclusive, keep trying

   If Not valid Then
         Screen.MousePointer = 0
         popmessagecr "Error", "Another terminal is currently performing EDI functions." & crlf$ & crlf$ & "Please try again later."
         Exit Sub
      End If
   'Invfile$ = MEDIImportPath$ & "\export.mdt"
   ' 21May02 ATW added 2 INI settings for TecSol compatibility
   InvFile$ = MEDIImportPath$ & "\" & TxtD$(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "export.mdt", "InvoiceFile", 0)
   m_intImportFormat = CInt(Val(TxtD$(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "1", "InvoiceFormat", 0)))

''   MediateMdb$ = dispdata$ & "\WSLIST.MDB"

''   If Not fileexists(MediateMdb$) Then
''         Screen.MousePointer = 0
''         popmessagecr "Mediate Link", "Could not find the Mediate Database " & MediateMdb$ & crlf$ & crlf$ & "Please ask your system supervisor to check the Mediate settings."
''         Exit Sub
''      End If

   If Not fileexists(InvFile$) Then
         Screen.MousePointer = 0
         AcquireLock filelock$, False, valid '14Feb17 TH Added - release lock before exit (TFS 176185)
         popmessagecr "eTrading Link", "There are no Invoice Records waiting to be processed."
         Exit Sub
      Else
         copy InvFile$, MEDIImportPath$ & "\export.old"
      End If


   invHdl% = FreeFile


   On Error GoTo ReadInvOpenErr
   Open InvFile$ For Input Access Read Lock Read Write As invHdl%
   On Error GoTo 0

   If ErrNo <> 0 Then
      AcquireLock filelock$, False, valid '14Feb17 TH Added - release lock before exit (TFS 176185)
      Exit Sub 'warning message should have been provided by error handler
   End If

   
   blnRejectWholeInvoice = TrueFalse(TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "N", "RejectAllEDIInvoiceIfError", 0))    '12Jan07 PJC Added (#EDI) '24Sep09 PJC ported (F0053407)

   'main loop
   Do While Not EOF(invHdl)

      On Error GoTo ReadInvReadErr
      ' 21May02 ATW Broke block into Header-reading routine
      ReadInvHeader invHdl, InvHdr

      ReDim InvLine(Val(InvHdr.numlines))
      ReDim recnos&(Val(InvHdr.numlines))
      ReDim Errs(Val(InvHdr.numlines)) As String * 3

      For loopvar = 1 To Val(InvHdr.numlines)

         On Error GoTo ReadInvReadErr
         ' 21May02 ATW broke reading line into routine
         ReadInvLine invHdl, InvLine(loopvar)

      Next

      On Error GoTo ReadInvReadErr
      ' 21May02 ATW broken block into Trailer reading routine - beware ! The trailer line got read before, but never shoved into the stuct!
      ReadInvTrailer invHdl, InvTrailer

      ProcessInvHdr InvHdr, MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$

      Reconcile = True

      For loopvar = 1 To Val(InvHdr.numlines)
         CheckInvInfo InvLine(loopvar), Errs$(loopvar), MOrderNo$, recnos&(loopvar)
      Next
      
      blnHasError = False    '20Oct06 PJC Added (#EDI) '24Sep09 PJC ported
      
      For loopvar = 1 To Val(InvHdr.numlines)
         '31Dec04 CKJ fields may be blank or contain 0.0000 when received from AAH                                                                          '24Sep09 PJC ported (F0053407)
         '            prefer testing strings instead of floating point comparison due to rounding                                                           '     "
         'If trimz$(InvTrailer.AdditAmount) <> "" And trimz$(InvTrailer.DiscountAmount) <> "" And trimz$(Errs$(loopVar)) = "" Then Errs$(loopVar) = "IV1"   '     "
         If trimz$(Errs$(loopvar)) = "" Then                         'no error code set yet                                                                 '     "
               Select Case trimz$(InvTrailer.AdditAmount)            'is there a value in this                                                              '     "
                  Case "", "0.0000"                                  'no, good                                                                              '     "
                  Case Else                                          'yes, check next field                                                                 '     "
                     Select Case trimz$(InvTrailer.DiscountAmount)   'is there a value in this                                                              '     "
                        Case "", "0.0000"                            'no, good                                                                              '     "
                        Case Else                                    'yes                                                                                   '     "
                           Errs$(loopvar) = "IV1"                    'set error code                                                                        '     "
                        End Select
                  End Select
            End If

         'ProcessInvInfo InvLine(loopVar), MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$, Errs$(loopVar), recnos&(loopVar)                                                                                     '12Jan07 PJC Removed and replaced by switch '24Sep09 PJC ported (F0053407)
         If blnRejectWholeInvoice = False Then                                                                                                                                                              '            If the whole invioce is not rejected when one line is in error then continue as before.
               ProcessInvInfo InvLine(loopvar), MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$, Errs$(loopvar), recnos&(loopvar)                                                                                '        "   Otherwise check the status of the order line is 4
            Else                                                                                                                                                                                            '        "
               If recnos&(loopvar) <> 0 Then                                                                                                                                                                '08Mar07 PJC Dont attempt to get the order at this point if the item on the invoice was not found on the original order i.e.  a zero order position. ('24Sep09 PJC ported with F0053407)
                     getorder ord, recnos&(loopvar), 4, False                                                                                                                                               '        "
                     If ord.status <> "4" Then                                                                                                                                                              '        "
                           WriteLog dispdata$ & "\mediate.log", SiteNumber%, "---", procname$ & "Order has not been received : " & MInvoiceNo$ & " , Local Code : " & Trim$(InvLine(loopvar).localcode)     '        "
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
            For loopvar = 1 To Val(InvHdr.numlines)                                                                            '        "   If one or more invoice lines have been identified as an error
               'if we do have an error on any invioce line then set any non-error lines to an error                            '        "   then invoice lines not in error are set to IV9 error code
               If blnHasError And trimz$(Errs$(loopvar)) = "" Then                                                             '        "   effectively removing the while invioce.
                     Errs$(loopvar) = "IV9"                                                                                    '        "
                  End If                                                                                                       '        "
               ProcessInvInfo InvLine(loopvar), MSupNo$, MOrderNo$, MInvoiceNo$, MPayDate$, Errs$(loopvar), recnos&(loopvar)   '        "
            Next                                                                                                               '        "
         End If                                                                                                                '        "

   Loop

   'Shut input file and table
   Close #invHdl
   '05Jun02 TH Removed (this had been inserted in a merge error between 8.4 and 8.5)
   'If Not fileexists(PWOfile$) Then
   '      Screen.MousePointer = 0   '16Jan02 TH Moved from below (%EDI%)
   '      If DisplayNoData Then popmessagecr "Mediate Link", "There are no Price With Order Records waiting to be processed."
   '      'Screen.MousePointer = 0  '    "
   '      Exit Sub
   '   Else
   '      copy PWOfile$, MEDIImportPath$ & "\replyprc.old"
   '   End If
   '------------------------------

   Kill InvFile$

   'Archive the processed records from the Mediate Table
   success = True

''   On Error GoTo Archive_Err
''   SQL$ = "INSERT INTO MediateArchive SELECT Mediate.* FROM Mediate WHERE (Mediate.StatusFlag='R');"
''   WSDB.Execute SQL$

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "R")
   Set rsMediate = gTransport.ExecuteSelectSP(g_SessionID, "pWMediatebySiteandStatusFlag", strParams)
   
   If Not rsMediate Is Nothing Then     'use returned recordset
      If rsMediate.State = adStateOpen Then
         If rsMediate.RecordCount <> 0 Then
            blnArchiveError = False
            Do While Not rsMediate.EOF And Not blnArchiveError
               'Insert into the mediate Archive
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, RtrimGetField(rsMediate!orderno)) & _
               gTransport.CreateInputParameterXML("OPCode", trnDataTypeVarChar, 13, RtrimGetField(rsMediate!OPCode)) & _
               gTransport.CreateInputParameterXML("LinkCode", trnDataTypeVarChar, 22, RtrimGetField(rsMediate!LinkCode)) & _
               gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 22, RtrimGetField(rsMediate!localcode)) & _
               gTransport.CreateInputParameterXML("Paydate", trnDataTypeVarChar, 4, RtrimGetField(rsMediate!paydate)) & _
               gTransport.CreateInputParameterXML("InvoiceNo", trnDataTypeVarChar, 20, RtrimGetField(rsMediate!InvoiceNo)) & _
               gTransport.CreateInputParameterXML("PWOQty", trnDataTypeint, 4, RtrimGetField(rsMediate!PWOQty)) & _
               gTransport.CreateInputParameterXML("PWOContractNo", trnDataTypeVarChar, 16, RtrimGetField(rsMediate!PWOContractNo)) & _
               gTransport.CreateInputParameterXML("PWOQtyRateApplies", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!PWOQtyRateApplies)) & _
               gTransport.CreateInputParameterXML("PWOLineExRate", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOLineExRate)) & _
               gTransport.CreateInputParameterXML("PWOVATCode", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!PWOVatCode)) & _
               gTransport.CreateInputParameterXML("PWOVATAmount", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOVATAmount)) & _
               gTransport.CreateInputParameterXML("PWOLineIncVAT", trnDataTypeFloat, 4, RtrimGetField(rsMediate!PWOLineIncVAT)) & _
               gTransport.CreateInputParameterXML("InvQty", trnDataTypeint, 4, RtrimGetField(rsMediate!InvQty)) & _
               gTransport.CreateInputParameterXML("InvContractNo", trnDataTypeVarChar, 35, RtrimGetField(rsMediate!InvContractNo)) & _
               gTransport.CreateInputParameterXML("InvLineTotal", trnDataTypeFloat, 4, RtrimGetField(rsMediate!InvLineTotal)) & _
               gTransport.CreateInputParameterXML("InvVATAmount", trnDataTypeFloat, 4, RtrimGetField(rsMediate!InvVATAmount)) & _
               gTransport.CreateInputParameterXML("InvLineIExVAT", trnDataTypeFloat, 4, RtrimGetField(rsMediate!InvLineExVAT)) & _
               gTransport.CreateInputParameterXML("InvVATCode", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!InvVATCode)) & _
               gTransport.CreateInputParameterXML("ASCIssuePrice", trnDataTypeVarChar, 9, RtrimGetField(rsMediate!ASCIssuePrice)) & _
               gTransport.CreateInputParameterXML("ASCPriceLastPaid", trnDataTypeVarChar, 9, RtrimGetField(rsMediate!ASCPriceLastPaid)) & _
               gTransport.CreateInputParameterXML("ASCContractPrice", trnDataTypeVarChar, 9, RtrimGetField(rsMediate!ASCContractPrice)) & _
               gTransport.CreateInputParameterXML("ASCPriceLastReconciled", trnDataTypeVarChar, 9, RtrimGetField(rsMediate!ASCPriceLastReconciled)) & _
               gTransport.CreateInputParameterXML("ASCContractNumber", trnDataTypeVarChar, 10, RtrimGetField(rsMediate!ASCContractNumber))
               strParams = strParams & gTransport.CreateInputParameterXML("ErrorCode", trnDataTypeVarChar, 3, RtrimGetField(rsMediate!ErrorCode)) & _
               gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, RtrimGetField(rsMediate!StatusFlag)) & _
               gTransport.CreateInputParameterXML("DateLastModified", trnDataTypeVarChar, 10, RtrimGetField(rsMediate!DateLastModified))
  
   
               lngWMediateArchiveID = gTransport.ExecuteInsertSP(g_SessionID, "WMediateArchive", strParams)
               If lngWMediateArchiveID = 0 Then blnArchiveError = True
               rsMediate.MoveNext
            Loop
         End If
      End If
   End If
   
''   If success Then
''         SQL$ = "DELETE FROM Mediate WHERE (Mediate.StatusFlag='R');"
''         WSDB.Execute SQL$
''      End If
         
   If Not blnArchiveError Then
      If Not rsMediate Is Nothing Then     'use returned recordset
         If rsMediate.State = adStateOpen Then
            If rsMediate.RecordCount <> 0 Then
               rsMediate.MoveFirst
               Do While Not rsMediate.EOF
                  lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WMediate", RtrimGetField(rsMediate!WMediateID))
                  rsMediate.MoveNext
               Loop
            
            End If
         End If
      End If
   End If
   rsMediate.Close
   Set rsMediate = Nothing
   
   On Error GoTo 0

   Screen.MousePointer = 0
   Confirm "eTrading Exception Report", "print Exception Report", ans$, k
   
   
   If Not k.escd And Trim$(UCase$(ans$)) = "Y" Then
      'Now we need to do the report
      'First lets get the recordset we intend to use
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "TodaysExceptions", 0)) Then
         strDate = Format(date, "dd") & "/" & Format(date, "mm") & "/" & Format(date, "yyyy")
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "I") & _
                     gTransport.CreateInputParameterXML("DateLastModified", trnDataTypeVarChar, 10, strDate)
         Set rsMediate = gTransport.ExecuteSelectSP(g_SessionID, "pWMediateforTodaysExceptionsRpt", strParams)
      Else
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("StatusFlag", trnDataTypeVarChar, 1, "I")
         Set rsMediate = gTransport.ExecuteSelectSP(g_SessionID, "pWMediateforExceptionsRpt", strParams)

      End If
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Mediate", "Y", "UseCrystal", 0)) Then
         Set crxApp = New CRAXDDRT.Application
         blnNoCrystalReport = False
         '14Nov16 TH Added section to allow the report to be imported from DB (Hosted) (TFS 157972)
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "Y", "CrystalDBReports", 0)) Then  '14Nov16 TH Added new section to get reports from the DB (TFS 157972)
            strReportName = getCrystalFilefromSQL("\aahexcpt.rpt")
            If strReportName = "" Then
               Screen.MousePointer = STDCURSOR
               popmessagecr "Error", "eTrading Exceptions Crystal report file missing from Database." & Chr$(13) & Chr$(13) & "Cannot Print Expired Batches Report."   '12Jan99 TH
               blnNoCrystalReport = True
            End If
         Else
            strReportName = dispdata$ & "\aahexcpt.rpt"
            If Not fileexists(dispdata$ & "\aahexcpt.rpt") Then
               Screen.MousePointer = STDCURSOR
               popmessagecr "!", "Could not print report. File " & dispdata$ & "\aahexcpt.rpt" & " not found"
               blnNoCrystalReport = True
            End If
         End If
                      
         If Not blnNoCrystalReport Then
            Set crxRpt = crxApp.OpenReport(strReportName)
          
         'rsMediate.Sort = "ScreenPosn"
         crxRpt.Database.SetDataSource rsMediate
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
         rsMediate.Close
         Set rsMediate = Nothing
         Set crxRpt = Nothing
         Set crxApp = Nothing
      Else
         'DO rtf here
         strRTFLayout = "\EDIexcep.rtf"
         strContext = "EDIexcep"
         GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, intSuccess  '06Jan17 TH Moved here for check
         'If fileexists(dispdata$ & strRTFLayout) Then
         If intSuccess Then
            'GetTextFile dispdata$ & strRTFLayout, strRTFTxt, 0
            'GetRTFTextFromDB dispdata$ & strRTFLayout, strRTFTxt, 0  '06Dec16 TH Replaced (TFS 157969) '26Jan17 TH Should have been remove on 06Jan

            SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
            MakeLocalFile strTmpFile                                                  'Tmp file used to
            intTmpFileNo = FreeFile                                                   'build report
            Open strTmpFile For Binary Access Write Lock Read Write As intTmpFileNo
            
            'Header Info
            FillHeapSupplierInfo gPRNheapID, sup, success
            ParseItems gPRNheapID, strPgHdr, 0
            Put intTmpFileNo, , strPgHdr
            Do While Not rsMediate.EOF
               'Put relevant info on the heap
               'Heap 10, gPRNheapID, "iDescription", Trim$(temp$), 0
               Heap 10, gPRNheapID, "OrderNo", Trim$(GetField(rsMediate!orderno)), 0    '22Sep05 TH Added
               Heap 10, gPRNheapID, "InvoiceNo", Trim$(GetField(rsMediate!InvoiceNo)), 0
               Heap 10, gPRNheapID, "InvQty", Trim$(GetField(rsMediate!InvQty)), 0  '18Aug04 TH DIscharge interface
               Heap 10, gPRNheapID, "LocalCode", Trim$(GetField(rsMediate!localcode)), 0
               strTemp = Format$(Val(GetField(rsMediate!ASCPriceLastReconciled)) / 100, "#0.00")
               Heap 10, gPRNheapID, "ConvertPrice", strTemp, 0
               Heap 10, gPRNheapID, "ErrorCode", Trim$(GetField(rsMediate!ErrorCode)), 0
               Select Case UCase(Trim$(GetField(rsMediate!ErrorCode)))
                  Case "NO1": strTemp = "No matching order was found on the System."
                  Case "IV1": strTemp = "Discount / Addition was posted with the Invoice."
                  Case "IV2": strTemp = "Part of this item is still outstanding."
                  Case "IV3": strTemp = "Not all items ordered on the the system are present on the Invoice."
                  Case "IV4": strTemp = "Price in Invoice record is outside of Invoice bounds."
                  Case "IV5": strTemp = "VAT rate on eTrading is different to VAT rate on the pharmacy system."
                  Case "IV6": strTemp = "Order had not been received."
                  Case "IV7": strTemp = "Invoice quantity does not match the quantity received."
                  Case "IV8": strTemp = "Invoice quantity is zero."
                  Case "PW1": strTemp = "Price in Price With Orders record is outside of Invoice bounds."
                  Case "PW2": strTemp = "Price With Orders record received with a quantity of zero."
                  Case "PW3": strTemp = "Price With Orders record received for a quantity greater than that ordered."
                  Case Else: strTemp = ""
               End Select
               Heap 10, gPRNheapID, "ErrorCodeText", strTemp, 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               'Heap act, id, "InvLineTotal", Trim$(GetField(rsMediate!InvLineTotal)), 0
               BlankWProduct d
               '27May10 AJK F0061692 Added EDILinkCode check
                           '21Jul16 XN  126634 Did lookup via EDIProductIdentifier first
               If Len(Trim$(GetField(rsMediate!localcode))) = 13 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) = True Then
                                strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                                        gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, Trim$(GetField(rsMediate!orderno))) & _
                                                        gTransport.CreateInputParameterXML("EDIProductIdentifier", trnDataTypeVarChar, 15, Trim$(GetField(rsMediate!localcode)))
                                Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderBySiteOrderNumAndEDIProductIdentifier", strParams)
                                If rsTemp.RecordCount > 0 Then
                                        d.SisCode = RtrimGetField(rsTemp!Code)
                                Else
                                  strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, Trim$(GetField(rsMediate!localcode)))
                  Set rsTemp = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByEDILinkCode", strParams)
                  If rsTemp.RecordCount > 0 Then
                     d.SisCode = RtrimGetField(rsTemp!SisCode)
                  End If
                                End If
               End If
               If RTrim$(d.SisCode) = "" Then
                  If Len(Trim$(GetField(rsMediate!localcode))) = 7 Then
                     d.SisCode = Trim$(GetField(rsMediate!localcode))
                  Else
                     d.barcode = Trim$(GetField(rsMediate!localcode))
                  End If
               End If
               getdrug d, 0, 0, False
               FillHeapDrugInfo gPRNheapID, d, 0
               strDetailLine = strPgItem
               ParseItems gPRNheapID, strDetailLine, 0
               Put intTmpFileNo, , strDetailLine

            
               rsMediate.MoveNext
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
            'popmessagecr "!", "Could not print report. File " & dispdata$ & strRTFLayout & " not found"
            popmessagecr "!", "Could not print report. RTF " & strRTFLayout & " not found in database"
         End If



      End If
   End If
   
   
''   If Not k.escd And Trim$(UCase$(ans$)) = "Y" Then
''         'DctFrm.Report.DataFiles(0) = dispdata$ & "\wslist.mdb"               '23Jan02 TH Replaced with other report ctrl (#55693)
''         'DctFrm.Report.ReportFileName = dispdata$ & "\aahexcpt.rpt"           '    "
''         StockTake.RptStockTake.DataFiles(0) = dispdata$ & "\wslist.mdb"       '    "
''         StockTake.RptStockTake.ReportFileName = dispdata$ & "\aahexcpt.rpt"   '    "
''
''
''         '22Sep99 TH Send out formula here
''         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "TodaysExceptions", 0)) Then    '22Sep99 TH Send date string for use in report
''               tdate$ = Format(date, "dd") & "/" & Format(date, "mm") & "/" & Format(date, "yyyy")     '  "
''               'DctFrm.Report.Formulas(0) = "TodaysDate = '" & tdate$ & "'"            '23Jan02 TH Replaced with other report ctrl (#55693)
''               StockTake.RptStockTake.Formulas(0) = "TodaysDate = '" & tdate$ & "'"    '    "
''            End If                                                                                     '  "
''
''         If UCase$(PrintToScreen$) = "Y" Then
''               'DctFrm.Report.Destination = 0   'Window     '23Jan02 TH Replaced with other report ctrl (#55693)
''               StockTake.RptStockTake.Destination = 0        '   "
''            Else
''               'DctFrm.Report.Destination = 1   'Printer    '23Jan02 TH Replaced with other report ctrl (#55693)
''               StockTake.RptStockTake.Destination = 1        '   "
''            End If
''
''         On Error GoTo CrystalErr
''         'DctFrm.Report.Action = 1              'Run report  '23Jan02 TH Replaced with other report ctrl (#55693)
''         StockTake.RptStockTake.Action = 1                    '   "
''         On Error GoTo 0
''      End If
   Screen.MousePointer = 11

   'release lock to allow other terminals to use mediate link
   AcquireLock filelock$, False, valid

   Screen.MousePointer = 0

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

   popmessagecr "eTrading Link", msg$

Resume Next


ReadInvReadErr:
   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to read from file : " & InvFile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)

   popmessagecr "eTrading Link", msg$

Resume Next

Archive_Err:
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Unable to archive data from eTrading to Archive in database" & cr$
   msg$ = msg$ & "Please contact ASC for support."

   popmessagecr "eTrading Link", msg$

   success = False
Resume Next

CrystalErr:
''   msg$ = "Module : " & modulename$ & crlf$
''   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
''   msg$ = msg$ & "Unable to run Crystal Report " & dispdata$ & "\aahexcpt.rpt" & cr$
''   msg$ = msg$ & "Please contact ASC for support." & cr$
''   'msg$ = msg$ & "Error Number      : " & DctFrm.Report.LastErrorNumber & cr$          '23Jan02 TH Replaced with other report ctrl (#55693)
''   'msg$ = msg$ & "Error Description : " & DctFrm.Report.LastErrorString                '    "
''   msg$ = msg$ & "Error Number      : " & StockTake.RptStockTake.LastErrorNumber & cr$  '    "
''   msg$ = msg$ & "Error Description : " & StockTake.RptStockTake.LastErrorString        '    "

   popmessagecr "eTrading Link", msg$

Resume Next


End Sub

Private Sub ReadInvTrailer(ByVal i_intFile As Integer, o_Trailer As MR275Trailer)
'  Description :  Read an invoice Trailer from the open file passed as a handle.
'                 Caters to multiple formats and converts to original
'                    Mediate 2.75 format.
'
'  Input :  i_intFile      ;  The file handle
'
'  Output:  o_Trailer         ;  The Mediate 2.75 Trailer returned
'
'14Feb17 TH Added - release lock (TFS 177178)

Const ROUTINE = "ReadInvTrailer"
Dim uErr As tErrorState
On Error GoTo ReadInvTrailerErrorHandler:
'__________________________

Dim strTrailer As String
Dim intLength As Integer
Dim filelock$ '14Feb17 TH Added

Dim uTecsol3Trailer As TCSL300iTrailer

   Line Input #i_intFile, strTrailer

   r.record = strTrailer

   Select Case m_intImportFormat
      Case FORMAT_MEDIATE275
         intLength = Len(o_Trailer)
         LSet o_Trailer = r
      Case FORMAT_TECSOL300
         LSet uTecsol3Trailer = r
         Convert_TCSL300i_MR275i_Trailer uTecsol3Trailer, o_Trailer
         intLength = Len(uTecsol3Trailer)
      Case Else
   End Select

   If (Len(strTrailer) <> intLength - 2) Then
      '14Feb17 TH Added - release lock (TFS 177178)
      filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2C.LCK", "EDIInvoiceLock", 0)
      AcquireLock filelock$, False, 0
         popmessagecr ROUTINE, "Trailer record missing from Invoices file." & Chr$(13) & "Invalid file format. This program will now end."
         Close
         storesEnd
      End If

'__________________________
ReadInvTrailerCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, App.EXEName & "." & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

ReadInvTrailerErrorHandler:
   CaptureErrorState uErr
   Resume ReadInvTrailerCleanup:
'__________________________ End of Error Handling

End Sub

Sub ReadMediateDefaults(ByRef strSupCode As String)
'16Jan02 TH Added supcode parameter to Sub and use this to get settings, copying default settings into
'    "      new supplier specific settings file - pass back no file error as oParameter (%EDI)

Dim MEDIhdl%, loopagain%, ErrNo%, errored%, retries%
Dim msg$
Dim strMediateSection As String
Dim blnSaveSettings As Boolean

   'MediateDefaultsFile$ = "\Mediate" & Trim$(io_strSupcode) & ".ini"                                         '16Jan02 TH Convoluted way to read new supplier
''   If Not fileexists(dispdata$ & MediateDefaultsFile$) Then                                                           '   "       supplier specific settings  (%EDI)
''         MediateDefaultsFile$ = MediateDefaultPath$ & "MEDI.dat"                                                      '   "
''         If Not fileexists(dispdata$ & MediateDefaultsFile$) Then
''               popmessagecr "Error", "Could not find the required data file : " & dispdata$ & MediateDefaultsFile$
''               io_strSupcode = "NOEDIFILE"  '16Jan02 TH Flag no file (%EDI%)
''               Exit Sub
''            Else                                                                                                      '   "
''               'copy defaults to new file                                                                             '   "
''               copy dispdata$ & MediateDefaultsFile$, dispdata$ & MediateDefaultPath$ & Trim$(io_strSupcode) & ".dat" '   "
''               MediateDefaultsFile$ = MediateDefaultPath$ & Trim$(io_strSupcode) & ".dat"                             '   "
''            End If                                                                                                    '   "
''      End If
   'OK now we are just using plain configuration settings
   'First we will test the export path setting (this must be present - if not out they go !!
   
   strMediateSection = strSupCode
   
   MEDIExportPath = TxtD(dispdata$ & "\Mediate.ini", strSupCode, "", "MEDIExportPath", 0)
    
   If MEDIExportPath = "" Then
   'Now we try and load the defaults
      MEDIExportPath = TxtD(dispdata$ & "\Mediate.ini", "Default", "", "MEDIExportPath", 0)
      If Trim$(MEDIExportPath) = "" Then
         'popmessagecr "Error", "Could not find the required data file : " & dispdata$ & MediateDefaultsFile$
         popmessagecr "EDI Configuration Error", "Cannot read default configuration settings for EDI/Mediate." & crlf & crlf & _
                                                 "Please Inform your system administrator"
         strSupCode = "NOEDIFILE"  '16Jan02 TH Flag no file (%EDI%)
         Exit Sub
      Else
      'Load the defaults as normal but then save them as the new supplier
         blnSaveSettings = True
         strMediateSection = "Default"
      End If
   End If
   
   'Now we load the rest of the stuff from the section
   
   MediatePWOLowerDiff = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediatePWOLowerDiff", 0))
   MediatePWOUpperDiff = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediatePWOUpperDiff", 0))
   MediateInvLowerDiff = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediateInvLowerDiff", 0))
   MediateInvUpperDiff = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediateInvUpperDiff", 0))
   MEDIImportPath$ = TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MEDIImportPath", 0)
   MediatePWOLowerDiffOC = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediatePWOLowerDiffOC", 0))
   MediatePWOUpperDiffOC = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediatePWOUpperDiffOC", 0))
   MediateInvLowerDiffOC = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediateInvLowerDiffOC", 0))
   MediateInvUpperDiffOC = Val(TxtD(dispdata$ & "\Mediate.ini", strMediateSection, "", "MediateInvUpperDiffOC", 0))
   
   
''   MEDIhdl% = FreeFile
''   loopagain = False
''   On Error GoTo RMDOpenErr
''   Do
''      Open dispdata$ & MediateDefaultsFile$ For Input Access Read Lock Read Write As MEDIhdl%
''   Loop Until Not loopagain
''   On Error GoTo 0
''
''   If errored Then Exit Sub
''
''   On Error GoTo RMDReadErr
''   Input #MEDIhdl, MediatePWOLowerDiff, MediatePWOUpperDiff, MediateInvLowerDiff, MediateInvUpperDiff
''   Input #MEDIhdl, MEDIImportPath$
''   Input #MEDIhdl, MEDIExportPath$
''   '22Nov00 EAC/CY added for seperate variances for on-contract goods
''   On Error Resume Next
''   Input #MEDIhdl, MediatePWOLowerDiffOC, MediatePWOUpperDiffOC, MediateInvLowerDiffOC, MediateInvUpperDiffOC
   If MediatePWOLowerDiffOC = 0 Then MediatePWOLowerDiffOC = MediatePWOLowerDiff
   If MediatePWOUpperDiffOC = 0 Then MediatePWOUpperDiffOC = MediatePWOUpperDiff
   If MediateInvLowerDiffOC = 0 Then MediateInvLowerDiffOC = MediateInvLowerDiff
   If MediateInvUpperDiffOC = 0 Then MediateInvUpperDiffOC = MediateInvUpperDiff
   
   If blnSaveSettings Then
      WritePrivateIniFile strSupCode, "MEDIExportPath", MEDIExportPath, dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediatePWOLowerDiff", Format$(MediatePWOLowerDiff), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediatePWOUpperDiff", Format$(MediatePWOUpperDiff), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediateInvLowerDiff", Format$(MediateInvLowerDiff), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediateInvUpperDiff", Format$(MediateInvUpperDiff), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MEDIImportPath", MEDIImportPath$, dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediatePWOLowerDiffOC", Format$(MediatePWOLowerDiffOC), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediatePWOUpperDiffOC", Format$(MediatePWOUpperDiffOC), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediateInvLowerDiffOC", Format$(MediateInvLowerDiffOC), dispdata$ & "/Mediate.ini", 0
      WritePrivateIniFile strSupCode, "MediateInvUpperDiffOC", Format$(MediateInvUpperDiffOC), dispdata$ & "/Mediate.ini", 0
   End If
''   On Error GoTo 0

''   Close #MEDIhdl%
If errored Then strSupCode = "NOEDIFILE" '16Jan02 TH (%EDI%)
setEdiSupcode strSupCode                 '   "

Exit Sub

'---------------------------------------------------------------------------------------
'  Error Handlers
'---------------------------------------------------------------------------------------

''RMDOpenErr:
''
''   ErrNo = Err
''   Select Case ErrNo
''      Case 70
''         If retries > 10 Then
''               loopagain = False
''               errored = True
''               popmessagecr "ReadMediateDefaults", "Defaults file is locked by another user." & Chr$(13) & "Please try again later."
''            Else
''               loopagain = True
''            End If
''      Case Else
''         msg$ = "Module : " & modulename$ & crlf$
''         msg$ = msg$ & "Procedure : ReadMediateDefaults" & crlf$ & crlf$
''         msg$ = msg$ & "Failed to open file : " & dispdata$ & MediateDefaultsFile$ & crlf$
''         msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
''         msg$ = msg$ & "Error Message : " & Error$(ErrNo)
''
''         popmessagecr "Mediate Link", msg$
''   End Select
''
''   errored = True
''
''   Resume Next

''RMDReadErr:
''
''   Resume Next
''   ErrNo = Err
''   msg$ = "Module : " & modulename$ & crlf$
''   msg$ = msg$ & "Procedure : ReadMediateDefaults" & crlf$ & crlf$
''   msg$ = msg$ & "Failed to open file : " & dispdata$ & MediateDefaultsFile$ & crlf$
''   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
''   msg$ = msg$ & "Error Message : " & Error$(ErrNo)
''
''   popmessagecr "Mediate Link", msg$

End Sub

Sub ReadPWO(i_strSupcode As String, DisplayNoData%)

'----------------------------------------------------------------------------------------
'
' Written : 14th March 1997
' Author  : EAC
'
' Inputs  :
' Outputs :
'
' Description
' -----------
'
'
'----------------------------------------------------------------------------------------
'16Jan02 TH Added supcode input parameter so as to get new suppplier specific settings (%EDI%)
'   "       Also changed mousepointer calls to tidy up message boxes
'24Sep09 PJC Ported: 12Jan07 PJC Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380)
'14Feb17 TH Release lock before non standard exit (TFS 176185)
   
Const procname$ = "ReadPWO"
Dim PWOHdr  As MD280iHdr
Dim PWOLine() As MD280iLine

Dim filelock$, linetext$, msg$, MOrderNo$, MOPCode$, PWOfile$
Dim valid%, pwohdl%, ErrNo%, loopvar%
   ReadMediateDefaults i_strSupcode              '16Jan02 TH Added (%EDI%)
   If i_strSupcode = "NOEDIFILE" Then Exit Sub   '   "


   Screen.MousePointer = HOURGLASS

   'filelock$ = dispdata$ + "\PRNTORD2.LCK"                                                                                '12Jan07 PJC Replaced by line below. (#84380) '24Sep09 PJC Ported
   filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2B.LCK", "EDIPWOLock", 0)   '12Jan07 PJC Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380) '24Sep09 PJC Ported
   AcquireLock filelock$, -2, valid  ' exclusive, keep trying

   If Not valid Then
      popmessagecr "Error", "Another terminal is currently performing EDI functions." & crlf$ & crlf$ & "Please try again later."
      Screen.MousePointer = 0
      Exit Sub
   End If

   PWOfile$ = MEDIImportPath$ & "\replyprc.dat"
''   MediateMdb$ = dispdata$ & "\WSLIST.MDB"

''   If Not fileexists(MediateMdb$) Then
''      Screen.MousePointer = 0   '16Jan02 TH Moved from below (%EDI%)
''      popmessagecr "Mediate Link", "Could not find the Mediate Database " & MediateMdb$ & crlf$ & crlf$ & "Please ask your system supervisor to check the Mediate settings."
''      'Screen.MousePointer = 0  '   "
''      Exit Sub
''   End If

   If Not fileexists(PWOfile$) Then
      Screen.MousePointer = 0   '16Jan02 TH Moved from below (%EDI%)
      AcquireLock filelock$, False, valid '14Feb17 TH Added - release lock before exit (TFS 176185)
      If DisplayNoData Then popmessagecr "eTrading Link", "There are no Price With Order Records waiting to be processed."
      'Screen.MousePointer = 0  '    "
      Exit Sub
   Else
      copy PWOfile$, MEDIImportPath$ & "\replyprc.old"
   End If

   
   pwohdl% = FreeFile
   On Error GoTo ReadPWOOpenErr
   Open PWOfile$ For Input Access Read Lock Read Write As pwohdl%
   On Error GoTo 0

   'open the table
'   On Error GoTo ReadPWOOpenTableErr
'   Set PWOStore = WSDB.OpenTable("Mediate")
'   On Error GoTo 0

   If ErrNo <> 0 Then
      Screen.MousePointer = 0
      AcquireLock filelock$, False, valid '14Feb17 TH Added - release lock before exit (TFS 176185)
      Exit Sub 'warning message should have been provided by error handler
   End If

   'main loop
   Do While Not EOF(pwohdl)
      
      On Error GoTo ReadPWOReadErr
      Line Input #pwohdl, linetext$
      On Error GoTo 0

      If Len(linetext$) <> (Len(PWOHdr) - 2) Then
         popmessagecr procname$, "Header record length invalid from Price With Orders file." & Chr$(13) & "Line length = " & Format$(Len(linetext$)) & " characters."
      End If

      r.record = linetext$
      LSet PWOHdr = r
      ReDim PWOLine(Val(PWOHdr.Numoflines))
      For loopvar = 1 To Val(PWOHdr.Numoflines)
         On Error GoTo ReadPWOReadErr
         Line Input #pwohdl, linetext$
         On Error GoTo 0
         If Len(linetext$) <> (Len(PWOLine(1)) - 2) Then
            popmessagecr procname$, "Detail record length invalid from Price With Orders file." & Chr$(13) & "Line length = " & Format$(Len(linetext$)) & " characters."
         End If
         r.record = linetext$
         LSet PWOLine(loopvar) = r
      Next

      ProcessPWOHdr PWOHdr, MOrderNo$, MOPCode$
      For loopvar = 1 To Val(PWOHdr.Numoflines)
         ProcessPWOInfo PWOLine(loopvar), MOrderNo$, MOPCode$
      Next

   Loop

   'Shut input file and table
   Close #pwohdl

   Kill PWOfile$

   'release lock to allow other terminals to use mediate link
   AcquireLock filelock$, False, valid

   Screen.MousePointer = 0

Exit Sub


'---------------------------------------------------------------------------------------------------
'ERROR Handlers
'---------------------------------------------------------------------------------------------------

ReadPWOOpenErr:

   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to open file : " & PWOfile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)

   popmessagecr "eTrading Link", msg$

   Resume Next


ReadPWOReadErr:

   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to read from file : " & PWOfile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)

   popmessagecr "eTrading Link", msg$

   Resume Next

'ReadPWOOpenTableErr:
'
'   '!!** if table already open then continue, else report error
'
'   Resume Next

'---------------------------------------------------------------------------------------------------

End Sub

Sub ReadTexsolDefaults()

   'stub ready for Texsol link

End Sub

Sub SaveMediateDefaults(i_strSupcode As String)
'22Nov00 EAC/CY Allow seperate variances for On-Contract items
'16Jan02 TH Added supplier parameter to Sub to use when saving settings file (%EDI%)
'30Nov06 TH

Const procname$ = "SaveMediateDefaults"
Dim MEDIhdl%, loopagain%, ErrNo%, errored%, retries%
Dim msg$
Dim strMediateSection As String

   strMediateSection = i_strSupcode

''   MediateDefaultsFile$ = MediateDefaultPath$ & Trim$(i_strSupcode) & ".dat"   '16Jan02 TH (%EDI%)
''   MEDIhdl% = FreeFile
''   loopagain = False
''   On Error GoTo SMDOpenErr
''   Do
''      Open dispdata$ & MediateDefaultsFile$ For Output Access Write Lock Read Write As MEDIhdl%
''   Loop Until Not loopagain
''   On Error GoTo 0
''
''   If errored Then Exit Sub

   On Error GoTo SMDReadErr
''   Print #MEDIhdl, MediatePWOLowerDiff, MediatePWOUpperDiff, MediateInvLowerDiff, MediateInvUpperDiff
''   Print #MEDIhdl, MEDIImportPath$
''   Print #MEDIhdl, MEDIExportPath$
''   '22Nov00 EAC/CY Added to allow seperate variances for on-contract items
''   Print #MEDIhdl, MediatePWOLowerDiffOC, MediatePWOUpperDiffOC, MediateInvLowerDiffOC, MediateInvUpperDiffOC
''   On Error GoTo 0

   Close #MEDIhdl%
   WritePrivateIniFile strMediateSection, "MediatePWOLowerDiff", Format$(MediatePWOLowerDiff), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediatePWOUpperDiff", Format$(MediatePWOUpperDiff), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediateInvLowerDiff", Format$(MediateInvLowerDiff), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediateInvUpperDiff", Format$(MediateInvUpperDiff), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediatePWOLowerDiffOC", Format$(MediatePWOLowerDiffOC), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediatePWOUpperDiffOC", Format$(MediatePWOUpperDiffOC), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediateInvLowerDiffOC", Format$(MediateInvLowerDiffOC), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MediateInvUpperDiffOC", Format$(MediateInvUpperDiffOC), dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MEDIImportPath", MEDIImportPath$, dispdata$ & "\Mediate.ini", 0
   WritePrivateIniFile strMediateSection, "MEDIExportPath", MEDIExportPath$, dispdata$ & "\Mediate.ini", 0
   
   On Error GoTo 0

Exit Sub

'---------------------------------------------------------------------------------------
'  Error Handlers
'---------------------------------------------------------------------------------------

SMDOpenErr:

   ErrNo = Err
   Select Case ErrNo
      Case 70
         If retries > 10 Then
            loopagain = False
            errored = True
            popmessagecr procname$, "Defaults file is locked by another user." & Chr$(13) & "Please try again later."
         Else
            loopagain = True
         End If
      Case Else
         msg$ = "Module : " & modulename$ & crlf$
         msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
         msg$ = msg$ & "Failed to open file : " & dispdata$ & MediateDefaultsFile$ & crlf$
         msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
         msg$ = msg$ & "Error Message : " & Error$(ErrNo)
         popmessagecr "eTrading Link", msg$
   End Select
   
   errored = True

   Resume Next

SMDReadErr:

   Resume Next
   ErrNo = Err
   msg$ = "Module : " & modulename$ & crlf$
   msg$ = msg$ & "Procedure : " & procname$ & crlf$ & crlf$
   msg$ = msg$ & "Failed to open file : " & dispdata$ & MediateDefaultsFile$ & crlf$
   msg$ = msg$ & "Error Number : " & Format$(ErrNo) & crlf$
   msg$ = msg$ & "Error Message : " & Error$(ErrNo)
   
   popmessagecr "eTrading Link", msg$


End Sub

Sub SendEDIOrder(i_strSupcode As String)
'-----------------------------------------------------------------------------
'Send order to EDI machine for all items at status 2 & 'E' type transmission.
'
'
' Scan ordordno.idx file for status 2 & 'E' type transmission
' Store & sort all lines by site/supplier/
'
'mods needed
'-----------
' need to check for same NSVcode on order two or more times on same run
'  for same supplier
'/urgency flag
'29Dec97 EAC Use Stores drug description
'19Dec98 EAC Use new Order printing routines
'07Jun99 EAC Corrected printing of tradenames on Edi orders
'21Feb00 SF now allows reprinting of the order
'10Apr00 CFY Parameter added to wsspool call.
'16Jan02 TH made supplier specific with seperate settings (%EDI%) - Added supplier code parameter
'15Feb02 TH Changed parameters in Wspool call to try and use correct number for reprint (#50749)
'10May02 SF added additional dummy parameter to PrintOrdTotal:
'05Aug02 TH Reinstated manual entry for EDI Ordering
'25Feb08 TH Use get drug sup now so that it will get write sup profile deatils for order costing
'           AND added check so that if non-stock prod will use price last paid IF NOT ZERO (as per standard order)
'24Sep09 PJC Ported: 12Jan07 PJC Filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380)
'11Apr10 TH Ensure contract number is reset for each item (F0042977)
'27May10 AJK F0061692 Use EDILinkCode if it exists as localcode
'05Aug10 TH Added batch handling of interface output for UHB Age interface
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'15May12 TH  Mods to record contract information in the WOrderlog (TFS 30860)
'09Aug13 TH  The lookup replacement had broken the link with the underlying order. This has led to a situation where the
'            output lines are all out by one in terms of the drug specific information (TFS  71076)
'08Nov14 TH  At N Cumbria the supcodes where camle case and this caused contract details not to be loaded (TFS 103725)
'10Jul15 TH EDI Print Extra info line. If we dont have anything parsable in the extra section then just print it directly and move on (TFS 102796)
'21Jul16 XN If EDI Barcode is set then send as localcode 126634
'13Feb17 TH In some areas you could exit from here with business lock still retained (TFS 176185)
'14Feb17 TH Release lock here - two more ways out that didnt release the locks (TFS 176185)
'22May17 XN 184544 set EDIOrder to true in to log
'-----------------------------------------------------------------------------
Dim filelock$, cond$, condoff$, currentsup$, Item$, FILE$, currentord$, bcr$, desc$
Dim RTFTxt$, temp$, lastordernum$, RTFfile$
Dim contract$, price$, daterec$, qtyord$, qtyrec$, ordqty$, AuthUserid$, ans$
Dim valid%, chan%, ErrNum%, filno%, lineno%, begptr%, endptr%  'foundsup%,
Dim success%, pageno%, printtn%, printsis%
Dim pointer&, X&
Dim pforprinting!, VatForPrinting!, PtotordCost!, PtotordVat!
Dim extraline$             '07Jun99 EAC Added
Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim lngFoundSup As Long

Dim foundPtr As Long  '01Jun02 ALL/ATW

Dim strContractNumber As String   '15May12 TH Added (TFS 30860)
Dim strContractPrice As String    '    "
Dim blncontract As Boolean        '    "


   ReadMediateDefaults i_strSupcode              '16Jan02 TH Added (%EDI%)
   If i_strSupcode = "NOEDIFILE" Then Exit Sub   '   "
   
   'getsupplier i_strSupcode, 0, 0, sup  '10Nov06TH Cast into global for generic printing routines

   k.escd = False
   'filelock$ = dispdata$ + "\PRNTORD2.LCK"        '12Jan07 PJC replaced (24Sep09 PJC Ported)
   filelock$ = dispdata$ & "\" & TxtD(dispdata$ & INIFILE_WINORD, INISECTION_INVIMPORT, "PRNTOR2A.LCK", "EDIOrderLock", 0)  '12Jan07 PJC filelock name changed to allow EDI orders and EDI invoice processes to occur at the same time.  (#84380) (24Sep09 PJC Ported)

   AcquireLock filelock$, -2, valid  ' exclusive, keep trying
   cond$ = Chr$(15)
   condoff$ = Chr$(18)

   If Not valid Then
      Beep
      popmessagecr "!n!iPlease try later", "EDI/Modem orders are being raised on another terminal"
      Exit Sub                                                '<== WAY OUT
   End If

   Edittype = 1
   currentsup$ = ""
   lngFoundSup = 0
   ''getnumofords edittype, pointer&, False
   OwnSiteNo$ = Right$("000" + LTrim$(Str$(SiteNumber)), 3)

   MainScreen.LstDisplay.Clear

   MainScreen.LstDisplay.AddItem "Searching ..."

   Do While MultiList.LstUnselected.ListCount
      MultiList.LstUnselected.RemoveItem 0
   Loop
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("InternalMethod", trnDataTypeVarChar, 1, "E") & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, UCase$(Trim$(i_strSupcode))) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "2")
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbySiteandInternalMethodandSupcodeandStatus", strParams)
   If rsOrders.RecordCount > 0 Then
      rsOrders.MoveFirst
      Do While Not rsOrders.EOF
      ''For x& = 2 To pointer&
         ''getorder ord, x&, 1, False        ' (no idx)
         ord = FillOrdFromRS(rsOrders, "WOrder")
         'If ord.status = "2" And ord.internalmethod = "E" Then
         '''If ord.status = "2" And ord.internalmethod = "E" And UCase$(Trim$(ord.supcode)) = UCase$(Trim$(i_strSupcode)) Then '16Jan02 TH (%EDI%)
               '     XXXSSSSSOOOOn[n...]
         Item$ = UCase$(OwnSiteNo$ + ord.supcode + ord.num + Str$(ord.OrderID))
         MultiList.LstUnselected.AddItem Item$
         rsOrders.MoveNext 'oops, quite important this really !!
         '''   End If
         'If INKEY$ = Chr$(27) Then
         '      k.escd = True
         '      Exit For
         '  End If
      ''Next
      Loop
   End If
   If k.escd Then
      Unload MultiList
      AcquireLock filelock$, 0, valid '13Feb17 TH Release lock (TFS 176185)
      Exit Sub                                       '<== WAY OUT
   End If


   ChangeTable "Blank", False '14Aug12 TH Added Param

   If MultiList.LstUnselected.ListCount Then

      MainScreen.LstDisplay.Visible = True
      chan = FreeFile
      Do
         On Error GoTo LockError
         ErrNum = 0
         Open MEDIExportPath$ & ToMediate For Append Lock Read Write As #chan
         Err70msg ErrNum, "ToMediate"
      Loop While ErrNum
      On Error GoTo 0

      MakeLocalFile FILE$
      filno = FreeFile
      Open FILE$ For Binary Access Write Lock Read Write As #filno                ' for spooling ...

      RTFfile$ = "\orddata.rtf"
      'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
      GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
         AcquireLock filelock$, 0, valid '13Feb17 TH Release lock (TFS 176185)
         Exit Sub
      End If

      striprtf RTFTxt$

      RTFfile$ = "\ordextra.rtf"
      'GetTextFile dispdata$ + RTFfile$, extraline$, success
      GetRTFTextFromDB dispdata$ + RTFfile$, extraline$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
         AcquireLock filelock$, 0, valid '13Feb17 TH Release lock (TFS 176185)
         Exit Sub
      End If
      striprtf extraline$
      temp$ = "{"
      Put #filno, , temp$

      GoSub ProcessEDIOrders

      If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
         PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
      End If
      printordertail filno%, "", False '20Aug12 TH PSO not allowed for EDI type
      'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "O" '04Aug10 TH Added '05Aug10 TH Changed to O type
      If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "O", False   '03Mar14 TH Added Param

      temp$ = "}"
      Put #filno, , temp$

      Close filno
      AcquireLock filelock$, 0, valid

      ans$ = ""
      k.helpnum = 0
      k.escd = False
      Confirm "!n!bOrder Report", "send report to printer", ans$, k

      If ans$ = "Y" And Not k.escd Then
         WSspool FILE$, "EDI Order Confirmation", 1, True, Val(currentord$), "EDIOrder"  '15Feb02 TH Added to try and use correct number for reprint (#50749)
      Else
         Kill FILE$
      End If
   Else
      AcquireLock filelock$, 0, valid '14Feb17 TH Release lock here (TFS 176185)
      popmessagecr "!n!bEDI Orders", "No items ordered"
   End If

   Unload MultiList
   Close #chan

Exit Sub

FindSupplierBounds:
   If begptr <= MultiList.LstUnselected.ListCount Then
      'currentsup$ = Left$(MultiList.LstUnselected.List(begptr - 1), 12)
      currentsup$ = Left$(MultiList.LstUnselected.List(begptr - 1), 18) '21Apr08 TH Replaced (F0020040)
      endptr = begptr
      For endptr = begptr To MultiList.LstUnselected.ListCount
         'If Left$(MultiList.LstUnselected.List(endptr - 1), 12) <> currentsup$ Then
         If Left$(MultiList.LstUnselected.List(endptr - 1), 18) <> currentsup$ Then '21Apr08 TH Replaced (F0020040)
            endptr = endptr - 1
            Exit For
         End If
      Next
      If endptr > MultiList.LstUnselected.ListCount Then    'last supplier
            endptr = MultiList.LstUnselected.ListCount
         End If
      ''currentord$ = Mid$(MultiList.LstUnselected.List(begptr - 1), 9, 4)            'xxxsssssOOOO'
      currentord$ = Mid$(MultiList.LstUnselected.List(begptr - 1), 9, 10)    'SQL NOW xxxsssssOOOOOOOOOO
      currentsup$ = Mid$(currentsup$, 4, 5)            'xxxsssssOOOOOOOOOO
   End If
Return

LockError:
   Select Case Err
      Case 70, 63
         Resume Next
   End Select

   ErrNum = Err
   AcquireLock filelock$, 0, valid '14Feb17 TH Release lock here (TFS 176185)
   popmessagecr "Error", "Halt in SendEDIOrder with error " & ErrNum
   Close
storesEnd

ProcessEDIOrders:

   lineno = 0
   begptr = 1     'start of items for current supplier
   endptr = 1     'end ditto
   pageno = 1

   Do 'all suppliers in turn
      GoSub FindSupplierBounds
      getsupplier currentsup$, 0, lngFoundSup, sup

      If lngFoundSup > 0 And sup.Method = "E" Then

         MainScreen.LstDisplay.AddItem "Supplier " & currentsup$ & "     "

         Do 'all items for this supplier
            r.record = ""
            LSet OrdLin = r
            ''currentord$ = Mid$(MultiList.LstUnselected.List(begptr - 1), 9, 4)
            currentord$ = Mid$(MultiList.LstUnselected.List(begptr - 1), 9, 10)
            If lastordernum$ <> currentord$ Then
               'write mediate hdr
               OrdHdr.OrdNum = OwnSiteNo$ + "/" + currentord$       'AS STRING * 16  sss/1 - sss/9999
               OrdHdr.OrdRef = ""                                   'AS STRING * 41
               OrdHdr.LocalSupCode = OwnSiteNo$ + "/" + currentsup$ 'AS STRING * 13  sss/xxxxx  eg 043/0001
               OrdHdr.AcctNum = ""                                  'AS STRING * 13
               OrdHdr.numlines = LTrim$(Str$(endptr - begptr + 1))  'AS STRING * 4
               OrdHdr.ContractNum = ""                              'AS STRING * 35
               OrdHdr.orderdate = Right$(date$, 2) & Left$(date$, 2) & Mid$(date$, 4, 2)     'AS STRING * 6  ' YYMMDD '03May98 CKJ Y2K !!** NOT Y2K COMPLIANT
               OrdHdr.DelivDate = ""                                'AS STRING * 6 YYMMDD
               OrdHdr.DelivANAnum = ""                              'AS STRING * 13
               OrdHdr.DelivDetails = sup.ordmessage                 'AS STRING * 40
               OrdHdr.crlf = Chr$(13) + Chr$(10)                    'AS STRING * 2   'Mandatory
               LSet r = OrdHdr
               Print #chan, Left$(r.record, Len(OrdHdr));
               'print order confirmation
               If pageno > 1 Then
                  If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
                     PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
                  End If
                  PtotordCost! = 0
                  PtotordVat! = 0
                  printordertail filno%, "", False '20Aug12 TH PSO not allowed for EDI type
                  temp$ = "[FF]" '9Feb95 CKJ prevents FF at end of run
                  PrinterParse temp$
                  Put #filno, , temp$
                  lineno = 0
                  'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "O"  '05Aug10 TH Changed to O type
                  If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "O", False    '03Mar14 TH Added Param
               End If
               pageno = pageno + 1
               printordertop currentsup$, currentord$, filno, printtn, printsis, 2, False '20Aug12 TH PSO not allowed for EDI type
               PrintOrdDescriptor filno, printtn, False '20Aug12 TH PSO not allowed for EDI type
               'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader ord.supcode, CLng(currentord$), "O"  '05Aug10 TH Changed to O type
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader ord.supcode, CLng(currentord$), "O", False    '03Mar14 TH Added Param
            End If
            lastordernum$ = currentord$
            ''x& = Val(Mid$(MultiList.LstUnselected.List(begptr - 1), 13))
            X& = Val(Mid$(MultiList.LstUnselected.List(begptr - 1), 19))
            getorder ord, X&, 1, True             '<----LOCK (no idx)
            MainScreen.LstDisplay.AddItem "Order    " & ord.num & "    : Item     " & ord.Code & "       "
            contract$ = "" '11Apr10 TH Ensure this is reset for each item (F0042977)
            'LookupDrug ord.Code, d, foundPtr&   '01Jun02 ALL/ATW  '15May12 TH Removed
            'Added, should really replace above
            d.SisCode = ord.Code         '09Aug13 TH The lookup replacement had broken the link with the underlying order (TFS  71076)
            getdrugsup d, 0, 0, False, sup.Code '24Feb08 TH Added to get supplier specific contract price/price last paid,  if required
            '27May10 AJK F0061692 Use EDILinkCode if it exists
                        OrdLin.localcode = ""
                        If TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) Then
                                'If EDI Barcode is set then send as localcode 126634 21Jul16 XN
                                If Trim$(d.EDIBarcode) <> "" Then
                                        OrdLin.localcode = Trim$(d.EDIBarcode)
                                ElseIf Trim$(d.EDILinkCode) <> "" Then
                                        OrdLin.localcode = Trim$(d.EDILinkCode)
                                End If
                        End If
            If Trim$(OrdLin.localcode) = "" Then
               DummyEAN d.SisCode, bcr$
               If Trim$(d.barcode) = bcr$ Then              'dummy barcode used
                  OrdLin.localcode = ord.Code            'AS STRING * 22
               Else                                      'assume genuine EAN
                  OrdLin.localcode = Trim$(d.barcode)    'AS STRING * 22
               End If
            End If
            OrdLin.qtyordered = ord.outstanding   'AS STRING * 9  max 999999999
            desc$ = d.DrugDescription   ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
            plingparse desc$, "!"
            OrdLin.Description = desc$
            OrdLin.PackSize = LTrim$(d.convfact)  'AS STRING * 8
            OrdLin.TransferMarker = " "           '1 space
            '12345678901234567
            'units (Urgency X)
            OrdLin.Comment = d.PrintformV         'AS STRING * 40  '17 usable
            If ord.urgency <> " " Then
               Mid$(OrdLin.Comment, 7, 11) = "(Urgency " + UCase$(ord.urgency) + ")"
            End If

            strContractNumber = ""
            strContractPrice = ""
            If ord.pflag <> "M" Then '02Feb99 TH Possible code if Free EDI items needed    '05Aug02 TH Reinstated to allow manual entry
               'If ord.supcode = d.supcode And Val(d.contprice) > 0 Then
               If (UCase(ord.supcode) = UCase(d.supcode)) And Val(d.contprice) > 0 Then    '08Nov14 TH (TFS 103725)
                  contract$ = Trim(d.contno)                '10 chars wide
                  If contract$ = "" Then contract$ = "CONTRACT"
                  OrdLin.ContractNum = contract$            'AS STRING * 35
                  price$ = Format$(Val(d.contprice) / 100, "0.00##")
                  OrdLin.UnitPrice = price$    'AS STRING * 9  œ; 0 0.0001 1.1111 11111.111 999999999
                  ord.cost = d.contprice
                  '15May12 TH Store contract information here for the log (TFS)
                  strContractNumber = Trim$(d.contno)
                  strContractPrice = Trim$(d.contprice)
               ElseIf UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then '25Feb08 TH Added further check to make sure that there is a price last paid
                  ord.cost = d.sislistprice                 'œ last paid
               Else
                  ord.cost = d.cost
               End If
            End If           '05Aug02 TH Added
            OrdLin.crlf = Chr$(13) + Chr$(10)       'AS STRING * 2       'Mandatory
            ord.status = "3"
            ord.qtyordered = ord.outstanding
            ord.received = "0"
            daterec$ = ""
            qtyord$ = ord.outstanding
            qtyrec$ = ordqty$
            AuthUserid$ = ord.invnum  'held here from auth & raise
            ord.invnum = ""
            
            '15May12 TH Record the contact info (TFS 30860)
            getdrug d, 0, 0, False  'reget the drug with the default supplier details
            blncontract = False
            If d.supcode <> ord.supcode Then 'This is being ordered from a secondary supplier
               If Val(d.contprice) > 0 Then  'there is contract info for the primary supplier
                  If Not (Val(strContractPrice) > 0) Then
                     'secondary supplier has no contract, primary does, we flag this order. This also covers manual entry
                     blncontract = True
                  End If
               End If
            End If
            setContractData strContractNumber, strContractPrice, blncontract
            '-------
                  
            'Orderlog ord.num, ord.Code, AuthUserid$, ord.orddate, daterec$, qtyord$, qtyrec$, ord.cost, ord.supcode, "O", SiteNumber, contract$, d.vatrate, "", "", ""
            'Orderlog ord.num, ord.Code, AuthUserid$, ord.orddate, daterec$, qtyord$, qtyrec$, ord.cost, ord.supcode, "O", SiteNumber, contract$, d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
            Orderlog ord.num, ord.Code, AuthUserid$, ord.orddate, daterec$, qtyord$, qtyrec$, ord.cost, ord.supcode, "O", SiteNumber, contract$, d.vatrate, "", "", "", "", ord.PSORequestID, True  ' 22May17 XN 184544 set EDIOrder to true in to log   '03Mar14 TH Added PSORequestID

            X& = PutOrder(ord, X&, "WOrder")         '<----UNLOCK  (no idx)
            setContractData "", "", False  '15May12 TH Reset the contact info (TFS 30860)
            LSet r = OrdLin
            Print #chan, Left$(r.record, Len(OrdLin));

            OrderLineParse ord, RTFTxt$, filno%, printsis%, printtn%, begptr%, PtotordCost!, PtotordVat!, pforprinting!, VatForPrinting!, True, False '14Nov12 TH Added PSO param EDI currently exempt from PSO
            'OrderLineParse ord, extraline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, pforprinting!, VatForPrinting!, False, False '14Nov12 TH Added PSO param EDI currently exempt from PSO
            '10Jul15 TH Replaced above line. If we dont have anything parsable in the extra section then just print it directly and move on (TFS 102796)
            If printtn Or OrdPrintPrice Then
               If InStr(extraline$, "[") > 0 Then
                  OrderLineParse ord, extraline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, pforprinting!, VatForPrinting!, False, False '14Nov12 TH Added PSO param EDI currently exempt from PSO
               Else
                  Put #filno, , extraline$
               End If
            End If
            '10Jul15 TH End
                  
            begptr = begptr + 1
         Loop While begptr <= endptr

      Else 'not found supplier or supplier not for EDI
         temp$ = d.SisCode & "  " & desc$ & " Not ordered & supplier '" & currentsup$ & "' not "
         If lngFoundSup = 0 Then
            temp$ = temp$ & "found.[cr]"
         Else
            temp$ = temp$ & "for EDI.[cr]"
         End If
         PrinterParse temp$
         Put #filno, , temp$
      End If
      begptr = endptr + 1       'move to start of next supplier's items
   Loop While begptr <= MultiList.LstUnselected.ListCount

Return

End Sub

Sub setEdiSupcode(i_strSupcode As String)
'16Jan02 TH Written (%EDI%)

   m_strEdiSupcode = i_strSupcode

End Sub

Sub SetMediateItemArchivable(NSVCode$, ordernum$, barcode$, EDILinkCode$, EDIProductIdentifier$)
'''04Mar98 EAC changed from snapshot to dynaset
'''25Jun98 EAC corrected sql
'21Mar10 TH Reinstated (F0080339)
'27May10 AJK F0061692 Added EDILinkCode
'05Mar15 TH Added setting to stop msg firing if the site dont use invoicing (eg AWP) (TFS 104228)
'21Jul16 XN Added EDIProductIdentifier 126634

Dim strParams As String
Dim lngResult As Long

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode$) & _
               gTransport.CreateInputParameterXML("Barcode", trnDataTypeVarChar, 22, barcode$) & _
               gTransport.CreateInputParameterXML("OrderNo", trnDataTypeVarChar, 16, ordernum$) & _
               gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, EDILinkCode$) & _
                           gTransport.CreateInputParameterXML("EDIProductIdentifier", trnDataTypeVarChar, 15, EDIProductIdentifier$)    ' 21Jul16 XN Added EDIProductIdentifier 126634
               
   lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWReconcilEDIArchive", strParams)
   If lngResult = 0 Then
      If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "EDI", "N", "SuppressEDIArchivableMsg", 0)) Then '05Mar15 TH Added setting to stop msg firing if the site dont use invoicing (eg AWP) (TFS 104228)
         popmessagecr "Error", "Failed to find item " & NSVCode$ & " of order number " & ordernum$ & " in the eTrading database" & cr$ & cr$ & "Unable to set this item to be archived."
      End If
      WriteLog dispdata$ & "\mediate.log", SiteNumber%, "---", "Item " & NSVCode$ & " of order number " & ordernum$ & "not found in Mediate table. Could not set this item to be archived."
   End If
   
''
''Dim dyn As dynaset
''Dim SQL$
''
''   '25Jun98 EAC correct sql
''   'sql$ = "SELECT Mediate.StatusFlag FROM MEDIATE WHERE Mediate.LocalCode = '" & Trim$(NSVCode$)
''   'sql$ = sql$ & "' AND (Mediate.OrderNo = '" & Trim$(OrderNum$)
''   'sql$ = sql$ & "' OR Mediate.OrderNo = '" & Trim$(Barcode$)
''   'sql$ = sql$ & "');"
''
''   SQL$ = "SELECT Mediate.StatusFlag FROM MEDIATE WHERE (Mediate.LocalCode = '" & Trim$(NSVCode$)
''   SQL$ = SQL$ & "' OR Mediate.LocalCode = '" & Trim$(barcode$) & "')"
''   SQL$ = SQL$ & " AND Mediate.OrderNo = '" & Trim$(ordernum$)
''   SQL$ = SQL$ & "';"
''
''   Set dyn = WSDB.CreateDynaset(SQL$)
''
''   If dyn.EOF Then
''         popmessagecr "Error", "Failed to find item " & NSVCode$ & " of order number " & ordernum$ & " in the Mediate database" & cr$ & cr$ & "Unable to set this item to be archived."
''         WriteLog dispdata$ & "\mediate.log", sitenumber%, "---", "Item " & NSVCode$ & " of order number " & ordernum$ & "not found in Mediate table. Could not set this item to be archived."
''      Else
''         On Error GoTo SMIAUpdateError
''         dyn.Edit
''         dyn!StatusFlag = "R"
''         dyn.Update
''         On Error GoTo 0
''      End If
''
''   dyn.Close
''   Set dyn = Nothing
''
''Exit Sub
''
''SMIAUpdateError:
''
''      popmessagecr "Error", "Failed to set status to Reconciled for item " & NSVCode$ & " in order number: " & ordernum$
''      WriteLog dispdata$ & "\mediate.log", sitenumber%, "---", "Failed to set field StatusFlag to R for item " & NSVCode$ & " in order number " & ordernum$
''      Resume Next

End Sub

