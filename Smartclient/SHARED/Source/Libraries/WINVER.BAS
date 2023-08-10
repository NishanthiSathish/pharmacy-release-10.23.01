Attribute VB_Name = "WINVER"
'----------------------------------------------------------------------------------
'<See Winver.rem, Winver1.rem, Winver2.rem, Winver3.rem, Winver4.rem, Winver5.rem  for previous>
'15Apr02 TH Moved comments to Winver6.rem  (pre 08Jan02 - 8.5, pre 27Feb02 -8.4)
'05Sep02 SF Moved comments to Winver7.rem
'28Jan04 TH Removed comments to winver8.rem
'04jan04 CKJ 32bit
'----------------------------------------------------------------------------------


'29Mar04 CKJ ========> Suite built as 8.6r3 Build 058
'             BuildNumber raised to 059
'
'05Apr04 CKJ Source Pruning part 1. Unused VBXs removed from mak files. Modified modules marked {SP1}
'            Events.bas
'            Aboutbox.frm
'            Corelib: Removed DFHLcrash, GetKeyLock, getpath, HelpKey, HelpQuit, InvalidIni, ScanCodesDB, SetFileHandles, InfoBar, popfreemem
'             Corelib.rem added to .\old\
'            Editform.frm
'            guibits: Removed procedure message
'            highasc
'            ocx
'            orderlib: Moved obsolete procs to .\old\orderlib.rem: entercode, EditDrugMessage, positionblob, PrintPickTotal
'            patsubs: removed unused procs SendToPump, showallroutes, UpdateRxDates
'            subpatme
'            supplier: Removed findsupplierX
'            wdatetim
'            widentsb
'            formula.bas: Removed copyorpasteformula
'            tpnsubsw: Removed enteractfact, enterinjfact
'            tpnw: Removed IronTotalX, TgSetCurCellColor & removed reference to obsolete proc Message
'            frmkinet.bas
'            frmkinet.frm
'            patmed: Moved Medicard8066, MedicardOld, EditClinicalSummary & RefreshPatPanelX to .\old\Patmed.rem
'            stkmaint.frm
'            stkmaint.bas: CreatePBSline: Removed superfluous parameter tmwrk, Removed unused proc RunCrystalReport
'            edi: Moved edimain, EdiSettings, displayPWORecord, MediateSetup, SaveTexsolDefaults,
'             Tecsoltest, TexsolSetup, AllItemsInInvoice to .\old\edi.rem
'            finanasc: Unused procs moved to .\old\finanasc.rem
'            ordmain.bas: PrintOrder: Removed ALL parameters as none were used
'            ordmain.frm
'            stckcont.bas renamed from stckcont.inc, latter moved to .\old\
'            stocklib: module moved to .\old\ and the only live procedure, choosewards, copied to wsprint
'            storeasc
'            storutil: Moved CheckSiteTemplate, TgSetLabelColour, updatesupplierinfo to .\old\storutil.rem
'            wslist: Removed support for non EAN13 barcodes
'            wsprint: Removed support for non-EAN barcodes, Choosewards: Copied proc from StorUtil.bas
'            ascshell.bas
'            ascshell.frm: MnuFormulary_Click: Removed Pharmacopoeia editor from live code
'            ident
'            paslink
'            wident
'29Mar04 CKJ ========> Suite built as 8.6 Build 059 testbuild
'             BuildNumber raised to 060
'06apr04 CKJ/   frmCMIup: changed ASCver to ASCver()
'               CMIupdt: Added stubs for OCXLaunch, SlaveModeEnabled, LaunchfromOCX, SignalASCDone
'06Apr04 TH/    Ordmain.frm: TblDisplay_Update: Added mod to allow Printing prepaks from passwrd lvl 5 (#63724)
'06Apr04 TH/    Patbill.Bas: SetupVariableQtys: Now allow variable qty repeats to be fractional in pharmac (#60287)
'14apr04 CKJ/   frmIssue: Added F7 Bag label prompt
'               subpatme: ActionIssueConfig, GetIssueConfig, SetIssueConfig added
'                 issue: Bag label support added
'16apr04 CKJ/   Dispens.frm: RxProtocol: Cleared k.escd before dir code handler (#73608)
'19Apr04 TH/    WSPrint.Bas: WSspool: Add suppliercode to the reprintnumber in the reprint file name (enh1574)
'               Orderlib.Bas: SupsWithOrds: Removed PrintinPacks clause to enable prints of part pack orders (#61824)
'                             PutLinesInArray: Removed PrintinPacks to allow selection of fractional order (#61824)
'                             Reprint: Altered header formatting of reprint selection screen (#enh1574)
'                             UpdatePrice: Added new flag to ensure the price last paid is NOT update if non-stock item AND box not checked (#73293)
'19Apr04 TH/    Guibits.Bas: EnhDisplayMacrofile: Written to use enh list box  (enh654)
'19Apr04 TH/    Corelib.Bas: ParseItems: If user cancels on free text dont set a global cancel, just dont do the freetext !(#72640)
'19Apr04 TH/                 ParseStdDataItems: If user cancels on freetext input, just cancel the input, dont set cancel flag as this
'                                               has repercusions elsewhere. (#72640)
'19Apr04 TH/    Finanasc.Bas: MonthEndDiscount: Allow only numeric entries for value of credit note  (#60060)
'19Apr04 TH/                  DisplayOrder:  Mask price if necessary (#UMMC pricehide)
'20Apr04 TH/    Widentsb.Bas: ConsSpecLookup: Use new enhanced lookup (enh654)
'21apr04 ckj    subpatme: sethelp: removed as it duplicated setinput, then set help to a non-existent file
'07may04 CKJ/   Corelib: AddFileToCache: Out of string space. Solution is to reduce buffer size using 54K less space.      (#74219)
'10may04 CKJ/   Patsubs: ReprintFile: Allows reprints where ID is > FFFFF (1048575). Added warning if > FFFFFF             (#69146)
'10may04 CKJ/   Ident: CmdOK_Click: Option to store waiting time record only on F5 Save: ASCRIBE.INI [WaitingTime] CreateOnlyAtPatientSave="Y" default=N  (#enh?)
'13May04 CKJ/   Finanasc: PrintLedger: alternative collation sequence \winord.ini [defaults] CodingSlipsInSupplierOrder="Y" default ="N" (Enh#73906)
'               OrdMain: AddlineToDisplay: Option to show price on screen at reconciliation: winord.ini [defaults] ShowPriceOnInvoiceScreen="Y" default = "N" (Enh#73906)
'               Supplier: Supplier_Callback: Added non-mandatory message, and used it to prompt user when changing Inuse flag (#72056 69968 69134)
'               Storeasc: SupplierOrderChecks: commented out
'               Issue: ChkPrintStockLbl: set not visible at design time
'                 Double click 'bag label [F7]' prompt to print bag label
'16May04 TH/    Corelib.Bas: ParseItems: ,ParseStdDataItems: Mod to above (#72640) after second check - now revert to previous value, dont assume k.escd was true !
'16May04 TH/    Patsubs.Bas: EnterDrug: Added - Terminal basis only - Used to retain focus on dircode after drug entered (#65365)
'16May04 TH/                 IssueAndPrint: Added update of last dispensers ID on issue (#62626)
'16May04 TH/    Logview.Bas: UserLogViewer: Added mods for (enh1435) - shows pickingticket number in logviewer where necessary.
'16May04 TH/                                Added mods to hide the price on certain passlvls (UMMC Price hide)
'16May04 TH/    Ident.Frm: Form_KeyUp: Use new enhanced lookups (enh654)
'16May04 TH/    Wident.Bas: SelectPatient: Use new enhanced lookups (enh654)
'16May04 TH/    Orderlib.Bas: Moved GetStoresDescription() from here to Subpatme.Bas(#63766)
'16May04 TH/    Subpatme.Bas: FillHeapDrugInfo: Added new general description iGendesc - uses stores desc if available, else resorts to normal description (#71558)
'16May04 TH/                  Moved GetStoresDescription() to here from Orderlib.Bas (#63766)
'16May04 TH/                  PutPickNo Written
'16May04 TH/                  Translog: Added mod to record Picking Ticket number if so configured (enh1549)
'16May04 TH/                  Updateinfoline: Added mod for UMMC price hide enhancement
'16May04 TH/                  Displaydrugline:Added mod to suppress cost view if configured (UMMC price hide enhancement)
'16May04 TH/                  GetFindDrugLowPassLevel() ,SetFindDrugLowPassLevel : Added (UMMC pricehide)
'16May04 TH/    TPNW.Bas: TPN_Callback: Use new enhanced consultant lookup (enh654)
'16May04 TH/    Dispens.Frm: DispMnuButHandler: Added terminal based switch to force another refresh to fill the route out (#67596)
'16May04 TH/                 MnuStockLevel_Click: Added passlvl for UMMC enhancement (hide price)
'16May04 TH/                 TxtPrompt_KeyUp: Added terminal based setting to enable rxing check : this will force the user back into the rxing process
'                                             with a warning rather than just state the prescription has not been saved - for UMMC, classic rxing (#65365)
'16May04 TH/                 TxtPrompt_KeyUp: A frankly horrible mod (sorry) to retain modified warning/instr codes (inc blanks) during the ammendment of a label (#67284)
'16May04 TH/                 TGLabelList_rowchange: Pass keep modified direction flag into label routines (#67284)
'16May04 TH/    Patmed.Bas: DisplaytheLabAndForm: Mod to retain modified dircode field (#67284) - Timing Issue on table refresh
'16May04 TH/                ChangeConsultant: Use new enhanced lookup (enh654)
'16May04 TH/                labeltoform: Added LabelModified to clause to protect original directions (#65853)
'16May04 TH/                Onloadingdispens: UMMC pricehide mod to set functionality based on passlvl
'16May04 TH/    Ordinfo.Frm: DisplayScreen3: ,DisplayPanel:,DisplayScreen1or2:  Added mod to suppress cost if configured (UMMC price hide)
'16May04 TH/    Storeasc.Bas: ReturnToStore: Use supplier code for delivery note if  wardcode is blank (#67791)
'16May04 TH/                  Receiveitem: Added Mods to prevent double issue when receipt has timed out and the line has been received elsewhere
'                                          - strengthened locking during receipt process (#59077)
'16May04 TH/                  Main: Added mod to read passed passlvl from dispensary to check if price should be suppressed (UMMC price hide)
'16May04 TH/                  CheckExitVal: Mods to record picking ticket number (enh1549)
'16May04 TH/                  ShelfStockList: If configured sort on supplier code (#63766)
'16May04 TH/                                  Now use the drug location not the loccation from the order (#71558)
'16May04 TH/                  scanorders: Added to record Picking Ticket Number (enh1549)
'17May04 ckj/   WSlist: WSlist: removed sethelp
'               WDCTimp: Startup: removed sethelp
'               OrdStub: Issue_Callback: Added
'17May04 TH/    Formula.Bas: ParseFormulaData: Added code for new ProductNSV and Item4Qty elements (#74372)
'17May04 TH/                 InitialiseHeapItems: Added code to initialise ProductNSV and Item4Qty elements (#74372)
'17May04 TH/                 PrintManWorksheet: Add mod to ensure correct batch expiry details available on worksheet (#72672)
'17May04 TH/    Dispens.Frm: TxtPrompt_KeyUp: Added mod to check if there is sufficient pmr space for a new label as the user begins the process Enh1532
'19May04 TH/    Stkmaint.Bas: Login: Deny access to low level users if configured - UMMC Hide price mod
'19May04 CKJ/   Supplier: Editors: Heap based storage. Significant re-write, with extra supporting functions
'                 EditorsFindSortTextFromCode, EditorsPrintAll, EditorsReadFile: Written
'               Corelib: Heap: Added action 14 which returns the last code and entry from a heap
'20May04 TH/    Import.Bas: ImportNewStyleTran:,ImportNewStyleOrd: Added mod to delete pre - existing records for selected sites and month before new import if so configured (#67751)
'20May04 TH  ========> Winord built as 8.6 Build 060 testbuild
'             BuildNumber raised to 061

