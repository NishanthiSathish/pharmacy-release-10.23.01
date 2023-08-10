Attribute VB_Name = "Supplier"
'------------------------------------------------------------------------------------------------
'                SUPPLIER Library
'
'18Apr97 CKJ Module Created
'            Brought together several strands from different modules
'            All supplier file handling now occurs in this module,
'            allowing changes to be made centrally.
'28May97 CKJ/KR Changed ward code to use supplier file, use with
'            AskSupplierWard to replace DisplayMacroFile on wardcode.dat
'            GetSupplierWard to replace SeqScan on wardcode.dat
'            Moved Editors from StkMaint
'29May97 CKJ Corrected filtration of ward type suppliers
'            Note change in params for AskSupplier
'29May97 EAC/CKJ GetSupplier: Cache recently used entries from index,
'            Add InUse param to ward based procs
'02Jun97 EAC CHOOSESUPPLIER: Miss out any blank supplier codes
'            AskSupplier:  Added warning if no valid supplier selected
'03Jun97 EAC CHOOSESUPPLIER: Use local variable for supplier file channel
'03Jun97 Kr  Added extra input parameter suppliertype to readfilnames
'            suppliertype = 0 - read both wards & ward lists
'                         = 1 - read wards only
'                         = 2 - read ward lists only
'27Jun97 CKJ AmendSuppliers: added "" to ConstructView
'29Jun97 EAC Use new SupDB in place of WSDB for some
'            tables in WSLIST.MDB
'30Jun97 EAC ReadFileNames: start reading supplier.v5 from 2nd byte
' 2Jul97 CKJ AskSupplier: Corrected my correction, when 'New' is selected,
'            added code 4, 'Other' as an option
'            Amendsuppliers: Replaced call to findsupplier with equivalent in-line code
'03Jul97 KR  SelectWards: Added  Set numofwards on exiting procedure
'11jul97 CKJ added Ethnic Origin editor
'18Jul97 CKJ Added CloseSupplierFile
' 5Aug97 CKJ Editors: Added ReadOnly view of all items except the direction codes
'            To use; call the specific view required as a minus number;
'            eg:   Editors 5       to edit consultant codes
'                  Editors -5      for read only view of consultant codes
'15Oct97 CKJ Editors: Corrected escape from sort by code/description
'15Dec97 CKJ/EAC GetSupplier: ucase of sup.suppliertype
'19Jan98 CKJ Editors: Link Cons to Specialty expansion now 50 chars to allow list
'21Jan98 CKJ SelectWards: Amended the text prompts to show maxnum
'            Editors: Added specialty options & corrected prompts when adding a new item
'26Jan98 EAC ReadWardNames: size array to be same size as all entries in supplier file
'08Feb98 CFY Extra code to handle ward type suppliers. Supplier code now copied to
'            field WardCode.
'11Feb97 CKJ added link from Ward to Specialty code
'23Feb98 EAC Supplier_Callback: Detect when suppliertype is changed to a "W" type supplier and set WardCode field to blank so that it will be updated uniquelly when exiting from AmendSuppliers
'25Feb98 EAC Supplier_callback: Added T order type for Transfer of stock, NB this mod required changes to STORES.INI
'05Mar98 CFY ChooseSupplier: Added new parameter to shellsort
'            Editors:                            "
'17Mar98 CKJ Supplier_Callback: Corrected blanking of ward code: It must not change the 29th Item,
'             it must change the item which has the tag = 29. This will vary with different views.
'18Mar98 CFY Supplier_Callback: Added code to delete entries from the wardcode array when the wardcode field is set to blank.
'18Mar98 CFY Removed section of code which adds a new wardcode to the array based list of
'            wardcodes as this task is done elsewhere.
'18Mar98 CFY DelWardArrayEntry: Re-wrote as code was 'unsafe'
'09Apr98 CFY Supplier_Callback: Extra code to fill the contactname fields inf the extrasupplierdata tablewith a space.
'            This prevents the database causing an error on addnew. This method was taken in preference to
'            changing the table definition.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'22May98 CFY/CKJ GetSupplierWard: Changed the condition which compares the code entered
'              by the user with the codes in the file. Was previously failing
'              and acception invalid codes.
'14Jul98 CKJ ASCFileName: selects file name from DSS & language variants
'            PushFile: sends file to specified location
'            Editors: uses ASCFileName
'            Editors: Replication is now offered after every edit, if the file is on the replication list
'            editorsDSSflag() written
'            Replicate written
'30Jul98 CKJ PushControl written. It sits as a filter mechanism between PushFile and the calling
'            routine. If the filename given has a special line in PushCtrl.ini then that method
'            is used instead of a simple copy. At the moment the directions files are the only
'            ones with special handling.
'13Aug98 EAC HK merges: DirectStruct type declaration moved here from STKMAINT.BAS
'29Sep98 CFY Editors: Replaced code which handles the printing. Previously output was spooled to LPT1. Now
'            output is generated in RTF format and uses context printing.
'05Oct98 CFY Editors: Added extra functionality so that we can now call the directions editor in View-Only mode.
'21Oct98 CFY/CKJ PushControl: Fixes to directions file update routine. New directions are now added to the
'                 destination file correctly. Directions that are already present in the destination
'                 file are now also updated and written back correctly.
'30Oct98 EAC AmendSuppliers: Don't commit new suppliers until accepted by user
'24Nov98 TH  AmendSuppliers: Ensure that TopUp date is saved to file in the right format
'27Nov98 TH  AmendSuppliers: Now optimistic locking so that supplier file is not locked out
'20Jan99 CFY WardInputWin: Moved routine from wslist.bas
'22Jan99 TH  Supplier_Callback: Added check on print picking tickets/del notes for ward Lists
'15Feb99 SF  asksupplierward: now also displays "L" supplier types and corrected tmp$ string used for additem
'04Mar99 CFY Added new fields to directions structure for prescribing/DSS.
'15Mar99 SF  added get4charwardcode: to allow list types to fit in pid.ward
'15Mar99 SF  added GetCostCentre: to ensure list have a cost centre attached when issuing
'17Mar99 CFY/SF AmendSuppliers: now restricts supplier code length to that setup in stores.ini
'17Mar99 SF  asksupplierward: removed 15Feb99 mod as it was wrong
'30Mar99 CFY get4charwardcode: Corrected logic which now allows the user to exit the loop
'09Aug99 SF  added ManualQtyEntry directstruct as a way of auto setting the manual qty entry flag
'06Sep99 CKJ Getsupplier,CloseSupplierFile:Added call to TrackOpenedfiles
'17Sep99 AE  EditDischarge:Written
'            EditDischargeLetter:Written
'            Editors:Added menu items for presenting complaints and diagnosis codes
'            EditRXLine: Written
'21Sep99 AE  Moved above procedures into separate module, Discharge.bas.  This avoids the need
'            to include the discharge editor forms (FrmBuildProfile, FrmBuildSelections, Treelist)
'            in the DSStools project, where they would be meaningless.
'10Sep99 CKJ UpdateSupplierIndexes,RebuildSupplierIndexes: written. Secondary index created & maintained
'            but not used in searches at this time.
'28Sep99 CKJ FillSupplierCache written
'            GetSupplierWard: Use new cache instead of brute force search
'30Sep99 CKJ Removed old cache which was filled opportunistically as suppliers were encountered
'            Instead read all suppliers once & hold in memory. Cache is invalidated & re-read if
'            reading from a different dispdata, if the supplier file date/time stamp changes, or
'            if the number of cache entries is set back to zero.
'11Oct99 CKJ Removed Findsupplier, replaced with GetSupplier
'12Oct99 CKJ FillSupplierCache: Corrected progress bar calculation
'16Nov99 CFY FillSupplierCache: Much Cludgadge around call to show progress bar form. Could previously cause an error
'            if a modal form happened to be on display at the time.
'03Dec99 AW Editors: changed ReDim menu$() & menuhlp() to cover new menu items added
'05Jan00 AW AskSupplier: changed to allow "<New>" to be at top of list.
'           AmendSupplier: Changed to check for "<New>" rather than "New".
'21Feb00 SF AskSupplier: Changed to allow "All" to be at top of list.
'03Apr00 TH Asksupplier: Added to allow shortname to be displayed instead of long name
'19Apr00 JP New field added to supplier structure to allow storage of an on-cost fee for a ward.
'20Apr00 CFY AmendSuppliers: OnCost field added
'09May00 TH Asksupplier: Added shortname flag to stop reading ini file in loop
'13Nov98 EAC Editors: HK mod to allow addition of items even though user has read-only access
'20Nov98 CFY Editors: Changed functionality of above mod
'28Jan99 CFY Editors: Changed functionality of above mod again to prevent editing if RestrictedView is on
'10May99 CFY PushControl: No longer ignores directions that have been deleted on the source site. Instead corresponding directions
'             on the destination site are marked as deleted.
'18Sep00 JN  RestrictedView(): Added stub function
'06Oct00 MMA/TH Asksupplier: Added to enable simultaneous viewing of shortname & longname
'16Nov00 SF Editors: added prescriber enhancements
'09Oct00 TH  AmendSupplier: Added parameter to differentiate store sup type
'09Oct00 TH  Supplier_Callback: Added parameter to allow differentiation of Store type suppliers
'09Oct00 TH  SetWardSpecifics: Added StoreEnabled% to handle store sites
'30Mar01 AE  Added Stat Dose flag to directStruct
'            Added InPatientDirections flag to supplierstruct
'            AmmendSupplier: Added code for Inpatient directions ("1 hit" dispensing)
'06Apr01 JN  AmendSupplier: Changed references to IIF to IFF in AE's changes of 30Mar01
'23Mar01 TH  AmendSupplier: Allow blanking of Ward TopUpDate field (#48578)
'21Jun01 TH  Supplier_Callback: fencepost wardcode deletion for wardtype selection (GPF experienced when using saveasnewward) (#53395)
'13jun01 CKJ Editors: Change Ethnic Origin caption for Language use
'26Jun01 CKJ EthnicOrgCaption: Moved from wident.bas
'31Oct01 TH  Added AdHocDelNote flag to supplierstruct (enh1302)
'31Oct01 TH  AmendSupplier: Added AddHoc Delivery Note Print field (enh1302)
'11Jan02 TH  Editors: Use cut down elements in array for Cons sort if file has > 2000 entries (specific for WA)
'15Jan02 TH  AmendSupplier: Added time for orderlog (#53214)
'13Mar02 TH  Editors: Large scale changes to allow for two arrays to be used when a file > 2000 entries.(#58364)
'21May02 SF  Editors: allows cancelling out correctly if adding a code (#60922)
'12sep02 TH  Editors: Use intFileLimit instead of hardcoded 2000 records, set to 150 for FFLabels (as this file gets larger quicker)(#63295)
'                     Ensure that on sort algorithms the correct file is accessed for the rebuild (not necessarily conscode.dat) (#)
'                     Mod to allow for new 'partitioned' file editing of inuse and not inuse (#63323)
'15Oct02 TH  Editors: Added Default file split level (2000 recs) - missed out somehow on last merge (#63295)
'05Sep02 SF  Editors: added pharmacist editors (enh#1274)
'28Jan04 TH  Supplier_Callback: Added check on in use to see if the supplier has outstanding reqs or to warn user to check for outstanding orders (#72056)
'13Mar04 TH  Supplier_Callback: Mod to above and bad date msg from topup date - Could be calling msgbox while do events still modally shown, so unload doevents first
'16Mar04 TH  Supplier_Callback: Removed mods (28Jan04,13Mar04) after discussion with CKJ - procedures called from here remain active in code, but
'                               now should never be called until (if) this mod is reinstated.
'30Mar04 CKJ {SP1}
'            Removed dead proc findsupplierX
'13May04 CKJ Supplier_Callback: Added non-mandatory message, and used it to prompt user when changing Inuse flag
'19May04 CKJ Editors: Heap based storage. Significant re-write, with extra supporting functions
'24may04 ckj Supplier_Callback: removed last mod. Instead use variable text next to the InUse box, taken from stores.ini [Info] 36= and 36YSE=
'27May04 CKJ AmendSuppliers, GetValues: close binarysearchidx
'07Jan10 CKJ SupplierCacheType, FillSupplierCache: Pointer if used should be long, but is never used and SP may have been patched to send 0, therefore remove from struct

'RCN P009

'19Mar09 TH  PutSupplier: Added sUpdateflag to heap for UHB (F0032689)
'19Mar09 TH  PutSupplier: Entry for supplier interface for UHB (F0032689)
'26Feb09 TH  SupplierOutput: Written for UHB SAGE Interface solution (F0032689)
'04Feb10 TH  FillSupplierCache: Replace write of pointer never used but some sites have 32000+ supplier records. (F0075540)
'16Apr10 XN  F0065193 Allow user to reorder list by clicking header
'26Apr10 XN  F0065193 Allow handling of non sortable items
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'05Aug10 XN  Replace WARD_CODE_LEN with GetWardCodeLen (F0051906)
'01Aug12 TH  Added Leadtime to supplierstruct for v8 compatibility (TFS47507)
'01Aug12 TH  Added PSO flag to supplierstruct (PSO)(TFS 40445)
'15Nov12 TH  Added PSO flag to supplier cache (TFS 49054)
'15Jul14 XN  Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506
'22Jan15 TH  GetSupplier: Added optional param to include lists if required. OCX needed this to load list
'                         and identify if was linked or not. (TFS 102821)
'01Feb16 TH  AskSupplier: Changed PSO param from boolean to enum. THis allows now tristate value, but retains existing "false" as "all"
'                         Now we can support "ALL","PSO","NONE PSO". existing default of false translates to "ALL" which is correct. (TFS 138644)
'16Aug16 XN  IfRequiresDeliveryNote: 160233 Gets if the ward stock list requires printing a delivery note
'            IfRequiresDeliveryNoteByWardCodeNSVCodeAndSite: 160233 Gets if the ward stock list requires printing a delivery note
'26Jan17 TH  SupplierOutput: Use new RTFExistsInDatabase function - Hosted (TFS 174442)
'17May17 KR  Bug 183869 : Unable to Print Delivery Notes [10.15.02]
'------------------------------------------------------------------------------------------------

DefInt A-Z
Option Explicit

'Const WARD_CODE_LEN = 5 ' 4     19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)

Type supplierstruct
   Code As String * 5
   contractaddress As String * 100
   supaddress As String * 100
   invaddress As String * 100
   conttelno As String * 14
   suptelno As String * 14
   invtelno As String * 14
   discountdesc As String * 70
   discountval As String * 9
   Method As String * 1
   ordmessage As String * 50
   avleadtime As String * 4
   contfaxno As String * 14
   supfaxno As String * 14
   '24Oct96 EAC - match mod made in DOS 12Mar96 by ASC
   'invfaxno As String * 14
   'icode as string * 2
   invfaxno As String * 13                                   '@~@~!!
''   pad1 As String * 3           '10Sep96 EAC was icode       '@~@~!!
   name As String * 15
   ptn As String * 1
   psis As String * 1
   fullname As String * 35     '21Mar93 CKJ Added
   discountbelow As String * 4 '  "
   discountabove As String * 4 '  "
   '27Aug96 EAC
   'pad As String * 95
   icode As String * 8                 '10Sep96 EAC
   costcentre As String * 15           'could be subjective and/or objective code for links
   PrintDeliveryNote As String * 1     'Yes or No
   PrintPickTicket As String * 1       'Yes or No
   suppliertype As String * 1          'e.g. ward, store, external supplier
   OrderOutput As String * 1           'e.g. paper,fax,edi,internal, X25, modem
   ReceiveGoods As String * 1          'Yes or No
   TopupInterval As String * 2         'Number in days
   ATCSupplied As String * 1           'Yes or No
''   pad2 As String * 4                  'WAS Cost code for ward
   topupdate As String * 8
   inuse As String * 1
   wardcode As String * 5              'Cost code for ward      '@~@~!! len 4 in translog
   onCost As String * 3                '19Apr00 JP On Cost as % charged to a ward.
   InPatientDirections As String * 1   '30Mar01 AE  "1" is on, anything else is false.
   'pad As String * 42                  '30Mar01 AE  43 - 1 for inpatient directions flag
   AdHocDelNote As String * 1          '31Oct01 TH Added new field to print delivery note on AdHoc Issue
''   pad As String * 41                  '31Oct01 TH 42 - 1 from above field
   SupplierID As Long                  '09May05 needed for SQL
   MinimumOrderValue As Double
   LeadTime As String * 2              '01Aug12 TH Added for v8 compatibility (TFS47507)
   PSO As Boolean                      '01Aug12 TH Added (PSO)(TFS 40445)
   UserField1 As String * 10            ' 15Jul14 XN Added new fields 88506
   UserField2 As String * 10            ' 15Jul14 XN Added new fields 88506
   UserField3 As String * 50            ' 15Jul14 XN Added new fields 88506
   UserField4 As String * 50            ' 15Jul14 XN Added new fields 88506
   NationalSupplierCode As String * 10  ' 15Jul14 XN Added new fields 88506
   DUNSReference As String * 13     ' 15Jul14 XN Added new fields 88506
   GlobalLocationNumber As String * 13  ' 15Jul14 XN Added new fields 88506
End Type

Type SupplierCacheType                           '28Sep99 CKJ Added
'   pointer As Integer                 07Jan10 CKJ Pointer if used should be long, but is never used and SP may have been patched to send 0, therefore remove from struct
   Code As String * 5
   Method As String * 1
   name As String * 15
   fullname As String * 35
   icode As String * 8
   costcentre As String * 15
   suppliertype As String * 1
   inuse As String * 1
   wardcode As String * 5
   supaddress As String * 100
   PSO As Boolean    '15Nov12 TH Added (TFS 49054)
End Type

Dim sup As supplierstruct
''Dim supidxchanged%
''Dim supchan%
''Dim supnotes$

Dim WardCodes() As String * 5 ' 4    19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906) '06Feb98 CFY Added
Dim WardCount%                   '

Const modulename = "SUPPLIER"

Dim msSupplierCacheDispdata As String            '28Sep99 CKJ Added
Dim m_lngSupplierCacheEntries As Long            '   "        Total entries in cache
Dim mvSupplierFileModified As Variant            '   "        Date/Time file modified
Dim mSupplierCache() As SupplierCacheType        '   "        Cache


'01Feb16 TH Added as tristate filter (TFS 138644)
Public Enum PSOSupplierFilter
   All
   PSO
   NonePSO
End Enum
'



'Sub findsupplierX (foundsup, supcode$, manualinput%, DisplayNotInuse%, sup As supplierstruct)
'----------------------Find the supplier from supfile-----------------------
'14Nov90 ASC return foundsup as the RA file number of the supplier
'            or 0 if not found and -1 if escaped
'            if manual input then the supplier is asked for
'21Mar93 CKJ Removed setinput
'xxMar97     In the move to windows, this has less meaning - maybe remove it?
'28Sep99 CKJ This procedure is obsolete and should not be used.
'            When called with the most common arguments it reduces to the following;
'            findsupplier foundsup, supcode$, False, False, sup
'               k.escd = False
'               supcode$ = UCase$(supcode$)
'               getsupplier supcode$, 0, foundsup, False, sup
'            End Sub
'

'mods needed
' Supplier file needs binary searching instead of disc based sequential - done
'-----------------------------------------------------------------------------

 '  foundsup = 0
 '  k.escd = False
 '
 '  If manualinput Then
 '        'If CSRLIN >= 24 Then
 '        '      LOCATE 24, 2
 '        '   Else
 '        '      pickwindow 1, 35, "", 0
 '        '      windowused = True
 '        '   End If
 '        'Print "  Enter supplier code   "; '29Mar93CKJ was site
 '        k.helpnum = 430
 '        supcode$ = ""
 '        asksupplier supcode$, 2, "", "Enter supplier code", DisplayNotInuse, sup '29Mar93CKJ
 '        'If windowused Then closewindow
 '     End If
 '
 '  If Not k.escd Then
 '        supcode$ = UCase$(supcode$)
 '        getsupplier supcode$, 0, foundsup, False, sup '@~@~
 '     Else
 '        foundsup = -1
 '        supcode$ = ""
 '     End If

