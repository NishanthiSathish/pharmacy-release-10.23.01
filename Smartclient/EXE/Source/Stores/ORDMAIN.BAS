Attribute VB_Name = "Ordmain"
'14Oct97 EAC CheckLevels: qtyonorder now in issue units rather than NSVs worths for part pack handling
'            CheckLevels: Add check for Suppliers without a supplier type defined
'10Dec97 EAC Ensure d.outstanding is updated in NSVworths
'06Jan98 EAC display all Mediate items that failed automatic invoicing
'06Jan98 EAC changes to allow flexible RTF printing of orders
'08Jan98 EAC allow display of tradenames
'17Feb98 EAC DisplayDebugMenu written
'19Feb98 EAC CheckLevels: QtyOnOrder changed from Integer to Long
'23Feb98 ASC SelectForSuppliers: Direct movement of stock for order method T
'25Feb98 EAC Checked and fixed above mod
'05Mar98 ASC checklevels: Facility added to increase stocks by a percentage, for use of holiday periods.
'            enterorder: Changed user prompt to indicate the type of order required.
'            OrderLineParse: Added ability to order part of an outer.
'            PrintPaperOrder: Call to killreprints if printing unsuccesful
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'21May98 CFY OrderLineParse: New ini setting added to winord.ini to specify if the local code rather than the nsv
'              code should be printed on orders.
'12Jun98 EAC SelectForSupplier: make authorising of all order types exclusive to one terminal
'12Nov98 TH  Checktofollows written to check number of "to follows" on issuing
'12Nov98 TH  PrintPaperOrder: Changes to allow for selective ordering from amend screen
'12Nov98 TH  SelectForSupplier: Changes to allow for selected item ordering from amend screen
'13Nov98 TH  PrintPaperOrder: Removed prompt to confirm printing as reprint facility no works and order needs to be logged
'17Nov98 TH  AddLineToDisplay: Code to put supname onto lvwMainScreen.tag for use on amend orders /returns screen
'23Nov98 TH  SelectForSupplier: selected item ordering from amend screen for direct stock movement
'23Nov98 TH  PrintPaperOrder: Added prompt to inform user which order number the order is logged under
'23Nov98 TH  PrintPaperOrder: Now writes last ordered date to drug file
'26Nov98 TH  OrderLineParse: Second location code added ,keyword bin2
'07Dec98 TH  checklevels: Removed updateindex call for amended orders was creating multiple index entries for the same order
'07Dec98 TH  checklevels: Added retention of old outstanding on amended orders
'08Dec98 TH  Checktofollows: Message now takes account of packsize/dosing units
'22Jan99 TH  PrintPaperOrder: msg prompt on printing orders now deals with multiple order numbers
'26Jan99 TH  AddlinetoDisplay: Replaced Tag with global to avoid referencing problems
'28Jan99 TH  PrintPaperOrder: code to handle manual price entry
'28Jan99 TH  SelectForSupplier: code to retain manual price entered o order for order types D and F
'28Jan99 TH  AddlinetoDisplay: display Manual entered price flag/ free drug flag on amend/receive screens
'29Jan99 TH  SelectForSupplier: Allow zero priced orders for EDI
'01Feb99 ASC checklevels: ASC Max % overstocking was 20 now 200%                               '    "
'08Feb99 TH  checklevels: Amend order (retention of old outstanding) for ROL ordering (inc. Non Stock prods)
'09Feb99 TH  checklevels: Use overstock in auto order and for non stock products as well as cyclical orders
'10Feb99 TH  PrintOrder: Mark credit notes going to Addlinetodisplay
'10Feb99 TH  AddlinetoDisplay: Display proper pack size for credit notes
'19Feb99 TH  AddlinetoDisplay: Now Picks up instorespacks% for both credits and reconciliations
'19Feb99 TH  PrintPaperOrder: Allow prices on order when prices on order set to yes
'23Feb99 TH  AddlinetoDisplay: Changed Pricing column(8) to show free,contract and non-stock pricing as well as manual price entry
'04Mar99 TH  checklevels: Code to stop fractional outer size under 1 causing division by zero
'04Mar99 TH  PrintOrder: Removed credit flag
'04Mar99 TH  AddlinetoDisplay: Removed Credit flag
'17May99 AE  OrderLineParse: Added item unitcost! to allow printing of cost of one NSV's worth of an item on the order (for Australia)
'17May99 AE  Moved the IF statement so that prices are always calculated, but only added to the total if calculatecosts is True
'05May99 TH  Checklevels: Changed structure of calculation to avoid rounding problems for Nonstock items in reorderlevel auto order
'26May99 TH  SelectForSupplier: Removed writing of lastordered date to internal suppliers drug file as it has not ordered the drug
'20Jul99 TH  Checktofollows: Just pick up the flagged tofollows
'30Sep99 AE  SiteDrugEnquiry: Corrected output to use the variable Stocklvl$ instead of d.stocklevel. ALso generally tidied
'            up output.
'11Oct99 CKJ Removed Findsupplier, replaced with GetSupplier
'26Oct99 AE  PrintPaperOrder:Code to allow verification of orders when saving them using command line switch.
'26Oct99 AE  VerifySavedOrder: Written
'03Dec99 TH  AddlinetoDisplay: Reinstated getsupplier for tradename toggle
'10Jan00 AW  PrintPaperOrder: changed format of date to format of now.
'            SelectForSupplier: Changed format of date to format of now.
'01Mar00 TH  RequisitionEnquiry: Added Created User ID
'01Mar00 TH  SelectForSupplier: Write last ordered date to drugfile when electronic ordering (E or M type)
'03Apr00 TH  OrderlineParse: Added Urgency code, keyword urg
'07Apr00 CFY SelectForSupplier: Reinstated drug lookup on internal orders as is essential to do this after switching dispdata
'13Apr00 TH  OrderLineParse: Added total cost inc vat for line, keyword itemincvat *GST*
'05Jun00 AJK SelectForSupplier: Ensured description was going to print file with correct length
'16Jun00 TH  OrderlineParse: Added keywords unitvatcost and unitcostincvat
'05Jun00 AJK SelectForSupplier: Ensured description was going to print file with correct length
'03Aug00 TH  SelectForSupplier: Moved pointer increment in internal ordering to make sure reprint is written to correct number
'15Aug00 TH  PrintPaperOrder: Added new context for faxing and removed printer selection boxes as should now be superfluous
'11Sep00 TH/JN/MMA  SelectForSupplier: Update datelastissued field for an internal order & added error-checking to this
'13Sep00 TH/CFY  Checklevels: Added ini switch to allow for reorder of part packs for stocked items using reorder level method. Dont flag "No supplier" messages to user if supplier is INTER
'11Oct00 TH  OrderlineParse: Added supplier reference number  (srefno)
'22Nov00 EAC/CY AddlineToDisplay: Allow reconciliation items to be marked as indispute
'26Mar01 TH  SiteDrugEnquiry: Reset Wslist.mdb to correct site
'26Mar01 TH  Checklevels: Added check on default supplier - if not in file then inform user and dont add to order
'24Sep01 CKJ Merged:
'01Sep01 TH  Checktofollows: Overhaul.Changed input paramter to handle checks on list types correctly (#52924)
'14Jan02 TH  SelectForSupplier: Use Osite$ and not sup structure when part ordering as sup structure could get refilled between
'   "        selecting amend orders and then selecting part order (i.e. was unsafe)  (#58045)
'14Jan02 TH  SiteDrugEnquiry: Stop error when resettinmg Ward Stock list mdb to Original site from stores - pragmatic solution (#57914,#57438)
'   "        because it is difficult to know what data objects association with the wslist are actually open at this time
'   "        Also more importantly the WSList is reopened for the correct site afterwards - I had made the above change stupidly
'   "        only from a dispensary perspective - Sorry. This should now ensure the wslist is correct after the site enquiry.
'15Jan02 TH  SelectForSupplier: Added new string to include time as well as date when logging receival of internal order (#53214)
'15Jan02 TH  PrintPaperOrder: Added time for orderlog (#53214)
'21Jan02 TH  Checklevels: Allow rol method items with required reorder amt to trigger topup (stocked or nonstocked) (#51092)
'22Feb02 TH  OrderlineParse: Added new qtypack element (enh1371)
'07Mar02 TH  Checklevels: Stop non numeric entry into overstock input (#59197)
'07Mar02 TH  Checklevels: If escape out of overstock then dont flag any validation message (It is irrelevant) (#59197)
'12Apr02 TH  OrderlineParse: Changed * sign to x after failed testing ! (enh1371)
'26Apr02 SF  PrintPaperOrder: added additional dummy parameter to PrintOrdTotal:
'05Aug02 TH  SelectForSupplier: Reinstated ability to manually enter price for EDI style Order
'04Jun03 TH  Checklevels: Use Local variable now for d.outstanding and ensure this is never negative (#67942)
'10Mar04 TH  Checklevels: Mod to round the qty ordered to ensure another order is not later required for non-stock prods only (#61736)
'10Mar04 TH               Changes to prevent 0 qty orders and also to round up qtys to ensure stock levels are fully replenished (stocked prods) (#69466) (#61736)
'13Mar04 TH  Checklevels: Put back mod (#61736) for now for political/Release reasons, should be revisited in future release ! Reinstated above line (code)
'31Mar04 CKJ {SP1}
'            PrintOrder: Removed ALL parameters as none were used
'13May04 CKJ AddlineToDisplay: Option to show price on screen at reconciliation: winord.ini [defaults] ShowPriceOnInvoiceScreen="Y" default = "N"

'------ V10 Consolidation : Welcome to our new world (looks like the old one I know, but keep the faith !!)

'29Aug08 TH  OrderlineParse: Now use element from d struct for srefno - heap entry is deprecated (F0027739)
'01Sep08 TH  SelectforSupplier: (F0023216) Update ordernumber fro EDI before modal box - still not perfect but less likely to cause duplicate order numbers
'23Jun08 XN  F0033906 Now used the ICW desktop F4 screens.
'07Jan10 CKJ AlternativeDBlayer now set as default = "Y"
'            AddLineToDisplaySQL: Added robot status as column 9. Note: only used when AlternativeDBlayer="Y" (F0030035)
'19Mar10 TH  AddLineToDisplay: Now this should by default only act as a wrapper to AddlinetoDisplaySQL (F0081160)
'09Apr10 XN  F0068649 EDI orders have seprate max number of lines per an order
'16May10 TH  SelectforSupplier: Extend part ordering to EDI/Modem Orders (F0068698/F0058642)
'04Aug10 TH  Checktofollows: Ported correctly for version 10. Looks like this was not ported fully and left in a none operational state. (F0091123)
'21Jul10 TH  PrintPaperOrder: Mod to set up header and footer for a batch output interface file (F0077944)
'21Jul10 TH  BatchOrderlogOutputfooter,BatchOrderlogOutputHeaderWritten (F0077944)
'22Jul10 TH  SelectforSupplier: Set up batch output for internal orders in interface (UHB)(F0077942)
'26Jul10 TH  SelectforSupplier: Added some heap element handling to allow for SAGE fast track transfers to be used in the UHB interface (F0032689)
'17sep10 TH  PrintOrder: Added param to add line procs to allow for trade name switch (F0096592)
'17sep10 TH  RefreshTblData: Added param to add line procs to allow for trade name switch (F0096592)
'17sep10 TH  AddLineToDisplay: Added param to allow for trade name switch (F0096592)
'17sep10 TH  AddLineToDisplaySQL: Added param to allow for trade name switch (F0096592)
'06Sep10 TH  EnterDeliveryReference Written : Added to collect if required the Docket Number (UMMC FINV) (F0054531)
'07Sep10 TH  BatchOrderlogOutputfooter: Added section to ensure special filename for UMMC (FINV) (F0054531)
'07Sep10 TH  EnterOrder: Added call to EnterDeliveryReference for UMMC (FINV) (F0054531)
'07Sep10 TH  PrintPaperOrder: Add linenumber onto the heap for UMMC (FINV) ordering interface (F0054531)
'07Sep10 TH  BatchOrderlogOutputHeader: Added formated "DD/MM/YYYY" date for UMMC (FINV) (F0054531)
'29Oct10 TH  OrderlineParse: Added on setting to allow for heap parsing (UMMC PRF) (F0094388/RCN545)
'02Nov10 AJK PrintPaperOrder: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Selectforsupplier: F0086901 Added date invoiced to OrderLog calls
'03Nov10 TH  OrderlineParse: Remove [srefno] from heap (so it doesnt get parsed with the wrong info).
'16Nov10 TH  OrderlineParse: set input param RTFTxt$ to byval as this can now be parsed here using heap printing. Because this sub is
'            called in a loop we get the same line already parse coming back which means the first item using heap
'            printing is then used for all subsequent lines (only for the heap elements) (F0100199)
'01Jun11 CKJ Removed DispPgNo. See comments in StoreAsc.bas for details
'            Changed DefInt to DefBool, uncovering untyped vars in Selectforsupplier, enterorder, AddLineToDisplay, AddLineToDisplaySQL
'06Jul11 CKJ CheckPath,RemoveLineFromDisplay, FillRSFromOrd, BuildAdoOrderRecordset: removed
'11Jul11 CKJ MainLVWRemoveSelection, MainLVWIsItemSelected, MainLVWAreAnySelected, MainLVWAreMultipleSelected, MainLVWSingleSelectedItemIndex,
'            MainLVWHighlightSingleRowByIndex, MainLVWMarqueeRowIndex, MainScreenSetTextAndPanels: written
'            Plenty of old code pruned & simplified - essentially wherever the above procs are used.
'11Jul11 TH  SiteDrugEnquitry: Removed clause on saveddrug$ which meant it defaulted to a given drug search on second pass (F0102540)
'18Jul11 TH  SiteDrugEnquitry: Add caption (F0123137)
'22Jul11 XN  printorder: maintain gird sort order on refreshed (F0102524), (F0102526), (F0102527)
'14Aug12 TH  Printorder: Added PSO Flag as parameter
'14Aug12 TH  AddLineToDisplaySQL: Added PSO Flag Parameter /Added support for New PSO Grids(TFS 41372). Include edittype 4 Invoicing (TFS 50285)
'15Aug12 TH  Printorder: Added to allow sort on Surname (TFS 41430)
'12Sep12 TH  SelectforSupplier: Changed tense of Internal order summary so cancel doesnt mislead (TFS 43632)
'10Oct12 TH  Printorder: Added Forename and DOB to sort (TFS 41571)
'14Nov12 TH  OrderlineParse: Added call to get PSO data onto the heap for PSO order printing(TFS 48804)
'14Nov12 TH  OrderlineParse: Added PSO Param to drive previous mod (TFS 48804)
'14Nov12 TH  EnterOrder: PSO Switch (TFS 41433)
'14Nov12 TH  EnterOrder: Added PSO support for captions (TFS 48805,48807)
'21Nov12 TH  EnterOrder: Warnings against PSO /None PSO Orders (TFS 49053)
'08Mar13 TH  AddLineToDisplaySQL: Name changes for PSO (TFS 56646,58429)
'22Mar13 TH  AddLineToDisplaySQL: Handle unrecorded DOB for PSO (TFS 59559)
'24Mar13 TH  PrintPaperOrder: Added PSO check on cancelled prescriptions. (TFS 59468)
'25Mar13 TH  OrderlineParse: Handle rtfs with either no parsing braces, or elements that are parsed from the heap only (TFS 59714)
'27Mar13 TH  OrderlineParse: Removed mod to try and handle text after the final brace - didnt work due to fiddly rtf
'                            handling and not sure it is really needed anyway. (TFS 59714)
'27Sep13 TH  SiteDrugEnquitry: Use the caption with a drug description if one is present (TFS 74334)
'09Jan14 TH  SiteDrugEnquitry: Allow stores only to be available on F4 too (TFS 80652)
'14Aug14 TH  OrderlineParse: Moved parsing until AFTER the standard elements (TFS 97903)
'16Jan15 TH  Checktofollows: Dont factor if in issue units - i.e Print in packs not set (TFS 108294)
'12Nov15 TH  SiteDrugEnquiry: Added Trim to ensure correct check on new description (TFS 132827)
'19Dec15 TH  Printorder: Sorts of rs not currently supported in the ado rs from web transport (TFS 138697)
'06Dec16 TH  PrintPaperOrder: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  BatchOrderlogOutputfooter: SelectForSupplier: Replaced RTF Handling (TFS 157969)
'07Jan17 TH  BatchOrderlogOutputfooter: BatchOrderlogOutputHeader: PrintPaperOrder: Replace check on file for RTF DB Handling (TFS 157969)
'26Jan17 TH  SelectforSupplier: Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'26Jan17 TH  BatchOrderlogOutputHeader: Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'26Jan17 TH  BatchOrderlogOutputFooter: Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'26Jan17 TH  PrintPaperOrder: Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'12Feb17 TH  PrintPaperOrder: Removed call to kill reprint as now inappropriate (TFS 176106)
'15Oct18 AS  Bug 224253: Pharmacy Stores - printing wrong supplier details on orders
'01Jun20 NS      MM-827-PW - Pharmacy stores amend orders sort order issue
'18Jan21 NS MM-4017-SW - Tx Text control EDI order not printing content of order
'29Jan21 NS MM-4639 SW - Purchase Order missing data and removing MM-4017 changes
'05Feb21 NS MM-4639 Removing this changes

Option Explicit
DefBool A-Z

Dim ord As orderstruct

Global OPrintTradeNames As Integer  '08Jan98 EAC allow display of tradenames
Global freestock%                   '25Nov98 TH  Flag for free ordering system
'

Sub DisplayDebugMenu()
'17Feb98 EAC Written

Dim escaped%
Dim ans$

   ans$ = "1"

   Do While Not escaped
      
      frmoptionset -1, "Debugging Menu"
      frmoptionset 1, "File Viewer"
      frmoptionset 1, "Show Orders"

      frmoptionshow ans$, ans$               'Preset 1st button 'On'
         
      escaped = (frmOption.Tag = "")
      frmoptionset 0, ""  'Unload Form
   
      If Not escaped Then
            Select Case ans$
               Case "1"
                  FileViewer
               Case "2"
                  ShowOrders Edittype
            End Select
         End If
   Loop

End Sub

Sub enterorder(Edittype As Integer, Display%, ByVal blnPSO As Boolean)
'05Mar98 ASC Changed user prompt to indicate the type of order required
'05May98 CKJ Removed paydate$ from DisplayOrders param list as not used here
'07Sep10 TH  Added call to EnterDeliveryReference for UMMC (FINV) (F0054531)
'01Jun11 CKJ Added as integer to edittype param
'14Nov12 TH  PSO Switch (TFS 41433)
'14Nov12 TH  Added PSO support for captions (TFS 48805,48807)
'21Nov12 TH  Warnings against PSO /None PSO Orders (TFS 49053)

Dim allowall%, winwidth%
Dim temp$, msg$
Dim strTemp As String
Dim strDeliveryNoteReference As String
Dim blnForceDelRefCapture As Boolean

   allowall = (Edittype <> -3)
   
   Select Case Edittype
      Case -3, 3, 4 'added -3 ASC 06Sep93
         temp$ = "order number"
         k.helpnum = 330
         winwidth = 58
         If Edittype = -3 Then
            winwidth = 34
            strTemp = "Supplementary Orders"
         ElseIf Edittype = 3 Then
            strTemp = "Receive " & IIf(blnPSO, "patient specific", "") & " goods" '14Nov12 TH added PSO support (TFS 48805)
         Else
            strTemp = IIf(blnPSO, "Patient Specific ", "") & "Invoice reconcilliation" '14Nov12 TH added PSO support (TFS 48807)
         End If
      Case -4
         temp$ = "credit order No"
         k.helpnum = 330
         winwidth = 61
      Case 6
         temp$ = "picking ticket number"
         k.helpnum = 340
         winwidth = 65
      Case Else
         'Print "Edit type not defined please contact system manager"
         popmessagecr "Error", "Edit type not defined please contact system manager"
         Stop '//// can't just STOP
      End Select

   msg$ = "Enter " + temp$
   If allowall Then msg$ = msg$ + " or press [Return] for all"
   msg$ = msg$ + "     "
   setinput 0, k
   k.escd = False
   'k.Max = 10
   k.Max = 9
   k.nums = True '01Dec05 TH
   If allowall Then k.min = 0 Else k.min = 1
   ordernum$ = ""
   'inputline ordernum$, k
   'inputwin "Enter Order Number", msg$, OrderNum$, k           '05Mar98 ASC/EAC
   temp$ = "Enter " & temp$
   If strTemp <> "" Then temp$ = strTemp
   InputWin temp$, msg$, ordernum$, k                '     "
   ordernum$ = UCase$(ordernum$)
   k.nums = False '01Dec05 TH
   If Not k.escd Then
      'If (Edittype = 3 Or Edittype = 4) And Trim$(ordernum$) <> "" Then '21Nov12 TH PSO Extended to inclue reconciliation (TFS)
      If (Abs(Edittype) = 3 Or Edittype = 4) And Trim$(ordernum$) <> "" Then '19FebTH PSO Extended to cover supplementary orders (TFS 56746)
         If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "PSO", "N", "AllowPSO", 0)) Then '14Nov12 TH PSO Switch (TFS 41433)
         'Here we do a check on the order number and stop if not PSO/None PSO
            If blnPSO Then  '19Feb13 TH Should never be set for Supplementaries (TFS 56746)
               If Not isPSOOrder(Val(ordernum$)) Then '21Nov12 TH (TFS 49052)
                  'popmessagecr "", "Order Number : " & ordernum$ & ". This is not a patient specific order. Please receive this as a standard order."
                  popmessagecr "", "Order Number : " & ordernum$ & ". This is not a patient specific order. Please " & IIf(Edittype = 3, "receive", "reconcile") & " this as a standard order."
                  k.escd = True
                  ordernum$ = "A"
                  Exit Sub
               End If
            Else
               If isPSOOrder(Val(ordernum$)) Then '21Nov12 TH (TFS 49053)
                  'popmessagecr "", "Order Number : " & ordernum$ & ". This is a patient specific order. Please receive this as a patient specific order."
                  If Edittype = -3 Then
                     popmessagecr "", "Order Number : " & ordernum$ & ". This is a patient specific order." & crlf & crlf & "Supplementary orders cannot be created."
                  Else
                     popmessagecr "", "Order Number : " & ordernum$ & ". This is a patient specific order. Please " & IIf(Edittype = 3, "receive", "reconcile") & " this as a patient specific order."
                  End If
                  k.escd = True
                  ordernum$ = "A"
                  Exit Sub
               End If
            End If
         End If
      End If
      If Edittype = 3 Then   '30Sep10 TH Added after unit test
         EnterDeliveryReference ordernum$  '07Sep10 TH Added call for UMMC (FINV) (F0054531)
         If k.escd Then             '28Sep10 TH Added
            ordernum$ = "A"         '    "
            Exit Sub                '    "
         End If                     '    "
         
      End If                 '30Sep10 TH Added after unit test
      
      If k.exitval = 13 And ordernum$ = "" Then: ordernum$ = "A"
      If Display = True Then
         ChangeTable "blank", False  '14Aug12 TH Added Param '01Nov05 TH Added
         Clearprintedorders
         DisplayOrders Edittype, False   '27Jun11 CKJ Removed unused args: ordernum$, , osite$, SiteNumber%, "", invoicenum$, OASCcode$(), ORecNo&(), Oordering$()
      End If
   End If

End Sub

'06Jul11 CKJ Removed
'Sub CheckPath(pathchecked$, found%)
''26Dec98 ASC checks to see if a path is available
'Dim filespec$
'
'   found = True
'   On Error GoTo NoPath
'   filespec$ = Dir$(pathchecked$, 16) 'checks for directory only
'   On Error GoTo 0
'
'Exit Sub
'
'NoPath:
'   found = False
'   Resume Next
'
'End Sub

Sub checktofollows(sup As supplierstruct, ByVal NSVCode$, Description$, PackSize$, k As kbdcontrol)
'12Nov98 TH Written
'08Dec98 TH Message now takes account of packsize/dosing units
'20Jul99 TH Just pick up the flagged tofollows!
'01Sep01 TH Overhaul; Was using sup structure though this was not explicitly passed into the procedure. Now passes active
'           supplier parameters into the procedure and uses these directly (prev used ward$). Also was using the sup.code
'           to check requistions against, which is incorrect for wardlists where the true cost centre is held in the wardcode
'           field. Also added some error trapping.
'04Aug10 TH Ported correctly for version 10. Looks like this was not ported fully and left in a none operational state. (F0091123)
'06Jul12 TH (TFS 37703) Change default to No
'16Jan15 TH Dont factor if in issue units -PrintinPacks NOT set (TFS 108294)

'On issue  checks by ward and drug to see if there are any to follows then
'prompts the user to see if they wish to carry on
'Parameters in :
'
'     *** wardcode$      = supplier code     '01Sep01 TH Replaced
'     sup            = supplier struct       '    "
'     nsvcode$       = NSVCode of Drug to be issued
'     Description$   = Drug description used in askwin
'     Packsize$      = Packsize (convfact) of drug to be issued

'           out :
'        k.escd      = Abort Issue

Dim DisplayQty!, cont&, totdisplayqty!, ord As orderstruct, fnd&, ans$, d As DrugParameters
Dim txt$, PartPack%
Dim costcentre$
Dim strStatus As String
Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim PendingDisplayQty!, PendingtotDisplayQty! '25Jun12 TH Now show pending (outstanding) from PT Not just tofollows
Dim Pendingtxt$
Dim strDesc As String

   If UCase$(sup.suppliertype) = "L" Then             '01Sep01 TH Now uses correct cost centre to ensure
      costcentre$ = UCase$(Trim$(sup.wardcode))       '   "       Lists are handled correctly. For wards the
   Else                                               '   "       code and warcode should be the same
      costcentre$ = UCase$(Trim$(sup.Code))           '   "       but use explicit code anyway
   End If                                             '   "
   
   If costcentre$ <> "" Then
      strStatus = "5"