'21May04 TH/    Subpatme.Bas: FillHeapDrugInfo: Altered above mod - removed a call to getstoresdescription due to referencing problems.
'21May04 TH/                  Moved GetStoresDescription() back to OrderLib.Bas
'21May04 TH/    OrderLib.Bas: Moved back here after referencing problems
'21May04 TH/    Wdelord.Bas: main: Removed call to sethelp, also some stubbage
'               Stub.Bas: Stubbage

'20May04 TH  ========> Suite built as 8.6 Build 061 testbuild
'             BuildNumber raised to 062

'24May04 TH/    Formula.Bas: ParseFormulaData: Now use the dosing units of the product selected, NOT possibly the last one (if the item is selected here) (#71589)
'24May04 TH/    WSPrint.Bas: sarall: Added getfield wrapper to any reads from the database to stop invalid use of null errors (#65828)
'24may04 CKJ/   Quescrol.bas: QuesMakeCtrl: aligned labels
'               Quescrol.frm: aligned lblInfo with text boxes & made autosizing. made lblDesc autosizing
'               Supplier: Supplier_Callback: removed last mod. Instead use variable text next to the InUse box, taken from stores.ini [Info] 36= and 36YSE=
'27May04 CKJ/   Corelib: FileNameFromChannel: Corrected
'                 GetTextFile: Added TrackOpenedFiles
'               WIdx: UpdateIndex: Added TrackOpenedFiles
'               IDXsort: SortIndex: Added TrackOpenedFiles
'               OCX: OCXAcquireLock: Added TrackOpenedFiles
'               WSlist: UpdateWardDrugFile: close binarysearchidx
'               WSprint: Sarall: close binarysearchidx
'               Supplier: AmendSuppliers, GetValues: close binarysearchidx
'               Subpatme: GetUniqueNSVCode: close binarysearchidx
'27May04 TH/    Subpatme: Displaydrugline: Changed UMMC mod to use Hideprice call
'27May04                  HidePrice: Written
'27May04 TH/    Finanasc: Changed UMMC mod to use Hideprice call
'27May04 TH/    Logview.Bas: UserLogViewer: Now uses HidePrice for UMMC mod
'27May04 TH/    Ordinfo.Frm: DisplayScreen3: ,DisplayPanel:,DisplayScreen1or2:  Above mod now uses hideprice wrapper
'28May04 CKJ/TH PrntCtrl: SelectAndPrintFFlabels: Rewrote avoiding use of arrays, as these have caused out of memory errors in the Editor proc.
'28May04 CKJ/   Storeasc: IssuePick: Close index
'                 CloseOrderFiles: written
'                 ChangeTable: CloseOrderFiles if Blank layout requested
'               Edi: CheckInvInfo, ProcessPWOInfo: Close index
'               Ordmain: PrintOrder, RequisitionEnquiry: Close index
'               Ordmain.frm: Form_Unload: added CloseOrderFiles
'               Orderlib: GetOrder: TrackOpenedFiles added
'                 CloseOrderChan: written
'               Subpatme: TransLogExtra: added TrackOpenedFiles
'28May04 TH/    Storeasc.Bas: ToFollowsPrint: Added Locking through acquire lock on prntpck5 to prevent possible deadlock (Glasgow)

'20May04 TH  ========> Suite built as 8.6 Build 062 testbuild
'             BuildNumber raised to 063

'09May05 CKJ    Consolidated Dispensing usercontrol and Stores source code.
'               Up to now, most V93 changes have been marked with a placeholder of **V93** instead of the date.
'               These have now been assigned a nominal date of 09May05, covering conversion changes from July04 to now.

'01Mar06 CKJ    Copyright year to 2006
'               Changed 9.3 to 9.5 and set build number to 001
'               HighAsc: OverrideLayout added

'25Apr06 CKJ    Changed Version numbering to be in line with main suite. See below.
'10May06 CKJ    Patsubs: CheckStandard: if canusespoon=true but dose is not one for spoonfuls then numbers are still needed (DR-06-0334)

'17May06 CKJ    ucDispens: DoAction_Change: Added "RefreshState-ForceInactive" to half-close the database connection and
'                 call RefreshState recursively to shut the UserControl down.
'               Dispens: PutRecordFailure: changed action
'20Nov07 CKJ    Ported StockTake robot mods from 9.9
'14Mar08 JP     Added call to GetSupplier as the wrong supplier was being selected (F0015752)
'25sep08 CKJ/AK ucDispens: TxtPrompt_Keyup: Moved SetFocus call below deferred printing (F0028203)
'                 Refreshstate: Added default to override pid.status "A"   (F0020276)
'30sep08 CKJ/   Dispens: removed call to SetSpecialty: superfluous as var is global already  (F0019922)
'                 Specialty to upper case
'                 Optional setting Ascribe, PID, SpecialtyMandatory="Y"
'                 Ward & Consultant; removed default of "NONE" if no element in XML
'               Subpatme: SetSpecialty: removed procedure
'               Set version to 10.0.0.0 from 9.8.25.0
'               Set copyright year to 2008 from 2006
'30Sep08 CKJ/   ProdStockEditor: Checkdrug: prevent zero d/m/y in start of period (F0024926)
'01oct08 CKJ/   ProdStockEditor: Checkdrug: prevent zero in pack size (merged from V8)  (F0029065)
'08oct08 CKJ/   Subpatme: DisplayBNFsectionlist: written, based on displaymacrofile but getting BNF data directly from ordercatalogue (F0027222,F0023942)
'                FindDrug: Altered layout to support multi-level BNF lookup
'                ProdStockEditor: StkMaint_Callback: DisplayBNFsectionlist replaces displaymacrofile
'               QuesScrol: QuesShow: accounts for taskbar when centering                  (F0035610)
'                Guibits: GetScreenWorkingArea: written. Returns coordinates of usable screen excluding taskbar
'               ucPSE: SetConnection: corrected token handling & tidied the handling of failed connection   (F0035503)
'               frmTxtWin: Turned usemnemonic off for the label
'13oct08 CKJ/   Merged from V8.8: 01Aug08 TH/CKJ Storeasc:Receiveitem: (F0023465)Remove check on k.escd to stop potential "double receipt" - ie update of drug with no subsequent update of order
'               Merged from V8.8: 01Aug08 TH/CKJ Orderlib: Updateprice:(F0023465)Extra fencepost to protect from "double receipt"
'               StockTakeLoad: stkLaunch: Token handling corrected     (F0035499)
'               frmManufacturing: form_load: Token handling corrected  (F0035499)
'17oct08 CKJ/   Ported minimum from stores to dispensing to support drug enquiry.  (F0036013)
'               Custom orderlib added (called OrderLibDISP) and pruned to the max.
'               Custom wOrderIO added (called wOrderDISP) with CLOSE and END removed.
'               Remaining necessary bits of stores placed in StockEnquiryDISP.
'               OrdInfo.frm added and minor layout mod added
'               Now called from ucDispens
'20oct08 CKJ/   Dispense: TxtPrompt_Keyup: extra call to DeferredPrinting added, so that setfocus can be done inside IFs (F0036227)
'                various: commented out unused code to save space
'22oct08 AK/CKJ ProdStockEditor: ViewSelected: Pass read only field array from Setting table if "DSS Master" setting is true (F0018781)
'               WGeneralIO: Added SettingValueGet: Return requested value from Setting table
'               WProductID: Added 5 new "_Locked" fields to DrugParameters structure, CastRecordSetToProduct and PutSiteProductDataNL (F0018781)
'               ucPSE: SelectView: Added new view to load UpdateServiceView form if Setting "DSS Master" is true (F0018781)
'               ucPSE: RefreshState: Changed "Add Product" button to restrict to Import only if Setting "DSS Master" is true (F0018781)
'               frmUpdateServiceView Added: New form for update service view (F0018781)
'23oct08 CKJ/   Subpatme: reinstated description search with multiple words eg "sodium chloride" (F0021923)
'                After trimming spaces, all characters other than 'a-z|0-9|.' become a wildcard.
'                This gives great flexibility to add drug, strength and form fragments to the search, eg "paracet cap", "*valproate 200"
'27oct08 CKJ/   ucDispens: added SetFocusTo TxtPrompt, as focus appears to vary depending on preceding popups (F0036227)
'04nov08 CKJ    Transport.cls: WriteAuditLog: Call to pAuditLogInsert replaced with pAuditLogInsertViaTransport
'           *** THIS WILL NEED REVIEWING if Pharmacy ever gets used with InterfaceRegister ***
'               See proc for detail                (F0037051, F0037016)
'12Nov08 CKJ/   Corelib:ParseURLToken: Added filter for problematic integrated security connection param  (F0037151)
'12Nov08 CKJ/   Storeasc:CheckExitVal: removed validchars=YNX. superuser facility deprecated since at least 2000 (F0038457)
'               Corelib: Corrected nulls to be eleven chr$(0) to match length of .validchars
'19Nov08 CKJ    HighEdit: mnuPrintSetup_Click: Noted that the common dialog is not used. In V8 this ensured
'                that the changes were done correctly to the default printer. Added debug option.
'                No functional change outside debug. Build requires common dialog COMDLG32.OCX in project
'                 - checked that all vbp files in Smartclient tree already contain it.                      (F0039104)
'
'RCN P0009