'End Sub


Sub XAmendSuppliersSQL(ByVal asksuppliercode%, primersupcode$, escaped%)
'SQL Editor not required (!) for SQL Version
'------------------------------------------------------------------------------
'                           Amend supplier details
'Problems
' Code allows sup code to be changed but makes no attempt to keep .mdb fields in sync
'  in fact orphan fields can be created
' Deletion of code no longer seems possible
' Wards do not have to have an internal site number
' I can't see how asksuppliercode=false, primersupcode="????" would work
'  - it doesn't seem to be setting the right variables
'  - how is it used?
'------------------------------------------------------------------------------
''Dim foundsup%, newsup%, found%, failed%
''Dim supcode$, dat$
''Dim pointer&, supfound&
''Dim contname1$, contname2$, SQL$
'''Dim snap As snapshot, tempdyn As Dynaset
''Dim resumeval%, retries%, i%, txt$
''Dim ViewNumber%, SetReadOnly%, LastView%, ViewName$, NumOfEntries%
''Dim outdate$, valid%
''Dim msg$, ans$ '06Feb98 CFY Added
''Dim tempsup As supplierstruct             '30Oct98 EAC Added
''Dim supwas As supplierstruct, supnow As supplierstruct, search$ '27Nov98 TH
''Dim lines$(), numoflines%                          '17Mar99 CFY/SF added
''Dim RsExtraSupplierData As ADODB.Recordset
''
''Const procname$ = "AmendSuppliers"
''
''   ''FillWardCodeArray                              '06Feb98 CFY Added
''   FillWardCodeArraySQL
''
''   Select Case asksuppliercode                    ' 5Aug97 CKJ Added block
''      Case True, False                            'allow updates
''         SetReadOnly = False
''         ViewNumber = 1                           'single fixed view at this time
''      Case Else                                   'no updates
''         SetReadOnly = True
''         asksuppliercode = (primersupcode$ = "")  'ask only if no code supplied
''         ViewNumber = 100                         'single fixed view without command buttons
''      End Select
''
''   Do
''      k.escd = False
''      foundsup = 0
''      supcode$ = ""
''      If asksuppliercode Then
''            '2Jul97 CKJ Replaced with in-line code
''            'findsupplier foundsup%, supcode$, True, True, sup  ' manual input of sup code
''            asksupplier supcode$, Iff(SetReadOnly, 0, 2), "", "Enter supplier code", True, sup
''            If Not k.escd Then
''                  'If Trim$(supcode$) <> "NEW" Then getsupplier supcode$, 0, foundsup, False, sup      '30Oct98 Don't load supplier for new suppliers  '05Jan99 AW changed
''                  If Trim$(supcode$) <> "<NEW>" Then getsupplierSQL supcode$, 0, foundsup, False, sup                                                     '         "
''               Else
''                  Exit Do                                   '5Aug97 CKJ Exit from edit all
''               End If
''         Else
''            supcode$ = Trim$(UCase$(primersupcode$))
''         End If
''
''      newsup = False
''      'If Not k.escd And supcode$ = "NEW" Then      '05Jan99 AW changed
''      If Not k.escd And supcode$ = "<NEW>" Then     '         "
''            Do
''               setinput 0, k
''               supcode$ = ""
''               k.min = 1
''               'k.max = Len(sup.code)                                                  '17Mar99 CFY/SF replaced
''               ReDim lines$(10)                                                        '17Mar99 CFY/SF
''               supcode$ = Trim$(txtd$(dispdata$ & "\STORES.INI", "Data", "", "1", 0))  '17Mar99 CFY/SF
''               deflines supcode$, lines$(), ",", 1, numoflines%                        '17Mar99 CFY/SF
''               k.Max = Val(lines$(2))                                                  '17Mar99 CFY/SF
''               supcode$ = ""                                                           '17Mar99 CFY/SF
''               newsup = True
''               inputwin "New Supplier", "Enter new supplier code", supcode$, k
''               ' get pointer to new record in supplier file
''               If k.escd Then Exit Sub                                 '<== WAYOUT
''               supcode$ = UCase$(supcode$)
''
''               binarysearchidx supcode$, dispdata$ & "\supfile.idx", True, 0, supfound&
''               If supfound& > 0 Then
''                     popmessagecr "Amend Site Details", supcode$ & " has already been defined in the Site file."
''                     supidxchanged = False
''                  Else
''                     supidxchanged = True
''                  End If
''            Loop While Not supidxchanged
''
''            '30Oct98 EAC keep in memory until user confirmed they want to save it
''            'GetPointer dispdata$ & "\supfile.v5", pointer&, -1 ' increment
''            'If pointer& <= 1 Then
''            '      GetPointer dispdata$ & "\supfile.v5", 2, 2   ' write only
''            '      pointer& = 2
''            '   End If
''            'foundsup = pointer&
''            'getsupplier supcode$, foundsup, found, True, sup  '@~@~  '<LOCK
''            '---
''
''            clearsup sup                     '12Dec94 CKJ moved below getsupplier
''
''            '30Oct98 EAC
''            'Do      ' extend supplier index
''            '   Updateindex "", supcode$, (foundsup), dispdata$ & "\supfile.idx", failed%
''            '   If failed = -1 Then popmessagecr "Supplier Index Update Failed", "Supplier index may no longer be accurate - please reindex now."
''            'Loop While failed = 1         ' index locked
''            '---
''
''            sup.Code = supcode$
''            sup.Method = "D" '30Mar93CKJ
''            sup.psis = "N"
''            sup.ptn = "N"
''            sup.inuse = "Y"
''
''            'putsupplier foundsup, False, sup  '<------UNLOCK and write record 30Oct98 EAC Keep in memory until user confirmed they want to keep it
''         End If
''
''      If Not k.escd Then
''            If foundsup > 0 Then             'if supplier exists      '!!** THIS CANNOT BE RIGHT
''                  'getsupplier supcode$, foundsup, found, Not SetReadOnly, sup    '<------LOCK if not SetReadOnly
''                  getsupplierSQL supcode$, foundsup, found, False, sup    '27Nov98 TH  No Lock -Now optimistic locking
''                  supwas = sup                                         '27Nov98 TH  Copy Original sup for later comparison
''               End If
''
''            LastView = ViewNumber
''            ConstructView dispdata$ & "\stores.ini", "views", "data", ViewNumber, "", SetReadOnly, ViewName$, NumOfEntries  '27Jun97 CKJ Added ""
''            Ques.Caption = "Amend Supplier Details for " & Trim$(sup.Code)
''
''            'SQL$ = "SELECT * FROM ExtraSupplierData WHERE Supcode = '" & Trim$(sup.code) & "';"
''            'Set snap = SupDB.CreateSnapshot(SQL$) '29Jun97 EAC changed WSDB to SupDB
''            'If Not snap.EOF Then
''            '      contname1$ = Trim$(GetField(snap!ContactName1))
''            '      contname2$ = Trim$(GetField(snap!ContactName2))
''            '      supnotes$ = Trim$(GetField(snap!notes))
''            '   Else
''            '      contname1$ = ""
''            '      contname2$ = ""
''            '      supnotes$ = ""
''            '   End If
''            'snap.Close
''            'Set snap = Nothing
''            'SQL$ = "SELECT * FROM ExtraSupplierData WHERE Supcode = '" & Trim$(sup.code) & "';"
''            'Set snap = SupDB.CreateSnapshot(SQL$) '29Jun97 EAC changed WSDB to SupDB
''            'Set RsExtraSupplierData = SupDB.CreateSnapshot(SQL$)
''            'contname1$ = ""
''            'contname2$ = ""
''            'supnotes$ = ""
''            'Set objDataAccess = New clsDataAccess
''            Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
''
''            'If objDataAccess.GetRecordset(SQL$, RsExtraSupplierData) Then
''            If Not RsExtraSupplierData.EOF Then
''               contname1$ = Trim$(GetField(RsExtraSupplierData!ContactName1))
''               contname2$ = Trim$(GetField(RsExtraSupplierData!ContactName2))
''               supnotes$ = Trim$(GetField(RsExtraSupplierData!notes))
''            Else
''               contname1$ = ""
''               contname2$ = ""
''               supnotes$ = ""
''            End If
''            'End If
''            RsExtraSupplierData.Close
''            Set RsExtraSupplierData = Nothing
''
''
''            For i = 1 To NumOfEntries
''               Select Case Val(Ques.lblDesc(i).Tag)
''                  Case 1:  txt$ = sup.Code
''                  Case 2:  txt$ = sup.FullName
''                  Case 3:  txt$ = sup.contractaddress
''                  Case 4:  txt$ = sup.conttelno
''                  Case 5:  txt$ = sup.contfaxno
''                  Case 6:  txt$ = sup.supaddress
''                  Case 7:  txt$ = sup.suptelno
''                  Case 8:  txt$ = sup.supfaxno
''                  Case 9:  txt$ = sup.invaddress
''                  Case 10: txt$ = sup.invtelno
''                  Case 11: txt$ = sup.invfaxno
''                  Case 12: txt$ = sup.discountdesc
''                  Case 13: txt$ = sup.discountval
''                  Case 14: txt$ = QuesGetText(i)      'pragmatic - ie set caption=caption
''                  Case 15: txt$ = sup.ordmessage
''                  Case 16: txt$ = contname1$
''                  Case 17: txt$ = contname2$
''                  Case 18: txt$ = QuesGetText(i)      '    "
''                  '
''                  Case 20: txt$ = sup.name
''                  Case 21: txt$ = sup.icode
''                  Case 22: txt$ = sup.ptn
''                  Case 23: txt$ = sup.psis
''                  '
''                  Case 25: txt$ = Iff(UCase$(sup.Method) = "D", "P", UCase$(sup.Method))
''                  Case 26: txt$ = sup.costcentre
''                  Case 27: txt$ = sup.suppliertype
''                  '
''                  Case 29: txt$ = sup.wardcode
''                  Case 30: txt$ = sup.PrintPickTicket
''                  Case 31: txt$ = sup.PrintDeliveryNote
''                  Case 32: txt$ = sup.ReceiveGoods
''                  Case 33: txt$ = sup.TopupInterval
''                  Case 34
''                     txt$ = sup.topupdate
''                     If Trim$(txt$) <> "" Then
''                           parsedate txt$, outdate$, "dd-mmm-yyyy", valid
''                           If valid Then txt$ = outdate$
''                        End If
''                  Case 35: txt$ = sup.ATCSupplied
''                  Case 36: txt$ = UCase(sup.inuse)
''                  Case 37: txt$ = sup.onCost
''                  Case 38: txt$ = Iff(Val(sup.InPatientDirections) = 1, "Y", "N")         '30Mar01 AE Added    '06Apr01 JN Changed IIF to IFF
''                  Case 39: txt$ = Iff(sup.AdHocDelNote = "Y", "Y", "N")    '31Oct01 TH Added
''                  End Select
''               QuesSetText i, Trim$(txt$)
''            Next
''
''            If Not SetReadOnly Then
''                  Ques.F3D1.Tag = Str$(NumOfEntries)               'Not ideal but pragmatic
''                  Select Case Trim$(sup.suppliertype)              ' 4Aug97 CKJ Expanded
''                     Case "L":     SetWardSpecifics True, True, False    ' enable WardCode & ward details
''                     Case "W", "": SetWardSpecifics False, True, False   ' disable WardCode, enable ward details
''                     'Case Else:    SetWardSpecifics False, False   ' supplier/external                           '09Oct00 TH Removed
''                     Case "S":    SetWardSpecifics False, False, True  ' store                                   '09Oct00 TH added parameter
''                     Case Else:    SetWardSpecifics False, False, False ' supplier/external                      '09Oct00 TH added parameter
''                     End Select
''               End If
''            QuesMakeCtrl 0, 1000                 '12Aug97 CKJ Show print button
''
''            QuesCallbackMode = 11
''            QuesShow NumOfEntries                '<== Edit now
''            QuesCallbackMode = 0
''
''            'If k.escd Then
''            If Trim$(Ques.Tag) <> "-1" Or SetReadOnly Then       '!!** But is HAS been - contact1/2, contract & notes already saved
''                  If Not SetReadOnly Then popmessagecr "ESCAPED", "Site file not updated"
''                  k.escd = True
''               Else
''                  k.escd = False
''                  For i = 1 To NumOfEntries
''                     txt$ = QuesGetText(i)
''                     Select Case Val(Ques.lblDesc(i).Tag)
''                        Case 1:  sup.Code = txt$
''                        Case 2:  sup.FullName = txt$
''                        Case 3:  sup.contractaddress = txt$
''                        Case 4:  sup.conttelno = txt$
''                        Case 5:  sup.contfaxno = txt$
''                        Case 6:  sup.supaddress = txt$
''                        Case 7:  sup.suptelno = txt$
''                        Case 8:  sup.supfaxno = txt$
''                        Case 9:  sup.invaddress = txt$
''                        Case 10: sup.invtelno = txt$
''                        Case 11: sup.invfaxno = txt$
''                        Case 12: sup.discountdesc = txt$
''                        Case 13: sup.discountval = txt$
''                        'Case 14: "&Update"
''                        Case 15: sup.ordmessage = txt$
''                        Case 16: contname1$ = txt$
''                        Case 17: contname2$ = txt$
''                        'Case 18: "&Edit Notes"
''                        '
''                        Case 20: sup.name = txt$
''                        Case 21: sup.icode = txt$
''                        Case 22: sup.ptn = txt$
''                        Case 23: sup.psis = txt$
''                        '
''                        Case 25: sup.Method = Iff(txt$ = "P", "D", txt$)
''                        Case 26: sup.costcentre = txt$
''                        Case 27: sup.suppliertype = txt$
''                        '
''                        Case 29:
''                           sup.wardcode = txt$
''                           '06Feb98 CFY Added ----
''                           If sup.suppliertype = "W" Then
''                                 If Trim$(sup.wardcode) = "" Then
''                                       If Len(Trim$(sup.Code)) <= WARD_CODE_LEN Then
''                                             '23Feb98 EAC make sure that the 4 letter codes are unique otherwise ask for unique code
''                                             'sup.wardcode = sup.code
''                                             ans$ = sup.Code$
''                                             Do While Not UniqueCode(ans$)
''                                                k.min = 1
''                                                k.Max = 4
''                                                msg$ = "ward code already in use." & cr & cr
''                                                msg$ = msg$ & "Please re-enter."
''                                                inputwin "ASCribe", msg$, ans$, k
''                                             Loop
''                                             sup.wardcode = ans$
''                                             '---
''                                             'WardCount = WardCount + 1             18Feb98 CFY Removed as not necessary
''                                             'ReDim Preserve WardCodes(WardCount)                   "
''                                             'WardCodes(WardCount) = sup.wardcode                   "
''                                          Else
''                                             msg$ = "Supplier code too long to fit in Ward code." & cr & cr
''                                             msg$ = msg$ & "Please enter new Ward code (max " & Trim$(Str$(WARD_CODE_LEN)) & " chars)"
''                                             k.min = 1
''                                             k.Max = 4
''                                             inputwin "ASCribe", msg$, ans$, k
''                                             ans$ = UCase$(ans$)
''                                             Do While Not UniqueCode(ans$)
''                                                k.min = 1
''                                                k.Max = 4
''                                                msg$ = "ward code already in use." & cr & cr
''                                                msg$ = msg$ & "Please re-enter."
''                                                inputwin "ASCribe", msg$, ans$, k
''                                             Loop
''                                          sup.wardcode = ans$
''                                          End If
''                                       '23Feb98 EAC commented out block
''                                       'Else
''                                       '   ans$ = txt$
''                                       '   Do While Not UniqueCode(ans$)
''                                       '      k.min = 1
''                                       '      k.max = 4
''                                       '      msg$ = "ward code already in use." & CR & CR
''                                       '      msg$ = msg$ & "Please re-enter."
''                                       '      inputwin "ASCribe", msg$, ans$, k
''                                       '   Loop
''                                       '   sup.wardcode = ans$
''                                       End If
''                                 End If
''                           '------
''
''                        Case 30: sup.PrintPickTicket = txt$
''                        Case 31: sup.PrintDeliveryNote = txt$
''                        Case 32: sup.ReceiveGoods = txt$
''                        Case 33: sup.TopupInterval = txt$
''                        Case 34:
''                           If Trim$(txt$) <> "" Then '23Mar01 TH Allow blanking of date (#48578)
''                                 parsedate txt$, outdate$, "3", valid     '24Nov98 TH Ensure that date is saved to
''                                 If valid Then sup.topupdate = outdate$   '24Nov98 TH file in the right format
''                              Else                   '23Mar01 TH
''                                 sup.topupdate = ""  '   "
''                              End If                 '   "
''                        Case 35: sup.ATCSupplied = txt$
''                        Case 36: sup.inuse = txt$
''                        Case 37: sup.onCost = txt$                   '20Apr00 CFY Added
''                        Case 38: sup.InPatientDirections = Iff(UCase(txt$) = "Y", "1", "0")    '30Mar01 AE  Added.  flag is 1 or 0     '06Apr01 JN Changed IIF to IFF
''                        Case 39: sup.AdHocDelNote = Iff(UCase(txt$) = "Y", "Y", "N")    '31Oct01 TH  Added
''                        End Select
''                  Next
''                  Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
''                     If Not RsExtraSupplierData.EOF Then
''                        RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''                        RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''                        ''blnInsert
''                     Else
''                        RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''                        RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''                        ''tempdyn.Edit
''                        ''blnEdit
''                     End If
''                  'SQL$ = "SELECT Supcode,ContactName1,ContactName2 FROM ExtraSupplierData WHERE Supcode = '" & Trim$(sup.code) & "';"
''                  'Set tempdyn = SupDB.CreateDynaset(SQL$) '29Jun97 EAC changed WSDB to SupDB
''                  'tempdyn.LockEdits = False
''
''                  'If tempdyn.EOF Then
''                  '      tempdyn.AddNew
''                  '      tempdyn!supcode = Trim$(sup.code)
''                  '   Else
''                  '      tempdyn.Edit
''                  '   End If
''                  'tempdyn!ContactName1 = Trim$(contname1$)
''                  'tempdyn!ContactName2 = Trim$(contname2$)
''                  'On Error GoTo USUpdateTableErr
''                  'tempdyn.Update
''                  'On Error GoTo 0
''                  'tempdyn.Close
''                  'Set tempdyn = Nothing
''               End If
''
''            Unload Ques
''
''            ' This lump of code could be a lot tidier & more efficient !!
''            If foundsup <= 0 Then          ' new supplier code
''                  If Not k.escd Then
''                        If supcode$ = "" Then
''                              popmessagecr "WARNING", "Supplier code is blank - record not saved"
''                              k.escd = True
''                           Else
''                              '30Oct98 EAC
''                              'GetPointer dispdata$ & "\supfile.v5", pointer&, -1 ' increment
''                              'If pointer& <= 1 Then
''                              '      GetPointer dispdata$ & "\supfile.v5", 2, 2   ' write only
''                              '      pointer& = 2
''                              '   End If
''                              'foundsup = pointer&
''                              'getsupplier supcode$, foundsup, found, True, tempsup  '@~@~  '<LOCK
''                              putsupplier foundsup, k.escd, sup    'Need to send with 0 ID to add new                 '<------UNLOCK and write record if not k.escd
''
''                              Do      ' extend supplier index
''                                 Updateindex "", supcode$, (foundsup), dispdata$ & "\supfile.idx", failed%
''                                 If failed = -1 Then popmessagecr "Supplier Index Update Failed", "Supplier index may no longer be accurate - please reindex now."
''                              Loop While failed = 1         ' index locked
''
''                              'getsupplier supcode$, 0, found, False, sup  '@~@~  '<no lock
''                              'If found Then
''                              '      popmessagecr "WARNING", "Supplier code " + supcode$ + " already exists - record not saved"
''                              '      k.escd = True
''                              '   End If
''                              '---
''                           End If
''                     End If
''               Else                                   ' existing supplier
''                  If Not SetReadOnly Then
''                        If Trim$(supcode$) <> Trim$(sup.Code) Then
''                              If Not k.escd Then
''                                    If Trim$(sup.Code) = "" Then
''                                          popmessagecr "WARNING", "Supplier code is blank - record not saved"
''                                          k.escd = True
''                                       Else
''                                          getsupplier Trim$(sup.Code), 0, found, False, sup  '@~@~  '<no lock
''                                          If found Then
''                                                popmessagecr "WARNING", "Supplier code " + Trim$(sup.Code) + " already exists - record not saved"
''                                                k.escd = True
''                                             End If
''                                       End If
''                                 End If
''
''                              If Not k.escd Then            ' update index
''                                    supidxchanged = True
''                                    Do      ' amend supplier index
''                                       Updateindex supcode$, Trim$(sup.Code), (foundsup), dispdata$ & "\supfile.idx", failed%
''                                       If failed = -1 Then popmessagecr "!n!iSupplier Index Update Failed", "Supplier index may no longer be accurate - please reindex now."
''                                    Loop While failed = 1         ' index locked
''                                 End If
''                           End If
''
''                        'make checks (optimistic locking) here                                                  '27Nov98 TH Added
''
''                           getsupplier Trim$(sup.Code), 0, found, True, supnow                                  '27Nov98 TH Added
''                           search$ = Space$(Len(supnow))                                                        '27Nov98 TH Added
''                           LSet r = supnow                                                                      '27Nov98 TH Added
''                           LSet search$ = r.record                         ' copy whole structure to a string   '27Nov98 TH Added
''                           LSet r = supwas                                 ' copy original as well              '27Nov98 TH Added
''                           If search$ <> Left$(r.record, Len(supnow)) Then ' and compare                        '27Nov98 TH Added
''                                                                                                                '27Nov98 TH Added
''                                 putsupplier foundsup, k.escd, supnow                                           '27Nov98 TH Added
''                                 popmessagecr "Save Supplier", "Can't save Supplier changes - record has been changed since it was read"         '27Nov98 TH Added
''                                                                                                                '27Nov98 TH Added
''                              Else                                                                              '27Nov98 TH Added
''                                 putsupplier foundsup, k.escd, sup                                              '27Nov98 TH Added
''                              End If                                                                            '27Nov98 TH Added
''
''                        'putsupplier foundsup, k.escd, sup  '<------UNLOCK and write record if not k.escd       '27Nov98 TH Removed
''
''                        If newsup Then
''                              'dat$ = Mid$(Date$, 4, 2) + Left$(Date$, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
''                              dat$ = thedate(False, True) '03May98 CKJ Y2K
''                              dat$ = dat$ & thedate(0, -2)  '15Jan02 TH Added time for log (#53214)
''                              OrderLog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", sitenumber, "", "1" '14Jan94 CKJ No VAT here
''                           End If
''                     End If
''               End If
''         End If
''   Loop While asksuppliercode = True  '5Aug97 CKJ If editing all suppliers, loop until exit
''
''   ''''If Not SetReadOnly Then sortindex "Supplier Index", dispdata$ & "\supfile.idx"
''
''   escaped% = k.escd           'return whether or not process was aborted
''   primersupcode$ = supcode$   'return selected supplier code
''
''   m_lngSupplierCacheEntries = 0   '28Sep99 CKJ Added to force re-read of cache
''
''Exit Sub
''
'' '           For i = 1 To NumOfEntries                '!!** Incorporate logging?
'' '              tmp$ = QuesGetText(i)
'' '              Ptr = Val(Ques.lblDesc(i).Tag)
'' '              If tmp$ <> RTrim$(presentent$(Ptr)) Then
'' '                    info$ = pad$((Ques.lblDesc(i)), 25) & " " & "Was : '" & RTrim$(presentent$(Ptr)) & "' Now : '" & tmp$ & "'"
'' '                    Summary$ = Summary$ & info$ & cr
'' '                    SomeChange = True
'' '                    'log changes here
'' '                    writelog rootpath$ + "\labutils.log", site, userid$, d.siscode & " " & info$
'' '                 End If
'' '              presentent$(Ptr) = tmp$
'' '           Next
'' '           'If Len(Summary$) Then popmessagecr "", Summary$    'for debugging
'' '           Unload Ques
'' '           If FixedView Then ViewNumber = 0     'exit
''
''USUpdateTableErr:
''   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)    '!!**'@~@~
''   Select Case resumeval
''      Case -1: Resume
''      Case 0:  Resume Next
''      Case 1:  Close: End    'TerminateApp       '!!**
''      End Select
''
End Sub