'      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
'                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
'                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, costcentre$) & _
'                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, NSVCode$) & _
'                  gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, 0) & _
'                  gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, 0) & _
'                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
'                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
      '04Aug10 TH relaced above as requistion num is cahr and consequently this was returning nothing (F0091123)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, costcentre$) & _
                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, NSVCode$) & _
                  gTransport.CreateInputParameterXML("num", trnDataTypeVarChar, 10, "") & _
                  gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
      'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteria", strParams) '16Jun08 TH Replaced
      If rsOrders.RecordCount > 0 Then
         Do While Not rsOrders.EOF
            ''scanordeqindex 5, NSVCode$, cont&, fnd&
            ord = FillOrdFromRS(rsOrders, "WRequis")
            ''If fnd& Then                                     '04Aug10 TH Removed (F0091123)
            'getorder ord, (fnd&), 5, False       ' (uses idx) '04Aug10 TH Removed (F0091123)
            'If UCase$(Trim$(costcentre$)) = UCase$(Trim$(ord.supcode)) And ord.tofollow = "1" Then   '01Sep01 TH Use new costcentre$
            If UCase$(Trim$(costcentre$)) = UCase$(RtrimGetField(rsOrders!supcode)) And UCase$(RtrimGetField(rsOrders!tofollow)) = "1" Then   '04Aug10 TH Replaced above (F0091123)
               If orddebug Then poporder ord, "Drug Information Debug"
               DisplayQty! = Val(RtrimGetField(rsOrders!outstanding))
               'If Not ((UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L")) Then 'And Not PrintInPacks) Then '16Jan15 TH Dont factor if in issue units (TFS 108294)
               If PrintInPacks And (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") Then  '29Jan15 TH Replaced above - always factor as issue units
                  If Val(PackSize$) <> 0 Then
                     If CLng(DisplayQty! * Val(PackSize$)) Mod Val(PackSize$) <> 0 Then
                        DisplayQty! = CLng((DisplayQty!) * Val(PackSize$))
                        PartPack = True
                     Else
                        DisplayQty! = DisplayQty! * Val(PackSize$)
                     End If
                  End If
               End If
               totdisplayqty! = totdisplayqty! + DisplayQty!
            ElseIf UCase$(Trim$(costcentre$)) = UCase$(RtrimGetField(rsOrders!supcode)) Then
               '22Jun12 TH Check for stuff already pending PT (not just to follow)
               PendingDisplayQty! = Val(RtrimGetField(rsOrders!outstanding)) '04Aug10 TH use field (F0091123)
               'If Not (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") Then  'And Not PrintInPacks Then '16Jan15 TH Dont factor if in issue units (TFS 108294)
               If PrintInPacks And (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") Then '29Jan15 TH Replaced above - always factor as issue units
                  If Val(PackSize$) <> 0 Then
                     If CLng(PendingDisplayQty! * Val(PackSize$)) Mod Val(PackSize$) <> 0 Then
                        PendingDisplayQty! = CLng((DisplayQty!) * Val(PackSize$))
                        PartPack = True
                     Else
                        PendingDisplayQty! = PendingDisplayQty! * Val(PackSize$)
                     End If
                  End If
               End If
               PendingtotDisplayQty! = PendingtotDisplayQty! + PendingDisplayQty!
               
            
            End If
            
            rsOrders.MoveNext '04Aug10 TH (F0091123)
         Loop
      End If
      rsOrders.Close
      Set rsOrders = Nothing
      
      k.escd = False
      If (totdisplayqty! > 0) Or (PendingtotDisplayQty!) Then '25Jun12 TH Added Extra Clause
         d.SisCode = Trim$(UCase$(NSVCode$))
         getdrug d, 0, 0, False
         ans$ = "Y"
         If totdisplayqty! > 0 Then
            If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Or PartPack Then   '08Dec98 TH
               txt$ = txt$ & Str$(totdisplayqty!) & " " + Trim$(d.PrintformV) & "  to follow"                                                 '    "
            Else                                                                                                       '    "
               txt$ = txt$ & Str$((totdisplayqty! / Val(d.convfact))) & " x " & Trim$(d.convfact) & " " + Trim$(d.PrintformV) & "  to follow"                                         '    "
            End If
         End If
         
         If PendingtotDisplayQty! > 0 Then
            If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Or PartPack Then   '08Dec98 TH
               Pendingtxt$ = Pendingtxt$ & Str$(PendingtotDisplayQty!) & " " & Trim$(d.PrintformV) & "  pending printing / issuing"
            Else                                                                                                       '    "
               Pendingtxt$ = Pendingtxt$ & Str$((PendingtotDisplayQty! / Val(d.convfact))) & " x " & Trim$(d.convfact) & " " & Trim$(d.PrintformV) & "  pending printing / issuing"                                        '    "
            End If
         End If
         
         ans$ = "N" '06Jul12 TH (TFS 37703)
         
         strDesc = "There are already :" & Iff(Len(txt$) > 0, crlf & crlf & txt$, "") & Iff(Len(Pendingtxt$) > 0, crlf & crlf & Pendingtxt$, "") & crlf & crlf & " of " & Trim$(Description$) & crlf & crlf & "For this ward. Do you wish to continue ?"
         'askwin "?ASCribe", "There Are Already " & txt$ & " of " & Trim$(Description$) & crlf & crlf & "To Follow for this ward. Do you wish to continue ?", ans$, k
         askwin "?EMIS Health", strDesc, ans$, k
         If Not ans$ = "Y" Then
               k.escd = True
            End If
      End If
   Else                                                                                                          '01Sep01 TH
      popmessagecr "!n!bSupplier " + Trim$(sup.name), "There is no valid cost centre set up for this supplier"   '   "
   End If

End Sub

Sub OrderLineParse(ord As orderstruct, ByVal RTFTxt$, devno%, printsis%, printtn%, linenum%, PtotordCost!, PtotordVat!, pforprinting!, VatForPrinting!, CalculateCosts%, ByVal blnPSO As Boolean)
'06Jan98 EAC     Written for flexible RTF printing
'05Mar98 ASC/EAC Added ability to order part of an outer.
'21May98 CFY New ini setting added to winord.ini to specify if the local code rather than the nsv
'            code should be printed on orders.
'26Nov98 TH  Second location code added ,keyword bin2
'19Feb99 TH  Manual price entry available for printing on orders
'17May99 AE  Added item unitcost
'17May99 AE  Moved IF statement to make unitcost work properly on "Extra Information" RTF
'            So "CalculateCosts" now means 'add cost of this line to the running total"
'30Jun99 CFY Added call to getdrugsup
'03Apr00 TH  Added Urgency code, keyword urg
'13Apr00 TH  Added total cost inc vat for line, keyword itemincvat *GST*
'16Jun00 TH  Added keywords unitvatcost and unitcostincvat
'11Oct00 TH  Added supplier reference number  (srefno)
'22Feb02 TH  Added new qtypack element (enh1371)
'12Apr02 TH  Changed * sign to x after failed testing ! (enh1371)
'26Apr02 SF added data element [qtywithouter] to display the qty with the outer pack size (enh#1555)
'17May05 TH  Now prints prices that are zero as well as positive (replace > with >=)
'29Aug08 TH  Now use element from d struct for srefno - heap entry is deprecated (F0027739)
'29Oct10 TH  Added on setting to allow for heap parsing (UMMC PRF) (F0094388/RCN545)
'03Nov10 TH  Remove [srefno] from heap (so it doesnt get parsed with the wrong info).
'16Nov10 TH  set input param RTFTxt$ to byval as this can now be parsed here using heap printing. Because this sub is
'            called in a loop we get the same line already parse coming back which means the first item using heap
'            printing is then used for all subsequent lines (only for the heap elements) (F0100199)
'14Nov12 TH  Added call to get PSO data onto the heap for PSO order printing(TFS 48804)
'25Mar13 TH  Handle rtfs with either no parsing braces, or elements that are parsed from the heap only (TFS 59714)
'            this also needs to include anything after the final brace (it must have worked under fairly rigid ,
'            but obviously acceptable, assumptions previously
'27Mar13 TH  Removed mod to try and handle text after the final brace - didnt work due to fiddly rtf
'            handling and not sure it is really needed anyway. (TFS 59714)
'03Mar14 TH eHub integration work (TFS)
'14Aug14 TH  Moved parsing until AFTER the standard elements (TFS 97903)

Dim startpos&, endpos&, openbracepos&, closebracepos&
Dim temp$
Dim Changed%   '01Jun02 ALL/ATW
Dim PrintLocalCode%

Dim UnitCost!                                                                  '17May99 AE added
Dim unitcostincvat!, unitvatcost!                                              '16Jun00 TH Added
Dim intPad As Integer  '04Nov07 TH Added
Dim strRTFMain As String   '14Aug14 TH Added

Dim str_eHubsp As String   '03Mar14 TH  Added for eHub integration (TFS)
Dim eHubHeapID As Integer
Dim intSuccess As Integer


   strRTFMain = ""  '14Aug14 TH Added
   
   '21May98 CFY Added line below
   PrintLocalCode = TrueFalse(TxtD(dispdata$ & "\winord.ini", "MAIN", "N", "PrintLocalCode", 0))

   startpos& = 1
   endpos& = Len(RTFTxt$)

   d.SisCode = ord.Code
   'getdrug d, 0, found, False                                                '30Jun99 CFY replaced
   getdrugsup d, 0, 0, False, sup.Code 'found, False, sup.code                                    '30Jun99 CFY'01Jun02 ALL/ATW

   'If OrdPrintPrice And CalculateCosts Then                                   '17May99 AE removed, replaced below
   pforprinting! = 0
   pforprinting! = Val(d.sislistprice)                                   '3May95 CKJ *Not* dependent on contno
   If Val(d.contprice) > 0 Then pforprinting! = Val(d.contprice)
   If UCase$(Trim$(ord.pflag)) = "M" Then pforprinting! = Val(ord.cost)  '19Feb99 TH
   UnitCost! = pforprinting! / 100                                       '17May99 AE added. 'unit cost in £
   unitcostincvat! = UnitCost! * VAT(Val(d.vatrate))                     '16Jun00 TH Added
   unitvatcost! = unitcostincvat! - UnitCost!                            '16Jun00 TH Added
   pforprinting! = dp!((pforprinting! * Val(ord.outstanding)) / 100)
   VatForPrinting! = pforprinting! * (VAT(Val(d.vatrate)) - 1)
   
   If OrdPrintPrice And CalculateCosts Then                                    '17May99 AE moved from above.
         PtotordCost! = PtotordCost! + pforprinting!
         PtotordVat! = PtotordVat! + VatForPrinting!
      End If
      
   '14Aug14 TH Moved below - parse AFTER the old stuff !!(TFS 97903)
   '29Oct10 TH Added on setting to allow for heap parsing (F0094388/RCN545)
   'If TrueFalse(TxtD(dispdata & "\winord.ini", "defaults", "Y", "OrderLineHeapPrinting", 0)) Then
   '   FillHeapDrugInfo gPRNheapID, d, 0
   '   FillHeapOrdInfo gPRNheapID, ord, 0
   '   If blnPSO Then FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0 '14Nov12 TH (TFS 48804)
   '   Heap 12, gPRNheapID, "srefno", "", 0  '03Nov10 TH Remove this incase it gets parsed below. We dont necessarily want this. The other details should be OK.
   '   ParseItems gPRNheapID, RTFTxt$, 0
   'End If
   

   If InStr(startpos&, RTFTxt$, "[") > 0 Then '26Mar13 TH Handle stuff at this stage with no parsing braces (TFS 59714)
      
      Do
         openbracepos& = InStr(startpos&, RTFTxt$, "[")
         If openbracepos& > 0 Then
               If openbracepos& > startpos& Then
                     temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
                     'Put #devno, , temp$
                     strRTFMain = strRTFMain & temp$
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
                  temp$ = Trim$(d.DrugDescription)      ' temp$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
                  plingparse temp$, "!"
               Case "[nsvcode]"
                  If printsis Then
                     If PrintLocalCode Then        '21May98 CFY Added
                        'temp$ = d.local         '        "
                        temp$ = Trim$(d.local)  '04Nov07 TH Added trim to stop new 20 char fld length damaging tabs of order line ()
                     Else                       '        "
                        temp$ = ord.Code
                     End If
                  Else
                     temp$ = String$(7, ".")
                  End If
               Case "[local]"  '04Nov07 TH Added a new element to allow a fixed length local code (belt and braces ?) ()
                     intPad = Val(TxtD$(dispdata$ + "\winord.ini", "OrderPrint", "0", "LocalCodePadding", 0))
                     If intPad > 0 Then
                        temp$ = Left$(d.local & Space$(intPad), intPad)
                     Else
                        temp$ = Trim$(d.local)
                     End If
                           
                     
               Case "[urg]"                '03Apr00 TH  Added Urgency code
                    temp$ = ord.urgency    '   "
               Case "[contract]"
                  temp$ = ""
                  If printtn Then
                     temp$ = "NC"
                     If Len(Trim$(d.contno)) > 0 Then temp$ = Trim$(d.contno)
                  End If
               Case "[qty]"
                  '05Mar98 ASC/EAC This would leave the amount ordered different to that to be received and sometime people deliberatley want part of an outer
                  'If Val(d.reorderpcksize) <= 1 Then
                        temp$ = Trim$(ord.outstanding)
                     'Else                                                                           '05Mar98 ASC/EAC
                     '   defnumofouters (Val(ord.outstanding)), (Val(d.reorderpcksize)), numofouters '     "
                     '   temp$ = Trim$(Str$(numofouters * Val(d.reorderpcksize)))                    '     "
                     'End If                                                                         '     "
               Case "[packsize]"
                  temp$ = "x " & d.convfact & " " & Trim$(LCase$(d.PrintformV))
               Case "[tradename]"
                  temp$ = ""
                  If printtn Then temp$ = Trim$(d.tradename)
               Case "[itemcost]"
                  temp$ = ""
                  If pforprinting! >= 0 And OrdPrintPrice Then temp$ = Format$(pforprinting!, "0.00")

               Case "[unitcost]"                                                              '17May99 AE added
                  temp$ = ""                                                                  '     "
                  If UnitCost! >= 0 And OrdPrintPrice Then temp$ = Format$(UnitCost!, "0.00")  '     "

               Case "[unitcostincvat]"                                                                    '16Jun00 TH added
                  temp$ = ""                                                                              '     "
                  If unitcostincvat! >= 0 And OrdPrintPrice Then temp$ = Format$(unitcostincvat!, "0.00")  '     "

               Case "[unitvatcost]"                                                                 '16Jun00 TH added
                  temp$ = ""                                                                        '     "
                  If unitvatcost! >= 0 And OrdPrintPrice Then temp$ = Format$(unitvatcost!, "0.00")  '     "


               Case "[itemvat]"
                  temp$ = ""
                  If pforprinting! >= 0 And OrdPrintPrice Then temp$ = Format$(VatForPrinting!, "0.00")
               
               Case "[itemincvat]"                                                                                        '13Apr00 TH Added *GST*
                  temp$ = ""                                                                                              '   "
                  If pforprinting! >= 0 And OrdPrintPrice Then temp$ = Format$((VatForPrinting! + pforprinting!), "0.00")  '   "

               Case "[bin]"
                  temp$ = ""
                  temp$ = Trim$(d.loccode)
               Case "[bin2]"                  '26Nov98 TH Second location code
                  temp$ = ""                  '26Nov98 TH
                  temp$ = Trim$(d.loccode2)   '26Nov98 TH
               Case "[srefno]"                                  '11Oct00 TH Added
                  temp$ = ""                                 '  "
                  'Heap 11, gPRNheapID, "sRefno", temp$, 0    '  "   '29Aug08 TH (F0027739)
                  temp$ = Trim$(d.SuppRefno)                         '  "
               Case "[isuptradename]"                 '12Oct06 TH Added '18Mar07 TH Made lower case - God Im an idiot sometimes! (SC-07-0098)
                  temp$ = Trim$(d.SupplierTradeName)  '   "
                  
               Case "[iledcode]"                 '11Oct10 TH Added (UMMC PRF Mods) (F0094388/RCN545)
                  temp$ = Trim$(d.ledcode)

               '22Feb02 TH Added element (enh1371)
               'Case "[qtypack]"
               Case "[qtypack]"
                  If Val(d.convfact) > 0 Then
                     If Int(Val(ord.outstanding)) = Val(ord.outstanding) Then
                        temp$ = Trim$(Format$(Val(ord.outstanding))) & " x " & Trim$(d.convfact) & " " & Trim$(LCase$(d.PrintformV))   '12Apr02 TH Changed * sign to x ! (enh1371)
                     Else
                        temp$ = Trim$(Format$(Val(ord.outstanding) * Val(d.convfact))) & " " & Trim$(LCase$(d.PrintformV))
                     End If

                  Else
                     temp$ = ""

                  End If

               '26Apr02 SF added to display the qty with the outer pack size (enh#1555)
               Case "[qtywithouter]"
                  If Val(d.convfact) > 0 Then
                     If Int(Val(ord.outstanding)) <> Val(ord.outstanding) Then
                        ' in issue units
                        temp$ = Trim$(Format$(Val(ord.outstanding) * Val(d.convfact))) & " " & Trim$(LCase$(d.PrintformV))
                     Else
                        If (Val(d.reorderpcksize) > 1) And (Val(ord.outstanding) >= Val(d.reorderpcksize)) Then
                           ' in outers
                           temp$ = Format$(Val(ord.outstanding) / Val(d.reorderpcksize))
                           temp$ = temp$ & " x " & Trim$(d.reorderpcksize) & " x " & Trim$(d.convfact) & " " & Trim$(LCase$(d.PrintformV))
                        Else
                           ' in packs
                           temp$ = Trim$(Format$(Val(ord.outstanding))) & " x " & Trim$(d.convfact) & " " & Trim$(LCase$(d.PrintformV))
                        End If
                     End If
                  End If
               '26Apr02 SF -----
               
               'Start : TFS 224253 : 15 Oct 2018 : Added Supplier Details
               Case "[scntaddress]"
                  temp$ = Trim$(sup.contractaddress)
               Case "[ssupaddress]"
                  temp$ = Trim$(sup.supaddress)
               Case "[sinvaddress]"
                  temp$ = Trim$(sup.invaddress)
               Case "[scnttelno]"
                  temp$ = Trim$(sup.conttelno)
               Case "[ssuptelno]"
                  temp$ = Trim$(sup.suptelno)
               Case "[sinvtelno]"
                  temp$ = Trim$(sup.invtelno)
               Case "[sdiscountdesc]"
                  temp$ = Trim$(sup.discountdesc)
               Case "[sdiscountval]"
                  temp$ = Trim$(sup.discountval)
               Case "[smethod]"
                  temp$ = Trim$(sup.Method)
               'End : TFS 224253 : 15 Oct 2018 : Added new field - Contact Address

               Case Else
                  ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
            End Select
            
            strRTFMain = strRTFMain & temp$ '14Aug14 TH Store for later Parse (TFS 97903)
            
            'Put #devno, , temp$ '14Aug14 TH Put after heap parse below (TFS 97903)
               
         End If
         
         startpos& = closebracepos& + 1
         
      Loop While (openbracepos& > 0)
      
      '14Aug14 TH Moved Block from above (TFS 97903)
      '29Oct10 TH Added on setting to allow for heap parsing (F0094388/RCN545)
      If TrueFalse(TxtD(dispdata & "\winord.ini", "defaults", "Y", "OrderLineHeapPrinting", 0)) Then
         FillHeapDrugInfo gPRNheapID, d, 0
         FillHeapOrdInfo gPRNheapID, ord, 0

         '--- 21/11/2018: TFS 231503 - Add supplier details to heap
            getsupplier ord.supcode, 0, 0, sup
            FillHeapSupplierInfo gPRNheapID, sup, 0
         '---

            If blnPSO Then FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0 '14Nov12 TH (TFS 48804)
            'Heap 12, gPRNheapID, "srefno", "", 0  '03Nov10 TH Remove this incase it gets parsed below. We dont necessarily want this. The other details should be OK.
            ParseItems gPRNheapID, strRTFMain, 0 '14Aug14 TH Now parse the entire text from above AFTER the standard stuff (TFS 97903)
      
         '03Mar14 TH eHub integration work (TFS)
         If TrueFalse(TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLineTransferPrint", 0)) Then
            'We are using Hub integration
            'Here we call a configurable sp with some simple IDs from the Order Line
            'This is used to bring back data for the heap for inclusion in any file based output.
            'It can also be used for trasmission of data via the DB if required.
            Heap 2, eHubHeapID, "", "", False 'For Safety completely clear heap both before and after - this has patient specific info
            Heap 1, eHubHeapID, "eHub Integration Data Heap", "", intSuccess
            If Not intSuccess Then
               popmessagecr "eHub", "Failed to allocate data heap for eHub Integration"
            Else
               str_eHubsp = TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLinesp", 0)
               If Trim$(str_eHubsp) <> "" Then
                  'FillHeapeHubInfo eHubHeapID, ord.OrderID, str_eHubsp, 0
                  FillHeapeHubInfo eHubHeapID, ord.PSORequestID, str_eHubsp, 0
                  ParseItems eHubHeapID, RTFTxt$, 0
               End If
               Heap 2, eHubHeapID, "", "", False 'For Safety completely clear heap both before and after - this has patient specific info
            End If
         End If
      End If
      '14Aug14 TH
      
      
      Put #devno, , strRTFMain
      
      '27Mar13 TH Remove this section
      ''25Mar13 TH Now add anything after the last brace
      'If Len(RTFTxt$) > closebracepos& - openbracepos& + 1 Then
      '   temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
      '   Put #devno, , temp$
      'End If

      '-------
      
   Else
      '25Mar13 TH OK we either dont have anythign parse-able or it has already been done via heap parsing
      'In this case we must output the rtf text as it stands (TFS 59714)
      Put #devno, , RTFTxt$
   End If
   temp$ = "\par}"
   Put #devno, , temp$
   
End Sub

Sub checklevels(cycle$)
'-----------------------------------------------------------------------------
'               Checks all drugs and add to order if required
'-----------------------------------------------------------------------------
'17Jul91 ASC Now adds another order if more required due to further orders
'              for items not stocked but already on order.
'23Jul91 ASC now subtracts stock level for non stock items
'27Sep92 ASC Now does cyclical ordering
'24Aug93 CKJ Outstanding now calculated x 2, 1st for Cyclical, 2nd for reorder
' 7Mar94 CKJ Multiple cycles
' 9Feb95 CKJ Added sisstock<>N to cycle check
'20May96 CKJ Mod to cyclical to avoid negative qtys
'            - tidying needed though.
'24May96 CKJ Added ASCRIBE.INI [Orders] CycleLvlChk=0/1
'14Oct97 EAC qtyonorder now in issue units rather than NSVs worths for part pack handling
'            Add check for Suppliers without a supplier type defined
'29Dec97 EAC Use Stores drug description
'19Feb98 EAC QtyOnOrder changed from Integer to Long
'05Mar98 ASC Facility added to increase stocks by a percentage, for use of holiday periods.
'07Dec98 TH  Removed updateindex call for amended orders was creating multiple index entries for the same order
'07Dec98 TH  Added retention of old outstanding on amended orders
'01Feb99 ASC ASC Max % overstocking was 20 now 200%
'08Feb99 TH  Amend order (retention of old outstanding) for ROL ordering (inc. Non Stock prods)
'09Feb99 TH  Use overstock in auto order and for non stock products as well as cyclical orders
'04Mar99 TH  Code to stop fractional outer size under 1 causing division by zero
'05May99 TH  Removed debug line
'05May99 TH  Changed structure of calculation to avoid rounding problems for Nonstock items in reorderlevel auto order
'13Sep00 TH/CFY  Added ini switch to allow for reorder of part packs for stocked items using reorder level method. Dont flag "No supplier" messages to user if supplier is INTER
'26Mar01 TH  Added check on default supplier - if not in file then inform user and dont add to order
'21Jan02 TH  Allow rol method items with required reorder amt to trigger topup (stocked or nonstocked) (#51092)
'07Mar02 TH  Stop non numeric entry into overstock input (#59197)
'07Mar02 TH  If escape out of overstock then dont flag any validation message (It is irrelevant) (#59197)
'04Jun03 TH  Use Local variable now for d.outstanding and ensure this is never negative (#67942)
'10Mar04 TH  Mod to round the qty ordered to ensure another order is not later required for non-stock prods only (#61736)
'10Mar04 TH  Changes to prevent 0 qty orders and also to round up qtys to ensure stock levels are fully replenished (stocked prods) (#69466) (#61736)
'13Mar04 TH  Put back mod (#61736) for now for political/Release reasons, should be revisited in future release ! Reinstated above line (code)
'29Mar07 TH  Ensure the pointer variables are set correctly if we are going to amend an existing line on the amend order page.
'02Apr07 TH  Set nod correctly to allow handling of cancel properly
'07July21 NS MM-7381-10.20.00.10 - DLO ordering returning incorrect quantity on order screen.

'mods needed
'Plethora of Booleans - surely reducible
'Re-calc of qtys - ditto
'STOREASC only

Dim nod&, F&, numofa%, numofi%, numofd%, numofdb%, numofout%, rolorder%, cycleqty%, cycleqty_DLO%   '07Jul21 MM-7381 '01Jun02 ALL/ATW
Dim lowstock%, cycleorder%, extradays%, ordered%, ordercycle%   ', qtyonorder%   '19Feb98 EAC commented out qtyonorder% '01Jun02 ALL/ATW
Dim reorderrol%, dummy%, CycleRol%, outstanding%, required%, topup%, numofouters%
Dim requirement!, dueorhave!, neededdispunits!, reorderlevel!
Dim numofitemsadded%
Dim cont&, fnd&, cyclefound&, pointer&, qtyonorder&, qtyonorder_DLO&, cyclefound_DLO&     '19Feb98 EAC added qtyonorder& '07Jul21 MM-7381
Dim reorderqty$, title$, msg$
Dim numofitemsamended%                                    '07Dec98 TH added
Dim rolfound&, rolqty%, rolfound_DLO&, rolqty_DLO%    '07Jul21 MM-7381
Dim percans$, overstock! '05mar98 ASC/EAC
Dim sglOutstanding As Single
Dim lngFoundSup As Long

Dim DrugPtr As Long  '01Jun02 ALL/ATW

'Dim oDataAccess    As clsDataAccess
Dim rsDrugs        As ADODB.Recordset
Dim rsOrders       As ADODB.Recordset
Dim rsOrders_DLO       As ADODB.Recordset
Dim strParams As String
Dim strSupplierType As String
Dim strStatus As String
Dim strDesc As String  '23Nov05 TH TOMERGE


   percans$ = "0"
   Screen.MousePointer = STDCURSOR
   Do
      k.nums = True: k.decimals = True
      k.Max = 3 '10Aug05 TH (#81783)
      InputWin "Automatic Order creation", "Enter % extra overstocking", percans$, k
      k.nums = False: k.decimals = False
      If Val(percans$) > 200 And Not k.escd Then
         popmessagecr "Re-Enter", "Maximum of 200% allowed"
      Else
         Exit Do
      End If
   Loop Until k.escd
   Screen.MousePointer = HOURGLASS
   If Not k.escd Then
      overstock! = (100 + Val(percans$)) / 100
   Else
      Exit Sub
   End If
   ChangeTable "Automatic Orders", False '14Aug12 TH Added Param
   MainScreen.CmdAutoOrder.Tag = ""
   MainScreen.CmdAutoOrder.Enabled = True
   MainScreen.Progress.Value = 0
   MainScreen.FrmGauge.Caption = ""

   reorderqty$ = ""
   If Len(cycle$) Then
      cycle$ = "," + cycle$ + ","
   End If
   Edittype = 1
   '''getnod nod
   F = 0
   numofa = 0   'number of items awaiting transmission
   numofi = 0   'number of items awaiting transmission
   numofd = 0   'number of items with outstanding orders
   numofdb = 0  'number of items with outstanding orders
   numofout = 0 'number of outstanding items added to order

   MainScreen.Progress.Value = 0
   MainScreen.FrmGauge.Caption = "Checking Levels..."
   UpdateBar 0, 0, 0, 0
   
   ''SQL GET the drugs and iterate through them
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsDrugs = gTransport.ExecuteSelectSP(g_SessionID, "pDrugsbySite", strParams)
   
   If rsDrugs.RecordCount > 0 Then
      rsDrugs.MoveFirst
      nod = rsDrugs.RecordCount '02Apr07 TH Added
      Do While Not rsDrugs.EOF

         rolorder = False   'if ROL method only
         lowstock = False   'If stock lvl is < ROL or not stocked
         cycleorder = False 'If a cycle has been entered
         rolfound& = 0
         rolqty = 0
   
         F = F + 1
         '''drugPtr = F
         UpdateBar 1, (rsDrugs.RecordCount), (F), ProgressBarScale
         '''getdrug d, drugPtr, 0, False ' found%, False  '01Jun02 ALL/ATW
         'd = FillDrugFromRS(rsDrugs)
         BlankWProduct d
         CastRecordsetToProduct rsDrugs, d  '18Oct04 TH Added
         'If d.SisCode = "DUE121X" Then MsgBox "ARR" '19Oct06 TH Removed
         If Val(d.convfact) = 0 Then
                        'popmessagecr "!n!b", "Stores pack size needs entering for " + Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
            popmessagecr "!n!b", "Stores pack size needs entering for " + Trim$(d.DrugDescription)
         Else
            sglOutstanding = d.outstanding
            If sglOutstanding < 0 Then sglOutstanding = 0
            If InStr(cycle$, "," + Trim$(d.ordercycle) + ",") And UCase$(d.sisstock) <> "N" Then  '9Feb95 CKJ added sisstock
            '''If InStr(cycle$, "," + Trim$(d.ordercycle) + ",") And (UCase$(d.sisstock) <> "N" Or TrueFalse(TxtD(dispdata & "\winord.ini", "defaults", "N", "NonStockForCycleOrder", 0))) Then  '21Apr08 TH
               rolorder = False
               cycleorder = True
               'If stock will not have arrived before it is next ordered
               '--------------------------------------------------------
               If Val(d.LeadTime) > d.cyclelength Then
                  extradays = Val(d.LeadTime) - d.cyclelength
               Else
                  extradays = 0
               End If
               requirement! = (sglOutstanding * Val(d.convfact)) + ((d.cyclelength + extradays) * (Val(d.anuse) / 365.25))    '    "
                                                                   
               cont& = 0        '24Aug93 CKJ qtyonorder is now calculated
               qtyonorder& = 0
               ''''Do               'check to see how much is already on order
                  ''''scanordreqindex edittype, d.siscode, cont&, fnd&
                  'Get all the orders (edditype =1 on siscode)
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode) & _
                           gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, CStr(Edittype))
                           
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderByCodeandStatusForAutOrder", strParams)
               If rsOrders.RecordCount > 0 Then
                  rsOrders.MoveFirst
                  Do While Not rsOrders.EOF
                     'If fnd& Then
                     ''getorder ord, (fnd&), edittype, False    ' (uses idx)
                     ''''ord = FillOrdFromRS(rsOrders, "WOrder")
                     '26Mar97 EAC - handle part packs from requisitions
                     ''''getsupplier ord.supcode, 0, lngFoundSup, sup
                     ''If lngFoundSup = 0 Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & ord.supcode & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC."
                     strSupplierType = RtrimGetField(rsOrders!suppliertype)
                     ''If strSupplierType = "" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!Code) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC."
                     If strSupplierType = "" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!Code) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to your System Manager." '24May05 TH Changed
                     
                     On Error GoTo ChkLvlsQtyErr
                     'TH Added check to stop credit notes being factored in.
                     If strSupplierType = "W" Or strSupplierType = "L" Then
                        If Val(RtrimGetField(rsOrders!status)) > 0 And Val(RtrimGetField(rsOrders!status)) < 9 Then qtyonorder& = qtyonorder& + Val(RtrimGetField(rsOrders!outstanding))
                     Else
                        If Val(RtrimGetField(rsOrders!status)) > 0 And Val(RtrimGetField(rsOrders!status)) < 9 Then qtyonorder& = qtyonorder& + (Val(RtrimGetField(rsOrders!outstanding)) * Val(d.convfact))
                     End If
                     On Error GoTo 0
                     rsOrders.MoveNext
                  Loop
                  '---
               End If
               ''rsOrders.Close
               ''Set rsOrders = Nothing
               ''Else
               ''   Set oDataAccess = Nothing
               ''End If
               '''Loop Until fnd& = 0   ' index closes automatically on fnd&=0
               dueorhave! = qtyonorder& + Val(d.stocklvl)
               neededdispunits! = (requirement! * d.safetyfactor * overstock!) - dueorhave! '    "
               reorderqty$ = LTrim$(Str$(Int(dp!(neededdispunits! / Val(d.convfact)) + 0.5))) '23Jun93 CKJ dp
               If Val(reorderqty$) < 0 Then
                  reorderqty$ = ""
               End If
            Else
               cycleorder = False
               rolorder = True
            End If
            If cycleorder Then
               If Val(reorderqty$) > 0 Then lowstock = True
            Else
               If Val(d.stocklvl) <= Val(d.reorderlvl) Or UCase$(d.sisstock) = "N" Then lowstock = True
            End If
            If lowstock Then
               ordered = False
               'checks to see if already on order
               '---------------------------------
               cont& = 0
               qtyonorder& = 0
               '''Do
               '''scanordreqindex edittype, d.siscode, cont&, fnd&
               ''Set oDataAccess = New clsDataAccess
               ''strSql = "Select * from [Order] where code ='" & d.siscode & "' and status = '1'"
               ''If oDataAccess.GetRecordset(strSql, rsOrders) Then
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode)
                          '' gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "")
                           
                          
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderCheckForAutoOrder", strParams)
               If rsOrders.RecordCount > 0 Then
                  rsOrders.MoveFirst
                  Do While Not rsOrders.EOF
                     '''getorder ord, fnd&, edittype, False       ' (uses idx)
                     '''ord = FillOrdFromRS(rsOrders, "WOrder")
                     strStatus = RtrimGetField(rsOrders!status)
                     strSupplierType = RtrimGetField(rsOrders!suppliertype)
                     If Val(strStatus) = 1 And cycleorder Then
                        'cyclefound& = fnd&
                        cyclefound& = RtrimGetField(rsOrders!WOrderID) '29Mar07 TH Needed For Update
                        cycleqty = Val(RtrimGetField(rsOrders!outstanding)) 'Uses last order only - qty modified later
                     Else
                        cyclefound& = 0
                        'If Val(strStatus) = 1 Then rolqty = Val(RtrimGetField(rsOrders!outstanding)): rolfound& = fnd&
                        If Val(strStatus) = 1 Then rolqty = Val(RtrimGetField(rsOrders!outstanding)): rolfound& = RtrimGetField(rsOrders!WOrderID) '29Mar07 TH Needed For Update
                     End If
                     If Val(strStatus) > 0 And strStatus <> "D" And strStatus <> "R" Then
                        ordered = True
                        ''''getsupplier ord.supcode, 0, lngFoundSup, sup
                        'If lngFoundSup = 0 Then '''And Trim$(UCase$(ord.supcode)) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & ord.supcode & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC." '   "       Dont flag "Inter" to user
                        'If strSupplierType = "" And Trim$(UCase$(RtrimGetField(rsOrders!supcode))) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!supcode) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC."
                        If strSupplierType = "" And Trim$(UCase$(RtrimGetField(rsOrders!supcode))) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!supcode) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to your System Manager."
                     
                        If strSupplierType = "W" Or strSupplierType = "L" Then
                           qtyonorder& = qtyonorder& + Val(RtrimGetField(rsOrders!outstanding))
                        Else
                           qtyonorder& = qtyonorder& + (Val(RtrimGetField(rsOrders!outstanding)) * Val(d.convfact))
                        End If
                        Select Case strStatus
                           Case "1": numofa = numofa + 1
                           Case "2": numofi = numofi + 1
                           Case "3": numofd = numofd + 1
                        End Select
                        If Val(d.stocklvl) < 1! * Val(overdue$) * Val(d.reorderlvl) Then
                           If strStatus = "3" Then numofdb = numofdb + 1
                        End If
                     End If
                     rsOrders.MoveNext
                  Loop
               End If
               rsOrders.Close
               Set rsOrders = Nothing
               'Start '07Jul21 MM-7381
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode)
                          '' gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "")
                           
                          
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderCheckForAutoOrder_DLO", strParams)
               If rsOrders.RecordCount > 0 Then
                  rsOrders.MoveFirst
                  Do While Not rsOrders.EOF
                     '''getorder ord, fnd&, edittype, False       ' (uses idx)
                     '''ord = FillOrdFromRS(rsOrders, "WOrder")
                     strStatus = RtrimGetField(rsOrders!status)
                     strSupplierType = RtrimGetField(rsOrders!suppliertype)
                     If Val(strStatus) = 1 And cycleorder Then
                        'cyclefound& = fnd&
                        cyclefound_DLO& = RtrimGetField(rsOrders!WOrderID) '29Mar07 TH Needed For Update
                        cycleqty_DLO = Val(RtrimGetField(rsOrders!outstanding)) 'Uses last order only - qty modified later
                     Else
                        cyclefound_DLO& = 0
                        'If Val(strStatus) = 1 Then rolqty = Val(RtrimGetField(rsOrders!outstanding)): rolfound& = fnd&
                        If Val(strStatus) = 1 Then rolqty_DLO = Val(RtrimGetField(rsOrders!outstanding)): rolfound_DLO& = RtrimGetField(rsOrders!WOrderID) '29Mar07 TH Needed For Update
                     End If
                     If Val(strStatus) > 0 And strStatus <> "D" And strStatus <> "R" Then
                        ordered = True
                        ''''getsupplier ord.supcode, 0, lngFoundSup, sup
                        'If lngFoundSup = 0 Then '''And Trim$(UCase$(ord.supcode)) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & ord.supcode & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC." '   "       Dont flag "Inter" to user
                        'If strSupplierType = "" And Trim$(UCase$(RtrimGetField(rsOrders!supcode))) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!supcode) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to ASC."
                        If strSupplierType = "" And Trim$(UCase$(RtrimGetField(rsOrders!supcode))) <> "INTER" Then popmessagecr "Error", "Procedure: CheckLevels" & cr$ & RtrimGetField(rsOrders!supcode) & " was not found in the supplier file." & cr$ & "This fault will affect the Automatic Ordering Calculations. Please report to your System Manager."
                     
                        If strSupplierType = "W" Or strSupplierType = "L" Then
                           qtyonorder_DLO& = qtyonorder_DLO& + Val(RtrimGetField(rsOrders!outstanding))
                        Else
                           qtyonorder_DLO& = qtyonorder_DLO& + (Val(RtrimGetField(rsOrders!outstanding)) * Val(d.convfact))
                        End If
                     End If
                     rsOrders.MoveNext
                  Loop
               End If
               rsOrders.Close
               Set rsOrders = Nothing
                qtyonorder& = qtyonorder& + qtyonorder_DLO&
                cycleqty = cycleqty + cycleqty_DLO
                rolqty = rolqty + rolqty_DLO
                'End '07Jul21 MM-7381
               ''Loop Until fnd& = 0   ' index closes automatically on fnd&=0
               If rolorder Then reorderlevel! = dp!(Val(d.reorderlvl) / Val(d.convfact)) + sglOutstanding - (qtyonorder& / Val(d.convfact))  '    "
               ordercycle = False
               If cycleorder Then
                  If Val(reorderqty$) > 0 Then ordercycle = True
               End If
               reorderrol = False
               If Val(d.stocklvl) / Val(d.convfact) < reorderlevel! And UCase$(d.livestockctrl) = "Y" Then reorderrol = True
               '24May96 CKJ If ASCRIBE.INI [Orders] CycleLvlChk=0 then items discovered to
               '            have a low stock level will *not* be added to the suggested
               '            reorder list during a Cyclical reorder pass
               '            Default is CycleLvlChk=1 ie standard behaviour
               CycleRol = (Val(TxtD$(dispdata$ + "\ascribe.ini", "Orders", "1", "CycleLvlChk", dummy)) <> 0)
               If Len(cycle$) > 0 And Not CycleRol Then reorderrol = False
               'if this item is on the cycle (cycleorder) and we have the addenbrooks setting then we do set the reorderrol flag
               '''If (cycleorder And TrueFalse(TxtD(dispdata & "\winord.ini", "defaults", "N", "CycleOrderStandardNonStockCheck", 0))) Then reorderrol = True '21Apr08 TH
               
               If reorderrol Or ordercycle Then
                  outstanding = False
                  If UCase$(d.sisstock) = "N" And (qtyonorder& / Val(d.convfact)) < sglOutstanding Then outstanding = True   '    "
                  If sglOutstanding - (qtyonorder& / Val(d.convfact)) - dp!(Val(d.stocklvl) / Val(d.convfact)) > 0 Then   '04Jun03 TH Replaced Above
                     required = True
                  Else
                     required = False
                  End If
                  If Val(reorderqty$) > 0 Then required = True
                  topup = False
                  If UCase$(d.sisstock) <> "N" And (Not ordered Or (reorderlevel! > 0 And rolorder)) And Val(d.reorderqty) > 0 Then topup = True    '21Jan02 TH Allow rol method items with required reorder amt to trigger topup (#51092)
                  If ((((outstanding Or rolfound& > 0) Or cycleorder) And required) Or topup) And d.inuse <> "N" Then
                     getsupplier d.supcode, 0, lngFoundSup, sup
                     If lngFoundSup > 0 Then
                        If cyclefound& > 0 Then
                           pointer& = cyclefound&
                        Else
                           If rolfound& > 0 Then    '08feb99 TH
                              pointer& = rolfound&     '  "
                           Else                     '  "
                              pointer& = 0 'Force to insert
                           End If                   '  "
                        End If
                        If pointer& > 0 Then
                           getorder ord, pointer&, Edittype, True      '----> LOCK (no idx)
                        Else
                           blankorder ord
                        End If
                        ord.Code = d.SisCode
                        If UCase$(d.sisstock) = "N" Then
                           numofout = numofout + 1
                           ord.outstanding = LTrim$(Str$(Int(sglOutstanding * overstock! - (qtyonorder& / Val(d.convfact)) - dp!(Val(d.stocklvl) / Val(d.convfact)) + 0.999999)))   '04Jun03 TH Replaced Above
                           If cyclefound& > 0 Then                                        '07Dec98 TH
                              ord.outstanding = Str$(Val(ord.outstanding) + cycleqty)  '  "
                           Else                                                                           '08Feb99 TH  Amend order properly if not cyclical order
                              If rolfound& > 0 Then ord.outstanding = Str$(Val(ord.outstanding) + rolqty) '     "
                           End If                                                                         '     "
                        Else
                           If Not cycleorder Then
                              If (Val(d.reorderqty) <> Int(Val(d.reorderqty))) And (TrueFalse(TxtD$(dispdata$ + "\winord.ini", "Defaults", "N", "AutoOrderPartPack", 0)) = -1) Then '13Sep00 TH/CFY
                                 ord.outstanding = LTrim$(Str$(((Val(d.reorderqty) + sglOutstanding) * overstock!) - (qtyonorder& / Val(d.convfact))))  '04Jun03 TH Replaced above
                              Else                                                                                                                                              '   "
                                 ord.outstanding = LTrim$(Str$(Int(((Val(d.reorderqty) + sglOutstanding) * overstock!) - (qtyonorder& / Val(d.convfact)) + 0.5))) '04Jun03 TH Replaced above
                              End If                                                                                                                                            '   "
                              If rolfound& > 0 Then ord.outstanding = Str$(Val(ord.outstanding) + rolqty)    '08Feb99 TH  Amend order properly if not cyclical order
                              If Val(ord.outstanding) < Val(d.reorderqty) Then ord.outstanding = d.reorderqty     '10Mar04 TH Added
                           Else
                              ord.outstanding = LTrim$(reorderqty$)
                              If cyclefound& > 0 Then ord.outstanding = Str$(Val(ord.outstanding) + cycleqty)
                           End If
                        End If
                        If Int(Val(d.reorderpcksize)) > 0 Then
                           defnumofouters (Val(ord.outstanding)), (Val(d.reorderpcksize)), numofouters
                           ord.outstanding = LTrim$(Str$(numofouters * Val(d.reorderpcksize)))
                        End If
                        ord.supcode = d.supcode
                        ord.status = "1"
                        ord.orddate = ""
                        ord.ordtime = ""
                        ord.num = ""
                        
                        '05Sep05 PJC/TH Added code below to ensure that negative quantities are not added as new orders. (#69466) '21Apr08 TH Merged from v8 (F0015819)
                        If Val(ord.outstanding) <= 0 Then
                           ord.status = "D"
                        End If

                        pointer& = PutOrder(ord, pointer&, "WOrder")   '------> UNLOCK (idx required => see below)
                        If cyclefound& > 0 Then
                           numofitemsamended = numofitemsamended + 1
                        Else
                           If rolfound& > 0 Then
                              numofitemsamended = numofitemsamended + 1
                           Else
                              'Dont update the added stats if the order is to be deleted    '05Sep05 PJC/TH Added code below to ensure that negative quantities are not added as new orders, logged if negative (#69466) '21Apr08 TH Merged form v8
                              If ord.status <> "D" Then
                                 numofitemsadded = numofitemsadded + 1
                              Else
                                 WriteLog dispdata$ & "\Orderneg.log", 0, UserID$, "Attempted to create order with zero or negative quantity. Ord.outstatnding: " & ord.outstanding & " NSVCode: " & d.SisCode & " Re-Orderlevel " & d.reorderlvl & " Re-Order quantity " & d.reorderqty
                              End If
                           End If
                        End If
                     Else                                                                                                '26Mar01 TH Tell user if default supplier
                        ''msg$ = "The default supplier for " & d.SisCode & "(" & Trim$(d.Description) & ")"'   "       not in supplier file
                        '23Nov05 TH TOMERGE
                        getdrug d, 0, 0, False
                        'msg$ = "The default supplier (" & Trim$(d.supcode) & ") for " & Trim$(GetStoresDescription()) & " (" & Trim$(d.Description) & ")"  '(#78513)
                        strDesc = d.DrugDescription    ' strDesc = GetStoresDescription() XN 4Jun15 98073 New local stores description
                        plingparse strDesc, "!"
                        msg$ = "The default supplier (" & Trim$(d.supcode) & ") for " & Trim$(strDesc)  '(#78513)
                        msg$ = msg$ & " could not be found in the supplier file." & crlf                                   '   "       do NOT add to order
                        msg$ = msg$ & "Therefore this item cannot be added to the order."                                 '   "
                        msg$ = msg$ & " This fault will affect the Automatic Ordering Calculations. Please report to EMIS Health." '   "
                        'popmessagecr "!Error", "Procedure: CheckLevels" & cr$ & msg$                                      '   "
                        Screen.MousePointer = STDCURSOR
                        popmessagecr "!Error", msg$
                        Screen.MousePointer = HOURGLASS
                     End If                                                                                              '   "
                  End If                                                                             '    "
               End If
               If MainScreen.CmdAutoOrder.Tag = "Cancelled" Then Exit Do  '05Mar98 ASC/EAC
            End If
         End If
         rsDrugs.MoveNext
      Loop 'Until F >= nod
      MainScreen.CmdAutoOrder.Enabled = False '05Mar98 ASC
   End If
   rsDrugs.Close
   Set rsDrugs = Nothing
   Screen.MousePointer = STDCURSOR
   
   If F < nod Then
      popmessagecr "ABORTED", Str$(numofitemsadded) + " items added to order"
   Else
      'Now get various totals independently
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1")
      numofa = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderCountbyStatus", strParams)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "2")
      numofi = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderCountbyStatus", strParams)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3")
      numofd = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderCountbyStatus", strParams)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "3") & _
                  gTransport.CreateInputParameterXML("Overdue", trnDataTypeFloat, 8, CDbl(Val(overdue$))) '16Aug06 TH Added val(got type mismatch when no default set)
      numofdb = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWOrderCountbyReceiptBelowDangerLevel", strParams)
   
      title$ = "#Creation of Automatic stock orders complete" '10Aug05 TH (#81783)
      msg$ = vbCr + " " + Str$(numofitemsadded) & TB & " item(s) added to order" + vbCr
      msg$ = msg$ + " " + Str$(numofitemsamended) & TB & " item(s) amended on order" + vbCr       '07Dec98 TH  Added
      msg$ = msg$ + " " + Str$(numofa) & TB & " item(s) awaiting raising" + vbCr
      msg$ = msg$ + " " + Str$(numofi) & TB & " item(s) awaiting confirmation of transmission " + vbCr
      msg$ = msg$ + " " + Str$(numofd) & TB & " item(s) awaiting receipt" + vbCr
      msg$ = msg$ + " " + Str$(numofdb) & TB & " item(s) awaiting receipt and below danger level" + vbCr
      msg$ = msg$ + " " + Str$(numofout) & TB & " item(s) added since outstanding and not stocked" + vbCr
      popmessagecr title$, msg$
   End If

Exit Sub

ChkLvlsQtyErr:

Dim ErrNum%, escd%
Dim ans$, text$

   ErrNum = Err
   Select Case ErrNum
      Case 6
         text$ = "Order Number : " & ord.num & cr$
         text$ = text$ & "Local Code : " & ord.Code & cr$
         text$ = text$ & "Order Qty  : " & ord.outstanding & cr$
         text$ = text$ & "Pack Size  : " & d.convfact & cr$ & cr$
         text$ = text$ & "This order is too large for the system to handle. Please" & cr$
         text$ = text$ & "delete this order and raise two smaller orders." & cr$
         popmsg "Error", text$, 48, ans$, escd%
      Case Else
   End Select
   Close
   storesEnd

   Resume Next

End Sub

Sub Printorder(blnRefreshifONumToDisplayAltered As Boolean, ByVal blnPSO As Boolean)
'----------------------------------------------------------------------------
'                   Prints the current order on the screen
'                   page by page starting at startpoint of file
'                   order.asc. Fills array orderinf() with ASC codes
'
'17sep10 TH Added param to add line procs to allow for trade name switch (F0096592)
'02JUn11 CKJ removed statics - not used
'27Jun11 CKJ AlternativeDBLayer option deprecated. Now only uses the SQL version,
'            equivalent to AlternativeDBLayer="Y". Deleted old code
'22Jul11 XN  maintain gird sort order on refreshed (F0102524), (F0102526), (F0102527)
'14Aug12 TH  Added PSO Flag as parameter - support for New PSO Grids(TFS 41372)
'15Aug12 TH  Added to allow sort on Surname (TFS 41430)
'10Oct12 TH  Added Forename and DOB to sort (TFS 41571)
'14Feb13 TH  Changed default sort order for PSO (TFS 56641)
'19Dec15 TH  Sorts of rs not currently supported in the ado rs from web transport (TFS 138697)
'----------------------------------------------------------------------------

'Static dbuflen%, DrugDesc()  As String

Dim DontPrintToFollow%, credit%, edtype%, Selected%, infobarred%
Dim Find%, FoundSup%
Dim temp1$
Dim pointer&, found&, X&
'27Jun11 CKJ Unused, Removed:  cont&
Dim startposn&, toomany%, contstore&
Dim rsOrders    As ADODB.Recordset
Dim strParams As String
Dim intTop As Integer
Dim intArraySize As Integer
Dim lngPickno As Long
Dim strSupCode As String
Dim strCode As String
Dim strStatus As String
Dim strNum As String
Dim blnRequis As Boolean
Dim wndStyle As Long '05Oct05 TH Added
Dim strOrderSetting As String  '21Oct05 TH Added

   intArraySize = ONumToDisplay
   Select Case Edittype
      Case 1, 5, 10: MainScreen.LblInput.Caption = "Enter code for amendment or addition"
      Case 3:        MainScreen.LblInput.Caption = "Enter code for item to be received"
      Case -3:       MainScreen.LblInput.Caption = "Enter code for item to be added"
      Case -4, 4:    MainScreen.LblInput.Caption = "Enter code for item to be reconciled"
      Case 6:        MainScreen.LblInput.Caption = "Enter code for item to be issued"
      Case 9:        MainScreen.LblInput.Caption = "Enter code for item to be credited"
      End Select

   DontPrintToFollow = False
   If ordernum$ = "F" Then DontPrintToFollow = True: ordernum$ = "A"
   
   'If dbuflen = 0 Then ReDim Preserve DrugDesc(1 To 6, 1 To 25) As String

   credit = Sgn(Edittype)
   edtype = Abs(Edittype)
   temp1$ = "supplier"

   'getnumofords edtype, pointer&, False
   startposn& = ONumToDisplay
   
   'cont& = IndexStartPos&    '27Jun11 CKJ Unused
   X& = OrderStartPos&        '   "        Why copy to X and then back? Replace x& with OrderStartPos& ?
   intTop = Val(TxtD(dispdata & "\winord.ini", "defaults", Format$((3 * OInfoMaxLen)), "MaxRow", 0))     '////why fetch 3*20?
   '---
   'Get the record set here, iterate through it and do what needs to be done supcode
   'strSQL = "Select * from [Order] where Num = '" & ordernum$ & "' and status = '" & CStr(edtype) & "'"
   strCode = ""
   strNum = ""
   strSupCode = ""
   lngPickno = 0
   
   Select Case Edittype
      Case 1, 2, 3, 9, -3
         If Trim$(ordernum$) = "A" Then
            If osite$ <> "A" Then
               strSupCode = osite$
            End If
         Else
            If Trim$(ordernum$) <> "" And Trim$(ordernum$) <> "A" Then
               strNum = ordernum$
            End If
         End If
         
         strStatus = CStr(edtype)
        
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupCode) & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, strCode) & _
                     gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, Val(strNum)) & _
                     gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, OrderStartPos&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, intTop)
         If (Edittype = 1 Or Edittype = 3) And blnPSO Then '14Aug12 TH Added support for New PSO Grids(TFS 41372)
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteriaSlimLinePSO", strParams)
         Else
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteriaSlimLine", strParams)
         End If
      Case -4, 4
         strStatus = "4"
         
         If Trim$(ordernum$) = "" Or Trim$(ordernum$) = "A" Then
            strNum = "-1" '05Dec05 TH This must now be set to -1 as zero is a valid order number for directorder reconciliation
         Else
            strNum = ordernum$
            If Len(Format(Val(strNum))) <> Len(strNum) Then strNum = "-66" '80464 Frig to prevent return of data for alpha entries
         End If
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
                     gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strSupCode) & _
                     gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(strNum)) & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, strCode) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, X&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, intTop)
         If Edittype = 4 Then
            If blnPSO Then '14Aug12 TH Added support for New PSO Grids(TFS 41372)
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaINVOICESlimlinePSO", strParams)
            Else
               Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaINVOICESlimline", strParams)
            End If
         Else
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaCREDITSlimLine", strParams)
         End If
      
      Case Else
         strSupCode = ""
         strCode = ""
         lngPickno = 0
         If (osite$ <> "A") Then
            strSupCode = osite$
            If ordernum$ <> "A" Then strNum = Trim$(ordernum$)
         ElseIf (ordernum$ <> "" And ordernum$ <> "A") Then
            lngPickno = Val(ordernum$)   '26Aug05 TH Added
         End If
         strStatus = CStr(edtype)
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupCode) & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, strCode) & _
                     gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, strNum) & _
                     gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, lngPickno) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, X&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, intTop)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteriaSlimline", strParams)
      End Select
      
   If Not rsOrders.EOF Then
   
      If Not TypeOf gTransport Is PharmacyWebData.Transport Then   '19Dec15 TH Sorts of rs not currently supported in the ado rs from web transport (TFS 138697)
         strOrderSetting = ""
         If blnPSO Then '15Aug12 TH Added to allow sort on Surname (TFS 41430)
            strOrderSetting = "OrderScreenbySurnamePSO" & Format$(Edittype)
            If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", strOrderSetting, 0)) Then  '14Feb13 TH Changed default for PSO (TFS 56641)
               rsOrders.Sort = "Surname,Forename,DOB" '10Oct12 TH Added Forename and DOB to sort (TFS 41571)
            Else
               strOrderSetting = "OrderScreenbyDescription" & Format$(Edittype)
               If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", strOrderSetting, 0)) Then rsOrders.Sort = "Description" '
            End If
         Else
            strOrderSetting = "OrderScreenbyDescription" & Format$(Edittype)
            If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", strOrderSetting, 0)) Then rsOrders.Sort = "Description" '
         End If
      End If
      
      rsOrders.MoveFirst
      Do While Not rsOrders.EOF
         Select Case Edittype
            Case 1, 2, 3, 9, -3: X& = GreaterOf(X&, rsOrders.fields("WOrderID"))
            Case 4, -4: X& = GreaterOf(X&, rsOrders.fields("WReconcilID"))
            Case Else:  X& = GreaterOf(X&, rsOrders.fields("WRequisID")): blnRequis = True
         End Select
         
         If blnRequis And DontPrintToFollow Then
            If RtrimGetField(rsOrders!tofollow) <> "1" Then AddLineToDisplaySQL edtype, rsOrders, toomany%, True, sup.ptn, blnPSO '17sep10 TH Added param (F0096592) '14Aug12 TH Added support for New PSO Grids(TFS 41372)
         Else
            AddLineToDisplaySQL edtype, rsOrders, toomany%, True, sup.ptn, blnPSO '17sep10 TH Added param (F0096592) ''14Aug12 TH Added support for New PSO Grids(TFS 41372)
         End If
         
         '22Feb99 TH the following is wanted to be changed to sort all in a page
         'If ONumToDisplay >= startposn& + (3 * OInfoMaxLen) Then Exit Do
         If ONumToDisplay >= startposn& + intTop Then Exit Do
         If toomany Then Exit Do       '//// ever set?
         rsOrders.MoveNext
      Loop
   End If
   '----------------------------------------
   
   ' 22Jul11 XN maintain gird  sort order on refreshed (F0102524), (F0102526), (F0102527)
   ' If columns are already sorted, the ensure the order is maintained
   If (MainScreen.m_LastColumnSorted > 0) And (MainScreen.m_LastColumnSorted <= UBound(OColumnType)) Then
      ' Get info on column type
      Dim ColumnType As String
      ColumnType = "text"
      If MainScreen.m_LastColumnSorted <= UBound(OColumnType) Then
              ColumnType = OColumnType(MainScreen.m_LastColumnSorted)
      End If

     ' Sort MM-827
      shellsort OInfoStore(), (ONumToDisplay), (MainScreen.m_LastColumnSorted), "|", ColumnType, TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "Y", "CaseSensitiveHeaderSort", 0))

     ' Revers order is needed
      If Not MainScreen.m_SortOrderAsc Then
            ReverseStringArray OInfoStore
      End If
   End If
   ' End of 22Jul11 XN maintain gird  sort order on refreshed (F0102524), (F0102526), (F0102527)
      
   If Not infobarred Then
      If ordernum$ <> "A" And ordernum$ <> "F" Then
         getsupplier ord.supcode, (Find), (FoundSup), sup
      End If
      infobarred = True
   End If

   'IndexStartPos& = cont&  '27Jun11 CKJ Unused
   OrderStartPos& = X&
      
   'SQL If ONumToDisplay = 0 Then MainScreen.lvwMainScreen.RowIndex = 0
   If blnRefreshifONumToDisplayAltered Then
      If ONumToDisplay <> intArraySize Then
          'MainScreen.lvwMainScreen.Refresh  27Jun11 CKJ handled in next line
          RefreshLVWMainScreen False, False
      End If
   Else
      MainScreen.lvwMainScreen.Refresh
      RefreshLVWMainScreen False, False
   End If
   
   If MainScreen.TxtInput.Visible Then MainScreen.lvwMainScreen.SetFocus
   
   If Edittype = 4 Then          '////why for reconcil only?
      MainScreen.lvwMainScreen.Visible = True
      MainScreen.lvwMainScreen.SetFocus
   End If
   
   If MainScreen.lvwMainScreen.Visible = True Then
      ' Retrieve the window style of the control.
      wndStyle = GetWindowLong(MainScreen.lvwMainScreen.Hwnd, GWL_STYLE)
   
      ' Test if the horizontal scroll bar style is present
      ' in the window style, indicating that a horizontal
      ' scroll bar is visible.
      If (wndStyle And WS_HSCROLL) <> 0 Then
         MainScreen.lvwMainScreen.Width = MainScreen.lvwMainScreen.Width + 300 'Nudge out the lstview to make sure we get rid of the critter
      End If
   End If

End Sub

Public Sub RefreshLVWMainScreen(ByVal blnNewItem As Boolean, ByVal blnWardStock As Boolean)
'V93 SQL Moved old fetch stuff here for now
'27Jun11 CKJ Noted that param blnNewItem is never used, but no functional change made. Removed commented code & the duplicated logic.   '////

Dim rowline$
Dim intNumofColumns As Integer
Dim lngRow As Long
Dim strKey As String
Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem
Dim intloop As Integer

   'Redraw the whole thing for now                             '////should not need to blank & refill every time
   ReDim lines$(OTblMaxCols + 1)
   
   MainScreen.lvwMainScreen.ListItems.Clear
   For lngRow = 1 To ONumToDisplay    '27Jun11 CKJ was To UBound(OInfoStore)
      If lngRow <= UBound(OInfoStore) Then
         rowline$ = OInfoStore(lngRow)
         deflines rowline$, lines$(), "|(*)", 1, intNumofColumns
         'set the key here for row and column to enter the row data
         'Value = Trim$(lines$(col))
         strKey = "R" & CStr(lngRow)
         
         Set lvwItem = MainScreen.lvwMainScreen.ListItems.Add(, strKey & ":C1", lines$(1))
         If blnWardStock And lines$(5) = "&" Then '08Nov05 Complicated switch to ensure titles are bold for WSList. Hack . Sorry
            lines$(5) = ""
            lvwItem.Bold = True
         End If
               
         For intloop = 2 To intNumofColumns 'Loop through the columns, set the key (rX:cX)
            lvwItem.ListSubItems.Add , strKey & ":C" & CStr(intloop), lines$(intloop)
         Next
       End If
    Next
   
End Sub

Public Sub RefreshlvwMainScreenRow(ByVal lngRow As Long, ByVal blnWardStock As Boolean)
'V93 SQL Moved old fetch stuff here for now

Dim strRowline As String
Dim intNumofColumns As Integer
Dim strKey As String
Dim lvwItem       As ListItem
Dim intloop As Integer
   
   ReDim strLines(OTblMaxCols + 1) As String
   strRowline = OInfoStore(lngRow)
   deflines strRowline, strLines(), "|(*)", 1, intNumofColumns
   Set lvwItem = MainScreen.lvwMainScreen.ListItems.Item(lngRow)
   For intloop = 1 To intNumofColumns - 1 'Loop through the columns
      lvwItem.ListSubItems.Remove 1
   Next
   lvwItem.text = strLines(1)
   If blnWardStock And strLines(5) = "&" Then '08Nov05 Complicated switch to ensure titles are bold for WSList. Hack . Sorry
      strLines(5) = ""
      lvwItem.Bold = True
   Else
      lvwItem.Bold = False
   End If
   strKey = "R" & CStr(lngRow)
   For intloop = 2 To intNumofColumns
      lvwItem.ListSubItems.Add , strKey & ":C" & CStr(intloop), strLines(intloop)
   Next
       
End Sub

Sub PrintPaperOrder(RTFfile$, Extrafile$, supcode$, printedok%, ByVal strDLO As String, ByVal blnPSO As Boolean)
'21Jul10 TH  Mod to set up header and footer for a batch output interface file (F0077944)
'07Sep10 TH  Add linenumber onto the heap for UMMC (FINV) ordering interface (F0054531)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'15May12 TH  Mods to record contract information in the WOrderlog (TFS 30860)
'24Mar13 TH  Added PSO check on cancelled prescriptions (TFS 59468)
'07Jan17 TH  Replace check on file for RTF DB Handling
'26Jan17 TH  Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'12Feb17 TH  Removed call to kill reprint as now inappropriate (TFS 176106)

Dim FILE$, temp$, printedordno$, ordernumb$, dataline$, extraline$
Dim msg$, SisCode$, dateord$, daterec$, qtyord$, qtyrec$, cost$, contract$
Dim success%, filno%, lineno%, Y%, attop%, pageno%  ', orderno%
Dim printtn%, printsis%, numberprinted%, loopvar%
Dim X&, pointer&
Dim pforprinting!, VatForPrinting!, PtotordCost!, PtotordVat!
Dim ordtitle$    '15Jan98 EAC added
Dim include%, found%  '12Nov98 TH  added
Dim numbers$ '22Jan99 TH
Dim foundPtr As Long   '01Jun02 ALL/ATW
Dim dummy&
Dim strSql As String
Dim strTable As String
Dim strParams As String
Dim lngLastOrderno As Long '01Nov05 TH Added
Dim lngLoop As Long

Dim strContractNumber As String   '15May12 TH Added (TFS 30860)
Dim strContractPrice As String    '    "
Dim blncontract As Boolean        '    "

''Dim objDataAccess As New clsDataAccess
Dim rsOrders As ADODB.Recordset
Dim lngOrderno As Long
Dim strRTFFile As String  '20Aug12 TH Added PSO
Dim strPSOMsg As String       '24Mar13 TH (TFS 59468)
Dim strDrugDesc As String     '  "
Dim strName As String         '  "
Dim blnPSOCancel As Boolean   '  "
Dim strCasenum As String      '  "
Dim strNHNumber As String     '  "

Dim eHubHeapID As Integer     '04Mar14 TH Added
Dim intSuccess As Integer     '  "
Dim str_eHubsp As String      '  "

Dim lngPSOPatientID As Long   '22Aug14 Th Added


   ReDim picklist(1000) As String
   
   getorderno 1, lngOrderno, False
   ordernumb$ = LTrim$(Str$(lngOrderno))
   blnPSOCancel = False  '24Mar13 TH set PSO Abort flag (TFS 59468)
   lngPSOPatientID = 0
   
   Do
      MakeLocalFile FILE$
      filno = FreeFile
      Open FILE$ For Binary Access Write Lock Read Write As #filno
   
      'GetTextFile dispdata$ + RTFfile$, dataline$, success
      GetRTFTextFromDB dispdata$ + RTFfile$, dataline$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
            popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
            printedok = False
            Exit Sub
         End If
      
      'GetTextFile dispdata$ + Extrafile$, extraline$, success
      GetRTFTextFromDB dispdata$ + Extrafile$, extraline$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
            popmessagecr "Error", "There was a problem reading the RTF layout file - " & Extrafile$
            printedok = False
            Exit Sub
         End If
   
      'strip the begining of RTF file bracket from the rtf strings
      If LCase$(Left$(dataline$, 5)) = "{\rtf1" Then dataline$ = Mid$(dataline$, 2)
      If LCase$(Left$(extraline$, 5)) = "{\rtf1" Then extraline$ = Mid$(extraline$, 2)

      'write start of rtf file bracket
      temp$ = "{"
      Put #filno, , temp$
   
      printedordno$ = ordernumb$
      '''getnumofords edittype, pointer&, False
   
      '''binarysearchidx "", "", 0, 0, 0  '!!** is this needed now?
   
      Y = 0
      lineno = 0
      attop = True
      pageno = 0
      'Reset costs
      PtotordCost! = 0
      PtotordVat! = 0
      
      'Now select just those records that are required.
      strTable = "WOrder"
      strSql = "Select * from [" & strTable & "] where Status = '1' and supcode ='" & Trim$(supcode$) & "'"
      ''Set objDataAccess = New clsDataAccess
      
      ''If objDataAccess.GetRecordset(strSql, rsOrders) Then
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1") & _
                  gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, Trim$(supcode$)) & _
                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 1, "") & _
                  gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("MaxID", trnDataTypeint, 4, 0)
      If blnPSO And sup.Method = "H" Then
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderHubPSObyCriteria", strParams)
      Else
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
      End If
      If Not rsOrders.EOF Then
         '24Mar13 TH Added PSO check on cancelled prescriptions (TFS 59468)
         If blnPSO Then
            '22Aug14 Th Added Pateint check for Hub orders - Only 1 patient per order is allow ed for PSo Orders - After talking with Andrewwe require this to be done automatically
            rsOrders.MoveFirst
            Do While Not rsOrders.EOF
               ord = FillOrdFromRS(rsOrders, "WOrder")
               include = True
               If PartsOrder Then
                  include = False
                  For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
                     If (ord.OrderID = MainScreen.lvwMainScreen.ListItems(lngLoop).ListSubItems(12).text) And MainLVWIsItemSelected(lngLoop) Then include = True
                  Next
               End If
               If Val(ord.PSORequestID) < 1 Then include = False
               If include Then
                  'Now we need to check if the prescriptions are cancelled
                  If IsParentPrescriptionCancelled(ord.PSORequestID) Then
                     'we will need the patient details here
                     FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0
                     d.SisCode = ord.Code
                     getdrugsup d, 0, 0, False, ord.supcode
                     'strDrugDesc = d.storesdescription
                     'If Trim$(strDrugDesc) = "" Then strDrugDesc = d.Description       XN 4Jun15 98073 New local stores description
                                         strDrugDesc = d.DrugDescription
                     plingparse strDrugDesc, "!"
                     Heap 11, gPRNheapID, "psoNameDOB", strName, 0
                     Heap 11, gPRNheapID, "psoCasenumber", strCasenum, 0
                     Heap 11, gPRNheapID, "psoNHnumber", strNHNumber, 0
                     strPSOMsg = strPSOMsg & "Quantity: " & Format(ord.qtyordered) & " of " & Trim$(strDrugDesc) & " For: " & strName & " Case Number: " & Trim$(strCasenum) & " NH Number: " & strNHNumber & crlf
                     ClearHeapPSOrderInfo gPRNheapID
                  End If
               End If
               rsOrders.MoveNext
            Loop
            If strPSOMsg <> "" Then
               'strPSOMsg = "The order could not be authorised because the prescriptions for the following orders have been cancelled." & crlf & crlf & strPSOMsg
               '25Mar13 TH Replaced above after email clarifications from Andrew
               strPSOMsg = "The following could not be authorised as the prescriptions are not current." & crlf & crlf & strPSOMsg
               
               popmessagecr "Patient Specific Ordering", strPSOMsg
               blnPSOCancel = True
            End If
         End If
         '24Mar13 TH ----
         
         If Not blnPSOCancel Then '24Mar13 TH Abort flag could be set from above check (TFS 59468)
            rsOrders.MoveFirst
            Do While Not rsOrders.EOF
               ord = FillOrdFromRS(rsOrders, "WOrder")
               include = True
               
               '11Jun12 TH For DLO we need to only use the DLO lines
               If UCase$(Trim$(strDLO)) <> UCase$(Trim$(ord.DLOWard)) Then include = False
               
               If include Then '11Jun12 TH DLO Added
                  If PartsOrder Then
                     include = False
                     For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
      '                 'MainScreen.lvwMainScreen.ListItems.item = i
      '                 '''MainScreen.lvwMainScreen.SelectedItem.Index = i
      '                 MainScreen.lvwMainScreen.ListItems(i).Selected = True
      '                 'If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And OMarked(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True                            '02Jun11 CKJ
      '                 If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And MainLVWIsItemSelected(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True    '    "            '////
                        If blnPSO Then
                        'we need a different mechanism as we can have multiple products for same supplier now (different patients)
                           If (ord.OrderID = MainScreen.lvwMainScreen.ListItems(lngLoop).ListSubItems(12).text) And MainLVWIsItemSelected(lngLoop) Then include = True
                        Else
                           '//// still not happy that this is guaranteed to pick the correct items
                           If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).text)) And MainLVWIsItemSelected(lngLoop) Then include = True
                        End If
                     Next
                  End If
               End If
               
               '20Aug12 TH PSO Check
               If include Then
                  If blnPSO Then
                     If Val(ord.PSORequestID) < 1 Then include = False
                  Else
                     If Val(ord.PSORequestID) > 0 Then include = False
                  End If
               End If
               
               If include Then
               
                  '22Aug14 TH Here we need to see if we are on a patient boundary, if so we need to create a new order
                  If sup.Method = "H" And blnPSO Then
                     ''Do pat Check
                     'If lngPSOPatientID = 0 Then
                        'lngPSOPatientID = PatientIDFromPSOrderInfo(ord.OrderID)
                     'ElseIf lngPSOPatientID <> PatientIDFromPSOrderInfo(ord.OrderID) Then
                     'If (lngPSOPatientID <> 0) And (lngPSOPatientID <> PatientIDFromPSOrderInfo(ord.OrderID)) Then
                     If (lngPSOPatientID <> 0) And (lngPSOPatientID <> RtrimGetField(rsOrders!PatientID)) Then
                        lineno = 0
                        If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
                           strRTFFile = "\ordtotal.rtf"
                           
                           'If fileexists(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf"
                           '07Jan17 TH Replace check on file
                           'GetRTFTextFromDB dispdata$ & "\PSO_ordtotal.rtf", "", intSuccess
                           'If intSuccess Then strRTFFile = "\PSO_ordtotal.rtf"
                           If RTFExistsInDatabase(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf" '26Jan17 TH
                           PrintOrdTotal filno, strRTFFile, PtotordCost!, PtotordVat!, 0, 0
                        End If
         
                        printordertail filno%, sup.ordmessage, blnPSO
                        attop = True
                        
                        'Reset costs ready for next order
                        PtotordCost! = 0
                        PtotordVat! = 0
                        'lngPSOPatientID = PatientIDFromPSOrderInfo(ord.OrderID)
                     End If
                     'lngPSOPatientID = PatientIDFromPSOrderInfo(ord.OrderID)
                     lngPSOPatientID = RtrimGetField(rsOrders!PatientID)
                  End If
               
                  Y = Y + 1
                  If attop Then
                     If pageno > 0 Then
                        temp$ = "[FF]"
                        PrinterParse temp$
                        Put #filno, , temp$
                     End If
                     pageno = pageno + 1
                     printedordno$ = LTrim$(Str$(lngOrderno + pageno% - 1))
                     If pageno > 1 Then ordtitle$ = ordtitle$ & ","
                     ordtitle$ = ordtitle$ & " " & printedordno$
                     printordertop supcode$, printedordno$, filno%, printtn%, printsis%, 0, blnPSO
                     attop = False
                     PrintOrdDescriptor filno, printtn, blnPSO
                  End If
      
                  lineno = lineno + 1
                  'picklist(Y) = LTrim$(Str$(x&)) 'was 4 chars only
                  picklist(Y) = LTrim$(Str$(rsOrders.fields("WOrderID")))
                  
                  temp$ = "{"
                  Put #filno, , temp$
      
                  OrderLineParse ord, dataline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, pforprinting!, VatForPrinting!, True, blnPSO
                  If printtn Or OrdPrintPrice Then OrderLineParse ord, extraline$, filno%, printsis, printtn%, lineno%, PtotordCost, PtotordVat!, pforprinting!, VatForPrinting!, False, blnPSO
      
                  temp$ = "}"
                  If OrdPrintLin Then temp$ = "[cr]}"
                  PrinterParse temp$
                  Put #filno, , temp$
                  
               End If
               '22Aug14 TH Here we need to see if we are on a patient boundary, if so we need to create a new order
         
               If lineno >= GetMaxNoOfLinesForOrder(sup.Method) Then   ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
                  lineno = 0
                  If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
                     '20Aug12 TH PSO Need to swap rtf
                     strRTFFile = "\ordtotal.rtf"
                     If blnPSO Then
                        '07Jan17 TH Replaced
                        'If fileexists(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf"
                        'GetRTFTextFromDB dispdata$ & "\PSO_ordtotal.rtf", "", intSuccess
                        'If intSuccess Then strRTFFile = "\PSO_ordtotal.rtf"
                        If RTFExistsInDatabase(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf" '26Jan17 TH Replaced above lines

                     End If
                     'PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
                     PrintOrdTotal filno, strRTFFile, PtotordCost!, PtotordVat!, 0, 0
                  End If
   
                  printordertail filno%, sup.ordmessage, blnPSO
                  attop = True
                  
                  'Reset costs ready for next order
                  PtotordCost! = 0
                  PtotordVat! = 0
               End If
               rsOrders.MoveNext
            Loop
         End If
      End If
   
      If Not blnPSOCancel Then '24Mar13 TH Added (TFS )
         If Not attop Then
            If OrdPrintPrice And (PtotordCost! + PtotordVat!) <> 0 Then
               strRTFFile = "\ordtotal.rtf"  '20Aug12 TH PSO
               '29Jul14 TH Added support for Hub rtfs
               If sup.Method = "H" Then
                  'If fileexists(dispdata$ & "\Hub_ordtotal.rtf") Then strRTFFile = "\Hub_ordtotal.rtf"
                  '07Jan17 TH Replaced
                  'GetRTFTextFromDB dispdata$ & "\Hub_ordtotal.rtf", "", intSuccess
                  'If intSuccess Then strRTFFile = "\Hub_ordtotal.rtf"
                  If RTFExistsInDatabase(dispdata$ & "\Hub_ordtotal.rtf") Then strRTFFile = "\Hub_ordtotal.rtf"  '26Jan17 TH Replaced above lines
                  
                  If blnPSO Then
                     'If fileexists(dispdata$ & "\Hub_PSO_ordtotal.rtf") Then strRTFFile = "\Hub_PSO_ordtotal.rtf"
                     '07Jan17 TH Replaced
                     'GetRTFTextFromDB dispdata$ & "\Hub_PSO_ordtotal.rtf", "", intSuccess
                     'If intSuccess Then strRTFFile = "\Hub_PSO_ordtotal.rtf"
                     If RTFExistsInDatabase(dispdata$ & "\Hub_PSO_ordtotal.rtf") Then strRTFFile = "\Hub_PSO_ordtotal.rtf"  '26Jan17 TH Replaced above lines
                  End If
               Else
                  If blnPSO Then
                     'If fileexists(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf"
                     '07Jan17 TH Replaced
                     'GetRTFTextFromDB dispdata$ & "\PSO_ordtotal.rtf", "", intSuccess
                     'If intSuccess Then strRTFFile = "\PSO_ordtotal.rtf"
                     If RTFExistsInDatabase(dispdata$ & "\PSO_ordtotal.rtf") Then strRTFFile = "\PSO_ordtotal.rtf" '26Jan17 TH Replaced above lines
                  End If
               End If
               'PrintOrdTotal filno, "\ordtotal.rtf", PtotordCost!, PtotordVat!, 0, 0
               PrintOrdTotal filno, strRTFFile, PtotordCost!, PtotordVat!, 0, 0
            End If
         
            printordertail filno%, sup.ordmessage, blnPSO
         End If
         
         temp$ = "}"
         Put #filno, , temp$
         
         Close #filno
      
         printedok = False
            
         If Y > 0 Then
            If sup.Method = "F" Then
               WSspool FILE$, "Stock Control", 1, False, False, "FaxOrd"
               WSspool FILE$, "Stock Control", 1, True, True, ""
            Else
               If (sup.Method <> "H") Or TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Hubordering", "Y", "PrintOrderOutput", 0)) Then '29Jul14 TH Added to suppress if necessary prints on hub ordering
                  WSspool FILE$, "Stock Control", 1, True, True, "PurchOrd"
               End If
            End If
            printedok = True                                                     '13Nov98 TH
         Else
            Kill FILE$
            popmessagecr "!n!bSupplier " + supcode$, "No items ordered"
            k.escd = True
         End If
      Else           '24Mar13 TH (TFS )
         k.escd = True
      End If
   
   Loop Until printedok Or k.escd
   
   numberprinted = Y
   
   If printedok Then
      lineno = 0
      pageno = 1
      lngPSOPatientID = 0
      For loopvar = 1 To numberprinted
         'If Not partsorder Or (partsorder And include) Then   '12Nov98 TH   "
         lineno = lineno + 1
         getorder ord, Val(picklist(loopvar)), Edittype, True 'Locking ???
         
         '23Nov12 TH For DLO we need to only use the DLO lines - THIS was missing !
         'Need to check - wld seem we could fail to print none-DLO correctly, but still raise !
         'If UCase$(Trim$(strDLO)) <> UCase$(Trim$(ord.DLOWard)) Then include = False
         'NO cos we are using array of selected from above, its the PSO check below that is genuinely superfluous
         'and possibly even the partial check to - REVIEW and maybe remove if genuinely superfluous.
         
         
         'V93 Parts Order TODO
         include = True
         If PartsOrder Then
            include = False
            For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
'                  ''MainScreen.lvwMainScreen.SelectedItem.Index = i
'                  MainScreen.lvwMainScreen.ListItems(i).Selected = True
'                  tempcode$ = MainScreen.lvwMainScreen.SelectedItem.Text
'                  'If Trim$(UCase$(ord.code)) = Trim$(UCase$(tempcode$)) And OMarked(MainScreen.lvwMainScreen.RowIndex) Then include = True
'                  'If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And OMarked(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True                            '02Jun11 CKJ
'                  If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And MainLVWIsItemSelected(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True    '    "            '////
            
               '//// still for review
               If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).text)) And MainLVWIsItemSelected(lngLoop) Then include = True    '    "            '////
            Next
         End If
            
         '20Aug12 TH PSO Check
         If include Then
            If blnPSO Then
               If Val(ord.PSORequestID) < 1 Then include = False
            Else
               If Val(ord.PSORequestID) > 0 Then include = False
            End If
         End If
            
         If include Then
         
            If lineno > 1 And sup.Method = "H" And blnPSO And (lngPSOPatientID <> 0) And (lngPSOPatientID <> PatientIDFromPSOrderInfo(ord.OrderID)) Then
               lineno = 1
               pageno = pageno + 1
               'numbers$ = numbers$ & Str$(lngOrderno) & "," '22Jan99 TH
               getorderno 1, lngOrderno, -1
               'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D" '21Jul10 TH (F0077944)
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D", False '03Mar14 TH Added PSO Flag
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then BatchOrderlogOutputfooter "D", True '03Mar14 TH Added PSO Flag
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) And lineno = 1 Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D", False   '03Mar14 TH Added PSO Flag
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And lineno = 1 And (ord.PSORequestID > 0) Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D", True  '03Mar14 TH Added PSO Flag
            End If
            
            ord.status = "3"
            ord.received = ord.outstanding
            ord.qtyordered = ord.outstanding
            ord.num = LTrim$(Str$(lngOrderno))
            If lngLastOrderno <> lngOrderno Then
               numbers$ = numbers$ & Str$(lngOrderno) & "," '22Jan99 TH
               lngLastOrderno = lngOrderno
            End If
            ''updateordreqindex edittype, "", "", "", ord.num, Val(picklist(loopvar)) '27 Feb 92
            ord.orddate = thedate(False, True)
            ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
            d.SisCode = ord.Code
            getdrugsup d, 0, 0, False, ord.supcode
            strContractNumber = ""
            strContractPrice = ""
            If UCase$(ord.pflag) <> "M" Then
               If Val(d.contprice) > 0 Then
                  ord.cost = d.contprice
                  '15May12 TH Store contract information here for the log (TFS 30860)
                  strContractNumber = Trim$(d.contno)
                  strContractPrice = Trim$(d.contprice)
               Else
                  If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then
                     ord.cost = d.sislistprice 'price last paid
                  Else
                     ord.cost = d.cost
                  End If
               End If
            End If                             '28Jan99 TH
            '15May12 TH Here record the supplier we are using . We can compare later with the primary supplier
            '           to work out what kind of contract information we may need to store
               
            foundPtr = 0                                   '23Nov98 TH  Write last ordered date
            getdrug d, 0, foundPtr, True                   '23Nov98 TH  to drug file       '30Jun99 CFY Replaced
            '''getdrugsup d, 0, foundPtr, True, ord.supcode                                       '
            d.lastordered = Format$(Now, "ddmmyyyy")
            putdrug d ''', foundPtr
            InitAltSupplier
            dummy& = PutOrder(ord, Val(picklist(loopvar)), "WOrder")                 '<----UNLOCK  (no idx)
            ordernum$ = ord.num
            SisCode$ = ord.Code
            dateord$ = ord.orddate
            dateord$ = dateord$ & thedate(0, -2) '14Jan02 TH Added time for log (#53214)
            daterec$ = ""
            qtyord$ = ord.outstanding
            qtyrec$ = "0" '06Jan97 EAC changed from  qtyrec$ = ordqty$
            cost$ = ord.cost  '16Feb92 ASC better guess see above !
            'cost$ = d.cost' only the best guess!
               
            '15May12 TH Added to record contract info (TFS 30860)
            blncontract = False
            If d.supcode <> ord.supcode Then 'This is being ordered from a secondary supplier
               If Val(d.contprice) > 0 Then  'there is contract info for the primary supplier
                  If Not (Val(strContractPrice) > 0) Then
                     'secondary supplier has no contract, primary does, we flag this order. This also covers manual entry
                     blncontract = True
                  End If
               End If
            End If

            If InStr(LCase(Command$), "/verifyorders") <> 0 Then          '26Oct99 AE Added
               VerifySavedOrder Val(picklist(loopvar)), Edittype, ord     '     "
            End If                                                        '     "
            
            contract$ = ""    '24Feb94 CKJ Contract details
            If ord.supcode = d.supcode And Val(d.contprice) > 0 Then
               contract$ = Trim$(d.contno) ' 10 chars wide
               If contract$ = "" Then contract$ = "CONTRACT"
            End If
            'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) And lineno = 1 Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D" '21Jul10 TH (F0077944)
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) And lineno = 1 Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D", False   '03Mar14 TH Added PSO Flag
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And lineno = 1 And (ord.PSORequestID > 0) Then BatchOrderlogOutputHeader ord.supcode, lngOrderno, "D", True  '03Mar14 TH Added PSO Flag
            
            Heap 10, gPRNheapID, "OrderLineNumber", Format$(lineno), 0  '07Sep10 TH Add linenumber onto the heap (F0054531)
            Heap 10, gPRNheapID, "OrderMessage", getspecialmsg(), 0  '07Sep10 TH Add linenumber onto the heap (F0054531)
               
            'Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, qtyrec$, cost$, ord.supcode, "D", SiteNumber, contract$, d.vatrate, "", "", "" '14Jan94 CKJ VAT
            
            setContractData strContractNumber, strContractPrice, blncontract '15May12 TH (TFS 30860)
            
            '04Mar14 TH eHub integration - Fill heap here with info
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then
               '03Mar14 TH eHub integration work (TFS)
               If TrueFalse(TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLineTransfer", 0)) Then
                  'We are using Hub integration
                  'Here we call a configurable sp with some simple IDs from the Order Line
                  'This is used to bring back data for the heap for inclusion in any file based output.
                  'It can also be used for trasmission of data via the DB if required.
                  Heap 2, eHubHeapID, "", "", False 'For Safety completely clear heap both before and after - this has patient specific info
                  Heap 1, eHubHeapID, "eHub Integration Data Heap", "", intSuccess
                  If Not intSuccess Then
                     popmessagecr "eHub", "Failed to allocate data heap for eHub Integration"
                  Else
                     str_eHubsp = TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLinesp", 0)
                     If Trim$(str_eHubsp) <> "" Then
                        FillHeapeHubInfo eHubHeapID, ord.PSORequestID, str_eHubsp, 0
                        'ParseItems eHubHeapID, RTFTxt$, 0
                        seteHUBHeapID eHubHeapID 'Make visible to Orderlog routine
                     End If
                  End If
               End If
               FillHeapPSOrderInfo gPRNheapID, ord.OrderID, 1, 0
            End If
            'Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, qtyrec$, cost$, ord.supcode, "D", SiteNumber, contract$, d.vatrate, "", "", "", ""  '02Nov10 AJK F0086901 Added paydate
            Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, qtyrec$, cost$, ord.supcode, "D", SiteNumber, contract$, d.vatrate, "", "", "", "", ord.PSORequestID  '03Mar14 TH Added PSORequestID
            setContractData "", "", False '15May12 TH (TFS 30860)
            
            If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then
               If TrueFalse(TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLineTransfer", 0)) Then
                  Heap 2, eHubHeapID, "", "", False 'For Safety completely clear heap both before and after - this has patient specific info
               End If
            End If
            
            If lineno >= GetMaxNoOfLinesForOrder(sup.Method) Then ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
               lineno = 0
               pageno = pageno + 1
               'numbers$ = numbers$ & Str$(lngOrderno) & "," '22Jan99 TH
               getorderno 1, lngOrderno, -1
               'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D" '21Jul10 TH (F0077944)
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D", False '03Mar14 TH Added PSO Flag
               If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then BatchOrderlogOutputfooter "D", True '03Mar14 TH Added PSO Flag
            Else
               'If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D" '21Jul10 TH (F0077944)
               If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D", False '03Mar14 TH Added PSO Flag
               If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then BatchOrderlogOutputfooter "D", True '03Mar14 TH Added PSO Flag
            End If
            If sup.Method = "H" And blnPSO Then lngPSOPatientID = PatientIDFromPSOrderInfo(ord.OrderID)
         Else
            lineno = lineno - 1
            'If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D" '21Jul10 TH (F0077944)
            If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "D", False  '03Mar14 TH Added PSO Flag
            If (loopvar = numberprinted) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "PSOBatchOrderOutput", 0)) And (ord.PSORequestID > 0) Then BatchOrderlogOutputfooter "D", True  '03Mar14 TH Added PSO Flag
         End If
      Next
      
      numbers$ = Left$(numbers$, Len(numbers$) - 1)
      If InStr(numbers$, ",") > 0 Then msg$ = "s "
      popmessagecr "#", "Your Order has been given the number" & msg$ & " " & numbers$

      If lineno > 0 Then                  'Increment the order Number
         getorderno 1, lngOrderno, -1
      End If
      k.escd = True
   Else
      'KillReprint   '12Feb17 TH Removed as you cant get here if you have created a reprint and removing the reprint is now redundant (TFS 176106)
   End If
   
   Heap 10, gPRNheapID, "OrderLineNumber", "", 0  '07Sep10 TH Clean up linenumber (F0054531)