'19Mar09 TH  Storeasc.Bas: Storesmain: Added sitenumber to heap for UHB Interfacing (F0032689)
'26Mar09 TH  Storeasc.Bas: Receiveitem: Added batchnum, expiry to "R" type orderlogs and added olToFollow to heap for UHB interfacing (F0032689)
'19Mar09 TH  Supplier.Bas: PutSupplier: Added sUpdateflag to heap for UHB (F0032689)
'19Mar09 TH  Supplier.Bas: PutSupplier: Entry for supplier interface for UHB (F0032689)
'26Feb09 TH  Supplier.Bas: SupplierOutput: Written for UHB SAGE Interface solution (F0032689)
'19Mar09 TH  SupplierEditor.Bas: Added fencepost to stop save on cancel (UHB) (F0032689)
'20Mar09 TH  StoreAsc.Bas: FillHeapDrugInfo: Added new heap elements for UHB (F0032689)
'17Mar09 TH  StoreAsc.Bas: FillHeapSupplierInfo: Added new elements for UHB Interfaces (F0032689)
'26Feb09 TH  StoreAsc.Bas: OrderOutput: Ported for UHB SAGE Interface solution (F0032689)
'26Feb09 TH  StoreAsc.Bas: FillHeapOrderLogInfo: Ported from V8 (F0032689)
'20Mar09 TH  ProdStockEditor.Bas: Stockoutput: Written for UHB SAGE Interface solution (F0032689)
'20Mar09 TH  ProdStockEditor.Bas: ViewSelected: Added mods for UHB stock interface (F0032689)
'20Mar09 TH  Subpatme.Bas: FillHeapDrugInfo: Added new heap elements for UHB (F0032689)
'17Mar09 TH  Subpatme.Bas: FillHeapSupplierInfo: Added new elements for UHB Interfaces (F0032689)
'26Feb09 TH  Subpatme.Bas: OrderOutput: Ported for UHB SAGE Interface solution (F0032689)
'26Feb09 TH  Subpatme.Bas: FillHeapOrderLogInfo: Ported from V8 (F0032689)
'26Feb09 TH  Subpatme.Bas: OrderLog: Added call to order outputinteface (UHB F0032689)
'29Mar09 TH  Finanasc.Bas: FinEditOrd: Ensure todays date is used for credit adjustments. Merged from version 8 (F0013564)
'23Apr09 TH  Finanasc.Bas: FinEditOrd: Added extra check on invoice number and go and collect were necessary (F0047271)
'23Apr09 TH  WProductIO.Bas: BlankWProduct: Added supplier profile blanking(F0031619). The ID here was being used as a flag
'                            in supplier switching and because this wasnt being cleared this led to profiles not being saved after
'                            switching sups in the same session. Also added ref no and suptrade name at same time to tidy up.
'23Apr09 TH  WSList.Bas: UpdateLineSQL: InsertLine: SarAllSQL:  Added trim around titletext (F0038841)
'23Apr09 TH  WSList.Bas: PrepareIssue: Added to prevent leading space (F0036816)
'20Apr09 TH  Subpatme.Bas: Translog: OrderLog: Make debug more specific (F0050755)
'22Apr09 TH  Subpatme.Bas: FillHeapSupplierInfo: Added sMethodexp UHB (F0051378)
'03Sep09 PJC WIDENTSB.bas: FillHeapPatientInfo: Added PatientPaymentCategory to patient heap. (F0054530)
'03Sep09 PJC WIDENTSB.bas: Declarations: Added PatientPaymentCategory to patidtype type (F0054530)
'03Sep09 PJC ucDispens.ctl: RefreshState: Populate PatientPaymentCategory in the pid structure from the OCX heap. (F0054530)
'04Sep09 PJC Subpatme.Bas: TransactionOutput: Added extra filter for the Patient Payment Category (F0054530)
'07Sep09 PJC WIDENTSB.bas: FillHeapPatientInfo: Added formatted version of DOB to the heap used for the UMMC billing interface. (F0054530)
'07Sep09 PJC Subpatme.Bas: FillHeapTranslogInfo: Added formatted version of trans date, trans costs/100, transaction Charge/Credit code and absolute qty to the heap. (F0054530)
'11Sep09 PJC Subpatme.Bas: TransactionOutput: Read the Patient stuff from the heap rather than the structure. (F0054530)
'21Sep09 PJC WEpisodeIO.Bas: GetEpisodeToOCXHeap: Added the rs Episode to the print heap on configuration setting. (F0054530)
'21Sep09 PJC ucDispens.ctl: OCXHeapPatientElementToPrintHeap: Created (F0054530)
'21Sep09 PJC ucDispens.ctl: RefreshState: Added call to OCXHeapPatientElementToPrintHeap (F0054530)
'28Sep09 PJC EDI.BAS: CheckInvInfo: Removed the 100 multiplier added configurable dp for Round function (F0024736)
'01Oct09 PJC Subpatme.Bas: Expandpid,FillHeapPatientInfo: Partially reinstated (following discussion with CKJ) after formatted DOB required on the label by UMMC (F0065077)
'05Oct09 PJC WIDENTSB.bas: FillHeapPatientInfo: Added Formatted NHS Number to Print Heap (F0064619)
'05Oct09 PJC ucDispens.ctl: OCXHeapPatientElementToPrintHeap: Added Primary Patient Identifier Display to print heap (F0064619)
'05Oct09 PJC ucDispens.ctl: RefreshState: Populated pidExtra with the PatientIdentifier/Valid for the patient print heap. (F0064619)

'24Dec09 CKJ/    Patsubs: PrintThelabel: Reinstated check on robot message from V8, as had been removed in conversion
'                Needed to prevent multiple labels being printed unnecessarily  (F0072185)

