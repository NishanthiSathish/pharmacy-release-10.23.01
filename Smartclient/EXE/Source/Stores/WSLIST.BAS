Attribute VB_Name = "WSLIST"
'DOStoWIN V1.0 (c) ASCribe 1996
'-------------------------------------------------------------------------------
'
'                          Ward Stock List Program
'                         -------------------------
'-------------------------------------------------------------------------------
'modification history
'--------------------
' 8Apr89 CKJ converted to QB4 from \STOCKL\WSLIST.BAS 19790 5-02-88 12:30pm
'21Apr89 CKJ the test of open KEY now removed
'30Apr89 CKJ minor tidying of code, the horrors remain
'30Sep89 CKJ cls on wayout, no clock, printcentred, antihack, chain      V4.1
'12Oct89 CKJ no cls on wayout
' 2Dec89 CKJ Started to convert to procedure based input routines & windows
'27Dec89 CKJ Ideas for the page handling/editing system ...
'  V4.2       each time the page is displayed, it only needs to know the top
'             line of that page. It also needs to place the cursor on the
'             current line, and to display no more than the num of lines in
'             the file;
'            TOPLIN = line to be at top of screen
'            CURLIN = line to be edited
'            LASTLIN = line number of last used line
'            CLIPBRD = 1st line of clipboard up to & including maxlin
'            MAXLIN = max size of ward which can be handled
'            REDRAW = T/F True to force complete redraw of screen
'11Jan90 CKJ V4.2 released for beta testing
'16Jan90 CKJ Added the ward code & DCT facilities from DCTWAR
'20Jan90 CKJ Minor tidying
'27Jan90 CKJ V4.2 á - all facilities now in place
'28Jan90 CKJ Date on printed list now formatted corectly
'16Mar90 CKJ Uses inputmenu                                              V4.2
'16May90 CKJ Length of Title now up to 50 chars                          V4.21
'22May90 CKJ uses getyesornocr                                           V4.21
'10Jun90 CKJ Filename checking tightened up. Released as ...             V4.22
'18Aug90 CKJ catno checking bug fixed - used cat$ not Drug.catno         V4.23
'16Oct90 CKJ Issue of stock items added                                  V5.0
'17Oct90 ASC Returns added, stock level now shown when issueing
'23Oct90 ASC Issues singles rather than multiples and always multiplies
'            by the pack size. Return window changed to avoid problem on
'            XT
'24Oct90 ASC method of issueing now does not take account of pre-pack etc.
'            some tiding done
'22Nov90 ASC drugs now added by code if wanted.
'20Dec90 ASC insert and delete subs changed to ckjinsert and ckjdelete
'            to avoid use of bc7 ISAM commands
'26Mar91 CKJ BCR support added
'27Mar91 CKJ First menu removed - offers new ward in the list
'   V5.1     Keyfile not needed - reads directory directly each time
'            Barcode Return available on shift-F9
'14Dec91 CKJ NSV code editing requires acclevels of >= 2
'   V5.3     Colour of ward name corrected
'            quantity inc from 2 to 3 chars
'            packsize inc from 3 to 4 chars
'            stockl structure moved to include file
'            Version number decided by Infobar
'            Removed momory size data from File info - it's on Alt-F1
'            Ward code now validated, no issue/return unless valid, view
'            ward name expansion on [F10] File Info.
'27Jan91 ASC loadvatrates added (one line only)
' 7Feb92 CKJ BCR Issue more user friendly - see Issue in Subpatme
'            Find next added on shift-F3
'23Feb92 CKJ Acclevel>=3 needed for delete stocklist
'            Fixed bug in save ward, when illegal filename entered
' 6Apr92 CKJ Mods made to accommodate Oldham; disable PRODINFO.V5 lookup etc.
'09Jun92 ASC Added column (kept only on memory of qty last issued) for display
'29Jul92 ASC Maxqty!=0 added to parameter line for issue in line with ordermnu.exe
'            changes
'15Nov92 CKJ Installed PrnDrvr. Textual changes in PrepareIssue.
'23Dec92 ASC Added escd to printl and ltype$ to issue
' 2Nov93 CKJ VBDOS: Move => MoveV
'10Jan94 CKJ Added Index for W issues & allowed CD issues to ask cost centre
'11Jan94 CKJ Added stock valuation & ^F4 drug enquiry
'14Jan94 ASC Linenum rather that 0 added to idx to make binarysearchidx work
' 7Mar94 ASC Stockpath removed from dim share
' 7Mar94 CKJ acclvl 1=no save 2=save 3=edit catno 4=delete stocklist
'18Jan95 CKJ Added erase labelline$()
'19Jan95 CKJ Added siteinfo default
'27Jan95 CKJ Saveward mod, index retries if locked
'20Mar95 CKJ Added progsdrv
'24Mar95 CKJ Moved Close
'17Apr95 ASC Memory probs therefore stopped dimming of prodind etc.
'20Jun95 CKJ Added editform
'21Feb96 EAC turn on cursor after a FindDrug form has been shown
'31May96 EAC add file locking
'--------EAC Converted to windows
'29Aug97 EAC add packsize handling  (4Sep97 CKJ Mods merged)
'16Oct97 EAC Various changes in LoadWard to try to speed it up
'17Oct97 EAC Added Adhoc Issue facility
'21Oct97 EAC ADDLINE: Speed up by creating array for all password levels
'            and then create MDB entry if neccessary
'            Correct BlockMove SQL to stop it screwing up the ScreenPosn field
'29Aug97 EAC InsertLine: speeded up inserting of line by not reloading ward
'18Nov97 CKJ Addline, Insertline: Do not show stores only items - this makes it
'            work as it did in DOS.
'10Dec97 EAC CreateRequisitionRecord: update outstanding quantity
'10Dec97 EAC CreateDeliveryNoteRecord: update outstanding quantity
'23Dec97 EAC WardInputWin: set max and min characters for input box
'30Dec97 EAC Allow picking tickets for wards to be printed using "8 x100" instead of "800"
'08Jan98 EAC LoadWard: Overcome 300 limit on wards by using standard AskSupplier routine
'16Jan98 EAC Handle Printing in Packs'
'02Feb98 EAC HandleWardIssue: Added formatting of text so that fractions are display with leading zero
'05Mar98 ASC wslist.bas: AdhocIssue: Now blanks ward code and drug name.
'            askward: Now only allows W & L type suppliers.
'            HandleWardIssue: Corrected quantity calc when printing in packs.
'            LoadWard: 05Mar98 ASC Now no longer takes the selection types from from windord.ini.
'                      procedure asksupplier also removed as we now call 'askward'.
'            PrepareIssue: Label now shows last issue qty.
'            WardInputWin: Now unloads text window.
'26Mar98 CFY LoadWard: Removed above mod in LoadWard and re-enstated original code.
'26Mar98 EAC PrepareIssue:
'              - All labels now print the correct ward code
'              - Label not printed if issue aborted
'              - label array cleared before label text from editor is inserted into it
'                to prevent duplicate lines at end of label
'31Mar98 CFY PrepareIssue: Added getdrug before the first issue box appears so that
'            the name of the drug can be displayed.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'05May98 CFY BlockInsert: Added Error traps to stop subscript out of range error occuring when attempting
'              to paste when there is nothing in the paste buffer. Also now inserts the drugs packsize.
'              Also added a DoEvents/Freelocks within the main loop to help prevent items being saved
'              in the wrong order.
'            BlockMove: Added DoEvents/Freelocks after each of the update queries to make sure that each
'              update has been committed to the database before the next update begins. This is
'              because each of the updates relies on the results of the previous one and if an update
'              fires before the previous update has finished, the move will probably change the wrong
'              records.
'07May98 EAC DeleteLines: use screen posn from MDB that is stored in Drugs.posn instead of inferring from screen posn
'07May98 EAC InsertLine: stop a stock level of zero and a last issue qty of zero being added for title lines
'07May98 EAC BlockMove: Stop marquee disappearing back to start of list
'07May98 EAC UpdateLine: Ensure correct MDB ScreenPosn is used
'                        Ensure that local code is set if drug is change in local code field
'18May98 EAC make LoadWard handle wards with corrupt indexes correctly
'            NB - Layout table in WSLIST.MDB now requires a new Index called SiteName
'26May98 CFY Renamed procedure from LoadWard to LoadWardOld. This procedure is now
'            redundant.
'26May98 CFY Renamed procedure from LoadWardOld to LoadWard. This procedure has now
'            been reinstated.
'26May98 CFY PrepareIssue: Now puts secondary warning code rather than the primary warning code on the label.
'09Jun98 CFY InsertLine: Fix to stop to .posn field in the drug array becoming out of sync with the actual screen
'            positions.
'11Jun98 CKJ PrepareIssue: removed multiplication of pack size * quantity as it is inappropriate
'12Jun98 EAC HandleWardIssues: Correct creation of delivery notes when PrintInPacks is true
'12Jun98 EAC HandleWardIssues: Ask user if returns to be added to a delivery note overriding settings in supplier file.
'23Jun98 EAC HandleWardIssues: added dp! to quantity calculations to prevent e numbers
'25Jun98 EAC PrepareIssues: removed mod of 12Jun98 as LastIssueQty now correctly set in HandleWardIssue
'25Jun98 EAC HandleWardIssues: Added LabelIssueQty to simplify code and reduce calculations
'            PrepareIssues: printing of label now uses LabelIssueQty returned from HandleWardIssues
'26Jun98 CFY PrepareIssues: Corrected handling of barcode issuing.
'22Jul98 CFY PrepareIssue: Calculation of costs now corrected. Was previously dividing the quantity
'            issued by the packsize. This was a problem as the quantity value may have
'            already been divided by the packsize depending upon whether printpickingtickets
'            or printdelivery notes had been selected and printinpacks was set to True.
'27Jul98 TH  DeleteLines: Added description to delete line message to try and avoid user confusion
'29Jul98 TH  AdhocEntry: Added msgbox for invalid ward entry
'24Aug98 TH  AdhocIssue:Added extra error flag to differentiate
'24Aug98 TH  Askward:   between cancel and non-existent ward
'28Aug98 TH  AdHocIssue: Added Warning msgbox if ward is not in use
'01Sep98 CFY PrepaerIssue: Now adds VAT to the cost printed no the label.
'22Sep98 TH  HandleWardissue: Added Check on site defaults for printing of delivery notes
'30Oct98 EAC PrepareIssue: CostCentre was never being set for L type wards with no cost centre defined.
'09Nov98 CFY PrepareIssue: The text 'Ward Stock' that is added to the end of the label is now no longer hard
'              coded, but is picked up from an ini file setting instead/
'17Nov98 TH  PrepareIssue: In issueing now checks for "to follows"
'19Nov98 TH  HandleWardissue: Check on PrintDeliverynotes not PrintPickingTickets in Site Defaults
'23Nov98 TH  PrepareIssue: Now writes last issued date to drug file
'07Dec98 TH  HandleWardissue: Simplified check on site defaults
'03Dec98 CKJ/TH CreateDeliveryNoteRecord: Set picking ticket number to 0 to avoid locking problems
'18Jan99 SF  PrepareIssue: Now doesn't allow an issue from a list to a ward that is set to not inuse
'20Jan99 CFY Moved WardInputWin to supplier.bas
'21Jan99 EAC AdHocIssue: Handle printing of stock labels
'22Jan99 TH  InsertLine: Added error trapping for non 8.1 configured wslist.mdb
'15Feb99 SF  adhocissue: if issuing to a list and no ward code setup then user must choose a cost centre
'08Mar99 TH  HandleWardissue: Skip Print label box if not marked P in ward stock list
'07Apr99 TH  HandleWardissue: Allow stocklabel printing from wslists if printpickingtickets set to Y
'15Apr99 TH  HandleWardissue: Removed above mod because it was wrong
'20Apr99 TH  HandleWardissue: Issue now used for WardStock issueing with PTs so that Stocklabels can be printed
'21Apr99 TH  HandleWardissue: Properly handle escaping from wards with PTs
'26Apr99 TH  HandleWardissue: Properly handle escaping from wards without PTs
'30Apr99 TH  HandleWardissue: Changed action parameter to flag non picking ticket wards
'12May99 TH  PrintStockLabels: Parse colour codes out of instructions
'08Jul99 TH  PrepareIssue: Lastissued field now updated in Translog
'09Jul99 TH  PrintStockLabels: Replaced storesdescription with description on stocklabel
'20Jul99 TH  PrintStockLabels: Get actual qtys from issue screen to put on stocklabels
'26Aug99 TH  CreateDeliveryNoteRecord: Ensure delnote is blank before building new record
'26Aug99 TH  CreateRequisitionRecord: Ensure requisition is blank before building new record
'20Oct99 TH  HandleWardissue: Ability to print labels without issue (on escape from issue screen)
'21Oct99 TH  HandleWardissue: Put message box prompt before above option
'02Nov99 TH  AddLine: Also add Barcode to mdb
'11Nov99 TH  PrepareIssue: Ensure passlevel one issues are correctly recorded to mdb
'23Nov99 AE  PrintStockLabels:Added Kill to remove local files
'02Dec99 TH  HandleWardissue: Added switch for non RTF printing of wardstocklabels
'02Dec99 TH  PrintOldStocklabels: Written - Reinstated old code form handlewardissue to allow non RTF wardstocklistprinting
'06Dec99 TH  PrintStockLabels: Use new unique context for Ward Stock Labels
'07Dec99 TH  PrintStockLabels: Puts only drug description details in drug* elements - was retaining warning info in redundant lines
'08Dec99 TH  HandleWardissue: Pick up nonrtf setting from terminal name in terminal.ini
'23Feb00 TH/mma/vs insertline: stops type mismatch
'23feb00 VS/MMA/TH printstocklabels: Check if return and if so put neg qty on label
'01Mar00 TH  CreateRequisitionRecord: Added User ID for info screens
'06Mar00 SF  HandleWardIssue: now puts the requisition number on the heap for when printing ward stock labels
'06Mar00 SF  DeleteLines: writes a ward stock list deletion event for Pyxis
'08Mar00 TH/MMA printstocklabels: added to allow number of containers to label = 0
'08Mar00 SF  DeleteLines: fixed logic to 06Mar00 Pyxis mod
'22Mar00 TH  Printstocklabels: corrected above (merge error)
'29Mar00 TH  AddhocIssiue:Added flush of K.validchars because was sometimes previously set by other routines and not flushed correctly
'30Mar00 TH  PrintStockLabels: Mods to correctly calculate costs (positive or negative)
'06Apr00 MMA AdhocIssue: changed to read "from" instead of "to" (event no. 42843)
'14Apr00 MMA/AW PrintStocklabels: Costs shown as -ve values for returns and +ve values for issues
'02May00 EAC InsertLine: event 38211: clear drug if drug not found.
'19Apr00 TH  Printstocklabels: Change to way costs are put on labels
'26Jun00 JN  BlockInsert: Added code to include barcode when copying to list
'29Jun00 JN  InsertLine: Checks user has sufficient privileges to insert lines
'07Jul00 JN  DeleteLines: Added code to prevent 'Type Mismatch' error
'20Jul00 TH  AddLine: APrevent Type Mismatch on adding descriptor line
'23Oct00 TH  PrintStockLabels: Exit sub if called with no labels to print (47216)
'17Jan01 AW  AdhocIssue: added string variable to display "to" if issue or "from" is return (event 49274)
'28Mar01 TH  EditWardCode: Reinitialised ability to change wardcode, but only for L type suppliers (Lists) (#50548)
'28Mar01 TH  SaveAsNewWard: Altered code sent in to enable correct save (#50545)
'19Jun01 TH  SaveAsNewWard: Retain packsize from original wslist (#52393)
'24sep01 CKJ Merged:
'01Sep01 TH  PrepareIssue: Changed input parameter to checktofollows (#52924)
'09Oct01 TH  PrepareIssue: Moved timing of call to checktofollows so as to accomodate any user entered cost centre (#52924)
'31Oct01 TH  AdhocIssue: Added ability to create Del note if supplier set up to do so when adhoc issuing/returning (enh1302)
'09Jan02 TH  PrepareIssue: Stop ability to print stock labels on return from the wardstocklist (#37539)
'11Jan02 TH  AdhocIssue: Blank CustOrdNo to stop any pre-existing variable being written to  logs (#50776)
'23Jan02 TH  AdhocIssue: Enabled AdhocIssue for lvl 5 password (#52055)
'23Jan02 TH  DisplayPage: Change caption for ward stock level 5 (#52055)
'23Jan02 TH  LoadWard: Added level 5 for wardstock (#52055)
'25Feb02 TH  AdhocIssue: Added ability for possible entry of custordno on adhoc return (enh1585)
'27Feb02 TH  BlockCut: Written as amalgam of copy and delete (enh1463)
'11Apr02 TH  PrepareIssue: Blank CustOrdNo to stop any pre-existing variable being written to logs on ward stock issue (#50776)
'11Apr02 TH  SortMarkedBlock: Added mod to retain original grid position (#17751)
'31May02 TH  HandleWardIssue: Added new parameter to CreateDeliveryNoteRecord call
'31May02 TH  AdhocIssue: Added mod to allow for the inclusion of an assigned picking ticket number to a delivery note from adhoc
'            issue - the same number will be assigned for a complete session per supplier
'31May02 TH  CreateDeliveryNoteRecord: Added new parameter enabling a picking ticket number to be supplied from adhocIssues where delnotes are created.
'17Jul02 TH  AdhocIssue: Inform the user of any assigned picking ticket number if required
'06Aug02 TH  AdhocIssue: Mod to add the increment of delnote.dat after read, not to increment at point of getting number,
'            also, added space to message to allow for better readability
'31Mar04 CKJ {SP1}
'            Removed support for non EAN13 barcodes
'17May04 ckj WSlist: removed sethelp
'19Oct06 TH  PrepareIssue: Fencepost stockline update for passlvls 1 and 5 (SC-06-0999)

'20May08 CKJ call MechDispClearLabelData
'20Oct08 TH  AddLine,LoadWard,InsertLine: Fix to barcode handling (F0037033)
'23Apr09 TH  UpdateLineSQL: InsertLine: SarAllSQL:  Added trim around titletext (F0038841)
'23Apr09 TH  PrepareIssue: Added to prevent leading space (F0036816)
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 chars based on config setting (F0051906)
'19May10 TH  AddLine,InsertLine: Now allow stores only products to also be available for ward stock addition (F0055971)
'            However, this was explicitly turned off before, so I have put this on a setting with
'            the original behaviour (ie no stores only items) as default
'01Mar11 TH  HandleWardIssue: CD Book Number recording Merged from V8 (F0089265)
'01Jun11 CKJ Changed DefInt to DefBool and uncovered missing type declarations in ReadWard, LoadWard
'            Removed deprecated BlockMove and associated global BlockOpPending
'            Ditto WSLIST (replaced by WSLISTSQL), FindRecord, UpdateLine
'02Jun11 CKJ finalusedline: removed as not used
'27Jun11 CKJ SWAPdrug: Unused - removed
'14Aug14 TH  PrintStockLabelsSQL: suppress preview (TFS 97937)
'25Sep14 XN  CreateDeliveryNoteRecord Prevent crash if pick number too large (TFS 99425)
'08Jan15 TH  PrepareIssue: Added call to cache wardstockline item to ensure it can be used in translog for straight issue (TFS 106426)
'08Jan15 TH  PrepareIssue: Added section to ensure new list is updated on straight issue - this will then be refreshed web side. (TFS 103886)
'16Jan15 TH  HandleWardIssue: Altered requisition message (TFS 108421)
'22Jan15 TH  PrepareIssue: Mods to allow list handling (especially lists not linked to wards/cost centers) (TFS 102821)
'10Feb15 TH  PrepareIssue: Dont switch dispdatas if from the ocx - now we can use none site specific list (TFS 110251)
'10Feb15 TH  PrepareIssue: Only update wsl DB if actually issued - we still use the qty as an output param tho (TFS 111027)
'06Jul16 XN  PrepareIssue: Fixed issue with dispensing to ward stock list lines with id over 32000 (157521)
'            concat: Made input parameter long (157521)
'09Jul16 TH  PrepareIssue: Renamed topuplevel variable and changed to long (TFS 157679)
'05Aug16 KR  Bug 159577: Pharmacy Stock lists - issuing of Stores only products
'04Jan17 TH  PrintStockLabelsSQL: Use DB Parsing (Hosted) (TFS 157969)
'05Jan17 TH  SpecificStockLabelLayout: Replaced RTF Handling (Hosted) (TFS 157969)
'26Jan17 TH  SpecificStockLabelLayout: Replaced fileexists to use DB (Hosted) checking (TFS 174442)
'08May17 TH  CreateRequisitionRecord: Remove the check on supplier/ward PT Setting for DLO (TFS 182083)

'mods needed
'-----------
'could do with a secure way of deleting an entire file - done
'help numbers are a bit arbitrary - need revision & documenting - done
'would like to print with barcodes, but there really isn't room,
' suggest the user copies marked block to clipboard, makes new file,
' pastes & then prints using PRILIST.
'need barcode issue to be keyboard-less                               - almost
'interface to REQUIS needed
' Editline, s as kbdcontrol, tab1-5 - none appear to be actually used
'  in fact most module level variables are never used      18Nov97 CKJ
' R as filerecord - global already                         18Nov97 CKJ

'----------------------------------------------------------------------------------------------

Option Explicit
DefBool A-Z

Const modulename$ = "WSLIST.BAS"

'global variables, arrays etc
Global warddispdata As String, dispdatastore As String
Global lngWardSiteID As Long 'SQL ADDED
Global WardStockLoaded As Integer   '//// review using this against txtinput.visible
Global drugs() As drugdetails
Global ward$, wardcode$, wardexp$
Global WardStockPasslvl%
Dim strWardFullName As String

Dim blankdrug As drugdetails
'Dim maxlin As Integer, curlin As Integer, lastlin As Integer         '31Mar04 CKJ {SP1} added type declaration    '//// should be Long 6Jul16 XN yes should of been long
Dim maxlin As Long, curlin As Long, lastlin As Long
'Dim blkst As Integer, BlkEnd As Integer                             '02Jun11 CKJ Not actually set to anything - removed
'Dim Changed As Integer                                              '02Jun11 CKJ Set but then never used - removed

Dim clipbored() As drugdetails
Dim badward% '24Aug98 TH Extra errorflag in Askward

Dim PrintStockLblsByDefault As Integer       '21Jan99 EAC determines if Print Stock Lables check box is checked by default

Sub AskNSVCode(ans As String, escd As Integer, title$)

    If Trim$(title$) = "" Then title$ = "Enter item code or label text."
    'ask user for drug
    setinput 0, k
    k.escd = False
    InputWin "Input Item", title$, ans$, k

    escd = k.escd

End Sub

