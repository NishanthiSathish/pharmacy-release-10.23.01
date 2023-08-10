Attribute VB_Name = "Orderlib"
'DOStoWIN V1.0 (c) ASCribe 1996
'                  Library routines for Ordering program
' 3Jun93 ASC Orderlib.rem made
' 4Nov93 CKJ VBDOS: printform => printformV
'22Nov93 CKJ Updateprice: Credit notes mod
'29Dec93 CKJ Added user def msg to orders
'31Dec93 CKJ Mods to PrintCard, added EditDrugMessage
'10Jan94 CKJ VATrate added to Orderlog BUT SET TO 0%
'14Jan94 CKJ Checked ORDERLOG VAT rates for all transactions. Added LookupDrug
'16Jan93 CKJ Pointers to all ordering files now LONG
'25Jan94 CKJ Added new codes to readorddata
'25Jan94 CKJ Extra check on wild reconciliations
'10Feb94 CKJ Added AskBatchNum
'24Feb94 CKJ Added contract to direct order log & wildcards to auth. & raise
' 7Mar94 CKJ Shared suppliers(), passlvls changed
' 9Mar94 CKJ Borderline for max module size - bits trimmed to make room
' 8Apr94 CKJ Corrected stockl path
' 3May94 CKJ Mod to PrintCard
'10Aug94 CKJ Space needed - rem'd lines for testing with 'debug
'11Aug94 CKJ Removed Locates from PrintSupScreen
'            Mod to joinsup, added sup.discountdesc to screen
'            Printcard: corrected stockl path
'            Temp mod for Picking Ticket printing (Burnley V6.1)
'31Aug94 CKJ Space saving mods to allow compilation with /e
' 5Jan95 CKJ ReadSites & SetDispdata
' 7Jan95 CKJ UpdatePrice: Internal ord box on manual only
'            SelectForSupplier: Use price last paid, not current issue price
'19Jan95 CKJ SiteInfo$ default added
'19Jan95 CKJ Printcard: Changed stockl path
' 9Feb95 CKJ CheckLevels: Added sisstock<>N to cycle check
' 5Mar95 CKJ Added ord.recdate to picking ticket issues, mod to printcard.
'22Apr95 ASC Price pinted on order if set in order.dat
' 5May95 CKJ Added OrdPrintLin, modified Selectforsupplier
' 5Jun95 CKJ Calls to getdrug: replaced find with 0 where appropriate
'14Jun95 CKJ Printcard modified
'21Jul95 CKJ Mod to default price on raising order
' 3Jul95 CKJ Corrected credit order printing and suppl. order printing
'24Aug95 CKJ Merged EDI mods
'22Sep95 CKJ ReadSites: Added redim if no other sites
'22Nov95 CKJ Removed Printlabels(dummy$)
' 8Feb96 EAC PutSupplier: Use new version of (un)lockrecord
'20May96 CKJ CheckLevels: Mod to cyclical to avoid negative qtys
'23May96 CKJ Added () for plural$
'24May96 CKJ Added ASCRIBE.INI [Orders] CycleLvlChk=0/[1]
'04Dec96 EAC Only read xx records at a time
'04Jun97 EAC Speed up issueing of pick tickets/delivery notes/
'            orders & credit order authorisation
'            tidied display of unnamed suppliers & num of
'            pick/del notes to be printed
'12Jun97 EAC SelectForSupplier: Corrected internal ordering
'18Jun97 EAC SelectForSupplier: More mods to internal ordering
'29Jun97 EAC Use seperate DB variable SupDB in place of WSDB
'08Oct97 EAC fall out of loop after saying no in Acquirelock
'10Dec97 EAC PrintPickBody: Allow specification of how many characters of the description are to printed.
'            PrintPickBody: Make top and bottom delimiter lines the same length
'23Dec97 EAC PrintPickBody: Ensure part orders are formatted as 0.x
'29Dec97 EAC Use stores drug description
'30Dec97 EAC Allow picking tickets for wards to be printed using "8 x100" instead of "800"
'06Jan98 EAC changes to allow flexible RTF printing
'05Mar98 ASC printordertop: Added extra text to indicate with this print is original
'            PrintPick: Added call to KillReprint if problems with printing
'            Reprint: New procedure to reprint orders credit orders,picking tickets and delivery notes.
'            updateprice: Now writes full description to log (Previously was truncating)
'            CheckIfWholeStoresPacks: converts to dispensary units if not whole stores packs for printing
'            EnterAmend: Now displays stock level when in issue box.
'                        Prompt to user to ask if they wish to re-order outer size or not (if applicable)
'            KillReprint: New procedure. Kills the reprint file
'            ParseRequisition: Added Section to print tofollow in correct units
'05Mar98 CFY printpick: New parameter added to shellsort
'            reprint:                  "
'28Mar89     ParseRequisition: Corrected code which adds the pack size to the item line.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'18May98 CKJ Moved function TheDate to corelib
'08May98 CFY supdwithords: CFY Trapped negative prices to stop overflow error occuring. Previously the
'            putlinesinarray: Reduced the y counter by 1 if we hit the MAXLINES boundary to truly reflect the
'              number of lines that have been added to the array and stop the system asking
'              for record 0 as it loops through the array later.
'12Jun98 CKJ Replaced (Original) with square brackets to allow ParseRTF. Also used our date function
'12Jun98 CKJ Reprint: Allows parsing of multi-page RTF files, much greater than 32Kb
'            Also tidied and corrected several other aspects. See proc header for details.
'18Jun98 EAC/CKJ CheckIfWholeStoresPacks: prevent rounding errors when calculating quantities not in ward packs
'23Jun98 EAC ParseRequisitions: prevent rounding errors in to follow qty
'25Jun98 CFY printpick: Added dp! to stocklevel calculation to prevent E numbers occuring and messing up
'            quantities.
'26Jun98 EAC SupsWithOrds: Corrected error where out of stock items where shown as ready for printing
'26Jun98 EAC ParseRequisitions: Correct printing of tofollows for Picking Tickets
'07Aug98 SF  Reprint: Moved list box caption and heading so they are only displayed when there is
'            something to print and then they will be unloaded.
'11Aug98 TH  ReadOrdData: Added nsvreconciliation$ for totals reconciliation for coding slips
'18Aug98 EAC PrintSupScreen: declare supnotes locally
'30Oct98 EAC PutLinesInArray: Non stock items to be printed on same delivery note as stock items
'30Oct98 EAC PrintPick: allow non numeric codes as in enter requisitions and issue picking tickets
'12Nov98 TH  PrintPick: Removed Printed ok Prompt as reprint facility now available
'            and printing was locked whilst awaiting response
'23Nov98 TH  PrintPick: Added prompt to show numbers picking tickets/delivery notes are logged against
'30Nov98 TH  PrintPickbottom: Added message to supplier for returns.
'30Nov98 TH  PrintPick: Added get message to supplier prompt for returns.
'02Dec98 TH  GetOrderNo: New delno.dat file to record reprint numbers for delivery notes accessed with edittype 25
'02Dec98 TH  PrintPick: Added call to increment delnote.dat pointer file (using edditype 25 as flag)
'            because using pickno is not unique
'02Dec98 TH  PrintPick: Changed number prompt to match reprint numbers
'09Dec98 TH  PrintPicktop: Added extra increment to stop zero reprint number (on creation of dat file)
'21Dec98 CFY ReadOrdData: AskBatchNum still read here but is now not used. Batchnumbering is now designated
'            at the drug level.
'05Jan99 CKJ Supswithords: read sup only when required, not on every entry in the file
'22Jan99 TH  DisplaySpecialMsg: Reinitialise message on order
'22Jan99 TH  Entersite: Added code to properly title all suppliers on order screens
'25Jan99 TH  Updateprice: Added extra details to neg stock error message
'25Jan99 TH  PrintOrderTop: delname element now standard supplier address not contract address
'26Jan99 TH  Entersite: Replaced Tag with global to avoid referencing problems
'28Jan99 TH  Supswithords: Now uses manually entered cost if order correctly flagged
'28Jan99 TH  Updateprice: Code to allow for zero cost
'09Feb99 TH  Updateprice: Show contract price even without contract number
'11Feb99 TH  Supswithords: Authorise Orders box properly reflects cost that will be printed on order
'11Feb99 TH  Updateprice: show packsize and qty ordered not amalgam of both in reconcile screen
'15Feb99 SF  entersite: If list type chosen then user must select cost centre for that list
'22Feb99 TH  Updateprice: Change mousepointer around msgboxes
'22Feb99 TH  Updateprice: set cancel correctly
'22Feb99 TH  Supswithords: Altered way price calculated in authorise orders box
'05Mar99 TH  Updateordreqindex: Added code to deal with index locking -now cycles through 5 times
'            then gives option to abort (Merge from V)
'22Mar99 TH  ParseRequistion: Added to spaces for neg cost items to retain tab on delnote
'17May99 AE  UpdatePrice:Changed formatting of d.stocklvl on screen
'17May99 AE  FurtherInfo:Changed formatting of d.leadtime on screen
'17May99 AE  EnterAmend:Changed formatting of d.stocklvl on screen
'26Apr99 TH  Updateprice: Put Storesdescription to title of inputbox
'18May99 CFY printpick: Removed shell sort on items so that they will appear in the order that they
'            were issued rather than sorted alphabetically by description
'27May99 TH  ParseRequistion: Added TradeName element to requisition
'08Jun99 TH  printpick: Now releases lock before popmsg with order no.
'22Jun99 TH  Updateprice: Zero price now acceptable in check on d.cost
'06Jul99 TH  printpick: Reinstated shellsort on picking ticket array on ini file setting
'11Oct99 CKJ Removed Findsupplier, replaced with GetSupplier
'12Oct99 AE  DischargeEditors: Added stub.
'14Oct99 AE  UpdatePrice:Added another Unload FrmEnhTxtWin - belt'n'braces
'19Oct99 AE  Reprint:Prevent "Out of String Space" if there are many reprint files, allow the user to see
'            the most recent files and show a message telling them to tidy reprints
'19Oct99 AE  Reprint:replaced reprint to context with view then print to defautl printer from high edit.  This to
'            allow the user to select the printer to print the reprint to, since some sites were printing
'            to a fax, but didn't want the reprints there.
'26Oct99 AE  ConfirmedReceiveFree: Written. Asks user to confirm recipt of free goods, asks for password
'            if appropriate and logs the action
'26Oct99 AE  UpdatePrice: Changes to the way free items are recieved.  If Done via F8, user must enter a high
'              Level password.  User is warned that they are about to receive at zero cost, and
'              their action is logged in dispdata\ZeroC.log.  If an item was ordered at zero cost,
'              this is also logged here.
'01Nov99 TH  PutLinesInArray: When authorising credit note allow abort of item if results in neg stocklevel and nonegissues set in patmed.ini
'08Nov99 TH  PutLinesInArray: Use counter for skipped items rather than flag
'11Feb00 MMA/SF printpick: replaced readprivateini: with txtd: as was reading the whole line including comments
'01Mar00 TH  Furtherinfo: Added Created User ID
'31Mar00 AE  Moved EOPmargin from Storesasc into Orderlib as it prevented Overnite from compiling
'13Apr00 TH  Updateprice: Change to message on receipt *GST*
'15May00 AE  ReadOrdData:Initialise EOPMargin; otherwise, is zero unless the site has gone into
'            "Set/Report Working Defaults" and saved.
'15May00 EAC/AE UpdatePrice: Corrected handling of Update received price
'26Sep00 TH  UpdatePrice: Changed format of stock lvl to 6 sig places
'26Sep00 TH  EnterAmend: Changed formatting of d.stocklvl on screen to 6 sig places
'29May01 TH  UpdatePrice: Changed call parameters to popmsg to handle escape correctly (#52398)
'24sep01 CKJ Merged:
'01Sep01 TH  Supswithords: Replaced tax symbol with currency symbol for discount display (#53521)
'31Oct01 TH  ParseRequisition: Changes to how the picklist array is handled now that the loccode field has been added for delivery notes. (enh1302)
'31Oct01 TH  PutLinesInArray: Added dblRound to prevent rounding problems when returning part of pack (#52463)
'31Oct01 TH  PutLinesInArray: Added location code as first in delnote array element (ie can be sorted on this). (enh1302)
'09Nov01 DB  Merged:
'03Oct01 DB  Supswithords, UpdatePrice: Replaced dp and poundsandpense calls due to a rounding error on numbers above 7 characters including decimal.
'            For example - 20832.08 was displayed as 20832.10
'30Oct01 TH/CKJ  PrintPicktop: Added elements wardcode and shortname and trapping on unfound suppliers for other elements
'   "            Now returns blank if given supplier cannot be found
'30Nov01 TH  Reprint: Remove "original" entry from heap as this was then being parsed into new orders before they could be reprinted next time. (#57228)
'14Jan02 TH  EnterAmend: Fix typo (#57617)
'14Jan02 TH  ConfirmedReceiveFree: Made title generic for user inputbox (#58208)
'08Mar02 TH  ShowFrmEnhTxtWin: written. Very simple wrapper at present only used to handle kbd type correctly  (#56352,54364)
'08Mar02 TH  UpdatePrice: Various changes involving using a new wrapper to call frmenhtxtwin when updating price (#56352,54364)
'22Apr02 SF  EnterAmend: added reorder outer info to the qty input form (enh#1555)
'10May02 SF  printpickbody: ParseRequisition: now also returns the total inlcuding onCost and the TAX total including onCost (enh#1555)
'10May02 SF  printpickbody: PrintOrdTotal: now also passes in the total inlcuding onCost and the TAX total including onCost (enh#1555)
'10May02 SF  ParseRequisition: added on cost enhancement, new data element [costinconcost] (enh#1555)
'10May02 SF  PrintOrdTotal: added on cost enhancement, new data element [totalexvatinconcost] (enh#1555)
'21May02 SF  EnterAmend: added i_strCaption parameter and sets the caption to the one passed in (en#1371)
'21May02 SF  ParseRequisition: added data elements [QtyOuter] and [QtyWithOuter] (enh#1371)
'27May02 SF  supswithords: now will not authorise the order if the supplier not in use (enh#1362)
'25Jun02 SF  supswithords: changes to enh#1362 after a review from PM testing
'04Jul02 TH  ParseRequisition: Added strips data element for Pyxis
'08Jul02 TH  ParseRequisition: Added override with nonegissues set that allows requisition to be created that will lead to neg stock on issue (#61735)
'29Jul02 TH  ParseRequisition: Mods to stripsize enhancement to fencepost 0 strip items and round to 2 dec places where required.
'14Oct02 CKJ Convdat: Removed trim() as trailing spaces are needed to preserve formatting on screen when date is blank   (#64106)
'10Feb03 TH  PutLinesInArray: Added ini file to initialise second none Index Search
'04Jun03 TH  updateoutstanding: Added Logging for investigation purposes (#)
'26Jan04 TH  supswithords: Added check to ensure not in use suppliers are handled correctly (#72056)
'18Mar04 CKJ ParseRequisition: Added [loc2] for Swisslog users
'31Mar04 CKJ {SP1}
'            moved obsolete procs to ./old/orderlib.rem: entercode, EditDrugMessage, positionblob, PrintPickTotal
'            Note that there are many variables without type declarations - handle in {SP2}
'19Apr04 TH  SupsWithOrds: Removed PrintinPacks clause to enable prints of part pack orders (#61824)
'            PutLinesInArray: Removed PrintinPacks to allow selection of fractional order (#61824)
'            Reprint: Altered header formatting of reprint selection screen (#enh1574)
'            UpdatePrice: Added new flag to ensure the price last paid is NOT update if non-stock item AND box not checked (#73293)
'16May04 TH  Moved GetStoresDescription() from here to Subpatme.Bas(#63766)
'21May04 TH  Moved back here after referencing problems
'14Mar08 JP  Added call to getsupplier sub so correct supplier code is selected
'21Jun04 CKJ putlinesinarray, ParseRequisition: added mechdisp issue (23Jan08 CKJ ported from V8)
'30Jun04 CKJ ParseRequisition: now allows configuration of brackets round qty (23Jan08 CKJ ported from V8)
'16Jun05 CKJ ParseRequisition: added strMessageText (23Jan08 CKJ ported from V8)
'15Aug05 CKJ PrintPickBody: Added block for robot Picking tickets (23Jan08 CKJ ported from V8)
'20May08 CKJ call MechDispClearLabelData (10Jun08 CKJ merged)
'13Jun08 JP  F002590
'13oct08 CKJ Merged from V8.8: 01Aug08 TH/CKJ Updateprice: (F0023465) Extra fencepost to protect from "double receipt"
'14Oct08 TH  Updateprice: Stop none numeric entry (".") being saved to order file - was breaking reporting  (F0030065)
'03Nov08 TH  Updateprice: (F0037390) Always alter update price last paid on a receipt (except the exceptional free things)
'31May09 TH  Putlinesinarray: Mod to prevent (on config)printing of PT for part of pack (ie less than 1 full pack) (F0033050)
'23Jun08 XN  F0033906 Added DisplayDrugEnquiry and ParseCommandURLServerAndWebFolder
'            method to use the ICW F4 desktop to display drug information
'30Sep10 TH  Printpick: Altered fencepost to allow batching on singleline credit order (F0097763)
'02Sep10 TH  Added m_strDeliveryNoteReference, get and set(UMMC FINV) (F0054531)
'11Jul11 CKJ Changed call from PrintStockLabels which was a stub proc to PrintStockLabelsSQL which does print

'RCN P009

'19Mar09 TH  SetDispdata: Added sitenumber to heap for UHB Interfacing (F0032689)

'RCN P007
'19Jan10 PJC SupsWithOrds: Added loop to find the correct supplier from array for minimal order. (F0074352)

'------ RCN P070
'15Jan10 XN  Added method DisplayRobotLoading and ParseCommandURLServerAndWebFolder (F0042698)
'02Nov10 AJK PrintPick: F0086901 Added date invoiced to OrderLog calls
'------ RCN P158
'09Apr10 XN  F0068649 EDI orders have seprate max number of lines per an order
'14Apr10 TH  ReadOrdData: Added ReconciliationThreshold (F0056463)

'------ RCN P0545
'03Nov10 TH  PrintOrderTail: Added after testing cos the rtf wouldnt handle the crlf directly (had to create two new elements.
'
'------ RCN P0650
'26Jul11 XN DisplayDrugEnquiry: Added robot stock level to F4 screen F0118239
'           DisplayDrugEnquiryKeyPress: New method to process the robot stock level request F0118239
'23Feb12 TH ReadOrdData: Replaced as blank is a valid setting (TFS20214)

'------- September release
'31May12 TH  PrintPick: DLO Changes
'11Jun11 TH  PrintPick: Furhter DLO Changes .Added param to sups with ords so DLO selections can be identified.
'11Jul12 TH  PrintPick: DLO Polishing - altered input box captions and info displayed (TFS)
'29May12 TH  BlankOrder: Added DLO Field
'11Jun12 TH  Extended global suppliers() array to accomodate DLO info.
'19Jul12 TH  PrintPick: Ensure DLO Order Qty createed is factored by PrintinPacks setting (TFS 39281)
'14Nov12 TH  Supswithords: PSO Caption support on auth orders (TFS 48800)
'26Mar13 TH  Printordertail,PrintOrdTotal: Handle stuff at this stage with no parsing braces (TFS 59714)
'27Mar13 TH  Printordertail: Removed stuff to handle rtf text after final parse - this was handled already in the conditional check (TFS 59714)
'27Mar13 TH  PrintOrdTotal: Moved handling of final rtf text  (TFS 59714)
'26Jun13 TH  Reprint: Added Ability to pick reprints from DB (TFS 64513)
'14Aug14 TH  PrintOrderTop: Added ordermsg element (TFS 86715)
'14Aug14 TH  PrintPickTop: Added ordermsg element (TFS 86715)
'24Jul15 XN  findnumberofpages: Picking Tickets Page Number Error 119158
'                        printpick: Picking Tickets Page Number Error 119158
'27Jul15 TH  Putlinesinarray: Changed Screen msg to properly reflect the print (TFS 90862)
'28Jul15 XN  supswithwords: Reordered, added Min Order column 92596
'03Aug15 TH  UpdatePrice: Mods to stop exponential in price last paid (TFS 102570)
'05Aug15 TH  EnterAmend: Stop fractional ordering when fraction not resolvable to 2 dec places (TFS 46785)
'14Dec15 TH  UpdatePrice: Reverted mod because the mask only protects manual price entry and we can get exp costs
'                         from automated receipt (internal order). Also added mod to remve exp where cost changed but no stock(TFS 137904)
'01Feb16 TH  Entersite: Changed input to asksupplier for PSO filtering (TFS 138644)
'26Jan17 TH  PrintOrdDescriptor: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'26Jan17 TH  printordertail: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'26Jan17 TH  PrintOrderTop: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'26Jan17 TH  PrintPickBottom: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'26Jan17 TH  PrintPickTop: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'12Feb17 TH  PrintPick: Removed call to kill reprint as now inappropriate (TFS 176106)
'09Mar17 TH  PrintOrdDescriptor: Added section to support Fax rtfs (TFS 179309)
'02Apr17 TH  Putlinesinarray: Replaced above. May have been a misplaced attempt to check an rtf, but we can find
'                             no evidence of this file on site so default behaviour to False (TFS 174890)
'04Aug17 TH  supswithwords: Ensure Supplier lookup done on code as IDs now not unique across new tables (TFS 190644)
'28Nov17 DR  Backed out previous change (TFS 190644)
'15Feb18 DR  Bug 204009 - When authorising an order in stores, the value displayed does not reflect the actual value of the order immediately
'09Apr18 DR  Bug 209205 - Stores - Authorise orders - Minimum value pop up box with wrong information incorrectly appears for DLO item
'15Oct18 AS  Bug 224253: Pharmacy Stores - printing wrong supplier details on orders
'18Jan21 NS MM-4017-SW - Tx Text control EDI order not printing content of order
'22Jan21 NS MM-3609 Added condition before including the \par
'29Jan21 NS MM-4639 SW - Purchase Order missing data and removing MM-4017 changes

Option Explicit
DefInt A-Z

Global ODrugInfo$
'Global IndexStartPos&,                '27Jun11 CKJ Unused. Removed
Global OrderStartPos& '04Dec96 EAC
'Global supchan                        '02Aor04 CKJ correct one is module level in Supplier.bas
Global orddebug%, supsinarray%         '04Jun97 EAC speed up authorisatioins
Global scrnmsg$  '26Jan99 TH
'Global IndexDebug '04Mar99 TH Merged from 8066
Global NoOfPTs&    '09Mar99 TH PT fix '26Mar99 TH Changed from integer to long  '28Jun98 Merge from 8066
'Global nositeindex%                    '17Feb99 TH
Global EOPMargin%     '31Mar00 AE Moved from StoresASC.bas '23Mar00 TH Added
''Global suppliers() As String * 21 '10Oct97 EAC
'Global suppliers() As String * 27
Global suppliers() As String * 30  ' 11Jun12 TH DLO

Dim r As filerecord            '!!** already global {SP2}
Dim ord As orderstruct
Dim tempord As orderstruct
Dim txtline$(5)
Dim dt As DateAndTime, td As DateAndTime
' 7Mar94 CKJ added ...
'Dim Shared numofsups, suppliers(numofsups) As String * 15
Dim numofsups As Integer
'22Apr95 ASC added
Dim specialmsg$, PtotordCost!, PtotordVat!
'11Jun96 EAC conversion to Windows
Dim ordchan As Integer, ordedittype As Integer
Dim picklist() As String
Dim m_strAdditionalOrderMsg As String '11Oct10 TH UMMC PRF Mods (F0094388/RCN545)

'Dim Ordno$                           '{SP2} seems obsolete       '15Aug05 CKJ Is obsolete. Removed
Dim m_strDeliveryNoteReference As String  '02Sep10 TH Added (UMMC FINV) (F0054531)

Sub adjustissueprice(d As DrugParameters, adjust!)
'          *****4*****         ****2*****
' ****3****           ****1****
' ---------*---------*---------*--------- Stockvalue + LossesGains
'          /2        1         x2
'                Stockvalue

Dim stockvalue!, Qty!
Dim newcost$

   d.lossesgains = d.lossesgains + adjust!
   stockvalue! = Val(d.cost) * dp!(Val(d.stocklvl) / Val(d.convfact))
   If Val(d.stocklvl) > 0 Then
      If d.lossesgains > 0 And d.lossesgains < stockvalue! Then     '**1**
         'If issue price will be no more than doubled by adding
         'losses and gains and lossesgains is +ve then average
         d.cost = LTrim$(Str$(dp!((stockvalue! + d.lossesgains) / (Val(d.stocklvl) / Val(d.convfact)))))
         d.lossesgains = 0
      Else
         If d.lossesgains > 0 Then                               '**2**
            'Only double price adding rest to losses and gains
            'to stop wild issue price fluctuations for +ve lossesgains
            d.cost = LTrim$(Str$(dp!(Val(d.cost) * 2)))
            d.lossesgains = dp!(d.lossesgains - stockvalue!)
         Else
            If d.lossesgains * -1 > stockvalue! / 2 Then      '**3**
               'If reducing by lossesgains would reduce price by more than half
               d.cost = LTrim$(Str$(dp!(Val(d.cost) / 2)))
               d.lossesgains = d.lossesgains + dp!(stockvalue! / 2)
            Else                                           '**4**
               'if reducing by lossesgains would not more than half the issue price
               d.cost = LTrim$(Str$(dp!((stockvalue! + d.lossesgains) / (Val(d.stocklvl) / Val(d.convfact)))))
               d.lossesgains = 0
            End If
         End If
      End If
   End If
   checklossgain d, ord.received, ord.cost, d.cost, newcost$, Qty!, "Updateprice-reconciliation"

End Sub

Sub blankorder(ord As orderstruct)
'29May12 TH Added DLO Field

   r.record = ""
   LSet ord = r
   ord.pickno = 0 '20Mar93 CKJ Added
   ord.DLO = False  '29May12 TH Added
   ord.PSORequestID = 0 '04Sep12 TH Added
   ord.WWardProductListLineID = 0 ' 17Aug16 XN Added 160463
   
End Sub

Function CalculatePickingTicketNumber(PageNumber As Integer) As String
'17Aug05 CKJ Added
'            BaseOrderNumber    range 1 to 9999
'            PageNumber         range 1 to n
'            Returns formatted string with value 1 to 9999

Dim BaseOrderNumber As Long
Dim PickingTicketNumber As Long

   getorderno 5, BaseOrderNumber, 0
   '13Sep96 EAC 9999 + pg1 -> 9999, 9999 + pg2 -> 1, 9999 + pg3 -> 2
   'PickingTicketNumber = ((BaseOrderNumber + PageNumber - 2) Mod 9999) + 1   '31dec07 CKJ ported function from V8 but amended to V9 standard - does not wrap at 9999
   PickingTicketNumber = BaseOrderNumber + PageNumber - 1                     '   "             **!! may want to wrap at 2^32-1
   CalculatePickingTicketNumber = Format$(PickingTicketNumber)
                                 
End Function

Sub CheckIfWholeStoresPacks(sendqty!, InStoresPacks%, send$)
Dim sendqty1!, sendqty2!
   
   If dp!(sendqty!) <> Int(dp!(sendqty!)) And Val(d.convfact) > 0 Then
      sendqty1! = dp!(sendqty! * Val(d.convfact))
      sendqty2! = CLng(dp!(sendqty! * Val(d.convfact)))
      If Abs((sendqty2! - sendqty1!) / sendqty1!) < (100 / 1000000) Then
         sendqty! = sendqty2!
      Else
         sendqty! = sendqty1!
      End If
      InStoresPacks% = False
   Else
      InStoresPacks% = True
   End If
   
   If Abs(sendqty!) < 1 Then    'still needed if want to order a fraction of an item with a convfact as 1
      send$ = Format$(sendqty!, "0.00")
   Else
      send$ = Format$(sendqty!)
   End If

End Sub

Function ConfirmedReceiveFree%(Edittype%, ord As orderstruct, AskPasswd%)
'Check for required password if necessary, and log all receipts / reconcilliations of free goods

