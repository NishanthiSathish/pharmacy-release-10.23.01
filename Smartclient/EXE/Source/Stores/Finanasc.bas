Attribute VB_Name = "FINANASC2"
'DOStoWIN V1.0 (c) ASCribe 1996
'-----------------------------------------------------------------------------
'                            Finance Program
'20Jan93 ASC derived from ordermnu.bas
'            I have removed any of the code used by the main menu and utilities
'            I have then moved editorders from orderlib and removed redundant
'            code from editorders

'            N.B. Any surcharges or discounts including carriage
'            costs and month end discounts must be costed to appropriate
'            patients/wards and not accounted for separately
'31Aug93 ASC Added ex VAT when TransVAT!>0 in Invoicesummary
'22Nov93 CKJ Added trans types H & L for credit note reconciliation
'            Amended creddate$
'31Dec93 CKJ VBDOS: printform => printformV
'            new VAT
'13Jan94 CKJ Added VAT rate to orderlog BUT STILL SET TO ZERO
'14Jan94 CKJ Checked ORDERLOG VAT rates for all transactions
'17Jan94 CKJ All references to orderfiles now LONG
'            FINANCE.INI added
'            Coding slip now sorted by order no/invoice no
'            Delivery charges handled
'25Jan94 CKJ Extra check on wild reconciliations
'            Bulk of code for discounts entered
'26Jan94 CKJ F10 file viewer written
' 7Feb94 CKJ Month end discount & carriage on orders
' 7Mar94 CKJ passlvls changed
' 7Apr94 CKJ Reset inv totals after reconciling
'17Jun94 CKJ Added reason file lookup to StockValAdjust
' 1Jul94 CKJ Mod to EditOrders to allow page down
' 7Jul94 CKJ Added AskReasonCode
' 5Oct94 CKJ InvoiceSummary: Corrected NSVdiscount$
' 7Jan95 CKJ Changed to use sitenos%() etc
' 9Feb95 CKJ Added confirm for cariage & discount
'20Mar95 CKJ added progsdrv
'24Mar95 CKJ altered Close
' 9Apr96 CKJ InvoiceSummary: Corrected totals displayed when discount posted
'29Oct97 EAC DisplayOrder: Add Hourglass when searching for information
'07Nov97 EAC FINEDITORD: Correct behaviour when deflining OInfoStore(x) to find record number
'29Dec97 EAC use stores drug description
'09Jan98 EAC ensure that Mediate Items will be archived once reconciled
'14Jan98 EAC print batch total at end of coding slip
'11Feb98 EAC StockValAdjust: Restore negative signs on screen
'            StockValAdjust: Correct tabs so that data lines up.
'12Feb98 EAC Finanasc: removed 'backdoor' even though you could never get there with acclevel$ = ""
'24Feb98 EAC FinEditOrd: allow amendment of total cost to meet suppliers invoice total and then write off difference to a cost centre
'13Mar98 CFY FinEditOrd: Now prints order number to log when dealing with 'V' type transactions.
'07Apr98 CFY printledgertop: Added extra code to parse [ordertext] to display either return n.
'            or order no. depending on if we are printing a credit or a return
'            printledger: Fiddle to stop the rtf file that is built up causing hi-edit to blow up with an 'stack overflow' error.
'                         Although hiedit no longer complains, I still can't get the correct fonts to display in the main [data]
'                         rtf.
'03May98 CKJ Removed 'Dynamic metacommand - has no meaning in VBwin
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'05May98 CKJ Added second line of information to reconcil displays for orders & credits
'08May98 CFY printledger: Now deducts credit items from the total amount rather than adding
'15Jul98 EAC FinEditOrd: Only try to archive EDI items if Mediate or Texsol is actually used.
'06Aug98 SF  printledger: Changed formatting so all order details will fit onto one line
'                         (suggest [data] section kept at Arial 8).
'                         Now only uses one RTF file: "csliptop.rtf".
'                         Now kills temp file.
'06Aug98 SF  PrintLedgerDescriptor: changed formatting
'06Aug98 SF  PrintLedgerTail: changed formatting, uses same rtf as printledger:
'12Aug98 TH  FinEditOrd: Now saves invoice total reconciliation changes to ord element (similar to carriage/discount)
'12Aug98 TH  Printledger:Code to deal with negative values (in total reconciliations and discounts)
'                        (Pounsandpence not designed to take negative values)
'12Aug98 TH  FinEditOrd: Added Psuedo Nsvcode to prevent corruption of orderlog
'28Aug98 TH  DisplayOrder: Added Code to exclude Credits
' 1Sep98 TH  DisplayOrder: Added code to properly exclude Credits
'30Oct98 EAC FinEditOrd: added k.escd settings to prevent overflow when entering total invoice cost
'            changed RndAjust from single to double precision so that e numbers eliminated for large values
'30Oct98 EAC FinEditOrd: correct edittype passed to InvoiceSummary so that carriage/discount is not offered for
'            credit note confirmation
'30Oct98 EAC InvoiceSummary: Correct display of total for credit notes
'16Nov98 TH  EnterInvandpay: Picks up date 'phrase' from winord.ini
'20Nov98 TH  FinEditOrd: Added code to allow for default button on final recocilliation to be set to cancel
'08Jan99 SF  InvoiceSummary: attempt to correct rounding errors that could occur
'18Jan99 TH  FinEditOrd: Added error trapping around font change
'28Jan99 TH  FinEditOrd: Added msgbox option to allow for recon price to be future price on ordering (sislistprice)
'29Jan99 TH  FinEditOrd: Only update d.sislistprice for non stock items
'11Feb99 TH  FinEditOrd: Clear Highlighted drugs on escape from invoice screen
'11Feb99 TH  Printledger: Ensure credit prices are printed as negative costs
'17May99 AE  StockValAdjust:Changed formatting of d.stocklvl on screen
'11Oct99 CKJ Removed Findsupplier, replaced with GetSupplier
'19Jan00 SF  FinEditOrd: now rounds the current linevalue to pounds and pence so total will correspond to that on the coding slip
'26Jan00 SF  printledger: now prints reconciliation diffs on both cost lines as was causing incorrect totals being printed
'15May00 EAC FinEditOrd: handle update recieved price properly for reconciliation
'20Oct00 JN  FinEditOrd: Added extra code to store VAT amount, VAT rate (code and %age amt) and VAT Inclusive separately as part of order file
'20Oct00 JN  PrintLedger: Added code to pick up new, pre-calculated VAT Amounts
'23Oct00 JN  RoundUpVAT: Written to round up VAT amounts
'22Nov00 EAC/CY Handle in-dispute items
'08Feb01 TH  FinEditOrd: Ensure paydate recorded as date of reconciliation for credits
'17May01 JKU/ASC InvoiceSummary(): VAT on carriage now available to be written to Reconcil.v8.
'            InvoiceSummary(): Writing of carriage record is now delayed until the user confirms that the Invoice Summary is OK.
'            FinEditOrd(): VAT on carriage now written to Reconcil.v8.
'17May01 JKU/SF InvoiceSummary(): Fixed minor bug in carriage total amount.
'17May01 JKU/EAC FinEditOrd(): Telly conf with TH, JC and MK on 14/06/01. TH and JC commented that the cost
'        field should not be written with any value if this is a VAT adjustment record. TH
'        said that he will sort out the Ausie side if they use this field.
'31May01 TH/JKU FinEditOrd(): Apply correct sales tax name in message
'31May01 TH/JKU InvoiceSummary(): Use getdrugsup for dummy carriage item. This can allow for different sales tax rates on different suppliers for carriage
'            by using supplier profiles on the dummy drug
'18Jun01 JKU/SF InvoiceSummary(): VAT on discount was not written to reconcil.v8 though written to orderlog. This is now rectified.
'22Jun01 JKU/SF DblRound(): Amended. When 'E' is encountered in TargetNum, the whole number is returned. Also, the function now detects 'D'
'        in TargetNum. When 'D' is encountered, it returns the TargetNum.
'26Jun01 JKU/SF FinEditOrd(): The RoundUpVAT function does not work. Eg. 72.97498 returns .72 We now use DBlRound() which is bomb proof.
'30Jun01 JKU FinEditOrd() & InvoiceSummary(): Despite previous attempts to fix, the penny rounding differences are still
'        there! This is the final attempt to fix the daaaammmmn thing. I'll hang myself if this fails.
'02Jul01 JKU PrintLedger(): The modifications done since 17May01 meant that the VATAmount and VATInclusive fields in the
'        Reconcil.v8 file are now being populated during the reconciliation routine. This is necessary to enrure that the
'        AP interface output reflects the actual invoice amounts. However, the coding slip run now shows inaccurate
'        figures for discounts. This is due to several reasons including the use of the PounsAndPence function which
'        renders negative figures to be reported as < 0.01 This is unacceptable in a coding slip run. Other reasons
'        include improper use of the format() function. This session hopes to rectify these problems. I propose to use
'        only the VATAmount and VATInclusive fields for out output. This will gaurantee that the coding slip run
'        reflects the invoice amounts.
'10Oct01 TH  FinEditOrd: Use correct figure from array,not just the last entered for nonstock price last received (#55781)
'10Jan02 TH  StockValAdjust: Changed formatting of stocklevel and also the stockvalue figures on the screen (#46714)
'11Jan02 TH  EnterInvandpay: Added check to stop only spaces being used in invoicenumber entry (#53708)
'15Jan02 TH  MonthEndDiscount, StockValAdjust, FinEditOrd: Added time to orderlog call  (#53214)
'23Jan02 TH  FinEditOrd: No Summary now if cancel at any stage of multi line invoicing (#53400)
'21Feb02 JKU dblRound(), InvoiceSummary(), PrintLedger() Changed IIf to IFF
'            dblRound():
'            - Replaced IsNagative% with NumSign$
'            - The negative sign is now removed from the Target number by using Mid$ rather than by Abs function. The abs function
'              voluntarily rounds the Target number in certain condition. E.g. Abs(2.444999999999999) will result in 2.445
'              This has an undesirable effect if we want to round the figure to 2 dec places. In the above example, we will end
'              up with 2.45 instead of 2.44
'12Apr02 TH  EnterInvandpay: Moved kbd sets into loop and trim inputted invoice number (#53708)

'01Jun02 All/CKJ Added Option explicit and corrected resulting problems
'                PrintDisputeNotes, PrintLedger: corrected fileno to filno
'                PrintDisputeNotes: corrected edittype to tmpEditType
'04Jun03 TH  DirectEntry: Added mask on qty entry box to prevent non-numeric entry being written to disk (#)
'28Jan04 TH  printledger: FinEditOrd: InvoiceSummary: Added set of new ord date fields
'31Mar04 CKJ {SP1}
'            Unused procs moved to .\old\finanasc.rem
'19Apr04 TH  MonthEndDiscount: Allow only numeric entries for value of credit note  (#60060)
'19Apr04 TH  DisplayOrder: added mod to hide price for UMMC
'13May04 CKJ PrintLedger: alternative collation sequence \winord.ini [defaults] CodingSlipsInSupplierOrder="Y" default ="N"


'------ V10 Consolidation : Welcome to our new world (looks like the old one I know, but keep the faith !!)


'29Aug08 TH  InvoiceSummary: (F0015785) Existing carriage being added at * 100 (its pence not pounds)
'10Sep08 TH  PrintLedger: (F0033030) Removed the fenceposts , sorry
'29Mar09 TH  FinEditOrd: Ensure todays date is used for credit adjustments. Merged from version 8 (F0013564)
'23Apr09 TH  FinEditOrd: Added extra check on invoice number and go and collect were necessary (F0047271)
'22Jul09 TH  EnterInvandpay: Ported Invoice date check from v8 (F0030601) RCNP0007
'20Aug09 PJC PrintDisputeNotes: ledcode is now trimmed (F0050136)
'25Nov09 TH  InvoiceSummary: (F0070364) Reinstated above as in fact it is in pounds EXCEPT for when previously entered on this order.
'    "                       This has now been fixed correctly - apologies to John as it wasnt as bad as thought (until I "fixed" it)
'04Feb10 TH  EnterInvandpay: Changed invoice date mask to 10 chars  (F0070774)
'07Jan10 CKJ corrected use of OTblMaxCols and the associated lines() array
'22Jan10 CKJ EnterInvAndPay: Corrected k.max for invoice date entry (F0070774 and F0051666)
'14Apr10 TH  ReconciliationThreshold: Ported from V8 (F0056463)
'14Apr10 TH  FinEditOrd: (F0056463) Ported Reconciliation threshold functionality
'02Nov10 AJK DirectEntry: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK FinEditOrder: F0086901 Added date invoiced to OrderLog calls and moved ord.paydate assignment to make it useful to orderlog write
'02Nov10 AJK MonthEndDiscount: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK StockValAdjust: F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Changed DefInt to DefBool and added 'as integer' to sitenumber param in DirectEntry, MonthEndDiscount, StockValAdjust
'25Aug11 TH  InvoiceSummary: Added decimal/numeric masking on carriage and discount screens (TFS 10905)
'27Jun13 TH  StockValAdjust: Ensure stock values sre correctly logged (TFS 67262)
'29Sep15 TH  DisplayCreditInfo: Tidied up cursor handling and tried to get the correct supplier details on caption where possible (TFS 127190)
'06Feb16 TH  FinEditOrd: Support for HUB Invoicing - largely ability totrack manual invoicing of failed electronic HUB uploads (TFS 138638)
'26Jul16 XN  FinEditOrd: Added EDIProductIdentifier to call to SetMediateItemArchivable
'06Dec16 TH  PrintDisputeNotes: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  PrintLedger: Replaced RTF Handling (TFS 157969)


'ideas
'/array holding all reconciliations in one session for display/in dispute
'/lookup page by invoice #
'/lookup other sites databases
'/running total during reconciliation
'/display of just reconciled
'/pre reconciliation totals to be displayed
' discount 1% => show more figs on updateprice
' allow VAT to be tweaked if calced by other rounding methods
' add vat rate & vat content to orderlog & translog
'/paydate - full parsing
' share discount around products
'/in stock val adjust, share out gainslosses
' iss/ret at a specific price then ret/iss at current for
'  1 item
'  all in a month
'  within date range
'  " offering for confirmation
'/debug display of current/specific order
' indexing picking tickets
' F7 receiving with -ve stock
' check update of disp when store issues
'/check coding slips for Credits
' reasons file with editor & lookup
' is delord 4 needed somewhere?
'---------- requiring attention---------------
'Scoping of Sup                          - separate but OK
'Scoping of k                            - done
'Need to add œ to issue params           - done
'discounts                               - simple version done
'credit notes                            - done
'VAT                                     - done
'in dispute flag                         - done
'supplier name; add to edit page         - done
'  also extend address editing by 1 char - done
'address fields; add fullname            - done
' add status 2 orders to printcard       - N/A
'log the cost of transport               - done
'check credit reconciliation
'check credit ledger slips
'widen orderlog for exp date etc         - done
'
'ORDERS.ASC
'----------
'edittype=1  items for amending
'edittype=2  Items made into transord.txt but transmission not confirmed
'edittype=3  for receiving
'edittype=9  for returns to suppliers
'
'  status=1  Items in view/amend orders page
'  status=2  Items made into transord.txt but transmission not confirmed
'  status=3  Items waiting to be received
'  status=D  awaiting deletion
'  status=R  received, awaiting deletion
'
'RECONCIL.ASC
'------------
'edittype=4  for invoice reconciliation, all stages

'  status=4  awaiting reconciliation
'  status=7  reconciled but coding slip not printed
'  status=8  coding slip printed OK, awaiting cull
'  status=R  ready for culling
'
'REQUIS.ASC
'----------
'edittype=5  for requisition editing
'edittype=6  for requisition issuing
'edittype=7  items for delivery note printing
'edittype=8  items awaiting to be made into GRN file
'
'  status=M  issued but waiting for transmission via modem
'
'-----------------------------------------------------------------------------
'Orderlog type
'
'X= Delete an I or M ordered requisition
'N= Delete orders already raised (Never to be received)
'   also used when modem or FTU orders are reinstated without transmission
'   status 2 to 1
'F= When FTU order placed (edittype 2 goes to 3)
'O= Create a new order on orderers machine ord.supcode="INTER" for internal
'   and "MODEM" for modem orders or raise an internal or modem order
'R= Receive item
'E= Issue a return when delivery note printed
'I= When internal order placed (Buyer's end)
'D= When a direct order has been raised
'A= Adjust stock value
'S= Stock level adjustment
'K= Delete drug (Kill)
'M= Make a new drug
'C= Create a supplier
'T= Reconciliation transaction
'B= Balance of reconciliation
'+= Adding reconciliation item from old system
'V= VAT Rounding difference

DefBool A-Z
Option Explicit

'{SP1}
'Dim R As filerecord
'Dim recno&(21)                   'record number for current line
'Dim ordering$(21)                'ASC code for current line
'Dim supcopy As supplierstruct
'Dim td As dateandtime
'Dim dt As dateandtime

Dim dcopy As DrugParameters
Dim ord As orderstruct
Dim ordcopy As orderstruct
Dim Rtot%
Dim lastsupplier$
Dim Rptr&(), Rval$(), Rnsv$() ' hold items approved
Dim lastInvIncVAT!, lastinvtotal!
Dim paydate$
'17May01 JKU/ASC Added.
Dim ordCarriage As orderstruct  'Temporarily hold carriage record destined for orderlog Reconcil.v8 update.
Dim ordDiscount As orderstruct  'Temporarily hold discount record destined for orderlog Reconcil.v8 update.
Dim tmpFoundCarriage&           'Temporarily hold the carriage record number
Dim tmpFoundDiscount&           'Temporarily hold the discount record number

Function DblRound(TargetNum As Variant, DecPlaces%, AlwaysDown%) As Double

'NOTE: This is a generic function and if found OK, may need to be moved to the Core Library.

'17May01 JKU/ASC Written
'This function takes a number (variant) and returns a double in n decimal places as specified by DecPlaces%.
'The AlwaysDown% parameter specify whether or not DblRound should round all down. Specify 0 to round 5 up 4 down.
'Note: This function is only limited by the TargetNum data type.


'22Jun01 JKU/SF Amended. When 'E' is encountered in TargetNum, the whole number is returned. Also, the function now detects 'D'
'        in TargetNum. When 'D' is encountered, it returns the TargetNum.
'21Feb02 JKU - Changed IIf to IFF
'            - Replaced IsNagative% with NumSign$
'            - The negative sign is now removed from the Target number by using Mid$ rather than by Abs function. The abs function
'              voluntarily rounds the Target number in certain condition. E.g. Abs(2.444999999999999) will result in 2.445
'              This has an undesirable effect if we want to round the figure to 2 dec places. In the above example, we will end
'              up with 2.45 instead of 2.44

Dim TheNumber$                 'the number to work on
'Dim IsNegative%                'to flag whether the number is negative                         '21Feb02 JKU Removed
Dim NumSign$                                                                                    '21Feb02 JKU Added
Dim DecPointAt%                'where the decimal point is
Dim RoundFrom%                 'the position of the number following the number to round.
Dim intTestNum%                'the number to test whether strNum2Round needs incrementing
Dim strNum2Round$              'the affected number i.e. the number we have to increment by 1
Dim intNum2Round%              'the integer equivalent of strNum2Round$


   'Check if the number is negative
   'IsNegative% = IIf(Val(TargetNum) > 0, 0, -1)   21Feb02 JKU Removed
   'TheNumber$ = Trim(Str(Abs(TargetNum)))         21Feb02 JKU Removed because Abs function voluntarily round 2.199999999999999 to 2.2
   
   '21Feb02 JKU Replaced above with block. This will now ensure that 2.444999999999999 actually returns 2.44 instead of 2.45 for two dec places.
   TheNumber$ = Trim$(TargetNum)          'Use of Trim$ function will preserve the Target Number
   If Val(TargetNum) < 0 Then
         NumSign$ = "-"
         TheNumber$ = Mid$(TheNumber, 2)  'We strip the negative sign from the target number
      End If
   '---
   
   '22Jun01 JKU/SF Commented out and replaced. To prevent a zero being returned.
   'If InStr(TheNumber$, "E") > 0 Then Exit Function
   If (InStr(TheNumber$, "E") > 0) Or (InStr(TheNumber$, "D") > 0) Then
         DblRound = Val(TargetNum)
         Exit Function
      End If
   
   If InStr(TheNumber$, ".") = 0 Then
         'Force a decimal
         TheNumber$ = TheNumber$ & ".0"
      End If

   TheNumber$ = "0" & TheNumber$ & String$(DecPlaces%, "0") 'Padding with required number of zeroes to prevent crashing.
   DecPointAt% = InStr(1, TheNumber$, ".")
   
   'Now take the decimal point out so we can work on the number
   TheNumber$ = Mid$(TheNumber$, 1, DecPointAt% - 1) & Mid$(TheNumber$, DecPointAt% + 1)
   
   RoundFrom% = DecPointAt% + DecPlaces%
   intTestNum% = CInt(Mid$(TheNumber$, RoundFrom%, 1))
   
   If Not AlwaysDown% And intTestNum% > 4 Then
      'We do the following if rounding up is required. The 4 is 5 up 4 down.
      Do
         intNum2Round% = CInt(Mid$(TheNumber$, RoundFrom% - 1, 1)) + 1
         If intNum2Round% > 9 Then
            strNum2Round$ = "0"
            TheNumber$ = Mid$(TheNumber$, 1, RoundFrom% - 2) & strNum2Round$ & Mid$(TheNumber$, RoundFrom%)
            RoundFrom% = RoundFrom% - 1
         Else
            strNum2Round$ = Trim(Str(intNum2Round%))
            TheNumber$ = Mid$(TheNumber$, 1, RoundFrom% - 2) & strNum2Round$ & Mid$(TheNumber$, RoundFrom%)
            RoundFrom% = 0
         End If
      
      Loop While RoundFrom% > 0
   End If
   
   'Now put the decimal back in
   TheNumber$ = Mid$(TheNumber$, 1, DecPointAt% - 1) & "." & Mid$(TheNumber$, DecPointAt%)
   
   'Apply user request
   TheNumber$ = NumSign$ & Mid$(TheNumber$, 1, DecPointAt% + DecPlaces%)
   
   DblRound = CDbl(TheNumber$)


End Function

Sub DirectEntry(SiteNumber As Integer)
'29Dec97 EAC use stores drug description
' enter backlog of reconciliation data
'04Jun03 TH Added mask on qty entry box to prevent non-numeric entry being written to disk (#)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitenumber param

