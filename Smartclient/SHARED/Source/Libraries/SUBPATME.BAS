Attribute VB_Name = "SUBPATME"
'-----------------------------------------------------------------------------
' ASC 03 Oct 90 Added getpatid and putpatid no mbf required !
' ASC 06 Dec 90 Changed getpatid to 173 byte structure
'13Dec90 CKJ dob$ fault fixed in Getpatid
'03Jan91 ASC screen tidying on printpmr,bug fix on findrdrug after line 22
'26Mar91 ASC/CKJ getpointer can now return 1 !
' 4Apr91 CKJ commented code in deflines removed to save space
' 7Apr91 CKJ minor tidyings
'29Apr91 ASC new indexing method together with losses gains calc.
' 7Aug91 CKJ GetPointer moved to DFHL
'            Long integers used with Get/PutRecord(N)L
'            NB Scan for !! & edit as needed
'11Aug91 ASC/CKJ Consolidated 2 versions. Uses d.inuse & stores
'27Oct91 CKJ Mods to Issue & Translog. See procs for details
'28Oct91 CKJ Findrdrug can display a prompt on bottom line
'29Oct91 CKJ Consolidated 2 versions again (The DIF file was 25763 bytes long)
'            Added mlsperpack to drugparameters
'            Added tradename search to getdrug, only gets first match though.
' 3Nov91 CKJ moved Savebatchnumber to TPNREMS
'17Jan92 ASC added loaddefaults which contains vat rates at prest for issuing
'26Jan92 ASC added new findrdrug selection screen including price also
'            poundsandpence procedure
' 7Jan92 CKJ Barcode issue altered
'            DisplayDrugLine avoids overflow error on display
'24Mar92 ASC period use now converted from integer for display
'08Apr92 ASC patidtype now not shared
'19Apr92 CKJ (Mods of 23Feb92 finally incorporated)
'            Help file path now explicitly \dispasc
'            page 150 now uses subpatme.hlp not main program's help file
'            (Mod of 3Mar92 OpenRandomFilePtr for PMR.V5 **NOT INCORPORATED**)
'            Tidied FormStatus & display of > œ99,999 in pounds&pence
'20Apr92 CKJ GetPMR now uses WriteLog - original would not work as written
'21May92 CKJ Added k.decimals to Issue. Added check for issue < 0 stock.
' 5Jun92 CKJ Losses/gains field widened to 9 chars
'26Jul92 ASC added checklossgain to subpatme
' 4Aug92 ASC issue now writelogs if issue causes or has negative stock level.
'17Aug92 CKJ Changed PMR logfile name
' 2Nov92 ASC See changes to translog marked 2Nov92
' 3Nov92 CKJ Installed PRNDRVR
' 9Nov92 CKJ Merged two versions 2/3Nov92   * NB * Translog mod looks wrong *
'16Nov92 ASC tofollow added to loadvatrates
'20Nov92 ASC modified cyclical ordering to exclude leadtime unless greater than
'            cycle length
'30Nov92 ASC Added labeltype to tranaction log to pick up civas information
'26Mar92 ASC Added issueunitcost$
'10Apr93 ASC Transaction debugging added to COMMAND$ "T" for translog and "O" for
'            orderlog findrdrug now allow up and down
'04May93 ASC No cost in orderlog message now removed
'26May93 ASC Formstatus poptransaction and poporderlog made gosub to save memory
'02Jun93 ASC Added vat and outstanding to arraytostruct and structtoarray
'12Jul93 CKJ Added dp! to Issue & Translog
'17Aug93 CKJ Moved ParseBNFcode from Labutils, dp! added to Translog stocklvl
' 2Nov93 CKJ VBDOS: printer = > printerV,  printform => printformV
'16Nov93 CKJ Findrdrug: Mod to badcheck
'16Dec93 ASC getdir altered for prescribing
'23Dec93 CKJ Added new fields to Drugs
'29Dec93 CKJ Added new VAT
'25Jan94 CKJ Added new items to loadvatrates
'08Feb94 ASC ATC code added where Prescribing code was going to be
'12Feb94 ASC removed DosesBetweenTimes
'20Feb94 ASC added SCREEN.ControlPanel(7) = 0 before MSGBOX
'22Feb94 ASC removed setting to "" in clearlabel
'16Mar94 CKJ mod to pounsandpence
' 3May94 CKJ Corrected TransLogVAT! in Translog
'27May94 CKJ Minor mod to Translog
' 7Jun94 ASC removed  DIM SHARED idxchan(1 TO 2), f$(15), patchan%, finchan% '!!** Used?
'            and      CONST idxminlength = 10    ' ie  "",00001<CR><LF>
'28Jul94 ASC Clearlabel gone to patsubs
'25Oct94 CKJ Findrdrug: Select drug now via form, drug file fully indexed,
'            PRODINFO.COP removed. Now requires \Q4LIB\FINDDRUG.FRM
'27Oct94 CKJ EditDrugMsg added on F2 in FindDrug.frm - not ideal since
'            INPUTBOX$ is truly awful
'15Dec94 CKJ Modified ISSUED.ASC code in translog
'19Dec94 CKJ Modified ISSUED.ASC code in translog for returns
'19Jan95 CKJ Added siteinfo defaults
'20Jan95 CKJ Highlight 1st drug in list. BNF chapter & section from std files.
'27Jan95 CKJ GetDrug; force closure of index
' 3Feb95 CKJ Added fields to ClearDrug
'17Feb95 CKJ Justifydrugs moved to labutils
' 3Mar95 CKJ Mod to orderlog & Issue
' 5Mar95 CKJ Removed k.escd = false at end of issue
'14Mar95 CKJ FindrDrug allows EAN 8
'            Removed imprest & numofdaysbo
' 2Apr95 ASC Added logging to issue when somebody escapes from the issue box
' 6Apr95 CKJ/ASC Issue: k.escd mod
'21Apr95 CKJ Findrdrug: Added wildcard search
' 5May95 ASC Do loop added with confirm for Watford but is definately a good
'            idea elsewhere particularly Kings.
'10May95 ASC Wipedef in issue fixed
' 5Jun95 CKJ GetDrug now does not alter FindDNum (as per PDS V5.x)
'20Jun95 CKJ Findrdrug: Added EditForm for viewing user messages
'11Sep95 CKJ Findrdrug: Avoids inkey$ when formshowing
'12Sep95 CKJ Orderlog & Translog: Added E number traps
' 3Nov95 CKJ Moved Plingparse to q4lib
'08Feb96 EAC PutDrug: Use new (un)lockrecord
'09Feb96 CKJ GetNod: Added loadvatrates
'22Feb96 CKJ Added CursorOn after showing forms
'29Feb96 CKJ/EAC OrderLog: Further mod for dbRAmode
'13Mar96 CKJ Orderlog: GetPointer now used instead of native code
'19Jul96 CKJ moved global d from patsubs
'20Aug96 ASC/EAC removed worksheetno from drugparameters as no longer needed
'22Aug96 ASC/EAC transfile$ added to make orderlog work properly
'27Aug96 ASC Added batch number habdling procedures
'27Aug96 EAC added new fields to supplier structure
'10Sep96 EAC SupplierStruct: icode stretched and moved
' 4Sep96 CKJ FindrDrug: Modified call to Editors with UserMsg (merged edit)
'12sep96 ASC Midnight now 00:00 was 24:00
'20Sep96 CKJ AddStockOfBatch, TakeStockFromBatch: Removed Noon & Midnight code
'26sep96 ASC modified translog for manufacturing
'26Sep96 CKJ transchan% and IssuedChan%: Share at module level, not static in proc
'            and close them in CheckSubPatMed
'            Corrected translog & orderlog usage if working over 24:00 at end of month
'02Oct96 EAC Added ward info fields to SupplierStruct
'24Oct96 EAC made mod so that SupplierStruct match DOS mod of 12Mar96
'07Nov96 KR  Changed findrdrug and displaydrugline so that it uses
'            standard font and tab settings.
'05Dec96 EAC EditDrugMsg: if user escaped  - record remained locked
'15Dec96 ASC Takestockfrombatch supports multiple batches
'19Dec96 CKJ Merged mods: of 13Dec96 CKJ
'            CheckLossGain: Log now in dispdata.xxx
'            EditDrugMessage: locks only if user doesn't escape
'19Dec96 EAC Translog: LastTransfile$ now set
'27Jan97 ASC in Findrdrug added a confirmation for Highly specialised drugs for oz and formulary reporting
'10Mar97 CKJ WARNING: Logging of Highly specialised drugs commented out, since this
'             uses data structures which are out of scope in most programs (ie PID)
'             Search on 10Mar97
'19Mar97 KR  Moved LabelValues() and TotalIssueCost! from Patmed.bas
'25Aug96 ASC added issue of specific batch number batchnumber$ and expiry$ return deails of what was issued.
'??Mar97 KR  combined the label printing form with issue in issue.
'            added parameters duplicates%, NumLabels%, Action to issue.
'22Mar97 KR  added check to disallow negative issues.
'09Apr97 KR. Ensure no issuing if no drugcode e.g. when free format labels.
'09Apr97 KR  Check gTimedOut to ensure no issue if timed out.
' 1May97 CKJ Moved Supplier structure to Supplier.bas
'18Jun97 KR  Added Close formula database and clear db variables if open in CloseSubPatme.
'27Mar97 KR  Issue: Removed Setting of dircode$ (directions) to the batchnumber as this was
'            changing the directions on the dispensing form.
'12Jul97 CKJ Findrdrug: Read NSVcode pattern from stkmaint.ini
'            Search also on '@~@~ 12Jul97'
'            uses PatternMatch in corelib
'15Jul97 CKJ Findrdrug: Added check for local code
'            Allow search by BNF chaper as well as BNF section
'            UpdateInfoLine: Modified to show more information than before,
'            without flashing messages and to show cost and the issue units per NSV
'17Jul97 CKJ Added d.Local code
'            Functions NSVpattern and LocalPattern added
'18Jul97 CKJ datelastperiodend*6 moved and stretched to 'ddmmccyy', old field is now d.blank
'            d.indexed now used to indicate on Data Provision Service
'             on DPS = "1" else not on DPS
'22Jul97 CKJ All SOUND statements re-enabled as this is now emulated in Corelib
'26Aug97 CKJ Issue: added prescriber id round translog
'27Aug97 CKJ Issue: InputWin not called: k.min/max/nums/decimals removed since otherwise this
'            leaves settings for next box which is set incorrectly to nums/decimals etc
'22Sep97 ASC/EAC DosesperAdminUnit added for dose range checking conversion from Tans etc
'22Oct97 CKJ ClearDrug: Added DPS fields
'12Dec97 CKJ Drugparameters; stretched route, shrunk dosesperadminunit, added DPSform
'12Dec97 CKJ Drugparameters; returned route and dosesperadminunit to original place
'23Dec97 EAC Added StoresDescription, StoresPack and TeamworkBtn to Drugparameters type
'29Dec97 EAC PoundsAndPence: change formatting of zeros
'29Dec97 EAC Issue: Automatically set the number of labels to be printed by assuming that each label
'            will be for a quantity <= pack size for that drug
'30Dec97 ASC parseissueqty checked and amended as commented
'19Jan98 EAC Move GetInsCode and GetWarCode from PATSUBS.BAS
'            Both procedures are no longer static subs
'19Jan98 EAC DisplayDrugLine: Add blob to signify if drug is on decision support service
'22Jan98 ASC TakeStockFromBatch: List box now shows drug name & qty (CKJ)
'02Feb98 EAC Issue: Added formatting of issue qty text to allow decimals to be entered correctly in Issue form
'05Feb98 CFY Issue: Temporary solution to stop div by 0 errors occuring when printing ad-hoc free format labels'
'27Feb98 ASC Made the debug orderlog and translogs text edit boxes to allow cut and paste.
' 3Mar98 CKJ Reinstated original code after ASC's mod, as it was correct in the first place
'11Mar98 CFY displaydrugline: Changed to display stores description by default. If stores description
'              is blank then revert to the dispensary description.
'27Apr98 CFY Issue: Will now print the correct quantity when 'Print labels Only' is selected. Previously
'            would always print the qty on the pmr screen regardless of what the user entered in the
'            issue box.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'13Jun98 ASC Changes made to the findrdrug screen
'15Jun98 CKJ Corrected some of these
'26Jun98 CFY updateinofline: Added redraw parameter to a allow a repaint of the info panel to be forced.
'29Jun98 EAC Issue: For Action=5, packs will only be displayed if they are in whole packs. NB this also stops problems
'            occurring due to rounding errors.
'14Jul98 CKJ GetInsCode, GetWarCode: use ASCFileName to switch to DSS and second language
'20Jul98 EAC Make the Escape from printing label work correctly
'23Jul98 TH/CKJ FillHeapDrugInfo written: Puts a drug on the heap or removes it
'20Jul98 EAC Added gTlogEventNumber and gTlogEpisode
'31Jul98 EAC Added GetUniqueNSVCode() and UpdateChar() for Hong Kong mods
'06Aug98 CKJ LocalPattern: Allow pattern in stkmaint.ini to be zero length.
'             This specifies no checking and all values are allowed.
'            Findrdrug: Local code search can be forced by using a prefix (just like tradename)
'             The default prefix is '=' but it can be set in stkmaint.ini [Data]
'             LocalCodePrefix=":" where a single sensible character is defined.
'             Sensible means avoid A-Z,0-9,? etc
'             Automatic use of the local code index now inhibited if the local code mask is ""
'30Sep98 CKJ Findrdrug & DisplayDrugLine: modified for large fonts, ini file options enabled.
'19Oct98 CKJ FillHeapDrugInfo: corrected d.loccode, amended l.local and removed d.extralocal
'28Oct98 CKJ Merged V: 15Oct98 TH  Findrdrug: Added check on finddrug.tag to stop unwarranted loading of drug
'10Nov98 TH  Translog: Added code to stop positive prices for returns
'20Nov98 TH  DrugParameters; Added Loccode2 for use in stock control
'03Dec98 TH  Added abs to handle returns of part packs
'30Nov98 CFY issue: Added code to handle duplicate sets of labels
'21Dec98 CFY Translog.bas: Added gTlogPPFlag$
'14Jan99 CFY Added field stocklvl field to transaction structure for recording stock level before the
'            transaction takes place
'15Jan99 CKJ Added stocktake details to drug structure
'21Jan99 CFY AddStockOfBatch: Added description to table
'25Mar99 TH  Issue: Changed value looked for from checkbox
'17May99 AE  UpdateInfoLine:Changed formatting of d.stocklvl on screen
'17May99 AE  ClearDrug:Initialised d.leadtime to "0" to prevent blank output.
'17May99 AE  Issue:Changed formatting of d.stocklvl on screen
'31Mar99 CFY findrdrug: (1) Fixed problem which would prevent wildcard searches from firing.
'                       (2) Switched the sequence in which local code and ASC lookup code are searched.
'                            ASC Lookup code now takes precedence above the local code.
'31Mar99 CFY LookupPattern: Lookup code format is now hardcoded for now but gives option of more flexability
'            in future for now.
'06Apr99 TH  Checkcode: Removed code to match 8066
'06Apr99 TH  Issue: Code to keepform loaded for baglabelprinting (to avoid use of global)
'07Apr99 TH  Issue: Increased form height when printing stocklabels
'15Apr99 TH  Issue: Changes to allow for issue quantity to be shown as units of packsize( X * X ) from stores
'26Apr99 TH  Issue: Corrected Logic to keepform open with baglabels
'30Apr99 TH  Issue: Allow for packsize to be shown in issue box when issuing from wardstocklists
'04Jun99 SF  Issue: added patient billing mods
'30Jun99 CFY Multiple mods for Supplier profiles
'08Jul99 TH  Translog: Update lastissued field in drug file
'20Jul99 TH  Issue: Include packsize in total for all new stock actions (5+)
'28Jul99 AE  Added DIM emptymsg$ at module level.  Was not dim'd anywhere, hence was always empty
'            when it was used for display.
'28Jul99 AE  Turned on Option Explicit in this Module, threw up a large number of undelclared variables.
'            GetDrugSup: corrected Findnum to findDnum
'            GetINsCode: Dim'd variables
'            GetNod: Dim'd variable
'            GetyWarCode Dim'd variables
'            Issue: Dim'd variables
'                   Site% has never been declared, hence was always 0.  Was working because writelog sets the
'                   site according to the command line if none is given.  Should use the global Sitenumber$, however
'                   issues may sometimes be made across sites, in which case the site will change.  Needs Review.
'            ListInstructions: Dim'd variables
'            ListWarnings: Dim'd variables
'            LoadVatRates: Dim'd variables
'            LocalPattern: Dim'd variables
'            LookupPattern: Dim'd variables
'            NSVPattern: Dim'd variables
'            ParseBNFcode: Dim'd variables
'            SaveNOd: Dim'd variables.  Also removed numofdrugs which was not referenced anywhere else
'            SelectBNFSection: Dim'd variables.
'            StoresValue: Written to allow finddrug.frm to read the value of Stores% which was previously
'                         not declared and hence always zero.
'            TakeStockFromBatch: Added passing of batch number and expiry into translog using module level
'                                variables SubPatExpiry and SubPatBatch.  Previously were explicitly set blank.
'            Translog: Dim'd variables. Additions to allow writing of batchnumber and expiry using the
'                      above variables.
'12Aug99 ASC\TH NSVPattern: Made popmessage clearer
'06Sep99 CKJ CheckDrugFile,CloseSubPatmed: Added call to TrackOpenedFiles
'11oct99 CKJ CloseFormulaDatabase: Altered sequence of closing objects
'            Added field HasFormula to drug. Note: Not accessible from stkmaint.ini yet.
'21Oct99 TH  Translog: Ensure MB (Manfactured items) have datelastissued field updated
'16Nov99 SF  Issue: added additional PBS patient billing mods
'18Nov99 AE  FillDrugList:Moved line which sets IsASCcode; seems to have got lost in the merge, and meant that new
'            drugs could not be added.
'24Nov99 SF  Issue: fixed the problem where program wasn't warning the user if issue went into negative on PBS
'02Dec99 SF  Issue: PBS patient billing mods to allow cancelling out at anytime and to make the code more readable
'07Dec99 CFY GetSupProfile: Improved error message to give enough information to the user to enable them to correct problems.
'10Jan00 AE  Added AbsTime to type DrugKinParam, also changed type to use doubles instead of singles.
'10Jan00 AW  Translog: changed format of date to format of now.
'23feb00 MMA/VS/TH Translog: moved write to datelastissued here to ensure ALL items updated
'01Mar00 TH  Added CreatedUser to order structure for information
'02Mar00 AE  PutDrugPK:Added field absorbtion time
'13Mar00 AW  Translog: Added code to prevent previous CostExVat and VATCost being written to translog. These are not
'            calculated for manufactured items.
'14Mar00 TH  Findrdrug: Reinstated wild card search on ini setting
'30Mar00 CFY FillHeapSupplierInfo Written. Code Taken form FillHeapDrugInfo
'06Apr00 TH  Issue: Stop packsize from wardstock issue going into caseno in translog
'06Apr00 TH  SupProfiletoDrug: *GST* Added vatrate to supplierprofile type
'18Apr00 CFY New fields added to transaction and order stucture to allow storage of customers own order number.
'            Translog: Now writes Customers own order number to transaction.
'19May00 CFY Moved GetcustOrdNo, PutCustOrdNo subroutines to subpatme.bas do to scoping.
'17Apr00 TH  updatebysupplier: *GST* allow global update of drugs/profiles by supplier
'            PutSupProfile: *GST* added vatrate.
'11Apr00 TH  OpenSupProfileDB: Added Parameter to stop messagebox *GST*
'10May00 AW  Translog: Commented out superfluous line.
'22May00 TH/AW Findrdrug: Use wildfound flag in getting ini setting for wildcard search
'              Previously found was being set and flagging back that there was a drug even if no selection
'              had been returned. Also set emptymsg$ to deal with failed searches.
'02Jun00 JN  Added:SetBatchNum and SetExpiryDate to control writing of batch num and expiry date to translog
'05Jun00 JN  Added:Translog - added CIVAS batch
'17Jul00 TH/AW Changed SupProfileDBOpen% to global for GST
'17Jul00 JN  GetWarCode: Added code to give warning if non-blank search string (warcod$) returns a blank string (warn$) - if this happens warnings are not set up correctly
'21Jul00 AE  GetSupProfile:If importing from an old snapshot, this field may not be present.  Trap the error if this occurs
'02Aug00 MMA Added: Global update for Teamwork
'25Aug00 JN  GetWarCode: Amended missing warning code warning routine to check Patmed.ini for .ini setting to turn this feature on/off
'25Aug00 TH/CY SupProfileToDrug: Trap blank entry in mdb
'25Aug00 TH UpdateSupProfVatRate: Written to ensure vatrates in supplier profiles are maintain as the default value
'                                 for all sites who are not set to edit this field - currently all except OZ
'29Aug00 JN UpdateSupProfVatRate: Added error trapping in case selected db is not set up
'28Jan99 CFY CheckCode: Changed wording of message if an invalid code is found.
'08Feb99 CFY findrdrug: Replaced fixed pattern for lookup codes to now use masks supplied in stkmaint.ini
'08Feb99 CFY checkcode: Removed hard coded pattern mask. Now uses masks from stkmaint.ini
'08Feb99 CFY LookupPattern: Written.
'26Apr99 CFY CheckCode: Changed message wording again for invalid codes
'12May99 CFY LookupPattern: Re-instated original code until HK can be convinced that they are mis-using this code
'12May99 CFY Checkcode: Removed lines which check whether first 3 characters match the description. (Now matches 8.066 code)
'08Sep00 TH  Updateinofline: format stocklevel to 6 sig figures
'15Sep00 TH  Updateinofline: format stocklevel to 6 sig figures
'26Sep00 TH  Issue: Changed formatting of d.stocklvl on screen to 6 sig places
'06Oct00 CFY updatesupprofvatrate: Strengthened error handling
'20Oct00 JN  orderstruct: added VATAmount, VATRateCode, VATRatePCT, VATInclusive to structure
'16Nov00 SF  added GetPrescriberDetails:, FillHeapPrescriberInfo:
'16Nov00 SF  Issue: added PBS V2 mods
'09Aug00 TH  Issue: If issue aborted due to neg stock then dont print stocklabels
'22Nov00 EAC/CY Handle in-dispute items and allow reprints of dispute note
'22Jan01 TH  TakeStockFromBatch: Call to set expiry date to correct format
'23Jan01 JN  SetExpiryDate: Now uses ParseDate
'29Mar01 ASC/CKJ Findrdrug: Added code to take a copy of d structure before editing takes place. If edits are cancelled (event 51305)
'           "    the original drug structure is replaced by the copy.
'15Mar01 TH  PutDrug: Added extra check to ensure profile is put back only to correct drug
'09Apr01 CKJ <Multiple procs>: Prescribing Ward modification.
'            If siteinfo.ini FormularyEXT <>"" then use this dispdata for every drug request,
'            instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting.
'            Read and cache the ward stock list for this ward, and if 'View All' button is visible then
'            check each item is on the WSL before showing it. NB uses a static string, max 2000 drugs
'            All files except for prodinfo.v8, nod and the drug*.idx files are still read from the
'            local dispdata. The prescribing 'friendly list' is taken from the ward stock list mdb in
'            the local dispdata, where the ward name matches the ward of the first patient opened.
'            This is cached and not re-read. It is not intended that the prescriber will handle patients
'            on more than one ward with this version. Locking and writing of the prodinfo is prevented.
'            UpdateInfoLine does not offer [F2] notes in this mode, and blanks captions if no drug is
'            displayed to prevent 'carry over'
'09Apr01 CKJ GetSetLocalWardListCode: Written. Allows the PID.ward to be passed into FillDrugList.
'            FillDrugList: Added call to GetSetLocalWardListCode since PID.ward not in scope except in ASCshell
'11Apr01 JN  ReadWholeWSL: Moved from Patmed.bas to resolve errors generated from
'                          calls made to it from outside dispensary
'03May01 CKJ FillDrugList: use enabled property of View All button instead of .visible
'15May01 JKU/CKJ PoundsAndPence(): The function was returning .245 as .24 due to precision handling. Now sorted.
'29May01 TH  PutSupProfile: Now reads supplier reference no from heap, as was getting
'            deleted each time due to not being cast into drug structure (#52439)
'29May01 TH  GetDrugSup: Remove SupplierReference Number from Heap as there should be no default value (#52439)
'29May01 TH  GetPrescriberDetails: Multiple changes to allow for the use of the lstboxfrm instead of enhlstbox- this is done for
'            The Royal Adelaide Hospital who want the selection of rxer done on a name sort, not by code  (#52394)
'29May01 TH  Issue: Stop ward stock labels printing on cancel (#45739)
'01Jun01 TH  GetPrescriberDetails: Changes to above after discussion with CKJ (#52439)
'01Jun01 CKJ/SF GetPrescriberDetails: Modified extensively to increase flexibility and reduce network traffic. (#52439)
'13Aug01 SF  added PIL2 field to drugparameters structure for CMI enhancement
'24sep01 CKJ Merged:
'01Sep01 TH  SupProfiletoDrug: Removed barcode write back to drugfile. Quick fix - user is never allowed to edit this field (at present) (#53511)
'            Therefore field could be blank if user has switched primary and sec. suppliers.
'            There is already better functionality to assign alternative barcodes outside of sup profiles.
'30Oct01 CKJ CanInferAdministrationUnits: Extended to include liquids and checks for dosesperissueunit>0
'08Jan02 TH  Added StripSize field to drugparameters structure for Pyxis enhancement (#56462)
'11Jan02 TH  Issue: Changed text of popmessage (#49916)
'15Jan02 TH  Orderlog: Tried to include time in log for order and receipt (#53214). This was half instituted,
'    "       but needed a couple of minor changes to allow the date string parameters here to include the time
'17Jan02 TH  Issue: Moved stockcontrol check to open up billing (specifically MOJ Rpt Disp) to non stock ctrl items (#58306)
'21Jan02 TH  ListWarnings: Now use chr(161) as marker for no warning selected (picked up later)
'21Jan02 TH  ListInstructions: Now use chr(161) as marker for no inst selected (picked up later)
'25Jan02 TH  Added Stocklvl parameter to orderlog type (#53214)
'25Jan02 TH  Orderlog: Added new stocklevel to orderlog (#53214)
'15Feb02 TH  Issue: Removed fenceposts for neg issues around TakeStockofBatch to allow returns of batches (#51886)
'15Feb02 TH  TakeStockFromBatch: Various changes to support the return of batches and enhance the general screen display (#51886)
'12Mar02 TH/SF Issue: Only allow billing on none stock ctrl items if configured to do so (#58306)
'22Apr02 SF  added ShelfPrinted to orderstruct (enh#1555)
'            FillHeapDrugInfo: added d.loccode2 to the heap (enh#1555)
'30Apr02 ATW Issue   :  passed through *ans$ to BillPatient 14 (return) to allow new billing routines to edit return qty as well as issue qty
'13May02 ATW FillHeapDrugINfo: added iPipCode and iMasterPip to heap.
'01Oct02 TH  getexpirydate: Written
'01Oct02 TH  setexpirydate: Added write to 'extra' variable
'04Jun03 TH  Merged Following mod from 8.4 . This had previously been missed (#68165)
'29Jan02 CKJ FillDrugList: When prescribing with friendly list, allow drugs from main list
'            where these are specified by NSVcode. This prevents subsequent 'drug not found msgs'
'            when using a drug which isn't on the friendly list.
'04Jun03 TH  --------------------------------------------------------------- (#68165)
'05Sep02 SF  added TransactionID field to the transaction structure (enh#1274)
'            added TranslogExtra structure (enh#1274)
'            Issue: writes to TranslogExtra if setup  (enh#1274)
'            added LogExtraData: to decide if to write to TranslogExtra (enh#1274)
'            Translog: writes TransactionID (enh#1274)
'            TranslogExtra: added to write the TranslogExtra record (enh#1274)
'31Jan03 TH  (PBSv4) MERGED
'31Jan03 TH  GetPrescriberDetails: Properly normalise Rxer mdb with correct link to get prescriber type description
'31Jan03 TH  Issue: (PBSv4) Switch of checking of min/max dose if PBS issue as the qty comes directly from PBS Schedule
'31Jan03 to 31May03 TH Various mods to allow for Dispensing action "X" in PBS. This action uses pre-set qtys, so it bypasses
'                      the issue screen (no of labels to print hard set to 1)
'01Mar03 TH         Merged Following Mod:
'05Sep02 SF         writes to TranslogExtra if setup (enh#1274)
'03Mar03 TH         (PBSv4) added mod to handle cancel coming from billing routines
'17Mar03 TH         (PBSv4) Added mod for PBS- If cancel then write a 'stub' Repeat record so the PBS details can be used on next run through.
'17Mar03 TH         Set default to Y (override) on BillingForNotLiveStockCtrl to allow PBS billing on non stock control items
'17Mar03 TH         Labels only option is not allowed for PBS, if selected user is warned and sent back to issue screen
'31Mar03 TH         (PBSv4) Added to suppress translog on PBS exceptional item issue
'07Apr03 TH         (PBSv4) Added mod to ensure no qty saved if escd PBS Issue.
'07Apr03 TH         (PBSv4) Added mod to correctly set Qty on PBS X type dispensing action
'----------
'06oct03 CKJ merged 8.5 14feb03 CKJ
'28Jan04 TH  Added CodingSlipDate and ReconcileDate to order structure for interface requirements (#72647)
'16Feb04 CKJ FindItemScreenChar added to Findrdrug screen for mechanical dispensing
'20Feb04 CKJ UpdateInfoLine: Added Swisslog and 2nd location
'09Mar04 ckj Issue: added pack size & removed 'Esc to abort'
'11Mar04 CKJ Issue: moved mechdisp messages to ini file
'29Mar04 CKJ Issue: Merged testbuild code - only use MechDisp if exe is ASCshell
'30Mar04 CKJ {SP1}
'21apr04 ckj sethelp: removed as it duplicated setinput, then set help to a non-existent file
'16May04 TH  FillHeapDrugInfo: Added new general description iGendesc - uses stores desc if available, else resorts to normal description (#71558)
'16May04 TH  Moved GetStoresDescription() to here from Orderlib.Bas (#63766)
'16May04 TH  ListInstructions: Added ability to use enhanced list for lookup (enh654)
'16May04 TH  ListWarnings: Added ability to use enhanced list for lookup (enh654)
'16May04 TH  PutPickNo Written
'16May04 TH  Translog: Added mod to record Picking Ticket number if so configured (enh1549)
'16May04 TH  Updateinfoline: Added mod for UMMC price hide enhancement
'16May04 TH  Displaydrugline:Added mod to suppress cost view if configured (UMMC price hide enhancement)
'16May04 TH  GetFindDrugLowPassLevel() ,SetFindDrugLowPassLevel : Added (UMMC pricehide)
'21May04 TH  FillHeapDrugInfo: Altered above mod - removed a call to getstoresdescription due to referencing problems.
'21May04 TH  Moved GetStoresDescription() back to OrderLib.Bas
'27May04 TH  Displaydrugline: Changed UMMC mod to use Hideprice call
'27May04 TH  HidePrice: Written
'27May04 CKJ GetUniqueNSVCode: close binarysearchidx
'28May04 CKJ TransLogExtra: added TrackOpenedFiles
'10Feb07 CKJ Mechdisp handling added
'22Feb08 TH  Added mod to cache specific supprof fields for prods being used with alt suppliers where
'            there is no profile. No the fields that are blanked they should ot get saved to the default
'            supplier profile(F0015066)
'
'16Apr08 JP  Altered the gTlogEpisode Global variable to be a long as the Episode column changed to an int

'------- V10 Consolidation : Welcome to our new world (looks like the old one I know, but keep the faith !!)

'29Aug08 TH  Mod to update Reason Code (F0024092)
'30Sep08 CKJ SetSpecialty: Removed as var is global already (F0019922)
'08oct08 CKJ DisplayBNFsectionlist: written, based on displaymacrofile but gets BNF data directly from ordercatalogue
'12Oct08 TH Extended invnum in Orderlog to 20
'12Oct08 TH Added StockValue to WTranslog and WOrderlog inserts
'13Oct08 TH Orderlog: Removed new issue unit qty fields as they are not always big enough and can error even though they are not currently used (F0035288)
'13Oct08 TH Incremented revision number to 10 in log inserts
'16Oc08 TH Changed handling of batches so user can issue more than current batches support, msg is displayed in this case,
'          but there is a tolerance to stop the message if the discrepancy may be caused by rounding.(F0027701)
'16Oct08 TH if user aborts batch issue the do not write batch number\expiry to translog
'23oct08 CKJ reinstated description search with multiple words eg "sodium chloride" (F0021923)
'05Feb09 TH Orderlog: Ensure stockvalue is only entered for logs with associated products(F0045173)

'RCNP 008

'20Mar09 TH  FillHeapDrugInfo: Added new heap elements for UHB (F0032689)
'17Mar09 TH  FillHeapSupplierInfo: Added new elements for UHB Interfaces (F0032689)
'26Feb09 TH  OrderOutput: Ported for UHB SAGE Interface solution (F0032689)
'26Feb09 TH  FillHeapOrderLogInfo: Ported from V8 (F0032689)
'26Feb09 TH  OrderLog: Added call to order outputinteface (UHB F0032689)
'20Apr09 TH  Translog: OrderLog: Make debug more specific (F0050755)
'22Apr09 TH  FillHeapSupplierInfo: Added sMethodexp UHB (F0051378)
'28Apr09 TH  FillHeapSupplierInfo: Added XML parsed heap elements after UHB interface testing (F0052059)
'06May09 TH  FillHeapDrugInfo: Added an xml Parsed description element (F0052059)
'06May09 TH  FillHeapSupplierInfo: Ensure various fields are trimmed BEFORE parsing for XML (F0052059)
'04Sep09 PJC TransactionOutput: Added extra filter for the Patient Payment Category (F0054530)
'07Sep09 PJC FillHeapTranslogInfo: Added formatted version of trans date, trans costs/100, transaction Charge/Credit code and absolute qty to the heap. (F0054530)
'11Sep09 PJC TransactionOutput: Read the Patient stuff from the heap rather than the structure. (F0054530)
'21Oct09 TH  FillHeapSupplierInfo: (F0066973) Remove foramt on warcode as "10A" was being interpreted and output as a time !!! (10:00:00)
'                                             Also added XMl escaped element at same time.
'07Jan10 CKJ Issue: Widened label for robot name on issue form (F0030035)
'11Mar10 TH  FillHeapTranslogInfo: Merged from 10.1 Dont know why this is not here (!) 21Oct09 TH added (F0066728) (F0080318)
'07Apr10 AJK FillDrugHeapInfo: Added fields for F0072542 and F0072782
'14Apr10 AJK FillDrugHeapInfo: Added fields for F0072782
'06May10 AJK DisplayDrugLine: F0073627 Added blnOtherRoutes param to be checked and add prefix to off route item display
'06May10 AJK FillDrugList: F0073627 Added blnOtherRoutes input to be passed to ProductLookup
'06May10 AJK FillDrugList: F0073627 Removed single item check for generating headings
'06May10 AJK FillDrugList: F0073627 Added check to ensure list is not empty before setting item
'06May10 AJK FindrDrug: F0073627 Added off route checking code to log and display off route matches
'17May10 TH  FillHeapDrugInfo: Added iDescriptionXML as UHB use the none xML element of this as well as the trimmed one (F0077941)
'04Jun10 XN  Issue: If Drug is not in use ask user if they want to continue (RCN P0158 F0023149)
'25Jun10 CKJ CanInferAdministrationUnits: removed as no longer used         (RCN P0158 F0088216)
'26Jul10 XN  Improved the fix for RCN P0158 F0023149, adding drug name and proper tidy up.
'03Aug10 XN  FillDrugList: Stores only products are now identified by d.ProductID <> 0, also force any WProudct.InUse = "S" read from DB to "Y"  (F0088717)
'                        updateinfoline: InUse in not "S" anymore for stores only products, so changed to display 'Y (S)' or 'N (S)' (F0088717)
'                        putdrug: Add check to see if in trasaction before doing rollback
'21Jul10 TH  Added setBatchOrderOutputFileName,getBatchOrderOutputFileNameto both store a reference to a local file
'            used to batch interface output and as a flag (UHB)(F0077944)
'21Jul10 TH  OrderOutput: Added functionality to allow appends to existing file (F0077944)
'30Sep10 TH  Orderlog: Replaced stock and value lookups with the drug actually just looked up (F0096947)
'02Nov10 AJK F0086901 Extended OrderLog struct to include DateInv
'02Nov10 AJK OrderLog F0086901 Added support for date invoiced
'02Nov10 TH  PutSupProfile: Extended supprefno from 20 to 36 chrs (UMMC PRF) (F0094388/RCN545)
'02Sep10 TH  FillHeapOrderLogInfo: Added DeliveryNoteReference for UMMC FINV (F0054531)
'02Sep10 TH  Orderlog: Added DeliveryNoteReference param and field (UMMC FINV) (F0054531)
'06Sep10 TH  FillHeapOrderLogInfo: Added olQtyOrdfromRec for UMMC FINV interface as qtyord in "R" type isnt actually qtyordered (F0054531)
'06Sep10 TH  getQuantityOrderedFromReceiptLog Written(UMMC FINV). This was unexpectedly required as the ordqty in the R type WOrderlog is not the
'            genuine qty ordered, but the outstanding on this line. This is useless for the outbound FINV interface so this function is needed to aggregate the
'            true ordered qty for writing to the heap. As it is relatively expensive and requires a DB call it is only envisaged that this is called as required
'            and not as part of general heap or information gathering. (F0054531)
'07Sep10 TH  FillHeapOrderLogInfo: Added new formatted order date using configurable seperator (dd+<sep>+mm+<sep>+YYYY) for UMMC/FINV (F0054531)
'15Oct10 XN  Reduced DeliveryNoteReference down to 10 chars to match db (F0098793) (UMMC FINV)
'23May11 TH  FindrDrug: Off route only on VMPAMPAMPP search (ie Dispensary selection from rx). Previously none NSV Searches  (ie barcode or description
'            that returned one row could still display selection screen if off route filtering was turned on.
'26May11 TH  ShowUserMessage: Reinstated use of editor to show user message but on a setting (allows printing) (F0064602)
'16Aug11 TH   Increased Orderlog DeliveryNoteReferenceto 30 chars(F0084761)
'31Jan12 CKJ Added support for d.PNExclude, requires extra param on Findrdrug which is normally False except for PN issuing
'25Jun12 CKJ Added Alternative Labels        TFS24660
'16Jul12 CKJ Issue: Prevent robot printing if alternative label layout is used                   TFS38989
'10Oct12 AJK 46452 TakeStockFromBatch: Changed find to filter for ADO recordsets
'31Oct12 TH  Issue: Create a sensible max qty msg for PSO (TFS41434)
'14Apr13 AJK 61362 TakeStockFromBatch: Changed filter to an iteration as it breaks for web transport layer produced recordsets for some odd reason
'20Jun13 TH  OrderLog : TransLog : Changed revision level as marker for FM (TFS 65781)
'24Jun13 TH  Translog: Another instance of the value not being accurate for certain logs at the point of writing
'                      This seems to be the case for MB logs that need the blance of cost adding in (TFS 67261)
'18Jul13 TH  Translog: A raft of changes to support QA and Bondstore issues (TFS 56613)
'24Jun13 TH  Translog: Another instance of the value not being accurate for certain logs at the point of writing
'                      This seems to be the case for MB logs that need the blance of cost adding in (TFS 67261)
'23Jul13 TH  Translog: Ensure new QA and Bond handling is only for batch (TFS 67261)
'25Jul13 TH  Translog: Reworked for QA and Bond (TFS 69599)
'16Aug13 CKJ Removed BNF lookup as now deprecated (TFS 42770)
'22Apr14 XN  GetInsCode: Updated to use local code first, then dss language specific then dss english 89088
'            GetWarCode: Updated to use local code first, then dss language specific then dss english 89088
'            ListInstructions: Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088
'            ListWarnings:     Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088

'26Mar14 TH  TranslogExtra: Added to ensure label text is XML escaped and in a reasonable format (TFS 77153)
'09Jun14 TH  Issue: set k.escd on invalid issue so that we can trap internal orders releasing qty to the ordering site on issue TFS 92735
'07Aug14 TH  Translog: Prefix Qty decimal fraction with zero (TFS 78353)
'17Oct14 XN  findrdrug: 88560 Control if allowed to show BNF in drug enquiry
'04Dec14 XN  Issue: Added range check on label count to prevent it blowing 32576
'15Jul14 XN  FillHeapSupplierInfo: Added support for printing extra supplier data, and printing new fields National supplier code, DUNS reference, and user field 1 to 4 88506
'07Jan15 TH  Issue: Added check on Ward Stock top up level (TFS 102826)
'07Jan15 TH  setm_intWardStockTopUpLevel: Added to allow a check on top up level for Ward Stock Issue (TFS 102826)
'19Feb15 TH  ReadWholeWSL: Removed after wsl review as this now seems deprecated (TFS 109032)
'30Apr15 XN  FillHeapDrugInfo: Added LabelDescriptionInPatient to heap (TFS 98073)
'05May15 XN  FillHeapDrugInfo: Added LabelDescriptionOutPatient to heap (TFS 98073)
'20May15 XN  FillHeapDrugInfo: Added LocalDescription to heap (TFS 98073)
'31Jul15 XN  Issue: Added range check on label count 92978
'10Aug15 TH  OrderLog : Prefix decimal fraction under 1 / -1 for qty ordered and qty received with zero (TFS 125871)
'07Apr16 XN  checklossgain: Moved gainloss log to db 123082
'                        Issue: Moved negative log to db 123082
'09Jul16 TH  setm_lngWardStockTopUpLevel: Renamed and changed to long (TFS 157679)
'09Jul16 TH  Issue: Renamed topuplvl variable and changed to long (TFS 157679)
'                        Issue: Moved negative log to db 123082
'01Jul16 KR  getbatchnum: Added trimz to remove superfluous characters.
'26Jul16 XN  Added TSupProfile.EDIBarcode 126634
'                        DrugToSupProfile: Added setting of EDIBarcode 126634
'                        FillHeapDrugInfo: Added EDIBarcode to printing 126634
'                        getdrugsup: Added setting EDIBarcode to blank 126634
'                        GetSupProfile: Added reading EDIBarcode to blank 126634
'                        SupProfileToDrug: Added reading EDIBarcode to blank 126634
'                        SupProfileToDrugSQL: Added reading EDIBarcode to blank 126634
'20Jan17 CKJ Issue: Only request robot labelling for actions which allow it (TFS 106390)
'24Jan17 TH  Issue: Reinstated purer fileexists check for alt labels on DB only - Hosted (TFS 174572)
'08May17 TH  ParseIssueQty: Make sure this routine supports fractions again -set ch as single (TFS 183532)
'22May17 XN  Added GTIN and EDIOrder to orderlogstruct 184323
'22Nov17 VR  Changes to refresh the product stock level immediately before an issue is made (TFS 190825)
'01Dec17 VR  Requisition Number not correctly written to wTranslog "consultant" field (TFS 198726)
'16Jan18 NS  Pharmacy EDI ordering - not writing the correct GTIN code to the wOrderlog file(TFS 200429)
'22Jan18 DR  Bug 201972 - Pharmacy wOrderlog GTIN column needs to be varchar(14) not varchar(13)
'Bug 209618: Pharmacy manufacturing - "Invalid Use of Null" error on searching on strings which are too short
'Bug 212330-Pharmacy Stock value Adjustment zero losses and gains error
'mods needed
'-----------
'
'-----------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Type transaction
   revisionlevel As String * 2  ' new version number of the transaction
   patid As String * 10
   caseno As String * 10        ' new CaseNo
   SisCode As String * 7
   convfact As String * 5       ' new d.convfact
   IssueUnits As String * 5     ' new d.PrintformV
   dispid As String * 3
   terminal As String * 15      ' new equals name of terminal 15 x space if unknown
   date As String * 8           ' was * 6   format now ddmmyyyy
   Time As String * 6           ' was * 4   add seconds as hhmmss
   Qty As String * 13           ' was * 9   to cope with E nums
   cost As String * 13          ' was * 9   to cope with E nums. Now equals Total Cost
   CostExVAT As String * 13     ' new Total Cost less VAT
   VATcost As String * 13       ' new equals VAT content
   VatCode As String * 1        ' new equals VAT code 0 to 9
   vatrate As String * 5        ' new equals VAT rate as "1.175" or similar
   ward As String * 5           ' was * 4   widened to eventually allow 5 char wards
   consultant As String * 9     ' was * 4 widened to allow 9 chars to be saved in (Requistion Number)consultant field in wTranslog Table. 01Dec17 TFS 198726
   specialty As String * 5      ' new equals specialty code or 5 x space if not known
   Prescriber As String * 5     ' new equals prescriber ID
   dircode As String * 255      ' was * 10  ?? any more chars needed?   24oct05 CKJ was 12 now 255. Table & SPs already at 255.
   kind As String * 1
   site As String * 3
   labeltype As String * 1      'ASC 30Nov92
   containers As String * 4     'ASC 23Jan92 but still not used in Jul97
   Episode As Long              ' new ??(Check IBA spec) JP 16.04.08 -
   EventNumber As String * 10   ' new ??(Check IBA spec)
   PrescriptionNum As String * 10  ' new long int is ~4,000,000,000 max
   BatchNum As String * 255     ' new '24Oct06 TH Extended from 10
   ExpiryDate As String * 8     ' new format is ddmmyyyy
   PPflag As String * 1         ' 21Dec98 CFY Added
   stocklvl As String * 9       ' 14Jan99 CFY Added
   custordno As String * 12     ' 18Apr00 CFY Added
   civastype As String * 1      ' 01Jun00 JN Added
   civasamount As String * 5    ' 01Jun00 JN Added
   TransactionID As Long        '05Sep02 SF added
   PrescriptionID As Long       '04Nov07 TH Added
   PrescriberID As Long         '     "
   InternalOrderNumber As Long
   WWardProductListItemID As Long
''   pad As String * 3           ' 21Dec98 CFY - was 35 - Added PPflag & stocklvl (1+9=10) '01Jun00 JN - removed a further 6 bytes for CIVAS returns enhancement    '05Sep02 SF was 7
''   crlf As String * 2           ' new separate this from the padding
End Type

Type orderlogstruct
   revisionlevel As String * 2  ' new version number of the transaction
   ordernum As String * 10     '30May06 TH Lengthened to allow 10 char nums in line with all other v9 processes
   'ordernum As String * 4
   SisCode As String * 7
   convfact As String * 5       ' new d.convfact
   IssueUnits As String * 5     ' new d.PrintformV
   dispid As String * 3
   terminal As String * 15      ' new equals name of terminal 15 x space if unknown
   'dateord As String * 6       ' format still ddmmyy in this version
   'dateordpad As String * 2    ' new ready for format of ddmmyyyy
   dateord As String * 8        '03May98 CKJ Y2K format now ddmmyyyy
   Timeord As String * 6        ' new add seconds as hhmmss
   'daterec As String * 6       ' format still ddmmyy in this version
   'daterecpad As String * 2    ' new ready for format of ddmmyyyy
   daterec As String * 8        '03May98 CKJ Y2K format now ddmmyyyy
   Timerec As String * 6        ' new add seconds as hhmmss
   qtyord As String * 13        ' was * 6   to cope with E nums
   qtyrec As String * 13        ' was * 6   to cope with E nums
   cost As String * 13          ' was * 9   to cope with E nums. Now equals Total Cost
   CostExVAT As String * 13     ' new Total Cost less VAT
   VATcost As String * 13       ' new equals VAT content
   VatCode As String * 1        ' new equals VAT code 0 to 9
   vatrate As String * 5        ' new equals VAT rate as "1.175" or similar
   kind As String * 1
   supcode As String * 5
   site As String * 3
   BatchNum As String * 25      ' new '24Oct06 TH Extended from 10
   ExpiryDate As String * 8     ' new format is ddmmyyyy
   'invnum As String * 12        ' was also used for returns code & batch num
   invnum As String * 20        '12Oct08 TH Extended to 20 to accomodate
   Date3 As String * 8          ' new
   Time3 As String * 6          ' new
   Qty3 As String * 13          ' new
   Info As String * 12          ' new
   LinkedNum As String * 4      ' new returns, supp orders & req’s link to another order
   ReasonCode As String * 4     ' new
   'pad As String * 28           ' new total length is now 256
   stocklvl As String * 9       '25Jan02 TH Added (#53214)
''   pad As String * 19           '    "
''   crlf As String * 2           ' new separate this from the padding
   DeliveryNoteReference As String * 30   '16Aug TH increased to 30 (F0084761)'19Oct10 XN (F0098793) increased to 20 max chars '15Oct10 XN reduced to 10 characters to match db (F0098793) (UMMC FINV)       '02Sep10 TH Added as docket number capture for (UMMC FINV) (F0054531)
   DateInv As String * 8        '02Nov10 AJK F0086901 Added
   PSORequestID As Long
   GTIN As String * 14          '19May17 XN 184323 Add GTIN to db
   EDIOrder As Boolean          '19May17 XN 184323 Add EDIOrder to db
End Type

'Supplier profile
Type TSupProfile                    '30Jun99 CFY Added
   SisCode As String * 7            '         "
   supcode As String * 5            '         "
   contno As String * 10            '         "
   reorderpcksize As String * 5     '         "
   'reorderlvl As String * 8         '08Oct06 TH Removed
   'reorderqty As String * 6         '08Oct06 TH Removed
   sislistprice As String * 9       '         "
   contprice As String * 9          '         "
   LeadTime As String * 3           '         "
   lastreconcileprice As String * 9 '         "
   'tradename As String * 30         '08Oct06 TH Removed
   SuppRefno As String * 36         '         "  '02Nov10 TH Extended from 20 to 36 (UMMC PRF) (F0094388/RCN545)
   AltBarCode As String * 13        '         "
   vatrate As String * 1   '*GST*
   SupplierTradeName As String * 30  '08Oct06 TH Added
   WSupplierProfileID As Long
   EDIBarcode As String * 14                    ' 22Jul16 XN added 126634
End Type

'08Jul99 AE Added
'A structure which holds pharmacokinetics parameters for drugs
'The parameter list holds all possible parameters for all
'current models, only the relevant ones being filled.
''Type DrugKinparam
''   Description As String   'Regimen description
''   RegNum As Integer
''   Selection As String     'SQL selection statement
''   Type As Integer        '1 - aminoglycoside, 2-thoephylline. relates to the model used
''   MinDosInc As Double
''   MinInt As Double                 'Minimum interval for dose recommendations
''   VolofDist As Double
''   SaltFact As Double               'Parameters
''   bioav  As Double                 '           "
''   absk As Double                   '           "
''   Abstime As Double                '10jan00 AE  Absorbtion Time
''   MaxPK As Double                 'Define the theraputic range for this drug
''   MaxAUC As Double                '      "
''   AUCTime As Double               '      "
''   LowBound As Double              '      "
''   HighBound As Double             '      "
''End Type

'''16Nov00 SF added for prescriber enhancements
''' stored in \dispdata.xxx\rxer.mdb "Prescribers" table
''Type PrescriberStruct
''   Code As String * 5
''   inuse As Integer
''   name As String * 30
''   Address1 As String * 30
''   Address2 As String * 30
''   Address3 As String * 30
''   postCode As String * 10
''   telephonenumber As String * 20
''   specialist As String * 25
''   secondaryCode As String * 15
''   registrationNumber As String * 15
''   datecreated As Double
''   prescribertype As String * 5
''   Freetext As String
''End Type

'''05Sep02 SF added to log the state of the label when writing the transaction
''Type transactionExtra
''   TransactionExtraID As Long
''   TransactionID As Long
''   YearMonth As String * 6
''   LabelText As String * 180
''   startdate As Long
''   batchnumber As Integer
''   padding As String * 56
''End Type

Type Batch
   BatchID As Long
   BatchQty As Single
End Type

Global VAT(0 To 9) As Single
Global TransLogVAT%
Global OrderLogVAT%
Global Highfact!
Global Lowfact!
Global entercostonreceipt$
Global tofollow%
Global UtilOrdNum$
Global UtilSupplier$
Global UtilReasonNew$
Global UtilReasonMod$
Global d As DrugParameters

Global LabelValues!()           '17Feb97 KR Used to store multiple labelvalues
Global TotalIssueCost!          '18Feb97 KR Used for storing total cost of issue for printing on labels

Global gTlogCaseno$
Global gTlogSpecialty$
Global gTlogPrescriberID$
Global gTlogEpisode As Long     'JP 16.04.08 - F0015821 - Needed for translog. Changed to Long
Global gTlogEventNumber$
Global gTlogPPFlag$

Global gPrescriberID$         '28Jul99 AE moved from Patmed.bas so that it is declared in Stkmaint
''Global gPrescriberDetails As PrescriberStruct      '16Nov00 SF added for prescriber enhancement

Global gCIVASdos As String * 5
Global gcivasbatch As String

''Global SupProfileDBOpen%               '17Jul00 AW/TH changed for GST

Global Const LBL_END_DESC = &H1F       '16Feb00 AE To indicate split between description and directions for WA label enhancement.
Global Const LBL_END_LINE = &H1E

Global Const ALTLABELCONTEXTROOT = "LBLALT"     '25Jun12 CKJ Alternative labels
Global Const ALTLABELMAX = 24                   'just room for 24 entries in 1024 chars of wConfiguration.Value at 42 chars per entry

Dim strBatchNumberBatchTracking As String       'MM-4114
Dim strExpiryDateBatchTracking As String        'MM-4114

Dim olog As orderlogstruct
Dim procname$
''Dim opened%              '18Jun97 KR Share at module level,not static in sub OpenFormulaDatabase.

''Dim Instruction$(), numofins%        '19Jan98 EAC moved from GetInsCode
''Dim Warning$(), numofwar%            '19Jan98 EAC moved from GetWarCode '18Jan99 EAC changed Numofwars% to Numofwar% as that is variable used in GetWarCode

Dim PrimarySupProfile As TSupProfile   '30Jun99 CFY added to hold the primary supplier info for a drug
Dim AlternativeSupplier$               '30Jun99 CFY Added
Dim emptymsg$                          '28Jul99 AE  Added
'Dim SubPatBatchNum As String * 10      '     "
Dim SubPatBatchNum As String * 255     '04Nov07 TH Altered
Dim SubPatExpiry  As String * 8        '     "
Dim msCustOrdNo As String                  '18Apr00 CFY Added
Dim m_strSubPatExpiryTime As String    '01Oct02 TH Added
Dim m_lngCurrentTransPointer As Long   '05Sep02 SF added
Dim m_strPickNo As String              '16May04 TH Added
Dim m_intBagLabels As Integer          '14apr04 CKJ bag labels are supported; 0 no, 1 deferred print, 2 immediate print
Dim m_blnLowPassLevel As Integer       '16May04 TH Added (UMMC price hide)

'22Feb08 TH Added (F0015066)
Dim m_DefaultSupplierProfileNSV As String
Dim m_strContNo  As String
Dim m_strContprice As String
Dim m_strSuppRefno As String

'22May09 TH Added
'Dim m_blnDispensingReturn As Boolean
Dim m_blnHistoryPrescription As Boolean '14Jan10 TH Renamed the above flag because the neame didnt read well logically

Dim m_strBatchOrderOutputFileName As String  '21Jul10 TH (UHB)(F0077944)
Dim m_UsePNExclude As Boolean                '31Jan12 CKJ Added for PN
Dim m_RepeatBatchID As Long                  '17Apr12 TH Added

Dim m_NHNumber As String               '30Apr12 TH Added
Dim m_NHNumberValid As Integer         '   "

Dim m_ContractNumber As String * 10    '14May12 TH Added (TFS 30860)
Dim m_ContractPrice As String * 9      '   "
Dim m_Contract As Boolean              '   "

Dim m_AltLabelContext As String              '25Jun12 CKJ

Global g_blnPSO As Boolean  '02Aug12 TH PSO (Moved from Patmed)

Dim m_intQAQty As Integer '01Jul13 TH Moved from Formula

Dim m_WWardProductListItemID As Long      '30Dec14 TH Added to record WardListID in Translog
Dim m_lngWardStockTopUpLevel As Long   '07Jan15 TH Added to allow a check on top up level for Ward Stock Issue (TFS 102826)'09Jul16 TH Renamed and changed to long (TFS 157679)

Dim m_eHubHeapID As Integer  '04Mar13 TH eHubHeapID - needed for order output
Dim str_eHubPatientBlock As String   '01Apr14 TH eHub

Dim LookupHeapId As Integer  '29Jun17 TH Added (TFS 191443)

Private Const OBJNAME As String = PROJECT & "SubPatMe."

Function ActionIssueConfig() As Integer
'14Apr04 CKJ Written
'            Allows behaviour of the issue form to be controlled from the main app
'            without adding all possible actions inside the issue form itself.
'
'            Returns   0/1    F7 pressed - callback happened, see below
'
'            Bag labels may be available or may not be handled at all in the current module
'            The default is no handling. If handling is available then two modes may operate;
'            [F7] to print instantly via a callback, or
'            enter number of labels in text box ([F7] increments) then handle after form is hidden

Dim intReturn As Integer

   intReturn = 0
   Select Case m_intBagLabels
      Case 1: intReturn = 1                                 'calling routine should increment counter
      Case 2: Issue_Callback                                'print one standard label now
      End Select

   ActionIssueConfig = intReturn

End Function

Sub AddStockOfBatch(SisCode$, expiry$, IssueQty!, batchnumber$)
'16Aug96 ASC
'08Mar07  TH Extended batchnumber
'06Jun08  TH Changed qty param to float
Dim strParams As String
Dim lngResult As Long
Dim dteExpiry As Date

   dteExpiry = CDate(expiry$)
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, d.LabelDescription) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, SisCode$) & _
               gTransport.CreateInputParameterXML("BatchNumber", trnDataTypeVarChar, 25, batchnumber$) & _
               gTransport.CreateInputParameterXML("Expiry", trnDataTypeDateTime, 8, dteExpiry) & _
               gTransport.CreateInputParameterXML("Qty", trnDataTypeFloat, 8, IssueQty!)
   lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WBatchStockLevel", strParams)
   
End Sub


Function AlphaNum$(lin$)
'-----------------------------------------------------------------------------
' Parse string and return only alphanumeric characters
' Case is preserved
'25Oct94 CKJ Written
'-----------------------------------------------------------------------------

Dim chars$, i%, ch$                  '28Jul99 AE Dim'd variable
   chars$ = ""
   For i = 1 To Len(lin$)
      ch$ = Mid$(lin$, i, 1)
      Select Case ch$
         Case "A" To "Z", "a" To "z", "0" To "9"
            chars$ = chars$ + ch$
         End Select
   Next
   AlphaNum$ = chars$

End Function


Sub checkcode(d As DrugParameters, badcheck%)
'-------------------------------------------------------------------------------
'Checks the dispensary drug code is AAAA111 or a truncation
'If badcheck = 2 then check is on code alone
'
'22Nov90 CKJ badcheck of 3 suppresses the popup window
'26Oct94 CKJ Checking with drug name now removed. Badcheck of 2 ignored
'            Popwin reduced
'            Use of '-' in a code is no longer valid
'28Jan99 CFY Changed wording of message if an invalid code is found.
'08Feb99 CFY Removed hard coded pattern mask. Now uses masks from stkmaint.ini
'06Apr99 TH  Removed code to match 8066
'
'-------------------------------------------------------------------------------

Dim lookup$
Dim match%
Dim Popwin%
Dim temp$

   If badcheck = 3 Then Popwin = False Else Popwin = True
   badcheck = False
   'If badcheck <> 2 And UCase$(Left$(d.code, 2)) <> UCase$(Left$(d.description, 2)) Then  '06Apr99 TH Taken out to match 8066
   '     badcheck = True                                                                   '  "
   '  End If                                                                               '  "
   temp$ = RTrim$(UCase$(d.Code))

   If Len(temp$) < 3 Then badcheck = True
      
   If Not badcheck Then
         match% = False
         lookup$ = LookupPattern()
         If lookup$ <> "" Then
               If Len(lookup$) > Len(temp$) Then
                     lookup$ = Left$(lookup$, Len(temp$))
                  End If
               match% = PatternMatch(temp$, lookup$)
            End If
         badcheck = Not match%
      End If
                                                                                          
   If badcheck And Popwin Then
         popmessagecr "#Incorrect Drug Code", "Look up code is missing or invalid"                                      '              "
      End If
End Sub

''Sub checkdrugfile()
'''-----------------------------------------------------------------
'''Used to close drug files before opening differently when indexing
'''06Sep99 CKJ Added call to TrackOpenedFiles
'''-----------------------------------------------------------------
''
''   ' SHARED findchan%                                    '25Oct94 CKJ removed
''   If getdchan <> 0 Then
''         Close getdchan
''         TrackOpenedFiles getdchan, "", ""               '24Aug99 CKJ
''         getdchan = 0
''      End If
''   ' IF findchan <> 0 THEN CLOSE findchan: findchan = 0  '25Oct94 CKJ removed
''
''End Sub

Sub checklossgain(d As DrugParameters, rec$, ordcost$, purprice$, newcost$, Qty!, descr$)
'ASC 21Jul92
'ASC 15Sep92 desc$ and d.siscode added to recorded data i.e. 'came from'
'13Dec96 CKJ Log now in dispdata.xxx
'07Apr16 XN  Moved gainloss log to db 123082

Dim pau!, adjust!, text$                    '28Jul99 AE Dim'd variable
   If Val(d.anuse) < 1 Then pau! = 1 Else pau! = Val(d.anuse)
   adjust! = d.lossesgains / (pau! / 12)

   If (adjust! > 3 * Val(d.cost)) Or (adjust! < -1 * Val(d.cost)) Then
         text$ = descr$ + "Stck lvl=" + d.stocklvl + vbNewLine
                 text$ = text$ + "Pck Sz=" + d.convfact + vbNewLine
                 text$ = text$ + "Issue price=" + d.cost + "|" + newcost$ + vbNewLine
                 text$ = text$ + "Pharmacy agreed price" + ordcost$ + vbNewLine
                 text$ = text$ + "Reconciled price=" + purprice$ + vbNewLine
                 text$ = text$ + "Qty received/reconciled=" + rec$ + vbNewLine
                 text$ = text$ + "Ann use=" + d.anuse + vbNewLine
         text$ = text$ + "Qty issued =" + Str$(Qty!) + vbNewLine
        text$ = text$ + "Resultant Losses/gains=" + Str$(d.lossesgains) + vbNewLine
        'MM-7804- unable to write to wpharmacylog for losses and gains, parameter order is changed to insert properly to WPharmacyLog and WPharmacyLogType table
        WriteLogSQL text$, "gainloss", 0, 0, d.SisCode
         'WriteLog dispdata$ & "\gainloss.log", 0, "", text$ 07Apr16 XN  Moved gainloss log to db 123082
      End If

End Sub


''Sub CloseFormulaDatabase()
'14Jan99 Removed code from CloseSubPatMed to separate routine here. Can now be called from the
'        manufacturing screen as it is unloaded.
'11oct99 CKJ Moved line

'   If Opened% Then
'         On Error Resume Next
'         FormulaTable.Close
'         StockLvlTable.Close
'         DbFormula.Close
'         'Set DbFormula = Nothing            '11oct99 CKJ moved below
'         Set FormulaTable = Nothing
'         Set StockLvlTable = Nothing
'         Set DbFormula = Nothing             '11oct99 CKJ moved here
'         Opened% = False
'         On Error GoTo 0
'      End If

''End Sub

''Sub CloseSubPatMed()
'''29Mar96 KR  Added CheckDrugFile to closing down
'''26Sep96 CKJ Added TransChan & IssuedChan as well
'''18Jun97 KR  Added. Close formula database and clear db variables if open.
'''14Jan99 CFY Removed code which closes the formula database and placed in a separate subroutine
'''            which can then be called on its onwm from the manufacturing form.
'''28Jul99 AE  corrected getchan with getDchan.
'''06sep99 CKJ Added calls to TrackOpenedFiles
''
''   checkdrugfile
''
''   If ordtranchan > 0 Then
''         Close ordtranchan
''         TrackOpenedFiles ordtranchan, "", ""
''         ordtranchan = 0
''      End If
''
''   If transchan > 0 Then
''         Close transchan
''         TrackOpenedFiles transchan, "", ""
''         transchan = 0
''      End If
''
''   If IssuedChan > 0 Then
''         Close IssuedChan
''         TrackOpenedFiles IssuedChan, "", ""
''         IssuedChan = 0
''      End If
''
''   CloseSupplierFile
''
''   '''SQL CloseFormulaDatabase       '14Jan99 CFY Added to replace code below
''
''End Sub

Sub displaydrugline(d As DrugParameters, ByVal Stores As Integer, ByVal Index As String, ByVal blnMaster As Boolean, ByVal blnOtherRoutes As Boolean)
' 7Feb92 CKJ Avoids overflow error on display
'16Feb92 ASC Popmessagecr added at same place to make more inconvenient
'25Oct94 CKJ Rewritten for FindDrug.frm
'            stores% not currently used, but left in case wanted
'17Mar96 KR  Store the drug pointer in the list.itemdata property.
'07Nov96 KR  Changed line displayed so that fields separated by tabs and
'            thus can be used with the tabbed listbox.
'19Jan98 EAC Add blob to signify if drug is on decision support service
'11Mar98 CFY Changed to display stores description by default. If stores description
'            is blank then revert to the dispensary description.
'30Sep98 CKJ Removed extraneous spaces, as there was just not enough room in large fonts
'            Tidied the procedure, removing old comments
'            Characters to indicate DSS status are now in country.044 etc;
'             FindItemScreenDSSchar0, FindItemScreenDSSchar1 = "32" to "255"
'14Mar99 ASC Added index$ so that the trade name can be shown in a trade name search
'16Feb04 CKJ FindItemScreenChar added
'16May04 TH  Added mod to suppress cost view if configured (UMMC price hide enhancement)
'27May04 TH  Changed above to use Hideprice call
'06May10 AJK F0073627 Added blnOtherRoutes param to be checked and add prefix to off route item display

Static doneonce%, ondss0$, ondss1$

Dim ondss$                 '19Jan98 EAC added
Dim MechDispSection As String           '16Feb04 CKJ
Dim lin$, LineCost$                     '28Jul99 AE Dim'd variable

   If Not doneonce Then
         ondss0$ = Chr$(Val(TxtD("country", "", "", "FindItemScreenDSSchar0", 0)))    'blank
         ondss1$ = Chr$(Val(TxtD("country", "", "183", "FindItemScreenDSSchar1", 0))) 'small blob
         doneonce = True
      End If

   If Index$ = "tradename" Then lin$ = Trim$(d.tradename) & " ~"
   'If Trim$(d.storesdescription) = "" Then
         'lin$ = lin$ & d.Description
      'Else
         'lin$ = lin$ & d.storesdescription
      'End If XN 4Jun15 98073 New local stores description
   lin$ = lin$ & d.DrugDescription
   plingparse lin$, "!"
   
   lin$ = Trim$(lin$) & TB
   
   Select Case Val(d.stocklvl)
      Case Is < 0: lin$ = lin$ & "NEG"
      Case 0:      lin$ = lin$ & "OUT"
      Case Else:
      End Select

   lin$ = lin$ & TB
   If d.mlsperpack > 0 Then lin$ = lin$ & Format$(d.mlsperpack)    '07Nov96 KR changed.

   If Val(d.convfact) Then     ' 7Feb92 CKJ Avoids Overflow if value not entered
         LineCost$ = LTrim$(Str$(Val(d.cost) / Val(d.convfact) / 100))
         poundsandpence LineCost$, True
      Else
         LineCost$ = "?"
         popmessagecr "!Contact system manager", "Stores pack size zero for items with price marked ?"
      End If
   
   '19Jan98 EAC  Add blob to signify if drug is on decision support service
   If d.indexed = "1" Then                                   '30Sep98 CKJ Added ini option
         ondss$ = ondss1$    'small blob
      Else
         ondss$ = ondss0$    'blank
      End If

   'If (truefalse(txtd$(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then linecost$ = "*****"     '16May04 TH Added '27May04 TH Removed
   '16Feb04 CKJ added block for mechanical dispensing machines
   MechDispSection = SectionIDForMechDisp(d.loccode)
   If Len(MechDispSection) Then
         ondss$ = TxtD(dispdata$ & "\mechdisp.ini", MechDispSection, ondss$, "FindItemScreenChar", 0)
      End If

   lin$ = lin$ & TB & HidePrice(Right$(Space$(5) & LineCost$, 5), False) & TB & LCase$(Left$(d.PrintformV, 4)) & TB & ondss$ '27May04 TH Added Hideprice call

   '06May10 AJK F0073627 Add prefix to off route items
   If blnOtherRoutes = True Then
      lin$ = TxtD(dispdata$ & "\PATMED.INI", "", "~", "OffRouteProductDisplayPrefix", 0) & " " & lin$
   Else
      lin$ = " " & lin$
   End If

   On Local Error Resume Next
   Finddrug.lstDrugs.AddItem lin$
   If blnMaster Then
      Finddrug.lstDrugs.ItemData(Finddrug.lstDrugs.NewIndex) = Str$(d.SiteProductDataID)
   Else
      Finddrug.lstDrugs.ItemData(Finddrug.lstDrugs.NewIndex) = Str$(d.productstockID)
   End If
   On Local Error GoTo 0

End Sub

Sub DrugToSupProfile(d As DrugParameters, SupProfile As TSupProfile)
'30Jun99 CFY Written
'Copies relevents sections of the drug structure to the supplier profile structure
      
   SupProfile.SisCode = d.SisCode
   SupProfile.supcode = d.supcode
   SupProfile.contno = d.contno
   SupProfile.reorderpcksize = d.reorderpcksize
   'SupProfile.reorderlvl = d.reorderlvl
   'SupProfile.reorderqty = d.reorderqty
   SupProfile.sislistprice = d.sislistprice
   SupProfile.contprice = d.contprice
   SupProfile.LeadTime = d.LeadTime
   SupProfile.lastreconcileprice = d.lastreconcileprice
   'SupProfile.tradename = d.tradename
   SupProfile.AltBarCode = d.barcode
   SupProfile.vatrate = d.vatrate  '*GST*
   SupProfile.EDIBarcode = d.EDIBarcode         ' 22Jul16 XN added 126634

End Sub

Sub EditDrugMsg(DrugPtr As Long)
'13Mar96 CKJ Removed inputbox
'05Dec96 EAC Drug remains locked if user escapes
'13Dec96 EAC/CKJ Decided to only lock & update if user actually edits
'            Last saved notes are retained - no msg if modified in meantime

Dim d As DrugParameters  '19jul96 CKJ added
Dim foundPtr&, ans$                                  '28Jul99 AE Dim'd variable
   
   getdrug d, DrugPtr&, foundPtr&, False
   If foundPtr& Then
      ans$ = Trim$(d.message)
      k.Max = Len(d.message)
      'inputwin "Drug Notes", "Enter notes for:" & cr & cr & d.Description, ans$, k   XN 4Jun15 98073 New local stores description
          InputWin "Drug Notes", "Enter notes for:" & cr & cr & d.LabelDescription, ans$, k
      If Not k.escd Then
         'beginstuff
         getdrug d, DrugPtr, foundPtr&, True  '13Dec96 CKJ/EAC lock drug
         d.message = ans$
''       putdrug d, DrugPtr
         PutProductNL d
         'commitstuff
      End If
   End If

End Sub

Sub FillDrugList(drug$, Index$, ByVal blnMaster As Boolean, Optional ByVal blnOtherRoutes As Boolean)
'22Feb99 ASC created from Findrdrug to stop re-entrancy for new Finddrug form
'28Jul99 AE  Dim'd variables, added call to StoresValue as previously Stores was not declared or set
'            IsASCcode now passed via cmdLetter(0).Tag on FindDrug. Was previously not declared,
'            hence the copy that was being set here was different to the copy used in findrdrug. Cannot
'            be a simple parameter since this procedure is called from findrdrug and FindDrug.frm.
'            Moved block which set prompt$ from findrdrug to here; again, was not declared and was being
'            set in findrdrug but used here, hence was always blank.
'18Nov99 AE  Moved line which sets IsASCcode; seems to have got lost in the merge, and meant that new
'            drugs could not be added.
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting.
'            Read and cache the ward stock list for this ward, and if 'View All' button is visible then
'            check each item is on the WSL before showing it. NB uses a static string, max 2000 drugs
'09Apr01 CKJ Added call to GetSetLocalWardListCode since PID.ward not in scope except in ASCshell
'03May01 CKJ use enabled property of View All button instead of .visible
'04Jun03 TH  Merged Following mod from 8.4 . This had previously been missed (#68165)
'29Jan02 CKJ When prescribing with friendly list, allow drugs from main list where these are
'            specified by NSVcode. This prevents subsequent 'drug not found msgs' when using
'            a drug which isn't on the friendly list.
'04Jun03 TH  ---------------------------
'23oct08 CKJ reinstated description search with multiple words eg "sodium chloride" (F0021923)
'06May10 AJK F0073627 Added blnOtherRoutes input to be passed to ProductLookup
'06May10 AJK F0073627 Removed single item check for generating headings
'06May10 AJK F0073627 Added check to ensure list is not empty before setting item
'03Aug10 XN  Stores only products are now identified by d.ProductID <> 0, also force any WProudct.InUse = "S" read from DB to "Y"  (F0088717)
'31Jan12 CKJ Added support for PNExclude

''Static strLocalList As String
 
Dim Headings$
Dim nf$, X%, valid%, ptr%, LookupPatt$, hashpos%
Dim schstart&, cont&, notshown%, foundit&, nod&, OK%
Dim Stores%, i%, isASCcode%
Dim AltDispdata As String
Dim wardcode As String
Dim blnIsNSVcode As Integer
Dim wildcard As Boolean
Dim rs As ADODB.Recordset
Dim tabstop As Integer

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "FillDrugList"

   On Error GoTo ErrorHandler

   ReDim Tabs(6) As Long
   
   blnIsNSVcode = False
   wildcard = False
   
''   If siteinfo$("FormularyEXT", "") = "" Then                                  '09Apr01 CKJ Formulary site not defined
''         AltDispdata$ = dispdata$                                              '            use standard one
''      Else                                                                     '            Formulary site is defined
''         AltDispdata$ = siteinfo$("FormularyDRV", "") & "\dispdata." & siteinfo$("FormularyEXT", Right$(dispdata$, 3))
''      End If

   nf$ = " not found"
   StoresValue 0, Stores
   k.escd = False
   
   Finddrug.lstDrugs.Visible = True
   Finddrug.lstBNFchap.Visible = False
   Finddrug.lstBNFchap.tabstop = False
   Finddrug.lstBNFsect.Visible = False
   Finddrug.lstBNFsect.tabstop = False
   For X = 0 To 3
      Finddrug.lblDrugInfo(X).Visible = True
   Next
   Finddrug.txtDrugsHdr.Visible = True
   '@~@~@~@~ set visible bits here

   k.escd = False
   
   '!!** Set index & search criteria for restricted drug search
   'Filter results against permitted items in product family and by route?
   
   If Not k.escd And Index$ = "" Then                 'check if AMP family
      If Left$(drug$, 1) = "¦" Then
         Index$ = "VMPAMPAMPP"
         drug$ = Mid$(drug$, 2)
      End If
   End If
   
   If Not k.escd And UCase$(Index$) = "VMPAMPAMPP" Then                 'check if AMP family
      If IsDigits(drug$) Then
         'emptymsg$ = "Product ID " & drug$ & nf$                       '01dec05 CKJ extended message
         emptymsg$ = "Product ID " & drug$ & nf$ & " in site " & Format$(SiteNumber) & cr & cr & "If this Product code exists, it may not be in use" & cr & "or it may not be available in this department"
      Else
         Index$ = ""
      End If
   End If

   If Not k.escd And Index$ = "" Then                'check if trade name
      If Left$(drug$, 1) = "?" Then                     'Trade names
         emptymsg$ = "Trade name " & drug$ & nf$
         drug$ = AlphaNum$(Mid$(drug$, 2))
         Index$ = "tradename"
      End If
   End If

   If Not k.escd And Index$ = "" Then                'check if barcode
      Select Case Len(drug$)
         Case 8, 13, 14
            If IsDigits(drug$) Then                  'is it a barcode?
               emptymsg$ = "Barcode " & drug$ & nf$
               Index$ = "barcode"
            End If
         End Select
   End If

   If Not k.escd And Index$ = "" Then                'check if NSVcode
      If PatternMatch(drug$, NSVpattern$()) Then  '12Jul97 CKJ Replaced fixed pattern
         emptymsg$ = "NSV code " & drug$ & nf$
         Index$ = "nsvcode"
         blnIsNSVcode = True
      End If
   End If
           
   If Not k.escd And Index$ = "" Then                'check if ASCcode or name
      Select Case Len(drug$)
         Case 2 To 8
            LookupPatt$ = LookupPattern()
            If LookupPatt$ <> "" Then
               If Len(LookupPatt$) > Len(drug$) Then
                  LookupPatt$ = Left$(LookupPatt$, Len(drug$))
               End If
               If PatternMatch(drug$, LookupPatt$) Then
                  emptymsg$ = "Lookup code " & drug$ & nf$
                  Index$ = "code"
                  isASCcode = True
               End If
            End If
         End Select
   End If
                                                                     
   If Not k.escd And Index$ = "" Then                '15Jul97 CKJ Check if local code
      If LocalPattern$() <> "" Then               '06Aug98 CKJ Only check if pattern defined
         If PatternMatch(drug$, LocalPattern$()) Then
            emptymsg$ = "Local code " & drug$ & nf$
            Index$ = "local"
         End If
      End If
   End If
                                                                                                     
   If Not k.escd And Index$ = "" Then                '06Aug98 CKJ Check local if prefix given
      If Left$(drug$, 1) = TxtD(dispdata$ & "\StkMaint.ini", "Data", "=", "LocalCodePrefix", 0) Then 'variable stkmaint$ not declared in ASCshell
         drug$ = Mid$(drug$, 2)
         If Len(drug$) Then
            emptymsg$ = "Local code " & drug$ & nf$
            Index$ = "local"
         End If
      Else                                            'Description search
         If Len(drug$) Then
'            If Left$(drug$, 1) = "*" Then                        '23oct08 CKJ original code
'               emptymsg$ = "Product " & drug$ & nf$
'               Index$ = "description"
'               wildcard = True
'               drug$ = Mid$(drug$, 2)
'               hashpos = InStr(drug$, "#")
'               If hashpos Then
'''                  schstart& = Val(Mid$(drug$, hashpos + 1))     V93 - NOT SUPPORTED (searches from numbered line onwards)
'                  drug$ = Left$(drug$, hashpos - 1)
'               End If
'            Else
'               drug$ = AlphaNum$(drug$)
'               emptymsg$ = "Product name " & drug$ & nf$
'               If Len(drug$) Then Index$ = "description"
'            End If
            emptymsg = "Product name '" & drug & "'" & nf         '23oct08 CKJ replace non "A-Z|0-9|." with a single wildcard
            For X = 1 To Len(drug)
               Select Case Mid$(drug, X, 1)                       'check each character
                  Case "a" To "z", "A" To "Z", "0" To "9", "."
                     'use unchanged
                  Case Else
                     Mid$(drug, X, 1) = "%"                       'wildcard
                  End Select
            Next
            replace drug, "%%", "%", 0                            'remove runs of % signs
            Index$ = "description"                                '23oct08 CKJ ---
         End If
      End If
   End If

   notshown = False
   If Index$ <> "" Then                              'fill the drug list box
      If blnMaster Then
         'call seperate lookup here
         Set rs = ProductMasterLookup(Index, drug, wildcard)
      Else
         '06May10 AJK F0073627 Added blnOtherRoutes
         Set rs = ProductLookup(Index, drug, wildcard, blnOtherRoutes)
      End If
      
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               Do While Not rs.EOF
                  BlankWProduct d
                        If Not IsNull(rs.Fields("ProductID").Value) Then
                            d.ProductID = rs!ProductID
                        End If
                        If Not IsNull(rs.Fields("productstockID").Value) Then
                            d.productstockID = rs!productstockID
                        End If
                  d.SisCode = RtrimGetField(rs!SisCode)
                  'd.Description = RtrimGetField(rs!Description)  XN 4Jun15 98073 New local stores description
                                  d.DrugDescription = RtrimGetField(rs!Description)
                                  d.LabelDescription = RtrimGetField(rs!LabelDescription)
                  d.storesdescription = RtrimGetField(rs!storesdescription)
                  d.inuse = RtrimGetField(rs!inuse)
                  If d.inuse = "S" Then d.inuse = "Y"           '03Aug10 XN  Force any WProudct.InUse = "S" read from DB to "Y"  (F0088717)
                  d.convfact = RtrimGetField(rs!convfact)
                  d.cost = RtrimGetField(rs!cost)
                  d.stocklvl = RtrimGetField(rs!stocklvl)
                  d.mlsperpack = RtrimGetField(rs!mlsperpack)
                  d.loccode = RtrimGetField(rs!loccode)
                  d.PrintformV = RtrimGetField(rs!PrintformV)
                  If blnMaster Then
                     d.SiteProductDataID = RtrimGetField(rs!SiteProductDataID)
                  Else                                            '07Mar12 TH Added to allow PN filtering (TFS28622)
                     d.PNExclude = RtrimGetField(rs!PNExclude)    '      "
                  End If                                          '      "
                  OK = False
                  
                  ' 3Aug10 XN F0088717 Stores only products are now identified by d.ProductID <> 0
                  ' Okay to show everthing if product is in use, and either
                  '     non-stores product
                  '         stores product and stores = -1
                  ' Or always show everthing if Stores = 1
                  If ((d.inuse = "Y") Or (d.inuse = " ")) And ((d.ProductID <> 0) Or (Stores = -1)) Then OK = True
                  If Stores = 1 Then OK = True
                  
'                  Select Case d.inuse
'                     Case "Y", " ": OK = True                ' is in use
'                     Case "S": If Stores = -1 Then OK = True ' S in stores
'                     End Select
'                  If Stores = 1 Then OK = True               ' show everything
                  ' end of F0088717
                  
''                  '09Apr01 CKJ decide if item is on the friendly list
''                  If strLocalList = "" Then
''                        GetSetLocalWardListCode False, wardcode                                'Added since PID.ward not in scope
''                        ReadWholeWSL wardcode, strLocalList, 0                                 'fill the friendly list
''                     End If
''                  If strLocalList = "," Then Finddrug.cmdAll.Enabled = False                   'no local list anyway
''                  Finddrug.cmdAll.Visible = Finddrug.cmdAll.Enabled                            '                         "    set visible from this
''                  If Finddrug.cmdAll.Enabled And Len(strLocalList) > 7 Then                    'at least one item
''                        If InStr(strLocalList, "," & d.SisCode & ",") = 0 Then OK = False      ',NSVcode,NSVcode,NSVcode,'
''                        If blnIsNSVcode Then OK = True                      '29Jan02 CKJ added '04Jun03 TH Merged
''                     End If

                  If m_UsePNExclude And d.PNExclude Then OK = False           '31Jan12 CKJ Don't show if PNExclude in force
                  
                  If OK Then
                     If Finddrug.lstDrugs.ListCount >= 700 Then
                        notshown = True        ' in danger of using up 64K
                        Exit Do                ' allocated to a list box
                     Else
                        displaydrugline d, Stores, Index$, blnMaster, blnOtherRoutes
                     End If
                  End If
               
                  rs.MoveNext
               Loop
            End If
         End If
      End If
   End If

   If notshown Then
      popmessagecr "!Note:", "The first" & Str$(Finddrug.lstDrugs.ListCount) & " items will be displayed"
   End If

   BlankWProduct d

      '06May10 AJK F0073627 Removed check as we always want to generate headings
'   If Finddrug.lstDrugs.ListCount > 0 Then           'did we find any?
'      If Finddrug.lstDrugs.ListCount = 1 Then        'only one drug found
'         Finddrug.lstDrugs.ListIndex = 0             'first drug in list
'      Else
         tabstop = Iff(Finddrug.lstDrugs.FontBold, 63, 75)
         Headings = Space$(tabstop) & TB & "Stock" & TB & "Pack" & TB & "Cost " & TB & "Unit" & TB
         i = 0                                       'number of tabstops found
         X = 0                                       'position in string
         Do
            X = InStr(X + 1, Headings, TB)
            If X Then
                  i = i + 1
                  Tabs(i) = X * 4
               End If
         Loop While X > 0
         ListBoxTextBoxSetTabs Finddrug.lstDrugs, (i), Tabs()     '(just clears if none found)
                                    
         SetTextBoxReadOnly Finddrug.txtDrugsHdr, True    '30Sep98 CKJ Tabbed text box used instead of label
         ListBoxTextBoxSetTabs Finddrug.txtDrugsHdr, (i), Tabs()  '(just clears if none found)
         Finddrug.txtDrugsHdr = Finddrug.txtDrugsHdr.Tag & TB & "Stock" & TB & "Pack" & TB & money$(7) & TB & "Unit"
         
         '06May10 AJK F0073627 Added check to ensure list is not empty
         If Finddrug.lstDrugs.ListCount > 0 Then Finddrug.lstDrugs.ListIndex = 0       'highlight 1st drug in list '20Jan95 CKJ Added
'      End If
'   End If
   
   Finddrug.CmdLetter(0).Tag = Format$(isASCcode)  '18Nov99 AE Moved.  IsASCcode is set here, and used in findrdrug

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Sub

Sub FillHeapDrugInfo(ByVal HeapID As Integer, d As DrugParameters, success As Integer)
'23Jul98 TH/CKJ Puts a drug on the heap or takes one off
'            All entries prefixed with 'i' to indicate Item (avoiding the word 'drug')
'            ID=id of heap (if negative then removes drug from that heap)
'            ID=0  adds to global print heap
'            success% not used yet, but present for future compatibility
'19Oct98 CKJ corrected d.loccode, amended l.local and removed d.extralocal
'22Apr02 SF  added d.loccode2 to the heap (enh#1555)
'16May04 TH  Added new general description iGendesc - uses stores desc if available, else resorts to normal description (#71558)
'21May04 TH  Altered above mod - removed a call to getstoresdescription due to referencing problems.
'22Feb05 TH  Parse date created and modified elements
'28Feb05 TH  All dates now in configurable format
'20Mar09 TH  Added new heap elements for UHB (F0032689)
'06May09 TH  Added an xml Parsed description element (F0052059)
'07Apr10 AJK Added fields for F0072542 and F0072782
'14Apr10 AJK Added fields for F0072782
'17May10 TH  Added iDescriptionXML as UHB use the none xML element of this as well as the trimmed one (F0077941)
'30Apr15 XN  FillHeapDrugInfo: Added LabelDescriptionInPatient to heap (TFS 98073)
'05May15 XN  FillHeapDrugInfo: Added LabelDescriptionOutPatient to heap (TFS 98073)
'20May15 XN  FillHeapDrugInfo: Added LocalDescription to heap (TFS 98073)

Dim act%, temp$, temp2$ '16May04 TH Added temp2$
Dim id%                    '28Jul99 AE Dim'd variable
Dim strDate As String
Dim strDateFormat As String  '28Feb05 TH Added
Dim strTemp As String  '06May09 TH Added

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
         strDateFormat = TxtD(dispdata$ & "/patmed.ini", "", "DD/MMM/CCYY", "DrugPrintHeapDateFormat", 0)
         ' commented changes to Heap names are subject to discussion
         Heap act, id, "iCode", Trim$(d.Code), 0
         'temp$ = d.Description  XN 4Jun15 98073 New local stores description
                 temp$ = d.LabelDescription
         plingparse temp$, "!"
         Heap act, id, "iDescription", Trim$(temp$), 0
         Heap act, id, "iDescriptionXML", XMLEscape(Trim$(temp$)), 0    '17May10 TH Added UHB (F0077941)
         strTemp = Left$(temp$, Val(TxtD(dispdata$ & "\genint.ini", "StockInterface", "20", "DescriptionTrim", 0))) '06May09 TH Added (F)
         Heap act, id, "iDescriptionTrim", strTemp, 0
         Heap act, id, "iDescriptionTrimXML", XMLEscape(strTemp), 0 '06May09 TH Added
         Heap act, id, "iInuse", Trim$(d.inuse), 0
         Heap act, id, "iDeluserid", Trim$(d.deluserid), 0
         Heap act, id, "iTradename", Trim$(d.tradename), 0
         Heap act, id, "iCost", Trim$(d.cost), 0
         Heap act, id, "iCost/100", Format$(Val(d.cost) / 100, "0.00"), 0
         Heap act, id, "iContno", Trim$(d.contno), 0
         Heap act, id, "iSupcode", Trim$(d.supcode), 0
         Heap act, id, "iAltsupcode", Trim$(d.altsupcode), 0
         Heap act, id, "iWarningcode2", Trim$(d.warcode2), 0
         Heap act, id, "iLedcode", Trim$(d.ledcode), 0
         Heap act, id, "iNSVcode", Trim$(d.SisCode), 0
         Heap act, id, "iBarcode", Trim$(d.barcode), 0
         Heap act, id, "iCyto", Trim$(d.cyto), 0
         Heap act, id, "iCivas", Trim$(d.civas), 0
         Heap act, id, "iFormulary", Trim$(d.formulary), 0
         Heap act, id, "iBnf", Trim$(d.bnf), 0
         Heap act, id, "iReconvol", Format$(d.ReconVol), 0
         Heap act, id, "iReconabbr", Trim$(d.ReconAbbr), 0
         Heap act, id, "iDiluent1abbr", Trim$(d.Diluent1Abbr), 0
         Heap act, id, "iDiluent2abbr", Trim$(d.Diluent2Abbr), 0
         Heap act, id, "iMaxmgPerml", Format$(d.MaxmgPerml), 0
         Heap act, id, "iWarningcode", Trim$(d.warcode), 0
         Heap act, id, "iInscode", Trim$(d.inscode), 0
         Heap act, id, "iDirectioncode", Trim$(d.dircode), 0
         Heap act, id, "iLabelformat", Trim$(d.labelformat), 0
         'Heap act, ID, "iExpiryminutes", Format$(d.expiryminutes), 0
         Heap act, id, "iExpirymin", Format$(d.expiryminutes), 0
         'Heap act, id, "iExpiryDays", Format$(Int((d.expiryminutes / 1440) + 0.99999)), 0  '20Mar09 TH Added for UHB (F0032689)
         Heap act, id, "iExpiryDays", Format$(((d.expiryminutes + 1339) \ 1440)), 0  '09Apr09 TH Added after CKJ Review
         Heap act, id, "iStockedyn", YesNo(Val(d.sisstock)), 0
         Heap act, id, "iStocked", d.sisstock, 0
         Heap act, id, "iAtc", Trim$(d.ATC), 0
         'Heap act, ID, "iReorderpacksize", Trim$(d.reorderpcksize), 0
         Heap act, id, "iReordpcksize", Trim$(d.reorderpcksize), 0
         Heap act, id, "iPrintform", Trim$(d.PrintformV), 0
         Heap act, id, "iMinissue", Trim$(d.minissue), 0
         Heap act, id, "iMaxissue", Trim$(d.maxissue), 0
         Heap act, id, "iReorderlevel", Trim$(d.reorderlvl), 0
         Heap act, id, "iReorderquantity", Trim$(d.reorderqty), 0
         Heap act, id, "iPackSize", Trim$(d.convfact), 0
         Heap act, id, "iAnuse", Trim$(d.anuse), 0
         Heap act, id, "iMessage", Trim$(d.message), 0
         Heap act, id, "iTherapcode", Trim$(d.therapcode), 0
         Heap act, id, "iExtralabel", Trim$(d.extralabel), 0
         Heap act, id, "iStocklevel", Trim$(d.stocklvl), 0
         Heap act, id, "iSislistprice", d.sislistprice, 0
         Heap act, id, "iSislistprice/100", Format$(Val(d.sislistprice) / 100, "0.00"), 0
         Heap act, id, "iContprice", d.contprice, 0
         Heap act, id, "iContprice/100", Format$(Val(d.contprice) / 100, "0.00"), 0
         'Heap act, ID, "iLivestockcontrol", Trim$(d.livestockctrl), 0
         Heap act, id, "iLivestock", Trim$(d.livestockctrl), 0
         Heap act, id, "iLeadtime", Trim$(d.LeadTime), 0
         Heap act, id, "iLeadtimeVal", Trim$(Format$(Val(d.LeadTime))), 0  '25Feb10 TH (F0078278) Added for UHB
         Heap act, id, "iLocation", Trim$(d.loccode), 0              '19Oct98 CKJ was "iLocalcode"
         Heap act, id, "iUsagedamping", Format$(d.usagedamping), 0
         Heap act, id, "iSafetyfactor", Format$(d.safetyfactor), 0
         Heap act, id, "iIndexed", Trim$(d.indexed), 0
         Heap act, id, "iIndexedyn", Trim$(YesNo(Val(d.indexed))), 0
         Heap act, id, "iRecalcatperiodend", Trim$(d.recalcatperiodend), 0
         Heap act, id, "iLossesgains", Format$(d.lossesgains), 0
         Heap act, id, "iLossesgains/100", Format$(d.lossesgains / 100, "0.00"), 0
         'Heap act, ID, "iDosesperissueunit", Format$(d.dosesperissueunit), 0
         Heap act, id, "iDoses/Issunit", Format$(d.dosesperissueunit), 0
         Heap act, id, "iMlsperpack", Iff(d.mlsperpack, Format$(d.mlsperpack), ""), 0     '!!**
         Heap act, id, "iOrdercycle", Trim$(d.ordercycle), 0
         Heap act, id, "iCyclelength", Format$(d.cyclelength), 0
         'Heap act, ID, "iLastreconcileprice", d.lastreconcileprice, 0
         Heap act, id, "iReconcileprice", d.lastreconcileprice, 0
         Heap act, id, "iReconcileprice/100", Format$(Val(d.lastreconcileprice) / 100, "0.00"), 0
         Heap act, id, "iOutstanding", Format$(d.outstanding), 0
         Heap act, id, "iUseThisPeriod", Format$(d.usethisperiod), 0
         Heap act, id, "iVATrate", Trim$(d.vatrate), 0
         Heap act, id, "iDosingunits", Trim$(d.DosingUnits), 0
         Heap act, id, "iATCcode", Trim$(d.ATCCode), 0
         Heap act, id, "iUsermessage", Trim$(d.UserMsg), 0
         'Heap act, ID, "iMaxinfusionrate", Format$(d.MaxInfusionRate), 0
         Heap act, id, "iMaxInfRate", Format$(d.MaxInfusionRate), 0
         Heap act, id, "iMinmgPerml", Format$(d.MinmgPerml), 0
         Heap act, id, "iInfusiontime", Format$(d.InfusionTime), 0
         Heap act, id, "iMgPerml", Format$(d.mgPerml), 0
         Heap act, id, "iIVcontainer", Trim$(d.IVcontainer), 0
         'Heap act, ID, "iDisplacementvolume", Format$(d.DisplacementVolume), 0
         Heap act, id, "iDisplVol", Format$(d.DisplacementVolume), 0
         Heap act, id, "iPILnumber", Format$(d.PILnumber), 0
         'Heap act, id, "iDatelastperiodend", d.datelastperiodend, 0
         parsedate Trim$(d.datelastperiodend), strDate, strDateFormat, 0
         Heap act, id, "iDatelastperiodend", strDate, 0
         Heap act, id, "iMindailydose", Format$(d.MinDailyDose), 0
         Heap act, id, "iMaxdailydose", Format$(d.MaxDailyDose), 0
         'Heap act, ID, "iMindosefrequency", Format$(d.MinDoseFrequency), 0
         Heap act, id, "iMinDoseFreq", Format$(d.MinDoseFrequency), 0
         'Heap act, ID, "iMaxdosefrequency", Format$(d.maxdosefrequency), 0
         Heap act, id, "iMaxDoseFreq", Format$(d.MaxDoseFrequency), 0
''         Heap act, id, "iRoute", Trim$(d.route), 0
         Heap act, id, "iChemical", Trim$(d.chemical), 0
         Heap act, id, "iLocalCode", Trim$(d.local), 0                   '19Oct98 CKJ amended
         'Heap act, ID, "iExtralocal", Trim$(d.extralocal), 0            '   "        removed
         'Heap act, ID, "iDosesperadminunit", Format$(d.dosesperadminunit), 0
''         Heap act, id, "iDoses/AdmUnit", Format$(d.DosesPerAdminUnit), 0
''         Heap act, id, "iAdminunit", Trim$(d.adminunit), 0
         Heap act, id, "iDSSform", Trim$(d.DPSform), 0
         'Heap act, ID, "iStoresdescription", Trim$(d.storesdescription), 0
         temp$ = d.storesdescription
         plingparse temp$, "!"
         Heap act, id, "iStoresdesc", Trim$(temp$), 0
         'If trimz$(d.storesdescription) = "" Then     '21May04 TH Added new general description iGendesc - uses stores desc if
               'temp2$ = d.Description                 '  "        available, else resorts to normal description (#71558)
            'Else                                      '  "
               'temp2$ = d.storesdescription           '  "
            'End If    '  XN 4Jun15 98073 New local stores description
                 temp2$ = d.DrugDescription
         plingparse temp2$, "!"                       '  "
         Heap act, id, "iGendesc", Trim$(temp2$), 0   '  "
         Heap act, id, "iGendescXML", XMLEscape(Trim$(temp2$)), 0    '04Mar14 TH Added (eHub)
         Heap act, id, "iStorespack", Trim$(d.storespack), 0
         Heap act, id, "iLocation2", Trim$(d.loccode2), 0      '22Apr02 SF added (enh#1555)
         Heap act, id, "iPipCode", Trim$(d.pipcode), 0 '13May02 ATW Added pipcodes
         Heap act, id, "iMasterPip", Trim$(d.pipcode), 0
         '16Feb05 TH Added (#78675)
         parsedate Trim$(d.lastissued), strDate, strDateFormat, 0
         Heap act, id, "ilastissued", strDate, 0
         parsedate Trim$(d.lastordered), strDate, strDateFormat, 0
         Heap act, id, "ilastordered", strDate, 0
         Heap act, id, "ibatchtracking", Trim$(d.batchtracking), 0
                  ''Heap act, id, "ilaststocktakedate", Trim$(d.laststocktakedate), 0
         parsedate Trim$(d.laststocktakedate), strDate, strDateFormat, 0
         Heap act, id, "ilaststocktakedate", strDate, 0
         Heap act, id, "ilaststocktaketime", Trim$(d.laststocktaketime), 0
                  Heap act, id, "iCreatedUser", Trim$(d.CreatedUser), 0
         Heap act, id, "icreatedterminal", Trim$(d.createdterminal), 0
         parsedate Trim$(d.createddate), strDate, strDateFormat, 0
         Heap act, id, "icreateddate", strDate, 0
         Heap act, id, "icreatedtime", Trim$(d.createdtime), 0
         Heap act, id, "imodifieduser", Trim$(d.modifieduser), 0
         Heap act, id, "imodifiedterminal", Trim$(d.modifiedterminal), 0
         parsedate Trim$(d.modifieddate), strDate, strDateFormat, 0
         Heap act, id, "imodifieddate", strDate, 0
         Heap act, id, "imodifiedtime", Trim$(d.modifiedtime), 0
         '------------
         '12Oct06 TH Added
         Heap act, id, "iSuprefno", Trim$(d.SuppRefno), 0
         Heap act, id, "iSupTradeName", Trim$(d.SupplierTradeName), 0
         '----------------
         '24Oct06 TH Added
         Select Case Val(d.batchtracking)
            Case 2: Heap act, id, "ibatchtrackingTxt", TxtD(dispdata$ & "/winord.ini", "", "Record Batch on Receipt", "BatchTracking1", 0), 0
            Case 3: Heap act, id, "ibatchtrackingTxt", TxtD(dispdata$ & "/winord.ini", "", "Record Batch and Expiry on Receipt", "BatchTracking2", 0), 0
            Case 4: Heap act, id, "ibatchtrackingTxt", TxtD(dispdata$ & "/winord.ini", "", "Record Batch and Expiry on Receipt & Confirm on Issue", "BatchTracking3", 0), 0
            Case Else: Heap act, id, "ibatchtrackingTxt", TxtD(dispdata$ & "/winord.ini", "", "Batch Tracking Off", "BatchTracking4", 0), 0
         End Select
         '----------------
         Heap act, id, "iBatchTrack", Iff(Val(d.batchtracking) > 1, "Y", "N"), 0 '20Mar09 TH UHB Interface Added
         '27Feb09 TH Added (UHB Interface)
         If Val(d.convfact) > 0 Then
            Heap act, id, "iCostUnit", Trim$(Format$(Val(d.cost) / d.convfact)), 0
            Heap act, id, "iCost/100Unit", Format$((Val(d.cost) / d.convfact) / 100, "0.00"), 0
            Heap act, id, "iCostGross", Trim$(Format$(Val(d.cost) * VAT(d.vatrate))), 0
            Heap act, id, "iCostGross/100", Format$((Val(d.cost) * VAT(d.vatrate)) / 100, "0.00"), 0
         Else
            Heap act, id, "iCostUnit", "0", 0
            Heap act, id, "iCost/100Unit", "0", 0
            Heap act, id, "iCostGross", "0", 0
            Heap act, id, "iCostGross/100", "0", 0
         End If
         '07Apr10 AJK Added for F0072782 & F0072542
         Heap act, id, "iDDDValue", Trim$(d.DDDValue), 0
         Heap act, id, "iDDDUnits", Trim$(d.DDDValue), 0
         Heap act, id, "iUserField1", Trim$(d.UserField1), 0
         Heap act, id, "iUserField2", Trim$(d.UserField2), 0
         Heap act, id, "iUserField3", Trim$(d.UserField3), 0
         Heap act, id, "iHIProduct", Trim$(d.HIProduct), 0
         '14Apr10 AJK Added fields for F0072782
         Heap act, id, "iEDILinkCode", Trim$(d.EDILinkCode), 0
                 Heap act, id, "iEDIBarcode", Trim$(d.EDIBarcode), 0             '22Jul16 XN 126634
         Heap act, id, "iPASANPCCode", Trim$(d.PASANPCCode), 0
         Heap act, id, "iPNExclude", Iff(d.PNExclude, "Y", "N"), 0   '27Jan12 CKJ
         Heap act, id, "iPSOLabel", Iff(d.PSOLabel, "Y", "N"), 0     '07Aug12 TH
         Heap act, id, "iEyeLabel", Iff(d.EyeLabel, "Y", "N"), 0     '24Feb13 TH (TFS 39777)
         
         Heap act, id, "iPhysicalDescription", Trim$(d.PhysicalDescription), 0   '16Jul09 TH Ported'25Jan08 CKJ added
         
         Heap act, id, "iDMandDReference", Trim$(d.DMandDReference), 0   '31Mar14 TH Added for interfacing '18Aug14 TH Merged for eHub (TFS 98117)
         Heap act, id, "iLabelDescriptionInPatient", Trim$(d.LabelDescriptionInPatient), 0    ' 30Apr15 XN Added 98073
         Heap act, id, "iLabelDescriptionOutPatient", Trim$(d.LabelDescriptionOutPatient), 0  ' 05May15 XN Added 98073
                 Heap act, id, "iLocalDescription", Trim$(d.LocalDescription), 0  ' 05May15 XN Added 98073
                 Heap act, id, "iDrugDescription", Trim$(d.DrugDescription), 0
                 
         success = True
      End If

End Sub

''Sub FillHeapPrescriberInfo(ByVal HeapID As Integer, gPrescriberDetails As PrescriberStruct, success As Integer)
'''16Nov00 SF added to put prescriber details on the heap
''
''Dim act%, id%
''
''   success = False
''   id = HeapID
''   If id = 0 Then id = gPRNheapID                                'default id global print heap
''   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
''   id = Abs(id)                                                  'ensure ID is positive
''
''   If id > 0 Then
''         Heap act, id, "rxCode", Trim$(gPrescriberDetails.Code), 0
''         Heap act, id, "rxName", Trim$(gPrescriberDetails.name), 0
''         Heap act, id, "rxAddress1", Trim$(gPrescriberDetails.Address1), 0
''         Heap act, id, "rxAddress2", Trim$(gPrescriberDetails.Address2), 0
''         Heap act, id, "rxAddress3", Trim$(gPrescriberDetails.Address3), 0
''         Heap act, id, "rxPostCode", Trim$(gPrescriberDetails.postCode), 0
''         Heap act, id, "rxTelephoneNumber", Trim$(gPrescriberDetails.telephonenumber), 0
''         Heap act, id, "rxSpecialist", Trim$(gPrescriberDetails.specialist), 0
''         Heap act, id, "rxSecondaryCode", Trim$(gPrescriberDetails.secondaryCode), 0
''         Heap act, id, "rxRegistrationNumber", Trim$(gPrescriberDetails.registrationNumber), 0
''         Heap act, id, "rxDateCreated", Format$(gPrescriberDetails.datecreated, "dd/mm/yyyy"), 0
''         Heap act, id, "rxPrescriberType", Trim$(gPrescriberDetails.prescribertype), 0
''         Heap act, id, "rxFreeText", Trim$(gPrescriberDetails.Freetext), 0
''      End If
''
''End Sub

Sub FillHeapSupplierInfo(HeapID As Integer, sup As supplierstruct, success As Integer)
'30Mar00 CFY Written. Code Taken form FillHeapDrugInfo
'17Mar09 TH  Added new elements for UHB Interfaces (F0032689)
'22Apr09 TH  Added sMethodexp UHB (F0051378)
'28Apr09 TH  Added XML parsed heap elements after UHB interface testing (F0052059)
'06May09 TH  Ensure various fields are trimmed BEFORE parsing for XML (F0052059)
'10Oct09 TH  Added XML element for Zetes
'21Oct09 TH (F0066973) Remove foramt on warcode as "10A" was being interpreted and output as a time !!! (10:00:00)
'            Also added XMl escaped element at same time.
'15Jul14 XN  Added new fields National supplier code, DUNS reference, and user field 1 to 4 88506
'            Added support for printing extra supplier data 88506

Dim act%
Dim id%
Dim strDate As String
Dim supAdd(10) As String
Dim intloop As Integer
Dim intPostcode As Integer
Dim strTemp As String  '06May09 TH Added

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
         Heap act, id, "sCode", Trim$(sup.Code), 0
         Heap act, id, "sCodeXML", Trim$(XMLEscape(sup.Code)), 0 '28Apr09 TH Added
         Heap act, id, "sCntAddress", Trim$(sup.contractaddress), 0
         Heap act, id, "sSupAddress", Trim$(sup.supaddress), 0
         Heap act, id, "sInvAddress", Trim$(sup.invaddress), 0
         Heap act, id, "sCntTelNo", Trim$(sup.conttelno), 0
         Heap act, id, "sSupTelNo", Trim$(sup.suptelno), 0
         Heap act, id, "sInvTelNo", Trim$(sup.invtelno), 0
         Heap act, id, "sDiscountDesc", Trim$(sup.discountdesc), 0
         Heap act, id, "sDiscountVal", Trim$(sup.discountval), 0
         Heap act, id, "sMethod", Trim$(sup.Method), 0 '17Mar09 TH Added for UHB Interfaces
         If UCase$(Trim$(sup.Method)) = "E" Then
            Heap act, id, "sEDI", "Y", 0
            Heap act, id, "sMethodExp", "EDI", 0  '22Apr09 TH Added UHB (F0051378)
         Else
            Heap act, id, "sEDI", "N", 0
            Select Case UCase$(Trim$(sup.Method))                             '22Apr09 TH Added UHB (F0051378)
               Case "F": Heap act, id, "sMethodExp", "Fax", 0                 '   "
               Case "I": Heap act, id, "sMethodExp", "Internal", 0            '   "
               Case "D": Heap act, id, "sMethodExp", "Direct", 0              '   "
               Case Else:  Heap act, id, "sMethodExp", "Other", 0             '   "
            End Select                                                        '   "
         End If
         Heap act, id, "sOrdMessage", Trim$(sup.ordmessage), 0
         Heap act, id, "sAvgLeadTime", Trim$(sup.avleadtime), 0
         Heap act, id, "sCntFaxNo", Trim$(sup.contfaxno), 0
         Heap act, id, "sSupFaxNo", Trim$(sup.supfaxno), 0
         Heap act, id, "sInvFaxNo", Trim$(sup.invfaxno), 0
         Heap act, id, "sName", Trim$(sup.name), 0
         Heap act, id, "sNameXML", XMLEscape(Trim$(sup.name)), 0  '10Oct09 TH Added
         Heap act, id, "sPtn", Trim$(sup.ptn), 0
         Heap act, id, "sPsis", Trim$(sup.psis), 0
         Heap act, id, "sfullname", Trim$(sup.fullname), 0
         strTemp = Left$(sup.fullname, Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "32", "FullnameTrim", 0))) '06May09 TH Use this and trim BEFORE parsing for XML (F0052059)
         'Heap act, id, "sfullnameTrim", Left$(sup.fullname, Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "32", "FullnameTrim", 0))), 0
         Heap act, id, "sfullnameTrim", strTemp, 0
         'Heap act, id, "sfullnameTrimXML", Trim$(Left$(XMLEscape(sup.fullname), Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "32", "FullnameTrim", 0)))), 0 '28Apr09 TH
         Heap act, id, "sfullnameTrimXML", XMLEscape(strTemp), 0 '28Apr09 TH
         Heap act, id, "sDiscountBelow", Trim$(sup.discountbelow), 0
         Heap act, id, "sDiscountAbove", Trim$(sup.discountabove), 0
         Heap act, id, "sIcode", Trim$(sup.icode), 0
         Heap act, id, "sCostCentre", Trim$(sup.costcentre), 0
         strTemp = Left$(sup.costcentre, Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "8", "CostCentreTrim", 0))) '06May09 TH Use this and trim BEFORE parsing for XML (F0052059)
         'Heap act, id, "sCostCentreTrim", Left$(sup.costcentre, Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "8", "CostCentreTrim", 0))), 0
         Heap act, id, "sCostCentreTrim", strTemp, 0
         'Heap act, id, "sCostCentreTrimXML", Trim$(Left$(XMLEscape(sup.costcentre), Val(TxtD(dispdata$ & "\genint.ini", "SupplierInterface", "8", "CostCentreTrim", 0)))), 0  '28Apr09 TH
         Heap act, id, "sCostCentreTrimXML", XMLEscape(strTemp), 0  '28Apr09 TH
         Heap act, id, "sPrintDelNote", Trim$(sup.PrintDeliveryNote), 0
         Heap act, id, "sPrintPickTick", Trim$(sup.PrintPickTicket), 0
         Heap act, id, "sSupType", Trim$(sup.suppliertype), 0
         Heap act, id, "sOrdOutput", Trim$(sup.OrderOutput), 0
         Heap act, id, "sReceiveGoods", Trim$(sup.ReceiveGoods), 0
         Heap act, id, "sTopUp", Trim$(sup.TopupInterval), 0
         Heap act, id, "sATC", Trim$(sup.ATCSupplied), 0
         'Heap act, id, "sTopUpDate", Format$(sup.topupdate, "dd/mmm/yyyy"), 0
         parsedate sup.topupdate, strDate, "dd/mmm/ccyy", 0
         Heap act, id, "sTopUpDate", strDate, 0
         Heap act, id, "sInUse", Format$(sup.inuse), 0
         'Heap act, id, "swardcode", Format$(sup.wardcode), 0
         Heap act, id, "swardcode", Trim$(sup.wardcode), 0                    '21Oct09 TH (F0066973)
         Heap act, id, "swardcodeXML", XMLEscape(Trim$(sup.wardcode)), 0      '21Oct09 TH Addd for good measure (Zetes)
         Heap act, id, "sMinOrderValue", Format$(sup.MinimumOrderValue), 0  '22May05 TH Added
         'For UHB - parse the address onto 4 lines
         For intloop = 1 To 3
            Heap act, id, "sSuppAdd" & Format$(intloop), "", 0
            Heap act, id, "sSuppAdd" & Format$(intloop) & "XML", "", 0  '28Apr09 TH Added
         Next
         Heap act, id, "sSuppPostcode", "", 0
         deflines sup.supaddress, supAdd(), ",", 1, 0
         'Find the last element
         For intloop = 1 To 10
            If Trim$(supAdd(intloop)) = "" And intloop > 1 Then
               intPostcode = intloop - 1
               Exit For
            End If
         Next
         If intPostcode > 0 Then
            For intloop = 1 To (intPostcode - 1)
               Heap act, id, "sSuppAdd" & Format$(intloop), Trim$(supAdd(intloop)), 0
               Heap act, id, "sSuppAdd" & Format$(intloop) & "XML", Trim$(XMLEscape(Trim$(supAdd(intloop)))), 0 '28Apr09 TH Added
            Next
            Heap act, id, "sPostcode", Trim$(supAdd(intPostcode)), 0
         Else
            For intloop = 1 To 3
               Heap act, id, "sSuppAdd" & Format$(intloop), Trim$(supAdd(intloop)), 0
               Heap act, id, "sSuppAdd" & Format$(intloop) & "XML", Trim$(XMLEscape(Trim$(supAdd(intloop)))), 0 '28Apr09 TH Added
            Next
         End If
         
        '15Jul14 XN  Added new fields 88506
        Heap act, id, "sNationalSupplierCode", Trim$(sup.NationalSupplierCode), 0
        Heap act, id, "sGlobalLocationNumber", Trim$(sup.GlobalLocationNumber), 0
        Heap act, id, "sDUNSReference", Trim$(sup.GlobalLocationNumber), 0
        If sup.suppliertype = "E" Or sup.suppliertype = "S" Then
            Heap act, id, "sUserField1", Trim$(sup.UserField1), 0
            Heap act, id, "sUserField2", Trim$(sup.UserField2), 0
            Heap act, id, "sUserField3", Trim$(sup.UserField3), 0   ' Will produce the same as ContractName1, ContractName2
            Heap act, id, "sUserField4", Trim$(sup.UserField4), 0
        ElseIf sup.suppliertype = "W" Then
            Heap act, id, "sUserField1", Trim$(sup.UserField1), 0
            Heap act, id, "sUserField2", Trim$(sup.UserField2), 0
            Heap act, id, "sUserField3", Trim$(sup.UserField3), 0   ' Will produce the same as ContractName1, ContractName2
            Heap act, id, "sUserField4", Trim$(sup.UserField4), 0
        End If
        
        On Error Resume Next
        
        '15Jul14 XN  Added support for printing extra supplier data 88506
        If sup.suppliertype = "E" Or sup.suppliertype = "S" Or sup.suppliertype = "W" Then
            Dim RsExtraSupplierData As ADODB.Recordset
            Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
            If Not (RsExtraSupplierData Is Nothing) Then
                If Not RsExtraSupplierData.EOF Then
                    Heap act, id, "sCurrentContractData", RtrimGetField(RsExtraSupplierData!CurrentContractData), 0
                    Heap act, id, "sNewContractData", RtrimGetField(RsExtraSupplierData!NewContractData), 0
                    
                    parsedate RtrimGetField(RsExtraSupplierData!DateofChange), strDate, "dd/mmm/ccyy", 0
                    Heap act, id, "sDateofChange", strDate, 0
                    
                    Heap act, id, "sNotes", RtrimGetField(RsExtraSupplierData!notes), 0
                End If
            End If
        End If
         success = True
      End If

End Sub

Sub findrdrug(drug$, Stores%, d As DrugParameters, foundPtr&, found%, newdrug%, ByVal blnMaster As Boolean, ByVal UsePNExclude As Boolean, Optional ByVal AllowBNF As Boolean = True, Optional ByVal forceBNF As Boolean = False)
'------------------------------------------------------------------------------
'                   Find a drug from its dispensary code
'
' 13 Jun ASC Not found messages inhibited if newdrug =2 for use in labutils
'            checking of new drugs
'28Oct91 CKJ Draws window on screen (lines on display unchanged) so that the
'            bottom line can be used to display a prompt line. Pass the prompt
'            as part of drug$ separated by chr$(127) ie <drug><#127><prompt>
'16Nov93 CKJ Mod to badcheck
'25Oct94 CKJ Rewritten: Select drug now via form, drug file fully indexed,
'            PRODINFO.COP removed. Now requires \Q4LIB\FINDDRUG.FRM
'27Oct94 CKJ passes stores% to UpdateInfoLine
'20Jan95 CKJ Highlight 1st drug in list. BNF chapter & section from std files
'14Mar95 CKJ Allow EAN 8
'11Apr95 ASC Form not unloaded to save memory ! list boxes emptied
'21Apr95 CKJ Added wildcard search - type '*text' where text is found in any
'            text field in the drug. Search is brute force, so slow. Esc is
'            allowed at any time. Max 700 items per search, but can continue
'            searching from any given point, eg '*tab' may show 700 items, the
'            last of which is drug 1654; continue search with '*tab#1654'
'24May95 CKJ Turns timer off expicitly, since _lostfocus is unreliable
'20Jun95 CKJ Uses editform for user message
'11Sep95 CKJ Avoids INKEY when form showing
'17Mar95 KR  Get drug pointer using listindex.itemdata instead of putting at end of data entry
'            This prevents the item from being shown in the listbox
' 4Sep96 CKJ Modified call to Editors with UserMsg
''07Nov KR Changed listbox so that it now uses standard font & tab settings.
'12Jul97 CKJ NSV code format now read from stkmaint.ini [data]'9' sixth data item
'            uses PatternMatch in corelib
'15Jul97 CKJ Added check for local code
'            Allow search by BNF chaper as well as BNF section
'06Aug98 CKJ Local code search can be forced by using a prefix (just like tradename)
'            The default prefix is '=' but it can be set in stkmaint.ini [Data]
'            LocalCodePrefix=":" where a single sensible character is defined.
'            Sensible means avoid A-Z,0-9,? etc
'            Automatic use of the local code index now inhibited if the local code mask is ""
'30Sep98 CKJ Tidied form, removed 3D panel & removed unnecessary spaces
'15Oct98 TH  Added check on finddrug.tag to stop unwarranted loading of drug
'08Feb99 CFY Replaced fixed pattern for lookup codes to now use masks supplied in stkmaint.ini
'31Mar99 CFY (1) Fixed problem which would prevent wildcard searches from firing.
'            (2) Switched the sequence in which local code and ASC lookup code are searched.
'                ASC Lookup code now takes precedence above the local code.
'28Jul99 AE  Dim'd variables.  Added call to StoresValue to allow filldruglist access to the value of
'            this procs' Stores% parameter.
'            IsASCcode now passed via CmdLetter(0).Tag on findDrug.frm.  This was previously undeclared
'            and hence always zero.  Cannot be passed as a simple parameter to filldruglist, as that
'            procedure is also called from finddrug.frm
'14Mar00 TH  Reinstated wild card search on ini setting
'22May00 TH  Use wildfound flag in getting ini setting for wildcard search
'            Previously found was being set and flagging back that there was a drug even if no selection
'            had been returned. Also set emptymsg$ to deal with failed searches.
'29Mar01 ASC/CKJ Added code to take a copy of d structure before editing takes place. If edits are cancelled (event 51305)
'           "    the original drug structure is replaced by the copy.
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting. Note that locking the
'            drug is illegal and is refused, and that Putdrug is disabled. GetNOD is also modified.
'            The 'friendly list' of drugs is now derived from the ward stock list for that ward, if one exists.
'            If no wsl has been created, or it contains no items then use the full dispensary list anyway.
'            NOTE: for convenience the list is cached in a string variable which can hold max 2000 items per WSL.
'23oct08 CKJ reinstated description search with multiple words eg "sodium chloride" (F0021923)
'06May10 AJK F0073627 Added off route checking code to log and display off route matches
'23May11 TH  Off route only on VMPAMPAMPP search (ie Dispensary selection from rx). Previously none NSV Searches  (ie barcode or description)
'            that returned one row could still display selection screen if off route filtering was turned on. (F0118215)
'31Jan12 CKJ Added param blnUsePNExclude for d.PNExclude, which is normally False except for PN issuing
'16Aug13 CKJ Removed: Use of BNF lookup deprecated (TFS 42770)
'17Oct14 XN  findrdrug: 88560 Control if allowed to show BNF in drug enquiry

'mods needed
'-----------
'would like to cache last n drugs found - if feasible
'need to trap list box contents approaching 64K         - done
'
'IN: drug$    ""|BNF        BNF        'Removed: "" does nothing & BNF is treated as normal text (TFS 42770)
'             AA[AANNNN]    ASC code
'             AAANNNA       NSV code
'             xxxxxxx       Local code (stkmaint.ini [data]9:,,,,,xxxxxxx)
'             =x[xxxxxx]    Local code, irrespective of mask shown above (prefix is configurable)
'             ?A[AAAA...]   Trade name
'             AAAAA[A|N...] Drug name
'             [A|N][A|N]... Drug name
'           NNNNNNNN[NNNNN] Barcode     (8 or 13 digits only)
'    stores%              0 in use drugs, no stores items
'                        -1 in use including stores items
'                         1 all items
'    d AS drugparameters  - contents ignored
'    foundptr%            - value ignored
'    found%               - value ignored
'    newdrug%             0 normal use
'                         2 don't check or display formulary status,
'                           and don't warn if ASCcode is not found
'    UsePNExclude       T/F normally False except for PN issuing
'
'OUT:drug$                  modified, ignore value
'    stores%                unchanged
'    d AS drugparameters    filled if found else cleared
'    foundptr%              ptr to PK in WProduct, indeterminate if not found
'    found%             T/F drug found, false if escaped. See **
'    newdrug%           T/F only T if ASCcode entered & drug not found
'
' ** Previous version returned '2' if ASCcode entered, and >1 match found.
'-----------------------------------------------------------------------------
Dim nf$, formcheck%, desc$, ans$
Dim Index$, exact%
Dim expansion$, isASCcode%
Dim dcop As DrugParameters
Dim lngDrugPtr As Long
Dim prompt As String
Dim ch127 As Integer
Dim iLoop As Integer
Dim Unrestricted As Boolean
Dim rsOffRoute As ADODB.Recordset '06May10 AJK F0073627 Added
Dim lngOffRouteCount As Long '06May10 AJK F0073627 Added

   ReDim Tabs(6) As Integer, lines(6) As String

   dcop = d

   nf$ = " not found"
   procname$ = "findrdrug"
   If newdrug = 2 Then formcheck = False Else formcheck = True
   m_UsePNExclude = UsePNExclude '31Jan12 CKJ copy param to module level variable for FillDrugList

   'If drug$ = "" Then drug$ = "BNF"      '16Aug13 CKJ Removed: Use of BNF lookup deprecated(TFS 42770)
   
   'drug$ = UCase$(Trim$(drug$))          '23oct08 CKJ preserve case until prompt has been extracted
   drug$ = Trim$(drug$)                   '   "
   Load Finddrug
   
   Finddrug.AllowBNF = AllowBNF           '17Oct14 XN  88560 Control if allowed to show BNF in drug enquiry
   Finddrug.forceBNF = AllowBNF And forceBNF

   prompt$ = " Description"
   ch127 = InStr(drug$, Chr$(127))
   If ch127 Then
      prompt$ = Trim$(Mid$(drug$, ch127 + 1))
      drug$ = Left$(drug$, ch127 - 1)
   End If
   Finddrug.txtDrugsHdr.Tag = prompt$
   drug$ = UCase$(drug$)                  '23oct08 CKJ preserve case until prompt has been extracted

   If blnMaster Then Finddrug.CmdOk.Tag = "MASTER" '05Dec06 TH Added

   Index$ = ""
   exact = False
   isASCcode = False

   found = False
   foundPtr = 0
   
   If Len(drug$) > 0 Then
      Select Case Left$(drug$, 1)
         Case "?":  Finddrug.OptTradeOrApproved(1).Value = True
         Case "*":  Finddrug.OptTradeOrApproved(3).Value = True
         Case Else: Finddrug.OptTradeOrApproved(0).Value = True
         End Select
   End If

   StoresValue 1, Stores                                    '28Jul99 AE Save the value of Stores for use in FillDrugList
   
'16Aug13 CKJ Removed: Use of BNF lookup deprecated(TFS 42770)
'   If UCase$(Left$(drug$, 3)) = "BNF" Then                          'BNF codes   23oct08 CKJ added ucase
'      If Len(drug$) > 3 Then
'         FillDrugList Mid$(drug$, 4), "bnf", blnMaster
'      End If
'      If Finddrug.lstDrugs.ListCount = 0 Then
'         SelectBNFSection
'      End If
'   Else
      If Len(drug$) > 0 Then
''         If (TrueFalse(txtd(dispdata$ & "\patmed.ini", "", "", "Wildcards", 0)) = True) And (UCase$(Left$(drug$, 1)) = "*") Then
''            index$ = "*"
''         End If
''         replace drug$, "*", "", 0
         replace drug$, "&", "", 0
         Finddrug.TxtSelect = drug$
         ''if locked to prescription then
'         OCXheap
         Index$ = ""                   '"VMPAMPAMPP"
         FillDrugList drug$, Index$, blnMaster
         '06May10 AJK F0073627 Added master switch check, ensure it's not an nsvcode search before recording off route count
         'If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "EnableOffRouteDispensing", 0)) And Index$ <> "nsvcode" Then
         If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "EnableOffRouteDispensing", 0)) And Index$ = "VMPAMPAMPP" Then '23May11 TH Off route only on VMPAMPAMPP search (ie Dispensary selection from rx)
            Set rsOffRoute = ProductLookup(Index$, drug$, False, True)
            lngOffRouteCount = rsOffRoute.RecordCount
         End If
         'emptymsg$ = "No matches for '" & Trim$(drug$) & "'"        '01dec05 CKJ message is set in FillDrugList
      End If
'   End If
     
   '06May10 AJK F0073627 Added OffRouteCheck
   'If Finddrug.lstDrugs.ListCount > 0 Or Left$(drug$, 3) = "BNF" Or lngOffRouteCount > 0 Then  'did we find any?
   If Finddrug.lstDrugs.ListCount > 0 Or lngOffRouteCount > 0 Or forceBNF Then  'did we find any?   '16Aug13 CKJ Removed BNF lookup as now deprecated (TFS 42770)
      If Finddrug.lstDrugs.ListCount <> 1 Or lngOffRouteCount > 0 Or forceBNF Then  '06May10 AJK F0073627 Added OffRouteCheck
      'If Finddrug.lstDrugs.ListCount <> 1 Or lngOffRouteCount > 1 Then  '20May11 TH  For none NSV searches if only one item returned (F0118215)'23May11 TH Removed and made mod above instead
         '09May05 CKJ Hide other options if list is locked to a product family
         Unrestricted = (Index$ <> "VMPAMPAMPP")
         Finddrug.OptTradeOrApproved(0).Value = True
         For iLoop = 0 To 3
            Finddrug.OptTradeOrApproved(iLoop).Enabled = Unrestricted
         Next
         
         Finddrug.Timer1.Enabled = True                           '25Jul05 CKJ added
         Finddrug.cmdAllRoutes.Enabled = True
         If lngOffRouteCount = 0 Then  '06May10 AJK F0073627 Added
            Finddrug.cmdAllRoutes.Enabled = False
         ElseIf Finddrug.lstDrugs.ListCount = 0 Then
            popmessagecr "#Warning", TxtD(dispdata$ & "\PATMED.INI", "", "No products for this route are available. Displaying off route matches only.", "OnlyOffRouteProductsAvailableWarningText", 0)
            Finddrug.AddOffRoute
         End If
         Finddrug.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form                                          'show form
         Finddrug.Timer1.Enabled = False
         'If finddrug.lstDrugs.ListIndex = -1 Then    'none chosen, Esc pressed
      End If
      
      If Finddrug.lstDrugs.ListIndex = -1 Or Finddrug.Tag = "Formulary" Then
         k.escd = True
         d = dcop
      ElseIf blnMaster Then
         'We have choosen a master drug - we need to get this from the master subset
         foundPtr = Val(Finddrug.lstDrugs.ItemData(Finddrug.lstDrugs.ListIndex))
         found = GetDrugMaster(foundPtr, d)
         formcheck = False
      Else                                                          'chosen one
         '06May10 AJK F0073627 Record the fact an off route selection was made on the heap
         If Left(Finddrug.lstDrugs.text, 1) = TxtD(dispdata$ & "\PATMED.INI", "", "~", "OffRouteProductDisplayPrefix", 0) Then
            Heap 10, gPRNheapID, "sOffRouteProductSelected", "Y", 0
         End If
         foundPtr = Val(Finddrug.lstDrugs.ItemData(Finddrug.lstDrugs.ListIndex))
         getdrug d, foundPtr, lngDrugPtr, False     '<== No Lock
         found = (lngDrugPtr <> 0)   '(found <> False)              'reduce to boolean
      End If
   End If

   Finddrug.lstDrugs.Clear
   Finddrug.lstBNFchap.Clear
   Finddrug.lstBNFsect.Clear
   Finddrug.lstBNFsectMaster.Clear

   isASCcode = Val(Finddrug.CmdLetter(0).Tag)       '28Jul99 AE IsASCcode is set in FillDrugList and passed as the tag.

   newdrug = False
   If Not k.escd Then
      If found Then
         If formcheck Then GoSub formstatus    'warns is non-formulary etc.
      Else
         BlankWProduct d                           'this is needed
         If formcheck Then
            popmessagecr "!Find product", emptymsg$
         ElseIf isASCcode Then
            newdrug = True
            d.Code = UCase$(drug$)
         End If
      End If
   End If

   Finddrug.CmdOk.Tag = "" '22Feb07 TH Added to clear the tag

Exit Sub

formstatus:
   desc$ = d.LabelDescription
   plingparse desc$, "!"
   desc$ = Trim$(desc$)

   Select Case d.formulary
      Case "N"
         SOUND 50, 5
         popmessagecr "#Warning", desc$ & " Non-formulary"
      Case "R"
         SOUND 50, 10
         popmessagecr "#Warning", desc$ & " Restricted use"
      Case "C"
         SOUND 50, 10
         popmessagecr "#Warning", desc$ & " Consultant signature only"
      End Select
   
   If trimz$(d.UserMsg) <> "" Then
         'SeqScan d.UserMsg, expansion$, dispdata$ & "\usermsg.dat"
         SeqScan d.UserMsg, expansion$, "usermsg" '21Sep05 TH Replaced above
         If Trim$(expansion$) <> "" Then
               If d.formulary = "S" Then '25Jan97 ASC
                     ans$ = "N"
                     k.Max = 1
                     k.min = 1
                     k.validchars = "YN"
                     InputWin "Highly Specialised Drug Indication", expansion$ & crlf & crlf & "Does this patient meet the above criteria ?", ans$, k
                     If UCase$(ans$) = "Y" And Not k.escd Then
                           '10Mar97 CKJ Removed until implemented correctly
               '!!**       writelog dispdata$ & "\HSDRUG.LOG", site%, userid$, pid.cons & pid.recno & "Conforms"
                        Else
                           ans$ = "N"
                           k.Max = 1
                           k.min = 1
                           k.validchars = "YN"
                           InputWin "Funding may not be available for this prescription", "Would you like to proceed", ans$, k
                           If ans$ = "Y" Then
                                 '10Mar97 CKJ Removed until implemented correctly
               '!!**             writelog dispdata$ & "\HSDRUG.LOG", site%, userid$, pid.cons & pid.recno & "Non-Conformer"
                              Else
                                 foundPtr& = 0
                                 found% = 0
                                 k.escd = True
                              End If
                        End If
                  Else
''                     Editor.Txt1 = expansion$
''                     Editor.LblCode = d.UserMsg
''                     Editor.Caption = "Please Note"
''                     Editor.cmdExit.default = True           'view only
''                     Editor.Tag = ""
''                     CentreForm Editor
''                     Editor.Show 1
''                     Unload Editor
                     ShowUserMessage d.UserMsg
                  End If
            Else
               popmessagecr "!Please Note", "Message code '" & d.UserMsg & "' is not defined"
            End If
      End If
Return

End Sub

Function GetCustOrdNo() As String
'18Apr00 CFY Written
'            Returns the currently stored customer order number

   GetCustOrdNo = Trim$(msCustOrdNo)
   
End Function

Sub getdrug(d As DrugParameters, ByVal productstockID As Long, foundPtr As Long, ByVal lockdrug As Boolean)
'-----------------------------------------------------------------------------
' if finddnum >0 then assumes you want drug in position found else the format
' has been tested and a drug with the field already filled will be returned
' with 'd' filled completely
' NB: foundptr is not boolean- it contains the PK of the found drug.
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting. Note that locking the
'            drug is illegal and is refused, and that Putdrug is disabled. GetNOD is also modified.
'09May05 CKJ Removed FormularyExt as prescribing would be done in Web
'            Locking not yet implemented in SQL
'            Note that D is blanked if drug not found
'            Site to be handled in SQL via sessionID
'-----------------------------------------------------------------------------
''Static nod&, lastdispdata$

''Dim AltDispdata As String

''   If siteinfo$("FormularyEXT", "") = "" Then                                '09Apr01 CKJ Formulary site not defined
''         AltDispdata$ = dispdata$                                            '            use standard one
''      Else                                                                   '            Formulary site is defined
''         If lockdrug Then                                                    '            Locking drugs is not permitted
''               popmessagecr ".", "Prescribing account cannot lock the Product File, request ignored"
''               lockdrug = False
''            End If
''         AltDispdata$ = siteinfo$("FormularyDRV", "") & "\dispdata." & siteinfo$("FormularyEXT", Right$(dispdata$, 3))
''      End If

''   If lastdispdata$ <> AltDispdata$ Or getd+-*chan = 0 Then                     '09Apr01 CKJ use Formulary files
''         If getdchan Then Close #getdchan
''         openrandomfile AltDispdata$ & "\prodinfo.v8", Len(d), getdchan      '09Apr01 CKJ use Formulary files
''         lastdispdata$ = AltDispdata$
''         getnod nod& 'ASC 31Mar93
''      End If
Dim blnOK As Boolean
Dim intCount As Integer
Dim rsLock As ADODB.Recordset
Dim strMsg As String
Dim strAns As String
Dim intloop As Integer
Dim blnOCX As Boolean   '31Jul06 TH Added to identify if we are from OCX. If so then we dont give the user any option
                        '           but to wait if the record is locked
                        
                        

   
   foundPtr& = 0                    'NB: *NOT* Boolean!
   d.ProductID = 0                  '09May05 added
   
   If productstockID > 0 Then
      GetProductNL productstockID, d
   ElseIf RTrim$(d.SisCode) <> "" Then
      GetProductNLbyNSV UCase$(RTrim$(d.SisCode)), d
   ElseIf RTrim$(d.barcode) <> "" Then
      GetProductNLbyBarcode RTrim$(d.barcode), d
   Else
      '!!** cancel locking hint?
      Exit Sub              'no barcode or siscode specified   <== WAY OUT
   End If
   
   foundPtr = d.productstockID
   If foundPtr = 0 Then
         'd.Description = "*** Product code " & d.SisCode & " not found ***"
                 d.DrugDescription = "*** Product code " & d.SisCode & " not found ***"
                 d.LabelDescription = "*** Product code " & d.SisCode & " not found ***"
   Else
      If lockdrug Then 'Stop            '!!** Need locking hint here
      'OPEN TRANSACTION
      
      blnOK = False
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
         If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then
            gTransportConnectionExecute "Begin Transaction"     '10Aug12 CKJ
         End If
         If Trim$(UCase(App.FileDescription)) = "DISPENSING COMPONENT" Then
            blnOCX = True
         Else
            blnOCX = False
         End If
         Do While Not blnOK
            intCount = 0
            Set rsLock = TableRowLock("ProductStock", d.productstockID, g_SessionID)
            If rsLock.EOF Or rsLock.RecordCount > 1 Then
               Do While gTransportIsInTransaction(g_SessionID)  '10Aug12 CKJ
                  'Here are going to rollback ay outstanding transactions prior to msg display
                  'We keep a count so we can reinstitute them
                  If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"     '10Aug12 CKJ
                  intCount = intCount + 1
               Loop
               If blnOCX Then
                  strAns = "Y"
                  strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & "Reason Unknown"
                  popmessagecr "EMIS Health", strMsg
               Else
                  strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & "Reason Unknown" & _
                           crlf & crlf & "OK to Retry ? (No Will exit Application)"
                  strAns = "Y"
                  popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
               End If
               If strAns = "N" Then
                  'Exit App
                  BlankWProduct d
                  foundPtr = 0
                  productstockID = 0
                  GoTo CloseApplication
               Else
                  blnOK = False
               End If
            Else
               If GetField(rsLock!sessionID) = g_SessionID Then
                  blnOK = True 'There is a lock - it is ours !
               Else
               'Geuine lock from another identifiable source
                  Do While gTransportIsInTransaction(g_SessionID)       '10Aug12 CKJ
                     'Here are going to rollback ay outstanding transactions prior to msg display
                     'We keep a count so we can reinstitute them
                     If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"  '10Aug12 CKJ
                     intCount = intCount + 1
                  Loop
                  If blnOCX Then
                     strAns = "Y"
                     strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & _
                              "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal)
                     popmessagecr "EMIS Health", strMsg
                  Else
                     strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & _
                              "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
                              crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
                     strAns = "Y"
                     popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                  End If
                  If strAns = "N" Then
                     'Exit App
                     BlankWProduct d
                     foundPtr = 0
                     productstockID = 0
                     GoTo CloseApplication
                  Else
                     blnOK = False
                  End If
               
               End If
            
            End If
            
            If Not blnOK Then
               'Restore any Transactions from before rollbacks for any modal display
               For intloop = 1 To intCount
                  gTransportConnectionExecute "Begin Transaction"       '10Aug12 CKJ
               Next
               
            End If
         Loop
      
      Else
         Do While Not blnOK
            gTransportConnectionExecute "Begin Transaction"     '10Aug12 CKJ
            blnOK = gTransport.GetRowLock(g_SessionID, "ProductStock", d.productstockID) '21Oct04 TH Testage
            If Not blnOK Then
               gTransportConnectionExecute "RollBack Transaction"                 '06Jan06 TH Moved from below msgbox call      '10Aug12 CKJ
               popmessagecr "", "Waiting to lock product record. Press OK to retry" '           Converted from msgbox
            End If
         Loop
      End If
      GetProductNL d.productstockID, d '09Nov05 TH get the definitive read here as it will be now safely behind
                                       '           the lock. Extra read, but as the original read may be without
                                       '           the key this seems for now the best way. Open for review
      End If
      '----------------
   End If
Exit Sub

CloseApplication:
On Error Resume Next                  'SQL If there has been an error then we should try and roll back to unlock any record.
   Do While gTransportIsInTransaction(g_SessionID)      '10Aug12 CKJ
      'Here are going to rollback any outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction" '10Aug12 CKJ
   Loop
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   'Now we have cleaned up the database we are ready to clean up and close
   'We will call a closedown routine that can be different for each app type using this library
   PutRecordFailure "-1", "Failed to Lock ProductStock Record"
   On Error GoTo 0

End Sub

Sub getdrugsup(d As DrugParameters, FindDNum&, foundPtr&, lockdrug%, supcode$)
'30Jun99 CFY written
'Extended version of getdrug to load a suppliers profile into the drug structure.
'The routine is called identically to getdrug but with the addition of the extra supplier code parameter.
'If the requested supplier profile record is found then the drug structure is filled with the relevent information
'for that supplier.
'If no record is found then the default primary supplier information is used.

'28Jul99 AE corrected Findnum to findDnum
'11Apr00 TH Added NoMessages% parameter
'29May01 TH Remove SupplierReference Number from Heap as there should be no default value

Dim success%, FoundProfile%
Dim SupProfile As TSupProfile
Dim tmpCode$
Dim strParams As String
Dim rsWSupplierProfile As ADODB.Recordset
   
   'getdrug d, FindNum%, found%, lockdrug%                                              'Load the drug
   getdrug d, FindDNum, foundPtr&, lockdrug                                                '28Jul99 AE changed Findnum to FindDum
   AlternativeSupplier$ = ""
   
''   'If Trim$(d.supcode) <> Trim$(supcode$) And found% > 0 Then
''   If foundPtr& > 0 Then
''         DrugToSupProfile d, PrimarySupProfile
''         Heap 12, gPRNheapID, "sRefno", "", 0  '29May01 TH Remove sRefno from Heap
''         ''SQL GetSupProfile d.SisCode, supcode$, SupProfile, success%, FoundProfile%        'Load requested supplier profile
''         If success% And FoundProfile% Then                                            'if found then fill the d structure
''               tmpCode$ = d.supcode                                                    'with the new information.
''               SupProfileToDrug d, SupProfile
''               d.supcode = tmpCode$                                                    'Keep the primary supplier code
''               AlternativeSupplier$ = supcode$
''            End If
''      End If

'SQL TRy and match the above when in doubt so as not to mess the architecture up (least touch ?)
'NB We should not need to lock the WSupplierProfile Record here because the drug acts as a lock already (AS PMRS to labels !)


If Trim$(d.supcode) <> Trim$(supcode$) And foundPtr& > 0 Then
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, supcode$)
               
   Set rsWSupplierProfile = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierProfilebyNSVCodeandSupCode", strParams)
   If rsWSupplierProfile.RecordCount > 0 Then
      'There is Unique constraint so we will use whatever comes back
      SupProfileToDrugSQL d, rsWSupplierProfile
   Else
      'We have no Supplier profile here so we are effectively using the default.
      'We must not use effective fields here so they are blanked.
      '22Feb08 TH (F0015066) OOOPS ! If we are going to do this on a lock than we need to retain these values after for the put
      '           otherwise we will copy the blank stuff back to the default profile (oh dear)
      If lockdrug Then
         m_DefaultSupplierProfileNSV = d.SisCode
         m_strContNo = d.contno
         m_strContprice = d.contprice
         m_strSuppRefno = d.SuppRefno
      End If
      d.contno = ""
      d.contprice = ""
      d.SuppRefno = ""
          d.EDIBarcode = ""
      'Other Fields - pricelast paid, reorder outer size, leadtime,tradename, vatrate etc. we take from the main supplier
      'because these are better than any guess or system default
   End If
   rsWSupplierProfile.Close
   Set rsWSupplierProfile = Nothing
End If

   
End Sub

Sub getexpirydate(expirydat As String)
'01Oct02 TH Written
   expirydat = m_strSubPatExpiryTime
End Sub

Function GetFindDrugLowPassLevel() As Integer
'16May04 TH Added (UMMC pricehide)
    GetFindDrugLowPassLevel = m_blnLowPassLevel
End Function

Sub GetInsCode(ByVal inscode As String, Instruction As String)
'10Jul94 ASC Get instruction from code
'13Feb95 CKJ Tidied
'20Mar95 CKJ was 5 char max width, now 6
'16Apr96 KR  procedure was static
'14Nov97 ASC added instruct.dss as distributed instructions and made static again
'19Jan98 EAC moved from PATSUBS.BAS
'   "     "  no longer a static sub
'   "     "  moved instruction$() and numofins% to module level
'22Apr14 XN  Updated to use local code first, then dss language specific then dss english 89088

Dim rs As ADODB.Recordset
Dim strParam As String
Dim Context As String
Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetInsCode"
   
    GetWLookupCode "instruct.v4", inscode, Instruction, False '29Jun17 TH New generic cached call (TFS 191443)
    Exit Sub
    
    On Error GoTo ErrorHandler

   'Instruction = ""
   'For iLoop = 1 To 2                                            22Apr14 XN Updated to use local code first, then dss language specific then dss english 89088
   '  Context = ASCContextName("instruct.v4", (iLoop = 1), 0)
   'For iLoop = 1 To 3
      'Context = ASCContextName("instruct.v4", (iLoop > 1), Iff(iLoop > 2, 44, 0))
      'strParam = gTransport.CreateInputParameterXML("siteid", trnDataTypeint, 4, gDispSite) & _
                 'gTransport.CreateInputParameterXML("context", trnDataTypeVarChar, 255, Context) & _
                 'gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 10, inscode) & _
                 'gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, Null)
      'Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParam)
      'If Not rs Is Nothing Then
         'If rs.State = adStateOpen Then
            'If rs.RecordCount <> 0 Then
               'Instruction = RtrimGetField(rs!Value)
               'Exit For
            'End If
         'End If
      'End If
   'Next

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup


'Static lastpath$
'Dim numoflocalins%
'Dim inschan%, X%, xs$, Y$, i$
'
'   inscod$ = RTrim$(UCase$(Left$(inscod$ + Space$(6), 6)))   '20Mar95 was 5
'   INSTRUCT$ = ""
'
'   If lastpath$ <> ASCFileName("INSTRUCT.V4", False, "") Then numofins = 0
'
'   If numofins = 0 Then
'         If fileexists(ASCContextName("INSTRUCT.V4", True, "")) Then
'               inschan = FreeFile
'               Open ASCFileName("INSTRUCT.V4", True, "") For Input Shared As inschan
'               Input #inschan, numofins
'               ReDim Instruction$(numofins)
'               For X = 1 To numofins
'                  Input #inschan, xs$
'                  Input #inschan, Y$
'                  Instruction$(X) = Left$(xs$ + Space$(6), 6) + Y$
'               Next
'               Close #inschan
'            End If
'
'         If fileexists(ASCContextName("INSTRUCT.V4", False, "")) Then
'               inschan = FreeFile
'               Open ASCFileName("INSTRUCT.V4", False, "") For Input Shared As inschan
'               Input #inschan, numoflocalins
'               ReDim Preserve Instruction$(numofins + numoflocalins)
'               For X = numofins + 1 To numofins + numoflocalins
'                  Input #inschan, xs$
'                  Input #inschan, Y$
'                  Instruction$(X) = Left$(xs$ + Space$(6), 6) + Y$
'               Next
'               numofins = numofins + numoflocalins
'               Close #inschan
'            Else
'               popmessagecr "Must be corrected", "Instruction file " & ASCFileName("instruct.v4", False, "") & " not present"
'''               Close
'''**               End!
'            End If
'         lastpath$ = ASCContextName("instruct.v4", False, "")
'      End If
'
'      For X = 1 To numofins
'         i$ = RTrim$(Left$(Instruction$(X), 6))
'         If inscod$ = i$ And i$ <> "" Then
'               INSTRUCT$ = Mid$(Instruction$(X), 7)
'               Exit For
'            End If
'      Next

End Sub

Function GetIssueConfig() As Integer
'14Apr04 CKJ Written
'            Returns 0/1/2   F7 Bag Label handling is disabled/enabled(deferred)/enabled(immediate)

   GetIssueConfig = m_intBagLabels                               'return F7 Bag label handling

End Function

Function GetPickNo() As String
'13Mar04  TH Written
'           Returns the currently stored PickNo number

   GetPickNo = Trim$(m_strPickNo)

End Function

''Sub GetPrescriberDetails(fromPMR%, RxCode$, success%)
'''16Nov00 SF added for prescriber enhancement
''' In:
'''   fromPMR% = True  - called from within dispense screen (shows current prescriber details)
'''   fromPMR% = False - called from within ident screen
'''   RxCode$  = if blank then display picking list otherwise automatically load precriber details specified from code$
'''
''' Out:
'''   success% = T/F   - returns whether prescriber details successfully retreived
'''
'''29May01 TH Multiple changes to allow for the use of the lstboxfrm instead of enhlstbox- this is done for
'''           The Royal Adelaide Hospital who want the selection of rxer done on a name sort, not by code  (#52394)
'''01Jun01 TH Changes to above after discussion with CKJ
'''01Jun01 CKJ/SF Routine modified extensively to increase flexibility and reduce network traffic. Original is commented out.
'''31Jan03 TH (PBSv4) MERGED - This could need on-site mdb changes !
'''31Jan03 TH (PBSv4) Properly normalise Rxer mdb with correct link to get prescriber type description
''
''Dim rxDB As Database
''Dim rxsnap As Snapshot
''Dim SQL$, code$, header$, rxList$, Display$, tmp$
''Dim OpenDB%, padLine%, numoflines%, x%
''Dim formlist As Form                     '29May01 TH Added
''Dim enhancedlist%, orderby$, codenum%    '    "
''Dim strNew As String  '22Jun03 TH Added
''
''   ReDim lines$(10)
''   success = False
''   If Not fileexists(dispdata$ & "\RXER.MDB") Then                                      '    "
''         popmessagecr "#ASCribe", "The prescriber database does not exist" & cr & "File: " & dispdata$ & "\RXER.MDB not found"
''         Exit Sub
''      End If
''
''   On Error GoTo GetPrescriberDetailsErr
''   orderby = txtd(dispdata$ & "\PATMED.INI", "Prescriber", "", "Orderby", 0) '29May01 TH Added for separate sort (if using old listbox)
''   If orderby <> "" Then
''         Set formlist = LstBoxFrm
''         enhancedlist = False
''      Else
''         Set formlist = EnhLstFrm
''         enhancedlist = True
''      End If
''
''   Set rxDB = OpenDatabase(dispdata$ & "\RXER.MDB", False, True)      '01Jun01 CKJ open for shared, read only
''   OpenDB = True
''
''   If RxCode$ <> "" Then
''         success = True
''         code$ = RxCode$
''      Else                                                    'get all prescribers and link to the Prescriber Type expansions
''         ' read site specific fields (default to code and name if not setup)
''         rxList$ = Trim$(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "code,name", "RxList", 0))
''         If Not enhancedlist Then rxList$ = txtd(dispdata$ & "\PATMED.INI", "Prescriber", rxList$, "AlternativeRxList", 0)   '29May01 TH Added to allow different setup if using old list box  '01Jun01 TH Changed ini setting
''         If InStr("," & LCase$(rxList$) & ",", ",code,") = 0 Then rxList$ = rxList$ & ",code"          'code' must be present
''         replace rxList$, ",,", ",", 0
''         'sql$ = "SELECT " & rxList$ & " FROM prescribers "    '31Jan03 TH (PBSv4) Replaced with below to allow for join (data is now correctly normalised)
''         SQL$ = "SELECT " & rxList$ & " FROM prescribers LEFT JOIN prescribertypes on prescribers.prescribertype = prescribertypes.PrescriberTypeCode "
''
''         If TrueFalse(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "N", "DisplayNotInuse", 0)) = False Then
''               SQL$ = SQL$ & " WHERE InUse = -1 "
''            End If
''
''         SQL$ = SQL$ & orderby$ & ";"
''
''         Set rxsnap = rxDB.CreateSnapshot(SQL$)
''         If Not rxsnap.EOF Then
''               padLine = Val(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "0", "PadLineWithNumSpaces", 0))
''               formlist.Caption = "Enter Prescriber"
''
''               ' read site specific header (default to code and name if not setup)
''               'header$ = TxtD(dispdata$ & "\PATMED.INI", "Prescriber", "Code [TB]Name   [TB]", "RxHeader", 0)
''               header$ = txtd(dispdata$ & "\PATMED.INI", "Prescriber", "Code [TB]Name                                      ", "RxHeader", 0)
''               If Not enhancedlist Then header$ = txtd(dispdata$ & "\PATMED.INI", "Prescriber", header$, "AlternativeRxHeader", 0) '01Jun01 TH Changed ini settings to avoid confusion
''               replace header$, "[TB]", TB, True
''               formlist.lblHead = header$
''
''               If fromPMR Then
''                     tmp$ = cr & "Current Prescriber details:" & cr & cr & "Prescriber ID: " & Trim$(gPrescriberID)
''                     formlist.lblTitle = tmp$ & cr & "Prescriber Name: " & Trim$(gPrescriberDetails.name) & cr
''                  Else
''                     formlist.lblTitle = ""
''                  End If
''
''               formlist.LstBox.Clear
''
''               deflines rxList$, lines$(), ",", 1, numoflines
''               For x = 1 To numoflines
''                  If LCase$(Trim$(lines$(x))) = "code" Then
''                        codenum = x
''                        Exit For
''                     End If
''               Next
''               'formlist.LstBox.AddItem "<NEW>" '18Jun03 TH Added
''               If TrueFalse(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "N", "AllowRxAddition", 0)) Then                    '22Jun03 TH Replaced Above
''                     strNew = Trim$(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "<NEW>", "NewPrescriber", 0))
''                     formlist.LstBox.AddItem strNew
''                  End If
''               Do While Not rxsnap.EOF
''                  Display$ = ""                               'only show in use prescribers unless spcified to show all
''                  For x = 1 To numoflines
''                     Select Case LCase$(Trim$(lines$(x)))
''                        Case "inuse"                                                      'use "Yes/No" instead of "-1/0"
''                           tmp$ = YesNo$(TrueFalse(GetField(rxsnap.Fields(lines$(x)))))
''                        Case "datecreated"                                                'format date correctly
''                           tmp$ = Format$(GetField(rxsnap.Fields(lines$(x))), "dd/mm/yyyy")
''                        Case Else                                                         'any other field
''                           tmp$ = GetField(rxsnap.Fields(lines$(x)))
''                        End Select
''                     Display$ = Display$ & tmp$ & TB
''                  Next
''                  formlist.LstBox.AddItem Display$ & Space$(padLine)
''                  rxsnap.MoveNext
''               Loop
''
''               If enhancedlist Then                       '29May01 TH Changed to allow use of old listbox
''                     EnhLstBoxShow
''                     code$ = Trim$(formlist.LstBox.Tag)
''                  Else
''                     LstBoxShow
''                     code$ = Trim$(formlist.Tag)
''                  End If
''
''               If code$ <> "" Then
''                     deflines code$, lines$(), TB & "(*)", 1, numoflines
''                     code$ = Trim$(lines$(codenum))  '29May01 TH Changed to allow code to be in different column position
''                     success = True
''                  End If
''            Else
''               popmessagecr "#ASCribe", "No prescribers set up, need to enter in Stock Maintenance"
''            End If
''         rxsnap.Close
''         Set rxsnap = Nothing
''      End If
''
''   If success Then
''         'If code$ = "<NEW>" Then         '18Jun03 TH Added
''         If code$ = strNew And TrueFalse(txtd(dispdata$ & "\PATMED.INI", "Prescriber", "N", "AllowRxAddition", 0)) Then            '22Jun03 TH Replaced
''               'close db objects
''               On Error Resume Next
''               If OpenDB Then
''                     rxDB.Close
''                     Set rxDB = Nothing
''                  End If
''               Unload formlist
''               Set formlist = Nothing
''               On Error GoTo 0
''
''               AddNewRxerOnTheFly        '20Jun03 TH Added
''            Else                         '18Jun03 TH Added
''               SQL$ = "SELECT * FROM prescribers WHERE code = '" & code$ & "';"
''               Set rxsnap = rxDB.CreateSnapshot(SQL$)
''               If Not rxsnap.EOF Then
''                     If Not GetField(rxsnap!inuse) Then
''                           askwin "?ASCribe", "This prescriber has been set out of use" & cr & "Do you still want to proceed?", tmp$, k
''                           ' writelog if continue??
''                           If tmp$ = "N" Or k.escd Then success = False
''                        End If
''                     If success Then
''                           gPrescriberID$ = Trim$(GetField(rxsnap!code))
''                           gPrescriberDetails.code = gPrescriberID$
''                           gPrescriberDetails.inuse = GetField(rxsnap!inuse)
''                           gPrescriberDetails.name = Trim$(GetField(rxsnap!name))
''                           gPrescriberDetails.Address1 = Trim$(GetField(rxsnap!Address1))
''                           gPrescriberDetails.Address2 = Trim$(GetField(rxsnap!Address2))
''                           gPrescriberDetails.Address3 = Trim$(GetField(rxsnap!Address3))
''                           gPrescriberDetails.postCode = Trim$(GetField(rxsnap!postCode))
''                           gPrescriberDetails.telephonenumber = Trim$(GetField(rxsnap!telephonenumber))
''                           gPrescriberDetails.specialist = Trim$(GetField(rxsnap!specialist))
''                           gPrescriberDetails.secondaryCode = Trim$(GetField(rxsnap!secondaryCode))
''                           gPrescriberDetails.registrationNumber = Trim$(GetField(rxsnap!registrationNumber))
''                           gPrescriberDetails.datecreated = CDbl(GetField(rxsnap!datecreated))
''                           gPrescriberDetails.prescribertype = Trim$(GetField(rxsnap!prescribertype))
''                           gPrescriberDetails.Freetext = Trim$(GetField(rxsnap!Freetext))
''                        End If
''                  Else
''                     success = False
''                     popmessagecr "#ASCribe", "Prescriber code not found"
''                  End If
''               rxsnap.Close
''            Set rxsnap = Nothing
''         End If                          '18Jun03 TH Added
''      End If
''
''GetPrescriberDetailsEnd:
''   On Error Resume Next
''   If OpenDB Then
''         rxDB.Close
''         Set rxDB = Nothing
''      End If
''   Unload formlist
''   Set formlist = Nothing
''   On Error GoTo 0
''Exit Sub
''
''GetPrescriberDetailsErr:
''   success = False
''   popmessagecr "#ASCribe", "Error in Procedure GetRxDetails: Error: " & Error$ & " Err: " & Format$(Err)
''Resume GetPrescriberDetailsEnd
''
''End Sub

Sub GetSetLocalWardListCode(Action As Integer, wardcode As String)
'09Apr01 CKJ Written
'            Allows the PID.ward to be passed into FillDrugList without stub procedures or using tags

Static strWardCode As String

   Select Case Action
      Case False: wardcode = strWardCode                    'Return code
      Case Else:  strWardCode = wardcode                    'Store code
      End Select

End Sub

Sub GetSupProfile(NSVCode$, supcode$, SupProfile As TSupProfile, success%, found%)
'30Jun99 CFY written
'Reads a supplier profile from the database. Requires both NSVCode and SupCode to be passed. The routine
'assumes that the NSVCode passed in is valid but checks the supplier code. The SupProfile structure
'is then populated if the record is found otherwise a blank structure is passed back. If for any reason
'the reading of the database fails then success is set to false.
'
'If the routine fails in any way success is set to false and the SupProfile structure is blanked
'if the record isn't found then success will be true, found will be false and the structure is blanked.
'
'07Dec99 CFY Improved error message to give enough information to the user to enable them to correct problems.
'06Apr00 TH *GST*Added vatrate field
'21Jul00 AE  If importing from an old snapshot, this field may not be present.  Trap the error if this occurs

'Dim ProfileSs As Snapshot
Dim sup As supplierstruct
Dim ssopen%, FoundSup As Long
Dim msg$, SQL$, ErrMsg$
Dim lngFoundSup As Long
Dim strParams As String
Dim rsProfileSS As ADODB.Recordset

   success% = True
   found% = False

   'Initialise Supplier profile structure.
   r.record = ""
   LSet SupProfile = r
   
   'Check the correct parameters have been supplied
   msg$ = ""
   If trimz(NSVCode$) = "" Then
         msg$ = msg$ & "NSVCode supplied is blank" & crlf
      End If
   If trimz(supcode$) = "" Then
         msg$ = msg$ & "Supplier Code supplied is blank" & crlf
      End If
   If Len(msg$) Then
         'msg$ = "Error encountered calling procedure GetSupProfile." & CRLF & msg$                                                             '07Dec99 CFY Replaced
         ErrMsg$ = "Error encountered calling procedure GetSupProfile." & crlf                                                                  '    "
         ErrMsg$ = ErrMsg$ & "A problem was found with product : " & crlf                                                                       '    "
         ErrMsg$ = ErrMsg$ & "NSVCode : " & NSVCode$ & crlf                                                                                     '    "
         ErrMsg$ = ErrMsg$ & "Desc    : " & d.LabelDescription & crlf & crlf                                                                         '    "
         ErrMsg$ = ErrMsg$ & msg$ & crlf & crlf                                                                                                 '    "
         ErrMsg$ = ErrMsg$ & "Please inform your Systems Supervisor to correct this problem." & crlf                                            '    "
         ErrMsg$ = ErrMsg$ & "(See " & dispdata$ & "\supprof.log) for details" & crlf                                                           '    "
         popmessagecr ".", ErrMsg$
         WriteLog dispdata$ & "\supprof.log", SiteNumber, UserID$, "NSVCode:" & NSVCode$ & ",  Desc:" & Trim$(d.LabelDescription) & ",  " & msg$     '07Dec99 CFY Added
         success% = False
      End If
    
   If success Then
      'Check the supplier code is valid
      getsupplier Trim$(supcode$), 0, lngFoundSup, sup
      success% = (lngFoundSup > 0)
   End If
   
   'If OK so far then attempt to load the record
   If success% Then
      '''SQL$ = "SELECT * FROM profile WHERE nsvcode = " & Chr$(39) & Trim$(NSVCode$) & Chr$(39)
      ''' = SQL$ & " AND supcode = " & Chr$(39) & Trim$(supcode$) & Chr$(39)
         On Error GoTo GetSupProfile_Err
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, supcode$)
               
   Set rsProfileSS = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierProfilebyNSVCodeandSupCode", strParams)
   If rsProfileSS.RecordCount > 0 Then
         
      'If record found then fill the supplier profile structure.
      If Not rsProfileSS.EOF Then
         found% = True
         SupProfile.SisCode = GetField(rsProfileSS!NSVCode)
         SupProfile.supcode = GetField(rsProfileSS!supcode)
         SupProfile.contno = GetField(rsProfileSS!contno)
         SupProfile.reorderpcksize = GetField(rsProfileSS!reorderpcksize)
         'SupProfile.reorderlvl = GetField(rsProfileSS!reorderlvl)
         'SupProfile.reorderqty = GetField(rsProfileSS!reorderqty)
         SupProfile.sislistprice = GetField(rsProfileSS!sislistprice)
         SupProfile.contprice = GetField(rsProfileSS!contprice)
         SupProfile.LeadTime = GetField(rsProfileSS!LeadTime)
         SupProfile.lastreconcileprice = GetField(rsProfileSS!lastreconcileprice)
         SupProfile.SupplierTradeName = GetField(rsProfileSS!SupplierTradeName)
         SupProfile.SuppRefno = GetField(rsProfileSS!SuppRefno)
         '''SupProfile.AltBarCode = GetField(rsProfileSS!AltBarCode)
         On Error Resume Next                                                                            '21Jul00 AE  If importing from an old snapshot, this field may not be present
         SupProfile.vatrate = GetField(rsProfileSS!vatrate)  '*GST*
         On Error GoTo GetSupProfile_Err                                                                 '     "
         SupProfile.WSupplierProfileID = GetField(rsProfileSS!WSupplierProfileID)
                 SupProfile.EDIBarcode = GetField(rsProfileSS!EDIBarcode)       ' 22Jul16 XN added 126634
         'Fill Heap
         Heap 10, gPRNheapID, "sRefno", SupProfile.SuppRefno, 0
         Heap 10, gPRNheapID, "sAltBarCode", SupProfile.AltBarCode, 0
      End If
      rsProfileSS.Close
      Set rsProfileSS = Nothing
   
   Else
   '? blank the type
   End If
   Else
   '?blank the type
   End If
GetSupProfile_Exit:
   On Error Resume Next
   If ssopen% Then
         rsProfileSS.Close
         Set rsProfileSS = Nothing
      End If
   On Error GoTo 0
   Exit Sub

GetSupProfile_Err:
   '!!! Fatal error message
   '!!! Check for corrupt database here.
   success% = False
   msg$ = "An error has occured in procedure : GetSupProfile" & crlf & crlf
   msg$ = msg$ & "Error No. : " & Format$(Err) & crlf
   msg$ = msg$ & Error$
   popmessagecr ".", msg$
   Resume GetSupProfile_Exit

End Sub

''Function GetUniqueNSVCode() As String
'''31Jul98 EAC written for HK mods
'''27May04 CKJ close binarysearchidx
''
''Dim tempNSV As String * 7
''Dim found As Integer
''Dim numeric As Integer
''Dim loopvar As Integer
''Dim UpdateNumeric As Integer
''Dim fnd As Long
''
''ReDim char$(4)
''ReDim DoUpdate%(3)
''
''popmessagecr ".", "GetUniqueNSVCode called - not currently supported"
''Stop '**!!**
''
''   tempNSV = UCase$(TxtD(dispdata$ & "\stkmaint.dat", "", "", "LastNSVCode", found))
''
''   If Trim$(tempNSV) = "" Then tempNSV = "AAA000A"
''
''''   binarysearchidx tempNSV, dispdata$ & "\drugsis.idx", True, 0, fnd&
''
''   Do While fnd& > 0
''      char$(4) = Right$(tempNSV, 1)
''      numeric = Val(Mid$(tempNSV, 4, 3))
''      char$(3) = Mid$(tempNSV, 3, 1)
''      char$(2) = Mid$(tempNSV, 2, 1)
''      char$(1) = Mid$(tempNSV, 1, 1)
''
''      UpdateChar char$(4), UpdateNumeric
''
''      If UpdateNumeric Then
''            numeric = numeric + 1
''            If numeric > 999 Then
''                  numeric = 0
''                  DoUpdate(3) = True
''               End If
''         End If
''
''      If DoUpdate(3) Then
''            For loopvar = 3 To 1 Step -1
''               UpdateChar char$(loopvar), DoUpdate(loopvar - 1)
''               If Not DoUpdate(loopvar - 1) Then Exit For
''            Next
''         End If
''
''      If DoUpdate(0) Then
''            popmessagecr "Error", "No more unique NSV codes available."
''''            Close
''''            End!
''         End If
''
''      tempNSV = char$(1) & char$(2) & char$(3) & Format$(numeric, "000") & char$(4)
''''      binarysearchidx tempNSV, dispdata$ & "\drugsis.idx", True, 0, fnd&
''
''   Loop
''
''   GetUniqueNSVCode = tempNSV
''
''   WritePrivateIniFile "", "LastNSVCode", tempNSV, dispdata$ & "\stkmaint.dat", found%
''   FlushIniCache     '28Jun00 JN Added
''''   binarysearchidx "", "", 0, 0, 0
''
''End Function

Sub GetWarCode(warcod$, Warning As String)
'10Jul94 ASC CHECK WARNING CODE
'13Feb95 CKJ Tidied
'20Mar95 CKJ was 5 char max width, now 6
'14Nov97 ASC NOw added .DSS decision support file
'19Jan98 EAC Moved from PATSUBS.BAS
'   "     "  No longer a static sub
'17Jul00 JN  Added warning when non-blank warcod$ returns a blank warn$
'25Aug00 JN  Amended warning to check Patmed.ini for .ini setting to turn this feature on/off
'22Apr14 XN  Updated to use local code first, then dss language specific then dss english 89088

Dim rs As ADODB.Recordset
Dim strParam As String
Dim Context As String
Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetWarCode"

    GetWLookupCode "warning.v4", warcod$, Warning, True '29Jun17 TH New generic cached call (TFS 191443)
    Exit Sub

   On Error GoTo ErrorHandler

   'Warning = ""
   'For iLoop = 1 To 2
   '   Context = ASCContextName("warning.v4", (iLoop = 1), 0)     22Apr14 XN Updated to use local code first, then dss language specific then dss english 89088
   'For iLoop = 1 To 3
      'Context = ASCContextName("warning.v4", (iLoop > 1), Iff(iLoop > 2, 44, 0))
      'strParam = gTransport.CreateInputParameterXML("siteid", trnDataTypeint, 4, gDispSite) & _
                  'gTransport.CreateInputParameterXML("context", trnDataTypeVarChar, 255, Context) & _
                  'gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 10, warcod) & _
                  'gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, Null)
      'Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParam)
      'If Not rs Is Nothing Then
         'If rs.State = adStateOpen Then
            'If rs.RecordCount <> 0 Then
               'Warning = RtrimGetField(rs!Value)
               'replace Warning, crlf, Chr$(LBL_END_LINE), 0
               'Exit For
            'End If
         'End If
      'End If
   'Next

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup




''Static lastpath$
''Dim numoflocalwar%
''Dim warchan%, X%, xs$, Y$, w$
''
''   warcod$ = RTrim$(UCase$(Left$(warcod$ + Space$(6), 6)))  '20Mar95 was 5
''   warn$ = ""
''
''   If lastpath$ <> ASCFileName("warning.v4", False, "") Then numofwar = 0
''
''   If numofwar = 0 Then
''         If fileexists(ASCFileName("warning.v4", True, "")) Then
''               warchan = FreeFile
''               Open ASCFileName("warning.v4", True, "") For Input Shared As warchan
''               Input #warchan, numofwar
''               ReDim Warning$(numofwar)
''               For X = 1 To numofwar
''                  Input #warchan, xs$
''                  Input #warchan, Y$
''                  Warning$(X) = Left$(xs$ + Space$(6), 6) + Y$
''               Next
''               Close #warchan
''            End If
''         If fileexists(ASCFileName("warning.v4", False, "")) Then
''               warchan = FreeFile
''               Open ASCFileName("warning.v4", False, "") For Input Shared As warchan '14Jul98 CKJ
''               Input #warchan, numoflocalwar
''               ReDim Preserve Warning$(numofwar + numoflocalwar)
''               For X = numofwar + 1 To numofwar + numoflocalwar
''                  Input #warchan, xs$
''                  Input #warchan, Y$
''                  Warning$(X) = Left$(xs$ + Space$(6), 6) + Y$  '20Mar95 was 5
''               Next
''               Close #warchan
''               numofwar = numofwar + numoflocalwar
''            Else
''               popmessagecr "Warning " & ASCFileName("warning.v4", False, "") & " not present", "Must be corrected"
''''               Close
''''               END!
''            End If
''         lastpath$ = ASCFileName("warning.v4", False, "")
''      End If
''
''   For X = 1 To numofwar
''      w$ = RTrim$(Left$(Warning$(X), 6))   '20Mar95 was 5
''      If warcod$ = w$ And w$ <> "" Then
''            warn$ = Mid$(Warning$(X), 7)   '20Mar95 was 5
''            Exit For
''         End If
''   Next
''   '25Aug00 JN Amended line below to use .ini setting from PatMed.ini to turn this feature on/off
''   If warcod$ > "" And warn$ = "" And TrueFalse(txtd(dispdata$ & "\patmed.ini", "", "N", "WarnCodeNotFoundMsg", 0)) Then '17Jul00 JN Added check for any failures to find a warning code
''         popmessagecr "!n!b", "The warning code '" & warcod$ & "' is not listed in the warning code file."
''      End If
End Sub

Function HidePrice(strCost As String, blnLeadingSpace As Integer) As String
'27May04 TH Written

If (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then
      HidePrice = Iff(blnLeadingSpace, " ****", "*****")
   Else
      HidePrice = strCost
   End If

End Function

Sub InitAltSupplier()

   AlternativeSupplier$ = ""
   
End Sub

Sub Issue(k As kbdcontrol, Qty!, maxqty!, d As DrugParameters, UserID$, patid$, dircode$, done%, trantype$, ward$, cons$, sitepaths%, IssType$, issueunitcost$, batchnumber$, expiry$, duplicates%, NumLabels%, Action As Integer)
'-----------------------------------------------------------------------------
' Checks qty! is sensible using mins and maxs from d struct then issues
' reduces qty! and makes transaction
'24Oct90 ASC tidied up and only qty! now not multiples
'27Apr91 ASC Now also increment period usage by qty!
'26Oct91 CKJ Drug record update moved to Translog
'27Oct91 CKJ/ASC max issue inc to 99,999 from 9000
' 7Feb92 CKJ BCR issue: if correct barcode is used, accept default qty.
'21May92 CKJ Added k.decimals. Added check for issue < 0 stock.
'07Jun92 ASC Added warning to issue before deleted items
'22Jul92 ASC if maxqty! is not 0 then will not allow issue above maxqty!
'29Jul92 ASC issuing now spelled correctly.
'24Jan95 CKJ made form wide enough - removed sizing calcs
' 3Mar95 CKJ uses formshowing%()
' 5Mar95 CKJ removed k.escd=false. This appeared in V6.3 uncommented.
' 6Apr95 CKJ/ASC Added k.escd=false
' 9Jan96 EAC add code to read PATMED.INI for ESCISSUEDEFAULT value
'15Mar96 KR  Converted to Windows
'!!**need to allow EAN 8
'25Aug96 ASC added issue of specific batch number batchnumber$ and expiry$ return deails of what was issued.
'??Mar97 KR  combined the label printing form with this form.
'            added parameters duplicates%, NumLabels%, Action:
'            In  Action = 1  - issue portion only
'            In  Action = 2  - issue and labels
'            Out Action = 3  - Issue aborted but still print labels
'            Out Action = 4  - Issue and print aborted
'            Out Duplicates  - whether duplicate labels to be printed
'            Out NumLabels%  - number of labels to be printed
'22Mar97 KR  added check to disallow negative issues.
'09Apr97 KR. Ensure no issuing if no drugcode e.g. when free format labels.
'09Apr97 KR  Check gTimedOut to ensure no issue if timed out.
'04Jun97 KR  Removed Confirm abort as no longer needed - now issue first and then
'            print label (Stephen said!)
' 27Mar97 KR Removed Setting of dircode$ (directions) to the batchnumber as this was
'            changing the directions on the dispensing form.
'26Aug97 CKJ added prescriber id round translog
'27Aug97 CKJ InputWin not called: k.min/max/nums/decimals removed since otherwise this
'            leaves settings for next box which is set incorrectly to nums/decimals etc
'23Dec97 EAC Add Action = 5 for the Store issue of Y x packsize
'            NB packsize should be passed through in Patid$ if different from packsize
'            in drug file e.g. WardStockLists
'29Dec97 EAC Automatically set the number of labels to be printed by assuming that each label
'            will be for a quantity <= pack size for that drug
'02Feb98 EAC Added formatting of issue qty text to allow decimals to be entered correctly in Issue form
'05Feb98 CFY Temporary solution to stop div by 0 errors occuring when printing ad-hoc free format labels
'27Apr98 CFY Will now print the correct quantity when 'Print labels Only' is selected. Previously
'            would always print the qty on the pmr screen regardless of what the user entered in the
'            issue box.
'29Jun98 EAC For Action=5, packs will only be displayed if they are in whole packs. NB this also stops problems
'            occurring due to rounding errors.
'20Jul98 EAC Make the Escape from printing label work correctly
'03Dec98 TH  Added abs to handle returns of part packs
'30Nov98 CFY Added code to handle duplicate sets fo labels
'21Jan99 EAC Added new actions to enable printing of Stock Labels
'               In  Action = 6  - Display as action = 2 but with option to print stock label (unchecked by default)
'               In  Action = 7  - Display as action = 2 but with option to print stock label (checked by default)
'               Out Action = 7  - Issue and print Stock Labels
'               Out Action = 8  - Issue aborted but still print Stock Labels
'25Mar99 TH  Changed value looked for from checkbox
'17May99 AE  Changed formatting of d.stocklvl on screen
'06Apr99 TH  Code to keepform loaded for baglabelprinting (to avoid use of global)
'07Apr99 TH  Increased form height when printing stocklabels
'15Apr99 TH  Changes to allow for issue quantity to be shown as units of packsize( X * X ) from stores
'20Apr99 TH  Close off actual issue for wardstock issueing with PTs
'21Apr99 TH  Reinstated usual format for issue amounts and closed off issue messages for psuedo issuing from wards with PTs
'26Apr99 TH  Corrected Logic to keepform open with baglabels
'30Apr99 TH  Allow for packsize to be shown in issue box when issuing from wardstocklists
'04Jun99 SF  added patient billing mods
'20Jul99 TH  Include packsize in total for all new stock actions (5+)
'28Jul99 AE  changed writelogs to use the global sitenumber instead of the undeclared variable Site%.  This was
'            previously always zero, but worked because writelog
'16Nov99 SF  added additional PBS patient billing mods
'24Nov99 SF  fixed the problem where program wasn't warning the user if issue went into negative on PBS
'06Apr00 TH  Stop packsize from wardstock issue going into caseno in translog
'26Sep00 TH  Changed formatting of d.stocklvl on screen to 6 sig places
'09Aug00 TH  If issue aborted due to neg stock then dont print stocklabels
'29May01 TH  Stop ward stock labels printing on cancel (#45739)
'11Jan02 TH  Changed text of popmessage (#49916)
'17Jan02 TH  Moved stockcontrol check to open up billing (specifically MOJ Rpt Disp) to non stock ctrl items (#58306)
'15Feb02 TH  Removed fenceposts for neg issues around TakeStockofBatch to allow returns of batches (#51886)
'12Mar02 TH/SF Only allow billing on none stock ctrl items if configured (#58306)
'30Apr02 ATW (#60856) Pass ans$ to billing routines to allow return value adjustment
'31Jan03 TH  (PBSv4) Switch of checking of min/max dose if PBS issue as the qty comes directly from PBS Schedule
'31Jan03 TH  to 31May03 TH Various mods to allow for Dispensing action "X" in PBS. This action uses pre-set qtys, so it bypasses
'            the issue screen (no of labels to print hard set to 1)
'01Mar03 TH  Merged Following Mod:
'05Sep02 SF  writes to TranslogExtra if setup (enh#1274)
'03Mar03 TH  (PBSv4) added mod to handle cancel coming from billing routines
'17Mar03 TH  (PBSv4) Added mod for PBS- If cancel then write a 'stub' Repeat record so the PBS details can be used on next run through.
'17Mar03 TH  Set default to Y (override) on BillingForNotLiveStockCtrl to allow PBS billing on non stock control items
'17Mar03 TH  Labels only option is not allowed for PBS, if selected user is warned and sent back to issue screen
'31Mar03 TH  (PBSv4) Added to suppress translog on PBS exceptional item issue
'07Apr03 TH  (PBSv4) Added mod to ensure no qty saved if escd PBS Issue.
'07Apr03 TH  (PBSv4) Added mod to correctly set Qty on PBS X type dispensing action
'16Feb04 CKJ Removed old comments to make code readable
'            Added MechDisp handling
'            moved prompt into body of warning window
'            added pack size to first line of issue form
'09Mar04 ckj added pack size & removed 'Esc to abort'
'11Mar04 CKJ moved mechdisp messages to ini file
'29Mar04 CKJ Merged testbuild code - only use MechDisp if exe is ASCshell
'04Jun10 XN  If Drug is not in use ask user if they want to continue (RCN P0158 F0023149)
'25Jun12 CKJ Added alternative label combo & handling       TFS24660
'31Oct12 TH  Create a sensible max qty msg for PSO (TFS41434)
'27Sep13 TH  Replaced above - Disable this for Doc Too (TFS 74486))
'09Jun14 TH  set k.escd on invalid issue so that we can trap internal orders releasing qty to the ordering site on issue TFS 92735
'04Dec14 XN  Added range check on label count to prevent it blowing 32576
'31Jul15 XN  Added range check on label count 92978
'07Apr16 XN  Moved negative log to db 123082
'09Jul16 TH  Renamed topuplvl variable and changed to long (TFS 157679)
'20Jan17 CKJ Only request robot labelling for actions which allow it (TFS 106390)
'24Jan17 TH  Reinstated purer fileexists check for alt labels on DB only - Hosted (TFS 174572)
'-----------------------------------------------------------------------------

Dim bk As Long, fr As Long, found%
Dim IssueQty$, StoresConvFact$
Dim keepform%
Dim Wspts%
Dim wsnopts%
Dim PatBillStub%, patBillEscd%  '04Jun99 SF added
Dim zeroissue%, lngDrugPtr&, negorpos%, temp$, desc$, ans$, tempans$              '28Jul99 AE Dim'd variable
Dim valid%, ans1$, warniss$, X%
Dim lenwin%, islive$                     '19Aug99 JP Dim'd variable
Dim patBillAns$      '16Nov99 SF added
Dim strLabelText As String
Dim intBatchNumber As Integer
Dim lngStartDate As Long
Dim blnReenter As Integer      '17Mar03 TH (PBSv4) Added '16feb04 CKJ renamed - was blnPBSLoop
Dim MachineType As String
Dim success As Integer
Dim QuantityIssued As String
Dim QuantityStocked As String
Dim ConvFactor As Single
Dim NumOfPacks As Single
Dim msg As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim tmp As String
Dim MechDispIni As String
Dim strMessageText As String   '16Jun05 CKJ added
Dim strNumofLabels As String   '16Aug05 TH Added
Dim RobotLabelling As Integer  '24Sep06 CKJ T/F
'Dim PSOsup As supplierstruct   '13Aug12 TH PSO
Dim strPSOSuptext As String

Dim count As Integer           '25Jun12 CKJ

   Wspts = False
   wsnopts = False
   If Action > 200 Then
         Action = Action - 200
         wsnopts = True
      End If

   If Action < 0 Then
         Action = Abs(Action)
         keepform = True
      End If

   If Action > 100 Then
         Action = Action - 100
         Wspts = True
      End If
      
   SetAltLabelContext ""                        '25Jun12 CKJ set to standard label by default
   FrmIssue.lblAltLabel.Visible = False         '   "
   FrmIssue.cmbAltLabel.Visible = False         '   "
   
   '07Aug12 TH Added
   If g_blnPSO Then
      If d.PSOLabel Then
         Action = 2
      Else
         Action = 1
      End If
   
   End If
      
   Select Case Action
      Case 1, 5  'Issue portion of form only 23Dec97 EAC added 5
         FrmIssue.Height = 2350
         FrmIssue.CmdOk.Top = 1485
         FrmIssue.cmdCancel.Top = 1485
         FrmIssue.Frmlabels.Visible = False
         FrmIssue.TxtLabels = 0
      Case 2, 6, 7 'Issue and Print       '21Jan99 EAC Added 6 & 7
         '21Jan99 EAC form enlarged to allow extra option box
         FrmIssue.Height = 4720
         FrmIssue.CmdOk.Top = 3765
         FrmIssue.cmdCancel.Top = 3765
         '---
         FrmIssue.Frmlabels.Visible = True
         FrmIssue.TxtLabels.text = "1"
         FrmIssue.TxtBagLabels = Val(TxtD(dispdata$ & "\patmed.ini", "BagLabels", "", "0", 0))     '30Nov98 Added
         '21Jan99 EAC stock label printing
         Select Case Action
            Case 2
               FrmIssue.lblAltLabel.Visible = True          '28Jun12 CKJ
               FrmIssue.cmbAltLabel.Visible = True          '   "
            Case 6, 7
               FrmIssue.ChkPrintStockLbl.Visible = True
               If Action = 7 Then FrmIssue.ChkPrintStockLbl.Value = 1      '28Jun12 CKJ added IF
            End Select
            
         '25Jun14 TH If Second label fix and disable the alternative label selector
         If IsExtraLabel() Then
            FrmIssue.cmbAltLabel.Clear
            FrmIssue.cmbAltLabel.AddItem "Extended Label"
            FrmIssue.cmbAltLabel.Enabled = False
         Else
            FrmIssue.cmbAltLabel.Enabled = True
            
            '25Jun12 CKJ Added block to support alternative label layouts
            FrmIssue.cmbAltLabel.Clear
            FrmIssue.cmbAltLabel.AddItem TxtD(dispdata & "\patmed.ini", "AltLabels", "Standard label", "DefaultDescription", 0)
            FrmIssue.cmbAltLabel.ItemData(FrmIssue.cmbAltLabel.NewIndex) = 0     'zero for standard label
            ReDim lines(1 To ALTLABELMAX) As String
            deflines TxtD(dispdata$ & "\patmed.ini", "AltLabels", "", "Settings", 0), lines(), "^", 1, count
            If count = ALTLABELMAX Then
               For count = 1 To ALTLABELMAX
                  ReDim Fields(1 To 3) As String         'context|description|inuse'
                  deflines lines(count), Fields(), "|(*)", 1, 0
                  If TrueFalse(Fields(3)) Then           'inuse = true
                     temp = UCase(Trim(Fields(1)))       'LBLALTnn'
                     If Len(temp) > 0 And InStr(temp, ALTLABELCONTEXTROOT) = 1 Then 'context starts 'LBLALT'
                        'GetRTFTextFromDB dispdata$ & "\" & Fields(1), "", intSuccess   '04Jan17 TH Now read from DB (Hosted)
                        'If fileexists(dispdata$ & "\" & fields(1) & ".rtf") Then    'rtf is present
                        If RTFExistsInDatabase(dispdata$ & "\" & Fields(1) & ".rtf") Then    '24Jan17 TH Reinstated purer file check on DB (TFS 174572)
                        'If intSuccess Then    '04Jan17 TH Now read from DB (Hosted) - replaced above
                           FrmIssue.cmbAltLabel.AddItem Fields(2)                   'description
                           FrmIssue.cmbAltLabel.ItemData(FrmIssue.cmbAltLabel.NewIndex) = Val(Right$(temp, 2))    'store nn from 'LBLALTnn'
                        End If
                     End If
                  End If
               Next
               Erase Fields
               Erase lines
            End If
         End If
         FrmIssue.cmbAltLabel.ListIndex = 0     'select standard label
         '--- end 25Jun12 ---
      End Select

   done = False
   zeroissue = False
   k.escd = False
   getdrug d, 0, lngDrugPtr, False

   If d.inuse = "N" Then
         SOUND 1000, 20
         
         ' 26Jul10 XN Get the drug description, and tidy up (RCN P0158 F0023149)
         Dim DrugDescription As String
         'drugDescription = RTrim$(d.Description)  XN 4Jun15 98073 New local stores description
                 DrugDescription = RTrim$(d.LabelDescription)
         plingparse DrugDescription, "!"
         
         ' 04Jun10 XN If Drug is not in use ask user if they want to continue (RCN P0158 F0023149)
         ' popmessagecr "#Warning", "This drug is no longer in use CHECK BEFORE ISSUING OR RETURNING"
         temp$ = "Drug '" & DrugDescription & "' is no longer in use." & vbNewLine & "Do you want to continue issuing or returning?"
         If MessageBox(temp$, MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2, "Warning") = IDNO Then
            k.escd = True
        End If
        '---
      End If

   If Not k.escd Then   ' 26Jul10 XN If Drug is not in use then skip the issue (RCN P0158 F0023149)
            If Qty! < 0 Then
               negorpos = -1
               temp$ = "RETURN"
               If IssType$ = "W" Then temp$ = "Stock RETURNED on ward"
            Else
               negorpos = 1
               temp$ = "ISSUE"
               If Wspts Then temp$ = "Issue via Picking Ticket" '15Jun12 TH TFS36037
               
               If IssType$ = "W" Then temp$ = "Stock ISSUED on ward"
               If g_blnPSO Then '31Oct12 TH Create a sensible max qty msg for PSO (TFS41434) (TFS 41014)
                  'temp$ = "Quantity for Patient Specific Order" '07Aug12 TH Added (PSO)
                  'Need now to get the PSO supplier details
                  'GetPSOSupplier PSOsup
                  strPSOSuptext = GetPSOSupplierText()
                  temp$ = "Quantity for PSO from " & strPSOSuptext
               End If
            End If

           If Not PBSDrugToDispens() Then        '31Jan03 TH (PBSv4) Switch of checking if PBS issue as the qty comes directly from PBS Schedule
               If Qty! * negorpos > Val(d.maxissue) Then
                  SOUND 1500, 1
                  'popmessagecr "#Check quantity", temp$ + " above set maximum please check"
                  popmessagecr "#Check quantity", temp$ + " above set maximum. Please check" '31Oct12 TH (TFS 41434)
               End If
               
               If Qty! < Val(d.minissue) And Qty! > 0 Then '30May95 CKJ simplified
                  SOUND 40, 1
                  'popmessagecr "#Check quantity", temp$ + " below set minimum please check"
                  popmessagecr "#Check quantity", temp$ + " below set minimum. Please check" '31Oct12 TH (TFS 41434)
               End If
           End If                               '31Jan03 TH (PBSv4)
           
           desc$ = RTrim$(d.LabelDescription)   ' desc$ = RTrim$(d.Description)  XN 4Jun15 98073 New local stores description
           plingparse desc$, "!"
           If Not g_blnPSO Then 'No Robot stuff for PSO
               '16Feb04 CKJ added block
               ConvFactor = Val(d.convfact)
               MechDispIni = dispdata$ & "\mechdisp.ini"
               Heap 1, RobotHeap, MachineType & " Data Heap", "", intSuccess
               If negorpos = 1 And LocationForMechDisp(d.loccode, MachineType) Then
                  FrmIssue.chkMechDisp.Width = 3000            '10Jan10 CKJ increased from 1500 for longer robot name
                  FrmIssue.chkMechDisp.Visible = True
                  'frmIssue.chkMechDisp.Caption = MachineType & " Issue"                                    '16Jun05 CKJ moved below to allow hotkey
                  'If TerminalForMechDisp(d.loccode) Then       'terminal is configured for mech disp   29Mar04 CKJ modified
                  'If app.EXEName = "ASCSHELL" And TerminalForMechDisp(d.loccode) Then       'terminal is configured for mech disp
                 
                  If TerminalForMechDisp(d.loccode) And Not Wspts And IssType <> "P" Then   'terminal is configured for mech disp   21Jun04 CKJ modified   '                prevent robot pick during picking ticket issue
                     FrmIssue.chkMechDisp.FontBold = False
                     FrmIssue.chkMechDisp.Enabled = True
                     FrmIssue.chkMechDisp.Value = 1          'checked
                     FrmIssue.chkMechDisp.Caption = MachineType & " &Issue"                              '16Jun05 CKJ Added Alt-I hotkey
                  Else
                     FrmIssue.chkMechDisp.FontBold = True
                     FrmIssue.chkMechDisp.Enabled = False
                     FrmIssue.chkMechDisp.Value = 2          'greyed
                     FrmIssue.chkMechDisp.Caption = MachineType & " Issue"                               '16Jun05 CKJ moved from above
                  End If
                  Heap 10, RobotHeap, "Machine", MachineType, intSuccess
                  Heap 10, RobotHeap, "IssueUnit", Trim$(d.PrintformV), intSuccess
                  tmp = "[IssueUnit]"                                                              'tab        btl
                  Heap 10, RobotHeap, "PackSize", Trim$(d.convfact) & " " & tmp, intSuccess        '28 tab     1 btl
                  If ConvFactor <> 1 Then tmp = "x [PackSize]"                                     'x 28 tab   btl
                  Heap 10, RobotHeap, "xPackSize", tmp, intSuccess
                  tmp = Trim$(d.loccode2)
                  If Len(tmp) = 0 Then tmp = "(NONE SPECIFIED)"
                  Heap 10, RobotHeap, "Location2", tmp, intSuccess
                  Heap 10, RobotHeap, "Description", desc$, intSuccess
                  Heap 10, RobotHeap, "cr", crlf, intSuccess
               End If
               If MachineType = "<UNKNOWN>" Then MachineType = ""         '26Feb04 CKJ added
           End If
           '15apr04 CKJ Added block
           'If GetIssueConfig() = 1 And Not frmIssue.Frmlabels.Visible Then     'deferred printing requested, but small form is on view
           If GetIssueConfig() = 1 And Val(FrmIssue.TxtLabels.text) = 0 Then    'deferred printing requested, but small form is on view 25Jul05 CKJ corrected type mismatch error
                 SetIssueConfig 0                                               'therefore turn bag labels off
              End If
           If Qty! < 0 Then SetIssueConfig 0                                    'Returns: turn bag labels off
           FrmIssue.lblBagLabelPrompt.Visible = False
           FrmIssue.lblBagLabelQuantity.Visible = False
           Select Case GetIssueConfig()                               'are bag labels supported?
              Case 1: FrmIssue.lblBagLabelQuantity.Visible = True     'defer printing until issue complete
              Case 2: FrmIssue.lblBagLabelPrompt.Visible = True       'print bag labels immediately
              End Select
           FrmIssue.lblBagLabelPrompt.Enabled = FrmIssue.lblBagLabelPrompt.Visible
           FrmIssue.lblBagLabelQuantity.Enabled = FrmIssue.lblBagLabelQuantity.Visible
           FrmIssue.TxtBagLabels.Visible = FrmIssue.lblBagLabelQuantity.Visible
           FrmIssue.TxtBagLabels.Enabled = FrmIssue.lblBagLabelQuantity.Visible

           Do
              lenwin = Len(desc$) + 18
              If d.livestockctrl = "Y" And IssType$ <> "W" Then
                 islive$ = " (Live)"
              Else
                 islive$ = ""
              End If
              If lenwin < 48 Then lenwin = 48
              If g_blnPSO Then '07Aug12 TH Added appropriate caption for PSO (TFS 40714)(TFS 41013)(TFS 41014)
                 FrmIssue.LblTopLine.Caption = "No issue will be made now from Pharmacy stock"
                 FrmIssue.lblPackSize.Caption = Iff(ConvFactor <> 1, "Pack size " & Trim$(d.convfact) & " " & RTrim$(LCase$(d.PrintformV)), "")
              ElseIf IssType$ = "W" Then '07Aug12 TH Added appropriate caption for PSO (TFS 40714)
                 FrmIssue.LblTopLine.Caption = temp$ & "    (No issue will be made now from Pharmacy stock)"     '09Nov05 CKJ
              Else
                 FrmIssue.LblTopLine.Caption = temp$ & " (" & FormatVal$(d.stocklvl, 2, 6) & " " & RTrim$(LCase$(d.PrintformV)) & " in stock)"
                 FrmIssue.lblPackSize.Caption = Iff(ConvFactor <> 1, "Pack size " & Trim$(d.convfact) & " " & RTrim$(LCase$(d.PrintformV)), "")
              End If
                   
              FrmIssue.LblDrug.Caption = desc$
              FrmIssue.LblPrintForm.Caption = LCase$(d.PrintformV)

              '23Dec97 EAC
              'ans$ = LTrim$(Str$(qty! * negorpos))
              On Error Resume Next '!!** 05Feb98 CFY Temporary solution until we can flag whether or not we are printing a free format label
              'If action = 5 Or Wspts Or wsnopts Then   '15Apr99 TH  30Apr99 TH Reinstated and include no Pt wards
              If Action > 4 Or Wspts Or wsnopts Then    '20Jul99 TH Include packsize in total for all stock actions
                    If Trim$(patid$) <> "" Then
                            StoresConvFact$ = Trim$(patid$)
                            patid$ = ""    '06Apr00 TH Stop packsize from wardstock issue going into caseno in translog
                        Else
                            StoresConvFact$ = Trim$(d.convfact)
                        End If

                    '29jun98 EAC For Action=5, packs will only be displayed if they are in whole packs
                    If Qty! Mod Val(StoresConvFact$) = 0 And Qty! <> 0 Then
                    IssueQty$ = Format$(Abs(Qty!) / Val(StoresConvFact$))
                    If InStr(IssueQty$, ".") > 0 Then IssueQty$ = Format$(IssueQty$, "0.#")     '02Feb98 EAC Added to allow decimals to be entered correctly in Issue form
                          ans$ = IssueQty$ & " x " & StoresConvFact$
                       Else
                          ans$ = Format$(Abs(Qty!))  '03Dec98 TH  Replaced above
                       End If
                    
                 Else
                    ans$ = LTrim$(Str$(Qty! * negorpos))
                    If Val(ans$) Mod Val(d.convfact) = 0 Then
                       FrmIssue.TxtLabels.text = Val(ans$) \ Val(d.convfact)
                    Else
                       FrmIssue.TxtLabels.text = Val(ans$) \ Val(d.convfact) + 1
                    End If
                    
                 End If
              On Error GoTo 0 '!** 05Feb98
              
              FrmIssue.TxtIssue.text = ans$

              Do
                 blnReenter = False '17Mar03 TH (PBSv4) Added   '16feb04 renamed
                 If negorpos = -1 Then fr = Red Else fr = Black 'bk = QBColor(15): fr = QBColor(0)
                 FrmIssue.FraIssue.ForeColor = fr
                 FrmIssue.LblTopLine.ForeColor = fr
                 FrmIssue.LblDrug.ForeColor = fr
                 FrmIssue.LblPrintForm.ForeColor = fr
                 FrmIssue.lblPackSize.ForeColor = fr        '09Mar04 CKJ added
                 FrmIssue.LblTopLine.BackColor = bk
                 FrmIssue.LblDrug.BackColor = bk
                 FrmIssue.LblPrintForm.BackColor = bk
                 tempans$ = FrmIssue.TxtIssue.text
                 
                 Do
                    k.timd = False
                    If trimz(d.SisCode) = "" Then FrmIssue.Chk3DPrintOnly.Value = 1                  '09Apr97 KR.  Ensure no issuing if no drugcode !!**
                    FrmIssue.TxtIssue.text = Format$(tempans$) '30Dec97 ASC/SF
                    FrmIssue.Caption = temp$ '"ISSUE"                                                '16Nov99 SF moved from below
                    patBillAns$ = tempans$                                                           '16Nov99 SF added
                    patBillEscd = billpatient(9, Format$(negorpos))    '16Nov00 SF set max qty in issue box
                    If Not patBillEscd Then     '02Dec99 SF only do following if mot PBS or not escaped above
                          If tempans$ = "" Then tempans$ = patBillAns$                                     '16Nov99 SF added
                          FrmIssue.TxtIssue.SelStart = 0    '10May95 ASC moved from outside do
                          If Action = 5 Then
                                FrmIssue.TxtIssue.SelLength = Len(IssueQty$)
                             Else
                                FrmIssue.TxtIssue.SelLength = Len(ans$)
                             End If
                          
                          gTimedOut = False
                          
                          If isPBS() Then                                '31Mar03 TH (PBSv4) Added
                                If PBSGetBillitem(53) = "X" Then         '01Apr03 TH Replaced above
                                      If negorpos = -1 Then                          '07Apr03 TH Added to Allow return on previous Exceptional quantity
                                            ans$ = Format$(PBSGetExceptionalQty())   '    "
                                         Else                                        '    "
                                            ans$ = PBSGetBillitem(94)                '    "
                                         End If                                      '    "
                                      Qty! = Val(ans$)
                                      FrmIssue.TxtLabels.text = "1"      '01May03 TH (PBSv4) Added for label printing - may need to ask the user? '31May03 TH Hard set to 1 label
                                      ItemTypeStatus 3, "", "", ""      'write too db '25Sep07 TH Merge error with  PBS, removed param
                                   Else
                                      SetKeepPBSDefaults True            '09Jul02 TH %PBS% Added
                                      FrmIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                                      ans$ = FrmIssue.TxtIssue.text
                                   End If
                             Else
                                SetKeepPBSDefaults True                  '09Jul02 TH %PBS% Added
                                FrmIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                                ans$ = FrmIssue.TxtIssue.text
                             End If
                          SetKeepPBSDefaults False
                          
                          If isPBS() Then                                           '17Mar03 TH (PBSv4) Added If cancel then write a 'stub'
                                
                                If ans$ = "" Then
                                   ItemTypeStatus 3, "", "", ""     '   "       Repeat record so the PBS details can be used '25Sep07 TH Merge error with  PBS, removed param
                                End If
                             End If                                                 '   "       on next run through.
                          
                                                  If Val(FrmIssue.TxtLabelSets.text) > 32767 Then          '31Jul15 92978 XN Added range check
                             popmessagecr ".Error", "Invalid number of labels"
                             patBillEscd = True
                          Else
                             duplicates% = Val(FrmIssue.TxtLabelSets.text)             '      "
                          End If
                          
                          If Trim$(ans$) <> "" Then     '02Dec99 SF added so as not to fire if escd on issue screen
                             
                             If negorpos = 1 Then                                  ' deal with an issue for PBS
                                patBillEscd = billpatient(10, Format$(ans$))    '16Nov00 SF now allows cancelling out
                             Else                                               ' deal with a return for PBS
                                patBillEscd = billpatient(14, ans$)             '30Apr02 ATW Send ANS$ thru to allow return qty setting
                             End If
                          End If                     '02Dec99 SF added
                          'If IssType$ <> "C" Then NumLabels% = Val(FrmIssue.TxtLabels.text)
                          If Val(FrmIssue.TxtLabels.text) > 32767 Then          '4Dec14 32576 XN Added range check (will give better error in ParseIssueQty just prevent it blowing up here)
                             patBillEscd = True
                          ElseIf IssType$ <> "C" Then
                             NumLabels% = Val(FrmIssue.TxtLabels.text)
                          End If
                       End If      '02Dec99 SF added
                     k.escd = False    '6Apr95 CKJ/ASC Added
                     k.escd = patBillEscd                                              '02Dec99 SF replaced above statement with a more readable variable name
                     If ans$ = "" Then                                                 'ASC 1Apr95 added to help Watford find people excaping from issue
                        'WriteLog dispdata$ & "\escissue.log", SiteNumber, UserID$, d.Description + d.SisCode + d.stocklvl + "Escaped issue " + patid$ + " " + ward$ + " " + cons$  XN 4Jun15 98073 New local stores description
                                                WriteLog dispdata$ & "\escissue.log", SiteNumber, UserID$, d.LabelDescription + d.SisCode + d.stocklvl + "Escaped issue " + patid$ + " " + ward$ + " " + cons$
                        Action = 4
                        k.escd = True
                     '23Dec97 EAC convert the Y x packsize
                     Else
                        '21Jan99 EAC handle dispensary and stock labels
                        If Action = 6 Or Action = 7 Then
                            'If FrmIssue.ChkPrintStockLbl.Value = True Then   '25Mar99 TH Replaced with below
                            If FrmIssue.ChkPrintStockLbl.Value = 1 Then
                               Action = 7
                            Else
                               Action = 1
                            End If
                         End If
                        ParseIssueQty ans$
                     End If
                     '30Oct12 TH PSO Check to ensure full pack (TFS 40713)
                     If ans$ <> "" And Not k.escd And g_blnPSO Then
                        If Val(ans$) Mod Val(d.convfact) <> 0 Then
                           popmessagecr "Patient Specific Ordering", "Patient Specific Order must be for complete packs only"
                           ans$ = ""
                        End If
                     End If
                 Loop Until ans$ <> "" Or k.escd   '04Jun97 KR
           
                 If gTimedOut Then k.escd = True  '09Apr97 KR
                 If Not k.escd Then      '20Jul98 EAC Added to escape from issue properly
                       '09Apr97 KR !!**
                       If trimz(d.SisCode) = "" Then FrmIssue.Chk3DPrintOnly.Value = 1
                       
                       'If only want to print labels then abort issue.
                       If FrmIssue.Chk3DPrintOnly.Value = 1 Then
                             'If isPBS() Then                                                          '17Mar03 TH (PBSv4) Added
                             If isPBS() Or (getTotalRepeats() > 0) Then      '27Sep13 TH Replaced above - Disable this for Doc Too (TFS 74486)
                                'popmessagecr "ASCribe Patient Billing", "Print Labels Only not allowed for PBS dispensing"   '    "
                                popmessagecr "Patient Billing", "Print Labels Only not allowed for " & Iff(isPBS(), "PBS", TxtD(dispdata$ & "\RptDisp.ini", "RepeatDispensing", "instalment", "instalmentDescription", 0)) & " dispensing" '28sep13 TH (TFS 74486)
                                blnReenter = True                                                                            '    "              '16feb04 Ckj renamed
                             Else                                                                                            '    "
                                k.escd = True
                                '21Jan99 EAC handle stock and dispensary labels
                                If FrmIssue.ChkPrintStockLbl.Value = 0 Then
                                      Action = 3 'abort issue but print labels.
                                   Else
                                      Action = 8 'abort issue but print stock labels.
                                   End If
                                Qty! = dp!(Val(ans$))      '27Apr98 CFY Added
                             End If                                                                                    '    "
                          Else
                             If (1! * Val(ans$) > maxqty!) And maxqty! <> 0 Then
                                   popmessagecr "RE-ENTER", "Issuing above maximum not allowed"   '11Jan02 TH Changed (#49916)
                                End If
                          End If
                       
                       '16Feb04 CKJ Added block
                       If negorpos = 1 And Len(MachineType) > 0 And Val(ans$) > 0 Then                                 'mechanical dispensing set up for this product
                             msg$ = ""
                             Select Case FrmIssue.chkMechDisp.Value
                                Case 0                                                                                 'issuing from alternate location xxx
                                   msg$ = "[SelectedManualIssueMsg]"                                                   ' "Check whether stock is held in [Machine]"
                                   
                                Case 1                                                                                 'check for issue in whole packs
                                   NumOfPacks = Int(Val(ans$) / ConvFactor)                                            'round down to last pack eg 30 to 28 or 102 to 100
                                   If Val(ans$) > NumOfPacks * ConvFactor Then                                         'whole pack not requested
                                         'If (Qty! / ConvFactor) > .1 Then                                             'round up to next pack?  eg 25 to 28 or 90 to 100
                                         '      NumOfPacks = NumOfPacks + 1
                                         '   End If

                                         '01Mar04 CKJ removed block
                                         '      msg$ = MachineType & " only issues whole packs" & crlf
                                         '      msg$ = msg$ & "Pack size is " & Trim$(d.convfact) & " " & d.PrintformV & crlf & crlf
                                         '      msg$ = msg$ & "Do you wish to adjust the issue quantity?"
                                         '      'msg$ = msg$ & "Suggested quantity is "
                                         '      'msg$ = msg$ & Format$(NumOfPacks * ConvFactor) & " " & d.printformv
                                         '      response$ = "Y"
                                         '      askwin "!" & MachineType & " Issue", msg$, response$, k
                                         '      If response = "Y" Then
                                         '            'Qty! = NumOfPacks * ConvFactor
                                         '            'FrmIssue.TxtIssue.Text = Format$(Qty!)
                                         '            blnReenter = True
                                         '         End If
                                      
                                         msg$ = "[SelectedPartPackMsg]"                                                ' "[Machine] only issues whole packs[cr]Pack size is [PackSize]"
                                         blnReenter = True
                                      End If

                                Case 2
                                   If Not Wspts And IssType <> "P" Then                                                '07Nov05 PJC [TerminalNotPermittedMsg] Message not required if robot pick during picking ticket issue.
                                      msg$ = "[TerminalNotPermittedMsg]"                                                  ' "This terminal cannot issue from [Machine][cr]Please check alternate location [Location2]"
                                   End If

                                End Select

                             ParseCtrlChars MechDispIni, "common", msg$, False
                             ParseItems RobotHeap, msg$, False
                             If Len(msg$) Then popmessagecr "!" & MachineType & " Issue", msg$
                          End If

                    End If
              Loop Until (((1! * Val(ans$) <= maxqty!) Or k.escd Or maxqty! = 0) And Not blnReenter)   '17Mar03 TH (PBSv4) Added  '16feb04 CKJ renamed boolean

              'If Not k.escd Then        '  7Feb92 CKJ Accept offered qty if SAME barcode is shot again
              If g_blnPSO And (Not k.escd) Then
                  'here we do PSO specific stuff (raise the order) (TFS 40713) (TFS 40789)
                  CreatePSOrder Val(ans$)
              Else
                 If (Not k.escd) And (Not Wspts) Then   '21Apr99 TH Dont Issue if printing a PT
                     valid = True
                     If Len(Trim$(d.barcode)) = 13 And Left$(ans$, 6) = Left$(d.barcode, 6) Then
                        ans$ = LTrim$(Str$(Qty! * negorpos))  ' matches 1st 6 chars of BCR
                        waitforticks 10
                     End If

                    '22Nov17 TFS 190825: Pharmacy dispensing - situation where stock can go negative
                    'Changes to refresh the product stock level immediately before an issue is made
                    getdrug d, 0, 0, False

                     If IssType$ <> "W" And (d.livestockctrl = "Y" Or TrueFalse(TxtD(dispdata & "\" & "patmed.ini", "PatientBilling", "Y", "BillingForNotLiveStockCtrl", found))) Then      '12Mar02 TH/SF Added change on ini setting after second check (#58306) '17Mar03 TH Set default to Y (override)
                        patBillEscd% = False                                                                      '04Jun99SF added
                        If billpatient(22, "") Or (Not BillPatDispensQty(Val(d.stocklvl), dp!(Val(ans$)), negorpos%, patBillEscd%)) Then   '16Nov00 SF now fires if PBS setup but public dispensing
                           If patBillEscd Then k.escd = True '03Mar03 TH (PBSv4) added
                           If Not patBillEscd And d.livestockctrl = "Y" Then    '02Dec99 SF added to check if reached reached repeat limit   '17Jan02 TH (#58306)
                              If dp!(Val(d.stocklvl) - dp!(Val(ans$))) < 0 And Val(ans$) > 0 And negorpos = 1 Then  '30May08 TH Added dp! to ans for fractional issue qty
                              'If Val(d.stocklvl) - Val(ans$) < 0 And Val(ans$) > 0 And negorpos = 1 Then
                                 If UCase$(TxtD(dispdata & "\" & "patmed.ini", "", "", "NoNegIssues", found)) = "Y" Then '22Mar97 KR added
                                       popmessagecr "!Issue Aborted", "Issue would reduce stock level below zero.  Issue aborted."
                                    k.escd = True
                                    Action = 4       '09Aug00 TH - Dont print stocklabels, Issue aborted
                                 Else
                                    ans1$ = "N"
                                    k.helpnum = 160
                                    SOUND 2500, 10
                                    If Val(ans$) > Qty! Then
                                       warniss$ = "Issue will reduce stock "                 '16feb04 ckj removed !n!b
                                    Else 'ASC 4Aug92
                                       warniss$ = "Stock "                                   '16feb04 ckj removed !n!b
                                    End If
                                    'Confirm warniss$ + "level below zero", "proceed with the issue", ans1$, k                              '16feb04 ckj moved prompt into body
                                    askwin "!EMIS Health", warniss$ + "level below zero" & crlf & "OK to proceed with the issue?", ans1$, k
                                    If ans1$ = "N" Then
                                       k.escd = True
                                    Else 'ASC 4Aug92
                                       'WriteLog dispdata$ & "\negative.log", SiteNumber, UserID$, d.Description + d.SisCode + Left$(ans$ + "     ", 5) + d.stocklvl XN 4Jun15 98073 New local stores description
                                                                           'WriteLog dispdata$ & "\negative.log", SiteNumber, UserID$, d.LabelDescription + d.SisCode + Left$(ans$ + "     ", 5) + d.stocklvl    07Apr16 XN  Moved negative log to db 123082
                                                                                WriteLogSQL "negative", "Negative Stock Warning" + vbNewLine + "Issued: " + ans$ + " Stock Lvl Was: " + d.stocklvl, 0, 0, d.SisCode
                                    End If
                                    If k.escd Then Action = 4       '29May01 TH Stop ward stock labels printing
                                 End If
                              End If
                           End If      '02Dec99 SF added
                              
                           If (Not k.escd) And (negorpos = 1) Then                    '26Jun02 TH %PBS% Changed
                              If isPBS() Then                                         '    "
                                 If TrueFalse(TxtD(dispdata & "\" & "patmed.ini", "PatientBilling", "Y", "PBSLaunchIssueScreen", found)) And Trim$(UCase$(PBSGetBillitem(53))) <> "X" Then  '23Jul03 TH Suppress if X type alredy selected
                                    'patBillEscd = BillPatient(1, "")    '23Jul03 TH Added
                                    patBillEscd = billpatient(35, "")
                                 Else
                                    patBillEscd = billpatient(20, "")
                                 End If
                                 If patBillEscd Then ans$ = ""     '07Apr03 TH (PBSv4) Added to ensure no qty saved if escd PBS Issue
                              ElseIf IsPCTDispensing() Then    '24Nov11 TH Added for PCT
                                  'We are in PCT Mode - we have done all checks and issued /returned.
                                  'Now we need to pop the screen to confirm the claim qty
                                  'We may need some rules here for a return !!!!
                                  patBillEscd = PCTConfirmClaimQty(dp!(Val(ans$)))
                              Else
                                 patBillEscd = billpatient(1, "")                  '    " '*****
                              End If
                           End If
                           If (Not k.escd) And (negorpos = 1) Then k.escd = patBillEscd                  '02Dec99 SF added to stop issue if necessary
                        Else
                           If Not patBillEscd% And negorpos% = 1 Then
                              k.escd = billpatient(1, "")
                           Else
                              k.escd = patBillEscd%
                           End If
                        End If
                     End If
                     Qty! = dp!(Val(ans$))  '12Jul93 CKJ Added dp!
                     
                     If (Not k.escd) And negorpos% = 1 Then
                        'patBillStub% = BillPatient(4, "")  '04Jun99SF added to set qty! to toDispens!
                        '16Aug05 TH Replaced above to allow for labels to be reset if necessary when billing in a repeat cycle
                        If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0)) Then
                           strNumofLabels = Format$(NumLabels)
                           PatBillStub% = billpatient(4, strNumofLabels)
                           NumLabels = Val(strNumofLabels)
                        End If
                        '--------------
                     End If
   
                     If Qty! > 999999 Then valid = False ' 27Oct91 CKJ/ASC (NB t.qty is 9 chars!!)
                     'If Qty! = 0 And Left$(d.Description, 3) <> "***" Then zeroissue = True    'asc 10.7  XN 4Jun15 98073 New local stores description
                                         If Qty! = 0 And Left$(d.LabelDescription, 3) <> "***" Then zeroissue = True
                  End If
               End If
               
               If isPBS() Then                                       '31Mar03 TH (PBSv4) Added to suppress translog on PBS exceptional item issue
                  'If PBSGetBillitem(92) = "Y" Then
                  If PBSGetBillitem(53) = "X" Then
                     Wspts = True
                     done% = True
                     Qty! = dp!(Qty! * negorpos)  '07Apr03 Th (PBSv4) Added
                  End If
               End If
               
               '07Jan15 TH Added check on Ward Stock top up level (TFS 102826)
               'If m_intWardStockTopUpLevel > 0 Then
               If m_lngWardStockTopUpLevel > 0 Then '09Jul16 TH Renamed and changed to long (TFS 157679)
                  If (dp!(Val(ans$)) > m_lngWardStockTopUpLevel) And (negorpos) > 0 Then '09Jul16 TH Renamed and changed to long (TFS 157679)
                     popmessagecr "Ward Stock", "Cannot Request more than line top up level"
                     k.escd = True
                  End If
               End If
               '---
               
              'If Not Wspts Then   '20Apr99 TH Do not actually issue if coming from a ward with PTs
              If (Not Wspts) And (Not g_blnPSO) Then   '20Apr99 TH Do not actually issue if coming from a ward with PTs '07Aug12 TH Added PSO
                    'If valid And Not k.escd And Not zeroissue And Left$(d.Description, 3) <> "***" Then     XN 4Jun15 98073 New local stores description
                                        If valid And Not k.escd And Not zeroissue And Left$(d.LabelDescription, 3) <> "***" Then
                          '16feb04 ckj added block
                          If negorpos = 1 And Len(MachineType) > 0 And FrmIssue.chkMechDisp.Value = 1 Then
                                RobotLabelling = (NumLabels > 0)    'we want robot labelling if supported (reduce to bool)
                                
                                '16Jul12 CKJ Prevent robot printing if alternative label layout is used                   TFS38989
                                If FrmIssue.cmbAltLabel.ListIndex > 0 Then RobotLabelling = False
                                If IsExtraLabel() Then RobotLabelling = False '25Jun14 TH Added
                                If Action% <> 2 And Action% <> 6 And Action% <> 7 Then RobotLabelling = False '20Jan17 CKJ Only request robot labelling for actions which allow it (TFS 106390)
                                
                                msg$ = ""
                                'success = MechDispIssue(d, True, Format$(qty! / ConvFactor), QuantityIssued, QuantityStocked, strMessageText, False) '16Jun05 CKJ added strMessageText
                                success = MechDispIssue(d, True, Format$(Qty! / ConvFactor), QuantityIssued, QuantityStocked, strMessageText, RobotLabelling)      '01Oct06 CKJ WillRobotPrint=RobotLabelling
                                
                                Heap 10, RobotHeap, "QtyRequested", Format$(Qty! / ConvFactor), intSuccess
                                Heap 10, RobotHeap, "QtyIssued", QuantityIssued, intSuccess
                                Heap 10, RobotHeap, "QtyStocked", QuantityStocked, intSuccess
                                Heap 10, RobotHeap, "QtyNeeded", Format$(Qty! / ConvFactor - Val(QuantityIssued)), intSuccess
                                Heap 10, RobotHeap, "MessageText", strMessageText, intSuccess                                                  '16Jun05 CKJ added
                                If success Then
                                      If Val(QuantityIssued) > 0 Then
                                            If Val(QuantityIssued) < Qty! / ConvFactor Then
                                                  msg$ = "[DeliveredPartQuantityMsg]"                   'msg$ = "Not enough stock in [Machine][cr][cr]    [QtyRequested] [xPackSize] requested[cr]    [QtyIssued] [xPackSize] issued[cr][cr]Please check alternate stock location [Location2][cr]for the remaining [QtyNeeded] [xPackSize]"

                                                  'If part qty delivered, site can choose to issue just this amount or to issue the whole qty
                                                  If TrueFalse(TxtD(MechDispIni, "common", "0", "DeliveredPartButIssueAll", 0)) = False Then
                                                        Qty! = Val(QuantityIssued) * ConvFactor                   '01mar04 CKJ
                                                     End If
                                               End If
                                         Else
                                            msg$ = "[DeliveredNoneMsg]"
                                            If TrueFalse(TxtD(MechDispIni, "common", "0", "DeliveredNoneButIssueAll", 0)) = False Then
                                                  zeroissue = True                                                'none to issue, status message from interface shows this so popmessage not essential
                                               End If
                                         End If
                                   Else
                                      msg$ = "[NoCommunicationMsg]"
                                      If TrueFalse(TxtD(MechDispIni, "common", "0", "NoCommunicationButIssueAll", 0)) = False Then
                                            zeroissue = True                                                      'could not communicate or product not recognised etc
                                         End If
                                   End If
                                
                                ParseCtrlChars MechDispIni, "common", msg$, False
                                ParseItems RobotHeap, msg$, False
                                If Len(msg$) Then popmessagecr "!" & MachineType & " Issue", msg$
                             End If
                          
                          If Not zeroissue Then                                                               '16feb04 CKJ added
                                Qty! = dp!(Qty! * negorpos) '25Aug93 ASC added dp!
                                'TakeStockFromBatch d.SisCode, (Qty!), batchnumber$, expiry$, 0, False               'auto is not dimmed, so will be zero
                                'TakeStockFromBatch d.SisCode, (Qty!), BatchNumber$, expiry$, 0, negorpos '17Sep07 TH Identify return correctly
                                TakeStockFromBatch d.SisCode, (Qty!), batchnumber$, expiry$, 0, Iff(negorpos <> 1, True, False) '22Octp07 TH NegorPos is not Boolean of course !!!!!
                                'SQL place marker
                                gTlogPrescriberID$ = gPrescriberID$        '26Aug97 CKJ added
                                Translog d, lngDrugPtr, UserID$, patid$, Qty!, dircode$, ward$, cons$, trantype$, sitepaths%, IssType$, issueunitcost$
                                If LogExtraData() Then                                                        '05Sep02 SF added block
                                      GetLabelDetails strLabelText, intBatchNumber, lngStartDate
                                      TranslogExtra strLabelText, intBatchNumber, lngStartDate
                                   End If
                                If IsPCTDispensing() Then
                                    LogAllPCTDispensings
                                End If
                                gTlogPrescriberID$ = ""                    '26Aug97 CKJ added
                                done = True                                '18jun04 CKJ Moved inside the IF ... done signals that the issue actually happened
                             End If
                          'done% = True                                     18jun04 CKJ Moved inside the IF above
                       Else
                          If Not k.escd And Val(ans$) <> 0 Then
                                'If Left$(d.Description, 3) = "***" Then ans$ = "Drug not on file"   XN 4Jun15 98073 New local stores description
                                                                If Left$(d.LabelDescription, 3) = "***" Then ans$ = "Drug not on file"
                                popmessagecr "!Issue", "Invalid issue:  '" & ans$ & "'"
                                k.escd = True '09Jun14 TH This needs setting so that we can trap internal orders releasing qty to the ordering site on issue TFS 92735
                             End If
                       End If
                 End If       '20Apr99 TH

              If gTimedOut Then
                    For X = 1 To 100
                       SOUND 200 + X, 2
                    Next
                    SOUND 200, 10
                    SOUND 300, 10
                    SOUND 400, 10
                    SOUND 100, 30
                    popmessagecr "Warning", "Issue needs confirming"
                 End If

           Loop Until Not gTimedOut
                     
           '25Jun12 CKJ Retain chosen alternative label layout (if any)
           If (Not k.escd Or Action = 3) And FrmIssue.cmbAltLabel.ListIndex > 0 Then   'leave blank for -1 (none selected) and 0 (standard label)
              SetAltLabelContext ALTLABELCONTEXTROOT & Format$(FrmIssue.cmbAltLabel.ItemData(FrmIssue.cmbAltLabel.ListIndex), "00")
           End If
                     
           If Val(FrmIssue.TxtBagLabels.text) < 1 Or keepform = False Then    '26Apr99 TH Corrected Logic
                 Unload FrmIssue               '24Mar97 KR Added
                 Set FrmIssue = Nothing        '15Nov05 CKJ Belt & Braces: form was not unloaded in spite of the unload proc executing
              End If
           
           If Wspts Then Qty! = dp!(Val(ans$))  '21Apr99 TH

           '07Apr03 TH (PBSv4) Added
           If isPBS() Then
                 If PBSGetBillitem(53) = "X" Then
                       Qty! = dp!(Qty! * negorpos)  '07Apr03 Th (PBSv4) Added
                End If
          End If
   End If   ' 26Jul10 XN If Drug is not in use then skip the issue (RCN P0158 F0023149)

   Heap 2, RobotHeap, "", "", intSuccess    '07Mar04 CKJ added
   SetIssueConfig 0                         '14apr04 CKJ reset for next time

End Sub

Function GetAltLabelContext() As String
'25Jun12 CKJ written       TFS24660
'Issue may set an alternative label context, eg m_AltLabelContext = "LBLALT19"
'This function makes the result visible to the print module

   GetAltLabelContext = m_AltLabelContext
   
End Function

Sub SetAltLabelContext(ByVal AltLabelContext As String)
'25Jun12 CKJ written. Companion to GetAltLabelContext()

   m_AltLabelContext = AltLabelContext
   
End Sub

Sub ListInstructions(Code$, expn$, escaped%)
'18Jan99 EAC written
'21Jan02 TH Now use chr(161) as marker for no inst selected (picked up later)
'22Apr14 XN Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088

Dim rs As ADODB.Recordset
Dim strParam As String
Dim Context As String
Dim iLoop As Integer
Dim LineChosen As Integer
Dim temp As String
Dim iLoopCount As Integer
Dim tempcode As String
Dim codeLength As Integer
Dim i As Integer
Dim exists As Boolean

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "ListInstructions"

   On Error GoTo ErrorHandler
   escaped = False
   Code$ = ""
   expn$ = ""
   LstBoxFrm.Caption = "Select Instruction"
   LstBoxFrm.LstBox.AddItem Space$(6) & TB$ & "<No Instruction>"

   iLoopCount = IIf(ReadLanguage(10, 0) = "044", 2, 3)
   
   'For iLoop = 1 To 2     22Apr14 XN Updated to use local code first, then dss language specific then dss english 89088
   '   Context = ASCContextName("instruct.v4", (iLoop = 1), 0)
   For iLoop = 1 To iLoopCount
      Context = ASCContextName("instruct.v4", (iLoop > 1), Iff(iLoop > 2, 44, 0))
      strParam = gTransport.CreateInputParameterXML("siteid", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("context", trnDataTypeVarChar, 255, Context) & _
                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 10, Null) & _
                  gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, 1)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParam)
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               Do While Not rs.EOF
                  temp$ = RtrimGetField(rs!Value)
                  tempcode$ = RtrimGetField(rs!Code)
                  
                  ' 22Apr14 XN filter out duplicate codes 89088
                  exists = False
                  codeLength = Len(tempcode$ & TB$)
                  If temp$ <> "" Then
                    For i = 1 To LstBoxFrm.LstBox.ListCount
                      If Left$(LstBoxFrm.LstBox.List(i), codeLength) = tempcode$ & TB$ Then
                          exists = True
                          Exit For
                      End If
                    Next i
                  End If
                  
                  If temp$ <> "" And Not exists Then
                     replace temp$, Chr$(LBL_END_LINE), " ", 0
                     temp$ = StripColourInfo$(temp$)
                     LstBoxFrm.LstBox.AddItem tempcode$ & TB$ & temp$
                  End If
                  rs.MoveNext
               Loop
            End If
         End If
      End If
   Next
   
   LstBoxShow
   
   Select Case LstBoxFrm.LstBox.ListIndex
      Case -1
         escaped = True
      Case 0
         'do nothing as code$ ="" & expn$ = "" from above
         Code$ = Chr$(161) '21Jan02 TH Use as marker for no inst
      Case Else
         temp$ = LstBoxFrm.Tag
         replace temp$, TB, Nul, 0
         Code$ = asciiz(temp$)
         
         If LookupHeapId > 0 Then
            Heap 12, LookupHeapId, CStr(gDispSite) & "|" & "instruct.v4" & "|" & Trim$(Code$), "", 0
         End If
         
         GetInsCode Code$, expn$
      End Select

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   Unload LstBoxFrm
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

''Dim loopvar%
''Dim LineChosen%
''Dim temp$                        '28Jul99 AE Dim'd variable
''
''   escaped = False
''   expn$ = ""
''   code$ = ""
''
''   If numofins% = 0 Then
''         GetInsCode "", ""    'Prefills Instruction$ used below
''      End If
''
''   If numofins = 0 Then       'If still empty then abort
''         popmessagecr "Error", "No instructions found to display. Please check with your systems administrator."
''         escaped = True
''         Exit Sub
''      End If
''
''   LstBoxFrm.Caption = "Select Instruction"
''   LstBoxFrm.LstBox.AddItem Space$(6) & TB$ & "<No Instruction>"
''   For loopvar = 0 To numofins
''      If Trim$(Instruction$(loopvar)) <> "" Then
''            code$ = Left$(Instruction$(loopvar), 6)
''            replace code$, "&", Chr$(13), 0
''            replace code$, Chr$(13), "&&", 0
''
''            temp$ = Mid$(Instruction$(loopvar), 7)
''            replace temp$, Chr$(LBL_END_LINE), " ", 0
''            temp$ = StripColourInfo$(temp$)
''            LstBoxFrm.LstBox.AddItem code$ & TB$ & temp$
''         End If
''   Next
''   LstBoxShow
''   LineChosen = LstBoxFrm.LstBox.ListIndex + 1
''   Unload LstBoxFrm
''
''   Select Case LineChosen
''      Case 0
''         escaped = True
''      Case 1
''         'do nothing as code$ ="" & expn$ = "" from above
''         code$ = Chr(161) '21Jan02 TH Use as marker for no inst
''      Case Else
''         expn$ = Mid$(Instruction$(LineChosen - 1), 7)
''         code$ = Left$(Instruction$(LineChosen - 1), 6)
''   End Select

End Sub

Sub ListWarnings(Code$, expn$, escaped%)
'18Jan99 EAC written
'21Jan02 TH Now use chr(161) as marker for no warning selected (picked up later)
'22Apr14 XN Updated to use local code first, then dss language specific then dss english (will filter out duplicate codes) 89088

Dim rs As ADODB.Recordset
Dim strParam As String
Dim Context As String
Dim iLoop As Integer
Dim LineChosen As Integer
Dim temp As String
Dim iLoopCount As Integer
Dim tempcode As String
Dim codeLength As Integer
Dim i As Integer
Dim exists As Boolean

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "ListWarnings"

   On Error GoTo ErrorHandler
   escaped = False
   Code$ = ""
   expn$ = ""
   LstBoxFrm.Caption = "Select Warning"
   LstBoxFrm.LstBox.AddItem Space$(6) & TB$ & "<No Warning>"

   iLoopCount = IIf(ReadLanguage(10, 0) = "044", 2, 3)

   'For iLoop = 1 To 2     22Apr14 XN Updated to use local code first, then dss language specific then dss english 89088
   '  Context = ASCContextName("Warning.v4", (iLoop = 1), 0)
   For iLoop = 1 To iLoopCount
      Context = ASCContextName("Warning.v4", (iLoop > 1), Iff(iLoop > 2, 44, 0))
      strParam = gTransport.CreateInputParameterXML("siteid", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("context", trnDataTypeVarChar, 255, Context) & _
                  gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 10, Null) & _
                  gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, 1)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParam)
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               Do While Not rs.EOF
                  temp$ = RtrimGetField(rs!Value)
                  tempcode$ = RtrimGetField(rs!Code)
                  
                  ' 22Apr14 XN filter out duplicate codes 89088
                  exists = False
                  codeLength = Len(tempcode$ & TB$)
                  If temp$ <> "" Then
                    For i = 1 To LstBoxFrm.LstBox.ListCount
                      If Left$(LstBoxFrm.LstBox.List(i), codeLength) = tempcode$ & TB$ Then
                          exists = True
                          Exit For
                      End If
                    Next i
                  End If
                  
                  If temp$ <> "" And Not exists Then
                     replace temp$, crlf, " ", 0
                     temp$ = StripColourInfo$(temp$)
                     LstBoxFrm.LstBox.AddItem tempcode$ & TB$ & temp$
                  End If
                  rs.MoveNext
               Loop
            End If
         End If
      End If
   Next
   
   LstBoxShow
   
   Select Case LstBoxFrm.LstBox.ListIndex
      Case -1
         escaped = True
      Case 0
         'do nothing as code$ ="" & expn$ = "" from above
         Code$ = Chr$(161) '21Jan02 TH Use as marker for no inst
      Case Else
         temp$ = LstBoxFrm.Tag
         replace temp$, TB, Nul, 0
         Code$ = asciiz(temp$)
         
         If LookupHeapId > 0 Then
            Heap 12, LookupHeapId, CStr(gDispSite) & "|" & "Warning.v4" & "|" & Trim$(Code$), "", 0
         End If

         GetWarCode Code$, expn$
      End Select

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   Unload LstBoxFrm
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

''Dim loopvar%
''Dim temp$, tempcode$
''
''Dim SelectedLine%                              '28Jul99 AE Dim'd variable
''
''   escaped% = False
''   expn$ = ""
''   code$ = ""
''
''   If numofwar% = 0 Then
''         GetWarCode "", ""    'Prefills Warning$ used below
''      End If
''
''   If numofwar% = 0 Then       'If still empty then abort
''         popmessagecr "Error", "No warnings found to display. Please check with your systems administrator."
''         escaped = True
''         Exit Sub
''      End If
''
''   LstBoxFrm.Caption = "Select Warning"
''   LstBoxFrm.LstBox.AddItem Space$(6) & TB$ & "<No Warning> "
''
''   For loopvar = 1 To numofwar%
''      If Trim$(Warning$(loopvar)) <> "" Then
''            tempcode$ = Left$(Warning$(loopvar), 6)
''            'replace code$, "&", Chr$(13), 0
''            'replace code$, Chr$(13), "&&", 0
''            temp$ = Mid$(Warning$(loopvar), 7)
''            replace temp$, Chr$(LBL_END_LINE), " ", 0
''            temp$ = StripColourInfo$(temp$)
''            LstBoxFrm.LstBox.AddItem tempcode$ & TB$ & temp$
''         End If
''   Next
''
''   LstBoxShow
''   SelectedLine% = LstBoxFrm.LstBox.ListIndex + 1
''   Unload LstBoxFrm
''
''   Select Case SelectedLine
''      Case 0
''         escaped = True
''      Case 1
''         'do nothing as code$ = "" and expn$ = "" from above
''         code$ = Chr(161) '21Jan02 TH Use as marker for no inst
''      Case Else
''         expn$ = Mid$(Warning$(SelectedLine% - 1), 7)
''         code$ = Left$(Warning$(SelectedLine% - 1), 6)
''   End Select

End Sub

Sub loadvatrates()
'--------------------------VAT default file-----------------------------------
'17 Jan 92 ASC
'29Dec93 CKJ Added new VAT file
'25Jan94 CKJ Added new items
'16Feb95 CKJ Concatenated

Dim fil%, lin%
Dim strInput As String
Dim pathfile As String
   
   'If fileexists(dispdata$ & "\storevat.def") Then
   '      fil = FreeFile
   '      Open dispdata$ & "\storevat.def" For Input As #fil
   '      Input #fil, TransLogVAT%, OrderLogVAT%, Highfact!, Lowfact!, entercostonreceipt$, tofollow%
   '      For lin = 0 To 9
   '         If EOF(fil) Then Exit For
   '         Line Input #fil, strInput
   '         VAT(lin) = Val(strInput)    ' 1 1.175 etc
   '      Next
   '      If Not EOF(fil) Then Input #fil, UtilOrdNum$, UtilSupplier$, UtilReasonNew$, UtilReasonMod$
   '      Close #fil
   '      TransLogVAT% = (TransLogVAT% <> 0) 'force boolean
   '      OrderLogVAT% = (OrderLogVAT% <> 0)
   '   End If
      
   pathfile = dispdata$ & "\WorkingDefaults.ini"
   OrderLogVAT% = Val(TxtD(pathfile, "", "", "OrderLogVAT", 0))
   TransLogVAT% = Val(TxtD(pathfile, "", "", "TransLogVAT", 0))
   Highfact! = Val(TxtD(pathfile, "", "", "Highfact", 0))
   Lowfact! = Val(TxtD(pathfile, "", "", "Lowfact", 0))
   entercostonreceipt$ = TxtD(pathfile, "", "", "entercostonreceipt", 0)
   tofollow% = Val(TxtD(pathfile, "", "", "tofollow", 0))
   For lin = 0 To 9
      VAT(lin) = Val(TxtD(pathfile, "", "", "VAT(" & Format$(lin) & ")", 0))
   Next
   UtilOrdNum$ = TxtD(pathfile, "", "", "UtilOrdNum", 0)
   UtilSupplier$ = TxtD(pathfile, "", "", "UtilSupplier", 0)
   UtilReasonNew$ = TxtD(pathfile, "", "", "UtilReasonNew", 0)
   UtilReasonMod$ = TxtD(pathfile, "", "", "UtilReasonMod", 0)
   TransLogVAT% = (TransLogVAT% <> 0) 'force boolean
   OrderLogVAT% = (OrderLogVAT% <> 0)
         
End Sub

Function LocalPattern() As String
'06Aug98 CKJ Allow pattern in stkmaint to be zero length. This specifies no checking and all
'            values are allowed. Also changed error msg to len(d.local) instead of fixed at 7
'            This is in preparation for allowing 10 char local codes.
'            Amended so that a switch of dispdata causes the entry to be read again

Static Localpatt$, lastpath$
ReDim lines$(6)
         
Dim tmp$, i%                     '28Jul99 AE Dim'd variable
   'If Localpatt$ = "" Then                              '06Aug98 CKJ removed
   If lastpath$ = "" Or lastpath$ <> dispdata$ Then      '06Aug98 CKJ added
         tmp$ = TxtD(dispdata$ & "\stkmaint.ini", "Data", ",,,,,", "72", 0)
         deflines tmp$, lines$(), ",(*)", 1, i

         'If lines$(6) = "" Then                         '06Aug98 CKJ replaced with block below
         '      popmessagecr "ASCribe", "System Configuration Error:" & cr & "Local code definition missing from StkMaint.ini"
         '   ElseIf Len(lines$(6)) > 7 Then
         '      popmessagecr "ASCribe", "System Configuration Error:" & cr & "Local code definition in StkMaint.ini exceeds 7 characters"
         '   Else
         '      Localpatt$ = lines$(6)
         '   End If

         If Len(lines$(6)) > Len(d.local) Then           '06Aug98 CKJ pattern="" is valid
               popmessagecr "EMIS Health", "System Configuration Error:" & cr & "Local code definition in StkMaint.ini exceeds " & Format$(Len(d.local)) & " characters"
            Else
               Localpatt$ = lines$(6)
               lastpath$ = dispdata$                     '06Aug98 CKJ added
            End If
      End If

   LocalPattern = Localpatt$

End Function

Function LogExtraData() As Integer
'05Sep02 SF added to decide if to write to TranslogExtra (enh#1274)

   
   If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "StoreLabelText", 0)) Then
         LogExtraData = True
      Else
         LogExtraData = False
      End If


End Function

Function LookupPattern() As String
'08Feb99 CFY Written
'31Mar99 CFY Lookup code format is now hardcoded for now but gives option of more flexability
'            in future for now.
'12May99 CFY Re-instated original code until HK can be convinced that they are mis-using this code

ReDim lines$(6)
Dim LookupPatt$, tmp$, i%
         
   If LookupPatt$ = "" Then
         tmp$ = TxtD(dispdata$ & "\stkmaint.ini", "Data", ",,,,,", "1", 0)
         deflines tmp$, lines$(), ",(*)", 1, i
         
         '12May99 CFY Re-instated block
         If lines$(6) = "" Then
               popmessagecr "EMIS Health", "System Configuration Error:" & cr & "ASC Code definition missing from StkMaint.ini"
            ElseIf Len(lines$(6)) > Len(d.Code) Then
               popmessagecr "EMIS Health", "System Configuration Error:" & cr & "ASC Code definition in StkMaint.ini exceeds " & Format$(Len(d.local)) & " characters"
            Else
               LookupPatt$ = lines$(6)
            End If
      End If
                                                                                                                                                                                    
   LookupPattern = LookupPatt$

End Function

Function NSVpattern() As String
'12Aug99 ASC\TH Made popmessage clearer

Static NSVpatt$
ReDim lines$(6)
Dim tmp$, i%
         
   If NSVpatt$ = "" Then
         tmp$ = TxtD(dispdata$ & "\stkmaint.ini", "Data", ",,,,,", "9", 0)
         deflines tmp$, lines$(), ",(*)", 1, i
         If lines$(6) = "" Then
               popmessagecr "EMIS Health", "System Configuration Error:" & cr & "NSV code definition missing from " & dispdata$ & "\StkMaint.ini"     '12Aug99 ASC\TH
            ElseIf Len(lines$(6)) > 7 Then
               popmessagecr "EMIS Health", "System Configuration Error:" & cr & "NSV code definition in " & dispdata$ & "\StkMaint.ini exceeds 7 characters"  '12Aug99 ASC\TH
            Else
               NSVpatt$ = lines$(6)
            End If
      End If

   NSVpattern = NSVpatt$

End Function

''Sub OpenFormulaDatabase()
'''18Jun97 CKJ/KR Moved opened to module level and set here.
''
'''Static opened 18Jun97 CKJ/KR Moved.
''
''   If Not Opened Then
''         Opened = True  '18Jun97 KR
''         Set DbFormula = OpenDatabase(dispdata$ & "\formula.mdb", False, False)
''         Set FormulaTable = DbFormula.OpenTable("Formula")
''         Set StockLvlTable = DbFormula.OpenTable("BatchStockLevel")
''      End If
''
''End Sub

''Sub OpenSupProfileDB(OpenDB%, NoMessages%)
'''30Jun99 CFY Written
'''Opens and closes the supplier profile database
'''11Apr00 TH  Added Parameter to stop messagebox *GST*
''
''Dim msg$
''
''   If OpenDB% And Not SupProfileDBOpen% Then          'Open Database
''         On Error GoTo OpenSupProfileDB_Err
''         Set SupProfileDB = OpenDatabase(dispdata$ & "\supprof.mdb")
''         On Error GoTo 0
''         SupProfileDBOpen% = True
''      End If
''
''   If Not OpenDB% And SupProfileDBOpen% Then          'Close Database
''         SupProfileDB.Close
''         Set SupProfileDB = Nothing
''         SupProfileDBOpen% = False
''      End If
''
''OpenSupProfileDB_Exit:
''   Exit Sub
''
''OpenSupProfileDB_Err:
''   SupProfileDBOpen% = False
''   msg$ = "An error has occured in procedure : OpenSupProfileDB" & crlf & crlf
''   msg$ = msg$ & "Error No. : " & Format$(Err) & crlf
''   msg$ = msg$ & Error$
''   popmessagecr ".", msg$
''   If Not NoMessages% Then popmessagecr ".", msg$   '11Apr00 TH Added  *GST*
''   On Error Resume Next
''   Resume OpenSupProfileDB_Exit
''
''End Sub

'Sub Orderlog(ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, qtyrec$, cost$, supcode$, trantype$, sitepaths, invnum$, VatCode$, ByVal strBatchNumber As String, ByVal strExpiry As String, ByVal strDeliveryNoteReference As String)
Sub Orderlog(ordernum$, SisCode$, UserID$, dateord$, daterec$, qtyord$, qtyrec$, cost$, supcode$, trantype$, sitepaths, invnum$, VatCode$, ByVal strBatchNumber As String, ByVal strExpiry As String, ByVal strDeliveryNoteReference As String, ByVal vstrDateInv As String, ByVal PSORequestID As Long, Optional ByVal EDIOrder As Boolean = False) '02Nov10 AJK F0086901 Added vstrDateInv
'Consider VAT/GST handling;
' If Orderlogvat = T then VAT is definitely not already in the price
'   therefore add VAT if rate > 1.0
' If Orderlogvat = F then VAT is may or may not be included in the price
'   however it will never be added to the d.cost
'   therefore deduct VAT if rate > 1.0
'08Dec05 TH Added two new date fields
'24Oct06 TH Extended Batchnumber
'29Aug08 TH Mod to update Reason Code (F0024092)
'12Oct08 TH Added Stock Value to the transaction (F0031170)
'12Oct08 TH Extended invoice number to 20 chars (F)
'13Oct08 TH Removed new issue unit qty fields as they are not always big enough and can error even though they are not currently used (F0035288)
'05Feb09 TH Ensure stockvalue is only entered for logs with associated products(F0045173)
'26Feb09 TH Added call to order outputinteface (UHB F0032689)
'20Apr09 TH Make debug more specific (F0050755)
'30Sep10 TH Replaced stock and value lookups with the drug actually just looked up (F0096947)
'15Oct10 XN DeliveryNoteReference Reduced down to 10 chars to match db (F0098793) (UMMC FINV)
'19Oct10 XN DeliveryNoteReference Reduced down to 20 chars (F0098793) (UMMC FINV)
'02Nov10 AJK F0086901 Added support for date invoiced
'16Aug11 TH Increased Orderlog DeliveryNoteReferenceto 30 chars(F0084761)
'20Jun13 TH Changed revision level as marker for FM (TFS 65781)
'03Mar14 TH Added PSORequestID param
'10Aug15 TH Prefix decimal fraction under 1 / -1 for qty ordered and qty received with zero (TFS 125871)
'22May17 XN Added GTIN and EDIOrder to orderlogstruct 184323
'22Jan18 DR Bug 201972 - Pharmacy wOrderlog GTIN column needs to be varchar(14) not varchar(13)

Static LastOlogFile$
Dim ologrecno&, OlogFile$, tmp$
Dim vatrate!, X$                                   '28Jul99 AE Dim'd variable
Dim utdDrug As DrugParameters, lngDrugPtr As Long   ' 01Jun02 ALL/ATW
Dim lngReturn    As Long
Dim strSql As String
Dim intQtyOrd As Integer
Dim intQtyRec As Integer
Dim lngQtyOrd As Long
Dim lngQtyRec As Long
Dim dteOrdered As Date
Dim dteReceived As Date
Dim dteInvoiced As Date '02Nov10 AJK F0086901 Added
Dim stockvalue As Single
Dim tempProfile As TSupProfile '9Jun17 XN Added 184323
Dim found As Integer '9Jun17 XN Added 184323

   procname$ = "Orderlog"

   tmp$ = date$

   'olog.revisionlevel = "10"     'SQL '13Oct08 TH Incremented for consolidation build.
   olog.revisionlevel = "A1"     '20Jun13 TH Changed revision level as marker for FM (TFS 65781)
   olog.ordernum = ordernum$
   olog.SisCode = SisCode$
   olog.convfact = ""
   olog.IssueUnits = ""
   olog.dispid = UserID$
   olog.terminal = ASCTerminalName()
   olog.dateord = Left$(Trim$(dateord$), 8)                                                   '    "      so now necessary to parse date out
   olog.dateord = Right$(olog.dateord, 4) & Mid$(olog.dateord, 3, 2) & Left$(olog.dateord, 2)
   If Trim$(dateord$) <> "" Then '08Mar07 TH Added Trim (SC-07-0136)
      If Len(Trim$(dateord$)) > 8 Then
         dteOrdered = CDate(Left$(dateord$, 2) & "/" & Mid$(dateord$, 3, 2) & "/" & Mid$(dateord$, 5, 4) & " " & Mid$(dateord$, 9, 2) & ":" & Mid$(dateord$, 11, 2) & ":" & Mid$(dateord$, 13, 2))
      Else
         dteOrdered = CDate(Left$(dateord$, 2) & "/" & Mid$(dateord$, 3, 2) & "/" & Mid$(dateord$, 5, 4))
      End If
   End If
   olog.Timeord = Mid$(dateord$, 9)
   olog.daterec = Left$(Trim$(daterec$), 8)
   olog.daterec = Right$(olog.daterec, 4) & Mid$(olog.daterec, 3, 2) & Left$(olog.daterec, 2)
   olog.Timerec = Mid$(daterec$, 9)
   If daterec$ <> "" Then
      If Len(Trim$(daterec$)) > 8 Then
         dteReceived = CDate(Left$(daterec$, 2) & "/" & Mid$(daterec$, 3, 2) & "/" & Mid$(daterec$, 5, 4) & " " & Mid$(daterec$, 9, 2) & ":" & Mid$(daterec$, 11, 2) & ":" & Mid$(daterec$, 13, 2))
      Else
         dteReceived = CDate(Left$(daterec$, 2) & "/" & Mid$(daterec$, 3, 2) & "/" & Mid$(daterec$, 5, 4))
      End If
   End If
   '02Nov10 AJK F0086901 START
   If Trim(vstrDateInv) <> "" Then
      olog.DateInv = Left$(Trim$(vstrDateInv), 8)
      olog.DateInv = Right$(olog.DateInv, 4) & Mid$(olog.DateInv, 3, 2) & Left$(olog.DateInv, 2)
      If Len(Trim$(vstrDateInv)) > 8 Then
         dteInvoiced = CDate(Left$(vstrDateInv, 2) & "/" & Mid$(vstrDateInv, 3, 2) & "/" & Mid$(vstrDateInv, 5, 4) & " " & Mid$(vstrDateInv, 9, 2) & ":" & Mid$(vstrDateInv, 11, 2) & ":" & Mid$(vstrDateInv, 13, 2))
      Else
         dteInvoiced = CDate(Left$(vstrDateInv, 2) & "/" & Mid$(vstrDateInv, 3, 2) & "/" & Mid$(vstrDateInv, 5, 4))
      End If
   Else
      dteInvoiced = CDate("30 December 1899")
   End If
   '02Nov10 AJK F0086901 END
   olog.qtyord = qtyord$
   olog.qtyrec = qtyrec$
   vatrate! = VAT(Val(VatCode$))
   If OrderLogVAT = 0 Or vatrate! = 0! Then vatrate! = 1!
   olog.VatCode = VatCode$
   olog.vatrate = Format$(vatrate!)
   If UCase$(trantype$) = "V" Then
      olog.cost = LTrim$(Str$(dp!(Val(cost$)))) 'LTrim$(Str$(dp!(Val(cost$) * vatrate!)))
      olog.CostExVAT = "0" 'LTrim$(Str$(dp!(Val(cost$))))
      olog.VATcost = LTrim$(Str$(dp!(Val(cost$)))) 'LTrim$(Str$(dp!(Val(olog.cost) - Val(olog.CostExVAT))))
   Else
      olog.cost = LTrim$(Str$(dp!(Val(cost$) * vatrate!)))
      olog.CostExVAT = LTrim$(Str$(dp!(Val(cost$))))
      olog.VATcost = LTrim$(Str$(dp!(Val(olog.cost) - Val(olog.CostExVAT))))
   End If
   olog.kind = trantype$
   olog.supcode = supcode$
   olog.site = Format$(sitepaths)
   'olog.BatchNum = ""                'Str*10' new;
   'olog.ExpiryDate = ""              'Str*8 ' new; format is ddmmyyyy
   
   'olog.BatchNum = strBatchNumber               '26Oct06 TH Why not use these ? '
   'olog.ExpiryDate = strExpiry                  '     "
   
   If strBatchNumber = "" And strBatchNumberBatchTracking <> "" Then    'MM-4114
    olog.BatchNum = strBatchNumberBatchTracking
   Else
    olog.BatchNum = strBatchNumber
   End If
   
   If strExpiry = "" And strExpiryDateBatchTracking <> "" Then  'MM-4114
    olog.ExpiryDate = strExpiryDateBatchTracking
   Else
    olog.ExpiryDate = strExpiry
   End If
   
   olog.invnum = invnum$             'Str*12' was also used for returns code & batch num
   olog.Date3 = ""                   'Str*8 ' new
   olog.Time3 = ""                   'Str*6 ' new
   olog.Qty3 = ""                    'Str*13' new
   olog.Info = ""                    'Str*12' new
   olog.LinkedNum = ""               'Str*4 ' new; returns, supp orders & req’s link to another order
   olog.ReasonCode = ""              'Str*4 ' new;
   If UCase$(trantype$) = "O" Or UCase$(trantype$) = "D" Or UCase$(trantype$) = "E" Or UCase$(trantype$) = "A" Then    '29Aug08 TH Added. These are the only two kinds that use reason codes that I can see (F0024092) '21Nov08 TH Added "E" '02Dec08 TH Added "A"
      olog.ReasonCode = invnum$
   End If
''   olog.pad = ""                     'str*17' new; total length is now 256
''   olog.crlf = crlf                  ' new; separated this from the padding

   olog.stocklvl = ""                           '25Jan02 TH Added new stocklevel to orderlog (#53214)
   stockvalue = 0                               '05Feb09 TH Add default value (F0045173)
   If Trim$(SisCode$) <> "" Then                '    "
      utdDrug.SisCode = Trim$(SisCode$)      '    "
      getdrug utdDrug, 0, lngDrugPtr, False    '    "        ' 01Jun02 ALL/ATW
      If lngDrugPtr <> 0 Then                       '    "   ' 01Jun02 ALL/ATW
         'olog.stocklvl = d.stocklvl       '    "
         'olog.convfact = d.convfact      '11Mar05 TH Added for SQL
         'olog.IssueUnits = d.PrintformV  '    "
         olog.stocklvl = utdDrug.stocklvl       '30Sep10 TH Replaced with the drug actually just looked up (F0096947)
         olog.convfact = utdDrug.convfact       '    "
         olog.IssueUnits = utdDrug.PrintformV   '    "
         'intQtyRec = CInt(dp!(Val(qtyrec$) * Val(d.convfact))) '28Sep05 TH What the hell was this for anyway ??
         'intQtyOrd = CInt(dp!(Val(qtyord$) * Val(d.convfact))) '    "      Changed data handling anyway after it blew up in testing
         '13Oct08 TH Removed the following two lines for now as they are not always big enough and can error even though they are not currently used F0035288
         'lngQtyRec = CLng(dp!(Val(qtyrec$) * Val(d.convfact)))
         'lngQtyOrd = CLng(dp!(Val(qtyord$) * Val(d.convfact)))
         If UCase$(trantype$) <> "C" Then
            'stockvalue! = 1! * dp!(((Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost)) + Val(d.lossesgains)) '05Feb09 TH (F0045173) Moved here as this is only relevant for logs concerning products
            stockvalue! = 1! * dp!(((Val(utdDrug.stocklvl) / Val(utdDrug.convfact)) * Val(utdDrug.cost)) + Val(utdDrug.lossesgains)) '05Feb09 TH (F0045173) Moved here as this is only relevant for logs concerning products '30Sep10 TH Replaced with the drug actually just looked up
         End If
      End If
   End If
   
   olog.DeliveryNoteReference = strDeliveryNoteReference
   
   olog.PSORequestID = PSORequestID
   
   ' 22May17 Setting of EDI Barcode and Order 184323
   If UCase$(trantype$) = "R" Then
         olog.GTIN = ""
   ElseIf supcode$ = utdDrug.supcode Then
     olog.GTIN = utdDrug.EDIBarcode
   ElseIf supcode$ <> "" Then
     GetSupProfile SisCode$, supcode$, tempProfile, 0, found
     If found = True Then
        olog.GTIN = tempProfile.EDIBarcode
        Else
            olog.GTIN = ""    '16Jan18 Pharmacy EDI ordering - not writing the correct GTIN code to the wOrderlog file(TFS 200429)
        End If
   End If
   'stockvalue! = 1! * dp!(((Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost)) + Val(d.lossesgains)) '12Oct08 TH Added (F0031170)  '05Feb09 TH Moved Above
  
   '10Aug15 TH Prefix decimal fraction under 1 / -1 with zero (TFS 125871)
   If Left$(olog.qtyord, 1) = "." Then
         If Len("0" & Trim$(olog.qtyord)) < 14 Then olog.qtyord = "0" & olog.qtyord
   ElseIf Left$(olog.qtyord, 2) = "-." Then
         If Len("-0" & Right(Trim$(olog.qtyord), Len(Trim$(olog.qtyord)) - 1)) < 14 Then olog.qtyord = "-0" & Right(olog.qtyord, Len(olog.qtyord) - 1)
   End If
   If Left$(olog.qtyrec, 1) = "." Then
         If Len("0" & Trim$(olog.qtyrec)) < 14 Then olog.qtyrec = "0" & olog.qtyrec
   ElseIf Left$(olog.qtyrec, 2) = "-." Then
         If Len("-0" & Right(Trim$(olog.qtyrec), Len(Trim$(olog.qtyrec)) - 1)) < 14 Then olog.qtyrec = "-0" & Right(olog.qtyrec, Len(olog.qtyrec) - 1)
   End If
      
      
        
   LSet r = olog
         
   With olog
      strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("RevisionLevel", trnDataTypeVarChar, 2, .revisionlevel) & _
               gTransport.CreateInputParameterXML("OrderNum", trnDataTypeVarChar, 10, .ordernum) & _
               gTransport.CreateInputParameterXML("SisCode", trnDataTypeVarChar, 7, .SisCode) & _
               gTransport.CreateInputParameterXML("Convfact", trnDataTypeVarChar, 5, .convfact) & _
               gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, .IssueUnits) & _
               gTransport.CreateInputParameterXML("Dispid", trnDataTypeVarChar, 3, .dispid) & _
               gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, .terminal) & _
               gTransport.CreateInputParameterXML("DateOrd", trnDataTypeVarChar, 8, .dateord) & _
               gTransport.CreateInputParameterXML("TimeOrd", trnDataTypeVarChar, 6, .Timeord) & _
               gTransport.CreateInputParameterXML("DateRec", trnDataTypeVarChar, 8, .daterec) & _
               gTransport.CreateInputParameterXML("TimeRec", trnDataTypeVarChar, 6, .Timerec) & _
               gTransport.CreateInputParameterXML("QtyOrd", trnDataTypeVarChar, 13, .qtyord) & _
               gTransport.CreateInputParameterXML("QtyRec", trnDataTypeVarChar, 13, .qtyrec) & _
               gTransport.CreateInputParameterXML("Cost", trnDataTypeVarChar, 13, .cost) & _
               gTransport.CreateInputParameterXML("CostExVat", trnDataTypeVarChar, 13, .CostExVAT) & _
               gTransport.CreateInputParameterXML("VatCost", trnDataTypeVarChar, 13, .VATcost) & _
               gTransport.CreateInputParameterXML("VatCode", trnDataTypeVarChar, 1, .VatCode) & _
               gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 5, .vatrate) & _
               gTransport.CreateInputParameterXML("Kind", trnDataTypeVarChar, 1, .kind) & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, .supcode) & _
               gTransport.CreateInputParameterXML("site", trnDataTypeVarChar, 3, .site) & _
               gTransport.CreateInputParameterXML("BatchNum", trnDataTypeVarChar, 25, .BatchNum) & _
               gTransport.CreateInputParameterXML("ExpiryDate", trnDataTypeVarChar, 8, .ExpiryDate) & _
               gTransport.CreateInputParameterXML("InvNum", trnDataTypeVarChar, 20, .invnum)

      '02Sep10 TH Added DeliveryNoteReference (UMMC FINV) (F0054531)
      strSql = strSql & _
               gTransport.CreateInputParameterXML("Date3", trnDataTypeVarChar, 8, .Date3) & _
               gTransport.CreateInputParameterXML("Time3", trnDataTypeVarChar, 6, .Time3) & _
               gTransport.CreateInputParameterXML("Qty3", trnDataTypeVarChar, 13, .Qty3) & _
               gTransport.CreateInputParameterXML("Info", trnDataTypeVarChar, 12, .Info) & _
               gTransport.CreateInputParameterXML("LinkedNum", trnDataTypeVarChar, 4, .LinkedNum) & _
               gTransport.CreateInputParameterXML("ReasonCode", trnDataTypeVarChar, 4, .ReasonCode) & _
               gTransport.CreateInputParameterXML("StockLvl", trnDataTypeVarChar, 9, .stocklvl) & _
               gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User) & _
               gTransport.CreateInputParameterXML("DateOrdered", trnDataTypeDateTime, 8, dteOrdered) & _
               gTransport.CreateInputParameterXML("DateReceived", trnDataTypeDateTime, 8, dteReceived) & _
               gTransport.CreateInputParameterXML("StockValue", trnDataTypeFloat, 8, stockvalue!) & _
               gTransport.CreateInputParameterXML("DeliveryNoteReference", trnDataTypeVarChar, 30, .DeliveryNoteReference)   '16Aug11 TH Extended to 30'19Oct10 XN Increased size to 20chars (F0098793) (UMMC FINV) '15Oct10 XN Reduced down to 10 chars to match db (F0098793) (UMMC FINV)
      strSql = strSql & _
               gTransport.CreateInputParameterXML("DateInvoiced", trnDataTypeDateTime, 8, dteInvoiced)  '02Nov10 AJK F0086901 Added
      '14May12 TH Added Contract Information (TFS 30860)
      strSql = strSql & _
               gTransport.CreateInputParameterXML("ContractNumber", trnDataTypeVarChar, 10, m_ContractNumber) & _
               gTransport.CreateInputParameterXML("ContractPrice", trnDataTypeVarChar, 9, m_ContractPrice) & _
               gTransport.CreateInputParameterXML("Contract", trnDataTypeBit, 1, m_Contract) & _
               gTransport.CreateInputParameterXML("PSORequestID", trnDataTypeint, 4, .PSORequestID) & _
               gTransport.CreateInputParameterXML("GTIN", trnDataTypeVarChar, 14, .GTIN)
      If UCase$(trantype$) = "R" Then
         strSql = strSql & gTransport.CreateInputParameterXML("EDIOrder", trnDataTypeBit, 1, Null)
      Else
         strSql = strSql & gTransport.CreateInputParameterXML("EDIOrder", trnDataTypeBit, 1, EDIOrder)
      End If
   End With
   
   lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WOrderlog", strSql)
   
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "GenericInterface", "N", "OrderInterface", 0)) Then OrderOutput olog, lngReturn, False '26Feb09 TH Added (UHB F0032689)
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "GenericInterface", "N", "PSOOrderInterface", 0)) Then OrderOutput olog, lngReturn, True '26Feb09 TH Added (UHB F0032689)

   'If InStr(UCase$(Command$), "/O") Then
   If InStr(UCase$(Command$), "/ORDERLOGDEBUG") Then '20Apr09 TH Altered to shield more effectively (F0050755)
      X$ = " ordernum      " & TB & olog.ordernum & cr
      X$ = X$ & " siscode" & TB & olog.SisCode & cr
      X$ = X$ & " dispid" & TB & olog.dispid & cr
      X$ = X$ & " dateord" & TB & olog.dateord & cr
      X$ = X$ & " daterec" & TB & olog.daterec & cr
      X$ = X$ & " qtyord" & TB & olog.qtyord & cr
      X$ = X$ & " qtyrec" & TB & olog.qtyrec & cr
      X$ = X$ & " cost" & TB & olog.cost & cr
      X$ = X$ & " kind" & TB & olog.kind & cr
      X$ = X$ & " supcode" & TB & olog.supcode & cr
      X$ = X$ & " site" & TB & olog.site & cr
      X$ = X$ & " invnum" & TB & olog.invnum & cr
      X$ = X$ & " dateinv" & TB & olog.DateInv & cr '02Nov10 AJK F0086901 Added
      popmessagecr "ORDERLOG " & dispdata$, X$
   End If

   If InStr(olog.qtyord, "E") Or InStr(olog.qtyrec, "E") Or InStr(olog.cost, "E") Then  '12Sep95 CKJ E# trap
      LSet r = olog
      WriteLog dispdata$ & "\ologenum.log", 0, "", "!" + Left$(r.record, Len(olog)) + "!" + qtyord$ + "!" + qtyrec$ + "!" + Str$(Val(cost$) * vatrate!) + "!"
   End If

End Sub

Sub Parsebnfcode(bnf$)
'-----------------------------------------------------------------------------
'16Aug93 CKJ Written
'Takes bnfcode as typed and parses on dots. Single digits become 0 prefixed.
' 1.2.3  => 01.02.03
' 1.12.3 => 01.12.03
' but longer entries remain untouched eg 123. 456.2 => 123.456.02
'-----------------------------------------------------------------------------

ReDim param(10) As String
Dim linetoparse$, linelen%, isin%, numargs%, count%, ch%

   linetoparse$ = Trim$(bnf$)
   linelen = Len(linetoparse$)
   isin = False
   numargs = 0
                                ' parse line into array
   For count = 1 To linelen
       ch = Asc(Mid$(linetoparse$, count))
       If ch = 46 Then    '.'
            isin = False
         Else
            If Not isin Then
                  numargs = numargs + 1
                  If numargs = 10 Then      ' param(10) contains the remainder
                        param(numargs) = Mid$(linetoparse$, count)
                        Exit For
                     End If
                  isin = True
               End If
            param(numargs) = param(numargs) + Chr$(ch)
         End If
   Next             '14Feb95 CKJ removed count

   bnf$ = ""                    ' use parsed array
   For count = 1 To numargs
      param(count) = Trim$(param(count))
      If Len(param(count)) = 1 Then bnf$ = bnf$ + "0"         ' add leading 0
      bnf$ = bnf$ + param(count)                              ' then digit(s)
      If count < numargs Then bnf$ = bnf$ + "."               ' and a dot
   Next
   Erase param

End Sub

Sub ParseIssueQty(IssueQty$)
'23Dec97 EAC written
'30Dec97 ASC checked and amended as commented
'02Feb98 EAC Changed mult% to mult$ to handle fractions properly
'06Nov14 TH Added checks to prevent issue/rtn > 500,000 - warn user and return no qty (TFS 32576)
'08May17 TH  Fixed above change to make sure this routine supports fractions again -set ch as single (TFS 183532)

Dim xposn%, digits%
'Dim mult&, ch& '30Dec97 ASC
Dim mult$, ch!  '30Dec97 ASC 02Feb98 EAC changed mult% to mult$ '06Nov14 TH Change ch to long '17May17 TH Change back to single

Dim remaind$
    
   Select Case Left$(IssueQty$, 1)
      Case "0" To "9": digits = True
      Case Else:       digits = False
   End Select
    
   If digits Then           '[0]-[255] [1x1]-[32767x255] [80x-]
      mult$ = "1"          '15Jun95 CKJ added &
      remaind$ = IssueQty$
      xposn = InStr(UCase$(IssueQty$), "X")
      If xposn = 0 Then xposn = InStr(IssueQty$, "*")
      If xposn Then
          mult$ = Left$(IssueQty$, xposn - 1)
          remaind$ = Trim$(Mid$(IssueQty$, xposn + 1))
          'If Val(mult$) < 0 Or Val(mult$) > 32767 Then digits = False
          If Val(mult$) < 0 Then digits = False '06Nov14 TH Altered - should now be caught below with proper msg
      End If
      If digits Then
         Select Case Left$(remaind$, 1)
             Case "0" To "9"
                If (Val(remaind$)) < 500001 Then
                   ch! = Val(remaind$)
                   If ch! < 0 Then
                       digits = False
                   Else
                       'If Trim(remaind$) <> Trim(Str$(ch!)) Then digits = False
                       If Trim$(remaind$) <> Format$(ch!) Then digits = False
                   End If
                End If
             Case Else
                 digits = False
         End Select
      End If
   End If
    
   If digits Then
      'Issue qty check here
      If ((Val(remaind$)) > 500000) Or ((ch! * Val(mult$)) > 500000) Then
         popmessagecr "!", "Cannot Issue or return more than 500,000 units"
         IssueQty$ = ""
      Else
         IssueQty$ = Trim$(Str$(ch! * Val(mult$)))
      End If
   Else
       IssueQty$ = ""
   End If

End Sub

Sub poundsandpence(X$, fivespaces)
'-----------------------------------------------------------------------------
'fivespaces = true  printout will be floating dec point within five cols
'fivespaces = false printout will be 7 cols wide with decimal point held
'             in fifth column until >œ9999
'17Jan91 ASC Now prints in pounds and pence all the time
'16Mar94 CKJ Changed x! to x#
' 4Feb96 CKJ Changed x# to v#
'29Dec97 EAC PoundsAndPence: change formatting of zeros
'15May01 JKU/CKJ The function was returning .245 as .24 due to precision handling. Now sorted.
'-----------------------------------------------------------------------------
Dim v#

   v# = Val(X$)
   'v# = (Int((v# * 100) + .5)) / 100   '15May01 JKU/CKJ Removed
   v# = (v# * 100) + 0.5                '15May01 JKU/CKJ Added
   v# = (Int(v#)) / 100                 '15May01 JKU/CKJ Added

   X$ = Trim$(LTrim$(Str$(v#)))
   If v# < 1 Then
         X$ = " 0" + X$
      ElseIf v# < 10 Then
         X$ = " " + X$
      End If
   If Not fivespaces Then
         If v# < 100 Then X$ = " " + X$
         If v# < 1000 Then X$ = " " + X$
         If v# < 10000 Then X$ = " " + X$
      End If
   If Mid$(X$, Len(X$), 1) = "." Then X$ = X$ + "0"
   If Mid$(X$, Len(X$) - 1, 1) = "." Then X$ = X$ + "0"
   If InStr(X$, ".") = 0 Then X$ = X$ + ".00"
   If fivespaces Then
         X$ = Left$(X$ + "     ", 5)
      End If
   If v# < 0.01 Then X$ = "< .01"
   If v# = 0 Then X$ = " 0.00"                          '29Dec97 EAC added '.00'
   If v# < 0.01 And Not fivespaces Then X$ = "   < .01"
   If v# = 0 And Not fivespaces Then X$ = "    0.00"    '29Dec97 EAC added '.00'
   If v# > 99999 And fivespaces Then
         X$ = "> 99k"  ' 19Apr92 CKJ was "TooHi"
      ElseIf v# > 99999 Then
         X$ = LTrim$(Str$(v#))
      End If
End Sub

Sub PutCustOrdNo(ByVal sCustOrdNo As String)
'18Apr00 CFY Written
'            Stores the current customer order number in a module level variable for later retrieval

   msCustOrdNo = sCustOrdNo
   
End Sub

Sub putdrug(d As DrugParameters)
'------------Puts a drug record on disc and unlocks it------------------------
'18Aug93 CKJ We need to be able to unlock a drug without writing back to it.
'            However since space is crucial in some progs, this approach has
'            been used even though it does not conform to company style.
'            To unlock without writing call    PutDrug d,-F
'15Mar01 TH  Added extra check to ensure profile is put back to correct drug
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting.
'            Putdrug is disabled so that no updates can occur in the dispensary caused by ward prescribing
'01Jun02 ALL/ATW 'f' parameter renamed to 'i_lngPointer'
'09May05 CKJ Calls PutProductNL to do the writing. i_lngPointer As Long removed as the keys are part of drugparameters
'            No locking is now done here, as this is handled outside.
'03Aug10 XN  Add check to see if in trasaction before doing rollback

Dim SupProfile As TSupProfile
Dim success%
Dim blnNotintransaction As Boolean
   
''   If siteinfo$("FormularyEXT", "") <> "" Then                               '09Apr01 CKJ Formulary site is defined
''         popmessagecr ".", "Prescribing account cannot update the Product File, request ignored"
''         Exit Sub                                                            '   "        <===== WAY OUT
''      End If

   'If we are not using the primary suppplier then write the profile fields to the SupProfile record,
   'load the primary supplier profile and populate the d structure before the save.
'SQL Now this should all be handled in PutProductNL !!!!!!!!
'''   If Not d.PrimarySup Then                        'SQL Replaced
'''   'If Trim$(AlternativeSupplier$) <> "" Then      '  "
'''         DrugToSupProfile d, SupProfile
'''         SupProfile.supcode = AlternativeSupplier$
'''         PutSupProfile SupProfile, success%
'''         'If Trim$(PrimarySupProfile.supcode) <> Trim$(AlternativeSupplier$) Then           '14Sep99 CFY Added
'''         If Trim$(UCase$(PrimarySupProfile.SisCode)) = Trim$(UCase$(d.SisCode)) And Trim$(PrimarySupProfile.supcode) <> Trim$(AlternativeSupplier$) Then  '15Mar01 TH Added extra check to ensure profile is put back to correct drug
'''              SupProfileToDrug d, PrimarySupProfile
'''            End If
'''      End If
   
''   Select Case i_lngPointer
''      Case Is > 0
''         LSet r = d
''         PutRecordL r, i_lngPointer, getdchan, Len(d)            ' 01Jun02 ALL/ATW Parentheses removed
''      Case Is < 0
''         '08Feb96 EAC Use new (un)lockrecord
''         UnlockRecord getdchan, -i_lngPointer, Len(d)
''      End Select
   
   If d.productstockID = 0 Then
      blnNotintransaction = True 'There should be no 'lock' on a new product
      
   Else
      blnNotintransaction = False
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
         If Not TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then gTransportConnectionExecute "begin Transaction"  '10Aug12 CKJ
      End If
   End If
   '22Feb08 TH Added (F0015066)
   If Trim$(m_DefaultSupplierProfileNSV) <> "" Then
      'We are using the default supplier out of context, therefore we need to save
      'the original supplier profile fields
      If d.SisCode = m_DefaultSupplierProfileNSV Then 'Extra check
         d.contno = m_strContNo
         d.contprice = m_strContprice
         d.SuppRefno = m_strSuppRefno
      End If
      m_DefaultSupplierProfileNSV = "" 'Clear the flag
   End If
   '--------------
   success = PutProductNL(d)
   'commit or rollback on the basis of success
   
      
   If Not blnNotintransaction Then   'New product - we dont have any transactions open here (hopefully)
      If success Then
         gTransportConnectionExecute "Commit Transaction"       '10Aug12 CKJ
      Else
      '???/what do we do here ? Hmmm
         MsgBox "Could not save changes to product " & d.SisCode
         WriteLog dispdata$ & "\locking.txt", SiteNumber, UserID$, "Could not save changes to product " & d.SisCode

                 ' 03Aug10 XN Add check to see if in trasaction before doing rollback
         If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "RollBack Transaction"      '10Aug12 CKJ
      End If
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then TableRowUnLock "ProductStock", d.productstockID, g_SessionID

   End If
   
   'If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLocking", 0)) Then TableRowUnLock "ProductStock", d.ProductStockID, g_SessionID
   
   'Set the drug structure to the state it was when passed into this procedure
   'SQL Frankly my Dear we no longer give a damn !!!
'''   If Trim$(AlternativeSupplier$) <> "" Then
'''         SupProfileToDrug d, SupProfile
'''         d.supcode = PrimarySupProfile.supcode
'''      End If
         
End Sub

''Sub PutDrugPK(Dkin As DrugKinparam)
''
'''Save the kinetics parameters to the DrugPK.mdb
'''08Jul99 AE  Written
'''02Mar00 AE  Added field absorbtion time
''
''Dim db As Database, ds As Dynaset, SQL$
''
''   SQL$ = "SELECT * FROM PkRegimens WHERE SisCode = """ & d.SisCode & """ And RegimenNo = " & Format$(Dkin.RegNum)
''   Set db = OpenDatabase(dispdata & "\DrugPK.mdb")
''   Set ds = db.CreateDynaset(SQL$, 1)        '-mode 1: deny write access to all other processes
''
''   If ds.EOF Then
''         ds.AddNew
''      Else
''         ds.Edit
''      End If
''   ds!SisCode = d.SisCode
''   ds!RegimenNo = Dkin.RegNum
''   ds!RegimenDesc = Dkin.Description
''   ds!SelectionParameters = Dkin.Selection
''   ds!Type = Dkin.Type
''   ds!MinDoseIncrement = Dkin.MinDosInc
''   ds!MaxAreaUnderCurve = Dkin.MaxAUC
''   ds!AUCTimeSpan = Dkin.AUCTime
''   ds!MaxPeak = Dkin.MaxPK
''   ds!MinTherBound = Dkin.LowBound
''   ds!MaxTherBound = Dkin.HighBound
''   ds!MinInterval = Dkin.MinInt
''   ds!VolumeofDistribution = Dkin.VolofDist
''   ds!SaltFactor = Dkin.SaltFact
''   ds!Bioavailability = Dkin.bioav
''   ds!AbsorbtionRateConst = Dkin.absk
''   ds!AbsorbtionTime = Dkin.Abstime                                                 '02Mar00 AE  Added absorbtion time
''   ds!LastModifiedBy = UserID$
''   ds!LastModifiedLocation = TerminalName$ & " on site " & Format$(SiteNumber)
''   ds!LastModifiedDateTime = Format$(Now, "dd/mm/yyyy HH:mm")
''   ds.Update
''
''   Set ds = Nothing
''   Set db = Nothing
''
''End Sub

Sub PutPickNo(strPickNo As String)
'16May04 TH Written

   m_strPickNo = Trim$(Left$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "", "PickTickNoPrefix", 0) & "   ", 3)) & Trim$(strPickNo)

End Sub

Sub PutSupProfile(SupProfile As TSupProfile, success%)
'''30Jun99 CFY written
'''Writes a supplier profile back to the database. Returns success% dependant upon whether or not the
'''save was successful.
'''11Apr00 TH Added NoMessages for genfin & reporter "silent running"
'''29May01 TH Now reads supplier reference no from heap, as was getting
'''           deleted each time due to not being cast into drug structure (#52439)
''
''Dim ProfileDyn As Dynaset
''Dim dynopen%
''Dim msg$, SQL$
''Dim temp$   '20May01 TH Added
''
''   success% = True
''
''   'check siscode and supcode here!!!!!!!
''
''   'Check if this is an add or an edit.
''   SQL$ = "SELECT * FROM profile WHERE nsvcode = " & Chr$(39) & SupProfile.SisCode & Chr$(39)
''   SQL$ = SQL$ & " AND supcode = " & Chr$(39) & SupProfile.supcode & Chr$(39)
''   On Error GoTo PutSupProfile_Err
''   Set ProfileDyn = SupProfileDB.CreateDynaset(SQL$)
''   dynopen = True
''
''   'Check if this is an add or edit.
''   If Not ProfileDyn.EOF Then
''         ProfileDyn.Edit
''      Else
''         ProfileDyn.AddNew
''         ProfileDyn!NSVCode = SupProfile.SisCode
''         ProfileDyn!supcode = SupProfile.supcode
''      End If
''
''   ProfileDyn!contno = SupProfile.contno
''   ProfileDyn!reorderpcksize = SupProfile.reorderpcksize
''   ProfileDyn!reorderlvl = SupProfile.reorderlvl
''   ProfileDyn!reorderqty = SupProfile.reorderqty
''   ProfileDyn!sislistprice = SupProfile.sislistprice
''   ProfileDyn!contprice = SupProfile.contprice
''   ProfileDyn!leadtime = SupProfile.leadtime
''   ProfileDyn!lastreconcileprice = SupProfile.lastreconcileprice
''   ProfileDyn!tradename = SupProfile.tradename
''
''   '29May01 TH Check heap - if in stores then this will be cached with the supplier profile,if stkmaint will be empty anyway
''   'ProfileDyn!SuppRefNo = SupProfile.SuppRefNo
''   Heap 11, gPRNheapID, "sRefno", temp$, 0            '29May01 TH This is really a way to get around the fact
''   If Trim$(temp$) <> "" Then                         '           that this field isnt cached as part of the drug
''         ProfileDyn!SuppRefno = temp$                 '           structure. It may seem a little adhoc as it evolved
''      Else                                            '           from an attempt to expose the field for printing.
''         ProfileDyn!SuppRefno = SupProfile.SuppRefno
''      End If                                          '           Please feel free to alter if there is a better way !
''   ProfileDyn!AltBarCode = SupProfile.AltBarCode
''
''   ProfileDyn!vatrate = SupProfile.vatrate '10Feb00 TH *GST*
''   ProfileDyn.Update
''
''PutSupProfile_Exit:
''   On Error Resume Next
''   If dynopen% Then
''         ProfileDyn.Close
''         Set ProfileDyn = Nothing
''      End If
''   On Error GoTo 0
''   Exit Sub
''
''PutSupProfile_Err:
''   '!!! Fatal error message
''   '!!! Check for corrupt database here.
''   success% = False
''   msg$ = "An error has occured in procedure : GetSupProfile" & crlf & crlf
''   msg$ = msg$ & "Error No. : " & Format$(Err) & crlf
''   msg$ = msg$ & Error$
''   popmessagecr ".", msg$
''   Resume PutSupProfile_Exit

Dim strParam As String
Dim lngResult As Long
Dim blnInsert As Boolean

   If SupProfile.WSupplierProfileID <= 0 Then blnInsert = True
'NOT updated - currently held in SiteProductData
'         & gTransport.CreateInputParameterXML("LabelInIssueUnits", trnDataTypeBit, 1, d.LabelInIssueUnits) _
'         & gTransport.CreateInputParameterXML("CanUseSpoon", trnDataTypeBit, 1, d.CanUseSpoon)
'12Oct06 TH Removed
'02Nov10 TH Extended supprefno from 20 to 36 chrs (UMMC PRF) (F0094388/RCN545)
'& gTransport.CreateInputParameterXML("PrimarySup", trnDataTypeBit, 1, 0) _

      'The following are now removed to the supplier profile table - not stored any longer in the ProductStock table
      strParam = "" _
         & gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, SupProfile.SisCode) _
         & gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, SupProfile.supcode) _
         & gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, SupProfile.contno) _
         & gTransport.CreateInputParameterXML("ReorderPckSize", trnDataTypeVarChar, 5, SupProfile.reorderpcksize) _
         & gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, SupProfile.sislistprice) _
         & gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, SupProfile.contprice)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, SupProfile.LeadTime) _
         & gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, SupProfile.lastreconcileprice) _
         & gTransport.CreateInputParameterXML("SupplierTradename", trnDataTypeVarChar, 30, SupProfile.SupplierTradeName) _
         & gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 36, SupProfile.SuppRefno) _
         & gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, SupProfile.vatrate)
      
      If blnInsert Then
         'insert
         strParam = strParam & gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
         lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strParam)
         d.WSupplierProfileID = lngResult
      Else
         'update
         strParam = gTransport.CreateInputParameterXML("WSupplierProfileID", trnDataTypeint, 4, SupProfile.WSupplierProfileID) & strParam
         lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WSupplierProfile", strParam)
      End If
      success = True    'if no error

End Sub

'Sub ReadWholeWSL(ByVal wardcode As String, NSVcodes As String, success As Integer)
''09Apr01 CKJ Derived from onwsl
''            Returns a comma separated list of NSVcodes and success=True/False
''            List contains a single comma even if no items were found or an error ocurred. This is deliberate.
''19Feb15 TH  Removed after wsl review as this now seems deprecated (TFS 109032)
'
'
'Dim stocklistdb$, msg$
'Dim strParams As String
'Dim rsWardStock As ADODB.Recordset
'
'   success = False
'   NSVcodes$ = ","
'
'   On Error GoTo ReadWholeWSL_Error
'   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'               gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(wardcode))
'   Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListReadWholeWSL", strParams)
'
'   If rsWardStock.RecordCount > 0 Then
'      Do While Not rsWardStock.EOF
'         NSVcodes$ = NSVcodes$ & GetField(rsWardStock!NSVCode) & ","
'         rsWardStock.MoveNext
'      Loop
'   End If
'   success = True
'
'
'ReadWholeWSL_Exit:
'   On Error Resume Next
'   rsWardStock.Close
'   Set rsWardStock = Nothing
'   On Error GoTo 0
'Exit Sub
'
'ReadWholeWSL_Error:
'   msg$ = "The following error has occured when trying" & crlf
'   msg$ = msg$ & "to access the ward stocklist database (wslist.mdb) :"
'   msg$ = msg$ & Error$ & "." & crlf & "Please contact your system administrator."
'   popmessagecr "Error" & Str$(Err), msg$
'Resume ReadWholeWSL_Exit
'
'End Sub

''Sub savenod(nod As Long)
'''28Jul99 AE Dim'd variable, removed numofdrugs$
'''01Jun02 ALL/ATW nod changed to long
''
''Dim fil%              '28Jul99 AE Dim'd variable
''
''   fil = FreeFile
'''   numofdrugs$ = Str$(nod%)         '28Jul99 AE numofdrug$ not referenced anywhere else
''   Open dispdata$ & "\NOD" For Output As #fil Len = 16
''   Write #fil, nod&   '01Jun02 ALL/ATW
''   Close #fil
''
''End Sub

Sub SelectBNFSection()
'10Feb99 ASC Taken from FindrDrug
'14Feb03 CKJ Removed params (drug$, index$) - pointless as never used
'08oct08 CKJ Now uses ordercatalogue instead of files on disk

'Dim X%, bnfchan%, num%, count%, lin1$, lin2$                                  '28Jul99 AE Dim'd variable
Dim strParameters As String
Dim rsLookups     As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strRScode     As String
Dim depth         As Integer
Dim iLoop         As Integer

Const ErrSource   As String = "SelectBNFsection"
   
   On Error GoTo ErrorHandler

   Finddrug.lstDrugs.Visible = False
   Finddrug.txtDrugsHdr.Visible = False               '14feb03 CKJ added
   Finddrug.lstBNFchap.Visible = True
   Finddrug.lstBNFchap.tabstop = True
   Finddrug.lstBNFsect.Visible = True
   Finddrug.lstBNFsect.tabstop = True
   
   For iLoop = 0 To 3
      Finddrug.lblDrugInfo(iLoop).Visible = False
   Next

   emptymsg$ = "No products found in this BNF section"
'   If fileexists(dispdata$ & "\bnfchap.dat") And fileexists(dispdata$ & "\bnfsect.dat") Then
'         bnfchan = FreeFile
'         Open dispdata$ & "\bnfchap.dat" For Input As #bnfchan
'         Input #bnfchan, num                   '20Jan95 CKJ
'         For count = 1 To num
'            Input #bnfchan, lin1$, lin2$
'            If Len(Trim$(lin1$)) Then Finddrug.lstBNFchap.AddItem lin1$ & "  " & lin2$
'         Next
'         Close bnfchan
'
'         bnfchan = FreeFile
'         Open dispdata$ & "\bnfsect.dat" For Input As #bnfchan
'         Input #bnfchan, num                   '20Jan95 CKJ
'         For count = 1 To num
'            Input #bnfchan, lin1$, lin2$
'            If Len(Trim$(lin1$)) Then
'                  Finddrug.lstBNFsectMaster.AddItem lin1$ & "  " & lin2$
'                  Finddrug.lstBNFsectMaster.ItemData(Finddrug.lstBNFsectMaster.NewIndex) = Int(Val(lin1$))
'               End If
'         Next
'         Close bnfchan
'      End If


   ReDim TabStops(1) As Long
   TabStops(1) = 37
   ListBoxTextBoxSetTabs Finddrug.lstBNFsect, 0, TabStops()
   ListBoxTextBoxSetTabs Finddrug.lstBNFsect, 1, TabStops()
               
   depth = TxtD(dispdata$ & "\stkmaint.ini", "Display", Format$(depth), "BNFlevels", 0)
   Select Case depth
      Case Is < 1, Is > 4: depth = 4
      End Select
      
   strParameters = gTransport.CreateInputParameterXML("Depth", trnDataTypeint, 4, depth)
   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pOrderCatalogueSelectForPharmacyBNF", strParameters)
   
   If Not rsLookups.EOF Then
      rsLookups.MoveFirst
      Do While Not rsLookups.EOF
         strRScode = GetField(rsLookups!Code)
         
         If Len(strRScode) = 2 Then
            Finddrug.lstBNFchap.AddItem strRScode & "  " & Trim$(GetField(rsLookups!Value))
         Else
            Finddrug.lstBNFsectMaster.AddItem strRScode & TB & Trim$(GetField(rsLookups!Value))
            Finddrug.lstBNFsectMaster.ItemData(Finddrug.lstBNFsectMaster.NewIndex) = Int(Val(strRScode))
         End If

         rsLookups.MoveNext
      Loop
   End If

Cleanup:
   On Error Resume Next
   rsLookups.Close
   Set rsLookups = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub

Sub setbatchnum(batchnumber As String)
   '02Jun00 JN Added
   SubPatBatchNum$ = batchnumber
End Sub

Sub setexpirydate(expirydat As String)
'01Oct02 TH Added write to 'extra' variable

   '02Jun00 JN Added
   'SubPatExpiry$ = Format$(expirydat, "ddmmyyyy")
   parsedate expirydat, SubPatExpiry$, "ddmmyyyy", False    '23Jan01 JN amended for international date compliance reasons
   m_strSubPatExpiryTime = expirydat        '01Oct02 TH Added
End Sub

Sub SetFindDrugLowPassLevel(blnLowPassLevel As Integer)
'16May04 TH Added (UMMC Pricehide)
m_blnLowPassLevel = blnLowPassLevel
End Sub

Sub SetIssueConfig(ByVal Action As Integer)
'14Apr04 CKJ Written
'            Allows behaviour of the issue form to be controlled from the main app
'            without adding all possible actions inside the issue form itself.
'
'            Action  Return
'               0      F     reset to default state - no bag label printing
'               1      F     set F7 Bag label to 1 deferred print, 2 immediate print
'               2      F     set F7 Bag label to 2 immediate print
'
'            Bag labels may be available or may not be handled at all in the current module
'            The default is no handling. If handling is available then two modes may operate;
'            [F7] to print instantly via a callback, or
'            enter number of labels in text box ([F7] increments) then handle after form is hidden

   Select Case Action
      Case 0, 1, 2
         m_intBagLabels = Action                                  'set/reset F7 Bag Label handling
      End Select

End Sub

Sub SplitFile(RTFTxt$, PgHdr$, PgItem$, PgEnd$)
'14Sep98 CFY Written
'Description: Receives the RTF file in the RTFTxt$ and splits it into components of
'             Header, Item and end using [DetailStart] and [DetailEnd] to denote the sections.
'13Jan99 CFY Moved from ipdlist.bas to enable wider use.

Dim HdrEnd%, DetStart%, DetEnd%, PgEndStart%

   HdrEnd% = InStr(1, RTFTxt$, "[DetailStart]", 1) - 1
   If HdrEnd% <> 0 Then
         PgHdr$ = Left$(RTFTxt$, HdrEnd%)
         DetStart% = HdrEnd% + Len("[DetailStart]") + 1
         DetEnd% = InStr(1, RTFTxt$, "[DetailEnd]", 1) - 1
         If DetEnd% <> 0 Then
               PgItem$ = Mid$(RTFTxt$, DetStart%, DetEnd% - DetStart%)
               PgEndStart% = DetEnd% + Len("[DetailEnd]") + 1
               PgEnd$ = Mid$(RTFTxt$, PgEndStart%)
            Else
               popmessagecr "!", "Element [DetailEnd] not found in rtf layout"
            End If
      Else
         popmessagecr "!", "Element [DetailStart] not found in rtf layout"
      End If

End Sub

Sub StoresValue(Action%, Value%)
'28Jul99 AE Written
'Holds the value of the Stores parameter to findrdrug.  Needed because FillDrugList needs
'to know its value, but is also called from FindDrug.frm, which has no knowledge of the
'value of Stores.

'Action: 0 - Return Stores in Value
'        1 - Set Stores to equal Value%

Static Stores%

   Select Case Action
      Case 0: Value = Stores
      Case 1: Stores = Value
      End Select

End Sub

Function StripColourInfo(txt$) As String

Dim loopvar%
Dim temp$

   If Len(txt$) < 3 Then
         StripColourInfo = txt$
         Exit Function
      End If

   temp$ = txt$
   For loopvar = 2 To Len(temp$)
      If Mid$(temp$, loopvar, 1) = "!" Then
            temp$ = Left$(temp$, loopvar - 2) & Mid$(temp$, loopvar + 1)
         End If
   Next

   StripColourInfo = temp$
      
End Function

Sub SupProfileToDrug(d As DrugParameters, SupProfile As TSupProfile)
'30Jun99 CFY written
'Copies the supplier profile information into the relevent fields in the drug file.
'06Apr00 TH *GST* change
'25Aug00 TH Trap blank entry in mdb
'01Sep01 TH Removed barcode write back to drugfile. Quick fix - user is never allowed to edit this field (at present) (#53511)
'           Therefore field could be blank if user has switched primary and sec. suppliers.
'           There is already better functionality to assign alternative barcodes outside of sup profiles.

      d.SisCode = SupProfile.SisCode
      d.supcode = SupProfile.supcode
      d.contno = SupProfile.contno
      d.reorderpcksize = SupProfile.reorderpcksize
      'd.reorderlvl = SupProfile.reorderlvl
      'd.reorderqty = SupProfile.reorderqty
      d.sislistprice = SupProfile.sislistprice
      d.contprice = SupProfile.contprice
      d.LeadTime = SupProfile.LeadTime
      d.lastreconcileprice = SupProfile.lastreconcileprice
      'd.tradename = SupProfile.tradename
      'd.BarCode = SupProfile.AltBarCode    '01Sep01 TH Removed  (#53511)
          d.EDIBarcode = SupProfile.EDIBarcode
      If InStr("0123456789", SupProfile.vatrate) > 0 Then  '25Aug00 TH
            d.vatrate = SupProfile.vatrate   '*GST*
         End If                                            '25Aug00 TH
End Sub

Sub SupProfileToDrugSQL(ByRef d As DrugParameters, ByVal SupProfile As ADODB.Recordset)
'30Jun99 CFY written
'Copies the supplier profile information into the relevent fields in the drug file.
'06Apr00 TH *GST* change
'25Aug00 TH Trap blank entry in mdb
'01Sep01 TH Removed barcode write back to drugfile. Quick fix - user is never allowed to edit this field (at present) (#53511)
'           Therefore field could be blank if user has switched primary and sec. suppliers.
'           There is already better functionality to assign alternative barcodes outside of sup profiles.

      d.SisCode = RtrimGetField(SupProfile!NSVCode)
      d.supcode = RtrimGetField(SupProfile!supcode)
      d.contno = RtrimGetField(SupProfile!contno)
      d.reorderpcksize = RtrimGetField(SupProfile!reorderpcksize)
      'd.reorderlvl = RtrimGetField(SupProfile!reorderlvl)
      'd.reorderqty = RtrimGetField(SupProfile!reorderqty)
      d.sislistprice = RtrimGetField(SupProfile!sislistprice)
      d.contprice = RtrimGetField(SupProfile!contprice)
      d.LeadTime = RtrimGetField(SupProfile!LeadTime)
      d.lastreconcileprice = RtrimGetField(SupProfile!lastreconcileprice)
      ''d.tradename = RtrimGetField(SupProfile!TradeName) '09Oct06 TH Removed
      'd.BarCode = SupProfile.AltBarCode    '01Sep01 TH Removed  (#53511)
      If InStr("0123456789", RtrimGetField(SupProfile!vatrate)) > 0 Then  '25Aug00 TH
            d.vatrate = RtrimGetField(SupProfile!vatrate)   '*GST*
         End If                                            '25Aug00 TH
      'd.PrimarySup = RtrimGetField(SupProfile!PrimarySup) '12Oct06 TH Removed
      d.SuppRefno = RtrimGetField(SupProfile!SuppRefno)
      d.SupplierTradeName = RtrimGetField(SupProfile!SupplierTradeName) '09Oct06 TH Added
          d.EDIBarcode = RtrimGetField(SupProfile!EDIBarcode) '09Oct06 TH Added

      d.WSupplierProfileID = RtrimGetField(SupProfile!WSupplierProfileID)
      
End Sub

Sub TakeStockFromBatch(NSVCode$, Qty!, batchnumber$, expiry$, ByVal auto As Boolean, ByVal blnReturn As Boolean)
'16Oc08 TH Changed handling of batches so user can issue more than current batches support, msg is displayed in this case,
'          but there is a tolerance to stop the message if the discrepancy may be caused by rounding.
'16Oct08 TH if user aborts batch issue the do not write batch number\expiry to translog
'10Oct12 AJK 46452 Changed find to filter for ADO recordsets
'14Apr13 AJK 61362 Changed filter to an iteration as it breaks for web transport layer produced recordsets for some odd reason

Dim ans$             'used for reply to confirm
Dim errored%         'set if record changed when updating
Dim tempexpiry$
Dim td As DateAndTime, ed As DateAndTime
Dim desc$                                             '28Jul99 AE Dim'd variable
Dim strParams As String
Dim rsBatchStock As ADODB.Recordset
Dim blnOK As Boolean
Dim BatchQty As Single
Dim intCount As Integer
Dim intloop As Integer
Dim rsBatchStockLevel As ADODB.Recordset
Dim blnRollBack As Boolean
Dim lngOK As Long
Dim rsLock As ADODB.Recordset
Dim strMsg As String
Dim strAns As String
Dim intTransloop As Integer
Dim blnSkipBatch As Boolean
Dim intBatchloop As Integer
Dim blnShowBatch As Boolean

Dim SelectedBatches() As Batch
   
   ''Exit Sub  'SQL DEMO
   blnShowBatch = True
   Do While blnShowBatch = True '26Oct06 TH
   blnShowBatch = False
   
   If Not auto Then Screen.MousePointer = HOURGLASS
   batchnumber$ = ""
   tempexpiry$ = ""
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode$)
   If Qty < 0 Then
      Set rsBatchStock = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLevelbySiteandNSVCodeReturns", strParams)
   Else
      Set rsBatchStock = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLevelbySiteandNSVCode", strParams)
   End If
   If rsBatchStock.RecordCount > 0 Then
   
      'Select batch number to be issued
      If auto Then       'not used yet but should be from IPDlist in time
         rsBatchStock.MoveFirst
         Do While Not rsBatchStock.EOF
            If GetField(rsBatchStock!Qty) >= Qty! / Val(d.convfact) Then
               'Issue from batch stock
               BatchQty = dp!(GetField(rsBatchStock!Qty) - Qty! / Val(d.convfact))
               'Put /back to DB
               'SQL BEGIN THE MAIN TRANSACTION FOR AN ISSUE HERE
               'SQL LOCK THE RECORD
               blnOK = PutBatchStockLevelQtySQl(GetField(rsBatchStock!WBatchStockLevelID), BatchQty)
               If blnOK Then Qty! = 0
               
            Else
               rsBatchStock.MoveNext
            End If
            If Qty! = 0 Then Exit Do
         Loop
         batchnumber$ = "Mixed batches" 'show on worksheet etc that no one batch has sufficient stock
         tempexpiry$ = "Manual"     '!!** IS THIS OK WHEN PARSED MECHANICALLY?
      Else
         Do
            LstBoxFrm.Caption = "Choose batch"                        '   "    ASC
            'LstBoxFrm.lblHead = "Expiry                       Batch Number         Quantity      (" & d.PrintformV & ")"   '     "
            LstBoxFrm.lblHead = "Expiry        " & TB & "Batch Number" & Space$(12) & TB & "Quantity(" & d.PrintformV & ")" '     "
            rsBatchStock.MoveFirst
            Do While Not rsBatchStock.EOF
               blnSkipBatch = False
               If intCount > 0 Then  'OK We have been here before, so we need to take account of any previous choices
                  For intBatchloop = 1 To intCount
                     If SelectedBatches(intBatchloop).BatchID = GetField(rsBatchStock!WBatchStockLevelID) Then blnSkipBatch = True
                  Next
               End If
               If Not blnSkipBatch Then
                  If Format$(GetField(rsBatchStock!expiry), "hh:nn") = "00:00" Then           '15Feb02 TH Added to exclude time where not appropriate  (#51886)
                     LstBoxFrm.LstBox.AddItem Format$(GetField(rsBatchStock!expiry), "dd/mm/yyyy   ") & Chr$(9) & GetField(rsBatchStock!batchnumber) & Chr$(9) & dp!(GetField(rsBatchStock!Qty)) & Chr$(9) & "(" & dp!(GetField(rsBatchStock!Qty) * Val(d.convfact)) & ")"      '15Feb02 TH
                  Else                                                           '15Feb02 TH
                     LstBoxFrm.LstBox.AddItem Format$(GetField(rsBatchStock!expiry), "dd/mm/yyyy hh:nn") & Chr$(9) & GetField(rsBatchStock!batchnumber) & Chr$(9) & dp!(GetField(rsBatchStock!Qty)) & Chr$(9) & "(" & dp!(GetField(rsBatchStock!Qty) * Val(d.convfact)) & ")"   '    "
                  End If                                                         '15Feb02 TH
                  'LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = MySet.Fields("ID")
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rsBatchStock!WBatchStockLevelID)
               End If
               rsBatchStock.MoveNext
            Loop
            'If Not rsBatchStock.EOF Then        '14Sep07 TH Replaced with below
            'If rsBatchStock.RecordCount > 0 Then
            If (rsBatchStock.RecordCount > 0 And LstBoxFrm.LstBox.ListCount > 0) Then  '16Oct08 TH Added extra check
               LstBoxFrm.LstBox.ListIndex = 0
               Screen.MousePointer = STDCURSOR
               desc$ = d.LabelDescription    ' desc$ = d.Description XN 4Jun15 98073 New local stores description
               plingparse desc$, "!"
               LstBoxFrm.lblTitle.Caption = Trim$(desc$) & " " & Str$(Qty!) & d.PrintformV '22Jan98 ASC
               LstBoxShow
               If LstBoxFrm.Tag <> "" Then
                  ''MySet.FindFirst ("id =" & Str$(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)))
                  'If Myset.Fields("Qty") >= qty! / Val(d.convfact) Then '15Dec96 ASC
                  ''On Error GoTo recordchanged
                  ''MySet.Edit   '<----- Optimistic locking
                  If Qty! < 0 Then                                                                      '15Feb02 TH (#51886)
                     'MySet.Fields("Qty") = dp!(MySet.Fields("Qty") + Abs(Qty! / Val(d.convfact)))
                     ''rsBatchStock.Seek (LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
                     
                     '14Apr13 AJK 61362 Changed filter to an iteration as it breaks for web transport layer produced recordsets for some odd reason
                     rsBatchStock.MoveFirst
                     'rsBatchStock.Filter = "WBatchStockLevelID = " & CStr(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) '10Oct12 AJK 46452 Changed find to filter
                     Do Until GetField(rsBatchStock!WBatchStockLevelID) = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        rsBatchStock.MoveNext
                     Loop
                     '14Apr13 AJK 61362 END
                     
                     
                     strBatchNumberBatchTracking = GetField(rsBatchStock.Fields("Batchnumber"))                 'MM-4114
                     strExpiryDateBatchTracking = Format(GetField(rsBatchStock.Fields("Expiry")), "ddmmyyyy")   'MM-4114
                     
                     
                     'BatchQty = dp!(GetField(rsBatchStock!Qty) + Abs(Qty! / Val(d.convfact)))
                     BatchQty = dp!(Qty! / Val(d.convfact)) ' For a return we are effectively just adding !
   ''                  blnOK = PutBatchStockLevelQtySQl(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex), BatchQty)
   ''                  If blnOK Then
   ''                     Qty! = 0
   ''                  Else
   ''                     GoTo recordchanged
   ''                  End If
                     intCount = intCount + 1
                     ReDim Preserve SelectedBatches(intCount)
                     SelectedBatches(intCount).BatchID = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                     SelectedBatches(intCount).BatchQty = BatchQty
                     LstBoxFrm.LstBox.RemoveItem LstBoxFrm.LstBox.ListIndex
                  Else
                     rsBatchStock.MoveFirst
                     'rsBatchStock.Filter = "WBatchStockLevelID = " & CStr(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) '10Oct12 AJK 46452 Changed find to filter
                     Do Until GetField(rsBatchStock!WBatchStockLevelID) = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        rsBatchStock.MoveNext
                     Loop
                     
                     strBatchNumberBatchTracking = GetField(rsBatchStock.Fields("Batchnumber"))                 'MM-4114
                     strExpiryDateBatchTracking = Format(GetField(rsBatchStock.Fields("Expiry")), "ddmmyyyy")   'MM-4114
                     If GetField(rsBatchStock.Fields("Qty")) >= Qty! / Val(d.convfact) Then
                        'MySet.Fields("Qty") = dp!(MySet.Fields("Qty") - Qty! / Val(d.convfact))
                        '''''BatchQty = dp!(GetField(rsBatchStock!Qty) - Qty! / Val(d.convfact))
                        BatchQty = Qty! / Val(d.convfact)
   ''                     blnOK = PutBatchStockLevelQtySQl(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex), BatchQty)
   ''                     If blnOK Then
   ''                        Qty! = 0
   ''                     Else
   ''                        GoTo recordchanged
   ''                     End If
                        intCount = intCount + 1
                        ReDim Preserve SelectedBatches(intCount)
                        SelectedBatches(intCount).BatchID = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        SelectedBatches(intCount).BatchQty = BatchQty
                        Qty! = 0
                        'LstBoxFrm.LstBox.RemoveItem LstBoxFrm.LstBox.ListIndex
                     Else
                        
                        ''MySet.Fields("Qty") = 0
                        BatchQty = GetField(rsBatchStock.Fields("Qty"))
                        'Qty = Qty - BatchQty
                        Qty = Qty - (BatchQty * Val(d.convfact)) '22Oct07 TH Replaced as qty is in issue units.
                     
   ''                     blnOK = PutBatchStockLevelQtySQl(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex), BatchQty)
   ''                     If blnOK Then
   ''                        Qty! = Qty! - GetField(rsBatchStock!Qty)
   ''                     Else
   ''                        GoTo recordchanged
   ''                     End If
                        intCount = intCount + 1
                        ReDim Preserve SelectedBatches(intCount)
                        SelectedBatches(intCount).BatchID = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
                        SelectedBatches(intCount).BatchQty = BatchQty
                        ''''Update the table !!
                        'LstBoxFrm.LstBox.RemoveItem LstBoxFrm.LstBox.ListIndex
                        'LstBoxFrm.LstBox.Refresh
                     End If                                                                       '   "
                  End If
               ''MySet.Update '<----- Optimistic locking
               'Now handled above to cope with different rollbacks
               
                        
                  On Error GoTo 0
                  If Not errored Then
                     'batchnumber$ = batchnumber$ & GetField(rsBatchStock!batchnumber) & ","            '   "
                     batchnumber$ = batchnumber$ & RtrimGetField(rsBatchStock!batchnumber) & ","     '02Jun08 TH Added trim for comma delimited batchnumbers in translog
                     tempexpiry$ = tempexpiry$ & Format$(GetField(rsBatchStock!expiry), "dd/mm/yyyy hh:nn") & ","  '   "
                  End If
                  errored = False
               Else
                  ans$ = "N"
                  k.escd = False
                  Confirm "Batch " & Iff((Qty! < 0 Or blnReturn), "Return", "Issue"), "abort batch " & Iff((Qty! < 0 Or blnReturn), "return", "issue"), ans$, k  '    "
                  '14Sep07 TH Added block to invert logic so as to fit with other questions (Oh dear, bit of a mess really)
                  If ans$ = "Y" Then
                     k.escd = True
                     batchnumber$ = "" '16Oct08 TH Abort batch issue so do not write number to log
                     tempexpiry$ = ""  '           Same for expiry
                  '   ans$ = "N" '22Oct07 TH ???
                  'Else
                  '   ans$ = "Y"
                  End If
               End If
            Else
               '16Oct08 TH Here we are issuing more than we have batches (unless we have a rounding issue
               '           In this case we need to warn the user, but we still continue
               If Qty! > Val(TxtD(dispdata$ & "\winord.ini", "", "0.5", "BatchRoundingTolerance", 0)) Then
                  popmessagecr "Batch Tracking", TxtD(dispdata$ & "\winord.ini", "", "The amount issued cannot be fulfilled by all recorded batch quantities. Issue will still continue", "RunOutOfBatchMsg", 0)
                  'WriteLog dispdata$ & "\BatchProblems.log", 0, "", d.SisCode & " " & Trim$(d.Description) & " Batches : " & batchnumber$  XN 4Jun15 98073 New local stores description
                  WriteLog dispdata$ & "\BatchProblems.log", 0, "", d.SisCode & " " & Trim$(d.LabelDescription) & " Batches : " & batchnumber$
               End If
               '16Oct08 TH
               'k.escd = True '22Mar07 TH We have run out of batches (07-0240) !!
               'ans$ = "Y"
               k.escd = False
               ans$ = "N"
               Qty! = 0 'WE are leaving as if we issue the lot
            End If
            Unload LstBoxFrm
         Loop Until Qty! <= 0 Or ans$ = "Y"
         
         If ans$ <> "Y" And Not k.escd Then
            'SQL NOW OPEN THE MAIN TRANSACTION
            'LOOP THROUGH THE SELECTED ARRAY. LOCK EACH RECORD. TEST THAT THERE IS STILL SUFFICIENT STOCK.
            'IF NOT MSG AND ROLLBACK. TREAT AS ESCAPED. IF OK UPDATE. KEEP TRANSACTION OPEN FOR THE REST OF THE ISSUE
            For intloop = 1 To UBound(SelectedBatches)
               blnOK = False
               If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
                  If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then
                     gTransportConnectionExecute "Begin Transaction"    '10Aug12 CKJ
                  End If
                  Do While Not blnOK
                     intCount = 0
                     Set rsLock = TableRowLock("WBatchStockLevel", SelectedBatches(intloop).BatchID, g_SessionID)
                     If rsLock.EOF Or rsLock.RecordCount > 1 Then
                        Do While gTransportIsInTransaction(g_SessionID) '10Aug12 CKJ
                           'Here are going to rollback ay outstanding transactions prior to msg display
                           'We keep a count so we can reinstitute them
                           If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"    '10Aug12 CKJ
                           intCount = intCount + 1
                        Loop
                        'Maybe not allow back out if not transactional !!!
                        strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & "Reason Unknown" & _
                                 crlf & crlf & "OK to Retry ? (No Will exit Application)"
                        strAns = "Y"
                        popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                        If strAns = "N" Then
                           'Exit App
                           GoTo CloseApplication
                        Else
                           blnOK = False
                        End If
                     Else
                        If GetField(rsLock!sessionID) = g_SessionID Then
                           blnOK = True 'There is a lock - it is ours !
                        Else
                        'Geuine lock from another identifiable source
                           Do While gTransportIsInTransaction(g_SessionID)      '10Aug12 CKJ
                              'Here are going to rollback ay outstanding transactions prior to msg display
                              'We keep a count so we can reinstitute them
                              If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction" '10Aug12 CKJ
                              intCount = intCount + 1
                           Loop
                           strMsg = "Could not lock Batch Stock Record Number " & CStr(SelectedBatches(intloop).BatchID) & crlf & _
                                    "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
                                    crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
                           strAns = "Y"
                           popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                           If strAns = "N" Then
                              'Exit App
                              GoTo CloseApplication
                           Else
                              blnOK = False
                           End If
                        
                        End If
                     
                     End If
                     
                     If Not blnOK Then
                        'Restore any Transactions from before rollbacks for any modal display
                        For intTransloop = 1 To intCount
                           gTransportConnectionExecute "Begin Transaction"      '10Aug12 CKJ
                        Next
                        
                     End If
                  Loop
               
               Else
                  Do While Not blnOK
                     gTransportConnectionExecute "Begin Transaction"    '10Aug12 CKJ
                     blnOK = gTransport.GetRowLock(g_SessionID, "WBatchStockLevel", SelectedBatches(intloop).BatchID)
                     If Not blnOK Then
                        gTransportConnectionExecute "RollBack Transaction"                 '06Jan06 TH Moved from below msgbox call     '10Aug12 CKJ
                        popmessagecr "", "Waiting to lock product record. Press OK to retry" '           Converted from msgbox
                     End If
                  Loop
               End If
               lngOK = PutBatchStockLevelQtySQl(SelectedBatches(intloop).BatchID, dp!(SelectedBatches(intloop).BatchQty)) '27Jan09 TH Added dp!
               If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then TableRowUnLock "WBatchStockLevel", SelectedBatches(intloop).BatchID, g_SessionID '27Oct06 TH Replaced the ID from the recordset
               If lngOK = 0 Then
                  popmessagecr "#", "Batch stock information may have changed since selection - Please try again"
                  blnRollBack = True
                  blnShowBatch = True
                  Exit For
               Else
                  '
               End If
               
               '----------------------------------------------------------------------------------
            Next
            tempexpiry$ = Left$(tempexpiry$, Len(tempexpiry$) - 1)
            batchnumber$ = Left$(batchnumber$, Len(batchnumber$) - 1)
         End If
      End If
   Else
      'NO BATCHES BUT HERE WE OPEN THE MAIN TRANSACTION FOR THE ISSUE PROCESS
   End If

   'Close dynaset & compare expiry dates - choose the earlier. '26Jun97 KR/CKJ
   rsBatchStock.Close
   Set rsBatchStock = Nothing
   
   Loop '26Oct06 TH
   '26Jun97 KR/CKJ added.
   If tempexpiry$ <> "" Then
      If expiry$ <> "" Then
         'Time format: dd/mm/yyyy hh:mm,dd/mm/yyyy hh:mm
         StringToTime Mid$(tempexpiry$, 12, 5), td    'if more than one date only take first - really should take earliest !!**
         StringToDate Left$(tempexpiry$, 10), td
         StringToTime Right$(expiry$, 5), ed
         StringToDate Left$(expiry$, 10), ed
         If td.mint < ed.mint Then expiry$ = tempexpiry$
      Else
         expiry$ = tempexpiry$
      End If
   End If
   If Not auto Then Screen.MousePointer = STDCURSOR
   k.escd = False

   SubPatBatchNum$ = batchnumber$      '28Jul99 AE Cludge using module-level variables to pass batchnum and
   If SubPatBatchNum$ = "" Then     'expiry into translog.
      SubPatExpiry$ = ""         '     "
   Else                          '     "
      setexpirydate Left$(expiry$, 10)  '     "
   End If                        '     "
Exit Sub

CloseApplication:
On Error Resume Next                  'SQL If there has been an error then we should try and roll back to unlock any record.
   Do While gTransportIsInTransaction(g_SessionID)      '10Aug12 CKJ
      'Here are going to rollback any outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction" '10Aug12 CKJ
   Loop
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   'Now we have cleaned up the database we are ready to clean up and close
   'We will call a closedown routine that can be different for each app type using this library
   PutRecordFailure "-1", "Failed to Lock WBatchStock Record"
   On Error GoTo 0


recordchanged:
'this will occur if the page is locked or changed i.e. someelse has used this batch
''
''   popmessagecr "", "Another user has now used this batch please choose again"
''   waitforticks 17
''   errored = True
''   Resume Next

End Sub

Function PutBatchStockLevelQtySQl(ByVal lngBatchStockLevelID As Long, ByVal sqlQty As Single) As Long

Dim strParams As String
Dim lngOK As Long
'ERROR HANDLING UPSTAIRS ????

   'First Lock then re-read the record. TODO SQL
   
   'Set objdata = New clsDataAccess
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("WBatchstockLevelID", trnDataTypeint, 4, lngBatchStockLevelID) & _
               gTransport.CreateInputParameterXML("Qty", trnDataTypeFloat, 4, sqlQty)
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWBatchStockLevelUpdateQtyUnderLock", strParams)
   
   PutBatchStockLevelQtySQl = lngOK
   

End Function

Sub Translog(d As DrugParameters, DrugNum&, UserID$, patid$, Qty!, dircode$, ward$, cons$, trantype$, sitepaths, IssType$, issueunitcost$)
'-----------------------------------------------------------------------------
'03Nov05 TH added ProductID
'24Oct06 TH Extended Batchnumber
'07Nov07 TH Extended batxchnumber again !! but htis time hopefully included the script for the DB field extension
'           Added PrescriptionID, PrescriberID . PCT Work around uses this and now uses the old deprecated prescriber
'           field with the 5 char legacy code if required.
'12Oct08 TH Added Stock Value to the transaction (F0031170)
'20Apr09 TH Make debug more specific (F0050755)
'17Apr12 TH Added RepeatBatchID for eMM/Rpt Disp integration.
'20Jun13 TH Changed revision level as marker for FM (TFS 65781)
'24Jun13 TH Another instance of the value not being accurate for certain logs at the point of writing
'           This seems to be the case for MB logs that need the blance of cost adding in (TFS 67261)
'18Jul13 TH A raft of changes to support QA and Bondstore issues (TFS 56613)
'24Jun13 TH Another instance of the value not being accurate for certain logs at the point of writing
'           This seems to be the case for MB logs that need the blance of cost adding in (TFS 67261)
'23Jul13 TH Ensure new QA and Bond handling is only for batch (TFS 67261)
'25Jul13 TH Reworked for QA and Bond (TFS 69599)
'07Aug14 TH Prefix Qty decimal fraction with zero (TFS 78353)

Static DeliveryNotes, LastTransfile$
Dim tranrecno&, TransFile$
Dim foundPtr&, pau!, adjust!, DoIt%, ans$, IssuedNo&
Dim purprice$, newcost$, vatrate!, tcost!, X$
Dim issueunitcostexvat$, Numoflines%
Dim t As transaction
'Dim gTransport    As clsDataAccess
Dim lngReturn    As Long
Dim strSql As String
Dim RequestID_Dispensing As Long
Dim blnCIVASReturn As Boolean
Dim blnCIVASIngredientReturn As Boolean
Dim stockvalue As Single
Dim Returnvalue As Single
Dim newstocklvl As Single
Dim blnQA As Boolean
Dim blnBond As Boolean
'Dim blnBondRelease As Boolean '18Jul13 TH This can be acccomodated in the standard MB functionality (TFS 56613)

   procname$ = "Translog"
   
   blnBond = False
   blnQA = False
   '23May08 TH Added
   
   If IssType$ = "BOND" Then '18Jul13 TH THis is used to identify an issue to the BondStore, its a special type of MB out of the pharmacy (TFS 56613)
      blnBond = True
      IssType$ = "MB"
   End If
   
   'If IssType$ = "MBBR" Then '18Jul13 TH This can be acccomodated in the standard MB functionality (TFS 56613)
   '   blnBondRelease = True
   '   IssType$ = "MB"
   'End If
   
   If InStr(IssType$, "MBRETURN") > 0 Then
      blnCIVASReturn = True
      If IssType$ = "MBRETURN_ING" Then blnCIVASIngredientReturn = True
      IssType$ = "MB"
   Else
      blnCIVASReturn = False
   End If
   
   If issueunitcost$ = "QA" Then '18Jul13 TH THis is used to identify an issue to QA (TFS 56613)
      blnQA = True
      issueunitcost$ = "0"
      issueunitcostexvat$ = "0"
   End If
   
   If InStr(issueunitcost$, Chr$(160)) Then
      ReDim tmp$(2)
      deflines issueunitcost$, tmp$(), Chr$(160), 0, Numoflines%
      issueunitcost$ = tmp$(0)
      issueunitcostexvat$ = tmp$(1)
   End If
  
   getdrug d, DrugNum&, foundPtr&, True         '<---------- LOCK drug record  ' 01Jun02 ALL/ATW   ' 01Jun02 ALL/ATW
   If DrugNum& = 0 Then DrugNum& = foundPtr&     '            (if found)
   'If DrugNum& = 0 Then
   If d.productstockID = 0 Then '24Jul06 TH Added
      popmessagecr ".Translog Error", "Cannot complete transaction - drug not found"
   Else
      't.revisionlevel = "10" 'SQL Changed revision level '12Oct08 Changed revision level
      t.revisionlevel = "A1" '20Jun13 TH Changed revision level as marker for FM (TFS 65781)
      t.patid = LTrim$(patid$)
      t.caseno = gTlogCaseno$
      t.SisCode = UCase$(d.SisCode)
      t.convfact = d.convfact
      t.IssueUnits = d.PrintformV
      t.dispid = LTrim$(UserID$)
      t.terminal = ASCTerminalName()
      t.date = Format$(Now, "yyyymmdd")  'Switched format
      t.Time = Format$(Now, "hhnnss")
      t.Qty = LTrim$(Str$(dp!(Qty!)))
      
      
      
      t.specialty = gTlogSpecialty$
      t.Prescriber = gTlogPrescriberID$
      t.PPflag = gTlogPPFlag$
      
    
      If Val(d.convfact) > 0 Then
         If RTrim$(IssType$) <> "W" And RTrim$(IssType$) <> "MB" Then
            If Val(d.anuse) < 12 Then pau! = 12 Else pau! = Val(d.anuse)
            adjust! = Qty! * (d.lossesgains / (pau! / 12))
            If Abs(adjust!) > Abs(d.lossesgains) Then adjust! = d.lossesgains
            If (Val(d.cost) * Qty!) / Val(d.convfact) + adjust! < 0 And Qty! > 0 Then
               'Added to stop negative prices for issues
               adjust! = (((Val(d.cost) * Qty!) / Val(d.convfact)) * -1) + 1
            End If
            If (Val(d.cost) * Qty!) / Val(d.convfact) + adjust! > 0 And Qty! < 0 Then
               adjust! = (((Val(d.cost) * Qty!) / Val(d.convfact)) * -1) - 1
            End If
            d.lossesgains = d.lossesgains - adjust!
            checklossgain d, "", "", purprice$, newcost$, Qty!, "Translog"
            If Qty! <> 0 Then 'JN 20Jun00 Added to stop problems with qty zeroing
               issueunitcost$ = LTrim$(Str$(Val(d.cost) + (adjust! * (Val(d.convfact) / Qty!))))
            Else
               issueunitcost$ = "0"
            End If
         End If
                  
         If blnCIVASReturn Then 'A return through Civas needs special handling
            stockvalue! = 1! * dp!(Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost) ' 14Apr91 CKJ'23Jun93 CKJ dp
            Returnvalue! = 1! * (Abs(Val(issueunitcostexvat$)))
            newstocklvl! = Abs(Qty) + dp!(Val(d.stocklvl)) 'abs, as a return is adding qty into stock
            If newstocklvl! <> 0 Then
               d.cost = LTrim$(Str$(dp!((stockvalue! + Returnvalue!) / newstocklvl!) * Val(d.convfact))) '* to get correct pack cost (NSVs worth)
            Else
               d.cost = LTrim$(Str$(dp!(Abs(Val(issueunitcostexvat$)) / Qty) * Val(d.convfact)))
            End If
         End If
         If TransLogVAT% Then vatrate! = VAT(Val(d.vatrate)) Else vatrate! = 1 '22Aug13 TH Moved here so Vatrate is accessible for MB Transactions
         If IssType$ = "MB" Then    'manufacturing balancing transaction
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "N", "includeTaxinFinalProduct", 0)) And vatrate! = 1 Then '22Aug13 TH (TFS)
               t.cost = issueunitcost$
               t.CostExVAT = issueunitcost$
               t.VATcost = "0"
            Else
               t.cost = issueunitcost$
               t.CostExVAT = issueunitcostexvat$
            t.VATcost = Str$(Val(issueunitcost$) - Val(issueunitcostexvat$))
            End If
            
            't.CostExVAT = ""
            't.VATcost = ""
            't.CostExVAT = issueunitcostexvat$
            't.VATcost = Str$(Val(issueunitcost$) - Val(issueunitcostexvat$))
            t.vatrate = ""
            t.VatCode = ""
         Else
            'If TransLogVAT% Then vatrate! = VAT(Val(d.vatrate)) Else vatrate! = 1 '22Aug13 TH Moved above
            tcost! = vatrate! * (Val(d.cost) * Qty! / Val(d.convfact) + adjust!)
            TotalIssueCost! = tcost!
            t.cost = LTrim$(Str$(dp!(tcost!)))
            t.CostExVAT = LTrim$(Str$(dp!(Val(d.cost) * Qty! / Val(d.convfact) + adjust!)))
            t.VATcost = LTrim$(Str$(dp!(Val(t.cost) - Val(t.CostExVAT))))
            t.VatCode = d.vatrate
            t.vatrate = Format$(vatrate!)
         End If
         If IssType$ = "M" Then
            issueunitcost$ = t.cost & "|" & Format$((Val(d.cost) * Qty! / Val(d.convfact) + adjust!))
            issueunitcost$ = t.cost & "|" & LTrim$(Str$(dp!(Val(d.cost) * Qty! / Val(d.convfact) + adjust!)))
         End If
      Else
         popmessagecr "WARNING", "Stores pack size not entered"
         t.cost = "0"
      End If
      
      t.ward = LTrim$(ward$)
      t.consultant = LTrim$(cons$)
      t.dircode = LTrim$(dircode$)
      t.kind = LTrim$(trantype$)
      t.site = LTrim$(Str$(sitepaths))
      If blnCIVASIngredientReturn Then
         t.labeltype = "C"
      Else
         t.labeltype = IssType$
      End If
      t.containers = ""
      t.civasamount = gCIVASdos$
      t.Episode = gTlogEpisode
      t.EventNumber = gTlogEventNumber
      
      If gcivasbatch > "" Then
         t.PrescriptionNum = gcivasbatch  'If gcivasbatch is set, use this instead of prescriptionid to identify ingredients and products from the same batch
      Else
         t.PrescriptionNum = Format$(PresentPrescriptionID&())
      End If
      
      If trimz(SubPatBatchNum$) = "" Then
         t.BatchNum = String$(Len(t.BatchNum), " ")
      Else
         t.BatchNum = SubPatBatchNum$        'Use module level variables to pass batchnum and exp
      End If
      
      If trimz(SubPatExpiry$) = "" Then
         t.ExpiryDate = ""
      Else
         t.ExpiryDate = SubPatExpiry$        'to translog from TakeStockFromBatch
      End If
      SubPatExpiry$ = ""
      
      '11Mar05 TH SQL moved here to get stklvl After the issue ! Should all be wrappered in get/putdrug transaction
      'If t.labeltype <> "W" And IssType$ <> "MB" Then
      If t.labeltype <> "W" And (IssType$ <> "MB" Or blnCIVASReturn) Then
         d.stocklvl = LTrim$(Str$(dp!(1! * Val(d.stocklvl) - Qty!)))  'ASC 10Apr93  '17Aug93 CKJ dp!
         d.usethisperiod = d.usethisperiod + Qty!
      End If
      
      't.stocklvl = d.stocklvl
      t.stocklvl = LTrim$(Str$(Val(d.stocklvl))) '10Jul13 TH set blanks to zero
      
      If Trim$(UCase$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "", "TranslogEntry", 0))) = "PICKTICKNO" And (UCase$(Trim$(trantype$)) = "S" Or UCase$(Trim$(trantype$)) = "P") Then   '16May04 TH Added (enh1549)
         t.custordno = GetPickNo()                                                                                                                                                            '   "
      Else                                                                                                                                                                                    '   "
         t.custordno = GetCustOrdNo()
      End If
      
      '07Nov07 TH Added for PCT workaround
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PharmacWorkaround", 0)) Then
         t.PrescriberID = getPrescriberID()
      End If
      
      '25Feb14 Th Added (TFS)
      If (UCase$(Trim$(trantype$)) = "S" Or UCase$(Trim$(trantype$)) = "P") Then   '16May04 TH Added (enh1549)
         t.InternalOrderNumber = Val(cons$)                                                                                                                                                           '   "
      Else                                                                                                                                                                                    '   "
         t.InternalOrderNumber = 0
      End If
                           
      RequestID_Dispensing = GetLabelRequestID()   '22May08 TH Written
      
      stockvalue! = 1! * dp!(((Val(d.stocklvl) / Val(d.convfact)) * Val(d.cost)) + Val(d.lossesgains)) '12Oct08 TH Added (F0031170)
         
      '24Jun13 TH Another instance of the value not being accurate for certain logs at the point of writing
      '           This seems to be the case for MB logs that need the blance of cost adding in (TFS 67261)
      'If IssType$ = "MB" And Not blnCIVASReturn And Not blnQA Then
      'If IssType$ = "MB" And Not blnCIVASReturn Then '08Jul13 TH Merge error from CIVAS branch
      If IssType$ = "MB" And Not blnCIVASReturn And Trim$(patid$) = "" Then '08Jul13 TH Merge error from CIVAS branch '23Jul13 TH Only for batch (TFS 67261)
         If Not blnBond Then stockvalue! = stockvalue! + (Val(t.CostExVAT) * -1)
         'stock level
         '25Jul13 TH Reworked for QA and Bond (TFS 69599)
         If blnBond Then
            t.stocklvl = Format$(Val(t.stocklvl) + getm_QAQty()) '10Jul13 TH Altered
         ElseIf Not blnQA Then
            'For QA we should be back where we started (after Bond)
            t.stocklvl = Format$(Val(t.stocklvl) + ((Val(t.Qty) + IIf(Val(t.Qty) < 0, getm_QAQty() * -1, getm_QAQty())) * -1)) '10Jul13 TH Altered
         End If
      End If
      
      
      
      '24Jun13 Unsophisticated way of costing all qty for a QA issue, but not actually pushing the qty into stock
      'Removed this as there is a transaction for QA so having the ful stock coming in then the QA issue after should look better
      '10Jul13 TH Now needed again to esure the full qty is booked (to then be booked straight out again
      'So , with QA tot (inc QA > MANU, QA (0 cost) < QA,if BOND, remainder <BOND
      
      If getm_QAQty() > 0 And Val(issueunitcost$) < 0 And IssType$ = "MB" And Not (blnBond Or blnQA) Then
         t.Qty = Format$(Val(t.Qty) - getm_QAQty())
      End If
      
      '07Aug14 TH Prefix decimal fraction with zero (TFS 78353) '13Ag14 TH Added trims on len checks - otherwise never fired.
      If Left$(t.Qty, 1) = "." Then
            If Len("0" & Trim$(t.Qty)) < 14 Then t.Qty = "0" & t.Qty
      ElseIf Left$(t.Qty, 2) = "-." Then
            If Len("-0" & Right(Trim$(t.Qty), Len(Trim$(t.Qty)) - 1)) < 14 Then t.Qty = "-0" & Right(t.Qty, Len(t.Qty) - 1)
      End If
      
      
      t.WWardProductListItemID = m_WWardProductListItemID
      
      With t
         strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("RevisionLevel", trnDataTypeVarChar, 2, .revisionlevel) & _
                  gTransport.CreateInputParameterXML("Patid", trnDataTypeVarChar, 10, .patid) & _
                  gTransport.CreateInputParameterXML("CaseNo", trnDataTypeVarChar, 10, .caseno) & _
                  gTransport.CreateInputParameterXML("Siscode", trnDataTypeVarChar, 7, .SisCode) & _
                  gTransport.CreateInputParameterXML("Convfact", trnDataTypeVarChar, 5, .convfact) & _
                  gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, .IssueUnits) & _
                  gTransport.CreateInputParameterXML("Dispid", trnDataTypeVarChar, 3, .dispid) & _
                  gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, .terminal) & _
                  gTransport.CreateInputParameterXML("Date", trnDataTypeint, 4, CLng(.date)) & _
                  gTransport.CreateInputParameterXML("Time", trnDataTypeVarChar, 6, .Time) & _
                  gTransport.CreateInputParameterXML("Qty", trnDataTypeVarChar, 13, .Qty) & _
                  gTransport.CreateInputParameterXML("Cost", trnDataTypeVarChar, 13, .cost) & _
                  gTransport.CreateInputParameterXML("CostExTax", trnDataTypeVarChar, 13, .CostExVAT) & _
                  gTransport.CreateInputParameterXML("TaxCost", trnDataTypeVarChar, 13, .VATcost) & _
                  gTransport.CreateInputParameterXML("TaxCode", trnDataTypeVarChar, 1, .VatCode) & _
                  gTransport.CreateInputParameterXML("TaxRate", trnDataTypeVarChar, 13, .vatrate) & _
                  gTransport.CreateInputParameterXML("Ward", trnDataTypeVarChar, 5, .ward) & _
                  gTransport.CreateInputParameterXML("Consultant", trnDataTypeVarChar, 9, .consultant) & _
                  gTransport.CreateInputParameterXML("Specialty", trnDataTypeVarChar, 5, .specialty) & _
                  gTransport.CreateInputParameterXML("Prescriber", trnDataTypeVarChar, 5, .Prescriber) & _
                  gTransport.CreateInputParameterXML("DirCode", trnDataTypeVarChar, 255, RTrim$(.dircode)) & _
                  gTransport.CreateInputParameterXML("Kind", trnDataTypeVarChar, 1, .kind) & _
                  gTransport.CreateInputParameterXML("Site", trnDataTypeVarChar, 10, .site) & _
                  gTransport.CreateInputParameterXML("LabelType", trnDataTypeVarChar, 1, .labeltype)
                                    
         '22May08 TH Added RequestID_Dispensing (need amongst other things for Civas Returns)
         '17Apr12 TH Added RepeatBatchID
         strSql = strSql & _
                  gTransport.CreateInputParameterXML("Containers", trnDataTypeVarChar, 4, .containers) & _
                  gTransport.CreateInputParameterXML("Episode", trnDataTypeint, 4, .Episode) & _
                  gTransport.CreateInputParameterXML("EventNumber", trnDataTypeVarChar, 10, .EventNumber) & _
                  gTransport.CreateInputParameterXML("PrescriptionNum", trnDataTypeVarChar, 10, .PrescriptionNum) & _
                  gTransport.CreateInputParameterXML("BatchNum", trnDataTypeVarChar, 255, .BatchNum) & _
                  gTransport.CreateInputParameterXML("ExpiryDate", trnDataTypeVarChar, 8, .ExpiryDate) & _
                  gTransport.CreateInputParameterXML("PPFlag", trnDataTypeVarChar, 1, .PPflag) & _
                  gTransport.CreateInputParameterXML("Stocklvl", trnDataTypeVarChar, 9, .stocklvl) & _
                  gTransport.CreateInputParameterXML("CustOrdNo", trnDataTypeVarChar, 12, .custordno) & _
                  gTransport.CreateInputParameterXML("CivasType", trnDataTypeVarChar, 1, .civastype) & _
                  gTransport.CreateInputParameterXML("CivasAmount", trnDataTypeVarChar, 5, .civasamount) & _
                  gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User) & _
                  gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, d.ProductID) & _
                  gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription) & _
                  gTransport.CreateInputParameterXML("PrescriberID", trnDataTypeint, 4, .PrescriberID) & _
                  gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, RequestID_Dispensing) & _
                  gTransport.CreateInputParameterXML("StockValue", trnDataTypeFloat, 8, stockvalue!) & _
                  gTransport.CreateInputParameterXML("RepeatBatchID", trnDataTypeint, 4, m_RepeatBatchID) & _
                  gTransport.CreateInputParameterXML("NHNumber", trnDataTypeVarChar, 10, m_NHNumber) & _
                  gTransport.CreateInputParameterXML("NHNumberValid", trnDataTypeBit, 1, Iff(m_NHNumberValid = 0, Null, Iff(m_NHNumberValid = 1, True, False))) & _
                  gTransport.CreateInputParameterXML("InternalOrderNumber", trnDataTypeint, 4, .InternalOrderNumber) & _
                  gTransport.CreateInputParameterXML("WWardProductListItemID", trnDataTypeint, 4, .WWardProductListItemID)
      End With
      
      '15May06 TH Open Transaction here
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "WTranslogTransactionWrapper", 0)) Then gTransportConnectionExecute "Begin Transaction"    '10Aug12 CKJ
      m_lngCurrentTransPointer = gTransport.ExecuteInsertSP(g_SessionID, "WTranslog", strSql)
      
''      If InStr(UCase$(Command$), "/T") Then
''         x$ = " patid         " & TB & t.patid & cr
''         x$ = x$ & " nsvcode" & TB & t.SisCode & cr
''         x$ = x$ & " dispid" & TB & t.dispid & cr
''         x$ = x$ & " date" & TB & t.date & cr
''         x$ = x$ & " time" & TB & t.Time & cr
''         x$ = x$ & " qty" & TB & t.Qty & crlf
''         x$ = x$ & " cost" & TB & t.cost & cr
''         x$ = x$ & " ward" & TB & t.ward & cr
''         x$ = x$ & " consultant" & TB & t.consultant & cr
''         x$ = x$ & " dircode" & TB & RTrim$(t.dircode) & cr
''         x$ = x$ & " kind" & TB & t.kind & cr
''         x$ = x$ & " site" & TB & t.site & cr
''         x$ = x$ & " labeltype" & TB & t.labeltype & cr
''         x$ = x$ & " containers" & TB & t.containers & cr
''         x$ = x$ & " VAT rate" & TB & Format$(100 * (vatrate! - 1))
''         popmessagecr "TRANSLOG " & dispdata$, x$
''      End If
'      If T.labeltype <> "W" And IssType$ <> "MB" Then
'         d.stocklvl = LTrim$(Str$(dp!(1! * Val(d.stocklvl) - Qty!)))  'ASC 10Apr93  '17Aug93 CKJ dp!
'         d.usethisperiod = d.usethisperiod + Qty!
'      End If
      If t.labeltype <> "W" Then d.lastissued = Format$(Now, "ddmmyyyy")   '10Jan99 AW Changed format.
      ''putdrugSQL d, DrugNum                '<--------- UNLOCK drug record
      putdrug d
      '15May06 TH close transaction here - therefore we should thoeretcially never get instances where we have translog without correspondin stock decrement
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "WTranslogTransactionWrapper", 0)) Then gTransportConnectionExecute "Commit Transaction"   '10Aug12 CKJ
      
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "GenericInterface", "N", "PrintingInterface", 0)) Then TransactionOutput t, m_lngCurrentTransPointer   '20Jan05 TH Added
      
      'If InStr(UCase$(Command$), "/T") Then
      If InStr(UCase$(Command$), "/TRANSLOGDEBUG") Then '20Apr09 TH Altered to shield more effectively (F0050755)
         X$ = " patid         " & TB & t.patid & cr
         X$ = X$ & " nsvcode" & TB & t.SisCode & cr
         X$ = X$ & " dispid" & TB & t.dispid & cr
         X$ = X$ & " date" & TB & t.date & cr
         X$ = X$ & " time" & TB & t.Time & cr
         X$ = X$ & " qty" & TB & t.Qty & crlf
         X$ = X$ & " cost" & TB & t.cost & cr
         X$ = X$ & " ward" & TB & t.ward & cr
         X$ = X$ & " consultant" & TB & t.consultant & cr
         X$ = X$ & " dircode" & TB & RTrim$(t.dircode) & cr
         X$ = X$ & " kind" & TB & t.kind & cr
         X$ = X$ & " site" & TB & t.site & cr
         X$ = X$ & " labeltype" & TB & t.labeltype & cr
         X$ = X$ & " containers" & TB & t.containers & cr
         X$ = X$ & " VAT rate" & TB & Format$(100 * (vatrate! - 1))
         popmessagecr "TRANSLOG " & dispdata$, X$
      End If
      If DeliveryNotes = 0 Then
         DeliveryNotes = Val(siteinfo$("DeliveryNotes", "0"))  '
         If DeliveryNotes = 0 Then DeliveryNotes = 1
      End If
      
'SQL - DO WE STILL NEED THIS ???
''      If DeliveryNotes = True Then
''         Select Case t.labeltype
''            Case "W", "P", "M"   ' no action
''            Case Else
''               DoIt = True
''               If Qty! = 0 Then DoIt = False
''               If Qty! < 0 Then
''                  ans$ = ""
''                  Confirm "!n!iReturn of goods", "show this return on the Delivery Note", ans$, k
''                  If k.escd Or ans$ = "N" Then DoIt = False
''                  k.escd = False
''               End If
''               If DoIt Then
''                  If IssuedChan = 0 Then OpenRandomFilePtr dispdata$ & "\issued.asc", Len(t), IssuedChan
''                  GetPointerSQL dispdata$ & "\issued.asc", IssuedNo&, False
''                  If IssuedNo& = 0 Then GetPointerSQL dispdata$ & "\issued.asc", 1, 2
''                  GetPointerSQL dispdata$ & "\issued.asc", IssuedNo&, True
''                  LSet r = t                  '13Mar96 CKJ
''                  PutRecordNL r, IssuedNo&, IssuedChan, Len(t)
''               End If
''         End Select
''      End If
      
      If InStr(t.Qty & t.cost, "E") > 0 Or InStr(t.Qty & t.cost, "D") > 0 Then '24Jul97 CKJ Simplified and added D# trap
         LSet r = t
         WriteLog dispdata$ & "\tlogenum.log", 0, "", "!" + Left$(r.record, Len(t)) + "!" + Str$(Qty!) + "!" + Str$(tcost!) + "!"
      End If
   End If

End Sub

Sub TranslogExtra(ByVal i_strLabel As String, ByVal i_intBatchNumber As Integer, ByVal i_lngStartDate As Long)
'26Mar14 TH Added to ensure label text is XML escaped and in a reasonable format (TFS 77153)

Dim strParams As String
Dim lngReturn As Long

   On Error GoTo TE_ErrorHandler

   replace i_strLabel, Chr(30), crlf, 0 '26Mar14 TH Added (TFS 77153)
   
   EscapeXML i_strLabel                 '26Mar14 TH Added (TFS 77153)
   
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, m_lngCurrentTransPointer) & _
               gTransport.CreateInputParameterXML("YearMonth", trnDataTypeVarChar, 6, Format$(Now, "yyyymm")) & _
               gTransport.CreateInputParameterXML("Labeltext", trnDataTypeVarChar, 255, RTrim$(i_strLabel)) & _
               gTransport.CreateInputParameterXML("Batchnumber", trnDataTypeint, 4, i_intBatchNumber) & _
               gTransport.CreateInputParameterXML("Startdate", trnDataTypeint, 4, i_lngStartDate)
   lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WTranslogExtra", strParams)
                                
TE_CleanUp:
   On Error GoTo 0
Exit Sub


TE_ErrorHandler:
   '
Resume TE_CleanUp

End Sub

''Sub updatebysupplier()
'''17Apr00 TH Written to allow global update of drugs/profiles by supplier. At present this
'''           facility is only for Vatrate but can be expanded as the need arises.
'''           Requires the addition of a new view (3) in supprof.ini
''
''Dim suptochange As supplierstruct, NumOfEntries%, i%, txt$, ans$, nod&, dyn As dynaset, x&, code$ ' 01Jun02 ALL/ATW
''
''
''    OpenSupProfileDB True, False
''
''    suptochange.code = ""
''    suptochange.name = ""
''    code$ = ""
''
''    asksupplier code$, 1, "", "Select Supplier to Update", 0, suptochange
''    If Trim$(suptochange.code) <> "" Or code$ = "A" Then
''            loadvatrates   'Necessary as they may not yet be loaded
''            ConstructView dispdata$ & "\supprof.ini", "views", "data", 3, "", 0, "", NumOfEntries
''            Ques.Caption = "Update Supplier Profiles for " & Iff(Trim$(code$) <> "A", Trim$(suptochange.name), "All Suppliers")
''            For i = 1 To NumOfEntries
''                Select Case Val(Ques.lblDesc(i).Tag)
''                    'Case 1:   txt$ = 'd.SisCode
''                    'Case 2:   txt$ = d.description
''                    'Case 3:   txt$ = SupProfile.tradename
''                    'Case 4:   txt$ = SupProfile.contno
''                    'Case 5:   txt$ = SupProfile.reorderpcksize
''                    'Case 6:   txt$ = SupProfile.reorderlvl
''                    'Case 7:   txt$ = SupProfile.reorderqty
''                    'Case 8:   txt$ = SupProfile.sislistprice
''                    'Case 9:   txt$ = SupProfile.contprice
''                    'Case 10:  txt$ = SupProfile.leadtime
''                    'Case 11:  txt$ = SupProfile.lastreconcileprice
''                    'Case 12:  txt$ = SupProfile.SuppRefNo
''                    Case 15:  txt$ = ""
''                End Select
''                QuesSetText i, Trim$(txt$)
''            Next
''            QuesCallbackMode = 16
''            QuesShow NumOfEntries
''            QuesCallbackMode = 0
''            If Not k.escd Then
''                    WriteLog dispdata$ & "\supdate.log", 0, UserID$, "Asked to update Drugfile for " & Iff(Trim$(code$) <> "A", Trim$(suptochange.name), "All Suppliers")
''                    For i = 1 To NumOfEntries
''                        txt$ = QuesGetText(i)
''                        Select Case Val(Ques.lblDesc(i).Tag)
''                            Case 15
''                                If Trim$(txt$) <> "" Then
''                                        popmsg "", "Are you sure you wish to update the " & money(9) & " rate for all items supplied by " & Iff(Trim$(code$) <> "A", Trim$(suptochange.name), "All Suppliers") & " to " & Format$((VAT(Val(txt$)) - 1) * 100) & " %", 1, ans$, k.escd
''                                        If (Not k.escd) And (ans$ = "Y") Then
''                                                Progress.lblInfo = "Updating Drugfile"
''                                                Progress.Show 0
''
''                                                getnod nod&
''                                                For x = 1 To nod
''                                                    getdrug d, x, 0, 0
''                                                    If d.supcode = suptochange.code Or code$ = "A" Then
''                                                            getdrug d, x, 0, -1
''                                                            d.vatrate = txt$
''                                                            putdrug d, x
''                                                        End If
''                                                    Progress.PerCent = (x / nod) * 100
''                                                Next x
''                                                Unload Progress
''                                                If SupProfileDBOpen% Then
''                                                        Progress.lblInfo = "Updating Supplier Profile Database"
''                                                        Progress.Show 0
''                                                        On Error GoTo SupprofError
''                                                        Set dyn = SupProfileDB.CreateDynaset("select * from profile")
''                                                        If Not dyn.EOF Then
''                                                                dyn.MoveFirst
''                                                                x = 1
''                                                                Do While Not dyn.EOF
''                                                                    If dyn.Fields("supcode") = suptochange.code Or code$ = "A" Then
''                                                                            dyn.Edit
''                                                                            dyn.Fields("vatrate") = txt$
''                                                                            dyn.Update
''                                                                        End If
''                                                                    Progress.PerCent = (x / dyn.RecordCount) * 100
''                                                                    x = x + 1
''                                                                    dyn.MoveNext
''                                                                Loop
''                                                                Unload Progress
''                                                            End If
''                                                        On Error GoTo 0
''                                                        popmessagecr "", "Update of Drug File and Supplier Profiles Complete"
''                                                    Else
''                                                        popmessagecr "", "Could Not Update SupplierProfiles" & crlf & crlf & "There was an Error opening SupProf.mdb"
''                                                    End If
''                                            End If
''                                    End If
''                            End Select
''                        Next
''                    End If
''                Unload Ques
''        End If
''
''ExitUpdateBySupplier:
''    On Error Resume Next
''    OpenSupProfileDB False, False
''    If Err Then
''            Err = 0
''        End If
''    On Error GoTo 0
''Exit Sub
''
''SupprofError:
''  popmessagecr "", "Could Not Update SupplierProfiles" & crlf & crlf & "There was an Error accessing SupProf.mdb"
''  On Error Resume Next
''  Unload Progress
''  If Error Then
''        Err = 0
''    End If
''  GoTo ExitUpdateBySupplier
''
''End Sub

Sub UpdateChar(char$, UpdateNext%)
'31Jul98 EAC written for HK mods

Dim temp%

   temp% = Asc(char$)

   temp = temp + 1

   If temp > Asc("Z") Then
         char$ = "A"
         UpdateNext = True
      Else
         char$ = Chr$(temp)
         UpdateNext = False
      End If

End Sub

Sub updateinfoline(Redraw%)
'25Oct94 CKJ Written. Only called from within FindDrug.frm
'19jul96 Note:!!** Depends on d being global!
'15Jul97 CKJ Modified to show more information than before, without flashing messages
'            and to show the cost and issue units per NSV
'13Jun98 ASC added local code to panel at bottom of findrdrug page
'26Jun98 CFY Added redraw parameter to a allow a repaint of the info panel to be forced.
'17May99 AE  Changed formatting of d.stocklvl on screen
'15Sep00 TH  format stocklevel to 6 sig figures
'09Apr01 CKJ Blank captions if no drug is displayed to prevent 'carry over'
'            Remove F2 notes if prescribing ward
'20Feb04 CKJ Added Swisslog and 2nd location
'16May04 TH  Added mod for UMMC price hide enhancement
'09May05 CKJ uses local copy of drug structure
'03Aug10 XN  InUse in not "S" anymore for stores only products, so changed to display 'Y (S)' or 'N (S)' (F0088717)

Static LastOne As Integer, doneit As Long

Dim foundPtr&, pform$, cost$
Dim linePtr As Integer
Dim intloop As Integer
Dim strNote As String
Dim strLocn As String
Dim strMachineType As String
Dim dlocal As DrugParameters
Dim lngOK As Long '12Dec06 TH
Dim storesItem As String

   linePtr = Finddrug.lstDrugs.ListIndex + 1
   If linePtr = 0 Then                                  ' none selected
      LastOne = 0
      doneit = 0
      For intloop = 0 To 3
         Finddrug.lblDrugInfo(intloop).Caption = ""
      Next
   Else
      foundPtr& = Finddrug.lstDrugs.ItemData(Finddrug.lstDrugs.ListIndex)
      If Redraw Then doneit = 0
      If linePtr% = LastOne% Then
         If foundPtr& <> doneit& Then
            If Finddrug.CmdOk.Tag = "MASTER" Then
               lngOK = GetDrugMaster(foundPtr&, dlocal)
            Else
               getdrug dlocal, (foundPtr&), foundPtr&, False
            End If
            
            Finddrug.lblDrugInfo(0).Caption = " NSV:  " & dlocal.SisCode & cr & "  Code: " & dlocal.Code & cr & "  Local: " & dlocal.local

                        '03Aug10 XN InUse in not "S" anymore for stores only products, so changed to display 'Y (S)' or 'N (S)' (F0088717)
            storesItem = Iff(dlocal.ProductID = 0, "(S)", "")
            Finddrug.lblDrugInfo(1).Caption = " Live:       " & dlocal.livestockctrl & cr & "  Stocked: " & dlocal.sisstock & cr & "  In use:    " & dlocal.inuse & " " & storesItem
            'end of F0088717
            
            '20Feb04 CKJ Added Swisslog and 2nd location
            strLocn = " Location:" & Right$(" " & Trim$(dlocal.loccode), 3)
            strNote = Iff(siteinfo$("FormularyEXT", "") = "", " Notes:   [F2]", "")
            If Len(trimz(dlocal.loccode2)) Then strLocn = " Loc:" & Right$(" " & Trim$(dlocal.loccode), 3) & "," & Right$(" " & Trim$(dlocal.loccode2), 3)
            If LocationForMechDisp(dlocal.loccode, strMachineType) Then
               strLocn = " " & strMachineType & "," & Right$(" " & Trim$(dlocal.loccode2), 3)
               strNote = " Stock:   [F4]"
            End If
            Finddrug.lblDrugInfo(2).Caption = " Formulary: " & dlocal.formulary & cr & " " & strLocn & cr & " " & strNote
            
            pform$ = " " & Trim$(LCase$(dlocal.PrintformV))
            If (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then    '16May04 TH Added for UMMC price hide enhancement
               cost$ = "*****"
            Else
               cost$ = Str$(dp!(Val(dlocal.cost) / 100))
               poundsandpence cost$, False
            End If
                        
                        '12May17 XN 178170 Got to display the correct  tradename
                        Dim tradename As String
                        If Trim$(dlocal.SupplierTradeName) = "" Then
                                tradename = Trim$(dlocal.tradename)
                        Else
                                tradename = Trim$(dlocal.SupplierTradeName)
                        End If
                        
            Finddrug.lblDrugInfo(3).Caption = " Stock level: " & FormatVal$(dlocal.stocklvl, 2, 6) & pform$ & "   Cost " & money$(5) & Trim$(cost$) & " for 1 x " & Trim$(dlocal.convfact) & pform$ & cr & "  " & tradename & cr & "  " & dlocal.message
         End If
         doneit& = foundPtr&
      Else
         LastOne% = linePtr%
      End If
   End If

End Sub

''Sub updatesupprofvatrate(dcopy As DrugParameters, d As DrugParameters)
'''25Aug00 TH Written to ensure vatrates in supplier profiles are maintain as the default value
'''           for all sites aho are not set to edit this field - currently all except OZ
'''29Aug00 JN Added error trapping in case selected db is not set up. Won't try to close an unopened dynaset
'''06Oct00 CFY Strengthened error handling
''
''Dim supprofdyn As dynaset           '25Aug00 TH
''Dim intNoErrors As Integer          '29Aug00 JN - used for pessimistic error check
''
''   'assume there will be errors     '29Aug00 JN
''   intNoErrors = False
''   On Error GoTo UpdateSupProfError '29Aug00 JN Added
''
''   'open supprof.mdb
''   OpenSupProfileDB True, False
''
''   'update on d.nsvcode
''   Set supprofdyn = SupProfileDB.CreateDynaset("Select vatrate from profile where profile.nsvcode ='" & d.siscode & "'")
''   intNoErrors = True               '29Aug00 JN - no errors occurred when opening dynaset
''   If Not supprofdyn.EOF Then
''         supprofdyn.MoveFirst
''         Do While Not supprofdyn.EOF
''         supprofdyn.Edit
''         supprofdyn.Fields!vatrate = d.vatrate
''         supprofdyn.Update
''         supprofdyn.MoveNext
''         Loop
''      End If
''
''Cleanup:
''   On Error Resume Next
''   If intNoErrors Then supprofdyn.Close
''   Set supprofdyn = Nothing
''
''   OpenSupProfileDB False, False
''
''   On Error GoTo 0                  '29Aug00 JN Added
''   Exit Sub
''
''UpdateSupProfError:                 '29Aug00 JN Added error trap...
''   Resume Cleanup
''End Sub

Function GetCurrentTransPointer() As Long
'20Jan05 TH Written

   GetCurrentTransPointer = m_lngCurrentTransPointer
   
End Function

Function ScalePrescribedUnits(ByRef d As DrugParameters, _
                              ByVal PrescribedUnits As String, _
                              ByRef NumericDose As Single, _
                              ByRef NumericDoseLow As Single, _
                              ByRef NumericDoseHigh As Single, _
                              ByRef message As String _
                             ) As Boolean
'09May05 CKJ Given a prescription which is in PrescribedUnits, attempt to reconcile with
'            the IssueInits & DosingUnits of the chosen product
'
'             labelling may be in...     issue units                      dosing units
'prescribed units may be...      +----------------------------------------------------------------------
'  stores units (note 1)         ¦     * convfact (note 2)              * convfact * dosesperissueunit
'  related to stores units       ¦     * factor * convfact (note 3)     * factor * convfact * dosesperissueunit
'  issue units                   ¦       no ratio                       * dosesperissueunit
'  related to issue units        ¦     * factor                         * factor * dosesperissueunit
'  dosing units                  ¦     / dosesperissueunit                no ratio
'  related to dosing units       ¦     * factor / dosesperissueunit     * factor
'
'Note 1: The Stores unit is the quantity implied by 1 NSVcode-worth of the product
'        The description of this unit is d.storespack and is normally 'pack' (5 chars max)
'        The description is optional and may be blank
'Note 2: Convfact is the number of issue units in one Stores unit
'        e.g tablets in a bottle, mL in a bag, test stix in a pack
'Note 3: It is unlikely that a ratio will be needed between mass or volume units prescribed
'        and the mass or volume units in Stores unit, but for completeness it can be used
'** Stores units not yet implemented **
'
'IN:
'  d structure       product to reconcile against
'  PrescribedUnits   abbreviation eg mg microgram mL pack tab
'  NumericDose       Three numeric dose fields each of which will be scaled
'  NumericDoseLow    Pass 0 for any unused dose
'  NumericDoseHigh   "
'
'OUT:
'  NumericDose       Returned scaled or returned unchanged if success=true, zero if success=false
'  NumericDoseLow    "
'  NumericDoseHigh   "
'  Message           Short text description of resolution of the units or of the problem if success=false
'
'USES:
'  d.printformV, d.dosingUnits, d.dosesperissueunit & d.LabelInIssueUnits must be set
'  d.storespack is not a mandatory field, but is available will be used
'  SP pUnitConversion performs resolution within a unit family, eg g to mg

Dim success As Boolean
Dim factor As String
Dim prescaling As Boolean
Dim scalefactor As Variant

   success = True
   factor = ""
   prescaling = False
   message = ""
   
   If LCase$(PrescribedUnits) = LCase$(Trim$(d.PrintformV)) Then
      message = "Prescription in issue units, Dispensing in issue units"
      If Not d.LabelInIssueUnits Then
         factor = "*"
         message = "Prescription in issue units, Dispensing in dosing units"
      End If

   ElseIf LCase$(PrescribedUnits) = LCase$(Trim$(d.DosingUnits)) Then
      message = "Prescription in dosing units, Dispensing in dosing units"
      If d.LabelInIssueUnits Then
         factor = "/"
         message = "Prescription in dosing units, Dispensing in issue units"
      End If
   Else
      scalefactor = UnitConversion(PrescribedUnits, 1, Trim$(d.PrintformV))
      If Not IsNull(scalefactor) Then
         prescaling = True
         message = "Prescription in ratio of issue units, Dispensing in issue units"
         If Not d.LabelInIssueUnits Then
            factor = "*"
            message = "Prescription in ratio of issue units, Dispensing in dosing units"
         End If
      Else
         scalefactor = UnitConversion(PrescribedUnits, 1, Trim$(d.DosingUnits))
         If Not IsNull(scalefactor) Then
            prescaling = True
            message = "Prescription in ratio of dosing units, Dispensing in dosing units"
            If d.LabelInIssueUnits Then
               factor = "/"
               message = "Prescription in ratio of dosing units, Dispensing in issue units"
            End If
         Else
            message = "Prescribed units match neither the Dosing nor Issue units so a dose cannot be calculated"
            success = False
         End If
      End If
   End If
   
   If success And Val(d.dosesperissueunit) = 0 Then
      Select Case factor
         Case "*", "/"
            success = False
            message = "Scaling of dose is required but 'doses per issue unit' is zero"
         End Select
   End If
   
   If success Then
      If prescaling Then
         NumericDose = dp!(NumericDose * CSng(scalefactor))
         NumericDoseLow = dp!(NumericDoseLow * CSng(scalefactor))
         NumericDoseHigh = dp!(NumericDoseHigh * CSng(scalefactor))
      End If
      
      Select Case factor
         Case "*"
            NumericDose = NumericDose * d.dosesperissueunit
            NumericDoseLow = NumericDoseLow * d.dosesperissueunit
            NumericDoseHigh = NumericDoseHigh * d.dosesperissueunit
         Case "/"
            NumericDose = dp!(NumericDose / d.dosesperissueunit)
            NumericDoseLow = dp!(NumericDoseLow / d.dosesperissueunit)
            NumericDoseHigh = dp!(NumericDoseHigh / d.dosesperissueunit)
         End Select
   Else
      NumericDose = 0
      NumericDoseLow = 0
      NumericDoseHigh = 0
   End If
   
   ScalePrescribedUnits = success

End Function

Function getbatchnum() As String
'14May05 TH Added
'01Jul16 KR Added trimz
   
   getbatchnum = trimz(SubPatBatchNum)
   
End Function
Sub ShowUserMessage(ByVal UserMessageCode As String)
'26May11 TH Reinstated use of editor to show user message but on a setting (allows printing) (F0064602)

Dim expansion As String
Dim strDrug As String

      If trimz$(UserMessageCode) <> "" Then
         SeqScan UserMessageCode, expansion$, "usermsg"
         If Trim$(expansion$) <> "" Then
'               If d.formulary = "S" Then '25Jan97 ASC
'                     ans$ = "N"
'                     k.Max = 1
'                     k.min = 1
'                     k.validchars = "YN"
'                     inputwin "Highly Specialised Drug Indication", expansion$ & crlf & crlf & "Does this patient meet the above criteria ?", ans$, k
'                     If UCase$(ans$) = "Y" And Not k.escd Then
'                           '10Mar97 CKJ Removed until implemented correctly
'               '!!**       writelog dispdata$ & "\HSDRUG.LOG", site%, userid$, pid.cons & pid.recno & "Conforms"
'                        Else
'                           ans$ = "N"
'                           k.Max = 1
'                           k.min = 1
'                           k.validchars = "YN"
'                           inputwin "Funding may not be available for this prescription", "Would you like to proceed", ans$, k
'                           If ans$ = "Y" Then
'                                 '10Mar97 CKJ Removed until implemented correctly
'               '!!**             writelog dispdata$ & "\HSDRUG.LOG", site%, userid$, pid.cons & pid.recno & "Non-Conformer"
'                              Else
'                                 foundPtr& = 0
'                                 found% = 0
'                                 k.escd = True
'                              End If
'                        End If
'                  Else
                     strDrug = Trim$(d.storesdescription)
                     plingparse strDrug, "!"
                     expansion$ = "(" & d.SisCode & ")  " & strDrug & cr & cr & expansion
                     If TrueFalse(TxtD(dispdata$ & "\Patmed.INI", "", "Y", "UseEditorToShowDrugMsgs", 0)) Then '26May11 TH Reinstated but on a setting (allows printing) (F0064602) '26Sep11 TH Changed default (TFS14788)
                        Editor.Txt1 = expansion$
                        Editor.lblCode = d.UserMsg
                        Editor.Caption = "Please Note"
                        Editor.cmdExit.default = True           'view only
                        Editor.Tag = ""
                        CentreForm Editor
                        Editor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                        Unload Editor
                     Else
                          popmessagecr "!Please Note", expansion$
                     End If
'                  End If
            Else
               popmessagecr "!Please Note", "Message code '" & d.UserMsg & "' is not defined"
            End If
      End If

End Sub

'Public Sub setSpecialty(strSpecialty As String)
''07Feb06 TH Added to set specialty from Dispensing ctrl.
'
'   gTlogSpecialty$ = strSpecialty
'End Sub

Sub DisplayBNFsectionlist(ByVal depth As Integer, ByVal strTitle As String, ByRef strCode As String, ByRef strDesc As String)
'08oct08 CKJ written, based on displaymacrofile but getting BNF data directly from ordercatalogue
'              looks up BNF details to number of levels requested, or stkmaint setting if unspecified, or 4 levels as default
'              indents description to correspond with code depth, but returns trimmed description
'              highlights row for existing code if found in list
               
Dim posn          As Integer
Dim strParameters As String
Dim rsLookups     As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim Level         As Integer
Dim highlight     As Integer
Dim strCodeCopy   As String
Dim strRScode     As String

Const ErrSource   As String = "DisplayBNFsectionlist"

   On Error GoTo ErrorHandler
   strCodeCopy = strCode
   strCode = ""
   strDesc = ""

   LstBoxFrm.LstBox.Clear

   LstBoxFrm.Caption = strTitle
   LstBoxFrm.lblHead.Caption = "Code" & Space$(8) & TB & "Description"
   
   depth = TxtD(dispdata$ & "\stkmaint.ini", "Display", Format$(depth), "BNFlevels", 0)
   Select Case depth
      Case Is < 1, Is > 4: depth = 4
      End Select
      
   strParameters = gTransport.CreateInputParameterXML("Depth", trnDataTypeint, 4, depth)
   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pOrderCatalogueSelectForPharmacyBNF", strParameters)
   
   If Not rsLookups.EOF Then
      rsLookups.MoveFirst
      Do While Not rsLookups.EOF
         strRScode = GetField(rsLookups!Code)
         Level = Len(strRScode) \ 3                '0 to 3 for the four levels of detail
         LstBoxFrm.LstBox.AddItem strRScode & TB & Space$(Level * 3) & Trim$(GetField(rsLookups!Value))
         If strCodeCopy = strRScode Then highlight = LstBoxFrm.LstBox.NewIndex
         rsLookups.MoveNext
      Loop
   End If
   rsLookups.Close
   If highlight Then
      LstBoxFrm.LstBox.ListIndex = LstBoxFrm.LstBox.ListCount - 1    'scroll to bottom of list
      LstBoxFrm.LstBox.ListIndex = highlight                         'scroll back up to wanted item, so it appears at top of page
   End If
   
   LstBoxShow

   posn = InStr(LstBoxFrm.Tag, TB)
   If posn Then
      strCode = Left$(LstBoxFrm.Tag, posn - 1)
      strDesc = LTrim$(Mid$(LstBoxFrm.Tag, posn + 1))
   End If

Cleanup:
   On Error Resume Next
   rsLookups.Close
   Set rsLookups = Nothing
   Unload LstBoxFrm
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub
Sub TransactionOutput(t As transaction, ByVal WTranslogID As Long)
'20Jan05 TH Written for System C integration
'16Nov05 TH Mod to allow configurable file extension for output file
'17Nov05 TH Added extra bits - the drug because this isnt there for ingredients (MATER), supplier for Cardiff (poss)
'04Feb08 TH Added extra stuff for RBH Oracle interface
'-------------------
'05Feb09 TH Ported from version 8
'04Sep09 PJC Added extra filter for the Patient Payment Category (F0054530)
'11Sep09 PJC Read the Patient stuff from the heap rather than the structure. (F0054530)

Dim strRTFFile As String, strFilename As String, strPointerFilename As String, strFilePrefix As String, strOutfile As String
Dim lngPointer As Long
Dim lclsup As supplierstruct, intFound As Integer
Dim strTransactionRef As String '04Feb08 TH Added
Dim strpflag As String
Dim intBatchtotal As Integer
Dim RTFTxt$
Dim strOutFilename As String
Dim strWard As String
Dim lngFound As Long
Dim strFilesuffix As String
Dim strMsg As String
Dim strPatientPaymentFilter As String '04Sep09 PJC Added extra filter for the Patient Payment Category (F0054530)
Dim strPatientPaymentCategory As String
Dim txt$, intSuccess As Integer '04Jan17 TH Added

'Static tranOutschan As Long
   
   strPatientPaymentFilter = Trim$(TxtD(dispdata$ & "\GenInt.INI", "Transloginterface", "", "PaymentFilter", 0))                                                                         '04Sep09 PJC Added extra filter for the Patient Payment Category (F0054530)
   Heap 11, gPRNheapID, "pPatientPaymentCategory", strPatientPaymentCategory, 0                                                                                                          '11Sep09 PJC Read the Patient stuff from the heap rather than the structure. (F0054530)
   If Trim$(strPatientPaymentCategory) = "" Then strPatientPaymentCategory = TxtD(dispdata$ & "\Genint.ini", "TranslogInterface", "UNKNOWN", "PatientPaymentDefault", 0)                 '11Sep09 PJC Set the default to be safe. (F0054530)
   'If Len(strPatientPaymentFilter) = 0 Or (Len(strPatientPaymentFilter) > 0 And InStr("," & strPatientPaymentFilter & ",", "," & Trim$(pid.PatientPaymentCategory) & ",") > 0) Then     '        "
   If Len(strPatientPaymentFilter) = 0 Or (Len(strPatientPaymentFilter) > 0 And InStr("," & strPatientPaymentFilter & ",", "," & Trim$(strPatientPaymentCategory) & ",") > 0) Then       '        "

      'Check which Issue types are required
      If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "IODL", "TransKinds", 0), t.kind) > 0 Then
         If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "IODLSPFMWXC", "TransLabels", 0), t.labeltype) > 0 Then  '04Mar08 TH Added (tried to add all types by default)
            'Put episode stuff on the heap - No need it is with the patient stuff
            'Put log stuff on heap                                                                 A
            FillHeapTranslogInfo gPRNheapID, t, WTranslogID, 0
   
            'Here we do the mapping exercise for RBH and replace elements as required. 21Apr08 TH Added
            strWard = TxtD(dispdata$ & "\GenInt.INI", "TransactionWardMapper", "", t.ward, 0)
            If Trim$(strWard) <> "" Then
               Heap 10, gPRNheapID, "tWard", Trim$(strWard), 0
               Heap 10, gPRNheapID, "tWardXML", Trim$(XMLEscape(strWard)), 0
            End If
            '--------------------
   
            '17Nov05 TH Added extra bits - the drug because this isnt there for ingredients (MATER), supplier for Cardiff (poss)
            getsupplier (t.ward), 0, lngFound, lclsup
            'If lngFound Then FillHeapSupplierInfo gPRNheapID, lclsup, 0
            FillHeapSupplierInfo gPRNheapID, lclsup, 0 '09Apr09 TH should be blank if not found
            FillHeapDrugInfo gPRNheapID, d, 0
            '------------------
                     
            'Output the file
            strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "", "RTFFile", 0)
            If strRTFFile <> "" Then
               strRTFFile = dispdata & "\" & strRTFFile
               'GetRTFTextFromDB strRTFFile, txt$, intSuccess  '04Jan17 TH Now read from DB (Hosted)
               'If fileexists(strRTFFile) Then
               If RTFExistsInDatabase(strRTFFile) Then
               'If intSuccess Then
                  strFilename = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "", "ExportFilePath", 0)
                  If strFilename <> "" Then
                     'strFile = strFilename
                     If DirExists(strFilename) Then
                        'Now get a pointer to ensure unique file
                        strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", transpath$ & "\TransInt.dat", "InterfacePointerFile", 0)
                        strPointerFilename = TxtD(transpath$ & "\GenInt.INI", "TranslogInterface", strPointerFilename, "InterfacePointerFile", 0)
                        GetPointerSQL strPointerFilename, lngPointer, True
                        '04Feb08 TH Added for RBH Oracle interface
                        'strTransactionRef = Right$(date$, 4) & Left$(date$, 2) & Left$("00000000", 8 - Len(Format$(lngPointer))) & Format$(lngPointer)
                        strTransactionRef = Right$(date$, 4) & Left$(date$, 2) & Left$("00000000", 8 - Len(Format$(lngPointer))) & Format$(lngPointer)
                        Heap 10, gPRNheapID, "TransactionRef", strTransactionRef, 0
                        Heap 10, gPRNheapID, "OutputRefNoPad", Format$(lngPointer), 0
                        Heap 11, gPRNheapID, "pFlag", strpflag, 0
                        If strpflag <> "Y" Then strpflag = "N"
                        Heap 10, gPRNheapID, "pFlagDefault", strpflag, 0
                        '------------
                        If TrueFalse(TxtD(dispdata$ & "\GenInt.INI", "Filebatching", "N", "UseFilebatching", 0)) Then   '18Feb08 TH
                           intBatchtotal = Val(TxtD(dispdata$ & "\GenInt.INI", "Filebatching", "0", "BatchTotal", 0))
                           If intBatchtotal > 0 Then
                               If (lngPointer Mod intBatchtotal = 0) Or (lngPointer = 1) Then
                                 'New file required
                                 strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "T", "FilePrefix", 0) & Space$(3), 3))
                                 strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer)
                                 'Parse the file
                                 'parseRTF strRTFFile, strOutfile
                                 parseRTFfromDB strRTFFile, strOutfile '04Jan17 TH Now use rtf in DB (Hosted)
                                 
                                 On Error GoTo TransactionOutput_Err
                                 FileCopy strOutfile, strFilename & TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", ".xml", "OutputFileExtension", 0)    '16Nov05 TH Replaced above line to allow configurable file extension
                                 
                                 'remove the file afterwards
                                 On Error Resume Next
                                 If fileexists(strOutfile) Then Kill strOutfile
                                 On Error GoTo 0
                                 
                                 If lngPointer > 1 Then
                                    'Copy the old to the "pick up" zone
                                    lngPointer = lngPointer - intBatchtotal
                                    If lngPointer = 0 Then lngPointer = 1
                                    strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "T", "FilePrefix", 0) & Space$(3), 3))
                                    strFilename = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "", "ExportFilePath", 0) & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer) & TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", ".xml", "OutputFileExtension", 0)
                                    strOutFilename = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", patdatapath$, "CompletedExportFilePath", 0) & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer) & TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", ".xml", "OutputFileExtension", 0)
                                    
                                    On Error GoTo TransactionOutput_Err
                                    FileCopy strFilename, strOutFilename
                                    
                                 End If
                              Else
                                 'Get the file name
                                 lngPointer = lngPointer - (lngPointer Mod intBatchtotal)
                                 If lngPointer = 0 Then lngPointer = 1
                                 strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "T", "FilePrefix", 0) & Space$(3), 3))
                                 strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer) & TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", ".xml", "OutputFileExtension", 0)
      
                                 'Write to it
                                 'parseRTF strRTFFile, strOutfile
                                 'GetTextFile strRTFFile, RTFTxt$, 0
                                 GetRTFTextFromDB strRTFFile, RTFTxt$, 0 '06Dec16 TH Replaced (TFS 157969)
                                 'Read the local file.
                                 ParseItems gPRNheapID, RTFTxt$, 0
      
                                 'write RTFTxt$
                                 PutTextFileAppend strFilename, RTFTxt$, 0
                              End If
      
                           Else
                              popmessagecr "Generic Interface", "File Batching enabled without BatchTotal being set. No files will be created"
                           End If
                        Else '18Feb08 TH
                           'The Normal way
                           
                           '19Mar09 TH Replaced filname handling and added suffix
                           'strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "T", "FilePrefix", 0) & Space$(3), 3))
                           'strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer)
                           strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "T", "FilePrefix", 0))
                           
                           'strFilename = strFilename & "\" & strFilePrefix & Left$("0000000000", 10 - (Len(Format$(lngPointer)))) & Format$(lngPointer)
                           strFilename = strFilename & "\" & strFilePrefix & Format$(lngPointer, "0000000000")
                           strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "", "Filesuffix", 0))
                           If t.Qty < 0 Then
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", strFilesuffix, "FilesuffixReturn", 0))
                           Else
                              strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", strFilesuffix, "FilesuffixIssue", 0))
                           End If
                           strFilename = strFilename & strFilesuffix
                           
                           'Parse the file
                           'parseRTF strRTFFile, strOutfile
                           parseRTFfromDB strRTFFile, strOutfile '04Jan17 TH Now use rtf in DB (Hosted)
                           'EscapeRTF file$, OutFile$
                           'Put the file to the output location
                           'Name strOutfile As strFilename & ".xml"
                           'FileCopy strOutfile, strFilename & ".xml"
                           On Error GoTo TransactionOutput_Err
                           FileCopy strOutfile, strFilename & TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", ".xml", "OutputFileExtension", 0)    '16Nov05 TH Replaced above line to allow configurable file extension
                           'If fileexists(file$) Then Kill file$
                           
                           'remove the file afterwards
                           On Error Resume Next
                           If fileexists(strOutfile) Then Kill strOutfile
                           On Error GoTo 0
                           
                        End If '18Feb08 TH
                     Else
                        popmessagecr "", "Generic Interface Incorrectly configured - Export File Path Not Found"
                     End If
                  Else
                     popmessagecr "", "Generic Interface Incorrectly configured - Export File Path required"
                  End If
               Else
                  popmessagecr "", "Generic Interface Incorrectly configured - Export File Not Found"    '09Apr09 TH Added after CKJ review
               End If
            Else
               popmessagecr "", "Generic Interface Incorrectly configured - Export File not specified"   '09Apr09 TH Added after CKJ review
            End If
         End If
      End If
   End If      '04Sep09 PJC End of Block (F0054530)
   
TransactionOutput_Exit:
   Exit Sub

TransactionOutput_Err:
   strMsg = "An error has occurred in procedure : TransactionOutput" & crlf & crlf
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\TransOutput.log", SiteNumber, UserID$, strMsg
   Resume TransactionOutput_Exit

End Sub

Sub FillHeapTranslogInfo(ByVal HeapID As Integer, trans As transaction, ByVal WTranslogID As Long, success As Integer)
'20Jan05 TH Written
'17Feb05 TH Altered tTimexml after on site testing (Now reflects HH:MM not HH:SS
'22Sep05 TH Added  XML elements on to the printheap for Christies.
'07Sep09 PJC Added formatted version of trans date, trans costs/100, transaction Charge/Credit code and absolute qty to the heap. (F0054530)
'11Mar10 TH Merged from 10.1 Dont know why this is not here (!) 21Oct09 TH added (F0066728) (F0080318)

Dim strDatexml As String, strTimeXML As String
Dim id As Integer, act    As Integer
Dim strRBHDate As String
Dim strTemp As String               '07Sep09 PJC Added
Dim strFormat As String             '07Sep09 PJC Added
Dim strDateFormatted As String      '07Sep09 PJC Added
Dim strMask As String '21Oct09 TH added (F0066728) '11Mar10 TH Merged from 10.1

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
         ' commented changes to Heap names are subject to discussion
         Heap act, id, "tWTranslogID", Format$(WTranslogID), 0
         Heap act, id, "tRevisionlevel ", Trim$(trans.revisionlevel), 0
         Heap act, id, "tPatid ", Trim$(trans.patid), 0
         Heap act, id, "tCaseno", Trim$(trans.caseno), 0
         Heap act, id, "tCasenoXML", Trim$(XMLEscape(trans.caseno)), 0  '22Sep05 TH Added
         Heap act, id, "tSisCode ", Trim$(trans.SisCode), 0
         Heap act, id, "tSisCode", Trim$(trans.SisCode), 0     '05Feb08 TH Why do these have spaces in ? Well I wrote it so it was my fault.
         Heap act, id, "tConvfact ", Trim$(trans.convfact), 0
         Heap act, id, "tIssueUnits", Trim$(trans.IssueUnits), 0
         Heap act, id, "tDispid", Trim$(trans.dispid), 0
         Heap act, id, "tTerminal", Trim$(trans.terminal), 0
         Heap act, id, "tTerminalXML", Trim$(XMLEscape(trans.terminal)), 0   '22Sep05 TH Added
         Heap act, id, "tDate", Trim$(trans.date), 0
         'strDatexml = Right$(Trim$(trans.date), 4) & "-" & Mid$(Trim$(trans.date), 3, 2) & "-" & Left$(Trim$(trans.date), 2)
         strDatexml = Left$(Trim$(trans.date), 4) & "-" & Mid$(Trim$(trans.date), 5, 2) & "-" & Right$(Trim$(trans.date), 2)
         Heap act, id, "tDatexml", strDatexml, 0

         Heap act, id, "tTime", Trim$(trans.Time), 0
            If Len(Trim$(trans.Time)) > 0 Then
               'strTimeXML = Left$(Trim$(trans.Time), 2) & ":" & Right$(Trim$(trans.Time), 2)
               strTimeXML = Left$(Trim$(trans.Time), 2) & ":" & Mid$(Trim$(trans.Time), 3, 2)   '17Feb05 TH Altered after on site testing
            Else
               strTimeXML = ""
            End If
            Heap act, id, "tTimexml", strTimeXML, 0

         parsedate trans.date, strRBHDate, "6", 0
         strRBHDate = Left$(Trim$(strRBHDate), 2) & "-" & UCase(Mid$(Trim$(strRBHDate), 3, 3)) & "-" & Right$(Trim$(trans.date), 4)
         Heap act, id, "tdd-mmm-yyyyDate", strRBHDate, 0
         
         strFormat = TxtD(dispdata$ & "\patmed.ini", "", "dd/mm/ccyy", "TransLogPrintHeapDateFormat", 0)                       '07Sep09 PJC Added formatted version of trans date to the heap. (F0054530)
         strTemp = Left$(Trim$(trans.date), 4) & "-" & (Mid$(Trim$(trans.date), 5, 2)) & "-" & Right$(Trim$(trans.date), 2)    '07Sep09 PJC convert the trans date to a known date for ParseDate. (F0054530)
         parsedate strTemp, strDateFormatted, strFormat, 0                                                                     '07Sep09 PJC Format the Date and add to the Heap. (F0054530)
         Heap act, id, "tDateFormatted", strDateFormatted, 0                                                                   '           "
         
         '07Sep09 PJC Added below for the Charge/Credit code and absolute qty. (F0054530)
         Heap act, id, "tTransChargeType", Iff(InStr(trans.Qty, "-") = 0, TxtD(dispdata$ & "\patmed.ini", "", "C", "TransLogPrintHeapChargeCode", 0), TxtD(dispdata$ & "\patmed.ini", "", "G", "TransLogPrintHeapCreditCode", 0)), 0
         strTemp = Trim$(trans.Qty)
         replace strTemp, "-", "", 0
         Heap act, id, "tAbsoluteQty", strTemp, 0
         
         Heap act, id, "tQty", Trim$(trans.Qty), 0
         
         strMask = TxtD(dispdata$ & "\GenInt.INI", "TranslogInterface", "0.######", "QtyinPacksMask", 0) '11Mar10 TH Merged from 10.1
         If Val(trans.convfact) > 0 Then
            strTemp = Trim$(Format$((Val(trans.Qty) / Val(trans.convfact)), strMask))
         Else
            strTemp = "0"
         End If
         If Right(strTemp, 1) = "." Then strTemp = Left$(strTemp, Len(strTemp) - 1) '21Oct09 TH Added (f0066728)
         Heap act, id, "tQtyPacks", strTemp, 0  '21Oct09 TH Added (f0066728)
         
         Heap act, id, "tCost", Trim$(trans.cost), 0
         Heap act, id, "tCostExVAT", Trim$(trans.CostExVAT), 0
         Heap act, id, "tVATcost", Trim$(trans.VATcost), 0
         
         strFormat = TxtD(dispdata$ & "\patmed.ini", "", "0.00", "TransLogPrintHeapCost/100Format", 0)         '07Sep09 PJC Added formatted version of trans costs/100 to the heap. (F0054530)
         Heap act, id, "tCost/100", Format$(Val(trans.cost) / 100, strFormat), 0                               '           "
         Heap act, id, "tCostExVAT/100", Format$(Val(trans.CostExVAT) / 100, strFormat), 0                     '           "
         Heap act, id, "tVATcost/100", Format$(Val(trans.VATcost) / 100, strFormat), 0                         '           "
         
         Heap act, id, "tVatCode", Trim$(trans.VatCode), 0
         Heap act, id, "tVatrate", Trim$(trans.vatrate), 0
         Heap act, id, "tWard", Trim$(trans.ward), 0
         Heap act, id, "tWardXML", Trim$(XMLEscape(trans.ward)), 0               '22Sep05 TH added
         Heap act, id, "tConsultant", Trim$(trans.consultant), 0
         Heap act, id, "tConsultantXML", Trim$(XMLEscape(trans.consultant)), 0   '22Sep05 TH added
         Heap act, id, "tSpecialty", Trim$(trans.specialty), 0
         Heap act, id, "tSpecialtyXML", Trim$(XMLEscape(trans.specialty)), 0     '22Sep05 TH added
         Heap act, id, "tPrescriber", Trim$(trans.Prescriber), 0
         Heap act, id, "tDircode", Trim$(trans.dircode), 0
         Heap act, id, "tDircodeXML", Trim$(XMLEscape(trans.dircode)), 0         '22Sep05 TH added
         Heap act, id, "tKind", Trim$(trans.kind), 0
         Heap act, id, "tSite", Trim$(trans.site), 0
         Heap act, id, "tLabeltype", Trim$(trans.labeltype), 0
         Heap act, id, "tContainers ", Trim$(trans.containers), 0
         Heap act, id, "tEpisode", Trim$(trans.Episode), 0
         Heap act, id, "tEventNumber", Trim$(trans.EventNumber), 0
         Heap act, id, "tPrescriptionNum", Trim$(trans.PrescriptionNum), 0
         Heap act, id, "tBatchNum", Trim$(trans.BatchNum), 0
         Heap act, id, "tExpiryDate", Trim$(trans.ExpiryDate), 0
         Heap act, id, "tPPflag", Trim$(trans.PPflag), 0
         Heap act, id, "tStocklvl", Trim$(trans.stocklvl), 0
         Heap act, id, "tCustordno", Trim$(trans.custordno), 0
         Heap act, id, "tCustordnoXML", Trim$(XMLEscape(trans.custordno)), 0  '22Sep05 TH added
         Heap act, id, "tCivastype", Trim$(trans.civastype), 0
         Heap act, id, "tCivasamount ", Trim$(trans.civasamount), 0
         Heap act, id, "tTransactionID ", Format$(trans.TransactionID), 0
         success = True
      End If


End Sub
Function XMLEscape(ByVal strSource As String) As String
'------------------------------------------------------------------------
' Purpose:  Takes a source string and returns the source string with
'           any illegal XML characters replaced with their XML Escape
'            Character equivilants
'
' Inputs:   strSource - Source string that require converting to XML format
'
' Outputs:  None
'
' Return :  Result of the source string converted to XML format
'
' Revision History
' 04Sep02 PH Created
' 22Sep05 TH Moved from v9 to v8 to allow XML escaping. Simplified error handling
'05Oct05 CKJ Instead of changing 1 char to 3 chars then to 5 chars with string overheads,
'            Do the move in one go them slice the final string for efficiency.
'            Also replaced """" for clarity
'------------------------------------------------------------------------

Dim nbsp4$

   nbsp4$ = String$(4, 160) & "$"       'four non-breaking spaces and a $ - just to be a unique string

   On Error Resume Next
   'replace strSource, "&", Chr(160) & "$" & Chr(160), 0
   'replace strSource, Chr(160) & "$" & Chr(160), "&amp;", 0
   'replace strSource, """", "&quot;", 0

   replace strSource, "&", nbsp4$, 0             'replace 1 char  with 5 -> slow
   replace strSource, nbsp4$, "&amp;", 0         'replace 5 chars with 5 -> fast
   replace strSource, Chr$(34), "&quot;", 0
   replace strSource, "'", "&apos;", 0
   replace strSource, "<", "&lt;", 0
   replace strSource, ">", "&gt;", 0
   replace strSource, "£", "&#163;", 0           '15Apr14 TH Added for eHub integration
   XMLEscape = strSource

   On Error GoTo 0

End Function

Sub PutTextFileAppend(pathfileext$, txt$, success%)
'Write txt$ to filepathext$. intended for RTF but can be any text
'Returns success=T/F
'05Jul08 TH Written. As PutTextFile, but for append (no way)


Dim chan%
   
   success = False
   On Error GoTo PutTextFileAppend_Err
   chan = FreeFile
   Open pathfileext$ For Append As #chan
   Print #chan, txt$;
   Close #chan
   success = True

PutTextFileAppend_Exit:
   On Error GoTo 0
Exit Sub

PutTextFileAppend_Err:
Resume PutTextFileAppend_Exit

End Sub

Sub OrderOutput(Ordlog As orderlogstruct, ByVal WOrderlogID As Long, ByVal blnPSO As Boolean)
'28Mar06 PJC Written for EDS cardiff integration based on TransactionOutput
'26Feb09 TH Ported for UHB SAGE Interface solution (F0032689)
'21Jul10 TH Added functionality to allow appends to existing file (F0077944)
'03Mar14 TH Added ability to exclude PSO from standard outputs
'03Mar14 TH If PSO run then only include PSO orders.Should use all PSO specific Settings

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
Dim RTFTxt$ '21Jul10 TH Added (F0077944) - this is used in the new batching requirement where an append is necessary

Dim strPSOPrefix As String
''Dim PSOOrd As orderstruct
Dim str_eHubType As String
Dim str_eHubPatient As String

Dim intSuccess As Integer  '04Jan17 TH

   If blnPSO Then
      strPSOPrefix = "PSO"
      If Ordlog.PSORequestID < 1 Then Exit Sub
      ''getorder PSOOrd,Ordlog.
      ''FillHeapPSOrderInfo gPRNheapID,
   Else
     If TrueFalse(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "N", "ExcludePSOOrders", 0)) And Ordlog.PSORequestID > 0 Then Exit Sub
   End If
   'Check the type of order record is correct.
   If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "D", strPSOPrefix & "OrderKinds", 0), Ordlog.kind) > 0 Then

         'Get the supplier Code
         getsupplier (Ordlog.supcode), 0, intFound, lclsup
                                                                
         'Check that the supplier type is speicified in the ini file
         If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "E", strPSOPrefix & "SupplierTypes", 0), lclsup.suppliertype) > 0 Then
               
               'Check that the supplier method type is speicified in the ini file
               strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMT", strPSOPrefix & "MethodTypes", 0)
               strMethodTypes = TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strMethodTypes, strPSOPrefix & "MethodTypes" & Ordlog.kind, 0) '18Mar09 TH Added to allow filtering by kind and method (UHB)
               'If InStr(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "DFEIMT", "MethodTypes", 0), lclsup.Method) > 0 Then
               If InStr(UCase$(strMethodTypes), UCase$(lclsup.Method)) > 0 Then
               
                     'Put the supplier information on the heap
                     
                     FillHeapSupplierInfo gPRNheapID, lclsup, 0
                     FillHeapDrugInfo gPRNheapID, d, 0

                     'Put log stuff on heap
                     FillHeapOrderLogInfo gPRNheapID, Ordlog, WOrderlogID, 0
                     
                     If getBatchOrderOutputFileName() <> "" Then
                        'New batching just parse the detail and append
                        strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "UHBOrdData.rtf", strPSOPrefix & "BatchDataRTFFile", 0)
                        'strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, "RTFFile" & Ordlog.kind, 0) '03Mar09 TH Added
                        'eHUB - Here we will need to differentiate between Devices, medicines and services and output seperate templates
                        If TrueFalse(TxtD(dispdata & "\winord.ini", "eHUBIntegration", "N", "EHubOrderLineTransferPrint", 0)) And (m_eHubHeapID > 0) And blnPSO Then
                           Heap 11, m_eHubHeapID, "PatientSpecificOrderType", str_eHubType, 0
                           Select Case UCase$(str_eHubType)
                              Case "MEDICINAL": strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, "eHubBatchDataRTFFile_Medicinal", 0)
                              Case "SERVICE": strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, "eHubBatchDataRTFFile_Service", 0)
                              Case "EQUIPMENT": strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, "eHubBatchDataRTFFile_Equipment", 0)
                           End Select
                           'OK Now we need to record the patient if not already in the patient block for the header
                           'Heap 11, gPRNheapID, "psoNHNumber", str_eHubPatient, 0
                           Heap 11, gPRNheapID, TxtD(dispdata$ & "\PSO.INI", "OrderLogInterface", "eHubHealthCareNumberUnformatted", "eHubPatientIdentifier", 0), str_eHubPatient, 0  '25Jun14 TH Now uses unformatted field - these need to match or we get duplicates in the header - made configurable incase we need to change the template
                           If InStr(str_eHubPatientBlock, "PatientReference id=" & Chr(34) & "_" & str_eHubPatient) = 0 Then
                              'We need to add this patient
                              
                              'GetTextFile (dispdata & "\" & TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "eHubOrderPatientOutput.rtf", "eHubOrderPatientOutputRTFFile", 0)), RTFTxt$, 0
                              GetRTFTextFromDB (dispdata & "\" & TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "eHubOrderPatientOutput.rtf", "eHubOrderPatientOutputRTFFile", 0)), RTFTxt$, 0 '06Dec16 TH Replaced (TFS 157969)

                              ParseItems gPRNheapID, RTFTxt$, 0
                              ParseItems m_eHubHeapID, RTFTxt$, 0
                              str_eHubPatientBlock = str_eHubPatientBlock & RTFTxt$
                              RTFTxt$ = "" 'Clear
                           End If
                        End If
                        If strRTFFile <> "" Then
                           strRTFFile = dispdata & "\" & strRTFFile
                           GetRTFTextFromDB strRTFFile, RTFTxt$, intSuccess  '04Jan17 TH Move here for check (Hosted)
                           'If fileexists(strRTFFile) Then
                           If intSuccess Then
                              'GetTextFile strRTFFile, RTFTxt$, 0
                              'GetRTFTextFromDB strRTFFile, RTFTxt$, 0 '06Dec16 TH Replaced (TFS 157969)

                              'Read the local file.
                              ParseItems gPRNheapID, RTFTxt$, 0
                              
                              'PSO Additional parse
                              If m_eHubHeapID > 0 Then ParseItems m_eHubHeapID, RTFTxt$, 0
   
                              'write RTFTxt$
                              PutTextFileAppend getBatchOrderOutputFileName(), RTFTxt$, 0
                           
                           Else
                              'popmessagecr "", "Generic Interface Incorrectly configured - Order Export File Not Found"    '09Apr09 TH Added after CKJ review
                              popmessagecr "", "Generic Interface Incorrectly configured - Order Export RTF Not Found"    '09Apr09 TH Added after CKJ review
                           End If
                        Else
                           popmessagecr "", "Generic Interface Incorrectly configured - Order DataExport File not specified"   '09Apr09 TH Added after CKJ review
                        End If
                     Else
                     'Output the file
                     strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "", strPSOPrefix & "RTFFile", 0)
                     strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", strRTFFile, strPSOPrefix & "RTFFile" & Ordlog.kind, 0) '03Mar09 TH Added
                     If strRTFFile <> "" Then
                        strRTFFile = dispdata & "\" & strRTFFile
                        'GetRTFTextFromDB strRTFFile, RTFTxt$, intSuccess  '04Jan17 TH Move here for check (Hosted)
                        'If fileexists(strRTFFile) Then
                        'If intSuccess Then
                        If RTFExistsInDatabase(strRTFFile) Then '24Jan17 TH Replaced above linesReworked wth new function (Hosted)
                           strFilename = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", "", strPSOPrefix & "ExportFilePath", 0)
                           If strFilename <> "" Then
                              'strFile = strFilename
                              If DirExists(strFilename) Then
                                 'Now get a pointer to ensure unique file
                                 strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "OrderLogInterface", dispdata$ & "\OrderInt.dat", strPSOPrefix & "InterfacePointerFile", 0)
                                 GetPointerSQL strPointerFilename, lngPointer, True
                                 Heap 10, gPRNheapID, "OutputRefNoPad", Format$(lngPointer), 0
                                 '19Mar09 TH Replaced filname handling and added suffix
                                 'strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "O", "FilePrefix", 0) & Space$(3), 3))
                                 'strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer)
                                 '14Sep10 TH Added for UMMC
                                 If TrueFalse(TxtD(dispdata$ & "\Genint.ini", "", "N", "UMMCOutputFileName", 0)) Then  '07Sep10 TH Added section to enure name is correct for UMMC (FINV) (F0054531)
                                    If Ordlog.kind = "R" Then
                                       strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_GRN_", "FilePrefixReceipt", 0))
                                    ElseIf Ordlog.kind = "E" Then '06Aug10 TH Reinstated as kind check for releasing credit note batch file with correct file name
                                       strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_GRN_", "FilePrefixCredit", 0))
                                    Else
                                       strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "PIS_PR_", "FilePrefixOrder", 0))
                                    End If
                                    'strFilename = strFilename & "\" & strFilePrefix & Format$(Now, "YYYYMMDDHHNNSS") & "_" & Format$(lngPointer, "00")
                                    strFilename = strFilename & "\" & strFilePrefix & Format$(Now, "YYYYMMDDHHNNSS") & "_" & Right$(Format$(lngPointer, "00"), 2) '28Sep10 TH Added
                                 Else
                                    strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "O", strPSOPrefix & "FilePrefix", 0))
                                    'strFilename = strFilename & "\" & strFilePrefix & Left$("0000000000", 10 - (Len(Format$(lngPointer)))) & Format$(lngPointer)
                                    strFilename = strFilename & "\" & strFilePrefix & Format$(lngPointer, "0000000000")
                                    strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", "", strPSOPrefix & "Filesuffix", 0))
                                    If Ordlog.kind = "A" Then
                                       strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixAdjust", 0))
                                    ElseIf Ordlog.kind = "R" Then
                                       strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixReceipt", 0))
                                    ElseIf Ordlog.qtyord < 0 Then
                                       strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixCredit", 0))
                                    Else
                                       strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", strFilesuffix, strPSOPrefix & "FilesuffixOrder", 0))
                                    End If
                                 End If
                                 strFilename = strFilename & strFilesuffix
                                 strFilename = strFilename & TxtD(dispdata$ & "\GenInt.INI", "OrderlogInterface", ".xml", strPSOPrefix & "OutputFileExtension", 0)
                                 
                                 
                                 'Parse the file
                                 'parseRTF strRTFFile, strOutfile
                                 parseRTFfromDB strRTFFile, strOutfile '04Jan17 TH Now use rtf in DB (Hosted)

                                 
                                 On Error GoTo OrderOutput_Err
                                 FileCopy strOutfile, strFilename
                                    
                                 'remove the file afterwards
                                 On Error Resume Next
                                 If fileexists(strOutfile) Then Kill strOutfile
                                 On Error GoTo 0
                              Else
                                 popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Export File Path Not Found"
                              End If
                           Else
                              popmessagecr "", "Generic Interface Incorrectly configured - Export File Path required"
                           End If
                        Else
                           'popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Export File Not Found"    '09Apr09 TH Added after CKJ review
                           popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Export RTF Not Found"    '09Apr09 TH Added after CKJ review
                        End If
                     Else
                        popmessagecr "", strPSOPrefix & " Generic Interface Incorrectly configured - Order Export File not specified"  '09Apr09 TH Added after CKJ review
                     End If
                     End If
                  End If
            End If
      End If
OrderOutput_Exit:
   Exit Sub

OrderOutput_Err:
   strMsg = "An error has occurred in procedure : OrderOutput" & crlf & crlf '09Apr09 TH Altered after CKJ review
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\OrderOutput.log", SiteNumber, UserID$, strMsg
   Resume OrderOutput_Exit

End Sub

Sub FillHeapOrderLogInfo(ByVal HeapID As Integer, olog As orderlogstruct, ByVal WOrderlogID As Long, success As Integer)
'26Feb09 TH Ported from V8 (F0032689)
'28Apr09 TH Added XML fields for interfacing
'02Sep10 TH Added DeliveryNoteReference for UMMC FINV (F0054531)
'06Sep10 TH Added olQtyOrdfromRec for UMMC FINV interface as qtyord in "R" type isnt actually qtyordered (F0054531)
'07Sep10 TH Added new formatted order date using configurable seperator (dd+<sep>+mm+<sep>+YYYY) for UMMC/FINV (F0054531)

Dim strDatexml As String
Dim strTimeXML As String
Dim id As Integer
Dim act As Integer
Dim strDateSep As String
Dim strSep As String

   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
         Heap act, id, "olWOrderlogID", Format$(WOrderlogID), 0  '18Mar09 TH
         Heap act, id, "olRevisionlevel ", Trim$(olog.revisionlevel), 0
         Heap act, id, "olOrderNum", Trim$(olog.ordernum), 0
         Heap act, id, "olSisCode", Trim$(olog.SisCode), 0
         Heap act, id, "olConvfact", Trim$(olog.convfact), 0
         Heap act, id, "olIssueUnits", Trim$(olog.IssueUnits), 0
         Heap act, id, "olDispid", Trim$(olog.dispid), 0
         Heap act, id, "olTerminal", Trim$(olog.terminal), 0
         Heap act, id, "olTerminalXML", Trim$(XMLEscape(olog.terminal)), 0 '28Apr09 TH Added
         
         Heap act, id, "olDateord", Trim$(olog.dateord), 0

         '07Sep10 TH Added for UMMC/FINV (F0054531)
         strSep = TxtD(dispdata$ & "\winord.ini", "defaults", "/", "HeapDateSeperator", 0)
         strDateSep = Right$(Trim$(olog.dateord), 2) & strSep & Mid$(Trim$(olog.dateord), 5, 2) & strSep & Left$(Trim$(olog.dateord), 4)
         Heap act, id, "olDateordSep", strDateSep, 0

         'strDatexml = Right$(Trim$(olog.dateord), 4) & "-" & Mid$(Trim$(olog.dateord), 3, 2) & "-" & Left$(Trim$(olog.dateord), 2)
         strDatexml = Left$(Trim$(olog.dateord), 4) & "-" & Mid$(Trim$(olog.dateord), 5, 2) & "-" & Right$(Trim$(olog.dateord), 2) '25Mar0-9 TH Has been swapped in v9 +
         Heap act, id, "olDatexml", strDatexml, 0

         Heap act, id, "olTimeord", Trim$(olog.Timeord), 0
         If Len(Trim$(olog.Timeord)) > 0 Then
            strTimeXML = Left$(Trim$(olog.Timeord), 2) & ":" & Mid$(Trim$(olog.Timeord), 3, 2)
         Else
            strTimeXML = ""
         End If
         Heap act, id, "olTimexml", strTimeXML, 0
         Heap act, id, "olDaterec", Trim$(olog.daterec), 0
         Heap act, id, "olTimerec", Trim$(olog.Timerec), 0
         Heap act, id, "olQtyOrd", Trim$(olog.qtyord), 0
         Heap act, id, "olQtyOrdInIssueUnits", Trim$(Val(olog.qtyord) * Val(olog.convfact)), 0  '04Mar14 TH Added
         Heap act, id, "olQtyRec", Trim$(olog.qtyrec), 0
         Heap act, id, "olCost", Trim$(olog.cost), 0
         Heap act, id, "olCostExVAT", Trim$(olog.CostExVAT), 0
         Heap act, id, "olCostExVAT/100", Format$(Val(olog.CostExVAT) / 100, "0.00"), 0  '19Mar09 TH Added
         
         Heap act, id, "olLineCost/100", Format$((Val(olog.cost) * Val(olog.qtyord)) / 100, "0.00"), 0
         Heap act, id, "olLineCostExVAT/100", Format$((Val(olog.CostExVAT) * Val(olog.qtyord)) / 100, "0.00"), 0
         
         Heap act, id, "olVATCost", Trim$(olog.VATcost), 0
         Heap act, id, "olVATCost/100", Format$(Val(olog.VATcost) / 100, "0.00"), 0
         Heap act, id, "olTotalVATCost/100ABS", Format$(Abs((Val(olog.qtyord) * Val(olog.VATcost))) / 100, "0.00"), 0 '29Mar09 TH Added (abs is to handle returns with positive value for UHB Interfacing)
         Heap act, id, "olVATCode", Trim$(olog.VatCode), 0
         Heap act, id, "olVATRate", Trim$(olog.vatrate), 0
         Heap act, id, "olKind", Trim$(olog.kind), 0
         Heap act, id, "olSupCode", Trim$(olog.supcode), 0
         Heap act, id, "olSupCodeXML", Trim$(XMLEscape(olog.supcode)), 0 '28Apr09 TH Added
         Heap act, id, "olSite", Trim$(olog.site), 0
         Heap act, id, "olBatchNum", Trim$(olog.BatchNum), 0
         Heap act, id, "olBatchNumXML", Trim$(XMLEscape(olog.BatchNum)), 0  '28Apr09 TH Added
         Heap act, id, "olExpiryDate", Trim$(olog.ExpiryDate), 0
         '26Mar09 TH Added XML Date (UHB)
         strDatexml = Right$(Trim$(olog.ExpiryDate), 4) & "-" & Mid$(Trim$(olog.ExpiryDate), 3, 2) & "-" & Left$(Trim$(olog.ExpiryDate), 2)
         Heap act, id, "olExpiryDateXML", strDatexml, 0
         Heap act, id, "olInvnum", Trim$(olog.invnum), 0
         Heap act, id, "olInvnumXML", Trim$(XMLEscape(olog.invnum)), 0 '28Apr09 TH Added
         Heap act, id, "olDate3", Trim$(olog.Date3), 0
         Heap act, id, "olTime3", Trim$(olog.Time3), 0
         Heap act, id, "olQty3", Trim$(olog.Qty3), 0
         Heap act, id, "olInfo", Trim$(olog.Info), 0
         Heap act, id, "olLinkedNum", Trim$(olog.LinkedNum), 0
         Heap act, id, "olReasonCode", Trim$(olog.ReasonCode), 0
         Heap act, id, "olStocklvl", Trim$(olog.stocklvl), 0
         Heap act, id, "olDeliveryNoteReference", Trim$(olog.DeliveryNoteReference), 0    '02Sep10 TH Added for UMMC FINV (F0054531)
         Heap act, id, "olDelno", Trim$(olog.DeliveryNoteReference), 0                    '    "
         '06Sep10 TH Added for UMMC FINV interface as qtyordered in "R" type isnt actually qtyordered (hmmm) (F0054531)
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "QtyOrderedonHeapReceiptLog", 0)) And UCase$(Trim$(olog.kind)) = "R" Then
            Heap act, id, "olQtyOrdfromRec", Format$(getQuantityOrderedFromReceiptLog(olog.supcode, olog.SisCode, olog.ordernum)), 0
         Else
            Heap act, id, "olQtyOrdfromRec", "", 0
         End If
         
         Heap act, id, "olNSVCode", Trim$(olog.SisCode), 0
         Heap act, id, "olOrdernum", Trim$(olog.ordernum), 0
         Heap act, id, "olContractNumber", Trim$(m_ContractNumber), 0   '02Apr14 TH Added (eHub)
         success = True
      End If


End Sub
Sub setHistoryPrescription(ByVal blnHistoryPrescription As Boolean)
'22May09 TH Written(F0040489)
'14Jan10 TH renamed : was setDispensingReturn but this didnt read logically
   m_blnHistoryPrescription = blnHistoryPrescription

End Sub

Public Function getHistoryPrescription() As Boolean
'22May0- TH Written(F0040489)
'14Jan10 TH renamed : was getDispensingReturn but this didnt read logically

   getHistoryPrescription = m_blnHistoryPrescription

End Function
Sub setBatchOrderOutputFileName(ByVal strBatchOrderOutputFileName As String)
'21Jul10 TH Written(UHB)(F0077944)
   m_strBatchOrderOutputFileName = strBatchOrderOutputFileName
   
End Sub
Public Function getBatchOrderOutputFileName() As String
'21Jul10 TH Written(UHB)(F0077944)

   getBatchOrderOutputFileName = m_strBatchOrderOutputFileName

End Function
Public Function getQuantityOrderedFromReceiptLog(ByVal strSupCode As String, ByVal strNSVCode As String, ByVal strOrderNumber As String) As Single
'06Sep10 TH Written(UMMC FINV) (F0054531)
Dim strParams As String
Dim rsResult As ADODB.Recordset
Dim sglResult As Single

   sglResult = 0
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, strSupCode) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
               gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, Val(strOrderNumber))
   Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWorderlogQtyOrderedforReceipt", strParams)
   If rsResult.RecordCount > 0 Then
      rsResult.MoveFirst
      sglResult = RtrimGetField(rsResult!qtyordered)
   End If
   rsResult.Close
   Set rsResult = Nothing
   
   getQuantityOrderedFromReceiptLog = sglResult

End Function
Public Sub setRepeatBatchID(ByVal RepeatBatchID As Long)
'17Apr12 TH Added

 m_RepeatBatchID = RepeatBatchID
 
End Sub
Public Sub setNHNumberData(ByVal NHNumber As String, ByVal NHNumberValid As Integer)
'26Apr12 TH Added
'This is used to store any NH Number data to allow it to be accessible for the translog write
'routines. NHNumbervalid is an integer as it needs to be tri-state so we can record null in the db
'0 = null (untested), 1 = True (tested and valid) , 2 = false (tested and invalid)

   m_NHNumber = NHNumber
   m_NHNumberValid = NHNumberValid
 
End Sub

Public Sub setContractData(ByVal strContractNumber As String, ByVal strContractPrice As String, ByVal blncontract As Boolean)
'26Apr12 TH Added
'This is used to store any Contract data to allow it to be accessible for the Orderlog write routines.
   
   m_ContractNumber = strContractNumber
   m_ContractPrice = strContractPrice
   m_Contract = blncontract
   
End Sub

Sub TakeStockFromBatchbyBatchNumber(NSVCode$, Qty!, batchnumber$, expiry$)
'01Jul12 TH Written for DLO - takes a known batch and reduces the qty accordingly
'           Needed as a batch cld be received and then imediately issued out automatically
'           to an identified ward

Dim strParams As String
Dim rsBatchStock As ADODB.Recordset
Dim blnOK As Boolean
Dim BatchQty As Single
Dim lngOK As Long
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode$) & _
               gTransport.CreateInputParameterXML("BatchNumber", trnDataTypeVarChar, 25, batchnumber$)
   
   Set rsBatchStock = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLevelbySiteIDNSVCodeandBatchNumber", strParams)
   
   If rsBatchStock.RecordCount > 0 Then
      rsBatchStock.MoveFirst
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
         gTransport.CreateInputParameterXML("WBatchstockLevelID", trnDataTypeint, 4, GetField(rsBatchStock!WBatchStockLevelID)) & _
         gTransport.CreateInputParameterXML("Qty", trnDataTypeFloat, 4, Qty)
      lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWBatchStockLevelUpdateQty", strParams)
   End If
         
   rsBatchStock.Close
   
   Set rsBatchStock = Nothing

End Sub

Sub setm_QAQty(ByVal intQAQty As Integer)
'24Jun13 TH Written (TFS 48388)

 m_intQAQty = intQAQty
 
End Sub
Function getm_QAQty() As Integer
'24Jun13 TH Written (TFS 48388)

   getm_QAQty = m_intQAQty
   
End Function

Sub PutWardListID(ByVal WardListID As Long)
'30Dec14 TH Written

   m_WWardProductListItemID = WardListID

End Sub
Sub setm_lngWardStockTopUpLevel(ByVal lngWardStockTopUpLevel As Long)
'07Jan15 TH Added to allow a check on top up level for Ward Stock Issue (TFS 102826)
'09Jul16 TH Renamed and changed to long (TFS 157679)

 m_lngWardStockTopUpLevel = lngWardStockTopUpLevel
 
End Sub
Sub seteHUBHeapID(ByVal eHubHeapID As Integer)
   m_eHubHeapID = eHubHeapID
End Sub
Function get_str_eHubPatientBlock() As String
'01Apr14 TH eHub

   get_str_eHubPatientBlock = str_eHubPatientBlock
   
End Function
Sub set_str_eHubPatientBlock(ByVal strPatientBlock As String)
'01Apr14 TH eHub

   str_eHubPatientBlock = strPatientBlock
End Sub

Sub GetWLookupCode(ByVal StrOriginalFile As String, ByVal Code As String, ByRef lookup As String, ByVal blnMultiLineLabelFormat)
'29Jun17 TH Written to standardise calls and implement some caching TFS 191443

Dim rs As ADODB.Recordset
Dim strParam As String
Dim Context() As String
Dim iLoop As Integer
Dim strItemSearch As String
Dim strValue As String
Dim intFound As Integer


Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetInsCode"

   On Error GoTo ErrorHandler

   lookup = ""
   
    'First lets see if we have this cached
    If LookupHeapId = 0 Then Heap 1, LookupHeapId, "WLookUps cache", "", 0
   
    strItemSearch = CStr(gDispSite) & "|" & StrOriginalFile & "|" & Trim$(Code)
                                                           
    Heap 11, LookupHeapId, strItemSearch, strValue, intFound                    'check the item cache for the item
    If intFound Then
        lookup = strValue
    Else
        'Loop through and set an array and then use this to set the params for the new single shot DB call
        ReDim Context(3)
        For iLoop = 1 To 3
           Context(iLoop) = ASCContextName(StrOriginalFile, (iLoop > 1), Iff(iLoop > 2, 44, 0))
        Next
        strParam = gTransport.CreateInputParameterXML("siteid", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 10, Code) & _
                   gTransport.CreateInputParameterXML("context1", trnDataTypeVarChar, 255, Context(1)) & _
                   gTransport.CreateInputParameterXML("context2", trnDataTypeVarChar, 255, Context(2)) & _
                   gTransport.CreateInputParameterXML("context3", trnDataTypeVarChar, 255, Context(3))
        Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteriaforMultiContext", strParam)
        
        If Not rs Is Nothing Then
           If rs.State = adStateOpen Then
              If rs.RecordCount <> 0 Then
                 lookup = RtrimGetField(rs!Value)
                 If blnMultiLineLabelFormat Then
                    replace lookup, crlf, Chr$(LBL_END_LINE), 0
                 End If
              End If
           End If
        End If
        Heap 10, LookupHeapId, strItemSearch, lookup, 0
    End If
    

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup


End Sub

Function GetLookupHeapId() As Integer
'29Jun17 TH Added (TFS 191443)

'To return the ID of the Loukup heaps for cache dumps
   GetLookupHeapId = LookupHeapId

End Function
Sub SetLookupHeapId(ByRef intLookupHeapId As Integer)
'29Jun17 TH Added (TFS 191443)

'To return the ID of the Loukup heaps for cache dumps
   LookupHeapId = intLookupHeapId

End Sub