Function ASCFileName(ByVal filename$, ByVal DSSfile%, ByVal Language$) As String
'14Jul98 CKJ Given the base filename, DSS/normal and the current language, return the
'            path and filename which is actually required
'            If the file has no special handling then it is returned unchanged, apart from
'            having the current dispdata added.
'            filename$ must be the name and extension without a \ and without the path
'            DSSfile = True/False where True returns the DSS file name
'            DSSfile = 1 automatically returns standard or DSS file name, based on ?????????
'            Language = ""    returns the file for the currently selected language
'            Language = "33"  returns the filename for a French system etc
'            Language = "STD" returns the filename for the primary language
'            eg fil$ = ASCFileName("Warning.V4", False, "")    'not DSS, current language
'             this may return   \dispdata.001\warning.v4   for the default language, English
'                          or   \dispdata.001\warn852.v4   if the current language is Chinese
'            In the options below the four choices are:
'            Option 1   Default language, site file
'                   2   Default language, DSS file
'                   3   Secondary language, site file
'                   4   Secondary language, DSS file
'20Jul98 EAC Added dispensary label options
'09May05 CKJ Moved warning/direction/instruction handling out of here

Dim lang$, deflang$, FILE$, opt%

   deflang$ = ReadLanguage(10, 1)                              'Default language, normally '044'
   lang$ = Right$("000" & UCase$(Language$), 3)                'Specified language, pad 33 to 033
   If lang$ = "STD" Then lang$ = deflang$                      'Specified language, pad 33 to 033
   If lang$ = "000" Then lang$ = ReadLanguage(10, 0)           'Current language '044', '852' etc
   If DSSfile = 1 Then DSSfile = editorsDSSflag(1)             'Read current DSS setting
   opt = Iff(lang$ = deflang$, 1, 3)                           'Option 1 or 3
   If DSSfile Then opt = opt + 1                               'Add 1 if DSS required

   Select Case LCase$(filename$)
      Case "warning.v4", "instruct.v4", "direct.v6", "dirv6.idx"
         popmessagecr ".Unsupported Option", "Procedure ASCFileName called for type " & filename$
''      Case "warning.v4"
''         FILE$ = Choose(opt, "warning.v4", "warning.dss", "warn###.v4", "warn###.dss")
''      Case "instruct.v4"
''         FILE$ = Choose(opt, "instruct.v4", "instruct.dss", "inst###.v4", "inst###.dss")
''      Case "direct.v6"
''         FILE$ = Choose(opt, "Direct.V6", "Direct.V6", "Dir###.V6", "Dir###.V6")         'NOT DSS
''      Case "dirv6.idx"
''         FILE$ = Choose(opt, "DirV6.idx", "DirV6.idx", "Dir###.idx", "Dir###.idx")       'NOT DSS
      Case "patmed.ini"
         FILE$ = Choose(opt, "Patmed.ini", "Patmed.ini", "Patmd###.ini", "Patmd###.ini") 'NOT DSS
      Case "route.ini"
         FILE$ = Choose(opt, "Route.ini", "Route.ini", "Route###.ini", "Route###.ini")   'DSS ONLY
      Case "displbl"    '20Jul98 EAC Added
         FILE$ = Choose(opt, "displbl", "displbl", "dlbl###", "dlbl###")   'DSS ONLY
      Case Else:
         FILE$ = filename$
      End Select
   
   replace FILE$, "###", lang$, 0
   ASCFileName = dispdata$ & "\" & FILE$

End Function

Function ASCContextName(ByVal filename$, ByVal DSSfile%, ByVal Language$) As String
'14Jul98 CKJ Given the base filename, DSS/normal and the current language, return the
'            path and filename which is actually required
'            If the file has no special handling then it is returned unchanged, apart from
'            having the current dispdata added.
'            filename$ must be the name and extension without a \ and without the path
'            DSSfile = True/False where True returns the DSS file name
'            DSSfile = 1 automatically returns standard or DSS file name, based on ?????????
'            Language = ""    returns the file for the currently selected language
'            Language = "33"  returns the filename for a French system etc
'            Language = "STD" returns the filename for the primary language
'            eg fil$ = ASCFileName("Warning.V4", False, "")    'not DSS, current language
'             this may return   \dispdata.001\warning.v4   for the default language, English
'                          or   \dispdata.001\warn852.v4   if the current language is Chinese
'            In the options below the four choices are:
'            Option 1   Default language, site file
'                   2   Default language, DSS file
'                   3   Secondary language, site file
'                   4   Secondary language, DSS file
'20Jul98 EAC Added dispensary label options
'09May05 CKJ Converted from handling filenames to using WLookup and WLookupContext tables

Dim lang$, deflang$, Context As String, opt%

   deflang$ = ReadLanguage(10, 1)                              'Default language, normally '044'
   lang$ = Right$("000" & UCase$(Language$), 3)                'Specified language, pad 33 to 033
   If lang$ = "STD" Then lang$ = deflang$                      'Specified language, pad 33 to 033
   If lang$ = "000" Then lang$ = ReadLanguage(10, 0)           'Current language '044', '852' etc
   If DSSfile = 1 Then DSSfile = editorsDSSflag(1)             'Read current DSS setting
   'opt = Iff(lang$ = deflang$, 1, 3)                          'Option 1 or 3
   opt = 1
   If DSSfile Then opt = 2                                     'if DSS required

   Select Case LCase$(filename$)
      Case "warning.v4":  Context = Choose(opt, "warning.###", "warning.###.dss")
      Case "instruct.v4": Context = Choose(opt, "instruction.###", "instruction.###.dss")
''      Case "direct.v6":   context = Choose(opt, "Direct.V6", "Dir###.V6")                    'NOT DSS
''      Case "patmed.ini":  context = Choose(opt, "Patmed.ini", "Patmd###.ini")                'NOT DSS
''      Case "route.ini":   context = Choose(opt, "Route.ini", "Route###.ini")                 'DSS ONLY
''      Case "displbl":     context = Choose(opt, "displbl", "dlbl###")                        'DSS ONLY
      Case Else:          Context = filename$
      End Select
   
   replace Context, "###", lang$, 0
   ASCContextName = Context

End Function

Sub asksupplier(supcode$, Code%, Filter$, Caption$, DisplayNotInuse%, sup As supplierstruct, ByVal enumPSOSupplierFilter As PSOSupplierFilter)
'28Aug96 EAC added displaywards%
'            added code% to subroutine header
'            code = 0 - don't add any text to list of suppliers
'            code = 1 - add 'All'   to start of list of suppliers
'            code = 2 - add 'New'   to start of list of suppliers
'            code = 3 - add 'None'  to start of list of suppliers
'            code = 4 - add 'Other' to start of list of suppliers
'03Sep96 EAC change displaywards% to Display%
'            code = 0 - display all suppliers
'            code = 1 - display suppliers only
'            code = 2 - display wards only
'29May97 CKJ Changed Display% to Filter$
'            If Filter$ = ""    then all are offered
'                         "W"   then only type W is shown
'                         "WL"  then only types W and L are shown, etc
'            Filter can be set to any of "LWSE" at this time
'            NB: Escape from the list box is now shown by both k.escd=true and supcode$=""
'26Apr10 XN  F0065193 Allow handling of non sortable items
'01Feb16 TH  Changed PSO param from boolean to enum. THis allows now tristate value, but retains existing "false" as "all"
'            Now we can support "ALL","PSO","NONE PSO". existing default of false translates to "ALL" which is correct. (TFS 138644)


Dim AddSupp%, LineSelected%, posn%
Dim tmp$
Dim iCount As Integer
Dim sSupline As String
Dim shortname%
Dim sName As String
Dim strSupplierProfiles As String '07Oct06 TH Added
Dim topItemIsNotSortable As Boolean '26Apr10 XN  F0065193 Allow handling of non sortable items
Dim blnPSOFilter As Boolean '01Feb16 TH Added
Dim blnExcludeHub As Boolean '25Feb16 TH Added

   sName$ = TxtD(dispdata$ & "\winord.ini", "defaults", "N", "SupplierShortName", 0)
   If InStr(Filter$, "_NO_HUB") > 0 Then
      Filter$ = Left$(Filter$, Len(Filter$) - 7)
      blnExcludeHub = True
   Else
      blnExcludeHub = False
   End If
     
   Select Case UCase$(sName$)
      Case "B":                            shortname% = 2  'display both names
      Case "Y", "T", "1", "-1", getYN$(1): shortname% = -1 'display shortname only
      Case Else:                           shortname% = 0  'display longname only
   End Select

   EnhLstFrm.LstBox.Clear
   
   EnhLstFrm.Caption = Caption$
   EnhLstFrm.lblTitle.Caption = ""
   EnhLstFrm.lblHead.Caption = "Code    " & TB & "Cost centre" & TB & "Full Name"
   If shortname = -1 Then
      EnhLstFrm.lblHead.Caption = "Code    " & TB & "Cost centre" & TB & "Short Name"
   ElseIf shortname = 2 Then
      EnhLstFrm.lblHead.Caption = "Code    " & TB & "Cost centre" & TB & "Short Name               " & TB & "Long Name" & Space(60)
   End If
   
   EnhLstFrm.TxtInput.MaxLength = 5 '16May05 TH Added (#80182)
   
   topItemIsNotSortable = False             '26Apr10 XN  F0065193 Allow handling of non sortable items
   Select Case Code
      Case 1: EnhLstFrm.LstBox.AddItem "<All>"
              topItemIsNotSortable = True   '26Apr10 XN  F0065193 Allow handling of non sortable items
      Case 2: EnhLstFrm.LstBox.AddItem "<New>"
              topItemIsNotSortable = True   '26Apr10 XN  F0065193 Allow handling of non sortable items
      Case 3: EnhLstFrm.LstBox.AddItem "None"
              topItemIsNotSortable = True   '26Apr10 XN  F0065193 Allow handling of non sortable items
      Case 4: EnhLstFrm.LstBox.AddItem "Other"
              topItemIsNotSortable = True   '26Apr10 XN  F0065193 Allow handling of non sortable items
   End Select
   Screen.MousePointer = HOURGLASS
   FillSupplierCache
   '07Oct06 TH If the filter is to return profiled sups only then we will do just that based on the current d structure
   If Filter$ = "PROFILES" Then
      strSupplierProfiles = "," & Trim$(d.supcode) & "," & GetAltenativeSupplierString(d.SisCode) & ","
   End If
   
   For iCount = 1 To m_lngSupplierCacheEntries
      AddSupp = False
      '01Feb16 TH Replaced filtering to allow nonePSO suppliers only to be shown as well (TFS)
      blnPSOFilter = True
      Select Case enumPSOSupplierFilter
         Case PSO: If mSupplierCache(iCount).PSO = False Then blnPSOFilter = False
         Case NonePSO: If mSupplierCache(iCount).PSO = True Then blnPSOFilter = False
      End Select
      'If Not (blnPSO And (mSupplierCache(iCount).PSO = False)) Then
      If blnPSOFilter Then
      If Len(Trim$(mSupplierCache(iCount).Code)) > 0 Then
         If Trim$(Filter$) = "" Then   'Filter is blank - show all
            AddSupp = True
         ElseIf Filter$ = "PROFILES" Then '07Oct06 TH Added
            If Trim$(mSupplierCache(iCount).Code) <> "" Then    'Suppliertype is not blank
               If InStr(Trim$(UCase$(strSupplierProfiles)), "," & Trim$(UCase$(mSupplierCache(iCount).Code)) & ",") Then
                  AddSupp = True
               End If
            End If
         Else                       'Filter is not blank
            If Trim$(mSupplierCache(iCount).suppliertype) <> "" Then    'Suppliertype is not blank
               If InStr(Trim$(UCase$(Filter$)), UCase$(mSupplierCache(iCount).suppliertype)) Then
                  AddSupp = True
               End If
            End If
         End If
         If Not (DisplayNotInuse) And UCase$(mSupplierCache(iCount).inuse) = "N" Then AddSupp = False
         If blnExcludeHub Then If mSupplierCache(iCount).Method = "H" Then AddSupp = False
         If AddSupp Then
            tmp$ = Trim$(mSupplierCache(iCount).wardcode)
            If tmp$ = Trim$(mSupplierCache(iCount).Code) Then tmp$ = ""
            If tmp$ <> "" Then tmp$ = "(" & tmp$ & ")"
            tmp$ = mSupplierCache(iCount).Code & TB & tmp$ & TB
            
            Select Case shortname
               Case -1
                  sSupline = Trim$(mSupplierCache(iCount).name)
               Case 0
                  sSupline = Trim$(mSupplierCache(iCount).fullname)
               Case 2
                  sSupline = Trim$(mSupplierCache(iCount).name) & TB & Trim$(mSupplierCache(iCount).fullname)
            End Select

            If sSupline <> "" And Right$(sSupline, 1) <> "," And Trim$(mSupplierCache(iCount).supaddress) <> "" Then
               sSupline = sSupline & ","
            End If
            sSupline = Trim$(sSupline & mSupplierCache(iCount).supaddress)
            If sSupline = "" Then sSupline = mSupplierCache(iCount).name
            
            ''EnhLstFrm.LstBox.AddItem tmp$ & Left$(sSupline, 50)
            If Val(terminal$("SupplierLstBoxWidth", "50")) < Len(sSupline) Then
               EnhLstFrm.LstBox.AddItem tmp$ & Left$(sSupline, Val(terminal$("SupplierLstBoxWidth", "50")))
            Else
               EnhLstFrm.LstBox.AddItem tmp$ & Left$(sSupline, 50)
            End If
         End If
      End If
      End If '15Nov12 TH Added PSO Filter
   Next

   If Filter = "W" Then EnhLstFrm.LblInput = "Enter Ward Code"

   Screen.MousePointer = STDCURSOR
   
   EnhLstFrm.AllowSortableHeaders , topItemIsNotSortable  '16Apr10 XN  F0065193 Allow user to reorder list by clicking header

   EnhLstBoxShow
   
   LineSelected = EnhLstFrm.LstBox.ListIndex + 1
   k.escd = False
   If EnhLstFrm.LstBox.Tag = "" Then
      k.escd = True
   Else
      If LineSelected = 0 Then
         k.escd = True
         If Filter = "W" Then
            popmessagecr Caption$, "No valid ward selected."
         Else
            popmessagecr Caption$, "No valid supplier selected."
         End If
      End If
   End If
   
   supcode$ = ""
   If Not k.escd Then
      supcode$ = Trim$(UCase$(EnhLstFrm.LstBox.text))
      posn = InStr(supcode$, TB)
      If posn Then
         supcode$ = Trim$(Left$(supcode$, posn - 1))
         getsupplier supcode$, 0, 0, sup
      Else
         Select Case supcode$
            Case "<ALL>": supcode$ = "A"
            Case "<NEW>", "NONE", "OTHER"
            Case Else:  k.escd = True
         End Select
      End If
   End If

   Unload EnhLstFrm

End Sub

Sub AskSupplierWard(Code$, desc$, inuse%)