'07Jan10 CKJ     OrdMain.frm, StoreASC, Finanasc: corrected use of OTblMaxCols and the associated lines() array
'                StoreASC: OTblMaxCols is not now read from config, as it has to match the code.
'                OrdMain: AlternativeDBlayer now set as default = "Y"
'                Subpatme: Issue: Widened label for robot name on issue form
'                OrdMain: AddLineToDisplaySQL: Added robot status as column 9. Note: only used when AlternativeDBlayer="Y" (RCN P0070 F0030035)
'                Supplier: SupplierCacheType, FillSupplierCache: Pointer if used should be long, but is never used and SP may have been patched to send 0, therefore remove from struct (RCN P0332  F0073973)
'                Winver: Changed copyright year to 2010
'20Jan10 CKJ     Mechdisp: RoboPharma: added lock mechanism similar to the Rowa i/f, using dispdata.xxx\RoboPhma.Lck
'                OrdMain.frm, Storeasc, Orderlib, WebClient: Merged XN Robot Loading option
'17Jan10 CKJ     HighEdit: Changed HighEdit. to Me. and set defbool
'                Added Table options with borders, shading, merge, split
'                Made exit more Windows standard, with Alt-F4 & [x] asking if changes should be saved
'                Covered up the file open and fields buttons (except in view-only mode)
'                Save button is shown when there is at least one change to save, action is same as save & exit
'                  (File operations are under program control, fields not used)
'                Made date button return '17-Mar-2010 ' instead of '17.03.110'
'                Removed fraOverlaySave_DragDrop as no such control exists
'                HE.keydown & MouseDown are not named like this in 32 bit se were not invoked
'                  cut/copy/paste work anyway, and popup menu steals focus, so both removed
'                HE.lowresources not supported - removed
'                added errorstart, errorfont, etc for all error... routines
'                Toggle preview from button now sets menus correctly
'                View-only now disables button bar & style bar
'                mnuColWidth: Prevented column width of -0.001    (RCN P0007 F0078650)
'19Mar10 CKJ/    SAR.frm: Overhaul - separate lookups for each drug code, new-look screen, much more validation
'                WSprint: Sarallsql: allow NewTopupLevel and NewPackSize to be set to ""
'                 If either contains Nul then they have not been set and should be ignored
'                 Do not proceed if NSVcode to be written is invalid (either left unchanged or new code)
'                 Blank all issue fields when NSV changes, but no others without asking
'                 Printed report does not truncate description         (RCN P0007 F0052571)
'24Mar10 CKJ     MechDisp: Robopharma now ends at the status 01 acknowledgement - modified to reflect this
'                Note that Robopharma locking should not be necessary, as RoboConnect now accepts multiple connections  (RCN P0007 F0067753)
'25Mar10 CKJ     HighAsc: Added Citrix override - allow NExx: to be changed to NEyy: for the same printer name and driver  (RCN P0007 F0081840)
'                 FindPrinterFromContext: Removed obsolete procedure
'29Mar10 CKJ     ucPSE: added d.livestockctrl = "Y" to import from other site & from DSS Master [RCN P0007 F0077938]
'30Mar10 CKJ     EDI: ProcessInvHdr: Validate InvPayDate and convert ddmmyy to ddmmccyy. Corrected spelling of 'UseInvoiceDate'   [RCN P0007 F0025467]
'31Mar10 CKJ/TH  HighASC: DeferredPrintingLog and SetSpecifiedPrinter log added (for restricted debug use only) [RCN P0007 F0078120]
'07Apr10 AJK     CORELIB.BAS: URLEscape: Ported in from v8 for HIL (F0072542)
'                PATPRINT.BAS: HILaunchLeaflet Ported from v8 and tweaked (F0072542)
'                ucDispens.ctl Added HILaunchLeaflet call to TxtPrompt_KeyUp (F0072542) Ported from v8
'                ProdudctStockEditor.BAS: ArrayToStruct: New fields ported from v8 for F0072782 and F0072542
'                ProdudctStockEditor.BAS: StructToArray: New fields ported from v8 for F0072782 and F0072542
'                WProduct.BAS DrugParameters type: Added new fields for F0072782 & F0072542
'                WProduct.BAS PutProductNL: Added new fields for F0072782 & F0072542
'                WProduct.BAS CastRecordsetToProduct: Added new fields for F0072782 & F0072542
'                WProduct.BAS BlankWProduct: Added new fields for F0072782 & F0072542
'                SUBPATME.BAS FillDrugHeapInfo: Added fields for F0072542 and F0072782
'                WIDENTSB.BAS FillHeapPatientInfo: Added new elements(pAgeInYears and pSpecialityExpHIL) for HIL printing, ported from v8 (F0072542)
'                FRMHIL.FRM Added
'08Apr10 XN      OrdMain.frm: lblHeading_Click Add proper column sorting in receive goods screen for F0055221
'                Storeasc.Bas: ChangeTable Added geting column type information from WConfiguration for F0055221
'                CoreLib.Bas: shellsort extended to accept column type, and implement proper sorting F0055221
'09Apr10 XN      StckCont.Bas GetMaxNoOfLinesForOrder returns the maximum number of lines allowed for a file different value used for EDI supplier F0068649
'                HSSL.BAS: PrintHSSLConfirmationSheet use new GetMaxNoOfLinesForOrder function to get number of lines on order F0068649
'                OrdMain.BAS PrintPaperOrder use new GetMaxNoOfLinesForOrder function to get number of lines on order F0068649
'                OrdMain.BAS Selectforsupplier use new GetMaxNoOfLinesForOrder function to get number of lines on order F0068649
'                StorUtil.BAS OrderingUtils writes the new edimaxnumoflines to WConfiguration F0068649
'                StorUtil.BAS CheckWorkingDefaults added validation for the new edimaxnumoflines F0068649
'                StorUtil.BAS updatedefaultsinfo reads new edimaxnumoflines value form Set/Amend working defautls, and writes to WConfiguration F0068649
'                StorUtil.BAS amenddefaults Added the edimaxnumoflines to the Set/Amend working defautls form F0068649
'                Orderlib.BAS ReadOrdData reads edimaxnumoflines from WConfiguration F0068649
'14Apr10 AJK     ProdudctStockEditor.BAS: ArrayToStruct: Added fields for F0072782
'                ProdudctStockEditor.BAS: StructToArray: Added fields for F0072782
'                WProduct.BAS DrugParameters type: Added new fields for F0072782
'                WProduct.BAS PutProductNL: Added new fields for F0072782
'                WProduct.BAS CastRecordsetToProduct: Added new fields for F0072782
'                WProduct.BAS BlankWProduct: Added new fields for F0072782
'                WProduct.BAS PutSiteProductDataNL: Added new fields for F0072782
'                SUBPATME.BAS FillDrugHeapInfo: Added fields for F0072782
'                ProdStockEditor.BAS: CheckDrug: F0042865 Added check for "-" being entered
'15Apr10 XN      ucDispens.ctl RefreshState prevented dispensing if ConsultantOutOfUse heap state is set (also depends on WConfiguration AllowDispensingToOutOfUseConsultant setting) F0075771
'16Apr10 TH/AJK  F0072542 Ensured pidExtra.Specialty is updated to allow speciality expansion to be added to print heap (HIL requirement)
'14Apr10 AJK     ProductStockEditor.BAS CheckDrug F0042865 Added check for "-" being entered and cleaned up cost validation
'16Apr10 XN      EnhList.frm EnableClickableHeaders New method to allow calling function to allow sorting by clicking on column headers F0065193
'                EnhList.frm LstHdr_Click Clicking on column header causes the list to be sorted by that column F0065193
'                EnhList.frm TxtInput_Change, LstBox_DblClick, TxtInput_GotFocus, TxtInput_KeyUp prevent text box lookup event firing when text box populated in code F0065193
'20Apr10 AJK     ProductStockEditor.BAS CheckDrug F0077124 Added NSV checks and rsCheck tidyup
'20Apr10 AJK     WPorduct.BAS GetProductRSByDrugID Written F0077124. Returns all WProduct rows for a given NSVCode, regardless of Site
'20Apr10 AJK     WPorduct.BAS GetProductRSByNSV Written F0077124. Returns all WProduct rows for a given NSVCode, regardless of Site
'23Apr10 XN      ROQROL.frm New Progress bar F0058248
'                ROQROL.frm mnuRoqAndRol_Click passes progress bar to PrintRoqAndRol, and disables forms controls beforehand F0058248
'                ROQROL.frm EnableControls enable form controls F0058248
'                StorUtil.bas PrintRoqAndRol update the progress bar for each iteration loop
'26Apr10 XN      Supplier.bas asksupplier Allow handling of non sortable items F0065193
'                Supplier.bas AskSupplierWard Allow handling of non sortable items F0065193
'                EnhList.frm changed name of EnableClickableHeaders to AllowSortableHeaders, and added new non sortable items parameter F0065193
'                EnhList.frm LstHdr_Click Allow handling of non sortable items F0065193
'06May10 AJK     FindDrug.frm: cmdAllRoutes_Click: F0073627 Added event to load all off route products
'                FindDrug.frm: AddOffRoute: F0073627 Added to load all of route products
'                FindDrug.frm: Form_Load: F0073627 Check master switch to determine whether to enable all routes button
'                PatMed.Bas: SaveLabel: F0073627 Added logging for Off Route product selection
'                SubPatMe.Bas DisplayDrugLine: F0073627 Added blnOtherRoutes param to be checked and add prefix to off route item display
'                SubPatMe.Bas FillDrugList: F0073627 Added blnOtherRoutes input to be passed to ProductLookup
'                SubPatMe.Bas FillDrugList: F0073627 Removed single item check for generating headings
'                SubPatMe.Bas FillDrugList: F0073627 Added check to ensure list is not empty before setting item
'                SubPatMe.Bas FindrDrug: F0073627 Added off route checking code to log and display off route matches
'                WProduct.Bas ProductLookup: F0073627 Added otherroutes parameter
'                ucDispens.ctl RefreshState: F0073627 Wipe off route flag
'17May10 AJK     ProdStockEditor.Bas ReadLocalSites: F0076258 Removed doneonce check as values are persisting across different controls in ICW
'19May10 XN      F0051906 Extended WSupplier.Wardcode from 4 to 5 charcs
'                SupplierEditor: Extended ward code to 5 characters
'                SupplierEditor: AmendSuppliers allow ward code of 5 characters and if W type suplier force wardcode = ward, and E and S types to blank wardcodes
'                WSList.bas: EditWardCode Extended ward code to 5 characters
'                WSList.bas: AdhocIssue send wardcode instead of ward to Issue method
'                WSList.bas: Wardinfo Extended ward code to 5 characters
'                WDirection.bas: WDirection.Location extended to 5 characters
'                OCX.bas: PMStoASCStruct.WardCode  extended to 5 characters
'                OCXLight.bas: PMStoASCStruct.WardCode  extended to 5 characters
'                PatSUBS.Bas: patlabel change name of method get4charwardcode to get5charwardcode
'                Supplier.bas: Extended ward code to 5 characters
'                Supplier.bas: FillWardCodeArraySQL Allowed method to rebuild the WardCode list if needed
'                Supplier.bas: change name of method get4charwardcode to get5charwardcode
'                WIDENTSB.BAS: patidtype.ward extended to 5 characters
'27May10 AJK     EDI.bas: SendEDIOrder: F0061692 Use EDILinkCode if it exists as localcode
'27May10 AJK     WProduct.bas: Declarations: F0061692 Changed d.EDILinkcode to string as it's a barcode that may have leading 0's
'27May10 AJK     EDI.bas: ProcessInvInfo: F0061692 Check to see if localcode is an EDILinkCode
'27May10 AJK     EDI.bas: CheckInvInfo: F0061692 Added EDILinkCode check
'27May10 AJK     EDI.bas: SetMediateItemArchivable: F0061692 Added EDILinkCode
'03Jun10 CKJ/    Mechdisp: SectionIDforMechDisp: Moved Exit For inside the IF to allow second & subsequent robot sections to be used    (RCN P0158 F0083830)
'                  ApostoreRequestProduct: Added stores & label description, to avoid use of global d struct in enquiry message (RCN P0158 F0088211)
'04Jun10 XN      SubPatMe.Bas Issue: If Drug is not in use ask user if they want to continue (RCN P0158 F0023149)
'10Jun10 XN              OrdMain.frm  picToolBar_MouseDown Remove allowing user to change colour of menu bar by clicking on it (F0085853)
'                                StoreAsc.Bas StoresMain Sets colour of tool bar from config setting, and set the site number in the title bar (F0085853)
'                                StoreAsc.Bas SetSiteToolBarColour Created method to load and set bar colour from site config setting (F0085853)
'14Jun10 XN      StoreAsc.Bas SetSiteToolBarColour fix error if setting was Hex
'16Jun10 XN      StorUtil.bas EnhancedRoqAndRol Added completed message to end of update annual usage progress (F0058248)
'25Jun10 CKJ     Patmed: Calcdefaultdoses, Formtolabel, Savelabel: Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet
'                Subpatme: CanInferAdministrationUnits: removed as no longer used                              (RCN P0158 F0088216)
'29Jun10 XN      CoreLib.bas: shellsort improved original changes after code review with chris (F0055221, F0065193)
'                CoreLib.bas: AGreaterThanB added function as used by updated shellsort (F0055221, F0065193)
'                OrdMain.frm: lblHeading_Click fixed problem getting last column type from database, for clickable list headers (F0055221, F0065193)
'05Jul10 XN              frmWebClient.frm: WebBrowserCtrl_WindowClosing instead of unloading form now starts CloseTimer to do a delayed closing of the form  (F0090834)
'                                frmWebClient.frm: CloseTimer_Timer added event handler for new timer to perform a delayed closing of the form when requested by web page (F0090834)
'10Jun10 XN      ProdStockeditor.bas ViewSelected Got method to use the DSSUpdateServiceInUse flag instead of DSSMaster
'                PSE.ctl RefreshState Allow user to add stores only product if DSS on web enabled (F0088717)
'                PSE.ctl CmdAdd_Click Got Choose Product Type to allow Stores Only Product (F0088717)
'22Jul10 CKJ     Mechdisp: MechDispIssue: 5 char ward codes - Consis needs fixed length ward code. RCN P00158 F0092472 (fix to F0051906)
'26Jul10 XN      SubPatMe.bas: Issue method. Improved the fix for RCN P0158 F0023149, adding drug name and proper tidy up (F0023149)
'04Aug10 XN              OrdInfo.frm DisplayPanel: Stores only product now identified if the ProductID=0 so updated handling in the display. (F0088717)
'                                ProdStockEditor.bas ViewSelected: Got it to use DSSUpdateServiceInUse instead of the DSSMaster flag, and ProductID <> 0 instead of InUse<>"S" (F0088717)
'                                PSE.ctl CmdAdd_Click: If stores only product then can't default InUse to "S" instead set productID = 0 (F0088717)
'                                MTSInterface.bas IsItemForMTSPacker: Stores only products identified now by d.ProductID being 0 (F0088717)
'                                WProduct.bas CastRecordsetToProduct: InUse can't be S anymore so force to "Y" (F0088717)
'                                SubPatMe.bas FillDrugList: Stores only products are now identified by d.ProductID <> 0, also force any WProudct.InUse = "S" read from DB to "Y"  (F0088717)
'                                                         updateinfoline: InUse in not "S" anymore for stores only products, so changed to display 'Y (S)' or 'N (S)' (F0088717)
'                                                         putdrug: Add check to see if in trasaction before doing rollback
'                               frmConversion.frm cmdUpdate_Click: InUse can not be "S" anymore so default to "Y" (F0088717)
'                                                                 PopulateProductStockAndWsupplierProfile: InUse can not be "S" anymore so default to "Y" (F0088717)
'05Aug10 XN              Supplier.bas: Replace the hard coded WARD_CODE_LEN with GetWardCodeLen that determines the ward code length based on config setting Use5CharWardCode F0051906
'                                WSList.bas EditWardCode: Got function to use GetWardCodeLen to determine ward code length F0051906
'                                WSList.bas Wardinfo: Got function to use GetWardCodeLen to determine ward code length F0051906
'                                SupplierEditor.bas AmendSuppliers: Got function to use GetWardCodeLen to determine ward code length F0051906
'11Aug10 CKJ     StoreASC, Dispense, RptDisp: Added IPLinkShutDown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
'                 Called at terminate, forceinactive and usercontrolenable(false) of dispensing & repeat dispensing.
'                 Called at unload of stores and optionally on stores ChangeTable.
'                 To inhibit on ChangeTable, set wConfiguration: mechdisp Common CloseLinkOnStateChange = "N"  (default is "Y").
'                 (Already in StockTake, stub used in manufacturing, stock editor & HSSL)
'26Aug10 AJK     ProdStockEditor.bas Checkdrug F0042865 Added extra cost validation checks
'06Sep10 XN              CoreLib.bas shellsort: add option to allow sort to be case insensitive (F0095829)
'                                CoreLib.bas AGreaterThanB: add option to allow sort to be case insensitive (F0095829)
'                                EnhList.frm LstHdr_Click: should be case insensitive (F0095829)
'07Sep10 CKJ     Mechdisp: Consis problem with scoping of d.barcode on stock enquiry from Findrdrug screen (RCN P0158 F0096016)
'                 For clarity, changed d. to dLocal. in areas which do not share the d structure. Nothing here now uses d.____ variables
'04Oct10 XN      GUIBITS.Bas MessageBox: F0023149 Windows 7 has larger boarders for windows forms so increased height of from by 10
'02Nov10 AJK ProdStockEditor.bas ViewSelected: F0086901 Added paydate to OrderLog calls
'02Nov10 AJK SUBPATME.bas F0086901 Extended OrderLog struct to include DateInv
'02Nov10 AJK SubPatMe.BAS OrderLog F0086901 Added support for date invoiced
'02Nov10 AJK EDI.bas: ProcessInvInfo: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK EDI.bas: SendEDIOrder: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK FINANASC2.BAS: DirectEntry: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK FINANASC2.BAS: FinEditOrder: F0086901 Added date invoiced to OrderLog calls and moved ord.paydate assignment to make it useful to orderlog write
'02Nov10 AJK FINANASC2.BAS: MonthEndDiscount: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK FINANASC2.BAS: StockValAdjust: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Orderlib.bas: PrintPick: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Ordmain.bas: PrintPaperOrder: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Ordmain.bas: Selectforsupplier: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK StoreASC.bas: AddToOrder: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK StoreASC.bas: CheckExitVal: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK StoreASC.bas: Issuepick: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK StoreASC.bas: receiveitem: F0086901 Added date invoiced to OrderLog calls
'02Nov10 AJK Storeutil.basOrderingUtils: F0086901 Added date invoiced to OrderLog calls
'27May11 XN  LstBoxFrm.frm: SetKeyUpCallBackProc: F087364 Added F4 support for Amend Orders
'27May11 XN  LstBoxFrm.frm: LstBox_KeyUp: F087364 Added F4 support for Amend Orders
'27May11 XN  StoreASC.bas: MinOrderValue_LstBoxFrm_KeyUp: F087364 Added F4 support for Amend Orders
'27May11 XN  GuiBits.bas: LstBoxShow: F087364 Cleared SetKeyUpCallBackProc after form is displayed
'--------------------------
'15Dec10 CKJ/AK  AscribePrintJob brought under source control (RCN P0573 F0104170 10.5 branch)
'                Set Version as 10.5.0.0
'                HighAsc: Merged external print job;
                 '17Sep10 CKJ Support for external print job added.
                 '28Sep10 CKJ Updated to add messages & longer, configurable timeout