Dim LocAcclevels$, LocUserFullname$, LocUserID$, fullname$
Dim valid%, msg$, OkToReceive%, escd%, Butt%
Dim drug$

   drug$ = d.LabelDescription  ' drug$ = d.Description  XN 4Jun15 98073 New local stores description
   plingparse drug$, "!"
   drug$ = Trim$(drug$)

   OkToReceive = False
   
   LocAcclevels$ = acclevels$
   LocUserID$ = UserID$
   LocUserFullname$ = UserFullName$
   
   If AskPasswd Then
      '''SQL ??? askpassword valid%, fullname$, "Free Goods"
      
      'If valid And Val(Mid$(acclevels$, 6, 1)) > 7 Then '22May05 TH Altered
      If Storepasslvl > 7 Then                           '   "
         escd = False
      Else
         popmessagecr "", "Password has insufficient privilege to receive free items."
         OkToReceive = False
         escd = True
      End If
   Else
      escd = False
   End If


   If Not escd Then
      Butt = 0
      msg$ = "WARNING! You are about to "
      msg$ = msg$ & Iff(Edittype = 3, "receive", "reconcile")
      msg$ = msg$ & " an item at ZERO COST." & cr$ & cr$
      msg$ = msg$ & "Are you sure you want to do this ?"
      Butt = MessageBox(msg$, MB_YESNO + MB_ICONSTOP + MB_DEFBUTTON2, Iff(Edittype = 3, "Receive", "Reconcile") & " Goods") '    "
      If Butt = IDYES Then
         OkToReceive = True
         msg$ = "Order " & Format$(ord.num) & ": " & d.SisCode$ & "(" & drug$ & ") "
         msg$ = msg$ & Iff(Edittype = 3, "received", "reconciled")
         msg$ = msg$ & " by User at Zero cost"
         WriteLog dispdata$ & "\ZeroC.log", 2, UserID$, msg$
      End If
   End If

   acclevels$ = LocAcclevels$
   UserID$ = LocUserID$
   UserFullName$ = LocUserFullname$

   ConfirmedReceiveFree = OkToReceive


End Function

Sub convdat(dat$)
'ddmmyy   => dd-mm-yy
'ddmmyyyy => dd-mm-yyyy

   dat$ = Left$(dat$, 2) & "-" & Mid$(dat$, 3, 2) & "-" & Mid$(dat$, 5)

End Sub

Sub defnumofouters(numofinners%, outersize%, numofouters%)

Dim numouters!

   numouters! = dp!(numofinners / outersize) '23Jun93 CKJ dp
   If numouters! - Int(numouters!) > 0.01 Then '.01 for rounding errors !
      numouters! = numouters! + 1
   End If
   numofouters% = Int(numouters!)

End Sub

Sub DischargeEditors(X%)
'12Oct99 AE Added stub
End Sub

Sub displayspecialmsg(InWindow, intEditType As Integer, ByVal strDLO As String, ByVal blnPSO As Boolean)
Dim strSup As String       '26Aug05 TH Added various things (#82103)
Dim strCaption As String   '    "

'!!** this was not intended to allow editing
'!!   Well that may be as there is a corresponding editspecialmsg, yet this
'     sub is not invoked in anything other than edit mode it seems.
'     And editspecialmsg only invoked via supplementary order.

   Select Case intEditType
   Case 1:
   'strCaption = Iff(Trim$(strDLO) <> "", "Authorise Direct Location Order", "Authorise Order") '13Jun12 TH DLO Added
   '23Nov12 TH PSO replaced above
   If blnPSO Then
      strCaption = "Authorise Patient Specific Order"
   ElseIf Trim$(strDLO) <> "" Then
      strCaption = "Authorise Direct Location Order"
   Else
      strCaption = "Authorise Order"
   End If
   
   Case 9: strCaption = "Authorise Credit Order"
   Case Else
      strCaption = "Authorise"
   End Select

   If InWindow Then
      'popmessagecr "Authorise Order", "  " + specialmsg$
      popmessagecr strCaption, "  " + specialmsg$
   Else
      setinput 0, k
      'k.Max = 50  '30Apr05 TH Altered
      k.Max = 200  '   "
      specialmsg$ = ""   '22Jan99 TH Reinitialise message on order
      strSup = Trim$(sup.name) & " (" & Trim$(sup.Code) & ")"  '26Aug05 TH Added
      replace strSup, "&", Chr(160), 0                         '    "
      replace strSup, Chr(160), "&&", 0                        '    "
      
      '13Jun12 TH DLO Added
      If (Trim$(strDLO) <> "") Then
         strSup = strSup & " - DLO for ward " & Trim$(strDLO)
      End If
      
      'inputwin "Authorise Order", "Enter special instructions for " & strSup, specialmsg$, k
      InputWin strCaption, "Enter special instructions for " & strSup, specialmsg$, k
   End If

End Sub
Sub CaptureAdditionalOrderMsg()
'11Oct10 TH UMMC PRF Mods added (F0094388/RCN545)

Dim strSup As String
Dim strMsg As String
Dim strAdditionalOrderMsg As String
Dim intLength As Integer
Dim intWrap As Integer
Dim intloop As Integer
   
   
      strMsg = TxtD(dispdata$ & "\Winord.ini", "Ordering", "Enter additional instructions for ", "AdditionalInstructionsMsg", 0)
      intLength = Val(TxtD(dispdata$ & "\Winord.ini", "Ordering", "100", "AdditionalInstructionsLength", 0))
      intWrap = Val(TxtD(dispdata$ & "\Winord.ini", "Ordering", "50", "AdditionalInstructionsWrap", 0))
      setinput 0, k
      k.Max = intLength
      strSup = Trim$(sup.name) & " (" & Trim$(sup.Code) & ")"
      replace strSup, "&", Chr(160), 0
      replace strSup, Chr(160), "&&", 0
      m_strAdditionalOrderMsg = ""
      InputWin "Authorise Order", strMsg & strSup, strAdditionalOrderMsg, k
      
      If Not k.escd Then
         If Len(strAdditionalOrderMsg) > intWrap Then
            'Add in crlfs as required
            For intloop = intWrap To 1 Step -1
               If InStr(1, Mid$(strAdditionalOrderMsg, intloop, 1), " ", vbBinaryCompare) Then
                  strAdditionalOrderMsg = Left$(strAdditionalOrderMsg, intloop) & crlf & Right$(strAdditionalOrderMsg, Len(strAdditionalOrderMsg) - (intloop))
                  Exit For
               End If
               
            Next
            
         End If
         m_strAdditionalOrderMsg = strAdditionalOrderMsg
      Else
         m_strAdditionalOrderMsg = ""
      End If
   

End Sub

Sub DrugEnquiry()
Dim drug$

   setinput 0, k
   EnterDrug drug$, "Item Enquiry"
   If Not k.escd Then
      ODrugInfo$ = drug$
      DisplayDrugEnquiry drug$, SiteNumber ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
'      Load DrugInfo
'      If Not k.escd Then
'         DrugInfo.Show 1
'      Else
'         Unload DrugInfo
'      End If
   End If

End Sub

Sub DisplayDrugEnquiry(ByVal drugSearchName$, ByVal isiteNumber As Integer)
' Will display the finddrug and then the F4 screen from the full or partial
' drugSearchName$ description used by finddrug.
' Depending on configuration settings (UseOldF4Screens), and if application was called from
' an icw page the method will either display the original vb6, or the new icw desktop, F4 screens
' 23Jun09 XN F0033906
' 15Jul11 XN F0118239 Added robot stock level to F4 screen
   
Dim useOldF4Screens As Boolean         ' If using original vb6 F4 screens or new icw web f4 desktop
Dim DrugPtr&
Dim found%                             ' If drug found
Dim httpAddress As String              ' web url to icw web f4 desktop
Dim httParamaters As String            ' parameters for icw web f4 desktop
Dim httpServerAndWebFolder As String   ' web server used to call this application
Dim strHideCost As String              ' if cost are to be hidden or displayed on the F4 screens
   
   ' Determine if we are displaying original F4 screens, or the new web ones
   useOldF4Screens = TrueFalse(TxtD$(dispdata$ & "\siteinfo.ini", "", "0", "UseOldF4Screens", False))
   
   ' Get web server and directory used to call this application
   httpServerAndWebFolder = ParseCommandURLServerAndWebFolder(Command$)
   
   ' if server or directory not present then can only use old F4 screens
   If (httpServerAndWebFolder = Empty) Then
      useOldF4Screens = True
   End If
   
   ' Now display the find drug, and F4 screens
   If useOldF4Screens Then
      ' Display the original vb6 F4 screens
      ODrugInfo$ = drugSearchName$
      Load DrugInfo
      If Not k.escd Then
         DrugInfo.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      Else
         Unload DrugInfo
      End If
   Else
      ' display the find drug form
      findrdrug drugSearchName$, 1, d, DrugPtr&, found, 2, False, False
      
      If found Then
         Dim webForm As New frmWebClient
         
         ' Determine if costs are to be hidden
         If (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then
            strHideCost = "Yes"
         Else
            strHideCost = "No"
         End If

         ' Generate the address for the icw F4 screens desktop
         httpAddress = httpServerAndWebFolder + "/application/StoresDrugInfoView/ICW_StoresDrugInfoView.aspx"
         httParamaters = "SessionID=" & Format$(g_SessionID) & _
                         "&AscribeSiteNumber=" & Format$(isiteNumber) & _
                         "&NSVCode=" & d.SisCode & _
                         "&HideCost=" & strHideCost
         
         ' Start of F0118239 XN 26Jul11
         ' If drug location is robot (and showing robot items on F4 screen), then pass in robot type to web page
         ' A call pack proc is setup for DisplayDrugEnquiryKeyPress, so if user presses F4 key on the web page
         ' then method DisplayDrugEnquiryKeyPress (below) is called that will do a stock enquiry on the db
         Dim strMachineType As String
         If TrueFalse(TxtD(dispdata$ & "\mechdisp.ini", "Common", "N", "ShowPacksOnF4Screen", 0)) Then
            If LocationForMechDisp(d.loccode, strMachineType) Then
                If (strMachineType <> "<UNKNOWN>") Then
                    httParamaters = httParamaters & "&Robot=" & strMachineType
                    webForm.SetKeyPessCallBackProc AddressOf DisplayDrugEnquiryKeyPress
                End If
            End If
         End If
         ' End of F0118239 XN 26Jul11
                      
         ' Display the icw F4 screens desktop
         webForm.Navigate httpAddress + "?" + httParamaters
         webForm.Caption = "Stores info"
         Load webForm
         webForm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         Unload webForm
      ElseIf Not k.escd Then
         ' Drug could not be found so display error message
         popmessagecr "!Item Enquiry", drugSearchName$ & " Not Found"
         k.escd = True
      End If
   End If
End Sub

' F0118239 XN 26Jul11
' Called when F4 screen is press on the ICW_StoresDrugInfoView.aspx page
' Will do a robot stock enquiry (results will be sent to the webForm, and displaued on popup message box)
Private Sub DisplayDrugEnquiryKeyPress(ByVal webForm As Object, ByVal lngKeyPress As Long, ByVal nUnused3 As Long, ByVal nUnused4 As Long)
   If lngKeyPress = KEY_F4 Then    ' F4 Key
      Dim strMachine As String
      Dim strStock As String
      Dim strMsg As String
      Dim NumItems As Single
      Dim strMessage As String

      ' Do robot enquiry
      If MechDispEnquiry(d, strMachine, strStock, strMessage) Then

         ' format the stock information (and send to web page)
         If Len(strStock) And (Val(d.convfact) = 1) Then
            strStock = strStock & " " & Trim$(d.PrintformV)
         Else
            strStock = strStock & "  pack"
         End If
         webForm.CallJavaScript "SetRobotStockLevel('" + strStock + "')"
         
         ' Build rest of popup message
         strMsg = strMachine & " stock level" & crlf & crlf & strStock
         
         If Len(strStock) And (Val(d.convfact) > 1) Then
            NumItems = Val(strStock) * Val(d.convfact)
            strMsg = strMsg & crlf & Format$(NumItems) & " " & Trim$(d.PrintformV)
         End If
         
         If Len(strMessage) Then strMsg = strMsg & crlf & strMessage & crlf
      Else
         ' Failed to got stock info so generate error
         If strMachine = "<UNKNOWN>" Then
            strMsg = "Dispensing machine not specified for this item"
         Else
            strMsg = strMachine & " not available" & crlf & crlf & strMessage    'Shows 'Swisslog' or 'Rowa' if it should have linked but could not
         End If
      End If

      ' Display popup message
      popmessagecr "#", strMsg
   End If
End Sub
' End of F0118239 XN 26Jul11

' Extracts the web server, and root folder of the web site from
' the a command line string. The url shoud be under the /urltoken= switch
' So /urltoken=http://localhost/ICW/application/somefolder/somepage.aspx
' would return http://localhost/ICW
' If the url can't be passed correctly the method will return an empty string
' 23Jun09 XN F0033906
' 08Aug16 XN 159843 Moved to CoreLib.bas
'Private Function ParseCommandURLServerAndWebFolder(ByVal strCommand As String) As String
'   Dim strTemp As String
'   Dim posn As String
'
'   posn = InStr(1, strCommand, "/urltoken=", vbTextCompare)     ' /urltoken=http://localhost/ICW/application/somefolder/somepage.aspx /MoreArgs
'   If posn Then strTemp = Mid$(strCommand, posn + 10)           ' http://localhost/ICW/application/somefolder/somepage.aspx /MoreArgs
'
'   posn = InStr(strTemp, " /")                                  ' Stop before next argument
'   If posn > 1 Then strTemp = RTrim$(Left$(strTemp, posn - 1))  ' http://localhost/ICW/application/somefolder/somepage.aspx
'
'   posn = InStr(1, strTemp, "//", vbTextCompare)                          ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=6
'
'   If posn > 1 Then posn = InStr(posn + 2, strTemp, "/", vbTextCompare)   ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=17
'
'   If posn > 1 Then posn = InStr(posn + 1, strTemp, "/", vbTextCompare)   ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=21
'
'   If posn > 1 Then strTemp = Left$(strTemp, posn - 1)                    ' http://localhost/ICW
'
'   If posn > 1 Then
'      ParseCommandURLServerAndWebFolder = strTemp
'   End If
'End Function

Sub editspecialmsg(Caption$)
Dim ans2$

   ans2$ = specialmsg$
   k.helpnum = 0 '!!**
   'k.Max = 76
   k.Max = 200
   
   InputWin Caption$, "Enter details or instructions to be printed on the order;" & cr, ans2$, k
   If Not k.escd Then specialmsg$ = ans2$
   k.escd = False
   
End Sub
Sub setspecialmsg(ByVal strMsg As String)
'17Nov05 TH Written
   specialmsg$ = strMsg
End Sub
Public Function getspecialmsg() As String
'17Nov05 TH Written
   getspecialmsg = specialmsg$
End Function

Sub EnterAmend(quantity$, reordersize$, i_strCaption As String)

'05Aug15 TH Stop fractional ordering when fraction not resolvable to 2 dec places (TFS 46785)
'12Aug15 TH Added k.escd set - msg was displaying but still retained and saved the qty on issue unit check (TFS 126082)

Dim bk As Long, fr As Long
Dim X%
Dim IssueQty$, StoresConvFact$
Dim desc$, ans$, tempans$
Dim Qty!, PackSize!
Dim negative%
Dim qtyordered$
Dim strPSOName As String '30Aug12 TH PSO
Dim StrEnteredqty As String

   Qty! = Val(quantity$)
   negative = (Sgn(Qty!) = -1)
   PackSize! = Val(reordersize$)
   FrmIssue.Height = 2100
   FrmIssue.cmdOK.Top = 1485
   FrmIssue.cmdCancel.Top = 1485
   FrmIssue.Frmlabels.Visible = False
   FrmIssue.TxtLabels = 0
   desc$ = Trim$(d.DrugDescription)   ' desc$ = Trim$(GetStoresDescription())  XN 4Jun15 98073 New local stores description
   plingparse desc$, "!"

   Do
      getdrug d, 0, 0, False
      strPSOName = ""
      If getPSO() Then
         Heap 11, gPRNheapID, "psoNameDOB", strPSOName, 0
         i_strCaption = "Enter/Amend Patient Specific Order for " & strPSOName
      End If
      FrmIssue.LblTopLine.Caption = desc$ & crlf$ & " (Stock level = " & FormatVal$(d.stocklvl, 2, 6) & " " & d.PrintformV & ")" '26Sep00 TH
      
      If Val(d.reorderpcksize) > 0 Then
         FrmIssue.LblTopLine.Caption = FrmIssue.LblTopLine.Caption & crlf & " (Re-order outer size = " & Format$(d.reorderpcksize) & ")"
      End If
      
      FrmIssue.LblTopLine.Height = 720                                                                            '     "
      FrmIssue.LblPrintForm.Caption = LCase$(d.PrintformV)

      If PackSize! > 0 Then
         StoresConvFact$ = Trim$(Format$(PackSize!))
      Else
         StoresConvFact$ = Trim$(d.convfact)
      End If
      IssueQty$ = Trim$(Str$(Abs(Qty!) / Val(StoresConvFact$)))
      If InStr(IssueQty$, ".") > 0 Then IssueQty$ = Format$(IssueQty$, "0.###") '09Jan07 TH Added extra format digits for fractions
      ans$ = IssueQty$ & " x " & StoresConvFact$
      FrmIssue.TxtIssue.text = ans$
      FrmIssue.LblDrug.Alignment = 1
      FrmIssue.LblDrug.Caption = "Quantity = "
      
      Do
         fr = Black                                'bk = QBColor(15): fr = QBColor(0)
         FrmIssue.FraIssue.ForeColor = fr
         FrmIssue.LblTopLine.ForeColor = fr
         FrmIssue.LblDrug.ForeColor = fr
         FrmIssue.LblPrintForm.ForeColor = fr
         FrmIssue.LblTopLine.BackColor = bk
         FrmIssue.LblDrug.BackColor = bk
         FrmIssue.LblPrintForm.BackColor = bk
         tempans$ = FrmIssue.TxtIssue.text
         
         k.timd = False
         FrmIssue.TxtIssue.text = tempans$
         FrmIssue.TxtIssue.SelStart = 0
         FrmIssue.TxtIssue.SelLength = Len(IssueQty$)
         If Len(i_strCaption) > 0 Then
            ' set caption
            FrmIssue.Caption = i_strCaption
         Else
            ' do as before
            FrmIssue.Caption = "Enter/Amend"
         End If
         gTimedOut = False
         FrmIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         
         ans$ = FrmIssue.TxtIssue.text
   
         If Trim$(ans$) = "" Then k.escd = True

         If gTimedOut Then k.escd = True
         
         StrEnteredqty = ans$ '05Aug15 TH
         
         If Not k.escd Then ParseIssueQty ans$
         If Val(d.reorderpcksize) > 1 Then
            If Edittype = 1 And dp!((Val(ans$) / Val(d.convfact)) Mod Val(d.reorderpcksize)) <> 0 Then                      '05Mar98 ASC
               qtyordered$ = ans$
               ans$ = "N"                                                                                           '      "
               Confirm "Item normally supplied in outers", "order part of an outer of " & d.reorderpcksize, ans$, k '      "
               If ans$ = "N" Then
                  ans$ = ""
               Else
                  ans$ = qtyordered$
               End If
            End If                                                                                                  '      "
         End If
         
         '05Aug15 TH Added section (TFS 46785)
         If Edittype = 1 And Trim$(ans$) <> "" And (Not k.escd) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "StopUncontrolledFractionalOrdering", 0)) Then
            If (Val(Format((Val(ans$) / Val(d.convfact)), "#.##")) <> Val(Format((Val(ans$) / Val(d.convfact)), "#.#######"))) Then
               'Here we have something that cant be expressed as a pack to 2 dec places. We must disallow this posibility
               popmessagecr "", "Ordering " & Format((Val(ans$) / Val(d.convfact)), "#.#######") & " pack(s) is not allowed as this will lead to balancing errors. Please check and alter order quantity."
               k.escd = True
            ElseIf Val(Format(ans$, "#")) <> Val(ans$) Then
               popmessagecr "", "Ordering fractional issue units is not allowed as this will lead to balancing errors. Please check and alter order quantity."
               k.escd = True '12Aug15 TH Added - msg was displaying but still retaine and saved the qty (TFS 126082)
            End If
         ElseIf Edittype = 1 And ans$ = "" And (Val(Format(StrEnteredqty, "#")) <> Val(StrEnteredqty)) Then
               popmessagecr "", "Ordering fractional issue units is not allowed as this will lead to balancing errors. Please check and alter order quantity."
         End If
         '05Aug15 TH ----
         
      Loop Until (Trim$(ans$) <> "") Or k.escd

      If gTimedOut Then
         'For x = 1 To 100
         '   SOUND 200 + x, 2
         'Next
         'SOUND 200, 10
         'SOUND 300, 10
         'SOUND 400, 10
         'SOUND 100, 30
         Beep
         popmessagecr "Warning", "Issue needs confirming"
      End If

   Loop Until Not gTimedOut
             
   If k.escd Then
      quantity$ = ""
   Else
      quantity$ = ans$
      If negative Then quantity$ = "-" & quantity$
   End If
   
   Unload FrmIssue
   

End Sub

Sub FileViewer()
Static fil$, lin$, Filter$

Dim pointer&, Item&
Dim ans$
Dim edtype%, OK%

   pointer& = 0
   
   frmoptionset -1, "File Viewer"
   frmoptionset 1, "Default"
   frmoptionset 1, "Orders"
   frmoptionset 1, "Reconciliation"
   frmoptionset 1, "Requisitions"

   frmoptionshow "1", fil$               'Preset 1st button 'On'
      
   k.escd = (frmOption.Tag = "")
   frmoptionset 0, ""  'Unload Form
   If Not k.escd Then
      Select Case Val(fil$)
         Case 1
            'ord = order
         Case 2 To 4
            edtype = Val(fil$) + 1
            getnumofords edtype, pointer&, False
            k.Max = 5
            k.nums = True
            If Val(lin$) = 0 Then lin$ = "2"
            InputWin "File Viewer", "Max Items =" + Str$(pointer&) + "  Min = 2" + Chr$(13) + " Enter first item   ", lin$, k
            If Not k.escd Then
               Select Case Val(lin$)
                  Case Is < 2, Is > pointer&
                     popmessagecr "", "Invalid choice"
                     k.escd = True
                  Case Else
                     Item& = Val(lin$)
               End Select
            End If

            If Not k.escd Then
               k.Max = 10
               ans$ = Filter$
               InputWin "File Viewer", "Enter filter", ans$, k
               If Not k.escd Then Filter$ = UCase$(ans$)
            End If
         End Select
   End If
   
   If Not k.escd Then
      Do
         OK = True
         If fil$ >= "2" Then
            getorder ord, Item&, edtype, False
            LSet r = ord
            If InStr(UCase$(RTrim$(r.record)) + Str$(ord.pickno), Filter$) = 0 Then OK = False
         End If
         If OK Then poporder ord, "File Viewer " + fil$ + "," + Str$(Item&)
         Item& = Item& + 1
         If Item& > pointer& Then Exit Do
      Loop Until k.escd
   End If

End Sub

Sub findnumberofpages(picklist() As String, numforpicking, totpages)
'Dummy run through to find no of pages
'-------------------------------------
'26Mar13 TH Reworked to handle DLO splits
'24Jul15 XN Picking Tickets Page Number Error 119158

Dim lineno%, pageno%, lined%, X%
Dim blnNewPage As Boolean
Dim blnDLOLined As Boolean

   lineno = 0
   pageno = 1
   lined = False
   For X = 1 To numforpicking
      lineno = lineno + 1
      
      '26Mar13 TH Removed section
      'If lineno > picknumoflines Then
      '   lineno = 1
      '   pageno = pageno + 1
      'End If
      
      'If Not lined And Left$(picklist(x), 1) = "~" Then
      '26Mar13 TH Replaced above line
      blnNewPage = (Mid$(picklist(X), Iff((Edittype% = 5), 2, 1), 1) = "~" And lined = False)
      If Not blnNewPage And Edittype% = 5 Then
         blnNewPage = Left$(picklist(X), 1) = "!" And blnDLOLined = False
         If blnNewPage Then lined = False 'reset for possible DLO non stocked
      End If
      If lineno > picknumoflines Or blnNewPage Then '30May12 TH DLO
      '----------
      
         If lineno > 1 Then
            pageno = pageno + 1
         End If
         lineno = 1
         'lined = True
         '26Mar13 TH Replaced above line
         If Edittype% = 5 Then                                 '30May12 TH DLO
            If Left$(picklist(X), 1) = "!" Then
               blnDLOLined = True
               If Mid$(picklist(X), 2, 1) = "~" Then lined = True '26Mar13 TH Added
            Else
               If Mid$(picklist(X), 2, 1) = "~" Then lined = True       ' 24Jul15 XN Picking Tickets Page Number Error 119158
            End If
         Else
            If Left$(picklist(X), 1) = "~" Then lined = True ' 24Jul15 XN Picking Tickets Page Number Error 119158
         End If
         '-----------
      End If
   Next
   totpages = pageno

End Sub

Sub furtherinfo(ByVal Edittype As Integer, ByRef L_ord As orderstruct)
'06Jul11 CKJ changed param orderrecnum& to the order structure & removed drug$
'            avoids another trip to the DB as it's already in scope
'            Also changed to use a local drug & supplier structures as well

Dim F&, found%, valid%
Dim pform$, title$, msg$, dat$, LineCost$, expdate$, ans$
Dim dailyuse!, daysleft!
Dim drug As String
Dim L_d As DrugParameters
Dim L_sup As supplierstruct

   findrdrug L_ord.Code, 1, L_d, F&, found%, 2, False, False
   
   If found Then
      'getorder L_ord, orderrecnum&, edittype, False '06Jul11 CKJ Now passed in from outside
      getdrugsup L_d, 0, F, False, L_ord.supcode
      
      drug$ = Trim$(d.DrugDescription)  ' drug$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
      plingparse drug$, "!"
      pform$ = LCase$(L_d.PrintformV)
      title$ = "#Further information for " & L_d.SisCode
      msg$ = " " & drug$ & vbCr & vbCr
      If Len(RTrim$(L_d.tradename)) Then
         msg$ = msg$ & " Trade name" & vbTab & RTrim$(L_d.tradename) & vbCr
      End If
      If Edittype <> 1 Then
         If Edittype < 5 Then
            msg$ = msg$ & " Order number" & vbTab & L_ord.num & vbCr
            msg$ = msg$ & " Order date"
         Else
            msg$ = msg$ & " Picking ticket No." & vbTab & Trim$(Str$(L_ord.pickno) & vbCr)
            msg$ = msg$ & " Requisition number" & vbTab & Trim$(L_ord.num) & vbCr
            msg$ = msg$ & " Requisition date"
         End If
         parsedate L_ord.orddate, dat$, "1-", valid
         msg$ = msg$ & vbTab & dat$ & vbCr
         msg$ = msg$ & " Quantity ordered" & vbTab & L_ord.qtyordered & vbCr
         msg$ = msg$ & " Qty. outstanding" & vbTab & L_ord.outstanding & vbCr
      End If
    
      LineCost$ = Str$(dp!(Val(L_d.cost) / 100))
      poundsandpence LineCost$, False
      msg$ = msg$ & " Issue price" & vbTab
      msg$ = msg$ & money(5) & Trim$(LineCost$) & " per " & Trim$(L_d.convfact) & " " & pform$ & vbCr
      If Edittype = 3 Or Edittype = 4 Then
          LineCost$ = Str$(dp!(Val(L_ord.cost) / 100))
          poundsandpence LineCost$, False
          msg$ = msg$ & " Purchase price" & vbTab
          msg$ = msg$ & money(5) & Trim$(LineCost$) & " per " & Trim$(L_d.convfact) & " " & pform$ & vbCr
      End If
      msg$ = msg$ & " Lead time" & vbTab & FormatVal$(L_d.LeadTime, 1, 3) & " days" & vbCr
      'out of stock = today + ((stock level - outstanding) / rate of usage)
      dailyuse! = Val(L_d.anuse) / 365.25
      If dailyuse! Then
         daysleft! = (Val(L_d.stocklvl) - L_d.outstanding) / dailyuse! '!! does it need convfact?
         If daysleft! >= 0 And Abs(daysleft!) < 32767 Then
            msg$ = msg$ & " Est. out of stock"
            today td
            dt.mint = daysleft! * mind
            AddExpiry td, dt
            DateToString td, expdate$
            msg$ = msg$ & vbTab & expdate$ & " " & vbCr
         End If
      End If
    
      clearsup L_sup
      getsupplier L_d.supcode, 0, 0, L_sup
      msg$ = msg$ & " Primary supplier" & vbTab & L_sup.name & "  " & L_d.supcode & vbCr
      clearsup L_sup
      getsupplier L_ord.supcode, 0, 0, L_sup
      If Edittype = 5 Or Edittype = 6 Then
         msg$ = msg$ & " Requisitioned by"
      Else
         msg$ = msg$ & " Current supplier"
      End If
      msg$ = msg$ & vbTab & L_sup.name & "  " & L_ord.supcode
      
      '05Jul12 TH Added Extra DLO Info
      If Edittype = 3 And L_ord.DLO Then
         msg$ = msg$ & vbCr & vbCr & " Direct Location Order for " & L_ord.DLOWard
      End If
      
      If Edittype = 5 Or Edittype = 6 Then
         msg$ = msg$ & vbCr & " Created by" & vbTab & L_ord.CreatedUser
         '06Jul12 TH Added
         If Edittype = 6 And L_ord.DLO Then
            msg$ = msg$ & vbCr & vbCr & " This is a DLO (direct location order) requisition"
         End If
      End If
      
      
      setinput 0, k
      k.validchars = "+" & vbCr                      '//// not supported
      popmessagecr title$, msg$
      If ans$ = "+" Then poporder L_ord, L_d.SisCode         '//// not supported
      k.escd = False
   Else
      popmessagecr "#", "Item not found : " & ord.Code & " " & drug$
   End If

End Sub

Sub getnumofords(Edittype, pointer&, incr%)
'--------------------Returns number of orders/ requistions file---------------
'
'   if incr% then increment if incr%= 1 then decrement if incr%=0 then
'   read number only. if incr%=2 then write number
' 2Aug91 ASC reconcil file added
'03May98 CKJ Y2K changes applied to new filenames as follows;
'             ORDER.ASC    => ORDER.V8
'             RECONCIL.ASC => RECONCIL.V8
'             REQUIS.ASC   => REQUIS.V8
'-----------------------------------------------------------------------------

   Select Case Edittype
      Case 0:          popmessagecr "WARNING", "Pointer edit type not defined please inform system manager"
      Case 1, 2, 3, 9: GetPointerSQL dispdata$ & "\order.v8", pointer&, incr%
      Case 4:          GetPointerSQL dispdata$ & "\reconcil.v8", pointer&, incr%
      Case Else:       GetPointerSQL dispdata$ & "\requis.v8", pointer&, incr%
   End Select

End Sub

Function getorderchan%()

   getorderchan% = ordchan%

End Function

Sub getorderno(Edittype, orderno As Long, incr%)
'ASC 27Mar91
'ASC 10Apr93 Stop reading locked record but return last orderno
'            Gets order number, requisition and return number
'02Dec98 TH  New delno.dat file to record reprint numbers for delivery notes accessed with edittype 25

'incr% = 0 READ
'incr% = -1 INCREMENT
'incr% = 1 DECREMENT
'incr% = 2 WRITE
'incr% = 3 LOCK
'incr% = 4 UNLOCK

Static lastincr%, lastorderno As Long

Dim temp$, pointer&
          
   If incr = 0 And lastincr = 3 Then
      orderno = lastorderno
      Exit Sub
   End If

   Select Case Edittype
      Case 1, 2, 3
         temp$ = "\orderno"
      Case 5, 6, 7, 8
         temp$ = "\reqno"
      Case 9
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "UseOrderNosForReturns", 0)) Then '12Aug05 TH Added (#82105)
            temp$ = "\orderno"
         Else
            temp$ = "\retno"
         End If
      Case -1  'Adjustments
         temp$ = "\adjust"
      Case 25  'del notes
         temp$ = "\delno"
      Case 4
         temp$ = "\dispnote"
   End Select

   pointer& = orderno
   GetPointerSQL dispdata$ + temp$ + ".dat", pointer&, incr%

   If pointer& > 2147483647 And incr < 3 Then 'SQL Upper limit of long, I guess you never know !
      pointer& = 1
      GetPointerSQL dispdata$ + temp$ + ".dat", pointer&, 2
   End If
   orderno = pointer&
   lastorderno = orderno
   lastincr = incr

End Sub

' XN 4Jun15 98073 Removed  as now using new local stores description
'Function GetStoresDescription$()

   'If trimz$(d.storesdescription) = "" Then
   '    GetStoresDescription$ = d.Description
   'Else
   '    GetStoresDescription$ = d.storesdescription
   'End If
   'GetStoresDescription = d.Description
    
'End Function
'Function RSGetStoresDescription(ByVal rsItem As ADODB.Recordset) As String
'
'   If trimz$(GetField(rsItem!storesdescription)) = "" Then
'      RSGetStoresDescription = GetField(rsItem!Description)
'   Else
'      RSGetStoresDescription = GetField(rsItem!storesdescription)
'   End If
'       RSGetStoresDescription = GetField(rsItem!Description)
    
'End Function

Sub entersite(Edittype, Display$, Options%, ByVal blnPSO As Boolean)
'--------------Enter site code------------
'21Mar93 CKJ Removed k from params
'17Dec96 EAC added Options% to subroutine header
'              Options = 0 - don't add any text to list of suppliers
'              Options = 1 - add 'All' to start of list of suppliers
'              Options = 2 - add 'New' to start of list of suppliers
'            added Display% to subroutine header
'              Display = 0 - display all suppliers
'              Display = 1 - display suppliers only
'              Display = 2 - display wards only
'01Feb16 TH Changed input to asksupplier for PSO filtering (TFS 138644)

Dim temp$, temp1$, SiteNum$, ans$
Dim allsites%, done%
Dim escd%
Dim lngFoundSup As Long


   Select Case Edittype
      Case 1 To 4, 9
         temp$ = "Supplier"
         temp1$ = temp$
         allsites = True
         k.helpnum = 405
      Case Is > 4
         temp$ = "Requisitioner"
         temp1$ = "Site"
         allsites = True
         k.helpnum = 410
   End Select
   LstBoxFrm.Caption = "Enter " + temp$ + "'s site code"
   SiteNum$ = ""
   setinput 0, k
   k.escd = False
   k.helpnum = 0
   'asksupplier SiteNum$, Options, Display, "Enter Supplier Code", False, sup, blnPSO '15Nov12 TH Added PSO param
   'asksupplier SiteNum$, Options, Display, "Enter " & IIf(blnPSO, "Patient Specific", "") & " Supplier Code", False, sup, blnPSO '15Nov12 TH Added PSO Captioning
   asksupplier SiteNum$, Options, Display, "Enter " & IIf(blnPSO, "Patient Specific", "") & " Supplier Code", False, sup, IIf(blnPSO, PSO, All) '01Feb16 TH Changed input (TFS 138644)

   If Not k.escd Then
      SiteNum$ = Trim$(UCase$(SiteNum$))
      getsupplier SiteNum$, 0, lngFoundSup, sup
      If SiteNum$ = "" Then SiteNum$ = "A"
      
      If lngFoundSup = 0 And SiteNum$ <> "A" Then
          ans$ = "N"
          k.helpnum = 0
          Confirm "!n!bSupplier/Site Code '" + SiteNum$ + "' not found", "use code '" + SiteNum$ + "'", ans$, k
          If ans$ = "N" Then k.escd = True
      End If
      If Not k.escd Then
         If sup.suppliertype <> "L" Then
            osite$ = SiteNum$
         Else
            osite$ = Trim$(sup.wardcode)
            If osite$ = "" Then
               Do
                  askward "Cost Centre Required", osite$, escd%, "W"
                  If Not escd% Then
                     getsupplier osite$, 0, 0, sup
                     If sup.suppliertype <> "W" Then
                        popmessagecr "#", osite$ & " is not a set up as a ward" & cr & "You will need to select a ward."
                        osite$ = ""
                     End If
                  Else
                     k.escd = True
                  End If
               Loop Until (sup.suppliertype = "W" And Trim$(osite$) <> "") Or escd%
            End If
         End If
      End If
             
      If Edittype = 5 And SiteNum$ <> "A" And Not k.escd Then
         done = False
         ordernum$ = ""
         setinput 0, k
         'k.Max = 4
         'k.Max = 10
         k.Max = 9 '06Mar06 TH Reduced capacity
         k.min = 0
         SiteNum$ = ""
         k.helpnum = 420
         InputWin "Order Number", "Enter requisition number [Return] to view all", ordernum$, k
         If ordernum$ = "" Then ordernum$ = "A"
         'TH Added
         If Trim$(osite$) = "A" Then
            If sup.name <> "" Then scrnmsg$ = "(ALL)"
         Else
            If sup.name <> "" Then scrnmsg$ = osite$ & " (" & Trim$(sup.name) & ")"
         End If
         replace scrnmsg$, "&", Chr(30), Len(scrnmsg$)
         replace scrnmsg$, Chr(30), "&&", Len(scrnmsg$)
         '-------
          done = True
      ElseIf Not k.escd Then
         ordernum$ = "A"
         If Edittype = 5 Then
             ans$ = "N"
             Confirm "?Requisitions - To follows", "display 'To follow' items", ans$, k
             If ans$ = "N" Then ordernum$ = "F"
         End If
         If Edittype = 1 Or Edittype = 9 Then    'TH Added Reqs (5)
            If Trim$(osite$) = "A" Then
               If sup.name <> "" Then scrnmsg$ = "(ALL)"
            Else
               If sup.name <> "" Then scrnmsg$ = osite$ & " (" & Trim$(sup.name) & ")"
            End If
         End If
      End If
   End If

End Sub

Sub KillReprint()

Dim orderno%, printpath$

   getprintpath printpath$, 0
   On Error GoTo cantdelete
   Kill dispdata$ & printpath$ & "\" & Format$(lngReprintno) & ".rtf"
   On Error GoTo 0
Exit Sub

cantdelete:
   WriteLog dispdata$ & "\killord.log", SiteNumber%, "---", "Can not delete reprint rtf file after cancellation" & dispdata$ & printpath$ & "\" & dispdata$ & printpath$ & "\" & Format$(orderno%) & ".rtf" & "error " & Err
Resume Next

End Sub

Sub LookupDrug(NSVCode$, d As DrugParameters, foundPtr As Long)

   BlankWProduct d
   d.SisCode = NSVCode$
   foundPtr& = 0
   getdrug d, 0, foundPtr&, False
   
              
End Sub

Sub nopass()
   
   popmessagecr "!NO ACCESS", "Password level insufficient"

End Sub

Sub ParseRequisition(filno, dataline$, Edittype, picklist$, runningvat!, totcost!, sngRunningVATIncOnCost As Single, sngTotCostIncOncost As Single)

Dim foundPtr&, FoundSup%, returnitem%
Dim sendqty!, Lcost!
Dim LineCost$, send$, tf$, temp$, location$, orderno$, pickno$
Dim startpos&, openbracepos&, closebracepos&
Dim InStoresPacks%, testqty!
Dim tof!, tof1!, tof2!
Dim NotEnoughStock%
Dim sngCostIncOnCost As Single
Dim lngReturn As Long
Dim lngFoundSup As Long
Dim strRobotFlag As String
Dim intSuccess As Integer
Dim QuantityToPick As String
Dim QuantityStocked As String
Dim QuantityIssued As String
Dim strMessage As String
Dim blnOrderInPacks As Integer
Dim sngQtyInPacks As Single
Dim strMessageText As String                 '16Jun05 CKJ added
Dim strDeptPacksRemaining As String          '30Jun05 CKJ added
Dim ShelfStockRemaining As Single            '01Jul05 CKJ added
Dim RobotPrint As Integer

   getorder ord, Val(Right$(picklist$, 10)), Edittype, (Edittype = 5) '<--LOCK if type 5 only
   BlankWProduct d
   d.SisCode = ord.Code
   getdrug d, 0, foundPtr&, False
   If foundPtr& = 0 Then
      popmessagecr "Error", d.SisCode & " : Item Not Found in drug file."
      k.escd = True
      Exit Sub
   End If
   strMessageText = ""
    
   getsupplier ord.supcode, 0, lngFoundSup, sup

   Select Case Edittype
      Case 5                                       'Picking Ticket
         LineCost$ = ""
         NotEnoughStock = False

         '31Dec07 CKJ Ported Block from V8.7
         '22Jun04 CKJ Added block                                                   '!!** need to check that we have stock before asking robot??
         strRobotFlag = " "                                                         'Manual pick until proven otherwise
         strDeptPacksRemaining = ""                                                 'Will hold extra info for the to-follow field
         
         If LocationForMechDisp(d.loccode, "") Then                                 'Robot pick
               blnOrderInPacks = (sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks)   'True if ord.outstanding is in units of packs
               If blnOrderInPacks Then                                                                'ord.outstanding is in packs
                     sngQtyInPacks = Val(ord.outstanding)                                             'use it as given
                  Else                                                                                'ord.outstanding is in tablets (or whatever)
                     sngQtyInPacks = Val(ord.outstanding) / Val(d.convfact)                           'convert to packs (inc fractions) !!** rounding ??
                  End If
               sngQtyInPacks = dp!(sngQtyInPacks)
   
               If Abs(sngQtyInPacks - Int(sngQtyInPacks)) > 0.0001 Then             'is it a whole pack
                     strRobotFlag = "P"                                             'no;  Part pack, manual pick
                  Else                                                              'yes; whole pack (near enough)
                     'attempt robot stock issue
                     QuantityToPick = Format$(sngQtyInPacks, "0")
                     
                     '16Oct06 CKJ added block
                     RobotPrint = False
                     Select Case SpecificStockLabelLayout(d.SisCode, Trim$(sup.Code), "")             '0 absent, 1 default, 2 ward, 3 drug, 4 ward+drug specific layout
                        Case 0
                           popmessagecr "!", "Label layout 'Stklabel.rtf' is not installed" & cr & "Not possible to print stock labels"
                        Case Is > Val(TxtD(dispdata$ & "\winord.ini", "defaults", "5", "PrintPickTicketLabelsMinLayout", 0))
                           RobotPrint = True                                        'request printing if specific layout found
                        End Select

                     If MechDispIssue(d, False, QuantityToPick, QuantityIssued, QuantityStocked, strMessageText, RobotPrint) Then      '16Jun05 CKJ added strMessageText  '01Oct06 CKJ Added RobotPrint
                           Select Case Val(QuantityIssued)                          'none/some/enough in robot? (measured in packs)
                              Case Is <= 0                                          'None in robot or prefer using shelf, manual pick
                                 strRobotFlag = "M"                                 'sendqty! will be set in the subsequent manual section
                                 
                                 '01Jul05 CKJ added block
                                 ShelfStockRemaining = Int(dp!(Val(d.stocklvl) / Val(d.convfact))) - Val(QuantityStocked)  'Total non-robot stock in the dept, ignoring fractions of packs
                                 If Val(QuantityToPick) > ShelfStockRemaining Then  'not enough shelf stock to cover request
                                       strRobotFlag = "m"                           'manual part pick
                                       NotEnoughStock = True
                                       If blnOrderInPacks Then
                                             sendqty! = ShelfStockRemaining                          'units as whole packs only
                                          Else
                                             sendqty! = ShelfStockRemaining * Val(d.convfact)        'units remain as packs or tabs
                                          End If
                                       strDeptPacksRemaining = "/" & QuantityStocked
                                    Else
                                       'allow the (M)anual section below to handle it
                                    End If
                              
                              Case Is >= sngQtyInPacks                              'Plenty, robot pick
                                 strRobotFlag = "R"
                                 sendqty! = Val(ord.outstanding)                    'units remain as packs or tabs
                              
                              Case Else                                             'Some, robot pick with some to-follow
                                 strRobotFlag = "R"
                                 NotEnoughStock = True
                                 If blnOrderInPacks Then                            'ord.received will be in packs
                                       sendqty! = Val(QuantityIssued)
                                    Else                                            'ord.received will be in tablets (or whatever)
                                       sendqty! = Val(QuantityIssued) * Val(d.convfact)
                                    End If
                                 strDeptPacksRemaining = "/" & Format$(Int(dp!(Val(d.stocklvl) / Val(d.convfact))) - Val(QuantityIssued)) '30Jun05 CKJ added
                              End Select
                           
                           If GetRobotPrintLabelMessageID() > 0 Then                '16oct06 CKJ added block
                              Erase LabelValues
                              ReDim LabelValues!(1)
                              LabelValues!(1) = Val(d.convfact)
                              PrintStockLabelsSQL Val(d.convfact), d.SisCode, Trim$(sup.Code), 1, 0  'One label per full pack from robot, no extras '11Jul11 CKJ changed from PrintStockLabels which was a stub proc
                           End If
                        Else                                                        'could not query robot
                           strRobotFlag = RTrim$("E     " & strMessageText)         'Error, manual pick     '30Jun05 CKJ added message which should print on next line
                           '!!** consider a way out here - abort the process?
                        End If
                     'SetRobotPrintLabelMessageID 0                                  '16oct06 CKJ
                     MechDispClearLabelData              '20May08 CKJ
                  End If
            End If
         
         '22jun04 CKJ rewrote block below to be functionally identical but more comprehensible form
         'sendqty! = 0
         'If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintinPacks Then   '30Dec97 EAC added print in Packs
         '      If ToFollow = 0 Or (Val(ord.outstanding) <= Val(d.stocklvl) / Val(d.convfact)) Or (truefalse(txtd$(dispdata$ & "\patmed.ini", "", "Y", "NoNegIssues", 0)) = False) Then '08Jul02 TH Replaced (#61735)
         '            sendqty! = Val(ord.outstanding)
         '         Else
         '            NotEnoughStock = True                                          '26Jun98 EAC Added
         '            If Val(d.stocklvl) > 0 Then
         '                  sendqty! = Int(dp!(Val(d.stocklvl) / Val(d.convfact)))   '20Mar93 CKJ Changed - to / '23Jun93 CKJ dp
         '               End If
         '         End If
         '   Else
         '      If ToFollow = 0 Or (Val(ord.outstanding) <= Val(d.stocklvl)) Or (truefalse(txtd$(dispdata$ & "\patmed.ini", "", "Y", "NoNegIssues", 0)) = False) Then  '08Jul02 TH Replaced (#61735)
         '            sendqty! = Val(ord.outstanding)
         '         Else
         '            NotEnoughStock = True                                          '26Jun98 EAC Added
         '            If Val(d.stocklvl) > 0 Then
         '                  sendqty! = Int(dp!(Val(d.stocklvl)))                     '20Mar93 CKJ Changed - to / '23Jun93 CKJ dp
         '               End If
         '         End If
         '   End If

         '22jun04 CKJ rewrote block
         If strRobotFlag = "m" Then                                                                   '01Jul05 CKJ added section - manual part pick of a robot item
               InStoresPacks = True
               send$ = Format$(sendqty!, "0")
            ElseIf strRobotFlag = "R" Then                                                            'some or all will be from the robot
               InStoresPacks = True
               send$ = Format$(sendqty!, "0")
            Else                                                                                      'not already requested some from robot - types P M E or <space>
               sendqty! = Val(ord.outstanding)                                                        'default is to use the whole quantity
               If tofollow <> 0 And TrueFalse(TxtD$(dispdata$ & "\patmed.ini", "", "Y", "NoNegIssues", 0)) Then  '08Jul02 TH Replaced (#61735)
                     If Val(d.stocklvl) > 0 Then
                           If sup.suppliertype = "S" Or sup.suppliertype = "E" Or PrintInPacks Then
                                 If Val(ord.outstanding) > Val(d.stocklvl) / Val(d.convfact) Then
                                       NotEnoughStock = True
                                       sendqty! = Int(dp!(Val(d.stocklvl) / Val(d.convfact)))         'sendqty in packs
                                    End If
                              Else
                                 If Val(ord.outstanding) > Val(d.stocklvl) Then
                                       NotEnoughStock = True
                                       sendqty! = Int(dp!(Val(d.stocklvl)))                           'sendqty in tablets
                                    End If
                              End If
                        Else
                           sendqty! = 0                                                               'no stock
                           NotEnoughStock = True   '20Jan05 TH/SAF
                        End If
                  End If

         If sendqty! > 0 Then testqty! = sendqty! Else testqty! = Val(ord.outstanding)
         CheckIfWholeStoresPacks (testqty!), InStoresPacks%, send$
         If sendqty! <= 0 Then send$ = "0"
            End If

         If tofollow <> 0 And NotEnoughStock Then
            If InStoresPacks Then
               tof! = Val(ord.outstanding) - sendqty!
            Else                                                                                         '    "
               tof! = (Val(ord.outstanding) - sendqty!) * Val(d.convfact)
            End If

            If tof! <> 0 Then
               tof1! = dp!(tof!)
               tof2! = CLng(dp!(tof!))
               If Abs((tof2! - tof1!) / tof1!) < 1 / 1000 Then
                  tof! = tof2!
               Else
                  tof! = tof1!
               End If
            End If
            tf$ = "(" & LTrim$(rightjust6(Str$(tof!))) & strDeptPacksRemaining & ")"      '30Jun05 CKJ added strDeptPacksRemaining
         End If
         ord.received = Format$(dp!(sendqty!))           '     "
         lngReturn = PutOrder(ord, Val(Right$(picklist$, 10)), "WRequis")           '<---UNLOCK
   
      Case 7                                       'Delivery Note
         CheckIfWholeStoresPacks Val(ord.received), InStoresPacks%, send$
         If Val(ord.outstanding) > 0 Then
            If InStoresPacks Then
               tf$ = "(" & Format$(Val(ord.outstanding)) & ")"
            Else
               tf$ = "(" & Format$(Val(ord.outstanding) * Val(d.convfact)) & ")"
            End If
         End If
   
      Case 9                                       'Credit Order
         send$ = ""
         If Abs(Val(ord.outstanding)) < 1 Then
            send$ = Format$(Val(ord.outstanding))
         Else
            send$ = Trim$(ord.outstanding)
         End If
      End Select
   
   Select Case Edittype
      Case 5                           'picking tickets
         'location$ = Trim$(Mid$(picklist$, 2, Len(d.loccode)))                                            '21Jun04 CKJ robot indicator is now char 2
         'location$ = Trim$(Mid$(picklist$, 3, Len(d.loccode)))                                             '   "
         location$ = Trim$(Mid$(picklist$, 4, Len(d.loccode))) '30May12 TH DLO
         orderno$ = Trim$(Mid$(picklist$, 2 + Len(d.loccode) + 2, Len(ord.num)))          '27dec07 CKJ should be 3 +  ??
      Case 7                           'delivery notes
         pickno$ = Trim$(Mid$(picklist$, 6 + Len(ord.num), 10))
         location$ = Trim$(Mid$(picklist$, 2, Len(d.loccode)))
         orderno$ = Trim$(Mid$(picklist$, 5, Len(ord.num)))
      Case 9                           'credit orders
         location$ = Trim$(Mid$(picklist$, 2, Len(d.loccode)))
         orderno$ = Trim$(Mid$(picklist$, 2 + Len(d.loccode) + 2, Len(ord.num)))
   End Select


   If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Then
      Lcost! = dp!((1! * Val(ord.cost) * (Val(ord.received) / Val(d.convfact))) / 100)
   Else
      Lcost! = dp!((1! * Val(ord.cost) * Val(ord.received)) / 100)
   End If

   
   runningvat! = runningvat! + (Lcost! * (VAT(Val(d.vatrate)) - 1))
   totcost! = totcost! + Lcost!
   If Sgn(Lcost!) = True Then
      returnitem = True
   Else
      returnitem = False
   End If

   If Val(sup.onCost) > 0 Then
      sngCostIncOnCost = Lcost + (Lcost! * (Val(sup.onCost) / 100))
   Else
      sngCostIncOnCost = Lcost!
   End If
   sngRunningVATIncOnCost = sngRunningVATIncOnCost + (sngCostIncOnCost * (VAT(Val(d.vatrate)) - 1))
   sngTotCostIncOncost = sngTotCostIncOncost + sngCostIncOnCost
   
   startpos& = 1
   
   Do
      openbracepos& = InStr(startpos&, dataline$, "[")
      If openbracepos& > 0 Then
         temp$ = Mid$(dataline$, startpos&, (openbracepos& - startpos&))
      Else
         temp$ = Mid$(dataline$, startpos&)
      End If
      Put #filno, , temp$
      

      If openbracepos& > 0 Then
         startpos& = openbracepos&
         closebracepos& = InStr(openbracepos&, dataline$, "]")
         temp$ = Mid$(dataline$, startpos&, closebracepos& - openbracepos& + 1)
         
         Select Case LCase$(temp$)
            Case "[r]":     temp$ = strRobotFlag            '21jun04 CKJ Added Robot indicator: Robot pick, Manual pick, Error/Empty, Part pack
            Case "[ord]":   temp$ = orderno$
            Case "[loc]":   temp$ = location$
            Case "[loc2]":  temp$ = Trim$(d.loccode2)
            Case "[pick#]": temp$ = pickno$
            Case "[qty]"
               temp$ = send$
               If strRobotFlag = "R" Then                   '21jun04 CKJ
                     temp$ = TxtD(dispdata$ & "\mechdisp.ini", "Common", "*", "PickingTicketQuantityPrefix", 0) & temp$  '30Jun04 CKJ now allows configuration
                     temp$ = temp$ & TxtD(dispdata$ & "\mechdisp.ini", "Common", "*", "PickingTicketQuantitySuffix", 0)
                     PrinterParse temp$
                  End If
            Case "[pack]"
               temp$ = "x "
               If (UCase$(sup.suppliertype) = "S" And InStoresPacks%) Or UCase$(sup.suppliertype) = "E" Or (PrintInPacks And InStoresPacks%) Then             '24Aug00 TH Added check on instorespack for internals (S type sups)
                  temp$ = temp$ & Trim$(d.convfact) & " "                                                                                                       '     "
                  temp$ = temp$ & Trim$(d.PrintformV)                                                                                                           '     "
               Else                                                                                                                                             '     "
                  temp$ = temp$ & Trim$(d.PrintformV)                                                                                                           '     "          '     "
               End If                                                                                                                                           '     "
            
            Case "[cost]", "[costinconcost]"
                If LCase$(temp$) = "[cost]" Then
                   temp$ = LTrim$(Str$(Abs(Lcost!)))
                Else
                   temp$ = LTrim$(Str$(Abs(sngCostIncOnCost)))
                End If
             
                poundsandpence temp$, False
                If returnitem Then
                   If InStr(temp$, " ") > 0 Then
                      temp$ = "-" & Trim$(temp$)
                      temp$ = Space$(8 - Len(temp$)) & temp$
                   Else
                      temp$ = "-" & Trim$(temp$)
                   End If
                End If

             Case "[nsvcode]":      temp$ = Trim$(ord.Code)
             Case "[urg]":       temp$ = ord.urgency                 '23Jun04 CKJ was trim$()
             Case "[description]"
                temp$ = Trim$(d.DrugDescription)  ' temp$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
                plingparse temp$, "!"
             Case "[tf]":           temp$ = tf$
             Case "[tradename]":    temp$ = Trim$(d.tradename)
             Case "[custordno]":    temp$ = trimz(ord.custordno)
             
             Case "[strips]"
                temp$ = ""
                If Val(d.StripSize) > 0 Then
                   If (UCase$(sup.suppliertype) = "S" And InStoresPacks%) Or UCase$(sup.suppliertype) = "E" Or (PrintInPacks And InStoresPacks%) Then
                      If (Val(send$) * d.mlsperpack) Mod Val(d.StripSize) = 0 Then
                         temp$ = Format$((Val(send$) * d.mlsperpack) / Val(d.StripSize))
                         temp$ = "(" & Format$(temp$, "#0.##") & " strips)"
                      End If
                   Else
                      If (Val(send$) * d.mlsperpack) Mod Val(d.StripSize) = 0 Then
                         temp$ = Format$((Val(send$)) / Val(d.StripSize))
                         temp$ = "(" & Format$(temp$, "#0.##") & " strips)"
                      End If
                   End If
                End If
            
            Case "[qtypack]"
                   If Val(d.convfact) > 0 Then
                      If Int(Val(ord.outstanding)) = Val(ord.outstanding) Then
                         temp$ = Trim$(Format$(Val(ord.outstanding))) & " x " & Trim$(d.convfact) & " " & Trim$(LCase$(d.PrintformV))
                      Else
                         temp$ = Trim$(Format$(Val(ord.outstanding) * Val(d.convfact))) & " " & Trim$(LCase$(d.PrintformV))
                      End If
                   Else
                      temp$ = ""
                   End If

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
               
            Case "[messagetext]"                      '16Jun05 CKJ added block
               temp$ = strMessageText

            Case Else
               PrinterParse temp$
         End Select
               
         Put #filno, , temp$
      End If
      
      startpos& = closebracepos& + 1

   Loop While (openbracepos& > 0)
    temp$ = "\par "
    Put #filno, , temp$
  

End Sub

Sub poporder(o As orderstruct, msg$)

Dim Info$
   
   Info$ = " Edit type          " & TB & Str$(ordedittype) & Space$(20) & cr & cr
   Info$ = Info$ & " NSVcode" & TB & o.Code & cr
   Info$ = Info$ & " ordered" & TB & o.qtyordered & cr
   Info$ = Info$ & " received" & TB & o.received & cr
   Info$ = Info$ & " outstanding" & TB & o.outstanding & cr
   Info$ = Info$ & " ord date" & TB & o.orddate & cr
   Info$ = Info$ & " rec date" & TB & o.recdate & cr
   Info$ = Info$ & " urgency" & TB & o.urgency & cr
   Info$ = Info$ & " location" & TB & o.loccode & cr
   Info$ = Info$ & " sup code" & TB & o.supcode & cr
   Info$ = Info$ & " status" & TB & o.status & cr
   Info$ = Info$ & " order number" & TB & o.num & cr
   Info$ = Info$ & " cost" & TB & o.cost & cr
   Info$ = Info$ & " picking ticket" & TB & Str$(o.pickno) & cr
   Info$ = Info$ & " to follow flag" & TB & o.tofollow & cr
   Info$ = Info$ & " invoice num etc" & TB & o.invnum & cr
   Info$ = Info$ & " pay date" & TB & o.paydate & cr
   Info$ = Info$ & " internal siteno" & TB & o.internalsiteno & cr
   Info$ = Info$ & " internal method" & TB & o.internalmethod & cr
   k.helpnum = 0
   popmsg msg$, Info$, 1, "", k.escd
   

End Sub

Sub printconfirmtop(filno%, Ordno$, title$)
Dim success% '', foundsup%
Dim startpos&, openbracepos&, closebracepos&
Dim RTFTxt$, temp$


   'GetTextFile dispdata$ + "\CSTOP.rtf", RTFTxt$, success
   GetRTFTextFromDB dispdata$ + "\CSTOP.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      popmessagecr "Error", "There was a problem reading the RTF layout file - CSTOP.RTF"
      Exit Sub
   End If

   striprtf RTFTxt$

   If Not success Then
      popmessagecr "Error", "Could not open the layout file PICKTOP.RTF"
      Exit Sub
   End If

   startpos& = 1

    RTFTxt$ = Mid$(RTFTxt$, 1, Len(RTFTxt$) - 1) 'get rid of end "}" that terminates rtf file if left in
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
                Case "[today]"
                    temp$ = thedate$(True, True) & " [Original]"
                Case "[sitename]"
                    getsupplier (ownname$), 0, 0, sup
               temp$ = Trim$(sup.name)
                Case "[orderno]"
                    temp$ = Trim$(Ordno$)
            End Select

            PrinterParse temp$
         Put #filno, , temp$
      End If

        startpos& = closebracepos& + 1

    Loop While (openbracepos& > 0)

End Sub

Sub PrintCSDescriptor(filno%)

Dim temp$

   temp$ = Space$(51) + "Qty.     Expected  Expected[cr]"
   temp$ = temp$ & "NSV code         Description                       Ordered  Qty.      Unit Cost[cr]"
   temp$ = temp$ & "[80x-][cr]"

   PrinterParse temp$
   Put #filno, , temp$

End Sub

Sub printdescriptorline(filno%, Edittype%)
Dim startpos&, openbracepos&, closebracepos&
Dim temp$, RTFfile$, RTFTxt$
Dim success%

   Select Case Edittype%
      Case 5: RTFfile$ = "\pickdesc.rtf"
      Case 7: RTFfile$ = "\delndesc.rtf"
      Case 9: RTFfile$ = "\creddesc.rtf"
   End Select

   'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   
   If Not success Then
      popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
      Exit Sub
   End If

   If Left$(RTFTxt$, 6) = "{\rtf1" Then RTFTxt$ = Mid$(RTFTxt$, 2)
   striprtf RTFTxt$
   
   startpos& = 1
    
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
            Case Else
               PrinterParse temp$
         End Select
         Put #filno, , temp$
      End If
      startpos& = closebracepos& + 1
   Loop While (openbracepos& > 0)

   temp$ = "{\par }"
    Put #filno, , temp$

End Sub

Sub PrintOrdDescriptor(devno%, printtn%, ByVal blnPSO As Boolean)
'26Jan17 TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'09Mar17 TH Added section to support Fax rtfs (TFS 179309)

Dim temp$, RTFTxt$
Dim startpos&, endpos&, openbracepos&, closebracepos&, currentpos&
Dim Changed%, success%
Dim strRTFFile As String   '20Aug12 TH PSO
   
   'If PSO then we should use the PSO rtfs (if available)
   
   strRTFFile = "\orddescr.rtf"
   '29Jul14 TH Added support for Hub prints
   If sup.Method = "H" Then
      'If fileexists(dispdata$ & "\Hub_orddescr.rtf") Then strRTFFile = "\Hub_orddescr.rtf"
      'GetRTFTextFromDB dispdata$ & "\Hub_orddescr.rtf", "", success  '08Jan17 TH Replaced (Hosted)
      'If success Then strRTFFile = "\Hub_orddescr.rtf"
      If RTFExistsInDatabase(dispdata$ & "\Hub_orddescr.rtf") Then strRTFFile = "\Hub_orddescr.rtf" '26Jan17 TH Replaced above
      If blnPSO Then
         'If fileexists(dispdata$ & "\Hub_PSO_orddescr.rtf") Then strRTFFile = "\Hub_PSO_orddescr.rtf"
         'GetRTFTextFromDB dispdata$ & "\Hub_PSO_orddescr.rtf", "", success  '08Jan17 TH Replaced (Hosted)
         'If success Then strRTFFile = "\Hub_PSO_orddescr.rtf"
         If RTFExistsInDatabase(dispdata$ & "\Hub_PSO_orddescr.rtf") Then strRTFFile = "\Hub_PSO_orddescr.rtf" '26Jan17 TH Replaced above
      End If
   ElseIf sup.Method = "F" Then  '09Mar17 TH NEver used the Fax rtfs !!! Added Section (TFS 179309)
      If RTFExistsInDatabase(dispdata$ & "\Faxdescr.rtf") Then strRTFFile = "\Faxdescr.rtf" '26Jan17 TH Replaced above
      If blnPSO Then
         If RTFExistsInDatabase(dispdata$ & "\PSO_Faxdescr.rtf") Then strRTFFile = "\PSO_Faxdescr.rtf" '26Jan17 TH Replaced above
      End If
   Else
      If blnPSO Then
         'If fileexists(dispdata$ & "\PSO_orddescr.rtf") Then strRTFFile = "\PSO_orddescr.rtf"
         'GetRTFTextFromDB dispdata$ & "\PSO_orddescr.rtf", "", success  '08Jan17 TH Replaced (Hosted)
         'If success Then strRTFFile = "\PSO_orddescr.rtf"
         If RTFExistsInDatabase(dispdata$ & "\PSO_orddescr.rtf") Then strRTFFile = "\PSO_orddescr.rtf" '26Jan17 TH Replaced above
      End If
   End If
   
   'GetTextFile dispdata$ + "\orddescr.rtf", RTFTxt$, success
   'GetTextFile dispdata$ + strRTFFile, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + strRTFFile, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      'popmessagecr "Error", "There was a problem reading the RTF layout file - " & "\orddescr.rtf"
      popmessagecr "Error", "There was a problem reading the RTF layout file - " & strRTFFile
      Exit Sub
   End If

   striprtf RTFTxt$
   
   startpos& = 1
   currentpos& = 1
   endpos& = Len(RTFTxt$)
   
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
            Case Else
               ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
         End Select
         Put #devno, , temp$
         currentpos& = closebracepos& + 1
      End If
      startpos& = closebracepos& + 1
   Loop While (openbracepos& > 0)

   If closebracepos& < endpos& Then
      temp$ = Mid$(RTFTxt$, currentpos&)
      Put #devno, , temp$
   End If
   
End Sub

Sub printordertail(filno%, message$, ByVal blnPSO As Boolean)
'03Nov10 TH Added after testing cos the rtf wouldnt handle the crlf directly (had to create two new elements.
'26Mar13 TH Handle stuff at this stage with no parsing braces (TFS 59714)
'27Mar13 TH Removed stuff to handle rtf text after final parse - this was handled already in the conditional check
'26Jan17 TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)

Dim success%
Dim startpos&, openbracepos&, closebracepos&
Dim RTFTxt$, temp$, RTFfile$

   Select Case UCase$(sup.Method)
      Case "D"
            RTFfile$ = "\ordbot.rtf"
            If blnPSO Then
               'If fileexists(dispdata$ & "\PSO_ordbot.rtf") Then RTFfile$ = "\PSO_ordbot.rtf"
               'GetRTFTextFromDB dispdata$ & "\PSO_ordbot.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\PSO_ordbot.rtf"
               If RTFExistsInDatabase(dispdata$ & "\PSO_ordbot.rtf") Then RTFfile$ = "\PSO_ordbot.rtf"  '26Jan17 TH Replaced above
            End If
      Case "E"
            RTFfile$ = "\ordbot.rtf"
      Case "F"
            RTFfile$ = "\faxbot.rtf"
      Case "H"
            RTFfile$ = "\ordbot.rtf"
            'If fileexists(dispdata$ & "\Hub_ordbot.rtf") Then RTFfile$ = "\Hub_ordbot.rtf"
            'GetRTFTextFromDB dispdata$ & "\Hub_ordbot.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
            'If success Then RTFfile$ = "\Hub_ordbot.rtf"
            If RTFExistsInDatabase(dispdata$ & "\Hub_ordbot.rtf") Then RTFfile$ = "\Hub_ordbot.rtf"   '26Jan17 TH Replaced above
            If blnPSO Then
               'If fileexists(dispdata$ & "\Hub_PSO_ordbot.rtf") Then RTFfile$ = "\Hub_PSO_ordbot.rtf"
               'GetRTFTextFromDB dispdata$ & "\Hub_PSO_ordbot.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\Hub_PSO_ordbot.rtf"
               If RTFExistsInDatabase(dispdata$ & "\Hub_ordbot.rtf") Then RTFfile$ = "\Hub_ordbot.rtf"   '26Jan17 TH Replaced above
            End If
   
      Case Else
   End Select

   'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)
   
   If Not success Then
          popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
      Exit Sub
   End If

   striprtf RTFTxt$

   If Not success Then
      popmessagecr "Error", "Could not open the layout file PICKTOP.RTF"
      Exit Sub
   End If

   startpos& = 1
    RTFTxt$ = Mid$(RTFTxt$, 1, Len(RTFTxt$) - 1) 'get rid of end "}" that terminates rtf file if left in
    
    If InStr(startpos&, RTFTxt$, "[") > 0 Then '26Mar13 TH Handle stuff at this stage with no parsing braces (TFS 59714)
       
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
               Case "[specialmsg]"
                  temp$ = specialmsg$
               Case "[additionalmsg]"
                  temp$ = m_strAdditionalOrderMsg
               '03Nov10 TH Added after testing cos the rtf wouldnt handle the crlf directly
               Case "[additionalmsg1]"
                  If InStr(1, m_strAdditionalOrderMsg, crlf, vbBinaryCompare) > 0 Then
                     temp$ = Left(m_strAdditionalOrderMsg, (InStr(1, m_strAdditionalOrderMsg, crlf, vbBinaryCompare) - 1))
                  Else
                     temp$ = m_strAdditionalOrderMsg
                  End If
               '03Nov10 TH Added after testing cos the rtf wouldnt handle the crlf directly
               Case "[additionalmsg2]"
                  If InStr(1, m_strAdditionalOrderMsg, crlf, vbBinaryCompare) > 0 Then
                     temp$ = Right(m_strAdditionalOrderMsg, Len(m_strAdditionalOrderMsg) - (InStr(1, m_strAdditionalOrderMsg, crlf, vbBinaryCompare) - 1))
                  Else
                     temp$ = ""
                  End If
               Case "[msg]"
                  temp$ = message$
               Case "[ordermsg]"
                  temp$ = ordmessage$
               Case "[signature]"
                  temp$ = "[cr][cr]Signature  " & String$(30, ".") & "[cr]"
               'Start : TFS 224253 : 15 Oct 2018 : Added new field - Contact Address
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
            End Select
               
            PrinterParse temp$
            Put #filno, , temp$
         End If
         startpos& = closebracepos& + 1
      Loop While (openbracepos& > 0)
      
      '27Mar13 TH Removed - this was handled above in the conditional check
      ''26Mar13 TH Now add anything after the last brace
      'If Len(RTFTxt$) > closebracepos& - openbracepos& + 1 Then
      '   temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
      '   Put #filno, , temp$
      'End If
      ''-------
   
   Else
      '26Mar13 TH OK we either dont have anything parse-able or it has already been done via heap parsing
      'In this case we must output the rtf text as it stands (TFS 59714)
      Put #filno, , RTFTxt$
   End If
   temp$ = "}"
   Put #filno, , temp$
   

End Sub

Sub printordertop(supcode$, Ordno$, filno%, printtn%, printsis%, Mode%, ByVal blnPSO As Boolean)

' mode% = 0 - for ordinary order printing
' mode% = 1 - for order cancelation printing
' mode% = 2 - for edi order printing
'14Aug14  TH  Added ordermsg element (TFS 86715)
'05Mar15  TH Added new fields just for order header (TFS 100122)
'26Jan17  TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)

Dim tempsup As supplierstruct
Dim ownsup As supplierstruct
Dim success%, Numoflines%, loopvar%, chars%
Dim startpos&, openbracepos&, closebracepos&
Dim RTFTxt$, temp$, RTFfile$, contname1$, contname2$, supnotes$, SQL$
Dim lngFoundSup As Long

   Select Case Mode%
      Case 0, 1, 2
         'do nothing
      Case Else
         popmessagecr "PrintOrderTop", "Called with illegal mode - " & Format$(Mode%)
         Mode% = 0
   End Select
   PtotordCost! = 0
   PtotordVat! = 0

   Select Case UCase$(sup.Method)
      Case "D"
            RTFfile$ = "\ORDTOP.rtf"
            If blnPSO Then
               'If fileexists(dispdata$ & "\PSO_ORDTOP.rtf") Then RTFfile$ = "\PSO_ORDTOP.rtf"
               'GetRTFTextFromDB dispdata$ & "\PSO_ORDTOP.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\PSO_ORDTOP.rtf"
               If RTFExistsInDatabase(dispdata$ & "\PSO_ORDTOP.rtf") Then RTFfile$ = "\PSO_ORDTOP.rtf" '26Jan17 TH Replaced above
            End If
      Case "E"
         RTFfile$ = "\ORDTOP.rtf"
      Case "F"
            RTFfile$ = "\FAXTOP.rtf"
            If blnPSO Then
               'If fileexists(dispdata$ & "\PSO_FAXTOP.rtf") Then RTFfile$ = "\PSO_FAXTOP.rtf"
               'GetRTFTextFromDB dispdata$ & "\PSO_FAXTOP.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\PSO_FAXTOP.rtf"
               If RTFExistsInDatabase(dispdata$ & "\PSO_FAXTOP.rtf") Then RTFfile$ = "\PSO_FAXTOP.rtf" '26Jan17 TH Replaced above
            End If
      Case "H"
            RTFfile$ = "\ORDTOP.rtf"
            'If fileexists(dispdata$ & "\Hub_ORDTOP.rtf") Then RTFfile$ = "\Hub_ORDTOP.rtf"
            'GetRTFTextFromDB dispdata$ & "\Hub_ORDTOP.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
            'If success Then RTFfile$ = "\Hub_ORDTOP.rtf"
            If RTFExistsInDatabase(dispdata$ & "\Hub_ORDTOP.rtf") Then RTFfile$ = "\Hub_ORDTOP.rtf" '26Jan17 TH Replaced above
            If blnPSO Then
               'If fileexists(dispdata$ & "\PSO_ORDTOP.rtf") Then RTFfile$ = "\PSO_ORDTOP.rtf" '26Aug14 TH This may need removing WHEN Hub none PSO is available
               'GetRTFTextFromDB dispdata$ & "\PSO_ORDTOP.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\PSO_ORDTOP.rtf"
               If RTFExistsInDatabase(dispdata$ & "\PSO_ORDTOP.rtf") Then RTFfile$ = "\PSO_ORDTOP.rtf" '26Jan17 TH Replaced above
               'If fileexists(dispdata$ & "\Hub_PSO_ORDTOP.rtf") Then RTFfile$ = "\Hub_PSO_ORDTOP.rtf"
               'GetRTFTextFromDB dispdata$ & "\Hub_PSO_ORDTOP.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
               'If success Then RTFfile$ = "\Hub_PSO_ORDTOP.rtf"
               If RTFExistsInDatabase(dispdata$ & "\Hub_PSO_ORDTOP.rtf") Then RTFfile$ = "\Hub_PSO_ORDTOP.rtf"  '26Jan17 TH Replaced above
            End If
      Case Else
         popmessagecr "ERROR", "Invalid Method specified in PrintOrderTop : " & sup.Method
         Exit Sub
   End Select
    
   LSet tempsup = sup
   lngFoundSup = 0
   getsupplier (ownname$), 0, lngFoundSup, sup
   
   LSet ownsup = sup
   LSet sup = tempsup
   GetExtraSupplierData sup.Code, contname1$, contname2$, supnotes$ '17Dec04 TH Replaced below

   '''SQL$ = "SELECT * FROM ExtraSupplierData WHERE (Supcode = '" & Trim$(sup.code) & "');"
   '''Set snap = SupDB.CreateSnapshot(SQL$) '29Jun97 EAC changed from WSDB to SupDB

   '''If Not snap.EOF Then
   '''      contname1$ = Trim$(GetField(snap!ContactName1))
   '''      contname2$ = Trim$(GetField(snap!ContactName2))
   '''      supnotes$ = Trim$(GetField(snap!notes))
   '''   Else
   '''      contname1$ = ""
   '''      contname2$ = ""
   '''      supnotes$ = ""
   '''   End If

   'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
      Exit Sub
   End If
    
   striprtf RTFTxt$

   If Not success Then
      popmessagecr "Error", "Could not open the layout file PICKTOP.RTF"
      Exit Sub
   End If

   startpos& = 1
    RTFTxt$ = Mid$(RTFTxt$, 1, Len(RTFTxt$) - 1) 'get rid of end "}" that terminates rtf file if left in
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
            Case "[heading]"
               Select Case Mode
                  Case 1
                     temp$ = "ORDER CANCELLATION"
                  Case 0
                     temp$ = "OFFICIAL ORDER"
                  Case 2
                     temp$ = "EDI ORDER"
               End Select
            Case "[today]"
               temp$ = thedate$(True, True) & " [Original]"
            Case "[delname]"
               LSet sup = ownsup
               deflines joinsup$(sup.supaddress, sup), txtline$(), ",", 1, Numoflines
               temp$ = ""
               For loopvar = 1 To Numoflines
                  temp$ = temp$ & LTrim$(txtline$(loopvar)) & "[cr]"  '13Oct06 TH SC-06-0959
               Next
               LSet sup = tempsup
            Case "[sitename]"
               lngFoundSup = 0
               getsupplier supcode$, 0, lngFoundSup, sup
               If sup.ptn = "Y" Then printtn = True Else printtn = False
               If sup.psis <> "N" Then printsis = True Else printsis = False
               deflines joinsup$(sup.supaddress, sup), txtline$(), ",", 1, Numoflines
               temp$ = ""
               For loopvar = 1 To Numoflines
                  temp$ = temp$ & Trim$(txtline$(loopvar)) & "[cr]" '13Oct06 TH SC-06-0959
               Next
            Case "[suptelno]"
               temp$ = Trim$(sup.suptelno)
            Case "[supfaxno]"
               temp$ = Trim$(sup.supfaxno)
            Case "[supcontact1]"
               temp$ = contname1$
            Case "[supcontact2]"
               temp$ = contname2$
            Case "[orderno]"
               If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PadOrderNumber", 0)) Then
                  If InStr(Ordno$, "/") Then chars = 12 Else chars = 10
                  temp$ = ordnumprefix$ + Right$("000000" + Ordno$, chars)
               Else
                  temp$ = ordnumprefix$ + Ordno$
               End If
            Case "[contactname]"
               temp$ = Trim$(ordcontact$)
            Case "[ordermsg]"  '14Aug14 TH (TFS 86715)
               temp$ = Trim$(sup.ordmessage)
               
            '05Mar15 TH Added new fields just for order header (TFS 100122)
            Case "[GlobalLocationNumber]"
               temp$ = Trim$(sup.GlobalLocationNumber)
            Case "[NationalSupplierCode]"
               temp$ = Trim$(sup.NationalSupplierCode)
            Case "[UserField1]"
               temp$ = Trim$(sup.UserField1)
            Case "[UserField2]"
               temp$ = Trim$(sup.UserField2)
            Case "[UserField3]"
               temp$ = Trim$(sup.UserField3)
            Case "[UserField4]"
               temp$ = Trim$(sup.UserField4)
            'Start : TFS 224253 : 15 Oct 2018 : Added new field - Contact Address
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
         End Select
                
         PrinterParse temp$
         Put #filno, , temp$
      End If
      startpos& = closebracepos& + 1
   Loop While (openbracepos& > 0)

    temp$ = "}"
    Put #filno, , temp$