Sub AskTitleText(title As String, escd As Integer)

    setinput 0, k
    k.Max = 56
    k.escd = False
    InputWin "New Title", "Enter Title Text", title$, k

    escd = k.escd

End Sub

Sub askward(title$, Code$, escd%, ByVal strFilter As String)
'05Mar98 EAC/ASC Now only allows W & L type suppliers
'24Aug98 TH  Added extra error flag to differentiate between cancel and non-existent ward

Dim lngFound  As Long

   escd% = False

   WardInputWin title$, "Enter ward code or press Shift - F1 for a list of codes.", Code$, k, "1"
   If k.escd Then escd% = True

   If Not k.escd Then
      getsupplier Code$, 0, lngFound, sup
      If lngFound <> 0 Then
         If Not (sup.suppliertype = "W" Or sup.suppliertype = "L") Then
            escd = True
            popmessagecr "Can not display", Code$ & " is not a ward or list."
         End If
      Else
         badward% = True
         escd = True
      End If
   End If
   k.escd = False

End Sub

Sub blockcopy()
'-----------------------------------------------------------------------------
'                     Copy marked block to the clipboard
'                      See undelete for the principles
'
'02Jun11 CKJ Removed OMarked()
'-----------------------------------------------------------------------------
Dim numtocopy As Long, loopvar As Long

   'search the array of marked items
'   For loopvar = LBound(OMarked) To UBound(OMarked)  02Jun11 CKJ
'      If OMarked(loopvar) Then                          "

   For loopvar = 1 To MainScreen.lvwMainScreen.ListItems.count
      If MainLVWIsItemSelected(loopvar) Then
         numtocopy = numtocopy + 1
         ReDim Preserve clipbored(numtocopy)
         LSet clipbored(numtocopy) = drugs(loopvar)
      End If
   Next

   'ReDim OMarked(1 To ONumToDisplay) 'clear all marked lines
   MainLVWRemoveSelection      '02Jun11 CKJ
   MainScreen.lvwMainScreen.Refresh

End Sub

Sub blockcut()
'-----------------------------------------------------------------------------
'                     Cut marked block to the clipboard
'                     See undelete for the principles
'
'27Feb02 TH Written as amalgam of copy and delete (enh1463)
'02Jun11 CKJ Removed OMarked()
'-----------------------------------------------------------------------------
Dim numtocopy As Long, loopvar As Long
Dim BlkStart&, BlkEnd&
Dim valid%

   'search the array of marked items
'   For loopvar = LBound(OMarked) To UBound(OMarked)
'      If OMarked(loopvar) Then
   
   For loopvar = 1 To MainScreen.lvwMainScreen.ListItems.count
      If MainLVWIsItemSelected(loopvar) Then
         numtocopy = numtocopy + 1
         ReDim Preserve clipbored(numtocopy)
         LSet clipbored(numtocopy) = drugs(loopvar)
      End If
   Next

   DimensionBlock BlkStart, BlkEnd, valid
   If valid Then DeleteLines BlkStart, BlkEnd, True

   'ReDim OMarked(1 To ONumToDisplay) 'clear all marked lines
   MainLVWRemoveSelection      '02Jun11 CKJ
   MainScreen.lvwMainScreen.Refresh

End Sub

Sub BlockInsert(currentpos As Long)
'05May98 CFY Added Error traps to stop subscript out of range error occuring when attempting
'            to paste when there is nothing in the paste buffer. Also now inserts the drugs packsize.
'            Also added a DoEvents/Freelocks within the main loop to help prevent items being saved
'            in the wrong order.
'
'26Jun00 JN  Modified routine to copy barcode along with rest of the clipboard information
'04Jan06 TH  Made a couple of cjanges to ensure the update and the insert keep screenposn integrity
'15Jun12 TH  Removed last issue date and daily issue from insert, this will now be inserted as a blank (TFS36185)
Const procname$ = "BlockInsert"

Dim loopvar%, foundPtr&, found%, success%, escd%    '01Jun02 ALL/ATW
Dim resumeval%, retries%
Dim strParams As String
Dim strBarcode As String
Dim lngReturn As Long
Dim blnOK As Boolean
Dim lngPosition As Long

   If currentpos& = 0 Then currentpos& = 1
       
   On Error GoTo BlockInsert_Exit        '05May98 CFY Added
   
   
   '15Dec14 TH - Update screen to make way for block
   'Refacctored now for new structures
''   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
''               gTransport.CreateInputParameterXML("ClipboardPosn", trnDataTypeint, 4, UBound(clipbored)) & _
''               gTransport.CreateInputParameterXML("CurrentPosn", trnDataTypeint, 4, currentpos& + 1) & _
''               gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
''
''   blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListBlockScreenPosnUpdate", strParams)
   
   strParams = gTransport.CreateInputParameterXML("ClipboardPosn", trnDataTypeint, 4, UBound(clipbored)) & _
               gTransport.CreateInputParameterXML("CurrentPosn", trnDataTypeint, 4, currentpos& + 1) & _
               gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, sup.SupplierID)

   blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardProductListBlockScreenPosnUpdate", strParams)
   
   lngPosition = MainScreen.lvwMainScreen.SelectedItem.Index
   
   For loopvar = 1 To UBound(clipbored)
      strBarcode = ""
      If Trim$(clipbored(loopvar).catno) <> "&" Then     '26Jun00 JN Moved code within If statement around to accommodate addition of barcode
         foundPtr = 0
         findrdrug clipbored(loopvar).catno, 1, d, foundPtr&, found%, False, False, False
         ''''SQL !!! TO DO ???       UpdateWardDrugFile clipbored(loopvar).catno, foundPtr&
         ''       temptbl("Barcode") = "*" & Trim$(d.BarCode) & "*"   '26Jun00 JN Added line to store Barcode in Db
         strBarcode = "*" & Trim$(d.barcode) & "*"
      End If
      On Error GoTo BIUpdateTableErr
'      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
'                  gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, ((currentpos& + loopvar))) & _
'                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(clipbored(loopvar).catno)) & _
'                  gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(clipbored(loopvar).drugttl)) & _
'                  gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
'                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$) & _
'                  gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(clipbored(loopvar).stklevl)) & _
'                  gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
'                  gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(clipbored(loopvar).paksize)) & _
'                  gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, clipbored(loopvar).lastissue) & _
'                  gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, clipbored(loopvar).localcode) & _
'                  gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
'                  gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, Val(clipbored(loopvar).dailyissue)) & _
'                  gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
      '15Jun12 TH Replaced above (TFS36185)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                  gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, ((currentpos& + loopvar))) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(clipbored(loopvar).catno)) & _
                  gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(clipbored(loopvar).drugttl)) & _
                  gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$) & _
                  gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(clipbored(loopvar).stklevl)) & _
                  gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(clipbored(loopvar).paksize)) & _
                  gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, "") & _
                  gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, clipbored(loopvar).localcode) & _
                  gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
                  gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
                  
      '15Dec14 TH Refactored to use new structures
''      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
''                  gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, ((currentpos& + loopvar))) & _
''                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(clipbored(loopvar).catno)) & _
''                  gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(clipbored(loopvar).drugttl)) & _
''                  gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
''                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$) & _
''                  gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(clipbored(loopvar).stklevl)) & _
''                  gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
''                  gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(clipbored(loopvar).paksize)) & _
''                  gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, "") & _
''                  gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, clipbored(loopvar).localcode) & _
''                  gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
''                  gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
''                  gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
''
''      lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardStockList", strParams)
      strParams = gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, ((currentpos& + loopvar))) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(clipbored(loopvar).catno)) & _
                  gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, Trim$(clipbored(loopvar).drugttl)) & _
                  gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
                  gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(clipbored(loopvar).stklevl)) & _
                  gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(clipbored(loopvar).paksize)) & _
                  gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeDateTime, 8, Null) & _
                  gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
                  gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, sup.SupplierID)
   
      lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardProductListLine", strParams)
      On Error GoTo 0
   Next
    
   LoadWard success, escd, False
   ChangeTable "blank", False  '14Aug12 TH Added Param   '17Oct05 TH swiz to help resizing
   DisplayPage
   MainLVWHighlightSingleRowByIndex lngPosition
BlockInsert_Exit:                                                    '05May98 CFY Added

Exit Sub

BIUpdateTableErr:

   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
   End Select
   
End Sub

'Function concat$(lin As Integer)  06Jul16 XN 157521
Function concat$(lin As Long)
'-----------------------------------------------------------------------------
'                Returns all parts of a line concatenated
'              All on 1 line is not aesthetically pleasing,
'             but it reduces string handling, and is faster.
'01Jun11 CKJ added as integer
'06Jul16 XN converted paremeter to integer to handle issues with new ward stock list 157521
'-----------------------------------------------------------------------------

   concat$ = RTrim$(drugs(lin).drugttl) + RTrim$(drugs(lin).stklevl) + RTrim$(drugs(lin).paksize) + RTrim$(drugs(lin).prepack) + RTrim$(drugs(lin).catno)

End Function

Sub CreateDeliveryNoteRecord(quantity!, UnitCost$, costcentre$, ByVal intPickno As Long)
'Sub CreateDeliveryNoteRecord(quantity!, UnitCost$, costcentre$, ByVal intPickno As Integer) ' 25Sep14 XN 99425 prevent crash if pick number too large
'10Dec97 EAC Update outstanding quantity
'15Dec97 CKJ/EAC Corrected handling of quantity!
'16Jan98 EAC do not update outstanding for the drug
'04May98 CKJ replaced tempord() array with simple tempord
'03Dec98 CKJ/TH Set picking ticket number to 0 to avoid locking problems
'26Aug99 TH Ensure delnote is blank before building new record
'31May02 TH Added new parameter enabling a picking ticket number to be supplied from adhocIssues where delnotes are created.

Dim tempord As orderstruct
'Dim picktickno   '31May02 TH Removed
Dim orderptr&

   'ReDim tempord(1) As orderstruct
   
   'getorderno 7, picktickno, True '03Dec98 CKJ/TH removed
   'picktickno = 0                  '03Dec98 CKJ/TH  '31May02 TH Removed

   '''getnumofords 7, orderptr&, True  'get next record in requis.asc
   
   ''''getorder tempord, orderptr&, 7, True

   blankorder tempord   '26Aug99 TH Ensure delnote is blank before building new record
   
   tempord.Code = d.SisCode
   'tempord.orddate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
   tempord.orddate = thedate(False, True) '03May98 CKJ Y2K
   tempord.ordtime = thedate(0, -2)  '11Oct05 TH Added
   tempord.loccode = d.loccode
   'tempord.supcode = sup.code
   tempord.supcode = costcentre$
   tempord.status = "7"
   tempord.cost = LTrim$(Str$(dp!(Val(UnitCost$))))
   'tempord.pickno = picktickno     '31May02 TH Replaced
   tempord.pickno = intPickno       '   "
   'tempord.ward = sup.code
   'tempord.ward = CostCentre$   '05may98 CKJ ward field not required
   tempord.received = LTrim$(Str$(dp!(quantity!)))
   tempord.qtyordered = tempord.received
   tempord.outstanding = "0"
   'tempord.recdate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
   tempord.recdate = tempord.orddate '03May98 CKJ Y2K
   
   orderptr& = PutOrder(tempord, 0, "WRequis") 'TH Force insert by passing 0 in
   ''If ReadPrivateIniFile(dispdata$ & "\winord.ini", "Logging", "PickingTickets") = "Y" Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, date & Time & " supcode : " & tempord.supcode & " recnum : " & Str$(orderptr&) & " Adding index record from CreateRequisitionRec": IndexDebug = True '05Feb99 TH Debuggery '04May99 TH merged from 8066
   '''updateordreqindex 7, "", tempord.code, "", costcentre$, orderptr&
   ''If IndexDebug Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, "Successful"   '06Feb99 TH Debuggery '04May99 TH Merge
   '16Jan98 EAC should not update outstanding for the drug

End Sub
Sub CreateDeliveryNoteRecordSQL(quantity!, UnitCost$, costcentre$, ByVal lngPickno As Long, ByVal blnDLO As Boolean)

Dim tempord As orderstruct
Dim orderptr&

   blankorder tempord
   
   tempord.Code = d.SisCode
   tempord.orddate = thedate(False, True)
   tempord.ordtime = thedate(0, -2)  '11Oct05 TH Added
   tempord.loccode = d.loccode
   tempord.supcode = costcentre$
   tempord.status = "7"
   tempord.cost = LTrim$(Str$(dp!(Val(UnitCost$))))
   tempord.pickno = lngPickno       '   "
   tempord.received = LTrim$(Str$(dp!(quantity!)))
   tempord.qtyordered = tempord.received
   tempord.outstanding = "0"
   tempord.recdate = tempord.orddate
   tempord.rectime = tempord.rectime  '11Oct05 TH Added

   tempord.DLO = blnDLO  '05Jul12 TH Added
   
   orderptr& = PutOrder(tempord, 0, "WRequis") 'TH Force insert by passing 0 in
End Sub
Sub CreateRequisitionRecord(quantity!, ordernum$, costcentre$)
'29May12 TH For DLO. This routine should capture CE machines creating PTs
'           or wardstock issues creating PTs. Here we just mark as DLO ready
'           to create the order when we would normally issue


Dim tempord As orderstruct
Dim orderptr&
Dim updateqty!
    
   ''getnumofords 5, orderptr&, True  'get next record in requis.asc
   ''getorder tempord, orderptr&, 5, True

   ''If ReadPrivateIniFile(dispdata$ & "\winord.ini", "Default", "CatchInters") = "Y" And tempord.internalmethod = "I" Then MsgBox "Successfully intercepted possible INTER - Please report to ASC"    '26Aug99 TH Fingers crossed

   blankorder tempord   '26Aug99 TH Ensure requisition is blank before building new record
   
   tempord.Code = d.SisCode
   tempord.outstanding = Trim$(Str$(quantity!))
   'tempord.orddate = Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
   tempord.orddate = thedate(False, True) '03May98 CKJ Y2K
   tempord.ordtime = thedate(0, -2)  '11Oct05 TH Added
   tempord.loccode = d.loccode
   tempord.supcode = costcentre$
   tempord.status = "5"
   tempord.num = Trim$(ordernum$)
   tempord.pickno = 0
   'tempord.ward = CostCentre$            '05may98 CKJ ward field not required
   tempord.recdate = ""    '15Dec97 CKJ/EAC removed Mid$(Date$, 4, 2) + Mid$(Date$, 1, 2) + Right$(Date$, 2)
   tempord.qtyordered = Trim$(Str$(quantity!))

   tempord.CreatedUser = Trim$(UCase$(UserID$)) '01Mar00 TH Added User ID for info screens

   orderptr& = PutOrder(tempord, 0, "WRequis") 'TH Force insert by passing 0

   ''updateordreqindex 5, "", tempord.code, "", tempord.num, orderptr&
   ''If ReadPrivateIniFile(dispdata$ & "\winord.ini", "Logging", "PickingTickets") = "Y" Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, date & Time & " supcode : " & tempord.supcode & " recnum : " & Str$(orderptr&) & " Adding index record from CreateRequisitionRec": IndexDebug = True '05Feb99 TH Debuggery '04May99 TH Merged from 8066
   ''updateordreqindex 7, "", "", "", tempord.supcode, orderptr&
   ''If IndexDebug Then WriteLog dispdata$ & "\picktick.log", 0, UserID$, "Successful"   '06Feb99 TH Debuggery '04May99 TH Merge
   '10Dec97 EAC
   '15Dec97 CKJ/EAC modified
   '16Jan98 EAC Handle Printing Packs for Ward Requisitions
   updateqty! = quantity!
   If Not PrintInPacks Then updateqty! = updateqty! / Val(d.convfact)
   updateoutstanding updateqty!, d
   '---
    
End Sub
Sub CreateRequisitionRecordSQL(quantity!, ordernum$, costcentre$, ByVal lngLayoutID As Long)
'29May12 TH Check if item is DLO - record and order if necessary
'28Mar13 TH Added param to check DLO against specific line (TFS 58711)
'18Dec14 TH Added Write to new req field to record the wsline from which this was raised (if any)
'08May17 TH Remove the check on supplier/ward PT Setting for DLO (TFS 182083)
      
Dim tempord As orderstruct
Dim orderptr&
Dim updateqty!
Dim blnDLO As Boolean
Dim lclsup As supplierstruct

   
   blnDLO = CheckDLOItem(d.SisCode, costcentre$, lngLayoutID) '29May12 TH '28Mar13 TH Added param (TFS 58711)
   
   '22Jun12 TH Further switches and checks
   If blnDLO Then
      
      '08May17 TH Here we need to derive the supplier from the ward list if there is a wardlistID -After discussion we just remove the check on supplier/ward (TFS 182083)
      'getsupplier costcentre$, 0, 0, lclsup
      'If (Not (TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0))) Or (lclsup.PrintPickTicket <> "Y")) Then blnDLO = False  '22Nov12 TH TFS 49691 Ensure default is off
      If Not (TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0))) Then blnDLO = False   '06May17 TH Replaced above
   
   End If
   
   blankorder tempord
   
   tempord.Code = d.SisCode
   tempord.outstanding = Trim$(Str$(quantity!))
   tempord.orddate = thedate(False, True)
   tempord.ordtime = thedate(0, -2)  '11Oct05 TH Added
   tempord.loccode = d.loccode
   tempord.supcode = costcentre$
   tempord.status = "5"
   tempord.num = Trim$(ordernum$)
   tempord.pickno = 0
   tempord.recdate = ""
   tempord.qtyordered = Trim$(Str$(quantity!))

   tempord.CreatedUser = Trim$(UCase$(UserID$))
   tempord.DLO = blnDLO  '29May12 TH
   
   tempord.WWardProductListLineID = lngLayoutID  '18Dec14 TH Added to record the wsline from which this was raised (if any)
   
   orderptr& = PutOrder(tempord, 0, "WRequis")

   updateqty! = quantity!
   If Not PrintInPacks Then updateqty! = updateqty! / Val(d.convfact)
   updateoutstanding updateqty!, d
   
   
    
End Sub

Sub DeleteLines(StartRow As Long, EndRow As Long, blnAuto As Integer)
'03Dec97 EAC stop subscript out of range error when deleteing last item from list
'07May98 EAC use screen posn from MDB that is stored in Drugs.posn instead of inferring from screen posn
'27Jul98 TH  Added description to delete line message to try and avoid user confusion
'06Mar00 SF  writes a ward stock list deletion event for Pyxis
'08Mar00 SF  fixed logic to 06Mar00 Pyxis mod
'07Jul00 JN  Added code to prevent 'Type Mismatch' error when deleting blank lines with Pyxis set to TRUE
'17Feb02 TH  Added Auto parameter for cut option on wslist (enh1463)
'03Oct06 TH  Added mod to stop deletion of no line !!(SC-06-0561)
'15Dec14 TH  Refactor for use with new ward stock DB structures

Const procname$ = "DeleteLines"