'                External printing default is now "Y"
'                ConditionalMessage: Added log of failed external print calls & extra param
'                ExecBlockingCommand: added error handler
'                HEdit: changed writelog from generic DeferredPrinting to ExternalPrint
'23Dec10 CKJ/AK  AscribePrintJob: Exe does not always close if an error occurs so added End.  (F0104815 from F0104170 testing)
'14Jun11 CKJ/TH  MTSandJVMinterface: Added option of nominal dosing time instead of the prescribed time  (F0120368)
'                JVMAppendData: Ward now 5 chars not 4, so altered JVMlocation format from 'WwwwDDMMCCYY' to 'Wwwww DDMMYY'  (F0120351)
'                Set CopyrightYear to 2011
'24Jun11 CKJ     MTSandJVMinterface: JVMAppendData: JVM file import errors on shortened DOB, so returned to "WwwwDDMMCCYY"   (F0121281)
'                A five char ward code causes a modal popup on every occurrence, and the unprintable code is replaced by ****
'01Jun11 CKJ     Set Copyright year to 2011
'                Removed "Microsoft Data Environment Instance 1.0 (SP4)" from project references
'                  as it is not explicitly called. File is "C:\Program Files\Common Files\Designer\MSDERUN.DLL"
'                MainScreen.frm: Noted that Form_Activate does not fire until the form has already been in use for a while (esp in Ward Stock) causing
'                    WSlist grid to be displayed too high up the screen (sometimes above it), so moved PicLayout resize to Form_Resize
'                  Removed/corrected references to MainScreen. as it must not reference it's own design-time object directly
'                  Removed old commented code and unused type, variable, menu options & events
'                  Set DefInt to DefBool which uncovered missing type declarations
'                  Removed DispPgNo. See comments in StoreAsc.bas for details
'                StoreASC: Removed DispPgNo. This used to be current 'page no' in DOS, where 20 lines per page were in view.
'                    For changes do a 'diff' with previous version in TFS.
'                  Changed DefInt to DefBool uncovering untyped params/vars
'                  Set gWardStockSite As Long, note that previously this was an implicit Integer
'                WSLIST: Changed DefInt to DefBool and uncovered missing type declarations
'                    Removed deprecated BlockMove and associated global BlockOpPending
'                WSPrint: Changed DefInt to DefBool & added 'as integer'
'                Ordmain: Removed DispPgNo. Changed DefInt to DefBool, uncovering untyped vars
'                FINANASC: Changed DefInt to DefBool and added 'as integer'
'27Jun11 XN      ucDispens.ctl: RefreshState F0089668 Added test for out of use wards
'27Jun11 CKJ     Stores modules: Code check-in at midway sprint. Deleted or commented unused/inappropriate code
'                Removal of TrueGrid remnants underway - more key & mouse events need simplifying.
'                Removed AlternativeDBLayer config option - now always uses SQL version.
'                Reinstated Alt-F12 debug option - now shows first 240 or so listview selected statuses.    (F0102533)
'                [Search for tag '//// then check & remove before release build]
'11Jul11 CKJ     Extensive Stores overhaul, large amounts of old code removed, duplication reduced.         (F0102533)
'                OMarked() array eliminated along with other vars & arrays, procedures & functions.
'19Jul10 XN          WEpisodeIO.bas: GetEpisodeToOCXHeap: added siteID to pEpisodeSelect F0123343
'                                ucRepeatDispens.ctl: RefreshState: added siteID to pEpisodeSelect F0123343
'                                RptDisp.bas: RptDispGetPatient: added siteID to pEpisodeSelect F0123343
'                                ucDispens.ctl: RefreshState: added siteID to pEpisodeSelect F0123343
'
'22Jul11 XN      OrdMain.bas: printorder: maintain gird sort order on refreshed (F0102524), (F0102526), (F0102527)
'                OrdMain.FRM: lblHeading_Click: Added m_SortOrderAsc to help maintain grid sort order on refresh (F0102524), (F0102526), (F0102527)
'                StoreAsc.bas: ChangeTable: Clear sort order on main grid MainScreen.m_LastColumnSorted (F0102524), (F0102526), (F0102527)
'                CoreLib.bas: ReverseStringArray: added the method (F0102524), (F0102526), (F0102527)
'26Jul11 XN      OrderLib.bas: DisplayDrugEnquiry: Added robot stock level to F4 screen F0118239
'                OrderLib.bas: DisplayDrugEnquiryKeyPress: New method to process the robot stock level request F0118239
'                frmWebClient.bas: Add ability to call methods based on key press on web form F0118239
'                frmWebClient.bas: Added methods SetKeyPessCallBackProc, KeyPressTimer_Timer, CallJavaScript F0118239
'11Aug11 CKJ     frmtxtWin, frmEnhTxtWin: Added extra checks on exit, as paste from clipboard bypasses normal traps. (TFS10806)
'15Sep11 CKJ     Corelib: MakeLocalFile: Corrected
'                wDateTim: DateAndTimeToMillisecond: Corrected  (TFS14212)
'                Set version to 10.6.0.0
'16Sep11 CKJ     ucDispens: RefreshState: Episode type handling simplified with addition of alias table   (TFS14479)
'14Oct11 CKJ     Set version to 10.7.0.0  (TFS14249)
'31Jan12 CKJ     Set copyright year to 2012
'                Added param to Findrdrug: UsePNExclude, set to false throughout smartclient (except PNOCX & HSSL)
'10May12 XN      Added CanUseSpoon lock TFS33227
'                UpdateServiceView.frm: Save: Save CanUseSpoon, CanUseSpoon_Locked field values from ui to db TFS33227
'                UpdateServiceView.frm: Load: Load CanUseSpoon, CanUseSpoon_Locked field from db to ui        TFS33227
'                WProduct.bas: DrugParameters: Added CanUseSpoon lock field TFS33227
'                WProduct.bas: CastRecordsetToProduct: Loaded CanUseSpoon field from DB TFS33227
'                WProduct.bas: PutSiteProductDataNL: Added saving CanUseSpoon field to DB TFS33227
'22Jun12 CKJ     StoreAsc: EditPatmedLayouts: alternative label layouts - large labels etc                     TFS36547
'                StoreAsc: EditPatmedLayouts: Added list of standard label layouts for which an RTF exists     TFS37022
'                  Removed deprecated "General prescription label layout" & "PRN prescription label layout"
'25Jun12 CKJ     HighAsc: ParseThenPrint: Now removes temp file if no reprint needed                           TFS37032
'                LstBoxFrm: LstBox_MouseDown: Added block to highlight clicked row, or remove highlight if click is in listbox whitespace
'                (Note: equivalent for enhLstBox needed but not included in this fix)                          TFS37033
'                FrmIssue: Added Alternative label combo                                                       TFS36547
'                Subpatme: Issue, Get/SetAltLabelContext: Added alternative label handling
'                Patsubs: DisplayTheLabel: Added Alternative Labels
'                Set version number to 10.9
'                ucDispens: Added dispensing control site line colour
'                ucDispens: corrected txtprompt_keyup "I" to behave as F8 with Action = 1
'28Jun12 AJK     36929  CORELIB.BAS: ParseURLToken:        Added 3 new params: WebDataConn as a byref to inform calling code if the URL token is for a web data connection
'                                                                              WebProxyPageURL as a byref string to inform the calling code what the full web proxy page url is
'                                                                              UnencryptedToken as a byref string to inform the calling code what the unencrypted token was
'                                                          Renamed ConnectionString to ResponseValue
'                                                          Added replacement code which derives the web page proxy url
'                                                          Added setting of unencryptedtoken value
'                                                          Formatting of connection string now conditional if connectiong string properties detected.
'                                    ParseCommandURLToken: Added new params to procedure and ParseURLToken call
'05Jul12 CKJ     Stores: Allow editing of toolbar colour & background image                                    TFS26714
'16Jul12 CKJ     Subpatme: Issue: Prevent robot printing if alternative label layout is used                   TFS38989
'24Jul12 CKJ     ProductStockEditor, MechDisp: Added Robot Configuration View,
'                 Send Product Information to Robot and Print Shelf Edge Label                                 TFS37640
'                ProductStockEditor: Added site name and colour bar                                            TFS39406
'16Aug12 CKJ     Added PharmacyWebData transport layer, amended all calls & references. Search on Aug12  (TFS36826)
'                Corelib: ReadSiteInfo: added call to gTransportADOSetLockTimeOut to ensure same setting is used throughout suite (non-web transport layer only)
'                  Uses wConfiguration d|siteinfo Connection SQLLockTimeout, default is "5000", values in millisecs, wait forever is "-1"
'17Aug12 CKJ     ParseURLToken: Suppress broken rules which may now be returned from web server (TFS36826)
'                Corrected displayed rounding error on connect Phase 3.69999
'                Prevented Decrypt error from trying to use database connection - now use MsgBox
'10Sep12 CKJ     Corelib: gTransportType: written
'                AboutBox: transport type added
'21Sep12 AJK     44489 ucDispens.ctl: RefreshState: Added check to ensure we're not loading all of this info when no Rx is in scope
'04Oct12 CKJ     Corelib: ReadSiteInfo: moved call to gTransportADOSetLockTimeOut until after dispdata has been defined  (TFS45776)
'                Added . to Global Const PROJECT = "Stores"
'04Oct12 CKJ     ucDispens, PSE: use transport layer wrapper for setsiteline & force-inactive (TFS44503)
'05Oct12 CKJ     WebTransport: ExecuteSelectSP: Load XML to RS using a stream which passes control characters 0x01-0x1F  (TFS44486)
'10Oct12 AJK     46452 SubPatMe.BAS TakeStockFromBatch: Changed find to filter for ADO recordsets
'22Jan13 CKJ     Stocktake: Added robot stock take for full stocklist TFS26732
'                 Added wildcard & comma separated list of locations to new stock take  TFS53365
'                 Removed superfluous code - remnants of unsupported TrueGrid
'                Changed Copyright Year to 2013
'24Jan13 CKJ     StoreAsc: SetSiteToolBarColourByForm: Added
'                StockTake: added call to SetSiteToolBarColourByForm    TFS54244
'28Jan13 CKJ     StockTake: Added stocktake name to caption bar         TFS54463
'                 Duplicate StockTakeName now allows edit & retry       TFS54466
'                 Widened StockTakeName from 20 to 64 characters        TFS54468
'29Jan13 CKJ     StockTake: Uses patch 10.10 StockTake Structure Update TFS54468 TFS54759.sql
'                 No longer uses 'SiteInfo.StockDataExt' - warns if present and not empty.
'                 Now fixed to same DispData as own site - cannot switch to use another site.
'                 gWardStockSite changed to gDispSite within StockTake module
'                 SiteCode removed as selection param from all StockTake SPs
'31Jan13 CKJ     Stocktake: corrected checks on menu options            TFS54759
'16Jan13 XN      ucDispens: RefreshState Optimise loading user information
'                alos updates sps pEpisodeSelect, pPatientSelect, fEpisodeType, pWLookupSelectByCriteria (48747)
'22Jan13 XN      ucDispens: RefreshState If session changes then clear user details (53975)
'30Jan13 XN      ucDispens: RefreshState Set the patient address and post code on pidExtra, so goes on print heap (41410)
'                RptDisp:   RefreshState Set the patient address and post code on pidExtra, so goes on print heap (41410)
'04Feb13 XN      WIDENSTB:  PatIDTypeExtra: added PostCode so goes on print heap (41410)
'                           FillHeapPatientInfo: Placed pPostCode onto print heap (41410)
'15Feb13 XN      PATMED:    FillHeapLabelInfo: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'                           furtherinfo:       Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'                           getlabel:          Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'                           SaveLabel:         Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'                PARPRINT:  WriteRecords: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                RptDisp:   RepeatDispenseItem: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                PatBill:   billpatient: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                           BillPatDispensQty%: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                WLabel:    WLabel: Replaced WLabel.LastDate with WLabel.lastSavedDateTime (40210)
'                           Putlabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                           PutLabelNL: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                           CastRecordsetToLabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                           BlankWLabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'                           LastSavedDateTimeToLastDate: Added method to convert new WLabel.lastSavedDateTime to old WLabel.LastDate string (40210)
'               Blisert:    IssueDrug: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'               Formula:    ReturnCivasItem: Removed dead code (40210)
'10Apr13 AJK    CORELIB:        ParseURLToken: Renamed PharmacyWebData URL
'24Apr13 XN     HSSL:             Main: Changed connection string encryption seed to work on any PC (60910)
'               frmManufacturing: Form_Load: Changed connection string encryption seed to work on any PC  (60910)
'               StockTakeLoad:    stkLaunch: Changed connection string encryption seed to work on any PC (60910)
'               StockExtra:       Main: Changed connection string encryption seed to work on any PC (60910)
'               ucDispens:        RefreshState: Changed seed to work on any PC (60910)
'               PSE:              SetConnection: Changed seed to work on any PC (60910)
'               ucPN:             OpenDBConnection: Changed seed to work on any PC (60910)
'               ucPN:             RefreshState: Changed seed to work on any PC (60910)
'               ucRepeatDispens   OpenDBConnection: Changed seed to work on any PC (60910)
'               ucRepeatDispens   RefreshState: Changed seed to work on any PC (60910)
'               frmBlank          Added  properites DefaultLeft, DefaultTop, DefaultWidth, DefaultHeight sdo can have fixed seed (60910)
'16Aug13 CKJ    Subpatme, FindDrug: Removed BNF lookup as now deprecated (TFS 42770)
'09Oct13 XN     ProdStockEditor: ViewSelected: Config setting to allow certain sites to edit a drug if they are on DSSOnWeb (TFS 75466)
'               PSE: CmdAdd_Click: Add setting to allow some sites to add drug if they have dss on web (TFS 75466)
'               PSE: SelectView: Only show Update Service View if DSS drug (TFS 75466)

