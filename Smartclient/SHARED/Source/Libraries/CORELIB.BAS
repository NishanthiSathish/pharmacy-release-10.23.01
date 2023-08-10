Attribute VB_Name = "CORELIB"
'-----------------------------------------------------------------------------
'
'                     Disk File Handling Library
'
' V1.0 CKJ 12 Apr 89
' 3Feb91 CKJ ** Library ONLY usable under PDS7 - supports V5.x program suite **
'-----------------------------------------------------------------------------
'modification history
'25Sep89 CKJ General purpose password handling routines written.
'            They allow encryption & storage of almost any length of string,
'            the string will be of double length when written to disk.
'14Jul90 ASC Added program locking lockprog and unlockprog which write and
'            delete a file of the name passed. Also lockcheck which warns the
'            user if the programme is locked and locks it if it isn't. This
'            system only works on terminals with a drive c:
'13Aug90 CKJ New facilities added - all based on DOS interupts
'            including drive/path handling & a new filexists()
'            Supports suite V4.2
'18Aug90 CKJ readseqfile uses readseqfilerr()
'24Sep90 ASC Record locking procs now written
'
'           -getrecord...Tests for lock then takes a sructure (r) with one
'            element (record) from a file filename$ at record number f%
'            and channel rchan% , then locks record f
'
'           -putrecord...Unlocks record f and saves it as above
'
'           -unlockrecord...unlocks record f
'
'           -viewrecord-gets the record without locking it
' 3Feb91 CKJ PDS7 forces the use of Far strings, so use of SADD amended.
'            CURDIR$ now used in getpath
'            *** WARNING: Library ONLY usable under PDS7 now ***
'21Feb91 CKJ Get/PutRecord(NL) (Un)LockRecord - rewritten
'            Err70msg moved from subpatme, and extended to err 63 as well
'23Feb91 CKJ & ASC Unused(?) old procedures deleted
'24Feb91 CKJ OpenRandomFile moved in from Tpnsubs
'14Apr91 CKJ FlushBuffers written & added to PutRecord
' 7Aug91 CKJ OpenRandomFilePtr written to cope with creating new files
'             ** Please see caveats in the proc comments **
'            All pointers to records now of type LONG integer (RecNo&)
'            GetPointer moved here from Subpatme
'            Get/PutRecord now called Get/PutRecordL
'26Oct91 CKJ OpenRandomFile - added Access Read Write
'            Removed Drugs.Inc
'            Proc Printeron now called PrinteronX, ready for excision.
' 4Apr92 CKJ Mod to fileexists, added WriteLog
' 8Apr92 CKJ Firefighting - why does fileexists seem to miss seeing Translog?
'09Jun92 ASC File fileexists is looking for added to error screen
'18Jun92 ASC Getpointer 4 and 5 added for locking and unlocking
'24Jun92 ASC fileexists now retries 30 time every 9 ticks if error 57
'            and writes results to writelog
'17Aug92 CKJ fileexists - corrected error
'            writelog - changed default file to error.log
'11Oct93 CKJ NoExp moved from Q4ANSI
'21Dec93 CKJ GetPointer inc=3 now returns current pointer value
'24Mar94 CKJ Copy does not now shell, removed PrinteronX
'            Removed readpassw & writepassw
'23Feb96 CKJ et al GetPointer: Corrected Lock range, removed increment 3/4
'            ErrHandler does not resume on Err 76
'20Mar96 CKJ Added Replace
' 2Apr96 CKJ GetField written
'            Added STDCURSOR & HOURGLASS constants
'04Apr96 KR  Added Automation$
'09Apr96 CKJ Fileexists: Trapped error 76, path not found
'            DirExists:  Now works under Windows
'03jul96 KR  Removed Acquirelock from Readsiteinfo.  Now found in ident form
'            should be in any other windows entry point.
'05Jul96 KR  Moved Plural$ from Wdatetim.bas
'31Aug96 CKJ Added TrueFalse%()
' 3Sep96 CKJ Added Global UserFullName, set automatically in Security
'            Merged Eddies changes of 21Aug96 - Shell starts Print under 3.11
'04Sep96 EAC Added global constants needed in Stock Control Program
'12Sep96 CKJ ParseCtrlChars: Mod to trap text ending with an unmatched openbrace
'            Added function IsDigits%(txt$) - checks for digits 0-9 only
'            Added k.date & k.norefresh to kbdcontrol
'            Added WindowsVersion() and DosVersion()
'17Sep96 CKJ Added declare for SendMessage
'20Sep96 CKJ Added ShowAboutBox Me, copyright$
'25Sep96 CKJ More Consts
'28Sep96 CKJ Const TB = tab char
'05Oct96 CKJ Replace now halts once length is satisfactory
'16Oct96 CKJ Added Help and help related procedures, plus constants for WinHelp
'            Changed k.helpnum to Long from Integer
'29Oct96 KR  Changed ShowAboutBox to use a standard AboutBox form not API call.
'30Nov96 CKJ Added sound from Technet article Q71102
' 3Dec96 CKJ Digits$() written: Takes a string & returns only digits 0-9
' 9Dec96 CKJ Makecommand: Merged changes from DOS version - should allow lower
'            network traffic on calling dos prog from windows.
'13Dec96 CKJ FileExists: Changed ASCROOT$ to rootpath$
'16Dec96 CKJ GetKeyLock and SetKeyLock written - use for CAP/NUM/SCROLL lock.
'            Fileexists: Changed the warning box to have retry & cancel buttons
'            LX: written - provides licence interface
'            Removed ConfirmX, Colour, PrintBar, PrintCentred
'17Dec96 CKJ Moved GetTextFile and PutTextFile from HighASC.bas
'            Flx: also ready for testing
'            HelpSearch: Corrected - now starts at top of list
'19Dec96 EAC FileExists: Changed log file to write to \TRANSLOG
'??Dec96 ASC Moved ShellSort from own bas file & added sort by column
' 2Jan97 CKJ Changed above to sort by column, not column+1 as before
'            This means that column=0 and column=1 do the same thing -
'              they now sort the whole string
'            Also, if column exceeds the string length it does not now crash.
' 7Jan97 CKJ SetKeyState: Corrected - values were wrong
'            Cosmetic change: VK_CAPITALS to VK_CAPITAL in a comment only
'            Pad: Changed + to &
'14Jan97 CKJ/EAC Makecommand: added "/W", removed Loader
'17Jan97 CKJ Makecommand: Merged change from S: (7.51 release) 16Jan97 EAC/CKJ removed ASCVDISK
'07Feb97 EAC Add plurals for Australia
'05Mar97 KR  Removed module-level declares Files()  & srch() as declared statically in Txtd
'05Mar97 CKJ Acquirelock: Correction made
' 7Mar97 CKJ SoundTimeOut: Added for the timing out 'blip' noise
'10Mar97 CKJ Added lf$ = Chr$(10)
'09May97 CKJ Proc to Undo (and Redo), Cut, Copy, Paste and Delete selected text in textboxes
'11May97 CKJ Moved IFF() from TPNW
'12May97 CKJ Moved IsIniValid, ValidateIni from StkMaint
'            Fileexists: user$ -> UserID$, site% -> 0 since neither were in scope
'            Changed + to & in string exprs
'            Option Explicit enabled - revealed that SitePaths & SlowTwinkle are NOT in scope
'15May97 CKJ Added Global StopEvents
'            Amended Sound handling
'            GetYesOrNocr removed
'29May97 CKJ Replace: Splice new text into existing string
'30May97 CKJ Money: Writing commenced, use for test & experimentation
'30May97 CKJ YesNo: Moved from TPN/StkMaint
'04Jun97 EAC TxtD: moved arrays to module level to facilitate flushing
'            Wrote FlushIniCache
'27Jun97 CKJ Money$(): Corrected default values
'12Jul97 CKJ Money$(): Changed £.p to £.pp
'            PatternMatch written
' 5Aug97 CKJ Added KEY_INSERT & KEY_DELETE
'18Aug97 CKJ Money$(): Corrected file name by removing spurious path
'18Sep97 CKJ DoSaferEvents written as wrapper for \libfiles\frmDoEvents.
'            Note that this form must now be added to all projects.
'12Oct97 CKJ PopMsg: Now uses MessageBox instead of MsgBox
'16Oct97 CKJ ReadSiteInfo: Added the command line option to set default disk drive
'             Also removed static array & dim'd it dynamically
'24Oct97 CKJ FreeSpace & diskbytseclust now use long integers
'            YesNo$(): now takes variant value, but must only be given numeric data types
'26Oct97 CKJ ShowAboutBox: Now recursion safe. Use icon from given form once more as all
'            forms must have an icon specified.
'28Oct97 CKJ ReadSiteInfo: Corrected command line drive mod when no drive letter is present.
'            Removed global KEY_B after a Txt scan of V: showed it is not used.
'            SingleUserOnly% now global
'15Dec97 CKJ moved MsgBox return values from report.bas
' 8Jan98 CKJ Added support for total memory checking
'12Jan98 CKJ ASCTerminalName written. This retrieves the terminal name from c:\ascterm.ini
'            If no name exists it allocates one, writes the file & adds an entry to Terminal.ini
'14Jan98 CKJ Heap Manager released for alpha test
'            NB Project now requires frmHeap.frm to be added
'19Jan98 CKJ ParseItems written - uses the Heap manager to store items for parsing.
'            SetupPRNheap allocates and destroys the global printing heap gPRNheapID
'24Jan98 CKJ Heap: Added actions 20 & 21
'26Jan98 CKJ Popmessagecr: old bold/inverse settings convert automatically to icons
'16Feb98 CKJ Added ASC_ICONSAMPLE = 8 for box shaped icon
'            Popmessagecr: Do not remove !n!b!i!f, but allow !xxxx through
'             Select the box icon with "~" in the title
'17Feb98 CKJ Popmessagecr: Remove !n!i and !n!b if found
'23Feb98 CKJ Corrected last mod
'05Mar98 CFY New parameter ColSep added. Used to denote if a particular character
'            should be used to identify columns. If left blank then the procedure
'            behaves as it used to.
'11Mar98 CKJ GetTextFile corrected; close chan if file is too large to read
'            - avoids File Already Open error
'24Mar98 CKJ ValidateIni, IsIniValid: FileDateTime returns the long date as configured for
'            individual terminal. Coerce date to defined format before use.
'29Apr98 CKJ Heap: Found that each entry accepts up to 32K of data, but keeps first 1K only.
'            Amended to allow linked list storage, using suffix to the item key.
'            This is transparent in use and does not affect existing code.
'            Limit now of ~16000 entries of 1K, more with smaller data items.
'18May98 CKJ Moved function TheDate from Orderlib
'03Jul98 CKJ IsIniValid: FileDateTime returns the time modified by Summer Time
'            ie a file saved at 16:29:50 may now have its time returned as 15:29:50 or 17:29:50
'            Until proven otherwise, assume that time zones may be similarly affected,
'            therefore consider a file to be valid if the minutes, seconds and file size
'            are identical, and the date and time differ by no more than 14 whole hours.
'14Jul98 CKJ Corelib: ReadLanguage written
'16Jul98 CKJ Heap: Corrected bug in action 11 - items not found in heap were returned as blank
'29Jul98 CKJ Direxists: Corrected. err 76 'path not found' returned direxists()=True
'            Now preserves mousepointer shape through the call
'            Now accepts optional trailing backslash (previously failed with "path\")
'04Aug98 CKJ Replace: merged 10Jul98 mod. If length is negative then replace using
'            case insensitive comparison If the replace is not dependent on length then
'            just use True for ignore case & False for the normal case specific replace
'06Aug98 CKJ Patternmatch: Added extra options;
'             *   matches any character, including space at that position
'             X   matches upper & lower case A to Z plus 0 to 9
'             .   matches a decimal point only
'             0   matches 0 to 9 and/or decimal point
'            If Pattern$ = "" then all characters and lengths are unconditionally valid
'20Aug98 TH  ASCTerminalName: trim myterminal$  if over 15 chars
'17Sep98 CKJ ASCTerminalName: removed the '-' from TERM-XYZA as some DBs are 8 chars wide only
'21Sep98 CKJ Added LB_ADDSTRING and WM_SETREDRAW
'            Heap actions 22, 23, 24 added and binary search implemented
'25Sep98 CKJ Heap: Removed actions 22, 23, 24: list().hwnd should remain encapsulated,
'            and inhibiting redraw does not improve speed.
'            Binary search rewritten to handle all access to the now unsorted lists, since the
'            sort order is not in ASCII order. Internal separator char changed from ascii 127->1
'25Sep98 CKJ ParseItems: preserve cursor across inputwin
'14Oct98 CKJ Added two EM_ message consts
'19Jan99 CFY SingleUserMode Written
'19Jan99 CFY HandleSingleUser Written
'12Mar99 CKJ IsINIvalid: Corrected logical error. GMT/BST section assumed that the
'            path/filename were not part of the validation, therefore used absolute positions.
'            Added parameter Tampered%, set True if validation string is present and incorrect.
'            ValidateINI: added Tamper
'            TxtD: Added Tamper check on INI files. No msg on files which have no validation though
'31Mar99 CKJ "DisableINIcheck" temporary measure for 8.1 release
'31Mar99 CFY Merged from drive w: 04Feb99 CFY PatternMatch: Added extra option:
'             B   matches any alphabetic character upper & lower case plus space
'24May99 CKJ Makecomand: This procedure now takes no action
'            AppPathNoSlash written; returns App.Path without trailing '\'
'            Removed Global ProgsDrv$
'26May99 CFY HandleSingleUser: Whoops! Was previously incrementing the translog pointer in the local translog file by 1
'            when recording the record number of the next transaction in the asc_back.ini file.
'19Jul99 AE  Heap:Action 11: moved "success = true" to make procedure work as described
'19Jul99 AE  SigFigs:Written
'19Jul99 AE  DecPl:Written
'19Jul99 AE  StrSigFigs:Written
'19Jul99 AE  StrDecPl:Written
'19Jul99 AE  ExpandExp:Written
'19Jul99 AE  RoundAt:Written
'02Sep99 AE  FillHeapStandardInfo: Written
'02Sep99 AE  AppendToRTF: Written
'06Sep99 CKJ CheckCharacter: Written, initially for Australian UMRN codes
'            HexString: written. Returns a hexdump of any string passed
'            TrackOpenedFiles, ListOpenedFiles: written. Build list of associations between file names and channels
'            AcquireLock: LockType 100 defined. returns debug info in the 'pathfile$' parameter
'            AcquireLock, OpenRandomFile: added calls to TrackOpenedFiles
'17Sep99 AE  ScanCodesDB: Written for use with diagnosis codes / presenting complaint codes
'27Oct99 AE  TxtH: Written.  Ready to replace TxtD, uses Heap as a cache and caches misses as well as hits
'                 for improved performance.
'28Oct99 CKJ Completed changes to TxtH for testing. TxtD now gets diverted to TxtH
'            Heap: Corrected action 1 - do not blank heap name.
'             Extended action 20 - return '|' separated list of heap IDs in Value$
'             and '|' separated list of Heap descriptions in Entry$
'02Dec99 SF  PatternMatch: if last char in string to PatternMatch a space then don't trim
'06Dec99 CFY HandleSinlgeUser: Changed method which decides if the pointers need to be written. Now uses a flag as an indicator.
'08Dec99 CFY HandleSingleUser: Now writes NEXT transaction and rxnumber to the ini file as this is what the merge program is expecting to see.
'10Jan00 AE  TxtH1: Defunct development procedure, removed completely.
'            KineticsMsg:Written
'25Jan00 AE  Added module-level variable sLivePath for new overnight job
'            ONJLivePath:  Written to return value of above
'            SetONJLivePath: Written to set value of above
'01Feb00 AE  DirExistsNoMSg: Written to provide functionality of DirExists without the
'            screen messages, which were causing some overnight jobs to fail.
'01Feb00 AE  Fileexists:Added Check for Overnight Job, to point to the correct drive. Will
'            Not affect the normal running of this procedure, as ONJLivePath will not be
'            set except in the overnight job.
'01Mar00 TH  SingleUserMode: Check for Citrix to correctly display whether single user or not
'03Mar00 TH  SingleUserMode: Change to above mod
'05Apr00 AE  ShowAboutBox:Added ASCRelease
'26May00 AE  Moved definition of DB_Lang_General into corelib.bas so as it's always available.
'            SQLSafe: Written. Replace ' with '' to avoiod parsing problems, use whenever building
'            an sql query using a variable which may contain a single '
'02Jun00 AE  Added definition of LB_GetItemHeight
'02Jun00 AE  UserPrefs: Written as a simple wrapper to allow saving of settings under a given
'            user in a given ini file.
'21Jun00 JN  Cludge added to store previous user's ID, AccessLevel and FullName before entering Teamwork,
'            So that on leaving Teamwork, previous log-in details can be substituted back.
'22Jun00 AW  Handlesingleuser: Checks to see if translog exists, if not increments pointer.
'26Jun00 AE  Corrected above mod.  If translog is not found, a new one is created with a pointer of 1.
'            Otherwise, the pointer is read, NOT incremented, and the NEXT transaction number written to
'            ASC_back.ini
'29Jun00 SF  Handlesingleuser: changed the section where some of the data is written to so that it corresponds
'            with the Single User Merge utility.
'10Jul00 AE  Further refinement of mod 26Jun00 AE to account for possible update problems
'19Sep00 AE  GetiniHeapID: Added for WA Label Debugging
'14Nov00 CKJ GetCountry: Added system-wide setting for country
'             Previously this had to be set on each PC either as an environment variable in Autoexec.bat or similar
'             eg SET Country="061"  or as the regional settings in control panel
'             Now, you may add the following line to Siteinfo.ini default section
'             Country="061"
'             This is tested in sequence: Autoexec.bat if present, Siteinfo.ini if present, otherwise use regional settings
'            ReadPrivateIniFile: Removed call to GetPrivateProfileString() as this can be unreliable over a poorly performing network.
'             Replaced with a call to txtd() which does not use the API and which caches all data found.
'             WARNING: The new version DOES NOT read WIN.INI style system settings from the NT registry,
'             nor does it return a whole INI file section if the IniEntry is null.
'             Also it caches everything, so call FlushIniCache explicitly if any INI file is written to.
'            SiteInfo: Moved the crude 'End' code from the ini file handler to here
'            TxtD: Use new style lookup and cache, unless command line includes /OLDINICACHE
'             Cache whole file without using the API call
'             This is designed to improve reliability & reduce network traffic
'             Once a new file has been encountered, read the entire file in one pass
'             See procedure header for full details, usage and cautions
'            IniCache written
'            AddFileToCache written
'            WritePrivateIniFile: Added FlushIniCache
'22Nov00 CKJ AddFileToCache: In Report.exe and Overnite.exe, ReadSiteInfo was not called until well into the program,
'             so pseudo-constants were not set causing an infinite loop since crlf = ""
'             Added trap for this, just in case it happens on another project.
'            Heap: added heap size calculation, displayed on debug window caption
'24Nov00 CKJ Renamed TxtH() to TxtHeap() and made it a private function. DO NOT CALL TxtHeap() DIRECTLY.
'            TxtH() is now a wrapper to TxtD(), the latter being the only function which should ever have been used,
'            unfortunately many calls have been written directly to TxtH(). So to avoid a lot of editing, TxtH() is
'            being preserved for historical use only. Please do not write any more new calls to TxtH().
'09Feb01 CKJ ExpandExp: Corrected handling of non-Boolean values, "D" type exponents, undefined exit value and simplified logic  (#49273)
'22Nov01 CKJ/TH GetPointer: Logical flaw found - error 63 (Bad record number) could escape the
'                trapping and proceed into reading without achieving a lock
'                Corrected and added logging
'            SoundBeepOnly(): Added. Terminal.ini SoundBeepOnly="T" 'Y/N/T/F/1/0/-1' default is N
'14Jan02 TH  Shellsort:Removed Static from sub definition. This was causing problems because ColumnIn wasnt being correctly
'    "       initialised and was sometimes staying in memory incorrectly in subsequent sorts (#40814)
'20Feb02 TH  RoundAt: Change rounding on strings with first char point (".") to stop insertion of zero (#56463)
'29Apr02 CKJ Added extended message to error handlers. Affects most procedures in Corelib, but retains
'            compatible interface to other modules. Search on '29Apr02' for areas modified.
'30Apr02 CKJ Heap: Added action 13 which provides a findfirst/findnext capability. Returns next item
'            after the entry supplied, or the very first item if entry="". Repeat while success=T
'14May02 CKJ Copy: Added TrackOpenedFiles
'20May02 CKJ FileExists: Major changes to the logic, including retries from most error types
'             Changed to fixed test from .044 file, as file may not be available during error
'             Added logging & modified displayed message extensively
'01Nov02 CKJ IsIniValid: Corrected list of months used by the DateDiff section
'10Feb03 CKJ GetPointer: Added selective logging of successful read/increment/decrement/write calls
'12Feb03 TH  Moved PadVar function to here from Patbill.Bas to avoid referencing problems
'31Jan03 TH  (PBSv4) Extended k.validchars from 10 chars to 11
'31Jan03 TH  (PBSv4) MERGED
'22sep03 CKJ changed ASCver to ASCver()
'30Mar04 CKJ {SP1}
'            Removed obsolete procs DFHLcrash, GetKeyLock, getpath, HelpKey, HelpQuit, InvalidIni, ScanCodesDB,
'            SetFileHandles, InfoBar, popfreemem
'            Consider removing old TXTx handlers, IPX printing support for {SP2}
'            Also noted that FileNameFromChannel doesn't.
'19Apr04 TH  ParseItems: If user cancels on free text dont set a global cancel, just dont do the freetext !(#72640)
'19Apr04 TH  ParseStdDataItems: If user cancels on freetext input, just cancel the input, dont set cancel flag as this
'                               has repercusions elsewhere. (#72640)
'07may04 CKJ AddFileToCache: Out of string space. Solution is to reduce buffer size using 54K less space.
'16May04 TH  ParseItems: ,ParseStdDataItems: Mod to above (#72640) after second check - now revert to previous value, dont assume k.escd was true !
'19May04 CKJ Heap: Added action 14 which returns the last code and entry from a heap
'27May04 CKJ FileNameFromChannel: Corrected
'            GetTextFile: Added TrackOpenedFiles
'04jun04 ckj 32bit
'            !!** No sound, beep only
'
'17Jul08 CKJ Encrypt, Decrypt: CAPI derived from MSDN example
'12Aug08 CKJ ParseCommandURLToken: written
'12Nov08 CKJ ParseURLToken: Added filter for problematic integrated security connection param  (F0037151)
'            Corrected nulls to be eleven chr$(0) to match length of .validchars
'
'28Mar10 TH  WritelogSQL: Moved from Storeasc for use across suite (as Chris required)
'07Apr10 AJK URLEscape: Ported in from v8 for HIL (F0072542)
'08Apr10 XN  F0055221 - Column sorting on Receiving Orders Form
'29Jun10 XN  Improved shellsort, and add method AGreaterThanB after code review with Chris (F0055221, F0065193)
'06Sep10 XN  F0095829 - gave shellsort the option of being case insensitive
'06Sep10 TH  GetPointerSQL: Changed Write of pointer for Ascroot types (using DSSMastersiteID rather than siteID) - need to write this for UMMC FINV (F0054531)
'22Jul11 XN  ReverseStringArray: added the method (F0102524), (F0102526), (F0102527)
'15Sep11 CKJ MakeLocalFile: Corrected.            (TFS14212)
'28Jun12 AJK 36929 ParseURLToken:        Added 3 new params: WebDataConn as a byref to inform calling code if the URL token is for a web data connection
'                                                            WebProxyPageURL as a byref string to inform the calling code what the full web proxy page url is
'                                                            UnencryptedToken as a byref string to inform the calling code what the unencrypted token was
'                                        Renamed ConnectionString to ResponseValue
'                                        Added replacement code which derives the web page proxy url
'                                        Added setting of unencryptedtoken value
'                                        Formatting of connection string now conditional if connectiong string properties detected.
'28Jun12 AJK 36929 ParseCommandURLToken: Added new params to procedure and ParseURLToken call
'08Aug12 CKJ Web Transport layer - created wrapper calls for gTransport.Connection
'16Aug12 CKJ Added gTransportADOSetLockTimeOut wrapper
'16Aug12 CKJ ReadSiteInfo: added call to gTransportADOSetLockTimeOut to ensure same setting is used throughout suite (non-web transport layer only)
'             Uses wConfiguration d|siteinfo Connection SQLLockTimeout, default is "5000", values in millisecs, wait forever is "-1"
'10Sep12 CKJ gTransportType: written
'04Oct12 CKJ ReadSiteInfo: moved call to gTransportADOSetLockTimeOut after dispdata has been defined  (TFS45776)
'10Apr13 AJK 61073 Renamed PharmacyWebData webpage
'03Jul13 TH  GetTextFile: Extended size of file handled (TFS 67988)
'03Jul13 TH  ParseItems: Altered length var to long to handle big stuff (TFS 67988)
'15Nov13 XN  WriteLogSQL: Added NSVCode 56701
'20Jan15 XN  WriteLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                        ReadLogSQL: Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'                        GetWPharmacyLogTypeIDFromDescription: Added method to get the  WPharmacyLogTypeID 26734
'27Jul15 TH  ASCTerminalName$: Added way of resetting terminal. Mid session user could change terminals then return to ocx (TFS 60163)

'mods needed
' waitforkeyorticks can't see keyboard
' check that acquirelock is set & cleared appropriately in modules
' no way out of err70msg
'/no way out of fileexists


'############################# OLD COMMENTS ##################################
'-----------------------------------------------------------------------------
'CKJ 31Mar89
'                        Miscellaneous Routines Library
'-----------------------------------------------------------------------------
'18Apr89 CKJ Procedure ANSI removed - all facilities present in COLOUR ()
'26Sep89 CKJ Since this library is used with every single Q4/Q4.5 program
'            it seems sensible to turn this into the general purpose library,
'            to form the core routines in a Quicklibrary in due course.
'            First of these is a Centred Print routine, to replace
'            GOSUB CENTRE in the LIBNAME file.
'12Nov89 CKJ Assigncolour removed, text is held in Colour in case it's needed
'14Jan90 CKJ waitforticks & waitforkeyorticks moved here from bigbox
' 7Mar90 CKJ fillkeybuff( ) preloads keyboard buffer eg on exit from program
'14Apr90 CKJ fillkeybuff moved to windows
'28Apr90 CKJ tidied prior to use in QLB
' 3Feb91 CKJ Infobar added from ASC's version
'23Feb91 CKJ/ASC Trim$ added, colour added to infobar & colour (?!)
'17Aug92 CKJ option to force mono
'5Dec    ASC colours increased for label printing
'31May93 CKJ Added dp!  ** WARNING ** If this function is called in a module
'            which does not include HELINPOP.INC then this function >MUST<
'            be explicitly declared in each module. ** Failure to do this will
'            result in the compiler assuming that a single precision array
'            called dp!() is being used, and will return Zero every time. **
'4Jun93  ASC printbar added
'21Aug93 ASC seqscan and displaymacrofile added
'30Aug93 ASC printbar now locates the bar relative to the box !
'22Sep93 CKJ Helinpop.inc must have been added by ASC for some reason,
'            but duplicate defines were left - removed these.
'            Also deleted 6 superfluous calls to videotype
'11Oct93 CKJ NoExp implemented
'30Oct93 CKJ NoExp moved to DFHL - avoids need for /e/x
' 8Feb94 CKJ Mod to deflines
'19Mar94 ASC W at end of cmd$ added for windows menu
' 7Apr94 CKJ VBW: Conversion started
'>>>>>>>>>>> Comments above please

'To be done
'----------
'CKJ to bring seqscan and displaymacrofile up to final spec.



'----Q4------------------ GENERAL INPUT ROUTINE -------------------------------
'
' This module contains the general purpose input routines for use in QB4.x
'11Aug91 CKJ Temporarily reinstated the REDIM
'21May93 CKJ Implemented system locking. See AcquireLock in Q4INPUT for info.
'19Aug93 ASC done now done% for programmes without defint a-z
' 3Feb94 ASC Common now within Command$
' 2Mar94 ASC/CKJ added file common for fixing memory probs
' 7Mar94 CLJ Changed numofhosps to 43
'21Mar94 CKJ Changed Chain to Run
'22Mar94 ASC Changed run to end if windows
'12Jul94 CKJ Removed patdat$(), numof hosps back to 15
'23Jun95 CKJ Added Airedale & Kings
'23Feb96 KR  Amended MakeCommand to trap program not present error & prevent
'            code reentry.
'>>>>>>>>>>> Comments above please

'Structure for use with all Q4INPUT routines. Include at start of each program
'mod history
'16Aug90 CKJ timeout support written            supports V4.2
'18Aug90 CKJ .helpfile now 13 chars - room for "\filename.ext"
'23Mar91 CKJ Barcode support added
'14May91 CKJ .helpfile now 22 chars - room for "\directry\filename.ext"
'26Jan96 CKJ/KR replaced nulls this time as global
'>>>>>>>>>>> Comments above please
'22May14 XN GetRichTextDocument: Started storing ICW reports in the DB 88863
'02Aug16 XN  g_URLToken: Moved to CoreLib so can be accessed by other parts of the system 159413
'12Aug16 XN  ParseCommandURLServerAndWebFolder: fixed issue coverting URL 160253
'10Nov16 TH  getCrystalFilefromSQL: Written for Hosted Enhancements to store Crystal Rpt file in DB (TFS 157972)
'10Nov16 TH  GetLocalFilePath: Written for Hosted Enhancements to store Crystal Rpt file in DB (TFS 157972)
'14Dec16 TH  WritePharmacyRTFToSQL: Written for Hosted Enhancements to store RTF files in DB (TFS 157972)
'10Jan17 TH  WritePharmacyRTFToSQL: Added PIL, but limitation is that we cannot duplicat .pil and .rtf "file" names in asme logical location
'            I believe this is OK at present as pils are handled in there own "area"
'03Feb17 TH  WritePharmacyRTFToSQL: Not sure why but generate system error if set length of varcharmax field to zero, so added cheap fix to set to 1 for blank string (as -1 wouldnt work either) (TFS 175260)
'03Feb17 TH  GetRTFUpdateDateTime: Written for Hosted Enhancements to read RTF file from DB (TFS 175260)
'06Feb17 TH  GetRTFTextFromDB : Added Optional param to suppress msg when rtf not found. THis is because this sub was used to replace (amongst other things)
'                               the #include handling from parsertf - which will silently return nothing if the file specified does not exist
'                               This was causing a problem for embedded draft methods in draft worksheets. (TFS 175148)
'08Feb17 TH  RTFExistsInDatabase: Use full path when resolving prefix for sub folders (TFS 176132,176137)
'07Feb17 TH  AcquireLockOld: Rebadged AcquireLock - this proc is fall back if the DB level locking goes wrong. (TFS 156987)
'07Feb17 TH  AcquireLock: Rewritten but still using existing logic. Now uses DB locking not file locking. (TFS 156987)
'10Feb17 TH  GetRTFTextFromDB: No longer need to remove trailing crlf - was an artefact of the method used to convert the rtf files (TFS 176550)
'10Feb17 TH  GetPharmacyRTFFromSQL: No longer need to remove trailing crlf - was an artefact of the method used to convert the rtf files (TFS 176550)
'13Feb17 TH  GetPharmacyRTFFromSQL: Mod to remove filename from file path - this was interfering with prefix(sub folder) handling (TFS 175775)
'14Feb17 TH  GetRTFTextFromDB: Added Section to fix PIL handling (TFS 177159)
'14Feb17 TH  WritePharmacyRTFToSQL: Added Section to fix PIL handling (TFS 177159)
'15Feb17 TH  WritePharmacyRTFToSQL: Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders (TFS 177159)
'15Feb17 TH  GetPharmacyRTFFromSQL: Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders) (TSF 177159)
'15Feb17 TH  GetRTFTextFromDB : Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders) (TSF 177159)
'18Feb17 TH  WriteLogSQL: Extended Detail form 255 to 8000 to match underlying DB change and ensure Robot logs saved correctly (TFS 177654)
'14Mar17 TH  RTFExistsInDatabase: ensure path and file arent conflicted (TFS 179340)
'02Apr17 TH  WriteLog: Now we need to write all logs to DB for Hosted so pass through to writelogSQL (TFS 175557)
'02Apr17 TH  WriteLogSQL: Changes for handling all file based writelogs. Added site as optional param (to pass through)
'24May17 TH  GetBackgroundPicture: Written for Hosted Enhancements to store pictures in DB (TFS 174888)
'28May17 TH  GetBackgroundPicture: Major work to use base64 encoding because transport layer doesnt use binary data correctly (TFS 174888)
'05Jun17 TH  WriteLog: Added blntoDisk over ride. This allows local logwrite for robot log caching (TFS 185815)
'05Jun17 TH  WriteLogSQL: Added optionalID to optimise log write if we know the type when going to write (TFS 185185)
'##################################################################################
Option Explicit
DefInt A-Z

Type pointertype
   ptr As Long
End Type  ' len=4

Type filerecord
   record As String * 1024     '24Mar94 CKJ was 1000
End Type

Type kbdcontrol
   'all the following are input parameters
   Max As Integer                 ' max no of chars
   min As Integer                 ' min no of chars
   esc As Integer                 ' T/F allow 'Escape' as terminator
   nums As Integer                ' T/F allow . and 0-9
   decimals As Integer            ' T/F allow 0-9 only
   passwrd As Integer             ' T/F no echo of input
   validchars As String * 11      ' up to 11 characters '31Jan03 TH (PBSv4) Extended from 10 chars
   HelpFile As String * 22        ' name of helpfile, [\]<filename>[.<ext>]
   helpnum As Long                ' page in helpfile, 1 <= helpnum <= 32000 '16Oct96 CKJ Now type LONG
   startat As Integer             ' start at column, cursor position unchanged
   timeout As Integer             ' 0 none, -1 default, 1 to 32767 seconds
   timedef As Integer             ' 0 none, 1 to 32767 seconds
   date As Integer                ' T/F chars must form a valid date             '12Sep96 CKJ  '08Nov05 CKJ not used
   norefresh As Integer           ' T/F in AskWin etc don't refresh on closing   '12Sep96 CKJ

   'all the following are output parameters
   timd As Integer                ' timeout occurred (NB escd is also set)
   escd As Integer                ' escape pressed and allowed
   up As Integer                  ' csr up pressed and allowed
   down As Integer                ' crs dn pressed and allowed
   exitval As Integer             ' other key eg Fx, Esc, CR, cursor ...
      ' inkey$
      ' 10, 13     - LINE FEED / RETURN KEY           k.exitval =  13
      ' 27         - ESC / Timeout                    k.exitval =  27
      '  8         - BACKSPACE KEY                    k.exitval =   8
      '  9         - TAB                              k.exitval =   9
      '  0 15      - Shift TAB                        k.exitval = -15
      '  0 "P"     - DOWN KEY                         k.exitval = -80
      '  0 "H"     - UP KEY                           k.exitval = -72
      '  0 "K"     - LEFT ARR0W at start of line      k.exitval = -75
      '  0 "M"     - RIGHT ARROW at end of line       k.exitval = -77
      '  0 "G"     - HOME at beginning of line        k.exitval = -71
      '  0 "O"     - END at end of line               k.exitval = -79
      '  0 "I"     - Page Up                          k.exitval = -73
      '  0 "Q"     - Page Dn                          k.exitval = -81
      '  0  ?      - Function keys - see below        k.exitval = -xx
      '             Plain      Shift      Ctrl        Alt
      '       F1   (59 ;)      84 T      (94 ^)     (104 h)
      '       F2    60 <       85 U       95 _       105 i
      '       F3    61 =       86 V       96 `       106 j
      '       F4    62 >       87 W       97 a       107 k
      '       F5    63 ?       88 X       98 b       108 l
      '       F6    64 @       89 Y       99 c       109 m
      '       F7    65 A       90 Z      100 d       110 n
      '       F8    66 B       91 [      101 e       111 o
      '       F9    67 C       92 \      102 f       112 p
      '       F10   68 D       93 ]      103 g       113 q
      '       F11   .. .       .. .       .. .        .. .
      '       F12   .. .       .. .       .. .        .. .
      ' items in braces above are already reserved & are not returned.
End Type

'»Type TagMemManInfo
'»   dwSize As Long
'»   dwLargestFreeBlock As Long
'»   dwMaxPagesAvailable As Long
'»   dwMaxPagesLockable As Long
'»   dwTotalLinearSpace As Long
'»   dwTotalUnlockedPages As Long
'»   dwFreePages As Long
'»   dwTotalPages As Long
'»   dwFreeLinearSpace As Long
'»   wPageSize As Integer
'»End Type
'»
'»Declare Function MemManInfo Lib "Toolhelp.dll" (lpmmi As TagMemManInfo) As Integer

'Windows API Functions
Public Declare Function GetSystemMenu Lib "user32.dll" (ByVal Hwnd As Long, ByVal bRevert As Long) As Long
'Declare Function RemoveMenu% Lib "User" (ByVal hMenu%, ByVal nPosition%, ByVal wFlags%)
Public Declare Function SetWindowPos Lib "user32.dll" (ByVal Hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long

'Declare Function GetPrivateProfileString Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
''Public Declare Function WritePrivateProfileString Lib "kernel32.dll" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpString As String, ByVal lpFileName As String) As Long
Public Declare Function GetProfileString Lib "kernel32.dll" Alias "GetProfileStringA" (ByVal lpAppname As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long) As Long

'Declare Function GetModuleUsage% Lib "Kernel" (ByVal hModule%)
'Declare Function ExitWindow% Lib "User" (ByVal dwReturnCode&, ByVal reserved%)
Public Declare Function GetVersion Lib "kernel32" () As Long
'Declare Function SendMessage Lib "User" (ByVal hwnd As Integer, ByVal wMsg As Integer, ByVal wParam As Integer, lParam As Any) As Long
Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal Hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long

'Declare Function Getfocus Lib "user" () As Integer
'Declare Function GetDialogBaseUnits Lib "User" () As Long
'Declare Sub APISetFocus Lib "User" Alias "SetFocus" (ByVal hWnd As Integer)
Declare Function WinHelp Lib "user32.dll" Alias "WinHelpA" (ByVal hWndMain As Long, ByVal lpHelpFile As String, ByVal uCommand As Long, dwData As Any) As Long
'Declare Function GetKeyState Lib "User" (ByVal nVirtKey As Integer) As Integer
'Declare Sub GetKeyboardState Lib "User" (lpKeyState As Any)
'Declare Sub SetKeyboardState Lib "User" (lpKeyState As Any)
'Declare Sub GetKeyboardStateByString Lib "User" Alias "GetKeyboardState" (ByVal lpKeyState$)
'Declare Sub SetKeyboardStateByString Lib "User" Alias "SetKeyboardState" (ByVal lpKeyState$)
Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal Hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Declare Function GetDiskFreeSpace Lib "kernel32.dll" Alias "GetDiskFreeSpaceA" (ByVal lpRootPathName As String, lpSectorsPerCluster As Long, lpBytesPerSector As Long, lpNumberOfFreeClusters As Long, lpTotalNumberOfClusters As Long) As Long
''Declare Function GetFreeSpace Lib "Kernel" (ByVal wFlags) As Long
''Declare Function GetWinFlags Lib "Kernel" () As Long
''Declare Function GetFreeSystemResources% Lib "User" (ByVal fuSysResources%)
''Declare Function GlobalCompact Lib "Kernel" (ByVal dwMinFree As Long) As Long
'Technet Article Q71102 Emulating SOUND Statement
'Declare Function OpenSound Lib "sound.drv" () As Integer
'Declare Function VoiceQueueSize Lib "sound.drv" (ByVal nVoice%, ByVal nBytes%) As Integer
'Declare Function SetVoiceSound Lib "sound.drv" (ByVal nSource%, ByVal Freq&, ByVal nDuration%) As Integer
'Declare Function StartSound Lib "sound.drv" () As Integer
'Declare Function CloseSound Lib "sound.drv" () As Integer
'Declare Function WaitSoundState Lib "sound.drv" (ByVal State%) As Integer

'Declare Function BitBlt Lib "gdi" (ByVal hDC1 As Integer, ByVal x1 As Integer, ByVal y1 As Integer, ByVal wd As Integer, ByVal ht As Integer, ByVal hDC2 As Integer, ByVal x2 As Integer, ByVal y2 As Integer, ByVal Pattern As Long) As Integer
Public Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Public Declare Function GetDC Lib "user32" (ByVal Hwnd As Long) As Long
Public Declare Function GetDesktopWindow Lib "user32" () As Long
Public Declare Function ReleaseDC Lib "user32" (ByVal Hwnd As Long, ByVal hdc As Long) As Long
Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long) As Long  '05Oct05 TH Added

Public Declare Function CallWindowProc Lib "user32.dll" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal Hwnd As Long, ByVal msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Public Declare Function LockWindowUpdate Lib "user32" (ByVal hwndLock As Long) As Long  '19Jul11 TH Added (F0123219)

'VBASM.DLL Declarations
'**GONE**
'Declare Function vbGetCtrlHwnd Lib "VBASM.DLL" (CTRL As Any) As Integer
'Declare Function vbGetCtrlName Lib "VBASM.DLL" (ctrl As Any) As String

'Declare Function FlushFileBuffers Lib "kernel32" (ByVal hFile As Long) As Long
'Declare Function GetDriveType Lib "kernel32.dll" Alias "GetDriveTypeA" (ByVal nDrive As String) As Long
'Global Const VBDRIVE_REMOVABLE = &H1002
'Global Const VBDRIVE_FIXED = &H1003
'Global Const VBDRIVE_REMOTE = &H1004
'Global Const VBDRIVE_CDROM = &H1005
'Global Const VBDRIVE_FLOPPY = &H1006
'Global Const VBDRIVE_RAMDISK = &H1007
'Global Const VBDRIVE_UNKNOWN = &H1010
'Global Const VBDRIVE_INVALID = &H0

'Start : SP - MM-9813 10.23 - another application in focus when printing in pharmacy
Public Declare Function PostMessage Lib "user32" Alias "PostMessageA" _
        (ByVal hWnd As Long, ByVal wMsg As Long, _
        ByVal wParam As Long, ByVal lParam As Long) As Long

Public Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" _
        (ByVal hWnd1 As Long, ByVal hWnd2 As Long, _
        ByVal lpsz1 As String, ByVal lpsz2 As String) As Long
Global Const WM_COMMAND As Long = &H111
Global Const MINAPP As Long = &H1A3
'END : SP - MM-9813 10.23 - another application in focus when printing in pharmacy


Global Const MB_OK = 0                 ' OK button only
Global Const MB_OKCANCEL = 1           ' OK and Cancel buttons
'Global Const MB_ABORTRETRYIGNORE = 2  ' Abort, Retry, and Ignore buttons
Global Const MB_YESNOCANCEL = 3        ' Yes, No, and Cancel buttons
Global Const MB_YESNO = 4              ' Yes and No buttons
Global Const MB_RETRYCANCEL = 5        ' Retry and Cancel buttons

Global Const MB_DEFBUTTON1 = 0        ' First button is default
Global Const MB_DEFBUTTON2 = 256       ' Second button is default
Global Const MB_DEFBUTTON3 = 512       ' Third button is default

'MsgBox return values                      15Dec97 CKJ moved from report.bas
Global Const IDOK = 1                    ' OK button pressed
Global Const IDCANCEL = 2                ' Cancel button pressed
'Global Const IDABORT = 3                ' Abort button pressed
'Global Const IDRETRY = 4                ' Retry button pressed
'Global Const IDIGNORE = 5               ' Ignore button pressed
Global Const IDYES = 6                   ' Yes button pressed
Global Const IDNO = 7                    ' No button pressed
Global Const IDCHECKED = 256             ' Check Box Ticked

'MsgBox icon values                        15Dec97 CKJ moved from Highasc.bas
Global Const MB_ICONSTOP = 16            ' Critical message
Global Const MB_ICONQUESTION = 32        ' Warning query
Global Const MB_ICONEXCLAMATION = 48     ' Warning message
Global Const MB_ICONINFORMATION = 64     ' Information message
Global Const ASC_ICONSAMPLE = 8          ' Box shaped icon   16Feb98 CKJ Added

'windows constants used for getting/setting menu options
'Global Const MF_BYPOSITION = &H400
'Global Const MF_ENABLED = &H0
'Global Const MF_GRAYED = &H1
'Global Const MF_DISABLED = &H2

'Constants for arranging windows
'Global Const CASCADE = 0
'Global Const TILE_HORIZONTAL = 1
'Global Const TILE_VERTICAL = 2
'Global Const ARRANGE_ICONS = 3

'constants used for listbox attributes              'win16 values
Global Const LB_FINDSTRING = &H18F                  'WM_USER + 16
Global Const LB_SETTABSTOPS = &H192                 'WM_USER + 19
Global Const LB_GETITEMHEIGHT = &H1A1               'WM_USER + 34

Global Const LB_ITEMFROMPOINT = &H1A9   '08Oct13 TH/CKJ (TFS 75383)

'constants used for textbox attributes
Global Const EM_GETLINECOUNT = &HBA                 'WM_USER + 10
Global Const EM_GETLINE = &HC4                      'WM_USER + 20
Global Const EM_CANUNDO = &HC6                      'WM_USER + 22
Global Const EM_UNDO = &HC7                         'WM_USER + 23
Global Const EM_SETTABSTOPS = &HCB                  'WM_USER + 27
Global Const EM_SETREADONLY = &HCF                  'WM_USER + 31

'Global Const WM_USER = &H400
'Global Const LB_ADDSTRING = WM_USER + 1            '14Sep98 CKJ Added
'Global Const LB_SETHORIZONTALEXTENT = WM_USER + 21 'Add a horizontal scroll bar to list box

'Global Const EM_LINESCROLL = WM_USER + 6
'Global Const EM_SETSEL = WM_USER + 11
'Global Const EM_LINEINDEX = WM_USER + 11
'Global Const EM_LINELENGTH = WM_USER + 17
'Global Const EM_REPLACESEL = WM_USER + 11
'Global Const EM_LINEFROMCHAR = WM_USER + 25
'Global Const EM_EMPTYUNDOBUFFER = &HCD             'WM_USER + 29
'Global Const EM_GETFIRSTVISIBLELINE = WM_USER + 30

'Global Const EM_GETSEL = &HB0
'Global Const EM_SETSEL = &HB1
'Global Const EM_LINESCROLL = &HB6
'Global Const EM_GETLINECOUNT = &HBA
'Global Const EM_LINEINDEX = &HBB
'Global Const EM_LINELENGTH = &HC1
'Global Const EM_REPLACESEL = &HC2
'Global Const EM_LINEFROMCHAR = &HC9
'Global Const EM_LIMITTEXT = &HC5
'Global Const EM_GETFIRSTVISIBLELINE = &HCE
'Global Const EM_FMTLINES = &HC8
'Global Const EM_GETLINE = &HC4

'Global Const WM_SETREDRAW = &HB                    '14Sep98 CKJ

'Declare Function PostMessageByString% Lib "User" Alias "PostMessage" (ByVal hWnd%, ByVal wMsg%, ByVal wParam%, ByVal lParam$)
'Global Const WM_WININICHANGE = &H1A
'Global Const HWND_BROADCAST = -1

'Keycode constants
Global Const KEY_F1 = &H70
Global Const KEY_F2 = &H71
Global Const KEY_F3 = &H72
Global Const KEY_F4 = &H73
Global Const KEY_F5 = &H74
Global Const KEY_F6 = &H75
Global Const KEY_F7 = &H76
Global Const KEY_F8 = &H77
Global Const KEY_F9 = &H78
Global Const KEY_F10 = &H79
Global Const KEY_F11 = &H7A
Global Const KEY_F12 = &H7B
Global Const KEY_ESCAPE = &H1B
Global Const KEY_PgUp = &H21
Global Const KEY_PgDn = &H22
Global Const KEY_END = &H23
Global Const KEY_HOME = &H24
Global Const KEY_LEFT = &H25
Global Const KEY_UP = &H26
Global Const KEY_RIGHT = &H27
Global Const KEY_DOWN = &H28
Global Const VK_CAPITAL = &H14
Global Const VK_NUMLOCK = &H90
'Global Const VK_SCROLL = &H91
Global Const KEY_RETURN = &HD
Global Const KEY_INSERT = &H2D
Global Const KEY_DELETE = &H2E
Global Const KEY_TAB = &H9

' Shift parameter masks
Global Const NO_MASK = 0
Global Const SHIFT_MASK = 1
Global Const CTRL_MASK = 2
Global Const ALT_MASK = 4

Global Const LEFT_BUTTON = 1
Global Const RIGHT_BUTTON = 2
Global Const MIDDLE_BUTTON = 4

' Colors
'0 Black      8 Gray
'1 Blue       9 Light Blue
'2 Green     10 Light Green
'3 Cyan      11 Light Cyan
'4 Red       12 Light Red
'5 Magenta   13 Light Magenta
'6 Yellow    14 Light Yellow
'7 White     15 Bright White
Global Const Black = &H0&
Global Const Red = &HFF&
Global Const Green = &HFF00&
Global Const Yellow = &HFFFF&
Global Const Blue = &HFF0000
Global Const Magenta = &HFF00FF
'Global Const Cyan = &HFFFF00
Global Const White = &HFFFFFF

'For reference...
'SCROLL_BARS           = &H80000000 ' Scroll-bars gray area
'DESKTOP               = &H80000001 ' Desktop
'ACTIVE_TITLE_BAR      = &H80000002 ' Active window caption
'INACTIVE_TITLE_BAR    = &H80000003 ' Inactive window caption
'MENU_BAR              = &H80000004 ' Menu background
'WINDOW_BACKGROUND     = &H80000005 ' Window background
'WINDOW_FRAME          = &H80000006 ' Window frame
'MENU_TEXT             = &H80000007 ' Text in menus
'WINDOW_TEXT           = &H80000008 ' Text in windows
'TITLE_BAR_TEXT        = &H80000009 ' Text in caption, size box, scroll-bar arrow box
'ACTIVE_BORDER         = &H8000000A ' Active window border
'INACTIVE_BORDER       = &H8000000B ' Inactive window border
'APPLICATION_WORKSPACE = &H8000000C ' Background color of multiple document interface (MDI) applications
'HIGHLIGHT             = &H8000000D ' Items selected item in a control
'HIGHLIGHT_TEXT        = &H8000000E ' Text of item selected in a control
'BUTTON_FACE           = &H8000000F ' Face shading on command buttons
'BUTTON_SHADOW         = &H80000010 ' Edge shading on command buttons
'GRAY_TEXT             = &H80000011 ' Grayed (disabled) text.  This color is set to 0 if the current display driver does not support a solid gray color
'BUTTON_TEXT           = &H80000012 ' Text on push buttons

Global Const SB_SETBKCOLOR = &H2001

Global Const STDCURSOR = 0       'Cursor shape - default
Global Const HOURGLASS = 11      'Cursor shape - wait...

'Help system Api: WinHelp Constants
Global Const HELP_CONTEXT = &H1
'Global Const HELP_QUIT = &H2
'Global Const HELP_INDEX = &H3
'Global Const HELP_CONTENTS = &H3
Global Const HELP_HELPONHELP = &H4
'Global Const HELP_SETINDEX = &H5
'Global Const HELP_SETCONTENTS = &H5
'Global Const HELP_CONTEXTPOPUP = &H8
Global Const HELP_FORCEFILE = &H9
'Global Const HELP_KEY = &H101
'Global Const HELP_COMMAND = &H102
Global Const HELP_PARTIALKEY = &H105
'Global Const HELP_MULTIKEY = &H201
'Global Const HELP_SETWINPOS = &H203

Global Const GWL_STYLE = (-16)
Global Const WS_HSCROLL = &H100000
Global Const WS_VSCROLL = &H200000


Global Const ATTR_DIRECTORY = 16     '12May97 CKJ Moved from DirExists
Global Const SRCCOPY = &HCC0020

'Global Const WF_STANDARD = &H10     '26Mar97 KR Removed
'Global Const WF_ENHANCED = &H20     '26Mar97 KR Removed
'Global Const WF_80x87 = &H400
'Global Const GFSR_SYSTEMRESOURCES = &H0
'Global Const GFSR_GDIRESOURCES = &H1
'Global Const GFSR_USERRESOURCES = &H2

'Common
''Global Identtype$       'used to define program going to   '08nov05 CKJ now not used.
''Global patno&             'Patient number (file position)  '08nov05 CKJ superfluous since entityid is used to retrieve wpat.entityid
Global UserID$            'user id usually initials
Global acclevels$         'Access level as string of numeric acces levels e.g. 2224222229
Global UserFullName$      'user's full name
''Global gLastID$           '21Jun00 JN Cludge to hold previous user's userid
''Global gLastAccessLevel$  '21Jun00 JN Cludge to hold previous user's accesslevel
''Global gLastUserFullName$ '21Jun00 JN Cludge to hold previous user's full name

'Program paths
Global SiteNumber As Integer
Global rootpath$
Global patdatapath$
Global gPatientSite As Long
Global dispdata$
Global gDispSite As Long
Global transpath$
Global orderlogpath$
''Global orderpath$                  '{SP2} remove facility?

Dim sLivePath As String            '25Jan00 AE  Path to the root (live drive).  Used for the Overnight Job
                                    '           via the routines SetONJLivePath and ONJLivePath()
''Global passfile$
''Global whichinputs$
''Global pddata$
Global hospname1$
Global hospname2$
Global hospabbr$
''Global TerminalName$           '10Jul97 CKJ Added      '09Feb05 CKJ Always useASCterminalname() instead
Global singleuseronly%         '28Oct97 CKJ Moved from ReadSiteInfo
                              
Global Const cr   As String = Constants.vbCr      ' carriage return, CHR$(13)
Global Const lf   As String = Constants.vbLf      ' line feed, CHR$(10)
Global Const crlf As String = Constants.vbCrLf    ' carriage return, line feed (13),(10)
Global Const TB   As String = Constants.vbTab     ' tab, CHR$(9)

Global k As kbdcontrol
Global r As filerecord
Global nulls As String * 11    'Ten Chr$(0)        '12Nov08 CKJ Eleven chr$(0) to match length of .validchars
Global Const StdTimeout = 300  'Secs = 5 minutes

Global RTFinternalTitle$       '12Aug97 CKJ added for use in parsing printer layouts
Global RTFinternalHeading$
Global RTFinternalTransfer$
Global RTFinternalHeader$
Global RTFinternalFooter$

Global gPRNheapID As Integer          '16Jan98 CKJ Added global heap ID for parsing prior to printing
Global Nul As String * 1              '   "        was local

Global g_URLToken As String ' added cached URL so frmWebClient has a web server name (F0033906)

'''26Dec98 ASC Value list types, and mask to extract from VlistStyle value
''Global Const GVLS_TEXT = 0          ' normal text presentation
'''Global Const GVLS_COMBO = 1        ' combo box presentation
'''Global Const GVLS_RADIO = 2        ' radio button presentation
'''Global Const GVLS_MASK = &HF       ' mask to extract type
''
''' Value list flags, ORed into VlistStyle
''Global Const GVLS_TRANSLATE = &H10  ' translate value pairs
'''Global Const GVLS_VALIDATE = &H20  ' auto-validate entered values
''Global Const GVLS_CYCLE = &H40      ' cycle through values when clicked
'''Global Const GVLS_SORTCOMBO = &H80 ' sort combo (if GVLS_COMBO too)

Global OwnerForm As Object          'AS : MS_Edge_Fix for modal windows without an owner form
Global bolFirstPrintCompleted As Boolean  'SP - MM-10661 10.23 Print FF Labels modal dialog issue resolve
Dim iniHeapID%, fileHeapID%         '28Oct99 CKJ Added

'26May00  AE Moved from Events.bas so that it is always available
''Global Const DB_LANG_GENERAL = ";LANGID=0x0809;CP=1252;COUNTRY=0"

Const m_strModuleName = "CoreLib"   '29Apr02 CKJ added
Const OBJNAME As String = PROJECT & "Corelib."

Dim procname$
Dim ErrNum

Dim country As Integer

Dim msOpenedChannels(1 To 2, 1 To 32) As String   '24Aug99 CKJ module level array of opened files
'   msOpenedChannels(1, x) name of file opened
'   msOpenedChannels(2, x) name of procedure
'                       x  channel number of file


'»Function DosVersion() As Variant
'»'12Sep96 CKJ VBWin example
'»'            Returns "6.20" "7.00" etc as variant, ie can be used as
'»'            a string or number without conversion.
'»
'»Dim Ver As Long, DosVer As Long
'»
'»   Ver = GetVersion()
'»   DosVer = Ver \ &H10000
'»   DosVersion = Format((DosVer \ 256) + ((DosVer Mod 256) / 100), "Fixed")
'»
'»End Function


Sub decode(passw As String)
'-----------------------------------------------------------------------------
'                   decode variable length binary string
'
'  byte n              0*0*0*0*     AND 10101010  &HAA
'  byte n+1            *1*0*0*1     AND 01010101  &H55
'  answer       A  65  01000001     OR
'-----------------------------------------------------------------------------
Dim plen As Integer
Dim pasin As String
Dim iByte As Integer
   
   plen = Len(passw) \ 2
   pasin = passw
   passw = ""
   If plen Then
         For iByte = 1 To plen * 2 Step 2
            passw = passw & Chr$((((Asc(Mid$(pasin, iByte)) * 2) Mod 256) And &HAA) Or (Asc(Mid$(pasin, iByte + 1)) And &H55))
         Next
      End If

End Sub

Sub decodehex(passw As String)
'-----------------------------------------------------------------------------
'30Oct94 CKJ Written. Returns an encoded hex string
'-----------------------------------------------------------------------------
Dim pasin As String, plen%, iByte%

   plen = Len(passw) \ 4
   pasin = passw
   passw = ""
   If plen Then
         For iByte = 1 To plen * 4 Step 4
            passw = passw & Chr$((((Val("&h" & Mid$(pasin, iByte, 2)) * 2) Mod 256) And &HAA) Or (Val("&h" & Mid$(pasin, iByte + 2, 2)) And &H55))
         Next
      End If

End Sub

Function decpl!(Value!, n%)
'19Jul99 AE Written
'Round a number (Value) to 'n' decimal places
'Beware VB's internal rounding. Use DP for important calculations, use this for
'display etc.
'--------------------------------------------
Dim sign%

'multiply up, use int to round, divide back down.

   n% = Abs(n%)
   sign = Sgn(Value!)
   Value! = Abs(Value!)

   Value! = Value! * 10 ^ n
   Value! = Value! + 0.5
   Value! = Int(Value!)
   Value! = Value! * 10 ^ -n

   decpl! = sign * Value!

End Function

Function URLEscape(ByVal strSource As String) As String
'------------------------------------------------------------------------
' Purpose:  Takes a source string and returns the source string with
'           any illegal URL characters replaced with their URL Escape
'           Character equivalants
'
' Inputs:   strSource - Source string that require converting to XML format
'
' Outputs:  None
'
' Return :  Result of the source string converted to URL format
'
' Revision History
' 07Aug09 TH Created
' 07Apr10 AJK Ported in from v8
    '------------------------------------------------------------------------

Dim nbsp2$

   nbsp2$ = String$(2, 160) & "$"       'two non-breaking spaces and a $ - just to be a unique string


    On Error Resume Next
   'replace strSource, "&", Chr(160) & "$" & Chr(160), 0
   'replace strSource, Chr(160) & "$" & Chr(160), "&amp;", 0
   'replace strSource, """", "&quot;", 0
   
   'replace strSource, "%", "%25", 0  'First for obvious reasons '28Jun10 TH Replaced with next 2 lines
   replace strSource, "%", nbsp2$, 0           'replace 1 char  with 3 -> slow
   replace strSource, nbsp2$, "%25", 0         'replace 3 chars with 3 -> fast

   
   replace strSource, " ", "%20", 0             'replace 1 char  with 5 -> slow
   replace strSource, "<", "%3C", 0         'replace 5 chars with 5 -> fast
   replace strSource, ">", "%3E", 0
   replace strSource, "#", "%23", 0
   
   replace strSource, "{", "%7B", 0
   replace strSource, "}", "%7D", 0
   replace strSource, "|", "%7C", 0
   replace strSource, "\", "%5C", 0
   replace strSource, "^", "%5E", 0
   replace strSource, "~", "%7E", 0
   replace strSource, "[", "%5B", 0
   replace strSource, "]", "%5D", 0
   replace strSource, "`", "%60", 0
   replace strSource, ";", "%3B", 0
   replace strSource, "/", "%2F", 0
   replace strSource, "?", "%3F", 0
   replace strSource, ":", "%3A", 0
   replace strSource, "@", "%40", 0
   replace strSource, "=", "%3D", 0
   replace strSource, "&", "%26", 0
   replace strSource, "$", "%24", 0
   URLEscape = strSource

   On Error GoTo 0

End Function

Sub deflines(alllines$, lines$(), sepctrl$, firstlin, Numoflines)
'-----------------------------------------------------------------------------
' split a line into individual parts, based on given separator
' set firstlin before calling, eg 0 if line$(0) is to be used, else 1
' numoflines is returned
' 9Feb94 CKJ Add "(*)" to the separator to preserve all blank lines
' 1Feb95 CKJ Removed line; "a,b,c" returned 3 lines, ",," returned 2 lines
'            - now both return 3 lines
' 9Feb95 CKJ Added line - did not parse "a,b,c" style lines correctly
'-----------------------------------------------------------------------------
Dim lin$, keepblanks%, sep$, cursep%, linnum%, lastsep%

   lin$ = RTrim$(alllines$)
   keepblanks = False
   sep$ = sepctrl$
   If Right$(sep$, 3) = "(*)" Then
         sep$ = Left$(sep$, Len(sep$) - 3)
         keepblanks = True
      End If
   If sep$ = "" Then
         lines$(firstlin) = alllines$
         Numoflines = 1
         Exit Sub
      End If
  'IF RIGHT$(lin$, 1) <> sep$ THEN lin$ = lin$ + sep$   1Feb95 CKJ Removed
   lin$ = lin$ & sep$       '9Feb95 CKJ Added
   cursep = InStr(lin$, sep$)
   linnum = firstlin

   Do While cursep
      lines$(linnum) = Mid$(lin$, lastsep + 1, cursep - lastsep - 1)
      If cursep - lastsep > 1 Or keepblanks Then linnum = linnum + 1   'optionally ignore blank lines
      lastsep = cursep
      cursep = InStr(lastsep + 1, lin$, sep$)
      If linnum > UBound(lines$) Then Exit Do
   Loop

   Numoflines = linnum - firstlin
   
End Sub

Function digits(lin$) As String
' 3Dec96 CKJ Written
'            Takes a string & returns only digits 0-9, removing all other chars
Dim chars$, i%, ch$

   chars$ = ""
   For i = 1 To Len(lin$)
      ch$ = Mid$(lin$, i, 1)
      Select Case ch$
         Case "0" To "9": chars$ = chars$ & ch$
         End Select
   Next
   digits$ = chars$

End Function

Function DirExists(ByVal drvpth$) As Boolean
'-----------------------------------------------------------------------------
' This is the core of the code which was used in FileExists, now modified
' to look for directories only.
'09Apr96 CKJ Modified for use in Windows
'29Jul98 CKJ Corrected. 'Resume Next' set Status=True even though it was on the same line
'            i.e. err 76 'path not found' returned direxists()=True
'            Now preserves mousepointer shape through the call
'            Now accepts optional trailing backslash (previously failed with "path\")

Dim status%, DirName$, msg$, mousewas%

   status = False
   mousewas = Screen.MousePointer
   If drvpth$ <> "" Then
         DirName = ""
         If Right$(drvpth$, 1) = "\" Then                                'path of C:\orderlog\
               drvpth$ = Left$(drvpth$, Len(drvpth$) - 1)                'remove  C:\orderlog
               If Right$(drvpth$, 1) = ":" Then drvpth$ = drvpth$ & "\"  'but is needed for C:\
            End If
         On Error GoTo DirExists_Err
         Screen.MousePointer = HOURGLASS
         DirName = Dir$(drvpth$, ATTR_DIRECTORY)
         If DirName <> "" Then
               If (GetAttr(drvpth$) And ATTR_DIRECTORY) = ATTR_DIRECTORY Then
                     status = True
                  End If
            End If
      Else
         On Error GoTo DirExists_Err
         Error 255
      End If

direxists_resume:
   On Error GoTo 0
   Screen.MousePointer = mousewas
   DirExists = status
Exit Function

DirExists_Err:
   Screen.MousePointer = STDCURSOR             '29Jul98 CKJ Note: appears to be ignored here

   ErrNum = Err
   'If errnum = 76 Then Resume Next            ' 9Apr96 CKJ Added. 76=Path not found
   If ErrNum = 76 Then Resume direxists_resume '29Jul98 CKJ Corrected

   Select Case ErrNum
      Case 57:   msg$ = T1("err57", " 57 Device I/O error")
      Case 64:   msg$ = T1("err64", " 64 Bad file name")
      Case 68:   msg$ = T1("err68", " 68 device unavailable")
      Case 71:   msg$ = T1("err71", " 71 disk not ready")
      Case 255:  msg$ = T1("err255", " 255 file name is null")
      Case Else: msg$ = T1("errnum", " Error number" + Str$(ErrNum))
      End Select
   msg$ = "Error reading directory:  " & drvpth$ & cr & cr & msg$ & cr & "Inform System Supervisor"
   popmessagecr "Note", msg$
   
Resume Next

End Function

Function DirExistsNoMsg(drvpth As String, iErrCode As Integer) As Boolean
'-----------------------------------------------------------------------------
'This is the code from DirExists, modified to remove screen messages.  These
'were causing problems with the overnight job, as the message box does not
'time out properly. This procedure is neater when running as a non-interactive
'program, as it does not write to screen directly.
'
'Returns True or False;  if an error occurred, sErrCode is set to the value of Err, 0 otherwise
'------------------------------------------------
'01Feb00 AE Written

Dim filename$, status%, DirName$, msg$, mousewas%

   status = False
   iErrCode = 0
   mousewas = Screen.MousePointer
   If drvpth$ <> "" Then
         DirName = ""
         If Right$(drvpth$, 1) = "\" Then                                'path of C:\orderlog\
               drvpth$ = Left$(drvpth$, Len(drvpth$) - 1)                'remove  C:\orderlog
               If Right$(drvpth$, 1) = ":" Then drvpth$ = drvpth$ & "\"  'but is needed for C:\
            End If
         On Error GoTo DirExistsNM_Err
         Screen.MousePointer = HOURGLASS
         DirName = Dir$(drvpth$, ATTR_DIRECTORY)
         If DirName <> "" Then
               If (GetAttr(drvpth$) And ATTR_DIRECTORY) = ATTR_DIRECTORY Then
                     status = True
                  End If
            End If
      Else
         On Error GoTo DirExistsNM_Err
         Error 64                             'File Name is Null - use "Bad File Name"
      End If

DirExistsNM_Exit:
   On Error GoTo 0
   Screen.MousePointer = mousewas
   DirExistsNoMsg = status

Exit Function

DirExistsNM_Err:
   Screen.MousePointer = STDCURSOR             '29Jul98 CKJ Note: appears to be ignored here

   If Err <> 76 Then iErrCode = Err            '76 = Path not found
   status = False

   Resume DirExistsNM_Exit

Resume Next

End Function


Sub DoSaferEvents(Action%)
'18Sep97 CKJ Wrapper for frmDoEvents
'            Call this instead of DoEvents/Freelocks to limit the damage
'            that can occur when non re-entrant code is used recursively.
'
'            Action% is used to choose between Hide and Unload options.
'            It may also be used to add a (hopefully) bomb-proof version
'            where we shell to a child process which does the DoEvents
'            on our behalf. Codes as follows;
'            Action = 0   Unload frmDoEvents without calling DoEvents
'                     1   Load frmDoEvents, DoEvents, unload frmDoEvents
'                     2   Load frmDoEvents, DoEvents, remain hidden
'                     3   Shell to child process, which does DoEvents
'            Options 0, 1 and 2 are all supported at present.

   Select Case Action
      Case 0                                      'unload only
         frmDoEvents.Tag = "0"
         Unload frmDoEvents
      Case 1, 2                                   'DoEvents then unload or hide
         frmDoEvents.Tag = Format$(Action)
         frmDoEvents.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      Case 3                                      'shell to child process
         popmessagecr "Programming Error", "DoSaferEvents Action=3 not supported"
      End Select

End Sub

Function dp!(Number!)
'-----------------------------------------------------------------------------
' Decimal Places:
'
' This function takes a single precision number (positive or negative
' including exponential notation) and returns the number to one less digit
' of precision in the decimals, by rounding the last digit. This only occurs
' if the number has 7 or more significant figures.
' 12Sep95 CKJ Added handling of small negative exponentials
'   1.234567  =>  1.23457
'  -1.234567  => -1.23457
'   1.23456   =>  1.23456      (unchanged)
'   1.23E-07  =>  0
'   1.23E-06  =>  1.23E-06
'   1.23E-04  =>  .000123
'-----------------------------------------------------------------------------
Dim X!, vals$, expon%, mantissa$, mantnodp$, expval%, decpt%, last%, adj$, round$

   X! = Abs(Number!)
   vals$ = LTrim$(Str$(X!))
   expon = InStr(vals$, "D")
   If expon = 0 Then expon = InStr(vals$, "E")

   If expon Then
         mantissa$ = Left$(vals$, expon - 1)                   ' 1.234
         mantnodp$ = Left$(mantissa$, 1) & Mid$(mantissa$, 3)  ' 1234
         expval = Val(Mid$(vals$, expon + 1))          ' 1.234567E-07  =>  -7
         Select Case expval
            Case Is <= -7
               dp! = 0
            Case -6 To -1        ' .0000012 to .1234567     12Sep95 CKJ Added
               dp! = Sgn(Number!) * Val(Left$("." & String$(expval * -1 - 1, "0") & mantnodp$, 8))
           'CASE 1 TO 8          ' 12.3456789 to 123456789
           '   dp! = SGN(number!) * VAL(LEFT$(mantnodp$, expval + 1) + "." + MID$(mantnodp$, expval + 2))
            Case Else
               dp! = Number!
            End Select
      Else

         decpt = InStr(vals$, ".")
         last = Val(Right$(vals$, 1))
         If decpt <> 0 And Len(vals$) >= 8 Then                   ' 765.12345
               If last >= 5 Then  ' round up
                     adj$ = LTrim$(Str$(10 - last))
                     round$ = "."
                  Else            ' round down
                     adj$ = LTrim$(Str$(last))
                     round$ = "-."
                  End If
               round$ = round$ & String$(Len(vals$) - decpt - 1, "0") & adj$ '    .00005
               dp! = Sgn(Number!) * (Val(vals$) + Val(round$))     ' 765.1235
            Else
               dp! = Number!
            End If
      End If

End Function

Sub encode(passw As String)
'-----------------------------------------------------------------------------
'                   encode variable length binary string
'
'                       byte n      byte n+1
'  character    B  66  01000010     01000010
'  AND          &HAA   10101010     01010101   &H55
'  masked char  (1)    00000010     01000000
'
'  random char         11011101     11011101
'  AND          &H55   01010101     10101010   &HAA
'  masked char  (2)    01011101     10001000
'  masked char  (1)    00000010     01000000
'  OR                  01011111     11001000
'  answer                95  _       200  È
'
'30Jun94 CKJ Mod to increase variability
'-----------------------------------------------------------------------------

Dim pasin As String, plen%, iByte%, pasch%

   plen = Len(passw)
   pasin = passw
   passw = ""
   If plen Then
         Randomize Timer
         For iByte = 1 To plen
            pasch = Asc(Mid$(pasin, iByte))
            passw = passw & Chr$(((pasch \ 2) And &H55) Or ((Rnd * 256) And &HAA))
            passw = passw & Chr$((pasch And &H55) Or ((Rnd * 256) And &HAA))
         Next
      End If

End Sub

Sub encodehex(passw As String)
'-----------------------------------------------------------------------------
'30Oct94 CKJ Written. Returns an decoded hex string
'-----------------------------------------------------------------------------
Dim pasin As String, plen%, iByte%, pasch%

   plen = Len(passw)
   pasin = passw
   passw = ""
   If plen Then
         Randomize Timer
         For iByte = 1 To plen
            pasch = Asc(Mid$(pasin, iByte))
            passw = passw & Right$("0" & Hex$(((pasch \ 2) And &H55) Or ((Rnd * 256) And &HAA)), 2)
            passw = passw & Right$("0" & Hex$((pasch And &H55) Or ((Rnd * 256) And &HAA)), 2)
         Next
      End If

End Sub

Sub Err70msg(ErrNum As Integer, Description$)
'-----------------------------------------------------------------------------
' Test for Permission Denied error, and pop message if found
'21Feb91 CKJ Checks for error 63 & 70 now
'29Apr02 CKJ Now calls Err70MsgEx. Added 'as integer'
'-----------------------------------------------------------------------------

   Err70MsgEx ErrNum, Description$, "", "External", ""

End Sub

Sub Err70MsgEx(iErrnum As Integer, sDescription As String, sExplanation As String, sModule As String, sProcedure As String)
'-----------------------------------------------------------------------------
' Test for Permission Denied error, and pop message if found
'21Feb91 CKJ Checks for error 63 & 70 now
'29Apr02 CKJ Created from Err70Msg, added params & more description
'-----------------------------------------------------------------------------
Dim sMsg As String
Dim sHeader As String

   Select Case iErrnum
      Case 70                                         ' permission denied
         sHeader = "Paused (Code 70)"
         sMsg = "Program paused - unable to access information requested." & Chr$(13)
         sMsg = sMsg & "Another terminal has locked" & Chr$(13)
      
      Case 63                                         ' Bad Record Number
         sHeader = "Paused (Code 63)"
         sMsg = "Program paused - unable to access information requested." & Chr$(13)
         sMsg = sMsg & "Another terminal is probably using" & Chr$(13)
      
      End Select

   If Len(sMsg) Then
         sMsg = sMsg & sDescription & Chr$(13)
         If Len(sExplanation) Then sMsg = sMsg & Chr$(13) & "Details:" & Chr$(13) & sExplanation & Chr$(13)
         If Len(sModule) Then sMsg = sMsg & "Module: " & sModule & Chr$(13)
         If Len(sProcedure) Then sMsg = sMsg & "Procedure: " & sProcedure & Chr$(13)
         sMsg = sMsg & Chr$(13) & "Please select OK to try again"
         MsgBox sMsg, MB_ICONEXCLAMATION, sHeader
      End If

End Sub

Function ErrorHandler(ErrNum As Integer, MODULE As String, procname As String) As Boolean
'23Feb96 CKJ/KR Moved Err 76 to the Case Else
'29Apr02 CKJ Now calls ErrorHandlerEx. Retained for compatibility with external modules
                                                            
   ErrorHandler = ErrorHandlerEx(ErrNum, MODULE, procname, "")

End Function

Function ErrorHandlerEx(ErrNum As Integer, MODULE As String, procname As String, sExtMessage As String) As Boolean
'23Feb96 CKJ/KR Moved Err 76 to the Case Else
'29Apr02 CKJ Added extended message parameter. Renamed from ErrorHandler

Dim ErrMsg As String, msg As String
Dim iChan As Integer

   Select Case ErrNum
      Case 70, 63            ' Permission denied, bad record number, the only two errors so far attributable to locking
         ErrorHandlerEx = 1  ' resume  next
      'Case 76                '!!** when is this invoked?
      '   errmsg = "Error No. : " & Str$(Errnum) & " File path entered incorrectly."
      '   MsgBox errmsg, 0, "ASCribe"
      '   ErrorHandler = 1    'Resume Next
      Case Else
         Select Case ErrNum
            Case 57:   ErrMsg = "Device I/O Error."
            Case 64:   ErrMsg = "Bad File Name."
            Case 68:   ErrMsg = "Device Unavailable."
            Case 71:   ErrMsg = "Disk not ready."
            Case 76:   ErrMsg = "Path not found."
            Case 255:  ErrMsg = "File Name is null."
            Case Else                                                                  '29Apr02 CKJ Added
               ErrMsg = Error$
               If Len(ErrMsg) = 0 Then ErrMsg = Error$(ErrNum)
            End Select

         msg = "The following error has occurred which prevents the program from continuing:" & Chr$(13) & Chr$(13)
         msg = msg & "Module   : " & MODULE & Chr$(13)
         msg = msg & "Routine  : " & procname & Chr$(13)
         msg = msg & "Error No.: " & Str$(ErrNum) & "    " & ErrMsg & Chr$(13) & Chr$(13)
         msg = msg & "Please contact your system administrator."

         msg = msg & cr & cr & "INFORMATION:" & cr                                     '29Apr02 CKJ Added new block
         msg = msg & "Date: " & Format$(Now, "ddmmmyyyy hh:nn:ss") & cr
         msg = msg & "App.title: " & App.title & cr
         msg = msg & "App.name: " & App.EXEName & cr
         msg = msg & "App.path: " & App.Path & cr
         msg = msg & "User: " & UserID$ & "     " & UserFullName$ & cr
         msg = msg & "Terminal: " & ASCTerminalName() & cr
''         msg = msg & "Command: " & g_command & cr
         msg = msg & "CurrentPath: " & CurDir$ & cr
         msg = msg & "Dispdata: " & dispdata$ & cr
         msg = msg & "Patdata: " & patdatapath$ & cr
         If Len(sExtMessage) Then msg = msg & cr & sExtMessage & cr

         popmessagecr ".EMIS Health", msg

         'Attempt to write a copy to to C:
         replace msg, crlf, Chr$(0), 0
         replace msg, cr, Chr$(0), 0
         replace msg, lf, Chr$(0), 0
         replace msg, Chr$(0), crlf, 0
         On Error Resume Next
         iChan = FreeFile
         Open "C:\ASCribe.log" For Append As #iChan
         Print #iChan, msg
         Close #iChan                                                                  '29Apr02 CKJ end of new block

''         Close    'Close all open files
''         END!      'exit the application
      End Select

End Function

Function ExpandExp$(Number$)
'19Jul99 AE Written
' Given a string containing a numerical value, checks for exponents in 'D' or 'E' form,
' and expands them.
' -ve Signs are retained, trailing spaces and zeros are removed, even if no exponent is found
'09Feb01 CKJ Corrected handling of non-Boolean values, "D" type exponents, undefined exit value and simplified logic (#49273)

Dim Neg%, ExPos%, Xval%, pntpos%, num$

   num$ = UCase$(Trim$(Number$))                                             'remove spaces

   If Left$(num$, 1) = "-" Then                                              'Check for negative number.  Remove "-" sign
         Neg = True                                                          'and replace it later
         num$ = Mid$(num$, 2)
      End If
   
   ExPos = InStr(num$, "D")                                                  'check for exponents
   If ExPos = 0 Then ExPos = InStr(num$, "E")
   
   If ExPos Then
         Xval = Val(Mid$(num$, ExPos + 1))                                   'remove the exponent part of the string
         num$ = Left$(num$, ExPos - 1)                                       'and store the mantissa value

         pntpos = InStr(num$ & ".", ".")                                     'find decimal point (comparison uses extra one)
         num$ = Left$(num$, pntpos - 1) & Mid$(num$, pntpos + 1)             'remove decimal point if present
         pntpos = pntpos + Xval                                              'Calculate new dp position
      
         Select Case pntpos                                                  'replace the dp and add zeros
            Case Is < 1                                                      'position  0 => add ".0", -1 => add ".00" etc
               num$ = "." & String$(Abs(pntpos) + 1, "0") & num$             '123' => '.00000123' to '.0123'
            Case Is > Len(num$) + 1                                          'position +2 => add "0.", +3 => add "00." etc
               num$ = num$ & String$(pntpos - Len(num$) - 1, "0") & "."      '123' => '1230.' to '12300000.'
            Case Else                                                        'within the number or immediately after it
               num$ = Left$(num$, pntpos - 1) & "." & Mid$(num$, pntpos)     '123' => '.123' '1.23' '12.3' '123.'
            End Select
            
         Do While Left$(num$, 1) = "0"                                       'remove leading zeros
            num$ = Mid$(num$, 2)
         Loop
                                                                             'remove trailing zeros
         Do While Right$(num$, 1) = "0"
            num$ = Left$(num$, Len(num$) - 1)
         Loop
                                                        
         If Left$(num$, 1) = "." Then num$ = "0" & num$                      'convert ".nnn" to "0.nnn"
         If Right$(num$, 1) = "." Then num$ = Left$(num$, Len(num$) - 1)     'remove dp if a whole number
      End If

   If Neg Then num$ = "-" & num$                 'Replace minus sign if appropriate

   ExpandExp = num$
   


End Function

Function fileexists(drvpthfilext$) As Boolean
'-----------------------------------
'11Aug90 CKJ New version, works over Novell
' 1Feb91 CKJ use integer array in DGROUP for PDS 7
' 3Feb90 CKJ replaced by PDS DIR$ from ASC's version
'            Problems 1) null filenames return first file in directory
'                     2) routine will not find SYS or hidden files
'                     3) recursion cannot be supported, since we do not have
'                         access to the dta used by PDS7
'            1) easily solved, but 2&3) remain
'            Do not delete the commented-out code, as it may be re-used.
' 4Apr92 CKJ Added 'bad file name' to list of errors which return 'false'
' 8Apr92 CKJ Firefighting - why does fileexists seem to miss seeing Translog?
'22Jun92 ASC Retry added to error 57 including writlog to disc in ASCROOT
'            error hidden to user until 30th time
'17Aug92 CKJ corrected error in error handling of null filename
' 8Nov94 CKJ Converted to text box.
'            To continue the prog hold one (either) shift & press return
'            To end prog hold both shift keys & press return
'            Return alone redisplays the box
'20Jan95 CKJ Don't check for Std I/O for 'file' present
'23Feb96 CKJ/KR Merged DOS/Win versions
'09Apr96 CKJ Trapped error 76, path not found
'            DOS version simply returned "" from Dir$, VBWin errors.
'            Now this version also treats path not found as file not found = true
'13Dec96 CKJ Changed ASCROOT$ to rootpath$
'16Dec96 CKJ Changed the 'dire warning' box to have retry & cancel buttons
'19Dec96 EAC Changed log file to write to \TRANSLOG
'12May97 CKJ user$ -> UserID$, site% -> 0 since neither were in scope
'01Feb00 AE  Added Check for Overnight Job, to point to the correct drive. Will
'            Not affect the normal running of this procedure, as ONJLivePath will not be
'            set except in the overnight job.
'20May02 CKJ Major changes to the logic, including retries from most error types
'            Changed to fixed test from .044 file, as file may not be available during error
'            Added logging & modified displayed message extensively

Dim complete%, failed%, filespec$, msg$, button%, NumOfTimes%, intButtons As Integer
Dim iChan As Integer, strError As String

   '20Jan95 CKJ Don't check for Std I/O
   Select Case UCase$(Trim$(drvpthfilext$))
      Case "PRN", "PRN:", "LPT1", "LPT1:", "LPT2", "LPT2:", "LPT3", "LPT3:"
         fileexists = True
      Case ""
         On Error GoTo FileExists_Err
         Error 255

      Case Else
         Do
            complete = False
            failed = False
            filespec$ = ""
            On Error GoTo FileExists_Err
            filespec$ = Dir$(drvpthfilext$)
            On Error GoTo 0
            If Not failed Then
                  fileexists = Not (filespec$ = "")
                  complete = True
               End If
         Loop Until complete
      End Select
Exit Function

FileExists_Err:
   ErrNum = Err
   strError = Error
   If ErrNum = 76 Then Resume Next            '9Apr96 CKJ Added. 76=Path not found
   
   'Most common errors seen so far...
   'error 57 - Device I/O error"
   'error 64 - Bad file name"
   'error 68 - device unavailable"
   'error 71 - disk not ready"
   'error 53 - file not found
   'error 75 - Path/File access error
   msg$ = Format$(ErrNum) & "  " & strError           'standard message
   intButtons = MB_OK                                 'assume cannot retry
   Select Case ErrNum
      Case 255:  msg$ = "255, File name is blank"     'pseudo error code
      Case 64:                                        'no action needed
      Case Else: intButtons = MB_RETRYCANCEL          'error may disappear on retry
      End Select
   msg$ = " Procedure FileExists cannot open '" & drvpthfilext$ & "'" & cr & cr & " Error " & msg$ & cr & cr
   msg$ = msg$ & "This may indicate a network, server or configuration problem." & cr
   msg$ = msg$ & "Please ask your System Manager for advice" & cr
   msg$ = msg$ & "before switching off or restarting this computer" & cr & cr
   If intButtons = MB_RETRYCANCEL Then
         msg$ = msg$ & "Select the Retry button if the problem may be temporary" & cr
         msg$ = msg$ & "or select the Cancel button to halt the program now." & cr
      Else
         msg$ = msg$ & "This program will now halt." & cr
      End If
         
   msg$ = msg$ & cr & cr & "INFORMATION:" & cr
   msg$ = msg$ & "Date: " & Format$(Now, "ddmmmyyyy hh:nn:ss") & cr
   msg$ = msg$ & "App.title: " & App.title & cr
   msg$ = msg$ & "App.name: " & App.EXEName & cr
   msg$ = msg$ & "App.path: " & App.Path & cr
   msg$ = msg$ & "User: " & UserID$ & "     " & UserFullName$ & cr
   msg$ = msg$ & "Terminal: " & ASCTerminalName() & cr
''   msg$ = msg$ & "Command: " & g_command & cr
   msg$ = msg$ & "CurrentPath: " & CurDir$ & cr
   msg$ = msg$ & "Dispdata: " & dispdata$ & cr
   msg$ = msg$ & "Patdata: " & patdatapath$ & cr
   msg$ = msg$ & "Retry number: " & Format$(NumOfTimes) & cr
   
   button = MsgBox(msg$, MB_ICONSTOP + intButtons, "Stop")    '16Dec96 CKJ Changed from [OK] to [Retry][Cancel] with Stop icon
   If button = IDCANCEL Or button = IDOK Then
         WriteLog transpath$ & "\filexst.log", 0, UserID$, drvpthfilext$ & " error " & Str$(ErrNum) & " re-try " & Str$(NumOfTimes) & "HALTED"
         'Attempt to write a copy to to C:
         replace msg$, crlf, Chr$(0), 0
         replace msg$, cr, Chr$(0), 0
         replace msg$, lf, Chr$(0), 0
         replace msg$, Chr$(0), crlf, 0
         On Error Resume Next
         iChan = FreeFile
         Open "C:\ASCribe.log" For Append As #iChan
         Print #iChan, msg
         Close #iChan

''         Close
''         END!                                             '<=== FORCE END OF PROGRAM
      End If
   
   NumOfTimes = NumOfTimes + 1
   WriteLog transpath$ & "\filexst.log", 0, UserID$, drvpthfilext$ & " error " & Str$(ErrNum) & " re-try " & Str$(NumOfTimes)
   failed = True
Resume Next

End Function

Function FileNameFromChannel(intChannel As Integer) As String
'29Apr02 CKJ Written
'27May04 CKJ Corrected

Dim strFilename As String
      
   strFilename = ""
   
   Select Case intChannel
      Case 1 To 32: strFilename = msOpenedChannels(1, intChannel)
      Case Else:    strFilename = "[Invalid channel number:" & Str$(intChannel) & "]"
      End Select
   If Len(strFilename) = 0 Then strFilename = "unknown file name"

   FileNameFromChannel = strFilename

End Function

Sub FillHeapStandardInfo(HeapID)
'Copied from a section of ParseItems. Used to expose commmon info which is always available
'ie, not patient or drug specific.
'02Sep99 AE Written
Dim success%
           
   Heap 10, HeapID, "userid", UserID$, success                'refresh common items
   Heap 10, HeapID, "username", UserFullName$, success
   Heap 10, HeapID, "terminal", ASCTerminalName(), success
   Heap 10, HeapID, "today", Format$(Now, "dd mmm yyyy"), success
   Heap 10, HeapID, "timenow", Format$(Now, "h:mm am/pm"), success

End Sub

''    Not feasible under VB6 - file channel is not exposed
''Sub FlushBuffers(chan%)
'''-----------------------------------------------------------------------------
'''                 Flush data held in I/O buffers to disk
'''
'''  Set Chan% to the channel number of an open file to be flushed,
'''  zero to flush all channels from 1 to 255,
'''  or a negative number, eg -30 in which case channels 1 to 30
'''    (if open) will be flushed.
'''
'''  No error occurs if invalid channel numbers are used - they are ignored.
'''  NB It may take 2-3 secs to scan 255 channels.
'''
'''14Apr91 CKJ Procedure written. NB Requires DOS 3.3 or higher
'''-----------------------------------------------------------------------------
''Dim startchan%, endchan%, flushchan%, DOShandle%
''
''   If chan = 0 Or Abs(chan) > 255 Then chan = -255
''
''   If chan < 0 Then
''         startchan = 1
''         endchan = Abs(chan)
''      Else
''         startchan = chan
''         endchan = chan
''      End If
''
''   For flushchan = startchan To endchan
''      '!!V93!! API**   FileAttr(2) Not supported
''      'Declare Function FlushFileBuffers Lib "kernel32" (ByVal hFile As Long) As Long
''   Next
''
''End Sub

Sub FlushIniCache()
           
   If iniHeapID Then Heap 2, iniHeapID, "", "", 0
   iniHeapID = 0
   
   If fileHeapID Then Heap 2, fileHeapID, "", "", 0
   fileHeapID = 0

End Sub

Sub FlushLookupCache()
           
   Dim LookupHeapId As Integer
   LookupHeapId = GetLookupHeapId()
                  
   If LookupHeapId Then Heap 2, LookupHeapId, "", "", 0
   SetLookupHeapId 0
   
End Sub

Private Function fLX(LinkID$, Token&) As String
'Licence control procedure
' All handling of the licence file is done here
' - read once, hold as static data & hand out data on demand
' Call at start of program to fill    Ret$ = Flx("", Token&)
' Ret$ is blank on first call, Token& is not used yet.
' NB if routine fails to read a valid set of data program ends.

'Once read into Txt$, each entry is of the format [10]item=value[13]

Static txt$
Dim pathfileext$, success%, tmp$, ret$, posn%, posn1%
                      
   success = False
   ret$ = ""
   If txt$ = "" Then                                           'not already loaded
         pathfileext$ = dispdata$ & "\ascribe.lx"
         If fileexists(pathfileext$) Then                      'file found
               GetTextFile pathfileext$, txt$, success
               If success Then
                     decodehex txt$
                     txt$ = Chr$(10) & txt$ & cr
                     'encodehex Txt$
                     'PutTextFile pathfileext$, Txt$, success
                  End If
            End If
      Else
         success = True
      End If

   If success And LinkID$ <> "" Then
         tmp$ = Chr$(10) & LinkID$ & "="
         posn = InStr(1, txt$, tmp$, 1)                        'case independent
         If posn Then
               posn1% = InStr(posn + Len(tmp$), txt$, cr)      'look for end of string
               fLX$ = Mid$(txt$, posn + Len(tmp$), posn1 - Len(tmp$) - posn)
            End If
      End If

End Function

Sub freespace(ByVal Drive$, totsize&, freeroom&)
'------------------------------------------------
' returns tot disc size & free space for any disc
' default disc used if drive$=""
' otherwise drive$ may be "a" or "A" through to last valid drive
' If an error occurs then totsize& is returned as 0, results are invalid
'24Oct97 CKJ clustdrv& and freeclust& were integers
'04Jun04 CKJ 32bit: NB still only OK up to 2GB - consider using GetDiskFreeSpaceEx

Dim secPerClus As Long      'sectors per cluster
Dim bytePerSec As Long      'bytes   per sector
Dim freeClus As Long        'number of free clusters
Dim totalClus As Long       'total number of clusters
Dim retval As Long

   If Drive$ = "" Then
        getdrive (Drive$)
        Drive$ = Drive$ & ":\"
     End If
   
   retval = GetDiskFreeSpace(Drive$, secPerClus, bytePerSec, freeClus, totalClus)

   totsize& = totalClus * secPerClus * bytePerSec
   freeroom& = freeClus * secPerClus * bytePerSec

End Sub

Sub GetCountry(country%)
'14Nov00 CKJ Added system-wide setting for country
'            Previously this had to be set on each PC either as an environment variable in Autoexec.bat or similar
'            eg SET Country="061"
'            or as the regional settings in control panel
'            Now, add the following line to Siteinfo.ini default section
'            []
'            Country="061"
'            This is tested between the original two, so the net effect is as follows
'            Use country defined in Autoexec.bat if present
'             otherwise use country defined in Siteinfo.ini if present
'             otherwise use country in regional settings
'            If all else fails then use 044
'            Note: GetProfileString is not used for siteinfo.ini since it performs badly when the network is inadequate.
'            However it is used for the regional settings since this is always on the local machine and is mapped to a
'            registry entry on NT without changing the call.
'            The result of the test is also held as a static, preventing the need to check every time.

Static iCountry As Integer

Dim lpreturnstring As String, iResult As Integer
Dim iChan As Integer, sFilename As String
Dim sText As String, iPosn As Integer
Dim strParams As String
Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "GetCountry"

   On Error GoTo ErrorHandler

   If iCountry = 0 Then
      iCountry = Val(Environ$("COUNTRY"))
      
''         If iCountry = 0 Then                                            'read country=xx in siteinfo.ini
''            sFilename = "\DISPDATA." & Format$(Val(g_command), "000") & "\siteinfo.ini"
''            If fileexists(sFilename) Then
''                  iChan = FreeFile
''                  Open sFilename For Binary As #iChan
''                  sText = Space$(LOF(iChan))
''                  Get #iChan, , sText                                 'read whole file as one string
''                  Close iChan
''                  iPosn = InStr(LCase$(sText), crlf & "country")      'look for <CrLf>Country = ...
''                  If iPosn Then                                       'found it
''                        sText = LTrim$(Mid$(sText, iPosn + 9))        'trim to leave "= ..."
''                        If Left$(sText, 1) = "=" Then                 'remove the equals and subsequent spaces
''                              sText = LTrim$(Mid$(sText, 2))          'now is 061... or "061"...
''                              If Left$(sText, 1) = Chr$(34) Then      'remove the " character if present
''                                    sText = LTrim$(Mid$(sText, 2))
''                                 End If
''                              iCountry = Val(Left$(sText, 3))         'should ignore any trailing characters including "
''                           End If
''                     End If
''                End If
''         End If
      
   If iCountry = 0 Then
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, "D|Siteinfo") & _
                  gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 255, "") & _
                  gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 255, "Country")
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWConfigurationSelectValue", strParams)
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               lpreturnstring = RtrimGetField(rs!Value)
               If Left$(lpreturnstring, 1) = Chr$(34) Then lpreturnstring = Mid$(lpreturnstring, 2)
               If Right$(lpreturnstring, 1) = Chr$(34) Then lpreturnstring = Left$(lpreturnstring, Len(lpreturnstring) - 1)
               iCountry = Val(lpreturnstring)
            End If
            rs.Close
         End If
      End If
   End If
      
'09May05 CKJ Win.ini deprecated
'»         If iCountry = 0 Then
'»               lpreturnstring = Space$(512)
'»               iResult = GetProfileString("intl", "iCountry", "FAILED", lpreturnstring, 512)
'»               lpreturnstring = Trim$(asciiz$(lpreturnstring))
'»               iCountry = Val(lpreturnstring) '44
               If iCountry = 0 Then iCountry = 44   '19Oct04 TH Reinstated
'»            End If
   End If

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   country = iCountry
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub

Sub getdrive(Drive$)
' returns current default drive as single upper case letter A, B, C, etc

   Drive$ = Left$(CurDir$, 1)
                                   
End Sub

Function GetField(fld As ADODB.field) As Variant
' 2Apr96 CKJ Written
'            Avoids 'Invalid use of Null' problems by assigning
'            zero, "" or date'0' as appropriate.
'14Oct96 CKJ Null date now returns 0# not 31-12-1899
'23aug04 ckj rewritten for adodb
'
'ADODB.DataTypeEnum
' adDate = 7
' adDBDate = 133
' adDBTime = 134
' adDBTimeStamp = 135
' adCurrency = 6
' adBSTR = 8
' adChar = 129
' adWChar = 130
' adVarChar = 200
' adLongVarChar = 201
' adVarWChar = 202
' adLongVarWChar = 203
' adArray = 8192

'  Boolean
'  Byte
'  Integer
'  Long
'  currency
'  single
'  double
'  text
'  longbinary
'  memo

   If IsNull(fld) Then
         Select Case fld.Type
            Case 7, 133, 134:             GetField = 0#
            Case 8, 129, 130, 200 To 203: GetField = ""
            Case Else:                    GetField = 0
            End Select
      Else
         GetField = fld
      End If

End Function

Function RtrimGetField(fld As ADODB.field) As Variant
'23aug04 CKJ based on GetField, but Rtrims the text and memo types

   If IsNull(fld) Then
         Select Case fld.Type
            Case 7, 133, 134:             RtrimGetField = 0#  'Format$(0, "dd-mm-yyyy")
            Case 8, 129, 130, 200 To 203: RtrimGetField = ""
            Case Else:                    RtrimGetField = 0
            End Select
      Else
         Select Case fld.Type
            Case 8, 129, 130, 200 To 203: RtrimGetField = RTrim$(fld)
            Case Else:                    RtrimGetField = fld
            End Select
      End If

End Function

Sub GetIniHeapId(o_intFileHeapID As Integer, o_intINIHeapId As Integer)

'To return the ID of the ini file heaps for debugging purposes (cache dumps)
'19Sep00 AE

   o_intFileHeapID = fileHeapID
   o_intINIHeapId = iniHeapID

End Sub
Sub GetPointerDisk(FILE$, pointer&, Increment%)
'-----------------------------------------------------------------------------
'ASC 8 Nov 90       Reads pointer at beginning of RAM file
'
'
' If increment =  0   reads pointer                       (i.e. inc = FALSE)
'              = -1  reads pointer and adds one and saves (i.e. inc = TRUE )
'              =  1   reads pointer and takes one and saves
'              =  2   writes pointer
'              =  3   reads pointer locks it
'              =  4   unlocks pointer
'
' 7Aug91 CKJ Proc moved to DFHL from Subpatme
'17Jun92 ASC seperate locking and unlocking added for order numbers
'21Dec93 CKJ/ASC inc=2 used to write NEW value, but return OLD value
'                         now writes NEW value and returns NEW value
'23Feb96 CKJ et al Corrected Lock range, removed increment 3/4
'            Tidied as per DOS version
'22Nov01 CKJ/TH Logical flaw found - error 63 (Bad record number) could escape the
'               trapping and proceed into reading without achieving a lock
'               Corrected and added logging
'29apr02 CKJ Added extended message
'10Feb03 CKJ Added selective logging of successful read/increment/decrement/write calls
'            Uses optional entries in ascribe.ini, default is not to log.
'            [GetPointer]
'            f:\patdata.001\pmr.v5=f:\patdata.001\pmrv5.log
'            f:\dispdata.001\supfile.v5=
'            In the example above, the PMR is logged to a specific file,
'            whereas requis is logged to the default file which is
'            <default drive>\<current dispdata>\GetPtr.log
'            Note that many files can be accessed from multiple dispdatas,
'            so these should be logged to a single specific location.
'            The file name above must be exactly as used in the program -
'            this may not include the drive letter so check carefully.
'08Nov05 CKJ Obsolete procedure. Renamed to allow finding of any remaining calls

'mods needed
' - take whole structure for record one then take pointer
' - use of chan = 0 will only work while only one file in the system needs locking
'-----------------------------------------------------------------------------
Dim p As pointertype, chan%, currentpoint&, retries%
Dim intDummy As Integer
Dim strMsg As String
Dim sMsg As String

Dim blnLogging As Integer              '10Feb03 CKJ
Dim strLogFile As String
Dim strLogText As String
Dim strDispdataAtStart As String

   procname$ = "getpointer"

   Select Case Increment
      Case 3, 4
         popmessagecr ".Warning:", "Corelib: GetPointer called with increment = " & Format$(Increment)
''         Close
''         END!
         Exit Sub
      End Select

   popmessagecr ".Warning:", "Corelib: Procedure GetPointer called - inform EMIS Health" & crlf & "Replace with GetPointerSQL"

   openrandomfile FILE$, 4, chan
   
   currentpoint& = pointer&
   retries = 0

   Do
      On Error GoTo GetPointer_Err
      ErrNum = 0
      Lock #chan, 1 To 4
      'If errnum = 70 Then                                                    '22Nov01 CKJ/TH Resume happens with Err 63 as well as 70
      Select Case ErrNum
         Case 63, 70
            If ErrNum = 63 Then                                               '   "           Log 63 'Bad Record Number'
                  strMsg = "Error 63, " & FILE$ & ", " & Format$(pointer&) & ", " & Format$(Increment)
                  WriteLog "c:\GetPoint.log", 0, UserID$, strMsg              '   "
                  WriteLog transpath$ & "\GetPoint.log", 0, UserID$, strMsg
               End If
            
            If retries < 5 Then
                  retries = retries + 1
                  waitforticks 10
               Else
                  'Err70msg errnum, "Pointer"                                                               '29Apr02 CKJ
                  sMsg = "Action=Lock, Value=" & Format$(pointer&) & ", Increment=" & Format$(Increment)
                  Err70MsgEx ErrNum, "Pointer record in " & FILE$, sMsg, m_strModuleName, procname$
               End If
         
         Case 0                                                               '   "   was ELSE
            On Error GoTo 0
            retries = 0
            Do
               On Error GoTo GetPointer_Err
               ErrNum = False
               Get #chan, 1, p
               'Err70msg errnum, "Pointer record (read)"                                                    '29Apr02 CKJ
               sMsg = "Action=Read, Value=" & Format$(pointer&) & ", Increment=" & Format$(Increment)
               Err70MsgEx ErrNum, "Pointer record in " & FILE$, sMsg, m_strModuleName, procname$
            Loop While ErrNum

            pointer& = p.ptr

            If Abs(Increment%) = 1 Then ' 6Aug91 CKJ Copes with inc/dec
                  pointer& = pointer& - Increment%
                  p.ptr = pointer&
                  Put #chan, 1, p
''                  FlushBuffers chan    Not feasible under VB6 - file channel is not exposed
               End If

            If Increment% = 2 Then
                  p.ptr = currentpoint&
                  Put #chan, 1, p
''                  FlushBuffers chan    Not feasible under VB6 - file channel is not exposed
                  pointer& = currentpoint&                 '21Dec93 CKJ Added
               End If

            Unlock #chan, 1 To 4
         
            '10Feb03 CKJ Added logging block
            strLogFile = TxtD(dispdata$ & "\ascribe.ini", "GetPointer", "", FILE$, blnLogging)
            If blnLogging Then
                  If strLogFile = "" Then strLogFile = dispdata$ & "\GetPtr.log"
                  'ByVal Text$, char$, length%, justify$)
                  strLogText = "File: " & FILE$ & " Pointer:" & PadVar$(Format$(pointer&), " ", 12, "R") & " Increment: " & Str$(Increment%) & " Terminal: " & ASCTerminalName$()
                  strDispdataAtStart = siteinfo$("dispdataDRV", "") & "\dispdata." & siteinfo$("dispdataEXT", Format$(SiteNumber, "000"))
                  If dispdata$ <> strDispdataAtStart Then                                                   'not using own dispdata e.g. ordering
                        strLogText = strLogText & " Dispdata now: " & dispdata$ & " own: " & strDispdataAtStart
                     End If
                  WriteLog strLogFile, SiteNumber, UserID$, strLogText
               End If

         Case Else                                                            '   "   added as belt & braces. Should be impossible
            strMsg = "Getpointer ended with unexpected error " & Format$(ErrNum) & ", " & FILE$ & ", " & Format$(pointer&) & ", " & Format$(Increment)
            WriteLog "c:\GetPoint.log", 0, UserID$, strMsg
            WriteLog transpath$ & "\GetPoint.log", 0, UserID$, strMsg
            'intDummy = ErrorHandler(errnum, "WDFHL", "GetPointer")            '   "   error which will always halt the program         '29apr02 CKJ
            sMsg = "Filename: " & FILE$ & cr & "Parameters: Pointer=" & Format$(pointer&) & ", Increment=" & Format$(Increment)
            intDummy = ErrorHandlerEx(ErrNum, "WDFHL", "GetPointer", sMsg)       '   "   error which will always halt the program
            '-- ENDED in ErrorHandler --
            
         End Select                                                           '   "   was End If
   Loop Until retries = 0

   Close #chan
   
   On Error GoTo 0
Exit Sub

GetPointer_Err:
   ErrNum = Err
   'If ErrorHandler(errnum, "WDFHL", "GetPointer") = 1 Then Resume Next                                                                 '29apr02 CKJ
   sMsg = "Filename: " & FILE$ & cr & "Parameters: Pointer=" & Format$(pointer&) & ", Increment=" & Format$(Increment)
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", "GetPointer", sMsg) = 1 Then Resume Next

End Sub

Sub GetPointerSQL(FILE$, pointer&, Increment%)
'-----------------------------------------------------------------------------
'ASC 8 Nov 90       Reads pointer at beginning of RAM file
'
'
' If increment =  0   reads pointer                       (i.e. inc = FALSE)
'              = -1  reads pointer and adds one and saves (i.e. inc = TRUE )
'              =  1   reads pointer and takes one and saves
'              =  2   writes pointer
'              =  3   reads pointer locks it
'              =  4   unlocks pointer
'

'mods needed
' - take whole structure for record one then take pointer
' - use of chan = 0 will only work while only one file in the system needs locking
'-----------------------------------------------------------------------------
'18May05 TH Added write section (increment = 2) and removed original err raise on this section
'06Sep10 TH Changed Write of pointer for Ascroot types (using DSSMastersiteID rather than siteID) - need to write this for UMMC FINV (F0054531)

''Dim p As pointertype, chan%, currentpoint&
Dim strParams As String
Dim lngPointer As Long
Dim intResult As Integer
Dim strPrefix As String
Dim intlastSlash As Integer
Dim strCategory As String
Dim strFile As String
Dim SiteID As Long

   procname$ = "GetpointerSQL"

   Select Case Increment
      Case 3, 4
         Err.Raise 32767, procname$, "Warning: Program Halted. Corelib: GetPointerSQL called with increment = 3 or 4"

      Case True, 1
         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            SiteID = gDispSite
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            SiteID = gPatientSite
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = gDispSite      ''**!!** Check that this is a valid assumption
            SiteID = GetDSSMasterSiteFromSiteID(gDispSite) '20Feb06 TH It wasnt
         End If
         'Convert the pathfile string to something useful for SQL
         
         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         If strPrefix = "A" Then
            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)
            If Increment = 1 Then
               lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerDecrementbyDSSMasterSiteID", strParams)
            Else
               lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerIncrementbyDSSMasterSiteID", strParams)
            End If
         Else
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)
                           
            If Increment = 1 Then
               lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerDecrement", strParams)
            Else
               lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerIncrement", strParams)
            End If
         End If
      Case 0
         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            SiteID = gDispSite
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            SiteID = gPatientSite
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = gDispSite      ''**!!** Check that this is a valid assumption
            SiteID = GetDSSMasterSiteFromSiteID(gDispSite) '20Feb06 TH It wasnt
         End If
         
         'Convert the pathfile string to something useful for SQL
         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         If strPrefix = "A" Then
            strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)
            
            lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerReadbyDSSMasterSiteID", strParams)
         Else
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)
            
            lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerRead", strParams)
         End If
         ' IF lngPointer is 0 then do Insert and put the new pointer !!
         'NO ! Now We Need to inform the user so they can put it in correctly. This is trapped below
         
      Case 2
         '18May05 TH Added as required in Manufacturing and removed original err raise on this section
         'Write to existing pointer record
         
         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            SiteID = gDispSite
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            SiteID = gPatientSite
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = gDispSite      ''**!!** Check that this is a valid assumption
            SiteID = GetDSSMasterSiteFromSiteID(gDispSite)  '06Sep10 TH No it wasnt - need to write for UMMC FINV (F0054531)
         End If
         
         'Convert the pathfile string to something useful for SQL
         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         '''Err.Raise 32767, procname$, "Warning: Corelib.GetPointer called with increment type 2" & crlf & "Not supported in this version. Inform Ascribe."
         If strPrefix = "A" Then
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                        gTransport.CreateInputParameterXML("Pointer", trnDataTypeint, 4, pointer&)
            
            lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerWritebyDSSMasterSiteID", strParams)
         Else
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, SiteID) & _
                        gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                        gTransport.CreateInputParameterXML("Pointer", trnDataTypeint, 4, pointer&)
            
            lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerWrite", strParams)
         End If
      End Select

   pointer& = lngPointer
''   currentpoint& = lngPointer
   
   If lngPointer < 0 Then
      'Here We Raise an error and inform the user that data is missing and needs to be rectified
      Err.Raise 32767, procname$, "Pointer record " & strCategory & " is missing from the database"
   End If

End Sub

Function GetRAMSize(txt$) As Long
' 8Jan98 CKJ Written. Returns total RAM as long, plus a text block for debugging.

'**GONE**
'»Dim mmi As TagMemManInfo
Dim s$, X%

'»   mmi.dwSize = Len(mmi)
'»   x% = MemManInfo(mmi)
'»   If x% <> 0 Then
'»         GetRAMSize = mmi.dwTotalPages * 4
'»      Else
'»         GetRAMSize = 0
'»      End If
'»
'»   s$ = "Total RAM installed" & TB & Format$(mmi.dwTotalPages * 4, "#,# Kb") & cr$
'»   s$ = s$ & cr$ & "dwLargestFreeBlock" & TB & Format$(mmi.dwLargestFreeBlock)
'»   s$ = s$ & cr$ & "dwMaxPagesAvailable" & TB & Format$(mmi.dwMaxPagesAvailable)
'»   s$ = s$ & cr$ & "dwMaxPagesLockable" & TB & Format$(mmi.dwMaxPagesLockable)
'»   s$ = s$ & cr$ & "dwTotalLinearSpace" & TB & Format$(mmi.dwTotalLinearSpace)
'»   s$ = s$ & cr$ & "dwTotalUnlockedPages" & TB & Format$(mmi.dwTotalUnlockedPages)
'»   s$ = s$ & cr$ & "dwFreePages" & TB & Format$(mmi.dwFreePages)
'»   s$ = s$ & cr$ & "dwTotalPages" & TB & Format$(mmi.dwTotalPages)
'»   s$ = s$ & cr$ & "dwFreeLinearSpace" & TB & Format$(mmi.dwFreeLinearSpace)
'»   s$ = s$ & cr$ & "wPageSize" & TB & Format$(mmi.wPageSize)

   txt$ = s$

End Function

''Sub GetRecordL(r As filerecord, recno&, Rchan%, RecLen%)
'''-----------------------------------------------------------------------------
''' 26 Sep 90 ASC
''' Opens gets and locks a random access record using a structure r AS filerecord
''' At present r is 1k i.e. bigger than any of our RAM records and the structure
''' for saving is copied using LSET before using getrecord. The length of the
''' record must also be sent in reclen% . Once this procedure is used on a record
''' a matching unlockrecord or putrecord must be done before ending the programme
''' or after finishing with this record to release it for others
'''21Feb91 CKJ Tidied, lockdebug removed
''' 7Aug91 CKJ RecNo now long integer
''' 8Aug91 CKJ Proc renamed from GetRecord to GetRecordL
'''-----------------------------------------------------------------------------
''
''   LockRecord Rchan%, recno&, RecLen%
''   GetRecordNL r, recno&, Rchan%, RecLen%
''
''End Sub

Sub GetRecordNL(r As filerecord, recno&, Rchan%, RecLen%)
'-----------------------------------------------------------------------------
' 4 Oct 90 ASC
' gets a record and releases the lock (NO LOCKING)
'21Feb91 CKJ The previous version Locked, Read, Unlocked ...
'            now it reads without further locking at all.
' 7Aug91 CKJ RecNo now long integer
' 7Apr94 CKJ VBW: Binary access
'29apr02 CKJ Added extended message
'24May11 CKJ Now used by JVM interface - re-enabled
'-----------------------------------------------------------------------------
Dim buffer As String, ByteNo&
Dim sMsg As String

   procname$ = "GetRecordNL"

   buffer = Space$(RecLen%)
   ByteNo& = (recno& - 1) * RecLen + 1

   On Error GoTo GetRecordNL_Err
   Do
      ErrNum = False
      Get #Rchan%, ByteNo&, buffer
      sMsg = "Channel=" & Format$(Rchan) & ", Record Num=" & Format$(recno&) & ", Length=" & Format$(RecLen)
      Err70MsgEx ErrNum, "Record in " & FileNameFromChannel(Rchan), sMsg, m_strModuleName, procname$
   Loop While ErrNum

   On Error GoTo 0
   LSet r.record = buffer

   On Error GoTo 0
Exit Sub

GetRecordNL_Err:
   ErrNum = Err
   sMsg = "Parameters: Record Number=" & Format$(recno&) & ", Channel=" & Format$(Rchan) & ", Length=" & Format$(RecLen)
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", procname$, sMsg) = 1 Then Resume Next

End Sub

Function CheckCharacter(sData As String, sAlgorithm As String) As String
'25Aug99 CKJ Written

Dim lNumPart As Long
Dim iRemainder As Integer

   Select Case UCase$(sAlgorithm)
      Case "UMRN"                          'Australian Universal Medical Record Number
         lNumPart = Val(sData)                                   'always 7 digits - confirm this in calling procedure
         iRemainder = lNumPart Mod 11                            'remainder has values 0-10
         CheckCharacter = Mid$("ABCDEFGHJKL", iRemainder + 1, 1) 'Returns one uppercase letter
      'Case "????"   Add algorithms here
      
      End Select

End Function

Sub copy(FromFile As String, tofile As String)
'-----------------------------------------------------------------------------
'
'           Shell to the DOS copy command. All parameters as normal
'
'24Mar94 CKJ Changed from shell
'??Jan96 KR  Changed to FileCopy from RA read/write
'14Mar96 CKJ Changed back again! FileCopy seemed such a good way of handling
'            copies, unfortunately it doesn't work with devices eg PRN, LPTx
'06Sep99 TH/CFY Enhanced message
'14May02 CKJ Added TrackOpenedFiles
'-----------------------------------------------------------------------------
Dim dummy%, IsPrinter%, RecLen%, iChan%, oChan%, readlen&, records&, remainder%
Dim rec&, buffer$, ans$
          
   If fileexists(FromFile) Then
         dummy = fileexists(tofile)   ' check filename for validity
         'FileCopy fromfile, tofile   '14Mar96 CKJ removed
         
         IsPrinter = False
         Select Case UCase$(Trim$(tofile))
            Case "PRN", "LPT1", "LPT2", "LPT3"
               IsPrinter = True
            Case "PRN:", "LPT1:", "LPT2:", "LPT3:"
               popmessagecr "WARNING", "Cannot copy to device '" & tofile & "', please contact Supervisor"
               Exit Sub
            End Select

         RecLen = 1024

         Do
            On Error GoTo Copy_Err    '17Feb95 CKJ must be in loop
            ErrNum = False
            iChan = FreeFile
            Open FromFile$ For Binary Access Read Write Lock Read Write As #iChan
            'Err70msg errnum, "File"  '!!**  T1("File")                                                                 '29Apr02 CKJ
            Err70MsgEx ErrNum, "File " & FromFile, "attempting to open source file", m_strModuleName, "Copy"
         Loop While ErrNum
         TrackOpenedFiles iChan, FromFile$, "Copy (Source)"                                                             '14May02 CKJ
         Do
            On Error GoTo CopyPrint_Err  '17Feb95 CKJ must be in loop
            ErrNum = False
            oChan = FreeFile
            Open tofile For Output Lock Read Write As #oChan Len = RecLen
            If IsPrinter Then
                  'Err70msg errnum, "Printer " & tofile                                                                 '29Apr02 CKJ
                  Err70MsgEx ErrNum, "Printer " & tofile, "attempting to open target printer", m_strModuleName, "Copy"
               Else
                  'Err70msg errnum, "File"  '!!**  T1("File") '!
                  Err70MsgEx ErrNum, "File " & tofile, "attempting to open target file", m_strModuleName, "Copy"
               End If
         Loop While ErrNum
         TrackOpenedFiles oChan, tofile$, "Copy (Destination)"                                                          '14May02 CKJ
         On Error GoTo 0

         readlen& = LOF(iChan)
         records& = readlen& \ RecLen             ' whole chunks of 1K
         remainder = readlen& - records& * RecLen ' bit of a record at end
         For rec& = 1 To records&
            buffer$ = Space$(RecLen)
            GoSub ReadRecord
            On Error GoTo CopyPrint_Err
            Print #oChan, buffer$;
         Next
         If remainder Then
               'Rec& is 1 or incremented from last time
               buffer$ = Space$(remainder)
               GoSub ReadRecord
               On Error GoTo CopyPrint_Err
               Print #oChan, buffer$;
            End If
''         FlushBuffers oChan    Not feasible under VB6 - file channel is not exposed

         Close iChan
         TrackOpenedFiles iChan, "", ""
         Close oChan
         TrackOpenedFiles oChan, "", ""
      End If
   On Error GoTo 0
Exit Sub

      
ReadRecord:
   Do
      On Error GoTo Copy_Err
      ErrNum = False
      Get #iChan%, (rec& - 1) * RecLen + 1, buffer$
      Err70MsgEx ErrNum, "Record in " & FromFile, Format$(Len(buffer$)) & " Bytes at " & Format$((rec& - 1) * RecLen + 1), m_strModuleName, "Copy"
   Loop While ErrNum
Return

CopyPrint_Err:
   ErrNum = Err
   If IsPrinter Then
         ans$ = "Y"
         askwin "Please Note", "Printer " & tofile & " is not responding" & cr$ & "OK to try again?", ans$, k
         DoSaferEvents 1    '18Sep97 CKJ
         If ans$ = "Y" And Not k.escd Then Resume
      Else
         GoTo Copy_Err
      End If
Resume Next

Copy_Err:
   ErrNum = Err
   If ErrorHandlerEx(ErrNum, "WDFHL", "Copy", "File copy from " & FromFile$ & cr & "to " & tofile$) = 1 Then Resume Next   '06Sep99 TH/CFY Enhanced message    '29apr02 CKJ

End Sub

Sub GetTextFile(pathfileext$, txt$, success%)
'Reads any text file, although intended for RTF
'Returns success=T/F
'17Dec96 CKJ Moved from HighASC.bas
'11Mar98 CKJ Corrected; close chan if file is too large to read
'27May04 CKJ Added TrackOpenedFiles
'03Jul13 TH Extended size of file handled (TFS 67988)

Dim chan%

   success = False
   On Error GoTo GetTextfile_OpenErr
   chan = FreeFile
   Open pathfileext$ For Binary Access Read Shared As #chan
   TrackOpenedFiles chan, pathfileext$, "GetTextFile"         '27May04 CKJ
   On Error GoTo GetTextfile_Err
   'If LOF(chan) < 32768 Then                                  'file is not too long to read
   If LOF(chan) < 10000000 Then           '03Jul13 TH Extend limit (TFS 67988)
         txt$ = Space$(LOF(chan))
         Get #chan, , txt$
         success = True
   Else
      popmessagecr "!", "File : " & pathfileext$ & " is too long to read and cannot be loaded" '03Jul13 TH Added msg in nlikely event this cant be loaded
   End If

GetTextfile_CloseAndExit:                                     '11Mar98 CKJ
   On Error Resume Next
   Close #chan
   TrackOpenedFiles chan, "", ""                              '27May04 CKJ
GetTextfile_Exit:
   On Error GoTo 0
Exit Sub

GetTextfile_OpenErr:
Resume GetTextfile_Exit

GetTextfile_Err:                                              '11Mar98 CKJ
Resume GetTextfile_CloseAndExit

End Sub

Function getYN$(Item)
'set item as follows;
' item returns
'   0  YN
'   1  Y
'   2  N
'   3  Yes   (5 chars)
'   4  No    (5 chars)
'   5  Y/N
'   6  &Yes  (6 chars)
'   7  &No   (6 chars)

'country
'31  Ja    Neen  Dutch
'32  Ja    Neen  Flemish
'33  Oui   Non   French
'34  Si    No    Spanish
'39  Si    No    Italian
'44  Yes   No    English
'45  Ja    Nej   Danish
'46              Swedish
'47              Norwegian
'49  Ja    Nein  German
'358 Kylla Ei    Finnish

Static lastcountry, lastYes$, lastNo$
Dim Yes$, No$, Y$, n$

   GetCountry country

   If country = lastcountry Then
         Yes$ = lastYes$
         No$ = lastNo$
      Else
         If country <> 44 Then
               Yes$ = T1("Yes", "") ' try reading from the country file
               No$ = T1("No", "")
               If Yes$ = "" Or InStr(Yes$, "MISSING") Then country = 44 'default
            End If
         If country = 44 Then   ' English or country file not found
               Yes$ = "Yes"
               No$ = "No"
            End If
      End If

   lastcountry = country
   lastYes$ = Yes$
   lastNo$ = No$

   Y$ = Left$(Yes$, 1)
   n$ = Left$(No$, 1)

   Select Case Item
      Case 0:    getYN$ = Y$ & n$       'YN'
      Case 1:    getYN$ = Y$            'Y'
      Case 2:    getYN$ = n$            'N'
      Case 3:    getYN$ = Yes$          'Yes'  5 chars max
      Case 4:    getYN$ = No$           'No'   5 chars max
      Case 5:    getYN$ = Y$ & "/" & n$ 'Y/N'
      Case 6:    getYN$ = "&" & Yes$    '&Yes' 6 chars max
      Case 7:    getYN$ = "&" & No$     '&No'  6 chars max
      Case Else: getYN$ = ""            ''
      End Select

End Function

Sub antihack(verbose As String, chksum As Variant)
'-----------------------------------------------------------------------------
'
'                            Anti tamper routine
'
'  This routine is solely aimed at reducing the risk of the hospital name
'  and abbreviation being altered. It does nothing to prevent copying.
'
'     XOR all bytes in given string & compare with preset answer.
'     This routine will return a chksum of 0 if the chksum as supplied was
'     correct for the verbose string.
'     Equally, it can be used to find the checksum in the first place by
'     calling with chksum = 0 (since n XOR n = 0, so n XOR 0 = n)
'     This routine should have a 1 in 256 chance (=0.39%) of failing to find
'     a hacked hospname.
'
'-----------------------------------------------------------------------------
Dim iByte%

   If Len(verbose) Then
         For iByte = 1 To Len(verbose)
            chksum = chksum Xor Asc(Mid$(verbose, iByte))
         Next
      End If

End Sub

Sub AppendToRTF(RTF$, text$, FontSize!)
'Appends the string in Text$ to the RTF provided in RTF$.
'Font colour and font type are set as the default (0), since to set these requires a
'knowledge of the RTF header.  However the font size can be set (in standard font points)
'Sending Text$ = "" inserts a blank line
'---------------------------------------------------
'02Sep99 AE Written

Dim font$
Dim FontSiz$
Dim FontColour$
Dim Super$
Dim SubSc$
Dim ctrl$

   font$ = "\f0"                                   'first font in font table (default)
   FontSiz$ = "\fs" & Format$(Int(FontSize * 2))   'font size given in half points
   FontColour$ = "\cf0"                            'first colour in colour table (black)
   Super$ = "\up0"                                 'Zero superscript alignment
   SubSc$ = "\dn0"                                 'Zero subscript alignment

   ctrl$ = font$ & FontSiz$ & FontColour$ & Super$ & SubSc$

   'Remove EOF bracket, if neccessary
   If Right$(RTF$, 2) = "}}" Then RTF$ = Mid$(RTF$, 1, Len(RTF$) - 1)
   If Right$(RTF$, 4) = "\ql}" Then RTF$ = Mid$(RTF$, 1, Len(RTF$) - 1)
   
   'Insert new text group
   RTF$ = RTF$ & "{" & ctrl$ & " " & text$
   If text$ <> "" Then RTF$ = RTF$ & "}{"
   RTF$ = RTF$ & crlf$
   RTF$ = RTF$ & "\par}\pard\ql}"

End Sub

Function AppPathNoSlash() As String
'24May99 CKJ Written
'            Returns App.Path without a trailing backslash.

Dim tmp$

   tmp$ = App.Path
   If Right$(tmp$, 1) = "\" Then tmp$ = Left$(tmp$, Len(tmp$) - 1)
   AppPathNoSlash$ = tmp$

End Function

Function asciiz$(st As String)
'--------------------------------
' given an ASCIIZ string (one terminated by null), returns an ordinary string.
' if passed an ordinary variable length string, returns it unchanged.
Dim ptr%

   ptr = InStr(st, Chr$(0))             '  ""=0   "ABC"=0   "|"=1   "ABC|"=4
   If ptr Then asciiz$ = Left$(st, ptr - 1) Else asciiz$ = st

End Function

Function ASCTerminalName$(Optional ByVal blnResetTerminal As Boolean = False)
'------------------------------------------------------------------------------------------------
'12Jan98 CKJ written
'            Check for presence of ASCTERM.INI on C:\
'            if found, extract terminal ID
'            else create unique terminal name & store in c:\ascterm
'            and create an entry in Terminal.ini as follows
'            e.g.  [TERM-KFNE]
'                  Alloc=10/01/1998 14:15:30
'20Aug98 TH  trim myterminal$  if over 15 chars
'17Sep98 CKJ removed the '-' from TERM-XYZA as some DBs are 8 chars wide only
'27Jul15 TH  Added way of resetting terminal. Mid session user could change terminals then return to ocx (TFS 60163)
'------------------------------------------------------------------------------------------------

Static strMyterminal As String, found%, txt$
Dim rsTerminal As ADODB.Recordset
Static strCachedMsg As String  '27Jul15 TH Added

   If blnResetTerminal Then strMyterminal = ""  '27Jul15 TH Added (TFS 60163)

   If strMyterminal = "" Then    'find terminal name for this terminal
         'myterminal$ = txtd("C:\ASCTERM.INI", "", "", "TerminalName", found)
         Set rsTerminal = gTransport.ExecuteSelectSP(g_SessionID, "pTerminalIdentifyForPharmacy", "")
         If Not rsTerminal Is Nothing Then     'use returned recordset
            If rsTerminal.State = adStateOpen Then
               If rsTerminal.RecordCount <> 0 Then
                  strMyterminal = RtrimGetField(rsTerminal!Description)
               End If
            End If
         End If
         rsTerminal.Close
         Set rsTerminal = Nothing
         

''         If Not found Or strMyterminal = "" Then     'create terminal name for this terminal
''               Do 'choose a name
''                  'myterminal$ = "TERM-" & RndLetter() & RndLetter() & RndLetter() & RndLetter()  '17Sep98 CKJ removed the -
''                  myterminal$ = "TERM" & RndLetter() & RndLetter() & RndLetter() & RndLetter()    '   "        some DBs are 8 wide only
''                  GetTextFile dispdata$ & "\TERMINAL.INI", txt$, 0
''                  found = InStr(UCase$(txt$), crlf & "[" & myterminal$ & "]")
''               Loop While found > 0
''
''               WritePrivateIniFile "", "TerminalName", myterminal$, "C:\ASCTERM.INI", 0
''               WritePrivateIniFile myterminal$, "Alloc", Format$(Now, "dd/mm/yyyy hh:nn:ss"), dispdata$ & "\TERMINAL.INI", 0
''               WriteLog dispdata$ & "\TERMINAL.LOG", 0, "", myterminal$
''               popmessagecr "", "Terminal name " & myterminal$ & " has been allocated"
''            End If
         '20Aug98 TH trim myterminal$
         'If Len(strMyterminal) > 15  Then
         If Len(strMyterminal) > 15 And (strCachedMsg <> strMyterminal) Then '27Jul15 TH Replaced above - if we have reest then we dont want to warn automatically unless the terminal has definitely changed
            popmessagecr "!EMIS Health", "Terminal name too long - truncated from " & strMyterminal & " to " & Left$(strMyterminal, 15)
            strCachedMsg = strMyterminal '27Jul15 TH Cache so as not to repeat msg inappropriately
            strMyterminal = Left$(strMyterminal, 15)
         End If
      End If
   ASCTerminalName$ = strMyterminal

End Function

''Function ASCTerminalNameSQL() As String
''Static strMyterminal As String, found%, txt$
''
''   If strMyterminal = "" Then    'find terminal name for this terminal
''      strMyterminal = txtd("C:\ASCTERM.INI", "", "", "TerminalName", found)
''      If strMyterminal = "" Then
''         'Go to the registry and see
''         strMyterminal = GetSetting("ASCribe", "AscribeConfig", "TerminalName", "")
''         If strMyterminal <> "" Then
''            Heap 10, iniHeapID, "C:\ASCTERM.INI||TerminalName", strMyterminal, 0
''         End If
''      End If
''      If strMyterminal = "" Then     'create terminal name for this terminal
''         Do 'choose a name
''            strMyterminal = "TERM" & RndLetter() & RndLetter() & RndLetter() & RndLetter()    '   "        some DBs are 8 wide only
''            GetTextFile dispdata$ & "\TERMINAL.INI", txt$, 0
''            found = InStr(UCase$(txt$), crlf & "[" & strMyterminal & "]")
''         Loop While found > 0
''         SaveSetting "ASCribe", "AscribeConfig", "TerminalName", strMyterminal
''         WritePrivateIniFile strMyterminal, "Alloc", Format$(Now, "dd/mm/yyyy hh:nn:ss"), dispdata$ & "\TERMINAL.INI", 0
''         WriteLog dispdata$ & "\TERMINAL.LOG", 0, "", strMyterminal
''         popmessagecr "", "Terminal name " & strMyterminal & " has been allocated"
''      End If
''      If Len(strMyterminal) > 15 Then
''            popmessagecr "!ASCribe", "Terminal name too long - truncated from " & strMyterminal & " to " & Left$(strMyterminal, 15)
''            strMyterminal = Left$(strMyterminal, 15)
''         End If
''   End If
''   ASCTerminalNameSQL = strMyterminal
''
''End Function

''Sub HandleSingleUser()
'''19Jan99 CFY Written
'''
'''This procedure should be called on start-up if the system has detected that it is in single-user
'''mode.
'''The routine carries out the following actions:
'''  1. Records the next Rx record number that will be used. If this has been previously recorded
'''     then it is not overwritten.
'''  2. Records the next transaction record number that will be used along with the transaction
'''     file that it will be written to. If the record number has already been recorded for a
'''     particular transaction file then it will not be overwritten.
'''
'''This information is all written to the file asc_back.ini in the dispdata.
'''
''' Eg.
'''    [Data]
'''    TL199901=65
'''    RxNumber=51460
'''    TL199902=2
'''
'''If the routine fails to record this information then the user is notified.
'''
'''26May99 CFY Whoops! Was previously incrementing the translog pointer in the local translog file by 1
'''            when recording the record number of the next transaction in the asc_back.ini file.
'''06Dec99 CFY Changed method which decides if the pointers need to be written. Now uses a flag as an indicator.
'''08Dec99 CFY Now writes NEXT transaction and rxnumber to the ini file as this is what the merge program is expecting to see.
'''22Jun00 AW  Checks to see if translog exists, if not increments pointer.
'''26Jun00 AE  Corrected above mod.  If translog is not found, a new one is created with a pointer of 1.
'''            Otherwise, the pointer is read, NOT incremented, and the NEXT transaction number written to
'''            ASC_back.ini
'''29Jun00 SF  changed the section where some of the data is written so that it corresponds with the Single User Merge utility
'''10Jul00 AE  Further refinement of mod 26Jun00 AE to account for possible update problems with badly
'''            configured citrix sites.
''
''Dim SuccessTrans%, SuccessRx%, UpdateRxPtr%, UpdateTransPtr%, SuccessUpdTrans%, SuccessUpdRx%
''Dim TransFile$, msg$
''Dim NextTranNo&, NextLabelNo&
''Dim sTempFile As String                                                                '10Jul00 AE
''
''   If singleuseronly% Then
''         '!!** If we have reached here we have found a single user license user
''         '     who is running some part of the system from a remote drive.
''      End If
''
''   UpdateRxPtr = True
''   UpdateTransPtr = True
''
''   'Check if the asc_backup exists and if it does check if we have already recorded
''   'the pointers for this month
''   If fileexists(dispdata$ & "\asc_back.ini") Then
''         UpdateRxPtr = TrueFalse(TxtD(dispdata$ & "\asc_back.ini", "ascshell", "Y", "UpdatePrescriptionPtr", 0))
''         UpdateTransPtr = TrueFalse(TxtD(dispdata$ & "\asc_back.ini", "ascshell", "Y", "UpdateTransactionPtr", 0))
''
''         'Transfile$ = "TL" & Right$(Date$, 4) & Left$(Date$, 2)                                   '06Dec99 CFY Removed
''         'dummy$ = TxtD$(dispdata$ & "\asc_back.ini", "Data", "", Transfile$, FoundTrans%)         '         "
''         'dummy$ = TxtD$(dispdata$ & "\asc_back.ini", "Data", "", "RxNumber", FoundRx%)            '         "
''      'Else                                                                                        '         "
''      '   FoundTrans% = False                                                                      '         "
''      '   FoundRx% = False                                                                         '         "
''      End If
''
''   SuccessTrans% = True
''   SuccessRx% = True
''
''   SuccessUpdTrans = True        '29Jun00 SF added to stop error message below if not necessary
''   SuccessUpdRx = True           '29Jun00 SF added to stop error message below if not necessary
''   'Record the next transaction record number to be written and the transaction file it
''   'will be written to.
''   'If Not FoundTrans% Then                                                         '06Dec99 CFY Replaced
''   If UpdateTransPtr Then                                                           '     "
''         TransFile$ = "TL" & Right$(date$, 4) & Left$(date$, 2)
''         If fileexists(transpath$ & "\" & TransFile$) Then                          '26Jun00  AE  Corrected
''            GetPointer transpath$ & "\" & TransFile$, NextTranNo&, False            '       "
''         Else                                                                       '       "
''            sTempFile = Format$(Now, "mmss") & Format$(1 + Int(Rnd * 1000), "0000")             '10Jul00 AE  Create a file with a unique name...
''            GetPointer transpath$ & "\" & sTempFile, 1, 2                                          '        Then open it with pointer...
''            On Error Resume Next                                                                   '        Finally rename it. This step will fail safely if
''            Name transpath$ & "\" & sTempFile As transpath & "\" & TransFile$                      '        Another process has created the file in the meantime.
''            If Err <> 0 Then SuccessUpdTrans = False                                               '        Flag an error if the translog was created between fileexists and us creating the temp file
''            If fileexists(transpath & "\" & sTempFile) Then Kill transpath & "\" & sTempFile   '        If the rename failed, remove the temporary file
''            On Error GoTo 0                                                                        '
''            NextTranNo& = 1                                                         '       "
''         End If                                                                     '       "
''         NextTranNo& = NextTranNo& + 1                                              '       "
''         WritePrivateIniFile "Data", TransFile$, Format$(NextTranNo&), dispdata$ & "\asc_back.ini", SuccessTrans%
''         '29Jun00 SF changed the section that the data is written so that it corresponds with the Single User Merge utility
''         'WritePrivateIniFile "Data", "UpdateTransactionPtr", "N", Dispdata$ & "\asc_back.ini", SuccessUpdTrans%      '06Dec99 CFY Added
''         WritePrivateIniFile "ascshell", "UpdateTransactionPtr", "N", dispdata$ & "\asc_back.ini", SuccessUpdTrans%
''         '29Jun00 SF -----
''      End If
''
''   'Record the next Rx number that will be written
''   'If Not FoundRx% Then                                                            '06Dec99 CFY Replaced
''   If UpdateRxPtr Then                                                              '     "
''         GetPointer patdatapath$ & "\labeltxt.v6", NextLabelNo&, False
''         NextLabelNo& = NextLabelNo& + 1                                            '08Dec99 CFY Added
''         WritePrivateIniFile "Data", "RxNumber", Format$(NextLabelNo&), dispdata$ & "\asc_back.ini", SuccessRx%
''         '29Jun00 SF changed the section that the data is written so that it corresponds with the Single User Merge utility
''         'WritePrivateIniFile "Data", "UpdatePrescriptionPtr", "N", Dispdata$ & "\asc_back.ini", SuccessUpdRx%        '06Dec99 CFY Added
''         WritePrivateIniFile "ascshell", "UpdatePrescriptionPtr", "N", dispdata$ & "\asc_back.ini", SuccessUpdRx%
''      End If
''
''   'Warn user if either of the above failed
''   If Not SuccessTrans% Or Not SuccessRx% Then
''         msg$ = "The system has detected that this terminal is running in single user mode" & crlf
''         msg$ = msg$ & "but cannot log details to disk." & crlf & crlf
''         msg$ = msg$ & "This means that all work done on this terminal cannot be automatically" & crlf
''         msg$ = msg$ & "updated to the central database when the system is brought back on-line." & crlf
''         popmessagecr ".", msg$
''      End If
''
''   If Not SuccessUpdTrans Or Not SuccessUpdRx Then                                                                    '06Dec99 CFY Added
''         msg$ = "The system failed to update the single user merge flags." & crlf                                    '         "
''         msg$ = msg$ & "Any work done during this session could be lost if the Single User Merge" & crlf             '         "
''         msg$ = msg$ & "is not run immediately after this session." & crlf                                           '         "
''         msg$ = msg$ & "Please contact your Systems Supervisor for further help."                                    '         "
''         popmessagecr ".", msg$                                                                                      '         "
''      End If
''
''End Sub

Sub Heap(Action%, HeapID%, Entry$, Value$, success%)
'------------------------------------------------------------------------------------------------
'13Jan98 CKJ Heap Manager written
'            This uses frmHeap which has a single sorted listbox. A new listbox is allocated
'            for each heap, and as heaps are created & destroyed this becomes a sparse array.
'            Each line in the array holds 'Entry & Tab & Value' and is searched using the
'            SendMessage API with LB_FINDSTRING
'
'            Limits are 255 heaps, 32K entries, 32K per entry; though not at the same time <g>
'            Please initialise once and remember the HeapID handle.
'            Pass the handle with every subsequent action, and destroy the heap afterwards.
'            The routine is able to support multiple heaps, and these do not interact with
'            each other, beyond the effects on system resources.
'            Think of it as a fast memory based INI file and you won't go far wrong.
'             allocate a HeapID for each file or section
'             then store entry=value for as many items as needed
'            As with INI files, the search using Entry is case insensitive,
'            but unlike INI files, leading and trailing spaces are kept and used.
'            All ASCII characters can be used in Value.
'            Duplicate entries cannot be created, as the first entry simply gets updated.
'            Remember to check the value of Success - it won't always be TRUE
'Action
'  0  Destroy all heaps. Returns success=T/F. HeapID, Entry and Value are ignored.
'      Caution - use only as program ends as this destroys the contexts for all heaps.
'  1  Initialise a heap. Returns success=T/F and HeapID=0 if failed, >0 if allocated.
'      Entry can optionally be set to a short description which is shown on the debug screen.
'      Value is ignored, and both Entry and Value are returned unchanged
'  2  Destroy a heap. Requires HeapID. Returns success=T/F and sets HeapID=0 if successful.
'      Entry & value are ignored and are returned unchanged
' 10  Write to a heap. Requires HeapID, entry and value. Returns success=T/F
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab.
'      Value can be "" or up to 32K long.
' 11  Read from a heap. Requires HeapID & entry. Returns value and success=T/F
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab
'      If entry is not found then success=false and value is unchanged,
'      hence value can be given a default and this will be returned.
' 12  Remove from a heap.  Requires HeapID & entry. Returns success=T/F. Value is ignored
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab
'      If entry is not found then success=false
' 13  Read next item from heap. Given entry, it finds and returns the next item after entry.
'      Requires HeapID & entry. Returns entry, value and success=T/F
'      Entry must not contain Chr$(0), Chr$(1) or Tab
'      If entry is "" then the first item on the heap is returned
'      If entry is found then the next item after it is returned, except when this
'      is the last item in the heap, it sets success=false, entry and value are unchanged.
'      If entry is not found then success=false, both entry and value are unchanged.
' 14  Read last item from a heap.
'      Requires HeapID. Returns entry, value and success T/F.
'      If heap is empty then success is False, both entry & value are unchanged.
' 20  Returns number of active heaps in the HeapID parameter,
'      return '|' separated list of heap IDs in Value$
'      and '|' separated list of Heap descriptions in Entry$
'      success% ignored and unchanged
' 21  Returns frmHeap.hWnd or 0 if no heaps initialised in the HeapID parameter.
'      Entry$, Value$, success% all ignored
'100  Display Heap for debug. Requires HeapID. Returns Success=T/F. Entry & value are ignored.
'
'24Jan98 CKJ Added actions 20 & 21
'29Apr98 CKJ Found that each entry accepts up to 32K of data, but keeps first 1K only.
'            Amended to allow linked list storage, using suffix to the item key.
'            This is transparent in use and does not affect existing code.
'            Limit now of ~16000 entries of 1K, more with smaller data items.
'16Jul98 CKJ Corrected bug in action 11 - items not found in heap were returned as blank
'14Sep98 CKJ Action 22 written; return hwnd of individual list box
'            Binary search written to replace LB_FINDSTRING which appears to do a brute-force
'            sequential search. The binary search is over twice as fast on a list of ~500 items.
'15Sep98 CKJ Added Actions 23 & 24 set redraw off/on, and replaced Additem with LB_ADDSTRING
'25Sep98 CKJ Removed actions 22, 23, 24: list().hwnd should remain encapsulated, and inhibiting
'            redraw does not improve speed.
'            Binary search rewritten to handle all access to the now unsorted lists, since the
'            sort order is not in ASCII order. Internal separator char changed from ascii 127->1
'19Jul99 AE  Action 11: moved "success = true" to make procedure work as described
'28Oct99 CKJ Corrected action 1 - do not blank heap name.
'            Extended action 20 - return '|' separated list of heap IDs in Value$
'            and '|' separated list of Heap descriptions in Entry$
'22Nov00 CKJ added heap size calculation, displayed on debug window caption
'30Apr02 CKJ Added action 13 which provides a findfirst/findnext capability. Returns next item
'            after the entry supplied, or the very first item if entry="". Repeat while success=T
'19May04 CKJ Added action 14 which returns the last code and entry from a heap
'09May05 CKJ Multiselect & copy added in debug page
'
'Mods wanted:
'  make the routine fully recursive, and keep one heap with details of all current heaps
'  add an array of items in one go
'  search on partial key and return all matching items
'  search on partial key and delete all matching items
'/ shutdown option, to destroy all heaps and unload frmHeap
'  full error reporting, with numerical & text error codes
'  store heaps to disk & reload again
'  need a way of detecting that the form has been unloaded by some other module
'   (and maybe cancelling the unload request)
'------------------------------------------------------------------------------------------------
'HeapID numbers are in the range 1 to HighTide, with NumInstances heaps allocated and active.
Static NumInstances%, HighTide%
Dim i%, ptr%, key$, sep$, tmp$, done%, Top%, bot%, sch%, lenkey%, InsertPtr%
Dim lHeapSize As Long

   success = False
   sep$ = Chr$(1)                                   '25Sep98 CKJ was chr(127)
   On Error GoTo HeapErr
   Select Case Action                               'don't mess with the design time object
      Case 2, 10, 11, 12, 13, 14, 22, 100
         If HeapID = 0 Then Exit Sub
      End Select
   
   Select Case Action
      Case 0                   'Destroy all heaps
         On Error Resume Next                       'heap may not be in use
         For i = 1 To HighTide
            frmHeap.lstHeap(i).Clear
            Unload frmHeap.lstHeap(i)
         Next
         On Error GoTo HeapErr
         HighTide = 0
         NumInstances = 0
         Unload frmHeap
         Set frmHeap = Nothing                      '24Jan98 CKJ added
         success = True
      
      Case 1                   'Create a heap
         HeapID = 0
         If NumInstances = 0 Then Load frmHeap
         NumInstances = NumInstances + 1
         On Error Resume Next
         For i = 1 To HighTide
            'frmHeap.lstHeap(i).Tag = ""            'find a spare (deallocated) heap
            tmp$ = frmHeap.lstHeap(i).Tag           'find a spare (deallocated) heap '28Oct99 CKJ Corrected
            If Err Then Exit For
         Next
         On Error GoTo HeapErr                      'i now holds a free ID, or is HighTide+1
         If i > HighTide Then HighTide = i
         Load frmHeap.lstHeap(i)
         frmHeap.lstHeap(i).Tag = Entry$
         HeapID = i
         success = True
      
      Case 2                   'Destroy a heap
         frmHeap.lstHeap(HeapID).Clear
         Unload frmHeap.lstHeap(HeapID)
         If HeapID = HighTide Then HighTide = HighTide - 1
         'Note that HighTide may still be artificially high; imagine heaps 1-4 allocated,
         'then destroy 2,3,4 in that order. HighTide now 3, but could be set to 1. Not
         'worth scanning downwards for first allocated list though. Just check if it could
         'be zeroed.
         NumInstances = NumInstances - 1
         If NumInstances = 0 Then
               HighTide = 0
               Unload frmHeap
               Set frmHeap = Nothing                '24Jan98 CKJ added
            End If
         HeapID = 0
         success = True
      
      Case 10                  'Write to a heap
         If Entry$ <> "" And InStr(Entry$, Nul) = 0 And InStr(Entry$, TB) = 0 And InStr(Entry$, sep$) = 0 Then
               done = False
               key$ = UCase$(Entry$) & sep$ & "0" & TB               '15Sep98 CKJ ucase added
               
               GoSub BinarySearchHeap
               
               If frmHeap.lstHeap(HeapID).ListIndex > -1 Then              'found it
                     ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                     If Len(key$ & Value$) <= 1024 And ptr = 0 Then   'new & old items fit in one block
                           frmHeap.lstHeap(HeapID).List(frmHeap.lstHeap(HeapID).ListIndex) = key$ & Value$
                           done = True
                           success = True
                        Else
                           Heap 12, HeapID, Entry$, "", success            'remove old item
                           If Not success Then Error 32767                 'quit
                           success = False                                 'reset ready for the add
                        End If
                  End If

               If Not done Then                                            'add it
                     ptr = 0
                     tmp$ = Value$
                     Do                                                    'iteratively add 1K blocks until done
                        key$ = UCase$(Entry$) & sep$ & Format$(ptr) & TB   '15Sep98 CKJ ucase added
                        GoSub BinarySearchHeap                             'InsertPtr now set
                        frmHeap.lstHeap(HeapID).AddItem Left$(key$ & tmp$, 1024), InsertPtr

                        If Len(key$ & tmp$) > 1024 Then
                              ptr = ptr + 1                                'allocate next block
                              tmp$ = Mid$(tmp$, 1024 - Len(key$) + 1)      'keep remainder
                           Else
                              ptr = 0                                      'finished
                           End If
                        frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).NewIndex) = ptr
                     Loop Until ptr = 0
                     success = True
                  End If
            End If
      
      Case 11                  'Read a heap
         If Entry$ <> "" And InStr(Entry$, Nul) = 0 And InStr(Entry$, TB) = 0 And InStr(Entry$, sep$) = 0 Then
               ptr = 0
               'Value$ = ""    '16Jul98 CKJ don't blank it until we've found its replacement
               Do
                  key$ = UCase$(Entry$) & sep$ & Format$(ptr) & TB      '15Sep98 CKJ ucase added
               
                  GoSub BinarySearchHeap
               
                  If frmHeap.lstHeap(HeapID).ListIndex > -1 Then     'found it
                        If ptr = 0 Then Value$ = ""                  '16Jul98 CKJ first part of the retrieval
                        ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                        Value$ = Value$ & Mid$(frmHeap.lstHeap(HeapID).text, Len(key$) + 1)
                        success = True                                     '19Jul99 AE added
                     ElseIf ptr > 0 Then                             'failed to find it, but should have done
                        success = False                                    '19Jul99 AE added
                        'popmessagecr "!", "Heap Manager - error reading linked list: " & Str$(HeapID) & " " & entry$ & Str$(ptr)
                        Error 32766
                     End If
               Loop While ptr > 0
              ' success = True                                '19Jul99 AE AE moved into if statement above
            End If
      
      Case 12                  'Remove from a heap
         If Entry$ <> "" And InStr(Entry$, Nul) = 0 And InStr(Entry$, TB) = 0 And InStr(Entry$, sep$) = 0 Then
               ptr = 0
               Do
                  key$ = UCase$(Entry$) & sep$ & Format$(ptr) & TB      '15Sep98 CKJ ucase added
               
                  GoSub BinarySearchHeap

                  If frmHeap.lstHeap(HeapID).ListIndex > -1 Then     'found it
                        ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                        frmHeap.lstHeap(HeapID).RemoveItem frmHeap.lstHeap(HeapID).ListIndex
                     ElseIf ptr > 0 Then                             'failed to find it, but should have done
                        'popmessagecr "!", "Heap Manager - error removing linked item: " & Str$(HeapID) & " " & entry$ & Str$(ptr)
                        Error 32767
                     End If
               Loop While ptr > 0
               success = True
            End If
      
      ' 13  Read next item from heap. Given entry, it finds and returns the next item after entry.
      '      Requires HeapID & entry. Returns entry, value and success=T/F
      '      Entry must not contain Chr$(0), Chr$(1) or Tab
      '      If entry is "" then the first item on the heap is returned
      '      If entry is found then the next item after it is returned, except when this
      '      is the last item in the heap, it sets success=false, entry and value are unchanged.
      '      If entry is not found then success=false, both entry and value are unchanged.

      Case 13                  'Read next item from a heap
         If InStr(Entry$, Nul) = 0 And InStr(Entry$, TB) = 0 And InStr(Entry$, sep$) = 0 Then
               If Entry$ = "" Then                                            'read first item on heap
                     If frmHeap.lstHeap(HeapID).ListCount > 0 Then            'heap has at least one item
                           Entry$ = frmHeap.lstHeap(HeapID).List(0)           'retrieve whole of the first line
                           Entry$ = Left$(Entry$, InStr(Entry$, sep$) - 1)    'and retain just the key part
                           Heap 11, HeapID, Entry$, Value$, success           'and find using recursive call
                        End If
                  Else                                                        'find subsequent item after given entry
                     key$ = UCase$(Entry$) & sep$ & Format$(0) & TB           'start with the given entry
                     GoSub BinarySearchHeap
                     Do While frmHeap.lstHeap(HeapID).ListIndex > -1
                        If Left$(frmHeap.lstHeap(HeapID).text, Len(Entry$) + 1) = UCase$(Entry$) & sep$ Then
                              'still reading elements belonging to the given entry, so step past these
                              If frmHeap.lstHeap(HeapID).ListIndex < frmHeap.lstHeap(HeapID).ListCount - 1 Then
                                    frmHeap.lstHeap(HeapID).ListIndex = frmHeap.lstHeap(HeapID).ListIndex + 1
                                 Else
                                    frmHeap.lstHeap(HeapID).ListIndex = -1    'end of heap reached
                                 End If
                           Else                                               'not end of heap, and next item has been found
                              Entry$ = frmHeap.lstHeap(HeapID).text           'retrieve whole of the line
                              Entry$ = Left$(Entry$, InStr(Entry$, sep$) - 1) 'and retain just the key part
                              Heap 11, HeapID, Entry$, Value$, success        'and find using recursive call
                              Exit Do
                           End If
                     Loop
                  End If
            End If

      Case 14                  'return last item from a heap
         If frmHeap.lstHeap(HeapID).ListCount Then
               key$ = frmHeap.lstHeap(HeapID).List(frmHeap.lstHeap(HeapID).ListCount - 1)  'read last line, may be end of linked list
               key$ = Left$(key$, InStr(key$, sep$) - 1)                      'and retain just the key part
               Heap 11, HeapID, key$, Value$, success                         'and find using recursive call
               If success Then Entry$ = key$                                  'return the key for this item
            End If

      Case 20                  'return number of active heaps
         HeapID = NumInstances
         Value$ = ""                                '28Oct99 CKJ Added block to fill Value with '|' separated list of heaps
         Entry$ = ""                                '            and fill Entry$ with Heap descriptions
         On Error Resume Next
         For i = 1 To HighTide
            Err = 0
            tmp$ = frmHeap.lstHeap(i).Tag           'try using an lstHeap - it may not exist
            If Err = 0 Then
                  If Len(Value$) > 0 Then Value$ = Value$ & "|"
                  Value$ = Value$ & Str$(i)
                  If Len(Entry$) > 0 Then Entry$ = Entry$ & "|"
                  Entry$ = Entry$ & frmHeap.lstHeap(i).Tag
               End If
         Next
         On Error GoTo HeapErr
      
      Case 21                  'return frmHeap.hWnd
         If NumInstances > 0 Then
               HeapID = frmHeap.Hwnd
            Else
               HeapID = 0
            End If

      Case 100                 'display heap for debugging
         With frmHeap.lstHeap(HeapID)
            .Visible = True
            lHeapSize = 0                                                           '22Nov00 CKJ added heap size calculation
            For i = 0 To .ListCount - 1
               lHeapSize = lHeapSize + Len(.List(i))
            Next
            lHeapSize = (lHeapSize + 1023) \ 1024                                   '   "        round up to next whole Kb
            frmHeap.Caption = "Debug Heap" & Str$(HeapID) & " " & .Tag & ";" & Str$(.ListCount) & " entries " & Format$(lHeapSize) & "Kb (" & Format$(NumInstances) & " active heaps)"
         End With
            
         ReDim TabStops(1) As Long
         TabStops(1) = 4 * 50
         ListBoxTextBoxSetTabs frmHeap.lstHeap(HeapID), 1, TabStops()
         frmHeap.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         frmHeap.lstHeap(HeapID).Visible = False
         success = True
      End Select

HeapExit:
Exit Sub
                  
BinarySearchHeap:
'This has no use outside this procedure, so done as a Gosub instead of a separate Function
'Takes key$ and .Listcount
'If found, returns .ListIndex = set appropriately
'otherwise returns .ListIndex = -1 and InsertPtr = value required as param to .Additem

   frmHeap.lstHeap(HeapID).ListIndex = -1                '14Sep98 CKJ Binary search
   Top = frmHeap.lstHeap(HeapID).ListCount               '0 or 1 to n
   bot = 1
   sch = 1
   lenkey = Len(key$)
   Do While Top >= bot                                   '  -- Binary Search --
      sch = (Top + bot) \ 2
      Select Case Left$(frmHeap.lstHeap(HeapID).List(sch - 1), lenkey)
         Case Is < key$                                  'less than required item
            bot = sch + 1                                'set bottom above this line
            sch = sch + 1                                'insert would be above this line
         Case Is > key$                                  'greater than required item
            Top = sch - 1                                'set top below this line
         Case Else                                       'equal to item
            frmHeap.lstHeap(HeapID).ListIndex = sch - 1  '-1 or 0 to n-1
            Exit Do                                      'force loop exit
         End Select
   Loop
   InsertPtr = sch - 1                                   'list is zero indexed
                                                                        
Return

HeapErr:
   'Error Err     'NB enable this line for testing ONLY
Resume HeapExit

End Sub

Sub Help(ByVal Hwnd As Long, Context As Long)
'--------------------------------------------------------------------------------------
'Displays help; the main routine to call
'
'Pass four parameters to the WinHelp function to display the correct topic.
'
'Parameter;
'hWnd              Handle of the form requesting help
'HelpFile$         Name of the help file containing the information
'wCommand          Type of help WinHelp should display
'dwData            Additional data some of the help types require
'
'Constants:
'HELP_CONTEXT      Displays help for a topic you identify with a context number
'HELP_QUIT         Closes WinHelp if no other application is using the WinHelp program
'HELP_HELPONHELP   Shows the Contents topic of the Using Help file
'HELP_CONTEXTPOPUP Displays, in a pop-up window, a specific Help topic you identify
'                  with a context number
'HELP_FORCEFILE    Tells WinHelp to check that it's displaying the correct help file;
'                  if it isn't, WinHelp opens the file you need
'HELP_KEY          Searches for a topic in the keyword list (of the help project file)
'                  that matches the term you pass WinHelp in the dwData parameter;
'                  if there's more than one match, WinHelp displays the Search dialog
'                  box with the topics listed in the GoTo frame
'HELP_PARTIALKEY   Similar to the HELP_KEY constant, but displays the Search dialog
'                  box without specifying a keyword
'
'Procedures provided here;
'Help              Displays help - the main routine to call
'HelpForceFile     Calls WinHelp and makes sure that it's displaying the help file
'                  for the application
'HelpGet           Calls WinHelp to display context-sensitive help
'HelpKey           Displays the help associated with a string
'HelpQuit          Terminates the WinHelp application
'HelpSearch        Displays the WinHelp Search dialog box
'--------------------------------------------------------------------------------------

   HelpGet Hwnd, HELP_CONTEXT, Context

End Sub

Private Sub HelpForceFile(ByVal Hwnd As Long)
'Calls WinHelp and makes sure that it's displaying the help file for the application
' this will make sure correct help file is displayed and
' will also make the first seek find the correct topic
'09May05 CKJ Pass hwnd as param

Dim X As Long

   If Len(App.HelpFile) Then
      X = WinHelp(Hwnd, App.HelpFile, HELP_FORCEFILE, " ")
      DoSaferEvents 1    '18Sep97 CKJ
   End If

End Sub

Sub HelpGet(ByVal Hwnd As Long, cmd As Integer, Context As Long)
'Calls WinHelp to display context-sensitive help
Dim X As Long

   Screen.MousePointer = HOURGLASS
   HelpForceFile Hwnd

   ' display context sensitive help
   X = WinHelp(Hwnd, App.HelpFile, cmd, ByVal Context)

   Screen.MousePointer = STDCURSOR

End Sub

Sub HelpSearch(ByVal Hwnd As Long)
'Displays the WinHelp Search dialog box
'17Dec96 CKJ Corrected - now starts at top of list

Dim X As Long

   'HelpGet HELP_PARTIALKEY, 0&
   
   Screen.MousePointer = HOURGLASS
   HelpForceFile Hwnd
   X = WinHelp(Hwnd, App.HelpFile, HELP_PARTIALKEY, "")
   Screen.MousePointer = STDCURSOR
   
End Sub

Function HexString(sRecord As String, sFormat As String) As String
'23Aug99 CKJ written
'This function takes a string of arbitrary length and coverts it to a format
'which can be displayed or dumped to a log file.
'All ASCII characters (0-255) can be handled and are shown in hex and in
'printable characters where feasible
'The sFormat parameter allows control of the returned string;
' ""  (default)  00000
'
' R        ruler      ----- 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 --------------------
' Oxxxxx   offset
' Wxx      width
' H        Hex
'

Dim iCount As Integer
Dim iLine As Integer
Dim sTemp As String
Dim sHex As String
Dim sChars As String
Dim sChar As String
Dim sHexPart As String

Const iCharsPerLine = 16

   sTemp = ""
   If InStr(1, sFormat, "R", 1) Then
         sTemp = "_____  "
         For iCount = 1 To iCharsPerLine
            sTemp = sTemp & Format$(iCount, "00 ")
         Next
         sTemp = sTemp & " " & String$(iCharsPerLine, "_") & crlf
      End If

   For iLine = 0 To (Len(sRecord) + iCharsPerLine - 1) \ iCharsPerLine - 1
      sHex = ""
      sChars = ""
      For iCount = 1 To iCharsPerLine
         sChar = Mid$(sRecord, iCharsPerLine * iLine + iCount, 1)
         If Len(sChar) Then
               sHexPart = Hex$(Asc(sChar))
               If Len(sHexPart) = 1 Then sHexPart = "0" & sHexPart
               sHex = sHex & sHexPart & " "
               Select Case Asc(sChar)
                  Case 0 To 31, 127
                     sChar = "_"
                  End Select
            Else
               sHex = sHex & "__ "
               sChar = ""
            End If
         sChars = sChars & sChar
      Next
      sTemp = sTemp & Format$(iLine * iCharsPerLine, "00000  ") & sHex & " " & sChars & crlf
   Next

   HexString = sTemp

End Function

Function Iff(expr As Variant, IfTrue As Variant, IfFalse As Variant) As Variant
'14Apr97 CKJ Small but useful procedure, which emulates IIF(Expr, "Res1", "Res2")
'            but without the fatal flaw when immediate strings are used (as above)
'            DO NOT use IIF as memory corruption can occur.
   
   If expr Then
         Iff = IfTrue
      Else
         Iff = IfFalse
      End If

End Function

''Function XIniCache(i_Pathfile As String, i_Section As String, i_Default As String, i_Entry As String, io_Found As Integer) As String
'''14Nov00 CKJ Written
'''            Read contents of file and item caches, return result having cached file if necessary
''
''Dim sItemSearch As String
''Dim sBuffer As String                                                       'String buffer
''Dim sSection As String                                                      'Ini file [section] in scope
''Dim sPathFile As String
''Dim bFileInCache As Integer
''Dim bDone As Integer
''
''   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
''   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0
''
''   io_Found = False                                                         'assume not found as default
''   sBuffer = i_Default                                                      'and prefill the buffer with supplied string
''   sSection = UCase$(Trim$(i_Section))
''   sPathFile = UCase$(Trim$(i_Pathfile))
''   sItemSearch = sPathFile & "|" & sSection & "|" & UCase$(Trim$(i_Entry))  'try file+item in item cache
''
''   Do
''      bDone = True                                                          'assume single pass unless otherwise needed
''      Heap 11, iniHeapID, sItemSearch, sBuffer, io_Found                    'check the item cache for the item
''      If io_Found Then                                                      'entry found in cache
''            'bDone, sBuffer and io_Found are already set correctly
''         Else                                                               'entry not in cache, so is the filename cached?
''            Heap 11, fileHeapID, sPathFile, "", bFileInCache                'has the filename been looked for before?
''            If bFileInCache Then                                            'entry found in cache
''                  'note that the filename is cached but the file itself may or may not exist on disk
''                  'filename is in the file cache, item not in file cache => item not present
''                  'bDone, sBuffer and io_Found are already set correctly
''               Else
''                  If fileexists(sPathFile) Then                             'this is a newly encountered file which exists
''                        AddFileToCache sPathFile                            'read file & cache it...
''                        bDone = False                                       '...then go round again
''                     Else                                                   'the newly encountered filename does not exist
''                        Heap 10, fileHeapID, sPathFile, "0", 0              'write filename to file cache with exists = "0"
''                        'file does not exist, hence item doesn't exist
''                        'bDone, sBuffer and io_Found are already set correctly
''                     End If
''               End If
''         End If
''   Loop Until bDone
''
''   XIniCache = sBuffer
''
''End Function

Function IniCache(i_Pathfile As String, i_Section As String, i_Default As String, i_Entry As String, io_Found As Integer) As String

'            Read contents of file and item caches, return result having cached file if necessary

Dim sItemSearch As String
Dim sBuffer As String                                                       'String buffer
Dim sSection As String                                                      'Ini file [section] in scope
Dim sPathFile As String
Dim bFileInCache As Integer
Dim bDone As Integer
Dim rsIniSetting    As ADODB.Recordset
Dim strParameters As String
Dim sSetting As String
Dim sNewEntry As String
Dim sValue As String
Dim strPrefix As String
Dim strCategory As String
Dim strSiteID As String
Dim intResult As Integer
Dim intlastSlash As Integer
Dim strFile As String

   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0

   io_Found = False                                                         'assume not found as default
   sBuffer = i_Default                                                      'and prefill the buffer with supplied string
   sSection = UCase$(Trim$(i_Section))
   sPathFile = UCase$(Trim$(i_Pathfile))
   strSiteID = Format$(SiteNumber)           '!!** Needs changing
   
   'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYLE SEARCHSTRING (CATEGORY)
   If InStr(LCase(sPathFile), "dispdata") > 0 Then
      strPrefix = "D"
   ElseIf InStr(LCase(sPathFile), "patdata") > 0 Then
      strPrefix = "P"
   ElseIf InStr(LCase(sPathFile), "ascroot") > 0 Then
      strPrefix = "A"
   End If
   'Convert the pathfile string to something useful for SQL
   
   intResult = -1
   Do While intResult <> 0
      If intResult > 0 Then intlastSlash = intResult
      intResult = InStr(intlastSlash + 1, i_Pathfile, "\", vbBinaryCompare)
   Loop
   strFile = Trim$(Mid$(i_Pathfile, intlastSlash + 1))
   If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
   strCategory = strPrefix & "|" & strFile
   '-------------------------------------------------------------------------------
   
   'i_Pathfile
   sItemSearch = strSiteID & "|" & strCategory & "|" & sSection & "|" & UCase$(Trim$(i_Entry))  'try file+item in item cache
          
   Do
      bDone = True                                                          'assume single pass unless otherwise needed
      Heap 11, iniHeapID, sItemSearch, sBuffer, io_Found                    'check the item cache for the item
      If io_Found Then                                                      'entry found in cache
            'bDone, sBuffer and io_Found are already set correctly
      Else                                                                  'entry not in cache, so is the section cached?
         Heap 11, fileHeapID, strSiteID & "|" & strPrefix & "|" & strFile & "|" & sSection, "", bFileInCache
         If bFileInCache Then                                               'entry found in cache
               'note that the filen|section is cached but the file itself may or may not exist on disk
               'filename is in the file cache, item not in file cache => item not present
               'bDone, sBuffer and io_Found are already set correctly
            Else
               'Debug.Print strCategory, sSection
               AddSectionToCacheSQL strCategory, sSection                   'sPathFile
               bDone = False
            End If
      End If
   Loop Until bDone

   IniCache = sBuffer
            
End Function

Function IsDigits(ByVal txt As String) As Boolean
'12Sep96 CKJ Written. Takes string & tests for 0-9 in all chars.
'            Returns True if all chars are numeric or if string is blank

Dim IsNumber%, counter%

   IsNumber = True
   For counter = 1 To Len(txt$)
      If InStr("0123456789", Mid$(txt$, counter, 1)) = 0 Then
            IsNumber = False
            Exit For
         End If
   Next
   IsDigits = IsNumber

End Function

Function IsNumber(ByVal chars As String, ByVal AllowNegative As Boolean) As Boolean
'09May05 CKJ Does a string conform to the structure for a simple integer or real number?
'            One decimal point is allowed, either leading, trailing or embedded
'            Leading/trailing zero optional, except for zero itself (ie '' '-' '-.' and '.' are not valid)
'            No spaces permitted, so trim before calling.
'            Exponentials, Hex, etc are not permitted
'            Note that this is deliberately stricter than the companion function CleanUpNumber()

Dim valid As Boolean
Dim strParsed As String

   valid = True      'assume innocent until proven guilty
   strParsed = chars
   
   replace strParsed, ".", "", 0
   If Len(chars) - Len(strParsed) > 1 Then valid = False       'more than one decimal point
   If Len(strParsed) = 0 Then valid = False
   
   If valid And AllowNegative Then                             'remove leading negative sign if permitted
      If Left$(chars, 1) = "-" Then                            'using original ensures trapping of '.-' etc
         strParsed = Mid$(strParsed, 2)
         If Len(strParsed) = 0 Then valid = False
      End If
   End If
   
   If valid Then
      valid = IsDigits(strParsed)                              'remaining chars must be 0 to 9 only
   End If
   
   IsNumber = valid

End Function

Function CleanUpNumber(ByVal chars As String) As String
'09May05 CKJ Take a number which is deemed valid by IsNumber() and return it in tidier format, preserving negative sign
'            a) any leading/trailing spaces are removed                 ' 1 ' => '1'
'            b) Remove leading zeroes from whole numbers                '001' => '1'
'            c) Add a leading zero before a naked decimal point         '.12' => '0.12'
'            d) Remove zeroes at end of decimals                        '1.000' => '1.' => '1' (see below)
'            e) Remove a naked decimal point at the end of the number   '123.' => '123'
'            f) If the resulting string is parsed out of existence then '0' is returned
'            g) Replace a negative sign if result is non-zero
'            Thus '  -.0000000   ' => '0'  and  '     ' => '0'

Dim strNum As String
Dim bValid As Boolean
Dim IsNegative As Boolean

   strNum = Trim$(chars)                                                      '(a)
   
   IsNegative = False
   If Left$(strNum, 1) = "-" Then                                             '(g)
      strNum = Mid$(strNum, 2)
      IsNegative = True
   End If
   
   Do While Left$(strNum, 1) = "0"                                            '(b)
      strNum = Mid$(strNum, 2)
   Loop
   
   If Left$(strNum, 1) = "." Then                                             '(c)
      strNum = "0" & strNum
   End If
   
   If InStr(strNum, ".") Then                                                 '(d)
      Do While Right$(strNum, 1) = "0"
         strNum = Left$(strNum, Len(strNum) - 1)
      Loop
      
      If Right$(strNum, 1) = "." Then                                         '(e)
         strNum = Left$(strNum, Len(strNum) - 1)
      End If
   End If
   
   If Len(strNum) = 0 Then strNum = "0"                                       '(f)
   
   If IsNegative And strNum <> "0" Then strNum = "-" & strNum                 '(g)
   
   CleanUpNumber = strNum

End Function

Sub ListOpenedFiles(sMessage As String)
'24Aug99 CKJ Written

Dim iChan As Integer

   sMessage = ""
   For iChan = 1 To 32
      If Len(msOpenedChannels(1, iChan)) Then
            sMessage = sMessage & "      " & Format$(iChan)
            On Error Resume Next                                  'Mark file as closed if
            If FileAttr(iChan, 1) <> 32 Then Err = 32767          'it is not open at all or
            If Err <> 0 Then sMessage = sMessage & "  (Closed)"   'not open for binary.
            On Error GoTo 0
            sMessage = sMessage & TB & msOpenedChannels(2, iChan) & TB & msOpenedChannels(1, iChan) & cr
         End If
   Next

End Sub

Sub ListOpenedFilesPlain(sMessage As String)
'29apr02 CKJ Simple version written for use inside an error handler
'            The original uses error handling and would have affected the program flow
'            This version appends to the existing message

Dim iChan As Integer
Dim sDetail As String

   sDetail = ""
   For iChan = 1 To 32
      If Len(msOpenedChannels(1, iChan)) Then
            sDetail = sDetail & "      " & Format$(iChan) & TB & msOpenedChannels(2, iChan) & TB & msOpenedChannels(1, iChan) & cr
         End If
   Next

   If Len(sDetail) Then
         sMessage = sMessage & cr & "Files opened for binary access:" & cr & sDetail & cr
      End If

End Sub

''Sub LockRecord(Rchan%, recno&, RecLen%)
'''-----------------------------------------------------------------------------
'''21Feb91 CKJ Procedure written
''' Locks a random access record, in a previously opened file.
''' Basically the record is eventually locked or the program terminates.
''' Once this procedure is used on a record a matching unlockrecord or
''' putrecord must be done before ending the program or after finishing with
''' this record to release it for others
''' 7Aug91 CKJ RecNo now long integer
''' 7Apr94 CKJ VBW: Binary access
'''29apr02 CKJ Added extended message
'''-----------------------------------------------------------------------------
''Dim FirstByte&, LastByte&
''Dim sMsg As String
''
''   procname$ = "LockRecord"
''   FirstByte& = (recno& - 1) * RecLen% + 1
''   LastByte& = FirstByte& - 1 + RecLen%
''   On Error GoTo LockRecord_Err
''   Do
''      ErrNum = False
''      Lock #Rchan%, FirstByte& To LastByte&
''      'Err70msg errnum, "Record"                                                                             '29Apr02 CKJ
''      sMsg = "Channel=" & Format$(Rchan) & ", Record Num=" & Format$(recno&) & ", Length=" & Format$(RecLen)
''      Err70MsgEx ErrNum, "Record in " & FileNameFromChannel(Rchan), sMsg, m_strModuleName, procname$
''   Loop While ErrNum
''   On Error GoTo 0
''Exit Sub
''
''LockRecord_Err:
''   ErrNum = Err
''   'If ErrorHandler(errnum, "WDFHL", "LockRecord") = 1 Then Resume Next                                                    '29apr02 CKJ
''   sMsg = "Parameters: Record Number=" & Format$(recno&) & ", Channel=" & Format$(Rchan) & ", Length=" & Format$(RecLen)
''   ListOpenedFilesPlain sMsg
''   If ErrorHandlerEx(ErrNum, "WDFHL", "LockRecord", sMsg) = 1 Then Resume Next
''
''End Sub

''Sub LX(ctl As Control, SuppCode$, Action%, Token&)
'''Nov-Dec96 CKJ/EAC Licence interface
'''Parameters:
''' Ctl is a control which has one or more attributes to be set.
'''   examples are mnuItem.enabled, mnuItem.visible, frmForm.tag
'''   The name of the control is central to the licence operation
''' SuppCode$ may be optional - depends on individual controls.
'''   It is used to specify a licence element for generic controls.
''' Action is applied to the control
'''   0 no  action
'''   1 set visible
'''   2 set enabled
'''   4 set tabstop
'''   8 set checked
'''  16 set text/caption
'''  32 set tag
'''  These can be added together, where doing so is sensible,
'''   eg   3 sets both visible & enabled to T or F
'''       48 sets text and tag of a textbox to same value
''' Token - to be decided; probably supplementary security
'''    leave at zero for now
'''16Dec96 CKJ Ready for testing
''
''Dim Value$, LinkID$, i%, Filter%
''
''   On Error Resume Next
''
''   LinkID$ = vbGetCtrlName(ctl.Parent) & "." & vbGetCtrlName(ctl)
''   LinkID$ = LinkID$ & "." & Format$(ctl.index) 'resume next if 'object not an array'
''   If SuppCode$ <> "" Then LinkID$ = LinkID$ & "." & SuppCode$
''
''   Value$ = fLX(LinkID$, Token&)
''
''   For i = 0 To 5
''      Filter = 2 ^ i                                 ' 1  2  4  8 16 32
''      Select Case Action And Filter
''         Case 1:  ctl.Visible = (Val(Value$) <> 0)   'reduce to boolean
''         Case 2:  ctl.Enabled = (Val(Value$) <> 0)
''         Case 4:  ctl.TabStop = (Val(Value$) <> 0)
''         Case 8:  ctl.Checked = (Val(Value$) <> 0)
''         Case 16
''            ctl.Text = Value$                        'only one will fire successfully
''            ctl.Caption = Value$
''         Case 32: ctl.Tag = Value$
''         End Select
''   Next
''   On Error GoTo 0
''
''End Sub

Function money(Action%) As String
'30May97 CKJ Writing commenced
'Provide units of currency and related data
'Note that all these are variable length, and are intended for
'display on screen in system font (where £ = Alt-163 or CHR$(163))
'This may not be correct in other fonts including
' Terminal, Courier New and Times New Roman where £ = Alt-156
'
'Action   INI file   Result etc...
'  1     MoneyUnit   Pound  Dollar
'  2     MoneyUnits  Pounds Dollars
'  3     Money/100   Penny  Cent
'  4     Money/100s  Pence  Cents
'  5     SymbolUnit  £      $
'  6     Symbol/100  p      c
'  7     SymbolHdg   £.pp   $:c
'  8     SymbolIntl  GBP    NZ$
'  9     SalesTax    VAT    GST
'
'Note that the .044 files were always intended for SCREEN use
'and the corresponding .INI files (eg TPNprogs.ini Printer.ini)
'designed for printed output.
'We probably ought to continue that tradition except when
'printing true-type fonts via the GDI, where preview on-screen
'is also used, eg HighEdit based printing. For this use the .044
'approach.
'
'27Jun97 CKJ Corrected default values
'12Jul97 CKJ Changed £.p to £.pp
'18Aug97 CKJ Corrected file name by removing spurious path

'Possible Mods:
'--------------
' Add 100 for printer codes??
' Consider fixed size versions, eg have AU$ and just $ as separate items
' Consider the problems of different fonts on-screen - some have £ in diff positions
' also direct printing to various printers
' and GDI printing too

Static Unit$, Units$, Hundredth$, Hundredths$, SymbUnit$, Symb100s$, SymbHdg$, SymbIntl$, SalesTax$
Dim FILE$

   If Unit$ = "" Then
         FILE$ = "country"  '18Aug97 CKJ Changed from ascroot$ & "\country" as path is added in TxtD
         Unit$ = TxtD(FILE$, "", "Pound", "MoneyUnit", 0)
         Units$ = TxtD(FILE$, "", "Pounds", "MoneyUnits", 0)
         Hundredth$ = TxtD(FILE$, "", "Penny", "Money/100", 0)
         Hundredths$ = TxtD(FILE$, "", "Pence", "Money/100s", 0)
         SymbUnit$ = TxtD(FILE$, "", "£", "SymbolUnit", 0)
         Symb100s$ = TxtD(FILE$, "", "p", "Symbol/100", 0)
         SymbHdg$ = TxtD(FILE$, "", "£.pp", "SymbolHdg", 0)
         SymbIntl$ = TxtD(FILE$, "", "GBP", "SymbolIntl", 0)
         SalesTax$ = TxtD(FILE$, "", "VAT", "SalesTax", 0)
      End If

   Select Case Action
      Case 1: money = Unit$                                   'Pound
      Case 2: money = Units$                                  'Pounds
      Case 3: money = Hundredth$                              'Penny
      Case 4: money = Hundredths$                             'Pence
      Case 5: money = SymbUnit$                               '£
      Case 6: money = Symb100s$                               'p
      Case 7: money = SymbHdg$                                '£.pp
      Case 8: money = SymbIntl$                               'GBP
      Case 9: money = SalesTax$                               'VAT
      End Select

End Function

Function NoExp$(Number!)
'-----------------------------------------------------------------------------
'8Oct93 CKJ Remove exponentials unless number is too large to fit in 9 chars.
'
' If number is v small eg <~1E-8 ish then return zero
'      "       v large eg >~1E8 ish  then keep exponent but fit in 9 chars.
' Otherwise return ordinal value.
'
'Cast Single to Double precision and return a string
'Cast value to currency type if there is still an exponential (D or E)
'If value >= 1,000,000,000 then replace with shortened exponential string
' - string returned will have major precision components in first 9 chars.
'
'(Currency data type:  -123456789012345.1234)
'-----------------------------------------------------------------------------
Dim curr As Currency, vald#, vals$, expon%, expons$

   vald# = Val(Str$(Number!))                          'cast Single to Double
   vals$ = Str$(vald#)                                 'convert to string
   expon = InStr(vals$, "D")                           'is there an exp?
   If expon = 0 Then expon = InStr(vals$, "E")
   If expon Then                                       'yes
         On Error Resume Next
         curr = Val(vals$)                             'cast to 'currency'
         If Err = 0 Then vals$ = Str$(curr)            'convert to string
         On Error GoTo 0
      End If
   If (1# * Val(vals$)) >= 1000000000# Or (1# * Val(vals$)) <= -100000000# Then
         expon = Log(Abs(1# * Val(vals$))) / Log(10)        'generate exponent
         expons$ = "E" & Trim$(Str$(expon))
         If InStr(vals$, ".") = 0 Then
               vals$ = Left$(vals$, 2) & "." & Mid$(vals$, 3) 'insert decimal point
            End If
         vals$ = Left$(Trim$(vals$), 9 - Len(expons$)) & expons$
      End If

   NoExp$ = Trim$(vals$)

End Function

Sub openrandomfile(FILE$, length%, chan%)
'-----------------------------------------------------------------------------
'    Open a random access file with error checking, returns Chan
'    Retries if locked, until able to continue
'
'26Oct91 CKJ Added 'ACCESS READ WRITE'
' 7Apr94 CKJ VBW: Binary access
'29apr02 CKJ Added extended message
'08Nov05 CKJ Obsolete procedure, used only by GetPointerDisk. Now set private.
'24May11 CKJ Now used by JVM interface - Private removed
'-----------------------------------------------------------------------------
Dim sMsg As String

   'On Error GoTo LockError2
   On Error GoTo OpenRandomfile_Err
   Do
      ErrNum = False
      chan = FreeFile
      'Open file$ For Random Access Read Write Shared As #chan Len = length
      Open FILE$ For Binary Access Read Write Shared As #chan
      'Err70msg errnum, "File"                                                            '29apr02 CKJ
      sMsg = "Channel=" & Format$(chan) & ", Length=" & Format$(length)
      Err70MsgEx ErrNum, "File " & FILE$, sMsg, m_strModuleName, "OpenRandomFile"
   Loop While ErrNum
   On Error GoTo 0
   
   TrackOpenedFiles chan, FILE$, "OpenRandomFile"           '24Aug99 CKJ

Exit Sub

OpenRandomfile_Err:
   ErrNum = Err
   sMsg = "Parameters: File=" & FILE$ & cr & "Channel=" & Format$(chan) & ", Length=" & Format$(length)
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", "OpenRandomFile", sMsg) = 1 Then Resume Next

End Sub

''08Nov05 CKJ Obsolete procedure - removed
''Sub OpenRandomFilePtr(FILE$, length%, chan%)
'''-----------------------------------------------------------------------------
'''   Create/Open RA file where first record is a pointer record.
'''
'''      Open a random access file in the normal way, but if the file does
'''      not exist then create it with the pointer record (first 4 bytes)
'''      set to Ptr = 1
'''
'''  This is intended for use on Transaction logs etc, BUT this procedure
'''  does NOT set Novell access rights - these must be set by hand!
'''
'''  It does prevent the first transaction being written some megabytes
'''  down the file, as happens when garbage on disk is used as a pointer.
'''
'''  WARNING! Theoretical risk of a lost transaction, as follows:
'''  Two users open the file at almost the same time, and the file does not
'''  yet exist. Both receive fileexists=false, so both proceed to write a
'''  pointer of one. First updates pointer to 2 before second has written
'''  its pointer of 1. This then happens, so second also then updates to 2
'''  and writes back. This is almost inconceivable since the timing of such
'''  updates would be impossible unless one machine was PAUSEd between the
'''  fileexists and the getpointer, on the first transaction of the month,
'''  while another machine was also trying to get a pointer.
'''
''' 7Aug91 CKJ Proc written
''' 8Apr92 CKJ Firefighting - why does fileexists seem to miss seeing Translog?
'''-----------------------------------------------------------------------------
''Dim dummy%
''
'' ' IF NOT fileexists(file$) THEN GetPointer file$, 1, 2  ' Write Ptr=1 to file
''   dummy = fileexists(FILE$) ' call proc to force message on screen & to disk
''   openrandomfile FILE$, length%, chan%
''
''End Sub

Function pad$(char$, length%)
'Left justify string, adding spaces at the right, or truncating at the right

   pad$ = Left$(char$ & Space$(length), length)

End Function

Function PadVar$(ByVal text$, char$, length%, justify$)
' text to pad, pad with, length of padding, justify
'12Feb03 TH Moved here from Patbill.Bas to avoid referencing problems

Dim txtL%

   text$ = Trim$(text$)
   txtL% = Len(text$)
   
   If txtL >= length Then
      PadVar$ = Left$(text$, length)
   ElseIf UCase$(justify$) = "R" Then
      PadVar$ = String$(length% - txtL%, char$) & text$
   Else
      PadVar$ = text$ & String$(length% - txtL%, char$)
   End If

End Function

Sub AcquireLock(pathfile$, LockType, done, Optional ByRef strLockedMsg As String)
' PathFile: Full pathname of file to lock, filename also used as message.
' Locktype: 0 Release, 1 Acquire shared (Deprecated), 2 Acquire exclusive lock
'                     -1  " keep trying,-2  " keep trying every 5 seconds.
' Returns:  Done T/F where False is because the user escaped

'07Feb17 TH Taken the existing sub and converted to DB handling. The old file locking can still be used on a setting via a pass through
'           Locking on file replace by call to DB Table PharmacyBusinessLock. Compund of name and locationID_Site essentially
'           replaces the file. The row is written with the SiteID so this doesnt stop re-entrancy from the same  session !!
'           It will however provide the details of the locking session (user ,terminal) when encountering a lock
'           Code check suggests only exclusive lock used and therefore needed here (no usage of shared lock) - So this will no longer be
'           supported in the DB system.
'           ALSO File locks will now be path independent. Code checks suggest all locks currently live in dispdata folders and are therefore
'           stockholding specific so this matches the DB paradigm > lock name and site is unique per process
'           Therefore the lock will be siteID and Old file name (no path) and extension. This is extracted from inbound pathfile$ (TFS 156987)





Dim k1 As kbdcontrol
Dim msg$, Msg2$, KeepTrying%, count%, LockChan%, ans$
Static NumLocks%, Locks$(), Lockdata%()
Dim strLockName As String
Dim strLockNameCache As String
Dim lngOK As Long
Dim strParameters As String
Dim rsLock As ADODB.Recordset

   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Locking", "N", "PharmacyFileLocking", 0)) Then
      AcquireLockOLD pathfile$, LockType, done
      Exit Sub
   End If
   
   'DO we still want this - it only shows locks from this client - kept for now
   If LockType = 100 Then
         msg$ = ""
         For count = 1 To NumLocks
            msg$ = msg$ & "      " & Format$(Lockdata(2, count)) & TB
            Select Case Lockdata(1, count)
               Case 0: msg$ = msg$ & "Released"
               Case 1: msg$ = msg$ & "Shared"
               Case 2: msg$ = msg$ & "Exclusive"
               End Select
            msg$ = msg$ & TB & Locks$(count)
         Next
         pathfile$ = msg$
         done = True
         Exit Sub
      End If

   If done = 1 Then done = True: Exit Sub  'THis used to release a lock for shared access - can find no instance of this usage
   done = True
   msg$ = pathfile$
   Msg2$ = T1("IsLckd", " is locked by another user")
   pathfile$ = UCase$(pathfile$)
   KeepTrying = (LockType < 0)
   LockType = Abs(LockType)
   strLockName = GetFileNameFromPath(pathfile$)
   strLockNameCache = strLockName & "_" & CStr(gDispSite)
   'Following section used to check if this lock is held by us before attemping to close
   'It may seem profligate, but here we will simply replace this by going to the DB to close regardless
   'Can revisit if necessary but might need to make site specific
   
   
   '07Feb17 TH This relies very much on the array being correct. But it always used to be. Use Session as safeguard ?
   '           The search through the array should be very specific - however, session addition adds extra level
   '           of security to ensure we are OK
   '           As lock aquisition can now identify that we already have the lock and honour this we dont need to
   '           close before taking the lock out
   For count = 1 To NumLocks
      'If Locks$(count) = pathfile$ Then
      If Locks$(count) = strLockNameCache Then
   
            If Lockdata(1, count) = LockType Then Exit Sub
            If Lockdata(1, count) <> 0 Then  '10Apr95 CKJ Added

                  ''Close Lockdata(2, count)
                  '07Feb17 TH ?? This relies very much on the array being correct. Use Session as safeguard ?
                  'The search through the array should be very specific - however, session addition adds extra level
                  'of security to ensure we are OK
                  'However, as lock aquisition can now identify that we already have the lock and honour this we dont need to
                  'close before taking the lock out
                  strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 255, strLockName)
                  lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyBusinessLockClose", strParameters)
                  'We dont really care aboutthe return - as far as we are concerned the lock is gone
                  'TrackOpenedFiles Lockdata(2, count), "", ""          '24Aug99 CKJ
                  Lockdata(1, count) = 0   ' released
                  'Lockdata(2, count) = 0   ' chan = 0 " " 'chan no longer used
               End If
            Exit For
         End If
   Next


   'Again for now we are making local tracking of locks redundant ? No - keep for debug and handling above
   If NumLocks < count Then
      NumLocks = count            ' same No as before or NumLocks + 1
      ReDim Preserve Locks$(NumLocks)
      ReDim Preserve Lockdata(1 To 2, NumLocks)
   End If
   'Locks$(count) = pathfile$
   Locks$(count) = strLockNameCache 'Use simpler variant - path must equate to siteID now
   Lockdata(1, count) = LockType
   If LockType = 0 Then Exit Sub     ' no further action on releasing a lock
   
   On Error GoTo AcquireLock_Err
   Do
      done = True
      'LockChan = FreeFile
      'If LockType = 1 Then ' shared lock
      '      Open pathfile$ For Binary Access Read Lock Write As #LockChan Len = (1)
      '   Else              ' exclusive lock
      '      Open pathfile$ For Binary Access Read Write Lock Read Write As #LockChan Len = (1)
      '   End If
      'Code analysis suggests exclusive lock is all that is used, so this is all we will support for DB version
      'Also we only seem to support site level (dispdata) locking - again we will thus only support this now
      
      strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
      gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 255, strLockName)
      Set rsLock = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBusinessLockAcquire", strParameters)
   
      If rsLock.EOF Or rsLock.RecordCount > 1 Then
         strLockedMsg = "Could not lock process." & crlf & "Reason Unknown"
         'popmessagecr "ASCribe", strMsg
''         LogMsg = strMsg
''         strMsg = strMsg & crlf & crlf & "Do you wish to continue?"
''         askwin "!EMIS Health", TxtD(dispdata$ & "\patmed.ini", "", strMsg, "RxLockingQuestion", 0), strAns, k
''         If strAns = "N" Or k.escd Then
''            blnOK = False
''         Else
''            blnOK = True
''            WriteLogSQL LogMsg, "PrescriptionLockOverride", 0, 0
''         End If
         done = False
      Else
         If GetField(rsLock!sessionID) = g_SessionID Then
            'blnOK = True 'There is a lock - it is ours !
            strLockedMsg = ""
         Else
            'Geuine lock from another identifiable source
            strLockedMsg = " Warning - " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & " is already locking this process."
            done = False
         End If
       End If
       
      'If done Then
      If strLockedMsg = "" Then
            'We have locked
            'Lockdata(2, count) = LockChan 'we dont care about channels
            'TrackOpenedFiles LockChan, pathfile$, "AcquireLock " & Iff(LockType = 1, "Shared", "Exclusive")          '24Aug99 CKJ
         Else
            setinput 0, k1
            'k1.helpnum = 0
            'k1.helpfile = ASCROOT$ + "\it.hlp"
            ans$ = "Y"
            Do While InStr(msg$, "\")
               msg$ = Mid$(msg$, InStr(msg$, "\") + 1)
            Loop
''            If KeepTrying Then
                  'If KeepTrying = True Then
                        'popmessage "!n!i" + Msg$ + Msg2$, T1("StillLckd")    '!"Still trying to get access, press [Esc] to quit"
                   '     KeepTrying = 1
                   '  End If
                  'PLAY "MbMsL64T255E"
                  'waitforkeyorticks 100, ans$
                  'k1.passwrd = True
                  'getyesorno ans$, k1

                  '5Mar97 CKJ Temporary addition until kbd scanning available !!**
''                  Confirm msg$ & Msg2$, T1("RetryLckd"), ans$, k1
''               Else
                  'Confirm msg$ & Msg2$, T1("RetryLckd", "try again"), ans$, k1
                  'Confirm msg$ & strLockedMsg, T1("RetryLckd", "try again"), ans$, k1
                  askwin "!" & msg$, strLockedMsg & crlf & crlf & " OK to " & T1("RetryLckd", "try again"), ans$, k1
''               End If
            If ans$ = "N" Or k1.escd Then
                  Lockdata(1, count) = 0       '5Mar97 CKJ replaced from DOS version
                  Exit Do
               End If
         End If
   Loop Until done
   'If KeepTrying = 1 Then 'closewindow
   On Error GoTo 0
Exit Sub

AcquireLock_Err:
   done = False
Resume Next

End Sub

Sub AcquireLockOLD(pathfile$, LockType, done)
' PathFile: Full pathname of file to lock, filename also used as message.
' Locktype: 0 Release, 1 Acquire shared, 2 Acquire exclusive lock
'                     -1  " keep trying,-2  " keep trying every 5 seconds.
' Returns:  Done T/F where False is because the user escaped
'12Apr93 CKJ Proc written
'19Apr93 CKJ Added override if done=1
'24Feb94 CKJ Added done=true at start
'10Apr95 CKJ/ASC Corrected error on re-using an unlocked file.
'            Also corrected escape from attempted, failed, lock.
'17Oct94 CKJ Windows version
' 5Mar97 CKJ Replaced line from DOS version & added confirm box regardless
'            of the 'keeptrying' flag
'24Aug99 CKJ LockType 100 defined: return debug info in the 'pathfile$' parameter
'07Feb17 TH  Rebadged - this proc is fall back if the DB level locking goes wrong. (TFS 156987)

Dim k1 As kbdcontrol
Dim msg$, Msg2$, KeepTrying%, count%, LockChan%, ans$
Static NumLocks%, Locks$(), Lockdata%()
   
   If LockType = 100 Then
         msg$ = ""
         For count = 1 To NumLocks
            msg$ = msg$ & "      " & Format$(Lockdata(2, count)) & TB
            Select Case Lockdata(1, count)
               Case 0: msg$ = msg$ & "Released"
               Case 1: msg$ = msg$ & "Shared"
               Case 2: msg$ = msg$ & "Exclusive"
               End Select
            msg$ = msg$ & TB & Locks$(count)
         Next
         pathfile$ = msg$
         done = True
         Exit Sub
      End If

   If done = 1 Then done = True: Exit Sub
   done = True
   msg$ = pathfile$
   Msg2$ = T1("IsLckd", " is locked by another user")
   pathfile$ = UCase$(pathfile$)
   KeepTrying = (LockType < 0)
   LockType = Abs(LockType)
   
   For count = 1 To NumLocks
      If Locks$(count) = pathfile$ Then
            If Lockdata(1, count) = LockType Then Exit Sub
            If Lockdata(1, count) <> 0 Then  '10Apr95 CKJ Added
                  Close Lockdata(2, count)
                  TrackOpenedFiles Lockdata(2, count), "", ""          '24Aug99 CKJ
                  Lockdata(1, count) = 0   ' released
                  Lockdata(2, count) = 0   ' chan = 0 " "
               End If
            Exit For
         End If
   Next
   If NumLocks < count Then
         NumLocks = count            ' same No as before or NumLocks + 1
         ReDim Preserve Locks$(NumLocks)
         ReDim Preserve Lockdata(1 To 2, NumLocks)
      End If
   Locks$(count) = pathfile$
   Lockdata(1, count) = LockType
   If LockType = 0 Then Exit Sub     ' no further action on releasing a lock
   
   On Error GoTo AcquireLockOLD_Err
   Do
      done = True
      LockChan = FreeFile
      If LockType = 1 Then ' shared lock
            Open pathfile$ For Binary Access Read Lock Write As #LockChan Len = (1)
         Else              ' exclusive lock
            Open pathfile$ For Binary Access Read Write Lock Read Write As #LockChan Len = (1)
         End If

      If done Then
            Lockdata(2, count) = LockChan
            TrackOpenedFiles LockChan, pathfile$, "AcquireLock " & Iff(LockType = 1, "Shared", "Exclusive")          '24Aug99 CKJ
         Else
            setinput 0, k1
            'k1.helpnum = 0
            'k1.helpfile = ASCROOT$ + "\it.hlp"
            ans$ = "Y"
            Do While InStr(msg$, "\")
               msg$ = Mid$(msg$, InStr(msg$, "\") + 1)
            Loop
''            If KeepTrying Then
                  'If KeepTrying = True Then
                        'popmessage "!n!i" + Msg$ + Msg2$, T1("StillLckd")    '!"Still trying to get access, press [Esc] to quit"
                   '     KeepTrying = 1
                   '  End If
                  'PLAY "MbMsL64T255E"
                  'waitforkeyorticks 100, ans$
                  'k1.passwrd = True
                  'getyesorno ans$, k1

                  '5Mar97 CKJ Temporary addition until kbd scanning available !!**
''                  Confirm msg$ & Msg2$, T1("RetryLckd"), ans$, k1
''               Else
                  Confirm msg$ & Msg2$, T1("RetryLckd", "try again"), ans$, k1
''               End If
            If ans$ = "N" Or k1.escd Then
                  Lockdata(1, count) = 0       '5Mar97 CKJ replaced from DOS version
                  Exit Do
               End If
         End If
   Loop Until done
   'If KeepTrying = 1 Then 'closewindow
   On Error GoTo 0
Exit Sub

AcquireLockOLD_Err:
   done = False
Resume Next

End Sub

''Sub AddFileToCache(io_sPathFile As String)
'''---------------------------------------------------------------------------------------------------------------------------
'''14Nov00 CKJ Written
'''            Read INI type file, add filename to file cache and add all lines and sections to the item cache
'''            Takes fully qualified path name, adds default drive if necessary, and returns revised name.
'''            NB: It makes no allowance for the possibility that the file and/or items may already be in the caches
'''             existing entries will be overwritten, new entries added, but note that anything in the cache which has
'''             been deleted from the file will not be touched. If this matters then ensure the cache is cleared prior
'''             to using this routine.
'''
'''            Cache whole file without using the API call
'''            This is designed to improve reliability & reduce network traffic
'''            Once a new file has been encountered, read the entire file in one pass
'''            Read it in chunks of 10-30K, reducing the need for multiple tiny network packets
'''            Cache misses on the file cache are still recorded, but not for the item cache
'''            because the whole file is held and therefore a heap miss is also a cache miss.
'''22Nov00 CKJ In Report.exe and Overnite.exe, ReadSiteInfo was not called until well into the program,
'''            so pseudo-constants were not set causing an infinite loop since crlf = ""
'''            Added trap for this, just in case it happens on another project.
'''07may04 CKJ Out of string space when adding crlf to sBuffer - due to 30K buffer + 30K temp string space
'''            Solution is to reduce buffer size - but must still be larger than any single line to parse
'''            This is expected to be 1K max, so set buffer to 3K. This uses 54K less space.
'''---------------------------------------------------------------------------------------------------------------------------
''Dim errnumcopy As Integer                                                 'preserve global error status
''Dim filefound As Integer                                                  'file exists T/F
''Dim quotes As Integer                                                     'position of quotes in string
''Dim iChan As Integer                                                      'Channel for opened file
''Dim sBuffer As String                                                     'String buffer
''Dim sRemnant As String                                                    'Unused remains of last buffer
''Dim sLine As String                                                       'Individual line from file
''Dim iPosnL As Integer                                                     'Left pointer in string buffer
''Dim iPosnR As Integer                                                     'Right pointer in string buffer
''Dim iBufLen As Integer                                                    'Length of buffer to be read
''Dim sSection As String                                                    'Ini file [section] in scope
''Dim iEquals As Integer                                                    'Position of equals sign
''Dim sNewEntry As String                                                   'Temp name while adding to heap
''
''   errnumcopy = ErrNum
''   ErrNum = False
''
''   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
''   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0
''
''   io_sPathFile = UCase$(io_sPathFile$)
''   If Left$(io_sPathFile, 2) <> "\\" And Mid$(io_sPathFile, 2, 1) <> ":" Then io_sPathFile = Left$(CurDir$, 2) & io_sPathFile
''   filefound = fileexists(io_sPathFile)
''   Heap 10, fileHeapID, io_sPathFile, Iff(filefound, "1", "0"), 0   'Add this file to the filecache 1=found 0=not found
''
''   If filefound Then                                                '06Jul00 CKJ FILL ITEM CACHE HERE
''         'data stream resembles   '[]<cr><lf>ITEM=THING<cr><lf><cr><lf>[SECTION]<cr><lf>ITEM=THING<cr><lf>'
''         iChan = FreeFile
''         Do                                                         'open file safely with retries
''            ErrNum = False
''            Open io_sPathFile For Binary Access Read Lock Write As #iChan
''            'Err70msg errnum, "File " & io_sPathFile                '29Apr02 CKJ
''            Err70MsgEx ErrNum, "File " & io_sPathFile, "attempting to open file", m_strModuleName, "AddFileToCache"   '29Apr02 CKJ
''         Loop While ErrNum
''         TrackOpenedFiles iChan, io_sPathFile, "AddFileToCache"     '29Apr02 CKJ
''         sSection = ""                                              'default section
''         sBuffer = ""                                               'buffer is empty
''         iBufLen = 0                                                'and length = 0
''         iPosnL = 1                                                 'we'll parse from byte position 1
''         Do                                                         'Keep buffer betwen two thirds full & full
''            'If iChan > 0 And Len(sBuffer) - iPosnL < 20 * 1024 Then'Still stuff to read & buffer is partly used up
''            If iChan > 0 And Len(sBuffer) - iPosnL < 3 * 1024 Then  'Still stuff to read & buffer is partly used up
''                  sRemnant = Mid$(sBuffer, iPosnL)                  'copy remaining unused bytes
''                  iPosnL = 1                                        'and read from left margin again next time
''                  'Select Case Len(sRemnant)                                                       07may04 CKJ removed
''                  '   Case 0:              iBufLen = 30 * 1024      'fill to exactly 30K              "
''                  '   Case Is < 10 * 1024: iBufLen = 20 * 1024      'fill to between 20K & 30K        "
''                  '   Case Else:           iBufLen = 10 * 1024      'fill to between 20K & 30K        "
''                  '   End Select                                                                      "
''                  iBufLen = 3 * 1024                                '07may04 CKJ Fixed size small buffer; fill to between 3K & 6K
''                  iBufLen = LesserOf(LOF(iChan) - Loc(iChan), iBufLen) 'or number of bytes remaining if less
''                  sBuffer = Space$(iBufLen)                         'reserve correct amount of space
''                  Get #iChan, , sBuffer                             'read next iBufLen bytes
''                  sBuffer = sRemnant & sBuffer                      'glue the bits together
''                  sRemnant = ""                                     'reclaim the temp space
''
''                  If Loc(iChan) >= LOF(iChan) Then                  'end of file reached
''                        Close iChan
''                        TrackOpenedFiles iChan, "", ""              '29Apr02 CKJ
''                        iChan = 0
''                        'sBuffer = sBuffer & crlf                   'just in case last line does not end with crlf  '07may04 CKJ removed
''                        If Right$(sBuffer, 2) <> crlf Then                                                          '   "        added
''                              sBuffer = sBuffer & crlf              'only when last line does not end with crlf     '   "          "
''                           End If                                                                                   '   "          "
''                     End If
''               End If
''
''            'Parse one line, then go round again
''            iPosnR = InStr(iPosnL, sBuffer, crlf)                   'end of first line indeterminate until checked
''            If iPosnR Then                                          'crlf found at right end of line of text
''                  sLine = Mid$(sBuffer, iPosnL, iPosnR - iPosnL)    'whole line without cr or lf chars
''                  iPosnL = iPosnR + 2                               'skip past the <crlf> (may be beyond end of string)
''                  Select Case Left$(sLine, 1)                       'parse the string based on first character
''                     Case "", " ", ";", "'", "="                    'blank line, comment ( ;') or no item code (=)
''                        'no action
''                     Case "["                                       'Its probably a section heading [likethis]
''                        sLine = Left$(sLine, InStr(sLine, "]"))     'keep only chars to left of ']' if any
''                        If Len(sLine) Then                          'if there were some put them as new section name
''                              sSection = Trim$(UCase$(Mid$(sLine, 2, Len(sLine) - 2)))  'without the brackets
''                           End If
''                     Case Else                                      'may be a valid 'ITEM = THING' line
''                        iEquals = InStr(sLine, "=")                 'does the line have an '=' sign?
''                        If iEquals Then                             'yes...
''                              sNewEntry = RTrim$(Left$(sLine, iEquals - 1))           'xyz=' or 'xyz =' => 'xyz'
''                              sNewEntry = io_sPathFile & "|" & sSection & "|" & UCase$(sNewEntry)
''                              sLine = LTrim$(Mid$(sLine, iEquals + 1))                '=abc' or '= abc' => 'abc'
''                              'clean up double quotes e.g. =<null>   =LINE   ="LINE" comment
''                              If Left$(sLine, 1) = Chr$(34) Then                      'open quotes
''                                    quotes = InStr(2, sLine, Chr$(34))                'close quotes
''                                    If quotes Then sLine = Mid$(sLine, 2, quotes - 2) 'keep between quotes only
''                                 End If
''                              Heap 10, iniHeapID, sNewEntry, sLine, 0                 'post on Heap
''                           End If
''                     End Select
''               End If
''         Loop Until iChan = 0 And iPosnL >= Len(sBuffer)            'stop when file is closed and buffer has been read
''      End If
''
''   ErrNum = errnumcopy
''
''End Sub

Sub AddSectionToCacheSQL(ByVal strCategory As String, ByVal strSection As String)

Dim rsConfiguration As ADODB.Recordset
Dim strParameters As String, str1 As String, str2 As String
Dim strValue As String

   'errnumcopy = errnum
   'errnum = False
   
   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0
   If Len(TB) = 0 Then
      MsgBox "Design Fault: Inform EMIS Health Hospital Pharmacy that ReadSiteInfo was not called when program started", MB_ICONSTOP, "System Error"
   End If
     
   Heap 10, fileHeapID, Format$(SiteNumber) & "|" & strCategory & "|" & strSection, "1", 0  'Add Section to ini heap
   
   'Now get all the possible keys
   '08Aug12 CKJ Must be SiteID now, not "LocationID_Site" because 'new' transport layer is name not ordinal driven
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                   gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 255, strSection)
   Set rsConfiguration = gTransport.ExecuteSelectSP(g_SessionID, "pWConfigurationSelectSection", strParameters)
   If Not rsConfiguration.EOF Then
   'FILL ITEM CACHE HERE
      rsConfiguration.MoveFirst
      Do While Not rsConfiguration.EOF
         str1 = Format$(SiteNumber) & "|" & strCategory & "|" & strSection & "|" & Trim$(GetField(rsConfiguration!key))
         strValue = GetField(rsConfiguration!Value)
         If Len(strValue) > 2 Then
            str2 = Mid$(Trim$(strValue), 2, Len(Trim$(strValue)) - 2)
         Else
            str2 = ""
         End If
         Heap 10, iniHeapID, str1, str2, 0
         rsConfiguration.MoveNext
      Loop
   End If
   rsConfiguration.Close
   Set rsConfiguration = Nothing
   
   'errnum = errnumcopy

End Sub

Sub ParseCtrlChars(filename$, Section$, Item$, Changed)
'12Jul94 CKJ Written (Pinched from Code3of9)
'            For ASCII characters below 32 type [nnn] eg for Escape use [27]
' 8Nov94 CKJ Added definition of printer codes, using TTOPIL.INI
'            Define printer controls   as Reset=[27]@   etc
'            Ini file conventions apply, namely ' starts a comment.
'            The code must start with a letter, but can then be alphanumeric.
'            The letters can be in upper or lower case.
'            Use in text as; "... items [Bold]must[Norm] be done daily ..."
'            If [Bold] and [Norm] represent bold and normal text
'16Jan95 CKJ Copied from TTOPIL, but uses file tpnini$.
'            If item not found then it is left unchanged
'10Jun95 CKJ Moved to PrntCtrl. File & section now given as parameters
'            Item names can now be any mix of alpha-numeric characters
'            which are not otherwise parsed.
'            Multiple strings can now be defined;
'            [<number of chars>x<char>] or [<number of chars>x<ASCII value>]
'            where number of chars is 1 to 32767 and char is 0 to 255
'            eg 80 spaces [80x ] or [80x32]
'               40 dashes [40x-]
'               Note that [40x[dash]] and dash="-" is acceptable if the
'               procedure is called iteratively until changed=false
'12Sep96 CKJ Mod to trap text ending with an unmatched openbrace
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22

Dim digits%, length&, posn&, openbrace&, closebrace&, char$, middle$, mult&, remaind$   'MM-4782
Dim xposn&, ch&, found%


   length = Len(Item$)
   If length Then
         posn = 1
         Do
            openbrace = InStr(posn, Item$, "[")
            closebrace = 0
            If openbrace Then closebrace = InStr(openbrace + 1, Item$, "]")
            If closebrace > openbrace And openbrace > 0 Then
                  char$ = ""
                  middle$ = Mid$(Item$, openbrace + 1, closebrace - openbrace - 1)
                  If Len(middle$) > 0 Then
                        Select Case Left$(middle$, 1)
                           Case "0" To "9": digits = True
                           Case Else:       digits = False
                           End Select
                        If digits Then           '[0]-[255] [1x1]-[32767x255] [80x-]
                              mult& = 1          '15Jun95 CKJ added &
                              remaind$ = middle$
                              xposn = InStr(UCase$(middle$), "X")
                              If xposn Then
                                    mult& = Val(Left$(middle$, xposn - 1))
                                    remaind$ = Mid$(middle$, xposn + 1)
                                    If mult& < 0 Or mult& > 32767 Then digits = False
                                 End If
                              If digits Then
                                    Select Case Left$(remaind$, 1)
                                       Case "0" To "9"
                                          ch& = Val(remaind$)
                                          If ch& < 0 Or ch& > 255 Then
                                                digits = False
                                             Else
                                                If Trim$(remaind$) <> Trim$(Str$(ch&)) Then digits = False
                                             End If
                                       Case Else
                                          If Len(remaind$) > 1 Then
                                                digits = False
                                             Else
                                                ch& = Asc(remaind$)
                                             End If
                                       End Select
                                 End If
                           End If
                        If digits Then
                              char$ = String$(mult&, ch&)             'print ascii char(s)
                              Changed = True
                           Else
                              char$ = TxtD(filename$, Section$, "[" & middle$ & "]", middle$, found)
                              If found Then
                                    Changed = True
                                 Else
                                    posn = openbrace + 1 'Not found or parsed
                                 End If
                           End If
                     End If
                  Item$ = Left$(Item$, openbrace - 1) & char$ & Mid$(Item$, closebrace + 1)
               Else
                  Exit Do
               End If
         Loop While openbrace > 0 And closebrace > openbrace  '12Sep96 CKJ was 'While openbrace' only
      End If

End Sub

Sub ParseItems(HeapID%, Item$, Changed%)
'17Jan95 CKJ Copied from ParseCtrlChars, but uses local data items
'12Aug97 CKJ Copied from ParseTPNDataItems, and trimmed to provide just those data items
'            which are module independant
'15Jan98 CKJ Copied from ParseStdDataItems, and modified to handle data on a shared heap.
'            This will mostly be used with gPRNheapID, and if so then user details are refreshed
'            Any other heap is used as given.
'            "FreeText" however is enabled in all heaps
'25Sep98 CKJ preserves cursor across inputwin
'19Apr04 TH  If user cancels on free text dont set a global cancel, just dont do the freetext !(#72640)
'16May04 TH  Mod to above after second check - now revert to previous value, dont assume k.escd was true !
'
'
'
'mods needed:
'   handle large files in pieces to avoid out of string space errors
'    1 - parse in memory only
'    2 - hold template in memory at start, then write to disk progressively as text grows
'    3 - read template from disk in chunks and write back as each part is parsed
'   trap iterative changes eg "[text]" -> "some[text]"
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22

Dim posn&, openbrace&, closebrace&, char$, middle$, ans$, success%, CursorStyle%    'MM-4782
Dim blnEscaped As Integer   '16May04 TH Added
Dim length As Long  '03Jul13 TH Altered to handle big stuff (TFS 67988)
                        
   If HeapID Then
        If HeapID = gPRNheapID Then
               Heap 10, HeapID, "userid", UserID$, success                'refresh common items
               Heap 10, HeapID, "username", UserFullName$, success
               Heap 10, HeapID, "terminal", ASCTerminalName(), success
               Heap 10, HeapID, "today", Format$(Now, "dd mmm yyyy"), success
               Heap 10, HeapID, "timenow", Format$(Now, "h:mm am/pm"), success
            End If
      
         length = Len(Item$)
         If length Then
               posn = 1
               Do
                  openbrace = InStr(posn, Item$, "[")
                  closebrace = 0
                  If openbrace Then closebrace = InStr(openbrace + 1, Item$, "]")
                  If closebrace > openbrace And openbrace > 0 Then
                        char$ = ""
                        middle$ = Mid$(Item$, openbrace + 1, closebrace - openbrace - 1)
                        Select Case LCase$(middle$)
                           'Case "internaltitle":    char$ = RTFinternalTitle$
                           'Case "internalheading":  char$ = RTFinternalHeading$    '12Aug97 CKJ added
                           'Case "internaltext":     char$ = RTFinternalTransfer$
                           'Case "internalheader":   char$ = RTFinternalHeader$
                           'Case "internalfooter":   char$ = RTFinternalFooter$
                           
                           Case "freetext"
                              char$ = ""
                              k.min = 0
                              k.Max = 76
                              Heap 11, HeapID, "FreeText", ans$, success          'read heap
                              CursorStyle = Screen.MousePointer                   '25Sep98 CKJ preserve cursor across inputwin
                              Screen.MousePointer = STDCURSOR
                              blnEscaped = k.escd  '16May04 TH Added
                              
                              Call InputWin("EMIS Health", "Enter one line of free text, if desired", ans$, k)
                                                            
                              Screen.MousePointer = CursorStyle
                              If Not k.escd Then
                                    char$ = ans$
                                    Heap 10, HeapID, "FreeText", ans$, success    'update heap
                                 End If
                              'k.escd = False    '19Apr04 TH Dont set a global cancel here, just dont do the freetext !(#72640)
                              k.escd = blnEscaped  '16May04 TH Added
                           Case Else
                              char$ = "[" & middle$ & "]"            'print as given if not found
                              Heap 11, HeapID, middle$, char$, success            'read heap
                              
                           End Select
      
                        If char$ = "[" & middle$ & "]" Then
                              posn = openbrace + 1
                           Else
                              Changed = True
                           End If
                        Item$ = Left$(Item$, openbrace - 1) & char$ & Mid$(Item$, closebrace + 1)
                     End If
               Loop While openbrace > 0 And closebrace > 0
            End If
      Else
         popmessagecr ".", "WARNING: ParseItems called with HeapID=0"
      End If

End Sub

Sub ParseStdDataItems(Item$, Changed)
'17Jan95 CKJ Copied from ParseCtrlChars, but uses local data items
'12Aug97 CKJ Copied from ParseTPNDataItems, and trimmed to provide just those data items
'            which are module independant
'19Apr04 TH  If user cancels on freetext input, just cancel the input, dont set cancel flag as this
'            has repercusions elsewhere.
'16May04 TH  Mod to above after second check - now revert to previous value, dont assume k.escd was true !
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22

Static freetxt$
Dim length&, posn&, openbrace&, closebrace&, char$, middle$, ans$   'MM-4782
Dim blnEscaped As Integer   '16May04 TH Added

   length = Len(Item$)
   If length Then
         posn = 1
         Do
            openbrace = InStr(posn, Item$, "[")
            closebrace = 0
            If openbrace Then closebrace = InStr(openbrace + 1, Item$, "]")
            If closebrace > openbrace And openbrace > 0 Then
                  char$ = ""
                  middle$ = Mid$(Item$, openbrace + 1, closebrace - openbrace - 1)
                  Select Case LCase$(middle$)
                     Case ""            'no action
                     Case "hospname1":  char$ = hospname1$
                     Case "hospname2":  char$ = hospname2$
                     Case "hospabbr":   char$ = hospabbr$
                     Case "userid":     char$ = UserID$             '24Oct96 CKJ new
                     Case "username":   char$ = UserFullName$
                     Case "terminal":   char$ = ASCTerminalName()
                     Case "today":      char$ = Format$(Now, "dd mmm yyyy")
                     Case "timenow":    char$ = Format$(Now, "h:mm am/pm")
                     
                     Case "internaltitle":    char$ = RTFinternalTitle$
                     Case "internalheading":  char$ = RTFinternalHeading$    '12Aug97 CKJ added
                     Case "internaltext":     char$ = RTFinternalTransfer$
                     Case "internalheader":   char$ = RTFinternalHeader$
                     Case "internalfooter":   char$ = RTFinternalFooter$
                     
                     Case "freetext"
                        char$ = ""
                        k.min = 0
                        k.Max = 76
                        ans$ = freetxt$
                        blnEscaped = k.escd  '16May04 TH Added
                        InputWin "Enter one line of free text, if desired", "", ans$, k
                        If Not k.escd Then
                              char$ = ans$
                              freetxt$ = ans$       'remember default for next time
                           End If
                        'k.escd = False  '19Apr04 TH Added - we dont want to set a global cancel here, just ignore the freetext !
                        k.escd = blnEscaped  '16May04 TH Added
                     Case Else
                        char$ = "[" & middle$ & "]"   'print as found
                     End Select

                  If char$ = "[" & middle$ & "]" Then
                        posn = openbrace + 1
                     Else
                        Changed = True
                     End If
                  Item$ = Left$(Item$, openbrace - 1) & char$ & Mid$(Item$, closebrace + 1)
               End If
         Loop While openbrace > 0 And closebrace > 0
      End If

End Sub

Function PathParse(ByVal i_strPath As String) As String
'02May02 ATW
'  Description :  Parses tags out of path strings and replaces with commonly used paths
'                 this should reduce setup woes when moving INI files between folders
'                 by allowing the path to change dynamically depending on the ini location.
'
'  Input       :     i_strPath      ;  The path to be parsed.
'
'  Output      :     Return         ;  The parsed path
'

Const TAG_DISPDATA = "[DISPDATA]"
Const TAG_PATDATA = "[PATDATA]"
Const TAG_APP = "[APPLICATION]"
   
   i_strPath = UCase$(i_strPath)

   replace i_strPath, TAG_DISPDATA, dispdata$, 0
   replace i_strPath, TAG_PATDATA, patdatapath$, 0
   replace i_strPath, TAG_APP, AppPathNoSlash(), 0

   PathParse = i_strPath
   
End Function

Function PatternMatch(Item$, Pattern$) As Boolean
'11Jul97 CKJ Written
'            Pattern$ defines the valid characters and length of the test string
'            it consists of a series of characters similar to the mask in quescrol
'             A   matches upper and lower case A to Z
'             9   matches 0 to 9
'            ' '  (ie one space) matches optional spaces at the end of the item$
'                 it is only valid at the end of the string
'            Usage: specify valid sequence of letters and numbers & optional trailing spaces
'                   eg item is NSV code Pattern is 'AAA999A'
'                   for New Zealand set Pattern to '999999 '
'06Aug98 CKJ Added extra options;
'             *   matches any character, including space at that position
'             X   matches upper & lower case A to Z plus 0 to 9
'             .   matches a decimal point only
'             0   matches 0 to 9 and/or decimal point
'            If Pattern$ = "" then all characters and lengths are unconditionally valid
'04Feb99 CFY Added extra option:
'             B   matches any alphabetic character upper & lower case plus space
'02Dec99 SF if last char in string to PatternMatch a space then don't trim

Dim valid%, min%, Max%, itemch$, pattch$, count%

   min = Len(RTrim$(Pattern$))                          'AAAA99 ' min=6
   Max = Len(Pattern$)                                  'AAAA99 ' max=7
   valid = True                                         'assume innocent until guilty
   
   If Max Then                                          'otherwise it is automatically valid
         'If Len(RTrim$(item$)) < min Then valid = False '02Dec9999 SF replaced
         '02Dec99 SF if last char in string to PatternMatch a space then don't trim
         If Right$(Pattern$, 1) = "B" Then
               If Len(Item$) < min Then valid = False
            Else
               If Len(RTrim$(Item$)) < min Then valid = False     ' do as before
            End If

         If Len(Item$) > Max Then valid = False
      
         If valid Then
               For count = 1 To Len(RTrim$(Item$))
                  itemch$ = Mid$(Item$, count, 1)
                  pattch$ = Mid$(Pattern$, count, 1)
                  Select Case pattch$
                     Case "*"                                 'unconditionaly valid
                     Case "A"
                        Select Case itemch$
                           Case "A" To "Z", "a" To "z"        'OK
                           Case Else: valid = False           'fail
                           End Select
                     Case "B"
                        Select Case itemch$
                           Case "A" To "Z", "a" To "z", Chr$(32)        'OK     '04Feb99 CFY Added
                           Case Else: valid = False                     'fail   '           "
                           End Select
                     Case "X"
                        Select Case itemch$
                           Case "A" To "Z", "a" To "z", "0" To "9"  'OK
                           Case Else: valid = False           'fail
                           End Select
                     Case "9"
                        Select Case itemch$
                           Case "0" To "9"                    'OK
                           Case Else: valid = False           'fail
                           End Select
                     Case "0"
                        Select Case itemch$
                           Case ".", "0" To "9"               'OK
                           Case Else: valid = False           'fail
                           End Select
                     Case "."
                        Select Case itemch$
                           Case "."                           'OK
                           Case Else: valid = False           'fail
                           End Select
                     Case " "
                        If count < min Then                   'fail
                              valid = False
                              popmessagecr "EMIS Health", "System Configuration Error:" & cr & "PatternMatch called with pattern '" & Pattern$ & "' containing embedded space(s)"
                           End If
                        If itemch$ <> " " Then valid = False  'fail
                     Case Else
                        valid = False
                        popmessagecr "EMIS Health", "System Configuration Error:" & cr & "PatternMatch called with pattern of '" & Pattern$ & "'"
                     End Select
                  If Not valid Then Exit For
               Next
            End If
      End If

   PatternMatch = valid

End Function

Sub plingparse(chars$, char$)
'Parse string changing nominated character to space at every occurrance
'Original purpose was to change pling (!) characters to spaces
' eg 'Paracetamol!tablets' becomes 'Paracetamol tablets' if char$="!"
'Note that   Replace chars$, char$, " ", 0   is functionally identical
'but Plingparse is quicker, especially with multiple replacements in
'a long string.
' 3Nov95 CKJ Moved from Subpatme
   
Dim plingpos%

   Do
      plingpos = InStr(chars$, char$)
      If plingpos > 0 Then Mid$(chars$, plingpos, 1) = " "
   Loop Until plingpos = 0

End Sub

Function plural$(fig As Single)
'-----------------------------------------------------------------------------
'  Returns "" if fig = 1 otherwise returns "s"
' 3Jun94 CKJ Returns null string if not UK system
' 9Jun94 CKJ Uses GetCountry
'05Jul96 KR  Updated routine to ensure win version in sync with dos.
'            now takes a single
'07Feb97 EAC Add plurals for Australia
'-----------------------------------------------------------------------------
Dim country As Integer
   
   GetCountry country

   Select Case fig
      Case 0: plural$ = "s"
      Case -1 To 1: plural$ = ""
      Case Else: plural$ = "s"
      End Select
   
   Select Case country
      Case 44, 61
      Case Else
         plural$ = ""
   End Select

End Function

Sub popmessagecr(title$, message$)
'-------------------------------------------------------------------------------
'    As POPMESSAGE but waits for keypress then does a CLOSEWINDOW
'    Single line plus title to be displayed. Usual title options available.
' 7Mar94 CKJ Changed to MSGBOX, but no support for colour
' 3Jun94 CKJ Popmessage reinstated except when forms are showing
'10Aug94 CKJ dummy looks at x posn not caption
'25Jan95 CKJ Filter out title with "\". Spelling error corrected.
'12Mar95 CKJ Use form if message is long or uses multiple lines
'23Jan98 CKJ Added icon handling BUT will need old !n!b to be removed before
'            it is fully effective.
'26Jan98 CKJ The only old prefixes still used are !n!b (set normal, bold)
'            and !n!i (set normal, inverse) therefore an icon can be selected.
'            Inverse was used for warnings & errors use MB_ICONEXCLAMATION
'            Bold was used for almost all other boxes; use MB_ICONINFORMATION
'16Feb98 CKJ Do not remove !n!b!i!f, but allow !xxxx through
'            Select the box icon with "~" in the title
'17Feb98 CKJ Remove !n!i and !n!b if found
'23Feb98 CKJ Corrected last mod
'-------------------------------------------------------------------------------
Dim ttl As String
Dim ico As Long

   ttl$ = title$
   If Left$(ttl$, 1) = "\" Then ttl$ = Mid$(ttl$, 2)
   
   ico = 0
   Select Case LCase$(Left$(ttl$, 4))                   '26Jan98 CKJ added block
      Case "!n!b": ico = MB_ICONINFORMATION
      Case "!n!i": ico = MB_ICONEXCLAMATION
      End Select

   If ico Then ttl$ = Mid$(ttl$, 5)                     '23Feb98 CKJ Corrected

   If ico = 0 Then                                      '26Jan98 CKJ added IF
         Select Case Left$(ttl$, 1)
            Case "!": ico = MB_ICONEXCLAMATION
            Case "?": ico = MB_ICONQUESTION
            Case "#": ico = MB_ICONINFORMATION
            Case ".": ico = MB_ICONSTOP
            Case "~": ico = ASC_ICONSAMPLE
            End Select
         If ico Then ttl$ = Mid$(ttl$, 2)
      End If

   popmsg ttl$, message$, ico, "", 0                    '25Jan95 was tt1$
   
End Sub

Sub popmsg(ttl$, text$, buttons As Long, ans$, escd%)
'-----------------------------------------------------------------------------
'Handling routine for MSGBOX
' This procedure can be called whether or not forms are on display.
' It returns the MSGBOX code plus a separate 'escaped' variable which
' is compatible with k.escd.
' To display multiple lines, embed CHR$(13) in text$
' If right shift is pressed when the box is closed, popfreemem is called.
' If both shift keys are pressed, and c:\shellasc.bat exists then terminate.
'
'27Oct94 CKJ Written
'12Oct97 CKJ Now uses MessageBox instead of MsgBox
'
'
'Buttons%                         [Esc] available    Escd%
'  0       (Default) OK                Y               F
'  1       OK, Cancel                  Y              T/F
'  2       Abort, Retry, Ignore        N               F
'  3       Yes, No, Cancel             Y              T/F
'  4       Yes, No                     N               F
'  5       Retry, Cancel               Y              T/F
' 16  X
' 32  ?
' 48  !
' 64  i
'  0       First button is default
'256       Second button is default
'512       Third button is default
'
'          Buttons%  Ans$  Escd%
'OK            1      Y     F
'Cancel, Esc   2            T
'Abort         3      A     F
'Retry         4      R     F
'Ignore        5      I     F
'Yes           6      Y     F
'No            7      N     F
'-----------------------------------------------------------------------------
Dim showbuttons%, stay%

   showbuttons = buttons
   buttons = MessageBox(text$, showbuttons, ttl$)
   If buttons = 2 Then
        escd = True
    Else
        escd = False
    End If
   ans$ = RTrim$(Mid$("Y ARIYN", buttons, 1))           ' reply format

End Sub

''Sub PutRecordL(r As filerecord, recno&, Rchan%, RecLen%)
'''-----------------------------------------------------------------------------
'''           Saves a random access record and unlocks it
'''
'''21Feb91 CKJ Puts a LOCKED record, then unlocks it.
'''                   ------
'''14Apr91 CKJ Flushbuffers added
''' 7Aug91 CKJ RecNo now long integer
''' 8Aug91 CKJ Proc renamed from PutRecord to PutRecordL
'''-----------------------------------------------------------------------------
''
''   PutRecordNL r, recno&, Rchan, RecLen
''   FlushBuffers Rchan
''   UnlockRecord Rchan, recno&, RecLen%
''
''End Sub

Sub PutRecordNL(r As filerecord, recno&, Rchan%, RecLen%)
'-----------------------------------------------------------------------------
'Saves a random access record without locking it
'21Feb91 CKJ Tidied & error handling extended.
' 7Aug91 CKJ RecNo now long integer
' 7Apr94 CKJ VBW: Binary access
'29Apr02 CKJ Added extended message
'24May11 CKJ Now used by JVM interface - re-enabled
'-----------------------------------------------------------------------------
Dim buffer As String, ByteNo&
Dim sMsg As String

   procname$ = "PutRecordNL"
   buffer = Space$(RecLen%)
   LSet buffer = r.record
   ByteNo& = (recno& - 1) * RecLen + 1
   On Error GoTo PutRecordNL_Err
   Do
      ErrNum = False
      Put #Rchan%, ByteNo&, buffer

      sMsg = "Channel=" & Format$(Rchan) & ", Record Num=" & Format$(recno&) & ", Length=" & Format$(RecLen)
      Err70MsgEx ErrNum, "Record in " & FileNameFromChannel(Rchan), sMsg, m_strModuleName, procname$
   Loop While ErrNum

   On Error GoTo 0
Exit Sub

PutRecordNL_Err:
   ErrNum = Err
   sMsg = "Parameters: Record Number=" & Format$(recno&) & ", Channel=" & Format$(Rchan) & ", Length=" & Format$(RecLen)
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", "PutRecordNL", sMsg) = 1 Then Resume Next

End Sub

Sub PutTextFile(pathfileext$, txt$, success%)
'Write txt$ to filepathext$. intended for RTF but can be any text
'Returns success=T/F
'17Dec96 CKJ Moved from HighASC.bas

Dim chan%
   
   success = False
   On Error GoTo PutTextfile_Err
   chan = FreeFile
   Open pathfileext$ For Output As #chan
   Print #chan, txt$;
   Close #chan
   success = True

PutTextfile_Exit:
   On Error GoTo 0
Exit Sub

PutTextfile_Err:
Resume PutTextfile_Exit

End Sub

Function ReadLanguage(Action%, Value As Variant) As Variant
'14Jul98 CKJ SiteInfo now holds optional language data
'            To avoid more Globals, this function returns data on request

Static NumLangs%, LangNow%
Static LanguageCodes(1 To 10) As String  '3 digit country numbers; 044 033 852 etc
Static LanguageNames(1 To 10) As String  'Descriptive names      ; English Chinese
Static LanguageAbbrs(1 To 10) As String  'Abbreviations          ; E C
Dim tmp$, count%, Index%

   If NumLangs = 0 Then
         tmp$ = siteinfo$("LanguageCodes", "044")
         deflines tmp$, LanguageCodes(), ",(*)", 1, NumLangs
         tmp$ = siteinfo$("LanguageNames", "English")
         deflines tmp$, LanguageNames(), ",(*)", 1, (NumLangs)
         tmp$ = UCase$(siteinfo$("LanguageAbbrs", ""))
         deflines tmp$, LanguageAbbrs(), ",(*)", 1, (NumLangs)
         For count = 1 To NumLangs
            LanguageCodes(count) = Right$("000" & Format$(Val(LanguageCodes(count))), 3)
            If LanguageNames(count) = "" Then LanguageNames(count) = "Language" & Str$(count)
         Next
         LangNow = 1                      'current language is the first in the list
      End If

   Index = 0
   On Error Resume Next
   Index = Value                          'may not be numeric
   On Error GoTo 0
   Select Case Action
      Case 1: ReadLanguage = NumLangs     'Return total number of languages
      Case 2: ReadLanguage = LangNow      'Return the array position of the current language

      Case 10, 11                         'Return number/name of Nth language, given Index=N
         Select Case Index                'Action 10 is number, 11 is name
            Case 0
               ReadLanguage = Iff(Action = 10, LanguageCodes(LangNow), LanguageNames(LangNow))
            Case 1 To NumLangs
               ReadLanguage = Iff(Action = 10, LanguageCodes(Index), LanguageNames(Index))
            Case Else
               ReadLanguage = Iff(Action = 10, 0, "")   'Error: return 0 or ""
            End Select
      
      Case 20                             'Set Current language, given Index eg 2
         Select Case Index
            Case 1 To NumLangs
               LangNow = Index
               ReadLanguage = LanguageCodes(Index)
            Case Else
               ReadLanguage = 0           'Error: return 0
            End Select
      
      Case 21                             'Set Current language, given language number eg 44
         For count = 1 To NumLangs
            If LanguageCodes(count) = Right$("000" & Format$(Index), 3) Then
                  LangNow = count
                  ReadLanguage = LanguageCodes(count)
                  Exit For
               End If
         Next
         If count > NumLangs Then ReadLanguage = 0      'Error: return 0
      
      Case 22                             'Set Current language, given language abbrev. eg E
         For count = 1 To NumLangs
            If LanguageAbbrs(count) = UCase$(Value) Then
                  LangNow = count
                  ReadLanguage = LanguageCodes(count)
                  Exit For
               End If
         Next
         If count > NumLangs Then ReadLanguage = 0      'Error: return 0
      End Select

End Function

Function ReadPrivateIniFile(iniFile$, iniSection$, IniEntry$) As String

   ReadPrivateIniFile = TxtD(iniFile$, iniSection$, "", IniEntry$, 0)

End Function

Sub readseqfile(filename As String, Numoflines%, seqdata() As String)
'-----------------------------------------------------------------------------
'                      Read sequential file into array
'
'NB no. of valid lines must be first entry in file, as integer
'   array must be large enough, & single dimension
'   first entry is put into seqdata(1) even if seqdata(0) is valid
'   if file is empty, numoflines is returned as 0
'   If any error occurs, the program halts.
'   Therefore, if the routine returns, the read was successful.
'
' example:   readseqfile  "A:\DATAFILE.TXT", length, thedata()
'-----------------------------------------------------------------------------
Dim filerrno%

   filerrno = readseqfilerr(filename, Numoflines, seqdata())
   If filerrno Then Error filerrno

End Sub

Function readseqfilerr(filename As String, Numoflines%, seqdata() As String) As Boolean
'-----------------------------------------------------------------------------
'                      Read sequential file into array
'
'NB no. of valid lines must be first entry in file, as integer
'   array must be large enough & single dimension
'   first entry is put into seqdata(1) even if seqdata(0) is valid
'   if file is empty, numoflines is returned as 0
'   the function returns a number which represents the error code
'       0  no error
'       9  subscript out of range - the array is too small for numoflines
'      62  input past EOF - fewer lines in file than numoflines stated
'      xx  Any disk access errors cause the routine to terminate
'
' example:   errnum = readseqfilerr ( "A:\DATAFILE.TXT", length, thedata() )
'
'29Apr02 CKJ Added extended message
'-----------------------------------------------------------------------------
Dim FILE$              'was shared?  Yes - see original err handler (CKJ)!!**
Dim upperlimit%, lineno%, seqfile%
Dim sMsg As String

   FILE$ = filename
   Numoflines = 0
   upperlimit = UBound(seqdata)
   lineno = 0
   On Error GoTo ReadSeqErr_Err
   seqfile = FreeFile
   Open filename For Input Access Read Lock Read Write As seqfile
   If EOF(seqfile) Then
         Numoflines = 0                               ' file is empty
         readseqfilerr = 0                            ' no error
      Else
         Input #seqfile, Numoflines
         If Numoflines = 0 Then                       ' file is empty
               readseqfilerr = 0                      ' no error
            Else
               If Numoflines > upperlimit Then
                     Numoflines = 0                   ' too many lines to read
                     readseqfilerr = 9                ' subscript out of range
                  Else
                     Do While lineno < Numoflines     ' more to read yet
                        If EOF(seqfile) Then          ' end reached last time
                              readseqfilerr = 62      ' input past end of file
                              Numoflines = 0
                              Exit Do
                           End If
                        lineno = lineno + 1
                        Line Input #seqfile, seqdata(lineno)
                     Loop
                     If Numoflines Then readseqfilerr = 0 ' data in & no error
                  End If
            End If
      End If
   Close seqfile
   On Error GoTo 0
Exit Function

ReadSeqErr_Err:
   ErrNum = Err
   
   sMsg = "Parameters: File=" & filename & cr & "Num of lines=" & Format$(Numoflines) & "Upper limit=" & Format$(upperlimit) & cr
   sMsg = sMsg & "Channel=" & Format$(seqfile) & ", Line number=" & Format$(lineno)
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", "ReadSeqFilerr", sMsg) = 1 Then Resume Next

End Function

Sub ReadSiteInfo()
'11Dec95 KR  Converted to Windows
'03jul96 KR  Removed Acquirelock routine for windows monolith.
'16Oct97 CKJ Added the command line option to set default disk drive.
'            Note that MsgBox has to be used here, as this is before the
'            configuration data is known including which disk drive to use
'            Also removed static array & dim'd it dynamically
'28Oct97 CKJ Corrected above mod when no drive letter is present.
'            SingleUserOnly% now global
'24May99 CKJ ProgsDrv now only used here. Elsewhere use AppPathNoSlash()
'09May05 CKJ WARNING: Functionality changed from 8.6, before calling ReadSiteinfo...
'            Set SiteNumber
'             - this is the account number known to customers, not the locationid_site
'            Set gTransport pointing at a valid database
'             - this is used
'04Oct12 CKJ ReadSiteInfo: moved call to gTransportADOSetLockTimeOut after dispdata has been defined (TFS45776)

Dim comfile$, cplace%, mplace%, chan%, Numoflines%
Dim raw$, ans$, z1%, z2%, siteext$
Dim patdataEXT$, dispdataEXT$, stockdataEXT$, chksum%, tmp$
Dim progsDRV$
Dim intFound As Integer
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "ReadSiteInfo"

   On Error GoTo ErrorHandler

   ReDim linex$(5)

''   TB = Chr$(9)    now a constant
   'nul is also available globally, and does not need setting here. It defaults to chr$(0).

''   '16Oct97 Block written to replace the one-liners in each prog which have no error handling
''   cplace = InStr(g_command, ":")      'if command$ contains " x:" where x is a-z A-Z
''   tmp$ = "Invalid use of command line parameter, default drive not changed" & cr & cr & UCase$(g_command)
''   If cplace > 2 Then                                              '??:'
''         If Mid$(g_command, cplace - 2, 1) = " " Then               ' ?:'
''               ans$ = UCase$(Mid$(g_command, cplace - 1, 1))        ' F:' A-Z if valid
''               Select Case ans$
''                  Case "A" To "Z"
''                     On Error Resume Next
''                     progsDRV$ = Left$(CurDir$, 2)
''                     ChDrive ans$ & ":"
''                     If Err Then
''                           MsgBox "WARNING: Command line error" & cr & "Unable to set default drive to " & ans$ & ":" & cr & "Error " & Err & " : " & Error$, 16, "ASCribe"
''                           Close
''                           End!
''                        End If
''                     On Error GoTo 0
''                  End Select
''            Else
''               MsgBox tmp$, 16, "ASCribe"
''            End If
''      ElseIf cplace Then                     '28Oct97 CKJ Colon present but not in correct place
''         MsgBox tmp$, 16, "ASCribe"
''      End If
''   SiteNumber = Val(g_command)
            
   'At this point there must be a valid connected gTransport object, SessionID, the Ascribe SiteNumber and its LocationID_Site
   'From these we get the mapped drive out of WConfiguration D|SiteInfo DispDataDRV
   'SessionID     from exe's command line or usercontrol's SetConnection
   'SiteNumber    from exe's command line or usercontrol's SetConnection
   'gDispSite     from GetLocationID_Site(SiteNumber)

   '16Aug12 CKJ added call to use same setting throughout suite (non-web transport layer only)
   '04Oct12 CKJ start with default, read config setting after dispdata has been defined (TFS45776)
   gTransportADOSetLockTimeOut 5000

   ''progsDRV$ = UCase$(Trim$(txtd("dispdata." & CStr(SiteNumber) & "\Siteinfo.ini", "", "", "DispdataDRV", intFound)))
   progsDRV$ = UCase$(Trim$(TxtD("dispdata.000\Siteinfo.ini", "", "", "DispdataDRV", intFound)))
   'If Not intFound Or progsDRV$ = "" Then                'Trap missing dispdataDRV setting in d|siteinfo
    '  Err.Raise 32767, OBJNAME & ErrSource, "Default drive has not been set" & cr & "Please correct the configuration table for site " & Format$(SiteNumber)
   'End If
   If Len(progsDRV) = 1 Then progsDRV = progsDRV & ":"
   
'Identtype$ - gone
'patno&     - gone
'UserID$    - set elsewhere
'acclevels$ - set elsewhere

   raw$ = siteinfo$("asc", "ª")
   If raw$ = "ª" Or SiteNumber = 0 Then
''         MsgBox "No site selected!" & cr & cr & UCase$(g_command), 16, "AScribe"    '28Oct97 CKJ Replaced popmessagecr as this is prior to opening .044 file
''         Close
''         END!
'         Err.Raise 32767, PROJECT & ErrSource, "No site selected: " & cr & cr & UCase$(g_command)
          Err.Raise 32767, PROJECT & ErrSource, "No site selected: " & cr & cr & "SiteNumber: " & Format$(SiteNumber) & cr & "Drive: " & progsDRV & cr & "SiteID: " & Format$(gDispSite)
     Else
         raw$ = raw$ & siteinfo$("asc1", "")             '19Jan95 CKJ
         ans$ = raw$
         decodehex ans$
         deflines ans$, linex$(), "|", 0, Numoflines%
         z1% = 0
         antihack Mid$(ans$, InStr(ans$, "|") + 1), z1%
         z2% = 0
         antihack Mid$(raw$, 4 * Len(linex$(0)) + 5), z2%
         If (linex$(0) <> Str$(z1%) & Str$(z2%)) Then    '28Oct97 CKJ Was a call to 'hacked'
''               MsgBox "It would appear that this program has been tampered with ..." & cr & "Please contact ASC Software for a replacement program." & cr, 16, "ASCribe"
''               Close
''               END!
             Err.Raise 32767, OBJNAME & ErrSource, "It would appear that this program has been tampered with ..." & cr & "Please contact Support at EMIS Health Hospital Pharmacy"
            End If
         ans$ = ""
         raw$ = ""
      End If
   
   hospabbr$ = linex$(1)
   hospname1$ = linex$(2)
   hospname2$ = linex$(3)
   singleuseronly% = Val(linex$(4))
   
   rootpath$ = progsDRV$ & "\ascroot"
''   orderpath$ = progsDRV$ & "\orders"
   
   siteext$ = Format$(SiteNumber, "000")
   If singleuseronly% Then siteext$ = "001"
   patdataEXT$ = siteinfo$("patdataEXT", siteext$)
   gPatientSite = GetLocationID_Site(Val(patdataEXT$)) '08Feb05 TH Reinstated after merge error
   
   dispdataEXT$ = siteinfo$("dispdataEXT", siteext$)
   stockdataEXT$ = siteinfo$("stockdataEXT", siteext$)

   transpath$ = progsDRV$ & "\translog"
   orderlogpath$ = progsDRV$ & "\orderlog"
   dispdata$ = progsDRV$ & "\dispdata." & dispdataEXT$
   patdatapath$ = Trim$(siteinfo$("patdataDRV", ""))
   If patdatapath = "" Then
      patdatapath = progsDRV
   Else
      'patdatapath$ = patdatapath$ & ":"                                   '09Nov05 CKJ
      If Len(patdatapath) = 1 Then patdatapath = patdatapath & ":"         '   "
   End If
   patdatapath = patdatapath & "\patdata." & patdataEXT
''   pddata$ = siteinfo$("secondbaxaPatData", "")
''   passfile$ = dispdata$ & "\startup.asc"

   antihack hospname1$ & hospname2$ & hospabbr$, chksum%       ' now for compatibility only

   '04Oct12 CKJ moved from above (TFS45776)
   gTransportADOSetLockTimeOut CLng(TxtD(dispdata$ & "\siteinfo.ini", "Connection", "5000", "SQLLockTimeout", 0))

''   TerminalName$ = txtd("C:\ASCTERM.INI", "", "Unknown", "TerminalName", 0)
   If ASCTerminalName() = "" Then
      Err.Raise 32767, OBJNAME & ErrSource, "No terminal name has been assigned." & crlf & "This process cannot be started." & crlf & "Please contact your System Administrator." & crlf
   End If
      
   SetupPRNHeap True, 0     '16Jan98 CKJ Added to allocate gPRNheapID

   loadvatrates             'single call moved to module startup
   
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description & crlf & "(" & OBJNAME & ErrSource & ")"
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc

End Sub

Sub replace(Item$, was$, isnow$, ByVal length As Long)
'Usage:  Replace part of one string with another, but only if it is greater than a given length
'        Note, this procedure _is_ case sensitive - it replaces only on exact match
'        Avoid iterative use: eg Replace chars$, "A", "AB", 0  will loop until crump.
'         - this is by design; it allows repetitive strings of chars to be cut to a minimum size
'           eg Replace chars$, "   ", "  ", 0   will reduce multiple spaces to just two.
'
'Example:
'        longname$ = "Mister Algernon Person"
'        Replace longname$, "Mister", "Mr.", 20   'will replace only if longname$ is > 20 chars
'        Replace longname$, "Algernon", "Al", 0   'will replace regardless of length

'05Oct96 CKJ Once replacing commenced, it carried on with all occurrences.
'            Now stops once length is satisfactory
'29May97 CKJ Splice new text into existing string if length before & after is unchanged
'            This is to reduce string handling & improve performance
'10Jul98 CKJ If length is negative then replace using case insensitive comparison
'            If the replace is not dependent on length then just use True for ignore case &
'            False for the normal case specific replace
'09May05 uses longs

Dim posn As Long, splice As Long, ignoreCase%

   splice = (Len(was$) = Len(isnow$))  ' if length is the same then splice is true
   ignoreCase = -(length < 0)          ' set true/false
   length = Abs(length)
   If Len(Item$) > length Then
         Do
            'posn = InStr(item$, was$)
            posn = InStr(1, Item$, was$, ignoreCase)   '10Jul98 CKJ added case option

            If posn Then
                 If splice Then
                       Mid$(Item$, posn) = isnow$
                    Else
                       Item$ = Left$(Item$, posn - 1) & isnow$ & Mid$(Item$, posn + Len(was$))
                    End If
              End If
         Loop While posn And Len(Item$) > length
      End If

End Sub

Function RndLetter() As String

Dim upperbound%, lowerbound%

   lowerbound = Asc("A")
   upperbound = Asc("Z")
   RndLetter = Chr$(Int((upperbound - lowerbound + 1) * Rnd + lowerbound))

End Function

Function RoundAt$(Number$, atfig%)

'19Jul99 AE Written
'
'Given a string containing a numerical value, rounds it to the atfig'th digit.
'Used by StrSigFigs / StrDecPl.
'20Feb02 TH Change rounding on strings with first char point (".") to stop insertion of zero (#56463)

Dim temp%, n$, num$, fig%, carry%, pntpos%
Dim RFig%, m%

   On Error GoTo RoundAtErr
   fig = atfig                                          'index of the figure we're rounding at
   RFig = fig + 1                                       'index of next figure to the right of fig
   carry = False
   num$ = Number$

   pntpos = InStr(num$, ".")                            'remove dp
   Select Case pntpos
         Case 1
            'num$ = "0" & Mid$(num$, 2)         '20Feb02 TH (#56463)
            num$ = Mid$(num$, 2) & "0"          '    "
         Case Len(num$)
            num$ = Left$(num$, Len(num$) - 1)
         Case Is > 1
            num$ = Mid$(num$, 1, pntpos - 1) & Mid$(num$, pntpos + 1)
         Case 0
            pntpos = Len(num$) + 1
         Case Else
      End Select

   If fig >= Len(num$) Then Error 999
      
   Do Until fig = 0
         If Val(Mid$(num$, RFig, 1)) >= 5 Or carry Then
               temp = Val(Mid$(num$, fig, 1))
               temp = temp + 1
               If temp = 10 Then
                     If fig <> 1 Then                   'rounding with carry
                           n$ = "0" & n$
                           fig = fig - 1
                           RFig = RFig - 1
                           carry = True
                        Else
                           n$ = "10" & n$
                           pntpos = pntpos + 1
                           Exit Do
                        End If
                  Else
                     n$ = Format$(temp) & n$            'rounding with no carry
                     carry = False
                     Exit Do
                  End If
            Else                                        'No rounding needed at this digit
               n$ = Mid$(num$, fig, 1)
               Exit Do
            End If
      Loop

   n$ = Mid$(num$, 1, fig - 1) & n$
   
   Select Case pntpos                                   'replace dp
      Case Is > Len(n$)
         For m = 1 To pntpos - Len(n$) - 1
               n$ = n$ & "0"
            Next
      Case Else
         n$ = Mid$(n$, 1, pntpos - 1) & "." & Mid$(n$, pntpos)
      End Select

                                            
   If Left$(n$, 1) = "." Then n$ = "0" & n$                'convert ".nnn" to "0.nnn"
                                                
   If Right$(n$, 1) = "." Then n$ = Left$(n$, Len(n$) - 1) 'remove dp if a whole number
   

RoundAtExit:

   RoundAt$ = n$
   Exit Function

RoundAtErr:
  
   n$ = Number$              'at present, returns the string unchanged if there was an error
   Resume RoundAtExit


End Function

Sub XSeqScan(scanstr$, expansion$, filename$)
' WARNING This is a TEMPORARY routine, it has no error checking and uses
'         a file structure which is far from ideal.
'
'21Jan91 CKJ Temporary routine written
'12Dec91 CKJ Seqscan moved here from Identsub
'31Aug05 TH Renamed and superceeded with new SQL based sub

Dim fil%, Items%, i%, Code$, expan$

   expansion$ = ""
   scanstr$ = UCase$(Trim$(scanstr$))
  
   If fileexists(filename$) Then
         fil = FreeFile
         Open filename$ For Input As #fil
         Input #fil, Items
         For i = 1 To Items
            Input #fil, Code$, expan$
            If scanstr$ = UCase$(LTrim$(RTrim$(Code$))) Then
                  expansion$ = expan$
                  Exit For
               End If
         Next
         Close #fil
         If i > Items Then expansion$ = "<Invalid Code>"
      Else
         expansion$ = " "
      End If

End Sub

Sub SeqScan(ByVal strScan As String, ByRef strExpansion As String, ByVal strFilename As String)
'30Aug05 TH Ported for SQL Version

' WARNING This is a TEMPORARY routine, it has no error checking and uses
'         a file structure which is far from ideal.
'
'21Jan91 CKJ Temporary routine written
'12Dec91 CKJ Seqscan moved here from Identsub

''Dim fil%, Items%, i%, Code$, expan$
Dim rsLookups As ADODB.Recordset
Dim strParameters As String
Dim lngOK As Long

Dim LookupHeapId As Integer
Dim strItemSearch As String
Dim strValue As String
Dim intFound As Integer
   strExpansion = "<Invalid Code>"
   'scanstr$ = UCase$(Trim$(scanstr$))
   LookupHeapId = GetLookupHeapId()
   If LookupHeapId = 0 Then
        Heap 1, LookupHeapId, "WLookUps cache", "", 0
        'Set the ID
        SetLookupHeapId LookupHeapId
    End If
    strItemSearch = CStr(gDispSite) & "|" & strFilename & "|" & strScan
                                                           
    Heap 11, LookupHeapId, strItemSearch, strValue, intFound                    'check the item cache for the item
    If intFound Then
        strExpansion = strValue
    Else
   
   '08Aug12 CKJ Was SiteID & FileName
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Context", trnDataTypeChar, 255, strFilename) & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 10, strScan) & _
                   gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, Null)

   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParameters)
   
   If Not rsLookups.EOF Then
      strExpansion = RtrimGetField(rsLookups!Value)
      rsLookups.Close
   Else
      rsLookups.Close
      '08Aug12 CKJ Was SiteID
      strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, strFilename)
      lngOK = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLookupCountbyContext", strParameters)
      If lngOK = 0 Then strExpansion = " "
   End If
   Set rsLookups = Nothing
  
         'Update cache
       Heap 10, LookupHeapId, strItemSearch, strExpansion, 0
       
    End If
  
''   If fileexists(filename$) Then
''         fil = FreeFile
''         Open filename$ For Input As #fil
''         Input #fil, Items
''         For i = 1 To Items
''            Input #fil, Code$, expan$
''            If scanstr$ = UCase$(LTrim$(RTrim$(Code$))) Then
''                  expansion$ = expan$
''                  Exit For
''               End If
''         Next
''         Close #fil
''         If i > Items Then expansion$ = "<Invalid Code>"
''      Else
''         expansion$ = " "
''      End If

End Sub


Sub setinput(default, k As kbdcontrol)
'-----------------------------------------------------------------------------
'
'             Set the default values for the KBDCONTROL structure
'11Apr91 CKJ more elements now cleared
'-----------------------------------------------------------------------------

Select Case default
   Case 0   ' general purpose: use once to initialise at start of the program.
      k.Max = 0                      ' max no of chars
      k.min = 0                      ' min no of chars
      k.esc = True                   ' T/F allow 'Escape' as terminator
'>>   k.UpDown = False               ' T/F allow cursor up/down as terminator
      k.nums = False                 ' T/F allow . and 0-9
      k.decimals = False             ' T/F allow 0-9 only
      k.passwrd = False              ' T/F no echo of input
      k.validchars = nulls           ' 10 nulls    '11Nov08 CKJ 11 nulls
      k.HelpFile = ""                ' name of helpfile
      k.helpnum = False              ' page in helpfile
      k.startat = False              ' start field at defined position
      k.timedef = StdTimeout         ' default timeout of 5 mins
      k.timeout = True               ' enable timeout, use default value
      k.date = False                 ' date only entry
      k.norefresh = False            ' don't inhibit screen refresh
   End Select

End Sub

Sub SetKeyLock(KeyName%, Action%)
'16Dec96 CKJ Written
'KeyName = VK_NUMLOCK, VK_CAPITAL, VK_SCROLL
'Action  = 0 to turn off, -1 to turn on, 1 to toggle
' 7Jan97 CKJ/MD Corrected CASE action - state values were wrong
                                 
'»Dim KeyState As String * 256, State%
'»
'»   GetKeyboardStateByString KeyState
'»
'»   State = Asc(Mid$(KeyState, KeyName + 1, 1)) And 1   'Is LOCK on? returns 0 or 1
'»   Select Case Action
'»      Case 0:  State = 0                               'set off
'»      Case -1: State = 1                               'set on
'»      Case 1:  State = 1 - State                       'toggle 0->1  1->0
'»      End Select
'»   Mid$(KeyState, KeyName + 1, 1) = Chr$(State)
'»
'»   SetKeyboardStateByString KeyState
   
End Sub

Sub SetupPRNHeap(Create%, success%)
'16Jan98 CKJ Written
'            This procedure initailises a heap for parsing data items for printing.
'            If the heap is alreay allocated, then it is destroyed and reinitialised.
'            The global gPRNheapID is allocated and cancelled here
'            If Create=F then the heap is destroyed
'            If Create=T then the heap is created (destroying it first if already in use)
'            Returns success=T/F

   If gPRNheapID Then                                'already exists
         Heap 2, gPRNheapID, "", "", success         'destroy heap
         If Not success Then
               popmessagecr ".", "WARNING: Unable to destroy 'gPRNheapID'" & Str$(gPRNheapID)
            End If
      End If
   
   If Create And gPRNheapID = 0 Then                 'create heap
         Heap 1, gPRNheapID, "Print Heap", "", success
         If success Then
               Heap 10, gPRNheapID, "hospabbr", hospabbr$, success
               Heap 10, gPRNheapID, "hospname1", hospname1$, success
               Heap 10, gPRNheapID, "hospname2", hospname2$, success
            Else
               popmessagecr ".", "WARNING: Unable to allocate 'gPRNheapID' for printing via Windows"
            End If
      End If

End Sub

Sub shellsort(SortArray() As String, MaxRow%, ByVal column%, ColSep$, Optional ByVal ColumnType As String = "", Optional ByVal ignoreCase As Boolean = False)
' =============================== ShellSort ==================================
'  The ShellSort procedure is similar to the BubbleSort procedure.  However,
'  ShellSort begins by comparing elements that are far apart (separated by
'  the value of the Offset variable, which is initially half the distance
'  between the first and last element), then comparing elements that are
'  closer together (when Offset is one, the last iteration of this procedure
'  is merely a bubble sort).
'
'  ColumnType can be NUMBER, or DATE, to signify the type of data the column
'  contains, hence sorting is altered to take this into account, any other
'  specification of ColumnType are treated as a string sort.
'
'  If the ColumnType is NUMBER then the string will be validated using IsNumber
'  and converted to a double using Val.
'
'  If the ColumnType is DATE then the string will be converted to a known date
'  format using parsedate, and so should conform to that format.
'
'  Note: If the columns contains a mix of numbers and strings, and ColumnType is
'  NUMBER, rows containing appear at the top of the list in ascending order, and
'  rows not containing numbers appear at the bottom of the list, in alphabetical
'  ascending order.
'
'  Note: If the method is called to sort a column containing string data it will
'  compare the data on the selected column right to the end of the string, however
'  NUMBER, and DATE types, will only sort on the data in the selected column.
'
'27Dec96 ASC Added Column to allow sorting on a particular column ( by char)
' 2Jan97 CKJ Changed above to sort by column, not column+1 as before
'            This means that column=0 and column=1 do the same thing -
'              they now sort the whole string
'            Also, if column exceeds the string length it does not now crash.
'05Mar98 CFY New parameter ColSep added. Used to denote if a particular character
'            should be used to identify columns. If left blank then the procedure
'            behaves as it used to.
'14Jan02 TH  Removed Static from sub definition. This was causing problems because ColumnIn wasnt being correctly
'    "       initialised and was sometimes staying in memory incorrectly in subsequent sorts (#40814)
'08Apr10 XN  Allowed the sort algorithum to take into account number, and date columns
'29Jun10 XN  Improved after code review with Chris.
'06Sep10 XN  F0095829 - gave shellsort the option of being case insensitive
' ============================================================================

Dim temp$, Offset%, Limit%, wSwitch%, Row%
Dim X%, Y%, ColumnIn%, columnoffset% '05Mar98 ASC
Dim a As String, b As String
Dim columnoffsetEnd As Integer, columnEnd As Integer

   If column <= 0 Then column = 1
   columnoffset = column

   If Trim$(ColSep$) <> "" Then  '05Mar98 CFY Added
         ColumnIn = column                      '
      End If                                    '
      
   ColumnType = UCase$(ColumnType)
   
   'Set comparison offset to half the number of records in SortArray:
   Offset = MaxRow \ 2
   Do While Offset > 0          ' Loop until offset gets to zero.
      Limit = MaxRow - Offset
      Do
         wSwitch = False        ' Assume no switches at this offset.

         ' Compare elements and switch ones out of order:
         For Row = 1 To Limit                                                                   '05Mar98 ASC
            If ColumnIn Then
                  Y = ColumnIn - 1                                                              '    "
                  column = 0                                                                    '    "
                  For X = 1 To Y                                                                '    "
                     column = InStr(column + 1, SortArray(Row), ColSep$)                        '    "
                  Next                                                                          '    "
                  column = column + 1
                  
                  columnoffset = 0                                                              '    "
                  For X = 1 To Y                                                                '    "
                     columnoffset = InStr(columnoffset + 1, SortArray(Row + Offset), ColSep$)   '    "
                  Next                                                                          '    "
                  columnoffset = columnoffset + 1
            End If                                                                           '    "
            
            ' XN 08Apr10 Allowed the sort algorithum to take into account number, and date columns
            If (ColumnType = "NUMBER") Or (ColumnType = "DATE") Then
                ' Determine the end of the columns (if ColSep$ is missing then use length of the string)
                columnEnd = InStr(column, SortArray(Row), ColSep$)
                columnEnd = Iff(columnEnd = 0 Or ColSep$ = "", Len(SortArray(Row)), columnEnd - 1)
                  
                columnoffsetEnd = InStr(columnoffset, SortArray(Row + Offset), ColSep$)
                columnoffsetEnd = Iff(columnoffsetEnd = 0 Or ColSep$ = "", Len(SortArray(Row + Offset)), columnoffsetEnd - 1)
            Else
                ' column is a string so extract from the selected column to the end of the string
                columnEnd = Len(SortArray(Row))
                columnoffsetEnd = Len(SortArray(Row + Offset))
            End If
            
            ' Extract the data for the column
            a = Mid$(SortArray(Row), column, columnEnd - column + 1)
            b = Mid$(SortArray(Row + Offset), columnoffset, columnoffsetEnd - columnoffset + 1)
            
            'If SortArray(Row) > SortArray(Row + Offset) Then
            'If Right$(SortArray(Row), Len(SortArray(Row)) - column) > Right$(SortArray(Row + Offset), Len(SortArray(Row + Offset)) - column) Then
            'If Mid$(SortArray(Row), column) > Mid$(SortArray(Row + Offset), columnoffset) Then  '2Jan97 CKJ Simplified
            If AGreaterThanB(a, b, ColumnType, ignoreCase) Then  '06Sep10 XN F0095829 gave shellsort option of being case insensitive ' XN 08Apr10 Allowed the sort algorithum to take into account number, and date columns
                  'SWAP SortArray(Row), SortArray(Row + Offset) '01Jul96 ASC
                  temp$ = SortArray(Row)
                  SortArray(Row) = SortArray(Row + Offset)
                  SortArray(Row + Offset) = temp$
                  wSwitch = Row
            End If
         Next    '14Feb95 CKJ removed Row

         'Sort on next pass only to where last switch was made:
         Limit = wSwitch - Offset
      Loop While wSwitch

      'No switches at last offset, try one half as big:
      Offset = Offset \ 2
   Loop

End Sub

Private Function AGreaterThanB(ByRef a As String, ByRef b As String, ByVal datatype As String, ByVal ignoreCase As Boolean) As Boolean
'  Returns if true if A > B
'
'  DataType can be NUMBER, or DATE, to signify the type of data the column
'  contains, hence sorting is altered to take this into account, any other
'  specification of DataType are treated as a string sort.
'
'  If the DataType is NUMBER then the string will be validated using IsNumber
'  and converted to a double using Val.
'
'  If the DataType is DATE then the string will be converted to a known date
'  format using parsedate, and so should conform to that format.
'
'  Note:
'  If the A is a valid format and B is not then returns false
'  If the A is not a valid format and B is valid then returns true
'  If both are not valid format then a string A > B comparison is performed
'
' 06Sep10 XN  F0095829 - gave method the option of being case insensitive
Dim ADate As String, BDate As String
Dim validADate As Integer, validBDate As Integer

    AGreaterThanB = False
    Select Case datatype
    Case "NUMBER"
        ' Compare the numbers, if the column data is not a number move it to bottom of list
        ' but still sort it using standard string sorting.
        If IsNumber(a, True) Then
            AGreaterThanB = Iff(IsNumber(b, True), Val(a) > Val(b), True)
        Else
            AGreaterThanB = Iff(IsNumber(b, True), False, a > b)
        End If
    Case "DATE"
        ' Converts date to YYYYMMDD format (but still kept as a string).
        ' uses parsedate to read and convert the date, to allow the max range of date formats
        parsedate a, ADate, "YYYYMMDD", validADate
        parsedate b, BDate, "YYYYMMDD", validBDate
                        
        ' Compare the dates, if the column data is not a number move it to bottom of list
        ' but still sort it using standard string sorting.
        If validADate Then
            AGreaterThanB = Iff(validBDate, ADate > BDate, True)
        Else
            AGreaterThanB = Iff(validBDate, False, a > b)
        End If
    Case Else
        ' Everything else is compared as a string
        ' 06Sep10 XN F0095829 Allowed sort to ignore case
        If ignoreCase Then
            AGreaterThanB = (StrComp(a, b, vbTextCompare) = -1)
        Else
                AGreaterThanB = (a > b)
        End If
        ' End of F0095829
    End Select
    
End Function

Sub ShowAboutBox(ExtraInfo As String)
'----------------------------------------------------------------------------
'20Sep96 CKJ Added, based on example by David McCarter 08/01/95
'            This procedure create a standard About Box
'            It uses the icon on the form which is passed as a parameter
'            ExtraInfo$ has room for two lines of approx 40-50 chars
'29Oct96 KR  Changed to use a standard AboutBox.  This is because the ShellAbout
'            function displays 'Microsoft ascshell', proberly 'cos it looks at
'            the VB runtime DLL.  It works in the same way.
'19Dec96 CKJ Removed icon line - uses default ASCribe icon now
'26Oct97 CKJ Now recursion safe. Use icon from given form once more as all
'            forms must have an icon specified.
'05Apr00 AE  Added ASCRelease
'22sep03 CKJ added brackets to ASCver()
'09May05 CKJ removed frmin as form - not usable with UserControl
'----------------------------------------------------------------------------
    
Dim objAboutBox As AboutBox

   Set objAboutBox = New AboutBox
   Load objAboutBox
   objAboutBox.lblTitle.Caption = ExtraInfo
   objAboutBox.LblVersion.Caption = "Version " & ASCver & ASCRelease
''   objAboutBox.Pic_ApplicationIcon.Picture = frmIn.Icon
   objAboutBox.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   Unload objAboutBox
   Set objAboutBox = Nothing

End Sub

Function SigFigs!(Value!, n%)

'19Jul99 AE  written

'Round value! to 'n' significant figures.
'Depending on magnitude of number, move decimal place by multiplying
'or dividing by the appropriate power of 10, then use the "add 0.5 and use
'Int(value)" technique to do the rounding. Finally, return the decimal point
'to it's original place.
'NB. Negatives are stripped of their sign and rounded, and finally the sign is reinstated.
'thus, for eg SigFigs(-10.56,3) returns -10.6

'Beware VB's internal rounding may create problems - use DP for important calculations,
'use this for display etc.

Dim temp!, sign%, Log10!, pwr%
   
   n% = Abs(n%)                         'shouldn't have a -ve no. of sig figs!
   If n = 0 Or Value! = 0 Then          'zero sig figs returns zero
      SigFigs = 0
      Exit Function
   End If

   sign% = Sgn(Value!)
   Value! = Abs(Value!)

   Log10! = Log(Value!) / Log(10#)
   pwr% = Int(Log10)                    'pwr = the number of orders of magnitude above 0
   
   If pwr% > 0 Then                     'move the decimal point
         pwr% = -(pwr% + 1 - n%)
      ElseIf pwr% < 0 Then
         pwr% = Abs(pwr%) - 1 + n%
      Else
         pwr% = n% - 1
      End If

   temp! = Value! * 10 ^ pwr
   temp! = temp! + 0.5                  'round up
   temp = Int(temp!)
   temp! = temp! * 10 ^ -pwr
   temp! = temp! * sign%
   SigFigs = temp!
   
End Function

''Function SingleUserMode() As Boolean
'''19Jan99 CFY Written
'''01Mar00 TH  Check for Citrix to correctly display whether single user or not
'''03Mar00 TH  Change to above mod
'''
'''This procedure checks a set number of paths to determine if any of these refer to remote drives
'''If no remote drives are found then the function reports back TRUE
'''If any remote drives are found then the function reports back FALSE
''
''Dim PathsToCheck$, Drive$
''Dim FoundRemote%, NumOfPaths%, index%
''
''Static FlagSet As Integer
''Static SingleUserModeFlag As Integer
''
''   If TrueFalse(TxtD(dispdata$ & "\Terminal.ini", "Default", "N", "CitrixServer", 0)) = True Then    '01Mar00 TH '03Mar00 Th Explicitly set section
''         SingleUserMode = False
''         Exit Function
''      End If
''
''   If Not FlagSet% Then
''         ReDim PathList$(10)
''
''         'Build up a list of paths to check  (Could be made configurable with .ini file perhaps ???)
''         PathsToCheck$ = CurDir$ & ","
''         PathsToCheck$ = PathsToCheck$ & transpath$ & ","                  'Transaction Logs
''         PathsToCheck$ = PathsToCheck$ & orderlogpath$ & ","               'Order Logs
''         PathsToCheck$ = PathsToCheck$ & patdatapath$ & ","                'Patient Data
''
''         deflines PathsToCheck$, PathList$(), ",", 1, NumOfPaths%
''
''         'Loop through each path and check to see if we can determine the type of drive
''         '(if any) that has been specified
''         On Error GoTo SingleUserMode_Err
''         index% = 1
''         FoundRemote% = False
''         Do
''            If Mid$(PathList$(index), 2, 1) = ":" Then                      'do we have a drive letter in the path?
''                  Drive$ = UCase(Left$(PathList$(index), 1))
''                  If GetDriveType(Drive$) = VBDRIVE_REMOTE Then             'Is it remote?
''                        FoundRemote% = True
''                     Else
''                        FoundRemote% = False
''                     End If
''               End If
''            index% = index% + 1
''         Loop Until (index% > NumOfPaths%) Or FoundRemote%
''         On Error GoTo 0
''
''         SingleUserModeFlag% = Not FoundRemote%
''         FlagSet% = True
''      End If
''
''   SingleUserMode = SingleUserModeFlag%
''
''SingleUserMode_Exit:
''   Exit Function
''
''SingleUserMode_Err:
''   popmessagecr "!", "The system was unable to determine" & crlf & "if this terminal is running in single user mode"
''   GoTo SingleUserMode_Exit
''
''End Function

Function siteinfo$(Entry$, default$)
'Read info from \Dispdata.xxx\Siteinfo.ini on the CURRENT DEFAULT DISK DRIVE
'** NB ** CURRENT DEFAULT DISK DRIVE as this can & will change during a prog.
'19Jan95 CKJ Added default$ & modified all progs in suite.
'            Default$ can be "", text, or CHR$(26) to end prog if entry absent
'14Nov00 CKJ Moved the crude 'End' code from the ini file handler to here

Dim sBuffer As String

''   sBuffer = txtd("\DISPDATA." & Right$("00" & LTrim$(Str$(Val(g_command))), 3) & "\siteinfo.ini", "", default$, entry$, 0)
   sBuffer = TxtD("Dispdata.000\siteinfo.ini", "", default$, Entry$, 0)    '!!** NOT SITE AWARE - NOW ALWAYS USES STARTUP SITE NUMBER
   
   If sBuffer = Chr$(26) Then                                                 '19Dec94 CKJ EOF char
''         popmessagecr "HALTED - ESSENTIAL DATA MISSING", "TEXT " & entry$ & " MISSING FROM SiteInfo.ini"
''         Close
''         END!                                                                 '<== ** END OF PROGRAM **
         Err.Raise 32767, OBJNAME & "SiteInfo", "HALTED - ESSENTIAL DATA MISSING:" & cr & "TEXT " & Entry$ & " MISSING FROM SiteInfo.ini"
      End If
   
   siteinfo$ = sBuffer

End Function

Sub SOUND(ByVal Freq As Long, ByVal Duration As Single)
'30Nov96 CKJ Technet Article Q71102 Emulating SOUND Statement
'            Frequency in Hz, Duration in ticks (18.4/sec)
'            (Note that freq is shifted to high byte)
'15May97 CKJ Amended to emulate the DOS sound statement more closely
'            It is now self contained, so does not need open/close sound
'            Note duration seems to be in multiples of about 0.5 millisecs
'            not in ticks, so has been amended roughly to ticks.
'            Duration 400 here is about the same as duration 400 in DOS
'            so multiply by 400/18.4~=21.8
'22Nov01 CKJ Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N

Beep

'Dim ret As Integer, Dur As Integer
'
'   If SoundBeepOnly() Then                                                       '22Nov01 CKJ NT4 may not support tones
'         Beep
'      Else
'         ret = OpenSound()
'         Dur = Iff(Abs(Duration) < 1500, Duration * 21.8, 32767)
'         ret = SetVoiceSound(1, Freq * 2 ^ 16, Dur)
'         ret = SetVoiceSound(1, Freq * 2 ^ 16, 0)
'         ret = StartSound()
'
'         Do While (WaitSoundState(1) <> 0)  ' Wait for sound to play.
'         Loop
'
'         ret = CloseSound()
'      End If

End Sub

Sub SoundAtten()
'22Nov01 CKJ Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N

Beep

'Dim ret As Integer
'
'   If SoundBeepOnly() Then                                                       '22Nov01 CKJ NT4 may not support tones
'         Beep
'      Else
'         ret = OpenSound()
'         ret = SetVoiceSound(1, 1600 * 2 ^ 16, 20)
'         ret = SetVoiceSound(1, 2000 * 2 ^ 16, 40)
'         ret = SetVoiceSound(1, 1600 * 2 ^ 16, 30)
'         ret = SetVoiceSound(1, 1000 * 2 ^ 16, 0)
'         ret = StartSound()
'
'         Do While (WaitSoundState(1) <> 0)  ' Wait for sound to play.
'         Loop
'
'         ret = CloseSound()
'      End If

End Sub

'Function SoundBeepOnly() As Boolean
''22Nov01 CKJ NT4 may not support tones, so option added to just call the basic Beep
''            Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N
'
'   SoundBeepOnly = TrueFalse(terminal("SoundBeepOnly", "N"))
'
'End Function

'Sub SoundClick()
'
'   SOUND 800, 0.25          '(duration 5)
'
'End Sub

'Sub SoundClose()
''22Nov01 CKJ Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N
'
'Dim ret As Integer
'
'   If Not SoundBeepOnly() Then                                                   '22Nov01 CKJ NT4 may not support tones
'         ret = CloseSound()
'      End If
'
'End Sub

Sub SoundError()

   Beep

'Dim ret As Integer
'
'   If SoundBeepOnly() Then                                                       '22Nov01 CKJ NT4 may not support tones
'         Beep
'      Else
'         ret = OpenSound()
'         ret = SetVoiceSound(1, 800 * 2 ^ 16, 25)
'         ret = SetVoiceSound(1, 600 * 2 ^ 16, 25)
'         ret = SetVoiceSound(1, 600 * 2 ^ 16, 0)
'         ret = StartSound()
'
'         Do While (WaitSoundState(1) <> 0)  ' Wait for sound to play.
'         Loop
'
'         ret = CloseSound()
'      End If

End Sub

'Sub SoundOpen()
''22Nov01 CKJ Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N
'
'Dim ret As Integer
'
'   If Not SoundBeepOnly() Then                                                   '22Nov01 CKJ NT4 may not support tones
'         ret = OpenSound()
'      End If
'
'End Sub

Sub SoundTimeOut()
'7Mar97 CKJ Added for the timing out 'blip' noise
'22Nov01 CKJ Terminal.ini SoundBeepOnly = "T" 'Y/N/T/F/1/0/-1 default is N

   Beep

'Dim ret As Integer
'
'   If SoundBeepOnly() Then                                                       '22Nov01 CKJ NT4 may not support tones
'         Beep
'      Else
'         ret = OpenSound()
'         ret = SetVoiceSound(1, 1000 * 2 ^ 16, 25)
'         ret = SetVoiceSound(1, 1500 * 2 ^ 16, 25)
'         ret = SetVoiceSound(1, 1500 * 2 ^ 16, 0)
'         ret = StartSound()
'
'         Do While (WaitSoundState(1) <> 0)  ' Wait for sound to play.
'         Loop
'
'         ret = CloseSound()
'      End If
   
End Sub

Function SQLSafe(ByVal sSQlStatement As String) As String

'Replace single ' in sql statements with '' to avoid
'parsing problems

'After an example by J.P.McManus
'26May00 AE

Dim sSql As String

   sSql = sSQlStatement

   replace sSql, "'", "~", 0
   replace sSql, "~", "''", 0
   SQLSafe = sSql


End Function

Function StrDecPl$(Number$, n%)
'
'19Jul99 AE Written
'Given a string containing a numerical value, returns it rounded to the nth decimal place.
'Exponents in the standard 'E' form are accepted, eg 10E-5, and returned with the exponent
'expanded. If the string has no, or fewer than n decimal places, the function will fill out
'the return string with zeros in place. eg, "10.5", to 4 dp becomes "10.5000". Negative numbers
'are accepted.
'
Dim Neg%, pntpos%, num$, m%

   On Error GoTo StrDecPlErr
   m = 1                                          'counter
   Neg% = False
   
   If n < 0 Then Error 999                        'if a -ve number of decimal places
   num$ = Trim$(Number$)
   
   If Left$(num$, 1) = "-" Then                   'Check for negative number.  Remove "-" sign
         Neg% = True                              'and replace it later
         num$ = Mid$(num$, 2)
      End If

   num$ = ExpandExp(num$)                         'expand exponents if present

   pntpos = InStr(num$, ".")
   Select Case pntpos
      Case 0
         num$ = num$ & "."                        'no dp - add, and fill with zeros
         pntpos = Len(num$)
         For m = 1 To n
               num$ = num$ & "0"
            Next
      Case Is > Len(num$) - n                     'not enough decimal places in Num$
         For m = 1 To n - (Len(num$) - pntpos)
               num$ = num$ & "0"
            Next
      Case Else
   End Select
         
   num$ = RoundAt(num$, n + pntpos - 1)           'round at the 'nth' significant digit

   If Left$(num$, 1) = "." Then num$ = "0" & num$
                                                  'remove dp if a whole number
   If Right$(num$, 1) = "." Then num$ = Left$(num$, Len(num$) - 1)

   If Neg% Then num$ = "-" & num$                 'Replace minus sign if appropriate

StrDecPlExit:
   
   StrDecPl$ = num$

Exit Function


StrDecPlErr:

   Select Case Err
      Case 999                                    '(Zero or -ve no. of dec pl requested)
         num$ = ""
      End Select
      
   Resume StrDecPlExit


End Function

Function StrSigFigs$(Number$, n%)

'19Jul99 AE Written
'Given a string conataining a numerical value, returns it rounded to the nth significant figure
'Exponents in the standard 'E' form are accepted, eg 10E-5, and returned with the exponent
'expanded. Negative numbers are accepted.
'If N is zero, an empty string is returned.

Dim Neg%, fd%, num$, m%

   On Error GoTo StrSigFigsErr
   fd = 1                                         'position of 1st significant digit, (not including dp)
   m = 1                                          'counter
   Neg% = False
   
   If n% <= 0 Then Error 999                      'return "" for zero significant figures
   num$ = Trim$(Number$)
   
   If Left$(num$, 1) = "-" Then                   'Check for negative number.  Remove "-" sign
         Neg% = True                              'and replace it later
         num$ = Mid$(num$, 2)
      End If

   num$ = ExpandExp(num$)                         'expand exponents if present

   Do
      Select Case Mid$(num$, m, 1)                'find first significant digit
         Case "0"
            fd = fd + 1
            m = m + 1
         Case "."
            m = m + 1
         Case Else
            Exit Do
         End Select
      Loop
   
   num$ = RoundAt(num$, fd + n - 1)               'round at the 'nth' significant digit

   If Neg% Then num$ = "-" & num$                 'Replace minus sign if appropriate

StrSigFigsExit:
   
   StrSigFigs$ = num$

Exit Function


StrSigFigsErr:

   Select Case Err
      Case 999                                    '(Zero or -ve no. of sig figs requested)
         num$ = ""
      End Select
      
   Resume StrSigFigsExit

End Function

Function T1(ByVal Entry As String, ByVal default As String) As String
' Text for DQQW
' Uses either \ASCROOT\DQQW.044 without sections or
'             \ASCROOT\DQQW.LNG, section [044]
' where 044 is read from Country= in config or autoexec
'14Dec95 KR Windows GetProfile String requires section
'09May05 ckj added default; leave blank for original behaviour

''   T1$ = txt$("DQQW", "", entry$)
   If default = "" Then default = "TEXT " & Entry & " MISSING FROM DQQW"
   T1 = TxtD("DQQW", "", default, Entry, 0)

End Function

Function terminal$(param$, default$)
'Check for presence of ASCTERM.INI on C:\
' - if found, extract terminal ID else use "Default" as terminal name
'Look for given param$ in TERMINAL.INI in DISPDATA.xxx, using
' terminal name as the Section

Static myterminal$, found%, tmp$

   If myterminal$ = "" Then    'find terminal name for this terminal
         myterminal$ = ASCTerminalName()        ' txtd("C:\ASCTERM.INI", "", "Default", "TerminalName", found)
      End If
   found = False
   If myterminal$ <> "Default" Then tmp$ = TxtD(dispdata$ & "\TERMINAL.INI", myterminal$, default$, param$, found)
   If Not found Then tmp$ = TxtD(dispdata$ & "\TERMINAL.INI", "Default", default$, param$, found)
''   If InStr(g_command, "/TERMDEBUG") Then popmessagecr "Terminal=" & myterminal$ & " Code=" & param$ & " Default=" & default$, "Result=" & tmp$
   terminal$ = tmp$

End Function

Function thedate$(hyphen, yyyy)
' 8Aug93 CKJ returns current date:
'
'             hyphen
'             -------------------
'      |      false    true
' yyyy |false 120893   12-08-93        current date
'      |true  12081993 12-08-1993      current date
'      | -2   143056   14:30:56        time when the date was last requested
'      |  1   143122   14:31:22        current time
'
'03May98 CKJ Work with copy of date to avoid midnight problems
'            Also keep a copy of the time and return this as hhmmss on second call
'            -2 => returns the time when the date was last requested (blank if never called)
'             1 => returns the current time

Static tim$
Dim dat$, tmp$, sep%

   sep = Abs(hyphen <> 0)          'true/false => 1/0
   Select Case yyyy
      Case 1, -2                   'current time, stored time
         If yyyy = 1 Then tmp$ = Time$ Else tmp$ = tim$
         thedate$ = Left$(tmp$, 2 + sep) & Mid$(tmp$, 4, 2 + sep) & Right$(tmp$, 2)
      Case Else
         Do
            dat$ = date$           'mm-dd-yyyy with year in range 1980-2099
            tim$ = Time$           'hh:mm:ss
         Loop While dat$ <> date$  'trap the midnight changeover
         thedate$ = Mid$(dat$, 4, 2 + sep) & Left$(dat$, 2 + sep) & Right$(dat$, 2 - 2 * (yyyy <> 0))
      End Select

End Function

Sub TrackOpenedFiles(iChannel As Integer, sFilename As String, sProcedure As String)
'24Aug99 CKJ Written
'            Given a valid channel number, update the array with filename and procedure name
'            This can be used for adding & removing files from the list

   Select Case iChannel
      Case 1 To 32
         msOpenedChannels(1, iChannel) = sFilename
         msOpenedChannels(2, iChannel) = sProcedure
      Case Else
         popmessagecr ".", "Procedure TrackOpenedFiles called with Channel =" & Str$(iChannel)
      End Select

End Sub

Function trimz(chars$) As String
'-----------------------------------------------------------------------------
'  Remove all spaces at left & right, and remove anything beyond a null byte.
'-----------------------------------------------------------------------------

   trimz = Trim$(asciiz$(chars$))

End Function

Function TrueFalse(Item$) As Boolean
'31Aug96 CKJ Written
'            Takes a string & returns 0 or -1
'            Y, T, -1     -> -1
'            all else     -> 0
'16Oct96 CKJ Added GetYN$(1)
' 8Jul97 CKJ Added '1' to list of True items
'08Mar12 TH  Added 'TRUE' to list
   
   Select Case Trim$(UCase$(Item$))
      Case "Y", "T", "1", "-1", getYN$(1), "TRUE": TrueFalse = -1
      Case Else:                                   TrueFalse = 0
      End Select

End Function

''Function txt(pathfile$, Section$, entry$) As String
'''19Dec94 CKJ Main code moved to TxtD. Proc functionally unchanged.
'''19Jan95 CKJ file$ -> pathfile$ in default string
''
''Dim found%
''
''   txt$ = txtd$(pathfile$, Section$, "TEXT " & Section$ & " " & entry$ & " MISSING FROM " & pathfile$, entry$, found)
''
''End Function

Function TxtD(pathfile$, Section$, default$, Entry$, found As Integer) As String
'Example:
'  File        DFHL.044          DFHL.LNG
'  Section     <none>            [044]
'  Entry       AskSupport=Contact ASC Support
'              AskSupport="Contact ASC Support  "
'              AskSupport="Contact ASC Support"   'max 70
'              AskSupport="Contact ASC Support"   ;max 70
'              (NB No comments allowed unless quotes are used)
'              (and no trailing spaces unless quotes are used)
'  Comment     ' Comment line
'              ; Comment line

' Filenames will be searched in the following order
'  if no filename   \ASCROOT\ASCRIBE.044    Section <none>
'                   \ASCROOT\ASCRIBE.LNG    Section [044]
'  exact match of   <pathfile>
'  if no ext given  \ASCROOT\<pathfile>.044 given Country=044 in config.sys
'                                           or Set Country=044 in autoexec.bat
'                   \ASCROOT\<pathfile>.LNG Section [044]
'
' If file/section/entry not found returns error msg:
'     "TEXT <section> <entry> MISSING FROM <file>"
'
'
' 9Jun94 CKJ Uses GetCountry
'10Jun94 CKJ Arrays files$(x,1) and srch$(y,1) cache filenames & entries
' 9Nov94 CKJ Order of file search changed. NOT perfect logic
'            - but will give 1st time hit in practice when given DQQW;
'            finds \ASCROOT\DQQW.044 or equivalent
'19Dec94 CKJ If Default is chr$(26), EOF, then End if not found in file.
'            - chosen as it would not occur inside a text file.
'            Cacheing now cleared if default disk is changed
'20Dec94 CKJ Also returns found = T/F
'19Jan95 CKJ Added debug option: command line /TXTDEBUG for missing lines
'25Jan95 CKJ Now stores new finds in buffer
'26Jan95 CKJ Simplified use of default to correct bug when found = default
'17Feb95 CKJ Preserve errnum across the call
'04Jun97 EAC moved to module level to allow flushing of cache
'12Mar99 CKJ Added Tamper check on INI files. No message on files which have no validation though
'29Oct99 CKJ Divert call to TxtH() which uses the Heap to manage caching
'14Nov00 CKJ Written style lookup and cache, no divert unless command line includes /OLDINICACHE
'            Cache whole file without using the API call
'            This is designed to improve reliability & reduce network traffic
'            Once a new file has been encountered, read the entire file in one pass
'            Read it in chunks of 10-30K, reducing the need for multiple tiny network packets
'            Cache misses on the file cache are still recorded, but not for the item cache
'            because the whole file is held and therefore a heap miss is also a cache miss.
'
'            Filename given                  Filname to look for                Action
'            ------------------------------  ---------------------------------  -----------
'            \apath\inifile.ext              x:\apath\inifile.ext               Add current drive
'            d:\apath\inifile.ext            d:\apath\inifile.ext               None
'            \\svr\share\apath\inifile.ext   \\svr\share\apath\inifile.ext      None
'
'            inifile                         x:\ascroot\inifile.ccc             Try local country in current ascroot,
'                                            x:\ascroot\inifile.044             then try country 044 in current ascroot
'
'            ccc     is the country number in regional settings
'            x:      is the default drive
'
'            Note that there are two subtle changes in behaviour:
'            If two country specific files exist, and the item is not found in the first one, then lookup is now performed
'             on the second file as well. Previously the routine would stop after the first file.
'            Use of the chr(26) flag to force ending of the program is not available execpt from the siteinfo() procedure.
'
'24Nov00 CKJ Renamed TxtH() as TxtHeap(). See procedure for details.
'-----------------------------------------------------------------------------
Dim sBuffer As String                                                          'String buffer
Dim sFile1 As String                                                           'First filename to look for
Dim sFile2 As String                                                           'Second filename to look for

   found = False                                                               'Not Found' until proven otherwise
   sBuffer = default$                                                          'preset default answer
   sFile1$ = UCase$(pathfile$)
   sFile2$ = ""
   
   If InStr(Right$(pathfile$, 4), ".") = 0 Then                                'no extension, eg 'DFHL'
        GetCountry country
        If country <> 44 Then sFile2$ = rootpath$ & "\" & sFile1$ & ".044"    'not UK, 2nd file is X:\ascroot\file.044
        sFile1$ = rootpath$ & "\" & sFile1$ & "." & Format$(country, "000")   'may not be UK, try X:\ascroot\file.xxx
      End If
   
   If Left$(sFile1$, 2) <> "\\" And Mid$(sFile1$, 2, 1) <> ":" Then sFile1$ = Left$(CurDir$, 2) & sFile1$
   sBuffer = IniCache(sFile1$, Section$, default$, Entry$, found)

   If Not found And Len(sFile2$) > 0 Then                                       'didn't find it, and there's a second filename
        If Left$(sFile2$, 2) <> "\\" And Mid$(sFile2$, 2, 1) <> ":" Then sFile2$ = Left$(CurDir$, 2) & sFile2$
        sBuffer = IniCache(sFile2$, Section$, default$, Entry$, found)
      End If

   TxtD$ = sBuffer

End Function

''Function TxtH$(pathfile$, Section$, default$, entry$, found)
'''24Nov00 CKJ ** DO NOT WRITE ANY MORE NEW CALLS TO THIS PROCEDURE **
'''            Instead please use TxtD() which is the only entry point for these functions.
'''            The old TxtH() has been renamed TxtHeap() and is a private function
'''            Do not use that one either!
''
''   TxtH = txtd(pathfile$, Section$, default$, entry$, found)
''
''End Function


Sub UndoCutCopyPasteDel(Choice%)
'------------------------------------------------------------
'09May97 CKJ Proc constructed from existing bits.
'Undo (and Redo), Cut, Copy, Paste and Delete selected text in textboxes
'Call with Choice = 1 Undo
'                 = 2 Cut
'                 = 3 Copy
'                 = 4 Paste
'                 = 5 Delete
'
'MSDN, Technical Articles, Visual Basic Articles, Visual Basic Tips
'Tip 130: Using the Undo Feature with a Text Box Control
'July 1, 1995
'Almost all Microsoft® Windows®-based applications provide an Edit menu on which you can
'select the Undo command to reverse the most recently made changes to an edit control.
'Using SendMessage to Undo Edit Control Changes
'When you modify the contents of an edit control in Microsoft® Visual Basic®, such as a
'Text Box control, the data you add or delete is saved in an internal buffer by the
'Microsoft Windows® operating system. You can use the Windows application programming
'interface (API) SendMessage function to allow your user to retrieve the modified text.
'Let's assume that you have typed some text into a Text Box control. You now want to delete
'some of that text. To do this, you select the text and press the DEL key. The text you
'selected is removed from the Text Box control. You can retrieve this text within a
'Visual Basic application by sending an EM_UNDO message to Windows. The EM_UNDO message
'tells the operating system that you want to undo the last change you made to the edit control.
'In this case, the edit control is the Text Box.
'After the EM_UNDO message is sent, the original contents of the Text Box control are restored.
'The modified text is still stored in the internal Windows buffer. Therefore, in your
'application, you need to send an EM_EMPTYUNDOBUFFER message to clear or delete the
'contents of this internal buffer. The EM_EMPTYUNDOBUFFER message clears the undo flag,
'which means that you can no longer undo your last change to the edit control.
'As shown in the example program below, you can also determine if an undo operation can be
'performed on the edit control. The EM_CANUNDO message returns an integer value set to True
'if there is text in the undo buffer, or zero if no text is available. You can perform an
'undo operation only if the contents of an edit control have been previously modified and
'the data is stored in the undo buffer.
'------------------------------------------------------------
Dim OK As Long

   On Error Resume Next
   Select Case Choice
      Case 1
         OK = SendMessage(Screen.ActiveControl.Hwnd, EM_CANUNDO, 0, 0&)
         If OK Then
               OK = SendMessage(Screen.ActiveControl.Hwnd, EM_UNDO, 0, 0&)
              'OK = SendMessage(Screen.ActiveControl.hWnd, EM_EMPTYUNDOBUFFER, 0, 0&) 'Optional
            End If
      Case 2
         Clipboard.SetText Screen.ActiveControl.SelText          'Copy selected text to Clipboard
         Screen.ActiveControl.SelText = ""                       'Delete selected text
      Case 3: Clipboard.SetText Screen.ActiveControl.SelText     'Copy
      Case 4: Screen.ActiveControl.SelText = Clipboard.GetText() 'Paste
      Case 5: Screen.ActiveControl.SelText = ""                  'Delete selected text
      End Select
   On Error GoTo 0

End Sub

''Sub UnlockRecord(Rchan%, recno&, RecLen%)
'''-----------------------------------------------------------------------------
'''21Feb91 CKJ Procedure written
''' Unlocks a random access record, in a previously opened file.
''' 7Apr94 CKJ VBW: Binary access
'''29Apr02 CKJ Added extended message
'''-----------------------------------------------------------------------------
''Dim FirstByte&, LastByte&
''Dim sMsg As String
''
''   procname$ = "UnlockRecord"
''   FirstByte& = (recno& - 1) * RecLen% + 1
''   LastByte& = FirstByte& - 1 + RecLen%
''   'On Error GoTo LockError7
''   On Error GoTo UnlockRecord_Err
''   Do
''      ErrNum = False
''      Unlock #Rchan%, FirstByte& To LastByte&
''
''      sMsg = "Channel=" & Format$(Rchan) & ", Record Num=" & Format$(recno&) & ", Length=" & Format$(RecLen)
''      Err70MsgEx ErrNum, "Record in " & FileNameFromChannel(Rchan), sMsg, m_strModuleName, procname$
''   Loop While ErrNum
''   On Error GoTo 0
''
''Exit Sub
''
''UnlockRecord_Err:
''   ErrNum = Err
''
''   sMsg = "Parameters: Record Number=" & Format$(recno&) & ", Channel=" & Format$(Rchan) & ", Length=" & Format$(RecLen)
''   ListOpenedFilesPlain sMsg
''   If ErrorHandlerEx(ErrNum, "WDFHL", procname$, sMsg) = 1 Then Resume Next
''
''End Sub

Sub UserPrefs(iAction As Integer, sPathFile As String, sUserID As String, sItem As String, sValue As String, bFound As Integer, sError As String)

'Simple routine for saving user preferences in a configuration file.
'These will be saved under a section called UserPrefs;
'The Items are saved with the given values in the appropriate section, prefixed by the userid_

'[UserPrefs]
'ae_Preference1=Y
'ae_Preference2=Bread Pudding
'ae_Preference3=0
'etc etc
'
'Parameters:
'
'iAction:
'           1 - Save the given item and value under the user id in the file specified.
'           2 - Return the value for the given item under the given user in the given file
'
'sPathFile - Qualified path and file name to search/save in.  Can be any text file.
'sUserId - .
'sItem - The entry to be searched for/saved under
'sValue - The value to be returned or saved.
'bFound - If saving,False if the file did not exist (in which case it will be created)
'                   True otherwise
'         If reading, True if the entry was found under that user, false otherwise
'sError - If an error occurred, this will hold a description of it.

'--------------------------------------------------------------------------------------------------------
'02Jun00 AE  Written

Dim bFail As Integer, sTmp As String
Dim sEntry As String

   On Error GoTo UserPrefsErr

   bFound = False

'First check that the required parameters are there:
   If Trim$(sPathFile) = "" Then bFail = True
   If Trim$(sUserID) = "" Then bFail = True
   If Trim$(sItem) = "" Then bFail = True
   If Trim$(sValue) = "" And iAction = 1 Then bFail = True

   If bFail Then Error 20001                    'Quick Exit Error

'Now carry out the request:
   sEntry = sUserID & "_" & sItem

   Select Case iAction
      Case 1
         'Save to the file
         If Not fileexists(sPathFile) Then bFound = False
         WritePrivateIniFile "UserPrefs", sEntry, sValue, sPathFile, 0
         FlushIniCache

      Case 2
         'Read from the file
         If fileexists(sPathFile) Then bFound = True
         If bFound Then sValue = TxtD(sPathFile, "UserPrefs", "", sEntry, bFound)

      End Select

UserPrefsExit:

   Exit Sub

UserPrefsErr:

   If Err <> 20001 Then
         sTmp = "Error " & Format$(Err) & ":'" & Error$ & "'" & cr$
         sTmp = sTmp & "occurred in UserPrefs." & cr$
      Else
         sTmp = "UserPrefs:  One or more paramters missing:" & cr$
      End If

   sTmp = sTmp & "sPathFile: " & TB & sPathFile & cr$
   sTmp = sTmp & "sUserID:" & TB & sUserID & cr$
   sTmp = sTmp & "sItem:" & TB & sItem & cr$
   sTmp = sTmp & "sValue:" & TB & sValue & cr$
   sTmp = sTmp & "bFound:" & TB & Iff(bFound, "True", "False") & cr$

   sError = sTmp
   Resume UserPrefsExit


End Sub


''   Sub waitforkeyorticks(num As Integer, keypress As String)
''   '!!** Under Windows this proc ONLY waits and DOES NOT scan the keyboard
''
''       waitforticks num
''
''   End Sub

Sub waitforticks(num As Integer)
'-----------------------------------------------------------------------------
'
'         Sit in this procedure for 'n' ticks (approx 18 ticks/sec)
'
'-----------------------------------------------------------------------------
Dim tick%, timval!

   If num Then
         For tick = 1 To num
            timval! = Timer
            Do While timval! = Timer
            Loop
         Next
      End If

End Sub

Function WindowsVersion() As Variant
'12Sep96 CKJ VBWin example
'            Returns "3.10" "3.11" "3.95" etc as variant, ie can be used as
'            a string or number without conversion.

Dim Ver As Long, WINVER As Long
   
   Ver = GetVersion()
   WINVER = Ver And &HFFFF&
   WindowsVersion = Format((WINVER Mod 256) + ((WINVER \ 256) / 100), "Fixed")

End Function

Sub WriteLog(pathfile$, site%, User$, text$, Optional ByVal blnToDisk As Boolean = False)
'-----------------------------------------------------------------------------
' Append text to a sequential file, for error log purposes
' Default filename is \dispdata.xxx\error.log where xxx is taken from
' the command string. If site is null then this is also set to xxx.
' Line consists of
' dd-mm-yyyy hh:mm:ss site user text...................................
'17Aug92 CKJ changed file to error.log
'29apr02 CKJ Added extended message
'02Apr17 TH  Now we need to write all logs to DB for Hosted so pass through to writelogSQL (TFS 175557)
'05Jun17 TH  Added blntoDisk over ride. This allows local logwrite for robot log caching (TFS 185815)
'-----------------------------------------------------------------------------
Dim SiteNum$, username$, FILE$, chan%
Dim sMsg As String
Dim lngSiteID As Long               '02Apr17 TH Added (TFS)
Dim strLogDescription As String     '  "
Dim strParams As String

   If site = 0 Then site = SiteNumber                'Val(g_command)
   SiteNum$ = Right$("000" & LTrim$(Str$(site)), 3)
   username$ = "    "
   LSet username$ = User$

   If pathfile$ = "" Then
         FILE$ = "\dispdata." & SiteNum$ & "\error.log"
      Else
         FILE$ = pathfile$
      End If
      
   '02Apr17 TH Section added - now we need to write all logs to DB for Hosted (TFS 175557)
   'If TrueFalse(TxtD(dispdata$ & "\siteinfo.ini", "Logging", "Y", "WritelogtoDB", 0)) Then
   If TrueFalse(TxtD(dispdata$ & "\siteinfo.ini", "Logging", "Y", "WritelogtoDB", 0)) And (Not blnToDisk) Then '05Jun17 TH Added over ride (TFS 185815)
      strLogDescription = GetFileNameFromPath(FILE$)
      'remove extension
      If InStr(strLogDescription, ".") > 0 Then
         strLogDescription = Left(strLogDescription, (InStr(strLogDescription, ".") - 1))
      End If
      'get LocationID
      strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, site)
      lngSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
      
      WriteLogSQL text$, strLogDescription, 0, 0, , lngSiteID
      Exit Sub
   End If
   

   On Error GoTo WriteLog_Err
   Do
      ErrNum = False
      chan = FreeFile
      Open FILE$ For Append Lock Read Write As #chan
      'Err70msg errnum, "Error Log"                                                           '29Apr02 CKJ
      sMsg = "Channel=" & Format$(chan) & " Site=" & Format$(site) & " User=" & User$
      Err70MsgEx ErrNum, "Error Log File " & FILE$, sMsg, m_strModuleName, "WriteLog"
   Loop While ErrNum
   On Error GoTo 0
   
   Print #chan, Mid$(date$, 4, 3); Left$(date$, 3); Right$(date$, 4); " ";
   Print #chan, Time$; " "; SiteNum$; " "; username$; " "; text$

   Close chan
   
Exit Sub

WriteLog_Err:
   ErrNum = Err
   'If ErrorHandler(errnum, "WDFHL", "WriteLog") = 1 Then Resume Next                                                        '29apr02 CKJ
   sMsg = "Parameters: File=" & FILE$ & cr & "Channel=" & Format$(chan) & " Site=" & Format$(site) & " User=" & User$
   ListOpenedFilesPlain sMsg
   If ErrorHandlerEx(ErrNum, "WDFHL", "WriteLog", sMsg) = 1 Then Resume Next

End Sub

Sub WritePrivateIniFile(iniSection$, IniEntry$, initext$, iniFile$, success%)
Dim strParams As String
Dim strFile As String
Dim strPrefix As String
Dim intResult As Integer
Dim intlastSlash As Integer
Dim strCategory As String

   'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYLE SEARCHSTRING (CATEGORY)
   If InStr(LCase(iniFile$), "dispdata") > 0 Then
      strPrefix = "D"
   ElseIf InStr(LCase(iniFile$), "patdata") > 0 Then
      strPrefix = "P"
   ElseIf InStr(LCase(iniFile$), "ascroot") > 0 Then
      strPrefix = "A"
   End If
   'Convert the pathfile string to something useful for SQL
   
   intResult = -1
   Do While intResult <> 0
      If intResult > 0 Then intlastSlash = intResult
      intResult = InStr(intlastSlash + 1, iniFile$, "\", vbBinaryCompare)
   Loop
   strFile = Trim$(Mid$(iniFile$, intlastSlash + 1))
   If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
   strCategory = strPrefix & "|" & strFile
   '-------------------------------------------------------------------------------

    strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 255, iniSection$) & _
                gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 255, IniEntry$) & _
                gTransport.CreateInputParameterXML("Value", trnDataTypeVarChar, 8000, Chr$(34) & initext$ & Chr$(34))
    success = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWConfigurationWrite", strParams)
    
''   success = (WritePrivateProfileString(iniSection$, IniEntry$, initext$, iniFile$) <> 0)
   FlushIniCache

End Sub

Function YesNo$(Value As Variant)
'30May97 CKJ Moved from TPN/StkMaint
'24Oct97 CKJ value now of type variant, but must only be given numeric data types

Dim yn$

   If Value Then yn$ = getYN(3) Else yn$ = getYN(4)   '10Aug94 CKJ removed space
   YesNo$ = Left$(yn$ + "     ", 5)                   '10Aug94 CKJ padded to 5 chars

End Function

Sub threesigfigs(X!)
'ASC 3Oct94 added 000001 to .5 .055 now becomes .06 instead of .05 !!
'16Sep96 CKJ Allow neg numbers: added Abs() & Int()->Fix()
' 8Nov96 CKJ Corrected neg number handling
' 3Jan96 CKJ Changed handling of 1.0 to 9.5 ml to x.xx from x.x
'09May05 CKJ Moved from tpnsubsw

Dim sign%, Y!

   sign = Sgn(X!)
   Y! = Abs(X!)
   Select Case Y!
      Case Is > 99.4:  X! = Fix(Y! + 0.5001)
      Case Is > 9.999: X! = Fix(Y! * 10 + 0.50001) / 10
      Case Else:       X! = Fix(Y! * 100 + 0.5000001) / 100
      End Select
   X! = X! * sign

End Sub

Sub MakeLocalFile(filename$)
'-----------------------------------------------------------------------------
'
'                  Create a local file in root
'
' extn is the local file number, and starts at zero
' It will increment during a given program run, reducing the creation time
' but will revert to zero when the program runs again
'
'11Jan90 CKJ Now scans from 0 each time
'25May99 CKJ Amended for definable path, multi-user operation
'            Terminal.ini [] or [termname], LocalFilePath="d:\path"
'             - explicit path, entered in either default or terminal section
'            Terminal.ini [] LocalFilePath="d:\path\%TERMINAL%"
'             - path includes terminal name, use only in default section.
'            UNC paths are allowed, e.g. LocalFilePath="\\server\share\path"
'09May05 CKJ Moved from Spool.bas
'15Jun11 TH  Changes to local file name conventions (F0088133)
'15Sep11 CKJ Corrected.                             (TFS14212)
'            Terminal name must have illegal chars removed before use in a filename.
'            Restriction to 8 chars not appropriate as terminal names can overlap.
'            - note that this alters existing behaviour of LocalFilePath setting.
'            Added fileexists() in a loop round before the file creation step.
'            Use of the print heap not appropriate for core file handling library
'            - heap may not exist, especially in interfaces.
'             After discussion it was felt that there is sufficient variability
'             using the predefined filename. If after review extras are wanted
'             then they should be a straight 'replace' without heap handling.
'            Moved terminal name after date/time in file name to allow parsing.
'
'            For consideration:
'            -should the default be moved from C:\ due to users' permissions?
'            -is RTF the best extension to use? Whould TXT/DAT/TMP be better?
'            -default error handling is not ideal - should add handler here
'            -scope of the generator is not the same as scope of the files;
'              consider L/R/T all running, they all share the same directory
'              and share the same clock, but could overlap in IDs. Same
'              problem when the clocks go back & 're-use' the hour again.
'              However considered of minor importance now with fileexists()
'-----------------------------------------------------------------------------
Const ErrSource As String = "MakeLocalFile"

Dim filno%
Dim drvpth$, LocalFile$, TerminalName$
Dim strFilename As String
Dim LocalFileID As Long
'Dim OK%, extn%, lockname$             '15Sep11 CKJ removed superfluous vars
'Dim strOptionalComponent As String    '   "        heap may not be present

   'OK = False          '15Sep11 CKJ superfluous
   'extn = 0            '   "
   
   drvpth$ = "c:"                                             '25May99 CKJ Added block
   LocalFile = "\#LOCALF#."
   drvpth$ = terminal$("LocalFilePath", drvpth$)              'Is path specified?
   
   '15Sep11 CKJ Moved block outside the following IF
   TerminalName$ = ASCTerminalName()                    'get terminal name
   replace TerminalName$, " ", "", 0                    'remove ' \/:*?"<>|¦.'
   replace TerminalName$, "\", "", 0
   replace TerminalName$, "/", "", 0
   replace TerminalName$, ":", "", 0
   replace TerminalName$, "*", "", 0
   replace TerminalName$, "?", "", 0
   replace TerminalName$, Chr$(34), "", 0               'quotes "
   replace TerminalName$, "<", "", 0
   replace TerminalName$, ">", "", 0
   replace TerminalName$, "|", "", 0
   replace TerminalName$, "¦", "", 0
   replace TerminalName$, ".", "", 0
   'TerminalName$ = Left$(TerminalName$, 8)              '15Sep11 CKJ removed - allow full name in path & filename
   If Len(TerminalName$) = 0 Then TerminalName$ = "DEFAULT"

   'If InStr(1, drvpth$, "%TERMINAL%", 1) Then          'Is terminal name wanted?      '15Sep11 CKJ The IF is superfluous now
   replace drvpth$, "%TERMINAL%", TerminalName$, True   'case insensitive replace
   'End If                                                                             '   "
   If Right$(drvpth$, 1) = "\" Then drvpth$ = Left$(drvpth$, Len(drvpth$) - 1)

   'lockname$ = drvpth$ & "\MakeLocl.lck"   '25May99 CKJ added    '15Jun11 TH Removed (F0088133)
   'AcquireLock lockname$, 2, 0                                   '   "

   Do '15Sep11 CKJ added
      '15Jun11 TH Replaced above (F0088133)
      'strFilename = "#LocalF#" & ASCTerminalName() & DateAndTimeToMillisecond()    '15Sep11 CKJ Replaced with parsed terminal name
      strFilename = "#LocalF#" & DateAndTimeToMillisecond() & TerminalName          '   "        and moved after date/time to allow parsing
      'strOptionalComponent = TxtD(rootpath$ + "\LocalFil.ini", "", "", "OptionalLocalFileElement", 0)   '15Sep11 CKJ removed after discussion
      'ParseItems gPRNheapID, strOptionalComponent, 0                                                    '            as heap may not be present
      '15Jun11 TH End
      
      '06Jul11 TH Replaced
      'Do
      '   Select Case extn
      '      Case Is > 999                     '25May99 CKJ Was 99, extended for server based spooling
      '         popmessagecr "** Program halted **", "** Cannot make local file - too many in use **"
   ''            Close
   ''            End!                            '!!** not ideal
      '         Err.Raise 32767, PROJECT & ErrSource, "Module Halted: " & cr & cr & "Cannot make local file - too many in use (1000 or more)"
   
      '      Case Is > 199                     '25May99 CKJ Added lesser warning, user can carry on
      '         popmessagecr ".WARNING", Format$(extn) & " local files are in use." & crlf & "Contact Support Desk for help and advice"
      '      End Select
   
         'If Not fileexists(drvpth$ & LocalFile & LTrim$(Str$(extn))) Then
         '   filename$ = drvpth$ & LocalFile & LTrim$(Str$(extn))
      '   filename$ = drvpth$ & strFilename & Right$("000" & LTrim$(Str$(extn)), 4) & strOptionalComponent & ".rtf" '15Jun11 TH Replaced above (F0088133)
      '   If Not fileexists(filename$) Then                                                                         '    "
      '      OK = True
      '   Else
      '      extn = extn + 1
      '   End If
      'Loop Until OK
      
      'We need to get the extension
      'Here we read a trust wide pointer
      GetPointerSQL rootpath$ & "\LocalFileID", LocalFileID, True
      LocalFileID = LocalFileID Mod 1000
      'filename$ = drvpth$ & "\" & strFilename & Right$("000" & LTrim$(Str$(LocalFileID)), 4) & strOptionalComponent & ".rtf" '15Jun11 TH Replaced above (F0088133)
      filename$ = drvpth$ & "\" & strFilename & Right$("000" & Format$(LocalFileID), 4) & ".rtf"  '15Jun11 TH Replaced above (F0088133)  '15Sep11 CKJ removed optional part as heap may not be present
   Loop While fileexists(strFilename)     '15Sep11 CKJ added to prevent clash with an existing file
   If UpdatedRTFfilename <> "" Then
    filename$ = UpdatedRTFfilename
   Else
   filno = FreeFile                       'create file of 0 bytes on disk
   Open filename$ For Output As filno     '(prevent name being used by another task)
   End If
   
   
   Close filno
   'AcquireLock lockname$, 0, 0           '25May99 CKJ added  '15Jun11 TH Removed (F0088133)

End Sub

Sub EscapeXML(strXML As String)
'09May05 CKJ Given an ASCII string convert to XML compliant format (not intended for Unicode)
'            Characters which the XMLDOM cannot handle are escaped, all others are unchanged
'            For efficiency, the same parameter is used for input and output, and if no changes
'            are needed then no bulk string manipulation takes place.
'            If replacements are made, then this is done as a splice into a pre-allocated string
'            and one cast back is done on exit.
'            The maximum size of the returned string is 6x the original length,
'            eg a null    => &#0;
'               a char 26 => &#26;
'               "         => &quot;
'            Note that ' is handled as &#39; not as &apos; for broadest compatibility

Dim ReadPtr As Integer     'position within strXML of current character if any
Dim WritePtr As Integer    'position within strXML of text already processed and written to Buffer (0 at first)
Dim Written As Integer     'position within Buffer where last write took place (0 at first)
Dim buffer As String       'output buffer
Dim intChar As Integer     'ASCII value of single character under microscope
Dim Fragment As String     'string fragment to be spliced into buffer

   buffer = ""
   Written = 0             'Nothing written to output buffer
   WritePtr = 0            'None of the input string parsed and written either

   For ReadPtr = 1 To Len(strXML)
      intChar = Asc(Mid$(strXML, ReadPtr, 1))
      Select Case intChar
         Case 0 To 8, 11, 12, 14 To 31, 34, 38, 39, 60, 62
            'allocate the buffer if not already done
            If Written = 0 Then buffer = String$(Len(strXML) * 6, 0)          'fill with nulls to max length

            'commit any pending text, from writeptr+1 to readptr-1
            'eg        Writeptr Readptr
            '          ¦        ¦
            '     abcdefGHIJKLMN&....
            Mid$(buffer, Written + 1) = Mid$(strXML, WritePtr + 1, ReadPtr - WritePtr - 1)   'splice fragment into buffer
            Written = Written + ReadPtr - WritePtr - 1                        'ie Written + Len(Fragment)
            
            'append the new text
            Select Case intChar
               Case 34:   Fragment = "&quot;"                                 ' "
               Case 38:   Fragment = "&amp;"                                  ' &
              'Case 39:   Fragment = "&apos;"                                 ' '  Do as numeric for compatibility
               Case 60:   Fragment = "&lt;"                                   ' <
               Case 62:   Fragment = "&gt;"                                   ' >
               Case Else: Fragment = "&#" & Format$(intChar) & ";"            ' all others
               End Select                                                     'it's more efficient to splice
            Mid$(buffer, Written + 1) = Fragment                              'two fragments than to concatenate
            Written = Written + Len(Fragment)                                 'and splice the one
            
            'update pointer within source data
            WritePtr = ReadPtr
         End Select
   Next
      
   If Written Then
      'commit any final text, if any
      ReadPtr = Len(strXML)                                                   'required since For/Next increments it
      If WritePtr < ReadPtr Then
         'Mid$(buffer, Written + 1) = Mid$(strXML, WritePtr + 1, ReadPtr - WritePtr - 1)   'splice fragment into buffer
         Mid$(buffer, Written + 1) = Mid$(strXML, WritePtr + 1, ReadPtr - WritePtr)   '20Feb15 TH Replaced (TFS 111721 )
         'Written = Written + ReadPtr - WritePtr - 1
         Written = Written + ReadPtr - WritePtr  '20Feb15 TH Replaced (TFS 111721 )
      End If
      
      'return revised string
      strXML = Left$(buffer, Written)                                         'the one big string handling
      buffer = ""
   End If
   
End Sub
Public Function GetDSSMasterSiteFromSiteID(ByVal lngSiteID As Long) As Long
'20Feb06 TH Written

Dim strParam As String

   strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngSiteID)
   GetDSSMasterSiteFromSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
   
End Function
Public Function GetSiteDescription(ByVal lngSiteID As Long) As String
'17Mar07 TH Written

Dim strParam As String
Dim strResult As String
Dim rs As ADODB.Recordset

   strResult = "Site " & Format$(lngSiteID)
   strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, lngSiteID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pLocationDescriptionbyLocationID", strParam)
   If Not rs.EOF Then
      strResult = RtrimGetField(rs!Description)
   End If
   rs.Close
   Set rs = Nothing
   GetSiteDescription = strResult
   
End Function

Public Function GetSessionState(ByVal Setting As String) As String
'28May08 TH Written
Dim strParam As String
Dim strResult As String
Dim rs As ADODB.Recordset

   strParam = gTransport.CreateInputParameterXML("setting", trnDataTypeVarChar, 1024, Setting)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pSessionAttributeGetNonXML", strParam)
   If rs.RecordCount > 0 Then
      strResult = RtrimGetField(rs!Value)
   Else
      strResult = ""
   End If
   
   
   GetSessionState = strResult
   
End Function

Public Function SetSessionState(ByVal Setting As String, ByVal strValue As String) As Long
'28May08 TH Written
Dim strParam As String
Dim lngResult As Long

   strParam = gTransport.CreateInputParameterXML("Setting", trnDataTypeVarChar, 1024, Setting) & _
            gTransport.CreateInputParameterXML("Value", trnDataTypeVarChar, 16, strValue)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSessionAttributeSetNonXML", strParam)
   
   SetSessionState = lngResult
   
End Function

Function Encrypt(ByVal strData As String, ByVal strPassword As String, strCipher As String) As Boolean
'17Jul08 CKJ CAPI derived from MSDN example

Dim intCipher       As Integer
Dim intHashType     As Integer
Dim CryptoAPI       As clsMSCAPI

   Encrypt = False
   On Error GoTo EncryptErr
   Set CryptoAPI = New clsMSCAPI
   
' ---------------------------------------------------------------------------
' For encrypting, leave one extra element in the array to handle the last
' NULL appended to the excrypted file
' ---------------------------------------------------------------------------
   CryptoAPI.Password = strPassword

   If CryptoAPI.Encrypt(strData) Then
      strCipher = CryptoAPI.OutputData
      Encrypt = True
   End If

Cleanup:
   On Error Resume Next
   Set CryptoAPI = Nothing
   On Error GoTo 0
Exit Function
  
EncryptErr:
   popmessagecr ".Encrypt Error", "Error: " & CStr(Err.Number) & "  " & Err.Description
Resume Cleanup
  
End Function

Function Decrypt(ByVal strCipher As String, ByVal strPassword As String, strData As String) As Boolean
'17Jul08 CKJ CAPI derived from MSDN example

Dim intCipher       As Integer
Dim intHashType     As Integer
Dim CryptoAPI       As clsMSCAPI

   Decrypt = False
   On Error GoTo DecryptErr
   Set CryptoAPI = New clsMSCAPI
   
   CryptoAPI.Password = strPassword

   If CryptoAPI.Decrypt(strCipher) Then
      strData = CryptoAPI.OutputData
      Decrypt = True
   End If

Cleanup:
   On Error Resume Next
   Set CryptoAPI = Nothing
   On Error GoTo 0
Exit Function
  
DecryptErr:
   'popmessagecr ".Decrypt Error", "Error: " & CStr(Err.Number) & "  " & Err.Description        '17Aug12 CKJ Can't call here is it uses database settings, no decrypt:no database access
   MsgBox "Error: " & CStr(Err.Number) & "  " & Err.Description, vbCritical + vbOKOnly, ".Decrypt Error"        '17Aug12 CKJ use this instead
Resume Cleanup
  
End Function

Function ParseURLToken(ByVal sessionID As Long, ByVal URLToken As String, phase As Single, Detail As String, WebDataConn As Boolean, WebProxyPageURL As String, UnencryptedToken As String) As String
'18Jul08 CKJ/LB Replaced PhaRTL with encrypted communication
'11Aug08 CKJ Moved from ucDispens to corelib
'12Nov08 CKJ Added filter for problematic integrated security connection param  (F0037151)
'28Jun12 AJK 36929 Added 3 new params: WebDataConn as a byref to inform calling code if the URL token is for a web data connection
'                                      WebProxyPageURL as a byref string to inform the calling code what the full web proxy page url is
'                                      UnencryptedToken as a byref string to inform the calling code what the unencrypted token was
'                  Renamed ConnectionString to ResponseValue
'                  Added replacement code which derives the web page proxy url
'                  Added setting of unencryptedtoken value
'                  Formatting of connection string now conditional if connectiong string properties detected.

Dim HttpRequest As WinHttpRequest
Dim strURL As String
Dim strToken As String
Dim posn As Integer
Dim success As Boolean
Dim strSeed As String
Dim strCypher As String
Dim strCypherHex As String
'Dim ConnectionString As String '28Jun12 AJK 36929 Renamed to ResponseValue
Dim ResponseValue As String '28Jun12 AJK 36929 Renamed from ConnectionString

'   On Error GoTo ErrorHandler
   ResponseValue = ""

   strToken = ""
   phase = phase + 1    '(2)
   posn = InStr(URLToken, "?")                                       '  someserver/ICW/integration/Pharmacy/GetEncryptedString.aspx?token=734711635|8af10894262a4d97a8dfec17fd5f0362&SessionId=795
   If posn > 2 Then                                                  '  split URL from response string
      '12Jan09 XN F0042881 had the http:// bit sent in via ICW as we maybe using HTTPS
      'strURL = "http://" & Left$(URLToken, posn - 1)                '  someserver/ICW/integration/Pharmacy/GetEncryptedString.aspx
      strURL = Left$(URLToken, posn - 1)                             '  http://someserver/ICW/integration/Pharmacy/GetEncryptedString.aspx
      '28Jun12 AJK 36929 Capture base URL and change page to web page proxy for passing out
      WebProxyPageURL = strURL
      replace WebProxyPageURL, "GetEncryptedString", "PharmacyTransport", 0
      '28Jun12 AJK 36929 END
      posn = InStr(posn + 1, URLToken, "token=", vbTextCompare)      '  token=734711635|8af10894262a4d97a8dfec17fd5f0362&SessionId=795
      
      If posn Then
         URLToken = Mid$(URLToken, posn + 6)                         '  734711635|8af10894262a4d97a8dfec17fd5f0362&SessionId=795
         posn = InStr(URLToken, "&")
         If posn > 1 Then                                            '  discard session id
            URLToken = Left$(URLToken, posn - 1)                     '  734711635|8af10894262a4d97a8dfec17fd5f0362
         End If
         
         posn = InStr(URLToken, "|")                                 '  split remainder into seed & token
         If posn Then
            strSeed = Left$(URLToken, posn - 1)                      '  734711635
            strToken = Mid$(URLToken, posn + 1)                      '  8af10894262a4d97a8dfec17fd5f0362
            UnencryptedToken = strToken '28Jun12 AJK 36929 Added to remember the unencrypted token value
         End If
      End If
   End If
      
   If Len(strToken) Then
      phase = phase + 1          '(3)
      If Encrypt(strToken, frmBlank.Tag & strSeed, strCypher) Then
         phase = phase + 0.1     '(3.1)
         strCypherHex = String$(Len(strCypher) * 2, vbNullChar)
         For posn = 1 To Len(strCypher)
            Mid$(strCypherHex, posn * 2 - 1, 2) = Right$("0" & Hex$(Asc(Mid$(strCypher, posn, 1))), 2)
         Next
         
         phase = phase + 0.1     '(3.2)
         Set HttpRequest = New WinHttpRequest
         phase = phase + 0.1     '(3.3)
         HttpRequest.open "POST", strURL, False
         HttpRequest.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
         phase = phase + 0.1     '(3.4)
         HttpRequest.send "SessionID=" & Format$(sessionID) & "&Token=" & strCypherHex
         phase = phase + 0.1     '(3.5)
         '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
         'ConnectionString = HttpRequest.responseText
         ResponseValue = HttpRequest.responseText
         '28Jun12 AJK 36929 END
         Set HttpRequest = Nothing
         'If ResponseValue = "" Then  '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
         If ResponseValue = "" Or InStr(1, ResponseValue, "<html", 1) > 0 Then '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue  '17Aug12 CKJ Suppress broken rules
            Detail = "- Token not valid"
            ResponseValue = ""  '17Aug12 CKJ Suppress broken rules
         Else
            'hex string to Ascii
            phase = phase + 0.1     '(3.6)
            For posn = 1 To Len(ResponseValue) Step 2  '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
               Mid$(ResponseValue, (posn \ 2) + 1) = Chr$(Val("&H" & Mid$(ResponseValue, posn, 2)))  '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
            Next
            ResponseValue = Left$(ResponseValue, Len(ResponseValue) \ 2)  '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
            'encrypted ascii to plain ascii
            phase = phase + 0.1     '(3.7)
            If Decrypt((ResponseValue), frmBlank.Tag & strToken, ResponseValue) Then  '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
               If InStr(ResponseValue, "Data Source=") > 0 Then  '28Jun12 AJK 36929 Format connection string if detected
                  'connectionString="Data Source=core-testing\testing;Initial Catalog=testingdatabase;Integrated Security=False;User ID=sys;Password="
                  replace ResponseValue, "Data Source=", "provider=sqloledb;server=", True
                  replace ResponseValue, "Initial Catalog=", "database=", True
                  replace ResponseValue, "User ID=", "uid=", True
                  replace ResponseValue, ";Integrated Security=False", "", True              '12Nov08 CKJ Added
                  replace ResponseValue, ";Integrated Security=True", "", True               '   "
                  WebDataConn = False '28Jun12 AJK 36929 Added
               Else
                  WebDataConn = True '28Jun12 AJK 36929 Added
               End If
            Else
               Detail = "- Reply not valid"
               ResponseValue = ""
            End If
         End If
      Else
         Detail = "- Token not usable"
      End If
   Else
      Detail = "- Token not provided"
   End If
   frmBlank.Tag = ""

   ParseURLToken = ResponseValue   '28Jun12 AJK 36929 Renamed ConnectionString to ResponseValue
   
End Function

Function ParseCommandURLToken(ByVal sessionID As Long, ByVal strCommand As String, phase As Single, Detail As String, WebDataConn As Boolean, WebProxyPageURL As String, UnencryptedToken As String) As String
'12Aug08 CKJ Pre-parser for ParseURLToken, driven by command line argument instead of URLtoken directly from web page
'            Expects to see standard URLtoken string embedded in Command$
'            [[/args|args]...] /urltoken=[standard URLtoken string][[ /args]...]
'
'Command should contain   /urltoken=some/path/GetEncryptedString.aspx?token=DECDECDEC|HEXHEXHEXHEXHEXHEX&SessionId=DEC   optionally followed by <space>/[more args]
'ParseURLToken is expecting to see  some/path/GetEncryptedString.aspx?token=DECDECDEC|HEXHEXHEXHEXHEXHEX   optionally followed by &[more args]
' (DEC and HEX are an arbitrary number of decimal/hexadecimal characters)
'28Jun12 AJK 36929 Added new params to procedure and ParseURLToken call

Dim strURLtoken As String
Dim posn As Integer
   
   strURLtoken = ""
   
   posn = InStr(1, strCommand, "/urltoken=", vbTextCompare)                      '/urltoken=some/path/GetCo... /MoreArgs
   If posn Then strURLtoken = Mid$(strCommand, posn + 10)                        'some/path/GetCo... /MoreArgs
   
   posn = InStr(strURLtoken, " /")                                               'stop before next <space>/
   If posn > 1 Then strURLtoken = RTrim$(Left$(strURLtoken, posn - 1))           'some/path/GetCo...
   
   ParseCommandURLToken = ParseURLToken(g_SessionID, strURLtoken, phase, Detail, WebDataConn, WebProxyPageURL, UnencryptedToken)  'pass for standard processing '28Jun12 AJK 36929 Added extra params

End Function
'Sub WriteLogSQL(ByVal strDetail As String, ByVal strDescription As String, ByVal intState As Integer, ByVal lngThread As Double)
Sub WriteLogSQL(ByVal strDetail As String, ByVal strDescription As String, ByVal intState As Integer, ByVal lngThread As Double, Optional ByVal NSVCode As String = "", Optional ByVal lngSiteID As Long = 0, Optional ByVal lngLogID As Long = 0)
'-----------------------------------------------------------------------------
' 03Aug09 TH Written as a sometime replacement for Writelog in the DB.
' This is really only for logging to help debug the "double receipt" problem,
' but can be used in the future as required.
' Detail should equate to the type of log ( roughly analagous to old file name)
' Description - the textual description of the event being logged.
' Terminal - the current Terminal
' User - the user at the point of logging
' Date and time are defaulted in theDB at point of insert.
' State - an optional integer used to record a given state - used to help track events in SQL
' Thread - an optional ID to be used when logging multiple points in a given process to aid in
' NSVCode - optional NSV Code value
' debugging form SQL.
'-----------------------------------------------------------------------------
'28Mar10 TH Moved from Storeasc for use across suite (as Chris required)
'15Nov13 XN Added NSVCode 56701
'20Jan15 XN Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'18Feb17 TH Extended Detail form 255 to 8000 to match underlying DB ahnage and ensure RObot logs saced correctly (TFS 177654)
'02Apr17 TH Changes for handling all file based writelogs. Added site as optional param (to pass through)


Dim sMsg As String
Dim strSql As String
Dim blnOK As Long
Dim ErrNum As Long
Dim ErrDesc As String

   If lngSiteID = 0 Then lngSiteID = gDispSite
   

   On Error GoTo WriteLogSQL_Err
   If lngLogID > 0 Then 'We know the type of log we are writing(TFS 185185)
    strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, lngSiteID) & _
             gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 25, ASCTerminalName()) & _
             gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 4, gEntityID_User) & _
             gTransport.CreateInputParameterXML("Detail", trnDataTypeVarChar, 8000, strDetail) & _
                         gTransport.CreateInputParameterXML("WPharmacyLogTypeID", trnDataTypeint, 4, lngLogID) & _
             gTransport.CreateInputParameterXML("State", trnDataTypeint, 4, intState) & _
             gTransport.CreateInputParameterXML("Thread", trnDataTypeint, 4, lngThread) & _
             gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode)
   Else
   '17Apr02 TH Replaced gDispSite with lngSiteID
    strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, lngSiteID) & _
             gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 25, ASCTerminalName()) & _
             gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 4, gEntityID_User) & _
             gTransport.CreateInputParameterXML("Detail", trnDataTypeVarChar, 8000, strDetail) & _
                         gTransport.CreateInputParameterXML("WPharmacyLogTypeID", trnDataTypeint, 4, GetWPharmacyLogTypeIDFromDescription(strDescription)) & _
             gTransport.CreateInputParameterXML("State", trnDataTypeint, 4, intState) & _
             gTransport.CreateInputParameterXML("Thread", trnDataTypeint, 4, lngThread) & _
             gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, NSVCode)  '15Nov13 XN Added NSVCode 56701
                                    
   End If
           
   blnOK = gTransport.ExecuteInsertSP(g_SessionID, "WPharmacyLog", strSql)
   
WriteLogSQL_Cleanup:

      
Exit Sub

WriteLogSQL_Err:
   ErrNum = Err.Number
   ErrDesc = Err.Description
   popmessagecr "", "A problem occured when trying to write to the Database WPharmacyLog Table" & crlf & crlf & "Error : " & Format$(ErrNum) & " Description : " & ErrDesc
   
   Resume WriteLogSQL_Cleanup
   
End Sub

' Reverses a string array
' 22Jul11 XN (F0102524), (F0102526), (F0102527)
Sub ReverseStringArray(Items() As String)
        Dim temp_array() As String
   ReDim temp_array(UBound(Items))
        
        Dim intCount As Integer
   For intCount = 1 To UBound(Items)
      temp_array(intCount) = Items(UBound(Items) - (intCount - 1))
   Next
        
   For intCount = 1 To UBound(Items)
      Items(intCount) = temp_array(intCount)
   Next
End Sub

'--------------------------------------------------------- Transport Layer -----------------------------------------------
Function gTransportConnectionIsNothing() As Boolean
'08Aug12 CKJ Wrapper written

Dim result As Boolean

   result = True
   
   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         result = False
      Else
         result = (gTransport.Connection Is Nothing)
      End If
   End If
   
   gTransportConnectionIsNothing = result

End Function

Function gTransportConnectionState() As ADODB.ObjectStateEnum
'08Aug12 CKJ Wrapper written

Dim State As ADODB.ObjectStateEnum

   State = adStateClosed
   
   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         State = adStateOpen
      Else
         If Not gTransport.Connection Is Nothing Then
            State = gTransport.Connection.State
         End If
      End If
   End If
   
   gTransportConnectionState = State
   
End Function

Sub gTransportConnectionClose()
'08Aug12 CKJ Wrapper written
   
   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         'no action
      Else
         If gTransportConnectionState = adStateOpen Then
            gTransport.Connection.Close
         End If
      End If
   End If

End Sub

Sub SetgTransportConnectionToNothing()
'08Aug12 CKJ Wrapper written
   
   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         'no action
      Else
         If Not gTransport.Connection Is Nothing Then
            Set gTransport.Connection = Nothing          '15Aug12 CKJ added Set
         End If
      End If
   End If

End Sub
 
Sub gTransportConnectionExecute(ByVal Parameters As String)
'08Aug12 CKJ Wrapper written
'            CAUTION: New transport layer does not support transactions initiated from the client
'            as there is no 'connection' object as such. Each call has to be completed in one go.
'            This wrapper is therefore not a substitute for refactoring transaction handling.
'            As a double check, no other commands can be executed & any attempt raises an error.
   
   Select Case LCase(Parameters)
      Case "begin transaction", "commit transaction", "rollback transaction"
         If Not gTransport Is Nothing Then
            If TypeOf gTransport Is PharmacyWebData.Transport Then
               'no action
            Else
               If Not gTransport.Connection Is Nothing Then
                  gTransport.Connection.Execute Parameters
               End If
            End If
         End If
      Case Else
         Err.Raise 32767, OBJNAME & "gTransportConnectionExecute", "Cannot execute '" & Parameters & "'"
      End Select
   
End Sub

Function gTransportIsInTransaction(ByVal sessionID As Long) As Boolean
'08Aug12 CKJ Wrapper written
   
Dim result As Boolean
   
   result = False
   
   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         'no action; return False
      Else
         If Not gTransport.Connection Is Nothing Then
            result = gTransport.IsInTransaction(g_SessionID)
         End If
      End If
   End If

   gTransportIsInTransaction = result
   
End Function
 
Sub gTransportADOSetLockTimeOut(ByVal lngMilliSecs As Long)
'16Aug12 CKJ Wrapper written
'            CAUTION: Despite its name ADOSetConnectionTimeOut does not
'            operate when establishing a connection. It is purely a
'            timeout on establishing a SQL lock. The SQL default is -1
'            which means wait forever. A specified timeout will raise
'            error 1222 which should be specifically trapped & handled.

   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         'no action
      Else
         If Not gTransport.Connection Is Nothing Then
            gTransport.ADOSetConnectionTimeOut lngMilliSecs
         End If
      End If
   End If
   
End Sub

Function gTransportType() As Integer
'10Sep12 CKJ Written. The transport layer is late bound, using web or direct SQL connection.
'            Returns value which indicates type of transport layer which has been instantiated.
'              0  No transport layer instantiated
'              1  Traditional direct SQL connection
'              2  Web-based connection

   If Not gTransport Is Nothing Then
      If TypeOf gTransport Is PharmacyWebData.Transport Then
         gTransportType = 2
      Else
         gTransportType = 1
      End If
   Else
      gTransportType = 0
   End If

End Function

Function ReadLogSQL(ByVal strDescription As String, ByVal blnRoot As Boolean) As ADODB.Recordset
'07Mar14 TH Added to allow access to new stuff from DB (Labutils) (TFS 75625)
'20Jan15 XN Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
'02Apr17 TH Added Root to allow cross site checks (labutils and reconcil from root path) (TFS 175557)


Dim sMsg As String
Dim strSql As String
Dim blnOK As Long
Dim ErrNum As Long
Dim ErrDesc As String
Dim rs As ADODB.Recordset


   

   On Error GoTo ReadLogSQL_Err
   Set rs = New ADODB.Recordset
   'strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
   '          gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 25, strDescription)
   'Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPharmacyLogbySiteandDescription", strSql)       20Jan15 XN 26734
   
   If blnRoot Then
      strSql = gTransport.CreateInputParameterXML("WPharmacyLogTypeID", trnDataTypeint, 4, GetWPharmacyLogTypeIDFromDescription(strDescription))
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPharmacyLogByWPharmacyLogID", strSql)
   Else
      strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                gTransport.CreateInputParameterXML("WPharmacyLogTypeID", trnDataTypeint, 4, GetWPharmacyLogTypeIDFromDescription(strDescription))
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPharmacyLogBySiteandWPharmacyLogID", strSql)
   End If
   Set ReadLogSQL = rs
   
ReadLogSQL_Cleanup:

      
Exit Function

ReadLogSQL_Err:
   ErrNum = Err.Number
   ErrDesc = Err.Description
   popmessagecr "", "A problem occured when trying to read from the Database WPharmacyLog Table" & crlf & crlf & "Error : " & Format$(ErrNum) & " Description : " & ErrDesc
   
   Resume ReadLogSQL_Cleanup
   
End Function

Function GetRichTextDocument(ByVal ReportName As String) As String
'22May14 XN Started storing ICW reports in the DB 88863

Dim rsRTF As ADODB.Recordset
Dim strParameters As String
Dim ErrNum As Long
Dim ErrDesc As String

    On Error GoTo ReadLogSQL_Err
    
    Set rsRTF = New ADODB.Recordset
    strParameters = gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, Len(ReportName), ReportName)

    Set rsRTF = gTransport.ExecuteSelectSP(g_SessionID, "pRichTextDocumentByDescription", strParameters)
   
    If rsRTF.EOF Then
        MsgBox "Failed to find report '" + ReportName + "'. Might need to be converted from old v8 file."
    Else
        GetRichTextDocument = RtrimGetField(rsRTF!Detail)
    End If
    rsRTF.Close
   
    Set rsRTF = Nothing
Exit Function

ReadLogSQL_Err:
    ErrNum = Err.Number
    ErrDesc = Err.Description
    popmessagecr "", "A problem occured when trying to read from the Database RichTextDocument Table" & crlf & crlf & "Error : " & Format$(ErrNum) & " Description : " & ErrDesc
End Function


Function GetWPharmacyLogTypeIDFromDescription(ByVal strDescription As String) As Integer
'20Jan15 XN Added method to get the  WPharmacyLogTypeID 26734

Dim strSql As String
Dim ErrNum As Long
Dim ErrDesc As String
Dim rs As ADODB.Recordset

   On Error GoTo GetWPharmacyLogTypeIDFromDescription_Err
   'MM-7804 -The length truncation is made to make it work on both the Transport Components(PharmacyWebData & PharmacyData)
   If Len(strDescription) > 25 Then
        strDescription = Left$(CStr(strDescription), 25)
    End If
   Set rs = New ADODB.Recordset
   strSql = gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 25, strDescription)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWPharmacyLogTypeGetOrAddByDescription", strSql)
   If Not rs.EOF Then
      GetWPharmacyLogTypeIDFromDescription = RtrimGetField(rs!WPharmacyLogTypeID)
   End If
      
Exit Function

GetWPharmacyLogTypeIDFromDescription_Err:
   ErrNum = Err.Number
   ErrDesc = Err.Description
   popmessagecr "", "A problem occured when trying to read from the Database WPharmacyLogType Table" & crlf & crlf & "Error : " & Format$(ErrNum) & " Description : " & ErrDesc
End Function

' Extracts the web server, and root folder of the web site from the a URL
' So http://localhost/ICW/application/somefolder/somepage.aspx or  /urltoken=http://localhost/ICW/application/somefolder/somepage.aspx /MoreArgs would
' return http://localhost/ICW
' If the url can't be passed correctly the method will return an empty string
' 23Jun09 XN F0033906
' 02Aug16 XN Made public so can get site url form other parts of the system 159413
' 09Aug16 XN Moved from OrderlibDisp.bas 159843
' 12Aug16 XN fixed issue coverting URL 160253
Function ParseCommandURLServerAndWebFolder(ByVal strURL As String) As String
   Dim strTemp As String    ' Temp string
   Dim posn As String       ' Position in the string
      
   strTemp = strURL
   
   posn = InStr(1, strTemp, "/urltoken=", vbTextCompare)     ' /urltoken=http://localhost/ICW/application/somefolder/somepage.aspx /MoreArgs
   If posn Then strTemp = Mid$(strTemp, posn + 10)           ' http://localhost/ICW/application/somefolder/somepage.aspx /MoreArgs
   
   posn = InStr(strTemp, " /")                                  ' Stop before next argument
   If posn > 1 Then strTemp = RTrim$(Left$(strTemp, posn - 1))  ' http://localhost/ICW/application/somefolder/somepage.aspx
   
   posn = InStr(1, strTemp, "//", vbTextCompare)                                 ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=6
   
   If posn > 1 Then posn = InStr(posn + 2, strTemp, "/", vbTextCompare)          ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=17
   
   If posn > 1 Then posn = InStr(posn + 1, strTemp, "/", vbTextCompare)          ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=21
   
   If posn > 1 Then ParseCommandURLServerAndWebFolder = Left$(strTemp, posn - 1) ' http://localhost/ICW

End Function

'Calls a web service method on the pharmacy web site
'urlPostFix - the web service name starting as the application folder (e.g. application/pharmacysharedscripts/PharmacyStatusNotesProcessor.asmx)
'methodName - the web service method to call SetStatusNoteState
'xmlParameters - parameters to pass to the method in xml formar (e.g. <sessionID>5424</sessionID><noteTypeID>11245</noteTypeID><requestTypeID>2154</requestTypeID>...)
'returns the data from the web service call
'XN 6Oct15  77780 created
'XN 09Aug16 Moved from OrderlibDisp.bas 159843
Function CallWebMethod(ByVal urlPostFix As String, ByVal methodName As String, ByVal xmlParameters As String) As String
    Dim HttpRequest As WinHttpRequest
    Dim strRet As String
    Dim intPos1 As Integer
    Dim intPos2 As Integer
    Dim XmlBody As String
    Dim url As String
    
    On Error GoTo CallWebMethod_Err
    
    ' Build up the url to call
    ' http://asc-xnorman/ICW_HongKong_Pharmacy/application/pharmacysharedscripts/PharmacyStatusNotesProcessor.asmx?op=SetStatusNoteState
    url = ParseCommandURLServerAndWebFolder(g_URLToken) + "/" + urlPostFix + "?op=" + methodName
    
    ' Create the XML body used to call the web service method
    XmlBody = "<?xml version=""1.0"" encoding=""utf-8""?>" + _
              "<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">" + _
                "<soap:Body>" + _
                    "<" + methodName + " xmlns=""http://tempuri.org/"">" + _
                        xmlParameters + _
                    "</" + methodName + ">" + _
                "</soap:Body>" + _
              "</soap:Envelope>"
    
    
    ' Open the webservice
    Set HttpRequest = New WinHttpRequest
    HttpRequest.setTimeouts 0, 60000, 30000, 120000
    HttpRequest.open "POST", url, False
    
    ' Create headings
    HttpRequest.setRequestHeader "Content-Length", Format(Len(XmlBody))
    HttpRequest.setRequestHeader "Content-Type", "text/xml; charset=utf-8"
    HttpRequest.setRequestHeader "SOAPAction", "http://tempuri.org/" + methodName
    
    ' Send XML command
    HttpRequest.send XmlBody

    ' Get all response text from webservice
    strRet = HttpRequest.responseText
    
    ' Close object
    Set HttpRequest = Nothing
    
    ' Extract result that is in the form
    '   <?xml version="1.0" encoding="utf-8"?>
    '   <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    '       <soap:Body>
    '           <SetStatusNoteStateResponse xmlns="http://tempuri.org/">
    '               <SetStatusNoteStateResult>Text that will be returned</SetStatusNoteStateResult>
    '           </SetStatusNoteStateResponse>
    '       </soap:Body>
    '   </soap:Envelope>
    intPos1 = InStr(strRet, "<" + methodName + "Result>")
    intPos2 = InStr(strRet, "</" + methodName + "Result>")
    If intPos1 > 0 And intPos2 > 0 Then
        intPos1 = InStr(intPos1, strRet, ">") + 1
        CallWebMethod = Mid(strRet, intPos1, intPos2 - intPos1)
    End If
    
Exit Function
CallWebMethod_Err:
   popmessagecr "", "A problem occurred trying to access web method " & methodName & crlf & crlf & "Error : " & Format$(Err.Number) & " Description : " & Err.Description
End Function
Function getCrystalFilefromSQL(ByRef strReportName As String) As String
'10Nov16 TH Written for Hosted Enhancements to store Crystal Rpt file in DB (TFS 157972)
'28Nov16 TH Added provision to replace any local cached file (redeploy option)
'14Dec16 TH changed strReportName to byref as from comments looks like this may be used outside

Dim rs As ADODB.Recordset
Dim strParams As String
Dim strFilename As String
Dim strReport As String
Dim stream As ADODB.stream
Set stream = New ADODB.stream
Dim lErrNo As Long
Dim sErrDesc As String
Dim blnCreateLocalFile As Boolean 'Flag to begin process of reading report from DB and creating local copy


   On Error GoTo ErrorHandler
   
   getCrystalFilefromSQL = ""
   
   If (InStr(LCase(strReportName), ".rpt") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   
   strReport = GetLocalFilePath() & strReportName & "_" & SiteNumber & ".rpt"
 
   If fileexists(strReport) Then
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "N", "CrystalDBReportsReload", 0)) Then
         Kill strReport
         blnCreateLocalFile = True
      Else
         strReportName = strReport
      End If
   Else
      blnCreateLocalFile = True
   End If
       
   If blnCreateLocalFile Then
      'Read from the DB and create locally
      stream.Type = adTypeBinary
      
      If Left$(strReportName, 1) = "\" Then strReportName = Right(strReportName, Len(strReportName) - 1)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strReportName)
                  
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyCrystalReportSelectbySiteandName", strParams)
      
      strReportName = "" '24Nov16 TH ensure this is used to flag that no report is available.
      
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               'strFileCOntents = RtrimGetField(rs!Value)
               'If Not fileexists(GetLocalFilePath & "\" & strReportName & "_" & SiteNumber) Then 'Dont Bother if we already have one
                  'MakeLocalFile strFile ' Dont think we need this if the stream cna write directly
                  stream.open
                  stream.Write rs!Report
                  stream.SaveToFile strReport, adSaveCreateOverWrite
                  stream.Close
                  strReportName = strReport
                  
               'End If
            End If
         End If
      End If
      rs.Close
      Set rs = Nothing
   End If
   getCrystalFilefromSQL = strReportName
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   stream.Close
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, "GetCrystalFileFromSQL", sErrDesc
   End If
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function
Public Function GetLocalFilePath() As String
'10Nov16 TH Written for Hosted Enhancements to store Crystal Rpt file in DB (TFS 157972)
'           This from Makelocalfile, however because some of this is used in the actual file name there, its
'           mostly copied and independent, not suitable for easy replacement.
'25May17 TH Made public to allow use from Toolbar stuff
Dim strDrvpth As String
Dim strTerminalName As String


   strDrvpth = "c:"
   strDrvpth = terminal$("LocalFilePath", strDrvpth)
   
   strTerminalName = ASCTerminalName()
   replace strTerminalName, " ", "", 0                    'remove ' \/:*?"<>|¦.'
   replace strTerminalName, "\", "", 0
   replace strTerminalName, "/", "", 0
   replace strTerminalName, ":", "", 0
   replace strTerminalName, "*", "", 0
   replace strTerminalName, "?", "", 0
   replace strTerminalName, Chr$(34), "", 0               'quotes "
   replace strTerminalName, "<", "", 0
   replace strTerminalName, ">", "", 0
   replace strTerminalName, "|", "", 0
   replace strTerminalName, "¦", "", 0
   replace strTerminalName, ".", "", 0
   If Len(strTerminalName) = 0 Then strTerminalName = "DEFAULT"

   replace strDrvpth, "%TERMINAL%", strTerminalName, True   'case insensitive replace
   
   If Right$(strDrvpth, 1) = "\" Then strDrvpth = Left$(strDrvpth, Len(strDrvpth) - 1)
   
   GetLocalFilePath = strDrvpth

End Function

Function getPharmacyRTFfromSQL(ByVal strFilePath As String, ByVal strReportName As String) As String
'14Dec16 TH Written for Hosted Enhancements to store RTF file in DB (TFS 157969)
'           THis is used for IO operations rather than the main template reads
'10Jan17 TH Extended to use pil files
'02Feb17 TH use file path NOT filename to generate prefix (TFS 175462)
'10Feb17 TH No longer need to remove trailing crlf - was an artefact of the method used to convert the rtf files (TFS 176550)
'13Feb17 TH Mod to remove filename from file path - this was interfering with prefix(sub folder) handling (TFS 175775)
'15Feb17 TH Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders) (TSF 177159)

Dim rs As ADODB.Recordset
Dim strParams As String
Dim strReport As String
Dim lErrNo As Long
Dim sErrDesc As String
Dim strResult As String

   On Error GoTo ErrorHandler
   
   strResult = ""
   getPharmacyRTFfromSQL = ""
   
   '13Feb17 TH Added Section (TFS 175775)
   If InStr(strFilePath, strReportName) > 1 Then
      'remove the report from here - this was being factored incorrectly into category below
      strFilePath = Left$(strFilePath, InStr(strFilePath, strReportName) - 1)
   End If
   If Right(strFilePath, 1) <> "\" Then strFilePath = strFilePath & "\" '15Feb17 TH To tighten check below
   
   If (InStr(LCase(strReportName), ".rtf") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   If (InStr(LCase(strReportName), ".pil") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   
   If Left$(strReportName, 1) = "\" Then strReportName = Right(strReportName, Len(strReportName) - 1)
   
   
   '15Feb17 TH Reworked below to tighten this up (incase the URL had conflicted with the known subfolders) (TFS 177159)
   'If InStr(LCase$(strFilePath), "\wksheets\draft") > 0 Then
   If Right$(LCase$(strFilePath), 16) = "\wksheets\draft\" Then
     strReportName = "WRKSHEET|DRAFT|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets\archive") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets\archive") > 0 Then  '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 18) = "\wksheets\archive\" Then
     strReportName = "WRKSHEET|ARCHIVE|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets") > 0 Then  '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 10) = "\wksheets\" Then
     strReportName = "WRKSHEET|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\pil") > 0 Then  '09Jan17 TH Added to support PIL printing from DB
   'ElseIf InStr(LCase$(strFilePath), "\pil") > 0 Then  '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 5) = "\pil\" Then
     strReportName = "PIL|" & strReportName
   End If
       
   
      
   If Trim$(strReportName) <> "" Then 'No point in reading if we have no report
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strReportName)
                  
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyRTFReportSelectbySiteandName", strParams)
      
      strReportName = ""
      
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               strResult = GetField(rs!Report)
               '10Feb17 TH This is no longer required - was an artefact of the method used to convert the rtf files (TFS 176550)
               'If Len(strResult) > 2 Then '15Jan17 TH Added section to ensure DB rtf is correct (was appending crlf)
               '   If Right$(strResult, 2) = crlf Then strResult = Left(strResult, Len(strResult) - 2)
               'End If
            End If
         End If
      End If
      rs.Close
      Set rs = Nothing
   End If
   
   getPharmacyRTFfromSQL = strResult
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, "GetPharmacyRTFfromSQL", sErrDesc
   End If
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function

Function WritePharmacyRTFToSQL(ByVal strFilePath As String, ByVal strReportName As String, ByVal strRTF As String) As Long
'14Dec16 TH Written for Hosted Enhancements to store RTF files in DB (TFS 157972)
'10Jan17 TH Added PIL, but limitation is that we cannot duplicat .pil and .rtf "file" names in asme logical location
'           I believe this is OK at present as pils are handled in there own "area"
'02Feb17 TH use file path NOT filename to generate prefix (TFS 175462)
'03Feb17 TH Not sure why but generate system error if set length of varcharmax field to zero, so added cheap fix to set to 1 for blank string (as -1 wouldnt work either) (TFS 175260)
'14Feb17 TH Added Section to fix PIL handling (TFS 177159)
'15Feb17 TH Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders (TFS 177159)

Dim rs As ADODB.Recordset
Dim strParams As String
Dim strReport As String
Dim lErrNo As Long
Dim sErrDesc As String
Dim lngResult As Long
Dim extraAddedFont As String
Dim startPosition As Integer
Dim totalCharacter As Integer

   On Error GoTo ErrorHandler
   lngResult = 0
   
   'Start: Bug 250758 - Remove default font insert in txtextcontrol rtf
   startPosition = 0
   totalCharacter = 0
   If InStr(1, strRTF, "Symbol;}}") > 58 Then
    If Mid(strRTF, (InStr(1, strRTF, "Symbol;}}")) - 58, 2) = "\f" Then
       startPosition = 61
       totalCharacter = 69
    Else
       startPosition = 62
       totalCharacter = 70
    End If
    If startPosition > 0 Then
       extraAddedFont = Mid(strRTF, (InStr(1, strRTF, "Symbol;}}")) - startPosition, totalCharacter)
       replace strRTF, extraAddedFont, "", 0
    End If
   End If
   'End: Bug 250758 - Remove default font insert in txtextcontrol rtf
   
   '14Feb17 TH Added Section (TFS 177159)
   If InStr(strFilePath, strReportName) > 1 Then
      'remove the report from here - this was being factored incorrectly into category below
      strFilePath = Left$(strFilePath, InStr(strFilePath, strReportName) - 1)
   End If
   If Right(strFilePath, 1) <> "\" Then strFilePath = strFilePath & "\" '15Feb17 TH To tighten check below (TFS 177159)
   
   If (InStr(LCase(strReportName), ".rtf") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   If (InStr(LCase(strReportName), ".pil") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   
   If Left$(strReportName, 1) = "\" Then strReportName = Right(strReportName, Len(strReportName) - 1)
   
   '15Feb17 TH Reworked below to tighten this up (incase the URL had conflicted with the known subfolders) (TFS 177159)
   'If InStr(LCase$(strFilePath), "\wksheets\draft") > 0 Then
   If Right$(LCase$(strFilePath), 16) = "\wksheets\draft\" Then
     strReportName = "WRKSHEET|DRAFT|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets\archive") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets\archive") > 0 Then  '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 18) = "\wksheets\archive\" Then
     strReportName = "WRKSHEET|ARCHIVE|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets") > 0 Then   '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 10) = "\wksheets\" Then
     strReportName = "WRKSHEET|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\pil") > 0 Then  '09Jan17 TH Added to support PIL printing from DB
   'ElseIf InStr(LCase$(strFilePath), "\pil") > 0 Then  '02Feb17 TH Replaced above - shd be testing path NOT filename (TFS 175462)
   ElseIf Right$(LCase$(strFilePath), 5) = "\pil\" Then
     strReportName = "PIL|" & strReportName
   End If
       
   
      
   If Trim$(strReportName) <> "" Then 'No point in reading if we have no report
      '03Feb17 TH Not sure why but generate system error if set length of varcharmax field to zero, so added cheap fix to set to 1 for blank string (as -1 wouldnt work either) (TFS 175260)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strReportName) & _
                  gTransport.CreateInputParameterXML("Report", trnDataTypeVarChar, Iff(Len(strRTF) > 0, Len(strRTF), 1), strRTF) & _
                  gTransport.CreateInputParameterXML("Update", trnDataTypeDateTime, 8, Now)
      lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyRTFReportWrite", strParams)
      
   End If
   
   WritePharmacyRTFToSQL = lngResult
   
Cleanup:
   'On Error Resume Next
   
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, "WritePharmacyRTFToSQL", sErrDesc
   End If
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function
Sub GetRTFTextFromDB(ByVal strPathfileext As String, ByRef strText As String, ByRef blnSuccess As Integer, Optional ByRef blnSilent As Boolean = False)
'Reads RTF from DB based on old RTF file reader,hence slightly odd API
'Returns success=T/F
'06Dec16 TH Written as replacement for GetTextFile For Hosted RTF templates
'           Currently uses only the global siteID in reference.
'06Jan17 TH Added sub directory handling
'06Feb17 TH Added Optional param to suppress msg when rtf not found. THis is because this sub was used to replace (amongst other things)
'           the #include handling from parsertf - which will silently return nothing if the file specified does not exist
'           This was causing a problem for embedded draft methods in draft worksheets. (TFS 175148)
'10Feb17 TH No longer need to remove trailing crlf - was an artefact of the method used to convert the rtf files (TFS 176550)
'14Feb17 TH Added Section to fix PIL handling (TFS 177159)
'15Feb17 TH Reworked logic to tighten this up (incase the URL had conflicted with the known subfolders) (TFS 177159)

Dim strFilename As String
Dim strParams As String
Dim rsRTF As ADODB.Recordset
Dim blnFailed As Boolean
Dim strPrefix As String

   If TrueFalse(TxtD(dispdata$ & "\Siteinfo.ini", "Defaults", "N", "UseRTFFiles", 0)) Then 'If we are using file shares then go to old sub
      GetTextFile strPathfileext, strText, blnSuccess
   Else
      blnFailed = False
      If InStr(strPathfileext, ".") > 0 Then
         If Right(Trim$(LCase$(strPathfileext)), 4) <> ".rtf" Then
            'popmessagecr "", "GetRTFTextFromDB Called for None rtf File. RTF Text could not be loaded"
            If Not blnSilent Then popmessagecr "", "GetRTFTextFromDB Called for None rtf File. RTF Text could not be loaded" '06Feb17 Replaced above for "silent running" (TFS 175148)
            blnFailed = True
         End If
      
      End If
      blnSuccess = False
      On Error GoTo GetRTFTextFromDB_Err
      If Not blnFailed Then
         'First we need to derive the filename for the DB Layer (no extension - this is for .rtf only)
         strFilename = GetFileNameFromPath(strPathfileext)
         
         '14Feb17 TH Added Section (TFS 177159)
         If InStr(strPathfileext, strFilename) > 1 Then
            'remove the report from here - this was being factored incorrectly into category below
            strPathfileext = Left$(strPathfileext, InStr(strPathfileext, strFilename) - 1)
         End If
         If Right(strPathfileext, 1) <> "\" Then strPathfileext = strPathfileext & "\" '15Feb17 TH To tighten check below (TFS 177159)
         
         'remove extension
         If (Right$(LCase$(Trim$(strFilename)), 4) = ".rtf") Then strFilename = Left$(strFilename, Len(strFilename) - 4)
         
         strPrefix = ""
      
         '15FEb17 TH Reworked logic to further tighten handling of subfolders (TFS 177159)
         'If InStr(LCase$(strPathfileext), "\wksheets\draft") > 0 Then
         If Right$(LCase$(strPathfileext), 16) = "\wksheets\draft\" Then
           strPrefix = "WRKSHEET|DRAFT|"
         'ElseIf InStr(LCase$(strPathfileext), "\wksheets\archive") > 0 Then
         ElseIf Right$(LCase$(strPathfileext), 18) = "\wksheets\archive\" Then
           strPrefix = "WRKSHEET|ARCHIVE|"
         'ElseIf InStr(LCase$(strPathfileext), "\wksheets") > 0 Then
         ElseIf Right$(LCase$(strPathfileext), 10) = "\wksheets\" Then
           strPrefix = "WRKSHEET|"
         'ElseIf InStr(LCase$(strPathfileext), "\pil") > 0 Then  '14Feb17 TH Added for PIL handling (TFS 177159)
         ElseIf Right$(LCase$(strPathfileext), 5) = "\pil\" Then
           strPrefix = "PIL|"
         End If
         strFilename = strPrefix & strFilename
      
         Set rsRTF = New ADODB.Recordset
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, Len(strFilename), strFilename)
         
         Set rsRTF = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyRTFReportSelectbySiteandName", strParams)
         
         If rsRTF.EOF Then
             'popmessagecr "!", "Failed to find report '" + strFilename + "'. Might need to be converted from old v8 file."
             If Not blnSilent Then popmessagecr "!", "Failed to find report '" + strFilename + "'. Might need to be converted from old v8 file." '06Feb17 Replaced above for "silent running" (TFS 175148)
         Else
             strText = RtrimGetField(rsRTF!Report)
             '10Feb17 TH This is no longer required - was an artefact of the method used to convert the rtf files (TFS 176550)
             ''If Len(strText) > 2 Then '15Jan17 TH Added section to ensure DB rtf is correct (was appending crlf)
             ''  If Right$(strText, 2) = crlf Then strText = Left(strText, Len(strText) - 2) '& "  " '10Feb17 TH Added replace to stop striprtf taking the last }
             ''End If
             blnSuccess = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rsRTF.Close
   Set rsRTF = Nothing

   On Error GoTo 0
Exit Sub

GetRTFTextFromDB_Err:
Resume Cleanup

End Sub

Function GetFileNameFromPath(ByVal strFullPath As String) As String


   GetFileNameFromPath = Right(strFullPath, Len(strFullPath) - InStrRev(strFullPath, "\"))
   
   
End Function
Function RTFExistsInDatabase(ByVal strFilePath As String) As Boolean
'10Jan17 TH Written for Hosted Enhancements to store RTF file in DB (TFS 157969)
'           THis is used as a replacement for fileexists. WE only want to know here if the rtf file is in the DB
'           This is extended to handle PIL files too (N.B. As a limitation of this we cannot now
'           duplicate .PIL and .RTF "files" in the same logical location !!)
'08Feb17 TH Use full path when resolving prefix for sub folders (TFS 176132,176137)
'14Mar17 TH ensure path and file arent conflicted (TFS 179340)

Dim rs As ADODB.Recordset
Dim strParams As String
Dim strReport As String
Dim lErrNo As Long
Dim sErrDesc As String
Dim strReportName As String

Dim lngResult As Long

   On Error GoTo ErrorHandler
   
   lngResult = 0
   strFilePath = Trim$(strFilePath)
   If (Right$(LCase(strFilePath), 4) = ".rtf") Then strFilePath = Left$(strFilePath, Len(strFilePath) - 4)
   If (Right$(LCase(strFilePath), 4) = ".pil") Then strFilePath = Left$(strFilePath, Len(strFilePath) - 4)
   
   'If Left$(strFilePath, 1) = "\" Then strFilePath = Right(strFilePath, Len(strFilePath) - 1)
   
   strReportName = GetFileNameFromPath(strFilePath)
   
   If InStr(LCase$(strFilePath), "\wksheets\draft") > 0 Then
     strReportName = "WRKSHEET|DRAFT|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets\archive") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets\archive") > 0 Then '08Feb17 TH Use full path
   ElseIf InStr(LCase$(strFilePath), "\wksheets\archive\") > 0 Then '14Mar17 TH ensure path and file arent conflicted (TFS 179340)
     strReportName = "WRKSHEET|ARCHIVE|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\wksheets") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\wksheets") > 0 Then  '08Feb17 TH Use full path
   ElseIf InStr(LCase$(strFilePath), "\wksheets\") > 0 Then  '14Mar17 TH ensure path and file arent conflicted (TFS 179340)
     strReportName = "WRKSHEET|" & strReportName
   'ElseIf InStr(LCase$(strReportName), "\pil") > 0 Then
   'ElseIf InStr(LCase$(strFilePath), "\pil") > 0 Then   '08Feb17 TH Use full path
   ElseIf InStr(LCase$(strFilePath), "\pil\") > 0 Then   '14Mar17 TH ensure path and file arent conflicted (TFS 179340)
     strReportName = "PIL|" & strReportName
   End If
       
      
   If Trim$(strReportName) <> "" Then 'No point in reading if we have no report
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strReportName)
      lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPharmacyRTFReportExists", strParams)
   End If
   
   RTFExistsInDatabase = (lngResult = 1)
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, "RTFExistsInDatabase", sErrDesc
   End If
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function

Function GetRTFUpdateDateTime(ByVal strFilePath As String, ByVal blnCheckReport As Boolean) As String
'03Feb17 TH Written for Hosted Enhancements to read RTF file from DB (TFS 175260)

Dim strFilename As String
Dim strParams As String
Dim rsRTF As ADODB.Recordset
Dim blnFailed As Boolean
Dim strPrefix As String
Dim strText As String

   GetRTFUpdateDateTime = ""
   
   blnFailed = False
   If InStr(strFilePath, ".") > 0 Then
      If Right(Trim$(LCase$(strFilePath)), 4) <> ".rtf" Then
         popmessagecr "", "GetRTFUpdateDateTime Called for None rtf File. RTF Text could not be loaded"
         blnFailed = True
      End If
   
   End If
   
   On Error GoTo GetRTFUpdateDateTime_Err
   If Not blnFailed Then
      'First we need to derive the filename for the DB Layer (no extension - this is for .rtf only)
      strFilename = GetFileNameFromPath(strFilePath)
      'remove extension
      If (Right$(LCase$(Trim$(strFilename)), 4) = ".rtf") Then strFilename = Left$(strFilename, Len(strFilename) - 4)
      
      strPrefix = ""
   
      If InStr(LCase$(strFilePath), "\wksheets\draft") > 0 Then
        strPrefix = "WRKSHEET|DRAFT|"
      ElseIf InStr(LCase$(strFilePath), "\wksheets\archive") > 0 Then
        strPrefix = "WRKSHEET|ARCHIVE|"
      ElseIf InStr(LCase$(strFilePath), "\wksheets") > 0 Then
        strPrefix = "WRKSHEET|"
      End If
      strFilename = strPrefix & strFilename
   
      Set rsRTF = New ADODB.Recordset
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, Len(strFilename), strFilename)
      
      Set rsRTF = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyRTFReportSelectbySiteandName", strParams)
      
      If rsRTF.EOF Then
          'popmessagecr "!", "Failed to find report '" + strFilename + "'. Might need to be converted from old v8 file."
          strText = ""  'should fail silently
      Else
          
          If blnCheckReport And RtrimGetField(rsRTF!Updated) = "" Then 'This is a switch to allow us to use a record dynamically as a reprint if necessary without having to remove and recreate the record all the time
            strText = ""
          Else
            strText = RtrimGetField(rsRTF!Updated)
            'Format the date here
          End If
      End If
   End If
   
   
   
   GetRTFUpdateDateTime = strText
Cleanup:
   On Error Resume Next
   rsRTF.Close
   Set rsRTF = Nothing

   On Error GoTo 0
Exit Function

GetRTFUpdateDateTime_Err:
Resume Cleanup

End Function
Function getBackgroundPicture(ByRef strFilename As String) As String
'24May17 TH Written for Hosted Enhancements to store pictures in DB (TFS 174888)
'28May17 TH Major work to use base64 encoding because transport layer doesnt use binary data correctly (TFS 174888)


Dim rs As ADODB.Recordset
Dim strParams As String
Dim strReport As String
Dim stream As ADODB.stream
Set stream = New ADODB.stream
Dim lErrNo As Long
Dim sErrDesc As String
Dim blnCreateLocalFile As Boolean 'Flag to begin process of reading report from DB and creating local copy
Dim strBuffer As String
Dim arrData() As Byte

   On Error GoTo ErrorHandler
   
   getBackgroundPicture = ""
   
   'If (InStr(LCase(strReportName), ".rpt") > 0) Then strReportName = Left$(strReportName, Len(strReportName) - 4)
   
   strReport = GetLocalFilePath() & "\" & SiteNumber & "_" & strFilename
 
   If fileexists(strReport) Then
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "BackGroundPicture", "N", "BackGroundPictureReload", 0)) Then
         Kill strReport
         blnCreateLocalFile = True
      Else
         strFilename = strReport
      End If
   Else
      blnCreateLocalFile = True
   End If
       
   If blnCreateLocalFile Then
      'Read from the DB and create locally
      stream.Type = adTypeBinary
      
      If Left$(strFilename, 1) = "\" Then strFilename = Right(strFilename, Len(strFilename) - 1)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 256, strFilename)
                  
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyImageSelectbySiteandName", strParams)
      
      strFilename = "" '24Nov16 TH ensure this is used to flag that no report is available.
      
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               'strFileCOntents = RtrimGetField(rs!Value)
               'If Not fileexists(GetLocalFilePath & "\" & strReportName & "_" & SiteNumber) Then 'Dont Bother if we already have one
                  'MakeLocalFile strFile ' Dont think we need this if the stream can write directly
                  stream.open
                  'We need to decode the image here
                  strBuffer = rs!Image
                  arrData() = DecodeBase64(strBuffer)
                  stream.Write arrData() 'Base64Decode(strBuffer)
                  stream.SaveToFile strReport, adSaveCreateOverWrite
                  stream.Close
                  strFilename = strReport
                 
               'End If
            End If
         End If
      End If
      rs.Close
      Set rs = Nothing
   End If
   getBackgroundPicture = strFilename
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   stream.Close
   On Error GoTo 0
   
   Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function
Public Function encodeBase64(ByRef arrData() As Byte) As String

    '28May17 TH Use standard encoding / decoding routines

    Dim objXML As MSXML2.DOMDocument
    Dim objNode As MSXML2.IXMLDOMElement

    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument

    ' byte array to base64
    Set objNode = objXML.createElement("b64")
    objNode.datatype = "bin.base64"
    objNode.nodeTypedValue = arrData
    encodeBase64 = objNode.text

    Set objNode = Nothing
    Set objXML = Nothing



End Function

Public Function DecodeBase64(ByVal strData As String) As Byte()

    '28May17 TH Use standard encoding / decoding routines


    Dim objXML As MSXML2.DOMDocument
    Dim objNode As MSXML2.IXMLDOMElement
    
    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument
    Set objNode = objXML.createElement("b64")
    objNode.datatype = "bin.base64"
    objNode.text = strData
    DecodeBase64 = objNode.nodeTypedValue
    
    Set objNode = Nothing
    Set objXML = Nothing

End Function

'START :  'AS : MS_Edge_Fix for modal windows without an owner form
Public Sub SetOwnerForm(Optional ByVal HandlerForm As Object = "")

On Error GoTo msg:
Set OwnerForm = Nothing
If Not HandlerForm Is Nothing Then
Set OwnerForm = HandlerForm
End If
Exit Sub
msg:
MsgBox (Err.Description)

End Sub

Public Sub ResetOwnerForm()

    Set OwnerForm = Nothing
    
End Sub

'END :  'AS : MS_Edge_Fix for modal windows without an owner form


'START : SP - MM-9813 10.23 - another application in focus when printing in pharmacy
Public Sub MinimizeAllApplication()

Dim lHwnd As Long
lHwnd = FindWindowEx(0, 0, "Shell_TrayWnd", vbNullString)
Call PostMessage(lHwnd, WM_COMMAND, MINAPP, 0&)

End Sub
'END : SP - MM-9813 10.23 - another application in focus when printing in pharmacy