End Sub

Sub GetExtraSupplierData(ByVal strSupCode As String, ByRef strContract1 As String, ByRef strContract2 As String, ByRef strSupNotes As String)

Dim strParams As String
Dim RsExtraSupplierData As ADODB.Recordset

   strContract1 = ""
   strContract2 = ""
   strSupNotes = ""
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("SupplierCode", trnDataTypeVarChar, 5, strSupCode)
   
   Set RsExtraSupplierData = gTransport.ExecuteSelectSP(g_SessionID, "pExtraSupplierDatabySupcode", strParams)
   If Not RsExtraSupplierData Is Nothing Then     'use returned recordset
      If RsExtraSupplierData.State = adStateOpen Then
         If RsExtraSupplierData.RecordCount <> 0 Then
            strContract1 = RtrimGetField(RsExtraSupplierData!ContactName1)
            strContract2 = RtrimGetField(RsExtraSupplierData!ContactName2)
            strSupNotes = RtrimGetField(RsExtraSupplierData!notes)
         End If
      End If
   End If

End Sub


Sub PrintOrdTotal(devno As Integer, RTFfile As String, PtotordCost As Single, PtotordVat As Single, i_sngOrderVATIncOnCost As Single, i_sngOrderCostIncOncost As Single)

'06jan98 EAC written
'10May02 SF  added on cost enhancement, new data element [totalexvatinconcost] (enh#1555)
'26Mar13 TH  Handle stuff at this stage with no parsing braces (TFS 59714)
'27Mar13 TH  Moved handling of final rtf text  (TFS 59714)