Dim loopvar%
Dim SQL$, ans$, msg$
Dim tempdrugs() As drugdetails
Dim resumeval%, retries%
Dim arraysize%
Dim StartMdbPosn&, EndMdbPosn&
Dim NSV$, Qty!
'''Dim objdata As clsDataAccess
Dim strParams As String
Dim blnOK As Boolean

   setinput 0, k
   k.escd = False
   If StartRow& = EndRow& Then
      If Left(drugs(StartRow&).localcode, 1) = Chr(0) Or Trim$(drugs(StartRow&).localcode) = "" Then ' *Seems this field can hold terminators - due to corrupt data ?
         'msg$ = "delete location " & Trim$(drugs(StartRow&).drugttl) & " from file"
         If drugs(StartRow&).LayoutID = 0 Then  '03Oct06 TH Added to stop deletion of no line !!(SC-06-0561)
            k.escd = True                       '    "
         Else                                   '    "
            msg$ = "OK to delete location " & Trim$(drugs(StartRow&).drugttl)  '10Jan05 TH Altered message from above
         End If                                 '    "
      Else
         msg$ = Trim$(drugs(StartRow&).drugttl) & Chr(13) & Chr(13) & "Packsize    " & Trim$(drugs(StartRow&).paksize) & Chr(13) & Chr(13) & "NSVCode   " & Trim$(drugs(StartRow&).localcode) & Chr(13) & Chr(13) & "OK to delete line from file ?"
      End If
   Else
      msg$ = "delete marked lines from file"
   End If

   If Not k.escd Then   '03Oct06 TH Added to stop deletion of no line !!(SC-06-0561)
      If blnAuto Then
         ans$ = "Y"
      Else
         'Confirm "Delete", msg$, ans$, k
         askwin "?Delete", msg$, ans$, k  '10Jan05 TH Added ? Icon
      End If
   End If

   If ans$ = "Y" And Not k.escd Then
      StartMdbPosn& = drugs(StartRow&).posn
      EndMdbPosn& = drugs(EndRow&).posn
            
      ReDim tempdrugs(UBound(drugs) - (EndRow& - StartRow& + 1))
      For loopvar = 1 To StartRow& - 1
         LSet tempdrugs(loopvar) = drugs(loopvar)
         tempdrugs(loopvar).posn = loopvar
      Next
         
      For loopvar = 0 To (UBound(drugs) - EndRow& - 1)
         LSet tempdrugs(StartRow& + loopvar) = drugs(EndRow& + loopvar + 1)
         tempdrugs(StartRow& + loopvar).posn = StartRow& + loopvar
      Next

      'Added for Pyxis Medstation interfacing requirements
      Select Case WardStockPasslvl
         Case 2, 3, 4
            If PyxisSetup(True) Then
               If OnPyxisWard(sup.Code) Then
                  For loopvar = StartRow& To EndRow&
                     NSV$ = Trim$(drugs(loopvar).catno)
                     Qty! = Val(drugs(loopvar).lastissue)      '07Jul00 JN Changed from CDbl to Val
                     If (NSV$ <> "") And (NSV$ <> "&") Then CreatePyxisEvent 2, 0, "", NSV$, Qty!, Trim$(sup.Code)
                  Next
               End If
            End If
      End Select
      
      arraysize = UBound(tempdrugs)
      ONumToDisplay = arraysize
      If arraysize = 0 Then arraysize = 1
      ReDim drugs(1 To arraysize)
      ReDim OInfoStore(1 To arraysize)     '////
      '02Jun11 CKJ: ReDim OMarked(1 To arraysize)
      MainLVWRemoveSelection   '02Jun11 CKJ

      For loopvar = 1 To ONumToDisplay
         LSet drugs(loopvar) = tempdrugs(loopvar)
      Next
         
      Select Case WardStockPasslvl
         Case 1
         Case 2, 3, 4
            'create dynaset of all element in table above the current position
            '15Dec14 TH Refactored to use new structures
            MainScreen.MousePointer = HOURGLASS
''            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
''                        gTransport.CreateInputParameterXML("ScreenPosnStart", trnDataTypeint, 4, StartMdbPosn&) & _
''                        gTransport.CreateInputParameterXML("ScreenPosnEnd", trnDataTypeint, 4, EndMdbPosn&) & _
''                        gTransport.CreateInputParameterXML("Sitename", trnDataTypeVarChar, 5, Trim$(ward$))
''            blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListLineDeletebyScreenPosn", strParams)
            strParams = gTransport.CreateInputParameterXML("ScreenPosnStart", trnDataTypeint, 4, StartMdbPosn&) & _
                        gTransport.CreateInputParameterXML("ScreenPosnEnd", trnDataTypeint, 4, EndMdbPosn&) & _
                        gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, Trim$(sup.SupplierID))
            blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardProductListLineDeletebyScreenPosn", strParams)
            If blnOK Then
               '15Dec14 TH Refactored to use new structures
''               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
''                           gTransport.CreateInputParameterXML("ScreenPosnStart", trnDataTypeint, 4, ((StartMdbPosn& - 1) - EndMdbPosn&)) & _
''                           gTransport.CreateInputParameterXML("ScreenPosnEnd", trnDataTypeint, 4, EndMdbPosn&) & _
''                           gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
''              blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListBlockScreenPosnUpdate", strParams) 'pLayoutLineUpdateScreenPosn
               strParams = gTransport.CreateInputParameterXML("ScreenPosnStart", trnDataTypeint, 4, ((StartMdbPosn& - 1) - EndMdbPosn&)) & _
                           gTransport.CreateInputParameterXML("ScreenPosnEnd", trnDataTypeint, 4, EndMdbPosn&) & _
                           gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, Trim$(sup.SupplierID))
               blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardProductListBlockScreenPosnUpdate", strParams) 'pLayoutLineUpdateScreenPosn
            End If
            MainScreen.MousePointer = 0
         Case Else
      End Select
      
      ChangeTable "blank", False  '14Aug12 TH Added Param   '17Oct05 TH swiz to help resizing
      DisplayPage
      
      If Not MainLVWHighlightSingleRowByIndex(StartRow&) Then                          '11Jul11 CKJ try this row
         MainLVWHighlightSingleRowByIndex MainScreen.lvwMainScreen.ListItems.count     '            fall-back if we couldn't
      End If
   End If
         
Exit Sub

DLUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
      End Select
   
End Sub

Sub DimensionBlock(BlockStart As Long, BlockEnd As Long, Contiguous As Integer)
'02Jun11 CKJ Removed OMarked(). Now uses listview as master for which lines are marked

Dim loopvar As Long
Dim lastlineselected As Boolean, foundfirst As Boolean

   'initialise variables
   Contiguous = True

   BlockStart = 0
   BlockEnd = 0
   'search through marked line array to determine size and location of block
'   For loopvar = LBound(OMarked) To UBound(OMarked)
'      If OMarked(loopvar) Then

   For loopvar = 1 To MainScreen.lvwMainScreen.ListItems.count
      If MainLVWIsItemSelected(loopvar) Then
         If BlockStart = 0 Then BlockStart = loopvar
         If loopvar > BlockEnd Then BlockEnd = loopvar
         If Not foundfirst Then
            foundfirst = True
         Else
            If Not lastlineselected Then
               Contiguous = False
               Exit For
            End If
         End If
         lastlineselected = True
      Else
         lastlineselected = False
      End If
   Next
   
   If BlockStart = 0 And BlockEnd = 0 Then Contiguous = False
   If Not Contiguous Then
      popmessagecr "!Error", "The marked block is not contiguous." & cr & "Please ensure that all lines between the start and" & cr & "the end of the block are selected."
   End If

End Sub

Sub DisplayPage()
'-----------------------------------------------------------------------------
'            Display as much of the current page as possible,
'          starting at topline, & leaving the cursor on curline
' Moving/scrolling/redrawing minimised where possible for rapid updating.
' NB Must assume that curlin has been checked & not out of range!!
'-----------------------------------------------------------------------------
'23Jan02 TH Change caption for ward stock level 5 (#52055)
'27Jun11 CKJ Removed endvar%

Dim tmp$
Dim loopvar&
Dim wndStyle As Long

   ONumToDisplay = UBound(drugs)

   ReDim OInfoStore(1 To ONumToDisplay)      '//// may be zero
   '02Jun11 CKJ: ReDim OMarked(1 To endvar)
   MainLVWRemoveSelection   '02Jun11 CKJ
   
   For loopvar& = 1 To ONumToDisplay
      OInfoStore(loopvar&) = UpdateScreenLine(loopvar&)
   Next
   
   '''MainScreen.lvwMainScreen.Rows = ONumToDisplay
   
   ChangeTable "WardStockList", False '14Aug12 TH Added Param
   tmp$ = strWardFullName & "  ( " & Trim$(wardcode$) & " )"  '10Aug05 TH Added name
   If WardStockPasslvl = 5 Then tmp$ = TxtD(dispdata$ + "\winord.ini", "WardStockList", " Please note that any changes you make will not be saved", "Lvl5Caption", 0) & crlf & wardexp$  '19Oct01 TH Added
   replace tmp$, "&", Chr(160), 0     '10Aug05 TH (#82082)
   replace tmp$, Chr(160), " && ", 0  '10Aug05 TH (#82082)
   MainScreen.LblGrid.Caption = tmp$  '19Oct01 TH now use tmp not wardexp directly
   PositionLblGrid
   
   RefreshLVWMainScreen False, True
   MainLVWHighlightSingleRowByIndex 1
   MainScreen.lvwMainScreen.SetFocus
   
   If MainScreen.lvwMainScreen.Visible = True Then
      ' Retrieve the window style of the control.
      wndStyle = GetWindowLong(MainScreen.lvwMainScreen.Hwnd, GWL_STYLE)
   
      ' Test if the horizontal scroll bar style is present
      ' in the window style, indicating that a horizontal
      ' scroll bar is visible.
      If (wndStyle And WS_HSCROLL) <> 0 Then
          ''MsgBox "A horizontal scroll bar is visible."
         MainScreen.lvwMainScreen.Width = MainScreen.lvwMainScreen.Width + 300 'Nudge out the lstview to make sure we get rid of the critter
      End If
   End If
   
   

End Sub

Sub DisplayWardCodes(Code As String, Caption As String)

Dim pointer&
Dim found%
Dim supcode$, tmp$
Dim loopvar As Long

   For loopvar = 1 To LstBoxFrm.LstBox.ListCount
      LstBoxFrm.LstBox.RemoveItem 0
   Next
   
   'fill combo box in readiness
  '' GetPointer dispdata$ + "\supfile.v5", pointer&, False 'read only
   For loopvar = 2 To pointer&
       getsupplier supcode$, (loopvar), 0, sup
       If Len(Trim$(sup.Code)) > 0 Then
         If UCase$(sup.suppliertype) = "W" Then
            tmp$ = UCase$(sup.Code)
            LstBoxFrm.LstBox.AddItem tmp$
         End If
      End If
   Next
    
   If LstBoxFrm.LstBox.ListCount > 0 Then LstBoxFrm.LstBox.ListIndex = 0
   
   LstBoxFrm.Caption = Caption$
   LstBoxFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   If Trim$(LstBoxFrm.Tag) = "" Then
      k.escd = True
   Else
      k.escd = False
   End If
   Code$ = Left$(LstBoxFrm.LstBox.text, Len(sup.Code))
   Unload LstBoxFrm

End Sub

Sub EditWardCode(title$, msg$, escaped%)
'-----------------------------------------------------------------------------
'                    Enter or update the ward code & DCT No.
'-----------------------------------------------------------------------------
'28Mar01 TH Reinitialised ability to change wardcode, but only for L type suppliers (Lists) (#50548)
'{SP2} Consider removing this proc - it does not seem useful
' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 chars based on config setting (F0051906)

Dim wcwas$, dct$, ans$
Dim tofind% ', supptr%
Dim lngSupptr As Long

   setinput 0, k
   wcwas$ = wardcode$
   dct$ = ""
   
   ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 chars based on config setting (F0051906)
   If Len(wardcode$) = (GetWardCodeLen() + 2) Then dct$ = Left$(wardcode$, 2)
   ans$ = Right$(wardcode$, GetWardCodeLen())
   'If Len(wardcode$) = 6 Then dct$ = Left$(wardcode$, 2)
   'ans$ = Right$(wardcode$, 4)
   ' End of F0051906
    
   msg$ = "Select the new Cost Centre Code"
   If sup.suppliertype <> "L" Then
      popmessagecr "", "This facility is only available for List type Suppliers"
   Else
      asksupplier wardcode$, 0, "W", msg$, False, sup, False '15Nov12 TH Added PSO param
      If Trim$(wardcode$) <> "" Then
         getsupplier ward$, tofind, lngSupptr, sup
         sup.wardcode = wardcode$
         putsupplier lngSupptr, sup
      Else
         wardcode$ = wcwas$
      End If
   End If
                
   escaped = k.escd
   'If wardcode$ <> wcwas$ And Not escaped Then Changed = True          02Jun11 CKJ variable 'Changed' never actually used - should it be? '////
    
End Sub

'02Jun11 CKJ Function not used, although it can be reinstated if anyone wants it
'Function finalusedline()
''------------------------------------------------------------------------------
''       Returns the number of the last line which contains non-spaces
''                      answer is in range 0 to lastlin
''------------------------------------------------------------------------------
'Dim Last%, count%
'
'
'   Last = lastlin
'   If lastlin Then
'      For count = lastlin To 1 Step -1
'         If Len(concat$(count)) Then Exit For
'         Last = count - 1
'      Next count
'   End If
'
'   finalusedline = Last
'
'End Function

Sub findline(findstring As String, o_blnFound As Boolean)   '01Jun02 ALL/ATW
'-----------------------------------------------------------------------------
'                                  FIND

'-----------------------------------------------------------------------------

Dim findlin As Long
Dim temp$

   If Len(findstring) Then
      findstring = UCase$(findstring)
      curlin = MainScreen.lvwMainScreen.SelectedItem.Index
      lastlin = UBound(drugs)
      findlin = curlin
      o_blnFound = False
      Do
         findlin = findlin + 1
         If findlin > lastlin Then findlin = 1
         temp$ = UCase$(concat$(findlin))
         If InStr(temp$, findstring) Then
            curlin = findlin
            o_blnFound = True
            MainLVWHighlightSingleRowByIndex curlin
            Exit Do
         End If
      Loop Until findlin = curlin
   End If

End Sub

Sub findstr(findstring As String)
'-----------------------------------------------------------------------------
'                                  FIND
'Proc name changed from find to findstr to avoid possible clashes with find% etc
'02Jun11 CKJ Removed k.up and k.down which have not been supported for years.
'            Also tidied display
'-----------------------------------------------------------------------------
Dim title$, msg$
Dim blnFound As Boolean

   title$ = "Find"
   msg$ = " Enter string of characters to be found." & crlf & crlf
   msg$ = msg$ & "  Both upper & lower case will be found in any" & crlf
   msg$ = msg$ & "  part of the descriptions, titles, pack sizes, " & crlf
   msg$ = msg$ & "  catalogue numbers, etc. " & crlf & crlf
   msg$ = msg$ & "  Enter string  "
   setinput 0, k
   k.Max = 30
   k.helpnum = 130
   
   InputWin title$, msg$, findstring$, k

'   If k.up Then
'      curlin = 1
'   ElseIf k.down Then
'      curlin = finalusedline()
'   ElseIf Not k.escd Then
'      findline findstring, blnFound
'      If Not blnFound Then popmessagecr "!n!iFind", "Not found"
'   End If

   If Len(Trim$(findstring)) Then
      findline findstring, blnFound
      If Not blnFound Then popmessagecr "!n!iFind", "Not found"
   End If
   
End Sub

Function GetPrintStockLabelsByDefault() As Integer
'21Jan99 EAC written

   GetPrintStockLabelsByDefault = PrintStockLblsByDefault

End Function

Sub HandleWardIssue(quantity!, costcentre$, lastissueqty$, escaped%, WSPackSize$, LabelIssueQty$, PrintLabel%, curline As Long, ByVal blnOCX As Boolean)

'23Dec97 EAC Update to stores description and stores issue
'            Added WSPackSize to parameter list
'29Dec97 EAC Use Stores drug description
'30Dec97 EAC Allow picking tickets for wards to be printed using "8 x100" instead of "800"
'02Feb98 EAC Added formatting of text so that fractions are display with leading zero
'05Mar98 ASC Corrected quantity calc when printing in packs
'12Jun98 EAC Correct creation of delivery notes when PrintInPacks is true
'12Jun98 EAC Ask user if returns to be added to a delivery note overriding settings in supplier file.
'23Jun98 EAC added dp! to quantity calculations to prevent e numbers
'25Jun98 EAC Added LabelIssueQty to simplify code and reduce calculations
'22Sep98 TH  Added Check on site defaults for printing of delivery notes
'19Nov98 TH  Check on PrintDeliverynotes not PrintPickingTickets in Site Defaults
'07Dec98 TH  Simplified check on site defaults
'21Jan99 EAC Use new stock label printing routines to print labels
'            Added PrintLabel parameter to subroutine declaration
'08Mar99 TH  Skip Print label box if not marked P im ward stock list
'07Apr99 TH  Changes to Ward stock issue to allow label printing fro wards with printpicking tickets set to yes
'15Apr99 TH  Removed above mod because it was wrong
'20Apr99 TH  Issue now used for WardStock issueing with PTs so that Stocklabels can be printed
'21Apr99 TH  Properly handle escaping from wards with PTs
'26Apr99 TH  Properly handle escaping from wards without PTs
'30Apr99 TH  Changed action parameter to flag non picking ticket wards
'20Oct99 TH  Ability to print labels without issue (on escape from issue screen)
'21Oct99 TH  Put message box prompt before above option
'02Dec99 TH  Added switch for non RTF printing of wardstocklabels
'07Dec99 TH  Make nonrtf switch terminal specific
'08Dec99 TH  Pick up nonrtf setting from terminal name in terminal.ini
'06Mar00 SF  now puts the requisition number on the heap for when printing ward stock labels
'31May02 TH  Added new parameter to CreateDeliveryNoteRecord call
'01Mar11 TH  CD Book Number recording Merged from V8 (F0089265)
'28Mar13 TH  Added line handling for prepare issue, basically to allow correct identification
'            of DLO items on issue where the same item is on the list multiple times as DLO/None DLO (TFS 58711)
'16Jan15 TH  Altered requisition message (TFS 108421)

Static lastordernum$                                                 '{SP2} consider is static needed

Dim done%, duplicates%, NumLabels%
Dim UnitCost$, batchno$, expdate$
Dim Qty$
Dim ans$
Dim Action%
Dim oldstocklabels%, Tname$
Dim specificlayout As Integer

'01Mar11 TH Merged from v8
Dim strCDNum As String
Dim strWards As String
'01Mar11 TH ---

Dim lngLayoutID As Long '28Mar13 TH Added (TFS 58711)


   oldstocklabels = False
   Heap 10, gPRNheapID, "CDNum", "", 0    'Initialise 10Dec04 TH Added  '01Mar11 TH Merged from v8
   Tname$ = TxtD$("C:\ASCTERM.INI", "", "", "TerminalName", 0)
   If Tname$ <> "" Then
      If UCase$(TxtD$(dispdata$ + "\terminal.ini", Tname$, "RTF", "WSLblLPTtype", 0)) <> "RTF" Then
         oldstocklabels = True
      End If
   End If
   escaped = False

   If Sgn(quantity!) = True Then
      If UCase$(sup.PrintDeliveryNote) = "Y" Then
        'Confirm "Return", "to show this item on a Delivery note", ans$, k
        Confirm "Return", "show this item on a Delivery note", ans$, k '03Jan05 TH removed superfluous to
        If Not k.escd And UCase$(Trim$(ans$)) = "Y" Then
            sup.PrintPickTicket = "N"
            sup.PrintDeliveryNote = "Y"
         Else
            sup.PrintPickTicket = "N"
            sup.PrintDeliveryNote = "N"
         End If
      Else
         sup.PrintPickTicket = "N"
      End If
   End If
   
   If sup.PrintPickTicket = "N" Then
      'issue from dispensary, using robot if necessary and printing in robot if supported
      If PrintLabel Then
         Action = 207

         '16oct06 CKJ added block   31Dec07 CKJ Ported block from V8.7
         specificlayout = SpecificStockLabelLayout(d.SisCode, costcentre$, "")
         If specificlayout = 0 Then                '0 absent, 1 default, 2 ward, 3 drug, 4 ward+drug specific layout
            popmessagecr "!", "Label layout 'Stklabel.rtf' is not installed" & cr & "Not possible to print stock labels"
            Action = 201
         End If
         
         '01Mar11 TH Merged From v8 (F0089265)
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "RecordCDNumber", 0)) Then                                '20Jan05 TH Added Section
            strWards = "," & TxtD(dispdata$ & "\winord.ini", "defaults", "", "CDWards", 0) & ","
            If InStr(strWards, "," & Trim$(sup.Code) & ",") > 0 Then
               setinput 0, k
               k.Max = 12
               InputWin "Enter Requisition", TxtD(dispdata$ & "\winord.ini", "defaults", "Enter CD Book Reference Number", "RecordCDNumberTitle", 0), strCDNum, k
               If Not k.escd Then
                  Heap 10, gPRNheapID, "CDNum", strCDNum, 0
                  PutCustOrdNo strCDNum
               End If
            End If
         End If
         '01Mar11 TH ----
         
      Else
         Action = 201
      End If
      Issue k, quantity!, 0, d, UserID$, WSPackSize$, "", done%, "S", costcentre$, "", SiteNumber, "S", UnitCost$, batchno$, expdate$, duplicates%, NumLabels%, Action
      If Not k.escd Then
         If Action = 7 Or Action = 8 Then                                                                       '02Dec99 TH Added switch for non RTF printing
            If oldstocklabels And GetRobotPrintLabelMessageID() = 0 Then                                        '16oct06 CKJ force RTF for robot printing   31Dec07 CKJ Ported from V8.7
               Printoldstocklabels NumLabels, duplicates, costcentre$
            Else
               PrintStockLabelsSQL quantity!, d.SisCode, costcentre$, NumLabels, duplicates
            End If
         End If
         LabelIssueQty$ = Trim$(Str$(Int(quantity!)))
      Else
         If Action = 7 Or Action = 8 Then                 'Ability to print labels without issue
            popmsg "EMIS Health", "OK to just print Stock Labels ?", MB_YESNOCANCEL + MB_DEFBUTTON1 + MB_ICONQUESTION, ans$, k.escd
            If ans = "Y" Then
               If oldstocklabels Then
                  Printoldstocklabels NumLabels, duplicates, costcentre$
               Else
                  PrintStockLabelsSQL quantity!, d.SisCode, costcentre$, NumLabels, duplicates
               End If
            End If
         End If
         escaped = True
      End If
   Else
       done = True
   End If
    
   If Not done Then
      escaped = True
      'Exit Sub                                              '<==== WAY OUT
   Else
    
      If UCase(sup.PrintPickTicket) = "Y" Then              'no actual stock issue will take place, so no robot handling needed
      'create a Picking Ticket entry
      'ask for requistion number
      ordernum$ = lastordernum$
      setinput 0, k
      'k.Max = 4
      k.Max = 10
      'inputwin "Enter Requisition", "Enter Requistion Number", ordernum$, k
      InputWin "Enter Requisition", "Enter Requisition Reference", ordernum$, k  '16Jan15 TH Altered (TFS 108421)
      If k.escd Then
         escaped = True
            'Exit Sub                                           '<==== WAY OUT
         Else
      lastordernum$ = ordernum$
      Heap 10, gPRNheapID, "OrderNum", ordernum$, 0
      Qty$ = Format$(quantity!)
      If InStr(Qty$, ".") > 0 Then Qty$ = Format$(Qty$, "0.#")
      If PrintLabel Then
         Action = 107
      Else
         Action = 101
      End If
      Issue k, quantity!, 0, d, UserID$, WSPackSize$, "", done%, "S", costcentre$, "", SiteNumber, "S", UnitCost$, batchno$, expdate$, duplicates%, NumLabels%, Action
      If Not k.escd Then
         If Action = 7 Or Action = 8 Then
            If oldstocklabels Then                                                                           '02Dec99 TH Added switch for non RTF printing
               Printoldstocklabels NumLabels, duplicates, costcentre$
            Else                                                                                         '   "
               PrintStockLabelsSQL quantity!, d.SisCode, costcentre$, NumLabels, duplicates
            End If                                                                                       '   "
         End If
         Qty$ = Str$(quantity!)
         If Val(Qty$) = 0 Then
            escaped = True
                  'Exit Sub                                        '<==== WAY OUT
         Else
            LabelIssueQty$ = Qty$
                  
            'If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "N", "UpdateLinesOnIssue", 0)) Then LabelIssueQty$ = "" '06Jul11 TH
            'If TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "Y", "ListUpdateEnabled", 0)) Then LabelIssueQty$ = "" '21Jul11 TH Amalgamate settings now '26Sep11 TH Changed default (TFS14789)
            If (Not blnOCX) And TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "Y", "ListUpdateEnabled", 0)) Then LabelIssueQty$ = "" '04Feb15 TH Change output for ocx (TFS 110480)

            If PrintInPacks Then
               quantity! = dp!(Val(Qty$) / Val(d.convfact))
            Else
               quantity! = Val(Qty$)
            End If
            'Check if item is DLO
            
            '28Mar13 TH Added (TFS 58711)
            If curline& > 0 Then
               If blnOCX Then
                  lngLayoutID = curline&
               Else
                  lngLayoutID = UCase$(drugs(curline&).LayoutID)
               End If
            Else
               lngLayoutID = 0
            End If
            
            CreateRequisitionRecordSQL quantity!, ordernum$, costcentre$, lngLayoutID '28Mar13 TH Added new param (TFS 58711) '28Dec07 CKJ Moved from below (merged from 8.7)
         End If
         'CreateRequisitionRecordSQL quantity!, ordernum$, costcentre$    28Dec07 CKJ
      Else
         If Action = 7 Or Action = 8 Then                 'Ability to print labels without issue
            popmsg "EMIS Health", "OK to just print Stock Labels ? No issue will be made.", MB_YESNOCANCEL + MB_DEFBUTTON1 + MB_ICONQUESTION, ans$, 0  '21Oct99 Give option to cancel
            If ans = "Y" Then
               If oldstocklabels Then
                   Printoldstocklabels NumLabels, duplicates, costcentre$
               Else
                   PrintStockLabelsSQL quantity!, d.SisCode, costcentre$, NumLabels, duplicates
               End If
            End If
         End If
         escaped = True
      End If
         End If
         
   ElseIf (sup.PrintPickTicket <> "Y" And sup.PrintDeliveryNote = "Y") Then
      'create a Delivery Note entry
      LabelIssueQty$ = Format$(quantity!)
      If PrintInPacks Then quantity! = dp!(quantity! / Val(d.convfact))
      CreateDeliveryNoteRecordSQL quantity!, UnitCost$, costcentre$, 0, False
      End If
   End If

   lastissueqty$ = LabelIssueQty$
   
   '01Mar11 TH Merged from v8
   PutCustOrdNo ""                                 '25Nov04 TH Added
   Heap 10, gPRNheapID, "CDNum", "", 0
   '01Mar11 TH ---
   
   MechDispClearLabelData                          '20May08 CKJ was SetRobotPrintLabelMessageID 0    '16oct06 CKJ

