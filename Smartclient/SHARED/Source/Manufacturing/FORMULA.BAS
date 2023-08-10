Attribute VB_Name = "FORMULA1"
'Manufacturing support procedures for manufacturing extemporaneous issue and CIVAS
'01Jul96 ASC written
'12Aug96 ASC modified after alpha test and to include more flexible printing
'20Sep96 CKJ ParseFormulaData: Changed expiry from 8 chars to 10
'            NB Possible faults marked with !!**
'23Sep96 CKJ Cludge for ManufBatchNums
'25Sep96 CKJ IssueAndPrintFormula: Removed "BN:" and changed Cost calculation
'            ParseFormulaData: Removed "BN:" and added dp! and plural$()
'              Added check for expiry date missing
'27sep96 KR  Removed / d.DosesPerIssueUnit in call to issue in ParseFormulaData.
'            Also changed 'FormulaQty! / d.mgPerml' to 'FormulaQty! * d.DosesPerIssueUnit' so that
'            correct quantity gets printed on the worksheet.
'29sep96 added another parsetime and parsedate to stop differences from parstime and time$
'        results making below re-ask for genuine time
'
'16Oct96 KR Added "Manufacturing" parameter to call to AskPassword
'29Nov96 ASC made lcase of d.printformv and d.dosingunits for consistency abd removed printrx and editing of Rx layout
'15Dec96 section moved here from Issueandprint to allow work sheet details to be passed to full worksheet
'        Printworklabel moved from patsubs.bas
'24Jan97 KR  Changed trim$ to trimz in ParseFormula Data when checking patient structure (pid) because when this procedure is called
'            from manufacturing, this variable has been not been set.  Trim$ does not remove the null
'            characters and HE assumes that null character is the end of the string to display.
'18Jun97 ASC/KR ParseFormulaData: Fixed endless loop bug by adding an else statement when check for drugs of different strengths.
'20Jun97 KR  PrintWorkLabel: Now prints prescription id on label.
'27Mar97 KR  GetNewFormula: Ensured that only call setfocus if formula form visible.
'27Jun97 KR  ParseFormulaData: Ensured issue qty * number of doses
'03Jul97 KR  Ensure expiry dates are millenium aware.
'07Jul97 KR  IssueAndPrintFormula: Unload issue form after use so that resizes correctly next time used.
'14Jul97 KR  IssueAndPrintFormula: Set k.escd to false prior to calling MakeExpiry - Prevents Type mismatch error trying to assign empty string to an access date field further on.
'14Jul97 KR  ParseformulaData: Check for blank method during parsing - prevents illegal function call error if no method present.
'25Aug97 ASC Fixed problem with pack size in manufactured items. (Code copied by CKJ from email)
'27Aug97 CKJ ParseformulaData: Added correction from EAC - adds extra opening { to RTF stream
'21Nov97 CFY/ASC Multiple Issues. Now all multiple issues are carried out in batch.
'30Dec97 ASC removed NSVcode from worksheet detail line and added access to total cost with and without VAT for QC
'            if [manufacturing] section of patmed.ini has QC=1 then stock is not incremented at manufacturing so that
'            the stores can be used to increment stock when the batch passes QC
'19Jan98 CKJ Printworklabel now RTF enabled
'        CKJ/ASC ParseFormulaData: Reinstated two stage processing of ingredients/consumables
'20Jan98 CKJ/CFY ParseFormulaData: Replaced string + with &
'            Reinstated FormulaQty calculation, to original functionality
'22Jan98 ASC ParseFormulaData: Corrected maths in multiple issue box which was not multiplying by number of doses (CKJ)
'28Jan98 CFY ParseFormulaData: Corrected parameters passed to DoIssue
'            DoIssue: Added a getdrug
'13Feb98 CFY DoChkIssue: Completely re-arranged logic so that handling of errors is prioratised
'                        according to severity.
'            ParseFormulaData: Removed unused parameter from ChkIssue procedure (now uses k.escd).
'                              Tightened code which checks if a drug exists.
'                              Added extra conditions to bring exececution out of procedure if escape occurs
'17Feb98 CFY ParseFormulaData:     Added blister packing code
'            IssueAndPrintFormula:           "
'23Feb98 CKJ Issueandprintformula: The translog line was commented out, no date, no initials
'            This line brings manufactured items back into stock and surely must remain
'            I have therefore reinstated the line pending investigation.
'23Feb98 CKJ ParseFormulaData: Prevent infinite loop while filling IssueSummary()
'24Feb98 ASC/CFY Added code to make multiple strenght issuing work.
'31Mar98 CFY getnewformula: Added code to set k.escd to True if the user decides not to add a new formula
'            for this product. Previously if the user said no the program would still start
'            to add a new product, prompt the user if they wished to save, then fall over if they
'            said Yes.
'            CallManufacturing: Removed condition to allow getnewformula to always be called, regardless of whether
'            a drug has been loaded or not. Previously if callmanufacturing was called with a drug
'            loaded, ie. from the dispensary, the formula would not be displayed on screen as all
'            the code to populate the form is held in getnewformula.
'27Apr98 CFY ParseFormulaData: Re-instated code which puts the correct formula quantities onto the worksheet as
'              opposed to the quantities which have been issued.
'06Jun98 CFY ParseFormulaData: Corrected quantity calculations and removed nsv code from title line.
'13Jun98 ASC ParseFormulaData:Tabs on consumables and batch fix corrected to line up printing
'18Jun98 CFY ParseFormulaData: Fix to stop issue box appearing when in issue mode.
'18Jun98 CFY DoIssue: Extra condition to stop issue occuring when in preview mode.
'19Jun98 CFY IssueAnPrintFormula: Trap added stop stop manufacturing costcentres being specified in patmed.ini which
'             are "" ie. empty string. If this happens a warning is given and a defualt cost centre
'             is set.
'19Jun98 CFY getnewformula: Removed setting of k.escd = False at end of procedure as this overides any setting
'             of the flag that occured during the procedure. Previously the calling routine was
'             unable to tell if escape had been hit or not.
'25Jun98 CFY ParseFormulaData: Removed 1 tab stop from the title line to correct alignment problems.
'26Jun98 CFY PrintWorkLabel: Now only prints the extra blank line at the beginning of the if the civas item has
'            no formula has been attached.
'20Jul98 EAC added patient and drug details to print heap for HK mods
'30Jul98 EAC make manufactured item cost and quantity available to OCX
'27Aug98 TH  PrintManWorksheet: Copies worksheet to file to allow for reprint
'28Aug98 TH  ParseFormulaData: Changed formats to suppress stray decimal points
'30Aug98 ASC ParseFormuladata: Now multiplies To qtys by batch size divided by To qty as best estimate of qty to be issued
'14Sep98 TH  PrintWorkSheet: Changed formats of dose$ and dosevol$
'15Sep98 TH  ParseFormuladata: Changed formats to round down numbers
'24Sep98 TH  Printworklabel: Changed various formats
'24Sep98 TH  ParseFormuladata: Changed formats
'27Oct98 ASC/CFY ParseFormulaData: see dated comments doses% and qty! now not set to 1 if zero unless a preview to stop erroneous issues when 0 qty entered.
'            Now finds the layout to add in consumable and ingredient check text to each formula
'13Nov98 EAC PrintWorkLabel: HK mod to display full Hospital Number on the labels
'19Nov98 CFY Procedure: StoreandTotal written.
'19Nov98 CFY Procedure: PromptForWrkSheet written.
'19Nov98 CFY Procedure: InitialiseHeapItems written.
'19Nov98 CFY Procedure: FileLayoutCombos written.
'19Nov98 CFY PrintWorkLabel: Added PatsPerSheet and layout to parameter list
'19Nov98 CFY PrintManWorksheet: Now re-written to deal with multiple patient worksheets and
'            printing using the printheap and library based printing routines. The old version
'            of the proedure has been renamed OldPrintManWorksheet.
'19Nov98 CFY ParseFormulaData: re-written main routine so that it now uses the print heap rather than parsing the
'            information here. Old routine has be renamed OldParseFormulaData
'19Nov98 CFY IssueAndPrintFormula: Added PatsPerSheet% and Layout$ to parameter list
'19Nov98 CFY callmanufacturing: Extra code added to initialise the new controls that have been added to the manufacturing
'            form
'19Nov98 CFY AMendLayout: Modified to handle multiple layouts.
'09Jan99 ASC Look at previos versions of formula.bas for OldPrintManworksheet if needed all comments now removed
'            - Added facility to have an patient specific formula
'21Jan99 CFY InitialiseHeapItems: Added code to initialise array that keeps running total of qty's used
'21Jan99 CFY StoreandTotal: Now correctly totals the dosing qty's.
'24Feb99 SF  AmendLayout: if amending a manufacturing ff label then restrict to 9 lines to allow expiry/batch# to fit on
'24Feb99 SF  IssueAndPrintFormula: added and sets escd% parameter
'24Feb99 SF  IssueAndPrintFormula: now doesn't ask to allocate a batch for a patient if called from main menu
'24Feb99 SF  IssueAndPrintFormula: now exits the sub at various points where cancel selected
'24Feb99 SF  ParseFormulaData: added and sets escd% parameter
'24Feb99 SF  PrintManWorksheet: added and sets escd% parameter
'24Feb99 SF  PrintWorkLabel: added and sets escd% parameter
'24Feb99 SF  PromptForWrkSht: added and sets escd% parameter
'05May99 CFY PrintManWorksheet: Modified worksheet preview facility so that worksheets are previewed to screen not to printer
'04Jun99 CFY ParseFormulaData: Fixed problem with multiple vial sizes. Now allows user to do multiple issues.
'             Also changed the issuing so that the ingredient products are issued to manufacturing even if doing an extemp
'             item. This is because the final product is now charged to the patient.
'            IssueAndPrintFormula: Now write balancing transactions when doing extemp items. Also removed code which prompts fro batch number from
'             this procedure and made into a separate routine. This enables generation of the batch number before the dispenary
'             label is printed which must be printed before the worksheet.
'            PromptBatchNumber: Written. As well as calling the routine which generates batch numbers, optional functionality
'             added to allow the user to enter their own.
'            ReturnCivasItem: Written.
'            TransactionRollback: Written.
'09Jul99 CFY Various mods to take into account patient specific formulas
'28Jul99 AE  Various fixes and mods to formula for GOS.
'            Unbound the controls, removed the data control FormulaData.
'            CallManufacturing: Added parameter 'viewmodes' to allow setting up of the form according
'                 to its context (eg, whether called from manufacturing or dispensing)
'                 Various mods as part of control unbinding
'            AmmendLayout: mods as part of control unbinding
'            BlankFormulaForm:      "
'            BlankFormulaLine:      "
'            DeleteFormula: Written to replace the code in the CmdDelete_Click event as part of
'                 control unbinding
'            GetNewFormula: Re-written as part of control unbinding.  Old procedure re-named GetNewFormulaOld
'            GetViewMode : Written to allow procedures in Formula.Frm to see the value of formulaviewmode%
'            InitialiseHeapItems: Added fixes to stop [rtotalunits] persisting between worksheets
'            IssueANdPrintFormula Open / Close FormulaDatabase added as part of control unbinding.
'            ParseFormulaData:  Added line to clear the item [method] on the print heap. Previously was persisting, so if we printed two
'                  worksheets, the first with a method and the second without, the second would contain the method from the first.
'                  Also replaced the word "doses" at the end of a batched produced item (in [description]) with d.printformV
'                  This is as it was in previous versions and seems to have been changed in error
'            PromptForWrkSht: Set k.escd if no layout defined
'            SaveFormula: Written as part of data control unbinding, and to fix bug where patient
'                  specific formulas were being saved as duplicates of the master formula.
'            SetFormulaForm: Written
'            SetFormulaView: Written
'            PrintManWorksheet: Corrected logic in IF statement
'03Aug99 AE / CFY IssueandPrintformula:Fixed call to translog. Was previously not doing the manufacturing balancing transaction.
'03Aug99 AE  DoIssue:Added lines to make manufactured items balance in translog. Previously, the
'            final price of the manufactured item was made of the total costs of each ingedient,
'            excluding vat, multipled by the packsize and thus never balanced.  Now is
'            made of the cost of the amount of each ingredient used including vat.
'04Aug99 CFY ParseFormulaData: Mod to display correct units when issuing multiple strength vials.
'05Aug99 CKJ/AE SaveFormula:Moved Section updating TableLayuot to after ds.update
'05Aug99 CKJ/AE SaveFormula:removed Lockmode
'05Aug99 CKJ/AE SaveFormula:Added Close prior to destroying recordsets
'05Aug99 CKJ/AE SaveFormula:Mods to error handling
'05Aug99 CFY IssueAndPrintFormula: Fix to prevent extemp items increasing the stock levels when they are made.
'03Sep99 AE  AmendLayout:Block added to convert plain text labels into rtf
'02Sep99 CFY Changed Desc length in TIssueSummary type from 50 to 623 to stop truncation.
'03Sep99 AE / CY PrintManWorksheet: Added line to search for patient specific formula before drug specific one.
'03Sep99 AE / CY IssueAndPrintFormula: Fix to make patient specific formulas be written to translogs properly
'03Sep99 AE  SaveFormula:Fix to allow items to be removed from a formula
'06Sep99 CFY parseformuladata: Now only displays total quantity for 1 vial size when issuing multiple strength vials. Other vial strengths
'            will be listed with no quantity.
'07Sep99 CFY DoIssue: Extemp% added to parameter list as do not need to divide by packsize when doing batch manufacturing
'08Sep99 CFY GetNewFormula: Initialialised formula type to prevent errors occuring when trying to select a new formula
'            which doesn't exist
'27Sep99 CFY TransactionRollback: Corrected and simplified transaction rollback.
'11Oct99 CKJ GetFormula: Before opening formula database, check flag in drug file
'            Issueandprintformula: Removed OpenFormulaDatabase - see inline comments
'            ResetHasFormulaFlag written
'            Saveformula: Update d.HasFormula flag for d.siscode
'            NOTE: d.HasFormula is not reset during DeleteFormula. This is deliberate & is because there might be a
'                  patient formula left on-file even if the main formula has been removed from use.
'22Oct99 CKJ GetFormula: Corrected d. to dTmp.
'05Jan00 AE  SaveFormula: Corrected d. to use d.tmp
'13Jan00 CFY ParseFormulaData: Fixed a number of rounding errors.
'21Feb00 SF  blankformulaline: now blanks NSV code column
'13Mar00 AW  Parseformuladata: Added if then statement to check issueqty!. If user has changed issue qty to 0 was not taking this into account
'            when working out cost of formula. Resets formulaqty! and issuecost$ for that ingredient.
'19May00 AW  Parseformuladata: Added format mask to prevent rounding errors on civas worksheets.
'24May00 AE  ParseFormulaData:added FormatVal to round quantity to 7sig figs/2decpl in the [formula] data item.
'02Jun00 JN  SetExpiryDate: written to parse expiry date
'02Jun00 JN  IssueAndPrintFormula : Added CIVAS related enhancements
'05Jun00 JN  GetBatchPointer: Written to return and then increment batch numbers from GetPointer
'22Jun00 TH/AW DoIssue: Added code to calculate costexvat price of manufactured items.
'              IssueAndPrintFormula: Added code to calculate costexvat price of manufactured items.
'14Jul00 JN  CallManufacturing : added a reference to an instance of formula.frm
'14Jul00 JN  SaveFormula : added a reference to an instance of formula.frm
'14Jul00 JN  SetFormulaView :  "   "   "    "    "   "       "     "
'14Jul00 JN  AmendLayout: added a reference to an instance of formula.frm
'14Jul00 JN  CancelFormula: added a reference to an instance of formula.frm
'14Jul00 JN  SetFormulaForm: added a reference to an instance of formula.frm
'14Jul00 JN  BlankFormulaForm: added a reference to an instance of formula.frm
'14Jul00 JN  BlankFormulaLine: added a reference to an instance of formula.frm
'14Jul00 JN  GetNewFormula: added a reference to an instance of formula.frm
'14Jul00 JN  NewFormula: added a reference to an instance of formula.frm
'17Jul00 JN  ParseFormulaData: Added - checks if d.dosesperissueunit = 0 and warns user. To avoid causing 'Overflow' error
'18Jul00 AJK AllocateNewBatchNumber : Called function strYearCharacter.
'            Added function strYearCharacter.
'21Jun00 TH/AW  TransactionRollBack: Change to cope with exvat costs on MB rollbacks
'24Aug00 JN  PrintWorkLabel: Checks Pharmacc is turned off before incrementing l.batchnumber
'02Feb99 CFY ParseFormulaData: Added new element ItemDescS which contains short descriptions that have been truncated to
'            40 characters.
'02Feb99 CFY StoreAndTotal: Now deals with information that has been passed in by the OCX.
'13Sep99 CFY callmanufacturing: Remembers current access levels before manufacturing was called. This is to prevent access levels being blanked
'            if user hits escape when prompted for password when in the PMR screen.
'29Sep99 CFY ParseFormulaData: If in OCX mode, now sets recovery time just before issue.
'13Sep00 JN  FillLayoutCombos: Added reference to instance
'13Sep00 JN  CopyOrPasteFormula: Added form instance reference
'14Jul00 JN  DeleteFormula: Added form reference
'14Jul00 JN  getnewformula: Added form reference
'14Jul00 JN  IssueAndPrintFormula: Added form reference
'14Jul00 JN  ParseFormulaData: Added form reference
'14Jul00 JN  PrintManWorkSheet: Added form reference
'14Jul00 JN  PrintWorkLabel: Added form reference
'23Oct00 TH  ParseFormulaData: clear previous cost elements (for 0 qty ingredient issues !)
'07Nov00 JN  CallManufacturing: Commented out 3 lines of code causing 2nd confirmation request when adding new formula
'07Nov00 JN  NewFormula: Added code to add New Formulas even in the formula the user
'            hasn't made any changes to the one they are editing
'20Nov00 SF  SF/CFY PrintWorkLabel: moved 24Aug00 logic into Dispens.frm: txtprompt_keyup
'31Oct00 TH  ParseFormulaData: Added Tradename for printable element of ingredient
'15Nov00 TH  ParseFormulaData: Added expirydateonly and expirytimeonly printable elements
'08Nov00 TH  IssueAndPrintFormula: Altered to stop division by zero  (Event 44586)
'15dec00 CKJ ParseFormulaData: Label section; hard coded expiry/batchno line removed as it should be in the layout
'             and it does not match the 'label' on the worksheet
'            AmendLayout: Added expiry & batchnumber in same format as was hard coded in ParseFormulaData
'             This can be altered or turned off via patmed.ini, CIVASconvertRTFexpiryline
'             where the default is "EXPIRY: [expirydate]  [batchnumber]"                        (#48601)
'22Jan01 TH  ParseFormulaData: Remove additional blank lines in label element of worksheet (#43639)
'16May01 JN/CKJ InitialiseHeapItems: Added code to initialise tradename heap item to prevent [tradename x] appearing on worksheets (#47711)
'17Jul01 CKJ Callmanufacturing: Removed 'frmCallManuf As Form' from parameter list - now declared within the procedure
'21Nov01 CKJ Callmanufacturing: Moved the Do/Loop further out to encompass form Load/Unload     (#47301)
'             This ensures the form is freshly created for each formula edited
'            Added DefInt A-Z as per standards. This revealed a type mismatch in AllocateNewBatchNumber
'            strYearCharacter: Added 'As String' to the function. This was returning a variant despite its name
'             Replaced the huge Case statement with compact function & improved the error message
'            AllocateNewBatchNumber: Changed '+' to '&' as this caused the Type Mismatch with strYearCharacter()
'             Changed use of Date$ to Now()
'24Jan02 TH  PrintManWorkSheet: Added a switch to stop wrksheet printing when user requests no wrksheet (#43808)
'24Jan02 TH  PromptBatchNumber: Added chr(160) in batchnumber as flag that no worksheet is required (#43808)
'22Feb02 TH  InitialiseHeapItems: Added code to initialise   [TotalPacksx] and [rTotalPacksx] (enh1372)
'22Feb02 TH  ParseFormulaData: Added Elements for ingredients  [TotalPacksx] and [rTotalPacksx] (enh1372)
'04Mar02 TH  PrintManWorkSheet: Added Parameter to Reprint call (#MOJ#)
'15Apr02 TH  PrintManWorkSheet: Added after testing to ensure is reset if no wrksheet required (#43808)
'21May02 SF  CallManufacturing: now doesn't allow editing of ingredients on a low level password (#58478)
'01Oct02 TH  DoIssue: Added 'big out' if no issue required
'01Oct02 TH  InitialiseHeapItems: Added code to initialise ingvol patient label elements
'01Oct02 TH  IssueAndPrintFormula: Check if expiry$ is already set to prevent over write of already entered expiry.
'01Oct02 TH                        Added new look ups to allow for manufacturing issue to patient from dispensing screen
'                                  (sets extemp here to include all necessary log entries - ings, balance and final issue)
'01Oct02 TH                        Added reset of m_blnLabelOnly after print & issue
'01Oct02 TH                        Added switch to new PrintlabelsfromDispens sub (this allows standard dispensing label printing)
'01Oct02 TH                        Dont set batchnumbers or totals if labels only are required
'01Oct02 TH                        Keep modular batch + expiry variables as they are still needed for the label prints
'01Oct02 TH  ParseFormulaData: Added check on findrdrug in loop (if drug$ is nsvcode then pushing through findrdrug again just fires duplicate warnings)
'01Oct02 TH                    Added 'hours' after Exphrs printable element
'01Oct02 TH                    Changed caption on manissue form to make clear if no issue will actually result
'01Oct02 TH  PrintLabelsFromDispens: Written
'01Oct02 TH  PrintManWorksheet: Added extra flag to denote no worksheet (m_blnLabelOnly)
'01Oct02 TH                     Added clauses to stop worksheet calcs on issue if no issue and no wrksheet print required
'01Oct02 TH  PromptBatchNumber: Added new section to allow for all manner of possibilities (basically to allow for a frigging reprint!) (#63313)
'01Oct02 TH  setFromDispens: Written
'01Oct02 TH  StoreandTotal: Replaced write of numdse to heap to reflect proper value
'01Oct02 TH                 Added ingvol printable element for CIVAS multiple patient wrksheets
'01Oct02 TH  UpdateDispensLabel: Written  - May require more stuff in here
'07Oct02 TH  InitialiseHeapItems: Added code to initialise [batchnumbersx] and [ExpiryDateOnlyx] elements
'07Oct02 TH  ParseFormulaData: Added a mod to read the heap for rxExpiry (entered directly by the user) - if this exists then use this for the
'                              Expiry, not he system calculated value (note this is not parsed (yet?), so dont use for date or time only settings !)
'07Oct02 TH  StoreandTotal: Added batchnumber and expriydateonly as wrksheet elements for storage (Clatterbridge) (#64008)
'15Oct02 TH  ParseFormulaData: Added hours suffix to ExpHrs element (missed from merge of 01Oct02)
'21Oct02 TH  PromptBatchNumber: Added new blnFromRxManagement parameter to suppress option to cancel or not print
'                               (in which case the pat details are posted to the caption of the batchnumer prompt input box)
'21Oct02 TH  PromptBatchNumber: Added setting to allow default to be set on new multi option screen
'21Oct02 TH  InitialiseHeapItems: Added code to initialise PatientDetails, cons and dob elements (where overhanging from previous multiple patien runs)
'13Nov02 CKJ Changed batchnumber$ to m_batchnumber$, and removed module level batchexpiry$
'            PrintWorkLabel: Added param o_blnFormulaHandled which is set True if IssueAndPrintFormula is called, and is false
'             if no suitable formula is found or if the old style rtf work label is used instead.
'07Feb03 TH  ParseFormulaData: Added stdLbl10A element to the heap. Not pretty - see note with mod for explanation
'14Feb03 TH/CKJ PrintWorkLabel: Removed dp! on Qty param of IssueAndPrintFormula as this means rounding further down is no longer
'                               workable (as the precision has already been reduced) and rounding errors are introduced.
'14Feb03 TH/CKJ ParseFormulaData: Added dp! to restore previous functionality
'17Feb03 TH  ParseFormulaData: Moved new stdLbl10A block lower and amended slightly to be able to use edited expiry
'17Feb03 TH                    Moved dp!mod to below ingredient processing to avoid rounding issues in any user windows (eg for variable doses)
'06Jun03 TH  ParseFormulaData: Added Mod to round ingredients if ini file is set AND ingredient set to issueinwholepacks (#68678)
'19Jun03 TH                    Various alterations to above after second check (#68678)
'09Mar04 CKJ IssueAndPrintFormula: added lblPackSize
'30Mar04 CKJ {SP1}
'            Removed obsolete proc copyorpasteformula
'17May04 TH  ParseFormulaData: Added code for new ProductNSV and Item4Qty elements (#74372)
'17May04 TH  InitialiseHeapItems: Added code to initialise ProductNSV and Item4Qty elements (#74372)
'17May04 TH  PrintManWorksheet: Add mod to ensure correct batch expiry details available on worksheet (#72672)
'24May04 TH  ParseFormulaData: Now use the dosing units of the product selected, NOT possibly the last one (if the item is selected here) (#71589)
'26Aug09 TH Ported from v8
'12Jan07 PJC ParseFormulaData: Added imput arguments workingdate$, workingtime$ and added them to print heap (enh77351).
'            PrintManWorksheet: Added imput arguments workingdate$, workingtime$ to the call to ParseFormulaData (enh77351).
'            IssueAndPrintFormula: Added arguments workingdate$, workingtime$ to the call to PrintManWorksheet (enh77351).
'            InitialiseHeapItems: Added code to initilaise preparationdate and preparationtime (enh77351)
'-------
'04Oct09 TH  PrintWorkLabel: Change message for new second checking functionality (F0065043)
'08Oct09 TH  GetNewFormula: Added (F0064968) different message if there is pre-existing approved formula
'02Mar10 TH  PrintManWorksheet: Stop worksheet print for label only run (selected from manufacturing issue screen) (F0079144)
'12Nov10 TH  ParseFormulaData: Allow stores only items as ingredients (where allowed pre RCNP0158, but stores only changes have made these unfindable)
'15Feb13 XN  ReturnCivasItem: Removed dead code (40210)
'20Mar13 TH  CIVASTransactionRollBack: Ensure that we dont even begin to return stuff with no batch number (TFS 36402)
'17Jun13 TH  Ensure container handling here only uses syringes !! (TFS 66598)
'19Jun13 TH  Handle uneven split where last split is actually a full syringe (TFS 66712)
'16Jul13 TH  ParseFormulaData: Put the actual issued qty on the heap (TFS 69172)
'24Jun13 TH  IssueAndPrintFormula: QA Yield - multiple mods to handle issuing of QA (TFS 48388)
'25Jul13 TH  IssueAndPrintFormula: Added pluralisation to QA issuing message (TFS 69591)
'25Jul13 TH  CIVASTransactionRollBack: (TFS 69663) Now we need to also exclude any Bond Store releases as these are not true returns
'                                      on the previous returns check(like MANU records)
'20Sep13 TH  IssueAndPrintFormula: Ensure Colchester Tax "accrue" is used also by issues into Bond Store (TFS 73794)
'07Oct13 TH  GetNewFormula: Allow Stores Only selection (pack downs) (TFS 75305)
'10Aug14 TH  CallManufacturing: Now allow print/preview of worksheet when contemplating authorising it (TFS 86640\126138 XN back port)
'18Aug15 XN  IssueAndPrintFormula: Changed setting batch number 64575
'                        CIVASTransactionRollBack: Enable proper rollback of manufactured items 64575
'15Sep15 TH  CIVASDoseIncStat: Custom frequencies also need a derived dose so these are added here (TFS 129498)
'14Sep15 TH  AmendLayout: For Level 9 Allow view of DRAFT not current. User needs to see proposed one to authorise ! (TFS 129439)
'14Sep15 TH  ParseFormulaData: We always get the latest draft method when in the draft or approval desktop (TFS 129553)
'14Sep15 TH  GetFormula: Get draft formula here if draft or authorise mode to use draft method or label on previews (TFS 129553)
'15Dec15 TH  ParseFormulaData: Changed dosesperissueunit to single to stop inappropriate rounding (TFS 136119)
'23Feb16 TH  SyringeContainers: FIx rounding on volume on last syringe (TFS 146402)
'16Mar15 TH  StoreandTotal: Reworked and added elements around volumes (TFS 148108)
'16Mar15 TH  InitialiseHeapItems : cleaned out and reset elements and new variables (TFS 148108)
'07Apr16 XN  DoIssue: Moved negative log to db 123082
'22May16 TH  ParseFormulaData: Unload the syringes form before use to ensure no values can be cached or re-used (TFS 153997)
'21Jun16 XN  resizeSyringeLabel: 154896 Added for Amm
'                        setSyrineLabelVolume: 154896 Added for Amm
'                        setSyrineLabelDose: 154896 Added for Amm
'02Aug16 XN  AllocateNewBatchNumber: If setting D|Patmed.ManufacturingBatchNumber.UseWeb is on will get the manufacturing batch number from the web (from PharmacyCounter table) 159413
'08Aug16 XN  AllocateNewBatchNumber: 159843 Fixed to getting web based batch number
'02Feb17 TH  AmendLayout: Fix for load of blank.rtf from DB when creating new layout. (TFS 175410)
'09Feb17 TH  SaveFormula: Ensure method replacement uses the DB RTF handling (Hosted) (TFS 176196)
'20Apr17 XN  ParseFormulaData: 182077 new fiels in manufacutire printing
'            InitialiseHeapItems: 182077 new fiels in manufacutire printing
'17Jul17 TH  ParseFormulaData: Added block to remove unwanted blank lines from [Label] element (port from v8.9) (TFS 189065)
'31Jan18 DR  Bug 203480 - Manufacturing blank rtf is looking for the wrong name


Option Explicit
DefInt A-Z

Type TIssueSummary
   'Desc As String * 50       '02Sep99 CFY Replaced
   desc As String * 65 '63        '         " '09Jun06 TH Extended
   Qty As Single
   Unit As String * 10
   'Error As String * 60      '13Feb98 CFY
   Error As String            '     "
   SisCode As String * 7
   barcode As String * 13
   IssType As String * 20
   IngType As String * 1      '24Feb98 CFY Added Ingredient Type.
   DBPosn As Integer
End Type

Global IssueSummary() As TIssueSummary

''Dim HFtable   As table        'Layout table (only one record)
Dim m_batchnumber$            '13Nov02 CKJ changed from batchnumber$
'Dim batchexpiry$             '13Nov02 CKJ removed as never used
'Dim FatalErr%                'Set if a fatal error occured during the issue check
                              'which should stop the issue proceeding.

Global GlobalManufBatchNum$   '23Sep96 CKJ PRAGMATIC SOLUTION - Needs improving !!**
Dim ManBlister As TManBlister '17Feb98 CFY Added

Dim ManuIssued!, ManuCost!    '30Jul98 EAC added for OCX mods
Dim TotalUnits!(15)
Dim totalQty!(15)
Dim TotalVol!
Dim TotalIngVol!          '16Jul13 TH  Added (TFS 68238)
Dim sngIngVolperdose As Single  '15Mar16 TH (TFS 148108)
Dim sngVolperdose As Single      '15Mar16 TH (TFS 148108)
Dim formulacopy$(15, 4)   '09Jan99 ASC

Dim FormulaViewMode%                      '28Jul99 AE added
Dim FormulaType%
Dim FormulaKey$                           'entry in field NSVcode in Formual.mdb relating to this record
Const MASTER_FORMULA = 1
Const PATIENT_FORMULA = 2
Const NEW_FORMULA = 3
Const NEW_PATIENTFORMULA = 4

Dim m_blnNoLabel As Integer      '01Oct02 TH (#63313)
Dim m_blnNoIssue As Integer
Dim m_blnLabelOnly As Integer
Dim m_blnFromDispens As Integer
Dim M_blnFromDispensing As Boolean '06Jun05 TH Added
Dim m_sgnCivasDose As Single '22May08 TH Ported
Dim m_blnArchiveView As Boolean '26Aug09 TH Added (F0054335)
Dim m_blnSecondAuthorisation As Boolean  '26Aug09 TH Added
Dim m_syringestoLabel As Integer       '03Dec12 TH Added
Dim m_SyringeLabelDose() As Single
Dim m_SyringeLabelVolume() As Single



''Global dbFormula As Database
''Global FormulaTable As table

'Sub copyorpasteformula (frmFormula As Form, action%)
''09Jan99 ASC holds a copy of a formula which can be used for editing to be a patient specific formula
''13Sep00 JN added reference to form instance
'
'Dim x%
'
'   For x = 0 To 14
'      Select Case action
'         Case 1 'copy
'            formulacopy$(x, 0) = frmFormula.TxtDescription(x).Text
'            formulacopy$(x, 1) = frmFormula.LblUnits(x).Caption
'            formulacopy$(x, 2) = frmFormula.TxtQty(x).Text
'            formulacopy$(x, 3) = frmFormula.TxtCode(x).Text
'            formulacopy$(x, 4) = frmFormula.CSCmbType(x).ListIndex
'         Case 2 'paste
'            frmFormula.TxtDescription(x).Text = formulacopy$(x, 0)
'            frmFormula.LblUnits(x).Caption = formulacopy$(x, 1)
'            frmFormula.TxtQty(x).Text = formulacopy$(x, 2)
'            frmFormula.TxtCode(x).Text = formulacopy$(x, 3)
'            frmFormula.CSCmbType(x).ListIndex = formulacopy$(x, 4)
'         Case Else: MsgBox "This action of copypasteformula is not permitted"
'      End Select
'   Next
'   Select Case action
'      Case 1
'         formulacopy$(15, 0) = frmFormula.CmbLayout(0).Text
'         formulacopy$(15, 1) = frmFormula.CmbLayout(1).Text
'      Case 2
'         frmFormula.CmbLayout(0).Text = formulacopy$(15, 0)
'         frmFormula.CmbLayout(1).Text = formulacopy$(15, 1)
'      End Select
'End Sub

Sub BlankFormulaForm(frmFormula As Form)
'14Jul00 JN Added reference to an instance of Formula.frm
Dim X%

   frmFormula.lblDescription.Caption = ""
   frmFormula.Caption = "Formula"
   For X = 0 To 14
      blankformulaline frmFormula, X
   Next

   '28Jul99 AE added because of removing binding to formuladata
   frmFormula.LblAuthorised.Caption = ""
   frmFormula.Lbl2ndAuth.Caption = ""
   'frmFormula.LblAuthorisedDate.Caption = ""
   frmFormula.LblTotQty = ""
   '26Aug09 TH Added
   frmFormula.LblStatusTag.Caption = ""
   frmFormula.lblStatus.Caption = ""
End Sub

Sub blankformulaline(frmFormula As Form, formulaline As Integer)
'21Feb00 SF now blanks NSV code column
'14Jul00 JN replaced references to formula. to frmFormula.
   frmFormula.TxtDescription(formulaline).text = ""
   frmFormula.lblUnits(formulaline).Caption = ""
   frmFormula.txtQty(formulaline).text = ""
   frmFormula.CSCmbType(formulaline).text = ""   '28Jul99 AE Added
   frmFormula.TxtCode(formulaline).text = ""     '21Feb00 SF added

End Sub

Sub callmanufacturing(d As DrugParameters, ViewMode%, ByVal blnFromDispensing As Boolean)
'16Oct96 KR Added "Manufacturing" parameter to call to AskPassword
'31Mar98 CFY Removed condition to allow getnewformula to always be called, regardless of whether
'            a drug has been loaded or not. Previously if callmanufacturing was called with a drug
'            loaded, ie. from the dispensary, the formula would not be displayed on screen as all
'            the code to populate the form is held in getnewformula.
'19Nov98 CFY Extra code added to initialise the new controls that have been added to the manufacturing
'            form
'28Jul99 AE  Added viewmodes. passed in by setting formula.tag to one of the following:
'
'            0 - view only mode (default). No changes allowed to any of the controls.
'            1
'            2 - Dispensary mode. Can make a new patient specific formula, but cannot add a new formula or edit the master formula
'            3-7 reserved for other dispensary modes
'            8 - reserved for limited access from manufacturing
'            9 - Manufacturing Mode. Full access.
'
'            These are set before other checks, eg for password levels are set.  Thus even if called with
'            veiw mode = 9, full access might still be denied if appropriate. ie, the view mode is the
'            *maximum* which will be allowed.
'
'            CmdCancel.Tag is used as the update flag - ie to indicate that the user has made changes
'            and thus to prompt them to save.

'?????99 AE  Added loop to prevent the user dropping out of manufacturing each time a product is
'            authorised, as this made it slow to edit a number of formulae.  Action in dispensing
'            mode is unchanged (ie, drops straight out after editing formula)

'14Jul00 JN  Changed routine to refer to a particular instance of formula.frm - hence extra parameter frmCallManuf
'   "     "  All instances of formula. have been replaced by frmCallManuf.
'20Jul00 JN  Restructured routine to avoid db locking problems (event 45136)
'22Aug00 JN  Did a little more restructuring (event 45136) to ensure invalid passwords don't
'   "     "  display formula form and to ensure that things happen in a more sensible order.
'07Nov00 JN  Commented out 3 lines of code causing 2nd confirmation request when adding new formula
'17Jul01 CKJ Removed 'frmCallManuf As Form' from parameter list - now declared within the procedure
'21Nov01 CKJ Moved the Do/Loop further out to encompass form Load/Unload
'            This ensures the form is freshly created for each formula edited
'21May02 SF  now doesn't allow editing of certain items on a low level password (#58478)
'10Aug14 TH  Now allow print/preview of worksheet when contemplating authorising it (TFS 86640)


Dim validpass%, i%, found%
''Dim TmpAccLevels$
Dim frmCallManuf As Formula                                                                '17Jul01 CKJ added
Dim strResult As String
Dim rsLayout As ADODB.Recordset
Dim strParams As String
Dim strName As String
Dim intVersionNumber As Integer
Dim intPosn As Integer

   k.escd = False
''   TmpAccLevels$ = acclevels$                                                                '13Sep99 CFY Added
''''   askpassword validpass, "", "Manufacturing"
''   If Trim$(acclevels$) = "" And Trim$(TmpAccLevels$) <> "" Then acclevels$ = TmpAccLevels$  '13Sep99 CFY Added
''   If validpass Then

   If GetSecondAuthorisation() And (getaccesslevel() = 9 Or getaccesslevel() = 0) And (Not M_blnFromDispensing) Then
      
      frmoptionset -1, "Manufacturing"
      
      If getaccesslevel() = 9 Then
      frmoptionset 1, "Select Formula"
      frmoptionset 1, "View draft formulae"
      frmoptionset 1, "View / Approve draft layout"
      Else
      frmoptionset 1, "Select archived Formula"
      frmoptionset 1, "View archived layout"
      End If
      frmoptionshow "1", strResult
      frmoptionset 0, ""
      If strResult = "2" Then
         If getaccesslevel() = 9 Then
         'Here we will just show a list of draft formulas, then bug out
         WFormulaDraftView
         Else
            'Show list of arcivelayouts
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
            Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteArchive", strParams)
            If rsLayout.RecordCount > 0 Then
               'Display select and steer the rs
               Unload LstBoxFrm
               LstBoxFrm.LstBox.Clear
               LstBoxFrm.Caption = "Select Archived Layout"
               LstBoxFrm.lblHead = "Version" & TB & "Name"
               Do While Not rsLayout.EOF
                  LstBoxFrm.LstBox.AddItem RtrimGetField(rsLayout!VersionNumber) & TB & RtrimGetField(rsLayout!name)
                  rsLayout.MoveNext
               Loop
               LstBoxShow
               If Len(LstBoxFrm.Tag) > 0 Then
                  intPosn = InStr(LstBoxFrm.Tag, TB)
                  If intPosn Then
                     intVersionNumber = Val(Left$(LstBoxFrm.Tag, intPosn - 1))
                     strName = Trim$(Mid$(LstBoxFrm.Tag, intPosn + 1))
                  End If
               Else
                  k.escd = True
               End If
               Unload LstBoxFrm
            Else
               popmessagecr "!Manufacturing", "There are currently no archived layouts"
               k.escd = True
            End If
            
            If Not k.escd Then
               'Show the option as to what to view, or just approve the thing. Loop until approved or cancelled
               ViewArchiveLayout strName, intVersionNumber
               k.escd = True
            End If
         End If
         k.escd = True
      ElseIf strResult = "3" Then
         'Show list of layouts
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
         Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteDraft", strParams)
         If rsLayout.RecordCount > 0 Then
            'Display select and steer the rs
            Unload LstBoxFrm
            LstBoxFrm.LstBox.Clear
            LstBoxFrm.Caption = "Select Draft Layout"
            LstBoxFrm.lblHead = "Name"
            Do While Not rsLayout.EOF
               LstBoxFrm.LstBox.AddItem RtrimGetField(rsLayout!name)
               rsLayout.MoveNext
            Loop
            LstBoxShow
            If Len(LstBoxFrm.Tag) > 0 Then
               strName = LstBoxFrm.Tag
            Else
               k.escd = True
            End If
            Unload LstBoxFrm
         Else
            popmessagecr "!Manufacturing", "There are currently no draft layouts"
            k.escd = True
         End If
         
         If Not k.escd Then
            'Show the option as to what to view, or just approve the thing. Loop until approved or cancelled
            ViewandApproveLayout strName
            k.escd = True
         End If
      End If
   End If
   
   If Not k.escd Then
   Do '21Nov01 CKJ Moved the Do up here to ensure form is freshly created for each formula edited
      '20Jul00 JN Load the form into memory and initialise DLLs then centre it on screen
      
      
      Set frmCallManuf = New Formula                                                      '17Jul01 CKJ added
      
      Load frmCallManuf
      frmCallManuf.Left = Int((Screen.Width - frmCallManuf.Width) / 2)
      frmCallManuf.Top = Int((Screen.Height - frmCallManuf.Height) / 2)
      
      FormulaViewMode = ViewMode             '28Jul99 AE
      FormulaType = 0                        '     "
      'Do '20Jul00 JN Moved the Do up here to refresh the Caption '21Nov01 CKJ Moved line above to ensure form is freshly created
      frmCallManuf.Caption = "Formula" 'Just to force form and DLL's to load  '14Jul00 JN changed to refer to instance formula.frm
      'Do                                    '20Jul00 JN moved Do above .caption change otherwise SetFormulaView make caption grow and grow
      Do
         getnewformula frmCallManuf, d, found, blnFromDispensing
      Loop Until found Or k.escd
      If Not k.escd Then
         If blnFromDispensing Then '06Jun05 TH set high level on new F type dispensary launch
            M_blnFromDispensing = True
            acclevels$ = "9"
         End If
         SetFormulaView frmCallManuf, FormulaViewMode             '28Jul99 AE Added  '14Jul00 JN amended
         Select Case Val(Mid$(acclevels$, 1, 1))                  '19Jul00 JN Amended
         '08Jun06 TH Reinstated
            Case 1 To 7                                           '19Jul00 JN Amended
               frmCallManuf.CmdAuthorise.Visible = False
               frmCallManuf.CmdNew.Visible = False
               frmCallManuf.cmdDelete.Visible = False
               frmCallManuf.MnuOptS.Visible = False               '08Sep99 CFY Added
               frmCallManuf.cmdReturn.Visible = False     '06Jun08 TH Added
               For i% = 0 To 1                                    '19Nov98 CFY added
                  frmCallManuf.CmdEdit(i).Enabled = False              '        "
                  frmCallManuf.CmbLayout(i).Enabled = False            '        "
                  frmCallManuf.TxtPatsPerSheet(i).Enabled = False      '        "
               Next
            'Case 8 To 9                                           '19Jul00 JN Amended
            Case 8                                       '10Aug14 TH Now allow print/preview of worksheet when contemplating authorising it (TFS 86640)
            Case 9                                       '        "
               frmCallManuf.mnuPrint(0).Enabled = True   '        "
               frmCallManuf.mnuPrint(1).Enabled = True   '        "
            Case Else
               If m_blnArchiveView Then
                  '26Aug09 TH Added
                  frmCallManuf.CmdAuthorise.Visible = False
                  frmCallManuf.CmdNew.Visible = False
                  frmCallManuf.cmdDelete.Visible = False
                  frmCallManuf.MnuOptS.Visible = False               '08Sep99 CFY Added
                  frmCallManuf.cmdReturn.Visible = False     '06Jun08 TH Added
                  frmCallManuf.CmdCompound.Visible = False
                  For i% = 0 To 1                                    '19Nov98 CFY added
                     frmCallManuf.CmdEdit(i).Enabled = False              '        "
                     frmCallManuf.CmbLayout(i).Enabled = False            '        "
                     frmCallManuf.TxtPatsPerSheet(i).Enabled = False      '        "
                  Next
               Else
                  popmessagecr "!n!i", "No access allowed to this module"  '22Aug00 JN added exclamation
                  validpass = 0
                  k.escd = True '22Aug00 JN Added - quick drop-out from module
               End If
         End Select
         '14Jul00 JN changed any reference to formula. to frmCallManuf. in order to refer to an instance of formula.frm
         'If validpass And Not k.escd Then   '22Aug00 JN Added to prevent access to module if validpass = 0
         If Not k.escd Then   'SQL replaces above
            '07Nov00 JN Commented out following 3 lines as users were being asked 'OK to Add New Formula?' twice! AAAARGH!
            'Do                                        '22Aug00 JN Moved from above to prevent req. for product code if not valid pwd
               'getnewformula frmCallManuf, d, found   '22Aug00 JN   "     "     "
            'Loop Until found Or k.escd                '22Aug00 JN   "     "     "
            If Not k.escd Then                        '22Aug00 JN
               If FormulaType = PATIENT_FORMULA Or M_blnFromDispensing Then
               ''If FormulaType = PATIENT_FORMULA Then
                  frmCallManuf.CmdCompound.Visible = False   '09Jan99 ASC
                  frmCallManuf.CmdNew.Visible = False                     '        "
                  frmCallManuf.cmdDelete.Visible = False                  '        "
                  If Not blnFromDispensing Then
                     For i% = 0 To 1                                    '        "
                        frmCallManuf.CmdEdit(i).Enabled = False              '        "
                        frmCallManuf.CmbLayout(i).Enabled = False            '        "
                        frmCallManuf.TxtPatsPerSheet(i).Enabled = False      '        "
                     Next
                  'Else
                  '   frmCallManuf.CmdAuthorise.Enabled = True
                  
                  End If
                  For i = 0 To 14
                     frmCallManuf.CSCmbType(i).Visible = False
                  Next '      "
                  frmCallManuf.ChkBlisterPack.Visible = False
                  frmCallManuf.MnuNew.Enabled = False
                  frmCallManuf.MnuDelete.Enabled = False
                  frmCallManuf.mnuPrint(0).Enabled = False
                  If blnFromDispensing Then
                     frmCallManuf.CmdCompound.Visible = True
                     frmCallManuf.CmdCompound.Enabled = True
                  End If
                  frmCallManuf.mnuFormat.Enabled = False
                  frmCallManuf.Frame2.Visible = True                    '22Jun05 TH Set to true
                  frmCallManuf.MnuOptS.Enabled = False                  '22Jun05 TH
                  frmCallManuf.CmdEdit(1).Enabled = False               '        "
                  frmCallManuf.CmbLayout(1).Enabled = False             '        "
                  frmCallManuf.TxtPatsPerSheet(1).text = ""
                  frmCallManuf.TxtPatsPerSheet(1).Enabled = False
               End If
            
               frmCallManuf.cmdCancel.Tag = ""        'Used as the flag to indicate changes have been made
               
                                      
               '21May02 SF now doesn't allow editing of certain items on a low level password (#58478)
               ' ingredient list
               For i = 0 To 14
                  If GetSecondAuthorisation() And (Not blnFromDispensing) Then
                     Select Case Val(Mid$(acclevels$, 1, 1))
                     Case 1 To 7, 9:  '26Aug09 TH Dont allow 9 to tinker
                        ' low level, don't allow editing
                        frmCallManuf.TxtCode(i).Enabled = False
                        frmCallManuf.TxtDescription(i).Enabled = False
                        frmCallManuf.txtQty(i).Enabled = False
                        frmCallManuf.lblUnits(i).Enabled = False
                        frmCallManuf.CSCmbType(i).Enabled = False
                     Case 8:
                        ' high level, allow editing
                        frmCallManuf.TxtCode(i).Enabled = True
                        frmCallManuf.TxtDescription(i).Enabled = True
                        frmCallManuf.txtQty(i).Enabled = True
                        frmCallManuf.lblUnits(i).Enabled = True
                        frmCallManuf.CSCmbType(i).Enabled = True
                     End Select
                     If Val(Mid$(acclevels$, 1, 1)) = 7 Then    '26Aug09 TH Added to allow level 7 to delete approve formulas
                        frmCallManuf.cmdDelete.Enabled = True   '           They can now return also
                        frmCallManuf.cmdDelete.Visible = True
                        frmCallManuf.cmdReturn.Enabled = True
                        frmCallManuf.cmdReturn.Visible = True
                     End If
                  Else
                     Select Case Val(Mid$(acclevels$, 1, 1))
                        Case 1 To 7:
                           ' low level, don't allow editing
                           frmCallManuf.TxtCode(i).Enabled = False
                           frmCallManuf.TxtDescription(i).Enabled = False
                           frmCallManuf.txtQty(i).Enabled = False
                           frmCallManuf.lblUnits(i).Enabled = False
                           frmCallManuf.CSCmbType(i).Enabled = False
                        Case 8 To 9:
                           ' high level, allow editing
                           frmCallManuf.TxtCode(i).Enabled = True
                           frmCallManuf.TxtDescription(i).Enabled = True
                           frmCallManuf.txtQty(i).Enabled = True
                           frmCallManuf.lblUnits(i).Enabled = True
                           frmCallManuf.CSCmbType(i).Enabled = True
                           frmCallManuf.txtQAQty.Enabled = False '24Jun13 TH
                           frmCallManuf.chkBond.Enabled = False  '26Jun13 TH
                     End Select
                  End If
               Next

               ' other items
               If GetSecondAuthorisation() And (Not blnFromDispensing) Then
                  Select Case Val(Mid$(acclevels$, 1, 1))
                     Case 1 To 7, 9: '26Aug09 TH Dont allow 9 to tinker
                        ' low level, don't allow editing
                        frmCallManuf.Text2.Enabled = False
                        frmCallManuf.Text3.Enabled = False
                        frmCallManuf.ChkDosingUNits.Enabled = False
                        frmCallManuf.ChkBlisterPack.Enabled = False
                        frmCallManuf.txtQAQty.Enabled = False '24Jun13 TH
                        frmCallManuf.chkBond.Enabled = False '26Jun13 TH
                     
                     Case 8:
                        ' high level, allow editing
                        frmCallManuf.Text2.Enabled = True
                        frmCallManuf.Text3.Enabled = True
                        frmCallManuf.ChkDosingUNits.Enabled = True
                        frmCallManuf.ChkBlisterPack.Enabled = True
                        frmCallManuf.txtQAQty.Enabled = True '24Jun13 TH
                        frmCallManuf.chkBond.Enabled = True '26Jun13 TH
                        
                  End Select

               Else
                  Select Case Val(Mid$(acclevels$, 1, 1))
                     Case 1 To 7:
                        ' low level, don't allow editing
                        frmCallManuf.Text2.Enabled = False
                        frmCallManuf.Text3.Enabled = False
                        frmCallManuf.ChkDosingUNits.Enabled = False
                        frmCallManuf.ChkBlisterPack.Enabled = False
                        frmCallManuf.txtQAQty.Enabled = False '24Jun13 TH
                        frmCallManuf.chkBond.Enabled = False '26Jun13 TH
                     Case 8 To 9:
                        ' high level, allow editing
                        frmCallManuf.Text2.Enabled = True
                        frmCallManuf.Text3.Enabled = True
                        frmCallManuf.ChkDosingUNits.Enabled = True
                        frmCallManuf.ChkBlisterPack.Enabled = True
                        frmCallManuf.txtQAQty.Enabled = True '24Jun13 TH
                        frmCallManuf.chkBond.Enabled = True '26Jun13 TH
   
                  End Select
               End If
               '21May02 SF -----
               '26Aug09 TH Determine whether we are dealing with Draft/Archive or Approved and colour/label form accordingly
                        
               frmCallManuf.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
               M_blnFromDispensing = False
               If FormulaViewMode > 7 Then             '?????99 AE Added to prevent dropping out after each formula is edited
                  BlankWProduct d                   'but only if in manufacturing (viewmode 8,9)!!
               Else                                 '    "
                  k.escd = True                     '    "
               End If                               '    "
            End If
         End If
      End If
      Unload frmCallManuf  '14Jul00 changed to instance of formula.frm                                      '21Nov01 CKJ Moved inside Do/Loop
      Set frmCallManuf = Nothing                                                        '17Jul01 CKJ added
   Loop Until k.escd
   End If
   '''SQL Removed k.escd = False
   
         'Unload frmCallManuf  '14Jul00 changed to instance of formula.frm                                        '21Nov01 CKJ Moved inside Do/Loop
         'Set frmCallManuf = Nothing                                                          '17Jul01 CKJ added
''      End If
Cleanup:
On Error Resume Next
Unload frmCallManuf
Set frmCallManuf = Nothing
On Error GoTo 0
End Sub

Sub CancelFormula(frmName As Form)
'04May00 JP added 2nd authorisation check if formula has been changed
'14Jul00 JN moved from event-based to module-based code

Dim ans$
Dim CIVAS2ndAuth%, OKToAuthorise%, validpass%         '04May00 JP added
Dim TmpID$, TmpFullName$, TmpAccLevel$                '04May00 JP added

   k.escd = False
   If frmName.cmdCancel.Tag = "C" Then

   '04May00 JP added 2nd authoristaion check. Took code from cmdCancel_Click from here...
   OKToAuthorise% = True
   CIVAS2ndAuth% = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVAS2ndAuth", 0))
         
   If CIVAS2ndAuth% Then
      TmpID$ = UserID$
      TmpFullName$ = UserFullName$
      TmpAccLevel$ = acclevels$
''               askpassword validpass%, "", "Second Authorisor"
      If validpass% Then
         'Check password level is sufficient
         If Mid$(acclevels$, 1, 1) <> "9" Then
            popmessagecr "!", "Insufficient password level"
            OKToAuthorise% = False
         End If
         'Check if this is another user doing the authorisation
         If OKToAuthorise And (TmpID$ = UserID$) Then
            popmessagecr "!", "Second authorisation must be carried out by another user"
            OKToAuthorise% = False
         End If
         'Everything OK so authorise
         If OKToAuthorise% Then
         '     SecondAuthID$ = UserID$          '28Jul99 AE should be safe, since this is immediately
            frmName.Lbl2ndAuth.Caption = UserID$      'copied to lbl2ndauth in formuladata_validate
            
            UserID$ = TmpID$
            UserFullName$ = TmpFullName$
            acclevels$ = TmpAccLevel$
               frmName.cmdCancel.Tag = "C"
'                     FormulaData.Recordset.Update
            SaveFormula frmName                 '14Jul00 JN added reference to form instance
         End If
      End If
      UserID$ = TmpID$
      UserFullName$ = TmpFullName$
      acclevels$ = TmpAccLevel$
   Else
'04May00 JP to here
      Confirm "Saving", "authorise changes to formula", ans$, k
      If ans$ = "Y" And Not k.escd Then
         SaveFormula frmName                       '14Jul00 JN added reference to form instance
      End If
   End If
End If
   
   If Not k.escd Then
         frmName.Hide
      End If

End Sub

Sub DeleteFormula(frmDelete As Form)

'28Jul99 AE written to replace function CmdDelete_Click in Formula.frm
'14Jul00 JN Added form reference

Dim r$, Deleting%, ans$, yn% ', SQL$
Dim d As DrugParameters
Dim strParams As String
Dim lngOK As Long

   Deleting = False

   'If FormulaViewMode >= 8 Then      'should not be needed, since delete button should not otherwise be visible
   If FormulaViewMode >= 8 Or (GetSecondAuthorisation() And (Not M_blnFromDispensing) And (getaccesslevel() = 7)) Then  '26Aug09 Th Addd clause
      Select Case FormulaType
         Case NEW_FORMULA, NEW_PATIENTFORMULA
               r$ = "There is not yet a database record for this formula." & cr$
               r$ = r$ & "No changes made."
               popmessagecr "!Manufacturing", r$

         Case PATIENT_FORMULA
               Confirm "Manufacturing", "delete this patient-specific formula ?", ans$, k
               If ans = "Y" And Not k.escd Then Deleting = True

         Case MASTER_FORMULA
               If GetSecondAuthorisation() And Not (M_blnFromDispensing) Then '26Aug09 TH Added Section
                  If getaccesslevel() = 7 Then
                     r$ = " Warning ! You are about to delete an approved formula." & crlf
                     r$ = r$ & "Please ensure that there are no outstanding prescriptions of " & crlf
                     r$ = r$ & "this formula before proceding." & crlf & crlf
                     r$ = r$ & "Really delete formula ?"
                     yn = MessageBox(r$, MB_YESNO + MB_ICONEXCLAMATION + 256, "Manufacturing")
                  ElseIf getaccesslevel() = 8 Then
                     yn = IDYES
                  Else
                     yn = 0
                  End If
              Else
                  r$ = " Warning ! You are about to delete a master product record." & crlf
                  r$ = r$ & "Please ensure that there are no outstanding prescriptions of " & crlf
                  r$ = r$ & "this formula before proceding." & crlf & crlf
                  'r$ = "Warning!  About to delete a master product record.  Please ensure" & cr$
                  'r$ = r$ & "that there are no outstanding prescriptions of this formula before" & cr$
                  'r$ = r$ & "proceding." & cr$ & cr$
                  r$ = r$ & "Really delete formula ?"
                  yn = MessageBox(r$, MB_YESNO + MB_ICONEXCLAMATION + 256, "Manufacturing")
               End If
               
               If yn = IDYES Then Deleting = True
      End Select


      If Deleting And Not k.escd Then
         '09Jun06 TH Removed all stuff below - changed params
         'SQL$ = FormulaKey$          'replace "Select" with "Delete"
         'SQL$ = Mid$(SQL$, 7)
         'SQL Removed SQL$ = "DELETE" & SQL$
         'SQL This will be the NSVCode I reckon
         ''Set db = OpenDatabase(dispdata$ & "\Formula.mdb")
         ''db.Execute (SQL$)
         
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaKey$)
         If GetSecondAuthorisation() And Not (M_blnFromDispensing) Then
            If getaccesslevel() = 7 Then
               lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaArchiveApproved", strParams)
            ElseIf getaccesslevel() = 8 Then
               lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaDeletebySiteandNSVCodeDraft", strParams)
            End If
         Else
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaDeletebySiteandNSVCode", strParams)
         End If
         BlankWProduct d
         frmDelete.Hide
      End If

   End If



End Sub

Sub DoChkIssue(Qty!, d As DrugParameters, IssType$, Errors$)
'21Nov97 CFY Added. Used to carry out checks on a drug before doing the issue.
'                   Code extracted from SubPatMe.Issue
'13Feb98 CFY Completely re-arranged logic so that handling of errors is prioratised
'            according to severity.


Dim found%

   getdrug d, 0, 0, False
   Errors$ = ""
   
   'Check Drug on file
   'If Left$(d.Description, 3) = "***" Then  XN 4Jun15 98073 New local stores description
   If Left$(d.LabelDescription, 3) = "***" Then
      popmessagecr "!", "Issue Aborted. Drug not on file."
      k.escd = True
      Exit Sub                         '<--- WAY OUT
   End If
   
   'Check Drug is in use
   If d.inuse = "N" Then
      popmessagecr "!", "Drug no longer in use. Check before issuing."
      k.escd = True
      Exit Sub                         '<--- WAY OUT
   End If
   
   'Check Quantities
   If Qty! > 999999 Then
      popmessagecr "!", "Issue Aborted. Issue Quantity Exceeds max allowed"
      k.escd = True
      Exit Sub                         '<--- WAY OUT
   End If
 
   'Check Stock Levels
   If d.livestockctrl = "Y" And IssType$ <> "W" Then
      If Val(d.stocklvl) - Qty! < 0 And Qty! > 0 Then
         If UCase$(TxtD(dispdata & "\patmed.ini", "", "N", "NoNegIssues", found)) = "Y" Then
            ManIssue.CmdOk.Enabled = False
         End If
         Errors$ = "Issue will reduce stock levels below zero."
         Exit Sub                   '<--- WAY OUT
      End If
   End If
   
   If Qty! > Val(d.maxissue) Then
      Errors$ = "Quantity above maximum"
   End If
   If Qty! < Val(d.minissue) And Qty! > 0 Then
      Errors$ = Errors$ & "Quantity below minimum"
   End If
   
   
End Sub

Sub DoIssue(Qty!, d As DrugParameters, UserID$, patid$, dircode$, done%, trantype$, ward$, cons$, sitepaths%, IssType$, issueunitcost$, batchnumber$, expiry$, extemp%)
'21Nov97 CFY Partially extracted and fiddled from Subpatmed.Issue
'13Feb98 CFY Added check for zero qty to stop div/0 error occuring in translog.
'18Jun98 CFY Extra condition to stop issue occuring when in preview mode.
'03Aug99 AE  Added lines to make manufactured items balance in translog. Previously, the
'            final price of the manufactured item was made of the total costs of each ingedient,
'            excluding vat, multipled by the packsize and thus never balanced.  Now is
'            made of the cost of the amount of each ingredient used including vat.
'07Sep99 CFY Extemp% added to parameter list as do not need to divide by packsize when doing batch manufacturing
'22Jun00 TH/AW Added code to calculate costexvat price of manufactured items.
'01Oct02 TH  Added 'big out' if no issue required
'30Mar04 CKJ Removed superfluous param k As kbdcontrol
'07Apr16 XN  Moved negative log to db 123082

Dim negorpos%, auto%, lngDrugPtr As Long
Dim vatrate!

   If m_blnNoIssue Then Exit Sub    '01Oct02 TH Added

   If Qty! <> 0 And ward$ <> "¬" Then     '18Jun98 CFY Added
      getdrug d, 0, lngDrugPtr, False  '28Jan97 CFY Added
      
      If Qty! < 0 Then
         negorpos = -1
      Else
         negorpos = 1
      End If
   
      If d.livestockctrl = "Y" And IssType$ <> "W" Then
         If Val(d.stocklvl) - Qty! < 0 And Qty! > 0 And negorpos = 1 Then
            'Stock levels fell below zero
            'WriteLog dispdata$ & "\negative.log", 0, UserID$, d.Description + d.SisCode + Left$(Str$(Qty!) + "     ", 5) + d.stocklvl   XN 4Jun15 98073 New local stores description
                        'WriteLog dispdata$ & "\negative.log", 0, UserID$, d.LabelDescription + d.SisCode + Left$(Str$(Qty!) + "     ", 5) + d.stocklvl  07Apr16 XN  Moved negative log to db 123082
                        WriteLogSQL "negative", "Negative Stock Warning" + vbNewLine + "Issued: " + Str$(Qty!) + " Stock Lvl Was: " + d.stocklvl, 0, 0, d.SisCode
         End If
      End If
      
      Qty! = dp!(Qty! * negorpos)
      If Not negorpos Then
         TakeStockFromBatch d.SisCode, (Qty!), batchnumber$, expiry$, auto, False 'Check this TH Dec06
      End If
      
      gTlogPrescriberID$ = gPrescriberID$
      If batchnumber$ > "" And InStr(batchnumber$, "_") = 0 Then
         setbatchnum batchnumber$
      Else
         setbatchnum GlobalManufBatchNum$
      End If
      Translog d, lngDrugPtr, UserID$, patid$, Qty!, dircode$, ward$, cons$, trantype$, sitepaths%, IssType$, issueunitcost$
      If TransLogVAT% Then vatrate! = VAT(Val(d.vatrate)) Else vatrate! = 1
      If extemp Then
         issueunitcost$ = Format$(dp!(Val(issueunitcost$) / Val(d.convfact) * vatrate) * Qty!) & "|" & Format$(dp!(Val(issueunitcost$) / Val(d.convfact)) * Qty!)  '18Jun00 TH
      End If
      gTlogPrescriberID$ = ""
      done% = True
   End If
            
End Sub

Sub FillLayoutCombos(frmFormula As Form)
'19Nov98 CFY written
'Fills the Combo boxes on the manufacturing screen with a list of available layouts.
'13Sep00 JN Added instance of Formula form

''Dim db As Database
''Dim Layout As table
Dim strParams As String
Dim rsLayout As ADODB.Recordset


   On Error GoTo FillLayoutCombos_Exit
   frmFormula.CmbLayout(0).Clear
   frmFormula.CmbLayout(1).Clear
''   Set db = OpenDatabase(dispdata$ & "\formula.mdb")
''   Set Layout = db.OpenTable("Layout")
   strParams = gTransport.CreateInputParameterXML("Location_SiteID", trnDataTypeint, 4, gDispSite)
   If GetSecondAuthorisation() Then
      Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteApproved", strParams)
   Else
      Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySite", strParams)
   End If
   ''Layout.MoveFirst
   If Not rsLayout Is Nothing Then     'use returned recordset
      If rsLayout.State = adStateOpen Then
         If rsLayout.RecordCount <> 0 Then
            Do While Not rsLayout.EOF
               On Error Resume Next
               frmFormula.CmbLayout(0).AddItem RtrimGetField(rsLayout!name)     '13Sep00 JN changed to refer to instance of form
               frmFormula.CmbLayout(1).AddItem RtrimGetField(rsLayout!name)     '13Sep00 JN    "     "   "    "     "     "   "
               rsLayout.MoveNext
                
               On Error GoTo 0
            Loop
         End If
      End If
   End If
   

FillLayoutCombos_Exit:
   On Error GoTo 0
   On Error Resume Next
   ''rsLayout.Close
   Set rsLayout = Nothing
''   db.Close
''   Set db = Nothing
   On Error GoTo 0

End Sub

''Function GetBatchPointer(bpfile$)
'''05Jun00 JN - wrapper for GetPointer used by translog in writing CIVAS data
''Dim buildchan%, gotpointer&
''   'if the file referred to doesn't exist, create it first
''   If fileexists(dispdata$ & "\" & bpfile$) = False Then
''      'make the file
''      openrandomfile dispdata$ & "\" & bpfile$, 0, buildchan
''      Close buildchan
''      End If
''
''   'now get the pointer and add one to it for the next time
''   GetPointer dispdata$ & "\" & bpfile$, gotpointer&, -1
''   GetBatchPointer = gotpointer&
''End Function

Sub AmendLayout(frmFormula As Form, Index As Integer)
'19Nov98 CFY modified to handle multiple layouts.
'24Feb99 SF  if amending a manufacturing ff label then restrict to 9 lines to allow expiry/batch# to fit on
'03Sep99 AE  Block added to convert plain text labels into rtf
'14Jul00 JN  Added parameter to refer to an instance of formula.frm : possible event-based recursion problems
'15Dec00 CKJ Added expiry & batchnumber in same format as was hard coded in ParseFormulaData
'            This can be altered or turned off via patmed.ini, CIVASconvertRTFexpiryline
'            where the default is "EXPIRY: [expirydate]  [batchnumber]"
'14Sep15 TH  For Level 9 Allow view of DRAFT not current. User needs to see proposed one to authorise ! (TFS 129439)
'02Feb17 TH  Fix for load of blank.rtf from DB when creating new layout. (TFS 175410)
'31Jan18 DR  Bug 203480 - Manufacturing blank rtf is looking for the wrong name

''Dim MyTable As table,
Dim body$, edittype$, tablename$, errored%, success%, ans$
Dim filename$, NewName$
Dim IndexModifier%      '19Nov98 CFY
Dim AllowEdits%, RTFLabel%, r$, button%, fil$                '03Sep99 AE Added
''Dim TextEdit%
Dim tmp$                                                     '15Dec00 CKJ/EAC
Dim rsTable As ADODB.Recordset
Dim strParams As String
Dim blnLayoutFound As Boolean
Dim lngWLayoutID As Long
Dim lngTableID As Long
Dim lngOK As Long
Dim lngPatientsPerSheet As Long
Dim strLayout As String
Dim strLineText As String
Dim strIngLineText As String
Dim strPrescription As String
Dim strName As String
Dim strLabel As String
Dim strMethod As String
Dim blnLayoutExists As Boolean
Dim strStatus As String '26Aug09 TH Added
Dim strExtra As String
Dim strDraftFileName As String
Dim strDraftLineText As String
Dim strDraftIngLineText  As String
Dim strDraftPrescription As String
Dim strDraftName As String
Dim lngLayoutVersion As Long
Dim dteNow As Date
Dim dteApp As Date
Dim strTempFileName As String
Dim blnNewDraftLayout As Boolean '10Oct09 TH
Dim strRTFTextCopy As String     '14Dec16 TH Added
Dim strRTFText As String         '  "
Dim strFilename As String        '02Feb17 TH Added
'Dim lngOk As Long

   blnNewDraftLayout = False
   Select Case Index
      Case 0, 1
        edittype$ = "linetext"
        tablename$ = "Layout"
        IndexModifier = 0
      Case 2, 3
        edittype$ = "Inglinetext"
        tablename$ = "Layout"
        IndexModifier = 2
      Case 4
        edittype$ = "Label"
        tablename$ = "formula"
      Case 5
        edittype$ = "Method"
        tablename$ = "formula"
      Case 6, 7                           '19Nov98 CFY
        edittype$ = "Layout"              '    "
        tablename$ = "Layout"             '    "
        IndexModifier = 6
   End Select

   If Index < 4 Or Index > 5 Then      '     "
      lngLayoutVersion = 1 '09Oct09 TH Added
      strExtra = "" '26Aug09 TH Added '25Feb10 TH Reinstated
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, Trim$(frmFormula!CmbLayout(Index - IndexModifier).text))
      If GetSecondAuthorisation() And tablename$ = "Layout" And getaccesslevel() = 8 Then strExtra = "DraftandLive"               '21Oct09 TH Reinstated
       Set rsTable = gTransport.ExecuteSelectSP(g_SessionID, "pW" & tablename$ & "bySiteandName" & strExtra, strParams)     '     "
      'Set rsTable = gTransport.ExecuteSelectSP(g_SessionID, "pW" & tablename$ & "bySiteandName", strParams)
      blnNewDraftLayout = True
      If Not rsTable Is Nothing Then     'use returned recordset
         If rsTable.State = adStateOpen Then
            If rsTable.RecordCount <> 0 Then
               blnLayoutFound = True
               
               If GetSecondAuthorisation() And getaccesslevel() = 8 Then
                  blnLayoutFound = False
                  strDraftFileName = RtrimGetField(rsTable!Layout)
                  strDraftName = RtrimGetField(rsTable!name)
                  strDraftPrescription = RtrimGetField(rsTable!Prescription)
                  strDraftLineText = RtrimGetField(rsTable!LineText)
                  strDraftIngLineText = RtrimGetField(rsTable!IngLineText)
                  
                  Do While Not rsTable.EOF
                     If RtrimGetField(rsTable!Code) = "D" Then
                        If Not blnLayoutFound Then '14Oct09 TH
                           blnLayoutFound = True
                           strDraftLineText = RtrimGetField(rsTable!LineText)
                           strDraftIngLineText = RtrimGetField(rsTable!IngLineText)
                           lngTableID = RtrimGetField(rsTable!WLayoutID)
                           lngLayoutVersion = RtrimGetField(rsTable!VersionNumber)
                        End If   '14Oct09 TH
                        Exit Do '14Oct09 TH Removed '21Oct09 TH Reinstated
                     Else
                        If Not blnLayoutFound Then '14Oct09 TH
                           blnNewDraftLayout = False
                           If RtrimGetField(rsTable!VersionNumber) + 1 > lngLayoutVersion Then lngLayoutVersion = RtrimGetField(rsTable!VersionNumber) + 1 '09Oct09 TH Added
                        End If '14Oct09 TH
                     End If
                     rsTable.MoveNext
                  Loop
               End If
            End If
         End If
      End If
      If Not blnLayoutFound Then
         If GetSecondAuthorisation() Then  '26Aug09 TH Added new section (F0054335)
            If getaccesslevel() = 9 Then
               popmessagecr "Manufacturing", "No draft layout for " & Trim$(frmFormula!CmbLayout(Index - IndexModifier).text) & ". You can only approve existing draft layouts"
               Exit Sub
            End If
            Confirm "Layout not found", "add new draft layout ", ans$, k
            'blnNewDraftLayout = True '10Oct09 TH Required so we dont update the formula form underneath
            dteNow = Now
            dteApp = 0
         Else
            Confirm "Layout not found", "add new layout ", ans$, k
            dteApp = Now
                     
         End If
         
            strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("PatientsPerSheet", trnDataTypeint, 4, 1) & _
                        gTransport.CreateInputParameterXML("Layout", trnDataTypeVarChar, 50, Null) & _
                        gTransport.CreateInputParameterXML("LineText", trnDataTypeVarChar, 1024, Null) & _
                        gTransport.CreateInputParameterXML("IngLineText", trnDataTypeVarChar, 1024, Null) & _
                        gTransport.CreateInputParameterXML("Prescription", trnDataTypeVarChar, 5000, Null) & _
                        gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, Trim$(frmFormula.CmbLayout(Index - IndexModifier).text)) & _
                        gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, Iff(GetSecondAuthorisation(), "D", "L")) & _
                        gTransport.CreateInputParameterXML("EntityID_Draft", trnDataTypeint, 4, gEntityID_User) & _
                        gTransport.CreateInputParameterXML("EntityID_Approved", trnDataTypeint, 4, Iff(GetSecondAuthorisation(), 0, gEntityID_User)) & _
                        gTransport.CreateInputParameterXML("DraftDate", trnDataTypeDateTime, 8, dteNow)
            strParams = strParams & gTransport.CreateInputParameterXML("ApprovedDate", trnDataTypeDateTime, 8, dteApp) & _
                        gTransport.CreateInputParameterXML("VersionNumber", trnDataTypeint, 4, lngLayoutVersion) '09Oct09 TH Added version num variable
                     lngWLayoutID = gTransport.ExecuteInsertSP(g_SessionID, "W" & tablename$, strParams)
         'Now get the new record
         strParams = gTransport.CreateInputParameterXML(tablename$ & "ID", trnDataTypeint, 4, lngWLayoutID)
         Set rsTable = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbyWLayoutID", strParams)
         lngTableID = lngWLayoutID
         'lngLayoutVersion = 1 '09Oct09 TH Removed
      Else
         ''errored = True
      End If
   End If

   
   If Index = 4 Or Index = 5 Then
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 1024, frmFormula.LblNSVcode.Caption)
      'Set rsTable = gTransport.ExecuteSelectSP(g_SessionID, "pW" & tablename$ & "bySiteandNSVCode", strParams)
      Set rsTable = gTransport.ExecuteSelectSP(g_SessionID, "pW" & tablename$ & "bySiteandNSVCodeDraft", strParams) '13Oct09 TH Added to allow edit from draft
      If Not rsTable Is Nothing Then     'use returned recordset
         If rsTable.State = adStateOpen Then
            If rsTable.RecordCount <> 0 Then
               blnLayoutFound = True
            End If
         End If
      End If
      If Not blnLayoutFound Then
         'popmessagecr "!", "Formula for " & LTrim$(frmFormula.LblNSVcode.Caption) & "Not found"
         popmessagecr "!", "Unable to add or amend " & IIf(Index = 4, "label", "method") & " in draft formula for " & LTrim$(frmFormula.LblNSVcode.Caption) & crlf & crlf & "Draft formula must be saved first"
         errored = True
      End If
   End If
      
   If Not errored Then                                 '?????99 AE Added
      'SQL Here we use the recordset from above
      Select Case Index
         Case 0, 1, 2, 3, 4 ', 5   '
            If Not IsNull(rsTable.Fields(edittype$)) Then
               body$ = rsTable.Fields(edittype$)
            End If
               
            If Index = 4 Then          'Printing manufacturing Label...
               SetNumEditorLines 9  '24Feb99 SF added to allow expiry/batch# to fit on the last line
               ' TextEdit "Edit " & edittype$, body$, "", True, (edittype$ = "Label")                '03Sep99 AE Moved below
               ' If Index = 4 Then SetNumEditorLines 0  '24Feb99 SF added to reset to default value  '    "
                
               '????99 AE Block Added for RTF printing
               Select Case Mid$(acclevels$, 1, 1)
                  Case "1", "2", "3", "4", "5", "6", "7"  'Allow view / print only
                     AllowEdits = False
                  Case "8" ', "9"                           'Allow viewing, editing and printing '10Aug14 TH If you are authorising you can only view
                     AllowEdits = True
                  Case Else
                     AllowEdits = False
               End Select
      
               'Search for RTF header in the label text
               ans$ = Left$(body$, 5)
               If ans$ = "{\rtf" Or ans$ = "" Then RTFLabel = True Else RTFLabel = False
         

               If AllowEdits And Not RTFLabel Then                      '**V93** CKJ Only RTF is supported

                  '15Dec00 CKJ Added expiry & batchnumber in same format as was hard coded in ParseFormulaData
                  '            This can be altered or turned off via patmed.ini, CIVASconvertRTFexpiryline
                  '            where the default is "EXPIRY: [expirydate]  [batchnumber]"
                  tmp$ = RTrim$(TxtD(dispdata$ & "\patmed.ini", "", "EXPIRY: [expirydate]  [batchnumber]", "CIVASconvertRTFexpiryline", 0))
                  If tmp$ <> "" Then body$ = body$ & crlf & tmp$
   
                  MakeLocalFile fil$
                  TextToRTF 2, body$, "AmendLayout"
                  PutTextFile fil$, body$, success
                  parseRTF fil$, fil$
                  GetTextFile fil$, body$, success
                  Kill fil$
                  RTFLabel = True
               End If
      
               'Edit or view the label in the chosen format
               If Not k.escd Then
                  If RTFLabel Then
                     Hedit -1, ""
                     Hedit Abs(AllowEdits), body$
                     Hedit -3, ""
                     'Save changes.  Can only be made now via high edit
                     If AllowEdits Then
                        strLabel = body$
                        'This is the Label field in the Formula
                        lngOK = WFormulaLabelUpdate(rsTable.Fields("WFormulaID"), strLabel)
                        If GetSecondAuthorisation() Then WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Draft Formula (Version " & Format$(RtrimGetField(rsTable.Fields("VersionNumber"))) & ") for " & RtrimGetField(rsTable.Fields("NSVCode")) & " Updated"
                        ''lngOK = WLayoutUpdate(lngTableID, gDispSite, RtrimGetField(rsTable!PatientsPerSheet), RtrimGetField(rsTable!Layout), RtrimGetField(rsTable!Linetext), RtrimGetField(rsTable!IngLineText), RtrimGetField(rsTable!Prescription), RtrimGetField(rsTable!name))
                     End If
                  Else
                     TextEdit "Edit " & edittype$, body$, "", AllowEdits, True
                     'this block can be removed once the /Preveiw section is removed, if desired
                     If rsTable.Fields(edittype$) <> body$ Or IsNull(rsTable.Fields(edittype$)) Then
                        strLabel = body$
                        lngOK = WFormulaLabelUpdate(rsTable.Fields("WFormulaID"), strLabel)
                        If GetSecondAuthorisation() Then WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Draft Formula (Version " & Format$(RtrimGetField(rsTable.Fields("VersionNumber"))) & ") for " & RtrimGetField(rsTable.Fields("NSVCode")) & " Updated"
                     End If
                     '----------------------------------------
                     'SQL USe the ID from above to update this formula
                  End If
               End If
      
               Else                                               '03Sep99 AE Added
                  'editing files other than manufacturing labels
                  TextEdit "Edit " & edittype$, body$, "", True, (edittype$ = "Label")
                 ' If Index = 4 Then SetNumEditorLines 0  '24Feb99 SF added to reset to default value
                  If rsTable.Fields(edittype$) <> body$ Or IsNull(rsTable.Fields(edittype$)) Then
                     If Trim$(UCase$(edittype$)) = "METHOD" Then
                        'Update the method here
                        strMethod = body$
                        lngOK = WFormulaMethodUpdate(rsTable.Fields("WFormulaID"), strMethod)
                     End If
                     If Trim$(UCase$(edittype$)) = "LINETEXT" Then
                        'Update the method here
                        strMethod = body$
                        'STATUS HERE FOR DRAFT ?
                        If GetSecondAuthorisation() And getaccesslevel() = 8 Then
                           lngPatientsPerSheet = RtrimGetField(rsTable!PatientsPerSheet)
                           'strLayout = RtrimGetField(rsTable!Layout)
                           strStatus = "D"
                           dteNow = Now
                           lngOK = WLayoutUpdate(lngTableID, gDispSite, lngPatientsPerSheet, strDraftFileName, strMethod, strDraftIngLineText, strDraftPrescription, strDraftName, strStatus, lngLayoutVersion, gEntityID_User, 0, Now, 0)
                           ''''TODOF0054335 If GetSecondAuthorisation() Then WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Draft Formula (Version " & Format$(RtrimGetField(rsTable.Fields("VersionNumber"))) & ") for " & RtrimGetField(rsTable.Fields("NSVCode")) & " Updated"
                        Else
                        lngOK = WLayoutLineTextUpdate(rsTable.Fields("WLayoutID"), strMethod)
                        End If
                     End If
                     If Trim$(UCase$(edittype$)) = "INGLINETEXT" Then
                        'Update the method here
                        strMethod = body$
                        'STATUS HERE FOR DRAFT ?
                        If GetSecondAuthorisation() And getaccesslevel() = 8 Then
                           lngPatientsPerSheet = RtrimGetField(rsTable!PatientsPerSheet)
                           strName = RtrimGetField(rsTable!name)
                           strStatus = "D"
                           lngOK = WLayoutUpdate(lngTableID, gDispSite, lngPatientsPerSheet, strDraftFileName, strDraftLineText, strMethod, strDraftPrescription, strDraftName, strStatus, lngLayoutVersion, gEntityID_User, 0, Now, 0)
                        Else
                           lngOK = WLayoutIngLineTextUpdate(rsTable.Fields("WLayoutID"), strMethod)
                        End If
                     End If
                    ''rsTable.Fields(edittype$) = body$
                     ''MsgBox "Update"
                     ''''lngOK = WLayoutUpdate(lngTableID, gDispSite, RtrimGetField(rsTable!PatientsPerSheet), RtrimGetField(rsTable!Layout), RtrimGetField(rsTable!Linetext), RtrimGetField(rsTable!IngLineText), RtrimGetField(rsTable!Prescription), RtrimGetField(rsTable!name))
                  End If
               End If                                             '03Sep99 AE Added
                     '-----------------------
               
      
            Case Else
               If Not errored Then
                  blnLayoutExists = True
                  If Not IsNull(rsTable.Fields(edittype$)) Then
                     If Len(Trim$((rsTable.Fields(edittype$)))) = 0 Then
                        blnLayoutExists = False
                     End If
                     '''Else
                     '''   If GetSecondAuthorisation() And getaccesslevel() = 8 Then
                     '''      strTempFileName = dispdata$ & "\wksheets\Draft\" & Trim$((rsTable.Fields(edittype$)))
                     '''      If Not (DirExists(dispdata$ & "\wksheets\Draft")) Then
                     '''         MkDir dispdata$ & "\wksheets\Draft"
                     '''         blnLayoutExists = False
                     '''      Else
                     '''         If Not fileexists(strTempFileName) Then blnLayoutExists = False
                     '''      End If
                     '''   End If
                     '''End If
                  Else
                     blnLayoutExists = False
                  End If
                  If blnLayoutExists Then
                     filename$ = GetField(rsTable.Fields(edittype$))
                     If GetSecondAuthorisation() Then
                        If getaccesslevel() = 8 Then
                           If Index = 5 Then
                              lngOK = WFormulaUpdateDraft(rsTable.Fields("WFormulaID"))
                           Else
                              'lngOK = WLayoutUpdateDraft(rsTable.Fields("WLayoutID")) '22Oct09 TH now do below as user may escape
                           End If
                        End If
                     End If
                  Else
                     If GetSecondAuthorisation() And getaccesslevel() = 8 And Trim$(strDraftFileName) <> "" Then  '26Aug09 TH Added X
                        NewName$ = strDraftFileName                                                               '26Aug09 TH Added X
                     Else                                                                                         '26Aug09 TH Added X
                        filename$ = dispdata$ & "\wksheets\blank.rtf"
                        If Index = 6 Or Index = 7 Then
                           ''NewName$ = "w" & Format$(GetField(rsTable!ID)) & ".rtf"
                           NewName$ = "w" & Format$(lngTableID) & ".rtf"
                        Else
                           NewName$ = "m" & Trim$(GetField(rsTable!NSVCode)) & ".rtf"
                        End If
                     End If                                                                                       '26Aug09 TH Added X
                     On Error GoTo AmendLayout_CopyErr
                     If GetSecondAuthorisation() Then
                        If strDraftFileName <> "" Then filename$ = dispdata$ & "\wksheets\" & strDraftFileName
                        'If Not (DirExists(dispdata$ & "\wksheets\Draft")) Then '10Jan17 TH Removed (Hosted)
                        '   MkDir dispdata$ & "\wksheets\Draft"
                        'End If
                        'If Not fileexists(dispdata$ & "\wksheets\Draft\" & NewName$) Then    '26Aug09 TH Added X
                        If Not RTFExistsInDatabase(dispdata$ & "\wksheets\Draft\" & NewName$) Then '10Jan17 TH Replaced above to use DB (Hosted)
                           'FileCopy filename$, dispdata$ & "\wksheets\Draft\" & NewName$     '26Aug09 TH Added X
                           '10Jan17 TH Replaced above to use DB (Hosted)
                           'strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", NewName$)
                           strFilename = GetFileNameFromPath(filename$) '02Feb17 TH Added  (TFS 175410)
                           strRTFText = getPharmacyRTFfromSQL(filename$, strFilename) '02Feb17 TH Added replace above (TFS 175410)
                           lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets\Draft\", NewName$, strRTFText)
                        End If
                     Else
                        If Not RTFExistsInDatabase(dispdata$ & "\wksheets\" & NewName$) Then
                            strFilename = GetFileNameFromPath(filename$)
                            strRTFText = getPharmacyRTFfromSQL(filename$, strFilename)
                            lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets\", NewName$, strRTFText)
                        End If
                     End If
                     filename$ = NewName$
                     If Index = 5 Then
                        ''lngOK = WLayoutUpdate(lngTableID, gDispSite, lngPatientsPerSheet, strLayout, strLineText, strIngLineText, strPrescription, strName)
                        lngOK = WFormulaMethodUpdate(rsTable.Fields("WFormulaID"), strMethod)
                     Else
                        'Cast into variables
                        lngPatientsPerSheet = RtrimGetField(rsTable!PatientsPerSheet)
                        strLayout = RtrimGetField(rsTable!Layout)
                        strLineText = RtrimGetField(rsTable!LineText)
                        strIngLineText = RtrimGetField(rsTable!IngLineText)
                        strPrescription = RtrimGetField(rsTable!Prescription)
                        strName = RtrimGetField(rsTable!name)
                        Select Case LCase$(edittype$)
                           Case "linetext": strLineText = filename$
                           Case "inglinetext": strIngLineText = filename$
                           Case "label": strLabel = filename$
                           Case "method": strMethod = filename$
                           Case "layout": strLayout = filename$
                        End Select
                        'strName = FileName$ '12Mar07 TH Removed
                        strStatus = "L"
                        If GetSecondAuthorisation() Then
                           If getaccesslevel() = 8 Then
                              strStatus = "D"
                              lngOK = WLayoutUpdate(lngTableID, gDispSite, lngPatientsPerSheet, strLayout, strLineText, strIngLineText, strPrescription, strName, strStatus, lngLayoutVersion, gEntityID_User, 0, Now, 0)
                            Else
                              'Archive here ???
                           End If
                        Else
                           lngOK = WLayoutUpdate(lngTableID, gDispSite, lngPatientsPerSheet, strLayout, strLineText, strIngLineText, strPrescription, strName, strStatus, lngLayoutVersion, gEntityID_User, gEntityID_User, Now, Now)
                        End If
                        On Error GoTo 0
                        'Now update the drop down combo
                        FillLayoutCombos frmFormula
                        'set here the combo to the correct name
                        If Not blnNewDraftLayout Then frmFormula.CmbLayout(Index - 6).text = strName '09Oct09 TH Only Revert to this if not draft as only approved should be available.
                     End If
                  End If
                  If GetSecondAuthorisation() And getaccesslevel() = 8 Then
                     '14Dec16 TH Use new DB layer
                     
                     'Hedit 11, dispdata$ & "\wksheets\Draft\" & filename$
                     'strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", filename$)
                     'strRTFTextCopy = strRTFText
                     'Hedit 1, strRTFText
                     'If strRTFTextCopy <> strRTFText Then
                     '   'Now save to DB
                     '   lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets\Draft\", filename$, strRTFText)
                     'End If
                     'EditRTFFromDB dispdata$ & "\wksheets\Draft\"  '10Jan17 TH Replaced Above(Hosted)
                     EditRTFFromDB dispdata$ & "\wksheets\Draft\" & filename$  '02Feb17 TH Needs ctual file name !!! (TFS 175413)
                     
                     'TODOF0054335 we cant tell if the user has actually saved, but we should record if they have the draft details and loggit
                     'If LCase(getHETag()) <> "exit" Then lngOK = WLayoutUpdateDraft(rsTable.Fields("Layout")) '25Feb10 TH Altered as was WLayoutID previously (?)
                     If LCase$(edittype$) <> "method" Then  '26Mar10 TH Added We do not save layouts when we are dealing in worksheets (F)
                        If LCase(getHETag()) <> "exit" Then lngOK = WLayoutUpdateDraft(rsTable.Fields("Name")) '02Mar10 TH Altered Properly
                     End If                                 '26Mar10 TH
                  Else
                     If getaccesslevel() = 9 Then   '10Aug14 TH Allow viewing (TFS 86640)
                        'Hedit 10, dispdata$ & "\wksheets\" & filename$
                        'Hedit 10, dispdata$ & "\wksheets\Draft\" & filename$  '14Sep15 TH Allow view of DRAFT not current. User needs to see proposed one to authorise ! (TFS 129439)
                        strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", filename$)   '12Jan17 TH Converted (Hosted)
                        Hedit 0, strRTFText '12Jan17 TH Converted (Hosted)
                     Else
                        'Hedit 11, dispdata$ & "\wksheets\" & filename$
                        EditRTFFromDB dispdata$ & "\wksheets\" & filename$ '10Jan17 TH Replaced Above(Hosted)
                     End If
                  End If
                  'If LCase$(edittype$) = "method" Then
                  If LCase$(edittype$) = "method" And getaccesslevel() <> 9 Then '10Aug14 TH dont save on viewing (TFS 86640)
                     lngOK = WFormulaMethodUpdate(rsTable.Fields("WFormulaID"), filename$)
                     strMethod = filename$
                  End If
               End If
         End Select
      End If                           '?????99 AE Added



AmendLayout_Exit:
   rsTable.Close                    '19Nov98 CFY Added
   Set rsTable = Nothing            '      "
   ''CloseFormulaDatabase             '28Jul99 AE Added as part of data control unbinding
   frmFormula.cmdCancel.Tag = "C"      '28Jul99 AE Added to indicate changes have been made '14Jul00 JN Amended
   Exit Sub
   
Nolabel:
''   MyTable.Edit
''   MyTable.Fields(edittype$) = " "
''   MyTable.Update
''   MsgBox "Update"
   Resume Next

AmendLayout_CopyErr:
   popmessagecr ".", "Unable to create new " & edittype$ & ". Check that " & dispdata$ & "\wksheets\blankrtf.rtf exists."
   GoTo AmendLayout_Exit
End Sub

Sub getformula(found%, ByRef rsFormula As ADODB.Recordset)
'------------------------------------------------------------------------
'15Dec96 ASC
'09Jul99 CFY Mod to take into account patient specific formulas
'11oct99 CKJ Before opening formula database, check flag in drug file
'            Open database if formula is known to be present, or if
'            formula has not been checked yet.
'            Flag d.HasFormula =
'            "Y"                      open database
'            "N"                      don't open database
'            "<any other character>"  open database, check & store result
'
'22Oct99 CKJ Corrected d. to dTmp.
'14Sep15 TH Get draft formula here if draft or authorise mode to use draft method or label on previews (TFS 129553)
'------------------------------------------------------------------------

   found = False     '**V93**  !!**

''Dim iOpenDB As Integer
''Dim dTmp As DrugParameters
''Dim lngDrugFound As Long
Dim strParams As String
Dim lngResult As Long
Dim strKey As String

   If Trim$(d.SisCode) <> "" Then
      'If M_blnFromDispensing Then '25Jun08 TH Now if we have an rxno we search on that reagrdless, drop to drug if cant find.(F0026799)
      If gRequestID_Prescription > 0 Then
         'strKey = Format$(L.prescriptionid) '04Oct05 TH Replaced below
         strKey = Format$(gRequestID_Prescription)
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strKey)
         Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         If rsFormula.RecordCount = 0 Then
            rsFormula.Close
            Set rsFormula = Nothing
            strKey = Trim$(d.SisCode)
            strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strKey)
            Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         End If
      Else
         strKey = Trim$(d.SisCode)
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strKey)
         'Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         '14Sep15 TH Get draft here if draft or authorise mode (TFS 129553)
         If getaccesslevel() = 8 Or getaccesslevel() = 9 Then
            Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCodeDraft", strParams)
            If rsFormula.RecordCount = 0 Then
               rsFormula.Close
               Set rsFormula = Nothing
               Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
            End If
         Else
            Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         End If
      End If
      'strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
      '            gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strKey)
      'Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
      
      If rsFormula.RecordCount > 0 Then found = True
''         Select Case d.HasFormula
''            Case "Y":  iOpenDB = True
''            Case "N":  iOpenDB = False
''            Case Else: iOpenDB = 1
''            End Select
''
''         ''If iOpenDB Then
''               'Open database and set table
''               ''OpenFormulaDatabase
''
''               'Find formula for this NSVcode or patient
''               FormulaTable.Index = "NSVcode"
''               FormulaTable.Seek "=", d.SisCode
''               found = Not (FormulaTable.NoMatch)
''
''               If iOpenDB = 1 Then  'store result
''                     dTmp.SisCode = d.SisCode
''                     getdrug dTmp, 0, lngDrugFound, True
''                     If lngDrugFound Then
''                           dTmp.HasFormula = Iff(found, "Y", "N")   '22Oct99 CKJ Corrected d. to dTmp.
''                           putdrug dTmp, lngDrugFound
''                        End If
''                  End If
''        ''    Else
''        ''       found = False
''        ''    End If
      Else
         found = False
      End If

End Sub

Function ProductHasFormula() As Boolean
'**V93** Temporary wrapper written since PatBill used to use d.hasformula directly

Dim formulafound As Integer
Dim rsFormula As ADODB.Recordset
   
   formulafound = False
   Set rsFormula = New ADODB.Recordset
   getformula formulafound, rsFormula
   ProductHasFormula = formulafound
   rsFormula.Close
   Set rsFormula = Nothing
   
End Function

Sub GetManufactureInfo(QtyIssued!, cost!)
'30Jul98 EAC written for OCX mods

   QtyIssued! = ManuIssued!
   cost! = ManuCost!

End Sub

Sub getnewformula(frmFormula As Form, d As DrugParameters, found%, ByVal blnFromDispensing As Boolean)
'25Sep96 CKJ Mod to allow non numerics
'27Mar97 KR  Ensured that only call setfocus if formula form visible.
'31Mar98 CFY Added code to set k.escd to True if the user decides not to add a new formula
'            for this product. Previously if the user said No the program would still start
'            to add a new product, prompt the user if they wished to save, then fall over if they
'            said Yes.
'19Jun98 CFY Removed setting of k.escd = False at end of procedure as this overides any setting
'            of the flag that occured during the procedure. Previously the calling routine was
'            unable to tell if escape had been hit or not.

'28Jul99 AE  Re-Written to unbind the controls on formula.frm.  Based on the original code, which
'            has been re-named as GetNewFormulOld
'08Sep99 CFY Initialialised formula type to prevent errors occuring when trying to select a new formula
'            which doesn't exist
'11Jul00 JN  Added db.close and sn.close as just setting to Nothing may be causing problems
'14Jul00 JN  Added form instance reference
'08Oct09 TH  Added (F0064968) different message if there is pre-existing approved formula
'07Oct13 TH  Allow Stores Only selection (pack downs) (TFS 75305)

Dim lngfoundptr As Long, drug$, ans$
Dim dcop As DrugParameters
'Dim PatientFormula% '09Jan99 ASC               28Jul99 AE Replaced with FormulaType

Dim r$, SQL$
''Dim sn As Snapshot, db As Database
Dim rsFormula As ADODB.Recordset
Dim strParams As String
Dim strMsg As String
Dim strProcedure As String    '26Aug09 TH Added (F0054335)
Dim blnNewDraft As Boolean    '   "
Dim strTemp As String         '   "
Dim intVersion As Integer     '   "
Dim strLines() As String
Dim intAccessLevel As Integer '16Aug09 TH Added

'   Formula.FormulaData.Recordset.Update 'Why is this always needed

   FormulaType = 0            '08Sep99 CFY Added
   intAccessLevel = Val(Left$(acclevels$, 1))
   If Trim$(d.SisCode) = "" And Not k.escd Then
      k.Max = 20
      k.min = 2
      k.nums = False
      k.decimals = False    '25Sep96 CKJ Added
      k.esc = True
      InputWin "Manufacturing", "Enter code for manufactured item", drug$, k
      If Not k.escd Then
         'findrdrug (drug$), False, d, lngfoundptr, 0, False, False, False
         findrdrug (drug$), True, d, lngfoundptr, 0, False, False, False '07Oct13 TH Allow Stores Only selection (pack downs) (TFS 75305)
      End If
   Else
      getdrug d, 0, lngfoundptr, False
   End If


'First get the formula if it exists. Look for a patient (prescription, in fact) specific formula, then
'a master formula, if neither are found prompt to create a new one
   
   If lngfoundptr > 0 And Not k.escd Then
      
''         Set db = OpenDatabase(dispdata & "\Formula.mdb")

      LSet dcop = d 'copy siscode for formula item
      '09Jan99 ASC checks for existance of a patient specific formula
      ''if l.
      'If Labf& > 0 Then
      If gRequestID_Prescription > 0 Then '18jun08 TH Replaced above
         If InStr(Command$, "formuladebug") Then popmessagecr "Finding Patient specific formula", "Labf& = " & Str$(Labf&) & "l.prescriptionid = " & Str$(gRequestID_Prescription) '04Oct05 TH replaced l.prescriptionID
         'gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, L.prescriptionid)  '04OCt05 TH Replaced
         ''If L.prescriptionid = 0 Then GetPointerSQL patdatapath$ + "\RxID.dat", L.prescriptionid, True   '04OCt05 TH Removed                    '    "
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, gRequestID_Prescription)
''               sql$ = "SELECT * FROM Formula WHERE NSVcode = """ & L.prescriptionid & """"
         If GetSecondAuthorisation() Then
            Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCodeA", strParams)
         Else
            Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         End If
         'SQL$ = L.prescriptionid
         SQL$ = gRequestID_Prescription   '04Oct05 TH Replaced
''         Set sn = db.CreateSnapshot(sql$)
         If Not rsFormula.EOF Then
            FormulaType = PATIENT_FORMULA
            FormulaViewMode = 0 '18Jun08 TH
         End If
      End If
            
      If FormulaType <> PATIENT_FORMULA Then                                                                                             '    "
         If InStr(Command$, "formuladebug") Then popmessagecr "Patient formula not found", ""
         ''SQL$ = "Select * from Formula where NSVcode = """ & d.SisCode & """"
         SQL$ = d.SisCode
''         Set sn = db.CreateSnapshot(sql$)
         '26Aug09 TH If from batch then we need Draft/Approved status's (Ordered of course). If archive mode then we need
         '           here to display archived rows.
         strProcedure = "pWFormulabySiteandNSVCode"
         If (Not blnFromDispensing) And GetSecondAuthorisation() Then
            If intAccessLevel = 9 Then
               strProcedure = strProcedure & "Draft"
            ElseIf intAccessLevel = 8 Then
               strProcedure = strProcedure & "DraftandApproved"
            ElseIf intAccessLevel < 8 And intAccessLevel > 0 Then
               strProcedure = strProcedure & "Approved"
            ElseIf m_blnArchiveView Then
               strProcedure = strProcedure & "Archive"
            End If
         End If
         
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
         'Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
         Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, strProcedure, strParams)
         If Not rsFormula.EOF Then
            FormulaType = MASTER_FORMULA
            If (Not blnFromDispensing) And intAccessLevel = 8 Then
               rsFormula.MoveFirst
               If GetSecondAuthorisation() Then
                  If RtrimGetField(rsFormula!Code) = "L" Then '26Aug09 TH Added Section to ensure process begins at the correct stage
                     FormulaType = 0
                     blnNewDraft = True
                  End If
               End If
            ElseIf m_blnArchiveView Then
               'OK There could be more than one archived formula so here we must display all and get the user to select the one they require to view
               If rsFormula.RecordCount > 0 Then '10Oct09 TH was 1, but then single record not handled.
               'Display select and steer the rs
                  Unload LstBoxFrm
                  LstBoxFrm.LstBox.Clear
                  LstBoxFrm.Caption = "Select Archive Formula for " & d.SisCode
                  LstBoxFrm.lblHead = "Version " & TB & "Approved by - on" & Space$(15)
                  Do While Not rsFormula.EOF
                     strTemp = RtrimGetField(rsFormula!Approved_Initials) & " - " & Format$((rsFormula!DateApproved), "dd/mm/yyyy HH:NN")
                     LstBoxFrm.LstBox.AddItem RtrimGetField(rsFormula!VersionNumber) & " " & TB & strTemp
                     'LstBoxFrm.LstBox.ItemData(intCount) = RtrimGetField(rsTMS!ProductID)
                     'intCount = intCount + 1
                     rsFormula.MoveNext
                  Loop
                  LstBoxShow
                  If Len(LstBoxFrm.Tag) > 6 Then
                     ReDim strLines(2)
                     deflines LstBoxFrm.Tag, strLines(), TB, 1, 2
                     intVersion = CInt(strLines(1))
                     'Now manoeuver rs
                     rsFormula.MoveFirst
                     Do While Not rsFormula.EOF
                        If (RtrimGetField(rsFormula!VersionNumber)) = intVersion Then Exit Do
                        rsFormula.MoveNext
                     Loop
                  Else
                     k.escd = True
                  End If
                  Unload LstBoxFrm
               Else
                  '26Aug09 TH Superfluous ??? Doesnt hurt !
                  popmessagecr "!Manufacturing", "There are no archived records for this Product"
                  k.escd = True
               End If
            End If
         End If
         
      End If                                                                                                               '    "
      
      If Not k.escd Then   '26Aug09 TH Added
         'If formula.FormulaData.Recordset.RecordCount = 0 Then 'not found in current list or either patient or item formula's
         If FormulaType = 0 Then
            If intAccessLevel < 8 And (Not blnFromDispensing) Then
               'r$ = "Cannot find a formula for this drug.  Use the Manufacturing," & cr$
               If m_blnArchiveView Then
                  popmessagecr "!Manufacturing", "There are no archived records for this Product"
               Else
                  If GetSecondAuthorisation() Then
                     r$ = "Cannot find an approved formula for this product.  Use the Manufacturing " & cr$
                     r$ = r$ & "Module to create and approve a new formula if one is required."
                  Else
                     r$ = "Cannot find a formula for this product.  Use the Manufacturing " & cr$
                     r$ = r$ & "Module to create a new formula if one is required."
                  End If
                  popmessagecr "!Manufacturing", r$
               End If
               k.escd = True
            ElseIf intAccessLevel = 9 And (Not blnFromDispensing) And GetSecondAuthorisation() Then   '26Aug09 TH Added new section (F00564335)
               r$ = "Cannot find a draft formula for this product.  Use the Manufacturing " & cr$
               r$ = r$ & "Module to draft a new formula if one is required."
               popmessagecr "!Manufacturing", r$
               k.escd = True
            Else
               If InStr(Command$, "formuladebug") Then popmessagecr "!", "Item formula not found"
               ans$ = "N"
               If GetSecondAuthorisation() Then
                  If blnNewDraft Then '08Oct09 TH Added (F0064968) different message if there is pre-existing approved formula
                     strMsg = "edit approved copy of this formula to create a new draft"
                  Else
                     strMsg = "add new draft formula for this product"  '26Aug09 TH Added
                  End If
                  'strMsg = "add new draft formula for this product"  '26Aug09 TH Added
               Else
                  strMsg = "add new formula for this product"
               End If
               If blnFromDispensing Then strMsg = "add new formula specifically for this patient"
                           
               Confirm "", strMsg, ans$, k
               
               If ans$ = "Y" And Not k.escd Then
                  BlankFormulaForm frmFormula
                  frmFormula.LblNSVcode.Caption = d.SisCode
                  If frmFormula.TxtCode(0).Visible Then frmFormula.TxtCode(0).SetFocus
                  If blnNewDraft Then  '26Aug09 TH Added. If we are creating a new draft we are actually editing from existing approved (as we know one exists) - no draft exists
                     FormulaType = MASTER_FORMULA
                  Else
                     FormulaType = NEW_FORMULA
                  End If
                  If blnFromDispensing Then
                     FormulaType = NEW_PATIENTFORMULA
                     ''SQL$ = L.prescriptionid
                     SQL$ = gRequestID_Prescription   '04Oct05 TH Added
                  End If
               Else
                  d.SisCode = ""
                  k.escd = True
               End If
            End If
         End If
      End If
      If Not k.escd Then
         FormulaKey$ = SQL$
         SetFormulaForm frmFormula, rsFormula, blnFromDispensing                  'Only allow viewing for batch products from dispensary '26Aug09 TH Added new param
         found = True
         If frmFormula.ChkDosingUNits.Value = 0 And FormulaViewMode < 8 Then FormulaViewMode = 0
         If frmFormula.ChkDosingUNits.Value = 0 And m_blnFromDispens Then
         popmessagecr ".Manufacturing", "This is not a patient specific formula. Cannot issue this item extemporaneously"
         k.escd = True
         End If
      End If

''      sn.Close    '11Jul00 JN Added close statements
''      db.Close

      Set rsFormula = Nothing  '11Jul00 JN Changed order around
''      Set db = Nothing
         'Set sn = Nothing

      LSet d = dcop
'
         '09Jan99 ASC If this is for a specific patient and there is no formula saved at present then create a copy in the Addnew buffer which will only be save if the user changes the formula
'         If Not PatientFormula% And l.prescriptionid > 0 Then                   '09Jan99 ASC
'               If InStr(Command$, "formuladebug") Then popmessagecr "", "Making a new patient specific record"
'               copyorpasteformula 1 'copy the formula                           '      "
'               formula.FormulaData.RecordSource = "Select * from formula where NSVcode = '9999999999'"  '  "
'               formula.FormulaData.Refresh                                      '      "
'               formula.FormulaData.Recordset.AddNew                             '      "
'               formula.LblNSVcode.Caption = l.prescriptionid                    '      "
'               copyorpasteformula 2  'paste                                     '      "
'               formula.ChkDosingUNits.Value = 1                                 '      "
'               If formula.TxtCode(0).Visible Then formula.TxtCode(0).SetFocus   '      "
'            End If                                                              '      "
   Else
      found = False
   End If

   'k.escd = False      '19Jun98 CFY Removed


End Sub

Function GetNoIssueRequired() As Integer
    GetNoIssueRequired = m_blnNoIssue
End Function

Function GetNoLabelRequired() As Integer
   GetNoLabelRequired = m_blnNoLabel
End Function

Function GetPatsPerSheet(LayoutName$) As Integer

''Dim db As Database
''Dim Layout As table
Dim lngPatsPerSheet As Long
Dim strParams As String

   On Error GoTo GetPatsPerSheet_Err
   ''Set db = OpenDatabase(dispdata$ & "\formula.mdb")
   ''Set Layout = db.OpenTable("layout")
   ''Layout.Index = "Name"
   ''Layout.Seek "=", LayoutName$
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, LayoutName$)
   lngPatsPerSheet = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLayoutbySiteandNameForPatsPerSheet", strParams)
   GetPatsPerSheet% = CInt(lngPatsPerSheet)
''   If Not Layout.NoMatch Then
''         GetPatsPerSheet% = GetField(Layout!PatientsPerSheet)
''      Else
''         GetPatsPerSheet% = -1
''      End If

GetPatsPerSheet_Exit:
''   On Error Resume Next
''   Layout.Close
''   Set Layout = Nothing
''   db.Close
''   Set db = Nothing
   Exit Function

GetPatsPerSheet_Err:
   ''popmessagecr "", "Get not read field : PatientsPerSheet from formula.mdb"
   popmessagecr ".", "Get not read field : PatientsPerSheet from WLayout table"
   GetPatsPerSheet% = -1
   GoTo GetPatsPerSheet_Exit

End Function

Function getviewmode()

'28Jul99 AE Written as a callback from formula.frm to get the value of formulaviewmode

   getviewmode = FormulaViewMode

End Function

Sub InitialiseHeapItems()
'19Nov98 CFY Written
'Initialises CIVAS heap items with a SPACE character. Would have used empty string but this
'seemed to cause Hiedit to sometimes print garbage characters.
'
'21Jan99 CFY Added code to initialise array that keeps running total of qty's used
'16May01 JN  Added code to initialise tradename heap item to prevent [tradenamex] appearing on worksheets
'22Feb02 TH  Added code to initialise   [TotalPacksx] and [rTotalPacksx] (enh1372)
'01Oct02 TH  Added code to initialise ingvol patient label elements
'07Oct02 TH  Added code to initialise [batchnumbersx] and [ExpiryDateOnlyx] elements
'21Oct02 TH  Added code to initialise PatientDetails, cons and dob elements (where overhanging from previous multiple patien runs)
'17May04 TH  Added code to initialise ProductNSV and Item4Qty elements (#74372)
'28Aug09 TH  Ported: 12Jan07 PJC Added code to initilaise preparationdate and preparationtime (enh77351)
'19Mar10 TH  Added to put description on Worksheet (NB this doesnt support multiple patient worksheets) (F0078677)
'20Apr17 XN  182077 new fiels in manufacutire printing

Dim labels%, lines%

   'Clear Patient label information
   For labels = 1 To 6              'MAX Patient labels per sheet (for now)
      For lines = 1 To 11
         Heap 10, gPRNheapID, "StdLbl" & Format$(lines%) & "A" & Format$(labels%), " ", 0
         Heap 10, gPRNheapID, "StdLbl" & Format$(lines%) & "B" & Format$(labels%), " ", 0
      Next
      Heap 10, gPRNheapID, "dose" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "numdse" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "Vol/Dse" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "pSurname" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "pForename" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "pAddress1" & Format$(labels%), " ", 0
      Heap 10, gPRNheapID, "ingvol" & Format$(labels%), " ", 0    '01Oct02 TH Added
      Heap 10, gPRNheapID, "batchnumber" & Format$(labels%), " ", 0        '07Oct02 TH Added
      Heap 10, gPRNheapID, "ExpiryDateOnly" & Format$(labels%), " ", 0     '    "
      Heap 10, gPRNheapID, "PatientDetails" & Format$(labels%), " ", 0   '21Oct02 TH Added
      Heap 10, gPRNheapID, "cons" & Format$(labels%), " ", 0             '    "
      Heap 10, gPRNheapID, "dob" & Format$(labels%), " ", 0              '    "
   Next

   'Clear Formula Ingredient Information
   For lines = 1 To 15
      Heap 10, gPRNheapID, "itemcode" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "itemdesc" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "tradename" & Format$(lines%), " ", 0  '16May01 JN Added this to prevent [tradenamex] appearing on worksheets
      Heap 10, gPRNheapID, "itemqty" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "item4qty" & Format$(lines%), " ", 0   '17May04 TH Added (#74372)
      Heap 10, gPRNheapID, "iunits" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "dunits" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "totalunits" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "rtotalunits" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "supcode" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "supname" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "ibatchno" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "iexpiry" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "ilinetext" & Format$(lines%), " ", 0
      Heap 10, gPRNheapID, "Issued" & Format$(lines%), " ", 0      '28Jul99 AE Added
      Heap 10, gPRNheapID, "TotalPacks" & Format$(lines%), " ", 0       '22Feb02 TH Added (enh1372)
      Heap 10, gPRNheapID, "rTotalPacks" & Format$(lines%), " ", 0      '    "
      Heap 10, gPRNheapID, "Userfield1_" & Format$(lines%), " ", 0                  ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "Userfield2_" & Format$(lines%), " ", 0                  ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "Userfield3_" & Format$(lines%), " ", 0                  ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "Storesdesc" & Format$(lines%), " ", 0                   ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "Gendesc" & Format$(lines%), " ", 0                      ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "SupTradeName" & Format$(lines%), " ", 0                 ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "LabelDescriptionInPatient" & Format$(lines%), " ", 0    ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "LabelDescriptionOutPatient" & Format$(lines%), " ", 0   ' 20Apr17 XN 182077 new fiels in manufacutire printing
      Heap 10, gPRNheapID, "LocalDescription" & Format$(lines%), " ", 0             ' 20Apr17 XN 182077 new fiels in manufacutire printing
   Next

   Heap 10, gPRNheapID, "blank", " ", 0
   Heap 10, gPRNheapID, "totalvol", " ", 0
   Heap 10, gPRNheapID, "rtotalvol", " ", 0
   Heap 10, gPRNheapID, "voldiff", " ", 0    '16Jul13 TH Added (TFS 68238)
   Heap 10, gPRNheapID, "drugdescription", " ", 0
   Heap 10, gPRNheapID, "ProductNSV", " ", 0    '17May04 TH Added (#74372)
   Heap 10, gPRNheapID, "preparationdate", " ", 0    '12Jan07 PJC Added (enh77351)
   Heap 10, gPRNheapID, "preparationtime", " ", 0    '12Jan07 PJC Added (enh77351)
   Heap 10, gPRNheapID, "totvoldiluent", " ", 0      '12Jan07 TH Added (enh76987/#89003)
   
   '15Mar16 TH Added (TFS 148108)
   Heap 10, gPRNheapID, "voldiff/dse", " ", 0
   Heap 10, gPRNheapID, "totalvoldiff", " ", 0
   Heap 10, gPRNheapID, "rvoldiff/dse", " ", 0
   Heap 10, gPRNheapID, "rtotalvoldiff", " ", 0
   

   Erase TotalUnits!
   Erase totalQty!         '21Jan99 CFY Added
   TotalVol! = 0
   TotalIngVol! = 0
   sngIngVolperdose = 0 '15Mar16 TH (TFS 148108)
   sngVolperdose = 0     '15Mar16 TH (TFS 148108)
   
   '26Aug09 TH Added (F0054335)
   Heap 10, gPRNheapID, "FormulaVersion", " ", 0
   Heap 10, gPRNheapID, "FSaved", " ", 0
   Heap 10, gPRNheapID, "Fapprovedby", " ", 0
   'STILL TO DO !!!
   Heap 10, gPRNheapID, "worksheetversion", " ", 0
   Heap 10, gPRNheapID, "WSaved", " ", 0
   Heap 10, gPRNheapID, "Wapprovedby", " ", 0
   '--------
   Heap 10, gPRNheapID, "LblDescRaw", " ", 0  '19Mar10 TH (F0078677)

End Sub

Sub IssueAndPrintFormula(frmFormula As Form, d As DrugParameters, extemp%, Qty!, doses%, PIDdetails$, WorkingDate$, WorkingTime$, batchexpiry$, wrks$, PatsPerSheet%, Layout$, escd%, ByRef rsFormula As ADODB.Recordset)
'25Sep96 CKJ Removed "BN:"
'25Sep96 CKJ Add only totalcost PER ITEM to the stock value (NOT scale by stock level & add whole cost!)
'26Sep96 CKJ Removed Dim Transchan and tranrecno&
'29sep96 added another parsetime and parsedate to stop differences from parstime and time$
'        results making below re-ask for genuine time
'07Jul97 KR Unload issue form after use so that resizes correctly next time used.
'14Jul97 KR Set k.escd to false prior to calling MakeExpiry - Prevents Type mismatch error trying to assign empty string to an access date field further on.
'17Feb98 CFY Added blister packing code
'23Feb98 CKJ The translog line below was shown commented out, no date, no initials
'            This line brings manufactured items back into stock and surely must remain
'            I have therefore reinstated the line pending investigation.
'19Jun98 CFY Trap added stop stop manufacturing costcentres being specified in patmed.ini which
'            are "" ie. empty string. If this happens a warning is given and a default cost centre
'            is set.
'30Jul98 EAC make manufactured item cost and quantity available to OCX
'19Nov98 CFY Added PatsPerSheet% and Layout$ to parameter list
'24Feb99 SF  added and sets escd% parameter
'24Feb99 SF  now doesn't ask to allocate a batch for a patient if called from main menu
'24Feb99 SF  now exits the sub at various points where cancel selected
'04Jun99 CFY Now write balancing transactions when doing extemp items. Also removed code which prompts fro batch number from
'            this procedure and made into a separate routine. This enables generation of the batch number before the dispenary
'            label is printed which must be printed before the worksheet.
'28Jul99 AE  Open / Close FormulaDatabase added as part of control unbinding.
'03Aug99 AE / CFY Fixed call to translog. Was previously not doing the manufacturing balancing transaction.
'05Aug99 CFY Fix to prevent extemp items increasing the stock levels when they are made.
'03Sep99 AE / CY Fix to make patient specific formulas be written to translogs properly
'11oct99 CKJ Removed OpenFormulaDatabase - see inline comments
'02Jun00 JN  Added CIVAS related enhancements
'22Jun00 TH/AW Added code to calculate costexvat price of manufactured items.
'14Jul00 JN  Added reference to instance of form
'08Nov00 TH  Altered to stop division by zero  (Event 44586)
'01Oct02 TH  Check if expiry$ is already set to prevent over write of already entered expiry.
'01Oct02 TH  Added new look ups to allow for manufacturing issue to patient from dispensing screen
'            (sets extemp here to include all necessary log entries - ings, balance and final issue)
'01Oct02 TH  Added reset of m_blnLabelOnly after print & issue
'01Oct02 TH  Added switch to new PrintlabelsfromDispens sub (this allows standard dispensing label printing)
'01Oct02 TH  Dont set batchnumbers or totals if labels only are required
'01Oct02 TH  Keep modular batch + expiry variables as they are still needed for the label prints
'09Mar04 CKJ added lblPackSize
'26Aug09 TH  Ported :12Jan07 PJC Added arguments workingdate$, workingtime$ to the call to PrintManWorksheet (enh77351).
'24Jun13 TH  QA Yield - multiple mods to handle issuing of QA (TFS 48388)
'25Jul13 TH  Added pluralisation to QA issuing message (TFS 69591)
'20Sep13 TH  Ensure Colchester Tax "accrue" is used also by issues into Bond Store (TFS 73794)
'18Aug15 XN  Changed setting batch number 84575
Dim totalCost!, totalcostExVAT!, ward$
Dim desc$, found%, DrugNum As Long, labeltxt$
Dim ans$, valid%
Dim oldstklvl!
Dim i%, txt$, valdate%              '17Feb98 CFY Added
Dim startdate As DateAndTime, tbl$  '      "
Dim lngfoundptr As Long
Dim intLabels As Integer
Dim strCode As String
Dim intLeft As Integer
Dim intTop As Integer
Dim strAns As String '24Jun13 TH Added (TFS 48388)
Dim strQACostCentre As String '25Jun13 TH Added to allow configurable QA cost center
Dim strDescription As String
Dim strBONDCostCentre As String
Dim vatrate! '23Aug13 TH Merge error

   '02Dec96 ASC
   desc$ = d.LabelDescription   'desc$ = d.Description  XN 4Jun15 98073 New local stores description
   plingparse desc$, "!"

   '02Oct99 CKJ Line below was added by AE as part of unbinding, however if it is necessary then
   'it implies that there is a procedure which calls this routine without first setting the
   'current record - in which case the Getfield below would be pointing at the first record.
   'Line therefore commented out.
   'OpenFormulaDatabase           '28Jul99 AE Added
   
   
   'Find out how much is to be made unless calling routine pre-determines e.g. extemp from patmed
   If Qty! = 0 Then
         ''d.SisCode = GetField(FormulaTable.Fields("NSVcode")) '26sep96 ASC
         If Val(Left$(RtrimGetField(rsFormula.Fields("NSVcode")), 1)) = 0 Then '06Jun05 TH Dont get if Pat specific
            d.SisCode = GetField(rsFormula.Fields("NSVcode"))
            getdrug d, 0, 0, False
         End If
         FrmIssue.Height = 2100
         FrmIssue.CmdOk.Top = 1485
         FrmIssue.cmdCancel.Top = 1485
         FrmIssue.Frmlabels.Visible = False
         FrmIssue.TxtLabels = 0

         'FrmIssue.Caption = "MANUFACTURE (Batch size = " & d.convfact & LCase$(d.PrintformV) & ")"
         FrmIssue.Caption = "MANUFACTURE"                '28Jul99 AE information moved to label"
         'txt$ = "Batch size =" & d.convfact & LCase$(d.PrintformV) & cr$    '!!**29Jul99 CFY
         txt$ = txt$ & "Enter quantity to be manufactured " & "(" + RTrim$(Str$(Val(d.stocklvl))) + " " + RTrim$(LCase$(d.PrintformV)) + " in stock)"
         FrmIssue.LblTopLine.Caption = txt$
         FrmIssue.lblPackSize.Caption = ""    '09Mar04 CKJ

         FrmIssue.LblDrug.Caption = desc$
         FrmIssue.LblPrintForm.Caption = LCase$(d.PrintformV)
         FrmIssue.TxtIssue.text = d.convfact
         FrmIssue.TxtIssue.SelStart = 0
         FrmIssue.TxtIssue.SelLength = Len(FrmIssue.TxtIssue.text)
         FrmIssue.LblDrug.Caption = desc$
         If m_blnFromDispens Then
            '22Jun05 TH Added block
            intLeft = Val(terminal("ManufacturingIssueScreenLeft", "-1"))
            intTop = Val(terminal("ManufacturingIssueScreenTop", "-1"))
            If intLeft > -1 And intLeft > -1 Then
               On Error Resume Next
               FrmIssue.Move intLeft, intTop
               FrmIssue.Refresh
               On Error GoTo 0
            End If
         End If
         FrmIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         If Val(FrmIssue.cmdCancel.Tag) Then
            Unload FrmIssue
            escd% = True
            Exit Sub
         End If
         If Val(FrmIssue.TxtIssue.text) = 0 Then
            Unload FrmIssue
            escd% = True
            Exit Sub
         End If
         If Val(d.convfact) <= 0 Then
            'popmessagecr "Drug Data Erroneous", "Please re-enter stores pack size for " & d.Description XN 4Jun15 98073 New local stores description
                        popmessagecr "Drug Data Erroneous", "Please re-enter stores pack size for " & d.LabelDescription
         Else
            '24Jun13 TH (TFS 48388) QA Yield -Here we warn the user what will happen
            '           and check the quantities are OK. The user may back out
            If (Val(FrmIssue.TxtIssue.text) - rsFormula.Fields("QAQuantity")) < 1 Then
               popmessagecr "", "This formula requires " & Format$(rsFormula.Fields("QAQuantity")) & " units for QA. The present quantity will not be enough to create any issueable stock."
               Unload FrmIssue
               escd% = True
               Exit Sub
            Else
               If rsFormula.Fields("QAQuantity") > 0 Then
                  strAns = "Y"
                  '25Jul13 TH Added pluralisation to message below (TFS 69591)
                  askwin "EMIS Health", "Please note that " & FrmIssue.TxtIssue.text & " " & Trim$(LCase$(d.PrintformV)) & plural$(Val(FrmIssue.TxtIssue.text)) & " will be made. " & Format$((Val(FrmIssue.TxtIssue.text) - rsFormula.Fields("QAQuantity"))) & " will be issued to " & IIf(rsFormula.Fields("Bond_Issue") = True, "the bond store", "stock") & " and " & Format$(rsFormula.Fields("QAQuantity")) & " will be issued to QA. OK to continue Y/N", strAns, k
                  If strAns <> "Y" Then k.escd = True
                  If k.escd Then
                     Unload FrmIssue
                     escd% = True
                     Exit Sub
                  Else
                     Qty! = Val(FrmIssue.TxtIssue.text)
                     gCIVASdos$ = CStr(Qty!)  '02Jun00 JN Added
                     setm_sgnCivasDose Qty!   '22May08 Th Ported
                     setm_QAQty rsFormula.Fields("QAQuantity")
                  End If
               Else
                  Qty! = Val(FrmIssue.TxtIssue.text)
                  gCIVASdos$ = CStr(Qty!)  '02Jun00 JN Added
                  setm_sgnCivasDose Qty!   '22May08 Th Ported
               End If
            End If
            
         End If
         Unload FrmIssue '07Jul97 KR
      End If

                                                                      '         "

   If Not extemp Then
         '29sep96 ASC changed from - to / to stop valid becoming false below
'SQL REMOVED
'''         ans$ = Mid$(date$, 4, 2) & "/" & Left$(date$, 2) & "/" + Right$(date$, 4)
'''         'parsedate ans$, ans$, "1", 0 '03Jul97 KR
'''         parsedate ans$, ans$, "8", 0
'''         Do
'''            inputwin "Calculate expiry", "Enter DATE when stock will be manufactured", ans$, k
'''            If k.escd Then escd% = True: Exit Sub    '24Feb99 SF added
'''            'parsedate ans$, workingdate$, "1", valid
'''            parsedate ans$, workingdate$, "8", valid
'''            If workingdate$ <> ans$ Then valid = False: ans$ = workingdate$
'''         Loop Until valid
'''         If Not extemp Then ans$ = Left$(Time$, 5)
'''         '29sep96 added another parsetime to stop differences from parstime and time$ results making below re-ask for genuine time
'''         parsetime ans$, ans$, "1", 0
'''         Do
'''            inputwin "Calculate expiry", "Enter TIME when stock will be manufactured", ans$, k
'''            If k.escd Then escd% = True: Exit Sub     '24Feb99 SF added
'''            parsetime ans$, workingtime$, "1", valid
'''            If workingtime$ <> ans$ Then valid = False: ans$ = workingtime$
'''         Loop Until valid
      End If
   k.escd = False    '14Jul97 KR
   MakeExpiry k, WorkingDate$, WorkingTime$, batchexpiry$

   setexpirydate batchexpiry$ '02Jun00 JN store batch expiry date

   parsedate Left$(batchexpiry$, 10), ManBlister.expiry, "ddmmmyy", valdate%
   'Book out ingredients to manufacture cost centre and print worksheet
   'Find the cost centre for manufacturing issues
   ward$ = UCase$(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "MANU", "CostCentre", found))
   'If Not found Then popmessagecr "Patmed.ini entry missing", "No 'CostCentre =' under [manufacturing] using MANU as default - contact system manager"                 '19Jun98 CFY Replaced with line below
   If Not found Or ward$ = "" Then popmessagecr "Patmed.ini entry missing", "No 'CostCentre =' under [manufacturing] using MANU as default - contact system manager"    '
   If ward$ = "" Then ward$ = "MANU"                                                                                                                                    '19Jun98 CFY Added
   'PrintManWorksheet frmFormula, 0, Qty!, doses%, extemp%, ward$, totalCost!, totalcostExVAT!, PIDdetails$, batchexpiry$, wrks$, PatsPerSheet%, Layout$, escd%, rsFormula   '24Feb99 SF       '14Jul00 JN
   PrintManWorksheet frmFormula, 0, Qty!, doses%, extemp%, ward$, totalCost!, totalcostExVAT!, PIDdetails$, batchexpiry$, wrks$, PatsPerSheet%, Layout$, WorkingDate$, WorkingTime$, escd%, rsFormula           '12JanO7 PJC added arguments workingdate$, workingtime$ (enh77351)  If escd% Then k.escd = True      '24Feb99 SF added
   If Not m_blnLabelOnly Then  '01Oct02 TH Added
      GlobalManufBatchNum$ = m_batchnumber$  '23Sep96 CKJ PRAGMATIC SOLUTION - Needs improving !!**
      setbatchnum GlobalManufBatchNum$       '02Jun00 JN Added batchnum to transaction log
      setManufactureInfo Qty!, totalCost!    '30Jul98 EAC added for OCX mods
   End If                      '    "

   
   
   If Not k.escd And ans$ <> "N" Then                             '24Feb99 SF
      '17Feb98 CFY Added  -----
''      If frmFormula.ChkBlisterPack Then
''         If OpenRTF(txt$, "\manblist.rtf") Then
''            replace txt$, "[drug]", ManBlister.drug, 0
''            replace txt$, "[strength]", ManBlister.Strength, 0
''            replace txt$, "[batch]", RTrim$(ManBlister.Batch), 0
''            replace txt$, "[expiry]", Left$(ManBlister.expiry, 8), 0
''            replace txt$, "[hospital]", hospname1$, 0
''         End If
''         For i = 1 To Qty!
''            Hedit 4, "ManuFoil" & Nul & txt$
''         Next
''
''         txt$ = ""
''         If OpenRTF(txt$, "\BLWKPHDR.RTF") Then
''            today startdate
''            pid.forename = " "
''            pid.surname = " "
''            pid.cons = " "
''            pid.caseno = " "
''
''            ParseWkSheetHdr txt$, startdate
''            tbl$ = ""
''            If OpenRTF(tbl$, "\BLWKTBL.RTF") Then
''               replace tbl$, "[drug]", ManBlister.drug, 0
''               rtfinsert tbl$
''               replace txt$, "[drugtable]", Trim$(tbl$), 0
''               Hedit 4, "BlistWkSh" & Nul & txt$
''            End If
''         End If
''      End If
     
      'Print Labels
      If Not (extemp) Then
         On Error Resume Next
         ''labeltxt$ = GetField(FormulaTable.Fields("Label")) & Chr$(10) & Chr$(13) & plvl$("DoNotUseAfter") & batchexpiry$ & "  " & m_batchnumber$  '25Sep96 CKJ Removed "BN:" '26sep96 ASC added getfield
         labeltxt$ = GetField(rsFormula.Fields("Label")) & Chr$(10) & Chr$(13) & plvl$("DoNotUseAfter") & batchexpiry$ & "  " & m_batchnumber$  '25Sep96 CKJ Removed "BN:" '26sep96 ASC added getfield
         On Error GoTo 0
         If m_blnFromDispens Then                       '01Oct02 TH Added
         ''   PrintLabelsFromDispens batchexpiry$
            If Not IsNull(rsFormula.Fields("Numoflabels")) And Not IsNull(rsFormula.Fields("Extralabels")) Then
               intLabels = (rsFormula.Fields("Numoflabels") * Int((Qty! / Val(d.convfact)) + 0.999)) + rsFormula.Fields("Extralabels")
            End If
            If intLabels > 0 Then
               DisplaytheLabel intLabels, 3, k, batchexpiry$, 0, False
            Else
               DisplaytheLabel 1, 3, k, batchexpiry$, 0, False
            End If
               
         Else
            ''If Not IsNull(FormulaTable.Fields("Numoflabels")) And Not IsNull(FormulaTable.Fields("Extralabels")) Then
            If Not IsNull(rsFormula.Fields("Numoflabels")) And Not IsNull(rsFormula.Fields("Extralabels")) Then
               'enough labels for each NSVs worth + a set for a part NSV's worth and a set of extra labels per batch
               '26sep96 ASC
               'printlabels labeltxt$, LTrim$(Str$((FormulaTable.Fields("Numoflabels") * Int(qty! + .999)) + FormulaTable.Fields("Extralabels")))
               ''printlabels labeltxt$, LTrim$(Str$((FormulaTable.Fields("Numoflabels") * Int((Qty! / Val(d.convfact)) + 0.999)) + FormulaTable.Fields("Extralabels")))
               printlabels labeltxt$, LTrim$(Str$((rsFormula.Fields("Numoflabels") * Int((Qty! / Val(d.convfact)) + 0.999)) + rsFormula.Fields("Extralabels")))
            Else
               printlabels labeltxt$, 1
            End If
         End If
      End If
      If Not m_blnNoIssue Then    '01Oct02 TH Added
         'Adjust drug stock level and cost and make balancing transaction
         'If Qty! > 0 And Not extemp% Then                                                   '04Jun99 CFY Replaced
         If Qty! > 0 Then                                                                   '     "
            If extemp Then                                                                   '?????99 AE/CY added for patient specific formulas
               d.SisCode = L.SisCode                                                        '  "
            'ElseIf M_blnFromDispensing Then
            '
            Else
               ''d.SisCode = GetField(FormulaTable.Fields("NSVcode")) '26sep96 added getfield
               d.SisCode = GetField(rsFormula.Fields("NSVcode"))
            End If                                                                          '  "
            strCode = d.SisCode
            getdrug d, 0, lngfoundptr, False
            'If lngfoundptr = 0 And Trim$(strCode) = Trim$(Format$(L.prescriptionid)) Then  '01Oct02 TH Added
            If lngfoundptr = 0 And Trim$(strCode) = Trim$(Format$(gRequestID_Prescription)) Then  '04Oct05 TH Added
               d.SisCode = Trim$(frmFormula.LblNSVcode.Caption)
               getdrug d, 0, lngfoundptr, False
               extemp% = True
            End If
            DrugNum = lngfoundptr

            'Make balancing transaction
            If TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "0", "QC", 0) = "1" Then                                                               '30Dec97 ASC
               popmessagecr "Stock in Bond", "To create stock an order needs to be raised and received at the total cost for this batch's yield"   '30Dec97 ASC
            Else                                                                                                                                   '30Dec97 ASC
                           
      
               '23Feb98 CKJ The line below was shown commented out, no date, no initials
               ' This line brings manufactured items back into stock and surely must remain
               ' I have therefore reinstated the line pending investigation.
               
               setbatchnum GlobalManufBatchNum$ '18Aug15 XN Moved here so always set 64575
               If Not extemp% Then
                  strBONDCostCentre = TxtD(dispdata$ & "\patmed.ini", "manufacturing", "BOND", "BONDCostCentre", 0)
                  If GetField(rsFormula.Fields("Bond_Issue")) = True Then '26Jun13 TH (TFS 56621)
                     Translog d, DrugNum, UserID$, "", dp!((Qty! - getm_QAQty()) * -1) * doses%, m_batchnumber$, ward$, "", "M", SiteNumber, "MB", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)  'Book into Manu
                     Translog d, DrugNum, UserID$, "", dp!((Qty!) - getm_QAQty()) * doses%, m_batchnumber$, strBONDCostCentre, "", "M", SiteNumber, "BOND", Str$(totalCost!) & Chr$(160) & Str$(totalcostExVAT!)     'then out to bond
                  Else
                     'Translog d, DrugNum, UserID$, "", dp!(Qty! * -1) * doses%, m_batchnumber$, ward$, "", "M", SiteNumber, "MB", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)    '18Jun00 TH
                     Translog d, DrugNum, UserID$, "", dp!((Qty! - getm_QAQty()) * -1) * doses%, m_batchnumber$, ward$, "", "M", SiteNumber, "MB", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)    '18Jun00 TH
                  End If
                  gcivasbatch = ""  '05Jun00 Added - clears off CIVAS batch details when finished writing dets to translog
               Else
                  'setbatchnum GlobalManufBatchNum$  '18Aug15 XN Moved to above 64575 '05Jun00 JN Added get back the batch number which has been blanked
                  Translog d, DrugNum, UserID$, (pid.recno), dp!(Qty! * -1) * doses%, m_batchnumber$, ward$, "", "M", SiteNumber, "MB", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)  '18Jun00 TH
               End If
      
               'If manufactured then make a new entry in BatchStockLevel Table to take new stock level
               If m_blnFromDispens Then extemp% = True '01Oct02 TH Added
               If Not extemp% Then                                                                                                                                                                                                         '  Now all this goes
                  'AddStockOfBatch d.SisCode, batchexpiry$, dp!(Qty! / Val(d.convfact)), m_batchnumber$'  inside the if statement
                  If GetField(rsFormula.Fields("Bond_Issue")) Then  '26Jun13 TH (TFS 56621)
                     'Here we must store the bond record with all details required to later release the product into stock and batch stock
                                         strDescription = d.LabelDescription   'strDescription = d.Description XN 4Jun15 98073 New local stores description
                     plingparse strDescription, "!"
                     
                     '20Sep13 TH (TFS 73794)
                     If TransLogVAT% Then vatrate! = VAT(Val(d.vatrate)) Else vatrate! = 1
                     If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "N", "includeTaxinFinalProduct", 0)) And vatrate! = 1 Then
                        totalcostExVAT! = totalCost!
                     End If
                     '---
                     
                     AddToBondStore d.SisCode, strDescription, batchexpiry$, dp!((Qty! - getm_QAQty()) / Val(d.convfact)), m_batchnumber$, totalCost!, totalcostExVAT!, getm_QAQty()
                  Else
                     AddStockOfBatch d.SisCode, batchexpiry$, dp!((Qty! - getm_QAQty()) / Val(d.convfact)), m_batchnumber$                                                                                                                                                                                                                       '05Aug99 CFY
                     getdrug d, DrugNum, lngfoundptr, True   '<--------- LOCK drug record 'Update stocklevel and cost for manufactured item                                                                                                      '05Aug99 CFY
                     oldstklvl! = Val(d.stocklvl)                             '25Sep96 ASC/CKJ                                                                                                                                             '05Aug99 CFY
                     'd.stocklvl = LTrim$(Str$(dp!(Val(d.stocklvl) + Qty!)))   '25Sep96 ASC/CKJ                                                                                                                                             '05Aug99 CFY
                     d.stocklvl = LTrim$(Str$(dp!(Val(d.stocklvl) + (Qty! - getm_QAQty()))))   '24Jun13 TH Factor out any QA qty                                                                                                                                            '05Aug99 CFY
                     
                     '22Aug13 TH Added section (TFS )
                     If TransLogVAT% Then vatrate! = VAT(Val(d.vatrate)) Else vatrate! = 1
                     If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "N", "includeTaxinFinalProduct", 0)) And vatrate! = 1 Then
                        If Val(d.stocklvl) <> 0 Then
                           d.cost = Format$((Val(d.cost) * oldstklvl! / Val(d.convfact) + totalCost!) / (Val(d.stocklvl) / Val(d.convfact)))
                        Else
                           'If Qty! <> 0 Then d.cost = Format$((totalcostExVAT!) / (Qty! / Val(d.convfact))) '08Nov00 TH
                           If (Qty! - getm_QAQty()) <> 0 Then d.cost = Format$((totalCost!) / ((Qty! - getm_QAQty()) / Val(d.convfact))) '24Jun13 TH Factor out any QA qty
                        End If
                     Else
                        If Val(d.stocklvl) <> 0 Then   '08Nov00 TH Altered to stop division by zero  (Event 44586)
                           d.cost = Format$((Val(d.cost) * oldstklvl! / Val(d.convfact) + totalcostExVAT!) / (Val(d.stocklvl) / Val(d.convfact))) '25Sep96 CKJ/ASC Add only totalcost PER ITEM to the stock value   '27sep96 ASC Now Ex VAT      '05Aug99 CFY
                        Else                        '08Nov00 TH
                           'If Qty! <> 0 Then d.cost = Format$((totalcostExVAT!) / (Qty! / Val(d.convfact))) '08Nov00 TH
                           If (Qty! - getm_QAQty()) <> 0 Then d.cost = Format$((totalcostExVAT!) / ((Qty! - getm_QAQty()) / Val(d.convfact))) '24Jun13 TH Factor out any QA qty
                        End If
                     End If
                     putdrug d  '23Aug13 TH Disastrous merge lost this !!!
                  End If
                  If getm_QAQty() > 0 Then '24Jun13 TH (TFS 48388) 'QA Issue can still be done on Bond Issues
                     'Further log at Zero Cost to QA cost centre
                     strQACostCentre = TxtD(dispdata$ & "\patmed.ini", "manufacturing", "QA", "QACostCentre", 0)
                     Translog d, DrugNum, UserID$, "", getm_QAQty(), m_batchnumber$, strQACostCentre, "", "M", SiteNumber, "MB", "QA"     '18Jun00 TH
                     setm_QAQty (0)
                  End If
               End If                                                                                                                                                                                                                   '05Aug99 CFY
               
               If extemp% Then
                  Translog d, DrugNum, UserID$, (pid.recno), dp!(Qty!) * doses%, L.dircode, (pid.ward), (pid.cons), (pid.status), SiteNumber, "MB", Str$(totalCost!) & Chr$(160) & Str$(totalcostExVAT!)   '18Jun00 TH
               End If
            End If
         Else
            If Not extemp% Then popmessagecr "!", "No batch quantity entered in formula"
         End If
      End If '01Oct02 TH Added
   End If
   
   If k.escd Or ans$ = "N" Then
      escd% = True
   Else
      escd% = False
   End If

   gCIVASdos$ = ""    '01Jun00 JN Added
   If Not m_blnLabelOnly Then  '01Oct02 TH Keep these as they are still needed for the label prints
      setbatchnum ""     '02Jun00 JN Added
      setexpirydate ""   '02Jun00 JN Added
   End If
   m_blnLabelOnly = False '01Oct02 TH Added
   gcivasbatch = ""   '29Aug01 TH Belt and Braces !
   setm_QAQty (0)  '24Jun13 TH As above - belt and braces (TFS 48388)
End Sub

Sub NewFormula(frmName As Form)
'14Jul00 JN moved code here from CmdNew_Click
'07Nov00 JN Added code to add New Formulas even in the formula the user
'           hasn't made any changes to the one they are editing

If frmName.cmdCancel.Tag = "C" Then '11Jul00 JN Checks for changes before adding a new formula
          CancelFormula frmName     '14Jul00 JN changed to refer to module-based code
      End If
   
   d.SisCode = ""
   k.escd = False                   '20Jul00 JN prevent routine from binning out early

   If UCase$(frmName.cmdCancel.Tag) <> "C" Then    '07Nov00 JN Added new but here
      frmName.Hide
   End If

End Sub

Sub ParseFormulaData(frmFormula As Form, Qty!, doses%, extemp%, ward$, Changed%, totalCost!, totalcostExVAT!, batchexpiry$, wrks$, WorkingDate$, WorkingTime$, escd%, ByRef rsFormula As ADODB.Recordset, ByRef rsLayout As ADODB.Recordset)
'19Nov98 CFY re-written main routine so that it now uses the print heap rather than parsing the
'            information here. Old routine has be renamed OldParseFormulaData
'24Feb99 SF  added and sets escd% parameter
'04Jun99 CFY Fixed problem with multiple vial sizes. Now allows user to do multiple issues.
'            Also changed the issuing so that the ingredient products are issued to manufacturing even if doing an extemp
'            item. This is because the final product is now charged to the patient.
'12Jul99 CFY Changed /par to \par. Added [date] element for backwards compatability
'            Also blank method on heap if it is not present in the database
'28Jul99 AE  Added line to clear the item [method] on the print heap. Previously was persisting, so if we printed two
'            worksheets, the first with a method and the second without, the second would contain the method from the first.
'            Also replaced the word "doses" at the end of a batched produced item (in [description]) with d.printformV
'            This is as it was in previous versions and seems to have been changed in error
'04Aug99 CFY Mod to display correct units when issuing multiple strength vials.
'06Sep99 CFY Now only displays total quantity for 1 vial size when issuing multiple strength vials. Other vial strengths
'            will be listed with no quantity.
'13Jan00 CFY Fixed a number of rounding errors.
'13Mar00 AW  Added if then statement to check issueqty!. If user has changed issue qty to 0 was not taking this into account
'            when working out cost of formula. Resets formulaqty! and issuecost$ for that ingredient.
'19May00 AW  Added formual mask to prevent rounding errors on civas worksheets.
'24May00 AE  added FormatVal to round quantity to 7sig figs/2decpl in the [formula] data item.
'05Jun00 JN  Added batch numbering for CIVAS items
'14Jul00 JN  Added form instance reference
'17Jul00 JN  Added trap to stop Overflow error when issuing
'23Oct00 TH  clear previous cost elements (for 0 qty ingredient issues !)
'31Oct00 TH  Added Tradename for printable element of ingredient
'15Nov00 TH  Added expirydateonly and expirytimeonly printable elements
'15dec00 CKJ Label section; hard coded expiry/batchno line removed as it should be in the layout
'             and it does not match the 'label' on the worksheet
'22Jan01 TH  Remove additional blank lines in label element of worksheet
'22Feb02 TH  Added Elements for ingredients  [TotalPacksx] and [rTotalPacksx] (enh1372)
'01Oct02 TH  Added check on findrdrug in loop (if drug$ is nsvcode then pushing through findrdrug again just fires duplicate warnings)
'01Oct02 TH  Added 'hours' after Exphrs printable element
'01Oct02 TH  Changed caption on manissue form to make clear if no issue will actually result
'07Oct02 TH  Added a mod to read the heap for rxExpiry (entered directly by the user) - if this exists then use this for the
'            Expiry, not he system calculated value (note this is not parsed (yet?), so dont use for date or time only settings !)
'15Oct02 TH  Added hours suffix to ExpHrs element (missed from merge of 01Oct02)
'07Feb03 TH  Added stdLbl10A element to the heap. Not pretty - see note below for explanation
'14Feb03 TH/CKJ Added dp! to restore previous functionality
'17Feb03 TH  Moved new stdLbl10A block lower and amended slightly to be able to use edited expiry
'17Feb03 TH  Moved dp!mod to below ingredient processing to avoid rounding issues in any user windows (eg for variable doses)
'06Jun03 TH  Added Mod to round ingredients if ini file is set AND ingredient set to issueinwholepacks (#68678)
'19Jun03 TH  Various alterations to above after second check (#68678)
'17May04 TH  Added code for new ProductNSV and Item4Qty elements (#74372)
'24May04 TH  Now use the dosing units of the product selected, NOT possibly the last one (if the item is selected here) (#71589)
'26Aug09 TH  Ported :'12Jan07 PJC Added input arguments workingdate$, workingtime$ and added them to print heap (enh77351).
'09Oct09 TH  Completed print heap elements and enhanced to handle old data too (as much as possible) (F0065893)
'19Mar10 TH  Added to put description on Worksheet (NB this doesnt support multiple patient worksheets) (F0078677)
'12Nov10 TH  Allow stores only items as ingredients (where allowed pre RCNP0158, but stores only changes have made these unfindable) (F0101234)
'10Dec12 TH  Ensure product is in cache at close of manu issue form, not ingredient (TFS 35629)
'20Jun13 TH  Syringe Handling : Now use tag handling to pick up user has OKed Values. For some reason cancel button code not being fully evoked. (TFS 66809)
'16Jul13 TH Put the actual issued qty on the heap (TFS 69172)
'14Sep15 TH  We always get the latest draft method when in the draft or approval desktop (TFS 129553)
'15Dec15 TH  Changed dosesperissueunit to single to stop inappropriate rounding (TFS 136119/145490)
'22May16 TH  Unload the syringes form before use to ensure no values can be cached or re-used (TFS 153997)
'20Apr17 XN  182077 new fiels in manufacutire printing
'17Jul17 TH  Added block to remove unwanted blank lines from [Label] element (port from v8.9) (TFS 189065)

Dim char$, drug$
Dim X%, found%, IngType$, lineprinted%, formulaqty!, IssueCost$
Dim dcop As DrugParameters, punits$
Dim FBatchnumber$, dt As DateAndTime, CalcExp As DateAndTime, batchtimeexpiry$ 'for copies of formula batchno details
Dim DateToday As DateAndTime
Dim IngredientType$, StillToIssue!, Issued!, ans$
Dim DescConvfact!       '25Aug97 ASC
Dim strTmpTotPck As String, strTmprTotPck  As String  '22Feb02 TH Added

Dim text$, Errors$
Dim Index%, FoundSup As Long
Dim packed%             '17Feb98 CFY Added
Dim qtyans$             '24Feb98 ASC/CFY
Dim tmp$, tmp2$         '15Sep98 TH
Dim PatientName$
Dim sup As supplierstruct
Dim ExpiryTime&
Dim dosesperissueunit As Single, AmountToIssue!, msg$, desc$, DosingUnits$, PrintformV$    '04Jun99 CFY '15Dec15 TH Change dosesperissueunit to single to stop inappropriate rounding (TFS 136119/145490)
Dim FirstVial%, DisplayQty%          '06Sep99 CFY Added
Dim Emsg%                            '17Jul00 JN  Added
Dim lngDrugPtr As Long
Dim strTmpExpiry As String  '07Oct02 TH Added
Dim strStdLbl10AFrig As String, strTmp As String    '07Feb03 TH Added
Dim StrItem4Qty As String   '14May04 TH Added
Dim lngPtr As Long
Dim strResult As String '19Apr05 TH
Dim count As Integer
Dim strAns As String
Dim strNSVCode As String
Dim dkeep As DrugParameters
Dim prepdate As DateAndTime  '05Aug09 TH Added '26Aug09 TH Ported
Dim ExpiryTimePrep&          '     "
Dim ExpiryTimePrepHours&     '     "
Dim strLabel As String, strDesc As String   '19Mar10 TH
Dim intSplitLine As Integer, intloop As Integer '19Mar10 TH
Dim strFormat As String  '30Nov12 TH
Dim strTemp As String
Dim strForm As String
Dim strIVContainer As String
Dim strDrugName As String
Dim dlcl As DrugParameters


   'Initialise
   ReDim lines$(1)
   ReDim IssueSummary(100)
   ReDim desclines$(5)
   packed = False
   If doses% = 0 And Not extemp% Then doses% = 1
   LSet dcop = d
   totalCost! = 0
   totalcostExVAT! = 0
   
   Heap 10, gPRNheapID, "date", Mid$(date$, 4, 3) & Left$(date$, 3) & Right$(date$, 4), 0    '[date]
   
   NameOfUnits (L.dose(1)), strForm       '30Nov12 TH Use new variable
   Heap 10, gPRNheapID, "du", strForm, 0  '     "                                            '[DoseUnit]
   Heap 10, gPRNheapID, "vol/dse", Format$(L.finalvolume), 0                                 '[Vol/Dse]
   Heap 10, gPRNheapID, "numdse", Format$(doses%), 0

   Heap 10, gPRNheapID, "hospitalname", hospname1$ & " " & hospname2$, 0                     '[hospitalname]
   Heap 10, gPRNheapID, "ward", trimz(pid.ward), 0                                           '[ward]
   Heap 10, gPRNheapID, "cons", trimz(pid.cons), 0                                           '[cons]
   Heap 10, gPRNheapID, "dob", trimz(pid.dob), 0                                             '[dob]
   'SQL Moved below Heap 10, gPRNheapID, "batchnumber", m_batchnumber$, 0                                     '[batchnumber]
   Heap 10, gPRNheapID, "worksheet", wrks$, 0                                                '[worksheet]
   Heap 10, gPRNheapID, "totalcostExVAT", Format$(totalcostExVAT!, "########.00"), 0         '[totalcostExVAT]
   Heap 10, gPRNheapID, "totalcost", Format$(totalCost!, "########.00"), 0                   '[totalcost]
   
   Heap 10, gPRNheapID, "preparationdate", Trim$(WorkingDate$), 0                            '[preparationdate]   '12Jan07 PJC Added (enh77351)
   Heap 10, gPRNheapID, "preparationtime", Trim$(WorkingTime$), 0                            '[preparationtime]   '12Jan07 PJC Added (enh77351)
   
   '[authorised]
   ''tmp$ = GetField(FormulaTable.Fields("Authorised")) & " " & GetField(FormulaTable.Fields("Authorised_Date"))
   tmp$ = GetField(rsFormula.Fields("Authorised")) & " " & GetField(rsFormula.Fields("Authorised_Date"))
   Heap 10, gPRNheapID, "Authorised", tmp$, 0
   
   '26Aug09 TH Added new printable elements
   
   'If GetSecondAuthorisation() Then
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "CIVAS2ndAuth", 0)) Then '26Mar10 TH Replace to ensure used for patient specific stuff (F0079148)
   
      '09Oct09 TH Completed print heap elements and enhanced to handle old data too (as much as possible) (F0065893)
      
      Heap 10, gPRNheapID, "FormulaVersion", GetField(rsFormula.Fields("VersionNumber")), 0
      If RtrimGetField(rsFormula!EntityID_Drafted) > 0 Then                              '    "
         tmp$ = "Saved by " & RtrimGetField(rsFormula.Fields("Draft_Initials")) & " on " & Format$(GetField(rsFormula.Fields("DateDrafted")), "dd/mm/yyyy HH:NN")
      Else                                                                                '    "
         tmp$ = "Saved by " & RtrimGetField(rsFormula!Authorised) & " on " & RtrimGetField(rsFormula!Authorised_Date)
      End If
      'tmp$ = "Saved by " & RtrimGetField(rsFormula.Fields("Draft_Initials")) & " on " & Format$(GetField(rsFormula.Fields("DateDrafted")), "dd/mm/yyyy HH:NN")
      Heap 10, gPRNheapID, "FSavedby", tmp$, 0
      If RtrimGetField(rsFormula!EntityID_Approved) > 0 Then
         tmp$ = "Approved by " & RtrimGetField(rsFormula.Fields("Approved_Initials")) & " on " & Format$(GetField(rsFormula.Fields("DateApproved")), "dd/mm/yyyy HH:NN")
      Else
         tmp$ = "Approved by " & RtrimGetField(rsFormula!Authorised2)
      End If
      Heap 10, gPRNheapID, "FApprovedby", tmp$, 0
      
      'Layout to come Here !!!!1
      Heap 10, gPRNheapID, "WorksheetVersion", GetField(rsLayout.Fields("VersionNumber")), 0
      If RtrimGetField(rsLayout!EntityID_Drafted) > 0 Then
         tmp$ = "Saved by " & RtrimGetField(rsLayout.Fields("Draft_Initials")) & " on " & Format$(GetField(rsLayout.Fields("DateDrafted")), "dd/mm/yyyy HH:NN")
      Else
         tmp$ = ""
      End If
      Heap 10, gPRNheapID, "WSavedby", tmp$, 0
      If RtrimGetField(rsLayout!EntityID_Approved) > 0 Then
         tmp$ = "Approved by " & RtrimGetField(rsLayout.Fields("Approved_Initials")) & " on " & Format$(GetField(rsLayout.Fields("DateApproved")), "dd/mm/yyyy HH:NN")
      Else
         tmp$ = ""
      End If
      Heap 10, gPRNheapID, "WApprovedby", tmp$, 0
   End If
   
   '[patientdetails]
   buildname pid, False, PatientName$
   tmp$ = PatientName$ & " " & Trim$(pid.caseno)
   Heap 10, gPRNheapID, "patientdetails", tmp$, 0
   On Error Resume Next
   
   '05May15 TH Sometimes we seem to be here with no drug in scope - yet this is pat manufacturing using a genuine formulation (not pat specific) (TFS 120401)
   '           so we may need to reload the drug at this point. this needs to be the global d structure as its is referenced when calculating the
   '           the expiry for the manufacturing form (TFS)
   If (d.productstockID = 0) And (Val(Left$(RtrimGetField(rsFormula.Fields("NSVcode")), 1)) = 0) Then
      d.SisCode = GetField(rsFormula.Fields("NSVcode"))
      getdrug d, 0, 0, False
   End If
   '05May15 TH --------
   
   ManIssue.lblPatientName.FontName = terminal$("MsgBoxFontName", "")
   ManIssue.lblPatientName.FontSize = Val(terminal$("MsgBoxFontSize", ""))
   ManIssue.lblPatientName.FontSize = 12
   
   On Error GoTo 0
   If asciiz$(tmp$) <> "" Then
      ManIssue.lblPatientName.Caption = tmp$
   Else
      ManIssue.LblPatient.Visible = False
      ManIssue.lblPatientName.Caption = ""
   End If

   '''SQL Removed for now'[PatientNotes]
   '''tmp$ = trimz$(pidNotes.notes)
   '''replace tmp$, cr & lf, " \par ", 0
   '''Heap 10, gPRNheapID, "patientnotes", tmp$, 0
   
   '[description]
   'tmp$ = Trim$(d.Description) & "  "   XN 4Jun15 98073 New local stores description
   tmp$ = Trim$(d.LabelDescription) & "  "
   DescConvfact! = Val(d.convfact)
   Heap 10, gPRNheapID, "drugdescription", tmp$, 0
   plingparse tmp$, "!"
   ''If GetField(FormulaTable.Fields("DosingUnits")) Then
   If GetField(rsFormula.Fields("DosingUnits")) Then
         tmp2$ = Format$(dp!((Qty! * d.dosesperissueunit) / Val(d.convfact)), "#######.###")                                  '19May00 AW Added
         tmp$ = tmp$ & Format$((tmp2$)) & Trim$(d.DosingUnits) & " x" & Str$(doses%) & " dose" & plural$((doses%))  '16Aug06 TH Added trim on dosingunits
      Else
         tmp2$ = Format$(dp!(Qty! / Val(d.convfact)), "#######.###")                                           '         "
         'tmp$ = tmp$ & Format$((tmp2$)) & d.DosingUnits & " x" & Str$(doses%) & " dose" & plural$((doses%))
         tmp$ = tmp$ & Format$((tmp2$)) & " x " & Trim$(d.convfact) & " " & LCase$(d.PrintformV)     '28Jul99 AE replaces above
      End If
   'Qty! = dp!(Qty!)  '14Feb03 TH/CKJ Added to restore previous functionality   '17Feb03 moved below
   Heap 10, gPRNheapID, "description", tmp$, 0
   ManIssue.LblDrugName.FontSize = 12
   ManIssue.LblDrugName.Caption = tmp$
   strDrugName = tmp$ '04Dec12 TH Added
   
   Heap 10, gPRNheapID, "dose", Format$(tmp2$), 0        '[Dose]
   Heap 10, gPRNheapID, "ProductNSV", Trim$(d.SisCode), 0   '17May04 TH Added (#74372)
   strIVContainer = d.IVcontainer '03Dec12 TH Added

   '[method]
   'If Not IsNull(FormulaTable.Fields("Method")) Then
         ''tmp$ = GetField(FormulaTable.Fields("Method"))
   tmp$ = GetField(rsFormula.Fields("Method"))
   If tmp$ <> "" Then
         If getaccesslevel() = 9 Or getaccesslevel() = 8 Then '14Sep15 TH We always get the latest draft method when in the draft or approval desktop (TFS 129553)
            tmp$ = dispdata$ & "\wksheets\draft\" & tmp$
         Else
            tmp$ = dispdata$ & "\wksheets\" & tmp$
         End If
         Heap 10, gPRNheapID, "method", "[#include" & TB & tmp$ & "]", 0
   Else                                                                  '28Jul99 AE Added to ensure methods
         Heap 10, gPRNheapID, "method", "", 0                            'do not persist on the heap
   End If
     ' End If

   '[label]
   tmp$ = ""                                                                   '15dec00 CKJ blank temp before reuse
   ''If Not IsNull(FormulaTable.Fields("Label")) Then
   If Not IsNull(rsFormula.Fields("Label")) Then
      tmp$ = rsFormula.Fields("Label")
      
      '17Jul17 TH Added block below (port from v8.9) (TFS 189065)
      If TrueFalse(TxtD$(dispdata$ & "\PATMED.INI", "manufacturing", "N", "RemoveRTFLabelCRLFs", 0)) Then   '12Jan07 PJC Added block removing all crlf from the rft style Label if configured.  (SC-06-0471 #70868)
        If InStr(tmp$, "{\rtf1\ansi\") = 1 Then                                                      '     "
           replace tmp$, crlf, "", 0                                                              '     "
        End If                                                                                    '     "
      End If
      '17Jul17 TH ------
      
   End If
   replace tmp$, "{" & Chr$(13) & Chr$(10) & "\par}", "{\par}", 0  '22Jan01 TH Remove additional blank lines
   replace tmp$, Chr$(13) & Chr$(10), " \par ", 0
   '15dec00 CKJ Line removed as it should be in the layout and does not match the 'label' on the worksheet
   'tmp$ = tmp$ & " \par " & plvl$("DoNotUseAfter") & batchexpiry$ & "  " & batchnumber$      '12Jul99 CFY Changed /par to \par
   Heap 10, gPRNheapID, "label", tmp$, 0
   '17Feb03 TH Moved block further below
   '07Feb03 TH Added block toput stdlbl10A on heap to ensure batchnumber and expiry are on the label element on the worksheet
   'This is a 100% FRIG necessitated by sites using this LABEL element on the worksheet. Since the reversal of the
   'label / worksheet printing process this has led to these elements not being put on the heap at the time of the
   'worksheet print. This code is to enable just this one element. Note that this code will have to be maintained independently
   'of the original source (the label printing routines). It is not nice.
   'strStdLbl10AFrig = ""
   'If Len(batchexpiry$) > 0 Then
   '      strStdLbl10AFrig = plvl$("DoNotUseAfter") & batchexpiry$
   '      If m_batchnumber$ <> "" Then
   '            strStdLbl10AFrig = strStdLbl10AFrig & " " & Trim$(TxtD$(dispdata$ & "\PATMED.INI", "", "", "BNOnLabel", found))
   '            strStdLbl10AFrig = strStdLbl10AFrig & m_batchnumber$
   '         End If
   '   End If
   'If (InStr(plvl$("PrintBatchNumber"), l.IssType) > 0) Or (InStr(plvl$("PrintRxNumOnLabel"), l.IssType) > 0) Then
   '      If Len(strStdLbl10AFrig) + Len(Format$(l.prescriptionid)) > 35 Then
   '            strTmp = " " & Format$(l.prescriptionid)
   '         Else
   '            strTmp = " No." & Format$(l.prescriptionid)
   '            If (InStr(plvl$("PrintRxNumonLabel"), l.IssType) > 0) And l.batchnumber > 0 Then
   '                  strTmp = strTmp & "/" & Format$(l.batchnumber)
   '               End If
   '         End If
   '      strStdLbl10AFrig = strStdLbl10AFrig & tmp$
   '   End If
   'Heap 10, gPRNHeapID, "stdlbl10A", strStdLbl10AFrig, 0
   '07Feb03 TH End Block ------------------------------
   
   '[Formula]
   char$ = ""
   FBatchnumber$ = m_batchnumber$
''   StringToDate Left$(batchexpiry$, 10), CalcExp                  'dd/mm/ccyy hh:mm
''   If InStr(batchexpiry$, ":") > 2 Then                           '20Sep96 CKJ Added IF...
''         StringToTime Mid$(batchexpiry$, InStr(batchexpiry$, ":") - 2, 5), CalcExp
''         datetomins CalcExp
''         End If
   char$ = " \par " & "[BoldOn]Description" & " \tab " & "Quantity" & " \tab \tab Batch number Expiry[BoldOff] \par "
   ParseCtrlChars dispdata$ & "\printer.ini", "RTF", char$, Changed
   Index = 1
   IngType$ = "VFTXYZ"                          'variable fixed or batch fixed
   LSet dlcl = d '10Dec12 TH cache for later (TFS 35629)
   GoSub CheckIssueSection                      'Do Issue Checks
   Qty! = dp!(Qty!) '17Feb03 TH Moved here to avoid rounding problems in ingredient processes
   If Not k.escd Then
         If ward$ <> "¬" Then
               If m_blnNoIssue Then ManIssue.Caption = "Manufacturing (NO ISSUE WILL TAKE PLACE)"  '01Oct02 TH Added to make clear
               ManIssue.IssueGrid_FetchRow
               ManIssue.IssueGrid_RowChange 1
               If Not TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "AllowPrepDateEdit", 0)) Then ManIssue.Frame1.Enabled = False '27May08 TH added (F0017809)
               
               ManIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
               '30Nov12 TH Here we may need to record stuff for syring label management
               m_syringestoLabel = 0
               
               'If UCase$(strIVContainer) = "S" And extemp Then '04Dec12 TH Added extemp as this is for Patient specific manufacturing ONLY
               If UCase$(strIVContainer) = "S" And extemp And (Not k.escd) Then '04Dec12 TH Added extemp as this is for Patient specific manufacturing ONLY
                  'If SyringeContainerMax() < CIVASDoseIncStat(L.dose(1)) Then
                  If ((SyringeContainerMax() < L.finalvolume) And (SyringeContainerMax() > 0)) Then '06Dec12 TH (TFS) use vol for syringe check AND dont use syring management if no syringes set up
                  
                     Unload FrmManuSyringes '22May16 TH unload the form to ensure no values can be cached
                     
                     'Patient details
                     FrmManuSyringes.lblPatientName.Caption = Trim$(pid.forename) & " " & Trim$(pid.surname)
                     FrmManuSyringes.lblNHNumber.Caption = OCXheap("HealthCareNumber", "UNKNOWN")
                     FrmManuSyringes.lblNHNumberDesc.Caption = GetNHSNumberDisplayName() & "  :"
                     FrmManuSyringes.lblCaseno.Caption = pid.caseno
                     FrmManuSyringes.lblProduct.Caption = strDrugName
                     
                     If CIVASDoseIncStat(L.dose(1)) = Int(CIVASDoseIncStat(L.dose(1))) Then '24Feb10 TH (F78659) Now also foramt stat doses correctly.
                        strFormat = "#;0"
                     Else
                        strFormat = "0.##;0"
                     End If
                     strTemp = "Total each dose : " & Format$(CIVASDoseIncStat(L.dose(1)), strFormat) & " " & strForm & " in " & Strz$(L.finalvolume) & "ml"
                     FrmManuSyringes.lblTotal = strTemp
                     FrmManuSyringes.TotalDose.Caption = Format$(CIVASDoseIncStat(L.dose(1)))
                     FrmManuSyringes.TotalVolume.Caption = Strz$(L.finalvolume)
                     ''SyringeContainers True, CIVASDoseIncStat(L.dose(1)), L.finalvolume, FrmManuSyringes
                     FrmManuSyringes.Tag = "" '20Jun13 TH (TFS 66809) Now use tag handling to pick up user has OKed Values. For some reason cancel button code not being fully evoked.
                     FrmManuSyringes.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                     If FrmManuSyringes.Tag <> "OK" Then k.escd = True '20Jun13 TH (TFS66809)
                     'OK if we havent escaped then we will "scoop" the screen and save the dose and vol for labels
                     'Also the number of labels - this will be used later to refactor labels at point of printing
                     If Not k.escd Then
                        m_syringestoLabel = FrmManuSyringes.NumofSyringes.Caption
                        ReDim m_SyringeLabelDose(m_syringestoLabel)
                        ReDim m_SyringeLabelVolume(m_syringestoLabel)
                        For intloop = 1 To m_syringestoLabel
                           m_SyringeLabelDose(intloop) = CSng(FrmManuSyringes.lblDose(intloop - 1).Caption)
                           m_SyringeLabelVolume(intloop) = CSng(FrmManuSyringes.lblVol(intloop - 1).Caption)
                        Next
                        L.containersize = SyringeContainerMax()
                        'Redo the worksheet element
                        LSet d = dlcl
                        'MakeWorksheet wrks$, Format$(CIVASDoseIncStat(L.dose(1))), Strz$(L.finalvolume), m_syringestoLabel, m_SyringeLabelVolume(1), m_SyringeLabelVolume(m_syringestoLabel) '20Jun13 TH Added params
                        MakeWorksheet wrks$, Strz$(L.finalvolume), m_syringestoLabel, m_SyringeLabelVolume(1), m_SyringeLabelVolume(m_syringestoLabel) '22May14 TH Removed dosevol param (TFS 91489)
                        Heap 10, gPRNheapID, "worksheet", wrks$, 0
                     End If
                  Else
                     'We only need one syringe so lets work out what size and put the relevant details on the heap
                     L.containersize = SyringeContainerbyVolume(CSng(L.finalvolume))
                     'Redo the worksheet element
                     LSet d = dlcl
                     'MakeWorksheet wrks$, Format$(CIVASDoseIncStat(L.dose(1))), Strz$(L.finalvolume), m_syringestoLabel, "", "" '20Jun13 TH Added params
                     MakeWorksheet wrks$, Format$(CIVASDoseIncStat(L.dose(1))), m_syringestoLabel, "", ""  '22May14 TH Removed dosevol param (TFS 91489)
                     Heap 10, gPRNheapID, "worksheet", wrks$, 0
                  End If
               End If
               'If Val(ManIssue.Tag) Then k.escd = True     '24Feb99 SF added, cancel clicked '19Apr05 TH Removed - k should be set OK , dont want to reload form
               '18Apr05 TH Added block -  Here we get the manufacturing dat and time and get the expiry
               If Not k.escd Then
                  'Next 2 lines may be superfluous if handled correctly in the form
                  LSet d = dlcl                        '10Dec12 TH (TFS 35629)
                  FillHeapDrugInfo gPRNheapID, d, 0    '    "
                  getexpirydate batchexpiry$          '13Jun06 TH
                  If Trim$(batchexpiry$) = "" Then    '    "
                     MakeExpiry k, ManIssue.lblDate.Caption, ManIssue.lblTime.Caption, batchexpiry$
                     setexpirydate batchexpiry$
                  End If
                  StringToDate Left$(batchexpiry$, 10), CalcExp                  'dd/mm/ccyy hh:mm
                  If InStr(batchexpiry$, ":") > 2 Then                           '20Sep96 CKJ Added IF...
                     StringToTime Mid$(batchexpiry$, InStr(batchexpiry$, ":") - 2, 5), CalcExp
                     datetomins CalcExp
                  End If
                  If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "SessionPrepDate", 0)) Then
                     'Store dates here
                     SetSessionState "PreparationDate", ManIssue.lblDate.Caption
                     SetSessionState "PreparationTime", ManIssue.lblTime.Caption
                  End If
               End If
               'Also need batchnumber setting HERE !
               '-------------
               If Not k.escd Then
                  m_batchnumber$ = ManIssue.txtBatchNumber.text
                  FBatchnumber$ = m_batchnumber$ '21May08 TH Added (F0019305)
                  ManBlister.Batch = m_batchnumber$
                  GlobalManufBatchNum$ = m_batchnumber$
                  setbatchnum m_batchnumber$
               End If
               If Not k.escd Then
                  'Here we need to interpret how to proceed by interpreting the option box results (if any)
                  'Now we will set the correct flags
                  For count = 1 To 5
                     If ManIssue.Option1(count).Value Then strResult = Format$(count): Exit For
                  Next
                  Select Case strResult
                     Case ""
                        k.escd = True
'                        StrResult = "1"
                     Case "1": 'ans$ = "Y"
                     Case "2":
                        'ans$ = "Y"
                        'StrResult = "1"
                        m_blnLabelOnly = True
                     Case "3"
                        m_blnNoLabel = True
                        'ans$ = "Y"
                        m_blnNoIssue = True
                     Case "4"
                        'ans$ = "Y"
                        m_blnNoIssue = True
                        m_blnLabelOnly = True
                     Case "5"
                        'ans$ = "Y"
                        m_blnNoIssue = True
                  End Select
                  If InStr("345", strResult) > 0 Then
                     askwin "EMIS Health", "Please note that no stock will be issued. OK to continue Y/N", strAns, k
                     If strAns <> "Y" Then k.escd = True
                  End If
               End If
               '27May08 TH Added section (F0017809)
               If Not k.escd Then
                  Heap 10, gPRNheapID, "PrepDate", ManIssue.lblDate.Caption, 0
                  Heap 10, gPRNheapID, "PrepTime", ManIssue.lblTime.Caption, 0
                  Heap 10, gPRNheapID, "PrepDateTime", ManIssue.lblDate.Caption & " " & ManIssue.lblTime.Caption, 0
               End If
               '27May08 TH ----------
               Unload ManIssue
            End If
         If Not k.escd Then Heap 10, gPRNheapID, "batchnumber", m_batchnumber$, 0 '19Apr05 TH Moved From above
         If Not k.escd Then Heap 10, gPRNheapID, "batchnumber", m_batchnumber$, 0 '22May08 TH Added Trim (F0019305)
         If Not k.escd Then                     'Do Real Issue
               IngType$ = "VFT"                 'variable fixed or batch fixed
               GoSub PrintFormulaSection
               IngType$ = "XYZ"                 'consumable variable fixed or batch fixed
               GoSub PrintFormulaSection
            Else
               'WriteLog dispdata$ & "\escissue.log", 0, UserID$, d.Description & d.SisCode & d.stocklvl & "Escaped issue " & (pid.recno) & " " & ward$ & " " & (pid.cons)  XN 4Jun15 98073 New local stores description
                           WriteLog dispdata$ & "\escissue.log", 0, UserID$, d.LabelDescription & d.SisCode & d.stocklvl & "Escaped issue " & (pid.recno) & " " & ward$ & " " & (pid.cons)
            End If
      Else
         'WriteLog dispdata$ & "\escissue.log", 0, UserID$, d.Description & d.SisCode & d.stocklvl & "Escaped issue " & (pid.recno) & " " & ward$ & " " & (pid.cons)  XN 4Jun15 98073 New local stores description
                 WriteLog dispdata$ & "\escissue.log", 0, UserID$, d.LabelDescription & d.SisCode & d.stocklvl & "Escaped issue " & (pid.recno) & " " & ward$ & " " & (pid.cons)
      End If

   If Not k.escd Then   '24Feb99 SF added
      '24Feb99 SF moved following block of code into IF/ENDIF
      Heap 10, gPRNheapID, "formula", char$, 0                 '[formula]
   
      DateToString CalcExp, batchexpiry$
      TimeToString CalcExp, batchtimeexpiry$

      Heap 10, gPRNheapID, "expirydateonly", batchexpiry$, 0           '[expirydateonly]  '15Nov00 TH Added
      Heap 10, gPRNheapID, "expirytimeonly", batchtimeexpiry$, 0       '[expirytimeonly]  '    "

      batchexpiry$ = batchexpiry$ & " " & Left$(batchtimeexpiry$, 2) & ":" & Right$(batchtimeexpiry$, 2)
      char$ = char$ & " \par \par Batch expiry : " & batchexpiry$ & " \par "
      m_batchnumber$ = FBatchnumber$   '14Aug06 TH Replaced with below '21May08 TH Replaced as it should now be set correctly after the form has been shown (F0019305)
      'm_batchnumber$ = getbatchnum()      '           (DR-06-0590)
      
      'Heap 10, gPRNheapID, "batchnumber", m_batchnumber$, 0      '[batchnumber]
      Heap 10, gPRNheapID, "batchnumber", Trim$(m_batchnumber$), 0      '[batchnumber] '22May08 TH Added Trim (F0019305)
      Heap 11, gPRNheapID, "rxExpiry", strTmpExpiry, 0      '07Oct02 TH
      If strTmpExpiry <> "" Then                            '  "
         Heap 10, gPRNheapID, "expirydate", strTmpExpiry, 0 '  "
      Else                                                  '  "
         Heap 10, gPRNheapID, "expirydate", batchexpiry$, 0       '[expirydate]
      End If                                                '  "
      '17Feb03 TH Moved block from above and amended slightly to be able to use edited expiry
      '07Feb03 TH Added block toput stdlbl10A on heap to ensure batchnumber and expiry are on the label element on the worksheet
      'This is a 100% FRIG necessitated by sites using this LABEL element on the worksheet. Since the reversal of the
      'label / worksheet printing process this has led to these elements not being put on the heap at the time of the
      'worksheet print. This code is to enable just this one element. Note that this code will have to be maintained independently
      'of the original source (the label printing routines). It is not nice.
      strStdLbl10AFrig = ""
      Heap 11, gPRNheapID, "expirydate", strTmp, 0
      If Len(batchexpiry$) > 0 Then
         strStdLbl10AFrig = plvl$("DoNotUseAfter") & strTmp
         If m_batchnumber$ <> "" Then
            strStdLbl10AFrig = strStdLbl10AFrig & " " & Trim$(TxtD(dispdata$ & "\PATMED.INI", "", "", "BNOnLabel", found))
            'strStdLbl10AFrig = strStdLbl10AFrig & m_batchnumber$
            strStdLbl10AFrig = strStdLbl10AFrig & Trim$(m_batchnumber$) '22May08 TH Added trim (F0019305)
         End If
      End If
      If (InStr(plvl$("PrintBatchNumber"), L.IssType) > 0) Or (InStr(plvl$("PrintRxNumOnLabel"), L.IssType) > 0) Then
         If Len(strStdLbl10AFrig) + Len(Format$(L.PrescriptionID)) > 35 Then
            strTmp = " " & Format$(L.PrescriptionID)
         Else
            strTmp = " No." & Format$(L.PrescriptionID)
            If (InStr(plvl$("PrintRxNumonLabel"), L.IssType) > 0) And L.batchnumber > 0 Then
               strTmp = strTmp & "/" & Format$(L.batchnumber)
            End If
         End If
         strStdLbl10AFrig = strStdLbl10AFrig & tmp$
      End If
      Heap 10, gPRNheapID, "stdlbl10A", strStdLbl10AFrig, 0
      '07Feb03 TH End Block ------------------------------
      
      '19Mar10 TH Added (F0078677)
      strLabel = L.text
      ParseEndDirMarker strLabel, Chr$(LBL_END_DESC), Chr$(LBL_END_LINE), intSplitLine
      Heap 12, gPRNheapID, "LblDescRaw", "", 0
      strDesc = ""
      For intloop = 1 To 5
         If intloop <= intSplitLine Then
            strDesc = strDesc & labelline$(intloop) & Iff(Right$(labelline$(intloop), 1) = " ", "", " ")
         End If
      Next
      'Parse out the end of line characters for the raw text items, and replace with spaces
      replace strDesc, Chr$(LBL_END_LINE), " ", 0
      Heap 10, gPRNheapID, "LblDescRaw", strDesc, 0
      '----------------
      

      'Calculate expiry time in terms of hours
      today DateToday
      ExpiryTime& = CalcExp.mint - DateToday.mint
      ExpiryTime& = ExpiryTime& / 60
      'Heap 10, gPRNHeapID, "ExpHrs", Format$(ExpiryTime&), 0              '15Oct02 TH Added hours suffix to ExpHrs element (missed from merge of 01Oct02)
      Heap 10, gPRNheapID, "ExpHrs", Format$(ExpiryTime&) & " hours", 0
      
      '08Oct09 TH Read These backout (F0062376)
      Heap 11, gPRNheapID, "PrepDate", WorkingDate$, 0
      Heap 11, gPRNheapID, "PrepTime", WorkingTime$, 0

      '05Aug09 TH Now require expiry from prep date, not just from today.'26Aug09 TH Ported from v8 (F0054335)
      StringToDate WorkingDate$, prepdate
      StringToTime WorkingTime$, prepdate
      datetomins prepdate
      ExpiryTimePrep& = CalcExp.mint - prepdate.mint
      ExpiryTimePrepHours& = ExpiryTimePrep& / 60
      'Round Down
      If ExpiryTimePrep& Mod 60 > 0 Then
            ExpiryTimePrepHours& = ExpiryTimePrepHours& - 1
         End If
      Heap 10, gPRNheapID, "ExpHrsPrep", Format$(ExpiryTimePrepHours&) & " hours", 0
      '-------
      Heap 11, gPRNheapID, "preparationdate", Trim$(WorkingDate$), 0                            '[preparationdate]   '12Jan07 PJC Added (enh77351)
      Heap 11, gPRNheapID, "preparationtime", Trim$(WorkingTime$), 0                            '[preparationtime]   '12Jan07 PJC Added (enh77351)

   End If            '24Feb99 SF added

   If k.escd Then       '24Feb99 SF added
      escd% = True   '24Feb99 SF added
   Else              '24Feb99 SF added
      escd% = False  '24Feb99 SF added
   End If            '24Feb99 SF added

Exit Sub


'====================================================================================================================


'21Nov97 CFY Added the following section
CheckIssueSection:
   For X = 1 To 15
      IssueSummary(Index).SisCode = ""                '23Feb98 CKJ Moved from end of loop
      text$ = ""
      Errors$ = ""
      FirstVial = 0                                   '06Sep99 CFY Added
      'IngredientType$ = GetField(FormulaTable.Fields("type" & LTrim$(Str$(X))))
      IngredientType$ = GetField(rsFormula.Fields("type" & LTrim$(Str$(X))))
      ''If Not IsNull(FormulaTable.Fields("code" & LTrim$(Str$(X)))) Then
      If (Not IsNull(rsFormula.Fields("code" & LTrim$(Str$(X))))) And (Trim$(rsFormula.Fields("code" & LTrim$(Str$(X)))) <> "") Then
         ''d.SisCode = GetField(FormulaTable.Fields("code" & LTrim$(Str$(X))))
         d.SisCode = GetField(rsFormula.Fields("code" & LTrim$(Str$(X))))
         text$ = text$ & d.SisCode & "  "
         LSet dkeep = d
         getdrug d, 0, lngDrugPtr, False
         If lngDrugPtr Then
            If d.dosesperissueunit <= 0 Then '17Jul00 JN Added trap to stop Overflow error when issuing
               drug$ = RTrim$(d.LabelDescription)  'drug$ = RTrim$(d.Description)  XN 4Jun15 98073 New local stores description
               plingparse drug$, "!"
               Emsg% = MessageBox("Warning: " & drug$ & " is not set up correctly." & cr & "Doses Per Issue Unit are set to 0." & cr & "Please set up this item correctly before continuing.", 48, "")
            End If
            drug$ = d.LabelDescription  'drug$ = d.Description XN 4Jun15 98073 New local stores description
            plingparse drug$, "!"
            text$ = text$ & RTrim$(drug$)
         Else
            ''Text$ = Text$ & GetField(FormulaTable.Fields("d" & LTrim$(Str$(X))))
            text$ = text$ & GetField(rsFormula.Fields("d" & LTrim$(Str$(X))))
            strNSVCode = GetField(rsFormula.Fields("code" & LTrim$(Str$(X))))
            LSet d = dkeep
            d.SisCode = strNSVCode '11Dec07 TH Tweak to get it to work as per v8
            'd.Description = "*** " + d.SisCode + " not found in drug file ***" XN 4Jun15 98073 New local stores description
                        d.LabelDescription = "*** " + d.SisCode + " not found in drug file ***"
         End If
                  
         ''formulaqty! = GetField(FormulaTable.Fields("qty" & LTrim$(Str$(X))))
         formulaqty! = GetField(rsFormula.Fields("qty" & LTrim$(Str$(X))))
         ''If GetField(FormulaTable.Fields("DosingUnits")) Then
         If GetField(rsFormula.Fields("DosingUnits")) Then
            If d.mgPerml <= 0 Then
               d.mgPerml = 1
            End If
            If d.dosesperissueunit <= 0 Then
               Errors$ = "DATA ERROR. 'Doses per Issue' contains invalid value."
            Else
               formulaqty! = dp!(formulaqty! / d.dosesperissueunit)
            End If
         Else
            d.mgPerml = 1
         End If

         Select Case IngredientType$
            Case "F", "X" 'fixed
               formulaqty! = formulaqty! * (Int(Qty! + 0.999999))
            Case "Z"      'batch fixed
            Case "T"      'to
               formulaqty! = formulaqty! * (Int(Qty! / DescConvfact! + 0.999999)) '30Aug98 ASC
            Case Else     'Y V variable                      '20Jan98 CKJ/CFY reinstated
               formulaqty! = (formulaqty! * Qty!) / DescConvfact! '25Aug97
         End Select
               
         If d.mgPerml <= 0 Then
            Errors$ = Errors$ & "DATA ERROR. 'mg per ml' contains invalid value."
         End If

         If ward$ <> "" Then
            ''If GetField(FormulaTable.Fields("DosingUnits")) Then
            If GetField(rsFormula.Fields("DosingUnits")) Then
               If d.dosesperissueunit >= 0 Then
                  'temp! = dp!(formulaqty! * d.dosesperissueunit)  '23Feb98 ASC/CKJ dp! added. Temp! typically would be in mg       '04Jun99 CFY Removed
                  dosesperissueunit = d.dosesperissueunit     '04Jun99 CFY Added - Store these values for display purposes.
                  DosingUnits$ = Trim$(d.DosingUnits)          '        "                           "
                  PrintformV$ = Trim$(d.PrintformV)            '        "                           "

                  drug$ = d.SisCode                                                          'may be ASCcode instead
                  If Trim$(drug$) = "" Then                                    '09Aug05 TH Added
                     popmessagecr "!", "No Matches for " & strNSVCode    '    "
                  Else                                                  '    "
                     'findrdrug drug$, False, d, 0, found, False, False                                '04Jun99 CFY Added  - Multiply by
                     findrdrug drug$, True, d, 0, found, False, False, False     '12Nov10 TH Allow stores only items as ingredients (where allowed pre RCNP0158, but stores only changes have made these unfindable)
                     '11Dec07 TH Moved from above
''                     dosesperissueunit% = d.dosesperissueunit     '04Jun99 CFY Added - Store these values for display purposes.
''                     DosingUnits$ = Trim$(d.DosingUnits)          '        "                           "
''                     PrintformV$ = Trim$(d.PrintformV)
                     '---------------------------
                     If drug$ <> d.SisCode Then                                                 '         "         - doses if this is a
                        AmountToIssue! = dp!(formulaqty! * dosesperissueunit) * doses%      '         "         - multiple strength issue.
                        If FirstVial = 0 Then FirstVial = 1
                     Else                                                                    '         "
                        AmountToIssue! = dp!(formulaqty! * dosesperissueunit)               '         "
                     End If                                                                  '         "
                     StillToIssue! = AmountToIssue!                                             '         "
                     k.escd = False                                  '23Feb98 CKJ Added
                     qtyans$ = ""                                    '24Feb98 CFY Added
                     Do
                        'findrdrug drug$, False, d, 0, found, False  '04Jun99 CFY Removed
                        k.escd = False                               '24Feb98 ASC/CFY
                        If found Then                                '13Feb98 CFY Added
                           If drug$ <> d.SisCode Then
                              'Confirm "Multiple strengths available", " to issue some of the " & Str$(Temp!) & d.DosingUnits & " from this preparation", ans$, k
                              desc$ = Trim$(d.LabelDescription) 'desc$ = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
                              plingparse desc$, "!"
                              msg$ = "Multiple strengths available." & crlf & crlf
                              'msg$ = msg$ & "Do you wish to issue some of the remaining " & Str$(StillToIssue!) & DosingUnits$ & crlf         '24May04 TH Replaced - use the dosing units of the product selected
                              msg$ = msg$ & "Do you wish to issue some of the remaining " & Str$(StillToIssue!) & Trim$(d.DosingUnits) & crlf  '           NOT possibly the last one (if the item is selected here) (#71589)
                              msg$ = msg$ & "using the preparation : " & desc$
                              askwin "!EMIS Health", msg$, ans$, k
                              If ans$ = "N" Then k.escd = True '24Feb98 ASC/CFY
                              If Not k.escd Then
                                 'inputwin "Issue " & d.description, "Enter number of " & d.PrintformV & " to issue from this preparation", qtyans$, k
                                 msg$ = "Issuing " & desc$ & crlf & crlf
                                 msg$ = msg$ & "Total amount to issue : " & Format$(AmountToIssue!) & d.DosingUnits & crlf          '04Aug99 CFY uses d.dosingunits no dosingunit$
                                 msg$ = msg$ & "Amount remaining : " & Format$(StillToIssue!) & d.DosingUnits & crlf & crlf         '      "
                                 msg$ = msg$ & "Enter number of " & d.PrintformV & "(s) to issue"                                   '04Aug99 CFY uses d.printfomrv no printformv$
                                 InputWin "EMIS Health", msg$, qtyans$, k
                              End If
                           End If
                        Else
                           k.escd = True                          '13Feb98 CFY Added
                        End If
                                 
                        If Not k.escd Then
                           text$ = d.LabelDescription   'text$ = d.Description XN 4Jun15 98073 New local stores description
                           plingparse text$, "!"                                          '        "
                           'Text$ = d.SisCode & " " & Text$ & RTrim$(drug$)                '        "
                           text$ = d.SisCode & " " & text$ '& RTrim$(drug$)  '27Oct06 TH Removed the extraneous desc
                           If Trim$(qtyans$) <> "" Then                                                                                      '24Feb98 CFY Added
                              Issued! = dp!(Val(qtyans$))                                                                                 'to calculate how
                           Else                                                                                                           'much left to issue
                              If d.dosesperissueunit > 0 Then '17Jul00 JN added check to prevent Overflow error
                                 Issued! = dp!(StillToIssue! / d.dosesperissueunit) * doses% '27Jun97 KR added * Doses% to deal with more than one
                              Else
                                 Issued! = dp!(0) * doses% '17Jul00 JN basically dummied a value here to prevent error
                              End If
                           End If
                           StillToIssue! = dp!(StillToIssue! - (Val(qtyans$) * d.dosesperissueunit))
                           'If extemp Then                                                '04Jun99 CFY Removed
                           '      DoChkIssue Issued!, d, l.IssType, Errors$               '         "
                           '      IssueSummary(Index).IssType = l.IssType                 '         "
                           '   Else
                           DoChkIssue Issued!, d, "M", Errors$
                           IssueSummary(Index).IssType = "M"
                           '   End If                                                     '         "
                           
                           IssueSummary(Index).Qty = Issued!      '23Feb98 CKJ Added
                           '06Jun03 TH Added Section  (#68678)
                           'If ((truefalse(TxtD$(dispdata$ & "\PATMED.INI", "", "", "CIVASIngredientRound", 0))) And (UCase$(d.issueWholePack) = "Y")) And (CInt(IssueSummary(Index).Qty) <> IssueSummary(Index).Qty) Then
                           If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "CIVASIngredientRound", 0)) And (UCase$(d.issueWholePack) = "Y") Then    '19Jun03 TH Various alterations after second check
                              'If IssueSummary(Index).Qty - CInt(IssueSummary(Index).Qty) > 0 Then                                                      '    "
                              If IssueSummary(Index).Qty - Fix(IssueSummary(Index).Qty) > 0.000001 Then                                                 '    "
                                 'IssueSummary(Index).Qty = CInt(IssueSummary(Index).Qty) + 1                                                        '    "
                                 IssueSummary(Index).Qty = Fix(IssueSummary(Index).Qty) + 1                                                          '    "
                              Else
                                 IssueSummary(Index).Qty = CInt(IssueSummary(Index).Qty)                                                             '    "
                                 'IssueSummary(Index).Qty = Fix(IssueSummary(Index).Qty)                                                             '    "
                              End If
                           End If
                           '----------------
                           Heap 10, gPRNheapID, "issued" & Format$(Index), Strz$(IssueSummary(Index).Qty), 0       '[issued] (in issue units)
                           Heap 10, gPRNheapID, "iunits" & Format$(Index), d.PrintformV, 0                         '[iunits]
                           GoSub FillIssueSummary                 '23Feb98 CKJ Added
                           'If StillToIssue! > .0001 Then findrdrug drug$, False, d, 0, found, False         '04Jun99 CFY Added
                           If StillToIssue! > 0.0001 And drug$ <> d.SisCode Then
                              findrdrug drug$, False, d, 0, found, False, False, False '01Oct02 TH Replaced above
                           End If
                        End If
                                    
                     Loop While drug$ <> d.SisCode And Not k.escd And StillToIssue! > 0.0001 '24Feb98 CFY loops until full amount has been fulfilled
                  End If '09Aug05 TH Added
               End If
            Else
               DoChkIssue formulaqty! * doses%, d, "M", Errors$
               IssueSummary(Index).IssType = "M"
               IssueSummary(Index).Qty = formulaqty! * doses%        '23Feb98 CKJ moved from below
               '06Jun03 TH Added Section (#68678)
               'If ((truefalse(txtd(dispdata$ & "\PATMED.INI", "", "", "CIVASIngredientRound", 0))) And (UCase$(d.issueWholePack) = "Y")) And (CInt(IssueSummary(Index).Qty) <> IssueSummary(Index).Qty) Then
               If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "CIVASIngredientRound", 0)) And (UCase$(d.issueWholePack) = "Y") Then    '19Jun03 TH Various alterations after second check
                  'If IssueSummary(Index).Qty - CInt(IssueSummary(Index).Qty) > 0 Then                                                      '    "
                  If IssueSummary(Index).Qty - Fix(IssueSummary(Index).Qty) > 0.000001 Then                                                 '    "
                     'IssueSummary(Index).Qty = CInt(IssueSummary(Index).Qty) + 1                                                        '    "
                     IssueSummary(Index).Qty = Fix(IssueSummary(Index).Qty) + 1                                                          '    "
                  Else
                     IssueSummary(Index).Qty = CInt(IssueSummary(Index).Qty)                                                             '    "
                     'IssueSummary(Index).Qty = Fix(IssueSummary(Index).Qty)                                                             '    "
                  End If
               End If
               '----------------
               Heap 10, gPRNheapID, "issued" & Format$(Index), Strz$(IssueSummary(Index).Qty), 0       '[issued] (in issue units)
               Heap 10, gPRNheapID, "iunits" & Format$(Index), d.PrintformV, 0                         '[iunits]
               GoSub FillIssueSummary                                '23Feb98 CKJ Added
            End If
         End If
      End If
      
      If k.escd Then Exit For

   Next

Return

FillIssueSummary:
   IssueSummary(Index).desc = text$
   IssueSummary(Index).Unit = d.PrintformV
   IssueSummary(Index).Error = Errors$
   IssueSummary(Index).SisCode = d.SisCode
   IssueSummary(Index).barcode = d.barcode
   IssueSummary(Index).IngType = IngredientType$
   If FirstVial <= 1 Then
      IssueSummary(Index).DBPosn = X
      If FirstVial = 1 Then FirstVial = 2
   Else
      IssueSummary(Index).DBPosn = 99
   End If
      
   Index = Index + 1
Return


PrintFormulaSection:
'05Jun00 JN Added - get pointer if not extemp
If Not extemp Then
''   If gcivasbatch = "" Then gcivasbatch = CStr(GetBatchPointer("CIVASbatch.dat")) 'if this is being allocated, gcivasbatch should be blank - ignore this line if it isn't
   If gcivasbatch = "" Then
      ''GetPointerSQL dispdata$ & "/CIVASbat.dat", lngPtr, True
      GetPointerSQL dispdata$ & "\CIVASbat.dat", lngPtr, True '05May05 TH surely / aint right ?
      gcivasbatch = Format$(lngPtr)
   End If
Else
   gcivasbatch = ""
   End If
   For X = 1 To (Index - 1)
      IngredientType$ = IssueSummary(X).IngType
      If InStr(IngType$, IngredientType$) > 0 And IngredientType$ <> "" Then
         If Not lineprinted And IngType$ = "XYZ" Then
            char$ = char$ & "Consumables used \par "
            lineprinted = True
         End If
         If Trim$(IssueSummary(X).SisCode) <> "" Then
            d.SisCode = IssueSummary(X).SisCode
            getdrug d, 0, lngDrugPtr, 0
            Heap 10, gPRNheapID, "ItemCode" & Format$(X), d.SisCode, 0                     '[ItemNSVCode]
            Heap 10, gPRNheapID, "supcode" & Format$(X), Trim$(d.supcode), 0              '[supcode]                                 '[supcode]
            Heap 10, gPRNheapID, "tradename" & Format$(X), Trim$(d.tradename), 0   '31Oct00 TH Added Tradename
            getsupplier d.supcode, 0, FoundSup, sup
            If FoundSup <> 0 Then
               Heap 10, gPRNheapID, "supname" & Format$(X), sup.name, 0                '[supname]
            Else
               Heap 10, gPRNheapID, "supname" & Format$(X), "** not found **", 0
            End If
            If lngDrugPtr Then
               drug$ = d.LabelDescription       'drug$ = d.Description  XN 4Jun15 98073 New local stores description
               plingparse drug$, "!"
               tmp$ = RTrim$(drug$)
               char$ = char$ & RTrim$(drug$) & " \tab "
            Else
               tmp$ = tmp$ & IssueSummary(X).desc
               char$ = char$ & IssueSummary(X).desc & " \tab "
            End If
            Heap 10, gPRNheapID, "ItemDesc" & Format$(X), tmp$, 0       '[ItemDesc]

            If IssueSummary(X).DBPosn <> 99 Then                        '06Sep99 CFY Added
               ''formulaqty! = GetField(FormulaTable.Fields("qty" & Format$(IssueSummary(X).DBPosn))) 'qty in dosing or issue units 26sep96 ASC added getfield '24Feb98 CFY removed '06Jun98 CFY Reinstated
               formulaqty! = GetField(rsFormula.Fields("qty" & Format$(IssueSummary(X).DBPosn))) 'qty in dosing or issue units 26sep96 ASC added getfield '24Feb98 CFY removed '06Jun98 CFY Reinstated
               DisplayQty = True                                     '06Sep99 CFY Added
            Else                                                     '         "
               DisplayQty = False                                    '         "
               formulaqty! = 0                                       '         "
            End If                                                   '         "
                     
            ''If GetField(FormulaTable.Fields("DosingUnits")) Then
            If GetField(rsFormula.Fields("DosingUnits")) Then
               If d.mgPerml > 0 Then
                  punits$ = "ml"
               Else
                  punits$ = LCase$(d.DosingUnits)
                  d.mgPerml = 1
               End If
               If d.dosesperissueunit > 0 Then
                  formulaqty! = dp!(formulaqty! / d.dosesperissueunit)
               End If
            Else
               'Dispensing units
               punits$ = LCase$(d.PrintformV)
               d.mgPerml = 1
            End If
                  
            If Not DisplayQty Then punits$ = "   "                        '06Sep99 CFY Added
            Heap 10, gPRNheapID, "dunits" & Format$(X), punits$, 0       '[dunits]

            Select Case IngredientType$
               Case "F", "X" 'fixed
                  formulaqty! = formulaqty! * (Int(Qty! + 0.999999))
               Case "Z"      'batch fixed
               Case "T"      'to
                  char$ = char$ & "To " & " \tab "
               Case Else     'Y V variable
                  'formulaqty! = (formulaqty! * Qty!) / DescConvfact!         '13Jan00 CFY Replaced
                  formulaqty! = dp!(formulaqty! * Qty!) / DescConvfact!       '         "
            End Select

            If Not DisplayQty Then                                 '06Sep99 CFY Added
               char$ = char$ & "     \tab"                      '         "
               tmp$ = "   "                                     '         "
               strTmpTotPck = "   "       '22Feb02 TH Added (enh1372)
               strTmprTotPck = "   "      '    "
            Else                                                '         "
               If d.mgPerml > 0 Then
                  ''If GetField(FormulaTable.Fields("DosingUnits")) Then
                  If GetField(rsFormula.Fields("DosingUnits")) Then
                     tmp$ = FormatVal(Format$(formulaqty! * d.dosesperissueunit / d.mgPerml), 2, 7)      '24May00 AE added FormatVal to round quantity
                     StrItem4Qty = FormatVal(Format$(formulaqty! * d.dosesperissueunit / d.mgPerml), 4, 9)  '17May04 TH Added (#74372)
                     char$ = char$ & " " & Format$(tmp$) & " \tab "
                  Else
                     tmp$ = FormatVal(Format$(formulaqty! / d.mgPerml), 2, 7)                            '24May00 AE added FormatVal to round quantity
                     StrItem4Qty = FormatVal(Format$(formulaqty! / d.mgPerml), 4, 9)                        '17May04 TH Added (#74372)
                     char$ = char$ & " " & Format$(tmp$) & " \tab "
                  End If
               End If

               '22Feb02 TH Added block (enh1372)
               If Val(d.convfact) > 0 Then
                  strTmpTotPck = FormatVal(Format$(formulaqty! / Val(d.convfact)), 2, 7)
                  If Int(Val(strTmpTotPck)) <> Val(strTmpTotPck) Then
                        strTmprTotPck = Format$(Int(Val(strTmpTotPck)) + 1)
                     Else
                        strTmprTotPck = Format$(Int(Val(strTmpTotPck)))
                     End If
               Else
                  strTmpTotPck = "   "
                  strTmprTotPck = "   "
               End If
               '------------------------

            End If
                        
            Heap 10, gPRNheapID, "ItemQty" & Format$(X), tmp$, 0       '[ItemQty]
            Heap 10, gPRNheapID, "Item4Qty" & Format$(X), StrItem4Qty, 0       '[Item4Qty]  '17May04 TH Added (#74372)

            Heap 10, gPRNheapID, "TotalPacks" & Format$(X), strTmpTotPck, 0       '22Feb02 TH Added block (enh1372)
            Heap 10, gPRNheapID, "rTotalPacks" & Format$(X), strTmprTotPck, 0
            'issue stock from stocklvl and batch qtys
            If ward$ <> "" Then                                         'print preview to screen or printer
               d.SisCode = IssueSummary(X).SisCode
               getdrug d, 0, 0, False
               Issued! = dp!(IssueSummary(X).Qty)
               Heap 10, gPRNheapID, "issued" & Format$(X), Strz$(Issued!), 0     '16Jul13 TH Put the actual issued qty on the heap (TFS 69172)
               If m_batchnumber$ > "" Then setbatchnum m_batchnumber$ '14Jun00 JN store batch number in translog
               m_batchnumber$ = ""    '13Jun98 ASC without this when 0 issue the previous values are retained
               batchexpiry$ = ""      '    "
               If Issued! = 0 Then            '13Mar00 AW added Checks to see if issued dose has been changed to 0
                       formulaqty! = 0        'needed to correct issue price of formula.
                       IssueCost$ = ""
                   End If
               If extemp Then    'is extemp set?
                  'DoIssue k, Issued!, d, userid$, (pid.recno), l.dircode, False, (pid.status), (pid.ward), (pid.cons), sitenumber, l.IssType, issuecost$, batchnumber$, batchexpiry$     '21Nov97 CFY      '04Jun99 CFY Replaced
                  DoIssue Issued!, d, UserID$, (pid.recno), L.dircode, False, "M", ward$, "", SiteNumber, L.IssType, IssueCost$, m_batchnumber$, batchexpiry$, extemp    '21Nov97 CFY                             '         "
               Else
                  DoIssue Issued!, d, UserID$, "", "", False, "M", ward$, "", SiteNumber, "M", IssueCost$, m_batchnumber$, batchexpiry$, extemp                                                                '28Jan98 CFY Added  /ASC checked
               End If                                                                                                                                                                                          '13Feb98 CFY

               If m_batchnumber$ = "" Then
                  m_batchnumber$ = "_____________"
                  batchexpiry$ = "__________"       '!!** WHAT HAPPENS WHEN BATCHEXPIRY IS MECHANICALLY PROCESSED?
               Else
                  StringToDate Left$(batchexpiry$, 10), dt
                  If InStr(batchexpiry$, ":") > 2 Then
                     StringToTime Mid$(batchexpiry$, InStr(batchexpiry$, ":") - 2, 5), dt
                     datetomins dt
                  End If
                  If dt.mint > 0 And dt.mint < CalcExp.mint Then
                     LSet CalcExp = dt  '25Sep96 CKJ Added check for zero
                     '13Jun06 TH OK so now we need to over-right the main expiry date for the product
                     setexpirydate batchexpiry$  'This should set the product expiry for the worksheet
                  End If
               End If
               char$ = char$ & punits$ & " \TAB " & m_batchnumber$ & " " & batchexpiry$ & " \tab "
            Else
               char$ = char$ & punits$ & " \TAB " & "XXXXXXXXX" & " " & date$ & " \tab "
            End If
                  
            'Heap 10, gPRNheapID, "ibatchno" & Format$(X), m_batchnumber$, 0   '[ibatchno]
            Heap 10, gPRNheapID, "ibatchno" & Format$(X), m_batchnumber$, 0   '[ibatchno] '22May08 TH Added Trim (F0019305)
            Heap 10, gPRNheapID, "iexpiry" & Format$(X), batchexpiry$, 0      '[iexpiry]
            
            '17Feb98 CFY added
''            If frmFormula.ChkBlisterPack.Value Then
''               If Not packed Then
''                  Select Case Left$(Trim$(UCase$(d.PrintformV)), 3)
''                     Case "TAB", "CAP":
''                        deflines d.Description, desclines$(), "!", 0, 0
''                        ManBlister.drug = desclines$(0)
''                        ManBlister.Strength = desclines$(1)
''                        packed = True
''                   End Select
''               End If
''            End If
                  
            lines$(0) = ""  '23Oct00 TH Important to clear previous cost (for 0 qty ingredient issues !)
            lines$(1) = ""
            deflines IssueCost$, lines$(), "|", 0, 0
            totalCost! = totalCost! + Val(lines$(0))
            totalcostExVAT! = totalcostExVAT! + Val(lines$(1))
            '------
            'If Not IsNull(HFtable.Fields("Linetext")) Then                   '19Nov98 CFY removed for now
            If Not IsNull(rsLayout.Fields("Linetext")) And rsLayout.RecordCount > 0 Then
               'tmp$ = (HFtable.Fields("Linetext"))
               tmp$ = (rsLayout.Fields("Linetext"))
               char$ = char$ & tmp$ & " \par "
            Else
               tmp$ = ""
               char$ = char$ & " \par "
            End If
            Heap 10, gPRNheapID, "iLineText" & Format$(X), tmp$, 0         '[LineText]
            
            ' 20Apr17 XN 182077 new fiels in manufacutire printing
            Heap 10, gPRNheapID, "Userfield1_" & Format$(X), d.UserField1, 0
            Heap 10, gPRNheapID, "Userfield2_" & Format$(X), d.UserField2, 0
            Heap 10, gPRNheapID, "Userfield3_" & Format$(X), d.UserField3, 0
            
            tmp$ = d.storesdescription
            plingparse tmp$, "!"
            Heap 10, gPRNheapID, "Storesdesc" & Format$(X), Trim$(tmp$), 0
            
            tmp$ = d.DrugDescription
            plingparse tmp$, "!"
            Heap 10, gPRNheapID, "Gendesc" & Format$(X), Trim$(tmp$), 0
            
            Heap 10, gPRNheapID, "SupTradeName" & Format$(X), Trim$(d.SupplierTradeName), 0
            
            Heap 10, gPRNheapID, "LabelDescriptionInPatient" & Format$(X), Trim$(d.LabelDescriptionInPatient), 0
            Heap 10, gPRNheapID, "LabelDescriptionOutPatient" & Format$(X), Trim$(d.LabelDescriptionOutPatient), 0
            Heap 10, gPRNheapID, "LocalDescription" & Format$(X), Trim$(d.LocalDescription), 0
            ' End of 182077 new fiels in manufacutire printing
         End If
      End If
      
      'FormulaTable.Index = "NSVcode"
      'FormulaTable.Seek "=", dcop.siscode '**!! why is this needed loss of position in formula table seems to be caused by issue
   
   Next

Return


End Sub

Sub PrintLabelsFromDispens(strExpiry As String)
'01Oct02 TH Written

Dim strNumoflabs As String

   k.nums = True
   k.Max = 3
   InputWin "Label printer", "Enter number of labels to print", strNumoflabs, k

   If Int(Val(strNumoflabs)) > 0 Then DisplaytheLabel Int(Val(strNumoflabs)), 3, k, strExpiry, 0, False

End Sub

Sub PrintManWorksheet(frmPrint As Form, preview, Qty!, doses%, extemp%, ward$, totalCost!, totalcostExVAT!, PIDdetails$, batchexpiry$, wrks$, PatsPerSheet%, Layout$, WorkingDate$, WorkingTime$, escd%, ByRef rsFormula As ADODB.Recordset)
'xxNov CFY rewritten
'24Feb99 SF added and sets escd% parameter
'05May99 CFY Modified worksheet preview facility so that worksheets are previewed to screen not to printer
'28Jul99 AE  corrected logic of If Statment
'03Sep99 AE / CY Added line to search for patient specific formula before drug specific one.
'14Jul00 JN  Added form instance reference
'24Jan02 TH  Added a switch to stop wrksheet printing when user requests no wrksheet (#43808)
'04Mar02 TH  Added Parameter to Reprint call (#MOJ#)
'15Apr02 TH  Added after testing to ensure is reset if no wrksheet required (#43808)
'01Oct02 TH  Added extra flag to denote no worksheet (m_blnLabelOnly)
'01Oct02 TH  Added clauses to stop worksheet calcs on issue if no issue and no wrksheet print required
'17May04 TH  Add mod to ensure correct batch expiry details available on worksheet (#72672)
'26Aug09 TH  Ported : '12Jan07 PJC Added imput arguments workingdate$, workingtime$ to the call to ParseFormulaData (enh77351).
'02Mar10 TH  Stop worksheet print for label only run (selected from manufacturing issue screen) (F0079144)

Static PatientsPrinted%

Dim Changed%
Dim dcop As DrugParameters
Dim filename$
Dim OutFile$            '05May99 CFY Added
Dim blnPrintwrksheet As Integer  '24Jan02 TH Added as switch to stop wrksheets printing (#43808)
Dim strTmpExpiry As String   '17May04 TH Added
Dim strParams As String
Dim rsLayout As ADODB.Recordset


   'Find formula for this NSVcode or patient
   blnPrintwrksheet = True                  '24Jan02 TH Added as switch to stop wrksheet printing (#43808)
   If m_blnLabelOnly Then                  '19Sep02 TH Added             '01Oct02 TH Added
      blnPrintwrksheet = False
   ElseIf m_batchnumber$ = Chr$(160) Then
      m_batchnumber$ = ""
      blnPrintwrksheet = False
   End If

   ''OpenFormulaDatabase
   If Trim$(d.SisCode) <> "" Then
''         FormulaTable.Index = "NSVcode"
''         'FormulaTable.Seek "=", d.SisCode                              '03Sep99 AE / CY removed
''         FormulaTable.Seek "=", L.prescriptionid                        'first search for patient specific...'?????99 AE /CY Added
''         If FormulaTable.NoMatch Then FormulaTable.Seek "=", d.SisCode  '...then for master formula
      LSet dcop = d
''
   End If

   ''If FormulaTable.NoMatch Then
   If rsFormula.RecordCount < 1 Then
      popmessagecr "!", "Formula for " & LTrim$(d.SisCode) & "Not found"
   Else
''         Set HFtable = dbFormula.OpenTable("Layout")
''         HFtable.Index = "Name"
''         HFtable.Seek "=", Layout$
      If Layout$ = "" Then
         popmessagecr "!", "No Layout associated with this Formula"
      Else
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, Layout$)
      Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteandName", strParams)

      If PatientsPrinted = 0 Then InitialiseHeapItems

      If PatsPerSheet% <> 0 Then
         If Qty! = 0 Then Qty! = 1
         'ParseFormulaData Qty!, doses%, extemp%, ward$, changed, totalCost!, totalcostExVAT!, batchexpiry$, wrks$         '24Feb99 SF replaced
         If (Not m_blnNoIssue Or blnPrintwrksheet) Then                 '01Oct02 TH Added clauses
            'ParseFormulaData frmPrint, Qty!, doses%, extemp%, ward$, Changed, totalCost!, totalcostExVAT!, batchexpiry$, wrks$, escd%, rsFormula, rsLayout  '24Feb99 SF '12Jan07 PJC Replaced by call below including  workingdate$, workingtime$ (enh77351)
            ParseFormulaData frmPrint, Qty!, doses%, extemp%, ward$, Changed, totalCost!, totalcostExVAT!, batchexpiry$, wrks$, WorkingDate$, WorkingTime$, escd%, rsFormula, rsLayout  '24Feb99 SF    '12Jan07 PJC Added (enh77351)
            If m_blnLabelOnly Then blnPrintwrksheet = False  '02Mar10 TH Added (F0079144) Stop worksheet print for label only run (selected from manufacturing issue screen)
         Else
            'Heap 10, gPRNheapID, "batchnumber", m_batchnumber$, 0
            Heap 10, gPRNheapID, "batchnumber", Trim$(m_batchnumber$), 0 '22May08 TH Added Trim (F0019305)
            '17May04 TH Add the batch expiry here (#72672)
            Heap 11, gPRNheapID, "rxExpiry", strTmpExpiry, 0      '07Oct02 TH
            If strTmpExpiry <> "" Then                            '  "
               Heap 10, gPRNheapID, "expirydate", strTmpExpiry, 0 '  "
            Else                                                  '  "
               Heap 10, gPRNheapID, "expirydate", batchexpiry$, 0       '[expirydate]
            End If                                                '  "
            m_batchnumber$ = ""
            batchexpiry$ = ""    '    "
         End If
         If Not escd% Then  '24Feb99 SF added
            '24Feb99 SF moved following code into IF/ENDIF
            PatientsPrinted% = PatientsPrinted% + 1
            StoreandTotal PatientsPrinted%
         End If          '24Feb99 SF added
      End If

      'Check if we need to print
      'If (PatientsPrinted% = PatsPerSheet% And PatsPerSheet% > 0) Or (PatsPerSheet% = 0 And PatientsPrinted > 0) Then                 '24Feb99 SF replaced
      'If Not escd% And ((PatientsPrinted% = PatsPerSheet% And PatsPerSheet% > 0) Or (PatsPerSheet% = 0 And PatientsPrinted > 0)) Then  '24Feb99 SF  '28Jul99 AE replaced with below
      'If Not escd% And (((PatientsPrinted% = PatsPerSheet%) And (PatsPerSheet% > 0)) Or (PatsPerSheet% = 0 And PatientsPrinted > 0)) Then  '28Jul99 AE
      If blnPrintwrksheet Then          '01Oct02 TH
         If Not escd% And blnPrintwrksheet And (((PatientsPrinted% = PatsPerSheet%) And (PatsPerSheet% > 0)) Or (PatsPerSheet% = 0 And PatientsPrinted > 0)) Then '24Jan02 TH (#43808)
            ''If HFtable.NoMatch Then
            If rsLayout.RecordCount < 1 Then
               popmessagecr "!", "Layout " & Layout$ & " not found."
            Else
               'filename$ = dispdata$ & "\wksheets\" & GetField(HFtable!Layout)
               filename$ = dispdata$ & "\wksheets\" & GetField(rsLayout!Layout)
               StoreandTotal 0
               If preview Then                                                '05May99 CFY Added
                  'parseRTF filename$, OutFile$                             '        "
                  parseRTFfromDB filename$, OutFile$ '04Jan17 TH Now Parse the DB version of the rtf (Hosted
                  If OutFile$ <> "" Then                                   '        "
                     Hedit 12, OutFile$                'preview it      '        "
                  End If                                                '        "
               Else
                  'ParseThenPrint "ManWkSheet", filename$, 1, 0
                  'ParseThenPrint "ManWkSheet", filename$, 1, 0, True  '27May11 TH Added param (F0088129)
                  ParseThenPrint "ManWkSheet", filename$, 1, 0, True, False '04Jan17 TH Use DB Parsing (Hosted)
                  ReprintFile 2, 1, 0, 0   '04Mar02 TH Added Parameter  (#MOJ#)
               End If
               PatientsPrinted% = 0
            End If
         End If
      End If
      If Not blnPrintwrksheet Then PatientsPrinted% = 0  '15Apr02 TH Added after testing to ensure is reset if no wrksheet required (#43808)

      On Error Resume Next
      'HFtable.Close
      'Set HFtable = Nothing
      rsLayout.Close
      Set rsLayout = Nothing
      On Error GoTo 0
      End If
   End If

   LSet d = dcop

End Sub

Sub PrintWorkLabel(frmWkLabel As Form, doses%, WorkingDate$, WorkingTime$, expiry$, formulafound%, PatsPerSheet%, Layout$, escd%, o_blnFormulaHandled As Integer, ByVal blnNonManufacturingIssue As Boolean)
'25Aug96 ASC Now prints true worksheet using manufacturing module if fullsheet is true
'15Dec96 ASC Puts details of worklabel as [worksheet] onto the layout of the full worksheet
'20Jun97 KR  Now prints prescription id on label.
'16Jan98 CKJ Added RTF support. Context is 'WorkLabel', file is 'WorkLbl.rtf',
'            items are 'StdLbl1A' to 'StdLbl10A' plus any standard ones
'26Jun98 CFY Now only prints the extra blank line if the civas item has no formula attached.
'20Jul98 EAC added patient and drug details to print heap for HK mods
'14Sep98 TH  Changed formats of dose$ and dosevol$
'24Sep98 TH  Changed various formats
'13Nov98 EAC HK mod to display full Hospital Number on the labels
'19Nov98 CFY Add PatsPerSheet and layout to parameter list
'24Feb99 SF  added and sets escd% parameter
'24Aug00 JN  Checks Pharmacc is turned off before incrementing l.batchnumber
'14Jul00 JN  Added form instance reference
'20Nov00 SF/CFY moved logic to increment batchnumber to Dispens.frm: txtprompt_keyup
'13Nov02 CKJ Added param o_blnFormulaHandled which is set True if IssueAndPrintFormula is called, and is false
'            if no suitable formula is found or if the old style rtf work label is used instead.
'14Feb03 TH/CKJ Removed dp! on Qty param of IssueAndPrintFormula as this means rounding further down is no longer
'               workable (as the precision has already been reduced) and rounding errors are introduced.
'04Oct09 TH Change message for new second checking functionality (F0065043)

Dim X%, lineno%, lastline$, dosevol!, lastdose!, dosevols$, dose$, desc$, wrks$, contname$, tmp$ '02Dec96 ASC
Dim count%
Dim TempCaseNo$, success%                 '13Nov98 EAC Added
Dim rsFormula As ADODB.Recordset
Dim sglDose As Single '26May05 TH Added
Dim intSlash As Integer '19Jun08 TH
   
   o_blnFormulaHandled = False            '13Nov02 CKJ
''   doRTF = (UCase$(terminal$("PatmedLblLPTtype", "")) = "RTF") '16Jan98 CKJ Added

   '20Jul98 EAC added for HK mods
''   If doRTF Then
   FillHeapDrugInfo gPRNheapID, d, 0
   FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
''      End If

   For X = 1 To 6
      lastdose! = dosevol!
      If L.dose(X) > 0 Then
         If d.dosesperissueunit > 0 Then
            dosevol! = (L.dose(X) / d.dosesperissueunit) * (L.ReconVol + d.DisplacementVolume)
         End If
      End If
      If dosevol! > 0 And lastdose! > 0 And lastdose! <> dosevol! Then
         MsgBox "Unequal doses not yet supported", 0, ""
         dosevol! = 0
      End If
   Next

   'For count = 1 To 10                                                                         '19Nov98 CFY
   '   Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "A", "", 0      'clear out the heap     '26Nov98
   '   Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "B", "", 0                              '26Nov98
   'Next

   '13Nov98 EAC HK mod to display full Hospital Number on the labels
   'lastline$ = Left$((LTrim$(RTrim$(PID.forename) + " " + RTrim$(PID.surname)) + " (" + RTrim$(PID.ward) + " " + RTrim$(PID.cons) + " " + RTrim$(PID.caseno) + ")" + Space$(36)), 36)
   TempCaseNo = pid.caseno
''   If OCXlaunch() Then Heap 11, gPRNheapID, "OCXHospNum", TempCaseNo$, success%
   lastline$ = Left$((LTrim$(RTrim$(pid.forename) + " " + RTrim$(pid.surname)) + " (" + RTrim$(pid.ward) + " " + RTrim$(pid.cons) + " " + RTrim$(TempCaseNo$) + ")" + Space$(36)), 36)

   d.SisCode = L.SisCode
   dosevols$ = Format$(dosevol!, "###0.##")  '24Sep98 TH Reinstated
   'dosevols$ = Format$(dosevol!) '14Sep98 TH Changed
   dosevols$ = Format$(dosevols$) '24Sep98 TH Changed

   dose$ = Format$(L.dose(1), "###0.##") '15Dec96 was a StrZ$
   'dose$ = Format$(l.dose(1))  '14Sep98 TH Changed
   dose$ = Format$(dose$)       '24Sep98 TH Changed

   'If Not doRTF Then printl "", 3, 1, "", k.escd                                             '1   '26Jun98 CFY moved inside 'If Not formulafound Then' condition
   
   desc$ = d.LabelDescription   'desc$ = d.Description
   plingparse desc$, "!"
   escd% = False     '24Feb99 SF added
   If d.dosesperissueunit > 0 Then 'ASC 13Sep96
      Set rsFormula = New ADODB.Recordset
      getformula formulafound, rsFormula '15Dec96 section moved here from Issue and print to allow work sheet details to be passed to issue and print
      ''formulafound = ProductHasFormula()
      ''Hasformula formulafound
      If formulafound Then
         MakeWorksheet wrks$, dose$, 0, "", "" '23Dec12 TH Added Param '20Jun13 TH Added params '22May14 TH Removed Dosevol param (TFS 91489)
         'If UCase$(Trim$(d.civas)) = "Y" Then            '26May05 TH Added
            'sglDose = (l.dose(1) / d.dosesperissueunit)
            '19Jun08 TH REplaced stat dose check with new function
            sglDose = (CIVASDoseIncStat(L.dose(1)) / d.dosesperissueunit)
            '19Jun08 TH
            'If l.dose(1) = 0 And (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
            '   'If stat derive a dose from the direction code
            '   intSlash = InStr(txtUC("TxtDircode").text, "/")
            '   If intSlash > 0 Then
            '      sglDose! = (Val(Left$(txtUC("TxtDircode").text, intSlash - 1)) / d.dosesperissueunit)
            '   End If
            'End If
            '--------------
            
         'Else                                            '    "
         '   sglDose = doses%                             '    "
         'End If                                          '    "
         
         'IssueAndPrintFormula d, True, (dp!(l.dose(1) / d.dosesperissueunit)), doses%, lastline$, workingdate$, workingtime$, Expiry$, wrks$, PatsPerSheet%, Layout$  '19Nov98 CFY added PatsPerSheet% and Layout to parameter list '24Feb99 SF replaced
         'IssueAndPrintFormula frmWkLabel, d, True, (dp!(l.dose(1) / d.dosesperissueunit)), doses%, lastline$, workingdate$, workingtime$, EXPIRY$, wrks$, PatsPerSheet%, layout$, escd%   '24Feb99 SF  '14Feb03 TH/CKJ Replaced
         'IssueAndPrintFormula frmWkLabel, d, True, (L.dose(1) / d.dosesperissueunit), doses%, lastline$, WorkingDate$, WorkingTime$, expiry$, wrks$, PatsPerSheet%, Layout$, escd%, rsFormula                     '    "
         IssueAndPrintFormula frmWkLabel, d, True, sglDose, doses%, lastline$, WorkingDate$, WorkingTime$, expiry$, wrks$, PatsPerSheet%, Layout$, escd%, rsFormula                     '    "
         o_blnFormulaHandled = True            '13Nov02 CKJ
      Else
         '04Oct09 TH Change message for new second checking functionality (F0065043)
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVAS2ndAuth", 0)) Then
            popmessagecr "!", "No approved copy of the formula for " & Trim$(desc$) & " is available. Please contact the system manager or approver"
         Else
            popmessagecr "!", "Full worksheet and formula for " & Trim$(desc$) & " not found"
         End If
      End If
   End If

   If Not formulafound And Not escd% Then
      For count = 1 To 11                                                                       '19Nov98 CFY
         Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "A", "", 0      'clear out the heap   '
         Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "B", "", 0                            '
      Next

''         If Not doRTF Then printl "", 3, 1, "", k.escd                               '1            '26Jun98 CFY
      Heap 10, gPRNheapID, "StdLbl2A", desc$, 0                                   '2
''         If Not doRTF Then printl desc$, 5, 1, "", k.escd                            '2
      lineno = 2
   
      If L.ReconVol > 0 Then
         tmp$ = "Use " + Strz$(L.ReconVol) + "ml of " + L.ReconAbbr + " to"
''               If doRTF Then
         Heap 10, gPRNheapID, "StdLbl3A", tmp$, 0                        '3
         Heap 10, gPRNheapID, "StdLbl4A", "reconstitute.", 0             '4
         Heap 10, gPRNheapID, "StdLbl5A", "Then take", 0                 '5
''                  Else
''                     printl tmp$, 3, 1, "", k.escd                                   '3
''                     printl "reconstitute.", 3, 1, "", k.escd                        '4
''                     printl "Then take", 3, 1, "", k.escd                            '5
''                  End If
         lineno = lineno + 3
      Else
         Heap 10, gPRNheapID, "StdLbl3A", "Take", 0                            '3
''               If Not doRTF Then printl "Take", 3, 1, "", k.escd                     '3
         lineno = lineno + 1
      End If
         
      tmp$ = dosevols$ & "ml ( = " & dose$ & RTrim$(d.DosingUnits) & ")"
   ''         If Not doRTF Then printl tmp$, 3, 1, "", k.escd                             '4/6
      lineno = lineno + 1
      Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0              '4/6
   
      If RTrim$(L.DiluentAbbr) <> "" Then
         tmp$ = "and dilute to"
''               If Not doRTF Then printl tmp$, 3, 1, "", k.escd                       '5/7
         lineno = lineno + 1
         Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0        '5/7

         tmp$ = Strz$(L.finalvolume) + "ml with " + L.DiluentAbbr
''               If Not doRTF Then printl tmp$, 3, 1, "", k.escd                       '6/8
         lineno = lineno + 1
         Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0        '6/8
         'need to show how many ml to remove here
      End If
      ContainerName (L.containersize), L.Container, contname$
      
      tmp$ = "Send in a" + Str$(L.containersize) + "ml " + contname$
''         If Not doRTF Then printl tmp$, 3, 1, "", k.escd                             '7/9
      lineno = lineno + 1
      Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0              '7/9
      
      tmp$ = plvl$("CIVASwrktxt1")
''         If Not doRTF Then printl tmp$, 5, 1, "", k.escd                             '8/10
      lineno = lineno + 1
      Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0              '8/10
      
      tmp$ = plvl$("CIVASwrktxt2")
''         If Not doRTF Then printl tmp$, 5, 1, "", k.escd                             '9/11
      lineno = lineno + 1
      Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", tmp$, 0              '9/11
      
''         For X = lineno To 10              '9Jun95 CKJ was TO 9
''            If Not doRTF Then printl "", 3, 1, "", k.escd                            '...11
''         Next

      '20Nov00 SF/CFY moved logic to increment batchnumber to Dispens.frm: txtprompt_keyup
      'If TrueFalse(TxtH$(dispdata$ & "\patmed.ini", "patient billing", "N", "BillPatient", 0)) Then   '24Aug00 JN Added check to only increment if Pharmacc is turned off
      '      l.batchnumber = l.batchnumber + 1
      '   End If
      '20Nov00 SF/CFY -----
      lastline$ = lastline$ & LTrim$(Str$(L.PrescriptionID)) '20Jun97 KR
      'If l.batchnumber > 0 Then lastline$ = lastline$ & "/BN" & LTrim$(Str$(l.batchnumber)) '23Jun00 JN Commented out
      
''         If Not doRTF Then printl lastline$, 3, 9, "", k.escd                        '12
      lineno = lineno + 1
      Heap 10, gPRNheapID, "StdLbl" & Format$(lineno) & "A", lastline$, 0         '12

''         If doRTF Then
      'ParseThenPrint "WorkLabel", dispdata$ & "\WorkLbl.rtf", 1, 0, False  '27May11 TH Added param (F0088129)
      ParseThenPrint "WorkLabel", dispdata$ & "\WorkLbl.rtf", 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)
''            End If
   End If

End Sub

Sub PromptBatchNumber(blnFromRxManagement As Integer)
'04Jun99 CFY Written
'24Jan02 TH Added chr(160) in batchnumber as flag that no worksheet is required (#43808)
'01Oct02 TH Added new section to allow for all manner of possibilities (basically to allow for a frigging reprint!) (#63313)
'21Oct02 TH Added new blnFromRxManagement parameter to suppress option to cancel or not print
'           (in which case the pat details are posted to the caption of the batchnumer prompt input box)
'21Oct02 TH Added setting to allow default to be set on new multi option screen

Dim ans$, msg$, PatientName$
Dim strResult As String, strAns As String  '01Oct02 TH (#63313)
Dim strTemp As String '16Oct02 TH Added
Dim strDefault As String  '21Oct02 TH Added

m_blnNoLabel = False
m_blnNoIssue = False
m_blnLabelOnly = False

   If Not blnFromRxManagement Then     '21Oct02 TH Added
         '01Oct02 TH  Added new section (#63313)
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "N", "AllPossibilities", 0)) Then
''            msg$ = d.Description
''            plingparse msg$, "!"
''            buildname pid, False, PatientName$
''            k.escd = False
''            Do While StrResult <> "1" And Not k.escd
''
''               frmoptionset -1, "Manufacturing " & Trim$(msg$) & " for " & PatientName$
''               frmoptionset 1, "Print and Issue with Worksheet and Labels "
''               frmoptionset 1, "Print and Issue with Labels only "
''               frmoptionset 1, "Print Worksheet only (No issues) "
''               frmoptionset 1, "Print Labels only (No issues)"
''               frmoptionset 1, "Print Worksheet and Labels only (No issues)"
''               strDefault = txtd(dispdata$ & "\patmed.ini", "manufacturing", "1", "AllPossibilitiesDefault", 0) '21Oct02 TH Added to allow default to be set
''               frmoptionshow strDefault, StrResult                                                               '    "
''               frmoptionset 0, ""
''                  Select Case Trim$(StrResult)
''                     Case ""
''                        k.escd = True
''                        StrResult = "1"
''                     Case "1": ans$ = "Y"
''                     Case "2":
''                        ans$ = "Y"
''                        StrResult = "1"
''                        m_blnLabelOnly = True
''                     Case "3"
''                        m_blnNoLabel = True
''                        ans$ = "Y"
''                        m_blnNoIssue = True
''                     Case "4"
''                        ans$ = "Y"
''                        m_blnNoIssue = True
''                        m_blnLabelOnly = True
''                     Case "5"
''                        ans$ = "Y"
''                        m_blnNoIssue = True
''                  End Select
''               If InStr("345", StrResult) > 0 Then
''                  askwin "ASCribe", "Please note that no stock will be issued. OK to continue Y/N", strAns, k
''                  If strAns = "Y" Then StrResult = "1"
''               End If
''            Loop
''
            ans$ = "Y"
         Else
         '01Oct02 TH -------------
            ans$ = "Y"
''            msg$ = d.Description              '09Jul99 CFY Added
''            plingparse msg$, "!"              '         "
''            msg$ = msg$ & crlf & crlf & "OK print worksheet and allocate batch number"
''            buildname pid, False, PatientName$
''            If Len(trimz$(PatientName$)) <> 0 Then msg$ = msg$ & crlf & "for " & PatientName$
''            askwin "ASCribe", msg$, ans$, k
         End If  '01Oct02 TH Added
      Else               '21Oct02 TH Added
         ans$ = "Y"      '    "
      End If             '    "
   If ans$ = "Y" And Not k.escd Then
         m_batchnumber$ = "M"
         AllocateNewBatchNumber m_batchnumber$
''         If TrueFalse(txtd(dispdata$ & "\patmed.ini", "manufacturing", "N", "PromptBatchNum", 0)) Then
''               ans$ = m_batchnumber$
''               msg$ = "Enter Batch Number or Return to accept the default"
''''               If blnFromRxManagement Then          '21Oct02 TH Added
''''                     strTemp = ipdlist.Tag
''''                  Else
''                     strTemp = "ASCribe"
''''                  End If
''
''               'inputwin "ASCribe", msg$, ans$, k   '16Oct02 TH Replaced
''               inputwin strTemp, msg$, ans$, k
''               If Not k.escd Then
''                     m_batchnumber$ = ans$
''                  End If
''            End If
         ManBlister.Batch = m_batchnumber$
         GlobalManufBatchNum$ = m_batchnumber$
         setbatchnum m_batchnumber$
      'End If
      Else                          '24Jan02 TH Added as flag that no worksheet is required (#43808)
         m_batchnumber$ = Chr$(160) '    "
      End If                        '    "
End Sub

Sub PromptForWrkSht(ByRef WrkShtLayout As String, PatsPerSheet%, escd%)
'19Nov98 CFY Written
'This routine is used to decide which worksheet should be used when dealing with CIVAS items.
'When the routine has determined which worksheet should be used, the name is returned in
'WrkShtLayout$, along with the number of pateints that can be printed on the layout in PatsPerSheet%
'If more than 1 layout is associated with the item, the user is shown which worksheets are available
'and asked to decide which one to use.
'24Feb99 SF added and sets escd% parameter
'28Jul99 AE  Set k.escd if no layout defined


''Dim db As Database
''Dim Formula As table
''Dim Layout As table
Dim ans$, desc$
Dim PatsPerSheet1%, PatsPerSheet2%
Dim strParams As String
Dim rsFormula As ADODB.Recordset

   ReDim Menu$(3), menuhlp%(3)
   
   On Error GoTo PromptForWrkSht_Err
''   Set db = OpenDatabase(dispdata$ & "\formula.mdb")
''   Set Formula = db.OpenTable("formula")
''   Set Layout = db.OpenTable("layout")
''   If Trim$(d.SisCode) <> "" Then
''         Formula.Index = "NSVcode"
''         Formula.Seek "=", d.SisCode
''      End If
''   If Trim$(d.SisCode) <> "" Then
'                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Format$(L.prescriptionid)) '04Oct05 TH Replaced below

      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Format$(gRequestID_Prescription))
''               sql$ = "SELECT * FROM Formula WHERE NSVcode = """ & L.prescriptionid & """"
      Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
''   End If
   escd% = False     '24Feb99 SF added
   If rsFormula.EOF Then
      If Trim$(d.SisCode) <> "" Then
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
         Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
      End If
   End If
   If Not rsFormula.EOF Then
      If GetField(rsFormula!Layout) = "" And GetField(rsFormula!Layout2) = "" Then   'Both empty
            popmessagecr "!", "No layout defined for this worksheet"
            k.escd = True                                                  '28Jul99 AE Added
            escd = True
         End If
      
      'If GetField(Formula!Layout) <> "" And GetField(Formula!Layout2) <> "" Then 'Both filled
      If Not escd And (GetField(rsFormula!Layout) <> "" And GetField(rsFormula!Layout2) <> "") Then '28Jul99 AE added escd
            ans$ = "N"
            PatsPerSheet1% = GetPatsPerSheet(RtrimGetField(rsFormula!Layout))
            PatsPerSheet2% = GetPatsPerSheet(RtrimGetField(rsFormula!Layout2))
            desc$ = Trim$(d.LabelDescription)   'desc$ = Trim$(d.Description)
            plingparse desc$, "!"
            Menu$(0) = "Choose worksheet for : " & desc$
            Menu$(1) = RtrimGetField(rsFormula!Layout) & TB & "(" & Format$(PatsPerSheet1) & " patients per sheet)"
            Menu$(2) = RtrimGetField(rsFormula!Layout2) & TB & "(" & Format$(PatsPerSheet2) & " patients per sheet)"
            inputmenu Menu$(), menuhlp%(), ans$, k
            If Not k.escd Then
                  Select Case Val(ans$)
                     Case 1:
                        WrkShtLayout$ = GetField(rsFormula!Layout)
                     Case 2:
                        WrkShtLayout$ = GetField(rsFormula!Layout2)
                  End Select
               Else                                '24Feb99 SF added ELSE block
                  escd% = True                     '24Feb99 SF added
                  GoTo PromptForWrkSht_Exit:       '24Feb99 SF added
               End If
         End If
            
      If RtrimGetField(rsFormula!Layout) <> "" And RtrimGetField(rsFormula!Layout2) = "" Then 'Layout filled
            WrkShtLayout$ = RtrimGetField(rsFormula!Layout)
         End If
      
      If RtrimGetField(rsFormula!Layout) = "" And RtrimGetField(rsFormula!Layout2) <> "" Then 'Layout 2 filled
            WrkShtLayout$ = RtrimGetField(rsFormula!Layout2)
         End If
      
      If WrkShtLayout$ <> "" Then
            PatsPerSheet% = GetPatsPerSheet(WrkShtLayout$)
         End If
      
      End If

PromptForWrkSht_Exit:
   On Error Resume Next
''   Layout.Close
''   Set Layout = Nothing
''   Formula.Close
''   Set Formula = Nothing
''   db.Close
''   Set db = Nothing
   Set rsFormula = Nothing
   
   On Error GoTo 0
   Exit Sub
PromptForWrkSht_Err:
   
   GoTo PromptForWrkSht_Exit

End Sub

''Sub ResetHasFormulaFlag()
'''11Oct99 CKJ written
''
''Dim dTmp As DrugParameters
''Dim lngDrugFound As Long
''Dim lngNOD As Long
''Dim iIncrement As Integer
''Dim lngCount As Long
''
''   getnod lngNOD
''   Progress.lblInfo = "Clearing Formula Flag:" & crlf & crlf & "This allows product file to be" & crlf & "correctly synchronised with" & crlf & "the formula database."
''   Progress.Show 0
''   iIncrement = lngNOD \ 100
''   If iIncrement < 1 Then iIncrement = 1
''
''   For lngCount = 1 To lngNOD
''      If (lngCount Mod iIncrement) = 0 Then Progress.PerCent = 100& * lngNOD \ lngCount
''      cleardrug dTmp
''      getdrug dTmp, lngCount, lngDrugFound, True
''      If lngDrugFound Then
''            d.HasFormula = " "
''            putdrug dTmp, lngDrugFound
''         End If
''    Next
''
''End Sub

Sub ReturnCivasItem(success%)
'04Jun99 CFY Written
'15Feb13 XN  Removed dead code (40210)

Dim ans$, msg$
'Dim valid%
Dim strReturn As String

   ReDim Menu$(3), menuhlp%(3)
   success = False
   If gRequestID_Dispensing = 0 Then
      popmessagecr "CIVAS Return", "Please select an original dispensing to return against."
   Else
      strReturn = Left$(UCase$(TxtD(dispdata$ & "\patmed.ini", "CIVASReturn", "N", "ReturnOnly", 0)) & " ", 1)
      If strReturn = "P" Then
         CIVASTransactionRollBack True, False
      ElseIf strReturn = "I" Then
         CIVASTransactionRollBack False, False
      Else
         msg$ = "Returning CIVAS product"
         'parsedate L.lastdate, dat$, "3", valid%  40210 XN 15Feb13 Removed as not used
         
         Menu$(0) = "Return CIVAS Item"
         Menu$(1) = "Return manufactured product"
         Menu$(2) = "Return ingredients and undo manufacturing issue"
         inputmenu Menu$(), menuhlp%(), ans$, k
         
         If Not k.escd Then
            Select Case Val(ans$)
               Case 1:
                  'Ingredients have already been booked out and item made so just return the final product
                  'back on the shelf.
                  'Here we ask for possible partial return.
                  
                  CIVASTransactionRollBack True, False 'trimz(pid.recno), L.prescriptionid, d.SisCode, "", dat$, msg$, success%
               Case 2:
                  'Product has not been made so need to rollback all transactions.
                  CIVASTransactionRollBack False, False 'trimz(pid.recno), L.prescriptionid, "", "", dat$, msg$, success%
               End Select
         End If
      End If
      success% = True 'bubble this up !!!!!!!
   End If
   
End Sub

Sub SaveFormula(frmSave As Form)

'28Jul99 AE Written
'replaces various Datacontrol.RecordSet.Update calls.
'05Aug99 CKJ/AE Moved Section updating TableLayuot to after ds.update
'05Aug99 CKJ/AE removed Lockmode
'05Aug99 CKJ/AE Added Close prior to destroying recordsets
'05Aug99 CKJ/AE Mods to error handling
'03Sep99 AE  Fix to allow items to be removed from a formula
'11Oct99 CKJ Update d.HasFormula flag for d.siscode
'05Jan00 AE  Corrected above to use d.tmp
'13Jul00 JN  added counter to give 10 retries if db in use with another user
'14Jul00 JN  added frmSave parameter to refer to form instance
'09Feb17 TH  Ensure method replacement uses the DB RTF handling (Hosted) (TFS 176196)

Dim r$, SQL$ '', db As Database, ds As Dynaset
Dim n%, ThisCode$, ThisDesc$, ThisQty$, ThisType$
Dim ans$, i%, txt$
''Dim TblLayout As table,
Dim FormulaCode$
''Dim dTmp As DrugParameters
Dim lngDrugFound As Long
Dim intRetries As Integer
Dim lngWFormulaID As Long
Dim strParams As String
Dim rsFormula As ADODB.Recordset
Dim strCode(15) As String * 7
Dim strDescription(15) As String * 60
Dim dblQty(15) As Double
Dim strType(15) As String * 1
Dim strMethod As String
Dim dblTotalQty As Double
Dim lngResult As Long
Dim strLabel As String '24May06 TH Added
Dim dteDateApproved As Date '26Aug09 TH Added (F0054335)
Dim dteDateDrafted As Date '26Aug09 TH Added (F0054335)
Dim VersionNumber As Integer
Dim blnArchive As Boolean
Dim FormulaVersionNumber As Integer
Dim StrFormulaStatus As String
Dim EntityID_Drafted As Long
Dim EntityID_Approved As Long
Dim blnSetApproved As Boolean
Dim lngReturn As Long
Dim strReasonForApproval As String
Dim localkeys As kbdcontrol
Dim rsFormulaApproved As ADODB.Recordset
Dim strRTFText As String      '09Feb17 TH THese were in but somehow missed a merge ?
Dim lngOK As Long             '  "


   If FormulaViewMode = 0 Then         'view only. Should never get here, as no changes should be permitted
      r$ = "Cannot change formula.  It is either already issued, or" & cr$
      r$ = r$ & "you do not have sufficient authority to do so." & cr$
      r$ = r$ & "Please contact your system administrator."
      popmessagecr ".Manufacturing", r$

   Else
''      CloseFormulaDatabase                                       'prevent locking errors
      If frmSave.CmbLayout(0).text = "" Or frmSave.TxtPatsPerSheet(0).text = "" Then
         r$ = "Worksheets not chosen for this formula.  Save anyway ?"
         askwin "!Manufacturing", r$, ans$, k
         If ans$ <> "Y" Then k.escd = True
      End If

      If Not k.escd Then
''         Set db = OpenDatabase(dispdata$ & "\Formula.mdb")
      
         Select Case FormulaType            'indicates the formula from which the information was read
            Case PATIENT_FORMULA            'patient-specific; can save straight back to the current record.
               SQL$ = FormulaKey$
            
            Case MASTER_FORMULA             'Master formula; only allow saving with a high-level password from manufacturing
               Select Case FormulaViewMode
                  Case Is <= 2              '2 is dispensary mode; save as new patient-specific formula
                     ''sql$ = "SELECT * FROM Formula WHERE NSVcode = """ & L.prescriptionid & """"
                     'gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, L.prescriptionid)'04Oct05 TH Replaced with below
                     strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, gRequestID_Prescription)
                     Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                     If Not rsFormula Is Nothing Then     'use returned recordset
                        If rsFormula.State = adStateOpen Then
                           If rsFormula.RecordCount <> 0 Then
                              lngWFormulaID = RtrimGetField(rsFormula!WFormulaID)
                           End If
                        End If
                     End If
                     'FormulaCode = Format$(L.prescriptionid) '04Oct05 TH Replaced below
                     FormulaCode = Format$(gRequestID_Prescription)
                   Case 8 '26Aug09 TH Added
                     strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaKey$)
                     'Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                     Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCodeDraftandApproved", strParams) '26Aug09 TH Now we only Approve drafts
                     If Not rsFormula Is Nothing Then     'use returned recordset
                        If rsFormula.State = adStateOpen Then
                           If rsFormula.RecordCount <> 0 Then
                              lngWFormulaID = RtrimGetField(rsFormula!WFormulaID)
                           End If
                        End If
                     End If
                     FormulaCode = FormulaKey$ '20Jul05 TH Added, otherwise can never be found when saved !!
                                             '(ADD NEW)
                  Case 9                    'Manufacturing mode; full access. Can overwrite master file
                     ''SQL$ = FormulaKey$     '(EDIT)
                     strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaKey$)
                     'Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                     If GetSecondAuthorisation() Then   '04Feb10 TH use old method for none second auth (Glasgow) otherwise site cant edit formulae !
                        Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCodeDraft", strParams) '26Aug09 TH Now we only Approve drafts
                     Else
                        Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                     End If
                     If Not rsFormula Is Nothing Then     'use returned recordset
                        If rsFormula.State = adStateOpen Then
                           If rsFormula.RecordCount <> 0 Then
                              lngWFormulaID = RtrimGetField(rsFormula!WFormulaID)
                           End If
                        End If
                     End If
                     FormulaCode = FormulaKey$ '20Jul05 TH Added, otherwise can never be found when saved !!
                     'LockMode = 1           'Exclusively lock the database in this case     05Aug99 CKJ/AE removed
                  End Select
      
            Case NEW_FORMULA, NEW_PATIENTFORMULA               'Allowed from manufacturing, not from dispensing.
               ''If FormulaViewMode < 9 Then '06Jun05 TH Removed injunction
               ''   'popmessagecr ".Manufacturing", "Must use the Manufactuing module to add a new product."'simple message because should never get here
               ''   popmessagecr ".Manufacturing", "Must use the Manufacturing module to add a new product." 'simple message because should never get here '02Oct99 CKJ Corrected spelling
               ''Else
                  ''sql$ = "SELECT * FROM Formula WHERE NSVcode = """ & d.SisCode & """"
                  'gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, L.prescriptionid)  '04Oct05 TH Replaced with below

                  '''strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  '''            gTransport.CreateInputParameterXML("NSVCode", trnDataTypeint, 4, gRequestID_Prescription)
                  '''Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                  'LockMode = 8            'DB_APPENDONLY - addnew record, cannot edit    '05Aug99 CKJ/AE removed
                  If FormulaType = NEW_PATIENTFORMULA Then
                     'FormulaCode = L.prescriptionid '(ADD NEW)
                     FormulaCode = gRequestID_Prescription '(ADD NEW) '04Oct05 TH Replaced
                  Else
                     FormulaCode = frmSave.LblNSVcode '(ADD NEW)
                  End If
                  strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                              gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaCode)
                  Set rsFormula = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandNSVCode", strParams)
                  If Not rsFormula Is Nothing Then     'use returned recordset
                     If rsFormula.State = adStateOpen Then
                        If rsFormula.RecordCount <> 0 Then
                           lngWFormulaID = RtrimGetField(rsFormula!WFormulaID)
                        End If
                     End If
                  End If
               ''End If
            End Select
      
      'Add or edit the record
SaveFormulaGetLock:
         On Error GoTo WaitError
         'Set ds = db.CreateDynaset(SQL$, LockMode)                                          '05Aug99 CKJ/AE removed
''         Set ds = db.CreateDynaset(sql$)
         On Error GoTo 0
         ''If sql$ = FormulaKey$ Then
         blnSetApproved = False
         If lngWFormulaID > 0 Then
            ''rsFormula.Edit
            FormulaCode = RtrimGetField(rsFormula!NSVCode)
            strMethod = RtrimGetField(rsFormula!Method)
            dblTotalQty = RtrimGetField(rsFormula!totalQty)
            strLabel = rsFormula!label
            FormulaVersionNumber = rsFormula!VersionNumber
            StrFormulaStatus = rsFormula!Code
            EntityID_Drafted = rsFormula!EntityID_Drafted
            dteDateApproved = RtrimGetField(rsFormula!DateApproved)
            dteDateDrafted = RtrimGetField(rsFormula!DateDrafted)
            '26Aug09 TH Add new Audit and status fields here
            If Not M_blnFromDispensing Then
               If getaccesslevel() = 9 Then 'We are approving !
                  StrFormulaStatus = "L"
                  'Version Number stays same , should have been incremented from the Draft
                  If FormulaVersionNumber > 1 Then blnArchive = True 'There is an existing approved formula so we must archive this
                  EntityID_Approved = gEntityID_User
                  EntityID_Drafted = EntityID_Drafted
                  dteDateApproved = Now
                  blnSetApproved = True
               Else 'We are drafting
                  If StrFormulaStatus = "L" Then '14Oct09 TH (F0066293) only increment if from approved. Editing a drafy should not increment the version number
                  FormulaVersionNumber = FormulaVersionNumber + 1 'Drafting from an approved formula, increment the version
                  End If
                  StrFormulaStatus = "D"
                  EntityID_Approved = 0
                  EntityID_Drafted = gEntityID_User
                  dteDateApproved = 0
                  dteDateDrafted = Now
               End If
            
            Else
               StrFormulaStatus = "L" 'Live - always live for Patient formulae
               EntityID_Approved = gEntityID_User
               EntityID_Drafted = gEntityID_User
               dteDateApproved = Now
               dteDateDrafted = Now
            End If
            
         Else
            ''rsFormula.AddNew
            ''rsFormula!NSVCode = FormulaCode
            If GetSecondAuthorisation() Then
               StrFormulaStatus = "D"
               EntityID_Approved = 0
               EntityID_Drafted = gEntityID_User
               dteDateApproved = 0
               dteDateDrafted = Now
               'FormulaVersionNumber = 1 'New Draft - must be #1
               'Now, because an approved formula can be deleted, we must get the latest archived version
               'If one exists, and then increment by 1
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaCode)
               lngReturn = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWFormulaSelectVersionbySiteandNSVCodeArchive", strParams)
               FormulaVersionNumber = lngReturn + 1
               '14Oct09 TH (F0066295) we need to get any existing Label and method from the live record
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, FormulaCode)
               Set rsFormulaApproved = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulaSelectLabelMethodbySiteandNSVCodeLive", strParams)
               If Not rsFormulaApproved.EOF Then
                  rsFormulaApproved.MoveFirst
                  strMethod = RtrimGetField(rsFormulaApproved!Method)
                  strLabel = RtrimGetField(rsFormulaApproved!label)
               End If
               rsFormulaApproved.Close
               Set rsFormulaApproved = Nothing
               '------------------------
            End If
         End If
      
         ''If frmSave.ChkDosingUNits.Value = 1 Then
         ''   rsFormula!DosingUnits = True
         ''Else
         ''   rsFormula!DosingUnits = False
         ''End If
         
         ''rsFormula!Layout = frmSave.CmbLayout(0).Text
         ''rsFormula!Layout2 = frmSave.CmbLayout(1).Text
         ''rsFormula!NumofLabels = Val(frmSave.Text2.Text)
         ''rsFormula!ExtraLabels = Val(frmSave.Text3.Text)

         For n = 1 To 15
            ''ThisCode$ = "Code" & Format$(n)
            ''ThisDesc$ = "d" & Format$(n)
            ''ThisQty$ = "Qty" & Format$(n)
            ''ThisType$ = "Type" & Format$(n)
               
            'If Formula.TxtCode(n - 1).Text <> "" Then                           '03Sep99 AE moved below
            ''rsFormula(ThisCode$) = frmSave.TxtCode(n - 1).Text
            strCode(n) = Trim$(frmSave.TxtCode(n - 1).text)
            If strCode(n) = "" Then strCode(n) = Null
            ''rsFormula(ThisDesc$) = Mid$(frmSave.TxtDescription(n - 1).Text, 1, 60)
            strDescription(n) = Mid$(frmSave.TxtDescription(n - 1).text, 1, 60)
            ''rsFormula(ThisQty$) = frmSave.TxtQty(n - 1).Text
            dblQty(n) = Val(frmSave.txtQty(n - 1).text)
            ''rsFormula(ThisType$) = Left$(frmSave.CSCmbType(n - 1).Text, 1)
            strType(n) = Left$(frmSave.CSCmbType(n - 1).text, 1)
                     
            If frmSave.TxtCode(n - 1).text <> "" Then                            '03Sep99 AE
               Select Case frmSave.CSCmbType(n - 1).ListIndex
                  Case -1                                   'not set - check for text entry
                     txt$ = frmSave.CSCmbType(n - 1).text
                     ''''''On Error GoTo SaveFormulaErr
                     Select Case UCase(txt$)                '11Oct99 CKJ Tidied layout to be more legible
                        Case "VARIABLE":  txt$ = "V"        'variable
                        Case "FIXED":     txt$ = "F"        'fixed
                        Case "TO":        txt$ = "T"        'to
                        'Case "CONS FIXED"                  'cons fix        '?????99 AE replaced with below
                        Case "CONS FIX":  txt$ = "X"        'cons fix
                        Case "CONS VAR":  txt$ = "Y"        'cons var
                        Case "BATCH FIX": txt$ = "Z"        'batch fix
                        Case "": txt$ = ""                  '09Jun08 TH Added (after testing)
                        Case Else:        Error 2201        'exit
                        End Select
                  Case 0: txt$ = ""                         'set blank
                  Case 1: txt$ = "V"                        'variable
                  Case 2: txt$ = "F"                        'fixed
                  Case 3: txt$ = "T"                        'to
                  Case 4: txt$ = "X"                        'cons fixed
                  Case 5: txt$ = "Y"                        'cons var
                  Case 6: txt$ = "Z"                        'batch fix
                  End Select
               ''rsFormula(ThisType$) = txt$
               strType(n) = txt$

            End If

         Next
         
         
         ''frmSave.LblAuthorised = UserID$
         ''frmSave.LblAuthorisedDate = Format(Now, "dd/mm/yyyy")                     '         "
         
         ''rsFormula!Authorised = frmSave.LblAuthorised
         ''rsFormula!Authorised2 = frmSave.Lbl2ndAuth
         ''rsFormula!Authorised_Date = frmSave.LblAuthorisedDate
         If Not M_blnFromDispensing Then
            If GetSecondAuthorisation() Then
               If getaccesslevel() = 8 Then
                  If rsFormula.RecordCount > 0 Then
                     If RtrimGetField(rsFormula!Code) = "L" Then lngWFormulaID = 0 'Force insert of new Draft !
                  End If
               End If
            End If
         End If
         If blnArchive Then
            'OK here we need to update the existing Approved record to Status A (Archive)
            'Use the siscode (this must ,at present be a master - might be as well to check. Site to update (status will be implicit)
            Select Case FormulaType
               Case MASTER_FORMULA
                  strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                              gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, FormulaCode)
                  lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaArchiveApproved", strParams)
                  WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Formula (Version " & Format$((FormulaVersionNumber - 1)) & ") for " & FormulaCode & " Archived"
         
            Case Else
            End Select
         End If
         If Not GetSecondAuthorisation() Then
            StrFormulaStatus = "L"
         End If
         ''rsFormula.Update
         'SAve the formula here
         '13Mar07 TH Extended label input to 5000 chars
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Authorised2", trnDataTypeVarChar, 5, frmSave.Lbl2ndAuth) & _
                     gTransport.CreateInputParameterXML("Layout2", trnDataTypeVarChar, 50, frmSave.CmbLayout(1).text) & _
                     gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, FormulaCode) & _
                     gTransport.CreateInputParameterXML("code1", trnDataTypeVarChar, 7, strCode(1)) & _
                     gTransport.CreateInputParameterXML("code2", trnDataTypeVarChar, 7, strCode(2)) & _
                     gTransport.CreateInputParameterXML("code3", trnDataTypeVarChar, 7, strCode(3)) & _
                     gTransport.CreateInputParameterXML("code4", trnDataTypeVarChar, 7, strCode(4)) & _
                     gTransport.CreateInputParameterXML("code5", trnDataTypeVarChar, 7, strCode(5)) & _
                     gTransport.CreateInputParameterXML("code6", trnDataTypeVarChar, 7, strCode(6)) & _
                     gTransport.CreateInputParameterXML("code7", trnDataTypeVarChar, 7, strCode(7)) & _
                     gTransport.CreateInputParameterXML("code8", trnDataTypeVarChar, 7, strCode(8)) & _
                     gTransport.CreateInputParameterXML("code9", trnDataTypeVarChar, 7, strCode(9)) & _
                     gTransport.CreateInputParameterXML("code10", trnDataTypeVarChar, 7, strCode(10)) & _
                     gTransport.CreateInputParameterXML("code11", trnDataTypeVarChar, 7, strCode(11)) & _
                     gTransport.CreateInputParameterXML("code12", trnDataTypeVarChar, 7, strCode(12)) & _
                     gTransport.CreateInputParameterXML("code13", trnDataTypeVarChar, 7, strCode(13)) & _
                     gTransport.CreateInputParameterXML("code14", trnDataTypeVarChar, 7, strCode(14)) & _
                     gTransport.CreateInputParameterXML("code15", trnDataTypeVarChar, 7, strCode(15)) & _
                     gTransport.CreateInputParameterXML("qty1", trnDataTypeFloat, 8, dblQty(1)) & _
                     gTransport.CreateInputParameterXML("qty2", trnDataTypeFloat, 8, dblQty(2)) & _
                     gTransport.CreateInputParameterXML("qty3", trnDataTypeFloat, 8, dblQty(3)) & _
                     gTransport.CreateInputParameterXML("qty4", trnDataTypeFloat, 8, dblQty(4)) & _
                     gTransport.CreateInputParameterXML("qty5", trnDataTypeFloat, 8, dblQty(5)) & _
                     gTransport.CreateInputParameterXML("qty6", trnDataTypeFloat, 8, dblQty(6))
         strParams = strParams & gTransport.CreateInputParameterXML("qty7", trnDataTypeFloat, 8, dblQty(7)) & _
                                 gTransport.CreateInputParameterXML("qty8", trnDataTypeFloat, 8, dblQty(8)) & _
                                 gTransport.CreateInputParameterXML("qty9", trnDataTypeFloat, 8, dblQty(9)) & _
                                 gTransport.CreateInputParameterXML("qty10", trnDataTypeFloat, 8, dblQty(10)) & _
                                 gTransport.CreateInputParameterXML("qty11", trnDataTypeFloat, 8, dblQty(11)) & _
                                 gTransport.CreateInputParameterXML("qty12", trnDataTypeFloat, 8, dblQty(12)) & _
                                 gTransport.CreateInputParameterXML("qty13", trnDataTypeFloat, 8, dblQty(13)) & _
                                 gTransport.CreateInputParameterXML("qty14", trnDataTypeFloat, 8, dblQty(14)) & _
                                 gTransport.CreateInputParameterXML("qty15", trnDataTypeFloat, 8, dblQty(15)) & _
                                 gTransport.CreateInputParameterXML("type1", trnDataTypeVarChar, 1, strType(1)) & _
                                 gTransport.CreateInputParameterXML("type2", trnDataTypeVarChar, 1, strType(2)) & _
                                 gTransport.CreateInputParameterXML("type3", trnDataTypeVarChar, 1, strType(3)) & _
                                 gTransport.CreateInputParameterXML("type4", trnDataTypeVarChar, 1, strType(4)) & _
                                 gTransport.CreateInputParameterXML("type5", trnDataTypeVarChar, 1, strType(5)) & _
                                 gTransport.CreateInputParameterXML("type6", trnDataTypeVarChar, 1, strType(6)) & _
                                 gTransport.CreateInputParameterXML("type7", trnDataTypeVarChar, 1, strType(7)) & _
                                 gTransport.CreateInputParameterXML("type8", trnDataTypeVarChar, 1, strType(8)) & _
                                 gTransport.CreateInputParameterXML("type9", trnDataTypeVarChar, 1, strType(9)) & _
                                 gTransport.CreateInputParameterXML("type10", trnDataTypeVarChar, 1, strType(10)) & _
                                 gTransport.CreateInputParameterXML("type11", trnDataTypeVarChar, 1, strType(11)) & _
                                 gTransport.CreateInputParameterXML("type12", trnDataTypeVarChar, 1, strType(12)) & _
                                 gTransport.CreateInputParameterXML("type13", trnDataTypeVarChar, 1, strType(13)) & _
                                 gTransport.CreateInputParameterXML("type14", trnDataTypeVarChar, 1, strType(14)) & _
                                 gTransport.CreateInputParameterXML("type15", trnDataTypeVarChar, 1, strType(15)) & _
                                 gTransport.CreateInputParameterXML("Method", trnDataTypeVarChar, 1024, strMethod)
         strParams = strParams & gTransport.CreateInputParameterXML("TotalQty", trnDataTypeFloat, 8, dblTotalQty) & _
                                 gTransport.CreateInputParameterXML("NumofLabels", trnDataTypeint, 4, Val(frmSave.Text2.text)) & _
                                 gTransport.CreateInputParameterXML("Label", trnDataTypeVarChar, 5000, strLabel) & _
                                 gTransport.CreateInputParameterXML("ExtraLabels", trnDataTypeint, 4, Val(frmSave.Text3.text)) & _
                                 gTransport.CreateInputParameterXML("DosingUnits", trnDataTypeBit, 1, frmSave.ChkDosingUNits.Value) & _
                                 gTransport.CreateInputParameterXML("d1", trnDataTypeVarChar, 60, strDescription(1)) & _
                                 gTransport.CreateInputParameterXML("d2", trnDataTypeVarChar, 60, strDescription(2)) & _
                                 gTransport.CreateInputParameterXML("d3", trnDataTypeVarChar, 60, strDescription(3)) & _
                                 gTransport.CreateInputParameterXML("d4", trnDataTypeVarChar, 60, strDescription(4)) & _
                                 gTransport.CreateInputParameterXML("d5", trnDataTypeVarChar, 60, strDescription(5)) & _
                                 gTransport.CreateInputParameterXML("d6", trnDataTypeVarChar, 60, strDescription(6)) & _
                                 gTransport.CreateInputParameterXML("d7", trnDataTypeVarChar, 60, strDescription(7)) & _
                                 gTransport.CreateInputParameterXML("d8", trnDataTypeVarChar, 60, strDescription(8)) & _
                                 gTransport.CreateInputParameterXML("d9", trnDataTypeVarChar, 60, strDescription(9)) & _
                                 gTransport.CreateInputParameterXML("d10", trnDataTypeVarChar, 60, strDescription(10)) & _
                                 gTransport.CreateInputParameterXML("d11", trnDataTypeVarChar, 60, strDescription(11)) & _
                                 gTransport.CreateInputParameterXML("d12", trnDataTypeVarChar, 60, strDescription(12)) & _
                                 gTransport.CreateInputParameterXML("d13", trnDataTypeVarChar, 60, strDescription(13)) & _
                                 gTransport.CreateInputParameterXML("d14", trnDataTypeVarChar, 60, strDescription(14)) & _
                                 gTransport.CreateInputParameterXML("d15", trnDataTypeVarChar, 60, strDescription(15)) & _
                                 gTransport.CreateInputParameterXML("Authorised", trnDataTypeVarChar, 5, UserID$) & _
                                 gTransport.CreateInputParameterXML("Authorised_Date", trnDataTypeDateTime, 8, Now) & _
                                 gTransport.CreateInputParameterXML("Layout", trnDataTypeVarChar, 10, frmSave.CmbLayout(0).text)
          
         '26Aug09 TH Added new fields (F0054335)
         strParams = strParams & gTransport.CreateInputParameterXML("WManufacturingStatusCode", trnDataTypeVarChar, 1, StrFormulaStatus) & _
                                 gTransport.CreateInputParameterXML("EntityID_Drafted", trnDataTypeint, 4, EntityID_Drafted) & _
                                 gTransport.CreateInputParameterXML("EntityID_Approved", trnDataTypeint, 4, EntityID_Approved) & _
                                 gTransport.CreateInputParameterXML("DateDrafted", trnDataTypeDateTime, 8, dteDateDrafted) & _
                                 gTransport.CreateInputParameterXML("DateApproved", trnDataTypeDateTime, 8, dteDateApproved) & _
                                 gTransport.CreateInputParameterXML("VersionNumber", trnDataTypeint, 4, FormulaVersionNumber)
                                 
         '24Jun13 TH Added for QA Yield (TFS 48388)
         strParams = strParams & gTransport.CreateInputParameterXML("QAQuantity", trnDataTypeint, 4, Val(frmSave.txtQAQty.text))
         
         '26Jun13 TH Added for Bond Issue (TFS 48388)
         strParams = strParams & gTransport.CreateInputParameterXML("Bond_Issue", trnDataTypeBit, 1, Val(frmSave.chkBond.Value))
         
         If lngWFormulaID > 0 Then
            strParams = gTransport.CreateInputParameterXML("WFormulaID", trnDataTypeint, 4, lngWFormulaID) & strParams
            lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WFormula", strParams)
            '26Aug09 TH Added logging for F0054335
            If GetSecondAuthorisation() Then
               Select Case StrFormulaStatus
                  Case "D" 'Draft
                     WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Draft Formula (Version " & Format$(FormulaVersionNumber) & ") for " & FormulaCode & " Updated"
                  Case "L" 'Approved
                     If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "N", "getReasonOnApproval", 0)) Then
                        InputWin "Manufacturing", "Please Enter a reason for approving this change", strReasonForApproval, localkeys
                     End If
                     If Trim$(strReasonForApproval) <> "" Then strReasonForApproval = "Reason = " & strReasonForApproval
                     WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Formula (Version " & Format$(FormulaVersionNumber) & ") for " & FormulaCode & " Approved. " & Trim$(strReasonForApproval)
                     'Move any method into Live use
                     If Trim$(strMethod) <> "" Then
                        '09Feb17 TH THis was missed ! We need to handle this from the DB (TFS 176196)
                        'If fileexists(dispdata$ & "\wksheets\Draft\" & strMethod) Then
                        If RTFExistsInDatabase(dispdata$ & "\wksheets\Draft\" & strMethod) Then
                        
                           'delete existing file
                           'If fileexists(dispdata$ & "\wksheets\" & strMethod) Then Kill dispdata$ & "\wksheets\" & strMethod '09Feb17 TH This will be overwritten
                           'copy draft
                           'FileCopy dispdata$ & "\wksheets\Draft\" & strMethod, dispdata$ & "\wksheets\" & strMethod
                           '09Feb17 TH Replaced Above to ensure method replacement uses the DB RTF handling (Hosted)(TFS 176196)
                           strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", strMethod)
                           lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets", strMethod, strRTFText)
                        End If
                     End If
                  End Select
            End If
         Else
            lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WFormula", strParams)
            FormulaType = MASTER_FORMULA 'Ensure this is kept next time round
            If GetSecondAuthorisation() Then
               Select Case StrFormulaStatus
                  Case "D" 'Draft
                     WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "New Draft Formula (Version " & Format$(FormulaVersionNumber) & ") for " & FormulaCode
                  Case "L" 'Approved
                     WriteLog dispdata$ & "\ManufacturingAudit.log", SiteNumber, UserID$, "Formula (Version " & Format$(FormulaVersionNumber) & ") for " & FormulaCode & " Approved"
               End Select
            End If
         End If
' TODO!!!        On Error GoTo LayoutUpdate_Err                                    '05Aug99 CKJ/AE Moved from before ds.update
'         Set TblLayout = db.OpenTable("Layout")
'         TblLayout.Index = "Name"                                          '19Nov98 CFY Added
'         For i = 0 To 1                                                    '      "
'            TblLayout.Seek "=", frmSave.CmbLayout(i).Text                          '      "
'            If Not TblLayout.NoMatch Then                                  '      "
'               TblLayout.Edit                                           '      "
'               TblLayout!PatientsPerSheet = frmSave.TxtPatsPerSheet(i).Text     '      "
'               TblLayout.Update                                         '      "
'            End If                                                      '      "
'         Next                                                              '      "

         '10Jun08 TH Added block (F00)
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, frmSave.CmbLayout(i).text) & _
                     gTransport.CreateInputParameterXML("PatsPerSheet", trnDataTypeint, 4, Val(frmSave.TxtPatsPerSheet(i).text))
         lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WLayoutUpdatePatsPerSheetbyName", strParams)
         '----------
         
''         '11Oct99 CKJ Update d.HasFormula flag for d.siscode
''         dTmp.SisCode = d.SisCode
''         If Trim$(dTmp.SisCode) <> "" Then
''            getdrug dTmp, 0, lngDrugFound, True
''            If lngDrugFound Then
''               d.HasFormula = "Y"                                   'need to set d.has formula as well, since it is not refreshed from disk
''               dTmp.HasFormula = "Y"                                '05Jan00 AE Corrected to use d.tmp
''               putdrug dTmp, lngDrugFound
''            End If
''         End If
         'If blnSetApproved Then
         If blnSetApproved And GetSecondAuthorisation() Then '24Feb10 TH Only switch the screen if second auth stuff is on.
            'Reset the form here
            frmSave.CmdAuthorise.Enabled = False
            frmSave.LblFormulaStatus.Caption = "APPROVED"
            SetDynamicChrome frmSave, &HC0FFC0
         End If
      End If
   End If

SaveFormulaExit:

   On Error Resume Next
   ''ds.Close                                                                      '05Aug99 CKJ/AE Added Close
   ''Set ds = Nothing
   rsFormula.Close                                                               '05Aug99 CKJ/AE Added Close
   Set rsFormula = Nothing
   ''db.Close                                                                      '05Aug99 CKJ/AE Added Close
   ''Set db = Nothing
   On Error GoTo 0
   frmSave.cmdCancel.Tag = ""                                                    '13Jul00 JN Added to prevent further save requests
Exit Sub


LayoutUpdate_Err:
   popmessagecr ".", "Error. Could not update Layout table. Your changes may be lost."
Resume SaveFormulaExit

WaitError:
   intRetries = intRetries + 1   '13Jul00 JN Added count to prevent infinite looping
   Err70msg 70, "Formula.mdb "
   If intRetries < 11 Then       '13Jul00 JN Added check for up to 10 retries before nicely binning out of routine
   Resume SaveFormulaGetLock
      Else
         popmessagecr ".", "Error. Could not update the formula after " & Format$(intRetries - 1) & " retries."
         Resume SaveFormulaExit
      End If

SaveFormulaErr:
'general errors etc
   
   Select Case Err
      Case 2201
         txt$ = "No type entered, or type not recognised. Please choose a " & cr$
         txt$ = txt$ & "type from the list provided"
         popmessagecr "!Manufacturing", txt$
         k.escd = True
         If frmSave.CSCmbType(n - 1).Visible Then frmSave.CSCmbType(n - 1).SetFocus
         'Resume SaveFormulaExit                                                 '05Aug99 CKJ/AE Replaced below
      Case Else
         txt$ = "Error in SaveFormula: " & Error$
         popmessagecr "!Manufacturing", txt$
         'Error Err                                                              '05Aug99 CKJ/AE Removed
      End Select
Resume SaveFormulaExit
   

End Sub

Sub SetFormulaForm(frmFormula As Form, ByVal rsFormula As ADODB.Recordset, ByVal blnFromDispensing As Boolean)
         
'28Jul99 AE written
'Display the data from the Formula.MDB onto the form
'14Jul00 JN added reference to a particular instance of formula.frm
'14Jul00 JN changed all references to formula. to frmFormula.

' sn As Snapshot input param
                       
Dim n%, drug$, txt$
Dim ThisCode$, ThisDesc$, ThisQty$, ThisType$
Dim intVersion As Integer '26Aug09 TH Added
                     
   If (FormulaType <> NEW_FORMULA) And (FormulaType <> NEW_PATIENTFORMULA) Then
      
      If rsFormula!DosingUnits = True Then
         frmFormula.ChkDosingUNits.Value = 1
      Else
         frmFormula.ChkDosingUNits.Value = 0
      End If
   
      drug$ = d.LabelDescription 'drug$ = d.Description
      plingparse drug$, "!"
      frmFormula.lblDescription.Caption = drug$
      
      FillLayoutCombos frmFormula  '26Aug09 TH Attempt to fix "heisenbug" were combos were not being filled correctly
      If Val(Left$(Format$(RtrimGetField(rsFormula!NSVCode)), 1)) = 0 Then '07Jun05 TH Added
         frmFormula.LblNSVcode = RtrimGetField(rsFormula!NSVCode)
      Else                                                                 '    "
         frmFormula.LblNSVcode = d.SisCode                                 '    "
      End If                                                               '    "
      frmFormula.CmbLayout(0).text = RtrimGetField(rsFormula!Layout)
      frmFormula.CmbLayout(1).text = RtrimGetField(rsFormula!Layout2)
      If frmFormula.CmbLayout(0).text = "" Then
         On Error Resume Next  '19May06 TH DB should always have layouts, but just incase
         frmFormula.CmbLayout(0).ListIndex = 0 'Set to default if no entry in db
         On Error GoTo 0
      End If

      txt$ = d.convfact & " " & d.PrintformV
      frmFormula.LblTotQty.Caption = txt$
      If RtrimGetField(rsFormula!EntityID_Drafted) > 0 And GetSecondAuthorisation() Then                               '26Aug09 TH Added
         frmFormula.LblAuthorised.Caption = RtrimGetField(rsFormula!Draft_Initials) & " " & Format$(GetField(rsFormula.Fields("DateDrafted")), "dd/mm/yyyy HH:NN")
      Else                                                                                '    "
         frmFormula.LblAuthorised.Caption = RtrimGetField(rsFormula!Authorised)
      End If                                                                              '    "
      If RtrimGetField(rsFormula!EntityID_Approved) > 0 And GetSecondAuthorisation() Then                              '    "
         frmFormula.Lbl2ndAuth.Caption = RtrimGetField(rsFormula!Approved_Initials) & " " & Format$(GetField(rsFormula.Fields("DateApproved")), "dd/mm/yyyy HH:NN")
      Else                                                                                '    "
         frmFormula.Lbl2ndAuth.Caption = RtrimGetField(rsFormula!Authorised2)
      End If                                                                              '    "
      If GetSecondAuthorisation() Then
         frmFormula.LblVersion = "# " & RtrimGetField(rsFormula!VersionNumber)
      Else
      'frmFormula.LblAuthorisedDate = RtrimGetField(rsFormula!Authorised_Date) '26Aug09 Th Removed
         frmFormula.lblStatus.Caption = RtrimGetField(rsFormula!Authorised_Date)
         frmFormula.Label11.Caption = "Authorisation Date"
         frmFormula.Label14.Caption = "Authorised by"
         frmFormula.Label12.Caption = "Second Authorisation"
      End If
      '26Aug09 TH Changes to form (F0054335)
      frmFormula.Text2.text = RtrimGetField(rsFormula!NumofLabels)
      frmFormula.Text3.text = RtrimGetField(rsFormula!ExtraLabels)
      
      For n = 1 To 15
         ThisCode$ = "Code" & Format$(n)
         ThisDesc$ = "d" & Format$(n)
         ThisQty$ = "Qty" & Format$(n)
         ThisType$ = "Type" & Format$(n)
         frmFormula.TxtCode(n - 1).text = RtrimGetField(rsFormula(ThisCode$))
         frmFormula.TxtDescription(n - 1).text = RtrimGetField(rsFormula(ThisDesc$))
         
         txt$ = RtrimGetField(rsFormula(ThisQty$))
         If txt$ = "0" Then txt$ = ""             'prevent from filling in zeros in empty boxes
         frmFormula.txtQty(n - 1).text = txt$
         
         Select Case RtrimGetField(rsFormula(ThisType$))                        'Where is the list of items added to cscmbtype ?
            Case "F":  txt$ = "Fixed"
            Case "V":  txt$ = "Variable"
            Case "T":  txt$ = "To"
            Case "X":  txt$ = "Cons Fix"
            Case "Y":  txt$ = "Cons Var"
            Case "Z":  txt$ = "Batch Fix"
            Case Else: txt$ = ""
         End Select
         frmFormula.CSCmbType(n - 1).text = txt$

         BlankWProduct d
         d.SisCode = frmFormula.TxtCode(n - 1).text
         getdrug d, 0, 0, False
         
         If frmFormula.ChkDosingUNits.Value = 1 Then
            frmFormula.lblUnits(n - 1).Caption = LCase$(d.DosingUnits)
         Else
            frmFormula.lblUnits(n - 1).Caption = LCase$(d.PrintformV)
         End If
      Next

      frmFormula.TxtPatsPerSheet(0) = GetPatsPerSheet((frmFormula.CmbLayout(0).text))
      frmFormula.TxtPatsPerSheet(1) = GetPatsPerSheet((frmFormula.CmbLayout(1).text))
      
      frmFormula.txtQAQty.text = Format$(RtrimGetField(rsFormula!QAQuantity)) '24Jun13 TH Added (TFS 48388)
      
      '26Jun13 TH Added (TFS 56621)
      If RtrimGetField(rsFormula!Bond_Issue) Then
         frmFormula.chkBond.Value = 1
      Else
         frmFormula.chkBond.Value = 0
      End If
      
      If Not blnFromDispensing And GetSecondAuthorisation() Then '26Aug09 TH Added (F0054335)
         Select Case RtrimGetField(rsFormula!Code)
            Case "L" 'Approved
               If getaccesslevel() = 8 Then 'In this case the Approved record is actually the basis for a new draft
                  SetDynamicChrome frmFormula, &HC0FFFF
                  frmFormula.LblFormulaStatus.Caption = "DRAFT"
                  frmFormula.lblStatus.Caption = "DRAFT"
                  intVersion = RtrimGetField(rsFormula!VersionNumber) + 1
                  frmFormula.Lbl2ndAuth.Caption = ""
                  frmFormula.LblAuthorised.Caption = ""
               Else
                  frmFormula.LblFormulaStatus.Caption = "APPROVED"
                  frmFormula.lblStatus.Caption = "APPROVED"
                  SetDynamicChrome frmFormula, &HC0FFC0
                  intVersion = RtrimGetField(rsFormula!VersionNumber)
               End If
            Case "D" 'Draft
               SetDynamicChrome frmFormula, &HC0FFFF
               frmFormula.LblFormulaStatus.Caption = "DRAFT"
               frmFormula.lblStatus.Caption = "DRAFT"
               intVersion = RtrimGetField(rsFormula!VersionNumber)
            Case "A" 'Archive
               SetDynamicChrome frmFormula, &H8080FF
               frmFormula.LblFormulaStatus.Caption = "ARCHIVE"
               frmFormula.lblStatus.Caption = "ARCHIVE"
               intVersion = RtrimGetField(rsFormula!VersionNumber)
         End Select
         'frmFormula.LblFormulaStatus.Caption = RtrimGetField(rsFormula!Description)
         If GetSecondAuthorisation() Then
            frmFormula.LblStatusTag.Caption = Format$(SiteNumber) & "/" & RtrimGetField(rsFormula!NSVCode) & "/" & RtrimGetField(rsFormula!Code) & intVersion
            frmFormula.LblVersion.Caption = "# " & Format$(intVersion)
         End If
      End If
   Else
      BlankFormulaForm frmFormula      '14Jul00 JN added reference to instance of formula.frm
      drug$ = d.LabelDescription         'drug$ = d.Description
      plingparse drug$, "!"
      frmFormula.lblDescription.Caption = drug$
      If FormulaType = NEW_PATIENTFORMULA Then
         
         frmFormula.ChkDosingUNits.Value = 1 '16Jun05 TH Added cos dosing units must be checked for pat spec.
         frmFormula.CmbLayout(0).text = "default" '17Jun05 TH This cant be right - there must be a proper way of identifying a default layout
         frmFormula.TxtPatsPerSheet(0) = GetPatsPerSheet((frmFormula.CmbLayout(0).text))
         'frmFormula.TxtPatsPerSheet(1) = GetPatsPerSheet((frmFormula.CmbLayout(1).Text))
      End If
      If Not blnFromDispensing Then 'Must be Draft if new '26Aug09 TH (F00543335)
          If GetSecondAuthorisation() Then
            frmFormula.LblFormulaStatus.Caption = "DRAFT"
            SetDynamicChrome frmFormula, &HC0FFFF
            'Set Version as 1
            frmFormula.LblVersion.Caption = "# 1"
            frmFormula.LblStatusTag.Caption = Format$(SiteNumber) & "/" & d.SisCode & "/D1"
          End If
          frmFormula.LblAuthorised.Caption = ""
          frmFormula.Lbl2ndAuth.Caption = ""
          frmFormula.lblStatus.Caption = ""
          frmFormula.LblAuthorised.Caption = ""
          
      End If
   End If
      
   '16Jun05 TH
   If m_blnFromDispens Then
      frmFormula.CmdEdit(0).Enabled = False
      frmFormula.CmdEdit(1).Enabled = False
      frmFormula.Frame2.Visible = True
   End If
   '--------
            


End Sub

Sub SetFormulaView(frmView As Form, mode%)

'            0 - view only mode (default). No changes allowed to any of the controls.
'            1
'            2 - Dispensary mode. Can make a new patient specific formula, but cannot add a new formula or edit the master formula
'            3-7 reserved
'            8 - reserved for limited access from manufacturing
'            9 - Manufacturing Mode. Full access.


'28Jul99 AE Written to allow setting of specific view modes by the calling procedure.
'14Jul00 JN amended to reflect reference to specific instance of formula.frm

Dim i%

   Select Case mode
      Case 0                             'view only.
         frmView.Caption = frmView.Caption & " (View Only)"
         frmView.ChkBlisterPack.Enabled = False
         frmView.ChkDosingUNits.Enabled = False
         frmView.CmbLayout(0).Enabled = False
         frmView.CmbLayout(1).Enabled = False
         frmView.TxtPatsPerSheet(0).Enabled = False
         frmView.TxtPatsPerSheet(1).Enabled = False
         frmView.CmdEdit(0).Enabled = False
         frmView.CmdEdit(1).Enabled = False
         frmView.Text2.Enabled = False
         frmView.Text3.Enabled = False
         frmView.MnuNew.Enabled = False
         frmView.MnuDelete.Enabled = False
         frmView.mnuline1.Visible = False
         frmView.MnuLine2.Visible = False
         frmView.mnuPrint(0).Enabled = False
         frmView.mnuPrint(1).Enabled = False
         frmView.mnuFormat.Enabled = False
         frmView.CmdAuthorise.Enabled = False
         frmView.CmdAuthorise.Visible = False
         frmView.CmdCompound.Enabled = False
         frmView.CmdCompound.Visible = False
         frmView.cmdDelete.Enabled = False
         frmView.cmdDelete.Visible = False

      Case 2 To 7                                   '2: Dispensary mode. Not allowed to edit master record
         frmView.ChkBlisterPack.Enabled = False     '3-7 reserved for other dispensary use
         frmView.Caption = frmView.Caption & " (Dispensary)"
         frmView.ChkDosingUNits.Enabled = False
         frmView.cmdDelete.Enabled = False
         frmView.cmdDelete.Visible = False
         frmView.mnuFormat.Enabled = False
         frmView.MnuNew.Enabled = False
         frmView.MnuDelete.Enabled = False
         frmView.mnuline1.Visible = False
         frmView.MnuLine2.Visible = False
         frmView.mnuPrint(0).Enabled = False
         frmView.mnuPrint(1).Enabled = False
         frmView.mnuline1.Visible = False
         frmView.MnuLine2.Visible = False
         frmView.Text2.Enabled = False
         frmView.Text3.Enabled = False
         ''frmView.MnuOptS.Enabled = True

      Case 8                                     '8 Reserved, 9 = Full access from manufacturing
         frmView.Caption = frmView.Caption & " (Manufacturing)"
      Case 9 '26Aug09 TH seperated this out so as to stop editing from 9 in 2ndAuth mode (F0054335)
         frmView.Caption = frmView.Caption & " (Manufacturing)"
         If GetSecondAuthorisation() And Not M_blnFromDispensing Then
            If getaccesslevel() = 9 Then
               frmView.ChkBlisterPack.Enabled = False
               frmView.ChkDosingUNits.Enabled = False
               frmView.CmbLayout(0).Enabled = False
               frmView.CmbLayout(1).Enabled = False
               frmView.TxtPatsPerSheet(0).Enabled = False
               frmView.TxtPatsPerSheet(1).Enabled = False
               frmView.CmdEdit(0).Enabled = False
               frmView.CmdEdit(1).Enabled = False
               frmView.Text2.Enabled = False
               frmView.Text3.Enabled = False
               frmView.MnuNew.Enabled = False
               frmView.MnuDelete.Enabled = False
               frmView.mnuline1.Visible = False
               frmView.MnuLine2.Visible = False
               frmView.mnuPrint(0).Enabled = False
               frmView.mnuPrint(1).Enabled = False
               'frmView.mnuFormat.Enabled = False
               frmView.mnuFormat.Enabled = True  '10Aug14 TH Allow view (TFS 86640)
               frmView.CmdCompound.Enabled = False
               frmView.CmdCompound.Visible = False
               frmView.cmdDelete.Enabled = False
               frmView.cmdDelete.Visible = False
               frmView.cmdReturn.Enabled = False
               frmView.cmdReturn.Visible = False
               frmView.MnuOptS.Enabled = False
            ElseIf getaccesslevel() = 8 Then
               'frmView.ChkBlisterPack.Enabled = False
               'frmView.ChkDosingUNits.Enabled = False
               'frmView.CmbLayout(0).Enabled = False
               'frmView.CmbLayout(1).Enabled = False
               'frmView.TxtPatsPerSheet(0).Enabled = False
               'frmView.TxtPatsPerSheet(1).Enabled = False
               'frmView.CmdEdit(0).Enabled = False
               'frmView.CmdEdit(1).Enabled = False
               'frmView.Text2.Enabled = False
               'frmView.Text3.Enabled = False
               'frmView.MnuNew.Enabled = False
               'frmView.MnuDelete.Enabled = False
               'frmView.mnuline1.Visible = False
               'frmView.MnuLine2.Visible = False
               'frmView.MnuPrint(0).Enabled = False
               'frmView.MnuPrint(1).Enabled = False
               'frmView.MnuFormat.Enabled = False
               frmView.CmdCompound.Enabled = False
               frmView.CmdCompound.Visible = False
               'frmView.CmdDelete.Enabled = False
               'frmView.CmdDelete.Visible = False
               frmView.cmdReturn.Enabled = False
               frmView.cmdReturn.Visible = False
               'frmView.MnuOptS.Enabled = False
               frmView.CmdAuthorise.Caption = "&Save Draft"
               frmView.cmdDelete.Caption = "&Delete Draft"
            ElseIf getaccesslevel() = 7 Then
               frmView.cmdReturn.Enabled = True
               frmView.cmdReturn.Visible = True
            End If
         End If
      End Select

   For i = 0 To 14                                  'These enabled to prevent greying of text.
      frmView.TxtCode(i).Enabled = True          'Ability to edit Governed by KeyPress Event
      frmView.TxtDescription(i).Enabled = True
      frmView.txtQty(i).Enabled = True
   Next

   frmView.cmdCancel.Enabled = True       'Exit button must always be available

End Sub

Sub setFromDispens(blnFromDispens As Integer)
'01Oct02 TH Written
   
   m_blnFromDispens = blnFromDispens
   
End Sub

Sub setManufactureInfo(QtyIssued!, cost!)
'30Jul98 EAC written for OCX mods

   ManuIssued! = QtyIssued!
   ManuCost! = cost!

End Sub

Sub SetNoIssueRequired(blnNoIssueRequired As Integer)
   m_blnNoIssue = blnNoIssueRequired
End Sub

Sub SetNoLabelRequired(blnNoLabelRequired As Integer)
   m_blnNoLabel = blnNoLabelRequired
End Sub

Sub StoreandTotal(suffix%)
'19Nov98 CFY Written
'This routine has two purposes:
'  1. Takes elements concerning the worksheet from the heap and makes copies, writing the
'     elements back to the heap, with a suffix.
'  2. Keeps running totals of certain elements, to place onto the heap just before printing
'     of the worksheets occurs. The action of placing the totals onto the heap is invoked by calling the
'     routine with a suffix of zero.
'
'21Jan99 CFY Now correctly totals the dosing qty's.
'02Feb99 CFY Now deals with information that has been passed in by the OCX.
'01Oct02 TH Replaced write of numdse to heap to reflect proper value
'01Oct02 TH Added ingvol printable element for CIVAS multiple patient wrksheets
'07Oct02 TH Added batchnumber and expriydateonly as wrksheet elements for storage (Clatterbridge)
'16Mar15 TH Reworked and added elements around volumes (TFS 148108)

Dim i%
Dim StdlblA$, StdlblB$, tmp$, numdose$
Dim strTemp As String   '01Oct02 TH Added
Dim TotalDiff!    '16Jul13 TH (TFS 68238)
Dim sglTotalDiffperDose As Single '15Mar16 TH Added fro new element calcs (TFS 148108)

   If suffix% > 0 Then
         'Copy Patient Details.....
         
         'Copy orginal dispensing label from heap then paste back with suffix added to the tag
         For i = 1 To 11
            Heap 11, gPRNheapID, "StdLbl" & Format$(i) & "A", StdlblA$, 0
            Heap 11, gPRNheapID, "StdLbl" & Format$(i) & "B", StdlblB$, 0
            Heap 10, gPRNheapID, "StdLbl" & Format$(i) & "A" & Format$(suffix%), StdlblA$, 0
            Heap 10, gPRNheapID, "StdLbl" & Format$(i) & "B" & Format$(suffix%), StdlblB$, 0
         Next
         
         Heap 11, gPRNheapID, "cons", tmp$, 0
         Heap 10, gPRNheapID, "cons" & Format$(suffix%), tmp$, 0
         Heap 11, gPRNheapID, "dob", tmp$, 0
         Heap 10, gPRNheapID, "dob" & Format$(suffix%), tmp$, 0
         Heap 11, gPRNheapID, "patientdetails", tmp$, 0
         Heap 10, gPRNheapID, "patientdetails" & Format$(suffix%), tmp$, 0
         Heap 11, gPRNheapID, "dose", tmp$, 0
         Heap 10, gPRNheapID, "dose" & Format$(suffix%), tmp$, 0
         Heap 11, gPRNheapID, "vol/dse", tmp$, 0
         Heap 10, gPRNheapID, "vol/dse" & Format$(suffix%), tmp$, 0
         Heap 11, gPRNheapID, "numdse", numdose$, 0
         'Heap 10, gPRNHeapID, "numdse" & Format$(suffix%), tmp2$, 0     '01Oct02 TH Replaced
         Heap 10, gPRNheapID, "numdse" & Format$(suffix%), numdose$, 0   '  "
         Heap 11, gPRNheapID, "ingvol", strTemp, 0                      '01Oct02 TH Added
         Heap 10, gPRNheapID, "ingvol" & Format$(suffix%), strTemp, 0   '  "
         'TotalIngVol = TotalIngVol + Val(strTemp)                    '15Mar16 TH Changed to reflect total, not per dose (TFS 148108)
         TotalIngVol = TotalIngVol + (Val(strTemp) * Val(numdose$))   '      "
         sngIngVolperdose = sngVolperdose + Val(strTemp)
         Heap 11, gPRNheapID, "batchnumber", strTemp, 0                          '07Oct02 TH Added
         Heap 10, gPRNheapID, "batchnumber" & Format$(suffix%), strTemp, 0       '  "
         Heap 11, gPRNheapID, "ExpiryDateOnly", strTemp, 0                       '  "
         Heap 10, gPRNheapID, "ExpiryDateOnly" & Format$(suffix%), strTemp, 0    '  "
         'TotalVol! = TotalVol! + Val(tmp$) * Val(numdose$)
         TotalVol! = TotalVol! + (Val(tmp$) * Val(numdose$)) '15Mar16 TH Changed to ensure the correct cumulative total although I think we only support 1 patient per sheet now (TFS 148108)
         sngVolperdose = sngVolperdose + (Val(tmp$))  '15Mar16 TH New Volume to account for per dose measures (TFS 148108)
         For i = 1 To 15
            tmp$ = ""
            Heap 11, gPRNheapID, "issued" & Format$(i), tmp$, 0        'Total number of units
            TotalUnits!(i) = TotalUnits!(i) + Val(tmp$)                'issued per item.
            Heap 11, gPRNheapID, "itemqty" & Format$(i), tmp$, 0       'Total number of dosing units  '21Jan99 CFY Added
            totalQty(i) = totalQty(i) + Val(tmp$) * Val(numdose$)      'issued per item.                    '21Jan99 CFY Added
         Next
      
         'Information from OCX
         Heap 11, gPRNheapID, "pSurname", tmp$, 0                       '02Feb99 CFY Added
         Heap 10, gPRNheapID, "pSurname" & Format$(suffix%), tmp$, 0    '        "
         Heap 11, gPRNheapID, "pForename", tmp$, 0                      '        "
         Heap 10, gPRNheapID, "pForename" & Format$(suffix%), tmp$, 0   '        "
         Heap 11, gPRNheapID, "Hospabbr", tmp$, 0                       '        "
         Heap 10, gPRNheapID, "Hospabbr" & Format$(suffix%), tmp$, 0    '        "
         Heap 11, gPRNheapID, "OCXHospNum", tmp$, 0                     '        "
         Heap 10, gPRNheapID, "OCXHospNum" & Format$(suffix%), tmp$, 0  '        "
         Heap 11, gPRNheapID, "pWard", tmp$, 0                          '        "
         Heap 10, gPRNheapID, "pWard" & Format$(suffix%), tmp$, 0       '        "
         Heap 11, gPRNheapID, "OCXBedno", tmp$, 0                       '        "
         Heap 10, gPRNheapID, "OCXBedno" & Format$(suffix%), tmp$, 0    '        "
         Heap 11, gPRNheapID, "iLocalcode", tmp$, 0                     '        "
         Heap 10, gPRNheapID, "iLocalcode" & Format$(suffix%), tmp$, 0  '        "
         Heap 11, gPRNheapID, "pSpecialty", tmp$, 0                     '        "
         Heap 10, gPRNheapID, "pSpecialty" & Format$(suffix%), tmp$, 0  '        "
         Heap 11, gPRNheapID, "OCXuserID", tmp$, 0                      '        "
         Heap 10, gPRNheapID, "OCXuserID" & Format$(suffix%), tmp$, 0   '        "
         Heap 11, gPRNheapID, "pAddress1", tmp$, 0                      '06May00 CFY Added
         Heap 10, gPRNheapID, "pAddress1" & Format$(suffix%), tmp$, 0   '        "
      Else
         'Add total figures onto the heap
         For i = 1 To 15
            If TotalUnits!(i) > 0 Then
               If Int(TotalUnits!(i)) < TotalUnits!(i) Then
                  Heap 10, gPRNheapID, "rtotalunits" & Format$(i), Format$(Int(TotalUnits!(i) + 1)), 0   'rounded version
               Else
                  Heap 10, gPRNheapID, "rtotalunits" & Format$(i), Format$(TotalUnits!(i)), 0            'rounded version
               End If
               Heap 10, gPRNheapID, "totalunits" & Format$(i), Format$(TotalUnits!(i)), 0             'non-rounded version
            End If
            
            If totalQty!(i) > 0 Then
                  Heap 10, gPRNheapID, "itemqty" & Format$(i), Format$(totalQty!(i)), 0   '21Jan99 CFY Added
               End If
         Next
         If TotalVol! > 0 Then
            If Int(TotalVol!) < TotalVol! Then
               Heap 10, gPRNheapID, "rtotalvol", Format$(Int(TotalVol!) + 1), 0  'rounded version
            Else
               Heap 10, gPRNheapID, "rtotalvol", Format$(TotalVol!), 0           'rounded version
            End If
            Heap 10, gPRNheapID, "totalvol", Format$(TotalVol!), 0            'non-rounded version
            TotalDiff! = TotalVol! - TotalIngVol!
            If Int(TotalDiff!) < TotalDiff! Then
               Heap 10, gPRNheapID, "rtotalvoldiff", Format$(Int(TotalDiff!) + 1), 0  'rounded version
            Else
               Heap 10, gPRNheapID, "rtotalvoldiff", Format$(TotalDiff!), 0           'rounded version
            End If
            sglTotalDiffperDose = sngVolperdose - sngIngVolperdose
            If Int(TotalDiff!) < TotalDiff! Then
               Heap 10, gPRNheapID, "rvoldiff", Format$(Int(sglTotalDiffperDose) + 1), 0  'rounded version
               Heap 10, gPRNheapID, "rvoldiff/dse", Format$(Int(sglTotalDiffperDose) + 1), 0
            Else
               Heap 10, gPRNheapID, "rvoldiff", Format$(sglTotalDiffperDose), 0           'rounded version
               Heap 10, gPRNheapID, "rvoldiff/dse", Format$(sglTotalDiffperDose), 0
            End If
            'Heap 10, gPRNheapID, "voldiff", Format$(TotalDiff!), 0            'non-rounded version ''
            '16Mar15 TH Reworked and added elements (TFS 148108)
            Heap 10, gPRNheapID, "voldiff", Format$(sglTotalDiffperDose), 0      'This needs to be the volume diff between vol and ingvol Per Dose
            Heap 10, gPRNheapID, "voldiff/dse", Format$(sglTotalDiffperDose), 0  'This needs to be the volume diff between vol and ingvol Per Dose
            Heap 10, gPRNheapID, "totalvoldiff", Format$(TotalDiff!), 0          'This needs to be the volume diff between total vol and total ingvol Per Dose
         End If
      End If
      
  
End Sub

Function strYearCharacter() As String
'18Jul00 AJK : Created
' Returns a string with A to Z to denote year
' A = 2000, B = 2001 etc until Z = 2025
' a = 2026, b = 2027 etc until z = 2051
' By 2052 I doubt the system will still be in use !
'
' Inputs : None
' Outputs : None
' Returns : A-Z, a-z depending in input
'
'21Nov01 CKJ Added 'As String' to the function. This was returning a variant despite its name
'            Replaced the huge Case statement with compact function & improved the error message
                                              
Dim intYear As Integer

   intYear = Year(Now)
   Select Case intYear
      Case 2000 To 2025
         strYearCharacter = Chr$(intYear - 2000 + 65)       '2000="A" [65], 2025="Z" [90]
      Case 2026 To 2051
         strYearCharacter = Chr$(intYear - 2026 + 97)       '2026="a" [97], 2051="z" [122]
      Case Else
         popmessagecr ".", "Cannot define prefix for current Year " & Format$(intYear) & crlf & "Therefore using year code 'A'"
         strYearCharacter = "A"
      End Select

End Function

Sub CIVASTransactionRollBack(ByVal blnProduct As Boolean, ByVal blnBatch As Boolean)
'(PatRecNo$, prescriptionid&, NSVCode$, LblType$, startdate$, ActionMsg$, success%)
'04Jun99 CFY Written based on CancelTransactions. I originally intended this to be a generic routine that could
'            be used to replace the CancelTransactions in OCX.bas but have decided against this for now. This is
'            because at present the routine is too simplistic and limiting when applied to returning CIVAS products
'            and needs expanding (I'm not sure how yet). However I think the code will eventually become too specific
'            in handling CIVAS products and should therefore remain a separate routine within formula.bas.
'27Sep99 CFY Corrected and simplified transaction rollback.
'21Jun00 TH  Change to cope with exvat costs on MB rollbacks
'20Mar13 TH  Ensure that we dont even begin to return stuff with no batch number (TFS 36402)
'25Jul13 TH (TFS 69663) Now we need to also exclude any Bond Store releases as these are not true returns
'                       on the previous returns check(like MANU records)
'22Aug13 TH Major overhaul to allow bond and QA issues to be handled (TFS 71827)
'18Aug15 XN  64575  Enable proper rollack of manufactured items

Dim tofind$, filename$, errcode%, msg$, fil%, pointer&, length%, recno&, issueunitcost$
Dim Increment&
Dim t As transaction, dlocal As DrugParameters
Dim rsLogs As ADODB.Recordset
Dim strParams As String
Dim batches() As String
Dim PrescriptionNum() As String
Dim batchDates() As String
Dim intReturnQty As Integer
Dim intBatches As Integer
Dim strBatchNumber As String
Dim strPrescriptionNum As String
Dim strBatchDate As String
Dim Menu$(), menuhlp%()
Dim intloop As Integer
Dim strAns As String
Dim strDesc As String
Dim rsLock As ADODB.Recordset
Dim blnOK As Boolean, lngOK As Long
Dim sglQty As Single
Dim rsBatchStock As ADODB.Recordset
Dim strDate As String
Dim strTime As String
Dim strExpiry As String
Dim blnPreReturned As Boolean
Dim blnBond As Boolean



   Screen.MousePointer = HOURGLASS
         
   If blnBatch Then
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
                  
      Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pWTranslogforCIVASreturn", strParams)
   Else
      'Check we are returning a dispensing line only
      If L.RequestID = 0 Then
      End If
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, L.RequestID)
                  
      Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pWTranslogSelectbyRequestID_DispensingandSiteID", strParams)
   End If
   If rsLogs.RecordCount > 0 Then
      'If there are multiple batches then we need to get the correct batch to return against.
      intBatches = 0
      Do While Not rsLogs.EOF
         If RtrimGetField(rsLogs!labeltype) = "M" And RtrimGetField(rsLogs!BatchNum) <> "" And _
            (IsNull(rsLogs!BatchQty) Or Abs(Val(RtrimGetField(rsLogs!Qty)) / Val(RtrimGetField(rsLogs!convfact))) = Val(RtrimGetField(rsLogs!BatchQty))) Then
            If intBatches > 0 Then
               If batches(intBatches) <> RtrimGetField(rsLogs!BatchNum) Then
                  intBatches = intBatches + 1
                  ReDim Preserve batches(intBatches)
                  batches(intBatches) = RtrimGetField(rsLogs!BatchNum)
                  ReDim Preserve PrescriptionNum(intBatches)
                  PrescriptionNum(intBatches) = RtrimGetField(rsLogs!PrescriptionNum)
                  ReDim Preserve batchDates(intBatches)
                  batchDates(intBatches) = RtrimGetField(rsLogs!date)
               End If
            Else
               intBatches = intBatches + 1
               ReDim batches(intBatches)
               batches(intBatches) = RtrimGetField(rsLogs!BatchNum)
               ReDim Preserve PrescriptionNum(intBatches)
               PrescriptionNum(intBatches) = RtrimGetField(rsLogs!PrescriptionNum)
               ReDim Preserve batchDates(intBatches)
               batchDates(intBatches) = RtrimGetField(rsLogs!date)
            End If
         End If
         rsLogs.MoveNext
      Loop
      ''22Aug13 TH OK - we also need to check the Bondstore (TFS 71827)
      If blnBatch Then
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
                     
         Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pWTranslogforCIVASreturnBONDSTORE", strParams)
         Do While Not rsLogs.EOF
            If Val(RtrimGetField(rsLogs!Qty)) > 0 Then
               If intBatches > 0 Then
                  If batches(intBatches) <> RtrimGetField(rsLogs!BatchNum) Then
                     intBatches = intBatches + 1
                     ReDim Preserve batches(intBatches)
                     batches(intBatches) = RtrimGetField(rsLogs!BatchNum)
                     ReDim Preserve PrescriptionNum(intBatches)
                     PrescriptionNum(intBatches) = RtrimGetField(rsLogs!PrescriptionNum)
                     ReDim Preserve batchDates(intBatches)
                     batchDates(intBatches) = RtrimGetField(rsLogs!date)
                  End If
               Else
                  intBatches = intBatches + 1
                  ReDim batches(intBatches)
                  batches(intBatches) = RtrimGetField(rsLogs!BatchNum)
                  ReDim Preserve PrescriptionNum(intBatches)
                  PrescriptionNum(intBatches) = RtrimGetField(rsLogs!PrescriptionNum)
                  ReDim Preserve batchDates(intBatches)
                  batchDates(intBatches) = RtrimGetField(rsLogs!date)
               End If
            End If
            rsLogs.MoveNext
         Loop
      End If
               
      If intBatches > 1 Then
         'OK multiple batches from this so we need to select just the one
         ReDim Menu$(intBatches)
         ReDim menuhlp%(intBatches)
         Menu$(0) = "Return CIVAS Batch"
         For intloop = 1 To intBatches
            Menu$(intloop) = batches(intloop)
         Next
         Screen.MousePointer = STDCURSOR
         inputmenu Menu$(), menuhlp%(), strAns, k
         If Not k.escd Or Val(strAns) < 1 Then
            strBatchNumber = batches(Val(strAns))
            strPrescriptionNum = PrescriptionNum(Val(strAns))
            strBatchDate = batchDates(Val(strAns))
         End If
         '22Aug13 TH New section to handle Bond returns (TFS 71827)
         If Trim$(strBatchNumber) <> "" And blnBatch Then
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 15, strBatchNumber)
            If gTransport.ExecuteSelectReturnSP(g_SessionID, "pBatchInPharmacyBondStoreComplete", strParams) Then
               'Already out of BOND
               popmessagecr "EMIS Health", "Batch : " & Trim$(strBatchNumber) & " has already been through the bond store. This batch cannot be returned."
               k.escd = True
            ElseIf gTransport.ExecuteSelectReturnSP(g_SessionID, "pBatchInPharmacyBondStore", strParams) Then
               strAns = "Y"
               Screen.MousePointer = STDCURSOR
               askwin "Manufacturing Return", "This Batch is currently in the Bondstore." & crlf & crlf & "OK to return batch : " & strBatchNumber, strAns, k
               If strAns <> "Y" Then k.escd = True
               blnBond = True
            'If Bond then store this knowledge so we can skip locking batchstocklevel table
            End If
         End If
      Else
         strBatchNumber = batches(1)
         strPrescriptionNum = PrescriptionNum(1)
         strBatchDate = batchDates(1)
         If blnBatch Then
            ' Find the prescription number for the batch
            '22Aug13 TH New section to handle Bond returns (TFS 71827)
            'We need to check if this has been through BOND If so we cannot proceed as this must have been made
            'This should also be a check on if it is currently in Bond if so we must also ask
            If Trim$(strBatchNumber) <> "" Then
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 15, strBatchNumber)
               If gTransport.ExecuteSelectReturnSP(g_SessionID, "pBatchInPharmacyBondStoreComplete", strParams) Then
                  'Already out of BOND
                  popmessagecr "EMIS Health", "Batch : " & Trim$(strBatchNumber) & " has already been through the bond store. This batch cannot be returned."
                  k.escd = True
               ElseIf gTransport.ExecuteSelectReturnSP(g_SessionID, "pBatchInPharmacyBondStore", strParams) Then
                  strAns = "Y"
                  Screen.MousePointer = STDCURSOR
                  askwin "Manufacturing Return", "This Batch is currently in the Bondstore." & crlf & crlf & "OK to return batch : " & strBatchNumber, strAns, k
                  If strAns <> "Y" Then k.escd = True
                  blnBond = True
               'If Bond then store this knowledge so we can skip locking batchstocklevel table
               Else
                  strAns = "Y"
                  Screen.MousePointer = STDCURSOR
                  askwin "Manufacturing Return", "OK to return batch : " & strBatchNumber, strAns, k
                  If strAns <> "Y" Then k.escd = True
               End If
            End If
         End If
      End If
      
      If Trim$(strBatchNumber) = "" And Not k.escd Then  '20Mar13 TH Ensure that we dont even begin to return stuff with no batch number (TFS 36402) '22Aug13 TH Added k.escd
         'popmessagecr "Ascribe", "It is not possible to return a blank batch"
         msg$ = "It is not possible to return a blank batch"
      Else
         Screen.MousePointer = HOURGLASS
        ' XN 18Aug15 moved to sp below 64575
         'If Not k.escd And blnBatch Then
            'rsLogs.Close
            'Set rsLogs = Nothing
            'strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        'gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 15, strBatchNumber) ''****& _
                        ''***gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 7, strBatchNumber)
                     
            'Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pWTranslogbyBatchnumforCIVASreturn", strParams)
         
         'End If
      
         If (Not k.escd) And (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "CIVASReturn", "Y", "CIVASCheckPreviousReturn", 0))) Then
          'First lets do a pass to see if there are any previous returns here.If so lets warn the user first
            'blnPreReturned = False
            'rsLogs.MoveFirst
            'Do While Not rsLogs.EOF And blnPreReturned = False
               'WHat criteria do we need
               'If (RtrimGetField(rsLogs!BatchNum) = strBatchNumber) And (Val(RtrimGetField(rsLogs!Qty)) < 0) And (UCase$(RtrimGetField(rsLogs!ward)) <> UCase$(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "MANU", "CostCentre", 0))) Then blnPreReturned = True
               '25Jul13 TH (TFS 69663) Now we need to also exclude any Bond Store releases as these are not true returns (like MANU records)
               'If (RtrimGetField(rsLogs!BatchNum) = strBatchNumber) And (Val(RtrimGetField(rsLogs!Qty)) < 0) And (UCase$(RtrimGetField(rsLogs!ward)) <> UCase$(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "MANU", "CostCentre", 0))) And (UCase$(RtrimGetField(rsLogs!ward)) <> UCase$(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "BOND", "BONDCostCentre", 0))) Then blnPreReturned = True
               'rsLogs.MoveNext
            'Loop
            
            'If blnPreReturned Then
            strParams = gTransport.CreateInputParameterXML("Date", trnDataTypeVarChar, 30, strBatchDate) & _
                        gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 10, d.SisCode) & _
                        gTransport.CreateInputParameterXML("Batchnumber", trnDataTypeChar, 25, strBatchNumber) & _
                        gTransport.CreateInputParameterXML("IgnoreWardCode", trnDataTypeVarChar, 25, TxtD(dispdata$ & "\patmed.ini", "manufacturing", "BOND", "BONDCostCentre", 0))
            If gTransport.ExecuteSelectReturnSP(g_SessionID, "pWTranslogHasCIVASBatchBeenReturned", strParams) Then
               strAns = "Y"
               askwin "CIVAS Return", "A previous return for this batch has been detected. Check logs for details. Do you wish to continue the return ?", strAns, k
               If strAns <> "Y" Then k.escd = True
            End If
         End If
         
         If Not k.escd Then
            rsLogs.Close
            Set rsLogs = Nothing
            strParams = gTransport.CreateInputParameterXML("Date", trnDataTypeVarChar, 30, strBatchDate) & _
                        gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 15, strPrescriptionNum) ''****& _
                        ''***gTransport.CreateInputParameterXML("Batchnum", trnDataTypeVarChar, 7, strBatchNumber)
                     Dim a As Date
                     
            Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pWTranslogbyPrescriptionNumforCIVASreturn", strParams)
         End If
         
         If Not k.escd Then
            ' Find highest row with prescription and batch number are set
            ' This is the final dispensing of the finished product
            ' XN 18Aug15 64575
            rsLogs.MoveFirst
            Do While Not rsLogs.EOF
                If strPrescriptionNum = RtrimGetField(rsLogs!PrescriptionNum) And strBatchNumber = RtrimGetField(rsLogs!BatchNum) Then
                    Exit Do
                End If
                
                rsLogs.MoveNext
            Loop
               
            Dim bFirstItem As Boolean
            bFirstItem = True
            Do While Not rsLogs.EOF
                If strPrescriptionNum = RtrimGetField(rsLogs!PrescriptionNum) And (RtrimGetField(rsLogs!kind) = "M" Or bFirstItem) Then
                  bFirstItem = False
                  gcivasbatch = strBatchNumber
                  setbatchnum strBatchNumber
                  'WE SHOULD CHANGE SITE HERE -NO
                  
                  dlocal.SisCode = RtrimGetField(rsLogs!SisCode)                                                                                                                           '27Sep99 CFY Replaces above block
                  getdrug dlocal, 0, 0, 0
                                          
                  gCIVASdos$ = Format$(Val(RtrimGetField(rsLogs!civasamount)) * -1) 'TH added
                  If blnBatch Then
                     'If RtrimGetField(rsLogs!labeltype) = "M" Then                                                                                                                            '         "
                        'IssueUnitCost$ = Format$(Val(t.cost) * -1)
                     'If RtrimGetField(rsLogs!labeltype) = "M" And (RtrimGetField(rsLogs!dircode) = strBatchNumber) And (Val(RtrimGetField(rsLogs!Qty)) < 0) Then 'This is the actual product
                     If RtrimGetField(rsLogs!labeltype) = "M" And (RtrimGetField(rsLogs!dircode) = strBatchNumber) And (Val(RtrimGetField(rsLogs!Qty)) < 0) Then 'This is the actual product
                        'Lock the batch stock table
                        If Not blnBond Then '22Aug13 TH  (TFS 71827)
                        Set rsLock = TableRowLock("WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID)
                        If rsLock.EOF Or rsLock.RecordCount > 1 Then
   ''                        Do While gTransport.IsInTransaction(g_SessionID)
   ''                           'Here are going to rollback ay outstanding transactions prior to msg display
   ''                           'We keep a count so we can reinstitute them
   ''                           If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
   ''                           intCount = intCount + 1
   ''                        Loop
   ''                        'Maybe not allow back out if not transactional !!!
   ''                        strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & "Reason Unknown" & _
   ''                                 crlf & crlf & "OK to Retry ? (No Will exit Application)"
   ''                        strAns = "Y"
   ''                        popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
   ''                        If strAns = "N" Then
   ''                           'Exit App
   ''                           GoTo CloseApplication
   ''                        Else
                              blnOK = False
   ''                        End If
                        Else
                           If GetField(rsLock!sessionID) = g_SessionID Then
                              blnOK = True 'There is a lock - it is ours !
                           Else
                           'Geuine lock from another identifiable source
   ''                           Do While gTransport.IsInTransaction(g_SessionID)
   ''                              'Here are going to rollback ay outstanding transactions prior to msg display
   ''                              'We keep a count so we can reinstitute them
   ''                              If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
   ''                              intCount = intCount + 1
   ''                           Loop
   ''                           strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & _
   ''                                    "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
   ''                                    crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
   ''                           strAns = "Y"
   ''                           popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
   ''                           If strAns = "N" Then
   ''                              'Exit App
   ''                              GoTo CloseApplication
   ''                           Else
                                 blnOK = False
   ''                           End If
                           
                           End If
                        End If
                        End If
                     
                     
                        issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)   '21Jun00 TH Added to cope with exvat costs on MB rollbacks
                        Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN", issueunitcost$              '         "
                        'Update the batch stock table
                        If Not blnBond Then '22Aug13 TH (TFS 71827)
                           If blnOK Then lngOK = PutBatchStockLevelQtySQl(RtrimGetField(rsLogs!WBatchStockLevelID), ((Val(RtrimGetField(rsLogs!Qty) * -1) / RtrimGetField(rsLogs!convfact))))
                           TableRowUnLock "WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID
                        End If
                     Else
                        If (Val(RtrimGetField(rsLogs!Qty)) > 0) And (RtrimGetField(rsLogs!dircode) = "") Then
                           '26Aug09 TH Added batch handling to get rid of the batch
                           '26Aug09 TH ****''''
                           'Here we must loop until we get the correct product !!!!!
                           ''Do While Not rsLogs.EOF
                           ''   If rsLogs!SisCode = dlocal.SisCode Then Exit Do 'now we should have the correct batchID to return the batchqty
                           ''   rsLogs.MoveNext
                           ''
                           ''Loop
                                                   '18Aug15 XN 64575 rollback batch stock level
                           'Set rsLock = TableRowLock("WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID)
                           'If rsLock.EOF Or rsLock.RecordCount > 1 Then
                           '   blnOK = False
                           'Else
                           '   If GetField(rsLock!sessionID) = g_SessionID Then
                           '      blnOK = True 'There is a lock - it is ours !
                           '   Else
                           '      blnOK = False
                           '  End If
                           'End If
                           '26Aug09 TH---------
                           issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)   '21Jun00 TH Added to cope with exvat costs on MB rollbacks
                           Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN", issueunitcost$       '         "
                       
                           '26Aug09 TH Added
                           ''If blnOK Then lngOK = PutBatchStockLevelQtySQl(RtrimGetField(rsLogs!WBatchStockLevelID), 0)
                           ''   TableRowUnLock "WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID
                           ''End If
                           ''rsLock.Close
                           ''set rsLock = Nothing
                           '26Aug09 TH---------
                                                   
                           'Update the batch stock table 18Aug15 XN 64575
                           If Not blnBond And Not IsNull(rsLogs!WBatchStockLevelID) Then '22Aug13 TH (TFS 71827)
                              Set rsLock = TableRowLock("WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID)
                              If rsLock.EOF Or rsLock.RecordCount > 1 Then
                                blnOK = False
                              Else
                                blnOK = GetField(rsLock!sessionID) = g_SessionID
                              End If
                           
                              If blnOK Then lngOK = PutBatchStockLevelQtySQl(RtrimGetField(rsLogs!WBatchStockLevelID), ((Val(RtrimGetField(rsLogs!Qty) * -1) / RtrimGetField(rsLogs!convfact))))
                              TableRowUnLock "WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID
                           End If
                        '22Aug13 TH New section to handle Bond returns (TFS 71827)
                        ElseIf (Val(RtrimGetField(rsLogs!Qty)) > 0) And (RtrimGetField(rsLogs!dircode) = strBatchNumber) And (UCase$(RtrimGetField(rsLogs!ward)) = UCase$(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "BOND", "BONDCostCentre", 0))) Then
                           'THis is a Bond Issue - we will now get this back from Bond
                           issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)
                           Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN", issueunitcost$       '         "
                           
                           '27Aug13 TH WE will also need to remove the BOND record from the bond store (TFS 72012)
                           DeleteFromBondStore dlocal.SisCode, strBatchNumber
                           
                        '22Aug13 TH New section to handle QA returns (TFS 71827)
                        ElseIf (Val(RtrimGetField(rsLogs!Qty)) > 0) And (RtrimGetField(rsLogs!dircode) = strBatchNumber) And (UCase$(RtrimGetField(rsLogs!ward)) = UCase$(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "QA", "QACostCentre", 0))) Then
                           'THis is a QA Issue - we will now get this back from QA
                           issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)
                           Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN", issueunitcost$       '         "
                       
                        End If
                     End If
                  ElseIf Not blnProduct Then                    'We are doing the whole item + ingredients
                     If RtrimGetField(rsLogs!labeltype) = "M" Then                                                                                                                            '         "
                        'IssueUnitCost$ = Format$(Val(t.cost) * -1)
                        If RtrimGetField(rsLogs!labeltype) = "M" And RtrimGetField(rsLogs!kind) <> "M" Then  'This is the actual product
                           If (Val(RtrimGetField(rsLogs!Qty)) > 0) Then
                              issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)   '21Jun00 TH Added to cope with exvat costs on MB rollbacks
                              Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MB", issueunitcost$              '         "
                           End If
                        Else 'this should be the balancing record
                           If (Val(RtrimGetField(rsLogs!Qty)) < 0) Then
                              issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)   '21Jun00 TH Added to cope with exvat costs on MB rollbacks
                              Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MB", issueunitcost$              '         "
                           End If
                        End If
                     Else
                        If (Val(RtrimGetField(rsLogs!Qty)) > 0) Then
                           'Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), RtrimGetField(rsLogs!labeltype), issueunitcost$       '         "
                           issueunitcost$ = Format$(Val(RtrimGetField(rsLogs!cost)) * -1) & Chr$(160) & Format$(Val(RtrimGetField(rsLogs!CostExTax)) * -1)   '21Jun00 TH Added to cope with exvat costs on MB rollbacks
                           Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), Val(RtrimGetField(rsLogs!Qty)) * -1, RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN_ING", issueunitcost$       '         "
                           
                           'Update the batch stock table 18Aug15 XN 64575
                           If Not blnBond And Not IsNull(rsLogs!WBatchStockLevelID) Then '22Aug13 TH (TFS 71827)
                              Set rsLock = TableRowLock("WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID)
                              If rsLock.EOF Or rsLock.RecordCount > 1 Then
                                blnOK = False
                              Else
                                blnOK = GetField(rsLock!sessionID) = g_SessionID
                              End If
                           
                              If blnOK Then lngOK = PutBatchStockLevelQtySQl(RtrimGetField(rsLogs!WBatchStockLevelID), ((Val(RtrimGetField(rsLogs!Qty) * -1) / RtrimGetField(rsLogs!convfact))))
                              TableRowUnLock "WBatchStockLevel", RtrimGetField(rsLogs!WBatchStockLevelID), g_SessionID
                           End If
                        End If
                     End If
      
                  Else 'We are looking at just the manufactured product here
                     If RtrimGetField(rsLogs!labeltype) = "M" And RtrimGetField(rsLogs!kind) <> "M" Then
                        If (Val(RtrimGetField(rsLogs!Qty)) > 0) Then     '17Nov05 TH/PJC Fenceposts to stop 'return of a return'
                           'OK the product is being returned. We now prompt the user who can make a partial return if required
   ''                        If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVASReturnUseDose", 0)) Then
   ''                           strAns = Format$(Abs(Val(RtrimGetField(rsLogs!CivasDose))))
   ''                        Else
   ''                           strAns = Format$(Abs(Val(RtrimGetField(rsLogs!Qty))))
   ''                        End If
                          
                           'strDesc = Trim$(d.storesdescription)
                           'If Trim$(strDesc) = "" Then strDesc = Trim$(d.Description)
                                                   strDesc = Trim$(d.DrugDescription)   'XN 4Jun15 98073 New local stores description
                           plingparse strDesc, "!"
                           Screen.MousePointer = STDCURSOR
                           Do
                              'strAns = Format$(Abs(Val(RtrimGetField(rsLogs!Qty))))
                              If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "CIVASReturn", "Y", "CIVASReturnUseDose", 0)) Then
                                 k.decimals = False
                                 k.nums = True
                                 strAns = Format$(Abs(Val(RtrimGetField(rsLogs!civasamount))))
                                 InputWin "CIVAS Return", strDesc & crlf & crlf & "Enter number of doses to return", strAns, k
                                 If Val(strAns) <= 0 Then
                                    popmessagecr "CIVAS Return", "No quantity entered. Return will not take place"
                                    k.escd = True
                                 End If
                                 If Val(strAns) > Val(RtrimGetField(rsLogs!civasamount)) Then
                                    popmessagecr "!CIVAS Return", "You are attempting to return more than was manufactured." & crlf & "Please check and re-enter."
                                    strAns = "0"
                                 End If
                                 If Not k.escd And Val(strAns) > 0 Then
                                    'Recalibrate from dose to quantity
                                    sglQty = (Val(strAns) / Abs(Val(RtrimGetField(rsLogs!civasamount)))) * (Abs(Val(RtrimGetField(rsLogs!Qty))))
                                    strAns = Format$(dp!(sglQty))
                                 End If
                              Else
                                 k.decimals = True
                                 k.nums = True
                                 strAns = Format$(Abs(Val(RtrimGetField(rsLogs!Qty))))
                                 InputWin "CIVAS Return", strDesc & crlf & crlf & "Enter quantity to return in " & Trim$(d.PrintformV), strAns, k
                                 If Val(strAns) <= 0 Then
                                    popmessagecr "CIVAS Return", "No quantity entered. Return will not take place"
                                    k.escd = True
                                 End If
                                 If Val(strAns) > Val(RtrimGetField(rsLogs!Qty)) Then
                                    popmessagecr "!CIVAS Return", "You are attempting to return more han was manufactured." & crlf & "Please check and re-enter."
                                    strAns = "0"
                                 End If
                              End If
                              
                           Loop While Not k.escd And Val(strAns) = 0
                           Screen.MousePointer = HOURGLASS
                           k.nums = False
                           k.decimals = False
                           sglQty = Val(strAns) / Abs(Val(RtrimGetField(rsLogs!Qty)))
                           If Not k.escd Then
                              issueunitcost$ = Format$(dp!((Val(RtrimGetField(rsLogs!cost)) * -1) * sglQty)) & Chr$(160) & Format$(dp!((Val(RtrimGetField(rsLogs!CostExTax)) * -1) * sglQty))
                              Translog dlocal, 0, UserID$, RtrimGetField(rsLogs!patid), (Val(RtrimGetField(rsLogs!Qty) * -1) * sglQty), RtrimGetField(rsLogs!dircode), RtrimGetField(rsLogs!ward), RtrimGetField(rsLogs!consultant), RtrimGetField(rsLogs!kind), Val(RtrimGetField(rsLogs!site)), "MBRETURN", issueunitcost$      '         "
                              'We now need to update the batch information so that this item can be batch issued at a later date.
                              'First search for a batch entry in the table
                              strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                          gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, dlocal.SisCode) & _
                                          gTransport.CreateInputParameterXML("BatchNumber", trnDataTypeVarChar, 15, strBatchNumber)
                                          
                              Set rsBatchStock = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLevelbySiteandNSVCodeandBatchReturns", strParams)
                              If rsBatchStock.RecordCount > 0 Then
                                 rsBatchStock.MoveFirst
                                 'Lock and update
                                 Set rsLock = TableRowLock("WBatchStockLevel", RtrimGetField(rsBatchStock!WBatchStockLevelID), g_SessionID)
                                 If rsLock.EOF Or rsLock.RecordCount > 1 Then
            ''                        Do While gTransport.IsInTransaction(g_SessionID)
            ''                           'Here are going to rollback ay outstanding transactions prior to msg display
            ''                           'We keep a count so we can reinstitute them
            ''                           If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
            ''                           intCount = intCount + 1
            ''                        Loop
            ''                        'Maybe not allow back out if not transactional !!!
            ''                        strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & "Reason Unknown" & _
            ''                                 crlf & crlf & "OK to Retry ? (No Will exit Application)"
            ''                        strAns = "Y"
            ''                        popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
            ''                        If strAns = "N" Then
            ''                           'Exit App
            ''                           GoTo CloseApplication
            ''                        Else
                                       blnOK = False
            ''                        End If
                                 Else
                                    If GetField(rsLock!sessionID) = g_SessionID Then
                                       blnOK = True 'There is a lock - it is ours !
                                    Else
                                    'Geuine lock from another identifiable source
            ''                           Do While gTransport.IsInTransaction(g_SessionID)
            ''                              'Here are going to rollback ay outstanding transactions prior to msg display
            ''                              'We keep a count so we can reinstitute them
            ''                              If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
            ''                              intCount = intCount + 1
            ''                           Loop
            ''                           strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & _
            ''                                    "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
            ''                                    crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
            ''                           strAns = "Y"
            ''                           popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
            ''                           If strAns = "N" Then
            ''                              'Exit App
            ''                              GoTo CloseApplication
            ''                           Else
                                          blnOK = False
            ''                           End If
                                    
                                    End If
                                 End If
                                 If blnOK Then lngOK = PutBatchStockLevelQtySQl(RtrimGetField(rsBatchStock!WBatchStockLevelID), (rsBatchStock!Qty) + (Val(RtrimGetField(rsLogs!Qty) * -1) * sglQty))
                                 TableRowUnLock "WBatchStockLevel", RtrimGetField(rsBatchStock!WBatchStockLevelID), g_SessionID
                                 rsBatchStock.Close
                                 Set rsBatchStock = Nothing
                                 rsLock.Close
                                 Set rsLock = Nothing
                              Else
                                 'Insert
                                 rsBatchStock.Close
                                 Set rsBatchStock = Nothing
                                 'Calculate expiry date based on the original issue date
                                 'rsLogs!Qty
                                 strDate = Format$(RtrimGetField(rsLogs!logdatetime), "DD/MM/YYYY")
                                 strTime = Format$(RtrimGetField(rsLogs!logdatetime), "HH:MM:SS")
                                 MakeExpiry k, strDate, strTime, strExpiry
                                 AddStockOfBatch d.SisCode, strExpiry, (Val(RtrimGetField(rsLogs!Qty)) * sglQty), strBatchNumber 'There is no Expiry !!!
                              
                              End If
                           End If
                        End If
                     End If                                                                                                                                            '         "
      
                  End If
                  '17Nov05 TH Added section
                  'If t.labeltype = "C" And NSVCode$ <> "" Then setm_sgnCivasDose Val(gCIVASdos$)
                  'If RtrimGetField(rsLogs!labeltype) = "C" And Not blnProduct Then setm_sgnCivasDose Val(gCIVASdos$)
                  If RtrimGetField(rsLogs!labeltype) = "C" Then setm_sgnCivasDose (Val(RtrimGetField(rsLogs!civasamount)) * -1)
                  gcivasbatch = ""
                  gCIVASdos$ = ""
                  setbatchnum ""
                  '----------
               End If
               rsLogs.MoveNext
            Loop
         End If
      End If '--20M1r13 TH We have no batch
   Else
      'Cant find the associated Translog records. Most likely cos in wrong site
      Screen.MousePointer = STDCURSOR
      If blnBatch Then
         popmessagecr "Manufacturing Return", "No batches are available for the return of this item"
      Else
         popmessagecr "Manufacturing Return", "Cannot return this Item. Check you are logged in to the original dispensing site"
      End If
   End If
   rsLogs.Close
   Set rsLogs = Nothing
   Screen.MousePointer = STDCURSOR
   
   If Len(msg$) Then popmessagecr "!", msg$

End Sub

Sub UpdateDispensLabel()
'01Oct02 TH Written  - May require more stuff in here
'This is used to update the label after a manufacturing issue (via the formula button) from the front screen

Dim sglQty As Single
   GetManufactureInfo sglQty, 0
   L.lastqty = L.lastqty + sglQty
   If L.BasePrescriptionID = 0 Then L.BasePrescriptionID = L.PrescriptionID '07Jun07 TH This should be handled elsewhere surely !
   
   SaveLabel 0

End Sub

Sub AllocateNewBatchNumber(batchnumber$)
'13Jul96 ASC Taken from TPNW and Batchnumber$ used for use by both TPN and manufacturing
'18Jul00 AJK Called function strYearCharacter.
'21Nov01 CKJ Changed '+' to '&' as this caused Type Mismatch with strYearCharacter once DEFINT A-Z added
'            Changed use of Date$ to Now()
'02Aug16 XN  159413 If setting D|Patmed.ManufacturingBatchNumber.UseWeb is on will get the manufacturing batch number from the web (from PharmacyCounter table)
'08Aug16 XN  159843 Fixed to getting web based batch number

Dim datechan, datefile$, numberfile$, BNTptr&, writedate$, BNT%


   datechan = FreeFile
   '!!** need err70msg
   Select Case batchnumber$
      Case "T"
         datefile$ = "\readdate.dat"
         numberfile$ = "\BNT.V5"
         batchnumber$ = ""
      Case "M"
         datefile$ = "\manudate.dat"
         numberfile$ = "\BNM.V75"
      Case Else
         popmessagecr "Error", "Batch number mode not defined for allocation"
   End Select

   '02Aug16 XN 159413 If setting D|Patmed.ManufacturingBatchNumber.UseWeb is on will get the manufacturing batch number from the web (from PharmacyCounter table)
   If batchnumber = "M" And TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "ManufacturingBatchNumber", "N", "UseWeb", 0)) Then
      batchnumber$ = CallWebMethod("application/pharmacysharedscripts/HelperWebService.asmx", "GetNextCountStr", "<sessionID>" + Format(g_SessionID) + "</sessionID><siteID>" + Format(gDispSite) + "</siteID><system>D|BNM.V75</system><section>Manufacturing</section><key>BatchNumber</key>")
      If batchnumber$ <> "" Then
        Exit Sub
      End If
   End If
   
   Open dispdata$ + datefile$ For Random As datechan Len = 12 'Len was 10 13Jul96 ASC
   Get datechan, 1, writedate$
   If date$ <> writedate$ Then
      BNTptr& = 0
      GetPointerSQL dispdata$ + numberfile$, BNTptr&, 2 '04May05 TH Amended
   End If

   writedate$ = date$
   Put datechan, 1, writedate$
   Close datechan
   GetPointerSQL dispdata$ + numberfile$, BNTptr&, True ' read, add 1, write, return value
   BNT% = BNTptr& Mod 1000

   'ajk 14/06/00 Use strYearCharacter so set an alphabetical chararacter for year to get a 26 year cycle
   'batchnumber$ = batchnumber$ & strYearCharacter() + Left$(Date$, 2) + Mid$(Date$, 4, 2) + Right$("000" + LTrim$(Str$(BNT%)), 3) '18Aug95 CKJ added BNT  '15Dec96 added decade to batchnumber ASC  '21Nov01 CKJ
   batchnumber$ = batchnumber$ & strYearCharacter() & Format$(Now, "MMDD") & Right$("000" & LTrim$(Str$(BNT%)), 3)                 '18Aug95 CKJ added BNT  '15Dec96 added decade to batchnumber ASC  '21Nov01 CKJ
  
End Sub
Function getFormulaFromDispense() As Boolean
getFormulaFromDispense = m_blnFromDispens
End Function
Function getm_sgnCivasDose() As Single
'22Sep05 TH Written (#)
        getm_sgnCivasDose = m_sgnCivasDose
End Function
Sub setm_sgnCivasDose(ByVal sngCivasDose As Single)
'22Sep05 TH Written (#)
 m_sgnCivasDose = sngCivasDose
End Sub


Function CIVASDoseIncStat(ByVal labeldose As Single) As Single
'19Jun08 TH Written
'Used to return either the usual dose used previously, or a dose scraped off the direction for stat
'15Sep15 TH Custom frequencies also need a derived dose (TFS 129498)

Dim intSlash As Integer
Dim sglReturn As Single

   sglReturn = labeldose
   'If sglReturn = 0 And (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
   If sglReturn = 0 And ((InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Or isCustomFrequency()) Then '15Sep15 TH Custom frequencies also need a derived dose (TFS 129498)
      intSlash = InStr(txtUC("TxtDircode").text, "/")
      If intSlash > 0 Then
         sglReturn = Val(Left$(txtUC("TxtDircode").text, intSlash - 1))
      End If
   End If
   
   CIVASDoseIncStat = sglReturn
   
End Function
Sub SetDynamicChrome(frm As Form, ByVal Colour_Background As Long)

Dim ctrl As Control
'Dim Colour_Background As Long

   'Colour_Background = &HFFE3D6     '!!** needs setting outside the app
   
   For Each ctrl In frm.Controls
'      Select Case ctrl.ForeColor
'         Case &H80000008
'         Case &H8000000A
'         Case &H80000005
'         End Select
      
'      ctrl.BackColor = &HFFE3D6     'main background
'      ctrl.BackColor = &HC0C0C0     'silver
'      ctrl.BackColor = &HB48246     'bit darker blue
'      ctrl.BackColor = &HA97868     'another blue
'      ctrl.BackColor = &HF0D3C6     'and another
'      ctrl.BackColor = &HE6E0B0     'Paler blue
      
      On Error GoTo ErrorHandler
      
''      If TypeOf ctrl Is CommandButton Then
''         ctrl.Style = 1 ' graphical
''      End If
      If TypeOf ctrl Is StatusBar Then
         SendMessage ctrl.Hwnd, SB_SETBKCOLOR, 0, ByVal Colour_Background
      End If
      
      Select Case ctrl.BackColor
         Case &H80000008
''            Stop
         Case &H8000000A, &HC0C0C0
            ctrl.BackColor = Colour_Background
         Case &H8000000F
            ctrl.BackColor = Colour_Background
         Case &H80000005, &HFFFFFF
            'white is fine for text boxes
         Case Else
''            Debug.Print Hex(ctrl.BackColor), ctrl.name
''            Stop
               ctrl.BackColor = Colour_Background
         End Select
      ctrl.FontName = "Arial"                '!!** for testing

Continue:
   Next

   frm.BackColor = Colour_Background
   
Exit Sub

ErrorHandler:
Resume Continue

End Sub
Sub setFormulaArchiveView(ByVal blnArchiveView As Boolean)
'26Aug09 TH
   m_blnArchiveView = blnArchiveView
End Sub
Sub setSecondAuthorisation(ByVal blnSecondAuthorisation As Boolean)
'26Aug09 TH
   m_blnSecondAuthorisation = blnSecondAuthorisation
End Sub
Function GetSecondAuthorisation() As Boolean
'26Aug09 TH
   GetSecondAuthorisation = m_blnSecondAuthorisation
End Function
Function getaccesslevel() As Integer
'26Aug09 TH
   getaccesslevel = Val(Left$(acclevels$, 1))
End Function
Sub DraftWlayoutWarning(ByVal strLayout As String, ByRef k As kbdcontrol, blnApprove)
'26Aug09 TH Written
Dim strParams As String '26Aug09 TH added (F0054335)
Dim rsResult As ADODB.Recordset
Dim strMsg As String
Dim strDesc As String
Dim strAns As String
Dim intloop As Integer

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Layout", trnDataTypeVarChar, 20, strLayout)
   Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteandLayoutForDraftWarning", strParams)
   
   If Not rsResult.EOF Then
      If rsResult.RecordCount > 30 Then strMsg = "There are more than 30 formulae, only first 30 are shown" & crlf & crlf
      rsResult.MoveFirst
      Do While Not rsResult.EOF
         strDesc = RtrimGetField(rsResult!LabelDescription)
         replace strDesc, "!", " ", 0
         strMsg = strMsg & RtrimGetField(rsResult!SisCode) & "  " & TB & strDesc & crlf
         intloop = intloop + 1
         If intloop = 30 Then Exit Do
         rsResult.MoveNext
      Loop
      If Not blnApprove Then
      strMsg = "OK to add or edit Draft Worksheet Template." & crlf & "WARNING - This worksheet template is used by the following draft and approved formula(e)" & crlf & crlf & strMsg
      Else
      strMsg = "OK to APPROVE this Worksheet Template." & crlf & "WARNING - This worksheet template is used by the following draft and approved formula(e)" & crlf & crlf & strMsg
      End If
      strAns = "N"
      askwin "Manufacturing", strMsg, strAns, k
      If Not strAns = "Y" Then k.escd = True
   End If
   rsResult.Close
   Set rsResult = Nothing


End Sub

Sub WFormulaDraftView()
'26Aug09 TH Written
Dim strParams As String '26Aug09 TH added (F0054335)
Dim rsResult As ADODB.Recordset
Dim strMsg As String
Dim strDesc As String
Dim strAns As String
Dim intloop As Integer

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWFormulabySiteDraftForView", strParams)
   
   If Not rsResult.EOF Then
      If rsResult.RecordCount > 30 Then strMsg = "There are more than 30 draft formulae, only first 30 are shown" & crlf & crlf
      rsResult.MoveFirst
      Do While Not rsResult.EOF
         strDesc = RtrimGetField(rsResult!LabelDescription)
         replace strDesc, "!", " ", 0
         strMsg = strMsg & RtrimGetField(rsResult!SisCode) & "  " & TB & strDesc & crlf
         intloop = intloop + 1
         If intloop = 30 Then Exit Do
         rsResult.MoveNext
      Loop
      strMsg = "Draft status formula(e) currently awaiting approval" & crlf & crlf & strMsg
      strAns = "N"
      popmessagecr "Manufacturing", strMsg
      If Not strAns = "Y" Then k.escd = True
   End If
   
   rsResult.Close
   Set rsResult = Nothing


End Sub

Sub ViewandApproveLayout(ByVal strName As String)
'26Aug09 TH Written
'12Jan17 TH Converted to use rtf from database (Hosted)

'With the name, offer to view various elements of the layout, or approve the whole thing
Dim strResult As String
Dim rsLayout As ADODB.Recordset
Dim strParams As String
Dim blnApproved As Boolean
Dim strRTFText As String

   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, strName)
   Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteandNameDraft", strParams)
   If Not rsLayout.EOF Then
      Do While (Not blnApproved) And (Not k.escd)
         frmoptionset -1, "View or Approve worksheet : " & Trim$(strName)
         frmoptionset 1, "View Layout"
         frmoptionset 1, "View Item Line Text"
         frmoptionset 1, "View Consumable Line Text"
         frmoptionset 1, "Approve " & Trim$(strName) & " worksheet"
         frmoptionshow "1", strResult
         frmoptionset 0, ""
         If Val(strResult) > 0 Then
         
            
            Select Case strResult
            Case "1"
                     'View the layout
                     '13Dec16 TH Load the rtf into string and send that to hi-edit
                     'Write a new sub\function to return the string - this replaces call using file below
                     'Hedit 10, dispdata$ & "\wksheets\Draft\" & RtrimGetField(rsLayout!Layout)
                     strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", RtrimGetField(rsLayout!Layout)) '12Jan17 TH Converted (Hosted)
                     Hedit 0, strRTFText '12Jan17 TH Converted (Hosted)
                     
            Case "2": TextEdit "View Item Line Text", RtrimGetField(rsLayout!LineText), "", False, False
            Case "3": TextEdit "View Ingredient Item Line Text", RtrimGetField(rsLayout!IngLineText), "", False, False
               
            Case "4"
                     'Here we must Approve the Wlayout record
                     'First show a warning of which formulae are "involved"
                     ApproveWLayout strName, RtrimGetField(rsLayout!Layout), (RtrimGetField(rsLayout!VersionNumber) - 1) '09Oct09 TH The version is alwasy 1 hogher as this must be a draft ( 2+)
                     k.escd = True
            Case Else: k.escd = True
            
            End Select
         Else
            k.escd = True
         End If
            
      Loop
   End If
End Sub

Sub ApproveWLayout(ByVal strName As String, ByVal strLayout As String, ByVal intVersion As Integer)
'26Aug09 TH Written
'OK First we find the existing approved layout(if there is one) and we archive the layout to an archive folder (rename the rtf. to_VerionNumber or something)
'Then we change the status of the layout to archived and log this
'Now we load the draft (do we need to check there is a draft before this ?)
'Update the draft to Approved. Log this and out, our work is done (... at least for now)
'11Jan17 TH Replaced all the file handling with new rtf DB layer (Hosted)
'04 Sept18 Bug 221716: Pharmacy Manufacturing - Inability to use a newly created worksheet layout : => when we create layout its inserting entry in PharmacyRTFReport  table with name “WRKSHEET|DRAFT|xxx”.
    'When we approve that layout file name not updating to “WRKSHEET|xxx”

Dim strNewLayout As String
Dim strParams As String
Dim lngOK As Long
Dim strRTFText As String '11Jan17 TH Added (Hosted)

'Lets GO.
   ''''On Error GoTo ApproveWLayout_CopyError
                     
   '11Jan17 TH Removed this as location now logical in DB
   'If Not (DirExists(dispdata$ & "\wksheets\Archive")) Then
   '   MkDir dispdata$ & "\wksheets\Archive"
   'End If
   'If fileexists(dispdata$ & "\wksheets\" & strLayout) Then
   If RTFExistsInDatabase(dispdata$ & "\wksheets\" & strLayout) Then '10Jan17 TH Replaced
      strNewLayout = Left(strLayout, (InStr(strLayout, ".") - 1)) & "_Version" & Format$(intVersion) & ".rtf"
      'FileCopy dispdata$ & "\wksheets\" & strLayout, dispdata$ & "\wksheets\Archive\" & strNewLayout
      'strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\", strLayout)                   '11Jan17 TH Replaced above (Hosted)
      'lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets\Archive\", strNewLayout, strRTFText) '  "
      strNewLayout = "_Version" & Format$(intVersion)
      subRTFExistsInDatabase strLayout, "\wksheets\", "WRKSHEET|", "WRKSHEET|ARCHIVE|", strNewLayout
   End If
   
   'Now Update the Approved record (if there is one).
   lngOK = WLayoutArchive(strName)
   
   'Now Update the Draft
   'If fileexists(dispdata$ & "\wksheets\Draft\" & strLayout) Then
   If RTFExistsInDatabase(dispdata$ & "\wksheets\" & strLayout) Then '10Jan17 TH Replaced
      'delete existing file
      'If fileexists(dispdata$ & "\wksheets\" & strLayout) Then Kill dispdata$ & "\wksheets\" & strLayout '11Jan17 TH We dont need to delete anymore. In the DB we will insert or update
      'copy draft
      'FileCopy dispdata$ & "\wksheets\Draft\" & strLayout, dispdata$ & "\wksheets\" & strLayout  '08Feb17 Th Removed
      strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Draft\", strLayout)                   '11Jan17 TH Replaced above (Hosted)
      lngOK = WritePharmacyRTFToSQL(dispdata$ & "\wksheets\", strLayout, strRTFText) '  "
   End If
   lngOK = WLayoutApprove(strName)
   
   'Log here
   'Update Name in PharmacyRTFReport
   subRTFExistsInDatabase strLayout, "\wksheets\Draft\", "WRKSHEET|DRAFT|", "WRKSHEET|", ""
   

End Sub

Sub subRTFExistsInDatabase(strRTFName As String, rtfFormatType As String, sourceRTFNameFormat As String, destRTFNameFormat As String, versionNo As String)
    Dim strFilename As String
    Dim strParams As String
    Dim strRTFReport As String
    Dim rtfName As String
    Dim intRTFReportId As Integer
    Dim lngOK As Long
    Dim rsRTF As ADODB.Recordset
    Set rsRTF = New ADODB.Recordset
    
    'Read report column value PharmacyRTFReport table
    strRTFReport = getPharmacyRTFfromSQL(dispdata$ & rtfFormatType, strRTFName)
    
    If (InStr(LCase(strRTFName), ".rtf") > 0) Then strRTFName = Left$(strRTFName, Len(strRTFName) - 4)
    If (InStr(LCase(strRTFName), ".pil") > 0) Then strRTFName = Left$(strRTFName, Len(strRTFName) - 4)
    
    rtfName = strRTFName
    strFilename = sourceRTFNameFormat & strRTFName

    'Check data present in PharmacyRTFReport table with format ("WRKSHEET|DRAFT|xxx") and if present Update data to ("WRKSHEET|xxx")
    strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
    gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strFilename)
         
    Set rsRTF = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyRTFReportSelectbySiteandName", strParams)
         
    If Not rsRTF.EOF Then

        strFilename = destRTFNameFormat & rtfName
        If (Len(versionNo) > 0) Then strFilename = strFilename & versionNo
        
        intRTFReportId = GetField(rsRTF!PharmacyRTFReportID)

        strParams = gTransport.CreateInputParameterXML("PharmacyRTFReportID", trnDataTypeint, 256, GetField(rsRTF!PharmacyRTFReportID)) & _
                    gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                    gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strFilename) & _
                    gTransport.CreateInputParameterXML("Report", trnDataTypeVarChar, Iff(Len(strRTFReport) > 0, Len(strRTFReport), 1), strRTFReport) & _
                    gTransport.CreateInputParameterXML("Update", trnDataTypeDateTime, 8, Now)
        lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyRTFReportUpdate", strParams)
    End If
End Sub


Sub ViewArchiveLayout(ByVal strName As String, ByVal VersionNumber As Integer)
'26Aug09 TH Written
'With the name, offer to view various elements of the layout, or approve the whole thing
'11Jan17 TH Replaced file handling to use RTF DB layer (Hosted)

Dim strResult As String
Dim rsLayout As ADODB.Recordset
Dim strParams As String
Dim blnApproved As Boolean
Dim strFile As String
Dim strRTFText As String '12Jan17 TH Added

   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, strName) & _
               gTransport.CreateInputParameterXML("VersionNumber", trnDataTypeint, 4, VersionNumber)
   Set rsLayout = gTransport.ExecuteSelectSP(g_SessionID, "pWLayoutbySiteandNameandVersionNumberArchive", strParams)
   If Not rsLayout.EOF Then
      Do While (Not blnApproved) And (Not k.escd)
         frmoptionset -1, "View or Approve worksheet : " & Trim$(strName) & " - Version Number : " & Format$(VersionNumber)
         frmoptionset 1, "View ArchiveLayout"
         frmoptionset 1, "View Archive Item Line Text"
         frmoptionset 1, "View Archive Consumable Line Text"
         'frmoptionset 1, "Approve " & Trim$(strName) & " worksheet"
         frmoptionshow "1", strResult
         frmoptionset 0, ""
         If Val(strResult) > 0 Then
         
            
            Select Case strResult
            Case "1"
                     'View the layout
                        strFile = Left(RtrimGetField(rsLayout!Layout), (InStr(RtrimGetField(rsLayout!Layout), ".") - 1)) & "_Version" & Format$(VersionNumber) & ".rtf"
                        'Hedit 10, dispdata$ & "\wksheets\Archive\" & strFile
                        strRTFText = getPharmacyRTFfromSQL(dispdata$ & "\wksheets\Archive\", strFile) '11Jan17 TH Replaced above (Hosted)
                        Hedit 0, strRTFText                                                           '  "
            Case "2": TextEdit "View Item Line Text", RtrimGetField(rsLayout!LineText), "", False, False
            Case "3": TextEdit "View Ingredient Item Line Text", RtrimGetField(rsLayout!IngLineText), "", False, False
               
            'Case "4"
            '         'Here we must Approve the Wlayout record
            '         'First show a warning of which formulae are "involved"
            '         ApproveWLayout strName, RtrimGetField(rsLayout!Layout), RtrimGetField(rsLayout!VersionNumber)
            Case Else: k.escd = True
            
            End Select
         Else
            k.escd = True
         End If
            
      Loop
   End If
End Sub

Sub SyringeContainers(ByVal blnEqual As Boolean, ByVal sglDose As Single, ByVal sglVolume As Single, ByRef frmSyringes As Form)
' 9Jun95 CKJ written, derived from Prescrib.frm:ChooseContainer
'File structure:
' Abbr|Name|Nominal_volume|Volume_as_supplied|Maximum_volume|Minimum_volume
' S|SYR|50|0|45|5
' B|BAG|500|530|600|50
'Given current container abbr & vol required, returns container name or,
' if not found, returns container abbr as given.
'05dec05 CKJ converted to standard ini file container.ini
'            []
'            total=n
'            1="..." to n="..."
'20Feb13 TH After converting and using to populate the grid on the form, had to alter to handle the final
'           syringe dose on uneven split. Also handle 5 + syringes properly.
'17Jun13 TH Ensure container handling here only uses syringes !! (TFS 66598)
'19Jun13 TH Handle uneven split where last split is actually a full syringe (TFS 66712)
'23Feb16 TH FIx rounding on volume on last syringe (TFS 146402)

Dim contnum%, temp$, Numoflines%, i%, intloop As Integer, Container As Integer
Static ContData$(), intSyringevol() As String, blnDoneOnce As Boolean
Dim intSingleSyrVol As Integer
Dim NumofSyringes As Integer
Dim strDose As String, strVolume As String
Dim strLastVolume As String, strLastDose As String
Dim dDiv As Double
Dim iInt As Integer
Dim dResult As Double
   
   'use Volume to calculate how much we need
   'Load containers from new table ???
   
         
   'contname$ = ContAbbr$                                                   'set the default
   contnum = Val(TxtD(dispdata$ & "\container.ini", "", "0", "total", 0))  'total num of containers defined
   
   If Not blnDoneOnce Then
   
      For i = 1 To contnum
         ReDim lines$(1 To 6)
         temp$ = UCase$(TxtD(dispdata$ & "\container.ini", "", "", Format$(i), 0))
         deflines temp$, lines$(), "|", 1, Numoflines%
         If lines$(1) = "S" Then
            Container = Container + 1
            'ReDim Preserve ContData$(1 To 6, 1 To contnum)
            ReDim Preserve intSyringevol(Container)
            'For intloop = 1 To 6
            '   ContData$(i, contnum) = UCase$(Trim$(lines$(i)))
            'Next
            intSyringevol(Container) = lines$(5)  'TH Max Volume in syringe
         End If
         'If lines$(1) = UCase$(ContAbbr$) And Val(lines(3)) = volume! Then
         '   contname$ = lines$(2)
         '   Exit For
         'End If
      Next
      
      'shellsort intSyringevol(), contnum, 1, "NUMBER"
      shellsort intSyringevol(), UBound(intSyringevol()), 1, "|", "NUMBER" '17Jun13 TH (TFS 66598)
      blnDoneOnce = True
   End If
   contnum = UBound(intSyringevol())  '17Jun13 TH Replaced - we only use syringes !! (TFS 66598)
   
   'OK Now we have our possible containers.
   intSingleSyrVol = 0
   'If we are equal or below smallest, use that
   For intloop = 1 To contnum
      If sglVolume <= intSyringevol(intloop) Then
         'This will be the volume syring we use
         intSingleSyrVol = intSyringevol(intloop)
         Exit For
      End If
   
   Next
   
   If intSingleSyrVol = 0 Then
      'OK we are going to need multiple syringes. These wil be of max type - no mixing !
      If Int(sglVolume / intSyringevol(contnum)) <> sglVolume / intSyringevol(contnum) Then
      
         NumofSyringes = Int(sglVolume / intSyringevol(contnum)) + 1
      Else
         NumofSyringes = Int(sglVolume / intSyringevol(contnum))
      End If
      
      'Now we know the number of syringes needed , so..
      If NumofSyringes > 0 Then
         'If NumofSyringes < 5 Then
         If NumofSyringes < 6 Then   '20Feb13 TH
            For intloop = 0 To 4
               frmSyringes.lblDose(intloop).Visible = False
               frmSyringes.lblVol(intloop).Visible = False
               frmSyringes.lblNum(intloop).Visible = False
            Next
            If blnEqual Then
               'If even share then we divide vol by syringes - Rounding  !!!????
               strDose = Format$((sglDose / NumofSyringes), "####0.##")
               strVolume = Format$((sglVolume / NumofSyringes), "####0.##")
               If Right$(strDose, 1) = "." Then strDose = Left$(strDose, Len(strDose) - 1)
               If Right$(strVolume, 1) = "." Then strVolume = Left$(strVolume, Len(strVolume) - 1)
               For intloop = 0 To (NumofSyringes - 1)
                  frmSyringes.lblDose(intloop).Caption = strDose
                  frmSyringes.lblDose(intloop).Visible = True
                  frmSyringes.lblVol(intloop).Caption = strVolume
                  frmSyringes.lblVol(intloop).Visible = True
                  frmSyringes.lblNum(intloop).Visible = True
               Next
               
            Else
               'if split then we take the max vol (syringe) for all but last vol which is the mod
               'strDose = Format$(((sglDose - (sglDose Mod numofsyringes)) / numofsyringes), "####0.##")
               
               
               strDose = Format$((sglDose * (intSyringevol(contnum) / sglVolume)), "####0.##")
               strVolume = Format$(intSyringevol(contnum), "####0.##")
               
               If sglVolume Mod intSyringevol(contnum) = 0 Then '19Jun13 TH (TFS 66712)
                  'Here there is an exact match, so really the two options will be the same
                  strLastVolume = strVolume
                  strLastDose = strDose
               Else
                  'strLastVolume = Format$((sglVolume Mod intSyringevol(contnum)), "####0.##")
                  strLastVolume = Format$(sglVolume - ((intSyringevol(contnum)) * (sglVolume \ intSyringevol(contnum))), "####0.##") '23Feb16 TH FIx rounding on volume on last syringe (TFS 146402)
                  
                  '20Feb13 TH Replaced below as nod wasnt handling fractional doses under 1
                  'strLastDose = Format$((sglDose Mod (sglDose * (intSyringevol(contnum) / sglVolume))), "####0.##")
                  
                  dDiv = sglDose / (sglDose * (intSyringevol(contnum) / sglVolume))
                  iInt = Int(dDiv)
                  dResult = dDiv - iInt
                  strLastDose = Format$(dResult * (sglDose * (intSyringevol(contnum) / sglVolume)), "####0.##")
               End If
               
               If Right$(strDose, 1) = "." Then strDose = Left$(strDose, Len(strDose) - 1)
               If Right$(strVolume, 1) = "." Then strVolume = Left$(strVolume, Len(strVolume) - 1)
               If Right$(strLastDose, 1) = "." Then strLastDose = Left$(strLastDose, Len(strLastDose) - 1)
               If Right$(strLastVolume, 1) = "." Then strLastVolume = Left$(strLastVolume, Len(strLastVolume) - 1)
               For intloop = 0 To (NumofSyringes - 2)
                  frmSyringes.lblDose(intloop).Caption = strDose
                  frmSyringes.lblDose(intloop).Visible = True
                  frmSyringes.lblVol(intloop).Caption = strVolume
                  frmSyringes.lblVol(intloop).Visible = True
                  frmSyringes.lblNum(intloop).Visible = True
               Next
               frmSyringes.lblVol(NumofSyringes - 1).Caption = strLastVolume
               frmSyringes.lblVol(NumofSyringes - 1).Visible = True
               frmSyringes.lblDose(NumofSyringes - 1).Caption = strLastDose
               frmSyringes.lblDose(NumofSyringes - 1).Visible = True
               frmSyringes.lblNum(NumofSyringes - 1).Visible = True
            End If
            frmSyringes.NumofSyringes.Caption = NumofSyringes
         Else
            popmessagecr "!", "This issue requires more than 5 seperate syringes to fulfil each dose. Please re-issue in a more appropriate way"
            k.escd = True        '20Feb13 TH Added
            Unload frmSyringes   '   "
         End If
      End If
   End If
   
   

End Sub

Function SyringeContainerMax() As Integer

Static intSyringevol As Integer
Dim intloop As Integer
Dim contnum As Integer
Dim strTemp As String

   contnum = Val(TxtD(dispdata$ & "\container.ini", "", "0", "total", 0))  'total num of containers defined
   
   If intSyringevol = 0 Then
      For intloop = 1 To contnum
         ReDim lines$(1 To 6)
         strTemp = UCase$(TxtD(dispdata$ & "\container.ini", "", "", Format$(intloop), 0))
         deflines strTemp, lines$(), "|", 1, 0
         If lines$(1) = "S" Then
            If intSyringevol < lines$(5) Then intSyringevol = lines$(5)  'TH Max Volume in syringe
         End If
      Next
   End If
   
   SyringeContainerMax = intSyringevol
   
End Function

Function Syringestolabel() As Integer
'03Dec12 TH Written
   If m_syringestoLabel < 1 Then m_syringestoLabel = 1
   Syringestolabel = m_syringestoLabel

End Function

Sub setSyringestolabel(ByVal intSyringestoLabel As Integer)
'03Dec12 TH Written

   m_syringestoLabel = intSyringestoLabel
   
End Sub

' 21Jun16 XN 154896 Added for Amm
Sub resizeSyringeLabel(ByVal intSyringestoLabel As Integer)
    ReDim m_SyringeLabelVolume(intSyringestoLabel)
    ReDim m_SyringeLabelDose(intSyringestoLabel)
End Sub

Function getSyringeLabelVolume(ByVal intSyringelabel As Integer) As Single
'03Dec12 TH Written

   getSyringeLabelVolume = m_SyringeLabelVolume(intSyringelabel)

End Function

' 21Jun16 XN 154896 Added for Amm
Function setSyrineLabelVolume(ByVal intSyringelabel As Integer, ByVal volume As Single)
    m_SyringeLabelVolume(intSyringelabel) = volume
End Function

' 21Jun16 XN 154896 Added for Amm
Function setSyrineLabelDose(ByVal intSyringelabel As Integer, ByVal dose As Single)
    m_SyringeLabelDose(intSyringelabel) = dose
End Function

Function getSyringeLabelDose(ByVal intSyringelabel As Integer) As Single
'03Dec12 TH Written

   getSyringeLabelDose = m_SyringeLabelDose(intSyringelabel)

End Function
Function SyringeContainerbyVolume(ByVal sngVol As Single) As Integer
'23Dec12 TH Written

Dim intSyringevol As Integer
Dim intloop As Integer
Dim contnum As Integer
Dim strTemp As String

   contnum = Val(TxtD(dispdata$ & "\container.ini", "", "0", "total", 0))  'total num of containers defined
   
   If intSyringevol = 0 Then
      For intloop = 1 To contnum
         ReDim lines$(1 To 6)
         strTemp = UCase$(TxtD(dispdata$ & "\container.ini", "", "", Format$(intloop), 0))
         deflines strTemp, lines$(), "|", 1, 0
         If lines$(1) = "S" Then
            'If intSyringevol < lines$(5) Then intSyringevol = lines$(5)  'TH Max Volume in syringe
            If lines$(5) > sngVol Then
               If intSyringevol > 0 And lines$(5) < intSyringevol Then
               intSyringevol = lines$(5)
               ElseIf intSyringevol = 0 Then
               intSyringevol = lines$(5)
               End If
            End If
         End If
      Next
   End If
   
   SyringeContainerbyVolume = intSyringevol
   
End Function