Dim temp$, RTFTxt$, total$, VAT$
Dim startpos&, endpos&, openbracepos&, closebracepos&, currentpos&
Dim Changed%, success%, totalneg%, vatneg%
Dim totalincvat!
Dim strTotalIncOnCost As String, strVATIncOnCost As String     '10May02 SF added


   totalneg% = (Sgn(PtotordCost!) = -1)
   total$ = Format$(Abs(PtotordCost!))
   vatneg% = (Sgn(PtotordVat!) = -1)
   VAT$ = Format$(Abs(PtotordVat!))
   poundsandpence total$, False
   poundsandpence VAT$, False

   '10May02 SF added
   strTotalIncOnCost = Format$(Abs(i_sngOrderCostIncOncost))
   strVATIncOnCost = Format$(Abs(i_sngOrderVATIncOnCost))
   poundsandpence strTotalIncOnCost, False
   poundsandpence strVATIncOnCost, False
   '22Apr02 SF -----


   'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - " & RTFfile$
         Exit Sub
      End If

   If Left$(RTFTxt$, 6) = "{\rtf1" Then RTFTxt$ = Mid$(RTFTxt$, 2)
   striprtf RTFTxt$
   
   startpos& = 1
   currentpos& = 1
   endpos& = Len(RTFTxt$)
   If InStr(startpos&, RTFTxt$, "[") > 0 Then '26Mar13 TH Handle stuff at this stage with no parsing braces (TFS 59714)
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
               Case "[totalexvat]"
                  If totalneg% Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Trim$(total$)
               Case "[totalvat]"
                  If vatneg% Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Trim$(VAT$)
               Case "[totalincvat]"
                  totalincvat! = (Sgn(PtotordCost!) * Val(total$)) + (Sgn(PtotordVat!) * Val(VAT$))
                  If Sgn(totalincvat!) = -1 Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Format$(Abs(totalincvat!), "######0.00")
               '10May02 SF added
               Case "[totalexvatinconcost]"
                  If totalneg% Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Trim$(strTotalIncOnCost)
               Case "[totalvatinconcost]"
                  If vatneg% Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Trim$(strVATIncOnCost)
               Case "[totalincvatinconcost]"
                  totalincvat! = (Sgn(PtotordCost!) * Val(strTotalIncOnCost)) + (Sgn(i_sngOrderCostIncOncost) * Val(strVATIncOnCost))
                  If Sgn(i_sngOrderVATIncOnCost) = -1 Then
                     temp$ = "-"
                  Else
                     temp$ = ""
                  End If
                  temp$ = temp$ & money$(5) & Format$(Abs(totalincvat!), "######0.00")
               '10May02 SF -----
   
   
               Case Else
                  ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
            End Select
            Put #devno, , temp$
            currentpos& = closebracepos& + 1
         End If
   
         startpos& = closebracepos& + 1
      
      Loop While (openbracepos& > 0)
      
      '26Mar13 TH Now add anything after the last brace
      'If Len(RTFTxt$) > closebracepos& - openbracepos& + 1 Then
      '   temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
      '   Put #devno, , temp$
      'End If
      '-------
      '27Mar13 TH Replaced above by moving this from below
      If closebracepos& < endpos& Then
         temp$ = Mid$(RTFTxt$, currentpos&)
         Put #devno, , temp$
      End If
   
   Else
      '26Mar13 TH OK we either dont have anythign parse-able or it has already been done via heap parsing
      'In this case we must output the rtf text as it stands (TFS 59714)
      Put #devno, , RTFTxt$
   End If

    '27Mar13 TH Moved inside parsing check
    'If closebracepos& < endpos& Then
    '      temp$ = Mid$(RTFTxt$, currentpos&)
    '      Put #devno, , temp$
    '   End If
    temp$ = "{\par}"
    Put #devno, , temp$


End Sub

Sub printpick(sitepaths, Edittype, supcode$, selectnum$, finished%)
'-----------------------Print picking tickets--------------------------------
'ASC 24 Feb 91
'ASC 23 Mar 91 location code sorted
'20May92 ASC Total and Total inc. VAT moved one column to the left for 79
'            column laser printers.
'??????? ASC Added to follows
'20Mar93 CKJ Changed - to / in to follows calc
'21Mar93 CKJ Removed setinput

'11Oct99 CKJ Removed Findsupplier
'11Feb00 MMA/SF replaced readprivateini: with txtd: as was reading the whole line including comments
'12Apr00 CFY Parameter added to wsspool call
'30Sep10 TH  Altered fencepost to allow batching on singleline credit order (F0097763)
'02Nov10 AJK F0086901 Added date invoiced to OrderLog calls
'31May12 TH  DLO Changes
'11Jun11 TH  Furhter DLO Changes .Added param to sups with ords so DLO selections can be identified.
'11Jul12 TH  DLO Polishing - altered input box captions and info displayed (TFS)
'19Jul12 TH  Ensure DLO Order Qty createed is factored by PrintinPacks setting (TFS 39281)
'26Mar13 TH  Mods to handle DLO splits properly (TFS 58711)
'10Dec13 TH  Change default PT Order to ensure DLO Orders can be sorted correctly (TFS 79649)
'24Jul15 XN Picking Tickets Page Number Error 119158
'12Feb17 TH Removed call to kill reprint as now inappropriate (TFS 176106)
'----------------------------------------------------------------------------