End Sub

Sub InsertLine(CurPos As Long)

'{SP2} note that param CurPos is not used
'20Oct08 TH Fix to barcode handling (F0037033)
'23Apr09 TH Added trim around titletext when inserting new line (F0038841)
'19May10 TH Now allow stores only products to also be available for ward stock addition (F0055971)
'           However, this was explicitly turned off before, so I have put this on a setting with
'           the original behaviour (ie no stores only items) as default
'15Dec14 TH Now use new Ward List structures

Const procname$ = "InsertLine"

Dim SQL$, drug$, title$
Dim escd%, found%, foundPtr&, loopvar%
Dim tempdrugs() As drugdetails
Dim resumeval%, retries%
Dim CurCursorPos&
Dim localcode$
Dim temp$
Dim strBarcode As String
Dim lngPacksize As Long
Dim lngReturn As Long
Dim strParams As String
Dim blnOK As Boolean
Dim intStores As Integer  '19May10 TH Added (F0055971)
    
   If WardStockPasslvl = 1 Then
      retries% = MessageBox("You do not have sufficient user privileges to insert lines.", 0, "")
      Exit Sub
   End If

   AskNSVCode drug$, escd%, ""

   If Not escd% Then
      If Trim$(drug$) <> "" Then
         'findrdrug Trim$(drug$), False, d, foundPtr&, found%, 2, False  '19May10
         intStores = Val(TxtD(dispdata$ & "\winord.ini", "WardStock", "0", "AllowStoresOnly", 0))  '19May10 TH (F0055971)
         findrdrug Trim$(drug$), intStores, d, foundPtr&, found%, 2, False, False
      Else
         found% = 0
      End If

      If Not found% Then
         title$ = drug$
         drug$ = "&"
         localcode$ = ""
         BlankWProduct d
      Else
         drug$ = d.SisCode
         title$ = d.DrugDescription             ' title$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
         plingparse title$, "!"
         If Trim$(d.local) = "" Or TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "Y", "UseNSVCodeForWSListandStockTake", 0)) Then
            localcode$ = Trim$(d.SisCode)
         Else
            localcode$ = Trim$(d.local)
         End If
         'strBarcode = d.barcode '20Oct08 TH Added (F0037033)
         strBarcode = "*" & d.barcode & "*"   '12Nov08 TH Added *s(F0037033)
      End If
      
      If MainScreen.lvwMainScreen.ListItems.count < 1 Then
         CurCursorPos = 1
      Else
         CurCursorPos = MainScreen.lvwMainScreen.SelectedItem.Index
      End If
         
      If CurCursorPos& = 0 Or drugs(1).posn = 0 Then
         CurCursorPos& = 1
         ReDim tempdrugs(UBound(drugs))
      Else
         ReDim tempdrugs(UBound(drugs) + 1)
      End If
      
      If CurCursorPos& > 1 Then
         For loopvar = 1 To CurCursorPos& - 1
            LSet tempdrugs(loopvar) = drugs(loopvar)
         Next
      End If

      LSet tempdrugs(CurCursorPos&) = blankdrug
      tempdrugs(CurCursorPos&).catno = drug$
      tempdrugs(CurCursorPos&).drugttl = title$
      tempdrugs(CurCursorPos&).posn = CurCursorPos&
      tempdrugs(CurCursorPos&).paksize = Trim$(d.convfact)
      tempdrugs(CurCursorPos&).localcode = localcode$
      If Trim$(drug$) = "&" Then
         tempdrugs(CurCursorPos&).lastissue = ""
         tempdrugs(CurCursorPos&).stklevl = ""
         tempdrugs(CurCursorPos&).dailyissue = ""
      Else
         tempdrugs(CurCursorPos&).lastissue = "0"
         tempdrugs(CurCursorPos&).stklevl = "0"
         tempdrugs(CurCursorPos&).dailyissue = "0"
         tempdrugs(CurCursorPos&).barcode = strBarcode  '20Oct08 TH Added (F0037033)
      End If
         
      If UBound(tempdrugs) > 1 Then
         For loopvar = CurCursorPos& To UBound(drugs)
            LSet tempdrugs(loopvar + 1) = drugs(loopvar)
            tempdrugs(loopvar + 1).posn = drugs(loopvar).posn + 1
         Next
      End If

      ReDim drugs(1 To UBound(tempdrugs))
      ONumToDisplay = UBound(drugs)
      ReDim OInfoStore(1 To ONumToDisplay)         '//// could possibly be zero - if ubound drugs() already zero
      '02Jun11 CKJ: ReDim OMarked(1 To ONumToDisplay)
      MainLVWRemoveSelection   '02Jun11 CKJ
      
      For loopvar = 1 To ONumToDisplay
         LSet drugs(loopvar) = tempdrugs(loopvar)
      Next

      Select Case WardStockPasslvl
         Case 1
         Case 2, 3, 4
               
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                        gTransport.CreateInputParameterXML("CurrentPosn", trnDataTypeint, 4, CurCursorPos&) & _
                        gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
                             
            blnOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListSingleLineUpdateScreenPosn", strParams)
            If CurCursorPos& = 0 Then CurCursorPos& = 1
               '''tempdyn("ScreenPosn") = CurCursorPos&
               '''tempdyn("SiteName") = ward$
               '''tempdyn("PrintLabel") = "~"
               '''tempdyn("TitleText") = Title$
               'tempdyn("PackSize") = Trim$(d.convfact)   '29Aug97 EAC             '23Feb00 TH/mma/vs remmed out
               ''If Trim$(drug$) <> "&" Then tempdyn("PackSize") = Trim$(d.convfact) '23Feb00 TH/mma/vs stops type mismatch
            If Trim$(drug$) <> "&" Then
               lngPacksize = Val(d.convfact)
            Else
               lngPacksize = 0
            End If
               '''tempdyn("LocalCode") = localcode$
   
            'Add new barcode field
            If Trim$(drug$) <> "&" Then
               temp$ = drug$
               temp$ = bcode$(temp$)
               strBarcode = temp$
            End If
   
            On Error GoTo ILUpdateTableErr
            If Trim$(drug$) <> "&" Then
               lngPacksize = Val(d.convfact)
            Else
               lngPacksize = 0
            End If
''            '23Apr09 TH Added trim around titletext (F0038841)
''            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
''                        gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, (CurCursorPos&)) & _
''                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(tempdrugs(CurCursorPos&).catno)) & _
''                        gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(title$)) & _
''                        gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
''                        gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$) & _
''                        gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, 0) & _
''                        gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
''                        gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, lngPacksize) & _
''                        gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, "") & _
''                        gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, localcode$) & _
''                        gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
''                        gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
''                        gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
''
''            lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardStockList", strParams)
            
            '15Dec14 TH Now use new structures
            strParams = gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, (CurCursorPos&)) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(tempdrugs(CurCursorPos&).catno)) & _
                        gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, Trim$(title$)) & _
                        gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
                        gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, lngPacksize) & _
                        gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeDateTime, 8, Null) & _
                        gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, sup.SupplierID)
   
            lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardProductListLine", strParams)
            '-----
            
            tempdrugs(CurCursorPos&).LayoutID = lngReturn 'TH ADDed
            drugs(CurCursorPos&).LayoutID = lngReturn  'TH ADDed
            On Error GoTo 0
         End Select
         ChangeTable "blank", False '14Aug12 TH Added Param    '17Oct05 TH swiz to help resizing
         DisplayPage
         MainLVWHighlightSingleRowByIndex CurCursorPos
      End If

Exit Sub

ILUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
   End Select
   
End Sub

Function IsAlpha%(char$)

    Select Case char$
        Case "0" To "9"
            IsAlpha = True
        Case Else
            IsAlpha = False
    End Select

End Function

Sub LoadWard(success As Integer, escaped As Integer, selectward As Integer)
'-----------------------------------------------------------------------------
'               a straight copy of the old subroutine
' Ideally this would be a few separate general purpose routines, maybe later!
'26Mar91 CKJ New ward offered in the list, error handling improved
'26May95 CKJ Now uses multilist form
'16Oct97 EAC Speed up loading of WSL's - use snapshot for Level One password
'05Nov97 EAC V8.05 Mods
'08Jan98 EAC Overcome 300 limit on wards by using standard AskSupplier routine
'23Jan02 TH  Added level 5 for wardstock (#52055)
'20Oct08 TH  Fix to barcode handling (F0037033)
'01Jun11 CKJ added as integer to success & escaped
'-----------------------------------------------------------------------------

'ReDim wdname$(300)  08Jan98 EAC
'Dim dyn As dynaset
'Dim snap As snapshot
Dim SQL$, DrugCode$, desc$
Dim tofind%, found%, numofdrugs%
Dim TotalDrugs As Long
Dim SelectionTypes$
'''Dim objdata As clsDataAccess
Dim strParams As String
Dim rsWardStock As ADODB.Recordset



    success = True      ' assume no ward until one is loaded successfully
    escaped = False
    
    If selectward Then
      '08Jan98 EAC Overcome 300 limit on wards by using standard AskSupplier routine
      'SelectionTypes$ = UCase$(TxtD$(dispdata$ & "\winord.ini", "WardStockList", "WL", "SelectionTypes", found))
      'SelectionTypes$ = UCase$(TxtD$(dispdata$ & "\winord.ini", "WardStockList", "L", "SelectionTypes", found))   '21Jul14 TH Only Lists now (TFS)
      SelectionTypes$ = UCase$(TxtD$(dispdata$ & "\winord.ini", "WardStockList", "WL", "SelectionTypes", found))   '15Dec14 TH No - both as we have to handle wards in old way
      asksupplier ward$, 0, SelectionTypes$, "Select department or ward", False, sup, False '15Nov12 TH Added PSO param
      If k.escd Then
         escaped = True
         Exit Sub
      End If
   End If
      
   tofind = 0
   getsupplier ward$, tofind, 0, sup
   wardcode$ = Trim$(sup.wardcode)
   wardexp$ = Trim$(sup.name)
   strWardFullName = Trim$(sup.fullname)
   
   MainScreen.lvwMainScreen.Enabled = False

   dispdatastore$ = dispdata$
   If trimz$(sup.icode) = "" Then
      warddispdata$ = dispdata$
      ''lngWardSiteID = gWardStockSite
   Else
      warddispdata$ = "\dispdata." & Right$("000" & Right$(Trim$(sup.icode), 3), 3)
      ''lngWardSiteID = GetSiteIDFromDispdata(Val(sup.icode))
      'SQL TO DO
      lngWardSiteID = Val(Right$("000" & Right$(Trim$(sup.icode), 3), 3))
      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, lngWardSiteID)
      gWardStockSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
   End If
   dispdata$ = warddispdata$
   If InStr(UCase$(Command$), "/WARDDEBUG") Then popmessagecr "", "Dispdata$ = |" & dispdata$ & "|"
   numofdrugs = 1
   TotalDrugs = 1
   
   'Now go to SQL to get the total
   ''strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
   ''            gTransport.CreateInputParameterXML("SupplierID", trnDataTypeint, 4, sup.SupplierID)
   ''TotalDrugs = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListCountbyWSupplierID", strParams)
   ''TotalDrugs = snap.Fields(0)
   'On Reflection have decided to retain the code linkage as the key !
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
               gTransport.CreateInputParameterXML("WSiteName", trnDataTypeVarChar, 5, Trim$(ward$))
   TotalDrugs = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListCountbySitename", strParams)
   
   
   If TotalDrugs = 0 Then TotalDrugs = 1
   ReDim drugs(1 To TotalDrugs)
   numofdrugs = 0
         
   Select Case WardStockPasslvl
      Case 1, 5 '23Jan02 TH Added level 5 (#52055)
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
         ''Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pLayoutBySiteName", strParams)
         Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteName", strParams)
         On Error GoTo loadwarderr
         If Not rsWardStock.EOF Then
            rsWardStock.MoveFirst
            Do Until rsWardStock.EOF
               If Trim$(GetField(rsWardStock!sitename)) = Trim$(ward$) Then
                  numofdrugs = numofdrugs + 1
                  If numofdrugs > TotalDrugs Then Exit Do
                  LSet drugs(numofdrugs) = blankdrug
                  If Trim$(GetField(rsWardStock!NSVCode)) = "&" Then
                     drugs(numofdrugs).drugttl = GetField(rsWardStock!titletext)
                     drugs(numofdrugs).catno = "&"
                     drugs(numofdrugs).lastissuedate = ""
                  Else
                     DrugCode$ = Trim$(GetField(rsWardStock!NSVCode))
                     If trimz$(GetField(rsWardStock!titletext)) = "" Then
                        desc$ = "Description missing from ward stock database."
                     Else
                        desc$ = Trim$(GetField(rsWardStock!titletext))
                     End If
                     drugs(numofdrugs).drugttl = desc$
                     drugs(numofdrugs).stklevl = Trim$(GetField(rsWardStock!topuplvl))
                     drugs(numofdrugs).paksize = trimz$(GetField(rsWardStock!PackSize))
                     If rsWardStock!PrintLabel = "~" Then
                        drugs(numofdrugs).prepack = " "
                     Else
                        drugs(numofdrugs).prepack = Trim$(GetField(rsWardStock!PrintLabel))
                     End If
                     drugs(numofdrugs).catno = Trim$(DrugCode$)
                     drugs(numofdrugs).lastissue = Trim$(GetField(rsWardStock!lastissue))
                     drugs(numofdrugs).lastissuedate = Trim$(GetField(rsWardStock!lastissuedate))
                     drugs(numofdrugs).localcode = Trim$(GetField(rsWardStock!localcode))
                     If Trim$(drugs(numofdrugs).localcode) = "" Then drugs(numofdrugs).localcode = drugs(numofdrugs).catno
                     If rsWardStock!lastissuedate = Format(date, "dd/mm/yyyy") Then
                        drugs(numofdrugs).dailyissue = Trim$(GetField(rsWardStock!dailyissue))   '29Jan99 TH
                     Else
                        drugs(numofdrugs).dailyissue = "0" 'Trim$(GetField(snap!lastissue))   '29Jan99 TH
                     End If
                  End If
                  drugs(numofdrugs).posn = GetField(rsWardStock!ScreenPosn)
                  drugs(numofdrugs).barcode = GetField(rsWardStock!barcode)
                  drugs(numofdrugs).LayoutID = GetField(rsWardStock!WWardStockListID) 'Added To give access to DB using the key
               End If
               rsWardStock.MoveNext
            Loop
         End If
      
         rsWardStock.Close
         Set rsWardStock = Nothing

      Case 2, 3, 4
         ''Set objdata = New clsDataAccess
         ''strParams = gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
         ''strParams = gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
         ''Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pLayoutBySiteName", strParams)
         ''Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListByWSupplierID", strParams)
         
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
         Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteName", strParams)
         ''Set objdata = Nothing
         On Error GoTo loadwarderr
         If Not rsWardStock.EOF Then
            rsWardStock.Sort = "Screenposn" '16Feb05 TH Added
            rsWardStock.MoveFirst
            

            Do Until rsWardStock.EOF
               'rsWardStock.Sort
               If Trim$(GetField(rsWardStock!sitename)) = Trim$(ward$) Then
                  numofdrugs = numofdrugs + 1
                  If numofdrugs > TotalDrugs Then Exit Do
                  LSet drugs(numofdrugs) = blankdrug
                  If Trim$(GetField(rsWardStock!NSVCode)) = "&" Then
                     drugs(numofdrugs).drugttl = GetField(rsWardStock!titletext)
                     drugs(numofdrugs).catno = "&"
                  Else
                     DrugCode$ = Trim$(GetField(rsWardStock!NSVCode))
                     If trimz$(GetField(rsWardStock!titletext)) = "" Or GetField(rsWardStock!PackSize) = 0 Or trimz$(GetField(rsWardStock!localcode)) = "" Then
                        ''cleardrug d
                        BlankWProduct d
                        d.SisCode = DrugCode$
                        getdrug d, 0, (found), False
                        If trimz$(GetField(rsWardStock!titletext)) = "" Then
                           desc$ = d.DrugDescription    ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
                           plingparse desc$, "!"
                           If Trim$(desc$) = "" Then desc$ = "Drug not found in drug database."
                           rsWardStock!titletext = Trim$(desc$)
                        Else
                           desc$ = trimz$(GetField(rsWardStock!titletext))
                        End If
                        If GetField(rsWardStock!PackSize) = 0 Then rsWardStock!PackSize = Val(d.convfact)
                        If trimz$(GetField(rsWardStock!localcode)) = "" Then
                           If trimz$(d.local) = "" Then
                              rsWardStock!localcode = Trim$(d.SisCode)
                           Else
                              rsWardStock!localcode = Trim$(d.local)
                           End If
                        End If
                     Else
                        desc$ = Trim$(GetField(rsWardStock!titletext))
                     End If
                     drugs(numofdrugs).drugttl = desc$
                     drugs(numofdrugs).stklevl = Trim$(GetField(rsWardStock!topuplvl))
                     drugs(numofdrugs).paksize = Trim$(GetField(rsWardStock!PackSize))
                     If rsWardStock("PrintLabel") = "~" Then
                        drugs(numofdrugs).prepack = " "
                     Else
                        drugs(numofdrugs).prepack = Trim$(GetField(rsWardStock!PrintLabel))
                     End If
                     drugs(numofdrugs).catno = Trim$(DrugCode$)
                     drugs(numofdrugs).lastissue = Trim$(GetField(rsWardStock!lastissue))
                     drugs(numofdrugs).lastissuedate = Trim$(GetField(rsWardStock!lastissuedate))
                     drugs(numofdrugs).localcode = Trim$(GetField(rsWardStock!localcode))
                     If Trim$(drugs(numofdrugs).localcode) = "" Then drugs(numofdrugs).localcode = drugs(numofdrugs).catno
                     If rsWardStock!lastissuedate = Format(date, "dd/mm/yyyy") Then
                        drugs(numofdrugs).dailyissue = Trim$(GetField(rsWardStock!dailyissue))
                     Else
                        drugs(numofdrugs).dailyissue = "0"
                     End If
                     drugs(numofdrugs).barcode = Trim$(GetField(rsWardStock!barcode))  '20Oct08 TH Added (F0037033)
                  End If
                  drugs(numofdrugs).posn = GetField(rsWardStock!ScreenPosn)
                  drugs(numofdrugs).LayoutID = GetField(rsWardStock!WWardStockListID) 'Added To give access to DB using the key
               End If
               rsWardStock.MoveNext
            Loop
         End If
      
         rsWardStock.Close
         Set rsWardStock = Nothing
      
      End Select

   MainScreen.lvwMainScreen.Enabled = True
   ONumToDisplay = numofdrugs
   '''shellsort drugs(), TotalDrugs, 0, 0

   dispdata$ = dispdatastore$
   ordernum$ = ""
   On Error GoTo 0

   Screen.MousePointer = 0

Exit Sub

loadwarderr:
   success = False
   Resume Next

LWUpdateTableErr:

   Select Case Err
      Case 0
      Case Else
         popmessagecr "Error", "Module : WSLIST.BAS" & Chr$(13) & "Procedure : LOAD_WARD" & Chr$(13) & Error$(Err)
      End Select

Resume Next

End Sub


Sub AdhocIssue(ByVal IsIssue As Boolean)
'06Nov14 TH Dont update the ward stock list if cancelled (TFS 103677)

Dim finished%, valid%, escd%, onlist%
Dim foundPtr&, found%, done%, doissue%
Dim ans$, drugname$, wdcode$, wddesc$, SQL$, desc$
Dim issueunitcost$, batchnumber$, expiry$
Dim lngFoundSup As Long
Dim lbltxt$
Dim IssueQty!
Dim Action%, dupes%, numoflbls%
Dim strIssueOrReturn$
Dim lngDelnotenumber As Long

'''Dim objdata As clsDataAccess
Dim strParams As String
Dim lngResult As Long
Dim RTFfile As String

   If IsIssue Then
      lbltxt$ = "Issue"
      strIssueOrReturn = " to "
   Else
      lbltxt$ = "Return"
      strIssueOrReturn = " from "
   End If

   Do
      valid = True
      wdcode$ = ""
      k.validchars = nulls  '29Mar00 TH Added because was sometimes previously set by other routines and not flushed. No mask required here
      askward "Enter ward code for Ad-hoc " & lbltxt$, wdcode$, finished%, "WL"
      If Not finished Then
         getsupplier wdcode$, 0, lngFoundSup, sup
         If lngFoundSup = 0 Or Not (sup.suppliertype = "W" Or sup.suppliertype = "L") Then
             valid = False
         Else
            wddesc$ = Trim$(sup.name)
            If sup.suppliertype = "L" Then
               wdcode$ = Trim$(sup.wardcode)
               If wdcode$ = "" Then
                  Do
                     askward "Cost Centre Required", wdcode$, escd%, "W"
                     If Not escd% Then
                        getsupplier wdcode$, 0, lngFoundSup, sup
                        If sup.suppliertype <> "W" Then
                           popmessagecr "#", wdcode$ & " is not a set up as a ward" & cr & "You will need to select a ward."
                           wdcode$ = ""
                        End If
                     Else
                        k.escd = True
                     End If
                  Loop Until (sup.suppliertype = "W" And Trim$(wdcode$) <> "") Or escd%
                                 End If
               End If
               ' Warning if ward is not in use
               If UCase$(Trim$(sup.inuse)) = "N" Then
                  k.escd = False
                  popmsg "EMIS Health", "     Ward  " & UCase$(wdcode$) & "  Is Not In Use" & cr & cr & Space$(18) & "Continue ?", 563, ans$, k.escd   '28Aug98 TH
                  If ans$ <> "Y" Or k.escd Then
                     Exit Sub
                  End If
                  ans$ = ""
               End If
            End If
         Else
            If Not badward% Then       '24Aug98 TH  Added extra error flag to differentiate between cancel and non-existent ward
               Exit Sub
            Else                    '
               popmessagecr "!EMIS Health", "Invalid Ward Code"
               badward% = False     '
            End If
         End If
            
         If Not finished Then
            If valid Then
               escd% = False
               Do
                  drugname$ = ""
                  AskNSVCode drugname$, escd%, "Enter item for Ad-hoc " & lbltxt$ & strIssueOrReturn & wddesc$      '17Jan01 AW changed (event no. 49274)"
                  If drugname$ = "BNF" Then drugname$ = "" '28Oct05 TH (#80629)
                  If Not escd% And Trim$(drugname$) <> "" Then
                     'findrdrug drugname$, 0, d, foundPtr&, found%, 0, False
                     'blnAllowStoresOnly setting read here to allow or not in Adhoc Issue
                     findrdrug drugname$, True, d, foundPtr&, found%, 0, False, False '29Jun11 TH (F0119245)
                     If found Then
                        desc$ = d.DrugDescription       ' desc$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
                        plingparse desc$, "!"
                        'check to see if it is on the ward stock list
                        onlist = False
                        'On Error Resume Next
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                                    gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
                                    gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, wdcode$)
                        lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListIsItemPresent", strParams)
                        '''Set objdata = Nothing
                        If lngResult > 0 Then onlist = True
                        If Not onlist Then
                           Select Case WardStockPasslvl
                              Case 1 ', 5         '23Jan02 TH Removed lvl 5 and enabled it below (#52055)
                                 doissue = False
                                 popmessagecr "!EMIS Health", "You are not authorised to issue items that are not on the Ward Stock List"
                              Case 2, 3, 4, 5    '   "
                                 ans$ = "N"
                                 'askwin ".Item not on Ward Stock List", desc$ & cr$ & cr$ & "OK to proceed with " & lbltxt$ & "?", ans$, k
                                 askwin ".Item not on Ward Stock List (" & Trim$(wdcode$) & ")", desc$ & cr$ & cr$ & "OK to proceed with " & lbltxt$ & "?", ans$, k
                                 If Not k.escd And Trim$(UCase$(ans$)) = "Y" Then
                                   doissue = True
                                 Else
                                     doissue = False
                                 End If
                               Case Else
                                   doissue = False
                           End Select
                        Else
                            doissue = True
                        End If

                        If doissue Then
                           issueunitcost$ = ""
                           batchnumber$ = ""
                           expiry$ = ""
                           IssueQty! = Val(d.convfact)
                           If IssueQty! = 0 Then IssueQty! = 1
                           If Not IsIssue Then
                              IssueQty! = IssueQty! * -1
                              EnterCustOrdNo True           '25Feb02 TH Added to allow for possible entry of custordno on return (enh1585)
                           Else                             '    "
                              PutCustOrdNo ""               '    "
                           End If                         '    "
                           Action = GetPrintStockLabelsByDefault()
                                       
                           '16Oct06 CKJ added block   31Dec07 CKJ Ported Block from V8.7
                           Select Case SpecificStockLabelLayout(d.SisCode, wdcode$, RTFfile)   '0 absent, 1 default, 2 ward, 3 drug, 4 ward+drug specific layout
                              Case 0
                                 popmessagecr "!", "Label layout 'Stklabel.rtf' is not installed" & cr & "Not possible to print stock labels"
                                 Action = 1
                              Case Is > Val(TxtD(dispdata$ & "\winord.ini", "defaults", "5", "PrintAdHocStockLabelsMinLayout", 0))
                                 Action = 7        'set print to default if specific layout found
                              End Select

                           '19May10 XN  Got Use ward code for issuing (F0051906)
                           Issue k, IssueQty!, 0, d, UserID$, "", "", done%, "S", sup.wardcode, "", SiteNumber%, "S", issueunitcost$, batchnumber$, expiry$, dupes, numoflbls, Action
                           If sup.AdHocDelNote = "Y" And Not k.escd Then
                              If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", "AdHocDelNoteNumbers", 0)) = True And lngDelnotenumber = 0 Then
                                 getorderno 5, lngDelnotenumber, False
                                 getorderno 5, 0, True 'gets a new picking ticket no for the occassion
                              End If
                              If PrintInPacks Then
                                 CreateDeliveryNoteRecordSQL dp!(IssueQty! / (Val(d.convfact))), issueunitcost$, sup.wardcode, lngDelnotenumber, False
                              Else
                                 CreateDeliveryNoteRecordSQL IssueQty!, issueunitcost$, sup.wardcode, lngDelnotenumber, False
                              End If
                           End If
                           If Action = 7 Or Action = 8 Then PrintStockLabelsSQL IssueQty!, d.SisCode, wdcode$, numoflbls, dupes
                                       MechDispClearLabelData      '20May08 CKJ was SetRobotPrintLabelMessageID 0   '16oct06 CKJ
                           'If onlist Then UpdateWardStockListIssueData d.SisCode, sup.wardcode, "Adhoc", CLng(IssueQty!) '11Apr14 TH Coerce to long (TFS 88720)
                           If onlist And Not (k.escd) Then UpdateWardStockListIssueData d.SisCode, sup.wardcode, "Adhoc", CLng(IssueQty!), 0 '18Dec14 TH Added param 06Nov14 TH Dont update if cancelled (TFS 103677)
                        End If
                     End If
                  
                  End If
                  If Trim$(drugname$) = "" And Not k.escd Then
                     popmessagecr "", "Please enter a drug code"
                  End If
               Loop Until escd%
            Else
                popmessagecr "Invalid Ward Code", "Please re-enter the code or press Shift - F1 for help."
            End If
      End If
      If lngDelnotenumber > 0 Then popmessagecr "", "Your Delivery note has been assigned the Picking Ticket Number for Reference " & Format$(lngDelnotenumber) '17Jul02 TH Inform the user of any number if required
      lngDelnotenumber = 0 '31May02 TH added to refresh the delnote (if used) for each different ward/supplier
   Loop Until finished

End Sub

Sub PrepareIssue(Mode%, drug As drugdetails, ret%, curline As Long, ByVal blnOCX As Boolean, ByVal blnTopupCheck As Boolean, ByRef lngIssueAmount As Long)
'-----------------------------------------------------------------------------
'                                 PrepareIssue
'
' Mode 1 ... assume current line
'      2 ... ask for item
'      3 ... ask for line & don't exit until esc pressed
'
' NB How to cope with HORIS catnos?
' 6Apr92 CKJ If HORIS then give msg & exit
'15Nov92 CKJ Installed PrnDrvr
'11Jan93 CKJ Added EditWardCode
'12Jan95 ASC added rverse feed for labels
'18Jan95 CKJ Added erase labelline$()
'19Jan98 EAC Add Warning and Instruction codes to printed
'05Mar98 ASC Label now shows last issue qty.
'26Mar98 EAC All labels now print the correct ward code
'            Label not printed if issue aborted
'            label array cleared before label text from editor is inserted into it
'            to prevent duplicate lines at end of label
'31Mar98 CFY Added getdrug before the first issue box appears so that the name of the drug
'            can be displayed.
'05May98 CKJ/EAC moved right margin text into body of label - simplifies RTF & normal printing
'            - may need a rethink but is safe
'26May98 CFY Now puts secondary warning code rather than the primary warning code on the label.
'11Jun98 CKJ removed multiplication of pack size * quantity as it is inappropriate
'12Jun98 EAC correct printing of labels if PrintInPacks enabled
'25Jun98 EAC removed mod of 12Jun98 as mods in HandleWardIssue now set LastIssueQty correctly
'26Jun98 CFY Corrected handling of barcode issuing.
'22Jul98 CFY Calculation of costs now corrected. Was previously dividing the quantity
'            issued by the packsize. This was a problem as the quantity value may have
'            already been divided by the packsize depending upon whether printpickingtickets
'            or printdelivery notes had been selected and printinpacks was set to True.
'01Sep98 CFY Now adds VAT to the cost printed no the label.
'30Oct98 EAC CostCentre was never being set for L type wards with no cost centre defined.
'09Nov98 CFY The text 'Ward Stock' that is added to the end of the label is now no longer hard
'            coded, but is picked up from an ini file setting instead/
'17Nov98 TH  On issues now checks for "to follows"
'23Nov98 TH  Now writes last issued date to drug file
'18Jan99 SF  Now doesn't allow an issue from a list to a ward that is set to not inuse
'21Jan99 EAC Use new stock label printing routines
'08Jul99 TH  Lastissued field now updated in Translog
'11Nov99 TH  Ensure passlevel one issues are correctly recorded to mdb
'01Sep01 TH  Changed input parameter to checktofollows (#52924)
'09Oct01 TH  Moved timing of call to checktofollows so as to accomodate any user entered cost centre (#52924)
'09Jan02 TH  Stop ability to print stock labels on return from the wardstocklist (#37539)
'11Apr02 TH  Blank CustOrdNo to stop any pre-existing variable being written to  logs (#50776)
'19Oct06 TH  Fencepost stockline update for passlvls 1 and 5 (SC-06-0999)
'23Apr09 TH  Added to prevent leading space (F0036816)
'07Jan15 TH  Moved Top Up check - check needs to be after an amount is entered in the issue form (TFS 103885)
'08Jan15 TH  Added call to cache wardstockline item to ensure it can be used in translog for straight issue (TFS 106426)
'08Jan15 TH  Added section to ensure new list is updated on straight issue - this will then be refreshed web side. (TFS 103886)
'22Jan15 TH  Mods to allow list handling (especially lists not linked to wards/cost centers) (TFS 102821)
'10Feb15 TH  Dont switch dispdatas if from the ocx - now we can use none site specific list (TFS 110251)
'10Feb15 TH  Only update wsl DB if actually issued - we still use the qty as an output param tho (TFS 111027)
'06Jul16 XN  Fixed issue with dispensing to ward stock list lines with id over 32000 (157521)
'09Jul16 TH  Renamed topuplevel variable and changed to long (TFS 157679)
'-----------------------------------------------------------------------------
Const procname$ = "PrepareIssue"

Static LastCostCentre$

Dim costcentre$

ReDim labelline$(10)

Dim IssueString$, copywardcode$, Action$, lastissue$, msg$, ans$, title$, size$
Dim lastissueqty$, SQL$
Dim escaped%, firstpass%, barcode%, Checked%, ptr%, foundPtr&, findPtr%   '01Jun02 ALL/ATW
Dim quantity!

Dim tempcode As String
Dim lngFound As Long
Dim blnFound As Boolean
'ReDim warnings$(3)
Dim DrugDesc$        '31Mar98 CFY Added
Dim LabelQty$        '25Jun98 EAC Added
Dim blnPrintLabel As Integer '09Jan02 TH Added
Dim lngSuccess As Long  'SQL

   'getsupplier ward$, findPtr%, lngFound, sup '29Jan15 TH Replaced with below
   getsupplierwardlist ward$, findPtr%, lngFound, sup
    
   
   If sup.suppliertype = "L" Then
      costcentre$ = trimz$(sup.wardcode)
      Do
         If costcentre$ = "" Then
            copywardcode$ = wardcode$
            title$ = "Cost Centre Required"
            msg$ = ""
            wardcode$ = LastCostCentre$
            'EditWardCode title$, msg$, escaped
            askward title$, wardcode$, escaped, "L"   '30Oct98 EAC Ideally this should only show W type suppliers
            costcentre$ = wardcode$               '30Oct98 EAC CostCentre never updated before getsupplier called
            wardcode$ = copywardcode$
         End If
         
         'getsupplierward wardcode$, "", 0, lngFound  '15Dec14 TH Added as wards and lists can now have same codes
         'If Not lngFound Then
            
            
            getsupplier costcentre$, 0, lngFound, sup  '01Jun02 ALL/ATW
            
            If sup.suppliertype <> "W" Then
                 popmessagecr "Cost Centre Required", "Please select a valid cost centre."     '30Oct98 EAC Added to tell user why they had to pick again.
                 costcentre$ = ""
            '18Jan99 SF added ElseIf block to ensure ward is set to inuse
            ElseIf sup.inuse = "N" And Not escaped Then
               popmessagecr "#Ward Not Inuse", "Ward " & costcentre$ & " is set to not inuse" & cr & "Cannot issue to this ward"    '14Jan99 SF added
               costcentre$ = ""
            End If
         'End If
         'Loop Until sup.suppliertype = "W" Or escaped                        '18Jan99 SF replaced
      Loop Until (sup.suppliertype = "W" And sup.inuse = "Y") Or escaped   '18Jan99 SF
   Else
      costcentre$ = Trim$(sup.Code)
   End If
   
   costcentre$ = Trim$(costcentre$) '23Apr09 TH Added to prevent leading space (F0036816)
   
   If costcentre$ = "" Then
      popmessagecr "!n!bWard Code has not been entered", "Cannot Issue or Return without a ward code"
      Exit Sub                                                  ' <== WAY OUT
   End If
   
   If escaped Then Exit Sub                                        ' <== WAY OUT
   
   If Not ret Then                                                             '08Oct01 TH Moved from above
      k.escd = False                                                        '   "
      checktofollows sup, drug.catno, drug.drugttl, drug.paksize, k         '   "
      If k.escd Then Exit Sub                                               '   "
   End If                                                                   '   "
   LastCostCentre$ = costcentre$
   'getsupplier ward$, 0, lngFound, sup  '01Jun02 ALL/ATW
   
   'getsupplier ward$, 0, lngFound, sup, True '22Jan15 TH Need to reload lists sometimes as these will have the req details required in the issue (TFS 102821)
   getsupplierwardlist ward$, 0, lngFound, sup  '29Jan15 TH Added

   firstpass = True
   
   If ret Then
      Action$ = "Return"
   Else
      Action$ = "Issue"
   End If
   
   If blnOCX Then
      tempcode$ = drug.catno
   Else
   If curline& = 0 Then
      tempcode$ = ""
   Else
      tempcode$ = UCase$(drugs(curline&).catno)
   End If
   End If
   Do
      Select Case Mode
         Case 1
            IssueString = tempcode$
         Case 2, 3
            IssueString = RTrim$(tempcode$)
            d.SisCode = IssueString$
            If IssueString$ <> "" Then getdrug d, 0, foundPtr&, False   'SQL Added Clause
            If foundPtr& = 0 Then            '01Jun02 ALL/ATW
               popmessagecr "!n!i" + Action$, "SIS code not defined in main index"
               Exit Sub                                         ' <== WAY OUT
            End If
            DrugDesc$ = d.LabelDescription      ' DrugDesc$ = d.Description XN 4Jun15 98073 New local stores description
            plingparse DrugDesc$, "!"
            
            title$ = Action$ + " Stock"

            msg$ = "  Press [Return] to " & Action$ & " current item, or enter" & Chr$(13)
            msg$ = msg$ & "  the Name, NSV code or Barcode of item to " & Action$ & Chr$(13)
            msg$ = msg$ & Chr$(13)
            msg$ = msg$ & "   " + Action$ + " item   " & Trim$(DrugDesc$) & Chr$(13)
            setinput 0, k
            k.Max = 30
            k.helpnum = 98                        ' ***
            
            IssueString = RTrim$(tempcode$)
            'If mode = 3 And Not firstpass Then IssueString = ""  '26Jun98 CFY Removed
            firstpass = False
            lastissue$ = IssueString
            InputWin title$, msg$, IssueString, k
            If k.escd Then Exit Sub                                ' <== WAY OUT
            If Mode = 3 And IssueString = "" Then Exit Sub         ' <== WAY OUT
            IssueString = UCase$(IssueString)
         Case Else
            Exit Sub                                               ' <== WAY OUT
      End Select
   
      barcode = False
      Checked = False
                                             
      If Len(IssueString) = 13 Then     ' is it a barcode?
            barcode = True
            For ptr = 1 To 13
               If InStr("0123456789", Mid$(IssueString, ptr, 1)) = 0 Then
                     barcode = False
                  End If
            Next ptr
         End If
   
      If barcode Then
         d.SisCode = ""
         d.barcode = IssueString
         getdrug d, 0, foundPtr&, False    '01Jun02 ALL/ATW
         If foundPtr& Then                 '01Jun02 ALL/ATW
               IssueString = UCase$(d.SisCode)
            findline IssueString, blnFound  '26Jun98 CFY Added  '01Jun02 ALL/ATW
            'SQL$ = "SELECT ScreenPosn FROM Layout WHERE (SiteName = '" & ward$ & "' AND NSVCode = '" & d.SisCode & "')"
            'SQL Set tempdyn = WSDB.CreateDynaset(SQL$)
            'SQL If Not tempdyn.EOF Then
                  'SQL curline& = GetField(tempdyn!ScreenPosn)
                  'SQL tempdyn.Close
                  'Stop: Checked = True '13Dec05 TH Removed - cant believe this was actually still here
               'End If
            If blnFound Then Checked = True    '13Dec05 TH Added
         End If
         If Not Checked Then
            popmessagecr "!n!i" + Action$, "Item not found in this Ward List."
            Exit Sub '13Dec05 TH Added cos this didnt seem to close things off properly down below
         End If
      End If
                

      If Checked Or Not barcode Then
         curlin = curline&
         If blnOCX Then
            blnFound = True
         ElseIf InStr(UCase$(concat$(curlin)), IssueString) Then
            blnFound = True                 ' in curline                                  '01Jun02 ALL/ATW
         Else                            ' not in current line
            findline IssueString, blnFound  ' now look for item in rest of stocklist
            If blnFound Then                                                              '01Jun02 ALL/ATW
               'redraw = True
            Else                                                                                   '01Jun02 ALL/ATW
               'blnFound = False                                                                   '01Jun02 ALL/ATW
               popmessagecr "!n!i" + Action$, "Item not found in this stocklist"
               Exit Sub '13Dec05 TH Added cos this didnt seem to close things off properly down below
               '   offer to add to stocklist??
            End If
         End If
      End If
   
      If blnFound And Not Checked Then  'blnFound <> 0 And Not Checked Then  ' not entered a barcode - so check validity   '01Jun02 ALL/ATW
         'd.SisCode = tempcode$
         d.SisCode = IssueString
         If Not blnOCX Then dispdata$ = warddispdata$    '10Feb15 TH Dont switch if from the ocx (TFS 110251)
         getdrug d, 0, foundPtr&, False  'x, found, False   '01Jun02 ALL/ATW
         If Not blnOCX Then dispdata$ = dispdatastore$   '10Feb15 TH Dont switch if from the ocx (TFS 110251)
         If foundPtr& = 0 Then            '01Jun02 ALL/ATW
            popmessagecr "!n!i" + Action$, "Product code not defined in main index" '"SIS code not defined in main index"  '01Jun02 ALL/CKJ
            Exit Sub                                         ' <== WAY OUT
         End If
      End If
   
      If foundPtr& <> 0 Then                  '01Jun02 ALL/ATW
         quantity! = 1

         size$ = ""
         If blnOCX Then
            For ptr = 1 To Len(drug.paksize)
               If InStr(" 0123456789", Mid$(drug.paksize, ptr, 1)) = 0 Then
                  size$ = "non numeric"
               End If
            Next ptr
         Else
            For ptr = 1 To Len(drugs(curline&).paksize)
               If InStr(" 0123456789", Mid$(drugs(curline&).paksize, ptr, 1)) = 0 Then
                  size$ = "non numeric"
               End If
            Next ptr
         End If
         
         If size$ = "" Then  ' numeric
            'quantity! = Val(drugs(curline&).paksize) * Val(drugs(curline&).stklevl)   '23Dec97 added multiplication * stocklevel
            If blnOCX Then
               quantity! = Val(drug.paksize)
            Else
               quantity! = Val(drugs(curline&).paksize)    '11Jun98 CKJ removed multiplication as it is inappropriate
            End If
            If quantity! = 0 Then size$ = "zero"
         End If

         If size$ <> "" Then
            setinput 0, k
            title$ = Action$
            msg$ = msg$ & Chr$(13)
            msg$ = msg$ & " Pack size is "
            msg$ = msg$ & size$
            msg$ = msg$ & Chr$(13)
            msg$ = msg$ & " Enter quantity to " + Action$ + Space$(10) + d.PrintformV
            k.Max = 4
            k.helpnum = 97                        ' ***
            k.decimals = True
            ans$ = ""
            InputWin title$, msg$, ans$, k
            quantity! = Val(ans$)
            If k.escd Or quantity! = 0 Then Exit Sub   ' <== WAY OUT
         End If
         'END IF
            
         If ret Then quantity! = quantity! * -1
         
         PutCustOrdNo "" '11Apr02 TH Blank CustOrdNo to stop any pre-existing variable being written to  logs (#50776)
           
         blnPrintLabel = False    '09Jan02 TH Added (#37539) - set up new bolean
         setm_lngWardStockTopUpLevel 0 '07Jan15 TH defensive
         If blnOCX Then
            '07Jan15 TH We arent sent a quantity so this check is not relevant at this stage
            ''01Sep14 TH Added top up check
            'If blnTopupCheck And (quantity! > (Val(drug.stklevl) * Val(drug.paksize))) Then
            '   popmessagecr "Ward Stock", "Cannot Request more than line top up level"
            '   escaped% = True
            'End If
            
            If blnTopupCheck Then setm_lngWardStockTopUpLevel (Val(drug.stklevl) * Val(drug.paksize)) '07Jan15 TH The check needs to be after an amount is entered in the issue form
            
            If Not escaped% Then
               If drug.prepack = "P" And Not ret Then blnPrintLabel = True
               PutWardListID curline  '08Jan15 TH Added (TFS 106426)
               HandleWardIssue quantity!, costcentre$, lastissueqty$, escaped%, (drug.paksize), LabelQty$, blnPrintLabel, curline, True '28Mar13 TH Added Param (TFS 58711) '09Jan02 TH Use new printlabel param to supress labels on returns (#37539)
               PutWardListID 0        '08Jan15 TH Added to clear (TFS 106426)
            End If
            
            setm_lngWardStockTopUpLevel 0 '07Jan15 TH Escaped or not we must reset this to ensure no future issue engages this check
            
         Else
            If drugs(curline&).prepack = "P" And Not ret Then blnPrintLabel = True  '09Jan02 TH Added (#37539)
            HandleWardIssue quantity!, costcentre$, lastissueqty$, escaped%, (drugs(curline&).paksize), LabelQty$, blnPrintLabel, curline, False '28Mar13 TH Added Param (TFS 58711) '09Jan02 TH Use new printlabel param to supress labels on returns (#37539)
         End If
         
         

         'HandleWardIssue quantity!, CostCentre$, LastIssueQty$, escaped%, (drugs(curline&).paksize), LabelQty$, (drugs(curline&).prepack = "P")  '23Dec97 EAC added ward stock packsize '21Jan99 EAC added "(drugs(curline&).prepack = "P")"



            If Not escaped% Then 'ASC 12Dec94
                  'LastIssueQty$ = Format$(Val(LastIssueQty$) / Val(drugs(curline&).paksize)) 16Jan98 EAC now handled in HandleWardIssue
                  '06Jul11 TH Here if set we should NOT update the array if no issue has yet taken place
                  'If Not (TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "N", "UpdateLinesOnIssue", 0)) And lastissueqty$ = "") Then
                  If Not (TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "Y", "ListUpdateEnabled", 0)) And lastissueqty$ = "") Then '21Jul11 TH Amalgamate settings now '26Sep11 TH Changed default (TFS14789)
                     If blnOCX Then  '08Jan15 TH Added section to ensure new list is updated on srtight issue - this will then be refreshed web side. (TFS 103886)
                        If Not sup.PrintPickTicket = "Y" Then UpdateWardStockListIssueData d.SisCode, sup.wardcode, "WSLIST", CLng(Val(lastissueqty$)), curline&  '10Feb15 TH Only update if actually issued - we still use the qty as an output param tho (TFS 111027)
                        lngIssueAmount = CLng(Val(lastissueqty$)) '28Jan15 TH Added for return param for ocx
                     Else
                        drugs(curline&).lastissue = lastissueqty$
                        drugs(curline&).lastissuedate = Format(Now, "dd/mm/yyyy")
            
                        drugs(curline&).dailyissue = Format$(Val(drugs(curline&).dailyissue) + Val(lastissueqty$)) '29Jan99 TH
                        
                        '19Oct06 TH Dont update if we are not supposed to be allowed to !(SC-06-0999)
                        If (WardStockPasslvl <> 5) And (WardStockPasslvl <> 1) Then lngSuccess = UpdateLineSQL(drugs(curline&), ward$)
                     End If
                  End If
                  
                  Select Case WardStockPasslvl
                    'Case 1           '11Nov99 TH Removed and added below to allow level one issues to be correctly recorded to mdb
                    'Case 2, 3, 4     '   "
                    Case 1, 2, 3, 4   '   "
                      'FindRecord curline&, matchfound%
                      'sql$ = "SELECT LastIssue,LastIssueDate FROM Layout WHERE (ScreenPosn = " & drugs(curline&).posn & " AND SiteName = '" & ward$ & "');"            '29Jan99 TH Replaced with below
                      SQL$ = "SELECT LastIssue,LastIssueDate,DailyIssue FROM Layout WHERE (ScreenPosn = " & drugs(curline&).posn & " AND SiteName = '" & ward$ & "');"
                      'SQL Set tempdyn = WSDB.CreateDynaset(SQL$)
                      'SQL tempdyn.LockEdits = False
                      'SQL If Not tempdyn.EOF Then
                           'SQL    tempdyn.Edit
                              'tempdyn!lastissue = drugs(curline&).lastissue        '12Jan99 SF replaced
                              'SQL If Trim$(drugs(curline&).lastissue) <> "" Then        '12Jan99 SF
                                    'SQL tempdyn!lastissue = drugs(curline&).lastissue   '     "
                                 'SQL Else                                               '     "
                                    'SQL tempdyn!lastissue = 0                           '     "
                                 'SQL End If                                             '     "
                              'SQL tempdyn!lastissuedate = drugs(curline&).lastissuedate
'SQL                               tempdyn!dailyissue = drugs(curline&).dailyissue  '29Jan99 TH
     'SQL                          tempdyn.Update
'SQL                         End If
                    Case Else
                  End Select
                  OInfoStore(curline&) = UpdateScreenLine(curline&)
                  'SQL MainScreen.lvwMainScreen.RefreshRow = curline&
                  RefreshlvwMainScreenRow curline&, True 'SQL
                  
               End If
            
            k.escd = False
         End If
   
      tempcode$ = IssueString$                  '26Jun98 CFY Added
   
   Loop While Mode = 3 'AND NOT k.escd
   

End Sub

Sub Printoldstocklabels(NumofLabels%, NumOfDupes%, costcentre$)
'02Dec99 TH Reinstated old code form handlewardissue to allow non RTF wardstocklistprinting

Dim Qty$(), loopvar%, loopvar2%, Numoflines%, warntxt$, loopvar3%, warnings$(), numofwarns%, found%, WSTxt$
Dim vatrate!, cost$, expiry$, body$, escaped%, loopvar4%
ReDim Qty$(NumofLabels)
ReDim warnings$(5)


    For loopvar = 1 To NumofLabels
        ReDim labelline$(10)
        'deflines d.Description, labelline$(), "!", 2, Numoflines  XN 4Jun15 98073 New local stores description
        deflines d.LabelDescription, labelline$(), "!", 2, Numoflines
        If Trim$(labelline$(4)) <> "" Then labelline$(3) = labelline$(3) & " " & labelline$(4)
        GetInsCode d.inscode, labelline$(1)
        GetWarCode d.warcode2, warntxt$
        deflines warntxt$, warnings$(), Chr$(30) & "(*)", 1, numofwarns
        For loopvar3 = 1 To numofwarns
            labelline$(6 + loopvar3) = warnings$(loopvar3)
        Next
        labelline$(4) = Space$(16) & Mid$(date$, 4, 3) & Left$(date$, 3) & Right$(date$, 4)
        Qty$(loopvar) = Trim$(Format$(LabelValues!(loopvar)))
        labelline$(5) = Space$(16) & "Qty " & Qty$(loopvar)
        
        labelline$(5) = labelline$(5) & Trim$(d.PrintformV)
        labelline$(6) = Space$(16) & "(" & UserID$ & ")"
        WSTxt$ = TxtD$(dispdata$ & "\winord.ini", "WardStockList", "Ward Stock", "LabelDescription", found)
        labelline$(10) = WSTxt$ & " (" & costcentre$ & ")"
        If PrintStockCost Then
            vatrate! = VAT(Val(d.vatrate))                                                                                                       '01Sep98 CFY Added
            If PrintInPacks And (sup.PrintPickTicket = "Y" Or sup.PrintDeliveryNote = "Y") Then
                    cost$ = Str$(vatrate! * (Val(d.cost) * Val(Qty$(loopvar))) / 100)
                    '
                Else
                    cost$ = Str$(vatrate! * (Val(d.cost) * (Val(Qty$(loopvar)) / Val(d.convfact))) / 100)
                End If
            poundsandpence cost$, True
            labelline$(10) = labelline$(10) & Space$(3) & "Cost: " & money(5) & Trim$(cost$)
        End If
        expiry$ = ""

        
        body$ = ""
        For loopvar4 = 1 To UBound(labelline$) - 1
            body$ = body$ & labelline$(loopvar4) & crlf
        Next
        body$ = body$ & labelline$(UBound(labelline$))
    
        Editor.cmdBtn(1).Visible = False
        TextEdit "", body$, "", True, True
    
        replace body$, Chr$(9), "[tab]", 0
        replace body$, Chr$(10), "", 0
    
        deflines body$, labelline$(), cr & "(*)", 1, Numoflines
        
        NumofLabels = 1
        body$ = ""
        k.escd = False
        
        For loopvar3 = 1 To Numoflines
            processcolour labelline$(loopvar3)
            body$ = body$ & "[CondOn]" & labelline$(loopvar3) & Chr$(13)
        Next
    
        ''''Reverselabel escaped
        For loopvar2 = 1 To NumOfDupes
            escaped = 52
            printextralabel body$, escaped
        Next
        ''''forwardlabel escaped
    Next
End Sub

'//// stub proc called in error
''Sub PrintStockLabels(IssueQty!, NSVCode$, WardCd$, NumofLabels%, NumOfDupes%)
''
'''Assumes that d and sup are still set from call to Issue previously
''
'''21Jan99 EAC Written
'''12May99 TH  Parse colour codes out of instructions
'''09Jul99 TH  Replaced storesdescription with description on stocklabel
'''20Jul99 TH  Get actual qtys from issue screen to put on stocklabels
'''23Nov99 AE  Added Kill to remove local files
'''06Dec99 TH  Use new unique context for Ward Stock Labels
'''07Dec99 TH  Puts only drug description details in drug* elements - was retaining warning info in redundant lines
'''10Feb00 AE  Moved Kill from 29Nov99 inside IF
'''23feb00 VS/MMA/TH Check if return and if so put neg qty on label
'''08Mar00 TH/MMA added to allow number of containers to label = 0
'''22Mar00 TH  corrected above (merge error)
'''30Mar00 TH  Mods to correctly calculate costs (positive or negative)
'''14Apr00 MMA/AW Costs shown as -ve values for returns and +ve values for issues
'''19Apr00 TH  Mod to repair the damage caused the above mod (oops)
'''23May00 JN  Problem with multiple label printing - only first label shows freehand text entry
'''            Print the Labels routine re-arranged to fix this, includes new mod ChangeQtyCostinRTF to parse the Qty and Cost changes to RTF file
'''20Sep00 JN  Fixed 'file not found' error with multiple label printing
'''23Oct00 TH  If there are no labels to print then dont print anything ! (47216)
''
''Dim snap As snapshot
''Dim RTFFile$, temp$, outfile$, SQL$
''Dim success%, loopvar%, loopvar2%, numofwarns%
''Dim ToIssue!, quantity!, vatrate!
''ReDim TempArray$(10)
''Dim returntostock%      '23feb00 VS/MMA/TH added new flag variable
''Dim returnedquantity%   '14Apr00 MMA/AW added
''Dim newrtf$             '24May00 JN added
''
''   If NumOfLabels% < 1 Then Exit Sub  '23Oct00 TH  If there are no labels to print then dont print anything !
''
''   ReDim cost$(NumOfLabels%)
''   ReDim Qty$(NumOfLabels%)
''
''
''   returntostock = 0    '23feb00 VS/MMA/TH added line, set variable to 1  '14Apr00 MMA/AW changed
''   returnedquantity = 1                                                   '14Apr00 MMA/AW added
''   RTFFile$ = ""
''   'Look in MDB for NSVCode/WardCd combination to find if it has a rtf file defined
''   SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '" & NSVCode & "' AND wardcode = '" & WardCd$ & "'"
''   Set snap = StckLblDb.CreateSnapshot(SQL$)
''   If snap.EOF Then
''         SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '" & NSVCode & "' AND wardcode = '*****'"
''         Set snap = StckLblDb.CreateSnapshot(SQL$)
''      End If
''   If snap.EOF Then
''         SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '*******' AND wardcode = '" & WardCd$ & "'"
''         Set snap = StckLblDb.CreateSnapshot(SQL$)
''      End If
''
''   If Not snap.EOF Then RTFFile$ = dispdata$ & getfield(snap!RTFfilename)
''   snap.Close
''   Set snap = Nothing
''
''   'Otherwise use the default stkLabel.rtf
''   If Trim$(RTFFile$) = "" Then RTFFile$ = dispdata$ & "\stklabel.rtf"
''
''   'Ensure stock label layout file exists else exit
''   If Not fileexists(RTFFile$) Then
''         popmessagecr ".Stock Label Printing", RTFFile$ & " is missing. Stock Label cannot be printed. Please inform your system supervisor."
''         Exit Sub
''      End If
''
''   'Fill the heap
''   GetInsCode d.inscode, temp$
''   If InStr(temp$, "!") = 2 Then temp$ = Mid$(temp$, 3)  '12May99 TH Moved plingparse to before heap call
''   Heap 10, gPRNheapID, "Instruct", temp$, success%
''   'If InStr(temp$, "!") = 2 Then temp$ = Mid$(temp$, 3)
''
''   GetWarCode d.warcode2, temp$
''   deflines temp$, TempArray$(), Chr$(30) & "(*)", 1, numofwarns
''   For loopvar = 1 To 3
''      If InStr(TempArray$(loopvar), "!") = 2 Then TempArray$(loopvar) = Mid$(TempArray$(loopvar), 3)
''      Heap 10, gPRNheapID, "Warn" & Trim$(Format$(loopvar)), TempArray$(loopvar), success%
''   Next
''
''   'temp$ = GetStoresDescription()  '09Jul99 TH Replaced with below
''   temp$ = d.Description            '   "
''   ReDim TempArray$(10)          '07Dec99 TH Puts only drug description details was retaining warning info
''   deflines temp$, TempArray$(), "!" & "(*)", 1, numofwarns
''   For loopvar = 1 To 3
''      Heap 10, gPRNheapID, "Drug" & Trim$(Format$(loopvar)), TempArray$(loopvar), success%
''   Next
''
''   Heap 10, gPRNheapID, "CCentre", WardCd$, success%
''
''   FillHeapDrugInfo gPRNheapID, d, success%
''
''   vatrate! = VAT(Val(d.vatrate))
''   ToIssue! = IssueQty!
''
''   If IssueQty < 0 Then     '23feb00 VS/MMA/TH added line   '14Apr00 MMA/AW changed
''         returntostock = -1                                 '14Apr00 MMA/AW
''         returnedquantity% = -1                             '14Apr00 MMA/AW
''    End If                                                  '14Apr00 MMA/AW
''
''   For loopvar = 1 To NumOfLabels
''      If ToIssue! < Val(d.convfact) Then
''            quantity! = ToIssue!
''         Else
''            quantity! = Val(d.convfact)
''         End If
''      ToIssue! = ToIssue! - quantity!
''
''      'qty$(loopvar) = Trim$(Format$(quantity!))            '20Jul99 TH Replaced with below
''      'qty$(loopvar) = Trim$(Format$(LabelValues!(loopvar))) '20Jul99 TH Get actual qtys from issue screen
''       Qty$(loopvar) = Trim$(Format$((LabelValues!(loopvar) * returnedquantity%)))          '23feb00 VS/MMA/TH replaced above  '14Apr00 MMA/AW changed
''      'temp$ = Str$(vatrate! * (Val(d.cost) * (quantity! / Val(d.convfact))) / 100)
''      'temp$ = Str$(Abs(vatrate! * (Val(d.cost) * (Val(qty$(loopvar)))) / 100))  '30Mar00 TH calculate costs based on correct qty and use unit cost correctly (maybe)
''      temp$ = Str$(Abs(vatrate! * (Val(d.cost) * (Val(Qty$(loopvar)) / Val(d.convfact))) / 100)) '19Apr00 TH okay okay, so maybe it was right after all
''      poundsandpence temp$, True
''
''      cost$(loopvar) = money(5) & Trim$(temp$)
''      If returntostock Then cost$(loopvar) = "-" & cost$(loopvar)  '30Mar00 TH Added to deal with neg costs
''   Next
''
''   'Print the Labels
''   '24May00 JN - Comments on label only shown on first one
''   '             Routine re-arranged to combat this
''
''   '24May00 JN - Remove any prior references to Qty and Cost from Heap
''   Heap 12, gPRNheapID, "Qty", "", success%
''   Heap 12, gPRNheapID, "Cost", "", success%
''
''   parseRTF RTFFile$, outfile$   '24May00 JN Moved parsertf here to compose outfile$ once
''                                 '           without Qty and Cost added
''   If outfile$ <> "" Then
''         Hedit 11, outfile$
''
''         For loopvar = 1 To NumOfLabels
''
''            Heap 10, gPRNheapID, "Qty", Qty$(loopvar), success%   '24May00 JN drop Qty and Cost onto heap
''            Heap 10, gPRNheapID, "Cost", cost$(loopvar), success% '           for individual print
''
''            parseRTF outfile$, newrtf$    '24May00 JN creates rtfnew$ for use with Qty and Cost changes
''
''            'parsertf rtffile$, outfile$  '23May00 JN moved outside loop
''            If Trim$(newrtf$) <> "" Then  '24May00 JN changed from outfile$ to newrtf$
''                  'hedit 11, outfile$                              '23May00 JN Moved
''                  For loopvar2 = 1 To NumOfDupes
''                     'HEdit 14, "Displbl" & Chr$(0) & outfile$    '06Dec99 TH Use new unique context for Ward Stock Labels
''                     'HEdit 14, "WSlbl" & Chr$(0) & outfile$       '    "
''                      Hedit 14, "WSlbl" & Chr$(0) & newrtf$       '24May00 JN now reads from newrtf$
''                      'Kill newrtf$                               '24May00 JN Added '20Sep00 JN moved below End If
''                  Next
''               End If
''            Kill newrtf$                                          '20Sep00 JN Moved here
''         Next
''
''         'Kill outfile$                                              '23Nov99 AE Added Kill to remove local files  '22Mar00 TH Removed line
''         Kill outfile$                        '08Mar00 TH/MMA added
''      End If
''End Sub