End Sub

Sub RefreshTblData(ByVal strPTN As String)

'14Jan98 EAC written
'17Sep10 TH added param (F0096592)

ReDim lines$(OTblMaxCols + 1)
Dim loopvar&, orderpointer&
Dim Numoflines%

   For loopvar& = 1 To ONumToDisplay&
      deflines OInfoStore(loopvar&), lines$(), "|(*)", 1, Numoflines
      orderpointer& = Val(lines$(OTblMaxCols + 1))
      getorder ord, orderpointer&, Edittype%, False
      
      AddLineToDisplay Edittype%, orderpointer&, 0, (loopvar&), strPTN, False '17Sep10 TH Added param
   Next
   
   MainScreen.lvwMainScreen.Refresh

End Sub

'11Jul11 CKJ Having carefully edited this, I find it's not actually used anywhere
'Sub RemoveLineFromDisplay()
'
'Dim missout As Long, loopvar As Long
'Dim highlight As Long
'
'   If ONumToDisplay <= 0 Then Exit Sub
'
'   ONumToDisplay = ONumToDisplay - 1
'
'   highlight = MainLVWMarqueeRowIndex
'   missout = False
'   For loopvar = 1 To ONumToDisplay
'      If loopvar = highlight Then missout = True
'      If missout Then OInfoStore(loopvar) = OInfoStore(loopvar + 1)
'   Next
'
'   If ONumToDisplay <= 0 Then
'      ONumToDisplay = 0
'      ReDim Preserve OInfoStore(1 To 1)
'   Else
'      ReDim Preserve OInfoStore(1 To ONumToDisplay)
'   End If
'   '02Jun11 CKJ: ReDim OMarked(1 To ONumToDisplay)
'   MainLVWRemoveSelection   '02Jun11 CKJ
'   If highlight > MainScreen.lvwMainScreen.ListItems.count Then highlight = MainScreen.lvwMainScreen.ListItems.count
'   MainLVWHighlightSingleRowByIndex highlight
'   MainScreen.lvwMainScreen.Refresh
'
'   On Error Resume Next '02Jun11 CKJ just in case stores prog is not top of z order
'   MainScreen.lvwMainScreen.SetFocus
'   On Error GoTo 0
'
'End Sub