'15Nov13 XN     CoreLib: WriteLogSQL: Added NSVCode 56701
'               StorUtil: WriteRoqAndRolLabutils: Moved labutils.log to WPharmacyLog table 56701
'               DRUGCONT: Command1_Click: Moved labutils.log to WPharmacyLog table 56701
'               ProdStockEditor: ViewSelected: Moved labutils.log to WPharmacyLog table 56701
'06Feb14 XN     PSE: SendToRobot: Added for Web version of product editor 56701
'24Mar14 XN     STOREASC: GetRobotLocationCode: Changed RobotLoaderReplyComponent to PharmacyReplyComponent (TFS86905)
'22Apr14 XN     SubPatMe: GetInsCode: Updated to use local code first, then dss language specific then dss english 89088
'               SubPatMe: GetWarCode: Updated to use local code first, then dss language specific then dss english 89088
'               SubPatMe: ListInstructions: Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088
'               SubPatMe: ListWarnings:     Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088
'23Apr14 XN     StoresAsc:AddToOrder: commented out code as the 0 = 1 condition means the code will never execute
'22May14 XN     SupplierEditors: Editors: Moved Patient invoice to standard ICW report Editor 88863
'               BMBill: PrintInvoice: Should now just come from DB 88863
'               CoreLib: GetRichTextDocument: Started storing ICW reports table in the DB 88863
'               V8 Data convertion: Splitout WBatchStockLevel from wFormula conversion 81731
'               V8 Data convertion: moved patient invoice into the DB 88863
'11Sep14 XN     PNDispense: Added m_RegimenRequestID, and SetRegimenRequestID    88799
'               PNDispense: Updated ProcessPN to use m_RegimenRequestID          88799
'               PNDispense: Updated GetEpisodefromSupplyRequest                  88799
'               PNDispense: Renamed GetEpisodefromSupplyRequest to GetEpisodeFromRequest and got to use RegimenRequestID   88799
'               TPNW: PNLoadRegimen - Got it to print prescription directly if no supply request ID   88799
'               TPNW: PNLoadProducts- got to use new regimen request ID          88799
'               ucPN: ProcessPN: added handling of regimen requestID
'25Sep14 XN     99425 WSLIST CreateDeliveryNoteRecord Prevent crash if pick number too large
'15Oct14 XN     ORDMAIN: lblHeading_Click: Allowed column header sorting to be case sensitive (TFS 87588)
'17Oct14 XN     OrderlobDISP.bas: DisplayDrugEnquiry: 88560 Prevented user from searching for drug via BNF (findrdrug)
'               StockEnquiryDISP.bas: DisplayDrugEnquiry: 88560 Prevented user from searching for drug via BNF (findrdrug)
'               ucDispense.ctl: DisplayDrugEnquiry: 88560 Prevented user from searching for drug via BNF (findrdrug)
'               FindDrug.FRM: AllowBNF: 88560 Control if allowed to show BNF
'               FindDrug.FRM: Form_KeyDown: 88560 Show BNF if user selects Alt+B
'               SubPatMe.FRM: AllowBNF: 88560 Control if allowed to show BNF
'05Nov14 XN     ucDispens.ctl: UserControl_KeyDown: 44134 Allowing focus to go back to control when dialog is closed
'06Nov14 XN     ucDispens.ctl: RefreshState: Added setting BSA (83897)
'               PNDispense.bas: ProcessPN: Added setting BSA (83897)
'               ucPN.ctl: RefreshState: Added setting BSA (83897)
'               WIdentsb.bas: patidtype: added SurfaceAreaInM2 (83897)
'               WIdentsb.bas: FillHeapPatientInfo: Added print heap elements pCalcSurfaceArea and pSurfaceArea (83897)
'               RptDisp.Bas: RptDispGetPatient: Added setting BSA (83897)
'               ucRepeatDispens.ctl: RefreshState: Added setting BSA (83897)
'               OCX.bas: AddOrUpdatePatientFromSessionExtension: Added BSA (83897)
'17Nov14 XN     AboutBox.frm: Removed Build Number from debug, and added correct version number, and copyright 59672
'               WinVer.bas:   Get verion number from app, and copyright date from app 59672
'04Dec14 XN     SubPatMe.Bas: Issue: Added range check on label count to prevent it blowing 32576
'29Dec14 XN     WPrescription.bas: Added GetRequestTypeByChildRequestID: To get the request type from child request ID 89292
'               PatPrint.bas: medicard: If doseless then should not print out the dose value on PMC 89292
'15Jul14 XN     SUBPATME:   FillHeapSupplierInfo: Added support for printing extra supplier data, and printing new fields National supplier code, DUNS reference, and user field 1 to 4 88506
'               SUPPLIER:   supplierstruct: Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506
'               SUPPLIER:   FillSupFromRS: Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506
'20Jan15 XN     CORELIB: WriteLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                               CORELIB: ReadLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                               CORELIB: GetWPharmacyLogTypeIDFromDescription: Added method to get the  WPharmacyLogTypeID 26734
'25Mar15 XN     LOGVIEW: NewUserLogViewer: Removed brackets from around Pack value in trans log viewer 114702
'08Apr15 XN     Wdctimp: WritePsionWardStockFile: prevent title line from showing packsize in output file 114692
'12May15 XN     TPNW.BAS: FillPrintHeapPN: Ensured there is a leading 0 on dosingweight < 1Kg 118106
'02Jun15 XN     TPNW.BAS: FillPrintHeapPN: Added missing print elements 120001 kcalpergN, modtextshort, regimen30, regimennomodtext, regimennomodtext30, pharmacytext, reqdoc
'15Jul14 XN     SUBPATME:   FillHeapSupplierInfo: Added support for printing extra supplier data, and printing new fields National supplier code, DUNS reference, and user field 1 to 4 88506
'               SUPPLIER:   supplierstruct: Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506
'               SUPPLIER:   FillSupFromRS: Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506
'20Jan15 XN     CORELIB: WriteLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                               CORELIB: ReadLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                               CORELIB: GetWPharmacyLogTypeIDFromDescription: Added method to get the  WPharmacyLogTypeID 26734
'30Apr15 XN     WProduct: Added DrugParameters.LabelDescriptionInpatient, and  DrugParameters.LabelDescriptionOutpatient alternate label for in-patients (TFS 98073)
'               PATSUBS: Added gDisableLabelDescriptionAlternative (TFS 98073)
'               PATSUBS: createlabel: added support for in-patient\out-patient specific label (TFS 98073)
'               PATSUBS: CastRecordsetToProduct: Reads in LabelDescriptionInpatient and LabelDescriptionOutpatient (TFS 98073)
'               SUBPATME: FillHeapDrugInfo: Added LabelDescriptionInpatient and LabelDescriptionOutpatient to heap (TFS 98073)
'05May15 XN     FINDDRUG: Form_KeyDown: 40374 If over 1 sec since key pressed then clear down the TxtSelect (used to typing to select the drug)
'                               FINDDRUG: MoveToSelection: 40374 re-enabled type letter to select a drug
'13May15 XN     WEpisodeIO: Added IsEpisodeOnEMMWard 26726
'               RefreshState: Added AllowReDispensingStr parameter to prevent reuse of dispensing records (mainly disabled for emm sites) 26726
'                             Added AllowReDispensingType Enum 26726
'05Jun15 XN             98073 updated everything with new local stores description
'08Jun15 XN     WINVER: Update txtBox_GotFocus to limit textbox width to 32767
'29Jun15 XN     PATMED: FillHeapLabelInfo: Added lLabelDrugDescription, lLabelDrugDescriptionXML, lLabelDrugDescriptionTrim, and lLabelDrugDescriptionTrimXML (98073)
'24Jul15 XN     ORDERLIB: findnumberofpages: Picking Tickets Page Number Error 119158
'                               ORDERLIB: printpick: Picking Tickets Page Number Error 119158
'27Jul15 TH     ORDERLIB: Putlinesinarray: Changed Screen msg to properly reflect the print (TFS 90862)
'27Jul15 TH     CORELIB: ASCTerminalName$: Added way of resetting terminal. Mid session user could change terminals then return to ocx (TFS 60163)
'27Jul15 TH     ucDispens.ctl: RefreshState: Added to reset the terminal name (in case switched mid session (TFS 60163)
'28Jul15 TH     ucDispens.ctl: TxtPrompt_KeyUp: Ensure WYSWYG is updated if ward is swapped (TFS 123260)
'28Jul15 TH     EDI.Bas: CheckInvInfo: Test against what we raise the order for, not what the cost variance is now (to stop new contracts causing exceptions) (TFS 120821)
'28Jul15 XN     Orderlib: supswithwords: Reordered, added Min Order column 92596
'29Jul15 TH     StoreASC.Bas: Editord: Dont use requisition num to look up on anything other than initial PT (TFS 72776)
'29Jul15 TH     StoreASC.Bas: IssuePick: Deal with possible exponential (TFS 102570)
'31Jul15 XN     SubPatMe.bas: Issue: Added range check on label count 92978
'03Aug15 TH     Orderlib.Bas: UpdatePrice: Mods to stop exponential in price last paid (TFS 102570)
'04Aug15 TH     WOrderIO.Bas: GetOrderDLOWard: Added check - we dont return DLO unless its a genuine order number (TFS 124853)
'05Aug15 TH     StoreASC.Bas: EnterActualReceive: Stop fractional receipt of orders when fraction not resolvable to 2 dec places (TFS 46785)
'05Aug15 TH     Orderlib.Bas: EnterAmend: Stop fractional ordering when fraction not resolvable to 2 dec places (TFS 46785)
'09Aug15 TH     ucDispens.ctl: Removed course length from custom frequency labels (TFS 125872)
'10Aug15 TH     SubPatMe.bas: OrderLog : Prefix decimal fraction under 1 / -1 for qty ordered and qty received with zero (TFS 125871)
'12Aug15 TH     Orderlib.Bas: EnterAmend: Added k.escd set - msg was displaying but still retained and saved the qty on issue unit check (TFS 126082)
'12Aug15 TH     StoreASC.Bas: EnterActualReceive: Removed inappropriate division by convfact from fractional receipt checks (TFS 126106)
'13Aug15 TH     ucDispens.ctl: Now mechanically still derive the duration (course length) from custom frequency labels  (TFS 126257)
'13Aug15 TH     Ordmain.Bas: AddLineToDisplaySQL: Added preceeding "0" to decimal (TFS 126282)
'13Aug15 TH     StoreASC.Bas: EnterActualReceive: Stop receipt of fractional issue unit (TFS 126355)
'17Aug15 TH     ucDispens.ctl: TxtPrompt_KeyUp: Added ucase and trim (TFS 123260)
'17Aug15 TH     Patmed.Bas: CheckRxComplete: If this is a custom dose we also dont need the time (as in PRN) (TFS 126360)
'17Aug15 TH     Patmed.Bas: Authorise: Custom frequency scripts do not need times. (TFS 126360)
'18Aug15 XN     Formula.bas: IssueAndPrintFormula: Changed setting batch number 64575
'                               Formula.bas: CIVASTransactionRollBack: Enable proper rollback of manufactured items 64575
'19Aug15 XN     ManIssue.frm: Moved code from IssueGrid_KeyDown to IssueGrid_KeyPress so pressing number keys in grid works better 118279
'04Sep15 TH     StoreASC.Bas: ReceiveItem: Fix costing fault on batch amalgamation for invoice (TFS 128729)
'15Sep15 TH     Patmed.Bas: CalcIV: Ensure we derive a dose in a similar matter to CIVAS Stat for Custom frequency - there is no dose in the slot so we have to scrape from the dircode text (TFS 129498)
'15Sep15 TH     Patmed.Bas: isCustomFrequency: Written as useful wrapper (TFS 129498)
'15Sep15 TH     ucDispens.ctl: TxtPrompt_KeyUp: Mod to scrape dose for custom frequency (as it does for Stat) when CIVAS (TFS 129498)
'15Sep15 TH     Formula.bas: CIVASDoseIncStat: Custom frequencies also need a derived dose so these are added here (TFS 129498)
'15Sep15 XN     PCT.bas: 51497 LogPCTClaimTransaction: set extra fields to null is wastage
'16Sep15 TH     ucDispens.ctl: RefreshState: Remove point correctly to pick up checkstandard (spoon) settings on dose (TFS 129773)
'15Sep15 TH     Ordmain.Frm: ProcessDrugLine: Ensure PSO partial invoices (per order) are handled correctly (TFS 127187)
'18Sep15 TH     ucDispens.ctl: AppendChildPrescriptionforLinkedRx: Written in attempt to simplify and refactor a little refreshstate (TFS 129844)
'18Sep15 TH     ucDispens.ctl: RefreshState: Extended and shifted handling of complex children to own sub for refactoring purposes (TFS 129844)
'18Sep15 TH     ucDispens.ctl: AppendChildPrescriptionforLinkedRx: Extended Prescription Infusion complex linking to allow for custom frequency(TFS 129929)
'17Sep15 TH     WPrescriptionIO.Bas: PrescriptionToOCXHeap: ANeed to support infusions in linked Rxs !(TFS 129844)
'22Sep15 TH     BondStore.Bas: BondStoreReleaseBatch: Bond store cost centre should be used not the main MANU code (TFS 127582)
'28Sep15 TH     ucDispens.ctl: ProcessLabelDuration: Written to refactor (a bit) refreshstate. This just process the durational aspect of the direction codes incomming (TFS 130610)
'28Sep15 TH     ucDispens.ctl: RefreshState: Extended and shifted handling of  durational aspect of the direction codes to own sub for refactoring purposes  (TFS 130610)
'29Sep15 TH     StoreASC.Bas: MainOptions: Ensure there is no possibility of previous supplier being used on receipt display (TFS 127190)
'29Sep15 TH     Finanasc.Bas: DisplayCreditInfo: Tidied up cursor handling and tried to get the correct supplier details on caption where possible (TFS 127190)
'14Oct15 TH     PNDispens.Bas: ProcessPN: Added section to get patietn status (for kind in any potential translog) (TFS 132485)
'03Nov15 TH     ucDispens.ctl: RefreshState: Added Trim on description to ensure correct check for selecting drug name on split dose prompt (TFS 132827)
'12Nov15 TH     StorePSO: Receive_eHUBPOD: Added Trim to ensure correct check on new description (TFS 132827)
'12Nov15 TH     Ordmain.Bas: SiteDrugEnquiry: Added Trim to ensure correct check on new description (TFS 132827)
'12Nov15 TH     ucDispens.ctl: RefreshState: Check on trimmed description (TFS 134982)
'03Dec15 TH     Patsubs.bas: ReprintFile: More appropriate message when reprint not found (TFS 137255)
'15Oct15 TH     ucDispens.ctl: AppendChildPrescriptionforLinkedRx: PRNs may not have direction - these and stat are now handled correctly (though should never be stat as secondary rx) (TFS 137379)
'20Oct15 TH     ucDispens.ctl: AppendChildPrescriptionforLinkedRx: Overhauled to use correct joining word on label (TFS 137379)
'04Dec15 TH     WPrescriptionIO.Bas: PrescriptionToOCXHeap: Ensure PRN is recorded TFS 137379)
'06Dec15 TH     WIdentsb.bas: Buildname: Ensure Mc Rule can accomodate 20 char surname (TFS 124058)
'13Dec15 TH     PSODisp.Bas: CreatePSOrder: Removed New patient from none Hub order (Hub and None Hub should be aligned) (TFS 138047)
'14Dec15 TH     Orderlib.Bas: UpdatePrice: Reverted mod because the mask only protects manual price entry and we can get exp costs
'                                          from automated receipt (internal order). Also added mod to remve exp where cost changed but no stock(TFS 137904)
'16Dec15 XN     WEpisodeIO: IsEpisodeOnEMMWard: used sp rather the db function so works with web transport layer 138581
'19Dec15 TH     Ordmain.Bas: Printorder: Sorts of rs not currently supported in the ado rs from web transport (TFS 138697)
'06Jan16 TH     ucDispens.ctl: TxtPrompt_KeyUp: Mod to installment disp so decrement/decrement is by label NOT rx to allow split dose installment dispensing (TFS 138797)
'18Jan16 TH     ucDispens.ctl: AppendChildPrescriptionforLinkedRx: Added DurationLastCOde as input param so it can be cached externally and resent (TFS 141453)
'                                                Added PRN specific joining settings and made the setting used after a stat more explicit (TFS 141453)
'18Jan16 TH     ucDispens.ctl: RefreshState: Added param to AppendChildPrescriptionforLinkedRx call (TFS 141453)
'24Sep15 XN     TPNW: FillPrintHeapPN: Add all the aliases to the heap 77778
'29Sep15 XN     WPrescription.bas: SiteSpecificRxInfoToPrintHeap: Added (TFS 77778)
'               ucDispens.ctl: RefreshState: Added site specific Rx print elements to heap (TFS 77778)
'06Oct15 XN     OrderLibDISP.bas: CallWebMethod: add method 77780
'               ucDispens.ctl:  RefreshState: Added support for converting Chinese name to RTF so can print out 77780
'04Nov15 TH     ucPN.ctl: ProcessPN: Clean rx and disp globals prior to loading any regimen, make sure we have nothing in state (TFS 133853)
'04Nov15 TH     TPNW.Bas: PNLoadRegimen: Load the PNPrescriptionID and Supply request into the globals here so we can use this in any transaction logs (TFS 133853)
'14Oct15 TH     PNDispenseMain.Bas: ProcessPN: Added section to get patient status (for kind in any potential translog) (TFS 132485)
'15Nov15 TH     PharmacyWebData: Transport :ExecuteSelectSP: Explicit set of curosr loaction to adUseClient to try to preserve filter, find and sort properties (TFS 134997)
'25Nov15 XN     PatMed.bas: CIVASCheck: Removed sort and moved to so web service works 134997
'12Feb15 XN     WPrescription.bas: SiteSpecificRxInfoToPrintHeap: 145005 Fixed printing of chinese name and language on worksheet
'16Feb16 XN     ucPN.ctl: ProcessPN: Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing 145448
'               TPNW.Bas: PNLoadRegimen: Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing 145448
'16Feb16 TH     Formula.bas: ParseFormulaData: Changed dosesperissueunit to single to stop inappropriate rounding (TFS 136119/145490) Port from 15Dec15 TH
'23Feb16 TH     Formula.bas: SyringeContainers: FIx rounding on volume on last syringe (TFS 146402)
'16Mar15 TH     Formula.bas: StoreandTotal: Reworked and added elements around volumes (TFS 148108)
'16Mar15 TH     Formula.bas: InitialiseHeapItems : cleaned out and reset elements and new variables (TFS 148108)
'26Apr16 TH     ucDispens: RefreshState: Mod to ensure dose qty box is shown on each pass for pat specific CIVAS issue (TFS 152118)
'01Feb16 TH     StorePSO: Invoice_eHUB: Changed input call to asksupplier (TFS 138644)
'01Feb16 TH     Supplier.Bas: AskSupplier: Changed PSO param from boolean to enum. THis allows now tristate value, but retains existing "false" as "all"
'                             Now we can support "ALL","PSO","NONE PSO". existing default of false translates to "ALL" which is correct. (TFS 138644)
'01Feb16 TH     Orderlib.Bas: Entersite: Changed input to asksupplier for PSO filtering (TFS 138644)
'04Feb16 TH     Guibits.Bas: LstBoxShow: Added option param to add extra button (TFS 138641)
'04Feb16 TH     LstBox.Frm: Added New Extra button with support (TFS 138641)
'                           Optional param in handler allow caption to be added - the tag denotes whether the button is pressed.
'                           Originally used as delete option for Hub Invoicing
'05Feb16 TH     StorePSO: SetHUBItemArchivable:Written based on SetMediateItemArchivable, seperate proc as likely to diverge (TFS 138638)
'05Feb16 TH     StorePSO: DisplayHUBExtraInfo: Written based on DisplayEDIExtraInfo, seperate proc as likely to diverge (TFS 138638)
'06Feb16 TH     Finanasc.Bas: FinEditOrd: Support for HUB Invoicing - largely ability totrack manual invoicing of failed electronic HUB uploads (TFS 138638)
'07Feb16 TH     StorePSO: ReadHUBInvoices: Refactored after discussion with Sue and Andrew Simons
'                                          After initially writing simpler for of auto invoicing, have decide now to repliacte as first pass the exact mechanism
'                                          used by EDI to handle exceptions and archiving of invoice data. (TFS 128638)
'07Feb16 TH     StorePSO: ReadHUBInvoices: Modified IO to HubInvoice and Archive tables
'08Feb16 TH     StorePSO: ReadHUBInvoices: Modified exception handling to use full datetime (TFS 138628)
'08Feb16 TH     StorePSO: ReadHUBInvoices: Only offer to print exceptions if there are any to print (TFS 144215)
'18Feb16 TH     StorePSO: CheckHubInvInfo: Added orderID param to get pat details in main sub (TFS 138645)
'18Feb16 TH     StorePSO: CheckHubInvInfo: Modifications and rework after initial testing (TFS 138645)
'18Feb16 TH     StorePSO: ReadHUBInvoices: Modifications and rework after initial testing (TFS)
'19Feb16 TH     StorePSO: ReadHUBInvoices: Altered IO for hub archiving as was incorrect. (TFS) -- Paydate handling needs review
'22Feb16 TH     StorePSO: ReadHUBInvoices: cache file name value as the listbox will now been unloaded (TFS 146047)
'22Feb16 TH     StorePSO: CheckHubInvInfo: Removed HUB Receipt check after discussion with Sue and Andrew (TFS 146056)
'25Feb16 TH     StorePSO: ReadHUBInvoices: Changed cursor handling
'02Mar16 TH     StorePSO: ProcessHubInvInfo: Changed Paydate to genuine date - previously it was sending strPaydate into DB and was being mangled (TFS 146872)
'10Feb16 TH     BondStore.bas: BondStoreReleaseBatch: Fixed cut and paste error - option says release not destroy batch (TFS 144417)
'16Feb16 TH     Formula.bas: ParseFormulaData: Changed dosesperissueunit to single to stop inappropriate rounding (TFS 136119/145490) Port from 15Dec15 TH
'17Feb16 TH     BondStore.bas: BondStoreReleaseBatch: Changed error msg also after Code Review (TFS 144417)
'15Dec15 TH     Formula.bas: ParseFormulaData: Changed dosesperissueunit to single to stop inappropriate rounding (TFS 136119)
'19Jan16 TH     ManIssue.Frm: Form_Load, lblDate_Click,lblTime_Click : Changes to allow for caching of PrepDate TFS 124077
'11Feb16 TH     frmLogView.frm: ImgDrug_Click: Allow ALL items to be picked, stores only and out of use included (TFS 144716)
'11Feb16 TH     frmLogView.frm: txtDrug_KeyPress: Allow ALL items to be picked stores only and out of use included (TFS 144716)
'01Mar16 XN     ucDispens.ctl: PopupFunctionMenu, UserControl_KeyDown: Removed F6 short cut, as does not work with web 104303
'30Mar15 XN     tpnw.bas: PrintTPNlabel: Added PN Paed Label type 102357
'               tpnw.bas: PNLayoutEditor: Added pn paed labels 102357
'               tpnw.bas: HasLayout: added function 102357
'26Apr16 TH     ucDispens: RefreshState: Mod to ensure dose qty box is shown on each pass for pat specific CIVAS issue (TFS 151553)
'23Feb16 TH     Formula.bas: SyringeContainers: FIx rounding on volume on last syringe (TFS 146402)
'16Mar15 TH     Formula.bas: StoreandTotal: Reworked and added elements around volumes (TFS 148108)
'16Mar15 TH     Formula.bas: InitialiseHeapItems : cleaned out and reset elements and new variables (TFS 148108)
'06Apr16 XN     StoreASC.bas: EditStockLabel: trimed LocalDescription before comparing it to "" 149885
'                             ProdStockEditor.ctl: trimed LocalDescription before comparing it to "" 149885
'                             DrugExt.bas: QuesSetState: trimed LocalDescription before comparing it to "" 149885
'22May16 TH     Formula.bas: ParseFormulaData: Unload the syringes form before use to ensure no values can be cached or re-used (TFS 153997)
'27May16 XN     WEpisodeIO.bas: IsEpisodeOnEMMWard: 154416  changed EpisodeID to Long