Sub PrintStockLabelsSQL(IssueQty!, NSVCode$, WardCd$, NumofLabels%, NumOfDupes%)

'Assumes that d and sup are still set from call to Issue previously
'14Aug14 TH suppress preview (TFS 97937)
'04Jan17 TH Use DB Parsing (Hosted) (TFS 157969)

''Dim snap As snapshot
Dim RTFfile$, temp$, OutFile$
Dim success%, loopvar%, loopvar2%, numofwarns%
Dim ToIssue!, quantity!, vatrate!
ReDim TempArray$(10)
Dim returntostock%
Dim returnedquantity%
Dim newrtf$
'''Dim objdata As clsDataAccess
Dim strParams As String
Dim RSStockLabels As ADODB.Recordset

   If NumofLabels% < 1 Then Exit Sub
   ReDim cost$(NumofLabels%)
   ReDim Qty$(NumofLabels%)


   returntostock = 0
   returnedquantity = 1
'@@   RTFfile$ = ""
   'Look in MDB for NSVCode/WardCd combination to find if it has a rtf file defined
   'SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '" & NSVCode & "' AND wardcode = '" & WardCd$ & "'"
   'Set snap = StckLblDb.CreateSnapshot(SQL$)
   'If snap.EOF Then
   '      SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '" & NSVCode & "' AND wardcode = '*****'"
   '      Set snap = StckLblDb.CreateSnapshot(SQL$)
   '   End If
   'If snap.EOF Then
   '   SQL$ = "SELECT rtffilename FROM StockLabels WHERE drugcode = '*******' AND wardcode = '" & WardCd$ & "'"
   '   Set snap = StckLblDb.CreateSnapshot(SQL$)
   'End If

   'If Not snap.EOF Then RTFFile$ = dispdata$ & getfield(snap!RTFfilename)
   'snap.Close
   'Set snap = Nothing
   ''Set objdata = New clsDataAccess
'@@   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'@@               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode) & _
'@@               gTransport.CreateInputParameterXML("wardcode", trnDataTypeVarChar, 5, wardcode)
'@@   Set RSStockLabels = gTransport.ExecuteSelectSP(g_SessionID, "pWStockLabelsbyDrugCodenadSiteIDandWard", strParams)
   ''Set objdata = Nothing
'@@   If Not RSStockLabels Is Nothing Then
'@@      If RSStockLabels.State = adStateOpen Then
'@@         If RSStockLabels.RecordCount > 0 Then
'@@            RSStockLabels.MoveFirst
'@@            RTFfile$ = dispdata$ & RtrimGetField(RSStockLabels!RTFfilename)
'@@         End If
'@@      End If
'@@   End If
'@@   RSStockLabels.Close
'@@   Set RSStockLabels = Nothing
  ' 'Otherwise use the default stkLabel.rtf
  ' If Trim$(rtffile$) = "" Then rtffile$ = dispdata$ & "\stklabel.rtf"
  '
  ' 'Ensure stock label layout file exists else exit
  ' If Not fileexists(rtffile$) Then
         
   If SpecificStockLabelLayout(NSVCode, WardCd, RTFfile) = 0 Then          '16Oct06 CKJ replaces block above   31Dec07 CKJ Ported Block from V8.7
      popmessagecr ".Stock Label Printing", RTFfile$ & " is missing." & cr & "Stock Label cannot be printed." & cr & "Please inform your system supervisor."
      Exit Sub
   End If

   'Fill the heap
   GetInsCode d.inscode, temp$
   If InStr(temp$, "!") = 2 Then temp$ = Mid$(temp$, 3)
   Heap 10, gPRNheapID, "Instruct", temp$, success%
   GetWarCode d.warcode2, temp$
   deflines temp$, TempArray$(), Chr$(30) & "(*)", 1, numofwarns
   For loopvar = 1 To 3
      If InStr(TempArray$(loopvar), "!") = 2 Then TempArray$(loopvar) = Mid$(TempArray$(loopvar), 3)
      Heap 10, gPRNheapID, "Warn" & Trim$(Format$(loopvar)), TempArray$(loopvar), success%
   Next
   
   temp$ = d.LabelDescription ' temp$ = d.Description XN 4Jun15 98073 New local stores description
   ReDim TempArray$(10)
   deflines temp$, TempArray$(), "!" & "(*)", 1, numofwarns
   For loopvar = 1 To 3
      Heap 10, gPRNheapID, "Drug" & Trim$(Format$(loopvar)), TempArray$(loopvar), success%
   Next

   Heap 10, gPRNheapID, "CCentre", WardCd$, success%

   FillHeapDrugInfo gPRNheapID, d, success%
      
   vatrate! = VAT(Val(d.vatrate))
   ToIssue! = IssueQty!

   If IssueQty < 0 Then
      returntostock = -1
      returnedquantity% = -1
   End If

   For loopvar = 1 To NumofLabels
      If ToIssue! < Val(d.convfact) Then
         quantity! = ToIssue!
      Else
         quantity! = Val(d.convfact)
      End If
      ToIssue! = ToIssue! - quantity!
      Qty$(loopvar) = Trim$(Format$((LabelValues!(loopvar) * returnedquantity%)))
      temp$ = Str$(Abs(vatrate! * (Val(d.cost) * (Val(Qty$(loopvar)) / Val(d.convfact))) / 100))
      poundsandpence temp$, True
      
      cost$(loopvar) = money(5) & Trim$(temp$)
      If returntostock Then cost$(loopvar) = "-" & cost$(loopvar)
   Next
   
   If GetRobotPrintLabelMessageID() Then                             '16oct06 CKJ Robot printing required   31Dec07 CKJ Ported block from V8.7
      Heap 10, gPRNheapID, "Qty", Qty$(1), False                     'Whole packs only, so first labels identical for Qty & Cost
      Heap 10, gPRNheapID, "Cost", cost$(1), False
      
      'ParseThenPrint "WSlbl", RTFfile$, 1, False, False                    'Robot printing done automagically '21Jun11 TH Added Param
      ParseThenPrint "WSlbl", RTFfile$, 1, False, False, False '04Jan17 TH Use DB Parsing (Hosted)
      NumOfDupes = NumOfDupes - 1
   End If

   If NumOfDupes > 0 Then
      'Print the Labels
   Heap 12, gPRNheapID, "Qty", "", success%
   Heap 12, gPRNheapID, "Cost", "", success%

   'parseRTF RTFfile$, OutFile$ '03Jan03 TH This is a shared file so needs conversion to read from DB
   parseRTFfromDB RTFfile$, OutFile$ '04Jan17 TH This is a shared file so needs conversion to read from DB
                                
   If OutFile$ <> "" Then
   
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "N", "PreviewWardStockLabelPrint", 0)) Then Hedit 11, OutFile$ '14Aug14 TH suppress preview (TFS 97937)
      
      For loopvar = 1 To NumofLabels
   
         Heap 10, gPRNheapID, "Qty", Qty$(loopvar), success%
         Heap 10, gPRNheapID, "Cost", cost$(loopvar), success%
   
         parseRTF OutFile$, newrtf$ '03Jan03 TH Retain this as old because here we are only parsing local files
   
         If Trim$(newrtf$) <> "" Then
            For loopvar2 = 1 To NumOfDupes
               Hedit 14, "WSlbl" & Chr$(0) & newrtf$
            Next
         End If
         Kill newrtf$
      Next
      Kill OutFile$
   End If
      End If
   
End Sub

Sub SaveAsNewWard()

'This is no longer appropriate as we no longer have a supplier editor in v9.3
'Therefor now we will only offer the ability to attach to an existing supplier
'(?Ward or List type only) and then only one that has no existing layout records.
'06Jun12 TH Removed val around Localcode (TFS 35845)


Dim escd%, loopvar%
Dim supcode$
Dim strPrintLabel As String
Dim lngReturn As Long
Dim strParams As String
Dim lngCount As Long

    'supcode$ = "NEW"    '28Mar01 TH Altered
    'supcode$ = "<NEW>"   '    "
    'AmendSuppliers False, supcode$, escd%
   setinput 0, k
   k.escd = False
   k.helpnum = 0
   asksupplier "", 0, "WL", "Enter Supplier Code", False, sup, False '15Nov12 TH Added PSO param
   
   If Not escd Then
      'Now we must check to make sure that this ward has no existing records
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gWardStockSite) & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, sup.Code)
      lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWWardStockListCountbySiteName", strParams)
      If lngCount > 0 Then
         popmessagecr "Ward Stock", "This Supplier already has Ward Stock List records - New records cannot be saved"
      Else
         For loopvar = 1 To UBound(drugs)
            If Trim$(drugs(loopvar).prepack) = "" Then
               strPrintLabel = "~"
            Else
               strPrintLabel = UCase$(Trim$(drugs(loopvar).prepack))
            End If
            supcode$ = sup.Code
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                        gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, loopvar) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(drugs(loopvar).catno)) & _
                        gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(drugs(loopvar).drugttl)) & _
                        gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, strPrintLabel) & _
                        gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(supcode$)) & _
                        gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(drugs(loopvar).stklevl)) & _
                        gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(drugs(loopvar).paksize)) & _
                        gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, "") & _
                        gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, drugs(loopvar).localcode) & _
                        gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, Val(drugs(loopvar).barcode)) & _
                        gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
                        gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
            lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardStockList", strParams)
         Next
      End If
   End If

End Sub
   
Sub SetupStockLabels()
   'Reads the stores ini file to determine if StockLabels should be printed on every stock issue
   'PrintStockLblsByDefault holds the value to be passed to ISSUE in the ACTION parameter
   
   '21Jan99 EAC written
   
   Dim found As Integer
   
   If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "", "PrintStockLabelsByDefault", found)) = True Then
      PrintStockLblsByDefault = 7
   Else
      PrintStockLblsByDefault = 6
   End If
   
End Sub

Sub SortMarkedBlock(MnuOption As Integer, DisplayAscending As Integer)
   '11Apr02 TH Added mod to retain original grid position (#17751)
   
Dim BlkStart&, BlkEnd&, longloop&
Dim valid%, WholeTable%, success%, escaped%
Dim SQL$
Dim intRow As Integer '11Apr02 TH (#17751)
Dim strParams As String
Dim lngResult As Long
   
   
   DimensionBlock BlkStart&, BlkEnd&, valid
   
   If (BlkEnd& - BlkStart&) = 0 And Not (BlkStart& = 0 And BlkEnd& = 0) Then
      valid = False
      popmessagecr "Error", "Only one line was selected." & Chr$(13) & "Please select some more lines and try again."
   End If
   
   If valid Then
      If BlkStart& = 0 And BlkEnd& = 0 Then WholeTable = True  'SQL MUST HANDLE HIS DIFFERENTLY
      
      'SQL$ = "SELECT * FROM Layout WHERE (SiteName = '" & ward$ & "'"
   ''      If WholeTable Then
   ''          'SQL$ = SQL$ & ")"
   ''      'Else
   ''          'SQL$ = SQL$ & ") AND (ScreenPosn >= " & BlkStart& & " AND ScreenPosn <= " & BlkEnd& & ")"
   ''      End If
      
      ''Set objdata = New clsDataAccess
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                  gTransport.CreateInputParameterXML("BlkStart", trnDataTypeint, 4, BlkStart&) & _
                  gTransport.CreateInputParameterXML("BlkEnd", trnDataTypeint, 4, BlkEnd&) & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$)
   
      Select Case MnuOption
         Case 1
           If DisplayAscending Then
            Else
            End If
         Case 0
            If DisplayAscending Then
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListSortMarkedBlockbyDescriptionASC", strParams)
            Else
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListSortMarkedBlockbyDescriptionDESC", strParams)
            End If
         Case 2
            If DisplayAscending Then
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListSortMarkedBlockbyNSVCodeASC", strParams)
            Else
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListSortMarkedBlockbyNSVCodeDESC", strParams)
            End If
      End Select
            
      intRow = MainScreen.lvwMainScreen.SelectedItem.Index
      LoadWard success, escaped, False
      ChangeTable "blank", False   '14Aug12 TH Added Param  '17Oct05 TH swiz to help resizing
      DisplayPage
      MainLVWHighlightSingleRowByIndex intRow
   End If

End Sub

Function SpecificStockLabelLayout(ByVal NSVCode As String, ByVal wardcode As String, ByRef pathfileRTF As String) As Integer
'11oct06 CKJ Written
'Look in MDB for NSVCode/WardCode combination to find if it has a rtf file defined
'retval shows whether a specific layout is available
' 4   ward and drug specific
' 3   drug specific, any ward
' 2   ward specific, any drug
' 1   no layout specified, but default layout is available
' 0   error occurred
'returns rtffilename as "x:\dispdata.xxx\filename.rtf" unless an error occurs
'     however filename is only valid if retval>0
'31Dec07 CKJ Converted from V8 to V9
'11Feb08 TH Ensure that the correct rtf name and path is returned (F0015240)
'05Jan17 TH Replaced RTF Handling (Hosted) (TFS 157969)
'26Jan17 TH Replaced fileexists to use DB (Hosted) checking (TFS 174442)

'Dim Snap as Snapshot
Dim retval As Integer
'Dim query As String
'Dim andward As String
Dim RSStockLabels As ADODB.Recordset
Dim strParams As String
Dim RTFfile As String
Dim intSuccess As Integer   '05Jan17 TH Added

   retval = 0                                                                'assume layout not available
   pathfileRTF = ""                                                          'no name until specified
   On Error GoTo SpecificStockLabelLayout_Err
 
 '  query = "SELECT rtffilename FROM StockLabels WHERE drugcode = '"
 '  andward = "' AND wardcode = '"
 '
 '  Set snap = StckLblDb.CreateSnapshot(query & NSVCode & andward & wardcode & "'")
 '  If Not snap.EOF Then
 '     retval = 4
 '  Else
 '     Set snap = StckLblDb.CreateSnapshot(query & NSVCode & andward & "*****'")
 '     If Not snap.EOF Then
 '        retval = 3
 '     Else
 '        Set snap = StckLblDb.CreateSnapshot(query & "*******" & andward & wardcode & "'")
 '        If Not snap.EOF Then
 '           retval = 2
 '        Else
 '           pathfileRTF = "stklabel.rtf"                                     'use default stock label name
 '           retval = 1
 '        End If
 '     End If
 '  End If
 '
 '  Select Case retval
 '     Case 2, 3, 4
 '        pathfileRTF = GetField(snap!RTFfilename)
 '     End Select
  
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("DrugCode", trnDataTypeVarChar, 7, NSVCode) & _
               gTransport.CreateInputParameterXML("WardCode", trnDataTypeVarChar, 5, wardcode)
   Set RSStockLabels = gTransport.ExecuteSelectSP(g_SessionID, "pWStockLabelsbyDrugCodeandSiteIDandWard", strParams)
   If Not RSStockLabels Is Nothing Then
      If RSStockLabels.State = adStateOpen Then
         If RSStockLabels.RecordCount > 0 Then
            RSStockLabels.MoveFirst
            RTFfile$ = dispdata$ & RtrimGetField(RSStockLabels!RTFfilename)
            retval = 4
            If RtrimGetField(RSStockLabels!wardcode) = "*****" Then retval = retval - 1
            If RtrimGetField(RSStockLabels!DrugCode) = "*******" Then retval = retval - 2
         End If
      End If
   End If

   'Otherwise use the default stkLabel.rtf
   If Trim$(RTFfile$) = "" Then
      RTFfile$ = dispdata$ & "\stklabel.rtf"
      retval = 1
   End If

   If retval > 0 Then
      'pathfileRTF = dispdata$ & "\" & pathfileRTF    '11Feb08 TH Replaced
      pathfileRTF = RTFfile$                          '    "
      'If Not fileexists(pathfileRTF) Then retval = 0
      'GetRTFTextFromDB pathfileRTF, "", intSuccess    '05Jan17 TH Replaced above line (Hosted)
      'If Not intSuccess Then retval = 0               '  "
      If Not RTFExistsInDatabase(pathfileRTF) Then retval = 0  '26Jan17 TH Replaced above line
   End If

SpecificStockLabelLayout_Exit:
   On Error Resume Next
'   snap.Close
'   Set snap = Nothing
   RSStockLabels.Close
   Set RSStockLabels = Nothing
   On Error GoTo 0
   SpecificStockLabelLayout = retval
Exit Function

SpecificStockLabelLayout_Err:
   'exit val already 0
   popmessagecr ".", "Err:" & Str$(Err) & cr & Error$
Resume SpecificStockLabelLayout_Exit

End Function

'27Jun11 CKJ Unused - removed
'Sub SWAPdrug(drug1 As drugdetails, drug2 As drugdetails)
'
'Dim tempdrug As drugdetails
'
'   LSet tempdrug = drug1
'   LSet drug1 = drug2
'   LSet drug2 = tempdrug
'
'End Sub

Sub TerminateApp()

   Close
   storesEnd

End Sub

Sub UpdateDrugArray(arraypos&, screenpos&, drug$, title$, PackSize$, topupqty$, PrintLabel$, lastissue$, lastissuedate$, localcode$)
'21Oct97 EAC Rewritten to avoid having to look up entry in MDB
'            Has side benefit that it can be used for level one passwords as well now!
'05Nov97 EAC V8.05 Mods


    r.record = ""
    LSet drugs(arraypos) = r
    
    drugs(arraypos).posn = screenpos
    
    If Trim$(drug$) = "&" Then
            drugs(arraypos).drugttl = title$
            drugs(arraypos).catno = drug$
        Else
            drugs(arraypos).stklevl = topupqty$
            drugs(arraypos).paksize = PackSize$
            drugs(arraypos).drugttl = Trim$(title$)
            drugs(arraypos).catno = drug$
            drugs(arraypos).lastissue = lastissue$
            drugs(arraypos).dailyissue = Format$(Val(drugs(arraypos).dailyissue) + Val(lastissue$))   '29Jan99 TH
            
            If PrintLabel$ = "" Then
                drugs(arraypos).prepack = " "            'may need to seek to correct place in table before this
            Else
                drugs(arraypos).prepack = PrintLabel$            'may need to seek to correct place in table before this
            End If
            '05Nov97 EAC
            drugs(arraypos).lastissuedate = lastissuedate$
            drugs(arraypos).localcode = localcode$
        End If
    
End Sub

Function UpdateLineSQL(drugs As drugdetails, strSiteName As String) As Long
'23Apr09 TH Added trim around titletext (F0038841)

Dim strSql As String
Dim lngSuccess As Long
Dim lastIssDate As Date

   '23Apr09 TH Added trim around titletext (F0038841)
''   strSql = gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeint, 4, drugs.LayoutID) & _
''            gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''            gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, drugs.posn) & _
''            gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, drugs.catno) & _
''            gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(drugs.drugttl)) & _
''            gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, drugs.prepack) & _
''            gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, strSiteName) & _
''            gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(drugs.stklevl)) & _
''            gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, Val(drugs.lastissue)) & _
''            gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(drugs.paksize)) & _
''            gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, drugs.lastissuedate) & _
''            gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, drugs.localcode) & _
''            gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, drugs.barcode) & _
''            gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, Val(drugs.dailyissue))
''            'gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
''    lngSuccess = gTransport.ExecuteUpdateSP(g_SessionID, "WWardStockList", strSql)
    
    '15Dec14 TH Use New Structures - replaced above
    'Convert Last Issue date
    If Trim$(drugs.lastissuedate) = "" Then
      lastIssDate = CDate("30 December 1899") 'Equiv null
    Else
      lastIssDate = CDate(drugs.lastissuedate)
    End If
    strSql = gTransport.CreateInputParameterXML("WWardProductListLineID", trnDataTypeint, 4, drugs.LayoutID) & _
            gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, drugs.posn) & _
            gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, drugs.catno) & _
            gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, Trim$(drugs.drugttl)) & _
            gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, drugs.prepack) & _
            gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, Val(drugs.stklevl)) & _
            gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, Val(drugs.lastissue)) & _
            gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, Val(drugs.paksize)) & _
            gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeDateTime, 8, lastIssDate) & _
            gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, Val(drugs.dailyissue))
            'gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
    lngSuccess = gTransport.ExecuteUpdateSP(g_SessionID, "WWardProductListLine", strSql)
    
    UpdateLineSQL = lngSuccess

End Function


Function UpdateScreenLine$(linepos As Long)

'05Nov97 EAC V8.05

Dim tmp$

    tmp$ = Trim$(drugs(linepos&).drugttl) & "|"
    tmp$ = tmp$ & Trim$(drugs(linepos&).stklevl) & "|"
    tmp$ = tmp$ & Trim$(drugs(linepos&).paksize) & "|"
    tmp$ = tmp$ & Trim$(drugs(linepos&).prepack) & "|"
    If Trim$(drugs(linepos&).catno) = "&" Then
            tmp$ = tmp$ & "&" & "|" '08Nov05 TH added & to allow for bolding further upstream.
        Else
            '05Nov97 EAC
            'tmp$ = tmp$ & Trim$(drugs(linepos&).catno) & "|"
            tmp$ = tmp$ & Trim$(drugs(linepos&).localcode) & "|"
            '---
        End If
    tmp$ = tmp$ & Trim$(drugs(linepos&).lastissue) & "|"
    tmp$ = tmp$ & Trim$(drugs(linepos&).dailyissue) & "|"  '29Jan99 TH
    tmp$ = tmp$ & Trim$(drugs(linepos&).lastissuedate) & "|"         '05Nov97 EAC
    UpdateScreenLine$ = tmp$

End Function

Sub UpdateWardDrugFile(drug As String, DrugPtr As Long)   '01Jun02 ALL/ATW

Dim fnddrug&
Dim wardnod&, failed%, foundPtr&   '01Jun02 ALL/ATW
Dim tempdrug As DrugParameters


    If Trim$(drug$) <> "&" Then 'not a label
            'check to see if this drug is already in ward drug
            'file by looking at index
            '''''binarysearchidx drug$, warddispdata$ & "\drugsis.idx", True, 0, fnddrug&
            If fnddrug& = 0 Then
                    'drug isn't in ward stock drug file, so add it
                    getdrug d, (DrugPtr&), 0, False 'fnd%, False  '01Jun02 ALL/ATW
                    'set dispdata to look at ward
                    dispdata$ = warddispdata$
                    'SQL getnod wardnod&                                              '01Jun02 ALL/ATW
                    'increment nod for ward
                    wardnod& = wardnod& + 1
                    getdrug tempdrug, (wardnod&), foundPtr&, True ', fnd%, True  '01Jun02 ALL/ATW
                    LSet tempdrug = d
                    tempdrug.stocklvl = "0"
                    putdrug tempdrug  '', foundPtr&                                  '01Jun02 ALL/ATW
                    'write nod back for ward
                    'SQL savenod wardnod&                                             '01Jun02 ALL/ATW
                    'update index for ward drug file