Sub RequisitionEnquiry()
'01Mar00 TH Added Created User ID

Dim tempord As orderstruct
Dim tempdrug As DrugParameters
Dim ans$, txt$, desc$, temp$
Dim edtype%, Find%  ', foundsup%   '01Jun02 ALL/ATW
Dim cont&, found&, pointer&, X&
Dim strParams As String
Dim rsRequis As ADODB.Recordset
Dim blnBigScreen As Boolean
Dim strDescription As String

   blnBigScreen = TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "WideReqInfoScreen", 0))
   setinput 0, k
   k.escd = False
   k.Max = 10
   k.min = 1
   ans$ = ""
   InputWin "Requisition Query", "Enter requisition number", ans$, k
   
   If Not k.escd And Trim$(ans$) <> "" Then
      If blnBigScreen Then
         LstBoxFrm.Width = LstBoxFrm.Width + 6000
         LstBoxFrm.LstHdr.Width = LstBoxFrm.LstHdr.Width + 6000
         LstBoxFrm.LstBox.Width = LstBoxFrm.LstHdr.Width + 6000
         LstBoxFrm.cmdOK.Left = LstBoxFrm.cmdOK.Left + 6000
         LstBoxFrm.cmdCancel.Left = LstBoxFrm.cmdCancel.Left + 6000
      End If
   
      edtype = 5
      cont& = 0
      found& = 0
      
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, "") & _
                  gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, ans$) & _
                  gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
      Set rsRequis = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteria", strParams)
      
      Do While Not rsRequis.EOF
         tempord = FillOrdFromRS(rsRequis, "WRequis")
         ''getorder tempord, x&, edtype, False    ' (no idx)
         'poporder tempord, "DEBUG"

         BlankWProduct tempdrug
         tempdrug.SisCode = tempord.Code
         getdrug tempdrug, 0, 0, False
         desc$ = tempdrug.LabelDescription      ' desc$ = tempdrug.Description  XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"

         getsupplier tempord.supcode, Find, 0, sup
         temp$ = " x " & Trim$(tempdrug.convfact) & " " & Trim$(tempdrug.PrintformV)
         
         txt$ = tempord.Code & TB & desc$
         If UCase$(tempord.status) <> "D" Then
            If blnBigScreen Then
               strDescription = txt$
            Else
               LstBoxFrm.LstBox.AddItem txt$
            End If
         End If
         txt$ = Trim$(tempord.qtyordered) & temp$ & TB & Trim$(tempord.outstanding) & temp$ & TB & Trim$(tempord.supcode) & TB & Trim$(tempord.CreatedUser) & TB '01Mar00 TH Added Created User ID
         Select Case UCase$(tempord.status)
            Case "5":  txt$ = txt$ & "Edit"
            Case "6":  txt$ = txt$ & "For Issue"
            Case "7":  txt$ = txt$ & "For Delivery"
            Case "8":  txt$ = txt$ & "For GRN Modem"
            Case "R":  txt$ = txt$ & "Received"
            Case Else: txt$ = txt$ & tempord.status
            End Select
         If UCase$(tempord.status) <> "D" Then 'SQL Added
            If blnBigScreen Then
               LstBoxFrm.LstBox.AddItem strDescription & TB & txt$
            Else
               LstBoxFrm.LstBox.AddItem txt$
            End If
            LstBoxFrm.LstBox.AddItem ""
         End If
         rsRequis.MoveNext
      Loop

      LstBoxFrm.lblTitle = Chr$(13) & "Requisition No. " & ans$ & Chr$(13)
      If blnBigScreen Then
         LstBoxFrm.lblHead = "NSV Code" & TB & "Description" & Space(40) & TB & "Qty Ordered" & TB & "Outstanding" & TB & "Supplier" & TB & "Created By " & TB & "Status          "   '01Mar00 TH Added Created User ID
      Else
         LstBoxFrm.lblHead = "Quantity Ordered" & TB & "Outstanding" & TB & "Supplier Code" & TB & "Created By " & TB & "Status          "   '01Mar00 TH Added Created User ID
      End If
      LstBoxFrm.Caption = "Requisition Enquiry"
      LstBoxShow
      Unload LstBoxFrm
   End If