'07Apr16 XN     StorUtil.bas: LogViewer: Removed (S)tock maintenance and (N)egative stock lookup options as moved to DB (123082)
'07Apr16 XN     SubPatMe.bas: checklossgain: Moved gainloss log to db 123082
'                               SubPatMe.bas: Issue: Moved negative log to db 123082
'                               Formula.bas: DoIssue: Moved negative log to db 123082
'03May16 XN     CoreLibPrintJob: Added SetChrome so user can select printer 123082
'                           CoreLibPrintJob: Added ListBoxTextBoxSetTabs so user can select printer 123082
'               HighAscPrintJob: Added CitrixOverridePrinterPort os can citrixis printer 123082
'               PrintJob: Added support of allowing user to select printer 123082
'04May16 XN     PatSub: Added gRequestID_AmmSupplyRequest
'                               ucDispens: RefreshState: Updated for amm 123082
'                               ucDispens: PrintLabel: Added for amm 123082
'                               ucDispens: DispensLoad: Updated for amm 123082
'                               ucDispens: PopupFunctionMenu: Updated for amm 123082
'17May16 XN     ucStores: ConvertTobase64 149374
'18May16 XN     ucDispens: ReprintLabel: Added for amm 153668
'                               ucDispens: PrintLabel: allowed it to do save Reprints 153668
'21Jun16 XN     ucDispens: PrintLabel: Fixed syringe volume 154896
'                               Formula.bas: resizeSyringeLabel: 154896 Added for Amm
'                               Formula.bas: setSyrineLabelVolume: 154896 Added for Amm
'                               Formula.bas: setSyrineLabelDose: 154896 Added for Amm
'06Jul16 XN     WSList.bas: PrepareIssue: Fixed issue with dispensing to ward stock list lines with id over 32000 (157521)
'               WSList.bas: concat: Made input parameter long (157521)
'09Jul16 TH     WSList.bas: PrepareIssue: Renamed topuplevel variable and changed to long (TFS 157679)
'09Jul16 TH     SubPatMe.Bas: setm_lngWardStockTopUpLevel: Renamed and changed to long (TFS 157679)
'09Jul16 TH     SubPatMe.Bas: Issue: Renamed topuplvl variable and changed to long (TFS 157679)
'02Aug16 XN     Dispense.bas: g_URLToken: Moved to CoreLib.bas 159413
'                               OrderlibDISP.bas: ParseCommandURLServerAndWebFolder : Made public so can get site url form other parts of the system 159413
'                               ucDispens.ctl: GetLabelText: Added to allow getting label text without printing, or saving 159413
'                               CoreLib.Bas: g_URLToken: Moved to CoreLib so can be accessed by other parts of the system 159413
'                               Patsubs.bas DisplaytheLabel: Added copies count as optional parameter 159413
'                               Formula.bas: AllocateNewBatchNumber: If setting D|Patmed.ManufacturingBatchNumber.UseWeb is on will get the manufacturing batch number from the web (from PharmacyCounter table) 159413
'02Aug16 XN     ucDispens.ctl: PrintLabe: 158642 Fix moving to next stage from AMM labeling stage
'05Aug16 KR     ucStores.ctl:  WardStockAction, WardStockExport, WardStockActionForUnsavedLine Initialise StoreValue (Bug 159577)
'               WSList.bas:    LoadWardLineIntoDrugDetails. Amended call to findrdrug (Bug 159577)
'08Aug16 XN     Formula.bas:   AllocateNewBatchNumber: 159843 Fixed to getting web based batch number
'                       ucDispens.ctl: PrintLabel: 159843 Now reads expiry from DB
'                               RepeatDispense.bas 159843 Moved ParseCommandURLServerAndWebFolder and CallWebMethod from OrderLib to CoreLib
'                               PNDispense.bas
'                               Orderlib.bas
'                               CORELIB.BAS
'12Aug16 XN     CORELIB.BAS: ParseCommandURLServerAndWebFolder: fixed issue coverting URL 160253
'16Aug26 XN     StoresAsc.Bas: issuepick: 160233 PrintDeliveryNote comes from Ward stock list now
'                               StoresAsc.Bas: receiveitem: 160233 PrintDeliveryNote comes from Ward stock list now
'                               StoresAsc.Bas: ReturnToStore: 160233 PrintDeliveryNote comes from Ward stock list now
'                               WOrder.bas: FillOrdFromRS: Fixed if WWardProductListLineID is null 160233
'                               Supplier.bas: IfRequiresDeliveryNote: 160233 Gets if the ward stock list requires printing a delivery note
'               Supplier.bas: IfRequiresDeliveryNoteByWardCodeNSVCodeAndSite: 160233 Gets if the ward stock list requires printing a delivery note
'24Aug16 XN     ucDispens.ctl: PrintLabel: 160920 Fixed expiry
'26Aug16 XN     ucDispens.ctl: PopupFunctionMenu: Added filtering of Return Stock for amm 161138
'                               Formula.bas: resizeSyringeLabel: 154896 Added for Amm
'                               Formula.bas: setSyrineLabelVolume: 154896 Added for Amm
'                               Formula.bas: setSyrineLabelDose: 154896 Added for Amm
'08Jul16 KR     SubPatme.bas: getbatchnum: 138721 Added Trimz to remove superfluous characters.
'11Jul16 KR     ucPN.ctl: RefreshState: 138707 Check for out-of-use wards and consultants prior to dispensing
'21Jul16 XN     EDI.bas: CheckInvInfo: Added EDIProductIdentifier check 126634
'                               EDI.bas: DisplayEDIExtraInfo: Added EDIProductIdentifier check 126634
'                               EDI.bas: ProcessInvInfo: Did lookup via EDIProductIdentifier 126634
'                               EDI.bas: SendEDIOrder: If EDI Barcode is set then send as localcode 126634
'                               EDI.bas: ReadInvoices:  Did lookup via EDIProductIdentifier first 126634
'                               Finanasc.bas: SetMediateItemArchivable: Added EDIProductIdentifier 126634
'                               WOrderDISP.bas: Added EDIProductIdentifier to orderstruct 126634
'                               WOrderDISP.bas: FillOrdFromRS: read in EDIProductIdentifier for WOrder, and WReconcil 126634
'                               WOrderDISP.bas: PutOrder: Added support for writing EDIProductIdentifier for WOrder, and WReconcil to DB 126634
'                               WOrder.bas: Added EDIProductIdentifier to orderstruct 126634
'               WOrder.bas: FillOrdFromRS: read in EDIProductIdentifier for WOrder, and WReconcil 126634
'               WOrder.bas: PutOrder: Added support for writing EDIProductIdentifier for WOrder, and WReconcil to DB 126634
'                               WProduct.bas: Added DrugParameters.EDIBarcode 126634
'                               WProduct.bas: CastRecordsetToProduct: Added reading EDIBarcode 126634
'               WProduct.bas: BlankWProduct: Clear EDIBarcode 126634
'                               SubPatMe.bas Added TSupProfile.EDIBarcode 126634
'                               SubPatMe.bas DrugToSupProfile: Added setting of EDIBarcode 126634
'                               SubPatMe.bas FillHeapDrugInfo: Added EDIBarcode to printing 126634
'                               SubPatMe.bas getdrugsup: Added setting EDIBarcode to blank 126634
'                               SubPatMe.bas GetSupProfile: Added reading EDIBarcode to blank 126634
'                               SubPatMe.bas SupProfileToDrug: Added reading EDIBarcode to blank 126634
'                               SubPatMe.bas SupProfileToDrugSQL: Added reading EDIBarcode to blank 126634
'10Oct16 XN             Ordmain.BAS: Added reading EDIBarcode to blank 164384
'20Jan17 CKJ    Subpatme: Issue: Only request robot labelling for actions which allow it (TFS 106390)
'09Feb17 XN     ManuLnch.bas:  Main: added cached URL so frmWebClient has a web server name (176200)
'29Nov17    KR  TPNW.bas        Fixed doseweight printing a trailing . even if dosing weight set as an integer. TFS199184