Dim sup As supplierstruct
Dim tmp$
Dim LineSelected%, posn%
Dim iCount As Integer, sSupline As String

   Code$ = ""
   desc$ = ""
   inuse = False
   
   EnhLstFrm.LstBox.Clear

   EnhLstFrm.Caption = "Enter Ward Code"
   EnhLstFrm.lblTitle.Caption = ""
   EnhLstFrm.lblHead.Caption = "Code    " & TB & pad$("Name", 18) & TB & "Address"
                          
   Screen.MousePointer = HOURGLASS
   FillSupplierCache
   For iCount = 1 To m_lngSupplierCacheEntries
      If Len(Trim$(mSupplierCache(iCount).Code)) > 0 Then              'Supplier.code present
         If Trim$(mSupplierCache(iCount).suppliertype) = "W" Then   'Suppliertype is Ward only
            If UCase$(mSupplierCache(iCount).inuse) <> "N" Then  'and is in use
               tmp$ = Trim$(mSupplierCache(iCount).wardcode) & TB & Trim$(mSupplierCache(iCount).name) & TB
               sSupline = Trim$(mSupplierCache(iCount).fullname)
               If sSupline <> "" And Right$(sSupline, 1) <> "," And Trim$(mSupplierCache(iCount).supaddress) <> "" Then
                  sSupline = sSupline & ","
               End If
               sSupline = sSupline & mSupplierCache(iCount).supaddress
               EnhLstFrm.LstBox.AddItem tmp$ & Left$(sSupline, 50)
            End If
         End If
      End If
   Next
   
   EnhLstFrm.AllowSortableHeaders '16Apr10 XN  F0065193 Allow user to reorder list by clicking header
   
   EnhLstBoxShow
   
   LineSelected = EnhLstFrm.LstBox.ListIndex + 1
   k.escd = False
   If EnhLstFrm.LstBox.Tag = "" Then
      k.escd = True
   Else
      If LineSelected = 0 Then
         k.escd = True
         popmessagecr "Enter Ward Code", "No valid ward selected."
      End If
   End If
   
   Code$ = ""
   If Not k.escd Then
      Code$ = Trim$(UCase$(EnhLstFrm.LstBox.text))
      posn = InStr(Code$, TB)                        'no tab for special lines 'All' etc
      If posn Then
         Code$ = Trim$(Left$(Code$, posn - 1))
         getsupplier Code$, 0, 0, sup
      Else
         k.escd = True
      End If
   End If

   Unload EnhLstFrm
   If Code$ <> "" Then
      desc$ = Trim$(sup.fullname)
      inuse = (UCase$(sup.inuse) <> "N")
   End If

End Sub

Sub ChooseSupplier(ByRef strCode As String, ByRef strDesc As String)


Dim sups%, X%, posn%
Dim iCount As Integer
'Dim strSupplierProfiles As String   '09Oct06 TH Added
'Dim blnAddSupp As Boolean           '    "

   FillSupplierCache
   ReDim lines$(m_lngSupplierCacheEntries)
   sups = 0
   
   '12Oct06 TH Removed - not required in current functionality
   ''08Oct06 TH If the filter is to return profiled sups only then we will do just that based on the current d structure
   'If strCode = "PROFILES" Then
   '   strSupplierProfiles = "," & Trim$(d.supcode) & "," & GetAltenativeSupplierString(d.SisCode) & ","
   'End If
   
   For iCount = 1 To m_lngSupplierCacheEntries
      Select Case mSupplierCache(iCount).suppliertype
         Case "W", "L" 'no action                        'exclude wards & lists
         Case Else                                       'include supplier and external
            If Len(Trim$(mSupplierCache(iCount).Code)) Then
               '12Oct06 TH Removed - not required in current functionality
               ''07Oct06 TH Added Section
               'blnAddSupp = True
               'If strCode = "PROFILES" Then
               '   If InStr(Trim$(UCase$(strSupplierProfiles)), "," & Trim$(UCase$(mSupplierCache(iCount).Code)) & ",") Then
               '      blnAddSupp = True
               '   Else
               '      blnAddSupp = False
               '   End If
               'End If
               '-----------
               'If blnAddSupp Then '07Oct06 TH Added Check
                  sups = sups + 1
                  lines$(sups) = Trim$(mSupplierCache(iCount).Code) & TB & Trim$(mSupplierCache(iCount).name)
               'End If
            End If
      End Select
   Next

   shellsort lines$(), sups, 0, ""

   For X = 1 To sups
      LstBoxFrm.LstBox.AddItem "  " & lines$(X)
   Next
   
   LstBoxFrm.lblTitle = cr & "Choose a Supplier Code" & cr
   LstBoxFrm.lblHead = "  Code  " & TB & "Supplier          "
   LstBoxShow
   If LstBoxFrm.LstBox.ListIndex > -1 Then
      posn = InStr(LstBoxFrm.Tag, TB)
      strCode = Trim$(Left$(LstBoxFrm.Tag, posn - 1))
      strDesc = Mid$(LstBoxFrm.Tag, posn + 1)
   Else
      strCode = ""
      strDesc = "Shift-F1 for list"
   End If
   Unload LstBoxFrm

End Sub

Sub clearsup(sup As supplierstruct)
'---------------------Clears a supplier record--------------------------------
'
   r.record = ""
   LSet sup = r
   sup.SupplierID = 0
   sup.MinimumOrderValue = 0 '17Aug06 TH Added

End Sub



Sub DelWardArrayEntry(Entry$)

Dim i%

  For i = 1 To WardCount
   If Trim$(UCase$(Entry$)) = WardCodes(i) Then
      WardCodes(i) = ""
      Exit For
   End If
  Next
   

End Sub



Function editorsDSSflag(State%) As Integer
'SQL Editor functions removed from this version of software
'''14Jul98 CKJ This function allows SkMaint to switch to editing DSS files (in the editors proc)
'''            and defaults to editDSS = False, without the need for a stub proc in other programs.
''
Static editDSS%

   If State = 1 Then                            'read current state
         editorsDSSflag = editDSS
      Else
         editDSS = (State <> 0)                 'set state
      End If

End Function








Function EthnicOrgCaption() As String

   If UCase$(TxtD(dispdata$ & "\ascribe.ini", "PID", "", "SetLanguage", 0)) = "PID.ETHNICORIGIN" Then
      EthnicOrgCaption = "Language"
   Else
      EthnicOrgCaption = "Ethnic Origin"
   End If

End Function

Sub FillSupplierCache()
'04Feb10 TH Replace write of pointer never used but some sites have 32000+ supplier records. (F0075540)
'15Nov12 TH Added PSO Flag (TFS 49054)
 
Dim iCount As Integer
''Dim lNumofsups As Long
''Dim Supplier As supplierstruct
''Dim nTimer As Single
''Dim iShown As Integer
''Dim iIncrement As Integer
Dim iCursorOnStart As Integer
Dim rsSuppliers    As ADODB.Recordset
Dim strParams As String
            
   On Error GoTo ErrorHandler
   iCursorOnStart = Screen.MousePointer
   Screen.MousePointer = HOURGLASS
   
   'If dispdata$ <> msSupplierCacheDispdata Then m_lngSupplierCacheEntries = 0
   'If m_lngSupplierCacheEntries Then                                                           'has entries
   '      If VarType(mvSupplierFileModified) = 7 Then                                        'date type
   '            If mvSupplierFileModified <> FileDateTime(dispdata$ & "\supfile.v5") Then    'changed
   '                  m_lngSupplierCacheEntries = 0                                             'so rebuild
   '               End If
   '         End If
   '   End If

   If m_lngSupplierCacheEntries = 0 Then   'Fill cache will all supplier entries
      'mvSupplierFileModified = FileDateTime(dispdata$ & "\supfile.v5")
      'msSupplierCacheDispdata = dispdata$
      'ConnectionString
''      Set oDataAccess = New clsDataAccess
      
''      If oDataAccess.GetRecordset("exec pSupplierSelectAll ", rsSuppliers) Then
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      Set rsSuppliers = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierSelectBySupplierType", strParams)
      m_lngSupplierCacheEntries = rsSuppliers.RecordCount
      If m_lngSupplierCacheEntries = -1 Then m_lngSupplierCacheEntries = 100                 '**!!** cludge
      ReDim mSupplierCache(m_lngSupplierCacheEntries) As SupplierCacheType
''      rsSuppliers.MoveFirst    Nope, bad move if BOF & EOF are true (empty table)
      
      iCount = 0
      Do While Not rsSuppliers.EOF
         With rsSuppliers
            iCount = iCount + 1
            If iCount > m_lngSupplierCacheEntries Then
               m_lngSupplierCacheEntries = m_lngSupplierCacheEntries + 1
               ReDim Preserve mSupplierCache(m_lngSupplierCacheEntries) As SupplierCacheType    '**!!** slow - needs changing
            End If
            'mSupplierCache(iCount).pointer = .Fields("WSupplierID")
                'mSupplierCache(iCount).pointer = 0 '04Feb10 TH Replace above pointer never used but some sites have 32000+ supplier records.
                                               '           CKJ must have missed this previously - probably branching isue (F0075540)
            mSupplierCache(iCount).Code = .Fields("Code")
            mSupplierCache(iCount).Method = .Fields("Method")
            mSupplierCache(iCount).name = .Fields("Name")
            mSupplierCache(iCount).fullname = .Fields("FullName")
            mSupplierCache(iCount).icode = .Fields("iCode")                '23sep04 CKJ was "Code"
            mSupplierCache(iCount).costcentre = .Fields("CostCentre")
            mSupplierCache(iCount).suppliertype = .Fields("SupplierType")
            'mSupplierCache(iCount).inuse = .Fields("InUse")
            If .Fields("InUse") Then
               mSupplierCache(iCount).inuse = "Y"
            Else
               mSupplierCache(iCount).inuse = "N"
            End If
            mSupplierCache(iCount).wardcode = .Fields("WardCode")
            mSupplierCache(iCount).supaddress = .Fields("SupAddress")
            mSupplierCache(iCount).PSO = .Fields("PSO")   '15Nov12 TH Added for PSO (TFS 49054)
            rsSuppliers.MoveNext
         End With
      Loop
   End If
   
Cleanup:
   On Error Resume Next
   Set rsSuppliers = Nothing
   Screen.MousePointer = iCursorOnStart
   On Error GoTo 0
   
Exit Sub
   
ErrorHandler:
   Stop  '!!**
Resume Cleanup

End Sub