End Sub

Sub Selectforsupplier(Edittype%, sitepaths%, finished As Integer, ByVal blnPSO As Boolean)
'---------------Finds all items on order for one supplier---------------------
'01Sep08 TH (F23216) Update ordernumber fro EDI before modal box - still not perfect but less likely to cause duplicate order numbers
'16May10 TH Extend part ordering to EDI/Modem Orders (F0068698/F0058642)
'22Jul10 TH Set up batch output for internal orders in interface (UHB)(F0077942)
'26Jul10 TH Added some heap element handling to allow for SAGE fast track transfers to be used in the UHB interface (F0032689)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'01Jun11 CKJ Added as integer to finished param
'19Aug12 TH  Added PSO param
'12Sep12 TH  Changed tense of Internal order summary so cancel doesnt mislead (TFS 43632)
'26Jan17 TH  Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)

'STOREASC only
Dim tempord As orderstruct
Dim maxline%, supnum%, counter%, posn%, endposn%
Dim iordered%, filno%, linno%, drugordered%, Y%, valid%, success%
Dim savededittype%
Dim loopvar%, numofsups%
Dim supcode$, search$, ans$, ordernumb$, FILE$, title$, desc$, RTFTxt$
Dim receiptexpected$, cost$, SisCode$, dateord$, daterec$, msg$, temp$
Dim qtyord$, contract$, filelock$
Dim RTFfile$
Dim orderqty!
Dim pointer&, X&, reqpoint&
Dim shuffle%, successful%
Dim RTfFile2$
Dim issuecost$
Dim recvalue!, stockvalue!
Dim NotEnough%
Dim body$, warned%
Dim chars9 As String * 9
Dim include%   '27Jun11 CKJ Removed i%
Dim strRecdat As String
Dim lngFound As Long
Dim foundPtr As Long
Dim strTable As String  'V93
Dim lngFoundSup As Long
Dim lngOrderno As Long
Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim InternalOrderOutputTracking As Integer '22Jul10 TH Added (UHB)
Dim lngLoop As Long    '02Jun11 CKJ
Dim strDLO As String  '11Jun12 TH Added
Dim intSuccess As Integer  '07Jan17 TH Added

   maxline = 400
   setinput 0, k
   If Not PartsOrder Then
      supswithords Edittype, supcode$, numofsups, strDLO, blnPSO
   Else
      supcode$ = osite$
      'for partsorder we need to check all are same DLO, if not msg, set escd, otherwise set strDLO
   End If
   
   If Not k.escd Then
      'SQL ForgetPrinterList
      supnum = 0
      ReDim wildcard$(supnum)
   Else
       finished = True
   End If

   Do While Not k.escd
      If supnum = 0 Then
         getsupplier supcode$, 0, lngFoundSup, sup
         If sup.Method <> "T" Then
            displayspecialmsg False, 1, strDLO, blnPSO  '13Jun12 TH Added DLO Param '23Nov12 TH Added PSO param
            If k.escd Then lngFoundSup = -2 '01May05 TH
            '11Oct10 TH Added UMMC PRF (F0094388/RCN545)
            If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Ordering", "N", "AdditionalInstructions", 0)) Then
               CaptureAdditionalOrderMsg
               If k.escd Then lngFoundSup = -2
            End If
         End If
      Else
         supcode$ = wildcard$(supnum)
         supnum = supnum - 1
         getsupplier supcode$, 0, lngFoundSup, sup
      End If
      If Not k.escd Then '01May05 TH
         If lngFoundSup = 0 And Right$(supcode$, 1) = "*" Then
            supcode$ = UCase$(Left$(supcode$, Len(supcode$) - 1))
            counter = 0
            Do
               lngFound = 0
               Do While counter < numofsups
                  counter = counter + 1
                  If InStr(suppliers(counter), supcode$) = 1 Then
                     lngFound = counter
                     search$ = Left$(suppliers(counter), 5)
                     Exit Do
                  End If
               Loop
   
               If lngFound Then
                  ans$ = "Y"
                  k.helpnum = 0
                  Confirm "!n!bSupplier search", "include supplier " + search$ + " ", ans$, k
                  If k.escd Then
                     lngFoundSup = 0
                     supnum = 0
                     ReDim wildcard$(supnum)
                     Exit Do
                  ElseIf ans$ = "Y" Then
                     supnum = supnum + 1
                     ReDim Preserve wildcard$(supnum)
                     wildcard$(supnum) = Trim$(search$)
                  End If
               End If
            Loop While lngFound
   
            If supnum = 0 And Not k.escd Then popmessagecr "!n!b", "No suppliers matching '" + supcode$ + "' were found"
            lngFoundSup = -2      ' no further message below
            k.escd = False
         End If
      End If
      If lngFoundSup = -1 Then k.escd = True: lngFoundSup = 0

      '25Feb98 EAC prevent authorisation of transfer method orders until Adjustment Cost Centre has been defined.
      If sup.Method = "T" And trimz$(AdjCostCentre$) = "" Then
         msg$ = "Can not proceed to authorise this order until the Adjustment Cost Centre for Stock Transfers has been entered." & cr$ & cr$
         msg$ = msg$ & "Your system administrator can set this option in the ""Set Working Defaults"" option in the ""Utilities"" menu."
         popmessagecr "Authorise Order", msg$
         lngFoundSup = 0
         k.escd = True
      End If
      '---
      
      If lngFoundSup > 0 Then
         Select Case Storepasslvl
            Case 2, 7, 8
               filelock$ = dispdata$ + "\PRNTORD" + Trim$(Str$(Edittype)) + ".LCK"
               AcquireLock filelock$, 2, valid  ' exclusive, keep trying
               If Not valid Then
                  popmessagecr "Authorising Orders", "Another terminal is currently authorising orders. Please try again later."
                  Exit Sub
               End If
                  

               Select Case sup.Method
                  Case "T"  'Direct stock movement
                     Unload LstBoxFrm
                     getorderno Edittype, lngOrderno, 0
                     ordernumb$ = LTrim$(Str$(lngOrderno))
                     iordered = 0                              '25Feb98 EAC iordered now counts, changed from iordered = false
                     ''getnumofords edittype, pointer&, False

                     MakeLocalFile FILE$
                     filno = FreeFile
                     Open FILE$ For Binary Access Write Lock Read Write As #filno

                     'GetTextFile dispdata$ + "\csdata.rtf", RTFTxt$, success
                     GetRTFTextFromDB dispdata$ + "\csdata.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

                     If Not success Then
                        popmessagecr "Error", "There was a problem reading the RTF layout file - CSDATA.RTF"
                        Exit Sub
                     End If
                     striprtf RTFTxt$
                    
                     posn% = InStr(RTFTxt$, "[data]")
                     endposn% = InStr(posn, RTFTxt$, "]")


                            temp$ = "{"
                     Put #filno, , temp$

                     printconfirmtop filno, ordernumb$, title$
                        
                     'setup RTF for next lot of data
                     temp$ = Mid$(RTFTxt$, 1, posn - 1)
                     Put #filno, , temp$
                        
                     'print the header
                     PrintCSDescriptor filno

                     linno = 0

                     Screen.MousePointer = HOURGLASS   '27Feb98 ASC
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                     gTransport.CreateInputParameterXML("Status", trnDataTypeint, 4, "1") & _
                                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, UCase$(Trim$(supcode$))) & _
                                     gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                                     gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                                     gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                     Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
                     If Not rsOrders Is Nothing Then
                        If rsOrders.State = adStateOpen Then
                           If rsOrders.RecordCount <> 0 Then
                              Do While Not rsOrders.EOF
                                 ord = FillOrdFromRS(rsOrders, "WOrder")
                                 'code here for selected ordering !!!!!!!
                                 'Actually we could do to lock the order now
                                 
                                 getorder ord, ord.OrderID, 1, True '14Mar07 TH Added
                                 If PartsOrder Then
                                    include = False
                                    For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count    '11Jul11 CKJ corrected logic error - lngLoop was NOT used in the loop & repeated same action every time
'                                       'If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And OMarked(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True                 '02Jun11 CKJ
'                                       If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And MainLVWIsItemSelected(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True    '    "
                                       '//// still for review
                                       If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).text)) And MainLVWIsItemSelected(lngLoop) Then include = True
                                    Next
                                 End If

                                 If (Not PartsOrder And ord.status = "1" And Trim$(supcode$) = UCase$(Trim$(ord.supcode))) Or ((PartsOrder And ord.status = "1") And (Trim$(supcode$) = UCase$(Trim$(ord.supcode)) And include)) Then   '23Nov98 TH Filter out selected items from amend screen
                                    getsupplier ord.supcode, 0, lngFound, sup
                                    'Work on site where stock is ordered from
                                    '----------------------------------------
                                    SetDispdata Val(sup.icode)
                                    d.SisCode = ord.Code
                                    getdrug d, 0, foundPtr&, False
                                    If foundPtr& > 0 Then
                                       desc$ = d.LabelDescription       ' desc$ = d.Description XN 4Jun15 98073 New local stores description
                                       plingparse desc$, "!"
                                       desc$ = Left$(desc$ + Space$(56), 56)
                                       chars9 = Format$(dp!(Val(d.stocklvl) / Val(d.convfact)))                      '27Feb98 ASC/EAC
                                       If Val(chars9) >= Val(ord.outstanding) Then                                   '27Feb98 ASC/EAC
                                          receiptexpected$ = ord.outstanding
                                       Else
                                          receiptexpected$ = LTrim$(Str$(Int(dp!(Val(d.stocklvl) / Val(d.convfact))))) '23Jun93 CKJ dp
                                          If Val(receiptexpected$) < 0 Then receiptexpected$ = "0"
                                       End If
                                       NotEnough = False
                                       If Val(receiptexpected$) > 0 Then
                                          iordered = iordered + 1
                                          ord.received = receiptexpected$
                                          ord.qtyordered = Trim$(ord.outstanding)
                                          ord.orddate = thedate(False, True)
                                          ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
                                          ord.internalsiteno = LTrim$(Str$(sitepaths))
                                          ord.internalmethod = "I"
                                          ord.status = "D" 'Delord will delete later
                                                
                                          'Work on site issueing stock
                                          '----------------------------
                                          'EnterBatchNo ord, True   '23Feb98 ASC !!** still needs sorting
                                          'SetDispdata Val(sup.icode) 25Feb98 EAC commented out as this is done above
                                          
                                          Heap 10, gPRNheapID, "InternalOrderNumber", ordernumb$, 0  '26Jul10 TH Added (UHB)(F0032689)
               
                                          Translog d, 0, UserID$, "", Val(receiptexpected$) * Val(d.convfact), "Push/Pull", ord.supcode, "", "S", Val(sup.icode), "S", issuecost$
                                          
                                          Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '26Jul10 TH Added (UHB)(F0032689)
                                          
                                          'If UCase$(ord.pflag) = "M" Then issuecost$ = ord.cost'27Jan99 TH
                                          drugordered = True
                                          
                                          'Work on site receiving stock
                                          '---------------------------
                                          SetDispdata 0
                                          getdrug d, 0, foundPtr&, False   '01Jun02 ALL/ATW
                                          
                                          If Val(d.stocklvl) < 0 Then
                                             Translog d, 0, UserID$, "", Val(d.stocklvl), "Push/Pull", AdjCostCentre$, "", "S", sitepaths, "S", issuecost$
                                             'If UCase$(ord.pflag) = "M" Then issuecost$ = ord.cost'27Jan99 TH
                                          End If
                                          EnterBatchNo ord, True, ord.received, 0 '25Oct06 TH Added param '25Feb98 EAC Added '30Mar99 CFY Additional parameter added

                                          recvalue! = 1! * (Val(receiptexpected$) * Val(issuecost$))
                                          ord.cost = issuecost$
                                          strRecdat = thedate(False, True)        '15Jan02 TH Added time for log (#53214)
                                          strRecdat = strRecdat & thedate(0, -2)  '    "
                                          'If Not UCase(ord.pflag) = "M" Then ord.cost = issuecost$ '27Jan99 TH
                                          'Orderlog ordernumb$, ord.code, userid$, ord.orddate, Mid$(Date$, 4, 2) & Left$(Date$, 2) & Right$(Date$, 2), ord.outstanding, receiptexpected$, ord.cost, ord.supcode, "R", sitepaths, "", d.vatrate '03May98 CKJ Y2K
                                          'Orderlog ordernumb$, ord.code, userid$, ord.orddate, TheDate(False, True), ord.outstanding, receiptexpected$, ord.cost, ord.supcode, "R", sitepaths, "", d.vatrate '03May98 CKJ Y2K '15Jan02 TH Use new string that includes time
                                          Heap 10, gPRNheapID, "olToFollow", "N", 0  '26Jul10 TH Added (UHB)(F0032689)
                                          'Orderlog ordernumb$, ord.Code, UserID$, ord.orddate, strRecdat, ord.outstanding, receiptexpected$, ord.cost, ord.supcode, "R", sitepaths, "", d.vatrate, "", "", ""                             '    "      as well as date (#53214)
                                          'Orderlog ordernumb$, ord.Code, UserID$, ord.orddate, strRecdat, ord.outstanding, receiptexpected$, ord.cost, ord.supcode, "R", sitepaths, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                                          Orderlog ordernumb$, ord.Code, UserID$, ord.orddate, strRecdat, ord.outstanding, receiptexpected$, ord.cost, ord.supcode, "R", sitepaths, "", d.vatrate, "", "", "", "", ord.PSORequestID   '03Mar14 TH Added PSORequestID
                                          
                                          stockvalue! = 1! * dp!(Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost)
                                          getdrug d, 0, foundPtr&, True   '01Jun02 ALL/ATW
                                          d.stocklvl = LTrim$(Str$((Val(receiptexpected$) * Val(d.convfact)) + Val(d.stocklvl)))
                                          If Val(d.stocklvl) > 0 Then
                                             d.cost = LTrim$(Str$(dp!((stockvalue! + recvalue!) / (Val(d.stocklvl) / Val(d.convfact)))))
                                          Else
                                             d.cost = issuecost$    'd.cost from issueing site
                                          End If
                                          d.sislistprice = issuecost$
                                          d.lastordered = Format$(Now, "ddmmyyyy")     '10Jan00 AW changed
                                          putdrug d '', foundPtr&    '01Jun02 ALL/ATW
                                       Else
                                          NotEnough = True
                                       End If
                                    Else
                                       'not found on their file
                                       drugordered = False
                                    End If
                                    ''dispdata$ = sitepth$(0)
                                    SetDispdata 0
                                    X& = PutOrder(ord, (ord.OrderID), "WOrder")  'V93                          '<----UNLOCK  (no idx)
                                    '--------------print details on confirmation sheet--------------------
                                    linno = linno + 1
                                    If linno > 50 Then
                                       '?? need to tackle what happens if exactly 50
                                       linno = 0
                                       temp$ = "[FF]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                       'terminate the RTF string for the data segment
                                       temp$ = Mid$(RTFTxt$, endposn + 1, Len(RTFTxt$) - (endposn + 1))
                                       Put #filno, , temp$
                                       printconfirmtop filno, ordernum$, ""
                                       'print the header
                                       PrintCSDescriptor filno
                                    End If
                                    If drugordered Then
                                       cost$ = Str$(dp!(Val(issuecost$) / 100)) '27Feb98 ASC/EAC
                                       poundsandpence cost$, True
                                       On Error GoTo nostring
                                       body$ = body$ & ord.qtyordered & TB$ & receiptexpected$ & TB$ + Trim$(cost$) & TB$ & desc$ & crlf  '27Feb98 ASC  '27Feb98 ASC
                                       On Error GoTo 0
                                       temp$ = d.SisCode + " " + Trim$(desc$) + "    " + rightjust6(ord.qtyordered) + "    " + rightjust6(receiptexpected$) + "     " + rightjust6(cost$) + "[cr]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                    Else
                                       If NotEnough Then
                                          msg$ = " Not enough stock for transfer"
                                       Else
                                          msg$ = " Not found"
                                       End If
                                       msg$ = msg$ & " (item not raised)"
                                       On Error GoTo nostring
                                       body$ = body$ & "Cannot Raise this Order " & d.SisCode & "  " & desc$ & " : " & msg$ & crlf '27Feb98 ASC/EAC
                                       On Error GoTo 0
                                       temp$ = d.SisCode & "  " & desc$ & msg$ & "[cr]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                    End If
                                 End If
                                 rsOrders.MoveNext
                              Loop
                           End If
                        End If
                     End If
                     Screen.MousePointer = STDCURSOR
                     
                     'terminate the RTF string for the data segment
                     temp$ = Mid$(RTFTxt$, endposn + 1, Len(RTFTxt$) - (endposn + 1))
                     Put #filno, , temp$
                     
                     Close filno
                     If iordered > 0 Then
                        body$ = "Qty Ord" & TB$ & "Qty Exp" & TB$ & "Cost" & TB$ & "Description" & crlf & String$(80, "-") & crlf & body$
                        If Not warned Then
                           TextEdit "Transmitting order", body$, "", False, False
                        End If
                        getorderno 1, lngOrderno, -1
                        ans$ = ""
                        Confirm "Authorise Order", "Send report to printer Y/N", ans$, k
                        If ans$ = "Y" Then
                           WSspool FILE$, "Stock Control", 1, True, True, "PurchOrd"
                        Else
                           Kill FILE$
                        End If
                        k.escd = True
                        successful = True
                     Else
                        popmessagecr "!n!b", "No items ordered"
                        Kill FILE$
                        k.escd = True
                     End If

                     
                  Case "I" 'Internal on same machine across accounts
                     InternalOrderOutputTracking = 0 '22Jul10 TH set this - nothing to do (F0077942)
                        Unload LstBoxFrm
                     getorderno Edittype, lngOrderno, 0
                     ordernumb$ = LTrim$(Str$(lngOrderno))
                     iordered = False
                     MakeLocalFile FILE$
                     filno = FreeFile
                     Open FILE$ For Binary Access Write Lock Read Write As #filno

                     'GetTextFile dispdata$ + "\csdata.rtf", RTFTxt$, success
                     GetRTFTextFromDB dispdata$ + "\csdata.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

                     If Not success Then
                        popmessagecr "Error", "There was a problem reading the RTF layout file - CSDATA.RTF"
                        Exit Sub
                     End If
                     striprtf RTFTxt$
                    
                     posn% = InStr(RTFTxt$, "[data]")
                     endposn% = InStr(posn, RTFTxt$, "]")


                            temp$ = "{"
                     Put #filno, , temp$

                     
                     LstBoxFrm.Caption = "Transmitting order"
                     
                     printconfirmtop filno, ordernumb$, title$
                     
                     'setup RTF for next lot of data
                     temp$ = Mid$(RTFTxt$, 1, posn - 1)
                     Put #filno, , temp$
                     
                     'print the header
                     PrintCSDescriptor filno

                     linno = 0
                     'Get orders status =1 , supcode =UCase$(Trim$(ord.supcode)) OK '10Jan07 TH chnaged ord.supcode for supcode$
                      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                  gTransport.CreateInputParameterXML("Status", trnDataTypeint, 4, "1") & _
                                  gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, UCase$(Trim$(supcode$))) & _
                                  gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                                  gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                                  gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                                  gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                                  gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
                     Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParams)
                     If Not rsOrders Is Nothing Then
                        If rsOrders.State = adStateOpen Then
                           If rsOrders.RecordCount <> 0 Then
                              InternalOrderOutputTracking = 1 '22Jul10 TH set this - we do have something so we may need a file (F0077942)
                              Do While Not rsOrders.EOF
                                 '30Apr07 TH Added
                                 include = False
                                 If PartsOrder Then
                                    For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