''                    Updateindex "", Trim$(tempdrug.siscode), (wardnod&), warddispdata$ & "\drugsis.idx", failed%  '01Jun02 ALL/ATW
                    'sort index
                    ''''sortindex "", warddispdata$ + "\drugsis.idx"
                    'set dispdata back to site for which program is running
                    dispdata$ = dispdatastore$
                End If
        End If

End Sub

Sub Wardinfo()
'-----------------------------------------------------------------------------
'          Mainly for debugging, not really for the user to understand
'11Jan94 CKJ Added stock valuation
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 chars based on config setting (F0051906)
'-----------------------------------------------------------------------------
Dim flin%, llin%, lin%, foundPtr&  '01Jun02 ALL/ATW
Dim msg$, catnum$, totalval$, title$, temp$
Dim totval!, Value!
   
   title$ = "Ward Information"
   msg$ = "  Ward:" & Chr$(9)
   If ward$ = "" Then
         msg$ = msg$ & "Un-named" & Chr$(13)
      Else
         msg$ = msg$ & ward$ & Chr$(13)
         msg$ = msg$ & "  Code:" & Chr$(9) + Right$(wardcode$, GetWardCodeLen()) '4)       ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
         If Len(wardcode$) = (GetWardCodeLen() + 2) Then                                                                        ' 19May10 XN  (F0051906)
         'If Len(wardcode$) = 6 Then
               msg$ = msg$ & Space$(6) + "DCT No:" & Chr$(9) + Left$(wardcode$, 2) & Chr$(13)
            Else
               msg$ = msg$ & Chr$(13)
            End If
         msg$ = msg$ & "  Name:" & Chr$(9) + wardexp$ & Chr$(13)
      End If

   flin = LBound(drugs)
   llin = UBound(drugs)
   temp$ = "stock list  "
'   If blkst > 0 And BlkEnd > 0 Then      '02Jun11 CKJ Looks like it should work, but blkst & BlkEnd are never set
'         flin = blkst                    '            Consider using marked lines instead
'         llin = BlkEnd
'         temp$ = "marked block"
'      End If
   totval! = 0
   
   For lin = flin To llin
      catnum$ = Trim$(drugs(lin).catno)
   
      If Trim$(catnum$) <> "" And Trim$(catnum$) <> "&" Then
               d.SisCode = catnum$
               getdrug d, 0, foundPtr&, False                  '01Jun02 ALL/ATW
               If (foundPtr& <> 0) And (Val(d.convfact) > 0) Then  '01Jun02 ALL/ATW
                  Value! = Val(d.cost) / Val(d.convfact) ' per issue unit
                  Value! = Value! * Val(drugs(lin).stklevl) * Val(drugs(lin).paksize)
                  totval! = totval! + Value!
                  End If
            End If
      totalval$ = Str$(totval! / 100)
      poundsandpence totalval$, False
   Next lin
         
   msg$ = msg$ & Chr$(13)
   msg$ = msg$ & "  Value of " + temp$ + "     " & money(5) & totalval$ & Chr$(13)

   popmessagecr title$, msg$

End Sub


Sub WSLISTSQL()
'17May04 ckj removed sethelp

Dim success%, escaped%

   WardStockLoaded = True
   MainScreen.lvwMainScreen.Enabled = True

   maxlin = 1000
   If InStr(Command$, "/TEST") Then maxlin = 250

   ''''lblprn = Val(siteinfo$("LabelLPT", "1"))  '19Jan95 CKJ Added "1"

   'tab1 = 3        ' name/title
   'tab2 = 43       ' stock level
   'tab3 = 51       ' pack size
   'tab4 = 56       ' prepack/bulk
   'tab5 = 63       ' catalogue no
   'tab6 = 71       ' Qty last issued
   
   'set up blankdrug
   blankdrug.drugttl = ""
   blankdrug.stklevl = ""
   blankdrug.paksize = ""
   blankdrug.prepack = ""
   blankdrug.catno = ""
   blankdrug.lastissue = ""
   
   'set up for input routines
   setinput 0, k
   k.HelpFile = "wslist.hlp"
   'sethelp                                        '17May04 CKJ
   
   'displaywardname " ", 0                         ' set-up static vars in sub
                        
   'For loopvar = 1 To OTblMaxCols - 1
   '        MainScreen.lvwMainScreen.ColumnCellAttrs(loopvar) = True
   '    Next
   '''MainScreen.lvwMainScreen.ColumnCellAttrs(1) = True
   
   LoadWard success, escaped, True
   'If Not escaped Then DisplayPage              '26Mar98 CFY Removed. Now using k.escd instead as this never seemed to get set.
   If Not k.escd Then DisplayPage                '26Mar98 CFY
   
'31Mar04 CKJ {SP1} Removed as it performs no useful function - filenames undefined & unlocking on absent path is not possible
'   '31May96 EAC file locking
'   If Trim$(prevlock$) = "" Then
'         AcquireLock stockpath$ + "new_ward.lck", 0, success
'         If fileexists(stockpath$ + "new_ward.lck") Then : Kill stockpath$ + "new_ward.lck"
'      Else
'         AcquireLock stockpath$ + prevlock$ + ".lck", 0, success
'         If fileexists(stockpath$ + prevlock$ + ".lck") Then : Kill stockpath$ + prevlock$ + ".lck"
'      End If
'
'   If Trim$(filname$) = "" Then
'         AcquireLock stockpath$ + "new_ward.lck", 0, success
'         If fileexists(stockpath$ + "new_ward.lck") Then : Kill stockpath$ + "new_ward.lck"
'      Else
'         AcquireLock stockpath$ + filname$ + ".lck", 0, success
'         If fileexists(stockpath$ + filname$ + ".lck") Then : Kill stockpath$ + filname$ + ".lck"
'      End If

   On Error GoTo 0

End Sub


Sub AddLine(drug$)
'20Oct08 TH Fix to barcode handling (F0037033)
'19May10 TH Now allow stores only products to also be available for ward stock addition (F0055971)
'           However, this was explicitly turned off before, so I have put this on a setting with
'           the original behaviour (ie no stores only items) as default

Const procname$ = "AddLine"

Dim linepos%, foundPtr&, ScreenPosn%    '01Jun02 ALL/ATW  found%,
Dim title$, tofind$
Dim resumeval%, retries%
Dim localcode$                '05Nov97 EAC
Dim temp$                     '02Nov99 TH
Dim blnFound As Integer
Dim lngPacksize  As Long
Dim strParams As String
Dim strBarcode As String
Dim lngReturn As Long
Dim intStores As Integer '19May10 TH Added (F0055971)


   tofind$ = Trim$(drug$)

   'findrdrug tofind$, True, d, foundptr%, found%, 2
   If tofind$ <> "" Then
      'findrdrug tofind$, False, d, foundPtr&, blnFound, 2, False    '18Nov97 CKJ Do not show stores only items
      intStores = Val(TxtD(dispdata$ & "\winord.ini", "WardStock", "0", "AllowStoresOnly", 0))  '19May10 TH (F0055971)
      findrdrug tofind$, intStores, d, foundPtr&, blnFound, 2, False, False                            '  "         Replace above line and allow stores only (on setting)
   End If

   If Not blnFound Then
         title$ = drug$
         drug$ = "&"
         localcode$ = ""                        'O5Nov97 EAC add localcode$
      Else
         drug$ = d.SisCode
         '29Dec97 EAC Use Stores drug description
         'title$ = d.description
         title$ = d.DrugDescription     ' title$ = GetStoresDescription() XN 4Jun15 98073 New local stores description
         '---
         plingparse title$, "!"
         If Trim$(d.local) = "" Then
               localcode$ = Trim$(d.SisCode)
            Else
               localcode$ = Trim$(d.local)            'O5Nov97 EAC add localcode$
            End If
      End If

   'update the data in the table
   'MainScreen.lvwMainScreen.ColumnIndex = 1

   'set up table to display extra line
   If drugs(1).posn > 0 Then ONumToDisplay = ONumToDisplay + 1
   ReDim Preserve OInfoStore(1 To ONumToDisplay)
   '02Jun11 CKJ: ReDim OMarked(1 To ONumToDisplay)
   MainLVWRemoveSelection   '02Jun11 CKJ
   
   If ONumToDisplay = 1 Then
      linepos = 0
   Else
      linepos = UBound(drugs)
   End If
   linepos = linepos + 1
   ReDim Preserve drugs(1 To linepos)
   ScreenPosn = linepos '23Jan06 TH Added

   '21Oct97 EAC moved from Case 1 statement below
   UpdateDrugArray (linepos), (ScreenPosn), drug$, title$, Trim$(d.convfact), "0", "", "0", "", localcode$       'O5Nov97 EAC add localcode$

   Select Case WardStockPasslvl%
      Case 1
         '21Oct97 EAC do nothing as new line added to array above for speed
      Case 2, 3, 4
''         WSListData.AddNew
''         WSListData("NSVCode") = drug$
''         WSListData("ScreenPosn") = ScreenPosn
''         WSListData("SiteName") = ward$
''         WSListData("TitleText") = Trim$(Title$)
''         WSListData("PrintLabel") = "~"
         'lngPacksize = d.convfact  '29Aug97 EAC             '20Jul00 TH Prevent Type Mismatch on Descriptor line
         If Trim$(drug$) <> "&" Then
         lngPacksize = Trim$(d.convfact) 'WSListData("PackSize") = Trim$(d.convfact) '    "
         Else
         lngPacksize = 0
         End If
''         WSListData("LocalCode") = localcode$

         'Add new barcode field
         If Trim$(drug$) <> "&" Then             '02Nov99 TH Added
            temp$ = drug$                     '      "
            temp$ = bcode$(temp$)             '      "
            strBarcode = temp$     '      "
         End If                               '      "
         drugs(ONumToDisplay).barcode = "*" & strBarcode & "*" '20Oct08 TH Added (F0037033) '12Nov08 TH Added *s
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, (ScreenPosn)) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(drug$)) & _
                     gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, Trim$(title$)) & _
                     gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, "~") & _
                     gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward$) & _
                     gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, lngPacksize) & _
                     gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, "") & _
                     gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, localcode$) & _
                     gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
                     gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, 0) & _
                     gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, sup.SupplierID)
   
            lngReturn = gTransport.ExecuteInsertSP(g_SessionID, "WWardStockList", strParams)
            'tempdrugs(ScreenPosn).LayoutID = lngReturn 'TH ADDed
            drugs(ONumToDisplay).LayoutID = lngReturn  'TH ADDed

''         On Error GoTo ALUpdateTableErr
''         WSListData.Update
''         On Error GoTo 0

         'If Trim$(drug$) <> "&" Then UpdateWardDrugFile drug$, foundptr% '21Oct97 EAC comment out for now until needed
         '21Oct97 EAC speed up by adding to array above
      Case Else
   End Select

   OInfoStore(linepos) = UpdateScreenLine((linepos))

   RefreshLVWMainScreen True, True
   MainLVWHighlightSingleRowByIndex MainScreen.lvwMainScreen.ListItems.count

Exit Sub

ALUpdateTableErr:

   resumeval = ProcessUpdateErr(Err, modulename$, procname$, (linepos), retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
   End Select
   
End Sub
Function GetWardStocklistLines() As Long
'08Aug06 TH
Dim strParams As String

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
               gTransport.CreateInputParameterXML("WSiteName", trnDataTypeVarChar, 5, Trim$(ward$))
   GetWardStocklistLines = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListCountbySitename", strParams)

End Function
Sub readward(ward$, lastlin As Integer, success As Integer, ByVal blnAlpha As Boolean)
'-----------------------------------------------------------------------------
'                  Read a ward from disc & load into array
'17Oct97 EAC converted to use snapshot (readonly) and added GetField calls to
'            make more robust
'29Jan99 TH  code for daily issue field
'01Jun11 CKJ added as integer to lastlin & success
'-----------------------------------------------------------------------------

'''SHARED diskerr, errno
''
''Dim snap As snapshot
''Dim SQL$, desc$, pcksize$
''Dim linenum%, found%, tofind%
''
''    Screen.MousePointer = HOURGLASS
''
''    success = False      ' assume no ward until one is loaded successfully
''
''    ReDim drugs(1 To 1)       ' empty drugs array
''
''    tofind = 0
''    getsupplier ward$, tofind, found, False, sup
''    wardcode$ = Trim$(sup.wardcode)
''    wardexp$ = Trim$(sup.FullName)
''    wardname$ = wardexp$
''    dispdatastore$ = dispdata$
''    If trimz$(sup.icode) <> "" Then
''         warddispdata$ = "\dispdata." & Right$("000" & Right$(Trim$(sup.icode), 3), 3)
''      Else
''         warddispdata$ = dispdata$
''      End If
''
''    SQL$ = "SELECT * FROM LAYOUT WHERE (SiteName = '" & ward$ & "') ORDER BY ScreenPosn"
''    Set snap = WSDB.CreateSnapshot(SQL$)
''
''    dispdata$ = warddispdata$
''    Do While Not snap.EOF
''            linenum = linenum + 1
''            ReDim Preserve drugs(1 To linenum)
''            R.record = ""
''            LSet drugs(linenum) = R
''            If getfield(snap!NSVCode) = "&" Then
''                drugs(linenum).drugttl = getfield(snap!TitleText)
''                drugs(linenum).catno = "&"
''            Else
''                desc$ = trimz$(getfield(snap!TitleText))
''                pcksize$ = Format$(getfield(snap!packsize))
''                If Trim$(desc$) = "" Or getfield(snap!packsize) = 0 Then
''                        cleardrug d
''                        d.siscode = getfield(snap!NSVCode)
''                        getdrug d, 0, (found), False
''
''                        If trimz$(getfield(snap!TitleText)) = "" Then
''                                '29Dec97 EAC Use Stores drug description
''                                'desc$ = d.description
''                                desc$ = GetStoresDescription()
''                                '---
''                                plingparse desc$, "!"
''                                If Trim$(desc$) = "" Then desc$ = "Drug not found in drug file"
''                            End If
''
''                        If getfield(snap!packsize) = 0 Then
''                             pcksize$ = d.convfact
''                          End If
''
''                    End If
''
''
''                drugs(linenum).drugttl = desc$
''
''                drugs(linenum).stklevl = getfield(snap!topuplvl)
''
''                drugs(linenum).paksize = pcksize$
''
''                If getfield(snap!PrintLabel) = "~" Then
''                        drugs(linenum).prepack = " "
''                    Else
''                        drugs(linenum).prepack = getfield(snap!PrintLabel)
''                    End If
''                drugs(linenum).catno = getfield(snap!NSVCode)
''                drugs(linenum).lastissue = ""
''                drugs(linenum).dailyissue = "" '29Jan99 TH
''            End If
''            drugs(linenum).posn = getfield(snap!ScreenPosn)
''
''            drugs(linenum).posn = getfield(snap!ScreenPosn)
''            snap.MoveNext
''        Loop
''
''    snap.Close
''    Set snap = Nothing
''
''    dispdata$ = dispdatastore$
''
''    lastlin = linenum
''
''    success = True
''
''    Screen.MousePointer = STDCURSOR
Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim numofdrugs As Long
Dim DrugCode As String
Dim desc As String