'Sub FillWardCodeArray()
'
'Dim loopvar%, numofsups&
'Dim rsSupplierWardcode As ADODB.Recordset
'
'   If WardCount = 0 Then
'Stop
'
'''         GetPointer dispdata$ & "\supfile.v5", numofsups&, False
'''         For loopvar = 2 To numofsups&
'''            getsupplier "", loopvar, 0, sup
'''            If sup.suppliertype = "W" Then
'''                  WardCount = WardCount + 1
'''                  ReDim Preserve WardCodes(WardCount)
'''                  WardCodes(WardCount) = Trim$(UCase$(sup.wardcode))
'''               End If
'''         Next
'         rsSupplierWardcode = gTransport.ExecuteSelect(g_SessionID, "pWSupplierForWardCodesbyWard", "")
'         If Not rsSupplierWardcode.EOF Then
'         Do While Not rsSupplierWardcode.EOF
'            WardCount = WardCount + 1
'            ReDim Preserve WardCodes(WardCount)
'            WardCodes(WardCount) = Trim$(UCase$(RtrimGetField(rsSupplierWardcode.wardcode)))
'            rsSupplierWardcode.MoveNext
'         Loop
'
'      End If
'
'End Sub

Sub FillWardCodeArraySQL(ByVal rebuild As Boolean)

Dim rsSuppliers As ADODB.Recordset
Dim strParameters As String

    If rebuild Then
        WardCount = 0
    End If


   If WardCount = 0 Then
      strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("SupplierType", trnDataTypeVarChar, 1, "W")
      Set rsSuppliers = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierSelectBySupplierType", strParameters)
      Do While Not rsSuppliers.EOF
         WardCount = WardCount + 1
         ReDim Preserve WardCodes(WardCount)    '!!** Not efficient - should change
         WardCodes(WardCount) = Trim$(UCase$(GetField(rsSuppliers!wardcode)))
         rsSuppliers.MoveNext
      Loop
      Set rsSuppliers = Nothing
   End If

End Sub
Sub setSupplierCacheEntries(ByVal intSupplierCacheEntries As Integer)
m_lngSupplierCacheEntries = intSupplierCacheEntries
End Sub
Sub get5charwardcode(ward$, desc$)      ' 19May10 XN changed name of of function as wardcodes are now 5 characters

Dim sup As supplierstruct
Dim typeList$, found As Long

   desc$ = "<Invalid Code>"
   typeList$ = UCase$(TxtD(dispdata$ & "\ASCRIBE.INI", "PID", "W", "WardsDisplayed", 0))
   If Trim$(ward$) = "" Then
      Do
         asksupplier ward$, 0, typeList$, "Select a Ward", False, sup, False '15Nov12 TH Added PSO param
      Loop While Trim$(ward$) = "" And (Not k.escd)
   End If
   
   If Not k.escd Then
      clearsup sup
      getsupplier ward$, 0, found, sup
      desc$ = Trim$(sup.fullname)
      If sup.suppliertype = "L" Then
            ward$ = Trim$(sup.Code)
         Else
            ward$ = Trim$(sup.wardcode)
         End If
   Else
      ward$ = ""
   End If

End Sub

Sub GetCostCentre(ward$, costcentre$)
'15Mar99 SF added to check that the ward is in supplier file and that if a list type
'           then it has a cost centre attached.

Dim sup As supplierstruct
Dim typeList$, Code$, found As Long

      clearsup sup
      getsupplier ward$, 0, found, sup
      
      If found = 0 Then
            typeList$ = UCase$(TxtD(dispdata$ & "\ASCRIBE.INI", "PID", "W", "WardsDisplayed", 0))
            Do
               asksupplier Code$, 0, typeList$, "Select a valid Ward", False, sup, False '15Nov12 TH Added PSO param
            Loop While Trim$(Code$) = ""
            clearsup sup
            getsupplier Code$, 0, found, sup
         End If
      
      If sup.suppliertype = "L" And Trim$(sup.wardcode) = "" Then
            popmessagecr "#", "List: " & Trim$(ward$) & " has no cost centre defined" & cr & "You will need to select a cost centre"
            Do
               asksupplier Code$, 0, "W", "Select a Cost Centre for: " & Trim$(Code$), False, sup, False  '15Nov12 TH Added PSO param
            Loop While Trim$(Code$) = ""
            clearsup sup
            getsupplier Code$, 0, found, sup
         End If

      costcentre$ = Trim$(sup.wardcode)

End Sub

Sub getsupplier(ByVal supcode As String, _
                ByVal Find As Long, _
                FoundSup As Long, _
                ByRef suplocal As supplierstruct _
               )

'09May05 removed param  locksup%  as this should be done outside the procedure by transactions
' Clears the sup structure whether or not the supplier is found
' Raises an error if Find is negative, otherwise
' looks for SupplierID=Find
' or Code=supcode
' No error if not found
'Returns sup structure and foundsup = sup.suplierID
' (Blank & zero if not found)
'Not cached now - no point as one server read is needed anyway

'10Jul14 TH Now Explicitly exclude lists with ward stock overhaul
'22Jan15 TH Added optional param to include lists if required. OCX needed this to load list
'           and identify if was linked or not. (TFS 102821)

Dim rsSupplier    As ADODB.Recordset
Dim strParameters As String

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetSupplier"

   On Error GoTo ErrorHandler

   FoundSup = 0
   clearsup suplocal
   supcode = trimz$(supcode)
   
   If Find < 0 Then
      Err.Raise 65535, "GetSupplier", "Attempted to load supplier " & Format$(Find)
   Else
      If Find > 0 Then
         strParameters = gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 1, Find)
         Set rsSupplier = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplier", strParameters)
      ElseIf Find = 0 And Len(supcode) > 0 Then
         strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                         gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, Len(sup.Code), supcode)
         Set rsSupplier = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierByCode", strParameters)
      End If
      
      If Not rsSupplier Is Nothing Then
         If Not rsSupplier.EOF Then
            suplocal = FillSupFromRS(rsSupplier)
            FoundSup = suplocal.SupplierID
         End If
      End If
   End If

Cleanup:
   On Error Resume Next
   Set rsSupplier = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   'ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Sub

Public Function FillSupFromRS(ByVal rsSupplier As ADODB.Recordset) As supplierstruct
'01Aug12 TH Added PSO Flag (TFS40445)
'15Jul14 XN  Added new fields to WSupplier National Supplier code, DUNS reference, User fields 1 to 4 88506

Dim suplocal As supplierstruct
   clearsup suplocal
   If Not rsSupplier.EOF Then
      With suplocal
         .AdHocDelNote = RtrimGetField(rsSupplier!AdHocDelNote)
         .ATCSupplied = RtrimGetField(rsSupplier!ATCSupplied)
         .avleadtime = RtrimGetField(rsSupplier!avleadtime)
         .Code = RtrimGetField(rsSupplier!Code)
         .contfaxno = RtrimGetField(rsSupplier!contfaxno)
         .contractaddress = RtrimGetField(rsSupplier!contractaddress)
         .conttelno = RtrimGetField(rsSupplier!conttelno)
         .costcentre = RtrimGetField(rsSupplier!costcentre)
         .discountabove = RtrimGetField(rsSupplier!discountabove)
         .discountbelow = RtrimGetField(rsSupplier!discountbelow)
         .discountdesc = RtrimGetField(rsSupplier!discountdesc)
         .discountval = RtrimGetField(rsSupplier!discountval)
         .fullname = RtrimGetField(rsSupplier!fullname)
         .icode = RtrimGetField(rsSupplier!icode)
         .InPatientDirections = RtrimGetField(rsSupplier!InPatientDirections)
         If RtrimGetField(rsSupplier!inuse) Then
            .inuse = "Y"
         Else
            .inuse = "N"
         End If
         .invaddress = RtrimGetField(rsSupplier!invaddress)
         .invfaxno = RtrimGetField(rsSupplier!invfaxno)
         .invtelno = RtrimGetField(rsSupplier!invtelno)
         .Method = RtrimGetField(rsSupplier!Method)
         .name = RtrimGetField(rsSupplier!name)
         .onCost = RtrimGetField(rsSupplier!onCost)
         .OrderOutput = RtrimGetField(rsSupplier!OrderOutput)
         .ordmessage = RtrimGetField(rsSupplier!ordmessage)
         .PrintDeliveryNote = RtrimGetField(rsSupplier!PrintDeliveryNote)
         .PrintPickTicket = RtrimGetField(rsSupplier!PrintPickTicket)
         .psis = RtrimGetField(rsSupplier!psis)
         .ptn = RtrimGetField(rsSupplier!ptn)
         .ReceiveGoods = RtrimGetField(rsSupplier!ReceiveGoods)
         .supaddress = RtrimGetField(rsSupplier!supaddress)
         .supfaxno = RtrimGetField(rsSupplier!supfaxno)
         .suppliertype = UCase$(RtrimGetField(rsSupplier!suppliertype))
         .suptelno = RtrimGetField(rsSupplier!suptelno)
         .topupdate = RtrimGetField(rsSupplier!topupdate)
         .TopupInterval = RtrimGetField(rsSupplier!TopupInterval)
         .wardcode = RtrimGetField(rsSupplier!wardcode)
         .SupplierID = RtrimGetField(rsSupplier!WSupplierID)
         .MinimumOrderValue = RtrimGetField(rsSupplier!MinimumOrderValue)
         .LeadTime = RtrimGetField(rsSupplier!LeadTime)
         .PSO = TrueFalse(RtrimGetField(rsSupplier!PSO))  '01Aug12 TH Added (PSO)(TFS40445)
         .UserField1 = RtrimGetField(rsSupplier!UserField1)                     ' 15Jul14 XN Added new fields 88506
         .UserField2 = RtrimGetField(rsSupplier!UserField2)                     ' 15Jul14 XN Added new fields 88506
         .UserField3 = RtrimGetField(rsSupplier!UserField3)                     ' 15Jul14 XN Added new fields 88506
         .UserField4 = RtrimGetField(rsSupplier!UserField4)                     ' 15Jul14 XN Added new fields 88506
         .NationalSupplierCode = RtrimGetField(rsSupplier!NationalSupplierCode) ' 15Jul14 XN Added new fields 88506
         .DUNSReference = RtrimGetField(rsSupplier!DUNSReference)       ' 15Jul14 XN Added new fields 88506
         .GlobalLocationNumber = RtrimGetField(rsSupplier!GlobalLocationNumber) ' 15Jul14 XN Added new fields 88506
      End With
   End If
   FillSupFromRS = suplocal

End Function

Sub getsupplierward(Code$, desc$, found%, inuse%)
'28May97 CKJ Written
'29May97 CKJ Limit to type "W" and InUse=Y
'            Added inuse flag, as the old "#" method is not applicable now
'09Feb98 EAC Modified to use the WardCode field
'22May98 CFY/CKJ Changed the condition which compares the code entered
'                by the user with the codes in the file. Was previously failing
'                and acception invalid codes
'28Sep99 CKJ Use new cache instead of brute force search
'            Also returns Found=T and InUse=F if item is found but not in use
'            - previously it returned Found=F

Dim codetmp$                              '22May98 CFY/CKJ Added
Dim iCount As Integer                     '28Sep99 CKJ added

   desc$ = "<Invalid Code>"
   found = False
   inuse = False
   codetmp$ = Trim$(UCase$(Code$))        '22May98 CFY/CKJ Added
   
   FillSupplierCache                                                                 '28Sep99 CKJ Block added
   For iCount = 1 To m_lngSupplierCacheEntries
      If mSupplierCache(iCount).suppliertype = "W" Then
         If Trim$(UCase$(mSupplierCache(iCount).wardcode)) = codetmp$ Then
            Code$ = Trim$(mSupplierCache(iCount).wardcode)
            desc$ = Trim$(mSupplierCache(iCount).fullname)
            found = True
            inuse = (UCase$(mSupplierCache(iCount).inuse) <> "N")
            Exit For
         End If
      End If
   Next

End Sub

''Sub GetValues(Item$, Vlu() As String, typ$)
''
'''To return values which are themselves user-definable, such as consultant codes.
'''Returned in the array Vlu(), where:
'''  Vlu(1,1...n) = Code of that item        'eg ASH
'''  Vlu(2,1...n) = Full name of that item   'eg Ashfield Ward
'''
'''  returns the appropriate type declaration character in typ$, eg $,%,&
''
''Dim FileName$, codetype$, codemax%, expmax%
''Dim fil%, Items%, n%, Codes() As String, Exps() As String
''Dim errnum%, i%, supcode$, found&, cont&
''
''   Select Case Item$
''      Case "CONSULTANTCODES"
''         FileName$ = dispdata$ & "\conscode.dat"         '!!OCX Not handled
''         codetype$ = "Consultant"
''         codemax = 4
''         expmax = 30
''         typ$ = "$"
''         GoSub GetCodes
''
''      Case "WARDCODES"
''         Do
''            supcode$ = ""
''            binarysearchidx supcode$, dispdata$ & "\supfile.idx", 1, cont&, found&
''            If found > 0 Then
''                  getsupplier "", (found&), 0, False, sup
''                  If sup.suppliertype = "W" Then
''                        n = n + 1
''                        ReDim Preserve Codes(1 To n)
''                        ReDim Preserve Exps(1 To n)
''                        Codes(n) = Trim$(sup.Code)
''                        Exps(n) = Trim$(sup.FullName)
''                  End If
''               End If
''         Loop Until found = 0
''         Items = n
''
''      Case ""
''               Exit Sub
''   End Select
''
''   If Items > 0 Then
''         ReDim Vlu(1 To 2, 1 To Items)
''         For n = 1 To Items - 1
''               Vlu(1, n) = Codes(n + 1)
''               Vlu(2, n) = Exps(n + 1)
''            Next
''      Else
''         Erase Vlu
''      End If
''
''
''GetValuesExit:
''
''   Exit Sub
''
'''copied from supplier.bas:Editors
''GetCodes:
''   Screen.MousePointer = HOURGLASS
''
''   If fileexists(FileName$) Then
''         Do
''            On Error GoTo GVfilerror             '13Feb95 CKJ Added error chk
''            errnum = 0
''            fil = FreeFile
''            Open FileName$ For Input As #fil
''            Err70msg errnum, "File " + FileName$
''         Loop While errnum
''         On Error GoTo 0
''
''         Input #fil, Items
''         ReDim Codes(Items) As String, Exps(Items) As String
''         For i = 1 To Items
''            Input #fil, Codes(i), Exps(i)
''            Codes(i) = UCase$(Trim$(Codes(i)))
''            Exps(i) = RTrim$(Exps(i))          '13Mar95 CKJ was trim$
''  '          If Char30 Then replace Exps(i), Chr$(30), crlf, 0
''         Next
''         Close #fil
''      Else
''         Items = 0
''      End If
''   Screen.MousePointer = STDCURSOR
''
''
''   Return
'''-------------------------------------------------------------------------------
''GVfilerror:
''
''   Select Case Err
''      Case 70, 63
''         errnum = Err
''         Resume Next
''      End Select
''   popmessagecr "Procedure halted", " Error " & Format$(Err) & " while saving file " & FileName$
''Exit Sub               '!!** is this OK?
''
''
''
''End Sub

Sub GetWardDescription(wardcode$, wardexp$, inuse%, found%)
'  Find ward description, regardless of whether currently in use or not.
'  Look for the ward code first in sup.wardcode of all "W" type entries,
'  then look for the ward code as sup.code in the "L" type entries.
'  Returns the description in wardexp$, InUse = T/F and Found = True
'  If item is not found then Found=False, wardexp$ and inuse% are unchanged

Dim iCount As Integer
Dim iFound As Integer
Dim sCode As String

   sCode = Trim$(UCase$(wardcode$))
   iFound = False
   FillSupplierCache

   For iCount = 1 To m_lngSupplierCacheEntries
      If mSupplierCache(iCount).suppliertype = "W" Then
         If Trim$(UCase$(mSupplierCache(iCount).wardcode)) = sCode Then
            ''wardcode$ = Trim$(mSupplierCache(iCount).wardcode)       !pointless!
            wardexp$ = Trim$(mSupplierCache(iCount).fullname)
            inuse = (UCase$(mSupplierCache(iCount).inuse) <> "N")
            iFound = True
            Exit For
         End If
      End If
   Next
   
   If Not iFound Then                                'now look in Repeat Prescribing Groups
      For iCount = 1 To m_lngSupplierCacheEntries
         If mSupplierCache(iCount).suppliertype = "L" Then
            If Trim$(UCase$(mSupplierCache(iCount).Code)) = sCode Then
               wardexp$ = Trim$(mSupplierCache(iCount).fullname)
               inuse = (UCase$(mSupplierCache(iCount).inuse) <> "N")
               iFound = True
               Exit For
            End If
         End If
      Next
   End If

   found = iFound
         
End Sub

Function joinsup$(addr$, sup As supplierstruct)
'29Mar93 CKJ Proc written
'11Aug94 CKJ Added supnam$ <> ""

Dim supnam$

   supnam$ = Trim$(sup.fullname)
   If supnam$ <> "" And Right$(supnam$, 1) <> "," And Trim$(addr$) <> "" Then supnam$ = supnam$ & ","
   joinsup$ = supnam$ & addr$

End Function

Sub ManualPush(ByVal pathfile$)
'15Jul98 CKJ This uses PushCtrl.ini to control whether a file is to be sent and where to.
'            Note that one file may imply another - eg asking for directions to be sent will
'            also send the index, if this has been set up in PushCtrl.ini

Dim filename$, NumItems%, count%, tot%, iniFile$, found%, values$, tmp$, i%
Dim filedesc$, ErrNum%, ErrMsg$, Files$
ReDim lines$(0 To 100), servers$(1 To 100)

   iniFile$ = dispdata$ & "\PushCtrl.ini"
   deflines pathfile$, lines$(), "\", 1, NumItems      '\\server\path\filename.ext
   filename$ = lines$(NumItems)                        'filename.ext
   tot = Val(TxtD(iniFile$, "Files", "0", "Total", found))
   For count = 1 To tot
      tmp$ = TxtD(iniFile$, "Files", "", Format$(count), found)
      If InStr(1, "," & tmp$, "," & filename$, 1) Then      'description,file.ext,another.ext
         filedesc$ = Left$(tmp$, InStr(tmp$, ",") - 1)   'description
         Files$ = Mid$(tmp$, InStr(tmp$, ",") + 1)       'file.ext,another.ext
         Exit For
      End If
   Next

   If count <= tot Then                                      'file is at least one we can push
         tot = Val(TxtD(iniFile$, "Sites", "0", "Total", found))
         If tot Then
               frmoptionset 0, "Send " & filedesc$ & " to..."      'Action 0 initialises
               values$ = ""
               For count = 1 To tot
                  tmp$ = TxtD(iniFile$, "Sites", "", Format$(count), found)
                  If Not found Then tmp$ = "<Site not found in PushCtrl.ini>"
                  deflines tmp$, lines$(), ",(*)", 1, NumItems
                  frmoptionset 1, lines$(1)
                  servers$(count) = lines$(2)
                  values$ = values$ & Iff(InStr(1, tmp$, filename$, 1) > 0, "1", "0")
               Next
               frmoptionshow (values$), values$
               frmoptionset 0, ""    'Unload
               ScreenRefresh
               
               For count = 1 To Len(values$)
                  If servers$(count) <> "" And Mid$(values$, count, 1) = "1" Then
                        deflines Files$, lines$(), ",", 1, NumItems  'file.ext,another.ext
                        For i = 1 To NumItems
                           ErrNum = PushControl(lines$(i), servers$(count), ErrMsg$)
                           'writelog ...
                           If ErrNum Then
                                 popmessagecr ".", "Error" & Str$(ErrNum) & " : " & ErrMsg$ & cr & "During send of " & filedesc$ & " (" & lines$(i) & ")" & cr & "to " & servers$(count)
                              End If
                        Next
                     End If
               Next
            End If
      End If
                     
End Sub

Function ProcessUpdateErr(ErrNo%, MODULE$, Proc$, Currec&, retries%) As Integer
   
   Select Case ErrNo
      Case 3197
         popmessagecr "Cannot Update Database", "This record has been changed by another user." & Chr$(13) & Chr$(13) & "Please reload this ward and try again."
         ProcessUpdateErr = 0

      Case 3046, 3260, 3186 To 3189
         retries = retries + 1
         waitforticks 20
         DoEvents
         ''FreeLocks
         ProcessUpdateErr = -1

      Case Else
         popmessagecr "Error", "Module : " & MODULE$ & Chr$(13) & "Procedure : " & Proc$ & Chr$(13) & Error$(ErrNo)
         ProcessUpdateErr = 1
   
      End Select

 '@~@~
 '  If Currec& > 0 And Currec& <= ONumtoDisplay Then
 '        MainScreen.lvwMainScreen.Modified = False
 '        MainScreen.lvwMainScreen.EditActive = False
 '        MainScreen.lvwMainScreen.RefreshRow = Currec&
 '     End If
   
End Function

Function PushControl(filename$, DrivePath$, ErrMsg$) As Integer
'''30Jul98 CKJ Written
'''            This procedure checks whether a file to be replicated can be simply copied
'''            in which case it invokes PushFile, or whether special handling is needed
'''            in which case it handles this itself.
'''            The control is provided by optional lines in PushCtrl.ini, in the [Files] section
'''            Each file which is pushed is assumed to have the default Method=0 ie a simple copy
'''            unless a line filename=<methodnum> is present. The method nums are allocated here.
'''
'''            To merge directions files use method 1, adding lines similar to the following;
'''            [Files]
'''            ;direction file (without path)=1
'''            direct.v6=1
'''            dir852.v6=1
'''            If the remote site does not have the directions file then it & its index are sent
'''            If the file exists, then each direction in the main file is read;
'''            For each direction which is in use and which is not ward specific;
'''             scan the remote index for the base direction plus all ward specific versions
'''             for each one found update specified fields (currently just the text)
'''            If the base direction is not found then add it copying the original one exactly
'''             then update the index
'''21Oct98 CFY/CKJ Fixes to directions file update routine. New directions are now added to the
'''                destination file correctly. Directions that are already present in the destination
'''                file are now also updated and written back correctly.
'''10May99 CFY  No longer ignores directions that have been deleted on the source site. Instead corresponding directions
'''             on the destination site are marked as deleted.
''
''Dim errnum%, iniFile$, pointer&, cont&, find&, found&, method%, chan1%, chan2%
''Dim remoteidx$, foundbasecode%, failed%, needsorting%
''Dim Dir1 As directstruct, dir2 As directstruct
''
''   errnum = 0
''   ErrMsg$ = ""
''   iniFile$ = dispdata$ & "\PushCtrl.ini"
''
''   method = Val(txtd(iniFile$, "Files", "0", filename$, 0))
''   Select Case method
''      Case 0                         'Normal copy
''         errnum = PushFile(filename$, DrivePath$, ErrMsg$)
''
''      Case -1                        'Ignore request - its handled elsewhere (eg DirV6.idx)
''         'No action needed
''
''      Case 1                         'Merge Directions files
''         remoteidx$ = "dirv6.idx"
''         If LCase$(filename$) <> "direct.v6" Then                             'infer index name
''               remoteidx$ = filename$                                         'dir852.v6
''               replace remoteidx$, ".", Nul, 0                                'dir852¦v6   where ¦ is chr$(0)
''               remoteidx$ = asciiz$(remoteidx$) & ".idx"                      'dir852' & '.idx'
''            End If
''
''         If Not DirExists(DrivePath$) Then                                    'is the path there
''               errnum = 76                                                    'no
''               ErrMsg$ = "Path not found " & DrivePath$
''            ElseIf Not fileexists(DrivePath$ & "\" & filename$) Then          'yes but files are not
''               errnum = PushFile(filename$, DrivePath$, ErrMsg$)              'so send them both
''               errnum = PushFile(remoteidx$, DrivePath$, ErrMsg$)
''            ElseIf Not fileexists(DrivePath$ & "\" & remoteidx$) Then         'data OK but index not
''               errnum = 53                                                    'this is abnormal
''               ErrMsg$ = "File not found " & remoteidx$
''            End If
''         remoteidx$ = DrivePath$ & "\" & remoteidx$                           'add the path now
''
''         If errnum = 0 Then
''               Progress.lblInfo = "Updating " & DrivePath$ & "\" & filename$ & cr & "From " & dispdata$ & "\" & filename$
''               Progress.Show 0
''               needsorting = False
''               openrandomfile DrivePath$ & "\" & filename$, Len(dir2), chan2  'their file
''               GetPointer dispdata$ & "\" & filename$, pointer&, 0
''               openrandomfile dispdata$ & "\" & filename$, Len(Dir1), chan1   'our file
''               For find& = 2 To pointer&                                      'scan our file
''                  Progress.PerCent = 100 * find& \ pointer&
''                  GetRecordNL R, find&, chan1, Len(Dir1)
''                  LSet Dir1 = R
''
''                  'Push only ones which are in use and not ward-specific
''                  'If dir1.deleted <> "Y" And LTrim$(dir1.location) = "" Then  'it's worth sending
''                  If LTrim$(Dir1.location) = "" Then  'it's worth sending
''                        foundbasecode = False
''                        cont& = 0
''                        Do                             'look for base code and ward specific ones
''                           binarysearchidx Trim$(Dir1.code), remoteidx$, True, cont&, found&
''                           If found& Then
''                                 GetRecordL R, found&, chan2, Len(dir2)       'read their direction
''                                 LSet dir2 = R
''                                 If LTrim$(dir2.location) = "" Then foundbasecode = True
''                                 'Update all relevant fields:
''                                 'code As String * 12                         'same as our code
''                                 'route As String * 4
''                                 'EqualInterval As Single
''                                 'TimeUnits As String * 3
''                                 'RepeatInterval As Integer
''                                 'RepeatUnits As String * 3
''                                 'CourseLength As Integer
''                                 'CourseUnits As String * 3
''                                 'Abstime As String * 1
''                                 'Days As String * 1
''                                 'Dose(12) As Single
''                                 'Times(12) As String * 4
''
''                                 'DeletedBy As String * 5
''                                 'ApprovedBy As String * 5
''                                 'RevisionNo As Integer
''                                 'location As String * 4                      'don't amend this
''                                 dir2.directs = Dir1.directs      '<= probably the only one of use
''                                 If UCase$(Dir1.deleted) = "Y" Then                 '10May99 CFY Added
''                                       dir2.deleted = Dir1.deleted                   '       "
''                                       dir2.DeletedBy = "IMPRT"                      '       "
''                                       Updateindex dir2.code, "", found&, remoteidx$, failed '       "
''                                    End If                                           '       "
''                                 'PRN As String * 1
''                                 LSet R = dir2                                '21Oct98 CFY/CKJ Added
''                                 PutRecordL R, found&, chan2, Len(dir2)       'write it back
''                              End If
''                        Loop While cont&
''                        binarysearchidx "", "", 0, 0, 0                       'close the index
''                        If Not foundbasecode Then                             'add the direction
''                              GetPointer DrivePath$ & "\" & filename$, found&, True
''                              If found& > 1 Then                              'can't do it if the file isn't correct
''                                    GetRecordL R, found&, chan2, Len(dir2)    'read the new record
''                                    LSet R = Dir1                             'copy ours to R
''                                    PutRecordL R, found&, chan2, Len(dir2)    'and write it
''                                    'Updateindex "", RTrim$(dir2.code), (found&), remoteidx$, failed     '21Oct98 CFY/CKJ Replaced
''                                    Updateindex "", RTrim$(Dir1.code), (found&), remoteidx$, failed      '       "
''                                    needsorting = True
''                                 Else
''                                    popmessagecr ".", "Pointer record missing from file " & DrivePath$ & "\" & filename$
''                                 End If
''                           End If
''                     End If
''               Next
''               Unload Progress
''               If chan1 Then Close chan1                                      'close our file
''               If chan2 Then Close chan2                                      'close theirs
''               If needsorting Then sortindex (remoteidx$), remoteidx$         'sort their index
''            End If
''
''
''      'Case 2   Add more methods here...
''
''
''      Case Else
''         ErrMsg$ = "PushControl called with undefined Method=" & Format$(method) & " for " & filename$
''         errnum = 32767
''      End Select
''
''   PushControl = errnum

End Function

Function PushFile(filename$, DrivePath$, ErrMsg$) As Integer
'Push edited file to another account

Dim tries%, errcode%

   Screen.MousePointer = HOURGLASS
   errcode = 0
   ErrMsg$ = ""
   If DirExists(DrivePath$) Then
         tries = 0
         On Error GoTo PushFile_Err
         FileCopy dispdata$ & "\" & filename$, DrivePath$ & "\" & filename$
         Screen.MousePointer = STDCURSOR
      Else
         errcode = 76                    'path not found
         ErrMsg$ = "Path not found"
         Screen.MousePointer = STDCURSOR
         popmessagecr ".", "Cannot access path '" & DrivePath$ & "'"
      End If

PushFile_Exit:
   Screen.MousePointer = STDCURSOR
   PushFile = errcode
Exit Function

PushFile_Err:
   If Err = 55 Then               'file already open
         If tries < 10 Then
               waitforticks 20    '1 sec approx
               Resume Next
            Else
               Screen.MousePointer = STDCURSOR
               popmessagecr ".", "Cannot access '" & filename$ & "' on '" & DrivePath$ & "'; file is already open"
               errcode = 55
               ErrMsg$ = Error$
               Resume PushFile_Exit
            End If
      Else
         errcode = Err
         ErrMsg$ = Error$
         Resume PushFile_Exit
      End If

End Function

Sub putsupplier(lngSupplierID As Long, sup As supplierstruct)
''SQL Currently this isnt required as the only changes to suppliers should come through the editors

''   If onlyunlock% Then
''         UnlockRecord supchan, (Find), Len(sup)    '08Feb96 EAC - use new version of (un)lockrecord
''      Else
''         LSet r = sup
''         PutRecordL r, (Find), supchan%, Len(sup)  '11Aug91 CKJ (f) & PutRecordL
''      End If
'17Jun05 TH Now it is !!!!
''removed  onlyunlock parameter

'19Mar09 TH Added sUpdateflag to heap for UHB (F0032689)
'19Mar09 TH Entry for supplier interface for UHB (F0032689)
'01Aug12 TH Added PSO Flag (TFS40445)

Dim strParams As String
Dim lngResult As Long
Dim blnInuse As Boolean
Dim WCustomerID As Long

   
   
      With sup
      blnInuse = TrueFalse(.inuse)
      
      If UCase$(Trim$(.suppliertype)) = "E" Then
         'External Supplier
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, .Code) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 15, .name) & _
               gTransport.CreateInputParameterXML("Fullname", trnDataTypeVarChar, 35, .fullname) & _
               gTransport.CreateInputParameterXML("contractaddress", trnDataTypeVarChar, 100, .contractaddress) & _
               gTransport.CreateInputParameterXML("supaddress", trnDataTypeVarChar, 100, .supaddress) & _
               gTransport.CreateInputParameterXML("invaddress", trnDataTypeVarChar, 100, .invaddress) & _
               gTransport.CreateInputParameterXML("conttelno", trnDataTypeVarChar, 14, .conttelno) & _
               gTransport.CreateInputParameterXML("suptelno", trnDataTypeVarChar, 14, .suptelno) & _
               gTransport.CreateInputParameterXML("invtelno", trnDataTypeVarChar, 14, .invtelno) & _
               gTransport.CreateInputParameterXML("contfaxno", trnDataTypeVarChar, 14, .contfaxno) & _
               gTransport.CreateInputParameterXML("supfaxno", trnDataTypeVarChar, 14, .supfaxno) & _
               gTransport.CreateInputParameterXML("invfaxno", trnDataTypeVarChar, 13, .invfaxno) & _
               gTransport.CreateInputParameterXML("discountdesc", trnDataTypeVarChar, 70, .discountdesc) & _
               gTransport.CreateInputParameterXML("discountval", trnDataTypeVarChar, 9, .discountval) & _
               gTransport.CreateInputParameterXML("method", trnDataTypeVarChar, 1, .Method) & _
               gTransport.CreateInputParameterXML("ordmessage", trnDataTypeVarChar, 50, .ordmessage) & _
               gTransport.CreateInputParameterXML("avleadtime", trnDataTypeVarChar, 4, .avleadtime) & _
               gTransport.CreateInputParameterXML("PrintTradeName", trnDataTypeVarChar, 1, .ptn) & _
               gTransport.CreateInputParameterXML("PrintNSVCode", trnDataTypeVarChar, 1, .psis) & _
               gTransport.CreateInputParameterXML("discountbelow", trnDataTypeVarChar, 4, .discountbelow) & _
               gTransport.CreateInputParameterXML("discountabove", trnDataTypeVarChar, 4, .discountabove) & _
               gTransport.CreateInputParameterXML("costcentre", trnDataTypeVarChar, 15, .costcentre)

         strParams = strParams & _
               gTransport.CreateInputParameterXML("OrderOutput", trnDataTypeVarChar, 1, .OrderOutput) & _
               gTransport.CreateInputParameterXML("onCost", trnDataTypeVarChar, 3, .onCost) & _
               gTransport.CreateInputParameterXML("MinimumOrderValue", trnDataTypeFloat, 8, .MinimumOrderValue) & _
               gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 2, .LeadTime) & _
               gTransport.CreateInputParameterXML("PSO", trnDataTypeBit, 1, .PSO) & _
               gTransport.CreateInputParameterXML("NationalSupplierCode", trnDataTypeVarChar, 10, .NationalSupplierCode) & _
               gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .UserField1) & _
               gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .UserField2) & _
               gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 50, .UserField3) & _
               gTransport.CreateInputParameterXML("UserField4", trnDataTypeVarChar, 50, .UserField4) & _
               gTransport.CreateInputParameterXML("DunsReference", trnDataTypeVarChar, 13, .DUNSReference) & _
               gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, blnInuse)
               
               If lngSupplierID = 0 Then
                  'Insert
                  lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WSupplier2", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Create", 0   '19Mar09 TH Added (UHB) (F0032689)
               Else
                  'Update
                  strParams = gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, lngSupplierID) & strParams
                  lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WSupplier2", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Update", 0   '19Mar09 TH Added (UHB) (F0032689)
               End If
               
         ElseIf UCase(Trim$(.suppliertype)) = "W" Or UCase(Trim$(.suppliertype)) = "S" Then
            'Ward or Store (customer)
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, .Code) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 15, .name) & _
               gTransport.CreateInputParameterXML("Fullname", trnDataTypeVarChar, 35, .fullname) & _
               gTransport.CreateInputParameterXML("Address", trnDataTypeVarChar, 100, .supaddress) & _
               gTransport.CreateInputParameterXML("TelephoneNo", trnDataTypeVarChar, 14, .suptelno) & _
               gTransport.CreateInputParameterXML("FaxNo", trnDataTypeVarChar, 14, .supfaxno) & _
               gTransport.CreateInputParameterXML("Costcentre", trnDataTypeVarChar, 15, .costcentre) & _
               gTransport.CreateInputParameterXML("PrintDeliveryNote", trnDataTypeBit, 1, IIf(.PrintDeliveryNote = "Y", True, False)) & _
               gTransport.CreateInputParameterXML("PrintPickTicket", trnDataTypeBit, 1, IIf(.PrintPickTicket = "Y", True, False)) & _
               gTransport.CreateInputParameterXML("onCost", trnDataTypeVarChar, 3, .onCost) & _
               gTransport.CreateInputParameterXML("AdHocDelNote", trnDataTypeBit, 1, IIf(.AdHocDelNote = "Y", True, False)) & _
               gTransport.CreateInputParameterXML("IsCustomer", trnDataTypeBit, 70, 0) & _
               gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, .UserField1) & _
               gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, .UserField2) & _
               gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 50, .UserField3) & _
               gTransport.CreateInputParameterXML("UserField4", trnDataTypeVarChar, 50, .UserField4) & _
               gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, blnInuse) & _
               gTransport.CreateInputParameterXML("GlobalLocationNumber", trnDataTypeVarChar, 13, .GlobalLocationNumber)
               
               If lngSupplierID = 0 Then
                  'Insert
                  lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WCustomer", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Create", 0   '19Mar09 TH Added (UHB) (F0032689)
               Else
                  'Update
                  strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, lngSupplierID) & strParams
                  lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WCustomer", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Update", 0   '19Mar09 TH Added (UHB) (F0032689)
               End If
         
         
         
         
         Else
            'List
            'Resolve the Customer ID here from the ward code
            If .wardcode <> "" Then
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, .wardcode)
               WCustomerID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWCustomerIDbyCode", strParams)
            Else
               WCustomerID = 0
            End If
            
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, .Code) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 15, .name) & _
               gTransport.CreateInputParameterXML("Fullname", trnDataTypeVarChar, 35, .fullname) & _
               gTransport.CreateInputParameterXML("PrintDeliveryNote", trnDataTypeBit, 1, IIf(.PrintDeliveryNote = "Y", True, False)) & _
               gTransport.CreateInputParameterXML("PrintPickTicket", trnDataTypeBit, 1, IIf(.PrintPickTicket = "Y", True, False)) & _
               gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, WCustomerID) & _
               gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, blnInuse) & _
               gTransport.CreateInputParameterXML("VisibleToWard", trnDataTypeBit, 1, True)
               
               
               
               If lngSupplierID = 0 Then
                  'Insert
                  lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WWardProductList", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Create", 0   '19Mar09 TH Added (UHB) (F0032689)
               Else
                  'Update
                  strParams = gTransport.CreateInputParameterXML("WWardProductListID", trnDataTypeint, 4, lngSupplierID) & strParams
                  lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WWardProductList", strParams)
                  Heap 10, gPRNheapID, "sUpdateflag", "Update", 0   '19Mar09 TH Added (UHB) (F0032689)
               End If
         End If
      End With
         
      