'                                       '11Jun07 TH replaced below
'                                       'If Trim$(UCase$(GetField(rsOrders!Code))) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(i).text)) And OMarked(MainScreen.lvwMainScreen.ListItems(i).Selected) Then include = True
'                                       'If Trim$(UCase$(GetField(rsOrders!Code))) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).Text)) And OMarked(lngLoop) Then include = True                            '02Jun11 CKJ
                                       '//// still for review
                                       If Trim$(UCase$(GetField(rsOrders!Code))) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).text)) And MainLVWIsItemSelected(lngLoop) Then include = True    '    "
                                    Next
                                 End If
                                 '----------------
                                 If (Not PartsOrder) Or (PartsOrder And include) Then    '12Nov98 TH Filter out selected items from amend screen
                                    '---------------------work on order file--------------------
                                    iordered = True
                                    'ord = FillOrdFromRS(rsOrders, "WOrder")                 '10Jan07 TH
                                    getorder ord, RtrimGetField(rsOrders!WOrderID), 1, True  '    "
                                    'get description of drug from buyer's file
                                    d.SisCode = ord.Code
                                    getdrugsup d, 0, foundPtr&, False, ord.supcode       '         " '01Jun02 ALL/ATW
                                    getsupplier ord.supcode, 0, lngFound, sup
                                    '---------------get drug details from supplier--------------
                                    SetDispdata Val(sup.icode)        '6Jan95 CKJ
      
                                    d.SisCode = ord.Code
                                    getdrugsup d, 0, foundPtr&, False, ord.supcode
                                    
                                    If foundPtr& > 0 Then
                                       desc$ = d.DrugDescription        ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
                                       plingparse desc$, "!"
                                       desc$ = Left$(desc$ + Space$(56), 56)
                                       ord.num = ordernumb$
                                       If (Val(d.stocklvl) / Val(d.convfact)) - d.outstanding >= Val(ord.outstanding) Then
                                          receiptexpected$ = ord.outstanding
                                       Else
                                          receiptexpected$ = LTrim$(Str$(Int(dp!(Val(d.stocklvl) / Val(d.convfact)) - d.outstanding)))
                                          If Val(receiptexpected$) < 0 Then receiptexpected$ = "0"
                                       End If
                                       ord.received = ""
                                       ord.qtyordered = Trim$(ord.outstanding)
                                       ord.orddate = thedate(False, True)
                                       ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
                                       If Not UCase(ord.pflag) = "M" Then ord.cost = ""
                                       ord.internalsiteno = LTrim$(Str$(sitepaths))
                                       ord.internalmethod = "I"
                                       ord.status = "3" 'Now only if found on stores machine ASC 20Mar93
                                       drugordered = True
                                       SetDispdata 0
                                    Else
                                       'not found on their file
                                       drugordered = False
                                    End If
                                    lngFound = 0  '?? is this needed ASC
                                    '07Feb07 TH Removed - somehow this had got reinstated - it is WRONG and it meant trying to lock and save some drugs not on the other site !!
                                    'getdrug d, 0, lngFound, True                   '23Nov98 TH  Write last ordered date   '26May99 TH Removed because this site has
                                    'd.lastordered = Format$(date, "ddmmyyyy")   '23Nov98 TH  to drug file              '           Not ordered this drug
                                    'putdrug d ', found                            '23Nov98 TH
                                    '07Feb07 TH Removed
                                    
                                    ''dispdata$ = sitepth$(0)       '6Jan95 CKJ 11Jun96 EAC
                                    SetDispdata 0
                                    
                                    'ord.OrderID = 0 'Force insert this is a new order ?
                                    X& = PutOrder(ord, ord.OrderID, "WOrder") 'V93                            '<----UNLOCK  (no idx)
      
                                    '--------------print details on confirmation sheet--------------------
                                    linno = linno + 1
                                    If linno > 50 Then
                                       linno = 0
                                       temp$ = "[FF]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                       temp$ = "{"
                                       Put #filno, , temp$
                                       LstBoxFrm.Caption = "Transmitting order"
                                       printconfirmtop filno, ordernumb$, title$
                                       'setup RTF for next lot of data
                                       temp$ = Mid$(RTFTxt$, 1, posn - 1)
                                       Put #filno, , temp$
                                       'print the header
                                       PrintCSDescriptor filno
                                    End If
      
                                    If drugordered Then
                                       cost$ = Str$(dp!(Val(d.cost) / 100)) '23Jun93 CKJ dp
                                       poundsandpence cost$, True
                                       LstBoxFrm.LstBox.AddItem d.SisCode & Chr$(9) & Trim$(desc$) & Chr$(9) + Trim$(ord.qtyordered) & Chr$(9) & Trim$(receiptexpected$) & Chr$(9) + Trim$(cost$)
                                       temp$ = d.SisCode + " " + Left(desc$, 38) + "    " + rightjust6(ord.qtyordered) + "    " + rightjust6(receiptexpected$) + "     " + rightjust6(cost$) + "[cr]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                    Else
                                       popmessagecr "Cannot Raise this Order", d.SisCode & Chr$(9) + " Not found (item not raised)"
                                       temp$ = d.SisCode + "  " + desc$ + "  Not found (item not raised)" + "[cr]"
                                       PrinterParse temp$
                                       Put #filno, , temp$
                                    End If
   
                                    '----now send to requisition file on suppliers's machine----
                                    savededittype = Edittype
                                    Edittype = 5
                                    If drugordered Then
                                       getsupplier Trim$(ord.supcode), 0, lngFound, sup  '12Jun97 EAC use correct supplier code
                                       SetDispdata Val(sup.icode)
                                      
                                       ord.status = "5"
                                       ord.orddate = thedate(False, True)
                                       ord.ordtime = thedate(0, -2)  '11Oct05 TH Added

                                       ord.num = ordernumb$
                                       ord.supcode = LTrim$(ownname$)
                                       ord.internalsiteno = LTrim$(Str$(sitepaths))
                                       reqpoint& = PutOrder(ord, 0, "WRequis") 'Force Insert
   
                                       If sup.suppliertype = "W" Or sup.suppliertype = "L" Then
                                          orderqty! = Val(ord.outstanding) / Val(d.convfact)
                                       Else
                                          orderqty! = Val(ord.outstanding)
                                       End If
                                       updateoutstanding orderqty!, d
                           
                                       '------make transaction on orderlog for buyer's end----------
                                       SetDispdata 0
                                       ordernum$ = ord.num
                                       SisCode$ = ord.Code
                                       dateord$ = ord.orddate
                                       dateord$ = dateord$ & thedate(0, -2) '15Jan02 TH Added time to order date for log (#53214)
                                       daterec$ = ""
                                       qtyord$ = ord.outstanding
                                       'orderlog now done when issueing
                                       'Now "O" type order for ASCribe internal "I" type produced when stock issued in store
                                       LookupDrug ord.Code, d, (lngFound) '14Jan94 CKJ Added
   
                                       contract$ = ""    '24Feb94 CKJ Contract details
                                       If ord.supcode = d.supcode And Val(d.contprice) > 0 Then
                                          contract$ = Trim$(d.contno) ' 10 chars wide
                                          If contract$ = "" Then contract$ = "CONTRACT"
                                       End If
                                       
                                       '22Jul10 TH Added (UHB) (F0077942)
                                       If (InternalOrderOutputTracking = 1) Then  'If This is the first line then we will write a header record if required
                                          'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "I"
                                          If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "I", False  '03Mar14 TH Added Param
                                          InternalOrderOutputTracking = 2 '22Jul10 TH set this - flag to write footer and release the file
                                       End If
                                       '-------
                                       'Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, "", "", sup.Code, "I", sitepaths, contract$, d.vatrate, "", "", "" '14Jan94 CKJ VAT '17Feb92 ASC
                                       'Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, "", "", sup.Code, "I", sitepaths, contract$, d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                                       Orderlog ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, "", "", sup.Code, "I", sitepaths, contract$, d.vatrate, "", "", "", "", ord.PSORequestID   '03Mar14 TH Added PSORequestID
                                    
                                       getdrug d, 0, lngFound, True                                                           '03Jun08 TH Port from v8 - Update date last ordered - moved from below. (#89426)(F0015752)
                                       If foundPtr = 0 Then                                                                   '        "
                                          popmessagecr "!n!b", "Unable to find drug in drug file. Cannot save your changes."  '        "
                                       Else                                                                                   '        "
                                          d.lastordered = Format$(Now, "ddmmyyyy")                                            '        "
                                          putdrug d                                                                           '        "
                                       End If                                                                                 '        "

                                    End If
                                    Edittype = savededittype
                                 End If
                                 rsOrders.MoveNext
                              Loop
                           End If
                        End If
                     End If
                        
                     'terminate the RTF string for the data segment
                     temp$ = Mid$(RTFTxt$, endposn + 1, Len(RTFTxt$) - (endposn + 1))
                     Put #filno, , temp$
                     
                     Close filno
                     
                     '22Jul10 TH Added (UHB) (F0077942)
                     If (InternalOrderOutputTracking = 2) Then
                        'If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "I" '21Jul10 TH
                        If TrueFalse(TxtD(dispdata$ & "\genint.ini", "ordering", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "I", False   '03Mar14 TH Added Param
                        InternalOrderOutputTracking = 0
                     End If
                     '---------
                     
                     If iordered Then
                        'title$ = "Transmitting order"
                        title$ = "Summary of transmitted order" '12Sep12 TH Replaced above (TFS 43632)
                        LstBoxFrm.Caption = title$
                        LstBoxFrm.lblHead = "NSVCode" & Space$(3) & TB$ & "Description" & Space$(50) & "Quantity" & TB$ & "Expected Qty" & TB$ & "Cost" & Space$(10)
                        LstBoxShow
                        Unload LstBoxFrm
                        ans$ = ""
                        Confirm "", "Send report to printer Y/N", ans$, k
                        If ans$ = "Y" Then
                           WSspool FILE$, "Stock Control", 1, True, True, "PurchOrd"
                        Else
                           Kill FILE$
                        End If
                        k.escd = True
                        successful = True
                        getorderno 1, lngOrderno, -1
                        
                        '03Jun08 TH Moved block into loop
                        'getdrug d, 0, foundPtr&, True
                        'If foundPtr& = 0 Then '  = False Then
                        '   popmessagecr "!n!b", "Unable to find drug in drug file. Cannot save your changes."
                        'Else
                        '   d.lastordered = Format$(Now, "ddmmyyyy")
                        '   putdrug d '', foundPtr&
                        '   If foundPtr& = 0 Then ' = False Then
                        '      popmessagecr "!n!b", "Unable to save changes to drug file."
                        '   End If
                        'End If
                     Else
                        popmessagecr "!n!b", "No items ordered"
                        Kill FILE$
                        k.escd = True
                     End If
                        

                  Case "M", "E"   '>>>>via modem to another ASCribe site or by EDI '13Jul95
                     'GetOrderNo 1, orderno, True
                     'ordernumb$ = LTrim$(Str$(orderno))
                     Y = 0
                     'getnumofords edittype, pointer&, False
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                                 gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1") & _
                                 gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, supcode$)
                     'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWorderIDbyStatusandSupcode", strParams)
                     Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWorderIDandCodebyStatusandSupcode", strParams) '16May10 TH Replaced above (F0068698/F0058642)
                     If rsOrders.RecordCount > 0 Then
                        rsOrders.MoveFirst
                        Do While Not rsOrders.EOF
                           '16May10 TH Added (F0068698/F0058642)
                           include = False
                           
                           '13Jun12 TH For DLO we need to only use the DLO lines
                           If UCase$(Trim$(strDLO)) = UCase$(Trim$(RtrimGetField(rsOrders!DLOWard))) Then
                           
                              If PartsOrder Then
                                 For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count
                                    'If Trim$(GetField(rsOrders!Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).Text)) And OMarked(lngLoop) Then include = True                           '02Jun11 CKJ
                                    If Trim$(GetField(rsOrders!Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.ListItems(lngLoop).text)) And MainLVWIsItemSelected(lngLoop) Then include = True   '   "
                                    'If include Then
                                    '   '13Jun12 TH Further check for DLO
                                    '
                                    'End If
                                 Next
                              End If
                           'If UCase$(Trim$(strDLO)) <> UCase$(Trim$(RtrimGetField(rsOrders!DLOWard))) Then include = False
                              If (Not PartsOrder) Or (PartsOrder And include) Then
                              '16May10 TH (F0068698/F0058642)----------------
                                 getorder ord, RTrim(GetField(rsOrders!WOrderID)), Edittype, True  '<----LOCK   (no idx)
                                 If Y Mod GetMaxNoOfLinesForOrder(sup.Method) = 0 Then    ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
                                    If Y = 0 Then
                                       getorderno 1, lngOrderno, False
                                    Else
                                       getorderno 1, lngOrderno, True
                                    End If
                                    ordernumb$ = LTrim$(Str$(lngOrderno))
                                 End If
                                 ord.num = ordernumb$
                                 ord.status = "2"
                                 ord.internalmethod = sup.Method      '   "    E/M
                                 ord.orddate = thedate(False, True)
                                 ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
      
                                 If Not UCase(ord.pflag) = "M" Then ord.cost = "" '29Jan99 TH To allow zero priced orders for EDI (removed for present)  '05Aug02 TH Reinstated
                                 Select Case sup.Method
                                    Case "M"                          'CKJ inhibit for EDI
                                       LookupDrug ord.Code, d, (lngFound)
                                       'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", sup.Code, "O", sitepaths, "", d.vatrate, "", "", ""              '    "
                                       '14May12 TH Here
                                       'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", sup.Code, "O", sitepaths, "", d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                                       Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", ord.qtyordered, "", "", sup.Code, "O", sitepaths, "", d.vatrate, "", "", "", "", ord.PSORequestID   '03Mar14 TH Added PSORequestID
                                    Case "E"
                                       ord.invnum = UserID$           'hold for use in EDI module
                                       LookupDrug ord.Code, d, (lngFound)
                                       getdrugsup d, 0, lngFound, False, ord.supcode
                                       If TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "N", "EnableEDILinkCode", 0)) Then
                                          If Trim$(d.EDIBarcode) <> "" Then
                                             ord.EDIProductIdentifier = Trim$(d.EDIBarcode)
                                          ElseIf Trim$(d.EDILinkCode) <> "" Then
                                             ord.EDIProductIdentifier = Trim$(d.EDILinkCode)
                                          End If
                                       End If
                                       If Trim$(ord.EDIProductIdentifier) = "" Then
                                          Dim bcr$
                                          DummyEAN d.SisCode, bcr$
                                          If Trim$(d.barcode) = bcr$ Then              'dummy barcode used
                                            ord.EDIProductIdentifier = Trim$(ord.Code)            'AS STRING * 22
                                          Else                                      'assume genuine EAN
                                            ord.EDIProductIdentifier = Trim$(d.barcode)    'AS STRING * 22
                                          End If
                                       End If
                                 End Select
                                 d.SisCode = ord.Code
                                 getdrug d, 0, foundPtr&, True
                                 d.lastordered = Format$(Now, "ddmmyyyy")
                                 putdrug d
      
                                 X& = PutOrder(ord, ord.OrderID, "WOrder") 'V93                     '<----UNLOCK (no idx)
                                 Y = Y + 1
                              End If '16May10 TH
                           End If
                           rsOrders.MoveNext
                        Loop
                     End If
                     getorderno 1, lngOrderno, True   '01Sep08 TH (F23216) Update ordernumber before modal box - still not perfect but less likely to cause duplicate order numbers
                     popmessagecr "!n!b", Str$(Y) + " items added for next EDI/modem transmission "
                     'getorderno 1, lngOrderno, True
                     k.escd = True
                     successful = True

                  'Case "D", "F"  'direct by paper order
                                 'also Fax order - same procedure to build order - uses different rtf file
                  Case "D", "F", "H"  '29Jul14 TH Added Hub method too
                     
                     Select Case sup.Method
                        Case "D"
                           'Check for the PSO template here if available
                           RTFfile$ = "\orddata.rtf"
                           RTfFile2$ = "\ordextra.rtf"
                           If blnPSO Then
                              '07Jan17 TH replaced rtf checks
                              'If fileexists(dispdata$ & "\PSO_orddata.rtf") Then RTFfile$ = "\PSO_orddata.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_orddata.rtf", "", intSuccess
                              'If intSuccess Then RTFfile$ = "\PSO_orddata.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_orddata.rtf") Then RTFfile$ = "\PSO_orddata.rtf"  '26Jan17 TH Replaced above
                              
                              'If fileexists(dispdata$ & "\PSO_ordextra.rtf") Then RTfFile2$ = "\PSO_ordextra.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_ordextra.rtf", "", intSuccess
                              'If intSuccess Then RTfFile2$ = "\PSO_ordextra.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_ordextra.rtf") Then RTfFile2$ = "\PSO_ordextra.rtf"  '26Jan17 TH Replaced above
                           End If
                        Case "F"
                           'Check for the PSO template here if available
                           RTFfile$ = "\faxdata.rtf"
                           RTfFile2$ = "\faxextra.rtf"
                           If blnPSO Then
                              '07Jan17 TH replaced rtf checks
                              'If fileexists(dispdata$ & "\PSO_faxdata.rtf") Then RTFfile$ = "\PSO_faxdata.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_faxdata.rtf", "", intSuccess
                              'If intSuccess Then RTFfile$ = "\PSO_faxdata.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_faxdata.rtf") Then RTFfile$ = "\PSO_faxdata.rtf" '26Jan17 TH Replaced above
                              'If fileexists(dispdata$ & "\PSO_faxextra.rtf") Then RTfFile2$ = "\PSO_faxextra.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_faxextra.rtf", "", intSuccess
                              'If intSuccess Then RTfFile2$ = "\PSO_faxextra.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_faxextra.rtf") Then RTfFile2$ = "\PSO_faxextra.rtf"   '26Jan17 TH Replaced above
                           End If
                        Case "H"
                           'Check for the PSO template here if available
                           RTFfile$ = "\orddata.rtf"
                           RTfFile2$ = "\ordextra.rtf"
                           '07Jan17 TH replaced rtf checks
                           'If fileexists(dispdata$ & "\Hub_orddata.rtf") Then RTFfile$ = "\Hub_orddata.rtf"
                           'GetRTFTextFromDB dispdata$ & "\Hub_orddata.rtf", "", intSuccess
                           'If intSuccess Then RTFfile$ = "\Hub_orddata.rtf"
                           If RTFExistsInDatabase(dispdata$ & "\Hub_orddata.rtf") Then RTFfile$ = "\Hub_orddata.rtf" '26Jan17 TH Replaced above
                           'If fileexists(dispdata$ & "\Hub_ordextra.rtf") Then RTfFile2$ = "\Hub_ordextra.rtf"
                           'GetRTFTextFromDB dispdata$ & "\Hub_ordextra.rtf", "", intSuccess
                           'If intSuccess Then RTfFile2$ = "\Hub_ordextra.rtf"
                           If RTFExistsInDatabase(dispdata$ & "\Hub_ordextra.rtf") Then RTfFile2$ = "\Hub_ordextra.rtf"  '26Jan17 TH Replaced above
                           If blnPSO Then
                              '07Jan17 TH replaced rtf checks
                              'If fileexists(dispdata$ & "\PSO_orddata.rtf") Then RTFfile$ = "\PSO_orddata.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_orddata.rtf", "", intSuccess
                              'If intSuccess Then RTFfile$ = "\PSO_orddata.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_orddata.rtf") Then RTFfile$ = "\PSO_orddata.rtf"   '26Jan17 TH Replaced above
                              'If fileexists(dispdata$ & "\PSO_ordextra.rtf") Then RTfFile2$ = "\PSO_ordextra.rtf"
                              'GetRTFTextFromDB dispdata$ & "\PSO_ordextra.rtf", "", intSuccess
                              'If intSuccess Then RTfFile2$ = "\PSO_ordextra.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\PSO_ordextra.rtf") Then RTfFile2$ = "\PSO_ordextra.rtf"   '26Jan17 TH Replaced above
                              'If fileexists(dispdata$ & "\Hub_PSO_orddata.rtf") Then RTFfile$ = "\Hub_PSO_orddata.rtf"
                              'GetRTFTextFromDB dispdata$ & "\Hub_PSO_orddata.rtf", "", intSuccess
                              'If intSuccess Then RTFfile$ = "\Hub_PSO_orddata.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\Hub_PSO_orddata.rtf") Then RTFfile$ = "\Hub_PSO_orddata.rtf"   '26Jan17 TH Replaced above
                              'If fileexists(dispdata$ & "\Hub_PSO_ordextra.rtf") Then RTfFile2$ = "\Hub_PSO_ordextra.rtf"
                              'GetRTFTextFromDB dispdata$ & "\Hub_PSO_ordextra.rtf", "", intSuccess
                              'If intSuccess Then RTfFile2$ = "\Hub_PSO_ordextra.rtf"
                              If RTFExistsInDatabase(dispdata$ & "\Hub_PSO_ordextra.rtf") Then RTfFile2$ = "\Hub_PSO_ordextra.rtf"  '26Jan17 TH Replaced above
                              
                           End If
                           
                     End Select

                            If valid Then
                                '--- TFS 231441 - Destroy existing heap only if user commits to authorise a new order
                                '    This call was being made too early on method MainOptions
                                SetupPRNHeap True, 0
                                '---
                                PrintPaperOrder RTFfile$, RTfFile2$, supcode$, successful, strDLO, blnPSO
                           If Not successful Then k.escd = True
                            End If
                            Printorder 0, False
                  Case Else
                     AcquireLock filelock$, 0, valid
                     popmessagecr "!n!iSupplier " + supcode$, "Order method (eg direct, internal) missing from supplier file"
                     k.escd = True
               End Select
               AcquireLock filelock$, 0, valid
            Case Else
               nopass
         End Select
         
      Else
         If Not k.escd And lngFoundSup = 0 Then
                 popmessagecr "!n!bSupplier not found", "Supplier " + supcode$ + " not on file"
                 k.escd = True
             End If
      End If
   Loop

   If Not PartsOrder And successful Then
      shuffle = False
      supsinarray = supsinarray - 1
      For loopvar = 1 To supsinarray
         'If Trim$(Mid$(suppliers(loopvar), 1, Len(sup.Code))) = supcode$ Then shuffle = True
         If (Trim$(Mid$(suppliers(loopvar), 1, Len(sup.Code))) = supcode$ And UCase$(Trim$(Right$(suppliers(loopvar), 5))) = UCase$(Trim$(strDLO))) Then shuffle = True '11Jun12 TH Added DLO Check
         If shuffle Then suppliers(loopvar) = suppliers(loopvar + 1)
      Next
      ReDim Preserve suppliers(supsinarray)
      If supsinarray = 0 Then
         finished = True
         Unload LstBoxFrm
         Select Case Edittype
            Case 1: msg$ = "All orders authorised."
            Case 5: msg$ = "All picking tickets printed."
            Case 7: msg$ = "All Delivery Notes printed."
            Case 9: msg$ = "All Credit Orders authorised."
            End Select
         popmessagecr "Authorise Orders", msg$
      End If
   End If
     
   'SQL ForgetPrinterList
   ReDim wildcard$(0)

Exit Sub

'27Feb98 ASC
nostring:
   If Not warned Then popmessagecr "Very large order", "Order too big to print a full confirmation slip for - order will be raised normally"
   warned = True
Resume Next

End Sub

Sub SiteDrugEnquiry()
'30Sep99 AE  corected output to use the variable Stocklvl$ instead of d.stocklevel. ALso generally tidied
'            up output.
'26Mar01 TH  Reset Wslist.mdb to correct site
'14Jan02 TH  Stop error when resettinmg Ward Stock list mdb to Original site from stores - pragmatic solution (#57914,#57438)
'   "        because it is difficult to know what data objects association with the wslist are actually open at this time
'   "        Also more importantly the WSList is reopened for the correct site afterwards - I had made the above change stupidly
'   "        only from a dispensary perspective - Sorry. This should now ensure the wslist is correct after the site enquiry.
'11Jul11 TH  Removed clause on saveddrug$ which meant it defaulted to a given drug search on second pass (F0102540)
'18Jul11 TH  Add caption (F0123137)
'27Sep13 TH  Use the caption with a drug description if one is present (TFS 74334)
'09Jan14 TH  Allow stores only to be available on F4 too (TFS 80652)
'12Nov15 TH  Added Trim to ensure correct check on new description (TFS 132827)

Dim mnu$(), ans$, temp$, temp1$, savedrug$, drug$
Dim hlp%()
Dim numofsites%, count%, DrugPtr&, found%, exitloop%   '01Jun02 ALL/ATW
Dim founditem&, stocklvl$, pathfound%    '01Jun02 ALL/ATW
Dim TmpSitenumber As Long
Dim intFound As Integer '24Aug05 TH Added
Dim strDate As String '12Dec05 TH Added
Dim strStoresDescription As String
Dim outstanding As String
   
   numofsites = UBound(sitenos%)
   ReDim mnu$(numofsites)
   ReDim hlp%(numofsites)
   If InStr(1, Command$, "/de0", 1) Then              '24Aug05 TH Added
      EnterDrug ODrugInfo$, "Site Drug Enquiry"
      If Not k.escd Then
         'findrdrug ODrugInfo$, 0, d, 0, intFound, 0, False, False      '   "
         findrdrug ODrugInfo$, -1, d, 0, intFound, 0, False, False      '09Jan14 TH Allow stores only to be available on F4 too (TFS 80652)
         If intFound Then ODrugInfo$ = d.SisCode         '   "
         savedrug$ = ODrugInfo$
      Else
         Close
         storesEnd
      End If
   ElseIf InStr(1, Command$, "/de", 1) Then
      ODrugInfo$ = Mid$(Command$, InStr(Command$, "/de") + 3)
      If InStr(ODrugInfo$, "/") > 0 Then ODrugInfo$ = Trim$(Left$(ODrugInfo$, InStr(ODrugInfo$, "/") - 1))
      savedrug$ = ODrugInfo$
   End If
   
   If numofsites > 0 Then
      temp$ = dispdata$
      TmpSitenumber = SiteNumber
      For count = 1 To numofsites
         If ODrugInfo$ <> "" Then
            d.SisCode = ODrugInfo$
            LstBoxFrm.lblHead = "Site           " & TB & "Stock level" & TB & "Owed   " & TB & "Date last ordered"