Dim locked%, printedok%, filno%, maxline%, numforpicking%, totpages%
Dim lineno%, pageno%, lined%, X%, foundPtr&, adjusted%, F&, done%
Dim pointer&
Dim adjust!
Dim dateord$, daterec$, qtyord$, qtyrec$, ordqty$, msg$
Dim filelock$, msg1$, FILE$, SisCode$
Dim loopvar%, missout%, itemsleft%
Dim dontkillit%
Dim lngReturn As Long
Dim lngFoundSup As Long
Dim lngOrderno As Long
Dim strNumbers As String
Dim strBatchNumber As String  '27Oct06 TH Added
Dim strExpiry As String       '     "
Dim blnDLOLined As Boolean '31May12 TH DLO
Dim blnNewPage As Boolean  '     "
Dim strDLO As String
Dim blnDLO As Boolean

   If Trim$(supcode$) = "" Then
      setinput 0, k
      blnDLO = False
      supswithords Edittype, supcode$, numofsups%, strDLO, False '11Jun11 TH Added param (DLO)
      If strDLO = "DLO" Then blnDLO = True
      
      If k.escd Then
         finished = True
      Else
         Unload LstBoxFrm  '10Aug05 TH Added (#82085)
         
         If numofsups = 0 Then
            finished = True
            k.escd = True
            Select Case Edittype
               Case 5
                  msg$ = "No picking tickets to be printed."
               Case 7
                  msg$ = "No delivery notes to be printed."
               Case 9
                  msg$ = "No credit orders to be printed."
            End Select
            popmessagecr "Information", msg$
         Else
            getsupplier supcode$, 0, 0, sup '13Mar JP/TH
            If sup.Method <> "T" And Edittype = 9 Then
               displayspecialmsg False, Edittype, "", False '13Jun12 TH Added param (DLO) '23Nov12 TH Added PSO param
               'k.escd = False  '26Aug05 TH Removed - Bring into line with new functionality in Ordering
               '27Oct06 TH Put batch stuff in here
               'TakeStockFromBatch ord.Code, (Val(ord.qtyordered) * Val(d.convfact)), strBatchNumber, strExpiry, 0
            End If
         End If
      End If
   End If
   
   If Not k.escd Then
      Do
         getsupplier supcode$, 0, lngFoundSup, sup
         If lngFoundSup = -1 Then
            k.escd = True
            lngFoundSup = 0
         End If
         filelock$ = dispdata$ + "\PRNTPCK" + Trim$(Str$(Edittype)) + ".LCK"
         AcquireLock filelock$, -2, locked  ' exclusive, keep trying
         printedok = False
         If locked And Not k.escd Then
            Do
               Select Case Edittype
                  Case 5
                     'msg1$ = "Order"
                     msg1$ = "Enter Requisition" '11Jul12 TH DLO Polishing
                  Case 7
                     'msg1$ = "Picking ticket"
                     msg1$ = "Enter Picking ticket" '11Jul12 TH DLO Polishing
               End Select

               If (Edittype = 5 Or Edittype = 7) And selectnum$ = "" Then
                  setinput 0, k
                  'k.Max = 5
                  'k.Max = 10  '31Oct05 TH Extended (#84168)
                  k.Max = 9 '24Nov05 TH Altered
                  selectnum$ = ""
                  
                  '11Jul12 TH Added Extra details , caption and ward/Location info (DLO Polishing)
                  msg1$ = "Location : " & Trim$(sup.name) & " (" & Trim$(sup.Code) & ")" & crlf & crlf & msg1$
                  
                  InputWin IIf(Edittype = 7, "Delivery note printing", "Picking ticket printing"), msg1$ + " number for printing or press [Return] for all", selectnum$, k
                  If LTrim$(selectnum$) = "" Then selectnum$ = "A"
                  If k.escd Then dontkillit% = True
               End If
                  
               If Not k.escd Then
                  Screen.MousePointer = HOURGLASS
   
                  Heap 10, gPRNheapID, "MechDispIdentifier1", supcode$, 0        'ward
                           
                  MakeLocalFile FILE$
                  filno = FreeFile
                  Open FILE$ For Binary Access Write Lock Read Write As #filno
                  
                  maxline = 400
                  ReDim picklist(maxline) As String
   
                  Do                                'Force through again if suspect index (but only once)
                     putlinesinarray selectnum$, maxline, Edittype, supcode$, picklist(), numforpicking, blnDLO
                  Loop While numforpicking < -10
                  'nositeindex = False  '11Jul11 CKJ never used
   
                  If numforpicking > 0 Then
                     'If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", "LocationOrder", 0)) Then                                                     '11Feb00 MMA/SF
                     If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", "LocationOrder", 0)) Then   '10Dec13 TH Change default TFS 79649
                        shellsort picklist(), numforpicking, 1, ""
                     End If                                                                                      '   "
                     If picknumoflines = 0 Then picknumoflines = 30
                     findnumberofpages picklist(), numforpicking, totpages
         
                     'Print picking ticket
                     '--------------------
         
                     printpickbody supcode$, filno, picklist(), numforpicking, Edittype, totpages
                     Close #filno

                     printedok = False ' 2Jun93 CKJ
                     Screen.MousePointer = STDCURSOR
                     WSspool FILE$, "Stores", 1, True, True, "PickTick"
                     printedok = True
                                                                                          
                  Else    'numforpicking > 0
                     Close #filno
                     Kill FILE$
                     Screen.MousePointer = STDCURSOR
                     popmessagecr "!n!bFinished", "No items for printing"
                     k.escd = True
                  End If  'numforpicking > 0
                        
               End If  'NOT k.escd
            Loop Until printedok Or k.escd
            
      
            If printedok And Not k.escd Then          'Process the lines printed
               Screen.MousePointer = HOURGLASS
               If Edittype = 7 Then                                          '07Oct05 TH Added (#)
                  getorderno 25, lngOrderno, False 'sets to current orderno
               Else
                  getorderno Edittype, lngOrderno, False 'sets to current orderno when
               End If
                                                   'FINISHED with is incremented
                                                   'for next time
               strNumbers = strNumbers & Format$(lngOrderno) & ","
               ''If lngOrderno = 0 Then WriteLog siteinfo$("dispdataDRV", "") & "\ascroot\pickno.log", SiteNumber%, UserID$, "PRINTPICK1: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & edittype
               If lngOrderno = 0 Then WriteLog rootpath$ & "\pickno.log", SiteNumber%, UserID$, "PRINTPICK1: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & Edittype
               
               lineno = 0
               pageno = 1
               lined = False
               'If (edittype = 9) And (numforpicking > 1) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "E"
               'If (Edittype = 9) And (numforpicking > 0) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "E"  '30Sep10 TH Altered fencepost (F0097763)
               If (Edittype = 9) And (numforpicking > 0) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "E", False  '03Mar14 TH Added Param
               For X = 1 To numforpicking
                  '31May12 TH need to factor DLO to get PT number
                  lineno = lineno + 1
                  If lineno > picknumoflines Then
                     lineno = 1
                     pageno = pageno + 1
                     If Edittype <> 7 Then
                        'If Edittype = 9 And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "E" '04Aug10 TH Added
                        If Edittype = 9 And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "E", False   '03Mar14 TH Added Param
                        getorderno Edittype, lngOrderno, -1
                        If lngOrderno = 0 Then
                           ''WriteLog siteinfo$("dispdataDRV", "") & "\ascroot\pickno.log", SiteNumber%, UserID$, "PRINTPICK2: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & edittype
                           WriteLog rootpath$ & "\pickno.log", SiteNumber%, UserID$, "PRINTPICK2: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & Edittype
                        Else
                           strNumbers = strNumbers & Format$(lngOrderno) & ","
                        End If
                        'header
                        'If (Edittype = 9) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "E"
                        If (Edittype = 9) And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputHeader sup.Code, lngOrderno, "E", False  '03Mar14 TH Added Param
                     End If
                  End If
                  
                  'If Not lined And Left$(picklist(x), 1) = "~" Then
                  blnNewPage = False
                  blnNewPage = (Mid$(picklist(X), Iff((Edittype% = 5), 2, 1), 1) = "~" And lined = False)
                  'If Not blnNewPage And Edittype% = 5 Then blnNewPage = Left$(picklist(x), 1) = "!" And blnDLOLined = False
                  If Not blnNewPage And Edittype% = 5 Then
                     blnNewPage = Left$(picklist(X), 1) = "!" And blnDLOLined = False
                     If blnNewPage Then lined = False '26Mar13 TH reset for possible DLO non stocked (TFS 58711)
                  End If
                  If lineno > picknumoflines Or pageno = 0 Or blnNewPage Then '30May12 TH DLO
                  'If Not lined And (Mid$(picklist(x), Iff((edittype% = 5), 2, 1), 1) = "~") Then
                     If lineno > 1 Then
                        pageno = pageno + 1
                        If Edittype <> 7 Then
                           getorderno Edittype, lngOrderno, -1
                           If lngOrderno = 0 Then
                              ''WriteLog siteinfo$("dispdataDRV", "") & "\ascroot\pickno.log", SiteNumber%, UserID$, "PRINTPICK3: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & edittype
                              WriteLog rootpath$ & "\pickno.log", SiteNumber%, UserID$, "PRINTPICK3: GetOrderNo returned a picking ticket no of zero: Called with edittype = " & Edittype
                           Else
                              strNumbers = strNumbers & Format$(lngOrderno) & ","
                           End If
                        End If
                        lineno = 1
                     End If
                     If Edittype% = 5 Then                                 '30May12 TH DLO
                        If Left$(picklist(X), 1) = "!" Then
                           blnDLOLined = True
                           If Mid$(picklist(X), 2, 1) = "~" Then lined = True '26Mar13 TH Added (TFS 58711)
                        Else
                           If Mid$(picklist(X), 2, 1) = "~" Then lined = True   ' 24Jul15 XN Picking Tickets Page Number Error 119158
                        End If
                     Else
                        If Left$(picklist(X), 1) = "~" Then lined = True ' 24Jul15 XN Picking Tickets Page Number Error 119158
                     End If
                  End If
                  
                  '27Oct06 TH Moved batch stuff here so as to be in line with the order line, but outside of locking
                  If Edittype = 9 Then
                     TakeStockFromBatch ord.Code, (Val(ord.qtyordered) * Val(d.convfact)), strBatchNumber, strExpiry, 0, True
                  End If
                  '--------
                  
                  '--> LOCK
                  
                  getorder ord, Val(Right$(picklist(X), 10)), Edittype, True
            
                  Select Case Edittype
                     Case 5
                        ord.status = "6"
                        ord.pickno = lngOrderno
                        ord.orddate = thedate(False, True)   '03May98 CKJ Y2K
                        ord.ordtime = thedate(0, -2)  '11Oct05 TH Added
                     Case 7
                       ord.recdate = thedate(False, True)   '5Mar95 CKJ Added '03May98 CKJ Y2K
                        If ord.internalmethod = "M" Then
                           ord.status = "8"              '==> SiteLink
                        Else
                           ord.status = "R"
                        End If
                     Case 9
                        ord.status = "R"
                        ord.orddate = thedate(False, True)
                        ord.ordtime = thedate(0, -2)  '11Oct05 TH Added

                        ord.num = LTrim$(Str$(lngOrderno))
                        ''27Oct06 TH Put batch stuff in here
                        'TakeStockFromBatch ord.Code, (Val(ord.qtyordered) * Val(d.convfact)), strBatchNumber, strExpiry, 0
                        d.SisCode = ord.Code
                        getdrug d, 0, foundPtr&, True '<-LOCK
                        d.stocklvl = LTrim$(Str$(dp!(Val(d.stocklvl) - (Val(ord.qtyordered) * Val(d.convfact)))))
                        adjusted = False

                        If Val(d.cost) <> Val(ord.cost) Then
                           'Adjust lossesgains by difference between issue price and return price
                           adjust! = (Val(d.cost) - Val(ord.cost)) * Val(ord.qtyordered)
                           adjustissueprice d, adjust!
                        End If
                        putdrug d
                        'TH Added the time to the date passed in
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", "-" + Trim$(ord.qtyordered), "", ord.cost, ord.supcode, "E", sitepaths, ord.invnum, d.vatrate, "", "", "" '14Jan94 CKJ VAT
                        'Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", "-" + Trim$(ord.qtyordered), "", ord.cost, ord.supcode, "E", sitepaths, ord.invnum, d.vatrate, "", "", "", ord.paydate  '02Nov10 AJK F0086901 Added paydate
                        Orderlog ord.num, ord.Code, UserID$, ord.orddate & thedate(0, -2), "", "-" + Trim$(ord.qtyordered), "", ord.cost, ord.supcode, "E", sitepaths, ord.invnum, d.vatrate, "", "", "", ord.paydate, ord.PSORequestID '03Mar14 TH Added PSORequestID
                  End Select
                           
                  '--> UNLOCK
                  lngReturn = PutOrder(ord, Val(Right$(picklist(X), 10)), GetTableName(Edittype))
                  If Edittype = 9 Then 'Returns note
                     '*** create reconciliation record
                     LSet tempord = ord
                     blankorder ord
                     LSet ord = tempord
                     ord.status = "4"
                     ord.qtyordered = LTrim$(Str$(-1 * Val(ord.qtyordered)))
                     ord.outstanding = "0"   '23Aug93 CKJ/ASC
                     ''pointer& = PutOrder(ord, (pointer&), "WReconcil")
                     pointer& = PutOrder(ord, 0, "WReconcil") '02Mar05 TH Force insert !
                  End If
                  
                  '31May12 TH DLO
                  If Edittype = 5 Then
                     '*** create order record if DLO
                     
                     If ord.DLO Then
                        If (TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0)) And (sup.PrintPickTicket = "Y")) Then  '22Nov12 TH TFS 49691 Ensure default is off
                           'we need the supplier (from d)
                           'May need more in here !!!!!!
                           '22Jun12 TH Do we not here need to add to an existing order ?? Check with AS
                           'More complex tho as how then do you link back to the original DLO line
                           d.SisCode = ord.Code
                           getdrug d, 0, 0, False
                           LSet tempord = ord
                           blankorder ord
                           LSet ord = tempord
                           ord.DLOWard = ord.supcode
                           ord.status = "1"
                           'ord.qtyordered = LTrim$(Str$(-1 * Val(ord.qtyordered)))
                           'ord.outstanding =
                           'ord.outstanding = "0"
                           If Not PrintInPacks Then '19Jul12 TH (TFS 39281)
                              ord.qtyordered = LTrim$(Str$(Val(ord.qtyordered) / d.convfact))
                              ord.outstanding = LTrim$(Str$(Val(ord.outstanding) / d.convfact))
                           End If
                           ord.supcode = d.supcode
                           ord.num = 0
                           ord.convfact = d.convfact
                           ord.CreatedUser = UserID
                           ord.orddate = ""
                           ord.ordtime = ""
                           ord.custordno = ""
                           ord.DeliveryNoteReference = ""
                           ord.tofollow = 0
                           ord.received = 0
                           If Val(d.contprice) > 0 Then
                              ord.cost = d.contprice
                           Else
                              If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then
                                 ord.cost = d.sislistprice 'price last paid
                              Else
                                 ord.cost = d.cost
                              End If
                           End If
                           ord.pflag = ""
                           
                           pointer& = PutOrder(ord, 0, "WOrder") ' insert !
                        End If
                     End If
                  End If
                  '31May12 TH ---
                  
                  ordernum$ = ord.num               'are all these necessary ASC ? !!**
                  SisCode$ = ord.Code               'they look as if an Orderlog should occur
                  dateord$ = ord.orddate
                  daterec$ = ""
                  qtyord$ = ord.outstanding
                  qtyrec$ = ordqty$
               Next X
               Screen.MousePointer = STDCURSOR
               If numforpicking > 0 Then
                  If Edittype <> 7 Then
                     getorderno Edittype, lngOrderno, -1
                  Else                                   '
                     getorderno 25, lngOrderno, -1
                  End If
                  'If Edittype = 9 And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "E" '04Aug10 TH Added
                  If Edittype = 9 And TrueFalse(TxtD(dispdata$ & "\genint.ini", "CreditNote", "N", "BatchOrderOutput", 0)) Then BatchOrderlogOutputfooter "E", False   '03Mar14 TH Added Param
               End If
               AcquireLock filelock$, 0, done
               strNumbers = Left$(strNumbers, Len(strNumbers) - 1)
               Select Case Edittype
                  Case 5
                     ''msg$ = "Your Picking Ticket has been given the number " & Str$(ord.pickno - (pageno - 1))
                     msg$ = "Your Picking Ticket has been given the number" & Iff(InStr(strNumbers, ","), "s", "") & " " & strNumbers
                  Case 7
                     ''msg$ = "Your Delivery Note has been given the number " & Str$(lngOrderno - 1)
                     msg$ = "Your Delivery Note has been given the number" & Iff(InStr(strNumbers, ","), "s", "") & " " & strNumbers
                  Case 9
                     ''msg$ = "Your Credit Order has been given the number " & ord.num
                     msg$ = "Your Credit Order has been given the number" & Iff(InStr(strNumbers, ","), "s", "") & " " & strNumbers
               End Select
               popmessagecr "#", msg$
               k.escd = True
               missout = False
               For loopvar = 1 To supsinarray
                  If Trim$(Mid$(suppliers(loopvar), 1, Len(sup.Code))) = supcode$ Then
                     If Val(Mid$(suppliers(loopvar), 6, 10)) - numforpicking <= 0 Then
                        If Trim$(Mid$(suppliers(loopvar), 26, 3)) = Trim$(strDLO) And Edittype = 7 Then  '16Jul12 TH DLO (TFS)
                           missout = True
                           supsinarray = supsinarray - 1
                        ElseIf Edittype <> 7 Then
                           missout = True
                           supsinarray = supsinarray - 1
                        End If
                     Else
                        'subtract printed items from display
                        itemsleft = Val(Mid$(suppliers(loopvar), 6, 10)) - numforpicking
                        Mid$(suppliers(loopvar), 6, 10) = Format$(itemsleft, String$(10, "0"))
                     End If
                  End If
                  If missout And loopvar <= supsinarray Then suppliers(loopvar) = suppliers(loopvar + 1)
               Next
               ReDim Preserve suppliers(supsinarray)
               If supsinarray = 0 Then
                  finished = True
                  Unload LstBoxFrm
                  Select Case Edittype
                     Case 1: msg$ = "No orders to authorise."
                     Case 5: msg$ = "No picking tickets to print."
                     Case 7: msg$ = "No Delivery Notes to print."
                     Case 9: msg$ = "No Credit Orders to authorise."
                     Case Else
                     End Select
                  popmessagecr "Authorise Orders", msg$
               End If
            Else
               '12Feb17 TH Removed as you cant get here if you have created a reprint and removing the reprint is now redundant (TFS 176106)
               'If Not dontkillit% Then     'Flag to stop reprint kill if cancel out of inputbox
               '      'KillReprint
               '   End If
               AcquireLock filelock$, 0, done 'Release lock before msg
            End If  'printed ok
                  
            ReDim picklist(1) As String
         End If   'if locked and not k.escd
      Loop Until k.escd Or Not locked
   End If

End Sub

Sub printpickbody(supcode$, filno, picklist() As String, numforpicking, Edittype, totpages)

'26Mar13 TH Mods to handle DLO splits properly (TFS 58711)


Static DescLen%

Dim lineno%, pageno%, lined%, X%, success%, found%
Dim temp$, RTFTxt$, RTFfile$
Dim totcost!, runningvat!
Dim sngRunningVATIncOnCost As Single, sngTotCostIncOncost As Single
Dim dummy As Integer
Dim CurrentPickingTicket As String
Dim blnNewPage As Boolean     '30May12 TH Added DLO
Dim blnDLOLined As Boolean    '    "


   If DescLen = 0 Then
      DescLen = Val(TxtD$(dispdata$ & "\winord.ini", "Defaults", "35", "OrderDescriptionLength", found))
   End If
   
   lineno = 0
   pageno = 0 'allows top to be printed on first page
   lined = False
    
   Select Case Edittype%
      Case 5: RTFfile$ = "\pickdata.rtf"
      Case 7: RTFfile$ = "\delndata.rtf"
      Case 9: RTFfile$ = "\creddata.rtf"
   End Select
    
   'GetTextFile dispdata$ + RTFfile$, RTFTxt$, success
   GetRTFTextFromDB dispdata$ + RTFfile$, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      popmessagecr "Error", "There was a problem reading the RTF layout file - PICKDATA.RTF"
      Exit Sub
   End If
   
   If Left$(RTFTxt$, 6) = "{\rtf1" Then RTFTxt$ = Mid$(RTFTxt$, 2)
   striprtf RTFTxt$

   temp$ = "{"
   Put #filno, , temp$

   If Not success Then
      popmessagecr "Error", "Could not open the layout file PICKDATA.RTF"
      Exit Sub
   End If
    
   For X = 1 To numforpicking
      lineno = lineno + 1
      'If lineno > picknumoflines Or pageno = 0 Or (Left$(picklist(x), 1) = "~" And lined = False) Then
      'blnNewPage = (Left$(picklist(x), Iff((edittype% = 5), 2, 1)) = "~" And lined = False)
      blnNewPage = False
      blnNewPage = (Mid$(picklist(X), Iff((Edittype% = 5), 2, 1), 1) = "~" And lined = False)
      'If Not blnNewPage And Edittype% = 5 Then blnNewPage = Left$(picklist(x), 1) = "!" And blnDLOLined = False
      If Not blnNewPage And Edittype% = 5 Then
         blnNewPage = Left$(picklist(X), 1) = "!" And blnDLOLined = False
         If blnNewPage Then lined = False '26Mar13 TH reset for possible DLO non stocked (TFS 58711)
      End If
      If lineno > picknumoflines Or pageno = 0 Or blnNewPage Then '30May12 TH DLO
         If pageno > 0 Then
            PrintPickBottom filno, blnDLOLined
         
            If Edittype = 5 Then                         '15Aug05 CKJ Added block for robot Picking tickets
               dummy = MechDispIssueComplete("")      'message text has already been displayed. Could put it for printing too if desired
            End If
                           
            temp$ = "[FF]"
            PrinterParse temp$
            Put #filno, , temp$
         End If
            
         lined = False
         blnDLOLined = False
         
         lineno = 1
         pageno = pageno + 1
            
         printpicktop supcode$, filno, pageno, totpages, Edittype, picklist(), X, (Left$(picklist(X), 1) = "!")  '30May12 TH DLO Added Param
         If Edittype% = 5 Then                                 '30May12 TH DLO
            If Left$(picklist(X), 1) = "!" Then
               blnDLOLined = True
               If Mid$(picklist(X), 2, 1) = "~" Then lined = True '26Mar13 TH Added (TFS 58711)
            Else
               'If Left$(picklist(x), 2) = "~" Then lined = True   '     "
               If Mid$(picklist(X), 2, 1) = "~" Then lined = True  '     "
            End If
         Else                                                  '     "
            If Left$(picklist(X), 1) = "~" Then lined = True
         End If                                                '     "
         
         printdescriptorline filno, Edittype

         If Edittype = 5 Then                                                          '17Aug05 CKJ Added block for robot Picking tickets
            CurrentPickingTicket = CalculatePickingTicketNumber(pageno)
            Heap 10, gPRNheapID, "MechDispIdentifier2", CurrentPickingTicket, 0     '   "        Write picktickno to heap for interface
         End If
      End If
      ParseRequisition filno, RTFTxt$, Edittype, picklist(X), runningvat!, totcost!, sngRunningVATIncOnCost, sngTotCostIncOncost
   Next
    
   If numforpicking > 0 Then
      If Edittype = 7 Or Edittype = 9 Then
         PrintOrdTotal filno, "\picktotl.rtf", totcost!, runningvat!, sngRunningVATIncOnCost, sngTotCostIncOncost
      End If
      PrintPickBottom filno, blnDLOLined

      If Edittype = 5 Then                         '15Aug05 CKJ Added block for robot Picking tickets
         dummy = MechDispIssueComplete("")      'message text has already been displayed. Could put it for printing too if desired
      End If
   End If
    
   temp$ = "}"
   Put #filno, , temp$

End Sub

Sub PrintPickBottom(filno%, ByVal blnDLO As Boolean)
'30May12 TH Added DLO Parameter
'26Jan17 TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)

Dim startpos&, openbracepos&, closebracepos&
Dim temp$, RTFTxt$
Dim success%
Dim strFile As String

   strFile = "\pickbot.rtf"
   If blnDLO Then
      'If fileexists(dispdata$ + "\pickbotDLO.rtf") Then
      'GetRTFTextFromDB dispdata$ & "\pickbotDLO.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
      'If success Then strFile = "\pickbotDLO.rtf"
      If RTFExistsInDatabase(dispdata$ + "\pickbotDLO.rtf") Then strFile = "\pickbotDLO.rtf" '26Jan17 TH Replaced above
      ' strFile = "\pickbotDLO.rtf"
      'End If
   End If

   'GetTextFile dispdata$ + "\pickbot.rtf", RTFTxt$, success
   'GetTextFile dispdata$ & strFile, RTFTxt$, success
   GetRTFTextFromDB dispdata$ & strFile, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   
   If Not success Then
      'popmessagecr "Error", "There was a problem reading the RTF layout file PICKBOT.RTF"
      popmessagecr "Error", "There was a problem reading the RTF layout " & strFile & " from the database"
      Exit Sub
   End If
   If Left$(RTFTxt$, 6) = "{\rtf1" Then RTFTxt$ = Mid$(RTFTxt$, 2)
   striprtf RTFTxt$
   startpos& = 1
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
                Case "[specialmsg]"
                    If Edittype = 9 Then
                        temp$ = specialmsg$
                    Else
                        temp$ = ""
                    End If
                Case Else
                    PrinterParse temp$
         End Select

            Put #filno, , temp$
      End If

        startpos& = closebracepos& + 1

    Loop While (openbracepos& > 0)
    temp$ = "{\par }"
    Put #filno, , temp$
   
End Sub

Sub printpicktop(supcode$, filno%, pageno, totpages, Edittype, picklist() As String, lineno%, ByVal blnDLO As Boolean)
'30May12 TH Added new DLO param
'14Aug14 TH Added ordermsg element (TFS 86715)
'26Jan17 TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)