'      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 5, .Code) & _
'               gTransport.CreateInputParameterXML("contractaddress", trnDataTypeVarChar, 100, .contractaddress) & _
'               gTransport.CreateInputParameterXML("supaddress", trnDataTypeVarChar, 100, .supaddress) & _
'               gTransport.CreateInputParameterXML("invaddress", trnDataTypeVarChar, 100, .invaddress) & _
'               gTransport.CreateInputParameterXML("conttelno", trnDataTypeVarChar, 14, .conttelno) & _
'               gTransport.CreateInputParameterXML("suptelno", trnDataTypeVarChar, 14, .suptelno) & _
'               gTransport.CreateInputParameterXML("invtelno", trnDataTypeVarChar, 14, .invtelno) & _
'               gTransport.CreateInputParameterXML("discountdesc", trnDataTypeVarChar, 70, .discountdesc) & _
'               gTransport.CreateInputParameterXML("discountval", trnDataTypeVarChar, 9, .discountval) & _
'               gTransport.CreateInputParameterXML("method", trnDataTypeVarChar, 1, .Method) & _
'               gTransport.CreateInputParameterXML("ordmessage", trnDataTypeVarChar, 50, .ordmessage) & _
'               gTransport.CreateInputParameterXML("avleadtime", trnDataTypeVarChar, 4, .avleadtime) & _
'               gTransport.CreateInputParameterXML("contfaxno", trnDataTypeVarChar, 14, .contfaxno) & _
'               gTransport.CreateInputParameterXML("supfaxno", trnDataTypeVarChar, 14, .supfaxno) & _
'               gTransport.CreateInputParameterXML("invfaxno", trnDataTypeVarChar, 13, .invfaxno) & _
'               gTransport.CreateInputParameterXML("name", trnDataTypeVarChar, 15, .name) & _
'               gTransport.CreateInputParameterXML("ptn", trnDataTypeVarChar, 1, .ptn) & _
'               gTransport.CreateInputParameterXML("psis", trnDataTypeVarChar, 1, .psis) & _
'               gTransport.CreateInputParameterXML("fullname", trnDataTypeVarChar, 35, .fullname) & _
'               gTransport.CreateInputParameterXML("discountbelow", trnDataTypeVarChar, 4, .discountbelow) & _
'               gTransport.CreateInputParameterXML("discountabove", trnDataTypeVarChar, 4, .discountabove) & _
'               gTransport.CreateInputParameterXML("icode", trnDataTypeVarChar, 8, .icode) & _
'               gTransport.CreateInputParameterXML("costcentre", trnDataTypeVarChar, 15, .costcentre) & _
'               gTransport.CreateInputParameterXML("PrintDeliveryNote", trnDataTypeVarChar, 1, .PrintDeliveryNote)
'
'      strParams = strParams & _
'               gTransport.CreateInputParameterXML("PrintPickTicket", trnDataTypeVarChar, 1, .PrintPickTicket) & _
'               gTransport.CreateInputParameterXML("suppliertype", trnDataTypeVarChar, 1, .suppliertype) & _
'               gTransport.CreateInputParameterXML("OrderOutput", trnDataTypeVarChar, 1, .OrderOutput) & _
'               gTransport.CreateInputParameterXML("ReceiveGoods", trnDataTypeVarChar, 1, .ReceiveGoods) & _
'               gTransport.CreateInputParameterXML("TopupInterval", trnDataTypeVarChar, 2, .TopupInterval) & _
'               gTransport.CreateInputParameterXML("ATCSupplied", trnDataTypeVarChar, 1, .ATCSupplied) & _
'               gTransport.CreateInputParameterXML("topupdate", trnDataTypeVarChar, 8, .topupdate) & _
'               gTransport.CreateInputParameterXML("inuse", trnDataTypeBit, 1, blnInuse) & _
'               gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 5, .wardcode) & _
'               gTransport.CreateInputParameterXML("onCost", trnDataTypeVarChar, 3, .onCost) & _
'               gTransport.CreateInputParameterXML("InPatientDirections", trnDataTypeVarChar, 1, .InPatientDirections) & _
'               gTransport.CreateInputParameterXML("AdHocDelNote", trnDataTypeVarChar, 1, .AdHocDelNote) & _
'               gTransport.CreateInputParameterXML("MinimumOrderValue", trnDataTypeFloat, 8, .MinimumOrderValue) & _
'               gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 2, .LeadTime) & _
'               gTransport.CreateInputParameterXML("PSO", trnDataTypeBit, 1, .PSO) '01Aug12 TH Added PSO Flag (TFS40445)
'   End With
'   If lngSupplierID = 0 Then
'      'Insert
'      lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WSupplier", strParams)
'      Heap 10, gPRNheapID, "sUpdateflag", "Create", 0   '19Mar09 TH Added (UHB) (F0032689)
'   Else
'      'Update
'      strParams = gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 4, lngSupplierID) & strParams
'      lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WSupplier", strParams)
'      Heap 10, gPRNheapID, "sUpdateflag", "Update", 0   '19Mar09 TH Added (UHB) (F0032689)
'   End If
'
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "GenericInterface", "N", "SupplierInterface", 0)) Then SupplierOutput sup, lngResult '19Mar09 TH Added (UHB)

End Sub
Sub SupplierOutput(sup As supplierstruct, ByVal WSupplierID As Long)
'26Feb09 TH Written for UHB SAGE Interface solution (F0032689)
'26Jan17 TH Use new RTFExistsInDatabase function - Hosted (TFS 174442)


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
Dim intSuccess As Integer '05Jan17 TH Added

   'Check the type of order record is correct.
   If InStr(TxtD(dispdata$ & "\GenInt.INI", "GenericInterface", "EWS", "SupplierTypes", 0), sup.suppliertype) > 0 Then

      'Put the supplier information on the heap
      FillHeapSupplierInfo gPRNheapID, sup, 0
      
      'Output the file
      strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", "", "RTFFile", 0)
      strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", strRTFFile, "RTFFile" & sup.suppliertype, 0) '03Mar09 TH Added
      If strRTFFile <> "" Then
         strRTFFile = dispdata & "\" & strRTFFile
         'If fileexists(strRTFFile) Then    'rtf is present
         'GetRTFTextFromDB strRTFFile, "", intSuccess  '04Jan17 TH Now read from DB (Hosted)
         'If intSuccess Then    '04Jan17 TH Now read from DB (Hosted) - replaced above
         If RTFExistsInDatabase(strRTFFile) Then  '26Jan17 TH Replaced above
            strFilename = TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", "", "ExportFilePath", 0)
            If strFilename <> "" Then
               'strFile = strFilename
               If DirExists(strFilename) Then
                  'Now get a pointer to ensure unique file
                  strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", dispdata$ & "\SupInt.dat", "InterfacePointerFile", 0)
                  GetPointerSQL strPointerFilename, lngPointer, True
                  Heap 10, gPRNheapID, "OutputRefNoPad", Format$(lngPointer), 0
                  
                  'strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", "S", "FilePrefix", 0) & Space$(3), 3))
                  strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", "S", "FilePrefix", 0))
                  'strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer)
                  'strFilename = strFilename & "\" & strFilePrefix & Left$("0000000000", 10 - (Len(Format$(lngPointer)))) & Format$(lngPointer)
                  strFilename = strFilename & "\" & strFilePrefix & Format$(lngPointer, "0000000000")
                  strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", "", "Filesuffix", 0))
                  strFilename = strFilename & strFilesuffix
                  strFilename = strFilename & TxtD(dispdata$ & "\GenInt.INI", "SupplierInterface", ".xml", "OutputFileExtension", 0)
                   
                  parseRTF strRTFFile, strOutfile
                  
                  On Error GoTo SupplierOutput_Err
                  FileCopy strOutfile, strFilename
                     
                  'remove the file afterwards
                  On Error Resume Next
                  If fileexists(strOutfile) Then Kill strOutfile
                  On Error GoTo 0
               Else
                  popmessagecr "", "Generic Interface Incorrectly configured - Supplier Export File Path Not Found"
               End If
            Else
               popmessagecr "", "Generic Interface Incorrectly configured - Supplier Export File Path required"
            End If
         Else
            popmessagecr "", "Generic Interface Incorrectly configured - Supplier Export File Not Found"    '09Apr09 TH Added after CKJ review
         End If
      Else
         popmessagecr "", "Generic Interface Incorrectly configured - Supplier Export File not specified"   '09Apr09 TH Added after CKJ review
      End If
   End If

SupplierOutput_Exit:
   Exit Sub

SupplierOutput_Err:
   strMsg = "An error has occurred in procedure : SupplierOutput" & crlf & crlf  '09Apr09 TH Altered after CKJ review
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\SupplierOutput.log", SiteNumber, UserID$, strMsg
   Resume SupplierOutput_Exit

End Sub
Static Sub readfilenames(WardNames$(), numofwards, suppliertype%)
'suppliertype = 0 - both wards & ward lists
'             = 1 - wards only
'             = 2 - ward lists only
'-----------------------------------------------------------------------------
'
'                     Read directory & return filenames
'
'-----------------------------------------------------------------------------
'mod history
'20Oct89 CKJ Only shell to make keyfile if it does not already exist
'27Dec89 CKJ Force recreation of index if data is held on floppy disc
'29Sep90 CKJ DOS 4.0 does not like  DIR .\WSLDATA\  so *.* added.
'26Mar91 CKJ DIR$ now used, keyfile is not needed
'10Sep96 EAC rewritten to use supplier file to find list of wards
'03Jun97 Kr  added extra paramter to readfilenames
'30Jun97 EAC Start reading supplier file from byte 2 not byte 1
'26Jan98 EAC ReadWardNames: size array to be same size as all entries in supplier file
'29Sep99 CKJ Replaced brute force search with cache


'   numoffiles = 0

'   On Local Error GoTo errhandler
'   filenames$(1) = Dir$(pathspec$ + "*.")   '10Jan94 CKJ was *.*
'
'   Do While filenames$(numoffiles + 1) <> ""
'      numoffiles = numoffiles + 1
'      filenames$(numoffiles + 1) = Dir$
'   Loop
'
'   On Local Error GoTo 0
'
'Exit Sub

   
' error 57 device I/O error
' error 68 device unavailable
' error 71 disk not ready

'errhandler:
'   Select Case Err
'      Case 57, 68, 71
'         filenames$(numoffiles) = ""
'         Resume Next
'      Case Else
'         Error Err
'      End Select

'------------------------------------------------------------------- 29Sep99 CKJ Removed block
'Dim tempsup As supplierstruct
'Dim loopvar&, numofsites&
'Dim SupType$   '03JUn97 KR added
'
'   numofwards = 0
'
'   If supchan% = 0 Then
'         OpenRandomFile dispdata$ + "\supfile.v5", Len(sup), supchan%
'      End If
'
'   GetPointer dispdata$ + "\supfile.v5", numofsites&, False
'
'   '26Jan98 EAC dimension WardNames array to max size needed
'   On Error Resume Next
'   If UBound(WardNames) <> numofsites& Then ReDim WardNames$(numofsites&)
'   On Error GoTo 0
'   '---
'
'   '03JUn97 KR added
'   Select Case suppliertype%
'      Case 0
'         SupType$ = "WL"
'      Case 1
'         SupType$ = "W"
'      Case 2
'         SupType$ = "L"
'      End Select
'
'   '30Jun97 EAC
'   'For loopvar& = 1 To numofsites&
'   For loopvar& = 2 To numofsites&
'   '---
'         GetRecordNL R, loopvar&, supchan%, Len(sup)
'         LSet tempsup = R
'
'         'If UCase$(tempsup.inuse) <> "N" And (UCase$(tempsup.SupplierType) = "L" Or UCase$(tempsup.SupplierType) = "W") Then
'         If UCase$(tempsup.InUse) <> "N" And (InStr(SupType$, UCase$(tempsup.suppliertype)) > 0) Then '03Jun97 KR added
'               numofwards = numofwards + 1
'               WardNames$(numofwards) = tempsup.code & tb & tempsup.name
'            End If
'      Next