Screen.MousePointer = HOURGLASS

      ' tofind = 0
      getsupplier ward$, 0, 0, sup
      wardcode$ = Trim$(sup.wardcode)
      wardexp$ = Trim$(sup.fullname)
      'wardname$ = wardexp$


strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(ward$))
         ''Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pLayoutBySiteName", strParams)
         Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteName", strParams)
         ''On Error GoTo loadwarderr
         If Not rsWardStock.EOF Then
            If blnAlpha Then rsWardStock.Sort = "TitleText"
            ReDim drugs(1 To 1)
            rsWardStock.MoveFirst
            
            Do Until rsWardStock.EOF
               If Trim$(GetField(rsWardStock!sitename)) = Trim$(ward$) Then
                  numofdrugs = numofdrugs + 1
                  ReDim Preserve drugs(1 To numofdrugs)
                  ''If numofdrugs > TotalDrugs Then Exit Do
                  LSet drugs(numofdrugs) = blankdrug
                  If Trim$(GetField(rsWardStock!NSVCode)) = "&" Then
                     drugs(numofdrugs).drugttl = GetField(rsWardStock!titletext)
                     drugs(numofdrugs).catno = "&"
                     drugs(numofdrugs).lastissuedate = ""
                  Else
                     DrugCode = Trim$(GetField(rsWardStock!NSVCode))
                     If trimz$(GetField(rsWardStock!titletext)) = "" Then
                        desc = "Description missing from ward stock database."
                     Else
                        desc = Trim$(GetField(rsWardStock!titletext))
                     End If
                     drugs(numofdrugs).drugttl = desc$
                     drugs(numofdrugs).stklevl = Trim$(GetField(rsWardStock!topuplvl))
                     drugs(numofdrugs).paksize = trimz$(GetField(rsWardStock!PackSize))
                     If rsWardStock!PrintLabel = "~" Then
                        drugs(numofdrugs).prepack = " "
                     Else
                        drugs(numofdrugs).prepack = Trim$(GetField(rsWardStock!PrintLabel))
                     End If
                     drugs(numofdrugs).catno = Trim$(DrugCode$)
                     drugs(numofdrugs).lastissue = Trim$(GetField(rsWardStock!lastissue))
                     drugs(numofdrugs).lastissuedate = Trim$(GetField(rsWardStock!lastissuedate))
                     drugs(numofdrugs).localcode = Trim$(GetField(rsWardStock!localcode))
                     If Trim$(drugs(numofdrugs).localcode) = "" Then drugs(numofdrugs).localcode = drugs(numofdrugs).catno
                     If rsWardStock!lastissuedate = Format(date, "dd/mm/yyyy") Then
                        drugs(numofdrugs).dailyissue = Trim$(GetField(rsWardStock!dailyissue))   '29Jan99 TH
                     Else
                        drugs(numofdrugs).dailyissue = "0" 'Trim$(GetField(snap!lastissue))   '29Jan99 TH
                     End If
                  End If
                  drugs(numofdrugs).posn = GetField(rsWardStock!ScreenPosn)
                  drugs(numofdrugs).barcode = GetField(rsWardStock!barcode)
                  drugs(numofdrugs).LayoutID = GetField(rsWardStock!WWardStockListID) 'Added To give access to DB using the key
               End If
               rsWardStock.MoveNext
            Loop
         End If
      
         rsWardStock.Close
         Set rsWardStock = Nothing
         lastlin = numofdrugs
         success = True
         Screen.MousePointer = STDCURSOR