Dim temp$, RTFTxt$
Dim success%, Numoflines%, loopvar%
Dim openbracepos&, closebracepos&, startpos&
Dim lngFoundSup As Long
Dim lngOrderno As Long
Dim tmppickno As Long
Dim strFile As String

   strFile = "\PICKTOP.rtf"
   If blnDLO Then
      'If fileexists(dispdata$ + "\PICKTOPDLO.rtf") Then
      '   strFile = "\PICKTOPDLO.rtf"
      'End If
      'GetRTFTextFromDB dispdata$ & "\PICKTOPDLO.rtf", "", success  '08Jan17 TH Replaced Above (Hosted)
      'If success Then strFile = "\PICKTOPDLO.rtf"
      If RTFExistsInDatabase(dispdata$ + "\PICKTOPDLO.rtf") Then strFile = "\PICKTOPDLO.rtf" '26Jan17 TH Replaced above
      
   End If

   'GetTextFile dispdata$ + "\PICKTOP.rtf", RTFTxt$, success
   'GetTextFile dispdata$ & strFile, RTFTxt$, success
   GetRTFTextFromDB dispdata$ & strFile, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      'popmessagecr "Error", "There was a problem reading the RTF layout file - PICKTOP.RTF"
      popmessagecr "Error", "There was a problem reading the RTF layout " & strFile & " from the database"
      Exit Sub
   End If
   getorder ord, Val(Right$(picklist$(1), 10)), Edittype, False
   If Left$(RTFTxt$, 6) = "{\rtf1" Then RTFTxt$ = Mid$(RTFTxt$, 2)
   striprtf RTFTxt$
   startpos& = 1
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
            Case "[today]"
               temp$ = thedate$(True, True) & " [Original]"
            Case "[sitename]"
               getsupplier (ownname$), 0, lngFoundSup, sup
               If lngFoundSup > 0 Then
                  temp$ = Trim$(sup.name)
               Else
                  temp$ = ""
               End If

            Case "[delname]"
               getsupplier supcode$, 0, lngFoundSup, sup
               If lngFoundSup > 0 Then
                  deflines joinsup$(sup.supaddress, sup), txtline$(), ",", 1, Numoflines
                  temp$ = Trim$(txtline$(1))
                  For loopvar = 2 To Numoflines
                     temp$ = temp$ & "[cr][tab]" & Trim$(txtline$(loopvar))
                  Next
               Else
                  temp$ = ""
               End If

               deflines joinsup$(sup.supaddress, sup), txtline$(), ",", 1, Numoflines
               temp$ = Trim$(txtline$(1))
               For loopvar = 2 To Numoflines
                     temp$ = temp$ & "[cr][tab]" & Trim$(txtline$(loopvar))
               Next

            Case "[wardcode]"
                getsupplier supcode$, 0, lngFoundSup, sup
                If lngFoundSup > 0 Then
                     temp$ = Trim$(sup.wardcode)
                  Else
                     temp$ = ""
                  End If

            Case "[shortname]"
               getsupplier supcode$, 0, lngFoundSup, sup
               If lngFoundSup > 0 Then
                  temp$ = Trim$(sup.name)
               Else
                  temp$ = ""
               End If
            
            Case "[pickno]"
               temp$ = "No. "
               Select Case Edittype
                  Case 5
                     'getorderno edittype, lngOrderno, 0                                        '17Aug05 CKJ Replaced with equivalent function
                     'tmppickno = ((lngOrderno + pageno - 2)) + 1
                     'temp$ = temp$ & LTrim$(Str$(tmppickno))

                        temp$ = temp$ & CalculatePickingTicketNumber(pageno)                    '   "

                  Case 7
                     getorderno 25, lngOrderno, 0
                     If lngOrderno = 0 Then
                        getorderno 25, lngOrderno, -1
                     End If
                     temp$ = temp$ & LTrim$(Str$(lngOrderno))
                  Case 9
                     getorderno Edittype, lngOrderno, 0
                     temp$ = temp$ & LTrim$(Str$(lngOrderno))
               End Select

            Case "[delno]"
               Select Case Edittype
                  Case 5, 9: temp$ = ""
                  Case 7:    temp$ = Str$(lngReprintno)
               End Select

            Case "[pg]"
               temp$ = Str$(pageno)

            Case "[totalpg]"
               temp$ = Str$(totpages)

            Case "[heading]"
               If Edittype = 5 Then temp$ = "PICKING TICKET"
               If Edittype = 7 Then temp$ = "DELIVERY NOTE"
               If Edittype = 9 Then temp$ = "Credit Order for Returned Goods"

            Case "[datahdr]"
               If Left$(picklist(lineno), 1) = "~" Then
                     temp$ = "    " & String$(23, "-") & "ITEMS REQUESTED AND NOT STOCKED" & String$(23, "-") & "[cr]"
                     PrinterParse temp$
                     Put #filno, , temp$
                  End If
               Select Case Edittype
                  Case 5:    temp$ = "[ulineon]Locn  Order   Description                          Qty  (To Follow)         Code [ulineoff]"
                  Case 7:    temp$ = "[ulineon]Order/Pick No  Description                         Qty  (To Follow)         Code         Cost[ulineoff]"
                  Case 9:    temp$ = "[ulineon]              Description                                   Quantity        Code         Cost[ulineoff]"
                  Case Else: popmessagecr "Halted 2", "EditType =" + Str$(Edittype)
               End Select
               
            Case "[custordno]"
               temp$ = trimz(ord.custordno)
               
            Case "[ordermsg]"  '14Aug14 TH (TFS 86715)
               temp$ = Trim$(sup.ordmessage)
               
            'Start : TFS 224253 : 15 Oct 2018 : Added new field - Contact Address
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
         End Select
            
         PrinterParse temp$
         Put #filno, , temp$
      End If
      startpos& = closebracepos& + 1
   Loop While (openbracepos& > 0)

    temp$ = "{\par }"
    Put #filno, , temp$

End Sub

Sub putlinesinarray(selectnum$, maxline, Edittype, supcode$, picklist() As String, numforpicking, ByVal blnDLO As Boolean)
'Used for edittype 5, 7 and 9 only

'first pass through identify sort and record those printed
'31May09 TH Mod to prevent (on config)printing of PT for part of pack (ie less than 1 full pack) (F0033050)
'27Jul15 TH Changed Screen msg to properly reflect the print (TFS 90862)
'02Apr17 TH Replaced above. May have been a misplaced attempt to check an rtf, but we can find
'           no evidence of this file on site so default behaviour to False (TFS 174890)
'---------------------------------------------------------

Dim doall%, Y%, lineno%, selectnow%, found%, F& '', foundsup%
Dim totcost!
Dim pointer&, X&, cont&
Dim prefix$
Dim skipitem%, ans$, temp$ '01Nov99 TH
Dim numofskipped%          '08Nov99 TH
Dim strSql As String
Dim rsOrders      As ADODB.Recordset
Dim blnOK         As Boolean
Dim strTable As String
Dim strRecordID As String
Dim strParams As String
Dim strIsRobot As String   '21jun04 CKJ
Dim intPTLevel As Integer  '31May09 TH Added (F0033050)
Dim strPrintDescription As String '27Jul15 TH Added (TFS 90862)

   'If fileexists(dispdata$ + "\tofollow") Then doall = True
   If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "N", "PutLinesinArray_ToFollow_DoAll", 0)) Then doall = True  '02Apr17 TH Replaced above. May have been a misplaced attempt to check an rtf, but we can find no evidence of this file on site so default behaviour to False (TFS 174890)
   

   Y = 0
   totcost! = 0
   lineno = 0
   numofskipped = 0
   X& = 1
   cont& = 0
   If Edittype = 9 Then
      strTable = "WOrder"
   Else
      strTable = "WRequis"
   End If
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, Format$(Edittype)) & _
               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, Trim$(supcode$)) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, "")
   If strTable = "WRequis" Then
      strParams = strParams & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, "")
   Else
      strParams = strParams & gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0)
   End If
   
   strParams = strParams & gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                           gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                           gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byCriteria", strParams)
   
   If rsOrders.RecordCount > 0 Then
   
      
      
      rsOrders.MoveFirst
      Do While Not rsOrders.EOF
         ord = FillOrdFromRS(rsOrders, strTable)
         If ord.status = Trim$(Str$(Edittype)) And UCase$(Trim$(supcode$)) = UCase$(Trim$(ord.supcode)) Then
            selectnow = True
            If selectnum$ <> "A" And (Edittype = 5 Or Edittype = 7) Then
               If Edittype = 5 And Trim$(ord.num) <> Trim$(selectnum$) Then selectnow = False
               If Edittype = 7 And LTrim$(Str$(ord.pickno)) <> Trim$(selectnum$) Then selectnow = False
               If Edittype = 7 And (ord.DLO <> blnDLO) Then selectnow = False  '05Jul12 TH DLO on Deliv. notes
            End If
            
            If Edittype = 7 And (ord.DLO <> blnDLO) Then selectnow = False  '05Jul12 TH DLO on Deliv. notes  '16Jul12 TH Added !!!!!!!
               
            If selectnow And ((Edittype = 5 Or Edittype = 7) And ord.tofollow = "1") Then  'selectnow and'
               If Edittype = 5 Then
                  d.SisCode = ord.Code
                  getdrug d, 0, (found), False
                  getsupplier ord.supcode, 0, 0, sup
                  intPTLevel = 0                                                                                                    '31May09 TH Added (F0033050)
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "N", "PreventPartPackPickingTickets", 0)) Then intPTLevel = 1    '  "
                  If (sup.suppliertype = "W" Or sup.suppliertype = "L") Then
                     'If Int(Val(d.stocklvl)) <= 0 Then selectnow = False
                     If Int(Val(d.stocklvl)) <= intPTLevel Then selectnow = False  '31May09 TH Replaced above (F0033050)
                  Else
                     'If Int(Val(d.stocklvl) / Val(d.convfact)) <= 0 Then selectnow = False
                     If Int(Val(d.stocklvl) / Val(d.convfact)) <= intPTLevel Then selectnow = False  '31May09 TH Replaced above (F0033050)
                  End If
               Else
                  If Not doall Then selectnow = False
               End If
            End If

            If selectnow Then
               Y = Y + 1
               If Y > maxline - 1 Then
                  '27Jul15 TH Added (TFS 90862)
                  Select Case Edittype
                     Case 7: strPrintDescription = "delivery note"
                     Case 9: strPrintDescription = "credit order"
                     Case Else
                        strPrintDescription = "picking ticket"
                  End Select
                  'popmessagecr "", "400 items on first picking ticket: repeat to complete"
                  '27Jul15 TH Replaced above (TFS 90862)
                  Screen.MousePointer = STDCURSOR
                  popmessagecr "", "400 items on first " & strPrintDescription & ": repeat to complete"
                  Screen.MousePointer = HOURGLASS
                  '27Jul15 TH End
                  
                  
                  Y = Y - 1
                  Exit Do
               End If
               d.SisCode = ord.Code
               getdrug d, 0, F, False
               prefix$ = " "
               If Edittype <> 7 And UCase$(d.sisstock) = "N" Then prefix$ = "~"
               '5|~LLL  NNNN<descrip>xxxx
                        '5|~LLL  NNNN<descrip>xxxx    old standard way                                                     '21jun04 ckj
                        '5|~ LLL NNNN<descrip>xxxx    new standard way                                                     '   "
                        '5|~!LLL NNNN<descrip>xxxx    new way for robot items                                              '   "
               '7|~NNNN/PPPP<descrip>xxxx
               '9| LLL  NNNN<descrip>xxxx

               If Edittype = 9 And (Val(d.stocklvl) - DblRound(Val(ord.qtyordered) * Val(d.convfact), 0, False) < 0) And (TrueFalse(TxtD$(dispdata$ & "\patmed.ini", "", "", "NoNegIssues", found)) = True) Then '01Nov99 TH Allow abort of item if results in neg stocklevel     '31Oct01 TH Added dblRound to prevent rounding problems when returning part of pack (#52463)
                  temp$ = d.DrugDescription   'temp$ = GetStoresDescription()    XN 4Jun15 98073 New local stores description                                                                                                                                     '   "
                  plingparse temp$, "!"                                                                                                                                                  '   "
                  Screen.MousePointer = STDCURSOR                                                                                                                                        '   "
                  '11Aug05 TH Added default stop on neg stock for cred notes (#82107)
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "N", "AllowNegativeCredits", 0)) Then
                     popmsg "", "This action will lower the stock level for " & Trim$(temp$) & " below zero " & crlf & crlf & "Do you still wish to authorise a credit note for this item ?", 4, ans$, k.escd '01Nov99 TH
                  Else
                     'popmessagecr "!", "This action will lower the stock level for " & Trim$(temp$) & " below zero " & crlf & crlf & Space$(50) & "Cannot raise this on Credit Note."
                     popmessagecr "!", "This action will lower the stock level for " & Trim$(temp$) & " below zero " & crlf & crlf & Space$(50) & "Cannot raise this on Credit Order."
                     ans$ = "N"
                  End If
                  If ans$ <> "Y" Then skipitem = -1                                                                                                                                      '   "
                  Screen.MousePointer = HOURGLASS                                                                                                                                        '   "
               End If                                                                                                                                                                    '   "
               If Not skipitem Then
                  Select Case Edittype
                     Case 5                           'picking tickets
                        'picklist(y) = d.loccode + "  " + ord.num                                              '21jun04 ckj
                        If LocationForMechDisp(d.loccode, "") Then strIsRobot = "!" Else strIsRobot = " "      '   "
                        'picklist(Y) = strIsRobot & d.loccode & " " & ord.num                                   '   "
                        picklist(Y) = strIsRobot & d.loccode & "" & ord.num  '30May12 TH Replaced above to allow DLO to go first
                        If ord.DLO Then
                           prefix$ = "!" & prefix$
                        Else
                           prefix$ = " " & prefix$
                        End If
                        
                     Case 7                           'delivery notes
                        picklist(Y) = d.loccode + ord.num + "/" + Left$(LTrim$(Str$(ord.pickno) + Space$(10)), 10)  '31Oct01 TH Added
                     Case 9                           'credit orders
                        prefix$ = " "
                        picklist(Y) = d.loccode + "  " + ord.num
                     Case Else
                        popmessagecr "Halted 1", "EditType =" + Str$(Edittype)
                  End Select
                  If Edittype = 9 Then
                     strRecordID = (Left$(LTrim$(GetField(rsOrders!WOrderID)) + Space$(10), 10))
                  Else
                     strRecordID = (Left$(LTrim$(GetField(rsOrders!WRequisID)) + Space$(10), 10))
                  End If
                  'picklist(Y) = prefix$ + picklist(Y) + Left$(GetStoresDescription(), 9) + strRecordID XN 4Jun15 98073 New local stores description
                                  picklist(Y) = prefix$ + picklist(Y) + Left$(d.DrugDescription, 9) + strRecordID
               Else
                  Y = Y - 1
                  skipitem = False
                  numofskipped = numofskipped + 1
               End If
            End If
         End If
         rsOrders.MoveNext
      Loop
   End If
   rsOrders.Close
   Set rsOrders = Nothing
   numforpicking = Y

End Sub



Sub ReadOrdData()
'Need to Convert to use the Configuration table in SQL
'14Apr10 TH Added ReconciliationThreshold (F0056463)
Dim orddatchan%
Const strFile = "\WorkingDefaults.ini"

   preprint$ = TxtD(dispdata$ & strFile, "", "", "preprint", 0)
   ordnumprefix$ = TxtD(dispdata$ & strFile, "", "", "ordnumprefix", 0)
   ownname$ = TxtD(dispdata$ & strFile, "", "", "ownname", 0)
   overdue$ = TxtD(dispdata$ & strFile, "", "", "overdue", 0)
   ordmessage$ = TxtD(dispdata$ & strFile, "", "", "ordmessage", 0)
   ordcontact$ = TxtD(dispdata$ & strFile, "", "", "ordcontact", 0)
   maxnumoflines = Val(TxtD(dispdata$ & strFile, "", "", "maxnumoflines", 0))
   tp$ = TxtD(dispdata$ & strFile, "", "", "tp", 0)
   picknumoflines = Val(TxtD(dispdata$ & strFile, "", "", "picknumoflines", 0))
   delreceipt = Val(TxtD(dispdata$ & strFile, "", "", "delreceipt", 0))
   delreconcile = Val(TxtD(dispdata$ & strFile, "", "", "delreconcile", 0))
   FullPageCS = Val(TxtD(dispdata$ & strFile, "", "", "FullPageCS", 0))
   NSVcarriage$ = TxtD(dispdata$ & strFile, "", "", "NSVcarriage", 0)
   NSVdiscount$ = TxtD(dispdata$ & strFile, "", "", "NSVdiscount", 0)
   AskBatchNum = Val(TxtD(dispdata$ & strFile, "", "", "AskBatchNum", 0))
   Delrequis = Val(TxtD(dispdata$ & strFile, "", "", "Delrequis", 0))
   OrdPrintPrice = Val(TxtD(dispdata$ & strFile, "", "", "OrdPrintPrice", 0))
   OrdPrintLin = Val(TxtD(dispdata$ & strFile, "", "", "OrdPrintLin", 0))
   ProgressBarScale = Val(TxtD(dispdata$ & strFile, "", "", "ProgressBarScale", 0))
   PrintStockCost = Val(TxtD(dispdata$ & strFile, "", "", "PrintStockCost", 0))
   PrintToScreen$ = TxtD(dispdata$ & strFile, "", "", "PrintToScreen", 0)
   PrintCanceledOrder$ = TxtD(dispdata$ & strFile, "", "", "PrintCanceledOrder", 0)
   PrintInPacks = Val(TxtD(dispdata$ & strFile, "", "", "PrintInPacks", 0))
   AdjCostCentre$ = TxtD(dispdata$ & strFile, "", "", "AdjCostCentre", 0)
   WSStores% = Val(TxtD(dispdata$ & strFile, "", "", "WSStores", 0))
   NSVReconciliation$ = TxtD(dispdata$ & strFile, "", "", "NSVReconciliation", 0)
   EOPMargin% = Val(TxtD(dispdata$ & strFile, "", "", "EOPMargin", 0))
   edimaxnumoflines = Val(TxtD(dispdata$ & strFile, "", "", "edimaxnumoflines", 0)) ' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
   'ReconcilThresholdVal$ = Val(TxtD(dispdata$ & strFile, "", "", "ReconcilThresholdVal", 0)) '14Apr10 TH Added (F0056463)
   ReconcilThresholdVal$ = TxtD(dispdata$ & strFile, "", "", "ReconcilThresholdVal", 0) '23Feb12 TH Replaced as blank is a valid setting (TFS20214)

End Sub

Sub ReadSites()
Static doneonce
Dim sites$
Dim comma%, NumItems%, count%

   If doneonce = False Then
      doneonce = True
      sites$ = siteinfo$("SiteNumbers", "")
      If sites$ <> "" Then
         comma = InStr(sites$, ",")
         NumItems = 1                                'at least one other site
         Do While comma
            NumItems = NumItems + 1
            comma = InStr(comma + 1, sites$, ",")
         Loop
   
         ReDim sitenos%(NumItems), siteabb$(NumItems), sitepth$(NumItems)
        
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         
         For count = 1 To NumItems
            sitenos%(count) = Val(sitepth$(count))
         Next
         sites$ = siteinfo$("dispdataDRVs", "")
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         sites$ = siteinfo$("hospabs", "")
         deflines sites$, siteabb$(), ",(*)", 1, NumItems
         For count = 1 To NumItems  ' example  G:\DISPDATA.003
             sitepth$(count) = sitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(sitenos%(count))), 3)
         Next
      Else
          ReDim sitenos%(0), siteabb$(0), sitepth$(0)
      End If
      
      sitenos%(0) = SiteNumber
      siteabb$(0) = hospabbr$
      sitepth$(0) = dispdata$
   End If

End Sub

Sub Reprint(Index, strExtra As String)
'26Jun13 TH Added Ability to pick reprints from DB (TFS 64513)


Dim FILE$, printpath$, fileinfo As Variant, tabpos%, RTFTxt$, totnf%, X%, temp$
Dim StringSize&, thisline$, msg$, Context$                                                   '19Oct99 AE
ReDim TempArray$(0)
ReDim TempArray2$(0)
Dim lngFile As Long
Dim blnToomany As Boolean           '26Jun13 TH Added (TFS 64513)
Dim rsReprints As ADODB.Recordset   '  "
Dim strParams As String             '  "
Dim strName As String               '  "
Dim blnDBFile As Boolean            '  "
Dim strText As String               '  "
Dim intSuccess As Integer           '  "
   
   blnDBFile = False
   
   If LstBoxFrm.LstBox.ListCount > 0 Then
      LstBoxFrm.LstBox.Clear
   End If
   
   getprintpath printpath$, Index + 1
   FILE$ = Dir$(dispdata$ & printpath$ & "\*.rtf")
   totnf% = 0
   Screen.MousePointer = HOURGLASS
   If FILE$ <> "" Then
      Do
         temp$ = dispdata$ & printpath$ & "\" & FILE$
         fileinfo = FileDateTime(temp$)
         thisline$ = Left$(FILE$, Len(FILE$) - 4) & TB & Format$(fileinfo, "dd mmm yyyy") & TB & Format(fileinfo, "hh:nn") & TB & Format$(FileLen(temp$), "#,#")
         StringSize& = StringSize& + Len(thisline$)
         
         If StringSize& < 32000 Then
            totnf% = totnf% + 1
            ReDim Preserve TempArray$(totnf%)
            ReDim Preserve TempArray2$(totnf%)
            TempArray$(totnf%) = thisline$
            ''TempArray2$(totnf%) = Format$(fileinfo, "yyyymmdd") & Format$(totnf%)
            TempArray2$(totnf%) = Format$(fileinfo, "yyyymmddhhnnss") & Format$(totnf%)
            FILE$ = Dir$                           '12Jun98 CKJ don't use variant here - added $ to Dir
         Else
            Screen.MousePointer = STDCURSOR
            msg$ = "There are too many reprint files to display them all." & cr$
            msg$ = msg$ & "The first " & Format$(totnf) & " files will be displayed." & cr$ & cr$
            msg$ = msg$ & "You MUST tidy your Reprint files immediately." & cr$
            msg$ = msg$ & "Contact EMIS Health if you are not sure how to do this."
            popmessagecr ".Reprint", msg$
            FILE$ = ""
            blnToomany = True
         End If
      Loop Until FILE$ = ""
   End If
      
   '26Jun13 TH Now we need to check the DB (TFS 64513)
   If Not blnToomany Then
      'Get from the DB records for this category
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 10, Mid$(printpath$, 2))
      Set rsReprints = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyStoresReprintbySiteIDandCategory", strParams)
      'Read the records
      If rsReprints.RecordCount > 0 Then
         Do While Not rsReprints.EOF
            temp$ = dispdata$ & printpath$ & "\" & FILE$
            'fileinfo = RtrimGetField(rsReprints!date)
            thisline$ = RtrimGetField(rsReprints!name) & TB & Format$(RtrimGetField(rsReprints!date), "dd mmm yyyy") & TB & Format(RtrimGetField(rsReprints!date), "hh:nn") & TB & Format$(RtrimGetField(rsReprints!DocLength), "#,#")
            StringSize& = StringSize& + Len(thisline$)
            
            If StringSize& < 32000 Then
               totnf% = totnf% + 1
               ReDim Preserve TempArray$(totnf%)
               ReDim Preserve TempArray2$(totnf%)
               TempArray$(totnf%) = thisline$
               ''TempArray2$(totnf%) = Format$(fileinfo, "yyyymmdd") & Format$(totnf%)
               TempArray2$(totnf%) = Format$(RtrimGetField(rsReprints!date), "yyyymmddhhnnss") & Format$(totnf%)
            Else
               Screen.MousePointer = STDCURSOR
               msg$ = "There are too many reprint files to display them all." & cr$
               msg$ = msg$ & "The first " & Format$(totnf) & " files will be displayed." & cr$ & cr$
               msg$ = msg$ & "You MUST tidy your Reprint files immediately." & cr$
               msg$ = msg$ & "Contact EMIS Health if you are not sure how to do this."
               popmessagecr ".Reprint", msg$
               FILE$ = ""
               blnToomany = True
               Exit Do
            End If
            rsReprints.MoveNext
         Loop
      End If
      rsReprints.Close
      Set rsReprints = Nothing
   End If
   
   If totnf% > 0 Then

      shellsort TempArray2$(), totnf%, 1, ""
      LstBoxFrm.Caption = "Choose " & strExtra & " reprint" '26Aug05 TH Added strExtra (#82441)
      LstBoxFrm.lblHead = "Number             " & TB & "Date               " & TB & "Time      " & TB & "Size"
      For X = totnf% To 1 Step -1
         lngFile = CLng(Right$(TempArray2$(X), Len(TempArray2$(X)) - 14))
         LstBoxFrm.LstBox.AddItem TempArray$(lngFile)
      Next
         Screen.MousePointer = STDCURSOR
         LstBoxShow
         If LstBoxFrm.Tag <> "" Then
            '12Jun98 CKJ Allows parsing of multi-page RTF files, much greater than 32Kb
            tabpos = InStr(LstBoxFrm.Tag, TB$)
            '26Jun13 TH First try the DB if there is nothing fall backon the file (TFS 64513)
            strName = Left$(LstBoxFrm.Tag, tabpos - 1)
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 10, Mid$(printpath$, 2)) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 15, strName)
            Set rsReprints = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyStoresReprintbySiteIDandCategoryandName", strParams)
            If Not rsReprints.EOF Then
               'Read the Document from the DB and load into a localfile
               strText = RtrimGetField(rsReprints!Document)
               MakeLocalFile FILE$
               PutTextFile FILE$, strText, intSuccess
               blnDBFile = True
            Else
               '26Jun13 TH If not in DB try the old way (TFS 64513)
               FILE$ = dispdata$ & printpath$ & "\" & Left$(LstBoxFrm.Tag, tabpos - 1) & ".rtf"
            End If
            
            rsReprints.Close           '26Jun13 TH (TFS 64513)
            Set rsReprints = Nothing   '  "
            
            RTFTxt$ = "(Re-printed by " & UserID$ & " on " & thedate$(True, True) & ")"
            Heap 10, gPRNheapID, "Original", RTFTxt$, 0
            parseRTF FILE$, temp$ '04Jan17 TH Checked - we use old file handling here correctly (Hosted)
            If FileLen(FILE$) = FileLen(temp$) Then
               Kill temp$
               popmessagecr "[Original] not found", "No date printed on original. Re-print is not allowed"
            Else
               Select Case Edittype
                  Case 1, 2, 3, 4, 9
                     Context$ = "PurchOrd"
                  Case 5, 6, 7, 8
                     Context$ = "PickTick"
               End Select
               Hedit 10, temp$
               Hedit 14, Context$ & Chr$(0) & temp$
            End If
            Heap 12, gPRNheapID, "Original", "", 0
            If blnDBFile Then  '26Jun13 TH Added (TFS 64513)
               Kill FILE$
            End If
         End If
         Unload LstBoxFrm
      Else
         popmessagecr "", "Nothing to reprint"
      End If

End Sub

Function rightjust6$(Value$)

   rightjust6$ = Right$(Space$(6) + Left$(Trim$(Value$), 6), 6)

End Function



Sub SetDispdata(site%)
' 6Jan95 CKJ Written. If site is in SITEINFO.INI then add drive letter
'            else assume same server
'            Site = 0  set dispdata to own sitenumber
'            Site = -1 returns number of sites (0-n)
'            Site > 0  set dispdata to specified site
'sitenos() sitepth() and dispdata$ are Named Common Shared
'19Mar09 TH  Added sitenumber to heap for UHB Interfacing (F0032689)

Dim count%
Dim strParams As String

   ReadSites
   Select Case site
      Case -1     ' how many sites?
         site = UBound(sitenos)
      Case 0      ' set to own site
         dispdata$ = sitepth$(0)
         'reset gDispSite
         strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
         gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
         Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0  '19Mar09 TH Added For UHB Interfacing
      Case Else   ' set to specified site
         For count = 0 To UBound(sitenos)
            If sitenos%(count) = site% Then
                  dispdata$ = sitepth$(count)
                  strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, site%)
                  gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
                  Heap 10, gPRNheapID, "SiteNumber", Format$(site%), 0 '19Mar09 TH Added For UHB Interfacing
                  Exit For
               End If
         Next
         If count > UBound(sitenos) Then
            popmessagecr "WARNING", "Site " + Str$(site) + " missing from SITEINFO.INI"
            Close
            storesEnd
         End If
   End Select

End Sub

Sub ShowFrmEnhTxtWin()
'08Mar02 TH Written  (#56352,54364)
'This is is a "proto - wrapper" for frmenhtxtwin (shown modally!). At present it
'is just written purely to ensure the keyboard settings are flushed and reset
'correctly, but ultimimately it can and probably should be extended
'into a full and proper wrapper

'TH Need receipt mode here for enhamcement !

   gk = k
   gk.exitval = 27
   frmEnhTxtWin.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   k = gk
   'Flush and reset k type
   If k.exitval = 27 Then k.escd = True
   k.validchars = nulls
   k.Max = 0              ' max will default to available space (currently preset to 78)
   k.min = 0              ' no minimum as standard
   k.esc = True           ' allow escape
   k.nums = False         ' default is whole character set
   k.decimals = False     '    "
   k.timeout = True       ' reset to standard timeout
   k.norefresh = False
   k.date = False         '   "
   k.passwrd = False      '   "



End Sub

Sub supswithords(Edittype%, supcode$, numofsups%, ByRef strDLOWard As String, ByVal blnPSO As Boolean)
'20Nov08 TH Made performance change for print PT's box load F0039009
'19Jan10 PJC F0074352 Added loop to find the correct supplier from array for minimal order.
'14Nov12 TH PSO Caption support on auth orders (TFS 48800)
'28Jul15 XN Reordered, added Min Order column 92596
'04Aug17 TH Ensure Supplier lookup done on code as IDs now not unique across new tables (TFS 190644)
'28Nov17 DR  Backed out previous change (TFS 190644)
'15Feb18 DR Bug 204009 - When authorising an order in stores, the value displayed does not reflect the actual value of the order immediately
'09Apr18 DR Bug 209205 - Stores - Authorise orders - Minimum value pop up box with wrong information incorrectly appears for DLO item