'06Jul11 CKJ Not appropriate for SQL - forces disk structure to be set up just to enquire on other sites
'            CheckPath sitepth$(count), pathfound%
'            If pathfound Then
               ''dispdata$ = sitepth$(count)
               ''strSiteNo = Right$(sitepth$(count), Len(sitepth$(count)) - InStr(sitepth$(count), "."))
               ''SetDispdata Val(sitepth$(count)) 'SQL you reckon ?
               ''SetDispdata Val(strSiteNo)
               SetDispdata sitenos%(count)
               ''sitenumber = GetSiteIDFromDispdata(Val(Right$(dispdata$, Mid$(dispdata$, InStr(1, dispdata$, ".", vbBinaryCompare)) + 1)))
               'SQL TO DO - Nudge the SessionSite Table here
               getdrug d, 0, founditem, False
               If founditem Then
                  stocklvl$ = Iff(Trim$(d.stocklvl) = "", "0", d.stocklvl) '''& TB & TB
                  If strStoresDescription = "" Then
                     'strStoresDescription = d.storesdescription ' XN 9Jun15 98073 New local stores description
                     'strStoresDescription = Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription)
                     strStoresDescription = Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription) '12Nov15 TH Added Trim to ensure correct check (TFS 132827)
                     plingparse strStoresDescription, "!"
                     LstBoxFrm.Caption = strStoresDescription
                  End If
                  outstanding = CStr(d.outstanding)
               Else
                  stocklvl$ = "Item not stocked on this site"
                  outstanding = ""
               End If
               parsedate d.lastordered, strDate, 1, 0
               LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & Trim$(stocklvl$) & TB & outstanding & TB & strDate
'06Jul11 CKJ Not appropriate for SQL - see above
'            Else
'               LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & "Not connected to this workstation"
'            End If
         Else
            LstBoxFrm.LstBox.AddItem siteabb$(count)
            LstBoxFrm.lblHead = "Site"
         End If
      Next
      dispdata$ = temp$
      SiteNumber = TmpSitenumber
      SetDispdata 0
      
      'LstBoxFrm.Caption = "Site Enquiry" '18Jul11 TH (F0123137) add caption
      If Trim$(LstBoxFrm.Caption) = "" Then LstBoxFrm.Caption = "Site Enquiry" '27Sep13 TH Use the caption with a drug description if one is present (TFS 74334)
      
      LstBoxShow '22Feb07 TH Moved out of loop
      
      Do
         ans$ = Format$(LstBoxFrm.LstBox.ListIndex + 1)
                                                                                 
         If Val(ans$) = 0 Then
            ans$ = ""
            k.escd = True
            exitloop = True
         Else
            k.escd = False
            exitloop = False
            temp$ = dispdata$
            temp1$ = hospabbr$
            dispdata$ = sitepth$(Val(ans$))
            hospabbr$ = siteabb$(Val(ans$))
            '''sitenos% (Val(ans$))
            
            'Now set sitenumber
            ''TmpSitenumber = SiteNumber
                           
            SetDispdata sitenos%(Val(ans$)) '24Aug05 TH Added
            ''sitenumber = GetSiteIDFromDispdata(Val(Right$(dispdata$, Mid$(dispdata$, InStr(1, dispdata$, ".", vbBinaryCompare)) + 1)))
            'SQL TO DO - Nudge the SessionSite Table here
            If SiteNumber = 0 Then
               popmessagecr "EMIS Health", "Site not properly configured - cannot view information"
               k.escd = True
            End If
            drug$ = savedrug$ '24Aug05 TH Added
            ''If Not k.escd Then
            
            'If Not k.escd And (Trim$(savedrug$) = "") Then
            If Not k.escd Then    '11Jul11 TH Removed above clause (F0102540)
                k.Max = 14
                k.min = 2
                drug$ = savedrug$
                k.helpnum = 50
                InputWin hospabbr$, "Enter item code       ", drug$, k
            End If
            If Not k.escd Then
'06Jul11 CKJ Not appropriate for SQL - forces disk structure to be set up just to enquire on other sites
'               CheckPath dispdata$, pathfound%                                                                             '26Dec98
'               If pathfound Then                                                                                           '  "
                  findrdrug drug$, 1, d, DrugPtr, found, 2, False, False                                                              '  "
                  If found Then
                     savedrug$ = d.SisCode
                     ODrugInfo$ = d.SisCode
                     DisplayDrugEnquiry ODrugInfo$, sitenos(Val(ans$))  ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
'                     Load DrugInfo
'                     DrugInfo.Show 1
                     On Error GoTo 0
                  End If
'06Jul11 CKJ Not appropriate for SQL - see above
'               Else
'                  dispdata$ = temp$
'                  popmessagecr "Error on " & sitepth$(Val(ans$)), "This workstation is not connected to " & hospabbr$
'               End If
            End If
            dispdata$ = temp$
            hospabbr$ = temp1$
            SiteNumber = TmpSitenumber
         End If
         If Not exitloop Then LstBoxFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form     '22Feb07 TH Added
      Loop While Not exitloop
      Unload LstBoxFrm                                                                                            '     "
      k.escd = False
      SiteNumber = TmpSitenumber '10Jan07 TH RESET SITE !!!!
      SetDispdata 0              '  "
   End If
   
   If InStr(Command$, "/de") <> 0 Then    '26Dec98 ASC
      Close
      storesEnd
   End If


End Sub

Sub VerifySavedOrder(pointer&, editype%, ord As orderstruct)
'26Oct99 AE Written to verify an order which has just been written to disk and log
'           any differences.

Dim verord As orderstruct, Verr%, msg$

   getorder verord, pointer&, Edittype, False
   Verr = False
   
   If Trim$(ord.num) <> Trim$(verord.num) Then Verr = 1
   If Val(ord.cost) <> Val(verord.cost) Then Verr = 2
   If Trim$(ord.Code) <> Trim$(verord.Code) Then Verr = 3
   
   If Verr <> 0 Then
         'log the two orders
         msg$ = crlf$ & TB$ & TB$ & "As Authorised" & TB$ & "As Saved" & crlf$
         msg$ = msg$ & ".code:      " & TB$ & ord.Code & TB$ & TB$ & verord.Code & crlf$
         msg$ = msg$ & ".qtyordered " & TB$ & ord.qtyordered & TB$ & verord.qtyordered & crlf$
         msg$ = msg$ & ".received   " & TB$ & ord.received & TB$ & verord.received & crlf$
         msg$ = msg$ & ".outstanding" & TB$ & ord.outstanding & TB$ & verord.outstanding & crlf$
         msg$ = msg$ & ".orddate    " & TB$ & ord.orddate & TB$ & verord.orddate & crlf$
         msg$ = msg$ & ".recdate    " & TB$ & ord.recdate & TB$ & TB$ & verord.recdate & crlf$
         msg$ = msg$ & ".urgency    " & TB$ & ord.urgency & TB$ & TB$ & verord.urgency & crlf$
         msg$ = msg$ & ".loccode    " & TB$ & ord.loccode & TB$ & TB$ & verord.loccode & crlf$
         msg$ = msg$ & ".supcode    " & TB$ & ord.supcode & TB$ & TB$ & verord.supcode & crlf$
         msg$ = msg$ & ".status     " & TB$ & ord.status & TB$ & TB$ & verord.status & crlf$
         msg$ = msg$ & ".num        " & TB$ & ord.num & TB$ & TB$ & verord.num & crlf$
         msg$ = msg$ & ".cost       " & TB$ & ord.cost & TB$ & verord.cost & crlf$
         msg$ = msg$ & ".pickno     " & TB$ & ord.pickno & TB$ & TB$ & verord.pickno & crlf$
         msg$ = msg$ & ".tofollow   " & TB$ & ord.tofollow & TB$ & TB$ & verord.tofollow & crlf$
         msg$ = msg$ & ".invnum     " & TB$ & ord.invnum & TB$ & TB$ & verord.invnum & crlf$
         msg$ = msg$ & ".paydate    " & TB$ & ord.paydate & TB$ & TB$ & verord.paydate & crlf$
         msg$ = msg$ & ".internalsiteno" & TB$ & ord.internalsiteno & TB$ & verord.internalsiteno & crlf$
         msg$ = msg$ & ".internalmethod" & TB$ & ord.internalmethod & TB$ & verord.internalmethod & crlf$
   
         WriteLog dispdata$ & "\Vord.log", 2, UserID$, msg$

         'tell the user
         msg$ = "WARNING!  This order has not saved correctly." & cr$ & cr$
         msg$ = msg$ & "ORDER AS AUTHORISED:" & TB$ & "ORDER AS SAVED:" & cr$ & cr$
         msg$ = msg & "number: " & ord.num & TB$ & TB$ & verord.num & cr$
         msg$ = msg$ & "NSVcode: " & ord.Code & TB$ & verord.Code & cr$
         msg$ = msg$ & "Cost: " & ord.cost & TB$ & TB$ & verord.cost & cr$
         popmessagecr ".EMIS Health", msg$

      End If
         
         

End Sub

'02Jun11 CKJ Appears to be unused, but retain until full build confirms this
'Public Function FillRSFromOrd(ord As orderstruct) As ADODB.Recordset
'
'Dim rsOrder As ADODB.Recordset
''Set rsOrder = New ADODB.Recordset
'
'Set rsOrder = BuildAdoOrderRecordset()
'  '      Source:=SQLQuery, _
'  '      ActiveConnection:=oConn, _
'  '      CursorType:=adOpenStatic, _
'  '      LockType:=adLockBatchOptimistic
'rsOrder.AddNew
'   With rsOrder
'      .Fields("code") = ord.Code
'      .Fields("CodingSlipdate") = ord.CodingSlipdate
'      .Fields("convfact") = ord.convfact
'      .Fields("cost") = ord.cost
'      .Fields("CreatedUser") = ord.CreatedUser
'      .Fields("custordno") = ord.custordno
'      .Fields("description") = ord.Description
'      .Fields("Indispute") = ord.Indispute
'      .Fields("IndisputeUser") = ord.IndisputeUser
'      .Fields("internalmethod") = ord.internalmethod
'      .Fields("internalsiteno") = ord.internalsiteno
'      .Fields("invnum") = ord.invnum
'      .Fields("IssueUnits") = ord.IssueUnits
'      .Fields("loccode") = ord.loccode
'      .Fields("num") = Int(ord.num) 'Added INT
'      .Fields("numprefix") = ord.numprefix
'      .Fields("orddate") = ord.orddate
'      .Fields("ordtime") = ord.ordtime
'      .Fields("outstanding") = ord.outstanding
'      .Fields("paydate") = ord.paydate
'      .Fields("pflag") = ord.pflag
'      .Fields("pickno") = ord.pickno
'      .Fields("qtyordered") = ord.qtyordered
'      .Fields("recdate") = ord.recdate
'      .Fields("received") = ord.received
'      .Fields("Reconciledate") = ord.Reconciledate
'      .Fields("rectime") = ord.rectime
'      .Fields("revisionlevel") = ord.revisionlevel
'      .Fields("ShelfPrinted") = ord.ShelfPrinted
'      .Fields("Status") = ord.status
'      .Fields("Stocked") = ord.Stocked
'      .Fields("supcode") = ord.supcode
'      .Fields("suppliertype") = ord.suppliertype
'      .Fields("tofollow") = ord.tofollow
'      .Fields("urgency") = ord.urgency
'      .Fields("VATAmount") = ord.VATAmount
'      .Fields("VATInclusive") = ord.VATInclusive
'      .Fields("VATRateCode") = ord.VATRateCode
'      .Fields("VATRatePCT") = ord.VATRatePCT
'   End With
'Set FillRSFromOrd = rsOrder
'
'End Function
'
'Function BuildAdoOrderRecordset() As ADODB.Recordset
'
'Const cstrProcName = ".BuildAdoOrderRecordset"
'
''Dim uError As tErrorState
'Dim adoRs As ADODB.Recordset
''Dim intLoop As Integer
'
'   'On Error GoTo BAPRErr
'
'   Set adoRs = New ADODB.Recordset
'
'   With adoRs.Fields
'      .Append "code", adVarChar, 7
'      .Append "convfact", adVarChar, 5
'      .Append "cost", adVarChar, 13              ' Current caseno
'      .Append "CreatedUser", adVarChar, 3           ' Previous caseno, after a merge
'      .Append "custordno", adVarChar, 12            ' trimmed & left justified
'      .Append "description", adVarChar, 56            ' trimmed & left justified
'      .Append "Indispute", adVarChar, 1                 ' as  ddmmyyyy  only
'      .Append "IndisputeUser", adVarChar, 3                  ' M F or space
'      .Append "internalmethod", adVarChar, 1                ' UCase only
'      .Append "internalsiteno", adVarChar, 3                 ' UCase only
'      .Append "invnum", adVarChar, 12              ' kkk.gg
'      .Append "IssueUnits", adVarChar, 5              ' ff.ii
'      .Append "loccode", adVarChar, 3               ' I/O/D/L
'
'      .Append "num", adVarChar, 4  ' equivalent to rf() 'changed from ptr ASC 1Aug93"
'      .Append "numprefix", adVarChar, 6            ' added for coventry etc
'      .Append "orddate", adVarChar, 8                  ' UCase only
'      .Append "ordtime", adVarChar, 6
'
'      .Append "outstanding", adVarChar, 13
'      .Append "paydate", adVarChar, 8
'      .Append "pflag", adVarChar, 1
'      .Append "pickno", adVarChar, 2
'      .Append "qtyordered", adVarChar, 13
'      .Append "recdate", adVarChar, 8
'      .Append "received", adVarChar, 13
'      .Append "rectime", adVarChar, 6
'      .Append "revisionlevel", adVarChar, 4
'      .Append "ShelfPrinted", adVarChar, 1
'      .Append "Status", adVarChar, 1
'      .Append "Stocked", adVarChar, 1
'      .Append "supcode", adVarChar, 5
'      .Append "suppliertype", adVarChar, 1
'      .Append "tofollow", adVarChar, 1
'      .Append "urgency", adVarChar, 1
'      .Append "VATAmount", adVarChar, 13
'      .Append "VATInclusive", adVarChar, 13
'      .Append "VATRateCode", adVarChar, 1          'adLongVarWChar, 255                    'memo field
'      .Append "VATRatePCT", adVarChar, 13
'   End With
'
'   adoRs.CursorLocation = adUseClient
'   adoRs.CursorType = adOpenStatic
'   adoRs.LockType = adLockBatchOptimistic
'   adoRs.Open
'
'Cleanup:
'
'   On Error Resume Next
'   Set BuildAdoOrderRecordset = adoRs
'
'   Set adoRs = Nothing
'
'   On Error GoTo 0
''   ProcessError uError, cstrProcName
'
'Exit Function
'
''BAPRErr:
''
''   CaptureErrorState uError
''   Set adoRs = Nothing
'   Resume Cleanup
'End Function

Sub AddLineToDisplay(edtype%, orderpointer&, maxitems%, ScreenPosn&, ByVal strPTN As String, ByVal blnPSO As Boolean)
'29Dec97 EAC Use Stores drug description
'16Jan98 EAC Added PrintInPacks
'17Nov98 TH  Code to put supname onto lvwMainScreen.tag for use on amend orders /returns screen
'26Jan99 TH  Replaced Tag with global to avoid referencing problems
'28Jan99 TH  display Manual entered price flag/ free drug flag on amend/receive screens
'10Feb99 TH  Display proper pack size for credit notes
'19Feb99 TH  Now Picks up instorespacks% for both credits and reconciliations
'23Feb99 TH  Changed Pricing column(8) to show free,contract and non-stock pricing as well as manual price entry
'04Mar99 TH  Removed Credit flag
'30Jun99 CFY Added call to getdrugsup
'03Dec99 TH  Reinstated getsupplier for tradename toggle
'22Nov00 EAC/CY Allow reconciliation items to be marked as indispute
'13May04 CKJ Option to show price on screen at reconciliation: winord.ini [defaults] ShowPriceOnInvoiceScreen="Y" default = "N"
'17sep10 TH Added param to allow for trade name switch (F0096592)

'SQL Removed orderstruct

'19Mar10 TH  Now this should by default only act as a wrapper to AddlinetoDisplaySQL (F0081160)
'27Jun11 CKJ AlternativeDBLayer option deprecated. Now only uses the SQL version, equivalent to AlternativeDBLayer="Y". Deleted old code
'            Note that efficiency of remaining code below could be better - it uses 'slimline' SPs in 'top 1 starting from here' mode,
'            instead of pulling specific single row. Would be worth revisiting as it is used fairly often.

Dim intTop As Integer               '19Mar10 TH Added
Dim strParams As String             '   "
Dim rsOrders As ADODB.Recordset     '   "

   intTop = 1
   'Get the record set here, iterate through it and do what needs to be done supcode
   orderpointer& = orderpointer& - 1 '(Used to set start ID correctly)
   Select Case Edittype
      Case 1, 2, 3, 9, -3
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, "") & _
                     gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, orderpointer&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 1)
         If (Edittype = 1 Or Edittype = 3) And getPSO() Then '30Aug12 TH added to allow for PSO Refresh
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteriaSlimLinePSO", strParams)
         Else
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteriaSlimLine", strParams)
         End If
      Case -4, 4
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                     gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, "") & _
                     gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, "") & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, orderpointer&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 1)
         If Edittype = 4 Then
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaINVOICESlimline", strParams)
         Else
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaCREDITSlimLine", strParams)
         End If
      
      Case Else
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                     gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                     gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 7, "") & _
                     gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, "") & _
                     gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, orderpointer&) & _
                     gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 1)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteriaSlimline", strParams)
      End Select
   
   If Not rsOrders.EOF Then
      rsOrders.MoveFirst
      AddLineToDisplaySQL edtype%, rsOrders, maxitems%, ScreenPosn&, strPTN, blnPSO '17Sep10 TH  Added param (F0096592)
   End If

End Sub

Sub AddLineToDisplaySQL(edtype%, ByVal rsLine As ADODB.Recordset, maxitems%, ScreenPosn&, ByVal strPTN As String, ByVal blnPSO As Boolean)
'07Jan10 CKJ Added robot status as column 9 (F0030035)
'17sep10 TH Added param to allow for trade name switch (F0096592)
'14Aug12 TH Added PSO Flag Parameter /Added support for New PSO Grids(TFS 41372). Include edittype 4 Invoicing (TFS 50285)
'08Mar13 TH Name changes for PSO (TFS 56646,58429)
'21Mar13 TH Mod to initialise long forenames (TFS 59487)
'22Mar13 TH Handle unrecorded DOB for PSO (TFS 59559)
'13Aug15 TH Added preceeding "0" to decimal (TFS 126282)

'//// -4 doesn't seem to be handled as fully as 4

Dim urgent%, loopvar%  ', escd%
Dim desc$, urgency$, LineCost$, msg$, ans$
'Dim sup As supplierstruct    '06Jul11 CKJ Removed - reads supplier from DB but then never used
Dim InStoresPacks As Integer '05Mar98 ASC/EAC   01Jun11 CKJ Added as integer
Dim temp$    '17Nov98 TH
'Dim lngFoundSup As Long
Dim lngID As Long
Dim MechDispSection As String
Dim StrBatch As String  '31May09 TH (F0041582)
Dim strForename As String
Dim blnUcase As Boolean
Dim strFName As String
Dim intloop As Integer
Dim strInitials As String  '21Mar13 TH (TFS 59487)
Dim intPosn As Integer     '21Mar13 TH (TFS 59487)
Dim strDOB As String
Dim valid As Integer
         

   ReDim TempArray(OTblMaxCols + 1) As String
   
   StrBatch = ""   '31May09 TH (F0041582)
   
   If ScreenPosn = -1 Then
      maxitems = False
      ONumToDisplay = ONumToDisplay + 1
      '21Aug06 TH Removed (DR-06-0620)
''      If ONumToDisplay > OMaxArraySize Then
''         ONumToDisplay = OMaxArraySize
''         maxitems = True
''         msg$ = "There are greater than " & Format$(OMaxArraySize) & " items to displayed." & cr$ & cr$
''         msg$ = msg$ & "The program can not display any more items. Please refine your search." & cr$
''         popmsg "WARNING!", msg$, 48, ans$, escd%
''         Exit Sub
''      End If
      ReDim Preserve OInfoStore(1 To ONumToDisplay)
      '02Jun11 CKJ: ReDim Preserve OMarked(1 To ONumToDisplay)
      ScreenPosn& = ONumToDisplay
   End If
   
   Select Case edtype%
      Case 1, 2, 3, 9, -3: lngID = rsLine.fields("WOrderID")
      Case 4, -4:          lngID = rsLine.fields("WReconcilID")
      Case Else:           lngID = rsLine.fields("WRequisID")     '': blnRequis = True
      End Select
   
   TempArray(OTblMaxCols + 1) = Str$(lngID) 'store pointer to order

   If Edittype = 3 Then
      temp$ = Trim$(RtrimGetField(rsLine!supcode))
      If Trim$(RtrimGetField(rsLine!name)) <> "" Then temp$ = temp$ & "(" & Trim$(RtrimGetField(rsLine!name)) & ")"
      scrnmsg = temp$
   End If

   'If Trim$(RtrimGetField(rsLine!storesdescription)) = "" Then XN 4Jun15 98073 New local stores description
      desc$ = RtrimGetField(rsLine!Description)
   'Else
      'desc$ = RtrimGetField(rsLine!storesdescription)
   'End If
   plingparse desc$, "!"

   Select Case edtype
      Case 1, 4, 5, 6, 9
         TempArray(1) = RtrimGetField(rsLine!Code)
      Case 3
         If strPTN = "Y" And RtrimGetField(rsLine!tradename) <> "" And OPrintTradeNames Then '17Sep10 TH Added (F0056592)
            TempArray(1) = RtrimGetField(rsLine!tradename)
         Else
            TempArray(1) = Trim$(desc$)
         End If
      End Select
   
   If Len(Trim$(RtrimGetField(rsLine!urgency))) Then
      urgency$ = RtrimGetField(rsLine!urgency)
      urgent = True
   Else
      urgency$ = " "
      urgent = False
   End If
   
   '31May09 TH Added (F0041582)
   StrBatch = ""
   If Val(Trim$(RtrimGetField(rsLine!batchtracking))) > 1 And (edtype = 3 Or edtype = 6) Then
      If edtype <> 6 Then
         StrBatch = RtrimGetField(rsLine!batchtracking)
      ElseIf Val(Trim$(RtrimGetField(rsLine!batchtracking))) = 4 Then
         StrBatch = RtrimGetField(rsLine!batchtracking)
      End If
   End If
   
   If Len(Trim$(urgency$)) <> 0 And Len(Trim$(StrBatch)) <> 0 Then
      urgency$ = urgency$ & "/" & Trim$(StrBatch)
   ElseIf Len(Trim$(StrBatch)) <> 0 Then
      urgency$ = Trim$(StrBatch)
   End If
   '------
   
   Select Case edtype
      Case 1, 3, 4, 5, 6, 9
         TempArray(2) = urgency$
      End Select
   
   Select Case edtype
      Case 1, 4, 9, 10
         If strPTN = "Y" And RtrimGetField(rsLine!tradename) <> "" And OPrintTradeNames Then '17Sep10 TH Added (F0056592)
            TempArray(3) = RtrimGetField(rsLine!tradename)
         Else
            TempArray(3) = Trim$(desc$)
         End If
      Case 5, 6
         TempArray(3) = Trim$(desc$)
      Case 3
         TempArray(3) = RtrimGetField(rsLine!received)
      End Select
   
   Select Case edtype
      Case 1, 5, 6, 9
         TempArray(4) = RtrimGetField(rsLine!outstanding)
         d.convfact = rsLine!convfact  '06Apr06
         CheckIfWholeStoresPacks (dp!(Val(RtrimGetField(rsLine!outstanding)))), InStoresPacks, TempArray(4)
      Case 3
         LineCost$ = Str$(dp!(Val(RtrimGetField(rsLine!cost)) / 100 * Val(RtrimGetField(rsLine!received))))
         '04Mar10 TH Added to try and get a sensible order cost for EDI items (F0043282)
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "ShowPriceOnReceiptScreenEDI", 0)) And Val(LineCost$) = 0 Then
            'Assume if no cost this is mediate so switch to use outstanding to try and derive order cost
            LineCost$ = Str$(dp!(Val(RtrimGetField(rsLine!cost)) / 100 * (Val(RtrimGetField(rsLine!received)) + Val(RtrimGetField(rsLine!outstanding)))))
         End If
         poundsandpence LineCost$, True
         'TempArray(4) = Trim$(LineCost$)                   '06Jul11 CKJ changed to show 0.00  '//// needs testing
         TempArray(4) = Format$(LineCost$, "0.00")          '   "

      Case 4
         d.convfact = rsLine!convfact  '06Apr06
         CheckIfWholeStoresPacks (dp!(Val(RtrimGetField(rsLine!outstanding)))), InStoresPacks, TempArray(4)
         TempArray(4) = Trim$(RtrimGetField(rsLine!received)) '24Jan06 TH Added
      End Select
   
   Select Case edtype
      Case 1, 4, 5, 6, 9
'         If UCase$(osite$) = "A" Then                                              '06Jul11 CKJ Removed block - reads supplier from DB but then never used
'            getsupplier Trim$(RtrimGetField(rsLine!supcode)), 0, lngFoundSup, sup
'         Else
'            getsupplier osite$, 0, lngFoundSup, sup
'         End If
         If Not InStoresPacks Or (UCase$(RtrimGetField(rsLine!suppliertype)) = "W" Or UCase$(RtrimGetField(rsLine!suppliertype)) = "L") And Not (PrintInPacks) Then    '16Jan98 EAC Added PrintInPacks
            TempArray(5) = RtrimGetField(rsLine!PrintformV)
         Else
            TempArray(5) = Format$(RtrimGetField(rsLine!convfact)) & " " & Trim$(RtrimGetField(rsLine!PrintformV))
         End If
      Case 3
         If Val(RtrimGetField(rsLine!outstanding)) > 0 Then   '19May06 TH replaced above line
            TempArray(5) = RtrimGetField(rsLine!outstanding)
         Else
            TempArray(5) = RtrimGetField(rsLine!received)
         End If
         If Left$(TempArray(5), 1) = "." Then TempArray(5) = "0" & TempArray(5) '13Aug15 TH Added (TFS 126282)
      End Select
      
   Select Case edtype
      Case 1, 3, 4, 5, 9
         TempArray(6) = RtrimGetField(rsLine!supcode)
      Case 6
         TempArray(6) = RtrimGetField(rsLine!supcode)
      End Select
  
   If Not (blnPSO And edtype = 1) Then
    
      Select Case edtype
         Case 1, 4, 5, 9
            If edtype = 4 And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "ShowPriceOnInvoiceScreen", 0)) Then    '13May04 CKJ Added
               LineCost$ = Str$(dp!(Val(RtrimGetField(rsLine!cost)) / 100 * Val(RtrimGetField(rsLine!received))))                                                 '   "
               poundsandpence LineCost$, True                                                                                 '   "
               'TempArray(7) = Trim$(LineCost$)                   '06Jul11 CKJ changed to show 0.00  '//// needs testing
               TempArray(7) = Format$(LineCost$, "0.00")
            Else
               
               TempArray(7) = RtrimGetField(rsLine!ordercycle)                                                                             '   "
            End If                                                                                                            '   "
         Case 3, 6
            TempArray(7) = ""
      End Select

      Select Case edtype                                                         '28Jan99 TH display Manual entered price flag/ free drug flag'27Jan99 Th
         Case 1, 3                                                               '   "
            If Trim$(UCase$(RtrimGetField(rsLine!pflag))) = "M" And Val(RtrimGetField(rsLine!cost)) = 0 Then         '23Feb99 TH Changed to show free,contract and non-stock pricing as well as manual price entry                     '   "
               TempArray(8) = "F"                                             '   "
            ElseIf Trim$(UCase$(RtrimGetField(rsLine!pflag))) = "M" Then                          '   "
               TempArray(8) = "M"                                          '   "
            ElseIf Val(RtrimGetField(rsLine!contprice)) <> 0 Then                                                         '   "
               TempArray(8) = "C"                                        '   "
            ElseIf Trim$(UCase$(RtrimGetField(rsLine!sisstock))) = "N" Then
               TempArray(8) = "N"
            End If
                                                                         '   "
         Case 5, 6, 9                                                         '   "
            TempArray(8) = ""                                                    '   "
         Case 4                                                            '22Nov00 EAC/CY Added
            temp$ = RtrimGetField(rsLine!Indispute)                                          '   "
            If temp$ = "P" Then temp$ = "Y"                                ' once a dispute note has been printed indispute set to P for printed
            TempArray(8) = temp$                                           '   "
      End Select
      
   Else
      If Trim$(UCase$(RtrimGetField(rsLine!pflag))) = "M" And Val(RtrimGetField(rsLine!cost)) = 0 Then         '23Feb99 TH Changed to show free,contract and non-stock pricing as well as manual price entry                     '   "
         TempArray(7) = "F"                                             '   "
      ElseIf Trim$(UCase$(RtrimGetField(rsLine!pflag))) = "M" Then                          '   "
         TempArray(7) = "M"                                          '   "
      ElseIf Val(RtrimGetField(rsLine!contprice)) <> 0 Then                                                         '   "
         TempArray(7) = "C"                                        '   "
      ElseIf Trim$(UCase$(RtrimGetField(rsLine!sisstock))) = "N" Then
         TempArray(7) = "N"
      End If
   End If
   
   
   '---
   If edtype = 1 And blnPSO Then  '14Aug12 TH Added support for New PSO Grids(TFS 41372)
      '08Mar13 TH Name changes for PSO (TFS 56646,58429)
      strForename = RtrimGetField(rsLine!forename)
      '21Mar13 TH Added to initialise long forenames (TFS 59487)
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
      '14Aug12 TH PSO
      TempArray(8) = " "
      'TempArray(8) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & Trim$(LCase$(RtrimGetField(rsLine!forename))) & " (" & Format$(RtrimGetField(rsLine!dob), "dd mmm yyyy") & ")"
      'TempArray(8) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & strFName & " (" & Format$(RtrimGetField(rsLine!dob), "dd mmm yyyy") & ")"
      
      '22Mar13 TH (TFS 59559) Handle unrecorded DOB
      strDOB = ""
      parsedate RtrimGetField(rsLine!dob), strDOB, "1", valid '26Mar13 TH Changed format from 3 to 1
      If Not valid Then strDOB = ""
      If strDOB <> "" Then strDOB = "(" & strDOB & ")"
      '-----
      
      'TempArray(8) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & strFName & " (" & Format$(RtrimGetField(rsLine!dob), "dd/mm/yyyy") & ")" '21Mar13 TH Changed format (TFS 59488)
      TempArray(8) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & strFName & " " & strDOB  '22Mar13 TH (TFS 59559) Handle unrecorded DOB
      
      TempArray(9) = " "
      TempArray(9) = Trim$(UCase$(RtrimGetField(rsLine!Casenumber)))
      
      TempArray(10) = " "
      TempArray(10) = Trim$(UCase$(RtrimGetField(rsLine!HealthCareNumber)))
      
   Else '14Aug12 TH Added support for New PSO Grids(TFS 41372) End
   
      '07Jan10 CKJ added block
      TempArray(9) = " "
      MechDispSection = SectionIDForMechDisp(RtrimGetField(rsLine!loccode))
      If Len(MechDispSection) Then
         TempArray(9) = TxtD(dispdata$ & "\mechdisp.ini", MechDispSection, TempArray(9), "FindItemScreenChar", 0)
      End If
      
      If (edtype = 3 Or edtype = 4) And blnPSO Then '14Aug12 TH Added support for New PSO Grids(TFS 41372). Include edittype 4 Invoicing (TFS 50285)
         strForename = RtrimGetField(rsLine!forename)
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
         
         '26Mar13 TH (TFS 59559) Handle unrecorded DOB. Missed this section last time
         strDOB = ""
         parsedate RtrimGetField(rsLine!dob), strDOB, "1", valid '26Mar13 TH Changed format from 3 to 1
         If Not valid Then strDOB = ""
         If strDOB <> "" Then strDOB = "(" & strDOB & ")"
         '-----
      
      
         TempArray(10) = " "
         'TempArray(10) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & Trim$(LCase$(RtrimGetField(rsLine!forename))) & " (" & Format$(RtrimGetField(rsLine!dob), "dd mmm yyyy") & ")"
         'TempArray(10) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & strFName & " (" & Format$(RtrimGetField(rsLine!dob), "dd mmm yyyy") & ")"
         TempArray(10) = Trim$(UCase$(RtrimGetField(rsLine!surname))) & ", " & strFName & " " & strDOB
         
         TempArray(11) = " "
         TempArray(11) = Trim$(UCase$(RtrimGetField(rsLine!Casenumber)))
         
         TempArray(12) = " "
         TempArray(12) = Trim$(UCase$(RtrimGetField(rsLine!HealthCareNumber)))
      Else '14Aug12 TH Added support for New PSO Grids(TFS 41372) End
      
      '11Jun12 TH DLO
      TempArray(10) = " "
      If edtype = 1 Then
         TempArray(10) = Trim$(UCase$(RtrimGetField(rsLine!DLOWard)))
      End If
      '---
      TempArray(11) = " "
      TempArray(12) = " "
      End If
   End If
   
      
   OInfoStore(ScreenPosn&) = TempArray(1)
   For loopvar = 2 To OTblMaxCols + 1
      OInfoStore(ScreenPosn&) = OInfoStore(ScreenPosn&) + "|" + TempArray(loopvar) '//// caution if we change the array composition
   Next