Dim title$, msg$, NSV$, desc$, pform$, packs$, OK  As Integer, supcode$, ans$, recdate$, valid As Integer, Value$, pointer&  '01Jun02 All/CKJ ' foundsup As Integer
Dim blnFound As Integer  '01Jun02 ALL/ATW
Dim lngFoundSup As Long

   title$ = "Direct Entry of Reconciliation Data"
   '03Nov05 TH (#84229)
   'If InStr(1, UCase$(g_Command), "DIRECTRECONCIL", vbTextCompare) = 0 Then
   '   popmessagecr title$, "You are not authorised to use this functionality"
   '   Exit Sub
   'End If
   
   blankorder ord
   msg$ = " This must only be used to create reconciliation entries" & cr
   msg$ = msg$ + " for goods which were not ordered or received in Pharmacy."
    
   popmessagecr title$, msg$
   
   NSV$ = ""
   EnterDrug NSV$, "Direct Entry"
   If Not k.escd Then
      findrdrug NSV$, True, d, False, blnFound, False, False, False
      If blnFound Then
         desc$ = d.drugDescription      ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         pform$ = LCase$(Trim$(d.PrintformV))
         packs$ = " x " + Trim$(d.convfact) + " " + pform$
         ord.Code = d.SisCode
      Else
         k.escd = True
      End If
   End If

   If Not k.escd Then
      OK = False
      Do
         supcode$ = ""
         asksupplier supcode$, 0, "ES", "Enter Supplier Code", False, sup, False '15Nov12 TH Added PSO param
         getsupplier supcode$, False, lngFoundSup, sup
         If lngFoundSup = 0 Then popmessagecr "!n!iWarning", "Supplier code '" + supcode$ + "' not found"
      Loop Until lngFoundSup > 0 Or k.escd
      ord.supcode = supcode$
   End If

   If Not k.escd Then
      title$ = "Direct Reconciliation"
      msg$ = "Enter quantity received"
      setinput 0, k
      k.Max = 6
      k.helpnum = 0
      ans$ = ""
      k.nums = True
      k.decimals = True    '   "
      inputwin title$, msg$, ans$, k
      ord.received = ans$
      k.nums = False
      k.decimals = False
      If Val(ans$) = 0 Then k.escd = True
   End If

   If Not k.escd Then
      msg$ = "  Enter date received (ddmmyy)      "
      setinput 0, k
      k.Max = 6
      k.min = 1
      k.helpnum = 0
      ans$ = ""
      inputwin title$, msg$, ans$, k
      parsedate ans$, recdate$, "3", valid
      If Not valid Then
         popmessagecr "!n!iDate received", "An invalid date was entered."
         k.escd = True
      Else
         ord.recdate = recdate$
      End If
   End If

   If Not k.escd Then
      msg$ = "Enter value of goods at receipt (" & money(5) & ")"
      setinput 0, k
      k.Max = 8
      k.helpnum = 0
      Value$ = ""
      inputwin "", msg$, Value$, k
      If Val(Value$) <= 0 Then k.escd = True
      ord.cost = Trim$(Str$(100! * Val(Value$) / Val(ord.received)))
      popmessagecr title$, "Cost per unit or box " & money(5) & Format$(Val(ord.cost) / 100!, "#.00")
   End If

   If Not k.escd Then
      msg$ = "accept these details. "
      ans$ = ""
      setinput 0, k
      k.helpnum = 0
      Confirm title$, msg$, ans$, k
      If ans$ = "Y" Then       ' do transaction
         ord.status = "4"   ' received awaiting reconciliation
         ord.outstanding = "0"
         ord.orddate = ord.recdate
         ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
         ord.qtyordered = ord.received
         ord.num = "0000"
         Edittype = 4
         pointer& = PutOrder(ord, 0, "WReconcil") 'zero forces insert
         'Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate, ord.received, ord.received, ord.cost, ord.supcode, "+", SiteNumber, "", d.vatrate, "", "", "" '14Jan94 CKJ VAT
         'Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate, ord.received, ord.received, ord.cost, ord.supcode, "+", SiteNumber, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
         Orderlog ord.num, ord.Code, UserID$, ord.orddate, ord.recdate, ord.received, ord.received, ord.cost, ord.supcode, "+", SiteNumber, "", d.vatrate, "", "", "", "", ord.PSORequestID '03Mar14 TH Added PSORequestID
      End If
   End If
   blankorder ord

End Sub

Sub DisplayReconcilInfo(ByVal blnPSO As Boolean)
'05May98 CKJ Added second line of information
'03Sep13 TH Added PSO Param (TFS 42773)

Dim dat$, valid%
Dim lines() As String
Dim intloop As Integer
Dim blnLclPSO As Boolean

   Edittype = 4
   osite$ = "A"
   enterorder Edittype, False, blnPSO '03Sep13 TH Added PSO Param (TFS 42773)

   If Not k.escd And ordernum$ <> "A" Then '22Mar93 CKJ added ordernum
      'Now we need to check this is a valid order or not
   
      If Not InvoicableOrder(Val(ordernum$), True, blnPSO) Then '03Sep13 TH Added PSO Param (TFS 42773)
         popmessagecr "", "There are no items awaiting reconciliation for order number " & Trim$(ordernum$)
         k.escd = True
      Else
         '11Aug05 TH Added look up to get supplier and pass this through for information
         enterinvandpay paydate$, invoicenum$, ordernum$
      End If
   End If
   
   Screen.MousePointer = HOURGLASS

   If Not k.escd Then
      blnLclPSO = blnPSO
      ChangeTable "blank", blnPSO '14Aug12 TH Added Param  '01Nov05 Th Added
      blnPSO = blnLclPSO
      
      Clearprintedorders
      DisplayOrders Edittype, blnPSO  '03Sep13 TH Added PSO Param (TFS 42773) '27Jun11 CKJ Removed unused args: ordernum$, , osite$, SiteNumber%, paydate$, invoicenum$, OASCcode$(), ORecNo&(), Oordering$()
      'MainScreen.LblGrid.Caption = "Invoice Reconciliation"
      MainScreen.LblGrid.Caption = Iff(blnPSO, "Patient Specific ", "") & "Invoice Reconciliation" '03Sep13 TH Added PSO Caption (TFS 42773)
      If Trim$(UCase$(ordernum$)) <> "A" Then
         MainScreen.LblGrid = MainScreen.LblGrid & " for Order #" & ordernum$
         parsedate paydate$, dat$, "dd mmm ccyy", valid                            '05May98 CKJ Added
         MainScreen.LblGrid = MainScreen.LblGrid & cr & "Invoice Number: " & invoicenum$ & "   For: " & Iff(valid, dat$, "date not specified") '05May98 CKJ Added
      End If
      PositionLblGrid
      MainScreen.lvwMainScreen.Visible = True
      MainLVWHighlightSingleRowByIndex 1
      MainScreenSetTextAndPanels Edittype
      MainScreen.lvwMainScreen.SetFocus
   End If

   Screen.MousePointer = STDCURSOR

End Sub

Sub EnterCreditNote(creditnote$)

Dim title$, msg$, ans$    '01Jun02 All/CKJ

   title$ = "Credit Note"
   msg$ = "Enter credit note number"
   setinput 0, k
   'k.nocrlf = True
   k.Max = 12
   k.min = 1
   creditnote$ = ""
   inputwin title$, msg$, ans$, k
   If Not k.escd Then creditnote$ = ans$

End Sub

Sub enterinvandpay(paydate$, invoicenum$, ByVal strOrderNum As String)
'--- Enter invoice number ---
'22Apr93 CKJ Added carriage & discount
'15Jan94 CKJ Removed " & "
'20Feb94 CKJ Parsedate
'16Nov98 TH  Picks up date 'phrase' from winord.ini
'11Jan02 TH  Added check to stop only spaces being used in invoicenumber entry (#53708)
'12Apr02 TH  Moved kbd sets into loop and trim inputted invoice number (#53708)
'14Oct05 TH  Use storesparsedate now as this will NOT accept zero days or no days entered
'22Jul09 TH  Ported Invoice date check from v8 (F0030601) RCNP0007
'04Feb10 TH  Changed invoice date mask to 10 chars  (F0070774)

Dim title$, msg$, paydat$, valid As Integer, temp$, done As Integer '01Jun02 All/CKJ
Dim intYear As Integer '04Aug09 TH Added

   title$ = "Invoice Reconcilation"
   msg$ = "Enter invoice number"
   'setinput 0, k       '12Apr02 TH Moved into loop below
   'k.escd = False      '   "
   'k.max = 12          '   "
   'k.min = 1           '   "
   invoicenum$ = ""
   Do While (Not k.escd And Trim$(invoicenum$) = "")                                '11Jan02 TH Added to stop spaces being used (#53708)
      setinput 0, k        '12Apr02 TH Moved inside loop
      k.escd = False       '   "
      'k.Max = 12           '   "
      k.Max = 20           '   "
      k.min = 1            '   "
      inputwin title$, msg$, invoicenum$, k
      If Trim$(invoicenum$) = "" And Not k.escd Then                                '    "
         popmessagecr "!n!iWarning", "Blank Invoice Number is an Invalid Entry"  '    "
         invoicenum$ = ""                                                        '    "
      End If                                                                     '    "
   Loop
   invoicenum$ = Trim$(invoicenum$)  '12Apr02 TH Added after testing  (#53708)
   If Not k.escd Then
   
      '(#81586) Get the order - if it exists then use the order date as a boundary
      ''strParams =
   
      Do
         'Read inifile setting for correct phraseology                                   '16Nov98 TH
         msg$ = ReadPrivateIniFile(dispdata$ & "\winord.ini", "Invoices", "DateMessage") '16Nov98 TH
         If msg$ = "" Then msg$ = " date to be paid "                                    '16Nov98 TH
         msg$ = "Enter " & msg$ & " dd/mm/yyyy"                                          '16Nov98 TH
         frmEnhTxtWin.Check1.Value = 1                                                   '02Feb99 TH Set check for session
         'msg$ = "Enter date to be paid  dd/mm/yyyy"        '03May98 CKJ Y2K
         setinput 0, k
         'k.Max = 10
         'k.Max = 9 '24Nov05 TH Altered
         k.Max = 10 '04Feb10 TH Added (F0070774)
         
         Storesparsedate paydate$, paydat$, "1", valid           'dd/mm/yyyy
         'If Not (valid And paydate$ = paydat$) Then
         '   paydat$ = ""
         'End If
         inputwin title$, msg$, paydat$, k
         'paydate$ = paydat$
         If Not k.escd Then
            'parsedate paydat$, temp$, "4", valid       'ddmmyy
            ''parsedate paydat$, temp$, "3", valid        '03May98 CKJ Y2K ddmmyyyy
            Storesparsedate paydat$, temp$, "3", valid
            If valid Then
               If paydate$ = temp$ Then done = True
               paydate$ = temp$
            Else
               'popmessagecr "RE-ENTER", "Incorrect date entered"
               BadDate
            End If
            
            '22Jul09 TH Ported from v8 (F0030601) RCNP0007
            If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Invoices", "Y", "CheckInvoiceYear", 0)) = True Then     '15Jan07 PJC Added check on the year. (#88163)
               intYear = Val(TxtD(dispdata$ & "\winord.ini", "Invoices", "1900", "InvoiceYear", 0))            '        "
               If Val(Right$(temp$, 4)) < intYear Then                                                                                                                                                      '           "
                     done = False                                                                                                                                                                           '           "
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Invoices", "Y", "ShowInvoiceYearMsg", 0)) = True Then                                                                                    '           "
                           popmessagecr "!n!i" & title$, TxtD(dispdata$ & "\winord.ini", "Invoices", "Invoice Date entered is earlier than minimum year: ", "InvoiceYearMsg", 0) & Format$(intYear)         '           "
                        End If                                                                                                                                                                              '           "
                  End If                                                                                                                                                                                    '           "
            End If                                                                                             '        "
            '---------
         End If
         If valid Then
            'Run the nex checks here
            
         End If
      Loop Until done Or k.escd
   End If

   If Not k.escd And 0 = 1 Then   '!!** disabled at the moment             {SP2} not executable
      'printw " Enter discount (as percentage)  "
      'k.max = 4
      'k.decimals = True
      'k.begline = True
      'k.wipedef = True
      'discountrate! = 0
      'ans$ = trim$(Str$(discountrate!))
      'inputline ans$, k
   End If

End Sub

Sub FINANASC(mnuans$, ByVal blnPSO As Boolean)
'03Sep13 TH Added PSO Param (TFS 42773)

Dim finished As Integer, prog$     '01Jun02 All/CKJ

   k.exitval = 13
   k.escd = False
   Rtot = 0                         ' tot num approved for reconciliation
   ReDim Rptr&(Rtot), Rval$(Rtot), Rnsv$(Rtot) ' hold items approved

   k.HelpFile = "ordermnu.hlp"

''   If Not fileexists(dispdata$ + "\supfile.idx") Then         '!! remove?
''         savesupidx
''         sortindex "", dispdata$ + "\supfile.idx"
''      End If

   Select Case k.exitval
      Case 13   ' Return
         Select Case mnuans$
            Case "1" 'Invoice reconciliation
               Select Case Storepasslvl
                  Case 4, 5, 8
                     DisplayReconcilInfo blnPSO '03Sep13 TH Added PSO Param (TFS 42773)
                  Case Else
                     nopass
                  End Select
      
            Case "2"      'Print coding slips
               Select Case Storepasslvl
                  Case 4, 5, 8:
                     ChangeTable "Blank", False '14Aug12 TH Added Param
                     Screen.MousePointer = HOURGLASS
                     printledgerSQL
                     Screen.MousePointer = STDCURSOR
                  Case Else: nopass
                  End Select
      
            Case "3"
               Select Case Storepasslvl
                  Case 4, 5, 8
                     DisplayCreditInfo
                  Case Else
                     nopass
                  End Select
         
            Case "4"
               Select Case Storepasslvl
                  Case 4, 5, 8:
                     ChangeTable "Blank", False '14Aug12 TH Added Param
                     MonthEndDiscount (SiteNumber)
                  Case Else: nopass
                  End Select
   
            Case "5"
               Select Case Storepasslvl
                  Case 4, 5, 8:
                     ChangeTable "Blank", False '14Aug12 TH Added Param
                     StockValAdjust (SiteNumber)
                  Case Else: nopass
                  End Select
   
            Case "6"   ' enter backlog of reconciliation data
               If Storepasslvl = 9 Then
                     ChangeTable "Blank", False '14Aug12 TH Added Param
                     DirectEntry SiteNumber
                  Else
                     nopass
                  End If
   
''            Case "7"                 '{SP2} remove facility?
''               finished = True
''               prog$ = orderpath$ + "\StoreASC"

            End Select
      End Select

End Sub

Sub FinEditOrd()
'29Mar09 TH Ensure todays date is used for credit adjustments. Merged from version 8 (F0013564)
'23Apr09 TH Added extra check on invoice number and go and collect were necessary (F0047271)
'14Apr10 TH (F0056463) Ported Reconciliation threshold functionality
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls and moved ord.paydate assignment to make it useful to orderlog write
'06Feb16 TH Support for HUB Invoicing - largely ability totrack manual invoicing of failed electronic HUB uploads (TFS 138638)

'edittype=1  for amending
'edittype=3  for receiving
'edittype=4  for invoice reconciliation   <== only used in this module
'edittype=-4 for credit note reconciliation   <== only used in this module
'edittype=5  for requisition editing
'edittype=6  for requisition issuing