Dim tempsup As supplierstruct
Dim aborted%, selectnow%, foundPtr&, X%, maxnum%, newsupplier%, LineSelected%, posn%
Dim templine$, LineCost$, msg$
Dim pointer&, orderno&
Dim price!, totcost!, lastsupcode$
Dim lines$()
Dim intSupNotInUse As Integer
Dim rsDrugs        As ADODB.Recordset
Dim rsOrders       As ADODB.Recordset
Dim strSql         As String
Dim strTable       As String
Dim lngFoundSup As Long
Dim lngSuptofind As Long
Dim strParams As String
Dim strAns As String
Dim strMsg As String
Dim blnPreOrderPrint As Boolean
Dim strDLO As String  '11Jun12 TH DLO
'Dim suppliers() As String * 32
'Dim suppliersDLO() As String * 5
Dim blnPSOSkip As Boolean   '19Aug12 TH PSO


   If Edittype% = 99 Then
      blnPreOrderPrint = True
      Edittype% = 1
   End If
   Screen.MousePointer = HOURGLASS
   numofsups = 0
   k.escd = False
   lastsupcode$ = ""
   intSupNotInUse = 0
   If supsinarray = 0 Then
      'ReDim suppliers(1) As String * 27
      ReDim suppliers(1) As String * 30
      aborted = False
      strTable = GetTableName(Edittype%)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, CStr(Edittype))
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "byStatusForSupsWithOrds", strParams)
      If rsOrders.RecordCount > 0 Then
         rsOrders.MoveFirst
         strDLO = ""
         Do While Not rsOrders.EOF
            'If RtrimGetField(rsOrders!supcode) <> lastsupcode$ Then
            
            blnPSOSkip = False
            If Edittype = 1 Then
               If Not blnPSO Or (blnPSO And (Val(RtrimGetField(rsOrders!PSORequestID)) > 0)) Then
                  
                  If (RtrimGetField(rsOrders!supcode) <> lastsupcode$ Or RtrimGetField(rsOrders!DLOWard) <> strDLO) Then
                     lastsupcode$ = RtrimGetField(rsOrders!supcode)
                     lngFoundSup = RtrimGetField(rsOrders!WSupplierID)
                     strDLO = Iff(blnPSO, "", (RtrimGetField(rsOrders!DLOWard))) '11Jun12 TH Added DLO  '19Aug12 Added PSO check
                     ''selectnow = True
                  End If
               Else
                  blnPSOSkip = True
                  ''selectnow = False
               End If
            ElseIf Edittype = 7 Then
               If (RtrimGetField(rsOrders!supcode) <> lastsupcode$ Or (IIf(RtrimGetField(rsOrders!DLO), "DLO", "")) <> strDLO) Then
                  lastsupcode$ = RtrimGetField(rsOrders!supcode)
                  lngFoundSup = RtrimGetField(rsOrders!WSupplierID)
                  strDLO = IIf(RtrimGetField(rsOrders!DLO), "DLO", "") '05Jul12 TH Added DLO
               End If
            Else
               If RtrimGetField(rsOrders!supcode) <> lastsupcode$ Then
                  lastsupcode$ = RtrimGetField(rsOrders!supcode)
                  lngFoundSup = RtrimGetField(rsOrders!WSupplierID)
               End If
            End If
            If Not blnPSOSkip Then
               selectnow = True
            Else
               selectnow = False
            End If
            If Edittype = 5 And RtrimGetField(rsOrders!tofollow) = "1" Then
               'd.SisCode = RtrimGetField(rsOrders!Code) '20Nov08 TH Removed (F0039009)
               'getdrug d, 0, foundPtr&, False           '    "
               'If foundPtr& Then                           '20Nov08 TH Replaced (F0039009)
               If Not IsNull(rsOrders!stocklvl) Then        '    "
                  If (RtrimGetField(rsOrders!suppliertype) = "W" Or RtrimGetField(rsOrders!suppliertype) = "L") Then
                     'If Int(Val(d.stocklvl)) <= 0 Then selectnow = False                          '20Nov08 TH Replaced (F0039009)
                     If Int(Val(RtrimGetField(rsOrders!stocklvl))) <= 0 Then selectnow = False     '    "
                  Else
                     'If Int(Val(d.stocklvl) / Val(d.convfact)) <= 0 Then selectnow = False                                               '20Nov08 TH Replaced (F0039009)
                     If Int(Val(RtrimGetField(rsOrders!stocklvl)) / Val(RtrimGetField(rsOrders!convfact))) <= 0 Then selectnow = False    '    "
                  End If
               Else
                   'popmessagecr "Error", "Could not find item " & d.SisCode & " in drug file." '10Jan07 TH Replaced with below
                   Screen.MousePointer = STDCURSOR '20Nov08 TH Added
                   popmessagecr "Error", "Could not find item " & RtrimGetField(rsOrders!Code) & " in drug file."
                   Screen.MousePointer = HOURGLASS '20Nov08 TH Added
                   selectnow = False
               End If
            End If
            If selectnow Then
               X = 0
               If Edittype = 1 Then
                  Do
                     X = X + 1
                     If X > maxnum Then Exit Do
                  Loop Until (RtrimGetField(rsOrders!supcode) = Trim$(Left$(suppliers(X), 5)) And RtrimGetField(rsOrders!DLOWard) = Trim$(Right$(suppliers(X), 5)))
               ElseIf Edittype = 7 Then
                  Do
                     X = X + 1
                     If X > maxnum Then Exit Do
                  Loop Until (RtrimGetField(rsOrders!supcode) = Trim$(Left$(suppliers(X), 5)) And (IIf(RtrimGetField(rsOrders!DLO), "DLO", "")) = Trim$(Right$(suppliers(X), 5)))
               Else
                  Do
                     X = X + 1
                     If X > maxnum Then Exit Do
                  Loop Until RtrimGetField(rsOrders!supcode) = Trim$(Left$(suppliers(X), 5))
               End If
               If X > maxnum Then
                  maxnum = X
                  newsupplier = True
               Else
                  newsupplier = False
               End If
               
               If Edittype = 3 Or Edittype = 1 Then
                  If Val(RtrimGetField(rsOrders!contprice)) > 0 Then
                      price! = Val(RtrimGetField(rsOrders!contprice))
                  Else
                     If (Edittype = 3 And Val(RtrimGetField(rsOrders!sislistprice)) > 0) Or (Edittype = 1 And UCase(RtrimGetField(rsOrders!sisstock)) = "N") Then
                        price! = Val(RtrimGetField(rsOrders!sislistprice))
                     Else
                        price! = Val(RtrimGetField(rsOrders!cost))
                     End If
                  End If
                  If UCase$(RtrimGetField(rsOrders!pflag)) = "M" Then
                  price! = Val(RtrimGetField(rsOrders!cost))
                  End If
               Else
                  price! = Val(RtrimGetField(rsOrders!cost))
               End If
               
               If newsupplier Then
                  If X > numofsups Then
                     numofsups = X
                     'ReDim Preserve suppliers(numofsups) As String * 27
                     ReDim Preserve suppliers(numofsups) As String * 30
                  End If
                  If Edittype = 1 Then
                     suppliers(X) = Left$(RtrimGetField(rsOrders!supcode) & Space(5), 5) & Format$(price! * Abs(Val(RtrimGetField(rsOrders!outstanding))), "0000000000") & Format$(lngFoundSup, "0000000000") & Left$(strDLO & "     ", 5)
                  Else
                     suppliers(X) = Left$(RtrimGetField(rsOrders!supcode) & Space(5), 5) & "         1" & Format$(lngFoundSup, "0000000000") & Left$(strDLO & "     ", 5)
                  End If
               Else
                  If Edittype = 1 Then
                     totcost! = price! * Val(RtrimGetField(rsOrders!outstanding)) + Val(Mid$(suppliers(X), 6, 10))
                  Else
                  
                     totcost! = Val(Mid$(suppliers(X), 6, 10)) + 1
                  End If
                  suppliers(X) = Mid$(suppliers(X), 1, Len(sup.Code)) & Format$(totcost!, "0000000000") & Format$(lngFoundSup, "0000000000") & Left$(strDLO & "     ", 5)
               End If
            End If
            'End If '19Aug12 TH PSO
            rsOrders.MoveNext
         Loop
      End If
     supsinarray = numofsups
   End If

   If Not k.escd Then
      LstBoxFrm.LstBox.Clear
      LstBoxFrm.Caption = "Authorise Orders - Select Supplier"
      
      Select Case Edittype
         Case 1
            'LstBoxFrm.lblHead = "Site   " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "Method" & TB & "Discount    " & TB & "Total(" & money(5) & ")" & Space$(20) & TB '25May05 TH Added extra width
            'LstBoxFrm.lblHead = "Site   " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "Method" & TB & IIf(blnPSO, "      ", "DLO   ") & TB & "Discount    " & TB & "Total(" & money(5) & ")" & Space$(20) & TB '25May05 TH Added extra width
            LstBoxFrm.lblHead = "Site   " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "Method" & TB & IIf(blnPSO, "      ", "DLO   ") & TB & "Min Order" & TB & "Total     " & TB & "Discount  " & TB & pad$("Discount Description", 30) '28Jul15 XN Reordered, added Min Order column 92596
            If blnPreOrderPrint Then
               LstBoxFrm.Caption = "Pre-Order Print - Select Supplier"
            Else
               LstBoxFrm.Caption = "Authorise " & IIf(blnPSO, "Patient Specific", "") & " Orders - Select Supplier" '14Nov12 TH PSO Caption support on auth orders (TFS 48800)
            End If
         Case 2 'EDI 08Mar07 TH Added
            LstBoxFrm.lblHead = "Site    " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "No of items"
            LstBoxFrm.Caption = "EDI Ordering - Select Supplier"
         Case 9
            LstBoxFrm.lblHead = "Site    " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "No of items"
            'LstBoxFrm.Caption = "Authorise Credit Notes - Select Supplier"  '12Aug05 TH (#82102)
            LstBoxFrm.Caption = "Authorise Credit Orders - Select Supplier"  '12Aug05 TH (#82102)
         Case 7
            'LstBoxFrm.lblHead = "Site    " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "No of items"
            LstBoxFrm.lblHead = "Site    " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "No of items" & TB & "DLO   " '05Jul12 TH Added extra capacity to allow for DLO Suffix '06Jul12 TH Removed and added new column
            LstBoxFrm.Caption = "Print Delivery Notes - Select Supplier"
         Case Else
            LstBoxFrm.lblHead = "Site    " & TB & "Name" & Space$(15) & TB & "In Use" & TB & "No of items"
            LstBoxFrm.Caption = "Print Picking Tickets - Select Supplier"
      End Select
      ''If supsinarray > 0 Then shellsort suppliers(), 0, 0, ""
      For X = 1 To supsinarray
         r.record = ""
         
         lngSuptofind = Val(Mid$(suppliers(X), 16, 10))
         getsupplier "", lngSuptofind, lngFoundSup, sup
         LSet tempsup = sup
         'If edittype = 7 Then
         '   templine$ = Trim$(Left$(suppliers(x), 5)) & IIf(Trim$(Right$(suppliers(x), 5)) = "", "", " (DLO)") & TB
         'Else
            templine$ = Trim$(Left$(suppliers(X), 5)) & TB
         'End If
         If tempsup.inuse <> "N" Then
            If lngFoundSup Then
               templine$ = templine$ & Trim$(tempsup.name) & TB
               If Left$(tempsup.fullname, 1) = "#" Then
                  templine$ = templine$ & "#" & TB
               Else
                  templine$ = templine$ & "Y" & TB
               End If
               If Edittype = 1 Then
                  'templine$ = templine$ & Trim$(tempsup.Method) & TB '28Jul15 XN Added padding 92596
                  templine$ = templine$ & pad$(Trim$(tempsup.Method), 8) & TB
                  
                  templine$ = templine$ & Right$(suppliers(X), 5) & TB '11Jun12 TH DLO
                  
                  '28Jul15 XN Added 92596
                  If Trim$(tempsup.MinimumOrderValue) = 0 Then
                        templine$ = templine$ & Space$(9) & TB
                  Else
                  templine$ = templine$ & pad$(money(5) & Trim$(tempsup.MinimumOrderValue), 9) & TB  '28Jul15 XN Added 92596
                  End If
                                  
                                  '28Jul15 XN moved below 92596
                  'If Len(Trim$(tempsup.discountval)) > 0 And Not aborted Then
                     'templine$ = templine$ & money(5) & Trim$(tempsup.discountval)
                     'templine$ = templine$ & money(5) & Trim$(tempsup.discountval) & TB '06Jul12 TH Added tab
                  'Else
                     'templine$ = templine$ & Space$(5) & TB '06Jul12 TH Added to keep in tab order
                  'End If
                  
               End If
            Else
               templine$ = templine$ & "<Un-named>" & TB
               templine$ = templine$ & "?" & TB
               If Edittype = 1 Then templine$ = templine$ & "-" & TB
            End If
                     
            If Edittype = 1 Then
               LineCost$ = Format$(Val(Mid$(suppliers(X), 6, 10)) / 100, "#0.00;-#0.00")
            Else
               LineCost$ = Format$(Val(Mid$(suppliers(X), 6, 10)))
            End If
      
            If Not aborted Then
               'templine$ = templine$ & TB & Trim$(LineCost$)
               'templine$ = templine$ & Trim$(LineCost$)  '06Jul12 TH removed tab                                       28Jul15 XN removed two lines below and added large if statement 92596
               'If Edittype = 1 Then templine$ = templine$ & TB & pad$(tempsup.discountdesc, 30)
               If Edittype = 1 Then
                  templine$ = templine$ & pad$(money(5) & Trim$(LineCost$), 10) & TB '06Jul12 TH removed tab
                  If Len(Trim$(tempsup.discountval)) > 0 And Not aborted Then
                     'templine$ = templine$ & money(5) & Trim$(tempsup.discountval)
                     templine$ = templine$ & pad$(money(5) & Trim$(tempsup.discountval), 10) & TB '06Jul12 TH Added tab
                  Else
                     templine$ = templine$ & Space$(5) & TB '06Jul12 TH Added to keep in tab order
                  End If
                  
                  templine$ = templine$ & pad$(Trim$(tempsup.discountdesc), 30)
               Else
                  templine$ = templine$ & Trim$(LineCost$) '06Jul12 TH removed tab
               End If
                           
               If Edittype = 7 Then templine$ = templine$ & TB & IIf(Trim$(Right$(suppliers(X), 5)) = "", "", "DLO") '06Jul12 TH Added for DLO
            End If
         
            LstBoxFrm.LstBox.AddItem templine$
         Else
            intSupNotInUse = intSupNotInUse + 1
         End If
      Next
            
      setinput 0, k

      LstBoxFrm.cmdCancel.Caption = "E&xit"
            
      numofsups = LstBoxFrm.LstBox.ListCount
      If numofsups > 0 Then
         Screen.MousePointer = STDCURSOR
         LstBoxShow
         LineSelected = LstBoxFrm.LstBox.ListIndex + 1
         If LineSelected > 0 Then
            ReDim lines$(5)
            templine$ = LstBoxFrm.LstBox.text
            deflines templine$, lines$(), TB, 1, 0
            'If edittype = 7 Then   '16Jul12 TH Removed
            '   strDLOWard = Iff(InStr(lines$(1), "(DLO)") > 0, "DLO", "")
            'Else
               strDLOWard = lines$(5)  '11Jun12 TH Added (DLO)
            'End If
            'supsinarray = 0  '11Jun12 TH Added - DLO means we must reload (revisit if necessary to improve performance)
         End If
         If LineSelected = 0 Then
            k.escd = True
         ElseIf lines$(3) = "#" Then
            k.escd = True
            msg$ = "Cannot authorise orders from suppliers having" & cr & "their Full Name starting with a '#'."
            Screen.MousePointer = STDCURSOR
            popmessagecr "#Authorise Orders", msg$
         Else
            k.escd = False
         End If
      
         If k.escd Then
            supcode$ = ""
            Unload LstBoxFrm
            supsinarray = 0
         Else
            supcode$ = LstBoxFrm.LstBox.text
            posn = InStr(supcode$, Chr$(9))
            supcode$ = Trim$(Mid$(supcode$, 1, posn - 1))
            If Edittype <> 1 Then NoOfPTs = Val(Mid$(suppliers(LineSelected), 6, 10))
            If Edittype = 1 Then
              If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "Y", "MinimiumOrderValueCheck", 0)) = True Then
                  getsupplier supcode$, 0, 0, tempsup '13Jun08 - JP - F0025902
                  For X = 1 To supsinarray                                                                                                                                    '19Jan10 PJC F0074352 Added loop to find the correct supplier from array for minimal order.
                     If Trim$(Left$(suppliers(X), 5)) = supcode$ And Trim$(Right$(suppliers(X), 5)) = Trim$(strDLOWard) Then                                                                                                        '           "
                        If (Val(Mid$(suppliers(X), 6, 10)) / 100) < tempsup.MinimumOrderValue Then                                                                            '           "
                        'If (Val(Mid$(suppliers(LineSelected), 6, 10)) / 100) < tempsup.MinimumOrderValue Then                                                                '           "
                           ''askwin "Authorise Orders", "This is below the minimum order value for this supplier do you wish to continue?  Y/N", strAns, k
                           'strMsg = "The value of this order is " & money(5) & " " & Format((Val(Mid$(suppliers(LineSelected), 6, 10)) / 100), "0.00#.##") & crlf & crlf &   '19Jan10 PJC F0074352 replaced by line below
                           strMsg = "The value of this order is " & money(5) & " " & Format((Val(Mid$(suppliers(X), 6, 10)) / 100), "0.00#.##") & crlf & crlf & _
                           "The minimum order value for " & Trim$(tempsup.name) & " is " & money(5) & Format(tempsup.MinimumOrderValue, "0.00#.##") & crlf & crlf & _
                           "Do you wish to contine ?"
                           askwin "?Authorise Orders", strMsg, strAns, k
                           If strAns <> "Y" Then
                            k.escd = True
                            supcode$ = ""
                            supsinarray = 0
                           End If
                        End If
                        Exit For                                                                                                                                              '19Jan10 PJC F0074352
                     End If                                                                                                                                                   '           "
                  Next                                                                                                                                                        '           "
             ''MsgBox Format$(Val(Mid$(suppliers(LineSelected), 6, 10)) / 100)
              
             End If
            End If
         End If
         numofsups = numofsups + intSupNotInUse   '
      Else
         Select Case Edittype
            Case 1: msg$ = "No orders to authorise."
            Case 2: msg$ = "No EDI orders to send."  '09Nov06 TH Added
            Case 5: msg$ = "No picking tickets to print."
            Case 7: msg$ = "No Delivery Notes to print."
            Case 9: msg$ = "No Credit Orders to authorise."
         End Select
         Screen.MousePointer = STDCURSOR
         popmessagecr "Authorise Orders", msg$
         k.escd = True
         supsinarray = 0
      End If
   End If

   Screen.MousePointer = STDCURSOR

   InitAltSupplier
   
   If k.escd Then Unload LstBoxFrm '19Jul05 TH (#81572)

End Sub

Sub updateoutstanding(Qty!, d As DrugParameters)
'ASC 20Mar93--update d.outstanding on suppliers side--------

Dim foundPtr&

   getdrug d, 0, foundPtr&, True                '<-LOCK
   If foundPtr& Then
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "N", "LogOutstandingQty", 0)) = True Then
         WriteLog dispdata$ & "\OutStand.log", SiteNumber%, UserID$, "Outstanding Quantity For " & d.SisCode & " WAS " & Format$(d.outstanding)
      End If
      d.outstanding = d.outstanding + Qty!
      putdrug d
     If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "", "N", "LogOutstandingQty", 0)) = True Then
         WriteLog dispdata$ & "\OutStand.log", SiteNumber%, UserID$, "Outstanding Quantity For " & d.SisCode & " IS " & Format$(d.outstanding)
      End If
   Else
      popmessagecr "!n!boutstanding", "Item not on file"
   End If

End Sub

Sub updateprice(Edittype, SisCode$, qtyrec$, ord As orderstruct, purprice$, automatic, sislistprice$, ByRef strTitle As String, ByRef strMsg As String, ByRef lngOrderPointer As Long, ByRef strWarnMsg As String, ByRef strWarnMsg2 As String, ByVal strOrdOutstanding As String, ByVal lngLogThreadID As Long)
'----------------------------------------------------------------------------
'
'                     Calculates value of stock from current value
'                     and value of that received (Averaged)
'Uses EditType  3  4 -4
'01Aug08 TH/CKJ (F0023465) Extra fencepost to protect from "double receipt"
'14Oct08 TH Stop none numeric entry (".") being saved to order file - was breaking reporting  (F0030065)
'03Nov08 TH (F0037389) Always update if receipt (or set default if non stocked)
'03Nov08 TH (F0025585) mask potentially exponential entry as cost.
'04Aug09 TH () Added logging for double receipt including logThreadId as input param
'19Feb13 TH PSO Removed spurious call to set msg (TFS 56147)
'03Aug15 TH Mods to stop exponential in price last paid (TFS 102570)
'14Dec15 TH Reverted mod because the mask only protects manual price entry and we can get exp costs
'           from automated receipt (internal order). Also added mod to remve exp where cost changed but no stock(TFS 137904)
'----------------------------------------------------------------------------

Dim foundPtr&, done%, majordif%, valerror%, valid%, escd%, Overpriced%          'foundsup%,
Dim PrintPrice$, title$, msg$, drug$, Completed$, qtyrecnow$
Dim totprintprice$, printdesc$, islive$, allinecost$, LineCost$
Dim VATcost$, poundpurprice$, temp$, prompt$, ans$, credit$, dat$
Dim orderdate$, yestr$, highprice$, lowprice$
Dim ndbd&
Dim pricenow!, recvalue!, newstocklvl!, stockvalue!, ye!
Dim mousewas% '22Feb99 TH
Dim updatecost%, locfreeflag%  '26Oct99 AE
Dim tmppurprice$                             '15May00 EAC/AE Added

Dim blnDoNotUpdateSisListPrice As Integer    '19Apr04 TH Added