End Sub

Sub BatchOrderlogOutputHeader(ByVal strSupCode As String, ByVal lngOrderno As Long, ByVal strKind As String, ByVal blnPSO As Boolean)
'21Jul10 TH Written (F0077944)
'07Sep10 TH Added formated "DD/MM/YYYY" date for UMMC (FINV)(F0054531)
'03Mar14 TH Added PSO Flag
'26Jan17 TH  Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)

Dim strRTFFile As String
Dim strFilename As String
Dim strPointerFilename As String
Dim strFilePrefix As String
Dim strOutfile As String
Dim lngPointer As Long
Dim lclsup As supplierstruct
Dim intFound As Long
Dim strMsg As String
Dim strMethodTypes As String '18Mar09 TH
Dim strFilesuffix As String
Dim strDatexml As String
Dim strSep As String        '07Sep10 TH Added (F0054531)
Dim strDateSep As String    '   "
Dim strPSOPrefix As String
Dim strOrderMessage  As String '31Mar14 TH Added(eHub)
Dim intSuccess As Integer   '07Jan17 TH Added

   On Error GoTo BatchOrderlogOutputHeader_Err
   If blnPSO Then
      strPSOPrefix = "PSO"
      'Setting here to allow PSO to go thrugh standard generic set up
      If TrueFalse(TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLineTransferPrint", 0)) Then set_str_eHubPatientBlock ""
   End If

   'Check the type of order record is correct.
   If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "D", strPSOPrefix & "OrderKinds", 0), strKind) > 0 Then

         'Get the supplier Code
         getsupplier (strSupCode), 0, intFound, lclsup
                                                                
         'Check that the supplier type is speicified in the ini file
         If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "E", strPSOPrefix & "SupplierTypes", 0), lclsup.suppliertype) > 0 Then
               
               'Check that the supplier method type is speicified in the ini file
               strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMTH", strPSOPrefix & "MethodTypes", 0)
               strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strMethodTypes, "MethodTypes" & strKind, 0) '18Mar09 TH Added to allow filtering by kind and method (UHB)
               'If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMT", "MethodTypes", 0), lclsup.Method) > 0 Then
               If InStr(UCase$(strMethodTypes), UCase$(lclsup.Method)) > 0 Then
               
                     
                     
                     'Output the file
                     'Here we want to get the batch header file
                     strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "UHBOrdHeader.rtf", strPSOPrefix & "BatchHeaderRTFFile", 0)
                     strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, "BatchHeaderRTFFile" & strKind, 0) '03Mar09 TH Added
                     If strRTFFile <> "" Then
                        strRTFFile = dispdata & "\" & strRTFFile
                        'If fileexists(strRTFFile) Then
                        '07Jan17 TH Replaced file check
                        'GetRTFTextFromDB strRTFFile, "", intSuccess
                        'If intSuccess Then
                        If RTFExistsInDatabase(strRTFFile) Then '26Jan17 TH Replaced above
                           'MakeLocalFile strFilename 'TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "", "ExportFilePath", 0)
                           'Now we must store the local file name so we can append the detail lines
                           'setBatchOrderOutputFileName strFilename
                           'Put the supplier information on the heap
                           FillHeapSupplierInfo gPRNheapID, lclsup, 0
                           strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", dispdata$ & "\OrderInt.dat", strPSOPrefix & "InterfacePointerFile", 0)
                           GetPointerSQL strPointerFilename, lngPointer, True
                           Heap 10, gPRNheapID, "OutputRefNoPad", Format$(lngPointer), 0
                           Heap 10, gPRNheapID, "olOrderNum", Format$(lngOrderno), 0
                           strDatexml = Format$(Now, "YYYY") & "-" & Format$(Now, "MM") & "-" & Format$(Now, "DD") '25Mar0-9 TH Has been swapped in v9 +
                           Heap 10, gPRNheapID, "olDatexml", strDatexml, 0
                           '07Sep10 TH Added block for UMMC /FINV (F0054531)
                           strSep = TxtD(dispdata$ & "\winord.ini", "defaults", "/", "HeapDateSeperator", 0)
                           strDateSep = Format$(Now, "DD") & strSep & Format$(Now, "MM") & strSep & Format$(Now, "YYYY")
                           Heap 10, gPRNheapID, "olDateordSep", strDateSep, 0
                           '-------
                           '31Mar14 TH Added (eHub)
                           strOrderMessage = getspecialmsg()
                           Heap 10, gPRNheapID, "OrderMessage", strOrderMessage, 0
                           EscapeXML strOrderMessage
                           Heap 10, gPRNheapID, "OrderMessageXML", strOrderMessage, 0
                           '-------
                           'If strFilename <> "" Then
                              'If DirExists(strFilename) Then
                                 'Parse the file
                                 'parseRTF strRTFFile, strOutfile
                                 parseRTFfromDB strRTFFile, strOutfile '04Jan17 TH Now use rtf in DB (Hosted)

                                 setBatchOrderOutputFileName strOutfile
                              'Else
                              '   popmessagecr "", "Generic Interface Incorrectly configured - Export File Path Not Found"
                              'End If
                           'Else
                           '   popmessagecr "", "Generic Interface Error - Local File could not be created"
                           'End If
                        Else
                           'popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Header File Not Found"    '09Apr09 TH Added after CKJ review
                           popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Header RTF not found in database"
                        End If
                     Else
                        popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Header File not specified"   '09Apr09 TH Added after CKJ review
                     End If
                  End If
            End If
      End If
BatchOrderlogOutputHeader_Exit:
   Exit Sub

BatchOrderlogOutputHeader_Err:
   strMsg = "An error has occurred in procedure : BatchOrderlogOutputHeader" & crlf & crlf '09Apr09 TH Altered after CKJ review
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\OrderOutput.log", SiteNumber, UserID$, strMsg
   Resume BatchOrderlogOutputHeader_Exit

End Sub



Sub BatchOrderlogOutputfooter(ByVal strKind As String, ByVal blnPSO As Boolean)
'21Jul10 TH Written (F0077944)
'07Sep10 TH Added section to ensure special filename for UMMC (FINV) (F0054531)
'04Oct10 TH Added formating on UMMC numeric suffix (now it just carries on and we take the right 2 characters).
'03Mar14 TH Added PSO Flag
'26Jan17 TH  Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)

Dim strRTFFile As String
Dim strFilename As String
Dim strPointerFilename As String
Dim strFilePrefix As String
Dim strOutfile As String
Dim lngPointer As Long
Dim lclsup As supplierstruct
Dim intFound As Long
Dim strMsg As String
Dim strMethodTypes As String '18Mar09 TH
Dim strFilesuffix As String
Dim strPointer As String
Dim RTFTxt$
Dim strOutFilename As String
Dim strPSOPrefix As String
Dim eHubPatientsHeapID As Integer  '01Apr14 TH eHub
Dim intSuccess As Integer
Dim strTotLines As String

   On Error GoTo BatchOrderlogOutputfooter_Err
   
   If blnPSO Then
      strPSOPrefix = "PSO"
      'Setting here to allow PSO to go thr0ugh standard generic set up
   End If

   'Check the type of order record is correct.
   If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "DH", strPSOPrefix & "OrderKinds", 0), strKind) > 0 Then

      'Get the supplier Code
      'getsupplier (strSupcode), 0, intFound, lclsup
                                                             
      'Check that the supplier type is speicified in the ini file
      'If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "E", "SupplierTypes", 0), lclsup.suppliertype) > 0 Then
            '06Aug10TH Removed below as we are no longer checking aganst supplier
            ''Check that the supplier method type is speicified in the ini file
            'strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMT", "MethodTypes", 0)
            'strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strMethodTypes, "MethodTypes" & strKind, 0) '18Mar09 TH Added to allow filtering by kind and method (UHB)
            ''If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMT", "MethodTypes", 0), lclsup.Method) > 0 Then
            'If InStr(UCase$(strMethodTypes), UCase$(strKind)) > 0 Then
            
                  
                  
                  'Output the file
                  'Here we want to get the batch header file
                  strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "UHBOrdFooter.rtf", strPSOPrefix & "BatchfooterRTFFile", 0)
                  strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, strPSOPrefix & "BatchfooterRTFFile" & strKind, 0) '03Mar09 TH Added
                  If strRTFFile <> "" Then
                     strRTFFile = dispdata & "\" & strRTFFile
                     'If fileexists(strRTFFile) Then
                     '07Jan17 TH Replaced checks
                     'GetRTFTextFromDB strRTFFile, "", intSuccess
                     'If intSuccess Then
                     If RTFExistsInDatabase(strRTFFile) Then  '26Jan17 TH Replaced above
                        
                        'Now we must store the local file name so we can append the detail lines
                        strFilename = getBatchOrderOutputFileName()
                        setBatchOrderOutputFileName ""
                        
                        'parse the file append to the main file
                        'GetTextFile strRTFFile, RTFTxt$, 0
                        GetRTFTextFromDB strRTFFile, RTFTxt$, 0  '06Dec16 TH Replaced (TFS 157969)

                        'Read the local file.
                        ParseItems gPRNheapID, RTFTxt$, 0

                        'write RTFTxt$
                        PutTextFileAppend strFilename, RTFTxt$, 0
                        
                        
                        'eHub we need to parse the whole now with the patient block
                        'create new heap
                        Heap 2, eHubPatientsHeapID, "", "", False 'For Safety completely clear heap both before and after - this has patient specific info
                        Heap 1, eHubPatientsHeapID, "eHub Integration Data Heap", "", intSuccess
                        If Not intSuccess Then
                           popmessagecr "eHub", "Failed to allocate data heap for eHub Integration"
                        Else
                           'Put the patientBlock onto the heap
                           Heap 10, eHubPatientsHeapID, "eHubPatients", get_str_eHubPatientBlock(), 0
                           
                           Heap 11, gPRNheapID, "OrderLineNumber", strTotLines, 0      '15Apr14 TH Added
                           Heap 10, eHubPatientsHeapID, "oTotLines", strTotLines, 0  '     "
                           
                           'parseRTFFromAdditionalHeap strFilename, strOutfile, eHubPatientsHeapID
                           parseRTFFromDBFromAdditionalHeap strFilename, strOutfile, eHubPatientsHeapID '13Jan17 TH Converted to use DB RTF (TFS 157969)
                        
                           On Error Resume Next
                           If fileexists(strFilename) Then Kill strFilename
                           On Error GoTo 0
                           strFilename = strOutfile
                           'destroy heap
                           Heap 2, eHubPatientsHeapID, "", "", False
                           set_str_eHubPatientBlock ""
                        End If
                        '----------------------------
                        Heap 11, gPRNheapID, "OutputRefNoPad", strPointer, 0
                        lngPointer = Val(strPointer)
                        
                        strOutFilename = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "", strPSOPrefix & "ExportFilePath", 0)
                        
                        strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "O", strPSOPrefix & "FilePrefix", 0))
                        'strFilename = strFilename & "\" & strFilePrefix & Left$("0000000000", 10 - (Len(Format$(lngPointer)))) & Format$(lngPointer)
                        If TrueFalse(TxtD(dispdata$ & "\Genint.ini", "", "N", "UMMCOutputFileName", 0)) Then  '07Sep10 TH Added section to enure name is correct for UMMC (FINV) (F0054531)
                           If strKind = "R" Then
                              strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_GRN_", "FilePrefixReceipt", 0))
                           ElseIf strKind = "E" Then '06Aug10 TH Reinstated as kind check for releasing credit note batch file with correct file name
                              strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_GRN_", "FilePrefixCredit", 0))
                           Else
                              strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_PR_", "FilePrefixOrder", 0))
                           End If
                           strOutFilename = strOutFilename & "\" & strFilePrefix & Format$(Now, "YYYYMMDDHHNNSS") & "_" & Right$(Format$(lngPointer, "00"), 2)  '04Oct10 TH Added Right
                        Else
                           strOutFilename = strOutFilename & "\" & strFilePrefix & Format$(lngPointer, "0000000000")
                           strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "", strPSOPrefix & "Filesuffix", 0))
                           If strKind = "A" Then
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixAdjust", 0))
                           ElseIf strKind = "R" Then
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixReceipt", 0))
                           ElseIf strKind = "E" Then '06Aug10 TH Reinstated as kind check for releasing credit note batch file with correct file name
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixCredit", 0))
                           Else
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixOrder", 0))
                           End If
                        End If
                        strOutFilename = strOutFilename & strFilesuffix
                        strOutFilename = strOutFilename & TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", ".xml", strPSOPrefix & "OutputFileExtension", 0)
                        
                        'On Error GoTo TransactionOutput_Err
                        FileCopy strFilename, strOutFilename
                        
                        On Error Resume Next
                        If fileexists(strFilename) Then Kill strFilename
                        On Error GoTo 0
                        
                     Else
                        popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Export File Not Found"    '09Apr09 TH Added after CKJ review
                     End If
                  Else
                     popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Export File not specified"   '09Apr09 TH Added after CKJ review
                  End If
               'End If '06Aug10TH Removed
         'End If
      End If
BatchOrderlogOutputfooter_Exit:
   Exit Sub

BatchOrderlogOutputfooter_Err:
   strMsg = "An error has occurred in procedure : BatchOrderlogOutputHeader" & crlf & crlf '09Apr09 TH Altered after CKJ review
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\OrderOutput.log", SiteNumber, UserID$, strMsg
   Resume BatchOrderlogOutputfooter_Exit

End Sub

Sub EnterDeliveryReference(ByVal strOrderNum As String)
'06Sep10 TH Written
'           Added to collect if required the Docket Number (UMMC FINV) (F0054531)
'Logic should be ;
'If force capture then loop until valid entry or escape.k.escd is captured above and then used to roll back receipt
'If not force capture then allow blank and ,if cancel, dont set k.escd but save blank ddel ref number


Dim strMsg As String
Dim strTemp As String
Dim strCaption As String
Dim blnForceDelRefCapture As Boolean
Dim strDeliveryNoteReference As String

   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Receipt", "N", "CaptureDeliveryRef", 0)) And (Val(strOrderNum) > 0) Then
      k.Max = Val(TxtD(dispdata$ & "\winord.ini", "Receipt", "10", "DeliveryRefMaxlength", 0))
      strCaption = TxtD(dispdata$ & "\winord.ini", "Receipt", "Delivery reference", "DeliveryRefInputCaption", 0)
      strMsg = "Enter Delivery Note Number"
      strMsg = TxtD(dispdata$ & "\winord.ini", "Receipt", strMsg, "DeliveryRefMessage", 0)
      
      blnForceDelRefCapture = True
      
      strDeliveryNoteReference = ""
      'Do While Not k.escd And blnForceDelRefCapture = True
      Do While (Trim$(strDeliveryNoteReference) = "") And blnForceDelRefCapture = True And (Not k.escd)
         blnForceDelRefCapture = TrueFalse(TxtD(dispdata$ & "\winord.ini", "Receipt", "N", "ForceDeliveryRef", 0))
         InputWin strCaption, strMsg, strDeliveryNoteReference, k
         '28Sep10 Changed after discussion with Khae
         If Not (k.escd And blnForceDelRefCapture) Then
            'Now if force capture and escaped then stop the receipt process
            'If Trim$(strDeliveryNoteReference) = "" And blnForceDelRefCapture Then k.escd = True
            strTemp = "Delivery note number must be entered"
            strTemp = TxtD(dispdata$ & "\winord.ini", "Receipt", strTemp, "DeliveryRefForceCaptureMessage", 0)
            If Not k.escd And Trim(strDeliveryNoteReference) = "" And blnForceDelRefCapture Then
               popmessagecr "", strTemp
            End If
         End If
      Loop
      If Not k.escd Then
         setDeliveryNoteReference strDeliveryNoteReference
      Else
         'If escaped but not forcecapture then record a blamk
         If Not blnForceDelRefCapture Then setDeliveryNoteReference ""
      End If
   End If
   
   If Not blnForceDelRefCapture Then k.escd = False  '28Sep10 Th Added. If not force capture then dont set k.escd as this will close down the receipt process

End Sub

Sub MainLVWRemoveSelection()
'02Jun11 CKJ written as replacement for OMarked() array handling

Dim Item As ListItem
   
   On Error GoTo MainLVWRemoveSelectionErr
   For Each Item In MainScreen.lvwMainScreen.ListItems
      Item.Selected = False
   Next
   
MainLVWRemoveSelectionExit:
Exit Sub

MainLVWRemoveSelectionErr:
Resume MainLVWRemoveSelectionExit
End Sub

Function MainLVWIsItemSelected(Index As Long) As Boolean
'02Jun11 CKJ written as replacement for OMarked() array handling
'            Intended for use where index may be outside the valid range of ListItems

Dim ItemSelected As Boolean

   ItemSelected = False
   On Error GoTo MainLVWIsItemSelectedErr
   With MainScreen.lvwMainScreen
      If Index > 0 And Index <= .ListItems.count Then
         ItemSelected = .ListItems(Index).Selected
      End If
   End With
   
MainLVWIsItemSelectedExit:
   MainLVWIsItemSelected = ItemSelected
Exit Function
   
MainLVWIsItemSelectedErr:
   ItemSelected = False
Resume MainLVWIsItemSelectedExit
End Function

Function MainLVWAreAnySelected() As Boolean
'02Jun11 CKJ written as replacement for OMarked() array handling
'            Returns True if one or more lines are selected

Dim Item As ListItem
Dim AnySelected As Boolean

   AnySelected = False
   On Error GoTo MainLVWAreAnySelectedErr
   For Each Item In MainScreen.lvwMainScreen.ListItems
      If Item.Selected Then
         AnySelected = True
         Exit For
      End If
   Next
MainLVWAreAnySelectedExit:
   MainLVWAreAnySelected = AnySelected
Exit Function
   
MainLVWAreAnySelectedErr:
   AnySelected = False
Resume MainLVWAreAnySelectedExit
End Function

Function MainLVWAreMultipleSelected() As Boolean
'02Jun11 CKJ written as replacement for OMarked() array handling
'            Returns True if two or more lines are selected

Dim Item As ListItem
Dim AnySelected As Boolean
Dim MultipleSelected As Boolean

   On Error GoTo MainLVWAreMultipleSelectedErr
   AnySelected = False
   MultipleSelected = False
   
   For Each Item In MainScreen.lvwMainScreen.ListItems
      If Item.Selected Then
         If AnySelected Then
            MultipleSelected = True
            Exit For
         Else
            AnySelected = True
         End If
      End If
   Next
   
MainLVWAreMultipleSelectedExit:
   MainLVWAreMultipleSelected = MultipleSelected
Exit Function
   
MainLVWAreMultipleSelectedErr:
   MultipleSelected = False
Resume MainLVWAreMultipleSelectedExit
End Function

Function MainLVWSingleSelectedItemIndex() As Long
'27Jun11 CKJ Returns the index of the currently selected item (ie where the marquee is)
'            but only if this is the only SelectedItem, with highlight
'            Returns 0 if no valid line is selected or if multiple lines are selected
'            Also returns 0 if there is one highlighted line which is NOT the current line

Dim ItemIndex As Long

   On Error GoTo MainLVWSingleSelectedItemIndex_Err
   ItemIndex = 0
   
   With MainScreen.lvwMainScreen
      If .ListItems.count > 0 Then                             'any lines to select
         If Not (.SelectedItem Is Nothing) Then                'a line is selected
            ItemIndex = .SelectedItem.Index
            If .ListItems(ItemIndex).Selected Then             'Line with focus is highlighted
               If MainLVWAreMultipleSelected() Then            'Is it the only line?
                  ItemIndex = 0
               End If
            Else
               ItemIndex = 0
            End If
         End If
      End If
   End With
      
MainLVWSingleSelectedItemIndex_Exit:
   MainLVWSingleSelectedItemIndex = ItemIndex
Exit Function

MainLVWSingleSelectedItemIndex_Err:
   ItemIndex = 0
Resume MainLVWSingleSelectedItemIndex_Exit

End Function

Function MainLVWHighlightSingleRowByIndex(ByVal ItemIndex As Long) As Boolean
'27Jun11 CKJ Unselects all rows then highlights just the one (if valid)
'            and sets it as the item with focus (the marquee)
'            ensuring it is visible by scrolling if necessary
'            Returns success T/F

Dim success As Boolean

   success = False
   On Error GoTo MainLVWHighlightSingleRowByIndex_Err
   
   MainLVWRemoveSelection                                      'cancel existing highlights if any
   
   With MainScreen.lvwMainScreen
      If .ListItems.count > 0 Then                             'any lines present
         Select Case ItemIndex
            Case Is > 0, Is <= .ListItems.count                'index is valid
               '.SelectedItem.Index = ItemIndex                 'set marquee
               .ListItems(ItemIndex).Selected = True           'set highlight
               .ListItems(ItemIndex).EnsureVisible             'scroll if needed
               success = True
            End Select
      End If
   End With
      
MainLVWHighlightSingleRowByIndex_Exit:
   MainLVWHighlightSingleRowByIndex = success
Exit Function

MainLVWHighlightSingleRowByIndex_Err:
   success = False
Resume MainLVWHighlightSingleRowByIndex_Exit

End Function


Function MainLVWMarqueeRowIndex() As Long
'27Jun11 CKJ Returns the index of the current item, even if .selected=False
'            ie it's where the cursor is, but not necessarily highlighted
'            and may not be for the same drug as txtinput is showing.
'            Otherwise known as the 'marquee'
'            Returns 0 if .SelectedItem Is Nothing or there are no rows

Dim ItemIndex As Long

   On Error GoTo MainLVWMarqueeRowIndex_Err
   ItemIndex = 0
   
   With MainScreen.lvwMainScreen
      If .ListItems.count > 0 Then                             'any lines to select
         If Not (.SelectedItem Is Nothing) Then                'a line is selected
            ItemIndex = .SelectedItem.Index
         End If
      End If
   End With
      
MainLVWMarqueeRowIndex_Exit:
   MainLVWMarqueeRowIndex = ItemIndex
Exit Function

MainLVWMarqueeRowIndex_Err:
   ItemIndex = 0
Resume MainLVWMarqueeRowIndex_Exit

End Function

Sub MainScreenSetTextAndPanels(ByVal Edittype As Integer)
'06Jul11 CKJ Code was duplicated many times (~30)
'            Centralised, simplified & error checked. Only applies to non-ward stock display
'            Takes current listview line (one with focus) and looks up order associated (if any)
'            Sets txtinput and panels if order found otherwise clears txtinput & panels
'            Uses global OInfoStore and osite$
'            Plus local ord, d and sup (latter two in UpdatePanels)

'//// any need for this?
'               Select Case Abs(edittype)
'                  Case 1, 3, 4, 5, 6, 9


Dim rowline$
Dim Numoflines As Integer
Dim lngOrderID As Long
Dim lngIndex As Long
Dim valid As Boolean
Dim udt_ord As orderstruct
Dim lines() As String

   With MainScreen
      If .TxtInput.Visible Then        'only if not ward stock
         valid = False
         lngIndex = MainLVWMarqueeRowIndex()    '//// may use MainLVWSingleSelectedItemIndex instead
         If lngIndex Then
            rowline$ = OInfoStore(lngIndex)
            If Len(Trim$(rowline$)) Then
               ReDim lines(OTblMaxCols + 1) As String
               deflines rowline$, lines$(), "|(*)", 1, Numoflines
               If Numoflines >= OTblMaxCols + 1 Then
                  lngOrderID = Val(Trim$(lines$(OTblMaxCols + 1)))
                  getorder udt_ord, lngOrderID, Edittype, False
                  .TxtInput.text = Trim$(udt_ord.Code)
                  UpdatePanels udt_ord, Abs(Edittype)
                  If Edittype = 1 And osite$ <> "A" And TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "Defaults", "Y", "OrderValuetoHeap", 0)) Then
                     Heap 10, gPRNheapID, "TotalOrderValue", CalculateWOrderValue(osite$), 0
                  End If
                  valid = True
               End If
            End If
         End If
         
         If Not valid Then
            .TxtInput.text = ""
            .PicInfo1.Cls
            .PicInfo2.Cls
            'consider BlankOrderInfoScreens instead as this hides the panels as well
         End If
         
         .TxtInput.SelStart = 0
         .TxtInput.SelLength = Len(.TxtInput.text)
      End If
   End With
   
End Sub