Dim SupType$                        '03JUn97 KR added
Dim iCount As Integer

   FillSupplierCache

   On Error Resume Next             '26Jan98 EAC dimension WardNames array to max size needed
   If UBound(WardNames) <> m_lngSupplierCacheEntries Then ReDim WardNames$(m_lngSupplierCacheEntries)
   On Error GoTo 0
   
   Select Case suppliertype         '03JUn97 KR added
      Case 0: SupType$ = "WL"
      Case 1: SupType$ = "W"
      Case 2: SupType$ = "L"
      End Select

   numofwards = 0
   For iCount = 1 To m_lngSupplierCacheEntries
      If UCase$(mSupplierCache(iCount).inuse) <> "N" Then
         If InStr(SupType$, UCase$(mSupplierCache(iCount).suppliertype)) > 0 Then
            numofwards = numofwards + 1
            WardNames$(numofwards) = mSupplierCache(iCount).Code & TB & mSupplierCache(iCount).name
         End If
      End If
   Next

End Sub


Sub Replicate(Action%)
'15Jul98 CKJ Added
'            This uses PushCtrl.ini to control which files are sent and where to.
'            Action
'             1 Replicate now as per PushCtrl.ini
'            -1 Replicate as per PushCtrl.ini after asking user for confirmation
'            10 Configure replication

Dim NumItems%, count%, tot%, iniFile$, found%, values$, tmp$, i%
Dim filedesc$, ErrNum%, ErrMsg$, ans$, menuopt$, lin%, totfiles%
Dim ans1$, success%
ReDim lines$(0 To 100), servers$(1 To 100), Files$(1 To 100)

   iniFile$ = dispdata$ & "\PushCtrl.ini"
   
   Select Case Action
      Case 1, -1            '1 replicate now, -1 replicate after asking
         ans$ = "Y"
         If Action = -1 Then
            askwin "!EMIS Health", "OK to replicate all files to all sites as configured?", ans$, k
         End If
         If ans$ = "Y" Then
            tot = Val(TxtD(iniFile$, "Sites", "0", "Total", found))
            For count = 1 To tot
               tmp$ = TxtD(iniFile$, "Sites", "", Format$(count), found)
               deflines tmp$, lines$(), ",(*)", 1, NumItems  'description,\\server\path,filename.ext,...
               For i = 3 To NumItems
                  ErrNum = PushControl(lines$(i), lines$(2), ErrMsg$)
                  'writelog ...
                  If ErrNum Then
                     popmessagecr ".", "Error" & Str$(ErrNum) & " : " & ErrMsg$ & cr & "During send of " & filedesc$ & " (" & lines$(i) & ")" & cr & "to " & lines$(1)
                  End If
               Next
            Next
         End If

         Case 10            'configure replication
            Do
               popmenu 0, "", 0, 0
               popmenu 2, "&Edit Item[cr]&Print list[cr]&Add Item[cr]De&lete item", 0, 0
               Unload LstBoxFrm
               LstBoxFrm.Caption = "EMIS Health"
               LstBoxFrm.lblTitle.Caption = cr & "Select replication account" & cr & "Shift-F1 or right click for menu" & cr
               LstBoxFrm.lblHead.Caption = "Description" & Space$(20) & TB & "Path"
               tot = Val(TxtD(iniFile$, "Sites", "0", "Total", found))
               For count = 1 To tot
                  tmp$ = TxtD(iniFile$, "Sites", "", Format$(count), found)
                  servers$(count) = tmp$           'description,\\server\path,filename.ext,...
                  deflines tmp$, lines$(), ",(*)", 1, NumItems
                  LstBoxFrm.LstBox.AddItem lines$(1) & TB & lines$(2) & "  "
               Next
               
               LstBoxShow
               popmenu 0, "", 0, 0
               menuopt$ = LstBoxFrm.LstBox.Tag
               
               lin = 0
               If LstBoxFrm.Tag <> "" Then
                  lin = LstBoxFrm.LstBox.ListIndex + 1   '0 to n-1 => 1 to n
               End If
               
               If lin = 0 And menuopt$ <> "3" Then Exit Do
               
               LstBoxFrm.Show 0
               LstBoxFrm.Enabled = False
   
               If menuopt$ = "3" Then                       'add item
                  tot = tot + 1
                  servers$(tot) = ""
                  lin = tot
                  menuopt$ = ""         'proceed to adding description
               End If
               
               Select Case menuopt$
                  Case "", "1"           ' Return key - edit item
                     ReDim lines$(1 To 100)
                     deflines servers$(lin), lines$(), ",(*)", 1, NumItems
                     ans1$ = lines$(1)

                     k.min = 1
                     k.Max = 30
                     InputWin "EMIS Health", "Enter description for account", ans1$, k
         
                     If Not k.escd Then
                           lines$(1) = ans1$
                           
                           ans1$ = lines$(2)
                           k.min = 1
                           k.Max = 64
                           InputWin "EMIS Health", "Enter full UNC path for " & lines$(1), ans1$, k
                           If Right$(ans1$, 1) = "\" Then ans1$ = Left$(ans1$, Len(ans1$) - 1)   'remove \
                        End If

                     If k.escd Then
                           popmessagecr "!", "Not changed"
                        Else
                           lines$(2) = ans1$
                           
                           frmoptionset 0, "Files to replicate"       'Action 0 initialises
                           values$ = ""
                           totfiles = Val(TxtD(iniFile$, "Files", "", "Total", found))
                           For i = 1 To totfiles
                              Files$(i) = TxtD(iniFile$, "Files", "", Format$(i), found)
                              frmoptionset 1, Left$(Files$(i), InStr(Files$(i), ",") - 1)
                              
                              For count = 3 To NumItems
                                 If Len(lines$(count)) Then
                                       If InStr(1, Files$(i), lines$(count), 1) Then Exit For
                                    End If
                              Next
                              values$ = values$ & Iff(count <= NumItems, "1", "0")
                           Next
                           frmoptionshow (values$), values$
                           frmoptionset 0, ""     'Unload
                           If Len(values$) Then
                                 tmp$ = lines$(1) & "," & lines$(2)
                                 For i = 1 To Len(values$)
                                    If Mid$(values$, i, 1) = "1" Then
                                          tmp$ = tmp$ & Mid$(Files$(i), InStr(Files$(i), ","))  ',filename.ext'
                                       End If
                                 Next
                                 servers$(lin) = tmp$
                                 'save back to disk
                                 WritePrivateIniFile "Sites", "Total", Format$(tot), iniFile$, success
                                 For i = 1 To tot
                                    WritePrivateIniFile "Sites", Format$(i), servers$(i), iniFile$, success
                                 Next
                                 FlushIniCache
                              Else
                                 popmessagecr "!", "Not changed"
                              End If
                        End If
                     k.escd = False
         
                  Case "2" ' F2 Print all
                     tmp$ = ""
                     tot = Val(TxtD(iniFile$, "Sites", "0", "Total", found))
                     For count = 1 To tot                                    'each \\server\path
                        ans$ = TxtD(iniFile$, "Sites", "", Format$(count), found)
                        deflines ans$, lines$(), ",(*)", 1, NumItems
                        tmp$ = tmp$ & "[Boldon]" & lines$(1) & "[Boldoff][tab]" & "Path: " & lines$(2) & "[cr]"
                        For i = 3 To NumItems                                'files start at 3rd item
                           tmp$ = tmp$ & "[tab]" & lines$(i) & "[cr]"
                        Next
                        tmp$ = tmp$ & "[cr]"
                     Next
                     replace tmp$, "\", Nul, 0  'double up the slahes as they are reserved in rtf
                     replace tmp$, Nul, "\\", 0
                     Heap 10, gPRNheapID, "InternalText", tmp$, 0
                     Heap 10, gPRNheapID, "InternalTitle", "Replication", 0
                     Heap 10, gPRNheapID, "InternalHeading", Format$(tot) & " accounts have been configured for replication" & "[cr]", 0
                     Heap 10, gPRNheapID, "InternalHeader", "", 0
                     Heap 10, gPRNheapID, "InternalFooter", "", 0
                     'ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0
                     'ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0, False  '27May11 TH Added param (F0088129)
                     ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0, False, False '04Jan17 TH Use the DB template
                  
                  Case "4" '  Delete item
                     ans$ = "N"
                     tmp$ = Trim$(LstBoxFrm.Tag)
                     replace tmp$, TB, "' ?" & cr & cr, 0
                     askwin "!Delete item", "OK to delete '" & tmp$, ans$, k
                     If ans$ = "Y" And Not k.escd Then
                           For count = lin To tot - 1
                              servers$(count) = servers$(count + 1)
                           Next
                           tot = tot - 1
                           'save back to disk
                           WritePrivateIniFile "Sites", "Total", Format$(tot), iniFile$, success
                           For i = 1 To tot
                              WritePrivateIniFile "Sites", Format$(i), servers$(i), iniFile$, success
                           Next
                           FlushIniCache
                        End If
                           
                  End Select
               LstBoxFrm.Enabled = True
               LstBoxFrm.Hide
            Loop
            Unload LstBoxFrm
      End Select
               
End Sub

Sub SelectWards(WDname$(), numofwards%, maxnum%, suppliertype%)
'suppliertype = 0 - both wards & ward lists
'             = 1 - wards only
'             = 2 - ward lists only

'03Jun97 KR  Added extra paramter to readfilenames
'03Jul97 KR  Added  Set numofwards on exiting procedure
'21Jan98 CKJ Amended the text prompts to show maxnum

Dim nw%, count%

   Screen.MousePointer = HOURGLASS
   
   readfilenames WDname$(), numofwards, suppliertype% '03Jun97 KR Added
               
   Load MultiList
   For count = 1 To numofwards
      MultiList.LstUnselected.AddItem WDname$(count)
   Next

   'multilist.LstUnselected.AddItem " New Ward"  '10Sep96 EAC New wards must be created in the supplier file now
   MultiList.Caption = "EMIS Health"                                            '21Jan98 CKJ
   If maxnum = 1 Then
      MultiList.lblLine(1) = "Select one Department or Ward"
   Else
      MultiList.lblLine(1) = "Select one or more Departments or Wards"   '21Jan98 CKJ was ONE dept
   End If
   If maxnum > 0 Then
      MultiList.lblLine(1) = MultiList.lblLine(1) & " up a maximum of" & Str$(maxnum)
   End If
   MultiList.lblLine(2) = "Press A-Z or CURSOR KEYS to move, then SPACE to select, RETURN when finished"
   'multilist.lblLine(2) = "To add or remove all, press TAB to move to the button required && press SPACE"
   MultiList.Tag = Trim$(Str$(maxnum%))                'max one line
   
   Screen.MousePointer = STDCURSOR
   HorizCentreForm MultiList

   MultiList.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   
   If Val(MultiList.Tag) = True Then  'valid
      nw = MultiList.LstSelected.ListCount
      If nw > maxnum% And maxnum% > 0 Then nw = maxnum%
      For count = 1 To nw
         WDname$(count) = MultiList.LstSelected.List(count - 1)
      Next
   Else
      nw = 0
      k.escd = True
   End If
   
   Unload MultiList
   numofwards = nw '03Jul97 KR Added
   ScreenRefresh

End Sub



''Sub XXXSupplier_Callback(index%)
'''''29Jun97 EAC changed WSDB to SupDB
''''' 4Aug97 CKJ modified mandatory fields
''''' 5Aug97 CKJ added on error round setfocus
'''''23Feb98 EAC Detect when suppliertype is changed to a "W" type supplier and set WardCode field to blank so that it will be updated uniquelly when exiting from AmendSuppliers
'''''25Feb98 EAC Added T order type for Transfer of stock, NB this mod required changes to STORES.INI
'''''17Mar98 CKJ Corrected blanking of ward code: It must not change the 29th Item, it must change
'''''            the item which has the tag = 29. This will vary with different views.
'''''18Mar98 CFY Added code to delete entries from the wardcode array when the wardcode field is set to blank.
'''''09Apr98 CFY Extra code to fill the contactname fields inf the extrasupplierdata tablewith a space.
'''''            This prevents the database causing an error on addnew. This method was taken in preference to
'''''            changing the table definition.
'''''22Jan99 TH  Added check on print picking tickets/del notes for ward Lists
'''''09Oct00 TH  Added parameter to allow differentiation of Store type suppliers
'''''21Jun01 TH  Fencepost wardcode deletion for wardtype selection (GPF experienced when using saveasnewward) (#53395)
'''''28Jan04 TH  Added check on in use to see if the supplier has outstanding reqs or to warn user to check for outstanding orders (#72056)
'''''13Mar04 TH  Mod to above and bad date msg from topup date - Could be calling msgbox while do events still modally shown, so unload doevents first
'''''16Mar04 TH  Removed mods (28Jan04,13Mar04) after discussion with CKJ - procedures called from here remain active in code, but
'''''            now should never be called until (if) this mod is reinstated.
'''''13May04 CKJ Added non-mandatory message, and used it to prompt user when changing Inuse flag
'''''24may04 ckj removed last mod. Instead use variable text next to the InUse box, taken from stores.ini [Info] 36= and 36YSE=
''''
''Const procname$ = "Supplier_Callback"
''
''Dim outdate$
''Dim SQL$, msg$, NewIndex%, tmp$, NoText%, WdNoText%, SENoText%
''''Dim tempdyn As dynaset
''Dim resumeval%, retries%, valid%, txt$, change%, i%
''Dim ptr%, sitetype$
''Dim LNoText%, temp$        '22Jan99 TH
'''Dim strSupMsg As String    '28Jan04 TH Added
''Dim RsExtraSupplierData As ADODB.Recordset
''Dim strParams As String
''Dim lngResult As Long
''Dim supnotes$
''
''   If index < 0 Then    'Shift-F1
''         ptr = Val(Ques.lblDesc(-index).Tag)
''         Select Case ptr
''               '!!**             Add lookups here (if any)
''            End Select
''
''      ElseIf index = 1000 Then                                    '12Aug97 CKJ Print
''         QuesPrintView "", "Location File :   +"
''
''      Else
''         ptr = Val(Ques.lblDesc(index).Tag)
''         txt$ = QuesGetText(index)
''         msg$ = ""
''         Select Case ptr  'Index
''            Case 0        'OK button pressed
''               For i = 1 To Val(Ques.F3D1.Tag)                    '1 to Number of controls created
''                  If Val(Ques.lblDesc(i).Tag) = 27 Then           'found the line for site type
''                        sitetype$ = UCase$(Trim$(QuesGetText(i))) 'found sitetype
''                        Exit For
''                     End If
''               Next
''
''               For i = 1 To Val(Ques.F3D1.Tag)                    '1 to Number of controls created
''                  txt$ = QuesGetText(i)
''                  tmp$ = ""
''                  NoText = (txt$ = "")
''                  WdNoText = NoText And sitetype = "W"
''                  SENoText = NoText And (sitetype = "S" Or sitetype = "E")
''                  LNoText = NoText And sitetype = "L"    '22Jan99 TH
''                  If sitetype = "L" Then temp$ = " list" '22Jan99 TH
''
''                  Select Case Val(Ques.lblDesc(i).Tag)            'reference number of line
''                     Case 1:  If NoText Then tmp$ = "You must enter a code for this site" & cr
''                     Case 2:  If NoText Then tmp$ = "Please enter the full name of this Site" & cr
''                     Case 20: If NoText Then tmp$ = "Please enter the short name of this Site" & cr
''                     Case 22: If SENoText Then tmp$ = "Please specify if the trade name is to be printed on orders for this site" & cr
''                     Case 23: If SENoText Then tmp$ = "Please specify if the NSV code is to be printed on orders for this site" & cr
''                     Case 25: If SENoText Then tmp$ = "Please enter the order output type" & cr
''                     Case 27: If NoText Then tmp$ = "Please enter the Site type for this location" & cr
''                     'Case 21: If WdNoText Then tmp$ = "Please enter the Internal Site Code for this ward" & cr '4Aug97 CKJ/EAC Now optional - defaults to own site
''                     'Case 30: If WdNoText Then tmp$ = "Please specify if Picking Tickets are to be printed for this ward" & cr
''                     'Case 31: If WdNoText Then tmp$ = "Please specify if Delivery Notes are to be printed for this ward" & cr
''                     Case 30: If WdNoText Or LNoText Then tmp$ = "Please specify if Picking Tickets are to be printed for this ward" & temp$ & cr  '22Jan99 TH
''                     Case 31: If WdNoText Or LNoText Then tmp$ = "Please specify if Delivery Notes are to be printed for this ward" & temp$ & cr   '22Jan99 TH
''                     Case 32: If WdNoText Then tmp$ = "Please specify if this ward will Receive Goods" & cr
''                     Case 33: If WdNoText Then tmp$ = "Please specify the Topup Interval for this ward" & cr  '!!** Surely not mandatory
''
''                     Case 34
''                        If sitetype = "W" And Not NoText Then
''                              parsedate txt$, outdate$, "3", valid
''                              If valid Then
''                                    QuesSetText i, outdate$
''                                 Else
''                                    BadDate
''                                    tmp$ = " "               'just to set the error flags
''                                 End If
''                           End If
''
''                     Case 35: If WdNoText Then tmp$ = "Please specify if this ward uses an ATC" & cr
''                     'Case 36: If sitetype = "E" Or sitetype = "S" Then strWarn = "Please ensure there are no outstanding Orders or Invoices for this Supplier" & cr   '13May04 CKJ 24may04 CKJ removed
''                     End Select
''
''                  If Len(tmp$) Then
''                        msg$ = msg$ & tmp$
''                        If NewIndex = 0 Then NewIndex = i
''                     End If
''               Next
''               If Len(msg$) Then Ques.Tag = ""
''
''            Case 14                                          'Amend contract details
''               'If Trim$(Ques.txtQ(27).Text) = "" Then
''               '      popmessagecr "Amend Site", "Please specify what kind of site this is."
''               '      Ques.txtQ(27).SetFocus
''               '      Exit Sub
''               '   End If
''
''               'If Trim$(Ques.txtQ(27).Text) <> "E" Then
''               '      popmessagecr "Amend Site", "Can only specify Contract Details for External Suppliers."
''               '   Else
''                     If Trim$(sup.Code) = "" Then
''                           popmessagecr "Error", "No supplier code defined."
''                        Else
''                           ContractEditor.Tag = sup.Code
''                           ContractEditor.Show 1
''                        End If
''               '   End If
''
''            Case 18                                          'Edit notes
''               change = True
''               TextEdit "Notes for Supplier '" & sup.Code & "'", supnotes$, "", change, False
''               If change Then
''                     Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
''                     If RsExtraSupplierData.RecordCount < 1 Then
''
''                        'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''                        'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''                        'blnInsert = True
''                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, sup.Code) & _
''                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, "") & _
''                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, "") & _
''                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, "") & _
''                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, " ") & _
''                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, " ") & _
''                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
''                        lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WExtraSupplierData", strParams)
''                     Else
''                        'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''                        'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''                        'tempdyn.Edit
''''                        strParams = gTransport.CreateInputParameterXML("WExtraSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
''''                                    gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''''                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
''''                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, TxtEdit(0)) & _
''''                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, TxtEdit(1)) & _
''''                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, TxtUpdDate) & _
''''                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName1)) & _
''''                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName2)) & _
''''                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
''''                        lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
''
''                        strParams = gTransport.CreateInputParameterXML("WExtraSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
''                                    gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
''                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!CurrentContractData)) & _
''                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!NewContractData)) & _
''                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, RtrimGetField(RsExtraSupplierData!DateofChange)) & _
''                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName1)) & _
''                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName2)) & _
''                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
''                        lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
''                     End If
''''                     SQL$ = "SELECT * FROM ExtraSupplierData WHERE supcode = '" & sup.Code & "';"
''''                     Set tempdyn = SupDB.CreateDynaset(SQL$) '29Jun97 EAC changed WSDB to SupDB
''''                     tempdyn.LockEdits = False
''''                     If Not tempdyn.EOF Then
''''                           tempdyn.Edit
''''                        Else
''''                           tempdyn.AddNew
''''                           tempdyn!supcode = Trim$(sup.Code)
''''                           tempdyn!ContactName1 = " "       '09Apr98 CFY Added
''''                           tempdyn!ContactName2 = " "       '09Apr98 CFY Added
''''                        End If
''''                     tempdyn!notes = supnotes$
''''                     On Error GoTo QCUpdateTableErr
''''                     tempdyn.Update
''''                     On Error GoTo 0
''''                     tempdyn.Close
''''                     Set tempdyn = Nothing
''                  End If
''               Unload Editor
''
''            Case 22, 23                                      'Trade Name & NSV code
''               If Trim$(txt$) = "" Then Ques.txtQ(index).Text = "N"
''
''            Case 25
''               Select Case txt$
''                  Case "P", "F", "E", "I", "X", "M", "T"        '25Feb98 EAC added "T" for stock Transfer
''                  Case Else
''                     'Ques.txtQ(Index).SetFocus  '@~@~
''                     popmessagecr "ERROR", "Invalid character" & cr & "Please enter P, F, E, I, X or M"
''                  End Select
''
''            Case 27
''               Select Case txt$                                  ' 4Aug97 CKJ Expanded
''                  Case "L":      SetWardSpecifics True, True, False    ' enable WardCode & ward details   '09Oct00 TH added parameter
''                  Case "W":
''                     SetWardSpecifics False, True, False   ' disable WardCode, enable ward details '09Oct00 TH added parameter
''                     'If sup.suppliertype <> "W" Then Ques.txtQ(29).Text = ""   '23Feb98 EAC Detect when suppliertype is changed to a "W" type supplier and set WardCode field to blank so that it will be updated uniquelly when exiting from AmendSuppliers
''                     'If sup.suppliertype <> "W" Then             '17Mar98 CKJ Corrected: It must not change the 29th Item, it must change the item which has the tag = 29. This will vary with different views
''                     If sup.suppliertype <> "W" And Trim$(sup.suppliertype) <> "" Then  '21Jun01 TH could be a new ward (GPF experienced when using saveasnewward)
''                           For i = 1 To Val(Ques.F3D1.Tag)       '1 to Number of controls created
''                              If Val(Ques.lblDesc(i).Tag) = 29 Then
''                                    DelWardArrayEntry QuesGetText(i) '18Mar98 CFY Added
''                                    QuesSetText i, ""            'blank the ward code
''                                    Exit For                     'quit loop
''                                 End If
''                           Next
''                        End If
''                  'Case "S", "E": SetWardSpecifics False, False   ' supplier  '09Oct00 TH Replaced
''                  Case "E": SetWardSpecifics False, False, False  ' supplier  '09Oct00 TH added parameter
''                  Case "S": SetWardSpecifics False, False, True  ' store      '09Oct00 TH added parameter
''                  Case Else
''                     'Ques.txtQ(Index).SetFocus  '@~@~
''                     popmessagecr "ERROR", "Invalid character" & cr & "Please enter W, L, S or E."
''                  End Select
''
''            Case 34
''               If Trim$(txt$) <> "" Then
''                     parsedate txt$, outdate$, "dd-mmm-yyyy", valid
''                     If valid Then
''                           QuesSetText index, outdate$
''                        Else
''                           '16Mar04 TH Removed mod after discussion with CKJ
''                           'On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
''                           'Unload frmdoevents        '   "
''                           'If Err Then               '   "
''                           '   Err = 0                '   "
''                           'End If                    '   "
''                           '16Mar04 TH ----------------------
''                           BadDate
''                           If NewIndex = 0 Then NewIndex = 34
''                        End If
''                  End If
''
''            '16Mar04 TH Removed mod after discussion with CKJ
''            '28Jan04 TH Added section
''            'Case 36 'InUse
''            '   If truefalse(txtd(dispdata$ & "\winord.ini", "", "Y", "SupplierReqCheck", 0)) Then
''            '      If Trim$(txt$) = "N" Then
''            '         'Now run checks on whether there are oustanding orders/requisitions/reconciliations
''            '         strSupMsg = SupplierOrderChecks(sup.code, sup.suppliertype)
''            '         If strSupMsg <> "" Then
''            '               'On Error Resume Next
''            '               On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
''            '               Unload frmdoevents        '   "
''            '               If Err Then               '   "
''            '                  Err = 0                '   "
''            '               End If                    '   "
''            '               popmessagecr "!WARNING", strSupMsg
''            '               On Error GoTo 0
''            '         Else
''            '            If Trim$(UCase$(sup.suppliertype)) = "E" Or Trim$(UCase$(sup.suppliertype)) = "S" Then
''            '               strSupMsg = txtd(dispdata$ & "\winord.ini", "", "Please ensure there are no outstanding Orders or Invoices for this Supplier !", "SupplierNoOrdsMsg", 0)
''            '                  'On Error Resume Next
''            '                  On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
''            '                  Unload frmdoevents        '   "
''            '                  If Err Then               '   "
''            '                     Err = 0                '   "
''            '                  End If                    '   "
''            '               popmessagecr "!WARNING", strSupMsg
''            '                  On Error GoTo 0
''            '            End If
''            '         End If
''            '      End If
''            '   End If
''            '-----------
''
''            Case 36                         'InUse Y/N                        '24may04 ckj block added
''               tmp$ = "36"                                                    'default
''               For i = 1 To Val(Ques.F3D1.Tag)                                '1 to Number of controls created
''                  If Val(Ques.lblDesc(i).Tag) = 27 Then                       'found the line for site type
''                        Select Case UCase$(Trim$(QuesGetText(i)))             'found sitetype
''                           Case "E", "S"
''                              If txt$ <> "Y" Then                             'External type supplier, set Not in use
''                                    tmp$ = "36YSE"                            'warning message
''                                 End If
''                           End Select
''                        Exit For
''                     End If
''               Next
''               Ques.lblInfo(index).Caption = TxtD(dispdata$ & "\stores.ini", "Info", "Y/N", tmp$, 0)
''
''            End Select
''
''         If Trim$(msg$) <> "" Then
''               popmessagecr "!Information missing", msg$
''               On Error Resume Next                              '5Aug97 CKJ Added
''               Ques.txtQ(NewIndex).SetFocus
''               On Error GoTo 0
''            End If
''      End If
''
''Exit Sub
''
''QCUpdateTableErr:
''   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)        '!!**
''   Select Case resumeval
''      Case -1: Resume
''      Case 0:  Resume Next
''      ''Case 1:  Close: End      '@~@~ was TerminateApp                                                     '!!**
''      '23Jun05 TH No Ends allowed !! Need to handle this properly
''      End Select
''
''End Sub