Dim strAbortProductUpdateMsg As String    '18Oct04 SQL
Dim strWarnProductUpdateMsg As String
Dim strStockWarnProductUpdateMsg As String
Dim strMsg2 As String
Dim strDesc As String
Dim blnAbort As Boolean
Dim strPricemsg As String
Dim strDrugDesc As String
Dim strTemp As String
Dim strPatName As String
Dim strPatDOB As String
Dim strPatCasenumber As String
Dim strPatNHNumber As String


   blnAbort = False                       '11Sep05 TH

   locfreeflag = freeflag
   d.SisCode = SisCode$
   getdrugsup d, 0, foundPtr&, False, ord.supcode
   If (ord.internalmethod = "I" Or ord.internalmethod = "M") And (Trim$(ord.cost) <> "" And Val(ord.cost) <> 0) Then  '     "
      purprice$ = LTrim$(ord.cost)
      PrintPrice = Format$(Val(purprice$) / 100, "#0.00;-#0.00")
      If Not automatic Then popmessagecr "!n!bInternal Order", " Cost is " & money(5) + Trim$(PrintPrice$) + " per " + RTrim$(d.convfact) + " " + LCase$(d.PrintformV)
   Else
      'If ordered from another ASCribe account prices
      'are correct unless drug not there when price  = 0
      If Not automatic Then
         msg$ = ""
         drug$ = d.DrugDescription 'drug$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
         plingparse drug$, "!"
         strTitle = RTrim$(drug$)
         getsupplier ord.supcode, 0, 0, sup
         If Trim$(d.tradename) <> "" Then
            msg$ = msg$ + " Trade name            " & vbCr
            strMsg2 = strMsg2 & ": " & d.tradename & vbCr
         End If
         'msg$ = msg$ + "  Current supplier      : " + Trim$(ord.supcode) + "  " + sup.name & vbCr ' now shows current supplier
         msg$ = msg$ + "  Current supplier   " & vbCr '   : " + Trim$(ord.supcode) + "  " + sup.name & vbCr ' now shows current supplier
         strMsg2 = strMsg2 & ": " & Trim$(ord.supcode) + "  " + sup.name & vbCr
         If Edittype = -4 Then  '12Aug05 TH Not relevant if credit (#82106)
            Completed$ = ""
         ElseIf Val(ord.outstanding) - Val(qtyrec$) = 0 Then     '!!** not so for reconciliation
            Completed$ = " (ITEM COMPLETED)"              ' outstanding = 0 for completed
         Else
            Completed$ = " (PART)"
         End If
         msg$ = msg$ + "  Order number  " & vbCr
         strMsg2 = strMsg2 & ": " & ord.num & Completed$ & vbCr
         getsupplier d.supcode, 0, 0, sup

         If Len(Trim$(d.contno)) > 0 Or Val(d.contprice) > 0 Then
            If d.supcode <> ord.supcode Then
               msg$ = msg$ + "  Contract supplier " & vbCr
               strMsg2 = strMsg2 & ": " & sup.name & vbCr
            End If
            msg$ = msg$ + "  Contract number " & vbCr
            strMsg2 = strMsg2 & ": " & d.contno & vbCr
            PrintPrice$ = Format$(Val(d.contprice) / 100, "#0.00;-#0.00")
            'msg$ = msg$ + "  Contract price       : " & money(5) + Trim$(PrintPrice$) + " per " + RTrim$(d.convfact) + " " + LCase$(d.PrintformV) & vbCr
            msg$ = msg$ + "  Contract price " & vbCr '      : " & money(5) + Trim$(PrintPrice$) + " per " + RTrim$(d.convfact) + " " + LCase$(d.PrintformV) & vbCr
            strMsg2 = strMsg2 & ": " & money(5) + Trim$(PrintPrice$) + " per " + RTrim$(d.convfact) + " " + LCase$(d.PrintformV) & vbCr
         Else
            If d.supcode <> ord.supcode Then
               'msg$ = msg$ + "  Primary supplier     : " + sup.name
               msg$ = msg$ + "  Primary supplier " & vbCr & vbCr '    : " + sup.name
               strMsg2 = strMsg2 & ": " & sup.name & "  (Not on contract)" & vbCr & vbCr
            Else
               msg$ = msg$ + "  (Not on contract)" & vbCr & vbCr
               strMsg2 = strMsg2 & vbCr & vbCr
            End If
         End If

         If Edittype = 3 Then
            qtyrecnow$ = qtyrec$
         Else
            qtyrecnow$ = ord.received
         End If
                 
         If Edittype = 3 Then
            totprintprice$ = Format$((Val(d.sislistprice) * Val(qtyrecnow$)) / 100, "#0.00;-#0.00")
            PrintPrice$ = Format$(Val(d.sislistprice) / 100, "#0.00;-#0.00")
            'printdesc$ = "  Price last paid      :"
            printdesc$ = "  Price last paid" & Chr(13) '    :"
         Else
            PrintPrice$ = Format$(Val(d.lastreconcileprice) / 100, "#0.00;-#0.00")
            totprintprice$ = Format$((Val(d.lastreconcileprice) * Val(qtyrecnow$)) / 100, "#0.00;-#0.00")
            'printdesc$ = "  Price last reconciled :"
            printdesc$ = "  Price last reconciled" & Chr(13) ' :"
         End If

         'msg$ = msg$ + printdesc$ + " " & money(5) + Trim$(totprintprice$) + " (or " & money(5) + Trim$(PrintPrice$) + " per " + Trim$(Str$(Val(d.convfact))) + " " + LCase$(d.PrintformV) + ")" & vbCr
         msg$ = msg$ & printdesc$ & Chr(13)
         strMsg2 = strMsg2 + ": " & money(5) + Trim$(totprintprice$) + " (or " & money(5) + Trim$(PrintPrice$) + " per " + Trim$(Str$(Val(d.convfact))) + " " + LCase$(d.PrintformV) + ")" & vbCr & vbCr

         If Edittype = 3 Then
            'msg$ = msg$ + "  Current stock level  : " + FormatVal$(d.stocklvl, 2, 6) + " " + LCase$(d.PrintformV) + islive$ '26Sep00 TH
            msg$ = msg$ + "  Current stock level " & Chr(13) ' : " + FormatVal$(d.stocklvl, 2, 6) + " " + LCase$(d.PrintformV) + islive$ '26Sep00 TH
            strMsg2 = strMsg2 & ": " & FormatVal$(d.stocklvl, 2, 6) + " " + LCase$(d.PrintformV) + islive$
            'If UCase$(d.livestockctrl) = "Y" Then msg$ = msg$ + " (Live)" & vbCr Else msg$ = msg$ & vbCr
            If UCase$(d.livestockctrl) = "Y" Then strMsg2 = strMsg2 + " (Live)" & vbCr Else strMsg2 = strMsg2 & vbCr
            allinecost$ = Format$(Val(d.cost) * Val(qtyrec$) / 100, "#0.00;-#0.00")
            LineCost$ = Format$(Val(d.cost) / 100, "#0.00;-#0.00")
            'msg$ = msg$ + "  Current issue price  : " & money(5) + Trim$(allinecost$) + " (or " & money(5) + Trim$(LineCost$) + " per " + Trim$(d.convfact) + " " + LCase$(d.PrintformV) + ")" & vbCr
            msg$ = msg$ + "  Current issue price" & Chr(13) '  : " & money(5) + Trim$(allinecost$) + " (or " & money(5) + Trim$(LineCost$) + " per " + Trim$(d.convfact) + " " + LCase$(d.PrintformV) + ")" & vbCr
            strMsg2 = strMsg2 & ": " & money(5) + Trim$(allinecost$) + " (or " & money(5) + Trim$(LineCost$) + " per " + Trim$(d.convfact) + " " + LCase$(d.PrintformV) + ")" & vbCr
         Else
            LineCost$ = Format$(Val(ord.cost) * Val(ord.received) / 100, "#0.00;-#0.00")
            VATcost$ = Format$(Val(ord.cost) * Val(ord.received) * VAT(Val(d.vatrate)) / 100, "#0.00;-#0.00")
            'msg$ = msg$ + "  Agreed Price          : " & money(5) + Trim$(LineCost$)
            msg$ = msg$ + "  Agreed Price " & Chr(13) '         : " & money(5) + Trim$(LineCost$)
            strMsg2 = strMsg2 & ": " & money(5) + Trim$(LineCost$)
            'If TransLogVAT Then msg$ = msg$ + "  or " & money(5) + Trim$(VATcost$) + " inc. " & money(9) & " @" + Str$(100 * (VAT(Val(d.vatrate)) - 1)) + "%"
            If TransLogVAT Then strMsg2 = strMsg2 + "  or " & money(5) + Trim$(VATcost$) + " inc. " & money(9) & " @" + Str$(100 * (VAT(Val(d.vatrate)) - 1)) + "%"
            msg$ = msg$ & vbCr
            qtyrec$ = ord.received
            allinecost$ = Format$(Val(ord.cost) * Val(qtyrec$) / 100, "#0.00;-#0.00")
         End If
         If getPSO() Then
            FillHeapPSOrderInfo gPRNheapID, ord.OrderID, Edittype, 0
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
            msg$ = msg$ & "  " & IIf(Edittype = 3, "Order ", "Invoice ") & " for Patient : " & strPatName & crlf & "  DOB : " & strPatDOB & crlf & "  Case Num : " & strPatCasenumber & crlf & "  NH Number : " & strPatNHNumber & crlf
            'frmEnhTxtWin.lblExtra.Top = 2000 '970
         End If
         msg$ = msg$ & vbCr & "  Enter purchase price (" & money(9) & " Exclusive) for " & Trim$(qtyrec$) & " x " & Trim$(Str$(Val(d.convfact))) & " " & LCase$(d.PrintformV) '+ " " & money(5)    '13Apr00 TH *GST*
         done = False
         Do
            k.Max = 9
            k.min = 1
            k.decimals = True
            purprice$ = Format$(Val(ord.cost) * Val(qtyrec$) / 100, "#0.00;-#0.00")
            purprice$ = Trim$(purprice$)
            If Trim$(purprice$) <> "0.00" Then
               If Val(purprice$) = 0 Then purprice$ = ""
            End If
            k.helpnum = 440
            Unload frmEnhTxtWin
            
            If Edittype = 3 Then frmEnhTxtWin.Check1.Value = 1  '03Nov08 TH (F0037389)Always update if receipt (or set default if non stocked)
               
            If d.sisstock = "N" And (ord.internalmethod <> "I" Or ord.internalmethod <> "E") Then
               frmEnhTxtWin.Tag = "reconcil"      'updated if checkbox is checked
               frmEnhTxtWin.Check1.Caption = "Use This Price For Next Order"
            End If                                '   "
            frmEnhTxtWin.Caption = strTitle
            frmEnhTxtWin.lblbox.Caption = msg$ & crlf & crlf & " " & money(5) & " "
            frmEnhTxtWin.txtBox = purprice$
            frmEnhTxtWin.txtBox.SelStart = 0
            frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
            frmEnhTxtWin.txtBox.Top = frmEnhTxtWin.Height - 1400 '(frmEnhTxtWin.lblExtra.top - 70)
            frmEnhTxtWin.txtBox.Left = 400
            HorizCentreForm frmEnhTxtWin
            frmEnhTxtWin.lblExtra.Left = frmEnhTxtWin.Width / 3
            frmEnhTxtWin.lblExtra.Height = frmEnhTxtWin.lblbox.Height
            frmEnhTxtWin.lblExtra.Width = ((frmEnhTxtWin.Width / 3) * 2) - 500
            frmEnhTxtWin.lblExtra.Top = frmEnhTxtWin.lblbox.Top
            frmEnhTxtWin.lblExtra.Visible = True
            frmEnhTxtWin.lblExtra.Caption = strMsg2
            'frmEnhTxtWin.Caption = " " & money(5) & " "
            


            'frmEnhTxtWin.lblbox.Caption = msg$ '19Feb13 TH Removed (TFS 56147)
               
            k.escd = False
            mousewas% = Screen.MousePointer
            Screen.MousePointer = 0
            ShowFrmEnhTxtWin
            Screen.MousePointer = mousewas%
            frmEnhTxtWin.Tag = ""
            purprice$ = Trim$(frmEnhTxtWin.txtBox)
            
            If InStr(Str$(CSng(Val(purprice$))), "E") > 0 Then                                  '03Nov08 TH Reverted to check here as trying to remove exponential could cause rounding issues.
               popmessagecr "!n!iABORTING", "Invalid cost entered. Please check and retry."     '  "
               k.escd = True                                                                    '  "
            End If                                                                              '  "

            If Not k.escd Then                                             '26Oct99 AE Added block
               If Val(purprice$) = 0 Then                                  'User must now confirm when
                  purprice$ = "0" '14Oct08 TH This essentially handles none numeric entry (".") (F0030065)
                  If ConfirmedReceiveFree(Edittype, ord, False) Then    'receiving free goods
                     locfreeflag = True
                     done = True
                  Else
                     k.escd = True
                     locfreeflag = False
                  End If
               End If
            End If
            sislistprice$ = ""
            If frmEnhTxtWin.Check1.Value = 1 And Not k.escd Then '01Feb99 TH If checkbox ticked update received price '015May00 EAC/AE changed  = true to = 1 AND NOT k.escd
               If Val(qtyrec$) > 0 And Not locfreeflag Then
                 tmppurprice$ = Format$(Val(purprice$) * 100 / Val(qtyrec$), "#0.00;-#0.00")
               Else
                  tmppurprice$ = "0"
               End If
               tmppurprice$ = ExpandExp$(tmppurprice$)  '03Aug15 TH Added to stop exponential in price last paid (TFS 102570)
               sislistprice$ = tmppurprice$
               d.sislistprice = tmppurprice$
            Else
               blnDoNotUpdateSisListPrice = True
            End If
            frmEnhTxtWin.Check1.Value = 0
            Unload frmEnhTxtWin
            If Not locfreeflag Then                    '26Oct99 AE No need for cost checks if user has confirmed it is a free item
               poundpurprice$ = purprice$
               If Val(qtyrec$) > 0 And Not k.escd Then
                  purprice$ = Trim$(Str$((Val(purprice$) * 100 / Val(qtyrec$))))
               Else
                  purprice$ = "0"
               End If
               If Not k.escd Then
                  If Edittype = 3 Then
                     pricenow! = Val(d.cost)
                  Else
                     pricenow! = Val(ord.cost)
                  End If
                  highprice$ = Format$(Highfact! * pricenow!, "#0.00;-#0.00")
                  lowprice$ = Format$(Lowfact! * pricenow!, "#0.00;-#0.00")
                  If Val(purprice$) > Val(highprice$) Or Val(purprice$) < Val(lowprice$) Then
                     If Val(purprice$) >= 2 * pricenow! Or Val(purprice$) <= pricenow! / 2 Then
                        majordif = True
                        title$ = "WARNING"
                        strDesc = d.DrugDescription 'strDesc = GetStoresDescription()  XN 4Jun15 98073 New local stores description
                        plingparse strDesc, "!"
                        strPricemsg = "  PRICE ENTERED FOR " & Trim$(strDesc) & " IS "
                        If Val(purprice$) > pricenow! Then
                           strPricemsg = strPricemsg & "MORE THAN DOUBLE"
                        Else
                           strPricemsg = strPricemsg & "LESS THAN HALF"
                        End If
                        strPricemsg = strPricemsg & " EXPECTED COST"
                        popmessagecr "!" & title$, strPricemsg '31May05TH Added pling
                        Beep
                     Else
                        majordif = False
                        title$ = "WARNING"
                     End If
                     If Edittype = 3 Then
                        temp$ = " Current"
                     Else
                        temp$ = "  Agreed"
                     End If
                     poundsandpence poundpurprice$, False
                     strDrugDesc = d.DrugDescription  'strDrugDesc = GetStoresDescription() XN 4Jun15 98073 New local stores description        '16Oct05 TH (#81725)
                     plingparse strDrugDesc, "!"                  '    "
                     prompt$ = "   " & strDrugDesc & crlf & crlf  '    "
                     prompt$ = prompt$ & "   Price entered = " & money(5) + Trim$(poundpurprice$) + Chr$(10)
                     prompt$ = prompt$ & " " + temp$ + " price  = " & money(5) + Trim$(allinecost$) + Chr$(10) + Chr$(10)
                     prompt$ = prompt$ & Space$(10) + "Re-enter   Y/N  " + Chr$(10)
                     mousewas% = Screen.MousePointer
                     Screen.MousePointer = 0
                     popmsg title$, prompt$, 3 + 32, ans$, k.escd
                     Screen.MousePointer = mousewas%
                     ''If ans$ = "Y" Then strMsg2 = "" '31May05 TH Added
                     If escd% Then k.escd = True
                     If ans$ = "N" And Not escd% And majordif Then
                        askwin "", "Are you certain these prices are correct?  Y/N", ans$, k
                        If ans$ = "Y" And Not k.escd Then
                           ans$ = "N" ' for compatibility with original Q
                        Else
                           k.escd = True
                        End If
                     End If
      
                     If ans$ = "N" And Not k.escd Then
                        Select Case Storepasslvl
                           Case 6, 8
                              done = True
                              If Edittype = 3 Then
                                 Overpriced = True
                              Else
                                 Overpriced = False
                              End If
                           Case 5, 8
                              done = True
                              If Abs(Edittype) = 4 Then
                                 If Edittype = -4 Then credit$ = "Credit " Else credit$ = ""
                                 'WriteLog "\ascroot\reconcil.log", 0, "", d.SisCode & " " & d.Description + "  Qty:" + qtyrecnow$ + "   Reconciled at " & money(5) + poundpurprice$ + " " + temp$ + " price œ" + allinecost$ + "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " + ord.num   '     "
                                 ''WriteLog siteinfo$("dispdataDRV", "") & "\reconcil.log", 0, "", d.SisCode & " " & d.Description + "  Qty:" + qtyrecnow$ + "   Reconciled at " & money(5) + poundpurprice$ + " " + temp$ + " price œ" + allinecost$ + "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " + ord.num    '     "
                                 'WriteLog rootpath$ & "\reconcil.log", 0, "", d.SisCode & " " & d.Description + "  Qty:" + qtyrecnow$ + "   Reconciled at " & money(5) + poundpurprice$ + " " + temp$ + " price œ" + allinecost$ + "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " + ord.num   XN 4Jun15 98073 New local stores description
                                 WriteLog rootpath$ & "\reconcil.log", 0, "", d.SisCode & " " & d.LabelDescription + "  Qty:" + qtyrecnow$ + "   Reconciled at " & money(5) + poundpurprice$ + " " + temp$ + " price œ" + allinecost$ + "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " + ord.num
                              End If
                           Case Else
                              nopass
                        End Select
                     End If
                  Else
                     done = True
                  End If
               End If
            End If
         Loop Until done Or k.escd
      Else  'Automatic receive
         If locfreeflag Then
            If Not ConfirmedReceiveFree(Edittype, ord, True) Then k.escd = True
         ElseIf Val(ord.cost) = 0 Then
            'log automatic recipts at 0 cost
            drug$ = d.LabelDescription    'drug$ = d.Description XN 4Jun15 98073 New local stores description
            plingparse drug$, "!"
            drug$ = Trim$(drug$)
                                                                                          
            msg$ = "Order " & Format$(ord.num) & ": " & d.SisCode$ & "(" & drug$ & ") "   'Log when free items are automatically received
            msg$ = msg$ & "Automatically received at zero cost"
            WriteLog dispdata$ & "\ZeroC.log", 2, UserID$, msg$
         End If
         If Not k.escd Then purprice$ = Trim$(ord.cost)
               
      End If
   End If

   If Not k.escd Then
      If Edittype = 3 Then
         blnAbort = False
         If lngOrderPointer > 0 Then '06Apr05 TH Here we must try and lock the order and check it is correct status !!
            'If Not k.escd Then   '11Sep05 TH Surely utterly superfluous
            '04Aug09 TH Added Double Receipt logging
            If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
               WriteLogSQL "UpdatePrice: About to Lock Order row, WOrderID = " & Format$(lngOrderPointer), "DoubleRecLog", 2, lngLogThreadID
            End If
            '---------------
            getorder ord, (lngOrderPointer), Edittype, True
            If (ord.status <> "3") Or (strOrdOutstanding <> ord.outstanding) Then   'do a comparison on orig outstanding too !!!!                                                                                              '   "       Added as way out if rec
               ''popmessagecr "!Ascribe", "This Order Line Has already been recieved. Please check the Order Logs for Confirmation"  '   "       previously locked and then
               strWarnProductUpdateMsg = "This Order Line has already been received or part received since beginning this Receipt. Please check the Order Logs for Confirmation"
               strWarnMsg = strWarnProductUpdateMsg
               PutOrder ord, (lngOrderPointer), "WOrder"                                                                                        '   "       received
               blnAbort = True
               lngOrderPointer = 0
               '04Aug09 TH Added Double Receipt logging
               If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                  WriteLogSQL "UpdatePrice: Line Already Processed, Changes Aborted", "DoubleRecLog", 0, lngLogThreadID
               End If
               '-------
               '06Jan06 TH This is the end of the transactional bound operation so we commit here
               'If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then
               '   gTransport.Connection.Execute "Commit Transaction"
               'End If
            Else
               '06Jan06 TH This is the start of the transactional bound operation so we begin here
               If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingRec", 0)) Then
                  gTransportConnectionExecute "Begin Transaction"      '15Aug12 CKJ
               End If
            End If                                                                                                                 '   "
            'Else
            '   lngOrderPointer = 0
            'End If
         Else
            blnAbort = True  '01Aug08 TH/CKJ (F0023465) Extra fencepost to protect from "double receipt"
            WriteLog dispdata$ & "\DblRec.log", SiteNumber%, UserID$, "Update price called with no lngPointer - Possible trap of double receipt (F0023465)"
         End If
         '11Sep05 TH --------------

         If Not blnAbort Then  '11Sep05 TH
            '04Aug09 TH Added Double Receipt logging
            If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
               WriteLogSQL "UpdatePrice: About to Lock Drug", "DoubleRecLog", 3, lngLogThreadID
            End If
            '-------
            getdrugsup d, foundPtr&, (foundPtr&), True, ord.supcode   ' 01Jun02 ALL/ATW
            If UCase$(d.livestockctrl) = "Y" Then
               'check current values
               valerror = False
               If Val(d.convfact) = 0 Then
                  ''popmessagecr "!n!iABORTING", "Conversion factor not entered for " + d.SisCode
                  strAbortProductUpdateMsg = "Conversion factor not entered for " + d.SisCode
                  valerror = True
               End If
               'If Val(d.cost) = 0 Then
               If Val(d.cost) = 0 And InStr(d.cost, "0") = 0 Then   '22Jun99 TH Zero price now acceptable
                  ''popmessagecr "!n!iWARNING", "Cost of current stock not entered purchase price assumed for " + d.SisCode
                  strWarnProductUpdateMsg = "Cost of current stock not entered purchase price assumed for " + d.SisCode
                  d.cost = purprice$
               End If
               If Val(d.stocklvl) < 0 Then
                  Beep
                  Beep
                  'If Trim$(d.storesdescription) <> "" Then
                   '  temp$ = d.storesdescription
                    ' replace temp$, "!", " ", 0
                     ''popmessagecr "!n!iABORTING", "Stock level negative for " & Trim$(temp$) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                     'strAbortProductUpdateMsg = "Stock level negative for " & Trim$(temp$) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                  'Else
                     'temp$ = d.Description
                     'replace temp$, "!", " ", 0
                     ''popmessagecr "!n!iABORTING", "Stock level negative for " & Trim$(temp$) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                     'strAbortProductUpdateMsg = "Stock level negative for " & Trim$(temp$) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                  'End If  XN 4Jun15 98073 New local stores description
                                  temp$ = d.DrugDescription
                                  replace temp$, "!", " ", 0
                                  strAbortProductUpdateMsg = "Stock level negative for " & Trim$(temp$) & " (" & d.convfact + " " + Trim$(d.PrintformV) + ") ; " & d.SisCode
                  valerror = True
               End If
               If Not valerror Then
                  updatecost = False                                                         '26Oct99 AE Added block
                  If Not locfreeflag Then updatecost = True                                  'update price last paid if *not* recieving at zero cost...
                  If locfreeflag And (Val(d.cost) = 0) Then updatecost = True                '...or if receiving free and the issue cost is zero
                  '---------------------------
                  ord.received = LTrim$(Str$(Val(ord.received) - Val(qtyrec$)))
                  stockvalue! = 1! * dp!(Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost) ' 14Apr91 CKJ'23Jun93 CKJ dp
                  recvalue! = 1! * (Val(qtyrec$) * Val(purprice$)) ' 14Apr91 CKJ
                  newstocklvl! = Val(qtyrec$) + dp!(Val(d.stocklvl) / Val(d.convfact)) 'in whole NSV's '23Jun93 CKJ dp
                  If newstocklvl! <> 0 Then
                     'd.cost = LTrim$(Str$(dp!((stockvalue! + recvalue!) / newstocklvl!)))            '14Dec15 TH Replaced (TFS 137904)
                     'd.cost = LTrim$(Str$(NoExp(dp!((stockvalue! + recvalue!) / newstocklvl!)))) '31Aug08 TH Replaced above to avoid exponentials when users enter stoopid amount (F0025585) '03Nov08 TH Removed - now just mask above
                     d.cost = LTrim$(Str$(NoExp(dp!((stockvalue! + recvalue!) / newstocklvl!))))      '14Dec15 TH Reverted this mod because the mask only protects manual price entry and we can get exp costs from automated receipt (internal order) (TFS 137904)
                  Else
                     'If updatecost Then d.cost = purprice$                                '26Oct99 AE
                     If updatecost Then d.cost = ExpandExp$(purprice$)    '14Dec15 TH Added to ensure cost is not exponential (TFS 137904)
                     ''popmessagecr "!n!bWARNING contact supervisor", "Stock level was 0 ! therefore no stock to price"  '25.03.92 ASC should not fire now _ve valerr stops this
                     strStockWarnProductUpdateMsg = "Stock level was 0 ! therefore no stock to price"
                  End If   '!!** needs sorting
                  'If updatecost And (Not blnDoNotUpdateSisListPrice) Then d.sislistprice = purprice$    '19Apr04 TH Added Clause (#73293)
                  If updatecost And (Not blnDoNotUpdateSisListPrice) Then d.sislistprice = ExpandExp$(purprice$)    '03Aug15 TH Replace above (TFS 102570)
                  'If updatecost Then d.sislistprice = purprice$   '03Nov08 TH (F0037390) Removed clause because it was very stoopid - we always alter update price on a receipt !!!!!!
                  d.stocklvl = LTrim$(Str$((Val(qtyrec$) * Val(d.convfact)) + Val(d.stocklvl)))
                  'If Overpriced Then WriteLog siteinfo$("dispdataDRV", "") & "\ascroot\receive.log", SiteNumber%, UserID$, d.SisCode & " " & d.Description & "  Qty:" & qtyrecnow$ & "   Received at " & money(5) & poundpurprice$ & " " & temp$ & " price œ" & allinecost$ & "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " & ord.num
                  'If Overpriced Then WriteLog rootpath$ & "\receive.log", SiteNumber%, UserID$, d.SisCode & " " & d.Description & "  Qty:" & qtyrecnow$ & "   Received at " & money(5) & poundpurprice$ & " " & temp$ & " price œ" & allinecost$ & "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " & ord.num  XN 4Jun15 98073 New local stores description
                  If Overpriced Then WriteLog rootpath$ & "\receive.log", SiteNumber%, UserID$, d.SisCode & " " & d.LabelDescription & "  Qty:" & qtyrecnow$ & "   Received at " & money(5) & poundpurprice$ & " " & temp$ & " price œ" & allinecost$ & "  Supplier: " & ord.supcode & "  " & credit$ & "Order No: " & ord.num
               Else
                  k.escd = True ' passes abort message back 25Mar92 ASC
               End If
            Else
               ord.received = LTrim$(Str$(Val(ord.received) - Val(qtyrec$)))
               d.cost = purprice$
               'If Not blnDoNotUpdateSisListPrice Then d.sislistprice = purprice$   '19Apr04 TH Added clause  (#73293)
               'd.sislistprice = purprice$  '03Nov08 TH (F0037390) Removed clause because it was very stoopid - we always alter update price on a receipt !!!!!!
               d.sislistprice = ExpandExp$(purprice$)    '03Aug15 TH Replace above (TFS 102570)
               d.stocklvl = LTrim$(Str$((Val(qtyrec$) * Val(d.convfact)) + Val(d.stocklvl)))
            End If
   
            If Val(ord.outstanding) = Val(qtyrec$) And Trim$(ord.orddate) <> "" Then    'if all order received  12Jul93 CKJ Added orddate
               'LEAD TIME
               '---------
               dat$ = thedate(True, True)
               orderdate$ = Left$(ord.orddate, 2) & "." & Mid$(ord.orddate, 3, 2) & "." & Right$(ord.orddate, 4)   '03May98 CKJ Y2K
               datetodays orderdate$, dat$, ndbd&, ye!, yestr$, valid%
               If Len(Trim$(d.LeadTime)) Then
                  d.LeadTime = LTrim$(Str$(((Val(d.LeadTime) * 5) + ndbd& + 1) / 6))
               Else
                  d.LeadTime = LTrim$(Str$(ndbd& + 1))
               End If
            End If
            putdrug d '', foundPtr&     '<== UNLOCK   ' 01Jun02 ALL/ATW
            '04Aug09 TH Added Double Receipt logging
            If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
               WriteLogSQL "UpdatePrice: Drug Record has been updated if required and unlocked", "DoubleRecLog", 4, lngLogThreadID
            End If
            '-------
            If strAbortProductUpdateMsg <> "" Then
               If lngOrderPointer > 0 Then
                  PutOrder ord, (lngOrderPointer), "WOrder"   '<== UNLOCK here before modal message !!  '11Sep05 TH Unlock order here before any warnings !
                  '06Jan06 TH This is the end of the transactional bound operation so we commit here
                  If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingRec", 0)) Then
                     gTransportConnectionExecute "Commit Transaction"      '15Aug12 CKJ
                  End If
                  '04Aug09 TH Added Double Receipt logging
                  If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
                     WriteLogSQL "UpdatePrice: Drug Record has been Unlocked, update of drug was aborted so order now unlocked and abort flags set", "DoubleRecLog", 0, lngLogThreadID
                  End If
                  '-------
               End If
               lngOrderPointer = 0                                                             'The receipt is aborted and the order released so this is flagged to receiveitem sub
               Beep
               Beep
               popmessagecr "!n!iABORTING", strAbortProductUpdateMsg
            Else
               'We are inside the order lock here so we need to pass the msgs back up for after the lock is released !
               If strWarnProductUpdateMsg <> "" Then
                  ''popmessagecr "!n!iWARNING", strWarnProductUpdateMsg
                  strWarnMsg = strWarnProductUpdateMsg          '11Sep05 TH send these messages back up outside the scope of locking
               End If
               If strStockWarnProductUpdateMsg <> "" Then
                  ''popmessagecr "!n!bWARNING contact supervisor", strStockWarnProductUpdateMsg
                  strWarnMsg2 = strStockWarnProductUpdateMsg    '11Sep05 TH send these messages back up outside the scope of locking
               End If
            End If
            ''End If
         'ELSE  Reconciliation 1Feb94 CKJ Now in Finanasc
         End If
      End If
   Else                        '11Sep05 TH Added as a marker that order has NOT been locked during a receipt
      lngOrderPointer = 0      '    "
      '04Aug09 TH Added Double Receipt logging
      If TrueFalse(TxtD(dispdata$ & "\Winord.ini", "Logging", "N", "DoubleRecLogging", 0)) Then
         WriteLogSQL "UpdatePrice: Order has not been updated and drug not written, abort flags set", "DoubleRecLog", 0, lngLogThreadID
      End If
      '-------
   End If

   InitAltSupplier      '10Aug99 CFY Added
   
End Sub


Public Function GetTableName(ByVal intEditType As Integer) As String
'For SQL
Dim strTable As String

   Select Case intEditType
      Case 1, 2, 3, 9: strTable = "WOrder"
      Case 4:          strTable = "WReconcil"
      Case Else:       strTable = "WRequis"
   End Select
   GetTableName = strTable

End Function

Sub EnterDrug(drug$, Caption$)
'12Mar07 TH Moved from Orderlibs to be refernced in logview\productstockeditor
' And then , later that day, moved back

   If drug$ = "" Then
      setinput 0, k
      k.Max = 14
      k.min = 2
      k.helpnum = 360
      InputWin Caption$, "Enter item code ", drug$, k
   End If

End Sub

Sub DisplayRobotLoading(ByVal isiteNumber As Integer, ByVal robotLocation As String)
' Will display the robot loading form.
' 07Jan09 XN F0042698
    
Dim httpAddress As String              ' web url to icw web f4 desktop
Dim httParamaters As String            ' parameters for icw web f4 desktop
Dim httpServerAndWebFolder As String   ' web server used to call this application
Dim strHideCost As String              ' if cost are to be hidden or displayed on the F4 screens

   ' Get web server and directory used to call this application
   httpServerAndWebFolder = ParseCommandURLServerAndWebFolder(Command$)

   ' if server or directory not present then can only use old F4 screens
   If (httpServerAndWebFolder = Empty) Then
      MessageBox "Could not get web site URL.", MB_OK + MB_ICONSTOP, "Invalid web info"
      Exit Sub
   End If

   ' Determine if costs are to be hidden
   If (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then
      strHideCost = "Yes"
   Else
      strHideCost = "No"
   End If

   ' Generate the address for the icw robot loading screens
   httpAddress = httpServerAndWebFolder + "/application/RobotLoading/ICW_RobotLoading.aspx"
   httParamaters = "SessionID=" & Format$(g_SessionID) & _
                   "&AscribeSiteNumber=" & Format$(isiteNumber) & _
                   "&RobotLocation=" & robotLocation & _
                   "&HideCost=" & strHideCost

   ' Display the icw robot loading screens desktop
   Dim webForm As New frmWebClient
   webForm.Navigate httpAddress + "?" + httParamaters
   webForm.Caption = "Robot loading information"
   Load webForm
   webForm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   Unload webForm
    
End Sub

Sub setDeliveryNoteReference(ByVal strDeliveryNoteReference As String)
'02Sep10 TH Written (UMMC FINV) (F0054531)

   m_strDeliveryNoteReference = strDeliveryNoteReference
   
End Sub

Function getDeliveryNoteReference() As String
'02Sep10 TH Written (UMMC FINV) (F0054531)

   getDeliveryNoteReference = m_strDeliveryNoteReference
   
End Function