Option Explicit
DefInt A-Z

''   '==testbuilds==
''   Global Const ASCver = "9.5 TestBuild"
''   Global Const ASCRelease = " NOT for CLINICAL USE"
''
''   '==releases==
''   'Global Const ASCver = "9.5"
''   'Global Const ASCRelease = ""     'Next Release -> "r1" ****NOTE: MUST include the "r"****
''
''   '==all builds==
''   Global Const ASCBuildNo = "001 NOT for CLINICAL USE"

'Const VER_Architecture = "10"         17Nov14 XN removed 59672
'Const VER_Major = "9"                 17Nov14 XN removed 59672
'Const VER_Minor = "0"                 17Nov14 XN removed 59672
'Const VER_Build = "0"                 17Nov14 XN removed 59672
'Global Const ASCver = VER_Architecture & "." & VER_Major & "." & VER_Minor & "." & VER_Build   17Nov14 XN removed 59672
Global Const ASCRelease = ""
'Global Const ASCBuildNo = VER_Build   17Nov14 XN removed 59672

'Global Const CopyrightYear = "2013"   17Nov14 XN removed 59672

' Gets correct version number form App
' 17Nov14 XN 59672
Public Function ASCver() As String
    ASCver = Format(App.Major, "00") & "." & Format$(App.Minor, "00") & ".00." & Format$(App.Revision, "000")
End Function

' Gets correct build number form App
' 17Nov14 XN 59672
Public Function ASCBuildNo() As String
    ASCBuildNo = Format$(App.Revision, "000")
End Function

' Gets correct copyright year form App
' 17Nov14 XN 59672
Public Function CopyrightYear() As String
    Dim yearStartIndex As Integer
    yearStartIndex = InStr(App.LegalCopyright, "20")
    If yearStartIndex > 0 Then
        CopyrightYear = Mid$(App.LegalCopyright, yearStartIndex, 4)
    Else
        CopyrightYear = "2014"
    End If
End Function