End Sub

Public Sub UpdateWardStockListIssueData(ByVal strNSVCode As String, ByVal strWardCode As String, ByVal strMode As String, ByVal Qty As Long, ByVal WWardProductListLineID As Long)
'26Jun11 TH Written to allow updates of Ward Stock List from external processes (F0065354)
'13Mar12 TH Overhaul - looks like this was unfinished. Code was not runnable ! (TFS 29130)
'11Apr14 TH Changed Qty parameter from int to long (TFS 88720)
'18Dec14 TH Overhaul to use specific line from specific list if recorded from the req creation.
'12Jan15 TH Now we are going to work slightly differnetly if we are using the new world - we will always update lists (TFS 108042)
'           Also Ensure new Adhoc stuff and genuine dates are handled and used correctly
   

'Current this is a wrapper from adhoc or req issues where the ward may be a list that may need updating
'The rule is that if the item is on the list it will have the running daily qty updated and the date if required.
'If there are multiple lines for the item on the list then the user will be warned, but only the date will be updated.
'There is no locking of the row(s)


Dim strParams As String
Dim rsWardlist As ADODB.Recordset
Dim lngOK As Long
Dim strMsg As String
Dim blnChangeDate As Boolean
Dim blnUpdateEnabled As Boolean

   '12Jan15 TH Now we are going to work slightly differnetly if we are using the new world - we will always update lists (TFS 108042)
   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "Y", "UseWebWardStock", 0)) Then
      If WWardProductListLineID > 0 Then '18Dec14 TH Now we should know the exact line in most instances
         strParams = gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeint, 4, WWardProductListLineID) & _
                gTransport.CreateInputParameterXML("Qty", trnDataTypeint, 4, Qty) & _
                gTransport.CreateInputParameterXML("IssueDate", trnDataTypeDateTime, 8, Now)
         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListUpdateIssueData", strParams)  '13Mar12 TH Removed square brackets from sp name
      Else
         'Here we will just update all rows (individual or otherwise) as AdHocs.
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("Ward", trnDataTypeVarChar, 5, strWardCode) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
                     gTransport.CreateInputParameterXML("Qty", trnDataTypeint, 4, Qty) & _
                     gTransport.CreateInputParameterXML("IssueDate", trnDataTypeDateTime, 8, Now)
                      
         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListUpdateIssueDataAdHoc", strParams)  '13Mar12 TH Removed square brackets from sp name
      End If
   Else
      'This is the OLD WORLD !!
      'First check we are configured on this mode to try the update
   
      blnUpdateEnabled = TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "Y", "ListUpdateEnabled", 0)) '26Sep11 TH Changed default (TFS14789)
      If Not blnUpdateEnabled Then blnUpdateEnabled = TrueFalse(TxtD(dispdata$ & "\winord.ini", "WardStock", "N", strMode & "ListUpdateEnabled", 0))
      
      If blnUpdateEnabled Then
      
         If WWardProductListLineID > 0 Then '18Dec14 TH Now we should know the exact line in most instances
            strParams = gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeint, 4, WWardProductListLineID) & _
                   gTransport.CreateInputParameterXML("Qty", trnDataTypeint, 4, Qty) & _
                   gTransport.CreateInputParameterXML("IssueDate", trnDataTypeDateTime, 8, Format(Now, "DD/MM/YYYY"))
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListUpdateIssueData", strParams)  '13Mar12 TH Removed square brackets from sp name
               
         
         Else
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                         gTransport.CreateInputParameterXML("Ward", trnDataTypeVarChar, 5, strWardCode) & _
                         gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
                         
            Set rsWardlist = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStocklistbyNSVCodeandWard", strParams)
         
            If rsWardlist.RecordCount > 0 Then
            
               If rsWardlist.RecordCount > 1 Then
                  'we cannot be specific so here we must warn the user and then only update the date (if appropriate - test for this first)
                  
                  'msg to user
                  strMsg = "This item is on the associated ward stock list in more than one place. " & crlf & "Only the date last issued on the list will be updated."
                  strMsg = TxtD(dispdata$ & "\winord.ini", "WardStock", strMsg, "MultipleLineUpdateMsg", 0)
                  popmessagecr "", strMsg
                  
                  blnChangeDate = False  '13Mar12 TH Maybe superfluous but set default value
                  
                  'loop through rs
                  rsWardlist.MoveFirst
                  Do While (Not rsWardlist.EOF) And (Not blnChangeDate) '13Mar12 TH Add extra clause for performance
                     'If Format(Now, "DD/MM/YYYY") <> GetField(rsWardlist!DateLastIssued) Then blnChangeDate = True
                     If Format(Now, "DD/MM/YYYY") <> GetField(rsWardlist!lastissuedate) Then blnChangeDate = True     '13Mar12 TH Use correct field name
                     rsWardlist.MoveNext  '13Mar12 TH This was missing !!! Not good
                  Loop
                  
                  'if we have a date change then update where date <> date
                  '07Jan15 TH Changed wardcode to ward list ID
                  If blnChangeDate Then
                     strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                                 gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeVarChar, 5, GetField(rsWardlist!WWardStockListID)) & _
                                 gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
                                 gTransport.CreateInputParameterXML("IssueDate", trnDataTypeDateTime, 8, Format(Now, "DD/MM/YYYY"))
                         
                     lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListUpdateIssueDate", strParams) '13Mar12 TH Removed square brackets from sp name
                  End If
                 
               Else
                  'only one row so straight update
                  strParams = gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeint, 4, GetField(rsWardlist!WWardStockListID)) & _
                         gTransport.CreateInputParameterXML("Qty", trnDataTypeint, 4, Qty) & _
                         gTransport.CreateInputParameterXML("IssueDate", trnDataTypeDateTime, 8, Format(Now, "DD/MM/YYYY"))
                  lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWWardStockListUpdateIssueData", strParams)  '13Mar12 TH Removed square brackets from sp name
               End If
            End If
         
            rsWardlist.Close           '13Mar12 TH Clean up
            Set rsWardlist = Nothing   '  "
         End If
      End If
   End If
   
               


End Sub

Function CheckDLOItem(ByVal strSiscode As String, ByVal strCostCentre As String, ByVal lngLayoutID As Long) As Boolean
'30May12 TH Written
'28Mar13 TH Added line param to get specific line if possible(TFS 58711)
Dim blnResult As Boolean
Dim strParams As String
Dim lngOK As Long

   lngOK = 0
   If lngLayoutID > 0 Then
      strParams = gTransport.CreateInputParameterXML("WWardsStockListID", trnDataTypeint, 4, lngLayoutID)
      lngOK = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWWardStockItemDLOcheckbyWWardStockListID", strParams)  '13Mar12 TH Removed square brackets from sp name
      
   Else
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                  gTransport.CreateInputParameterXML("SisCode", trnDataTypeVarChar, 7, strSiscode) & _
                  gTransport.CreateInputParameterXML("CostCentre", trnDataTypeVarChar, 5, strCostCentre)
      lngOK = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWWardStockItemDLOcheck", strParams)  '13Mar12 TH Removed square brackets from sp name
   End If
   
   CheckDLOItem = (lngOK > 0)
      
End Function

Sub LoadWardLineIntoDrugDetails(ByVal WardStockListLineID As Long, ByRef drug As drugdetails)

'01Sep14 TH Written for WSList web integartion

Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim DrugCode$, desc$
Dim tempdrug As DrugParameters
Dim intStores As Integer    '05Aug16 KR Added

Dim blnFound&

   strParams = gTransport.CreateInputParameterXML("WardStockListLineID", trnDataTypeint, 4, WardStockListLineID)
   
   Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardProductListLineByIDForStores", strParams)
   ''On Error GoTo loadwarderr
   If Not rsWardStock.EOF Then
      rsWardStock.MoveFirst
      LSet drug = blankdrug
      If Trim$(GetField(rsWardStock!NSVCode)) = "" Then
         drug.drugttl = GetField(rsWardStock!Description)
         drug.catno = "&"
         drug.lastissuedate = ""
      Else
         DrugCode$ = Trim$(GetField(rsWardStock!NSVCode))
                     
         '05Aug16 KR Added.  Ensure the Stores value is initialised
         StoresValue 0, intStores
         findrdrug DrugCode$, intStores, tempdrug, blnFound&, False, False, False, False
         'findrdrug DrugCode$, False, tempdrug, blnFound&, False, False, False, False
         
         If blnFound <= 0 Then
            desc$ = "Could not find item " & DrugCode$ & " in drug file."
         ElseIf trimz$(GetField(rsWardStock!Description)) = "" Then
            'If trimz$(d.storesdescription) = "" Then
                'desc$ = tempdrug.Description
            'Else
                'desc$ = tempdrug.storesdescription
            'End If XN 4Jun15 98073 New local stores description
                        desc$ = tempdrug.DrugDescription
            plingparse desc$, "!"
         Else
            desc$ = GetField(rsWardStock!Description)
         End If
         
         drug.drugttl = Trim$(desc$)
         drug.stklevl = Trim$(GetField(rsWardStock!topuplvl))
         If GetField(rsWardStock!PackSize) = 0 Then
            drug.paksize = tempdrug.convfact
         Else
            drug.paksize = trimz$(GetField(rsWardStock!PackSize))
         End If
         If rsWardStock!PrintLabel = "~" Then
            drug.prepack = " "
         Else
            drug.prepack = Trim$(GetField(rsWardStock!PrintLabel))
         End If
         drug.catno = Trim$(DrugCode$)
         drug.lastissue = Trim$(GetField(rsWardStock!lastissue))
         drug.lastissuedate = Trim$(GetField(rsWardStock!lastissuedate))
         drug.localcode = "" 'Trim$(GetField(rsWardStock!localcode))
         'If Trim$(drug.localcode) = "" Then
         drug.localcode = drug.catno
         If rsWardStock!lastissuedate = Format(date, "dd/mm/yyyy") Then
            drug.dailyissue = Trim$(GetField(rsWardStock!dailyissue))   '29Jan99 TH
         Else
            drug.dailyissue = "0" 'Trim$(GetField(snap!lastissue))   '29Jan99 TH
         End If
      End If
      drug.posn = GetField(rsWardStock!ScreenPosn)
      'drug.barcode = GetField(rsWardStock!barcode)
      drug.LayoutID = GetField(rsWardStock!WWardProductListLineID) 'Added To give access to DB using the key
      'ward$ = GetField(rsWardStock!SiteName)  '01Sep14 TH Added (this is no longer derived externally to the ocx.
      'If Trim$(ward$) = "" Then ward$ = GetField(rsWardStock!ListCode)   '22Jan15 TH If the ward isnt available this could be an unassigned list so use the list code (TFS 102821)
      ward$ = GetField(rsWardStock!ListCode)  '06Feb15 TH Only use the specified code as cost centre will be looked up independently.
      
   End If
      
   rsWardStock.Close
   Set rsWardStock = Nothing
   
   
End Sub