ReDim lines$(OTblMaxCols + 1)
Dim Numoflines%, edtype%, credit%, loopvar As Long   ', NoneFound%  '27JUn11 CKJ loopvar was integer
Dim OlogVatTemp%, RndAdjust#                '24Feb98 EAC Added    30Oct98 EAC RndAdjust! -> RndAdjust#
Dim numofords&
Dim temp#
Dim sislistprice$, sListPrice$()
Dim GoodsExVAT!, GoodsIncVAT!, GoodsVAT!    '30Jun01 JKU Added for penny rounding fix
Dim nummarked As Integer, foundorder&, foundPtr As Long, costperpack!, qtyrec$, purprice$, linevalue!, reconciltxt$, InvoiceTotal!  '01Jun02 All/CKJ '01Jun02 ALL/ATW
'27Jun11 CKJ removed newscreen  As Integer, samepage  As Integer
Dim title$, ans$, msg$, count As Integer, adjust!, daterec$, qtyord$, rectype$, baltype$
Dim strTitle As String
Dim strMsg As String
Dim lclsup As supplierstruct '05Feb16 TH Added

   credit = Sgn(Edittype)
   edtype = Abs(Edittype)
   lastsupplier$ = ""
   
   clearsup lclsup '05Feb16 TH Added

   If Not MainLVWAreAnySelected() Then  '02Jun11 CKJ replaces block above
      popmessagecr "#ERROR", "No drugs selected." & Chr$(13) & Chr$(13) & "Double Click the drugs with the Left Mouse Button."
      k.escd = True
      Exit Sub
   End If

   setinput 0, k

   If edtype <> 4 Then
      popmessagecr "ERROR", "Entered FinEditOrd with edittype = " + Str$(Edittype)
      Exit Sub
   End If
                    
   If ordernum$ = "A" Then ' Can't reconcile until specific order entered
      popmessagecr "#ERROR", "Cannot reconcile until a specific order number is entered."
      k.escd = True
   End If
   
   If Trim$(invoicenum$) = "" Then enterinvandpay paydate$, invoicenum$, Format$(ord.num) '23Apr09 TH (F0047271)
   
   If Not k.escd Then 'if1
      lastinvtotal! = 0
      lastInvIncVAT! = 0
      nummarked = 0
      For loopvar = 1 To ONumToDisplay
         'If (Not k.escd) And OMarked(loopvar) Then 'if2                    '02Jun11 CKJ
         If (Not k.escd) And MainLVWIsItemSelected(loopvar) Then 'if2       '   "
            nummarked = nummarked + 1
            deflines OInfoStore(loopvar), lines$(), "|(*)", 1, Numoflines
            foundorder& = Val(lines$(OTblMaxCols + 1))
            d.SisCode = Trim$(lines$(1))
            getdrug d, 0, foundPtr&, False

            If (foundorder& <> 0) And (foundPtr& <> 0) Then     'if3
               getorder ord, (foundorder&), edtype, False
               If foundorder& > 0 And ord.status = "4" And Val(ord.num) = Val(ordernum$) And Sgn(Val(ord.qtyordered)) = credit Then 'if5
                  '05Feb16 TH We need to get the supplier here to differentiate HUB invoices ???
                  If Trim$(lclsup.Code) = "" Then getsupplier ord.supcode, 0, 0, lclsup
                  
                  getorder ord, foundorder&, edtype, True    '<----LOCK (no idx)
                  costperpack! = Val(ord.cost)
                  qtyrec$ = ord.received
                  '25Mar97 EAC Mediate Link - display any info from the Mediate database to aid reconciliation
                  
                  If ord.internalmethod = "E" Then
                     If lclsup.Method = "H" Then   '16Feb16 TH HUB (TFS 138638)
                        DisplayHUBExtraInfo ord    '  "
                     Else
                        DisplayEDIExtraInfo ord
                     End If
                  End If
                  '---
                  updateprice credit * 4, d.SisCode, qtyrec$, ord, purprice$, False, sislistprice$, strTitle, strMsg, 0, "", "", "", 0 '04Aug09 TH Added param
   
                  '30Jun01 JKU The existing code will modify the reconcil.v8 and associated files.
                  '        The lastinvtotal! and lastInvIncVAT! have been declared as shared variable in
                  '        declaration part of this module. The invoiceSummary function uses these variables
                  '        to work out the invoice VAT amount to display in the invoice summary screen.
                  '        Therefore, it makes sence to calculate the ord.VATAmount on the same basis here.
                     
                  If Not k.escd Then 'if4
                     linevalue! = Val(purprice$) * Val(qtyrec$)
                     linevalue! = DblRound(linevalue!, 0, 0)   'Get rid of fraction of a penny
                     lastinvtotal! = lastinvtotal! + linevalue!
                     'store VAT rate
                     ord.VATRateCode = d.vatrate
                     ord.VATRatePCT = CStr(VAT(Val(d.vatrate)))
                     GoodsIncVAT! = linevalue! * VAT(Val(d.vatrate))
                     GoodsIncVAT! = DblRound(GoodsIncVAT!, 0, 0)
                     lastInvIncVAT! = lastInvIncVAT! + GoodsIncVAT!
                     GoodsIncVAT! = GoodsIncVAT! / 100
                     GoodsIncVAT! = DblRound(GoodsIncVAT!, 2, 0)
                     ord.VATInclusive = Format$(GoodsIncVAT!)
                     GoodsExVAT! = linevalue! / 100
                     GoodsExVAT! = DblRound(GoodsExVAT!, 2, 0)
                     GoodsVAT! = GoodsIncVAT! - GoodsExVAT!
                     GoodsVAT! = DblRound(GoodsVAT!, 2, 0)
                     ord.VATAmount = Format$(GoodsVAT!)
                     lastsupplier$ = ord.supcode
                     Rtot = Rtot + 1
                     ReDim Preserve Rptr&(Rtot), Rval$(Rtot), Rnsv$(Rtot), sListPrice$(Rtot)
                     Rptr&(Rtot) = foundorder&
                     Rval$(Rtot) = purprice$
                     Rnsv$(Rtot) = ord.Code
                     sListPrice$(Rtot) = sislistprice$
                     ord.invnum = invoicenum$
                     ord.paydate = "--------"
                  End If 'if4
                  foundorder& = PutOrder(ord, foundorder&, "WReconcil")                  '<----UNLOCK (no idx)
                  'k.escd = False
               End If 'if5
            End If 'if3
         End If 'if2
      Next
    
      If (Not k.escd) And Rtot Then
         InvoiceSummary Edittype, ordernum$, paydate$, invoicenum$, reconciltxt$, InvoiceTotal!
         title$ = "Summary for Invoice No " + Trim$(invoicenum$) & Space$(15)
         ans$ = Format$(Str(InvoiceTotal!), "#0.00;-#0.00")
         msg$ = reconciltxt$ & Chr(13) & Chr(13) & "Enter gross amount (after carriage and"
         msg$ = msg$ & Chr(13) & "discounts), if this is different to above."
         msg$ = msg$ & Chr(13) & "NB: Differences are deemed to be on " & money(9) & "."
         
         Do                                                                 '14Apr10 TH (F0056463) Ported 21Sep05 PJC Moved loop from below to include the setting of k structure.
            setinput 0, k
            k.escd = False
            k.Max = 9
            k.min = 1
               
            k.decimals = True
            On Error Resume Next
            frmTxtWin.lblbox.FontName = "Courier"
            If Err Then           '     "
               Err = 0         '     "
            End If             '     "
            On Error GoTo 0       '     "
            frmTxtWin.Tag = "reconcil"
            inputwin title$, msg$, ans$, k
            frmTxtWin.Tag = ""

            'Exits the loop if the input window is cancelled.
            'If k.escd  Then                 '14Apr10 TH Ported 21Sep05 PJC  Added Not k.timd
            If k.escd And Not k.timd Then    '  "
                     Exit Do
               End If
         Loop While ReconcilThreshold(InvoiceTotal!, ans$) = False

         If Not k.escd Then
            For count = 1 To Rtot
               getorder ord, Rptr&(count), edtype, True    '<-- LOCK (no idx)
               If ord.status <> "4" Or Val(ord.num) <> Val(ordernum$) Or Trim$(ord.invnum) <> invoicenum$ Or ord.Code <> Rnsv$(count) Then
                  Rptr&(count) = PutOrder(ord, Rptr&(count), "WReconcil") '01Jun06 TH Unlock.
                  popmessagecr "!n!iWARNING: Reconciliation halted", "Item " + Rnsv$(count) + " has been altered from another terminal"
                  
               'End If '01Jun06 TH !!! SO WHY DO WE CONTINUE !!! ARRRRGHHH!
               Else    '           replaced above
                  purprice$ = Rval$(count)
   
                  d.SisCode = ord.Code
                  'getdrug d, 0, found, True     '<== LOCK DRUG
                  getdrugsup d, 0, foundPtr&, True, ord.supcode
                  adjust! = ((Val(purprice$) - Val(ord.cost)) * Val(ord.received))
                  d.lastreconcileprice = purprice$
                  If Trim$(sListPrice$(count)) <> "" Then d.sislistprice = Trim$(sListPrice$(count))
                  If Val(ord.cost) <> Val(purprice$) Then adjustissueprice d, adjust! * credit
                  daterec$ = thedate(False, True)
                  'strTimeRec = thedate(0, -2)
                  qtyord$ = ord.outstanding
                  qtyrec$ = ord.received
                  rectype$ = "T"
                  baltype$ = "B"
                  If credit = -1 Then
                      qtyord$ = Str$(-Val(ord.outstanding))
                      qtyrec$ = Str$(-Val(ord.received))
                      adjust! = -adjust!
                      rectype$ = "H"
                      baltype$ = "L"
                  End If
   
                  '02Nov10 AJK F0086901 Moved from below
                  If credit = -1 Then
                     ord.paydate = Format$(Now, "ddmmyyyy")
                  Else
                     ord.paydate = paydate$
                  End If
   
                  putdrug d  '20Jun13 TH Moved from below. This is because the changes in value need to be reflected in the log below (TFS )
                  'Orderlog ord.num, ord.code, userid$, ord.orddate, daterec$, qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, sitenumber, invoicenum$, d.vatrate '14Jan94 CKJ VAT 'ord.supcode replaces ownname$ 17.03.92 ASC '15Jan02 TH Added time (#53214)
                  ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$ & thedate(0, -2), qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, invoicenum$, d.vatrate                                              '    "
                  'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, invoicenum$, d.vatrate, "", "", ""                                             '    "
                  'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, invoicenum$, d.vatrate, "", "", "", ord.paydate '02Nov10 AJK F0086901 Added paydate
                  Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, purprice$, ord.supcode, rectype$, SiteNumber, invoicenum$, d.vatrate, "", "", "", ord.paydate, ord.PSORequestID '03Mar14 TH Added PSORequestID
                  If Abs(adjust!) >= 0.0001 Then
                     'Orderlog ord.num, ord.code, userid$, ord.orddate, daterec$, qtyord$, qtyrec$, LTrim$(Str$(Adjust!)), ord.supcode, baltype$, sitenumber, invoicenum$, d.vatrate '14Jan94 CKJ VAT 'ord.supcode replaces ownname$ 17.03.92 ASC  '15Jan02 TH Added time (#53214)
                     ''Orderlog ord.num, ord.Code, UserID$, ord.orddate, daterec$ & thedate(0, -2), qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, invoicenum$, d.vatrate                                               '    "
                     'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, invoicenum$, d.vatrate, "", "", ""                                              '    "
                     'Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, invoicenum$, d.vatrate, "", "", "", ord.paydate '02Nov10 AJK F0086901 Added paydate
                     Orderlog ord.num, ord.Code, UserID$, ord.orddate & ord.ordtime, daterec$ & thedate(0, -2), qtyord$, qtyrec$, LTrim$(Str$(adjust!)), ord.supcode, baltype$, SiteNumber, invoicenum$, d.vatrate, "", "", "", ord.paydate, ord.PSORequestID  '03Mar14 TH Added PSORequestID
                  End If
                  ord.status = "7"
                  ord.cost = purprice$
                  ord.invnum = invoicenum$
                  '02Nov10 AJK F0086901 Moved above orderlog entry
'                  If credit = -1 Then
'                     ord.paydate = Format$(Now, "ddmmyyyy")
'                  Else
'                     ord.paydate = paydate$
'                  End If
                  ord.Reconciledate = Format$(Now, "ddmmyyyy")  '28Jan04 TH Added
                  If Trim$(ord.Indispute) <> "" Then
                     ord.IndisputeUser = UserID$
                  End If
   
                  'putdrug d, foundPtr&               '<== UNLOCK DRUG  '01Jun02 ALL/ATW
                  ''putdrugSQL d, foundPtr&
                  'putdrug d  '20Jun13 TH Moved above (TFS )
                  InitAltSupplier
                  Rptr&(count) = PutOrder(ord, Rptr&(count), "WReconcil")     '<-- UNLOCK (no idx)
                  If ord.internalmethod = "E" Or ord.internalmethod = "V" Then   '06Jul11 CKJ Removed menu enabled clauses because they were always enabled (but not visible)
                     'We will need to differentiate here whether the supplier is EDI od HUB ???
                     If lclsup.Method = "H" Then '06Feb16 TH HUB (TFS 138638)
                        SetHUBItemArchivable ord.Code, ord.num, d.barcode, d.EDILinkCode  '06Feb16 TH HUB (TFS 138638)
                     Else
                        'SetMediateItemArchivable ord.Code, ord.num, d.barcode, d.EDILinkCode    '15Jul98 EAC make sure Mediate or Texsol is actually used '27May10 AJK F0061692 Added EDILinkCode
                        SetMediateItemArchivable ord.Code, ord.num, d.barcode, d.EDILinkCode, ord.EDIProductIdentifier   '22Jul16 XN Added 126634 EDIProductIdentifier '15Jul98 EAC make sure Mediate or Texsol is actually used '27May10 AJK F0061692 Added EDILinkCode
                     End If
                  End If
                  
               End If '01Jun06 TH Added
            Next
            '17May01 JKU/ASC Added. We now write the orderlog and reconcil.v8 files. This was originally done in Invoice Summary function.
            If Trim(ordCarriage.Code) <> "" Then
               'Update Carriage
               ''Orderlog ordCarriage.num, ordCarriage.Code, UserID$, ordCarriage.orddate, ordCarriage.recdate, "1", "1", ordCarriage.cost, ordCarriage.supcode, "T", SiteNumber, ordCarriage.invnum, ordCarriage.VATRateCode ' extra carriage
               'Orderlog ordCarriage.num, ordCarriage.Code, UserID$, ordCarriage.orddate & ordCarriage.ordtime, ordCarriage.recdate , "1", "1", ordCarriage.cost, ordCarriage.supcode, "T", SiteNumber, ordCarriage.invnum, ordCarriage.VATRateCode ' extra carriage
               'Orderlog ordCarriage.num, ordCarriage.Code, UserID$, ordCarriage.orddate & ordCarriage.ordtime, ordCarriage.recdate & ordCarriage.rectime, "1", "1", ordCarriage.cost, ordCarriage.supcode, "T", SiteNumber, ordCarriage.invnum, ordCarriage.VATRateCode, "", "", "" '27Apr06 TH Added rec time
               'Orderlog ordCarriage.num, ordCarriage.Code, UserID$, ordCarriage.orddate & ordCarriage.ordtime, ordCarriage.recdate & ordCarriage.rectime, "1", "1", ordCarriage.cost, ordCarriage.supcode, "T", SiteNumber, ordCarriage.invnum, ordCarriage.VATRateCode, "", "", "", ord.paydate '02Nov10 AJK F0086901 Added paydate
               Orderlog ordCarriage.num, ordCarriage.Code, UserID$, ordCarriage.orddate & ordCarriage.ordtime, ordCarriage.recdate & ordCarriage.rectime, "1", "1", ordCarriage.cost, ordCarriage.supcode, "T", SiteNumber, ordCarriage.invnum, ordCarriage.VATRateCode, "", "", "", ord.paydate, ord.PSORequestID  '03Mar14 TH Added PSORequestID
               tmpFoundCarriage& = PutOrder(ordCarriage, tmpFoundCarriage&, "WReconcil")  '<= UNLOCK
            End If
            
            If Trim(ordDiscount.Code) <> "" Then
               'Orderlog ordDiscount.num, ordDiscount.code, userid$, ordDiscount.orddate, ordDiscount.recdate, "1", "1", ordDiscount.cost, ordDiscount.supcode, "B", sitenumber, ordDiscount.invnum, "0"                   '  "
               ''Orderlog ordDiscount.num, ordDiscount.Code, UserID$, ordDiscount.orddate, ordDiscount.recdate, "1", "1", ordDiscount.cost, ordDiscount.supcode, "T", SiteNumber, ordDiscount.invnum, ordDiscount.VATRateCode
               'Orderlog ordDiscount.num, ordDiscount.Code, UserID$, ordDiscount.orddate & ordDiscount.ordtime, ordDiscount.recdate, "1", "1", ordDiscount.cost, ordDiscount.supcode, "T", SiteNumber, ordDiscount.invnum, ordDiscount.VATRateCode
               'Orderlog ordDiscount.num, ordDiscount.Code, UserID$, ordDiscount.orddate & ordDiscount.ordtime, ordDiscount.recdate & ordDiscount.rectime, "1", "1", ordDiscount.cost, ordDiscount.supcode, "T", SiteNumber, ordDiscount.invnum, ordDiscount.VATRateCode, "", "", "" '27Apr06 TH Added rec time
               'Orderlog ordDiscount.num, ordDiscount.Code, UserID$, ordDiscount.orddate & ordDiscount.ordtime, ordDiscount.recdate & ordDiscount.rectime, "1", "1", ordDiscount.cost, ordDiscount.supcode, "T", SiteNumber, ordDiscount.invnum, ordDiscount.VATRateCode, "", "", "", ord.paydate  '02Nov10 AJK F0086901 Added paydate
               Orderlog ordDiscount.num, ordDiscount.Code, UserID$, ordDiscount.orddate & ordDiscount.ordtime, ordDiscount.recdate & ordDiscount.rectime, "1", "1", ordDiscount.cost, ordDiscount.supcode, "T", SiteNumber, ordDiscount.invnum, ordDiscount.VATRateCode, "", "", "", ord.paydate, ord.PSORequestID   '03Mar14 TH Added PSORequestID
               tmpFoundDiscount& = PutOrder(ordDiscount, tmpFoundDiscount&, "WReconcil")  '<= UNLOCK
            End If
            temp# = (Val(ans$) - InvoiceTotal!) * 100!
            temp# = temp# + (0.5 * Sgn(temp#))
            RndAdjust# = Fix(temp#)
            If Abs(RndAdjust#) >= 0.0001 Then
               'Need to turn OrderLogVat off so that no VAT is added to this transaction
               OlogVatTemp% = OrderLogVAT%
               OrderLogVAT% = False
               'Orderlog ord.num, NSVReconciliation$, userid$, "", daterec$, "", "", LTrim$(Str$(RndAdjust#)), ord.supcode, "V", sitenumber, invoicenum$, ""   '12Aug98 TH Added Psuedo Nsvcode to prevent corruption of orderlog
               'Orderlog ord.num, NSVReconciliation$, UserID$, "", daterec$ & thedate(0, -2), "", "1", LTrim$(Str$(RndAdjust#)), ord.supcode, "V", SiteNumber, invoicenum$, "", "", "", ""  '12Aug98 TH Added Psuedo Nsvcode to prevent corruption of orderlog
               'Orderlog ord.num, NSVReconciliation$, UserID$, "", daterec$ & thedate(0, -2), "", "1", LTrim$(Str$(RndAdjust#)), ord.supcode, "V", SiteNumber, invoicenum$, "", "", "", "", ord.paydate  '02Nov10 AJK F0086901 Added paydate
               Orderlog ord.num, NSVReconciliation$, UserID$, "", daterec$ & thedate(0, -2), "", "1", LTrim$(Str$(RndAdjust#)), ord.supcode, "V", SiteNumber, invoicenum$, "", "", "", "", ord.paydate, ord.PSORequestID  '03Mar14 TH Added PSORequestID
               OrderLogVAT% = OlogVatTemp%
               foundPtr& = 0                                                                                          '12Aug98 TH Code to add reconciliation differences'to orderstructure using nsvreconciliation$ as a '01Jun02 ALL/ATW
               If Len(Trim$(NSVReconciliation$)) = 7 Then LookupDrug NSVReconciliation$, d, foundPtr&                 'dummy drug identifier  '01Jun02 ALL/ATW
               If foundPtr& = 0 Then                                                                                  ' '01Jun02 ALL/ATW
                  msg$ = "The NSV code for posting Reconciliations has not been defined.  " & cr              '
                  msg$ = msg$ & "Please enter this in Utilities / Set Defaults,   " & cr                      '
                  msg$ = msg$ & "then enter it under drug maintenance as 'Invoice Reconciliation'.       "    '
                  popmessagecr "", msg$                                                                       '
                  k.escd = True                                                                               '
               Else                                                                                           '
                  ''getnumofords 4, numofords&, True   ' get a new order entry                                  '
                  ''getorder ord, numofords&, edittype, True    '<----LOCK (no idx)                             '
                  blankorder ord                                                                              '
                  ord.status = "7" ' Reconciled, waiting for coding slip printing                             '
                  ord.num = ordernum$                                                                         '
                  ord.Code = NSVReconciliation$                                                               '
                  ord.supcode = lastsupplier$ 'which was offered for reconciliation                           '
                  '29Mar09 TH Merged from version 8 (F0013564)
                  If credit = -1 Then                                                                      '15Jan07 PJC Set the Paydate to todays date for credit adjustments. (#71830)
                     ord.paydate = Format$(Now, "ddmmyyyy")                                                '         "
                  Else                                                                                     '         "
                     ord.paydate = paydate$                                                                '         "
                  End If                                                                                   '         "
                  'ord.paydate = paydate$                                                                      '
                  ord.Reconciledate = Format$(Now, "ddmmyyyy")
                  ord.invnum = invoicenum$                                                                    '
                  ord.qtyordered = Iff(Edittype = -4, "-1", "1")
                  ord.received = "1"                                                                          '
                  ord.outstanding = "0"                                                                       '
                  ord.orddate = thedate(False, True)
                  ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
                  ord.recdate = ord.orddate
                  ord.rectime = ord.ordtime
                  ord.cost = "0"
                  RndAdjust# = RndAdjust# / 100   'In £
                  ord.VATInclusive = Format$(Str(RndAdjust#), "#0.00;-#0.00")
                  ord.VATAmount = ord.VATInclusive
''                  updateordreqindex 4, "", ord.Code, "", ord.num, (numofords&)                                '
                  numofords& = PutOrder(ord, 0, "WReconcil")    'Force Insert                                                                '
               End If                                                                                         '
            End If                                                                                               '
            lastinvtotal! = 0
            lastInvIncVAT! = 0
            lastsupplier$ = ""
            k.escd = False
            '02Jun11 CKJ: ReDim OMarked(1 To ONumToDisplay)
            MainLVWRemoveSelection   '02Jun11 CKJ
         ElseIf ans$ = "N" And Not k.escd Then
            For count = 1 To Rtot
               getorder ord, Rptr&(count), edtype, True    '<-- LOCK (no idx)
               ord.paydate = ""
               Rptr&(count) = PutOrder(ord, Rptr&(count), "WReconcil")                  '<-- UNLOCK (no idx)
            Next
            lastinvtotal! = 0
            lastInvIncVAT! = 0
            lastsupplier$ = ""
            k.escd = True
         Else
            If MainScreen.lvwMainScreen.SelectedItem.Index > 0 Then
               '''For a = 1 To MainScreen.lvwMainScreen.ListItems.count               '   "
               '''   If OMarked(a) Then OMarked(a) = 0                  '   "
               '''Next                                                  '   "
            Else
               MainScreen.TxtInput.text = ""
            End If                                                   '   "
         End If
      Else
         k.escd = True 'SQL
         
         If Not MainLVWAreAnySelected() Then       '02Jun11 CKJ simplified
            MainScreen.TxtInput.text = ""
            popmessagecr "#Error", "No drugs marked for reconciliation"
         End If
      End If
   End If 'if1

   Rtot = 0
   ReDim Rptr&(Rtot), Rval$(Rtot), Rnsv$(Rtot)
           
End Sub

Sub InvoiceSummary(Edittype As Integer, ordernum$, paydate$, invoicenum$, reconciltxt$, InvoiceTotal!)
'NB Does NOT close window
'site & supplier missing
'
' 5Oct94 CKJ Corrected NSVdiscount$
' 9Feb95 CKJ Added confirm for carriage & discount
' 9Apr96 CKJ Corrected totals displayed when discount posted
'05Nov97 EAC Corrected adding of VAT to Reconciliation Total
'            Tidied up the InvoiceSummary dialog now that Tabs are
'            handled by MsgBox
'24Feb98 EAC Added InvoiceTotal! to subroutine parameters to allow total invoice cost to be passed back to calling routine
'30Oct98 EAC Correct display of total for credit notes
'08Jan99 SF  attempt to correct rounding errors that could occur
'17May01 JKU/ASC VAT on carriage now written to Reconcil.v8.
'            Writing of carriage record is now delayed until the user confirms that the Invoice Summary is OK.
'            Also fixed discount. Now discount is only written to file when user clicks OK in Invoice Summary window.
'            The VAT difference (on ASC000V) is now written to the VAT field instead of the cost field.
'17May01 JKU/SF Resolved minor bugs in carriage cost.
'31May01 TH/JKU Use getdrugsup for dummy carriage item. This can allow for different sales tax rates on different suppliers for carriage
'            by using supplier profiles on the dummy drug
'18Jun01 JKU/SF VAT on discount was not written to reconcil.v8 though written to orderlog. This is now rectified.
'30Jun01 JKU Penny rounding difference fix
'08Jul01 JKU/SF Now VAT on discount is written to the orderlog.
'21Feb02 JKU Changed IIf to IFF
'02Apr04 CKJ {SP1} removed unused param sitenumber
'            (edittype, sitenumber, ordernum$, paydate$, invoicenum$, reconciltxt$, InvoiceTotal!)
'29Aug08 TH  (F0015785) Existing carriage being added at * 100 (its pence not pounds John!!)
'25Nov09 TH  Reinstated above as in fact it is in pounds EXCEPT for when previously entered on this order.
'    "       This has now been fixed correctly - apologies to John as it wasnt as bad as thought (until I "fixed" it) (F0070364)
'25Aug11 TH  Added decimal/numeric masking on carriage and discount screens (TFS 10905)

Dim invVAT$    '08Jan99 SF added

'17May01 JKU/ASC Added
Dim CarriageVAT!  'Carriage VAT amount
Dim GoodsMsg$     'For invoice goods value messages
Dim DiscountMsg$  'For discount messages
Dim DDiscount$    'For discount display
Dim InvoiceMsg$   'For Invoice Value Messages
'---
Dim DiscountVAT!    '18Jun01 JKU/SF Added for VAT on discount
Dim DiscountNet!    '   "
Dim DiscountInc!    '   "
Dim carrtotal!, CarrIncVAT!, foundorder&, foundPtr As Long, cont&, header As Integer, foundcarriage&, CarrMsg$, total$, dat$, Msg2$, title$, carrcost$, ans$  '01Jun02 All/CKJ  '01Jun02 ALL/ATW
Dim carriage!, msg$, discount$, Discnt!
Dim strParameters As String
Dim rsOrders As ADODB.Recordset

   carrtotal! = 0
   CarrIncVAT! = 0

   blankorder ordCarriage    're-initialise ordCarriage.
   blankorder ordDiscount    're-initialise ordDiscount.
  
   If Edittype = 4 Then  'Reconciling orders, not credit notes
      'get carriage 'nsvcode', look up OrderNum, NSVcode & offer for change
      foundorder& = 0
      'LookupDrug NSVCarriage$, d, found              '31May01 TH/JKU Replaced with below. This can allow for different
      d.SisCode = NSVcarriage$                        '   "       sales tax rates on different suppliers for carriage
      getdrugsup d, 0, foundPtr&, False, lastsupplier$    '   "       by using supplier profiles on the dummy drug  '01Jun02 ALL/ATW
      If foundPtr& Then
         cont& = 0
         header = False
         foundcarriage& = 0
         ''Do     ' scan all orders looking for this drug & this order
         ''scanordreqindex edittype, NSVcarriage$, cont&, foundorder&
         'We need to do an orderbycriteria here
         '30Aug06 TH (SC-06-080)Removed the pickno parameter - this isnt required in Reconcil, was left over from the switch from WOrder. Sorry
         '14Mar07 Swap code and num around in params list as it was wrong !!!
         
         strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                         gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                         gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                         gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(ordernum$)) & _
                         gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, NSVcarriage$) & _
                         gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                         gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
         'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParameters)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteria", strParameters) '14Aug06 TH Need to check reconcil,not orders.
         
         If Not rsOrders.EOF Then
            Do While Not rsOrders.EOF  '14Aug06 TH added EOF oops!
               ''If foundorder& Then
               ''getorder ord, (foundorder&), edittype, False     ' (uses idx)
               ord = FillOrdFromRS(rsOrders, "WReconcil")
               If Val(ord.cost) <> 0 And Val(ord.num) = Val(ordernum$) And (ord.status = "7" Or ord.status = "8") Then
                  If Not header Then
                     CarrMsg$ = "  Carriage:      Invoice num   "
                     CarrMsg$ = CarrMsg$ & "(" & money(9) & " code " + d.vatrate + ")"
                     header = True
                  End If
                  CarrMsg$ = CarrMsg$ & Space$(7) + Chr$(13)
                  total$ = Str$(Val(ord.cost) / 100)
                  poundsandpence total$, False
                  dat$ = ord.orddate
                  convdat dat$
                  CarrMsg$ = CarrMsg$ & dat$ & "  " & ord.invnum & "       " & money$(5) & Trim$(total$)
                  If ord.status = "8" Then CarrMsg$ = CarrMsg$ & " (To ledger)"
                  If ord.status = "7" And Trim$(ord.invnum) = invoicenum$ Then
                     carrtotal! = carrtotal! + Val(ord.cost)
                     'foundcarriage& = foundorder&
                     foundcarriage& = ord.OrderID   '25Nov09 TH Replaced above (F0070364)
                  End If
                  CarrMsg$ = CarrMsg$ & Chr$(13)
               End If
               rsOrders.MoveNext
            Loop
         End If
         ''Loop While foundorder&
         CarrIncVAT! = carrtotal! * VAT(Val(d.vatrate))
         If foundcarriage& > 0 Then
            Msg2$ = "  Additional"
            CarrIncVAT! = CarrIncVAT! / 100 '25Nov09 TH Added (F0070364)
         Else
            Msg2$ = "  Enter"
         End If
         title$ = "Invoice Reconcilation"
         Msg2$ = CarrMsg$ & Chr$(13) & Chr$(13) & Msg2$ & " carriage excl " & money(9) & " " & money(5) & "  "
         setinput 0, k
         k.Max = 7
         k.decimals = True       '25Aug11 TH (TFS 10905)
         k.nums = True           '   "
         carrcost$ = ""
         inputwin title$, Msg2$, carrcost$, k
         If Val(carrcost$) <> 0 And Not k.escd Then
            ans$ = ""
            k.helpnum = 0 '!!**
            Confirm "Confirm CARRIAGE cost", "reconcile carriage cost of " & money(5) & " " & Format$(carrcost$, "#0.00;-#0.00"), ans$, k
            If k.escd Or ans$ = "N" Then carrcost$ = "0"
         End If
         
         If Not k.escd And Val(carrcost$) <> 0 Then
                     
            '17May01 JKU/SF Commented out the 'If' statement because we no longer 'lump' the carriage costs into one
            '            record. If the user part matches the carriage cost, from now on, two or more records
            '            will be written to files rather than 1 single record. This provides a better audit trail.
                     
                     
            ''getnumofords 4, foundcarriage&, True   ' get a new order entry
            ''getorder ord, 0, edittype, True    '<----LOCK (no idx) 'Force Insert
      
            blankorder ord
            ord.status = "7" ' Reconciled, waiting for coding slip printing
            ord.num = ordernum$
            ord.Code = NSVcarriage$
            ord.supcode = lastsupplier$ 'which was offered for reconciliation
            ord.paydate = paydate$
            ord.Reconciledate = Format$(Now, "ddmmyyyy")
            ord.invnum = invoicenum$
            ord.qtyordered = "1"
            ord.received = "1"
            ord.outstanding = "0"
            ord.orddate = thedate(False, True)
            ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
            ord.recdate = ord.orddate
            ord.rectime = ord.ordtime
            ord.cost = "0"
                     
            carriage! = Val(carrcost$) * 100     ' pence
                     
            'We now save carriage costs as separate records
            'Was: carrtotal! = carrtotal! + Carriage!  ' total carriage
            carrtotal! = carriage!     'now
            
                   
            CarrIncVAT! = carrtotal! * VAT(Val(d.vatrate))
            ord.cost = Str$(Val(ord.cost) + carriage!)
            'ord.recdate = thedate(False, False) ' todays date '03May98 CKJ Y2K
            ord.recdate = thedate(False, True)   ' todays date '03May98 CKJ Y2K
            'Total & Balance transactions ...
            
            carriage! = carriage! / 100
            carriage! = DblRound(carriage!, 2, 0)
            CarrIncVAT! = CarrIncVAT! / 100
            CarrIncVAT! = DblRound(CarrIncVAT!, 2, 0)
            CarriageVAT! = DblRound(CarrIncVAT!, 2, 0) - DblRound(carriage!, 2, 0)
            ord.VATInclusive = Str(CarrIncVAT!)
            ord.VATAmount = Str(CarriageVAT!)
            ord.VATRateCode = d.vatrate
                                 
            '17May01 JKU/ASC Added. Make a copy of ord and FoundCarriage for later file update.
            LSet ordCarriage = ord
            tmpFoundCarriage& = foundcarriage&
            '---
                     
            '17May01 JKU/ASC Commented out. We are going to write carriage to file later because at this point,
            '        the user hasn't yet been presented with the invoive summary screen. Consequently, if
            '        the user clicks Cancel, carriage has already been written.
            'Orderlog ord.num, NSVCarriage$, userid$, ord.orddate, ord.recdate, "1", "1", Str$(Carriage!), ord.supcode, "T", sitenumber, ord.invnum, D.vatrate ' extra carriage
            'Orderlog ord.num, NSVCarriage$, userid$, ord.orddate, ord.recdate, "1", "1", Str$(Carriage!), ord.supcode, "B", sitenumber, ord.invnum, D.vatrate
            'putorder ord, foundcarriage&  '<= UNLOCK
            '---JKU


         End If
      End If

     
      
      '17May01 JKU/ASC added. This replaces the messages for carriage. NB: This will override any carrmsg set above.
      If Trim(ordCarriage.Code) <> "" Then
         CarrMsg$ = "CARRIAGE____________________________________" & Chr(13) & Chr(13)
         CarrMsg$ = CarrMsg$ & Space(18) & "Carriage Net"
         CarrMsg$ = CarrMsg$ & Format$(Format$(carriage!, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@")
         CarrMsg$ = CarrMsg$ & Chr(13) & Space(18) & "Carriage " & money(9)
         CarrMsg$ = CarrMsg$ & Format$(Format$(CarriageVAT!, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
         CarrMsg$ = CarrMsg$ & Space(16) & "Carriage Gross"
         CarrMsg$ = CarrMsg$ & Format$(Format$(CarrIncVAT!, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      Else
         CarrMsg$ = ""
      End If
      
      'enter discount
      foundorder& = 0
      LookupDrug NSVdiscount$, d, foundPtr&    'get discount 'nsvcode'
      If foundPtr& Then
         msg$ = "Enter Total discount £"    '21Mar07 CD added £ sign
         setinput 0, k
         k.Max = 7
         k.decimals = True       '25Aug11 TH (TFS 10905)
         k.nums = True           '   "
         discount$ = ""
         title$ = "Invoice Reconcilation"   '21Mar07 CD added caption string as was blank at this point
         inputwin title$, msg$, discount$, k
         If Val(discount$) <> 0 And Not k.escd Then
            ans$ = ""
            k.helpnum = 0 '!!**
            Confirm "Invoice/Prompt Payment Discount", "Reconcile discount of " & money(5) & " " & Format$(discount$, "#0.00;-#0.00"), ans$, k
            If k.escd Or ans$ = "N" Then discount$ = "0"
            k.escd = False
         End If
               
         If Val(discount$) <> 0 And Not k.escd Then
            ''getnumofords 4, foundcarriage&, True   ' get a new order entry
            '''getorder ord, 0, edittype, True    '<----LOCK (no idx)  'Force Insert  '27Apr06 TH Removed. Insert handled now in put

            blankorder ord
            ord.status = "7"               'Reconciled, waiting for coding slip printing
            ord.num = ordernum$
            ord.Code = NSVdiscount$
            ord.supcode = lastsupplier$    'which was offered for reconciliation
            ord.paydate = paydate$
            ord.Reconciledate = Format$(Now, "ddmmyyyy")   '28Jan04 TH Added
            ord.invnum = invoicenum$
            ord.qtyordered = "1"
            ord.received = "1"
            ord.outstanding = "0"
            ord.orddate = thedate(False, True)   '03May98 CKJ Y2K
            ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
            ord.recdate = ord.orddate
            ord.rectime = ord.ordtime
            Discnt! = -Val(discount$) * 100      ' pence
            ord.cost = Str$(Discnt!)
            'Total & Balance transactions ...
               
            '17May01 JKU/ASC Commented out. The Orderlog and Reconcil.v8 files are now written at the very end, when
            '            the user clicks OK in the invoice summary window. Currently, if the user clicks Cancel
            '            in the invoice summary screen, the discount amount is already written to the files and
            '            it stays there! Clearly, this is unacceptable. We will write the files later.
            
            'Orderlog ord.num, nsvdiscount$, userid$, ord.orddate, ord.recdate, "1", "1", Str$(Discnt!), ord.supcode, "T", sitenumber, ord.invnum, "0" ' discount 0%VAT  '5Oct94 CKJ was NSVcarriage
            'Orderlog ord.num, nsvdiscount$, userid$, ord.orddate, ord.recdate, "1", "1", Str$(Discnt!), ord.supcode, "B", sitenumber, ord.invnum, "0"                   '  "
            'putorder ord, foundcarriage&  '<= UNLOCK
            'poundsandpence discount$, False
            'popmessagecr "!n!bDiscount Posted", " Discount of " & Money(5) + discount$ & " posted, do not enter again"
            '---

            '17May01 JKU/ASC Added
            DDiscount$ = Str(Discnt! / 100)
            ord.VATInclusive = Format$(DDiscount$, "#0.00;-#0.00")
            DDiscount$ = money(5) & Format$(DDiscount$, "#0.00;#0.00-")
            DiscountMsg$ = "DISCOUNT ON INVOICE_________________________" & Chr(13) & Chr(13)
            DiscountMsg$ = DiscountMsg$ & Space(12) & "Discount (" & ord.Code & ")"
          

            '18Jun01 JKU/SF Added to account for VAT on discount. NB: VAT has been written to the orderlog for discount BUT
            '        not to the reconcil.v8 file. This fix will bring the reconcil.v8 file in line with the others.
 
            'DiscountMsg$ = DiscountMsg$ & Format$(DDiscount$, "@@@@@@@@@@@@@@") & Chr(13)     'Removed carriage return
            DiscountMsg$ = DiscountMsg$ & Format$(DDiscount$, "@@@@@@@@@@@@@@")
   
            DiscountNet! = DblRound(Val(ord.VATInclusive), 2, 0)  'NB: ord.VATInclusive is net at this point.
            DiscountInc! = DiscountNet! * VAT(Val(d.vatrate))
            DiscountInc! = DblRound(DiscountInc!, 2, 0)
            DiscountVAT! = DiscountInc! - DiscountNet!

            ord.VATInclusive = Format$(Str(DiscountInc!), "#0.00;-#0.00")
            ord.VATAmount = Format$(Str(DiscountVAT!), "#0.00;-#0.00")

            DiscountMsg$ = DiscountMsg$ & Chr(13) & Space(18) & "Discount " & money(9)
            DiscountMsg$ = DiscountMsg$ & Format$(Format$(ord.VATAmount, money(5) & "#0.00 ;" & money(5) & "#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
            DiscountMsg$ = DiscountMsg$ & Space(16) & "Discount Gross"
            DiscountMsg$ = DiscountMsg$ & Format$(Format$(ord.VATInclusive, money(5) & "#0.00 ;" & money(5) & "#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
            '--- 18Jun01 JKU/SF
          
            '08Jul01 JKU/SF added to account for VAT on discount in the orderlog.
            ord.VATRateCode = d.vatrate
            '---08Jul01 JKU/SF

            LSet ordDiscount = ord                   'For file update in FinEditOrd
            tmpFoundDiscount& = foundcarriage&  'For file update in FinEditOrd
            '---
         End If
      End If
   End If
         
   '****

   total$ = Str(lastinvtotal! / 100)
   total$ = Str(DblRound(total$, 2, 0))
   GoodsMsg$ = "GOODS_______________________________________" & Chr(13) & Chr(13)
   GoodsMsg$ = GoodsMsg$ & Space(18) & "Goods Ex " & money(9)
   GoodsMsg$ = GoodsMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
   '---

   If TransLogVAT Then
      invVAT$ = Str((lastInvIncVAT! / 100) - Val(total$))         '30Jun01 JKU Penny rounding fix. Replaced
      invVAT$ = Str(DblRound(invVAT$, 2, 0))
      GoodsMsg$ = GoodsMsg$ & Space(18) & money(9) & " on Goods"
      GoodsMsg$ = GoodsMsg$ & Format$(Format$(invVAT$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      total$ = Str(DblRound(total$, 2, 0) + DblRound(invVAT$, 2, 0))
      GoodsMsg$ = GoodsMsg$ & Space(13) & "Total Goods Value"
      GoodsMsg$ = GoodsMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00 "), "@@@@@@@@@@@@@@") & Chr(13)
   End If

   total$ = Str(DblRound((lastinvtotal! / 100), 2, 0) + DblRound((carrtotal! / 100), 2, 0) + DblRound((Discnt! / 100), 2, 0))
   If Edittype = -4 Then
      InvoiceMsg$ = "CREDIT NOTE VALUE___________________________" & Chr(13) & Chr(13)
      InvoiceMsg$ = InvoiceMsg$ & Space(9) & "Credit Note Net Value"
      InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
   Else
      InvoiceMsg$ = "INVOICE VALUE_______________________________" & Chr(13) & Chr(13)
      ''InvoiceMsg$ = InvoiceMsg$ & Space(13) & "Invoice Net Value"
      InvoiceMsg$ = InvoiceMsg$ & Space(11) & "Invoice  Net  Value"
      InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
   End If
      
   If TransLogVAT Then
      invVAT$ = Str(DblRound((lastInvIncVAT! / 100), 2, 0) + DiscountVAT! + DblRound(CarrIncVAT!, 2, 0) + DblRound((Discnt! / 100), 2, 0) - DblRound(total$, 2, 0)) '25Nov09 TH Reinstated as in fact it is in pounds EXCEPT for when previously entered on this order. This has no been fixed above - apologies to John as it wasnt as bad as thought (until I "fixed" it) (F0070364)
      'invVAT$ = Str(DblRound((lastInvIncVAT! / 100), 2, 0) + DiscountVAT! + DblRound(CarrIncVAT! / 100, 2, 0) + DblRound((Discnt! / 100), 2, 0) - DblRound(total$, 2, 0)) '29Aug08 TH (F0015785) Existing carriage being added at * 100 (its pence not pounds John!!)
      If Edittype = -4 Then
         InvoiceMsg$ = InvoiceMsg$ & Space(9) & "Credit Note " & money(9) & " Total"
         InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(invVAT$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      Else
         ''InvoiceMsg$ = InvoiceMsg$ & Space(13) & "Invoice " & money(9) & " Total"
         InvoiceMsg$ = InvoiceMsg$ & Space(11) & "Invoice  " & money(9) & "  Total"
         InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(invVAT$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      End If
      total$ = Str(DblRound(total$, 2, 0) + DblRound(invVAT$, 2, 0))
      If Edittype = -4 Then
         InvoiceMsg$ = InvoiceMsg$ & Space(7) & "Credit Note Total Value"
         InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      Else
         InvoiceMsg$ = InvoiceMsg$ & Space(11) & "Invoice Total Value"
         InvoiceMsg$ = InvoiceMsg$ & Format$(Format$(total$, money(5) & "#0.00 ;#0.00-"), "@@@@@@@@@@@@@@") & Chr(13)
      End If
   End If
   
   '17May01 JKU/ASC Commented out and replaced. Ensuring that InvoiceTotal! is 2 decimal places. Please do not touch
   '            because this will affect the VAT rounding amount. As it was, the amount posted to VAT rounding
   '            pseudo code can be 1 penny out (see the FinEditOrd function).
   InvoiceTotal! = DblRound(total$, 2, 0)
      
   If Trim(ordCarriage.Code) = "" And Trim(ordDiscount.Code) = "" Then
      msg$ = InvoiceMsg$
   Else
      msg$ = GoodsMsg & Iff(Trim(ordCarriage.Code) <> "", Chr(13) & CarrMsg$, "")                             '21Feb02 JKU Replaced
      msg$ = msg$ & Iff(Trim(ordDiscount.Code) <> "", Chr(13) & DiscountMsg$, "") & Chr(13) & InvoiceMsg$     '21Feb02 JKU Replaced
   End If
   
   reconciltxt$ = msg$

  

End Sub

Sub ModifyPrice(d As DrugParameters, adjustment$)
' Combines drug price, stock level & losses/gains with an adjustment to the
' overall stock value. The adjustment is in pence. Convfact is also needed.
' The drug must be locked if the revised figures are to be written back.

'                                            value of stocklevel
'                                                    v
'neg ------2------+------1------+------0------+------1------+------2------ pos
'    *************3*************        ******1******
'                               ***4****             **********2**********
'    value of gainslosses relative to stocklevel

Dim stockvalue!      '01Jun02 All/CKJ

   d.lossesgains = d.lossesgains + Val(adjustment$)
   stockvalue! = Val(d.cost) * (Val(d.stocklvl) / Val(d.convfact))
   If Val(d.stocklvl) > 0 Then
         If d.lossesgains > 0 And d.lossesgains < stockvalue! Then    ' **1**
               'If issue price will be no more than doubled by adding
               'losses and gains and lossesgains is +ve then average
               d.cost = LTrim$(Str$((stockvalue! + d.lossesgains) / (Val(d.stocklvl) / Val(d.convfact))))
               d.lossesgains = 0
            Else
               If d.lossesgains > 0 Then                              ' **2**
                     'Only double price adding rest to losses and gains
                     'to stop wild issue price fluctuations for +ve lossesgains
                     d.cost = LTrim$(Str$(Val(d.cost) * 2))
                     d.lossesgains = d.lossesgains - stockvalue!
                  Else
                     If d.lossesgains * -1 > stockvalue! / 2 Then     ' **3**
                           'If reducing by lossesgains would reduce price by more than half
                           d.cost = LTrim$(Str$(Val(d.cost) / 2))
                           d.lossesgains = d.lossesgains + (stockvalue! / 2)
                        Else                                          ' **4**
                           'if reducing by lossesgains would not more than halve issue price
                           d.cost = LTrim$(Str$((stockvalue! + d.lossesgains) / (Val(d.stocklvl) / Val(d.convfact))))
                           d.lossesgains = 0
                        End If
                  End If
            End If
      End If
   '!!checklossgain d, ord.received, ord.cost, purprice$, newcost$, qty!, "Updateprice-reconciliation"

End Sub

Sub MonthEndDiscount(SiteNumber As Integer)
'-----------------------------------------------------------------------------
'26Jan94 CKJ Written
'15Jan02 TH Added time to orderlog call
'19Apr04 TH Allow only numeric entries for value of credit note  (#60060)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitenumber param
'-----------------------------------------------------------------------------

Dim title$, finmsg$, foundPtr As Long, msg$, supcode$, CreditNoteNum$, discount$, reason$, ans$, escd%, dateord$ '', adjnum As Integer    '01Jun02 All/CKJ  '01Jun02 ALL/ATW
Dim lngFoundSup As Long
Dim lngAdjnum As Long
'foundsup As Integer,

   title$ = "Month End Credit/Discount for " + Trim$(hospabbr$)
   finmsg$ = "Enter month end discount/credit from supplier." & cr & cr
   finmsg$ = finmsg$ & "Use this to record a discount or credit note " & cr
   finmsg$ = finmsg$ & "which cannot be attributed to a single item." & cr

   foundPtr& = 0
   If Len(Trim$(NSVdiscount$)) = 7 Then LookupDrug NSVdiscount$, d, foundPtr&
   If foundPtr& = 0 Then
         msg$ = "The NSV code for posting discounts has not been defined.  "
         msg$ = msg$ & "Please enter this in Utilities / Set Defaults,   "
         msg$ = msg$ & "then enter it under drug maintenance as 'Discount'.       "
         popmessagecr "", msg$
         k.escd = True
      End If

   If Not k.escd Then
         Do
            supcode$ = ""
            asksupplier supcode$, 0, "ES", "Enter Supplier Code", False, sup, False   '15Nov12 TH Added PSO param
            If k.escd Then Exit Sub
            getsupplier supcode$, False, lngFoundSup, sup
            If lngFoundSup = 0 Then
                  popmessagecr "Aborting", "Supplier code '" + supcode$ + "' not found"
                  k.escd = True
               Else
                  finmsg$ = finmsg$ + Chr$(13) + "Supplier" & TB & TB & ": " + sup.name + Chr$(13) + Chr$(13)
               End If
         Loop Until lngFoundSup > 0 Or k.escd
      End If

   If Not k.escd Then
         EnterCreditNote CreditNoteNum$
         finmsg$ = finmsg$ + "Credit note number" & TB & ": " & CreditNoteNum$ + Chr$(13) + Chr$(13)
      End If

   If Not k.escd Then
         msg$ = "Enter value of credit/discount in " & money(5)
         setinput 0, k
         k.Max = 8
         'k.nocrlf = False
         
         k.helpnum = 0
         discount$ = ""
         'inputline Discount$, k
         k.decimals = True   '19Apr04 TH Added (#60060)
         k.nums = True       '   "
         inputwin title$, msg$, discount$, k
         If Val(discount$) = 0 Then k.escd = True
         poundsandpence discount$, True
         finmsg$ = finmsg$ + "Discount" & TB & TB & ": " & money(5) & discount$ + Chr$(13) + Chr$(13)
      End If

   If Not k.escd Then            ' 7Jul94 CKJ Added
         AskReasonCode "discount/credit", reason$
         finmsg$ = finmsg$ + "Reason" & TB & TB & ": " & reason$ + Chr$(13) + Chr$(13)
      End If

   If Not k.escd Then
         finmsg$ = finmsg$ & "Accept these values?"
         ans$ = ""
         popmsg title$, finmsg$, 4 + 256, ans$, escd%
         k.helpnum = 0
         If ans$ = "Y" And Not escd Then          ' do transaction
               'dateord$ = thedate$(False, False) '03May98 CKJ Y2K
               dateord$ = thedate(False, True)    '03May98 CKJ Y2K
               getorderno -1, lngAdjnum, True
               'Orderlog LTrim$(Str$(adjnum)), d.siscode, userid$, dateord$, "", "0", "", LTrim$(Str$(Val(discount$) * 100)), supcode$, "A", sitenumber, reason$ + " " + ordernum$, d.vatrate  '14Jan94 CKJ VAT '28Jun93 CKJ was d.code '17May94 CKJ was adjust
               'Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(discount$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", "" '15Jan02 TH Replaced above, added time to log
               'Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(discount$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", "", ""  '02Nov10 AJK F0086901 Added paydate
               Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(discount$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", "", "", ord.PSORequestID   '03Mar14 TH Added PSORequestID
            End If
      End If

End Sub

Function posnegmoney$(Value!)

Dim valstr$      '01Jun02 All/CKJ

   valstr$ = Str$(Abs(Value!))
   poundsandpence valstr$, False
   If Value! < 0 Then
         posnegmoney = valstr$ + "-"
      Else
         posnegmoney = valstr$
      End If
          
End Function

Sub PrintDispNoteDescriptor(filno%, finsch$)
'22Nov00 EAC/CY Handle in-dispute items

Dim temp$

   If Left$(finsch$, 1) = "C" Then            ' CREDIT
         temp$ = " Supp. User ID NSVcode Description" & "[Tab]" & "QtyxPack size" & "[Tab]" & "Ledger" & "[Tab]" & Trim$(money(5)) & "Value" & "[Tab]"  '06Aug98 SF
         If TransLogVAT Then temp$ = temp$ & Trim$(money(5)) & " inc " & Trim$(money(9))  '05Aug98 SF
      Else
         temp$ = " Supp. User ID NSVcode Description" & "[Tab]" & "QtyxPack size" & "[Tab]" & "Ledger" & "[Tab]" & Trim$(money(5)) & " Cost" & "[Tab]"  '06Aug98 SF
         If TransLogVAT Then temp$ = temp$ & Trim$(money(5)) & " inc " & money(9)      '05Aug98 SF
      End If
   temp$ = temp$ & "[cr]" & String$(119, 95) & "[cr]"    '06Aug98 SF
   PrinterParse temp$
   Put #filno, , temp$


End Sub

Sub PrintDisputeNotes()
'22Nov00 EAC/CY Handle in-dispute items
'01Jun02 All/CKJ corrected fileno to filno
'                corrected edittype to tmpEditType
'20Aug09 PJC ledcode is now trimmed (F0050136)

Dim temp$, RTFTxt$, data1$, data2$, tmpaddr$
Dim desc As String * 35
Dim success% '', foundsup%
Dim startposn&
Dim batchcost!, batchvat!
Dim copyOfData1$, vstartposn&
Dim DispNoteNum&, tmpEditType%
Dim numforledger As Long, pointer&, fil As Integer, idxlen As Integer, X&, cred$, finsch$, FILE$, filno As Integer, endposn&, Items As Integer, totalcost!, totalincvat!   '01Jun02 All/CKJ
Dim printtop As Integer, FirstPrint As Integer, cont&, found&, credit As Integer, schnext$, foundnext&, LineCost$, lineincvat$, gap$, printedok As Integer    '01Jun02 All/CKJ
Dim rsOrders As ADODB.Recordset
Dim strParams As String
Dim ReconcilRecords() As Long
Dim intloop As Integer


   Screen.MousePointer = HOURGLASS
   tmpEditType = Edittype
   Edittype = 4
   k.escd = False
   numforledger = 0

   GetPointerSQL dispdata$ & "\dispnote.dat", DispNoteNum&, -1

   Screen.MousePointer = HOURGLASS
   Do                         '2 print all items
      'Make spool file for printing
      MakeLocalFile FILE$
      filno = FreeFile
      Open FILE$ For Binary Access Write Lock Read Write As #filno         ' for spooling ...
        
      'GetTextFile dispdata$ & "\dnotetop.rtf", RTFTxt$, success
      GetRTFTextFromDB dispdata$ & "\dnotetop.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - " & dispdata$ & "\DNOTETOP.RTF" & cr & "Cannot continue..."    '06Aug98 SF
         Close #filno
         Exit Sub
      End If
        
      vstartposn& = InStr(RTFTxt$, "[DO_NOT_TOUCH_THIS_DATA_ITEM]")
      If vstartposn& = 0 Then
         popmessagecr "Error", "need to add [DO_NOT_TOUCH_THIS_DATA_ITEM] into " & dispdata$ & "\DNOTETOP.RTF"
        Close #filno
         Exit Sub
      End If
        
      startposn& = InStr(RTFTxt$, "[data]")
      endposn& = InStr(startposn&, RTFTxt$, "[data]") + Len("[data]")
   
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "FinancePrintFix", 0)) Then  '27Mar06 TH Ultra caution. To be removed after UAT !
         data1$ = Mid$(RTFTxt$, vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]"), startposn& - (vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]")))
      Else
         data1$ = Mid$(RTFTxt$, vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]"), startposn& - (vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]")) - Len("[data]")) '06Aug98 SF
      End If
      
      data2$ = Mid$(RTFTxt$, endposn& + 1)
      copyOfData1$ = data1$
      
      temp$ = Left$(RTFTxt$, vstartposn& - 1)
      Put #filno, , temp$

        Items = 0
        totalcost! = 0
        totalincvat! = 0
        printtop = True
        FirstPrint = True
    
        cont& = 1  'read file in order
        finsch$ = ""
        If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
        
        batchvat! = 0
        batchcost! = 0
        
        'SQL get the stuff here my man
        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite))
        Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilPrintDispNotes", strParams)
        If rsOrders.RecordCount > 0 Then
            ReDim ReconcilRecords(rsOrders.RecordCount)
            Do While Not rsOrders.EOF
            
               Items = Items + 1
               credit = False
               ord = FillOrdFromRS(rsOrders, "WReconcil")
               ReconcilRecords(Items) = ord.OrderID
               If Val(ord.qtyordered) < 0 Then credit = True
               If printtop Then
                  data1$ = copyOfData1$
                  If Not FirstPrint Then
                     temp$ = "[ff]"
                     PrinterParse temp$
                     data1$ = temp$ & data1$
                  End If
                  replace data1$, "[today]", Format$(Now, "dd-mm-yyyy"), 0
                  getsupplier (ord.supcode), 0, 0, sup
                  
                  tmpaddr$ = joinsup$(sup.supaddress, sup)
                  replace data1$, "[supaddr]", tmpaddr$, 0
                  replace data1$, "[dnotenum]", Format$(DispNoteNum&), 0
   
                  replace data1$, "[supplier]", Trim$(sup.name), 0
                  replace data1$, "[orderno]", Trim$(ord.num), 0
                  If credit Then
                     replace data1$, "[paytext]", "", 0
                     replace data1$, "[invoicetext]", "Credit Note No.", 0
                     replace data1$, "[ordertext]", "Return No.", 0
                  Else
                     replace data1$, "[paytext]", "Payment Date:", 0
                     replace data1$, "[invoicetext]", "Invoice No.", 0
                     replace data1$, "[ordertext]", "Order No.", 0
                  End If
                  replace data1$, "[invoiceno]", Trim$(ord.invnum), 0
                  replace data1$, "[paydate]", Trim$(ord.paydate), 0
                  replace data1$, "[ordertext]", "Order No.", 0
                  Put #filno, , data1$
                  printtop = False
                  FirstPrint = False
                  PrintDispNoteDescriptor filno, finsch$
               End If

               d.SisCode = ord.Code
               getdrug d, 0, 0, False
               desc$ = d.drugDescription        ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
               plingparse desc$, "!"
         
               LineCost$ = LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100))
               
               poundsandpence LineCost$, False
               
               totalcost! = totalcost! + Val(LineCost$)
               If Not credit Then
                  batchcost! = batchcost! + Val(LineCost$)
               Else
                  batchcost! = batchcost! - Val(LineCost$)
               End If
            
               If Trim$(ord.VATInclusive) = "" Then
                  lineincvat$ = Str$(Val(LineCost$) * VAT(Val(d.vatrate)))
                  poundsandpence lineincvat$, False
                  If ord.Code = NSVdiscount$ Then
                     lineincvat$ = "       " & Right$(Format$(Str$(Val(LineCost$) * VAT(Val(d.vatrate))), "###0.00"), 7)
                  End If
                  
                  If ord.Code = NSVReconciliation$ Then
                  lineincvat$ = "       " & Right$(Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00"), 7)
               End If
            Else
               lineincvat$ = ord.VATInclusive
               poundsandpence lineincvat$, False
   
               If ord.Code = NSVdiscount$ Then
                  lineincvat$ = "       " & Right$(Format$(LTrim$(lineincvat$), "###0.00"), 7)
               End If
               If ord.Code = NSVReconciliation$ Then
                  lineincvat$ = "       " & Right$(Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00"), 7)
               End If
   
            End If
            totalincvat! = totalincvat! + Val(lineincvat$)
            If Not credit Then
               batchvat! = batchvat! + Val(lineincvat$)
            Else
               batchvat! = batchvat! - Val(lineincvat$)
            End If
            If Val(ord.outstanding) > 0 Then gap$ = "*" Else gap$ = ""
    

            temp$ = ord.supcode & "   " & UserID$ & "   "
            temp$ = temp$ & " " & ord.Code & " " & Trim$(desc$) & gap$ & "[Tab]"
            temp$ = temp$ & Trim$(ord.received)
            temp$ = temp$ & " x " & Trim$(d.convfact) & "[Tab]" & LCase$(d.PrintformV) & "[Tab]"
            temp$ = temp$ & Trim$(d.ledcode) & "[tab]" & Trim$(LineCost$)     '20Aug09 PJC ledcode is now trimmed (F0050136)
            'temp$ = temp$ & d.ledcode & "[tab]" & Trim$(LineCost$)           '     "                    "
            If TransLogVAT Then temp$ = temp$ & "[Tab]" & Trim$(lineincvat$) & " (" & d.vatrate & ")"
            temp$ = temp$ & "[cr]"
            PrinterParse temp$
            Put #filno, , temp$
            
            
''            If Left$(finsch$, 17) <> Left$(schnext$, 17) Or foundnext& = 0 Then
''                    PrintLedgerTail filno%, finsch$, printtop%, totalcost!, totalincvat!
''                    If Not FullPageCS Then FirstPrint = True
''                End If
    
            finsch$ = schnext$
            ''If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
            ''found& = foundnext&
            rsOrders.MoveNext
        Loop
      End If
      temp$ = "{\par}"
      Put #filno, , temp$
      

      replace data2$, "[totalexvat]", Trim$(money$(5)) & Format$(batchcost!, "0.00"), 0
      replace data2$, "[totalincvat]", Trim$(money$(5)) & Format$(batchvat!, "0.00"), 0
      replace data2$, "[totalvat]", Trim$(money$(5)) & Format$(batchvat! - batchcost!, "0.00"), 0
      Put #filno, , data2$

      Close #filno
    
        Screen.MousePointer = STDCURSOR

        If Items = 0 Then
               Kill FILE$    'no items printed
               popmessagecr "!n!bDispute Notes", "No items printed"
               k.escd = True
            Else
               WSspool FILE$, "Dispute Notes", 1, True, True, "CodingSlip"
               printedok = True
               If printedok Then        '4 update file
                  Screen.MousePointer = STDCURSOR
                  ClearStatusDisplay
                  DisplayStatus "Processing..."
                  cont& = 1  'read file again
                  'SQL USE AN ARRAY FROM THE ABOVE ID's !!!! LOOP AND UPDATE
                  For intloop = 1 To Items
                     getorder ord, (ReconcilRecords(intloop)), 4, True
                     If ord.status = "4" And ord.Indispute = "Y" Then ord.Indispute = "P"
                     found& = PutOrder(ord, (ReconcilRecords(intloop)), "WReconcil")
                  Next
                  MainScreen.LstDisplay.Visible = False
               End If
            End If
   
   Loop Until printedok Or k.escd
   
   Screen.MousePointer = STDCURSOR
   k.escd = False
   Edittype = tmpEditType

End Sub

Sub printledger()
'''---Print ledger output (could also be used to connect to ledger in future)---
'''17Jan94 CKJ Procedure re-written
''' 1 find all items, make index, sort index
''' 2 print all items
''' 3 confirm printing
''' 4 update file
'''29Dec97 EAC Use Stores drug description
'''14Jan98 EAC print batch total at end of coding slip
'''07Apr98 CFY printledger: Fiddle to stop the rtf file that is built up causing hi-edit to blow up with an 'stack overflow' error.
'''                         Although hiedit no longer complains, I still can't get the correct fonts to display in the main [data]
'''                         rtf.
'''08May98 CFY Now deducts credit items from the total amount rather than adding
'''06Aug98 SF  Changed formatting so all order details will fit onto one line
'''            (suggest [data] section kept at Arial 8).
'''            Now only uses one RTF file: "csliptop.rtf".
'''            Now kills temp file.
'''12Aug98 TH  Code to deal with negative values (in total reconciliations and discounts)
'''            (Pounsandpence not designed to take negative values)
'''11Feb99 TH  Ensure credit prices are printed as negative
'''11Oct99 CKJ Removed Findsupplier
'''26Jan00 SF  now prints reconciliation diffs on both cost lines as was causing incorrect totals being printed
'''12Apr00 CFY Parameter added to wsspool call
'''20Oct00 JN  Added code to pick up new, pre-calculated VAT Amounts
'''02Jul01 JKU/EAC Amendments and fixes to enable proper working with modifications and fixes made to invoice reconciliation routine.
'''21Feb02 JKU Changed IIf to IFF
'''01Jun02 All/CKJ corrected fileno to filno
'''13May04 CKJ alternative collation sequence \winord.ini [defaults] CodingSlipsInSupplierOrder="Y" default ="N"
''
''Dim temp$, RTFTxt$, data1$, data2$
''Dim desc As String * 35
''Dim success%, foundsup%
''Dim startposn&
''Dim batchcost!, batchvat!  '14Jan98 EAC print batch total at end of coding slip
''Dim copyOfData1$, vstartposn&          '06Aug98 SF added
''Dim numforledger As Integer, pointer&, fil As Integer, idxlen As Integer, x&, cred$, finsch$, FILE$, filno As Integer, endposn&, items As Integer, totalcost!, totalincvat! '01Jun02 All/CKJ
''Dim printtop As Integer, FirstPrint As Integer, cont&, found&, credit As Integer, schnext$, foundnext&, linecost$, lineincvat$, gap$, Title$, msg$, ans$, printedok As Integer '01Jun02 All/CKJ
''Dim blnSortBySupplier As Integer       '13May04 CKJ
''Dim intSubtotalChars As Integer        '17May04 CKJ
''
''   Screen.MousePointer = HOURGLASS
''   numforledger = 0
''   getnumofords 4, pointer&, False    'was 7
''   fil = FreeFile
''   Open dispdata$ + "\ledger.idx" For Binary Access Read Write Lock Read Write As #fil
''   'Create index <credit><order no><invoice no><NSVcode>000000x 1+4+12+7+7=31
''   'Create index <credit><supcode><order no><NSVcode>000000x    1+5+4+7+7=24                   '13May04 CKJ alternative collation sequence
''
''   'idxlen = 31
''   'putidxline fil, 1, idxlen, "24" + Space$(idxlen - 9), 0, False                             '13May04 CKJ
''   blnSortBySupplier = TrueFalse(txtd(dispdata$ & "\winord.ini", "defaults", "N", "CodingSlipsInSupplierOrder", 0))
''   If blnSortBySupplier Then idxlen = 24 Else idxlen = 31                                      '   "
''   putidxline fil, 1, idxlen, pad$(Format$(idxlen - 7), idxlen - 7), 0, False                  '   "
''   putidxline fil, 2, idxlen, Space$(idxlen - 7), 0, False
''
''   For x& = 2 To pointer&        '1 find all items, make index, sort index
''      getorder ord, x&, 4, False  'was 7
''      If ord.status = "7" Then
''            numforledger = numforledger + 1
''            If Sgn(Val(ord.qtyordered)) = -1 Then cred$ = "C" Else cred$ = "I"
''            finsch$ = "    "
''            RSet finsch$ = Trim$(ord.num)
''            'putidxline fil, numforledger + 2, idxlen, cred$ + finsch$ + ord.invnum + ord.code, X&, False
''            If blnSortBySupplier Then
''                  putidxline fil, numforledger + 2, idxlen, cred$ & ord.supcode & finsch$ & ord.code, x&, False
''               Else
''                  putidxline fil, numforledger + 2, idxlen, cred$ & finsch$ & ord.invnum & ord.code, x&, False
''               End If
''         End If
''      'If INKEY$ = Chr$(27) Then    '!!** 06Aug98 CKJ/SF won't work under Windows
''      '      numforledger = 0       '
''      '      k.escd = True          '
''      '      Exit For               '
''      '   End If                    '
''   Next
''
''   'putidxline fil, 1, idxlen, "24" + Space$(idxlen - 9), (numforledger), False                '13May04 CKJ
''   putidxline fil, 1, idxlen, pad$(Format$(idxlen - 7), idxlen - 7), (numforledger), False     '   "
''
''   Close fil
''   Screen.MousePointer = STDCURSOR
''
''   If Not k.escd Then
''         sortindex "", dispdata$ + "\ledger.idx"
''      End If
''
''   Screen.MousePointer = HOURGLASS
''   Do                         '2 print all items
''
''        'Make spool file for printing
''        MakeLocalFile FILE$
''        filno = FreeFile
''        Open FILE$ For Binary Access Write Lock Read Write As #filno         ' for spooling ...
''
''        'GetTextFile dispdata$ + "\cslipdat.rtf", rtftxt$, success      '06Aug98 SF replaced
''        GetTextFile dispdata$ & "\csliptop.rtf", RTFTxt$, success       '06Aug98 SF
''         If Not success Then
''               'popmessagecr "Error", "There was a problem reading the RTF layout file - CSLIPDAT.RTF"    '06Aug98 SF replaced
''               popmessagecr "Error", "There was a problem reading the RTF layout file - " & dispdata$ & "\CSLIPTOP.RTF" & cr & "Cannot continue..."    '06Aug98 SF
''               'Close #fileno  '06Aug98 SF added     '01Jun02 All/CKJ
''               Close #filno  '06Aug98 SF added       '01Jun02 All/CKJ corrected
''               Exit Sub
''            End If
''
''        'If Left$(rtftxt$, 6) = "{\rtf1" Then rtftxt$ = Mid$(rtftxt$, 2)    '07Apr98 CFY Added, 06Aug98 SF removed
''        'striprtf rtftxt$                                                                       '
''
''
''        vstartposn& = InStr(RTFTxt$, "[DO_NOT_TOUCH_THIS_DATA_ITEM]")      '06Aug98 SF added
''        If vstartposn& = 0 Then                                            '06Aug98 SF added
''               popmessagecr "Error", "need to add [DO_NOT_TOUCH_THIS_DATA_ITEM] into " & dispdata$ & "\csliptop.rtf"  '06Aug98 SF added
''               'Close #fileno                                              '06Aug98 SF added      '01Jun02 All/CKJ
''               Close #filno                                                '06Aug98 SF added      '01Jun02 All/CKJ corrected
''               Exit Sub                                                    '06Aug98 SF added
''            End If                                                         '06Aug98 SF added
''
''        startposn& = InStr(RTFTxt$, "[data]")
''        'endposn& = InStr(startposn&, rtftxt$, "]")                        '06AugSF replaced
''        endposn& = InStr(startposn&, RTFTxt$, "[data]") + Len("[data]")    '06Aug98 SF
''
''
''        'data1$ = Left$(rtftxt$, startposn& - 1)             '07Apr98 EAC/CFY Added, 06Aug98 SF replaced
''        data1$ = Mid$(RTFTxt$, vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]"), startposn& - (vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]")) - Len("[data]")) '06Aug98 SF
''        data2$ = Mid$(RTFTxt$, endposn& + 1)                '07Apr98 EAC/CFY Added
''        copyOfData1$ = data1$                               '06Aug98 SF added
''
''        'Put #filno, , temp$                        '!!** 04Aug98 SF removed
''        'temp$ = "{"                                '06Aug98 SF replaced
''        temp$ = Left$(RTFTxt$, vstartposn& - 1)     '06Aug98 SF
''        Put #filno, , temp$
''
''        items = 0
''        totalcost! = 0
''        totalincvat! = 0
''        printtop = True
''        FirstPrint = True
''
''        cont& = 1  'read file in order
''        finsch$ = ""
''        binarysearchidx finsch$, dispdata$ + "\ledger.idx", 1, cont&, found&
''        If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
''
''        '14Jan98 EAC print batch total at end
''        batchvat! = 0
''        batchcost! = 0
''        '---
''
''        Do While found&
''            items = items + 1
''            schnext$ = ""   ' check next entry too
''            binarysearchidx schnext$, dispdata$ + "\ledger.idx", 1, cont&, foundnext&
''            getorder ord, found&, 4, False
''
''            If printtop Then
''                    'printledgertop filno, FirstPrint, printtop, credit       '06Aug98 SF replaced
''                    data1$ = copyOfData1$                                     '06Aug98 SF
''                    If Not FirstPrint Then                                    '
''                          temp$ = "[ff]"                                      '
''                          PrinterParse temp$                                  '
''                          data1$ = temp$ & data1$                             '
''                       End If                                                 '
''                    replace data1$, "[today]", Format$(Now, "dd-mm-yyyy"), 0  '
''                    foundsup = 0                                              '
''                    'findsupplier foundsup, (ord.supcode), False, False, sup  '11Oct99 CKJ Removed
''                    getsupplier (ord.supcode), 0, foundsup, False, sup        '   "        added
''
''                    replace data1$, "[supplier]", Trim$(sup.name), 0          '
''                    replace data1$, "[orderno]", Trim$(ord.num), 0            '
''                    If credit Then                                            '
''                        replace data1$, "[paytext]", "", 0                    '
''                        replace data1$, "[invoicetext]", "Credit Note No.", 0 '
''                        replace data1$, "[ordertext]", "Return No.", 0        '
''                     Else                                                     '
''                        replace data1$, "[paytext]", "Payment Date:", 0       '
''                        replace data1$, "[invoicetext]", "Invoice No.", 0     '
''                        replace data1$, "[ordertext]", "Order No.", 0         '
''                     End If                                                   '
''                     replace data1$, "[invoiceno]", Trim$(ord.invnum), 0      '
''                     replace data1$, "[paydate]", Trim$(ord.paydate), 0       '
''                     replace data1$, "[ordertext]", "Order No.", 0            '
''                     Put #filno, , data1$                                     '
''                     printtop = False                                         '
''                     FirstPrint = False                                       '
''
''                    'temp$ = Mid$(rtftxt$, 1, startposn& - 1)     '07Apr98 CFY Removed
''                    'Put #filno, , temp$                          '           "
''                    'Put #filno, , data1$  '07Apr98 EAC added     '07Apr98 CFY Removed for now as this seems to cause the rtf file to screw up.
''                    '---
''                    PrintLedgerDescriptor filno, finsch$
''                End If
''
''            d.siscode = ord.code
''            'getdrug d, 0, fnd, False     '01Jun02 All/CKJ
''            getdrug d, 0, 0, False        '01Jun02 All/CKJ fnd never used
''
''            '29Dec97 EAC use stores drug description
''            'desc$ = d.description
''            desc$ = GetStoresDescription()
''            '---
''            plingparse desc$, "!"
''
''            '02Jul01 JKU/EAC removed and added. We now use VATInclusive and VATAmount fields to work out cost in £
''            'linecost$ = LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100))    'Now ord.VATInclusive - ord.VATAmount
''            'poundsandpence linecost$, False                                        'Not appropriate to use in this function
''            linecost$ = Str(Val(ord.VATInclusive) - Val(ord.VATAmount))
''            linecost$ = Format$(linecost$, "#0.00;-#0.00")
''            '---
''
''            '02Jul01 JKU/EAC Removed. We do not need to worry about negative amounts not showing because we have done away
''            '        with the PoundsAndPnece function which is inappropriate here.
''            'If ord.code = nsvdiscount$ Then            '12Aug98 TH Added to deal with negative values
''            '      linecost$ = Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00")
''            '   End If
''            'If ord.code = NSVReconciliation$ Then      '12Aug98 TH Reconciliations to total are alterations to Vat
''            '      'linecost$ = "       "                'totals thus only one value needs to be printed     '26Jan00 SF replaced as was causing incorrect totals
''            '      linecost$ = Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00")   '26Jan00 SF
''            '   End If                                  '
''            '---
''
''            totalcost! = totalcost! + Val(linecost$)
''            If Not credit Then                                                   '08May98 CFY Added
''                  batchcost! = batchcost! + Val(linecost$)                       '14Jan98 EAC add batch totals
''               Else                                                              '08May98 CFY Added
''                  batchcost! = batchcost! - Val(linecost$)                       '        "
''               End If                                                            '        "
''
''            '02Jul01 JKU/EAC Removed and replaced. We now use VATInclusive at all times
''            'If Trim$(ord.VATInclusive) = "" Then                                 '20Oct00 JN Added check for blank entries in ord.VATInclusive, if found calc old way
''            'lineincvat$ = Str$(Val(linecost$) * VAT(Val(d.vatrate)))
''            'poundsandpence lineincvat$, False
''            lineincvat$ = Format$(ord.VATInclusive, "#0.00;-#0.00")
''            '---
''
''            '02Jul01 JKU/EAC Removed. We do not need to worry about negative amounts not showing because we have done away
''            '        with the PoundsAndPnece function which is inappropriate here.
''            'If ord.code = nsvdiscount$ Then            '12Aug98 TH Added to deal with negative values
''            '      lineincvat$ = "       " & Right$(Format$(Str$(Val(linecost$) * VAT(Val(d.vatrate))), "###0.00"), 7)
''            '   End If
''            ''If ord.code = nsvdiscount$ Then           '12Aug98 TH Removed
''            ''      lineincvat$ = "       " & Right$(Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00"), 7)
''            ''   End If
''
''            'If ord.code = NSVReconciliation$ Then      '12Aug98 TH Added to deal with negative values
''            '      lineincvat$ = "       " & Right$(Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00"), 7)
''            '   End If
''            '   Else
''            '      '20Oct00 Get VAT details the new way, by reading pre-calculated values in from order file
''            '      lineincvat$ = ord.VATInclusive
''            '      poundsandpence lineincvat$, False
''            '
''            '      If ord.code = nsvdiscount$ Then            '20Oct00 JN Incorporated THs changes here 12Aug98 TH Added to deal with negative values
''            '            lineincvat$ = "       " & Right$(Format$(LTrim$(lineincvat$), "###0.00"), 7)
''            '         End If
''            '      If ord.code = NSVReconciliation$ Then      '20Oct00 JN Incorporated THs changes here 12Aug98 TH Added to deal with negative values
''            '            lineincvat$ = "       " & Right$(Format$(LTrim$(Str$((Val(ord.cost) * Val(ord.received)) / 100)), "###0.00"), 7)
''            '         End If
''            '
''            '   End If
''            '---
''
''            totalincvat! = totalincvat! + Val(lineincvat$)
''            If Not credit Then                                                   '08May98 CFY Added
''                  batchvat! = batchvat! + Val(lineincvat$)                       '14Jan98 EAC add batch totals
''               Else                                                              '08May98 CFY Added
''                  batchvat! = batchvat! - Val(lineincvat$)                       '        "
''               End If                                                            '        "
''            'If Val(Ord.outstanding) > 0 Then gap$ = "*" Else gap$ = " "      '06Aug98 SF replaced
''            If Val(ord.outstanding) > 0 Then gap$ = "*" Else gap$ = ""        '06Aug98 SF
''
''            'Print #filno, ord.supcode; " "; Left$(ord.paydate, 2); "/"; Mid$(ord.paydate, 3, 2); "/"; Right$(ord.paydate, 2);
''            'Print #filno, " "; ord.code; " "; desc$; gap$;
''            'Print #filno, Right$("        " + trim$(ord.received), 8);
''            'Print #filno, " x "; d.convfact; LCase$(d.printformV); " ";
''            'Print #filno, d.ledcode; " "; linecost$;
''            'If TransLogVAT Then Print #filno, " "; lineincvat$; " ("; d.vatrate; ")";
''            'Print #filno,
''            If credit Then linecost$ = Str$(Val(linecost$) * credit)           '11Feb99 TH  Ensure credit prices are printed as negative costs
''            If credit = True Then lineincvat$ = Str$(Val(lineincvat$) * credit) '   "
''
''            temp$ = ord.supcode & " " & Left$(ord.paydate, 2) & "/" & Mid$(ord.paydate, 3, 2) & "/" & Right$(ord.paydate, 2)
''            'temp$ = temp$ & " " & Ord.code & " " & desc$ & gap$                    '06Aug98 SF replaced
''            temp$ = temp$ & " " & ord.code & " " & Trim$(desc$) & gap$ & "[Tab]"    '06Aug98 SF
''            'temp$ = temp$ & Right$("        " + Trim$(Ord.received), 8)      '06Aug98 SF replaced
''            temp$ = temp$ & Trim$(ord.received)                               '06Aug98 SF
''            'temp$ = temp$ & " x " & d.convfact & LCase$(d.PrintformV) & " "                       '06Aug98 SF replaced
''            temp$ = temp$ & " x " & Trim$(d.convfact) & "[Tab]" & Trim(LCase$(d.PrintformV)) & "[Tab]"   '06Aug98 SF
''            'temp$ = temp$ & d.ledcode & " " & linecost$             '06Aug98 SF replaced
''
''            '02Jul01 JKU/EAC Removed and replaced. linecost$ and lineincvat$ are already formatted.
''            'temp$ = temp$ & d.ledcode & "[tab]" & Trim$(linecost$)   '06Aug98 SF                          '02Jul01 JKU/EAC Removed
''            'temp$ = temp$ & IIf(Trim(d.ledcode) = "", "?", Trim(d.ledcode)) & "[Tab]" & Trim(linecost$)    '02Jul01 JKU/EAC Replaced    21Feb02 JKU Removed
''            temp$ = temp$ & Iff(Trim(d.ledcode) = "", "?", Trim(d.ledcode)) & "[Tab]" & Trim(linecost$)    '02Jul01 JKU/EAC Replaced    '21Feb02 JKU Replaced
''            'If TransLogVAT Then temp$ = temp$ & " " & lineincvat$ & " (" & d.vatrate & ")"             '06Aug98 SF replaced
''            'If TransLogVAT Then temp$ = temp$ & "[Tab]" & Trim$(lineincvat$) & " (" & d.vatrate & ")"   '06Aug98 SF    '02Jul01 JKU/EAC removed
''            temp$ = temp$ & "[Tab]" & Trim(lineincvat$) & " (" & d.vatrate & ")"                           '02Jul01 JKU/EAC Replaced. We are going to show lineincVAT regardless
''            '---
''
''            temp$ = temp$ & "[cr]"
''            'temp$ = temp$ & "{\par}"
''            PrinterParse temp$
''            Put #filno, , temp$
''
''            'If Left$(finsch$, 17) <> Left$(schnext$, 17) Or foundnext& = 0 Then          '17May04 CKJ Corrected when new collation order used
''            intSubtotalChars = idxlen - 14                                                '   "        17 for old style, 10 for new style collation
''            If Left$(finsch$, intSubtotalChars) <> Left$(schnext$, intSubtotalChars) Or foundnext& = 0 Then       '  "
''                    'temp$ = String$(120, 45) & "[cr]"                                    '07Apr98 CFY Removed
''                    'PrinterParse temp$                                                   '         "
''                    'Put #filno, , temp$                                                  '         "
''                    'temp$ = Mid$(rtftxt$, endposn& + 1, Len(rtftxt$) - (endposn& + 1))
''                    'Put #filno, , temp$
''                    'Put #filno, , data2$  '07Apr98 EAC added                             '07Apr98 CFY Removed for now as this seems to cause the rtf file to screw up.
''                    PrintLedgerTail filno%, finsch$, printtop%, totalcost!, totalincvat!
''                    If Not FullPageCS Then FirstPrint = True
''                End If
''
''            finsch$ = schnext$
''            If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
''            found& = foundnext&
''            'If INKEY$ = Chr$(27) Then             '!!** 06Aug98 CKJ/SF won't work under Windows
''            '    'If items Then closewindow
''            '    items = 0
''            '    Exit Do
''            'End If
''        Loop
''
''        temp$ = "{\par}"
''        Put #filno, , temp$
''
''        'PrintLedgerCost filno%, batchcost!, batchvat!                                                '06Aug98 SF replaced
''        replace data2$, "[totalexvat]", Trim$(money$(5)) & Format$(batchcost!, "0.00"), 0             '06Aug98 SF
''        replace data2$, "[totalincvat]", Trim$(money$(5)) & Format$(batchvat!, "0.00"), 0             '
''        replace data2$, "[totalvat]", Trim$(money$(5)) & Format$(batchvat! - batchcost!, "0.00"), 0   '
''        Put #filno, , data2$
''
''        'write closing RTF brace
''        'temp$ = "}"                '06Aug98 SF removed
''        'Put #filno, , temp$        '
''
''        Close #filno
''
''        Screen.MousePointer = STDCURSOR
''
''        If items = 0 Then
''               Kill FILE$    'no items printed
''               popmessagecr "!n!bCoding Slips", "No items printed"
''               k.escd = True
''
''            Else
''               WSspool FILE$, "Coding Slips", 1, True, False, "CodingSlip"        '07Mar98 CFY replaced with line below, 06Aug98 SF/CFY put back in to delete temp file
''               'WSspool file$, "Coding Slips", 1, False, False      '06Aug98 SF/CFY
''
''               Do                      '3 confirm printing
''                   Title$ = "Completed"
''                   msg$ = Str$(items) + " items sent to printer" + Chr$(13)
''                   msg$ = msg$ + "    Printed OK ?  Y/N  (Esc to abort) "
''                   ans$ = ""
''                   setinput 0, k
''                   k.helpnum = 1350
''                   askwin Title$, msg$, ans$, k
''                   If ans$ = "Y" Then
''                           printedok = True
''                       Else
''                           k.escd = True
''                       End If
''                   If k.timd Then popmessagecr "!n!i", "Printing must be confirmed"
''               Loop Until Not k.timd  '25Oct92 ASC
''
''               If printedok Then        '4 update file
''                        Screen.MousePointer = STDCURSOR
''                        ClearStatusDisplay
''                        DisplayStatus "Processing..."
''                        cont& = 1  'read file again
''                        binarysearchidx "", dispdata$ + "\ledger.idx", False, cont&, found&
''                        Do While found&
''                           getorder ord, found&, 4, True
''                           'If ord.status = "7" Then ord.status = "8"
''                           If ord.status = "7" Then                           '29Jan04 TH Replaced above line
''                              ord.status = "8"                                '    "
''                              ord.CodingSlipdate = Format$(Now, "ddmmyyyy")   '    "   Now writes date to fields
''                           End If                                             '    "
''                           PutOrder ord, found&
''                           binarysearchidx "", dispdata$ + "\ledger.idx", False, cont&, found&
''                        Loop
''                        MainScreen.LstDisplay.Visible = False
''                   End If
''            End If
''
''   Loop Until printedok Or k.escd
''
''   binarysearchidx "", "", False, False, False
''   Screen.MousePointer = STDCURSOR

End Sub
Sub printledgerSQL()
'---Print ledger output (could also be used to connect to ledger in future)---
'17Jan94 CKJ Procedure re-written
' 1 find all items, make index, sort index
' 2 print all items
' 3 confirm printing
' 4 update file
'29Dec97 EAC Use Stores drug description
'14Jan98 EAC print batch total at end of coding slip
'07Apr98 CFY printledger: Fiddle to stop the rtf file that is built up causing hi-edit to blow up with an 'stack overflow' error.
'                         Although hiedit no longer complains, I still can't get the correct fonts to display in the main [data]
'                         rtf.
'08May98 CFY Now deducts credit items from the total amount rather than adding
'06Aug98 SF  Changed formatting so all order details will fit onto one line
'            (suggest [data] section kept at Arial 8).
'            Now only uses one RTF file: "csliptop.rtf".
'            Now kills temp file.
'12Aug98 TH  Code to deal with negative values (in total reconciliations and discounts)
'            (Pounsandpence not designed to take negative values)
'11Feb99 TH  Ensure credit prices are printed as negative
'11Oct99 CKJ Removed Findsupplier
'26Jan00 SF  now prints reconciliation diffs on both cost lines as was causing incorrect totals being printed
'12Apr00 CFY Parameter added to wsspool call
'20Oct00 JN  Added code to pick up new, pre-calculated VAT Amounts
'02Jul01 JKU/EAC Amendments and fixes to enable proper working with modifications and fixes made to invoice reconciliation routine.
'21Feb02 JKU Changed IIf to IFF
'01Jun02 All/CKJ corrected fileno to filno
'13May04 CKJ alternative collation sequence \winord.ini [defaults] CodingSlipsInSupplierOrder="Y" default ="N"
'14sep06 TH  moved section as it forced the splitting of coding slips out of sequence (#SC-06-0861)
'10Sep08 TH (F0033030) Removed the fenceposts , sorry

Dim temp$, RTFTxt$, data1$, data2$
Dim desc As String * 35
Dim success% '', foundsup%
Dim startposn&
Dim batchcost!, batchvat!  '14Jan98 EAC print batch total at end of coding slip
Dim copyOfData1$, vstartposn&          '06Aug98 SF added
Dim numforledger As Integer, pointer&, fil As Integer, idxlen As Integer, X&, cred$, finsch$, FILE$, filno As Integer, endposn&, Items As Integer, totalcost!, totalincvat! '01Jun02 All/CKJ
Dim printtop As Integer, FirstPrint As Integer, cont&, found&, credit As Integer, schnext$, foundnext&, LineCost$, lineincvat$, gap$, title$, msg$, ans$, printedok As Integer '01Jun02 All/CKJ
Dim blnSortBySupplier As Integer
Dim intSubtotalChars As Integer
''Dim objdata As clsDataAccess
Dim rsCodingSlip As ADODB.Recordset
Dim strParams As String
Dim strPreviousSup As String
Dim strPreviousNum As String
Dim strPreviousInvoiceNum As String
Dim strPreviousCredit As String



   Screen.MousePointer = HOURGLASS
   numforledger = 0
   ''getnumofords 4, pointer&, False    'was 7
   ''fil = FreeFile
   ''Open dispdata$ + "\ledger.idx" For Binary Access Read Write Lock Read Write As #fil
   blnSortBySupplier = TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "CodingSlipsInSupplierOrder", 0))
   ''If blnSortBySupplier Then idxlen = 24 Else idxlen = 31                                      '   "
   ''putidxline fil, 1, idxlen, pad$(Format$(idxlen - 7), idxlen - 7), 0, False                  '   "
   ''putidxline fil, 2, idxlen, Space$(idxlen - 7), 0, False

   ''For x& = 2 To pointer&        '1 find all items, make index, sort index
   ''   getorder ord, x&, 4, False  'was 7
   ''   If ord.status = "7" Then
   ''      numforledger = numforledger + 1
   ''      If Sgn(Val(ord.qtyordered)) = -1 Then cred$ = "C" Else cred$ = "I"
   ''      finsch$ = "    "
''         RSet finsch$ = Trim$(ord.num)
''         If blnSortBySupplier Then
''            putidxline fil, numforledger + 2, idxlen, cred$ & ord.supcode & finsch$ & ord.code, x&, False
''         Else
''            putidxline fil, numforledger + 2, idxlen, cred$ & finsch$ & ord.invnum & ord.code, x&, False
''         End If
''      End If
''   Next
   
'   putidxline fil, 1, idxlen, pad$(Format$(idxlen - 7), idxlen - 7), (numforledger), False     '   "
'
'   Close fil
'   Screen.MousePointer = STDCURSOR
'
'   If Not k.escd Then
'      sortindex "", dispdata$ + "\ledger.idx"
'   End If
   
   Screen.MousePointer = HOURGLASS
   Do                         '2 print all items
      'Make spool file for printing
      MakeLocalFile FILE$
      filno = FreeFile
      Open FILE$ For Binary Access Write Lock Read Write As #filno         ' for spooling ...
      'GetTextFile dispdata$ & "\csliptop.rtf", RTFTxt$, success       '06Aug98 SF
      GetRTFTextFromDB dispdata$ & "\csliptop.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - " & dispdata$ & "\CSLIPTOP.RTF" & cr & "Cannot continue..."    '06Aug98 SF
         Close #filno
         Exit Sub
      End If
      vstartposn& = InStr(RTFTxt$, "[DO_NOT_TOUCH_THIS_DATA_ITEM]")
      If vstartposn& = 0 Then
         popmessagecr "Error", "need to add [DO_NOT_TOUCH_THIS_DATA_ITEM] into " & dispdata$ & "\csliptop.rtf"
         Close #filno
         Exit Sub
      End If
   
      startposn& = InStr(RTFTxt$, "[data]")
      endposn& = InStr(startposn&, RTFTxt$, "[data]") + Len("[data]")
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "FinancePrintFix", 0)) Then  '27Mar06 TH Ultra caution. To be removed after UAT !
         data1$ = Mid$(RTFTxt$, vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]"), startposn& - (vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]")))
      Else
         data1$ = Mid$(RTFTxt$, vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]"), startposn& - (vstartposn& + Len("[DO_NOT_TOUCH_THIS_DATA_ITEM]")) - Len("[data]")) '06Aug98 SF
      End If
      data2$ = Mid$(RTFTxt$, endposn& + 1)
      copyOfData1$ = data1$

      temp$ = Left$(RTFTxt$, vstartposn& - 1)
      Put #filno, , temp$

      Items = 0
      totalcost! = 0
      totalincvat! = 0
      printtop = True
      FirstPrint = True
   
'      cont& = 1  'read file in order
'      finsch$ = ""
'      binarysearchidx finsch$, dispdata$ + "\ledger.idx", 1, cont&, found&
      ''If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
      ''GET THE REQUIRED DATA HERE SORTED AS PER ORIGINAL IDX FILE
      ''Use the Boolean to get a different sp if necessary
      ''Set objdata = New clsDataAccess
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite))
      'set rsCodingslip =
      If blnSortBySupplier Then
         Set rsCodingSlip = gTransport.ExecuteSelectSP(g_SessionID, "pCodingSlipsSupplierOrder", strParams)
      Else
         Set rsCodingSlip = gTransport.ExecuteSelectSP(g_SessionID, "pCodingSlips", strParams)
      End If
      batchvat! = 0
      batchcost! = 0
      If rsCodingSlip.RecordCount > 0 Then
         rsCodingSlip.MoveFirst
         ''Do While found&
         strPreviousSup = GetField(rsCodingSlip!supcode)
         strPreviousNum = GetField(rsCodingSlip!num)
         strPreviousInvoiceNum = GetField(rsCodingSlip!invnum)
         strPreviousCredit = GetField(rsCodingSlip!credit)
         Do While Not rsCodingSlip.EOF
            Items = Items + 1
            schnext$ = ""   ' check next entry too
            ''binarysearchidx schnext$, dispdata$ + "\ledger.idx", 1, cont&, foundnext&
            ''getorder ord, found&, 4, False
            If Left$(GetField(rsCodingSlip!credit), 1) = "C" Then credit = True Else credit = False
            ord = FillOrdFromRS(rsCodingSlip, "WReconcil")
            
            'Moved from below 14sep06 TH
            If (strPreviousSup <> GetField(rsCodingSlip!supcode)) Or (strPreviousNum <> GetField(rsCodingSlip!num)) Or (strPreviousInvoiceNum <> GetField(rsCodingSlip!invnum)) Or (strPreviousCredit <> GetField(rsCodingSlip!credit)) Then
                PrintLedgerTail filno%, finsch$, printtop%, totalcost!, totalincvat!
                If Not FullPageCS Then FirstPrint = True
            End If
            
            If printtop Then
               data1$ = copyOfData1$
               If Not FirstPrint Then
                  temp$ = "[ff]"
                  PrinterParse temp$
                  data1$ = temp$ & data1$
               End If
               replace data1$, "[today]", Format$(Now, "dd-mm-yyyy"), 0
               getsupplier (ord.supcode), 0, 0, sup
   
               replace data1$, "[supplier]", Trim$(sup.name), 0
               replace data1$, "[orderno]", Trim$(ord.num), 0            '
               If credit Then                                            '
                  replace data1$, "[paytext]", "", 0                    '
                  replace data1$, "[invoicetext]", "Credit Note No.", 0 '
                  replace data1$, "[ordertext]", "Return No.", 0        '
               Else                                                     '
                  replace data1$, "[paytext]", "Payment Date:", 0       '
                  replace data1$, "[invoicetext]", "Invoice No.", 0     '
                  replace data1$, "[ordertext]", "Order No.", 0         '
               End If                                                   '
               replace data1$, "[invoiceno]", Trim$(ord.invnum), 0      '
               replace data1$, "[paydate]", Trim$(ord.paydate), 0       '
               replace data1$, "[ordertext]", "Order No.", 0            '
               FillHeapSupplierInfo gPRNheapID, sup, 0   '25Jan05 TH Added '17Nov05 TH Merged
               ParseItems gPRNheapID, data1$, 0          '    "

               Put #filno, , data1$                                     '
               printtop = False                                         '
               FirstPrint = False                                       '
               PrintLedgerDescriptor filno, finsch$
            End If
    
            d.SisCode = ord.Code
            getdrug d, 0, 0, False        '01Jun02 All/CKJ fnd never used
   
            desc$ = d.drugDescription   ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
            plingparse desc$, "!"
      
            LineCost$ = Str(Val(ord.VATInclusive) - Val(ord.VATAmount))
            LineCost$ = Format$(LineCost$, "#0.00;-#0.00")
            
            totalcost! = totalcost! + Val(LineCost$)
            If Not credit Then
               batchcost! = batchcost! + Val(LineCost$)                       '14Jan98 EAC add batch totals
            Else                                                              '08May98 CFY Added
               batchcost! = batchcost! - Val(LineCost$)                       '        "
            End If                                                            '        "
               
            lineincvat$ = Format$(ord.VATInclusive, "#0.00;-#0.00")
               
            totalincvat! = totalincvat! + Val(lineincvat$)
            If Not credit Then                                                   '08May98 CFY Added
               batchvat! = batchvat! + Val(lineincvat$)                       '14Jan98 EAC add batch totals
            Else                                                              '08May98 CFY Added
               batchvat! = batchvat! - Val(lineincvat$)                       '        "
            End If                                                            '        "
            If Val(ord.outstanding) > 0 Then gap$ = "*" Else gap$ = ""        '06Aug98 SF
    
            If credit Then LineCost$ = Str$(Val(LineCost$) * credit)           '11Feb99 TH  Ensure credit prices are printed as negative costs
            If credit = True Then lineincvat$ = Str$(Val(lineincvat$) * credit) '   "
   
            temp$ = ord.supcode & " " & Left$(ord.paydate, 2) & "/" & Mid$(ord.paydate, 3, 2) & "/" & Right$(ord.paydate, 2)
            temp$ = temp$ & " " & ord.Code & " " & Trim$(desc$) & gap$ & "[Tab]"    '06Aug98 SF
            temp$ = temp$ & Trim$(ord.received)                               '06Aug98 SF
            temp$ = temp$ & " x " & Trim$(d.convfact) & "[Tab]" & Trim(LCase$(d.PrintformV)) & "[Tab]"   '06Aug98 SF
            temp$ = temp$ & Iff(Trim(d.ledcode) = "", "?", Trim(d.ledcode)) & "[Tab]" & Trim(LineCost$)    '02Jul01 JKU/EAC Replaced    '21Feb02 JKU Replaced
            temp$ = temp$ & "[Tab]" & Trim(lineincvat$) & " (" & d.vatrate & ")" '17May05 TH missed off somehow
            temp$ = temp$ & "[cr]"
            PrinterParse temp$
            Put #filno, , temp$
               
            intSubtotalChars = idxlen - 14                                                '   "        17 for old style, 10 for new style collation
            '''If Left$(finsch$, intSubtotalChars) <> Left$(schnext$, intSubtotalChars) Or foundnext& = 0 Then       '  "
               '14sep06 TH removed following four lines as they forced the splitting of coding slips out of sequence (#SC-06-0861)
''            If (strPreviousSup <> GetField(rsCodingSlip!supcode)) Or (strPreviousNum <> GetField(rsCodingSlip!num)) Or (strPreviousInvoiceNum <> GetField(rsCodingSlip!invnum)) Or (strPreviousCredit <> GetField(rsCodingSlip!credit)) Then
''                PrintLedgerTail filno%, finsch$, printtop%, totalcost!, totalincvat!
''                If Not FullPageCS Then FirstPrint = True
''            End If
            finsch$ = schnext$
            ''If Left$(finsch$, 1) = "C" Then credit = True Else credit = False
            If Left$(GetField(rsCodingSlip!credit), 1) = "C" Then credit = True Else credit = False
            ''found& = foundnext&
            strPreviousSup = GetField(rsCodingSlip!supcode)
            strPreviousNum = GetField(rsCodingSlip!num)
            strPreviousInvoiceNum = GetField(rsCodingSlip!invnum)
            strPreviousCredit = GetField(rsCodingSlip!credit)
            rsCodingSlip.MoveNext
            
         Loop
         '31Aug08 TH Added to ensure final sub total on single lines over a page (F19417)
         If Items > 1 Then
            '10Sep08 TH (F0033030) Removed the fenceposts , sorry
            'If (strPreviousSup <> GetField(rsCodingSlip!supcode)) Or (strPreviousNum <> GetField(rsCodingSlip!num)) Or (strPreviousInvoiceNum <> GetField(rsCodingSlip!invnum)) Or (strPreviousCredit <> GetField(rsCodingSlip!credit)) Then
                PrintLedgerTail filno%, finsch$, printtop%, totalcost!, totalincvat!
            '    If Not FullPageCS Then FirstPrint = True
            'End If
         End If
         '----------
      End If
      ''rsCOdingSlip.Close           'Persist these as they are the basis of the update below
      ''Set rsCOdingSlip = Nothing
      
      temp$ = "{\par}"
      Put #filno, , temp$
      replace data2$, "[totalexvat]", Trim$(money$(5)) & Format$(batchcost!, "0.00"), 0             '06Aug98 SF
      replace data2$, "[totalincvat]", Trim$(money$(5)) & Format$(batchvat!, "0.00"), 0             '
      replace data2$, "[totalvat]", Trim$(money$(5)) & Format$(batchvat! - batchcost!, "0.00"), 0   '
      Put #filno, , data2$

      Close #filno
    
      Screen.MousePointer = STDCURSOR

      If Items = 0 Then
         Kill FILE$    'no items printed
         popmessagecr "!n!bCoding Slips", "No items printed"
         k.escd = True
      Else
         WSspool FILE$, "Coding Slips", 1, True, False, "CodingSlip"
         Do                      '3 confirm printing
            title$ = "Completed"
            msg$ = Str$(Items) + " items sent to printer" + Chr$(13)
            msg$ = msg$ + "    Printed OK ?  Y/N  (Esc to abort) "
            ans$ = ""
            setinput 0, k
            k.helpnum = 1350
            askwin title$, msg$, ans$, k
            If ans$ = "Y" Then
                printedok = True
            Else
                k.escd = True
            End If
            If k.timd Then popmessagecr "!n!i", "Printing must be confirmed"
         Loop Until Not k.timd
   
         If printedok Then        '4 update file
            Screen.MousePointer = STDCURSOR
            ClearStatusDisplay
            DisplayStatus "Processing..."
            ''cont& = 1  'read file again
            ''binarysearchidx "", dispdata$ + "\ledger.idx", False, cont&, found&
            If rsCodingSlip.RecordCount > 0 Then
               rsCodingSlip.MoveFirst
               ''Do While found&
               ''SQL BEGIN TRANSACTION HERE
               Do While Not rsCodingSlip.EOF
                  If rsCodingSlip!WReconcilID > 0 Then
                     getorder ord, rsCodingSlip!WReconcilID, 4, True
                     ord = FillOrdFromRS(rsCodingSlip, "WReconcil")
                     'SQL LOCK HERE ON THE RECONCILID
                     If ord.status = "7" Then
                        ord.status = "8"
                        ord.CodingSlipdate = Format$(Now, "ddmmyyyy")
                     End If
                     found& = PutOrder(ord, rsCodingSlip!WReconcilID, "WReconcil")
                     ''binarysearchidx "", dispdata$ + "\ledger.idx", False, cont&, found&
                  End If
                  rsCodingSlip.MoveNext
               Loop
               ''SQL COMMIT OR ROLLBACK TRANSACTION HERE
               MainScreen.LstDisplay.Visible = False
            End If
         End If
      End If
   
   Loop Until printedok Or k.escd
   
   ''binarysearchidx "", "", False, False, False
   Screen.MousePointer = STDCURSOR
   
Cleanup:
On Error Resume Next
rsCodingSlip.Close
Set rsCodingSlip = Nothing

On Error GoTo 0


End Sub


Sub PrintLedgerDescriptor(filno%, finsch$)
'06Aug98 SF changed formatting
'11Oct99 CKJ Removed Findsupplier

Dim temp$
   
   If Left$(finsch$, 1) = "C" Then            ' CREDIT
         'temp$ = "Supp. Date     NSVcode Description" + Space$(24) + "Qty retd x Pack size   Ledger   " & money(5) & "Value"                                '06Aug98 SF replaced
         temp$ = " Supp.Date     NSVcode Description" & "[Tab]" & "QtyxPack size" & "[Tab]" & "Ledger" & "[Tab]" & Trim$(money(5)) & "Value" & "[Tab]"  '06Aug98 SF
         
         'If TransLogVAT Then temp$ = temp$ & "   " & money(5) & " inc " & money(9)       '05Aug98 SF replaced
         If TransLogVAT Then temp$ = temp$ & Trim$(money(5)) & " inc " & Trim$(money(9))  '05Aug98 SF
      Else
         'temp$ = "Supp. Pay date NSVcode Description" + Space$(24) + "Qty recd x Pack size   Ledger   " & money(5) & " Cost"                                '06Aug98 SF replaced
         temp$ = " Supp.Pay date NSVcode Description" & "[Tab]" & "QtyxPack size" & "[Tab]" & "Ledger" & "[Tab]" & Trim$(money(5)) & " Cost" & "[Tab]"  '06Aug98 SF
         
         'If TransLogVAT Then temp$ = temp$ & "   " & money(5) & " inc " & money(9)       '05Aug98 SF replaced
         If TransLogVAT Then temp$ = temp$ & Trim$(money(5)) & " inc " & money(9)      '05Aug98 SF
      End If

   'temp$ = temp$ & "[cr]" & String$(120, 45) & "[cr]"   '06Aug98 SF replaced
   temp$ = temp$ & "[cr]" & String$(119, 95) & "[cr]"    '06Aug98 SF
   PrinterParse temp$
   Put #filno, , temp$

End Sub

Sub PrintLedgerTail(filno%, finsch$, printtop%, totalcost!, totalincvat!)

'06Aug98 SF Changed formatting, now writes our directly to already opened file.
'08Jul01 JKU/SF Changed use of poundsandpence to format$(). The PoundsAndPence function is inappropriate here because
'            we are displaying figures for accountants and therefore, every penny counts!


Dim temp$, total$

    'GetTextFile dispdata$ + "\cslipbot.rtf", rtftxt$, success                      '04Aug98 SF removed
    '  If Not success Then                                                          '
    '        popmessagecr "Error", "There was a problem reading the RTF layout file - CSLIPBOT.RTF"   '
    '        Exit Sub                                                               '
    '     End If                                                                    '
    '                                                                               '
    'If Not success Then                                                            '
    '        popmessagecr "Error", "Could not open the layout file PICKTOP.RTF"     '
    '        Exit Sub                                                               '
    '    End If                                                                     '
    '                                                                               '
    'If Left$(rtftxt$, 6) = "{\rtf1" Then rtftxt$ = Mid$(rtftxt$, 2)                '
    'striprtf rtftxt$                                                               '
                                                                                    '
    'startpos& = 1                                                                  '
                                                                                    '
    'startposn& = InStr(rtftxt$, "[data]")                                          '
    'endposn& = InStr(startposn& + 1, rtftxt$, "]")                                 '
    'temp$ = Mid$(rtftxt$, 1, startpos& - 1)                                        '
                                                                                    '
    'PrinterParse temp$                                                             '
    'Put #filno, , temp$                                                            '
                                                                                    
    total$ = Str$(totalcost!)
    
    '08Jul01 JKU/SF Changed to avoid < .01 display
    'Was: poundsandpence Total$, False
    total$ = Format$(total$, "#0.00;-#0.00")
    '---08Jul01 JKU/SF
    
    If Left$(finsch$, 1) = "C" Then              ' CREDIT
            'temp$ = "Total value           £" + total$ & "[cr]"
            'temp$ = "Total value[tab]" & money(5) + total$ & "[cr]"           '06Aug98 SF replaced
            temp$ = "Total value " & Trim$(money(5)) & Trim$(total$) & "[cr]"  '06Aug98 SF
            If TransLogVAT Then
                total$ = Str$(totalincvat!)
                
                '08Jul01 JKU/SF Changed to avoid < .01 display
                'Was: poundsandpence Total$, False
                total$ = Format$(total$, "#0.00;-#0.00")
                '---08Jul01 JKU/SF
                
                'temp$ = temp$ & "Total value inc. VAT  £" + total$ & "[cr]"
                'temp$ = temp$ & "Total value inc. " & money(5) & "[tab]" & money(5) + total$ & "[cr]"  '06Aug98 SF replaced
                temp$ = temp$ & "Total value inc.  " & Trim$(money(5)) & Trim$(total$) & "[cr]"         '06Aug98 SF
            End If
        Else
            'temp$ = "Total cost           £" + total$ & "[cr]"
            'temp$ = "Total cost[tab]" & money(5) + total$ & "[cr]"           '06Aug98 SF replaced
            temp$ = "Total cost " & Trim$(money(5)) & Trim$(total$) & "[cr]"  '06Aug98 SF

            If TransLogVAT Then
                total$ = Str$(totalincvat!)
                
                '08Jul01 JKU/SF Changed to avoid < .01 display
                'Was: poundsandpence Total$, False
                total$ = Format$(total$, "#0.00;-#0.00")
                '---08Jul01 JKU/SF
                
                'temp$ = temp$ & "Total cost inc. VAT  £" + total$ & "[cr]"
                'temp$ = temp$ & "Total cost inc. " & money(5) & "[tab]" & money(5) + total$ & "[cr]"   '06Aug98 SF replaced
                temp$ = temp$ & "Total cost inc.  " & Trim$(money(5)) & Trim$(total$) & "[cr]"          '06Aug98 SF
            End If
        End If
    
    temp$ = "[cr]" & temp$    '06Aug98 SF added
    PrinterParse temp$
    Put #filno, , temp$

    'temp$ = Mid$(rtftxt$, endposn& + 1, Len(rtftxt$) - (endposn& + 1))    '06Aug98 SF removed
    'PrinterParse temp$                                                    '
    'Put #filno, , temp$                                                   '
                                                                           '
   'temp$ = "{\par}"                                                       '
   'Put #filno, , temp$                                                    '

    printtop = True
    totalcost! = 0
    totalincvat! = 0

End Sub

''Sub savesupidx()
'''-----------------------------------------------------------------------------
'''
'''  Read supplier file sequentially & build unsorted index from scratch.
'''
'''mods
'''  needs to know idxminlen, which is defined in IDX module - hard coded = 7
'''  filename is also hard coded at the moment
'''-----------------------------------------------------------------------------
''
''Dim fil As Integer, pointer&, x&   '01Jun02 All/CKJ
''
''   On Error Resume Next
''   Do
''      Err = 0
''      fil = FreeFile
''      Open dispdata$ + "\supfile.idx" For Binary Lock Read Write As #fil
''      'If Err = 70 Then
''      '      waitforkeyorticks 4, (dummy$)    ' 1/5 second approx
''      '   ElseIf Err Then
''      '      'VIEW PRINT
''      '      popmessagecr "", "Program halted in SaveSupIdx with error" & Err
''      '      Close
''      '      End
''      '   End If
''      Err70msg Err, "Supplier File"
''   Loop While Err
''   On Error GoTo 0
''
''   GetPointer dispdata$ + "\supfile.v5", pointer&, 0
''   putidxline fil, 1, 7 + 5, "5", pointer& - 1, False    '5    00000xx<CR>'
''   putidxline fil, 2, 7 + 5, "", 0, False                '     0000000<CR>'
''
''   For x& = 2 To pointer&
''      'getsupplier (dummy$), (X&), 0, 0, sup      '01Jun02 All/CKJ
''      getsupplier "", (x&), 0, sup             '01Jun02 All/CKJ removed dummy$
''      putidxline fil, x& + 1, 7 + 5, sup.Code, x&, False  '0001 0000004<CR>'
''   Next
''   Close #fil
''
''End Sub

Sub ShowOrders(tempedittype%)
' 9Apr93 Proc written. Send Edittype=3,4,5 for immediate display, any other
'        value asks for category wanted.
'17Feb98 EAC edittype now global, replaced with tempedittype%
'            made more Windows standard by use of radio buttons

'Needs DOING For SQL Still !!!!!!!!!!!!

Dim des1$, des2$, des3$, des$, ans$, title$, foundone As Integer, finentries As Integer, lastord$, cont&, found&, msg$    '01Jun02 All/CKJ

   des1$ = "Orders raised but not received"
   des2$ = "Orders received or reconciled "
   des3$ = "Requisitions"
   
   Select Case tempedittype
      Case 3: des$ = des1$
      Case 4: des$ = des2$
      Case 5: des$ = des3$
      Case Else
         frmoptionset -1, "Order Number Enquiry - Select category"
         frmoptionset 1, des1$
         frmoptionset 1, des2$
         frmoptionset 1, des3$
         frmoptionshow "1", ans$
         frmoptionset 0, ""

         If Val(ans$) Then ShowOrders Val(ans$) + 2
         Exit Sub
      End Select

   title$ = des$ + "  (OrderNum-Lines)"
   foundone = False
   finentries = 0
   lastord$ = ""
   cont& = 1
   Do
      'SQL Removed scanordreqindex tempedittype, "", cont&, found&
      If found& Then
            getorder ord, (found&), tempedittype, False
            If ord.status <> "D" And ord.status <> "R" Then
                  If ord.num = lastord$ Then
                        finentries = finentries - 1
                     Else
                        If Len(lastord$) Then msg$ = msg$ & Left$(Str$(finentries) + "   ", 3) & cr$
                        'If POS(0) > 72 Then Print
                        msg$ = msg$ + Right$("     " + Trim$(ord.num), 5)
                        finentries = -1
                        lastord$ = ord.num
                     End If
               End If
         End If
   Loop While found&
   If Len(lastord$) Then msg$ = msg$ + Str$(finentries)
   popmessagecr title$, msg$

End Sub

Sub StockValAdjust(SiteNumber As Integer)
'-----------------------------------------------------------------------------
' Adjust total stock value for a drug, optionally storing supplier code
'26Jan94 CKJ Added clearing of losses/gains
'17Jun94 CKJ Added reason file lookup
'29Dec97 EAC Use Stores drug description
'11Feb98 EAC Restore negative signs on screen
'            Correct tabs so that data lines up.
'17May99 AE  Changed formatting of d.stocklvl on screen
'10Jan02 TH  Changed formatting of stocklevel and also the stockvalue figures on the screen (#46714)
'15Jan02 TH  Added time for recording in orderlog (#53214)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to sitenumber param
'10Jul11 TH  Added switch to allow if required adjustments when stock level is zero or negative (F0118236)
'27Jun13 TH  Ensure stock values sre correctly logged (TFS 67262)
'-----------------------------------------------------------------------------

Dim title$, adjnsv$, foundPtr As Long, msg$, desc$, pform$, packs$, cost$, stkval!, finmsg$, adjust$, zeroLG As Integer, ans$, stockvalue!, OK As Integer, supcode$       '01Jun02 All/CKJ  '01Jun02 ALL/ATW
Dim reason$, escd%, dateord$ '', adjnum   As Integer        'foundsup As Integer,
Dim blnFound As Integer     '01Jun02 ALL/ATW Split found to blnFound and foundPtr
Dim lngFoundSup As Long
Dim lngAdjnum As Long
Dim strDesc As String  '08Dec04 TH
Dim blnDrugSaved As Boolean   '27Jun13 TH Added


   blnDrugSaved = False    '27Jun13 TH Added

   title$ = "Adjustment for " & Trim$(hospabbr$)
   
   adjnsv$ = ""
   EnterDrug adjnsv$, "Stock Value Adjustment"
   If k.escd Then Exit Sub
         
   findrdrug adjnsv$, True, d, False, blnFound, False, False, False
   If blnFound Then ' <> 0 Then   '01Jun02 ALL/ATW
      desc$ = d.drugDescription ' desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
      plingparse desc$, "!"
      If (Val(d.stocklvl) < 0) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "StopNegativeStockAdjustments", 0)) Then  '10Jul11 TH (F0118236) Added switch
         popmessagecr ".Stock Value Adjustment", "Stock level for " & Trim$(desc$) & " is negative. Cannot continue with adjustment"
      ElseIf Val(d.stocklvl) = 0 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "StopZeroStockAdjustments", 0)) Then  '10Jul11 TH (F0118236) Added switch
         popmessagecr ".Stock Value Adjustment", "Stock level for " & Trim$(desc$) & " is zero. Cannot continue with adjustment"
      Else
         ' stkval = d.cost * d.stocklvl + d.lossesgains
         '          -------------------   -------------
         '          d.convfact * 100          100
         getdrug d, (False), foundPtr&, True ' <== Lock   '01Jun02 ALL/ATW
         msg$ = "Price/stock value adjustment for item " & d.SisCode & Chr$(13)
         ''desc$ = GetStoresDescription()
         plingparse desc$, "!"
         msg$ = msg$ + desc$ + Chr$(13) + Chr$(13)
         pform$ = LCase$(Trim$(d.PrintformV))
         packs$ = " x " + Trim$(d.convfact) + " " + pform$
         msg$ = msg$ + "Stock level          " + FormatVal$(d.stocklvl, 2, 8) + " " + pform$ + Chr$(13) + Chr$(13) '15 Apr99 AE changed trim$ to FormatVal$   '10Jan02 TH Changed to 8 sig places
         msg$ = msg$ + "Current issue cost   "
         cost$ = Str$(Val(d.cost) / 100)
         poundsandpence cost$, False
         msg$ = msg$ + "" & money(5) & cost$ + " for 1" + packs$ + Chr$(13)
         msg$ = msg$ + "Losses/gains pending "
         msg$ = msg$ + "" & money(5) & posnegmoney$(d.lossesgains / 100) + Chr$(13)
         msg$ = msg$ + "                     --------" + Chr$(13)
         msg$ = msg$ + "Stock value          "
         stkval! = Val(d.cost) * Val(d.stocklvl) / Val(d.convfact) + d.lossesgains
         stkval! = stkval! / 100    ' to œ
         msg$ = msg$ + "" & money(5) & Format$(Str$(stkval!), "#0.00;-#0.00") + Chr$(13) + Chr$(13) '10Jan02 TH changed formatting to avoid poundsandpence
         finmsg$ = msg$
         'G/L present, some stock, price would remain +ve
         If d.lossesgains <> 0 And Val(d.stocklvl) > 0 And (Val(d.cost) * (Val(d.stocklvl) / Val(d.convfact)) + d.lossesgains) > 0 Then
            msg$ = msg$ + Chr$(13) + "  (Enter zero to reallocate gains/losses)" + Chr$(13)
         End If

         msg$ = msg$ + "  Enter adjustment to stock value   "
         setinput 0, k
         k.escd = False
         k.Max = 8
         ''k.begline = True
         ''k.wipedef = True
         ''k.helpnum = 0
         'k.nobrackets = True
         adjust$ = ""
         inputwin title$, msg$, adjust$, k
         zeroLG = False
         msg$ = ""

         If Not k.escd And Val(adjust$) = 0 Then
            If d.lossesgains <> 0 Then
               ans$ = "N"
               setinput 0, k
               k.helpnum = 0
               Confirm "Move Losses/Gains to Issue Price", "zero losses/gains by adding to issue price", ans$, k
               If ans$ = "Y" And Not k.escd Then zeroLG = True
            Else
               popmessagecr "!n!iZero Losses/Gains", "Losses/Gains is already zero, no changes made"
            End If
         End If

         If Not k.escd And (Val(adjust$) <> 0 Or zeroLG = True) Then
            dcopy = d
            If zeroLG Then
               Select Case Val(d.stocklvl)
                  Case 0
                     k.escd = True
                     msg$ = "Stock level is zero"
                  Case Is < 0
                     k.escd = True
                     msg$ = "Stock level is negative"
                  Case Else ' > 0
                     stockvalue! = Val(d.cost) * (Val(d.stocklvl) / Val(d.convfact))
                     d.cost = LTrim$(Str$((stockvalue! + d.lossesgains) / (Val(d.stocklvl) / Val(d.convfact))))
                     d.lossesgains = 0
                     If Val(d.cost) <= 0 Then
                        k.escd = True
                        popmessagecr "ERROR", "Price would be zero or negative"
                     End If
               End Select
            Else
               ModifyPrice d, Str$(Val(adjust$) * 100)
            End If

            finmsg$ = "  Revised issue cost" & TB$ & TB$
            cost$ = Str$(Val(d.cost) / 100)
            poundsandpence cost$, False
            finmsg$ = finmsg$ + Format$(Val(cost$), "0.00") + " for 1" + packs$ + Chr$(13)

            '1FEb98 EAC format$ was removing the minus from the values
            'finmsg$ = finmsg$ + "  Revised losses/gains" & tb$ + Format$(Val(posnegmoney$(d.lossesgains / 100)), "0.00") + Chr$(13)
            finmsg$ = finmsg$ + "  Revised losses/gains" & TB$ + posnegmoney$(d.lossesgains / 100) + Chr$(13)
            '---

            'printwcr Space$(35) + "ÄÄÄÄÄÄÄÄÄ"
            finmsg$ = finmsg$ + TB$ & TB$ & "---------" + Chr$(13)      '11feb98 EAC added removed one tab
            finmsg$ = finmsg$ + "  Revised stock value" & TB$
            '1FEb98 EAC format$ was removing the minus from the values
            'finmsg$ = finmsg$ + Format$(Val(posnegmoney$((Val(d.cost) * Val(d.stocklvl) / Val(d.convfact) + d.lossesgains) / 100)), "0.00") + Chr$(13) + Chr$(13)
            finmsg$ = finmsg$ + posnegmoney$((Val(d.cost) * Val(d.stocklvl) / Val(d.convfact) + d.lossesgains) / 100) + Chr$(13) + Chr$(13)
            '---

            If Not k.escd And Not zeroLG Then
               OK = False
               Do
                  supcode$ = ""
                  setinput 0, k
                  '''k.ret = True
                  'asksupplier supcode$, StockValCode%, StockValDisplay%, "Enter Supplier Code", False, sup
                  asksupplier supcode$, StockValCode%, StockValDisplay$, "Enter Supplier Code", False, sup, False '15Nov12 TH Added PSO param
                  If UCase$(supcode$) = "NONE" Then: supcode$ = ""
                  If Not k.escd And Trim$(supcode$) <> "" Then: getsupplier supcode$, 0, lngFoundSup, sup
                  If lngFoundSup = 0 And Trim$(supcode$) <> "" Then popmessagecr "!n!iWarning", "Supplier code '" + supcode$ + "' not found"
               Loop Until lngFoundSup > 0 Or supcode$ = ""
               k.escd = False
               finmsg$ = finmsg$ + "  Supplier code (if known)" & TB$ & TB$ & supcode$ & Chr$(13)      '11Feb98 EAC added one tab
            End If

            If Not k.escd And Not zeroLG Then
               msg$ = "  Order number  (if known)"
               inputwin title$, msg$, ordernum$, k
               'enterorder -3, True
               finmsg$ = finmsg$ + msg$ & TB$ & TB$ + Trim$(ordernum$) + Chr$(13)      '11FEb98 EAC added one tab and trimmed ordernum$
               k.escd = False  '!!** can't esc here
            End If

            If Not k.escd Then              ' 7Jul94 CKJ Added
               AskReasonCode "adjustment", reason$
               finmsg$ = finmsg$ & Chr$(13) & "  Reason Code : " & TB$ & TB$ & reason$
            End If

            If k.escd Then
               d = dcopy
               If msg$ <> "" Then
                  popmessagecr "Escaped", "Cannot allow this change."
               End If
            Else
               finmsg$ = finmsg$ & Chr$(13) & Chr$(13) & "  Accept revised values?"
               ans$ = ""
               setinput 0, k
               k.helpnum = 0
               strDesc = d.drugDescription  ' strDesc = GetStoresDescription() XN 4Jun15 98073 New local stores description                     '08Dec04 TH Added
               plingparse strDesc, "!"                                '    "
               finmsg$ = Space$(2) & strDesc & crlf & crlf & finmsg$  '    "
               popmsg title$, finmsg$, 4 + 256 + 48, ans$, escd%
               If ans$ = "Y" And Not escd% Then         ' do transaction
                  'dateord$ = thedate$(False, False) '03May98 CKJ Y2K
                  dateord$ = thedate(False, True)    '03May98 CKJ Y2K
                  getorderno -1, lngAdjnum, True
                  'Orderlog LTrim$(Str$(adjnum)), d.siscode, userid$, dateord$, "", "0", "", LTrim$(Str$(Val(Adjust$) * 100)), supcode$, "A", sitenumber, reason$ + " " + ordernum$, d.vatrate  '14Jan94 CKJ VAT '28Jun93 CKJ was d.code '15Jan02 TH Added time (#53214)
                  'Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(adjust$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", ""                          '    "
                  putdrug d '27Jun13 TH Required for the logging of stock values (TFS 67262)
                  blnDrugSaved = True
                  'Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(adjust$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                  Orderlog LTrim$(Str$(lngAdjnum)), d.SisCode, UserID$, dateord$ & thedate(0, -2), "", "0", "", LTrim$(Str$(Val(adjust$) * 100)), supcode$, "A", SiteNumber, reason$ + " " + ordernum$, d.vatrate, "", "", "", "", ord.PSORequestID '03Mar14 TH Added PSORequestID
               Else
                  d = dcopy
               End If
            End If
         End If
         ''putdrugSQL d, foundPtr&    ' <== Unlock   '01Jun02 ALL/ATW
         'putdrug d
         If Not blnDrugSaved Then putdrug d '27Jun13 TH Replaced above as it may already have been saved
      End If
   End If

End Sub

Sub DisplayCreditInfo()
'05May98 CKJ added second line
'29Sep15 TH Tidied up cursor handling and tried to get the correct supplier details on caption where possible (TFS 127190)

Dim creddate$      '01Jun02 All/CKJ
Dim lines() As String
Dim strSupplier  As String
Dim lngFound As Long
Dim strSupplierCode As String

   Edittype = -4
   osite$ = "A"
   enterorder Edittype, False, False
   
   Screen.MousePointer = HOURGLASS
   
   If Not k.escd And ordernum$ <> "A" Then   '22Mar93 CKJ added ordernum
         'creddate$ = thedate$(False, False) '03May98 CKJ Y2K
         If Not InvoicableOrder(Val(ordernum$), False, False) Then
            popmessagecr "", "There are no items awaiting confirmation for credit order number " & Trim$(ordernum$)
            k.escd = True
         Else
            creddate$ = thedate(False, True)    '03May98 CKJ Y2K !!**
            Screen.MousePointer = STDCURSOR  '29Sep15 TH Tidied up
            EnterCreditNote invoicenum$
            Screen.MousePointer = HOURGLASS  '29Sep15 TH Tidied up
         End If
      End If
   
   If Not k.escd Then
         ChangeTable "blank", False  '14Aug12 TH Added Param '13Jan06 TH Added
         Clearprintedorders
         DisplayOrders Edittype, False   '27Jun11 CKJ Removed unused args: ordernum$, , osite$, SiteNumber%, creddate$, ordernum$, OASCcode$(), ORecNo&(), Oordering$()
         strSupplier = ""
         'If Val(ordernum$) <> 0 Then
         '   getsupplier ord.supcode, 0, lngFound, sup '23Jan06 TH Reinstated on different criteria
         '   If lngFound Then                          '      "
         '      strSupplier = "  " & Trim$(sup.name) & " (" & Trim$(sup.Code) & ")"
         '   End If                                    '      "
         'End If
         MainScreen.LblGrid = "Credit Note Confirmation" & cr & "Credit Note: " & invoicenum$ '05May98 CKJ added second line
         If Trim$(UCase$(ordernum$)) <> "A" Then MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " for Order #" & Trim$(ordernum$) '& strSupplier '12Aug05 TH (#82106)
         PositionLblGrid
         MainScreen.lvwMainScreen.SetFocus
         'SQL TODO' MainScreen.lvwMainScreen.SetFocus
         MainLVWHighlightSingleRowByIndex 1
         MainScreenSetTextAndPanels Edittype

         If MainScreen.lvwMainScreen.ListItems.count > 0 Then
            '29Sep15 TH Now we can get the supplier info from the heap if it is there (TFS 127190)
            If TrueFalse(terminal("DisplayStoresPanels", "Y")) And Trim$(UCase$(ordernum$)) <> "A" Then
               Heap 11, gPRNheapID, "sName", strSupplier, 0
               Heap 11, gPRNheapID, "sCode", strSupplierCode, 0
               strSupplier = "  " & Trim$(strSupplier) & " (" & Trim$(strSupplierCode) & ")"
               MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & strSupplier
            Else
               '04Mar06 TH Moved block from above to use correct supplier (not the default !!)
               'getsupplier ord.supcode, 0, lngFound, sup '23Jan06 TH Reinstated on different criteria
               'If lngFound Then                          '      "
               '   strSupplier = "  " & Trim$(sup.name) & " (" & Trim$(sup.Code) & ")"
               '   If Trim$(UCase$(ordernum$)) <> "A" Then MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & strSupplier
               'End If
               '29Sep15 Replaced block above, if we dont have the info on the heap then use the global setting (which may be suspect but its better then before)
               If Trim$(UCase$(ordernum$)) <> "A" Then MainScreen.LblGrid.Caption = MainScreen.LblGrid.Caption & " " & scrnmsg
            End If
         End If
      End If

   Screen.MousePointer = STDCURSOR

End Sub


Sub DisplayOrder(OrderNumber$)


Dim HdrDone%
Dim foundone As Integer, header As Integer, linnum  As Integer, cont&, recnum&, found&, msg$, F As Long, pform$, desc$, temp$, orddat$, supname$ '', foundsup  As Integer  '01Jun02 All/CKJ '01Jun02 ALL/ATW
Dim onum$, text$, tempcost$, recdat$, paydat$     '01Jun02 All/CKJ
Dim strTableName As String
'Dim gTransport    As clsDataAccess
Dim rsOrders    As ADODB.Recordset
Dim strParams As String
Dim blnSecondPassRequired As Boolean
Dim lngFoundSup As Long
Dim blnBigScreen As Boolean
Dim strMessage As String

   blnBigScreen = TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "WideOrdInfoScreen", 0))
   If OrderNumber$ <> "A" And Abs(Edittype) <> 3 Then
      setinput 0, k
      'k.Max = 12
      k.Max = 20 '07Nov05 TH Expanded
      invoicenum$ = ""
      inputwin "Order Enquiry", "Enter invoice number", invoicenum$, k
      If k.escd Then Exit Sub
      
      If Trim$(OrderNumber$) = "" And Trim$(invoicenum$) = "" Then
         popmessagecr "!n!iNo details entered", "Enter an order or invoice number, or enter both."
         Exit Sub
      End If
   End If

   Screen.MousePointer = HOURGLASS

   foundone = False
   header = False
   HdrDone = False
   Edittype = 3
   If Trim$(invoicenum$) <> "" Then Edittype = 4  ' reconcil only

   'search through records
   linnum = 0
   cont& = 0
   blnSecondPassRequired = True
   
   Do While blnSecondPassRequired = True
      
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      If invoicenum$ <> "" And Val(OrderNumber$) > 0 Then
         'Here we are looking for a subset of both Order number AND invoice number ??? I think so
         strParams = strParams & gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(OrderNumber$))
         strParams = strParams & gTransport.CreateInputParameterXML("InvNum", trnDataTypeVarChar, 12, Trim$(invoicenum$))
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderInfobyInvoiceNumberAndOrderNumActive", strParams)
         blnSecondPassRequired = False
      Else
         If invoicenum$ <> "" Then
            strParams = strParams & gTransport.CreateInputParameterXML("InvNum", trnDataTypeVarChar, 12, Trim$(invoicenum$))
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyInvoiceNumberOrOrderNumActive", strParams)
            blnSecondPassRequired = False
         Else
            strParams = strParams & gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(OrderNumber$))
            If Edittype = 4 Then
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyNumActive", strParams)
               blnSecondPassRequired = False
            Else
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyNumActive", strParams)
            End If
         End If
      End If
      If blnBigScreen Then
         LstBoxFrm.Width = LstBoxFrm.Width + 3000
         LstBoxFrm.LstHdr.Width = LstBoxFrm.LstHdr.Width + 3000
         LstBoxFrm.LstBox.Width = LstBoxFrm.LstHdr.Width + 3000
         LstBoxFrm.cmdOK.Left = LstBoxFrm.cmdOK.Left + 3000
         LstBoxFrm.cmdCancel.Left = LstBoxFrm.cmdCancel.Left + 3000
      End If
      If Not rsOrders.EOF Then
         rsOrders.MoveFirst
         header = False  '03Jul05 TH Added
         ''HdrDone = False  '03Jul05 TH Added
         Do While Not rsOrders.EOF
            msg$ = ""
            BlankWProduct d
            'Cast the Order into the structure
            If invoicenum$ <> "" Or Edittype = 4 Then
               ord = FillOrdFromRS(rsOrders, "WReconcil")
            Else
               ord = FillOrdFromRS(rsOrders, "WOrder")
            End If
            d.SisCode = ord.Code
            F = 0
            getdrug d, F, 0, False
            pform$ = LCase$(d.PrintformV)
            desc$ = d.drugDescription   ' desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
            plingparse desc$, "!"
            If Not header Then
               'display the column headings
               If Edittype = 3 Then
                  temp$ = "Outstanding   " & TB & "Qty x Pack size" & TB & "Approx Price" & TB & "              " & TB & "          "
                  If blnBigScreen Then temp$ = "NSV Code" & TB & "Description" & Space(40) & TB & temp$
                  If HdrDone Then
                     LstBoxFrm.LstBox.AddItem temp$
                  Else
                     LstBoxFrm.lblHead = temp$
                     ''If Not blnBigScreen Then HdrDone = True
                     HdrDone = True
                  End If
               Else
                  If Trim$(invoicenum$) <> "" Then
                     temp$ = "Order No." & TB
                  Else
                     temp$ = ""
                  End If
                  If blnBigScreen Then temp$ = "NSV Code" & TB & "Description" & Space(40) & TB & temp$
                  If HdrDone Then
                     LstBoxFrm.LstBox.AddItem temp$ & "Received      " & TB & "Qty x Pack size" & TB & "Pay Date    " & TB & "Invoice Number" & TB & "Price     " & Space$(80) & TB '22Jul05 TH Added 50 spaces to boost width (#81587)
                     LstBoxFrm.LstBox.AddItem ""
                  Else
                     LstBoxFrm.lblHead = temp$ & "Received      " & TB & "Qty x Pack size" & TB & "Pay date  " & TB & "Invoice Number" & TB & "Price     " & Space$(80) & TB '22Jul05 TH Added 50 spaces to boost width (#81587)
                     ''If Not blnBigScreen Then HdrDone = True
                     HdrDone = True
                  End If
               End If
               linnum = linnum + 1
               header = True
            End If
            GoSub displin
            rsOrders.MoveNext
         Loop
      End If
      If Edittype = 3 Then Edittype = 4
      rsOrders.Close
      Set rsOrders = Nothing
   Loop
   
   Screen.MousePointer = STDCURSOR
   
   If Not foundone Then
      If invoicenum$ <> "" And Val(OrderNumber$) > 0 Then
         strMessage = "No items on record for this order and invoice number"
      ElseIf invoicenum$ <> "" Then
         strMessage = "No items on record for invoice number"
      Else
         strMessage = "No items on record for this order"
      End If
      'popmessagecr "Order Enquiry", "No items on record for this order"
      popmessagecr "Order Enquiry", strMessage
   Else
      'set the title of the screen
      orddat$ = ord.orddate
      convdat orddat$
      supname$ = ""
      getsupplier ord.supcode, 0, lngFoundSup, sup
      If lngFoundSup Then supname$ = RTrim$(sup.name)
      onum$ = OrderNumber$
      If onum$ = "" Then onum$ = "#..."
      LstBoxFrm.lblTitle = cr & "Order Number: " & onum$ & "   Date: " & orddat$ & "   Supplier: " & supname$ & "  (" & Trim$(ord.supcode) & ")" & cr
      
      LstBoxFrm.Caption = "Order Enquiry"
      LstBoxShow
      'Unload LstBoxFrm
   End If
'SQL
If Edittype = 3 Then Edittype = 4
endofproc:
'17Feb05 TH moved here
   On Error Resume Next
   Unload LstBoxFrm
   On Error GoTo 0
Exit Sub

displin:
   foundone = True
   If Val(ord.qtyordered) < 0 Then
      foundone = False
      Return          '28Aug98 TH Added to exclude Credit notes
      text$ = "Credit"  '!!** This line is never executed
   End If
   
   text$ = ord.Code & TB & desc$
   If blnBigScreen Then text$ = text$ & TB
   If Not blnBigScreen Then LstBoxFrm.LstBox.AddItem text$
   
   If Edittype = 3 Then
      If Val(ord.outstanding) <> Val(ord.qtyordered) Then
         msg$ = Trim$(ord.outstanding) & TB
      Else
         msg$ = Trim$(ord.qtyordered) & TB
      End If
      msg$ = msg$ & Trim$(ord.qtyordered) & " x " & d.convfact & pform$ & TB
      tempcost$ = Str$(Val(ord.cost) / 100!)
      poundsandpence tempcost$, False
      tempcost$ = Right$(money(5) & HidePrice(LTrim$(tempcost$), True), 8)
      msg$ = msg$ & tempcost$
      If blnBigScreen Then msg$ = text$ & msg$
      LstBoxFrm.LstBox.AddItem msg$
   Else
      recdat$ = Trim$(ord.recdate)
      paydat$ = Trim$(ord.paydate)
      convdat recdat$
      convdat paydat$
      
      If OrderNumber$ = "" Then
         msg$ = "  # " + ord.num + TB
      Else
         msg$ = ""
      End If
      
      msg$ = msg$ & recdat$
   
      If Val(ord.outstanding) <> 0 Then
         msg$ = msg$ & " (Part)"
      Else
         msg$ = msg$ & Space$(7)
      End If
      msg$ = msg$ & TB & Trim$(ord.received) & " x " & d.convfact & pform$ & TB & paydat$ & TB & ord.invnum
      tempcost$ = Str$(Val(ord.cost) / 100!)
      poundsandpence tempcost$, False
      tempcost$ = Right$(money(5) + LTrim$(tempcost$), 8)
      msg$ = msg$ & TB & tempcost$
      If blnBigScreen Then msg$ = text$ & msg$

      LstBoxFrm.LstBox.AddItem msg$
   End If
      
   LstBoxFrm.LstBox.AddItem ""

Return

waitkey:
   
Return

End Sub

Private Function ReconcilThreshold(ByVal InvoiceTotal As Single, ByVal NewInvoiceTotal As String) As Integer
'31Aug05 PJC Created Function to handle the InvoiceTotal Threshold. Tests to see if the Fuctionality is activated.
'            Checks if the New Invoice total is outside the threshold.
'            Prompts user for confirmation if the threshold is broken.
'            Returns True if the amount is acceptable otherwise retirns false.
'21Sep05 PJC Arguments and declarations now defined with the 'As' syntax.
'            IF block amended: uses constants and removal of call to the Str function.
'            Function is now Private
'            Added Extra Else clause  (Code not in production at this point)
'19Oct05 PJC Set Cancel Button as default. Added Title.
'14Apr10 TH  Ported from V8 (F0056463)
'05Nov14 TH  Round to avoid floating point deviation (TFS 27651)


Dim RecThreshold As Single
Dim strMsg       As String
Dim ans          As String
Dim strTitle     As String   '19Oct05 PJC Added

Dim CheckReconcilThreshold As Integer

Const DISPLAY_FORMAT = "#0.00;-#0.00"   '21Sep05 PJC added

    'Return False by default
    ReconcilThreshold = False

                                                                                                                                              '21Sep05 PJC Made various changes to the If block
   'Is site set up to view Reconcil threshold.                                                                                                '     "
   'If ReconcilThresholdVal$ is empty string then the Threshold is not used.                                                                  '     "
   If Trim(ReconcilThresholdVal$) <> "" Then                                                                                                  '     "
         RecThreshold! = Val(ReconcilThresholdVal$)                                                                                           '     "      Format is now called with Constant DISPLAY_FORMAT
         'Does the defined threshold get exceeded?                                                                                            '     "
         'If Abs(Val(NewInvoiceTotal) - InvoiceTotal) > RecThreshold Then                                                                      '     "
         If round(Abs(Val(NewInvoiceTotal) - InvoiceTotal), 2) > RecThreshold Then   '05Nov14 TH round to avoid floating point deviation (TFS 27651)                                                                  '     "
                  strMsg = "The Amended Invoice Total exceeds the " & money(9) & " Reconciliation Threshold." & crlf & crlf                   '     "
                  strMsg = strMsg & "Invoice Total: " & money(5) & Format$(InvoiceTotal, DISPLAY_FORMAT) & crlf                               '     "      Removed the call to Str function
                  strMsg = strMsg & "Amended Invoice Total: " & money(5) & Format$(NewInvoiceTotal, DISPLAY_FORMAT) & crlf                    '     "
                  strMsg = strMsg & "Difference: " & money(5) & Format$(Abs(Val(NewInvoiceTotal) - InvoiceTotal), DISPLAY_FORMAT) & crlf      '     "
                  strMsg = strMsg & money(9) & " Reconciliation Threshold: " & money(5) & Format$(RecThreshold, DISPLAY_FORMAT) & crlf & crlf '     "      Removed the call to Str function
                                                                                                                                              '     "
                  'popmsg "", strMsg & "Do you want to continue with the Amended Invoice Total ?", MB_ICONQUESTION + MB_OKCANCel, ans, 0      '     "      Replaced 32, 1, with Constants
                  strTitle = TxtD$(dispdata$ & "\winord.ini", "Reconcile", "Reconciliation Threshold Exceeded", "RecThresholdTitle", 0)                                                    '19Oct05 PJC Added
                  popmsg strTitle, strMsg & "Do you want to continue with the Amended Invoice Total ?", MB_ICONQUESTION + MB_OKCANCEL + MB_DEFBUTTON2, ans, 0    '19Oct05 PJC Set Cancel Button as default.Added title.
                                                                                                                                              '     "
                  'Return true as the user has accepted the new amount?                                                                       '     "
                  If ans = "Y" Then                                                                                                           '     "
                        ReconcilThreshold = True                                                                                              '     "
                     End If                                                                                                                   '     "
            Else                                                                                                                              '     "
               ReconcilThreshold = True                  '21Sep05 PJC Added                                                                   '     "      Added to Return true if below threshold
            End If                                                                                                                            '     "
      Else                                                                                                                                    '     "
         'Return True so that functionality is as before.                                                                                     '     "
         ReconcilThreshold = True                                                                                                             '     "
      End If                                                                                                                                  '     "
End Function