Function UniqueCode(Code$) As Integer
'06Feb98 CFY Added

Dim i%, Unique%

   Unique = True
   For i = 1 To WardCount
      If Trim$(WardCodes(i)) = Trim$(Code$) Then
         Unique = False
         Exit For
      End If
   Next

   If Unique Then
      WardCount = WardCount + 1
      ReDim Preserve WardCodes(WardCount)
      WardCodes(WardCount) = Code$
   End If

   UniqueCode = Unique

End Function

''Function UpdateSupplierIndexes(codewas$, suppliertypewas$, wardcodewas$, inusewas$, codenow$, suppliertypenow$, wardcodenow$, inusenow$, Vector&) As Integer
'''10sep99 CKJ Written. Single routine to update both supplier indexes
'''            Returns success True/False
''
''Dim sWas As String
''Dim sNow As String
''Dim iSuccess As Integer
''Dim sTitle As String
''Dim sText As String
''Dim iFailed As Integer
''Dim sInUseWas As String
''Dim sInUseNow As String
''
''   sWas = UCase$(Trim$(codewas$))
''   sNow = UCase$(Trim$(codenow$))
''   sInUseWas = UCase$(inusewas$)
''   If sInUseWas <> "Y" Then sInUseWas = "N"
''   sInUseNow = UCase$(inusenow$)
''   If sInUseNow <> "Y" Then sInUseNow = "N"
''
''   iSuccess = True
''   sTitle = ".Supplier Index Update Failed"
''   sText = crlf & "Supplier index may no longer be accurate - please reindex now"
''
''   Do      ' amend original supplier index
''      Updateindex sWas, sNow, Vector&, dispdata$ & "\supfile.idx", iFailed
''      If iFailed = -1 Then popmessagecr sTitle, "(Code 1)" & sText
''   Loop While iFailed = 1         ' index locked
''   If iFailed Then iSuccess = False
''
''   'CCCCCT#WWWWUnnnnnn     supplier sup.code, sup.suppliertype, costcentre sup.wardcode, #, sup.inuse
''   'The '#' character is used to allow a search to distinguish between similar codes, e.g. Ward code "ABCD" and supplier code "ABCD "
''   sWas = UCase$(pad$(codewas$, 5) & pad$(suppliertypewas$, 1) & "#" & pad$(wardcodewas$, 4) & sInUseWas)
''   sNow = UCase$(pad$(codenow$, 5) & pad$(suppliertypenow$, 1) & "#" & pad$(wardcodenow$, 4) & sInUseNow)
''
''   Do      ' amend new supplier index
''      Updateindex sWas, sNow, Vector&, dispdata$ & "\supfiles.idx", iFailed
''      If iFailed = -1 Then popmessagecr sTitle, "(Code 2a)" & sText
''   Loop While iFailed = 1         ' index locked
''   If iFailed Then iSuccess = False
''
''   'Entries created for suppliers where 'WWWW' is not four spaces.
''   '#WWWWTCCCCCUnnnnnn     costcentre sup.wardcode, #, sup.suppliertype, supplier sup.code, sup.inuse
''   'The '#' character is used to allow a search to distinguish between similar codes, e.g. Ward code "ABCD" and supplier code "ABCD "
''   sWas = "#" & UCase$(pad$(wardcodewas$, 4) & pad$(suppliertypewas$, 1) & pad$(codewas$, 5) & sInUseWas)
''   sNow = "#" & UCase$(pad$(wardcodenow$, 4) & pad$(suppliertypenow$, 1) & pad$(codenow$, 5) & sInUseNow)
''   If Trim$(wardcodewas$) = "" Then sWas = ""      'only use if the sup.wardcode is present
''   If Trim$(wardcodenow$) = "" Then sNow = ""      '                 "
''
''   If Trim$(sNow) <> "" Or Trim$(sWas) <> "" Then
''         Do      ' amend new supplier index
''            Updateindex sWas, sNow, Vector&, dispdata$ & "\supfiles.idx", iFailed
''            If iFailed = -1 Then popmessagecr sTitle, "(Code 2b)" & sText
''         Loop While iFailed = 1         ' index locked
''         If iFailed Then iSuccess = False
''      End If
''
''   UpdateSupplierIndexes = iSuccess
''
''End Function

Sub WardInputWin(title$, prompt$, ans$, k As kbdcontrol, ShiftF1Use$)
'13Aug96 CKJ Added timeout
'18Sep96 CKJ added k.escd=false
'22Oct95 CKJ Added k.timd=false
'23Dec97 EAC set max and min characters for input box
'05Mar98 ASC Now unloads text window
'20Jan99 CFY Moved routine from wslist.bas

   frmEnhTxtWin.Tag = ShiftF1Use$
   frmEnhTxtWin.Caption = title$
   frmEnhTxtWin.lblbox.Caption = prompt$
   frmEnhTxtWin.txtBox = ans$
   frmEnhTxtWin.txtBox.SelStart = 0
   frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
   If k.passwrd Then frmEnhTxtWin.txtBox.PasswordChar = "*" '19Dec96 CKJ
   gTimedOut = False
   k.timd = False
   k.min = 1
   k.Max = Len(sup.Code)
   LSet gk = k
   gk.exitval = 27
   HorizCentreForm frmEnhTxtWin
   If gk.timeout Then TimeoutOn frmEnhTxtWin.Timer1

   frmEnhTxtWin.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form       'modal
   
   ans$ = UCase$(frmEnhTxtWin.txtBox)
   
   'gk.timd = k.timd      'timeout uses 'normal' k   7Mar97 CKJ Removed
   k = gk
   k.escd = False
   k.timd = gTimedOut
   If k.timd Then k.exitval = 27
   If k.exitval = 27 Then k.escd = True
   k.validchars = nulls
   k.Max = Len(sup.Code)  ' max will default to available space (currently preset to 78)
   k.min = 0              ' no minimum as standard
   k.esc = True           ' allow escape
   k.nums = False         ' default is whole character set
   k.decimals = False     '    "
   k.timeout = True       ' reset to standard timeout
   k.norefresh = False
   k.date = False
   frmEnhTxtWin.txtBox.PasswordChar = "" '19Dec96 CKJ
   k.passwrd = False
   Unload frmEnhTxtWin

' Q4INPUT.BAS:inputline     Other bits to think about ...
'    k.wipedef = False    ' don't wipe default next time
'    ans = RTrim$(ans)    ' the string at time of exit (or empty if escd?   !!**)
'    k.nobrackets = False ' brackets normally used
'    k.updown = False     ' may be used if k.allexits not wanted
'    k.overwrite = False  ' insert is the default
'    k.ret = False        ' return alone not allowed
'    k.delline = False    ' Set to false on leaving to disable delline function
'    k.anykey = false

End Sub

Function GetSupplierExtraDetailsSQL(ByVal strSupplierCode As String) As ADODB.Recordset
'26Jul04 TH Written as useful wrapper
Dim strParams As String
''Dim objDataAccess As clsDataAccess
Dim rsResult As ADODB.Recordset
Dim blnOK As Boolean

   Set rsResult = New ADODB.Recordset
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strSupplierCode)
   Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWExtraSupplierDatabySupcode", strParams)
   
      
   Set GetSupplierExtraDetailsSQL = rsResult
   ''rsResult.Close
   ''Set rsResult = Nothing

End Function
Function RestrictedView()
'15Sep00 Added stub function
   RestrictedView = False
End Function
Function IsAlternativeSupplier(ByVal strNSVCode As String, ByVal strSupCode As String) As Boolean
Dim strParams As String
Dim intReturn As Integer

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
               gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strSupCode)
   intReturn = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWSupplierProfileForIsAlternativeSupplier", strParams)
   If intReturn > 0 Then
      IsAlternativeSupplier = True
   Else
      IsAlternativeSupplier = False
   End If

End Function
Public Function GetAltenativeSupplierString(ByVal strNSVCode As String) As String
Dim strParams As String
Dim rsAltsups As ADODB.Recordset
Dim strOutput As String

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
   Set rsAltsups = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierProfilebyNSVCodeForAltSups", strParams)
   If rsAltsups.RecordCount > 0 Then
      Do While Not rsAltsups.EOF
         strOutput = strOutput & RtrimGetField(rsAltsups!supcode) & ","
         rsAltsups.MoveNext
      Loop
   End If
   rsAltsups.Close
   Set rsAltsups = Nothing
   If Len(strOutput) > 0 Then strOutput = Left$(strOutput, Len(strOutput) - 1)
   GetAltenativeSupplierString = strOutput
   
End Function

Public Function GetProductSupplierString(ByVal strNSVCode As String) As String
'09Oct06 TH Written
Dim strParams As String
Dim rsSups As ADODB.Recordset
Dim strOutput As String

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
   Set rsSups = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplierProfilebyNSVCode", strParams)
   If rsSups.RecordCount > 0 Then
      Do While Not rsSups.EOF
         strOutput = strOutput & RtrimGetField(rsSups!supcode) & ","
         rsSups.MoveNext
      Loop
   End If
   rsSups.Close
   Set rsSups = Nothing
   If Len(strOutput) > 0 Then strOutput = Left$(strOutput, Len(strOutput) - 1)
   GetProductSupplierString = strOutput
   
End Function


' Returns number of characters to use for the ward codes
' Will be 4 or 5 characters depending on setting
' Category: D|stores
' Section:  Settings
' Key:          Use5CharWarcCode
'
' 19May10 XN  F0051906 Created
Function GetWardCodeLen() As Integer
                On Error GoTo WardCodeLen_Err
                
        If TrueFalse(TxtD(dispdata$ & "\stores.ini", "settings", "0", "Use5CharWardCode", 0)) Then
                GetWardCodeLen = 5
        Else
                GetWardCodeLen = 4
        End If
        
Exit Function

WardCodeLen_Err:
        GetWardCodeLen = 4
End Function
Sub getsupplierwardlist(ByVal supcode As String, _
                ByVal Find As Long, _
                FoundSup As Long, _
                ByRef suplocal As supplierstruct _
               )

'29Jan15 TH Written as now we need to get lists independently as wards and lists coexist in the new WSupplier view and can produce duplicates


Dim rsSupplier    As ADODB.Recordset
Dim strParameters As String

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetSupplier"

   On Error GoTo ErrorHandler

   FoundSup = 0
   clearsup suplocal
   supcode = trimz$(supcode)
   
   If Find < 0 Then
      Err.Raise 65535, "getsupplierwardlist", "Attempted to load ward Stock List " & Format$(Find)
   Else
      If Find > 0 Then
         strParameters = gTransport.CreateInputParameterXML("WSupplierID", trnDataTypeint, 1, Find)
         Set rsSupplier = gTransport.ExecuteSelectSP(g_SessionID, "pWWardProductListasSupplierbyID", strParameters)
      ElseIf Find = 0 And Len(supcode) > 0 Then
         strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                         gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, Len(sup.Code), supcode)
         Set rsSupplier = gTransport.ExecuteSelectSP(g_SessionID, "pWWardProductListasSupplierByCode", strParameters)
         
      End If
      
      If Not rsSupplier Is Nothing Then
         If Not rsSupplier.EOF Then
            suplocal = FillSupFromRS(rsSupplier)
            FoundSup = suplocal.SupplierID
         End If
      End If
   End If

Cleanup:
   On Error Resume Next
   Set rsSupplier = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   'ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Sub

'Gets if the ward stock list requires printing a delivery note
'16Aug16 XN 160233
'16Apr17 TH Reinstated check against delnote setting when not from ward list (TFS 181524)
Function IfRequiresDeliveryNote(ByVal wwproductListLineID As Long, ByRef sup As supplierstruct) As Boolean
    Dim strParameters As String

    Const ErrSource As String = "IfPrintDeliveryNote"

    On Error GoTo ErrorHandler

    If wwproductListLineID > 0 Then
        strParameters = gTransport.CreateInputParameterXML("WWardProductlistLineID", trnDataTypeint, 4, wwproductListLineID)
        IfRequiresDeliveryNote = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetIfRequiresDeliveryNoteByWWardProductListLineID", strParameters)
    Else
        'IfRequiresDeliveryNote = False
        'we need to work out the setting of the ward here (TFS 181524)
        If sup.PrintDeliveryNote = "Y" Then
            IfRequiresDeliveryNote = True
        Else
            IfRequiresDeliveryNote = False
        End If
    End If

    Exit Function

ErrorHandler:
    If Err.Number Then Err.Raise Err.Number, ErrSource, Err.Description
End Function

'Gets if the ward stock list requires printing a delivery note
'16Aug16 XN 160233
Function IfRequiresDeliveryNoteByWardCodeNSVCodeAndSite(ByVal wardcode As String, ByVal NSVCode As String) As Boolean
    Dim strParameters As String

    Const ErrSource As String = "IfPrintDeliveryNote"

    On Error GoTo ErrorHandler

    strParameters = gTransport.CreateInputParameterXML("WardCode", trnDataTypeVarChar, Len(wardcode), wardcode)
    strParameters = strParameters + gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, Len(NSVCode), NSVCode)
    strParameters = strParameters + gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
    IfRequiresDeliveryNoteByWardCodeNSVCodeAndSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetIfRequiresDeliveryNoteByWardCodeNSVCodeAndSite", strParameters)

    Exit Function

ErrorHandler:
    If Err.Number Then Err.Raise Err.Number, ErrSource, Err.Description
End Function
