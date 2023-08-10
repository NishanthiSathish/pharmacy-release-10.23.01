Attribute VB_Name = "HIGHASC"
'-------------------------------------------------------------------------------
' High Edit support routines & constants
'
' 7Oct96 CKJ/EAC Moved routines from Formula/TPN
'            Get/PutTextfile and HEdit released for limited use
'16Oct96 CKJ WinHelp contants moved to Corelib
'16Oct96 CKJ HEdit: Force loading of form before using hWnd
' 8Nov96 CKJ/EAC Many extras added - header/footer, editing menu etc
'                Uses HELoadDoc instead of HEPasteRTF - allows head/foot & >32K
' 9Nov96 CKJ Added .BMP support
'            HEdit: Actions 10,11,12,13 added - provide filename containing RTF
'            HEdit: Action 0 added, view only
'17Dec96 CKJ Moved GetTextFile and PutTextFile to Corelib
'26Mar97 KR  Commented out all declares & constants not reference to decrease
'            the size of the vb symbol table - no problems saving code in environment.
' 5Aug97 CKJ Reinstated file format constants
'            Added plain text option to Hedit: Add 100 to existing actions
'29Oct97 CKJ Added extra menu options, with lookups to external files
'             Actions 1000 to 1004 defined. Procs ReplaceSelText & DisplayPlainFile added
'15Dec97 CKJ Removed IDYES as now in corelib
'14Jan98 CKJ A raft of new procedures added, all to handle print contexts
'            These allow specific printers to be chosen for each task, on each terminal
'            Once chosen these are stored in terminal.ini, and can be edited later.
'            Major procs are; HEdit   - actions xx4, plus force loading/unloading
'             EditPrintContexts       - allows changes to local or system settings
'             EditContextDescriptions - comment text displayed to the user is cusomisable
'             ParseThenPrint          - Parse RTF file based on gPRNheapID and Print Context
'            Use /HeapDebug to see the heap before ParseThenPrint
'            Use /HEdemo to see print preview instead of printing, in Hedit actions 4 & 14
' 3Mar98 CKJ ParseThenPrint: Extended to allow layout files >32K (eg containing a logo),
'            and to allow the inclusion of fully formatted files also of >32K (formatted
'            meaning that no [xxx] entries will be parsed, the whole file is passed unchanged)
'17Mar98 CKJ ChooseDevice: Added Unload LstBoxFrm to prevent recursive usage
'02Jul98 CFY Hiedit: New functionality added to either display or print the name of the .rtf file if
'            hiedit due to the fact the file is missing.
'20Aug98 CFY ParseThenPrint: Extra functionality added to enable reprinting of last RTF file printed using this
'            routine. This is done by renaming the temporary local file after printing to a
'            pre-determined file name defined with the constant CReprintFile. The file can then
'            be re-printed by calling this routine with <reprint> as the File$ parameter.
'28Oct98 CKJ Merged from V: 09Oct98 CKJ ParseRTF: Added checks for [ without ] and for [...[...], which caused an
'            infinite loop and an out of memory error respectively.
'30Jun99 CFY ParseThenPrint: Reserved context 'SCREEN' added which when encountered print previews to screen.
'17Sep99 AE  Declared HE API procedures for use with new clinical summary form
'            HiTable: written to provide basic support to produce tables from code
'27Nov01 CKJ Added facility to defer printing.
'            HEdit goes through the motions of printing including setting up reprints,
'            however it queues work in local files until the work is released later in the same program.
'            DeferredPrinting written. Takes Action parameter to clear queue, add to queue, print queue.
'            DeferredPrintingActive written. returns state of deferred printing as T/F
'05Dec01 CKJ DeferredPrinting: Fault corrected: Action 2 must set DeferredPrinting inactive before HEdit is called
'10Dec01 CKJ DeferredPrinting: Allow activation by Site or Terminal. Terminal.ini DeferredPrinting="Y"  Y/N/T/F/1/0/-1 default="N"
'10Dec01 CKJ HEdit: Modified deferred printing to avoid re-saving from inside HE. Added filetype to the stored context
'            DeferredPrinting: Added file type to the context string, since the file is not always RTF now.
'11Jan02 TH  ChooseDevice: Stop GPF on cancel when asked to choose printer (#54984)
'29sep03 CKJ Allow printing demo mode from ascribe.ini [] HEdemo=Y
'15oct03 CKJ removed constant CReprintfile. Now a function.
'30Mar04 CKJ {SP1}
'01Mar06 CKJ OverrideLayout: Added
'            HEdit: OverrideLayout used
'
'20May08 CKJ ParseThenPrint: Added Rowa label confirmation exchange & set param copies ByVal
'25Mar10 CKJ Added Citrix override - allow NExx: to be changed to NEyy: for the same printer name and driver  (RCN P0007 F0081840)
'            FindPrinterFromContext: Removed obsolete procedure
'31Mar10 CKJ/TH DeferredPrintingLog and SetSpecifiedPrinter log added (for restricted debug use only) [RCN P0007 F0078120]
'15Dec10 CKJ Merged external print job                         (RCN P0573 F0104170 10.5 branch)
'              17Sep10 CKJ Support for external print job added.
'              28Sep10 CKJ Updated to add messages & longer, configurable timeout
'            External printing default is now "Y"
'            ConditionalMessage: Added log of failed external print calls & extra param
'            ExecBlockingCommand: added error handler
'            HEdit: changed writelog from generic DeferredPrinting to ExternalPrint
'25Jun12 CKJ ParseThenPrint: Now removes temp file if no reprint needed       TFS37032
'03Jan17 TH  ParseRTFFromDB: Written based on ParseRTF
'            It still uses a local file to output to, but reads rtf from the DB
'10Jan17 TH  EditRTFFromDB: Created new wrapper for editing rtf in Db (Hosted)
'24Jan17 TH  ParseRTFFromDB: Convert chunk counter to long for calculation (TFS 174587)
'30Jan17 TH  EditRTFFromDB: Added Logging (For PN editors) (TFS 174973)
'02Feb17 TH  ParseRTFFromDB: Added section to allow inclusion of local file (not from DB) on #includx (TFS 175474)
'                            This is a bit of a sticking plaster to handle some local data handling on the alternative label
'                            List report (TFS 175474)
' 06Feb17 TH ParseRTFFromDB: Added silent running setting for DB #include for backward compatibility (TFS 175148)
' 06Feb17 TH parseRTFFromDBFromAdditionalHeap: Added silent running setting for DB #include for backward compatibility (TFS 175148)
' 25Jly19 AS Start : 249720 - Free format label Alignment issue
'
'Mods needed
'-----------
'/Remove unnecessary constants below
' add error checking
' unify the interface to the highedit form - 'exit' as a tag is non-standard
'/amend the highedit form - two Alt-F menus items
'                         - exit should be cleaner
'/use the HEIsModified flag to decide if saving is needed
'
'-------------------------------------------------------------------------------
'GetTextfile DISPDATA$ & "\anyfile.rtf", txt$, dummy%
'
'Do
'   Changed = False
'   ParseDataItems txt$, Changed
'   ParseCtrlChars DISPDATA$ + aninifile$, "", txt$, Changed
'   ParseCtrlChars DISPDATA$ + "\printer.ini", "RTF", txt$, Changed
'Loop While Changed
'
'HEdit 3, txt$       'print it


'GetTextfile DISPDATA$ & "\anyfile.rtf", txt$, dummy%
'txtwas$ = txt$
'HEdit 1, txt$       'view and edit it
'If txt$ <> txtwas$ Then
'      PutTextfile DISPDATA$ & "\anyfile.rtf", txt$, dummy%
'   End If
'-----------------------------------------------------------------------------
DefInt A-Z
Option Explicit

'17Sep10 CKJ Added for ExecBlockingCommand
Private Type STARTUPINFO
   cb As Long
   lpReserved As String
   lpDesktop As String
   lpTitle As String
   dwX As Long
   dwY As Long
   dwXSize As Long
   dwYSize As Long
   dwXCountChars As Long
   dwYCountChars As Long
   dwFillAttribute As Long
   dwFlags As Long
   wShowWindow As Integer
   cbReserved2 As Integer
   lpReserved2 As Long
   hStdInput As Long
   hStdOutput As Long
   hStdError As Long
End Type

Private Type PROCESS_INFORMATION
   hProcess As Long
   hThread As Long
   dwProcessID As Long
   dwThreadID As Long
End Type

Private Declare Function CreateProcess Lib "kernel32" Alias "CreateProcessA" ( _
   ByVal lpApplicationName As String, ByVal lpCommandLine As String, ByVal lpProcessAttributes As Long, _
   ByVal lpThreadAttributes As Long, ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, _
   ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As String, lpStartupInfo As STARTUPINFO, _
   lpProcessInformation As PROCESS_INFORMATION) As Long

Private Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
'Private Declare Function GetExitCodeProcess Lib "kernel32" (ByVal hProcess As Long, lpExitCode As Long) As Long

'Private Const IDLE_PRIORITY_CLASS = &H40&
Private Const NORMAL_PRIORITY_CLASS = &H20&
'Private Const HIGH_PRIORITY_CLASS = &H80&
'Private Const REALTIME_PRIORITY_CLASS = &H640&

'Timeout param for WaitForSingleObject()
'Private Const INFINITE = -1&
'Return codes from WaitForSingleObject()
Private Const WAIT_ABANDONED = &H80&      'The specified object is a mutex object that was not released by the thread that owned the mutex object before the owning thread terminated. Ownership of the mutex object is granted to the calling thread and the mutex state is set to nonsignaled. If the mutex was protecting persistent state information, you should check it for consistency.
Private Const WAIT_OBJECT_0 = &H0&        'The state of the specified object is signaled.
Private Const WAIT_TIMEOUT = &H102&       'The time-out interval elapsed, and the object's state is nonsignaled.
Private Const WAIT_FAILED = &HFFFFFFFF    'The function has failed. To get extended error information, call GetLastError.
'--- end 17Sep10 CKJ

Dim mnuInfo$() '28Oct97 CKJ (0,)=Action, (1,)=Title, (2,)=Filename
               '            (,1)=Index

'---------------------
' Language Definitions
'---------------------
'Global actlanguage As Integer
'Global Const LANGUAGE_GERMAN = 0
'Global Const LANGUAGE_ENGLISH = 1

'----------
' OpenFile
'----------
'27Mar97 KR Removed
'Global Const OF_READ = &H0
'Global Const OF_WRITE = &H1
''Global Const OF_READWRITE = &H2            '01Mar06 CKJ removed
'Global Const OF_SHARE_COMPAT = &H0
'Global Const OF_SHARE_EXCLUSIVE = &H10
'Global Const OF_SHARE_DENY_WRITE = &H20
'Global Const OF_SHARE_DENY_READ = &H30
''Global Const OF_SHARE_DENY_NONE = &H40     '01Mar06 CKJ removed
'Global Const OF_PARSE = &H100
'Global Const OF_DELETE = &H200
'Global Const OF_VERIFY = &H400
'Global Const OF_SEARCH = &H400
'Global Const OF_CANCEL = &H800
''Global Const OF_CREATE = &H1000            '01Mar06 CKJ removed
'Global Const OF_PROMPT = &H2000
'Global Const OF_EXIST = &H4000
'Global Const OF_REOPEN = &H8000

'Global Const OF_DEFHESAVE = OF_CREATE + OF_READWRITE + OF_SHARE_DENY_NONE

'---------
' Printing
'---------
'27Mar97 KR Removed
'Global Const PRINT_END = 0
'Global Const PRINT_START = 1
'Global Const PRINT_FULLDOCUMENT = 4
'Global Const PRINT_INSERTDOCUMENT = 5
'Global Const PRINT_FULLDOCUMENTABORTDLG = 7

'---------
' Style
'---------
'27Mar97 KR Removed
'Global Const ATTR_STANDARD = 0
'Global Const ATTR_BOLD = 1
'Global Const ATTR_UNDERLINE = 2
'Global Const ATTR_ITALIC = 4
'Global Const ATTR_STRIKEOUT = 8
'Global Const ATTR_SUBSCRIPT = 16
'Global Const ATTR_SUPERSCRIPT = 32

'Global Const CURRENT_ATTRIBUTE = 255

'------------------
' Font Name Length
'------------------
'27Mar97 KR Removed
'Global Const LF_FACESIZE = 32

'-----------
' Font Mode
'-----------
'27Mar97 KR Removed
'Global Const FONT_TYP = &HF

'Global Const FONT_DISPLAY = &H0
'Global Const FONT_PRINTER = &H1
'Global Const FONT_LOGICAL = &H2

'Global Const FONT_SET = &HF0

'Global Const FONT_SET_NONE = &H0
'Global Const FONT_SET_STYLE = &H10
'Global Const FONT_SET_COLOR = &H20
'Global Const FONT_SET_NAME = &H40
'Global Const FONT_SET_SIZE = &H80

'Global Const FONT_SET_ALL = FONT_SET_STYLE + FONT_SET_COLOR + FONT_SET_NAME + FONT_SET_SIZE

'------------
' Field Types
'------------
'Global Const TYP_TEXT = 0
'Global Const TYP_BITMAP = 6
'Global Const TYP_USER = 10
'
'Global Const TYP_SHAREDPF = TYP_USER + 100
'
'Global Const TYP_INTERESSENT = TYP_SHAREDPF + 10
'Global Const TYP_KUNDE = TYP_SHAREDPF + 11
'Global Const TYP_LIEFERANT = TYP_SHAREDPF + 12
'Global Const TYP_VERTRETER = TYP_SHAREDPF + 13
'Global Const TYP_NAME1 = TYP_SHAREDPF + 14
'Global Const TYP_NAME2 = TYP_SHAREDPF + 15
'Global Const TYP_STRASSE = TYP_SHAREDPF + 16
'Global Const TYP_PLZ = TYP_SHAREDPF + 17
'Global Const TYP_ORT = TYP_SHAREDPF + 18
'Global Const TYP_LAND = TYP_SHAREDPF + 19
'
'Global Const TYP_DATUM = TYP_SHAREDPF + 30
'Global Const TYP_ANGEBOTSDATUM = TYP_SHAREDPF + 31
'Global Const TYP_AUFTRAGSDATUM = TYP_SHAREDPF + 32
'Global Const TYP_LIEFERSCHEINDATUM = TYP_SHAREDPF + 33
'Global Const TYP_RECHNUNGSDATUM = TYP_SHAREDPF + 34
'Global Const TYP_BESTELLDATUM = TYP_SHAREDPF + 35
'Global Const TYP_GUTSCHRIFTDATUM = TYP_SHAREDPF + 36
'
'Global Const TYP_NUMMER = TYP_SHAREDPF + 40
'Global Const TYP_ANGEBOTSNUMMER = TYP_SHAREDPF + 41
'Global Const TYP_AUFTRAGSNUMMER = TYP_SHAREDPF + 42
'Global Const TYP_LIEFERSCHEINNUMMER = TYP_SHAREDPF + 43
'Global Const TYP_RECHNUNGSNUMMER = TYP_SHAREDPF + 44
'Global Const TYP_BESTELLNUMMER = TYP_SHAREDPF + 45
'Global Const TYP_KUNDENNUMMER = TYP_SHAREDPF + 46
'Global Const TYP_INTERESSENTENNUMMER = TYP_SHAREDPF + 47
'Global Const TYP_LIEFERANTENNUMMER = TYP_SHAREDPF + 48
'Global Const TYP_GUTSCHRIFTNUMMER = TYP_SHAREDPF + 49
'
'Global Const TYP_SEITE = TYP_SHAREDPF + 50
'Global Const TYP_ZEICHEN = TYP_SHAREDPF + 51
'Global Const TYP_UKDNR = TYP_SHAREDPF + 52
'Global Const TYP_BEARBEITER = TYP_SHAREDPF + 53
'Global Const TYP_PROJEKTEUR = TYP_SHAREDPF + 54
'Global Const TYP_ZAHLUNGSBEDINGUNG1 = TYP_SHAREDPF + 55
'Global Const TYP_LIEFERBEDINGUNG = TYP_SHAREDPF + 56
'Global Const TYP_SKONTO = TYP_SHAREDPF + 57
'Global Const TYP_ZAHLUNGSBEDINGUNG2 = TYP_SHAREDPF + 58
'Global Const TYP_TELEFON = TYP_SHAREDPF + 59
'
'Global Const TYP_SUMNETTO = TYP_SHAREDPF + 60
'Global Const TYP_SUMBRUTTO = TYP_SHAREDPF + 61
'Global Const TYP_UEBERTRAG = TYP_SHAREDPF + 62
'Global Const TYP_SEITENSUMME = TYP_SHAREDPF + 63
'Global Const TYP_SCHAETZPREIS = TYP_SHAREDPF + 64
'Global Const TYP_MWST = TYP_SHAREDPF + 65
'Global Const TYP_MWSTSATZ = TYP_SHAREDPF + 66
'Global Const TYP_FRACHT = TYP_SHAREDPF + 67
'Global Const TYP_PORTO = TYP_SHAREDPF + 68
'
'Global Const TYP_LIEFERDATUM = TYP_SHAREDPF + 70
'Global Const TYP_ARTIKEL = TYP_SHAREDPF + 71
'Global Const TYP_VERSANDART = TYP_SHAREDPF + 72
'
'Global Const TYP_LAUFKARTE = TYP_SHAREDPF + 111
'Global Const TYP_ARTIKELNR2 = TYP_SHAREDPF + 112
'Global Const TYP_LEGIERUNG = TYP_SHAREDPF + 113
'Global Const TYP_KATEGORIE = TYP_SHAREDPF + 114
'Global Const TYP_ROHDATUM = TYP_SHAREDPF + 115
'Global Const TYP_PRODDATUM = TYP_SHAREDPF + 116
'Global Const TYP_FERTIGDATUM = TYP_SHAREDPF + 117
'Global Const TYP_STUECK = TYP_SHAREDPF + 118
'Global Const TYP_GESSTUECK = TYP_SHAREDPF + 119
'Global Const TYP_GRUPPE = TYP_SHAREDPF + 120
'Global Const TYP_GRUPPENNR = TYP_SHAREDPF + 121
'Global Const TYP_STAND = TYP_SHAREDPF + 122
'Global Const TYP_FLAECHE = TYP_SHAREDPF + 123
'Global Const TYP_DATUMWE = TYP_SHAREDPF + 124
'Global Const TYP_STUECKNORM = TYP_SHAREDPF + 125
'Global Const TYP_FLAECHENORM = TYP_SHAREDPF + 126

'--------------
' Font Colors
'--------------
'27Mar97 KR Removed
'Global Const RGB_BLACK = &H0&
'Global Const RGB_BLUE = &HFF0000
'Global Const RGB_CYAN = &HFFFF00
'Global Const RGB_GREEN = &HFF00&
'Global Const RGB_MAGENTA = &HFF00FF
'Global Const RGB_RED = &HFF&
'Global Const RGB_YELLOW = &HFFFF&
'Global Const RGB_WHITE = &HFFFFFF

'Global Const RGB_DKBLUE = &H7F0000
'Global Const RGB_DKCYAN = &H7F7F00
'Global Const RGB_DKGREEN = &H7F00&
'Global Const RGB_DKMAGENTA = &H7F007F
'Global Const RGB_DKRED = &H7F&
'Global Const RGB_DKYELLOW = &H7F7F&

'Global Const RGB_GRAY = &H7F7F7F
'Global Const RGB_LTGRAY = &HC0C0C0

'Global Const CURRENT_COLOR = &HFFFFFFFF

'-----------------
' Undo Types
'-----------------
'27Mar97 KR Removed
'Global Const UNDO_NONE = -1
'Global Const UNDO_CHARINSERT = 0
'Global Const UNDO_CHARDELETE = 1
'Global Const UNDO_LINEINSERT = 2
'Global Const UNDO_BACKSPACE = 3
'Global Const UNDO_LINEDELETE = 4
'Global Const UNDO_BLOCKCUT = 5
'Global Const UNDO_BLOCKPASTE = 6
'Global Const UNDO_BLOCKCLEAR = 7

'-----------------
' Flags for Row
'-----------------
'Global Const ALIGN_MASK = 3
'
'Global Const ALIGN_LEFT = 0
'Global Const ALIGN_RIGHT = 1
'Global Const ALIGN_CENTER = 2
'Global Const ALIGN_JUSTIFY = 3
'
'Global Const LINE_VISIBLE = 4
'Global Const LINE_SOFTRETURN = 8
'Global Const LINE_HARDRETURN = 16
'Global Const LINE_FORMFEED = 32
'Global Const LINE_TABULATOR = 128
'
'Global Const SPACING_MASK = 768
'
'Global Const SPACING_ONE = 0
'Global Const SPACING_ONEHALF = 1
'Global Const SPACING_DOUBLE = 2
'
'Global Const LINE_INVISIBLEPF = 1024
'Global Const LINE_PAGINATEFF = 2048
'Global Const LINE_NOTEDITABLE = 4096

'-----------------
' Flags for Research
'-----------------
'Global Const SEARCH_FORWARD = 0
'Global Const SEARCH_CASE = 2
'Global Const SEARCH_WORD = 4
'Global Const SEARCH_CURSOR = 8
'Global Const SEARCH_BACK = 16
'Global Const SEARCH_INIT = 32
'
'Global Const SEARCH_NOTFOUND = 0
'Global Const SEARCH_FOUND = 1
'Global Const SEARCH_ERROR = 2

'---------------------
' Flags for HE_NEXTPF
'---------------------
'Global Const NEXTPF_BACKWARD = 0
'Global Const NEXTPF_FORWARD = 1
'Global Const NEXTPF_ONLYEDITABLE = 2
'Global Const NEXTPF_ONLYVISIBLE = 16
'Global Const NEXTPF_FILEENDSTOP = 32

'-------------------------
' Flags for Fields
'-------------------------
'Global Const PF_ALIGNMASK = 3
'
'Global Const PF_ALIGNLEFT = 0
'Global Const PF_ALIGNRIGHT = 1
'
'Global Const PF_EDITABLE = 4
'Global Const PF_FUNCTION = 8
'Global Const PF_VISIBLE = 32
'Global Const PF_LINEREMOVE = 64
'Global Const PF_FIXEDSIZE = 128
'Global Const PF_MULTILINE = 256

'---------------------------------------------
' Format for HEAppend-, HELoad- und HESaveDoc
'---------------------------------------------
'27Mar97 KR Removed  5Aug97 CKJ Reinstated
Global Const FILEFORMAT_HIGHEDIT = 0
Global Const FILEFORMAT_ANSI = 1
'Global Const FILEFORMAT_OEM = 2
Global Const FILEFORMAT_RTF = 3

'--------------------------
' Format for HELoadPicture
'--------------------------
'27Mar97 KR Removed
'Global Const FILEFORMAT_BITMAP = 0
'Global Const FILEFORMAT_PCX = 1
'Global Const FILEFORMAT_GIF = 2
'Global Const FILEFORMAT_TIFF = 3
'Global Const FILEFORMAT_TARGA = 4
'Global Const FILEFORMAT_WMF = 5

'----------------
' Picture Flags
'----------------
'27Mar97 KR Removed
'Global Const BMP_ERROR = &H80008000

'Global Const BMP_NONE = -1
'Global Const BMP_ORIGINAL = 0
'Global Const BMP_SCALE = 1
'Global Const BMP_KEEPRATIO = 2

'------------
' Units
'------------
Global Const UNIT_CM = 0
Global Const UNIT_IN = 1

'----------------
' Tabs
'----------------
'27Mar97 KR Removed
'Global Const TAB_LEFT = 0
'Global Const TAB_RIGHT = 1
'Global Const TAB_DECIMAL = 2
'Global Const TAB_CENTER = 3
'Global Const TAB_LEFTMARGIN = 6
'Global Const TAB_RIGHTMARGIN = 7
'Global Const TAB_INDENT = 9

'---------
' Context
'---------
'27Mar97 KR Removed
'Global Const CONTEXT_MAIN = 0
'Global Const CONTEXT_HEAD = 1
'Global Const CONTEXT_FOOT = 2

'--------------------
' Table Adjust Flags
'--------------------
Global Const TABLE_ADJUSTCOLUMNS = 1
Global Const TABLE_ADJUSTROWS = 2
Global Const TABLE_ADJUSTREDRAW = 4

Global HighEdit As New TextControlEditorPharmacyClient.TxWrapper
Global He As New TextControlEditorPharmacyClient.HeEmulator
Global UpdatedRTFfilename As String

Dim m_strHETag As String  '22Oct09 TH Added

'01Mar06 CKJ Removed reference to the VBX declarations
''   '-------------------
''   ' Export Functions
''   '-------------------
''   '26Mar97 KR Removed.
''   'Declare Function HEAppendDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEBackColorDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEColorDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEDeleteDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEDocInfoDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEFontDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEFormatDocDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HELoadDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEParagraphDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEPictureDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEPrintDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEPrintSetupDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEReplaceDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HESaveDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HESearchDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''
''   'Declare Function HEAddAllPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%, ByVal iLevel%, iTypList%) As Integer
''   'Declare Function HEAddFunctionPF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal sName$) As Integer
''   'Declare Function HEAddPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%) As Integer
''   Declare Function HEAdjustTable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%) As Integer
''   'Declare Function HEAppendDoc Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpFileName$, ByVal iFormat%) As Integer
''
''   Declare Function HECanCopy Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HECanPaste Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HECanUndo Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEChangeFunctionPF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal szNewText$) As Integer
''   'Declare Sub HECharInsert Lib "HEVB.VBX" (ByVal hWnd%, ByVal iChar%)
''   Declare Sub HEClear Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Function HEClearAllPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%, ByVal iLevel%, iTypList%) As Integer
''   'Declare Function HEClearPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%) As Integer
''   'Declare Sub HEClearUndoList Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Function HECloseActivePF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRedraw%) As Integer
''   'Declare Function HECloseActiveTable Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HECloseChild Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Sub HECopy Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Function HECopyData Lib "HEVB.VBX" (ByVal hWnd%, sHighEdit$, sText$) As Integer
''   'Declare Function HECopyDataGlobalMem Lib "HEVB.VBX" (ByVal hWnd%, iHighEdit%, iText%) As Integer
''   'Declare Function HECopyRTF Lib "HEVB.VBX" (ByVal hWnd%, sRTF$) As Integer
''   'Declare Function HECopyRTFGlobalMem Lib "HEVB.VBX" (ByVal hWnd%, iRTF%) As Integer
''   'Declare Sub HECursorEnd Lib "HEVB.VBX" (ByVal hWnd%)
''   Declare Sub HECursorHome Lib "HEVB.VBX" (ByVal hWnd%)
''   Declare Sub HECut Lib "HEVB.VBX" (ByVal hWnd%)
''
''   'Declare Function HEDeletePF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRedraw%) As Integer
''   Declare Function HEDeleteTableRow Lib "HEVB.VBX" (ByVal hWnd%, ByVal lRow&) As Integer
''   'Declare Sub HEDisplayStatusText Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpText$)
''
''   'Declare Sub HEEnableScreenFonts Lib "HEVB.VBX" (ByVal hWnd%, ByVal iScreenFonts%)
''   'Declare Sub HEEndSession Lib "HEVB.VBX" (ByVal hWnd%, ByVal iParam%)
''   'Declare Sub HEExtSetRedraw Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRedraw%, ByVal iUpdate%, ByVal iSaveWindow%)
''   'Declare Function HEExtInsertFunctionPF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal iFlags%, ByVal lpText$) As Integer
''
''   'Declare Sub HEFormatDoc Lib "HEVB.VBX" (ByVal hWnd%)
''
''   'Declare Sub HEGetActiveHeadFoot Lib "HEVB.VBX" (ByVal hWnd%, lphWndHead%, lphWndFoot%)
''   'Declare Function HEGetActiveHighEdit Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetActiveIconBar Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetActiveRuler Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetActiveStatusLine Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetActiveTabulator Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetAlign Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Sub HEGetChars Lib "HEVB.VBX" (ByVal hWnd%, lpiLeftChar%, lpiRightChar%)
''   'Declare Function HeGetCellFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndTable%, ByVal nFlags%, ByVal Row&, ByVal Col%, FontHeight, FontName$, FontStyle%)
''   Declare Function HeGetCellText Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndTable%, ByVal nFlags%, ByVal nRow&, ByVal nCol%, Lpsz$) As Integer
''   'Declare Function HEGetColorIndex Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetContext Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Sub HEGetCursor Lib "HEVB.VBX" (ByVal hWnd%, lpiCursorX%, lplCursorY&)
''   'Declare Function HEGetEOFChar Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetFileName Lib "HEVB.VBX" (ByVal hWnd%, hlstr$) As Integer
''   'Declare Function HEGetFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFont%, iHeight%, lRGB&, iPitch%, iFamily%, ByVal sName$) As Integer
''   'Declare Function HEGetFontHandle Lib "HEVB.VBX" (ByVal hWnd%, ByVal iIndex%, ByVal iDevice%) As Integer
''   'Declare Function HEGetFontIndex Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetFunctionPFData Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal Buffer$) As Integer
''   'Declare Function HEGetFunctionPFDataLen Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%) As Integer
''   'Declare Function HEGetFunctionPFName Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal Buffer$) As Integer
''   'Declare Function HEGetFunctionPFNameLen Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%) As Integer
''   'Declare Function HEGetFunctionPFTableCount Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetFunctionPFTyp Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%) As Integer
''   'Declare Function HEGetGlobalMemSegments Lib "HEVB.VBX" (ByVal iMem%) As Integer
''   Declare Function HEGetInstancePrinter Lib "HEVB.VBX" (ByVal hWnd%, sPrinter$, iDefault%) As Integer
''   'Declare Function HEGetLine Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpBuffer$, ByVal iMaxLen%) As Integer
''   'Declare Function HEGetLineCount Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Function HEGetLineLength Lib "HEVB.VBX" (ByVal hWnd%, ByVal lLine&) As Integer
''   'Declare Sub HEGetMargins Lib "HEVB.VBX" (ByVal hWnd%, lpiLeft%, lpiTop%)
''   'Declare Sub HEGetPage Lib "HEVB.VBX" (ByVal hWnd%, lpwTextPage%, lpwMaxPage%)
''   'Declare Function HEGetPathName Lib "HEVB.VBX" (ByVal hWnd%, lhstr$) As Integer
''   'Declare Function HEGetPFBkColor Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Function HEGetPFData Lib "HEVB.VBX" (ByVal hWnd%, ByVal sBuffer$) As Integer
''   'Declare Function HEGetPFDataLen Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetPFFlags Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetPFWidth Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Sub HEGetPhysicalDim Lib "HEVB.VBX" (ByVal hWnd%, lpiWidth%, lpiHeight%)
''   'Declare Sub HEGetPhysicalMargins Lib "HEVB.VBX" (ByVal hWnd%, lpiLeft%, lpwTop%)
''   'Declare Function HEGetPictureDim Lib "HEVB.VBX" (ByVal hWnd%, iWidth%, iHeight%) As Integer
''   'Declare Function HEGetPictureFlags Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetPictureOffset Lib "HEVB.VBX" (ByVal hWnd%, xOffset%, yOffset%) As Integer
''   'Declare Function HEGetPrinterCursorHeight Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Function HEGetPrinterDC Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetPrinterIC Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Sub HEGetPrinterDim Lib "HEVB.VBX" (ByVal hWnd%, lpiWidth%, lpwHeight%)
''   'Declare Function HEGetPrinterLineHeight Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Function HEGetPrinterLineWidth Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Sub HEGetRBMargins Lib "HEVB.VBX" (ByVal hWnd%, lpiRight%, lpiBottom%)
''   'Declare Function HEGetRGB Lib "HEVB.VBX" (ByVal hWnd%, ByVal iIndex%) As Long
''   'Declare Function HEGetScreenFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFont%, iHeight%, lRGB&, iPitch%, iFamily%, ByVal sName$) As Integer
''   'Declare Function HEGetSelectedText Lib "HEVB.VBX" (ByVal hWnd%, sBuffer$) As Integer     '17Sep99 AE
''   'Declare Sub HEGetSelection Lib "HEVB.VBX" (ByVal hWnd%, lpiXWidth%, lplYWidth&)
''   'Declare Function HEGetSelectionStart Lib "HEVB.VBX" (ByVal hWnd%, lpiXStart%, lplYStart&) As Integer
''   'Declare Function HEGetSpacing Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetStyle Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetTabCount Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetTabList Lib "HEVB.VBX" (ByVal hWnd%, iTabTyp%, lTabOffset&) As Integer
''   'Declare Function HEGetTabWidth Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetText Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpBuffer$, ByVal iMaxLen%) As Integer
''   'Declare Sub HEGetTextDim Lib "HEVB.VBX" (ByVal hWnd%, lpiWidth%, lpiHeight%)
''   'Declare Function HEGetTyp Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetUndoDepth Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEGetUnit Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Sub HEGetVersion Lib "HEVB.VBX" (iMajor%, iMinor%, iInternal%)
''   'Declare Function HEGlobalMemToString Lib "HEVB.VBX" (ByVal iMem%, sBuffer$, ByVal iSegment%) As Integer
''
''   'Declare Sub HEHideDropDown Lib "HEVB.VBX" (ByVal hWnd%)
''
''   'Declare Sub HEInitNewDoc Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Function HEInsertBitmap Lib "HEVB.VBX" (ByVal hWnd%, ByVal iBitmap%) As Integer
''   'Declare Function HEInsertFunctionPF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTyp%, ByVal lpText$) As Integer
''   Declare Function HEInsertTable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iColumns%, ByVal iRows%) As Integer
''   Declare Function HEInsertTableRow Lib "HEVB.VBX" (ByVal hWnd%, ByVal lRow&) As Integer
''   'Declare Function HEIsClearDelete Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsCRVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsFormFeed Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsGrayBk Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsHeadFootVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsIgnoreEditable Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsInsertMode Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsLineBreak Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsLineEditable Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsLineGhost Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsModified Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPercentThumb Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPFActive Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPFBkVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPFFunctionVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPFGhost Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsPictureFrame Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsPreview Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsReadOnly Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsScreenFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal iIndex%) As Integer
''   'Declare Function HEIsScreenFontsEnabled Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsSpaceVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEIsTableActive Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsTabVisible Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HEIsTextSelectable Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''
''   Declare Function HeLoadDoc Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpFileName$, ByVal iFormat%) As Integer
''   Declare Function HELoadPicture Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpFileName$, ByVal iFormat%) As Integer    '30jun99 AE
''
''   'Declare Function HENextPF Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%, ByVal iLevel%, iTypList%) As Integer
''
''   Declare Sub HePaginate Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Sub HEPaginateHwnd Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndHead%, ByVal hWndFoot%)
''   Declare Sub HEPaste Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Function HEPasteData Lib "HEVB.VBX" (ByVal hWnd%, sHighEdit$, sText$) As Integer
''   'Declare Function HEPasteDataGlobalMem Lib "HEVB.VBX" (ByVal hWnd%, ByVal iHighEdit%, ByVal iText%) As Integer
''   'Declare Function HEPasteRTF Lib "HEVB.VBX" (ByVal hWnd%, sRTF$) As Integer
''   'Declare Function HEPasteRTFGlobalMem Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRTF%) As Integer
''   Declare Sub HEPreview Lib "HEVB.VBX" (ByVal hWnd%)
''   'Declare Sub HEPrintDoc Lib "HEVB.VBX" (ByVal hWnd%)
''   Declare Function HEPrintDocAbortDlg Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpDocTitle$, ByVal iPageCounter%) As Integer
''   'Declare Sub HEPrintDocParam Lib "HEVB.VBX" (ByVal hWnd%, ByVal iStartPage%, ByVal iEndPage%)
''   'Declare Function HEPrintDocParamAbortDlg Lib "HEVB.VBX" (ByVal hWnd%, ByVal iStartPage%, ByVal iEndPage%, ByVal lpDocTitle$, ByVal iPageCounter%) As Integer
''   'Declare Sub HEPrintDocParamHwnd Lib "HEVB.VBX" (ByVal hWnd%, ByVal iStartPage%, ByVal iEndPage%, ByVal hWndHead%, ByVal hWndFoot%)
''   'Declare Function HEPrintDocParamHwndAbortDlg Lib "HEVB.VBX" (ByVal hWnd%, ByVal iStartPage%, ByVal iEndPage%, ByVal hWndHead%, ByVal hWndFoot%, ByVal lpDocTitle$, ByVal iPageCounter%) As Integer
''   'Declare Sub HEPrintInsertDoc Lib "HEVB.VBX" (ByVal hWnd%, ByVal hdcPrinter%, ByVal x1%, ByVal y1%, ByVal x2%, ByVal y2%)
''   '
''   'Declare Function HEQueryUndoType Lib "HEVB.VBX" (ByVal hWnd%) As Long
''   'Declare Function HEQuickReplace Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpText$, ByVal iLen%) As Integer
''   '
''   Declare Sub HERedraw Lib "HEVB.VBX" (ByVal hWnd%, ByVal iClear%)
''   Declare Function HEReplaceSel Lib "HEVB.VBX" (ByVal hWnd%, ByVal szText$, ByVal iTextWidth%) As Integer
''   '
''   Declare Function HESaveDoc Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpFileName$, ByVal iStyle%, ByVal iFormat%) As Integer
''   Declare Function HESearch Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%, ByVal lpText$, ByVal iDisplayError%) As Integer    '30Jun99 AE
''   Declare Function HESearchContinue Lib "HEVB.VBX" (ByVal hWnd%, ByVal iDisplayError%) As Integer
''   Declare Function HESelectAll Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HESelectWord Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   'Declare Function HESendMessage Lib "HEVB.VBX" (ByVal hWnd%, ByVal wMessage%, ByVal wParam%, ByVal lParam&) As Long
''   'Declare Sub HESetAlign Lib "HEVB.VBX" (ByVal hWnd%, ByVal iAlign%)
''   'Declare Function HESetAllPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%, ByVal iLevel%, iTypList%) As Integer
''   'Declare Sub HESetAllPFWidth Lib "HEVB.VBX" (ByVal hWnd%, ByVal iWidth%, iTypList%)
''   'Declare Function HeSetCellFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndTable%, ByVal nFlags%, ByVal Row&, ByVal Col%, FontHeight%, FontName$, FontStyle%)
''   Declare Function HeSetCellText Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndTable%, ByVal nFlags%, ByVal nRow&, ByVal nCol%, ByVal Lpsz$) As Integer
''   'Declare Sub HESetClearDelete Lib "HEVB.VBX" (ByVal hWnd%, ByVal iClearDelete%)
''   'Declare Function HESetContext Lib "HEVB.VBX" (ByVal hWnd%, ByVal iContext%) As Integer
''   'Declare Sub HESetControls Lib "HEVB.VBX" (ByVal hWnd%, ByVal iStyle%)
''   'Declare Function HESetCursor Lib "HEVB.VBX" (ByVal hWnd%, ByVal iXNew%, ByVal lYNew&) As Integer
''   'Declare Sub HESetCRVisible Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Sub HESetEOFChar Lib "HEVB.VBX" (ByVal hWnd%, ByVal iChar%)
''   'Declare Function HESetFont Lib "HEVB.VBX" (ByVal hWnd%, ByVal iHeight%, ByVal lRGB&, ByVal iPitch%, ByVal iFamily%, ByVal sName$, ByVal iMode%) As Integer
''   'Declare Sub HESetFileName Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpFileName$)
''   'Declare Sub HESetGrayBk Lib "HEVB.VBX" (ByVal hWnd%, ByVal iGrayBk%)
''   'Declare Sub HESetIgnoreEditable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iIgnoreEditable%)
''   'Declare Sub HESetInsertMode Lib "HEVB.VBX" (ByVal hWnd%, ByVal iInsertMode%)
''   Declare Function HESetInstancePrinter Lib "HEVB.VBX" (ByVal hWnd%, ByVal sPrinter$) As Integer
''   'Declare Sub HESetLineBreak Lib "HEVB.VBX" (ByVal hWnd%, ByVal iBreak%)
''   'Declare Sub HESetLineEditable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iEditable%)
''   'Declare Sub HESetLineGhost Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Sub HESetMargins Lib "HEVB.VBX" (ByVal hWnd%, ByVal iLeft%, ByVal iTop%)
''   'Declare Sub HESetModified Lib "HEVB.VBX" (ByVal hWnd%, ByVal iModified%)
''   'Declare Sub HESetSpacing Lib "HEVB.VBX" (ByVal hWnd%, ByVal iLineSpacing%)
''   'Declare Sub HESetOffset Lib "HEVB.VBX" (ByVal hWnd%, ByVal iXOffset%, ByVal iYOffset%, ByVal iUpdate%)
''   'Declare Sub HESetPageCounter Lib "HEVB.VBX" (ByVal hWnd%, ByVal iPageCounter%)
''   'Declare Sub HESetPathName Lib "HEVB.VBX" (ByVal hWnd%, ByVal lpPathName$)
''   'Declare Sub HESetPercentThumb Lib "HEVB.VBX" (ByVal hWnd%, ByVal iPercentThumb%)
''   'Declare Sub HESetPFBkColor Lib "HEVB.VBX" (ByVal hWnd%, ByVal lRGB&)
''   'Declare Sub HESetPFBkVisible Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Sub HESetPFFunctionVisible Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Function HESetPFFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%) As Integer
''   'Declare Sub HESetPFGhost Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Function HESetPFWidth Lib "HEVB.VBX" (ByVal hWnd%, ByVal iWidth%) As Integer
''   'Declare Function HESetPictureDim Lib "HEVB.VBX" (ByVal hWnd%, ByVal iWidth%, ByVal iHeight%) As Integer
''   'Declare Function HESetPictureFlags Lib "HEVB.VBX" (ByVal hWnd%, ByVal iFlags%) As Integer
''   'Declare Sub HESetPictureFrame Lib "HEVB.VBX" (ByVal hWnd%, ByVal iPictureFrame%)
''   'Declare Function HESetPictureOffset Lib "HEVB.VBX" (ByVal hWnd%, ByVal xOffset%, ByVal yOffset%) As Integer
''   'Declare Sub HESetRBMargins Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRight%, ByVal iBottom%)
''   Declare Sub HESetReadOnly Lib "HEVB.VBX" (ByVal hWnd%, ByVal iReadOnly%)
''   'Declare Sub HESetRedraw Lib "HEVB.VBX" (ByVal hWnd%, ByVal iRedraw%)
''   'Declare Sub HESetScrollBars Lib "HEVB.VBX" (ByVal hWnd%, ByVal iScrollBars%)
''   'Declare Function HESetSelection Lib "HEVB.VBX" (ByVal hWnd%, ByVal iXWidth%, ByVal lYWidth&) As Integer   '17Sep99 AE
''   'Declare Function HESetSelectionEditable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iEditable%) As Integer
''   'Declare Function HESetUndoDepth Lib "HEVB.VBX" (ByVal hWnd%, ByVal iMaxDepth%)
''   'Declare Sub HESetSpaceVisible Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Function HESetStyle Lib "HEVB.VBX" (ByVal hWnd%, ByVal iAttribute%, ByVal lColor&) As Integer
''   'Declare Sub HESetTabVisible Lib "HEVB.VBX" (ByVal hWnd%, ByVal iVisible%)
''   'Declare Function HESetTabList Lib "HEVB.VBX" (ByVal hWnd%, ByVal iCount%, iTabTyp%, lTabOffset&) As Integer
''   'Declare Sub HESetTabWidth Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTabWidth%)
''   'Declare Sub HESetTextDim Lib "HEVB.VBX" (ByVal hWnd%, ByVal iWidth%, ByVal iHeight%)
''   'Declare Sub HESetTextSelectable Lib "HEVB.VBX" (ByVal hWnd%, ByVal iTextSelectable%)
''   'Declare Sub HESetUnit Lib "HEVB.VBX" (ByVal hWnd%, ByVal iUnit%)
''   Declare Function HEShowHeadFoot Lib "HEVB.VBX" (ByVal hWnd%, ByVal iShow%) As Integer
''
''   Declare Function HETableActivate Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''   Declare Function HEToggleFormFeed Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''
''   Declare Function HEUndo Lib "HEVB.VBX" (ByVal hWnd%, ByVal iIndex%) As Integer
''
''   'Declare Sub HEWinIniChange Lib "HEVB.VBX" (ByVal hWnd%, ByVal lParam&)
''   Declare Sub HEWinIniChange Lib "HEVB.VBX" (ByVal hWnd%, ByVal LPSTR$)
''   'Declare Function HEWriteProfile Lib "HEVB.VBX" (ByVal hWnd%) As Integer
''
''   '17Sep99 AE Added
''   'Declare Function HEGetColumnWidth Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndT%, ByVal nFlags%, ByVal nColumn%, nWidth%) As Integer       ' word, word, lpword
''   Declare Function HESetColumnWidth Lib "HEVB.VBX" (ByVal hWnd%, ByVal hWndT%, ByVal nFlags%, ByVal nColumn%, ByVal nWidth%) As Integer ' word, word, word
''
''   Declare Function HETableInsertDlg Lib "HEVB.VBX" (ByVal hWnd%) As Integer

Sub ChooseDevice(prompt$, PrinterDriverPort$, AllowDelete%)
'12Jan98 CKJ Written
'Lists all devices in the WIN.INI file and user selects one
'The rendering subsystem is not offered,
'and the current default is shown at the top of the list.
' Prompt$ is optional and will be displayed if given
' PrinterDriverPort$ is taken as the current printer
'  - left unchanged on escape
'17Mar98 CKJ Added Unload LstBoxFrm to prevent recursive usage
'11Jan02 TH Stop GPF on cancel (#54984)
'09May05 V93 OK
'12Sep19 251288 - User Prompted to Select Printer Twice

Dim devstring As String * 4096
Dim res$, di%, Numoflines%, tmp$, i%, ans$
Dim Prn As Printer

   HighEdit.Tag = ""
   
   Unload LstBoxFrm
   LstBoxFrm.Caption = "EMIS Health"
   LstBoxFrm.lblTitle.Caption = cr & "Select printer" & Iff(Len(prompt$), " for ", "") & prompt$ & cr
   LstBoxFrm.lblHead.Caption = "Printer Name" & Space$(30) & TB & "Driver" & Space$(5) & TB & "Port" & Space$(20) & "."
   i = GetCurrentPrinter(PrinterDriverPort$)
   LstBoxFrm.LstBox.AddItem Iff(AllowDelete, TB & TB & "<Remove entry>", "")
   
   For Each Prn In Printers
       tmp$ = Prn.DeviceName & TB & Prn.DriverName & TB & Prn.Port
       If LCase$(Prn.DeviceName) <> LCase$(PrinterDriverPort$) Then
             LstBoxFrm.LstBox.AddItem tmp$
       Else
             LstBoxFrm.LstBox.AddItem tmp$, 0
       End If
   Next

   LstBoxShow
   
   res$ = LstBoxFrm.Tag
   If Len(res$) Then
         If AllowDelete And Left$(res$, 1) = TB Then
               askwin "EMIS Health", "Are you sure you want to delete this entry?", ans$, k
               If ans$ = "Y" And Not k.escd Then PrinterDriverPort$ = ""
            Else
               PrinterDriverPort$ = res$
               replace PrinterDriverPort$, TB, ",", 0
            End If
      Else
         PrinterDriverPort$ = ""    '11Jan02 TH (#54984)
      End If
   Unload LstBoxFrm
   
End Sub

Sub EditPrintContexts(SystemEntries%)
'12Jan98 CKJ Written
'Show a list box of all printer contexts and current settings for this terminal
'If SystemEntries then show for [Default] instead of the current terminal
'User can select any and amend as required

Dim res$, Numoflines%, i%, Context$, term$, PRNwas$
Dim allcontexts$, numofcontexts%, Comment$, PrinterDriverPort$
ReDim lines$(100)
           
   Do
      FlushIniCache
      HighEdit.Tag = ""
      LstBoxFrm.Caption = "EMIS Health"
      LstBoxFrm.lblTitle.Caption = cr & "Select print context to amend for " & Iff(SystemEntries, "SYSTEM DEFAULTS", "this terminal") & cr
      LstBoxFrm.lblHead.Caption = "Context     " & TB & "Printer" & Space$(20) & TB & "Driver    " & TB & "Port" & Space$(15) & TB & "Comment" & Space$(100)
      'Context        Printer       Driver      Port                Comment
      '-------------  ------------  ----------  ------------------  ---------------------
      'GeneralLbl     Epson-FX80    UNIDRV      LPT1:               Prescription labels
      'GeneralPlain   HP-4L         HP_DRV      \\Pharmacy\Queue1   Plain paper on laser
      
      allcontexts$ = terminal("PrintContexts", "")
      
      ReDim lines$(100)
      deflines allcontexts$, lines$(), ",", 1, numofcontexts
   
      For i = 1 To numofcontexts
         If SystemEntries Then                             'read printer for [Default]
               term$ = "Default"
               PrinterDriverPort$ = TxtD(dispdata$ & "\TERMINAL.INI", term$, "", lines$(i), 0)
            Else                                           'read printer for this term/context
               term$ = ASCTerminalName()
               PrinterDriverPort$ = terminal(lines$(i), "")
            End If
         Comment$ = terminal(lines$(i) & "Prompt", "")
         replace PrinterDriverPort$, ",", TB, 0
         If PrinterDriverPort$ = "" Then PrinterDriverPort$ = TB & TB
         LstBoxFrm.LstBox.AddItem lines$(i) & TB & PrinterDriverPort$ & TB & Comment$
      Next
   
      LstBoxShow
      res$ = LstBoxFrm.Tag
      Unload LstBoxFrm
   
      If Len(res$) Then
            ReDim lines$(100)
            deflines res$, lines$(), TB & "(*)", 1, Numoflines
            Context$ = lines$(1)
            i = GetCurrentPrinter(PRNwas$)
            If Len(lines$(2)) Then
                  PrinterDriverPort$ = lines$(2) & "," & lines$(3) & "," & lines$(4)
                  i = SetSpecifiedPrinter(PrinterDriverPort$)
               Else
                  PrinterDriverPort$ = ""
               End If
   
            ChooseDevice lines$(5), PrinterDriverPort$, True
            i = SetSpecifiedPrinter(PRNwas$)

            If Len(Context$) > 0 Then 'And Len(PrinterDriverPort$) > 0 Then 'save it
                  replace PrinterDriverPort$, TB, ",", 0
                  'Add this context and printer to the user's terminal (may already be there!)
                  WritePrivateIniFile term$, Context$, PrinterDriverPort$, dispdata$ & "\TERMINAL.INI", 0
                  'Add this context to [default] PrintContexts if not already there (Should be there!)
                  If InStr("," & UCase$(allcontexts$) & ",", "," & UCase$(Context$) & ",") = 0 Then
                        WritePrivateIniFile "Default", "PrintContexts", allcontexts$ & "," & Context$, dispdata$ & "\TERMINAL.INI", 0
                     End If
                  FlushIniCache     '28Jun00 JN Added
               End If
         End If
   Loop While Len(res$)
               
End Sub

'25Mar10 CKJ function removed - no longer used. Would require to be aware of Citrix changing Port designation
'Private Function FindPrinterFromContext(Context$, PrinterDriverPort$) As Integer
''12Jan98 CKJ Written
''Given Context$ returns PrinterDriverPort$, or "" if none selected
''No User interface
'
'   PrinterDriverPort$ = terminal(Context$, "")
'   FindPrinterFromContext = (PrinterDriverPort$ <> "")
'
'End Function

Private Function GetCurrentPrinter(PrinterDriverPort$) As Integer
'12Jan98 CKJ Written
'the current HighEdit printer is placed in PrinterDriverPort$
'Returns success = T/F
'Note DefPrntr = T if the current printer is same as Windows default
'              = F if a special printer is set
                                              
Dim DefPrntr%

   GetCurrentPrinter = HighEdit.He.GetInstancePrinter(PrinterDriverPort$, DefPrntr)

End Function

Sub GetFileByChunk(filename$, ChunkSize%, Chunk$, Completed%)

Dim readlen&, buffer$, ErrNum%
Static phase%, recnum&, records&, remainder&, chan%, RecLen&
'phase
' 0 unopened
' 1 opened and reading whole chunks
' 2 opened and about to read last chunk

   If filename$ = "" Then                                    'Close & Reset
         If phase > 0 Then
               Close chan
               phase = 0
            End If
         Exit Sub                                            '<== WAY OUT
      End If

   Chunk$ = ""
   Completed = False
   If phase = 0 Then
         If fileexists(filename$) Then
               Do
                  On Error GoTo GetFileByChunk_Err
                  ErrNum = False
                  chan = FreeFile
                  Open filename$ For Binary Access Read Write Lock Read Write As #chan
                  Err70msg ErrNum, "File"
               Loop While ErrNum
      
               RecLen& = Iff(ChunkSize, ChunkSize, 10000)    'Use given size or default to 10,000
               readlen& = LOF(chan)                          'length of file
               records& = readlen& \ RecLen&                 'whole chunks of 1K
               remainder& = readlen& - records& * RecLen&    'bit of a record at end
               recnum& = 1                                   'start at record 1
               If records& = 0 Then phase = 2 Else phase = 1 'but may not have a whole chunk
            Else
               Completed = 1                                 'failed
            End If
      End If

   If phase = 1 Then
         buffer$ = Space$(RecLen&)
         GoSub ReadRecordByChunk
         Chunk$ = buffer$
         recnum& = recnum& + 1
         If recnum& > records& Then
               If remainder = 0 Then                         'no more to read
                     Close chan                              'so finish here
                     phase = 0
                     Completed = True
                  Else                                       'otherwise...
                     phase = 2                               'ready for next call
                  End If
            End If

      ElseIf phase = 2 Then
         If remainder Then
               'recnum& is 1 or incremented from last time
               buffer$ = Space$(remainder)
               GoSub ReadRecordByChunk
               Chunk$ = buffer$
            End If

         Close chan
         phase = 0
         Completed = True
      End If
   
GetFileByChunk_Exit:
   On Error GoTo 0
Exit Sub

      
ReadRecordByChunk:
   Do
      On Error GoTo GetFileByChunk_Err
      ErrNum = False
      Get #chan%, (recnum& - 1) * RecLen& + 1, buffer$
      Err70msg ErrNum, "Record"
   Loop While ErrNum
Return


GetFileByChunk_Err:
   ErrNum = Err
   If ErrorHandler(ErrNum, "HighASC", "GetFileByChunk") = 1 Then Resume Next
   '!!** More...

End Sub

Function DeferredPrintingActive() As Integer
'27Nov01 CKJ Companion to DeferredPrinting procedure
'            Returns T/F depending on whether deferred printing is currently active
'            This is determined by the presence of "(DeferredPrinting)Total" in the print heap

Dim strValue As String
Dim intFound As Integer

   intFound = False
   If gPRNheapID = 0 Then                                                                           'ensure print heap is present
         popmessagecr ".", "Cannot use deferred printing - Print Heap not initialised"
      Else
         Heap 11, gPRNheapID, "(DeferredPrinting)Total", strValue, intFound                         'read Total if entry present
      End If

   DeferredPrintingActive = intFound

End Function

Sub DisplayPlainFile(textfile$, title$, desc$)

Dim fil%, lin$
   
   If fileexists(textfile$) Then
         fil = FreeFile
         Open textfile$ For Input Lock Write As #fil

         LstBoxFrm.Caption = title
         'LstBoxFrm.lblHead.Caption = "Description"
         Do While Not EOF(fil)
            Input #fil, lin$
            If Trim$(lin$) <> "" Then
               LstBoxFrm.LstBox.AddItem lin$
            End If
         Loop
         Close #fil
         
         LstBoxShow

         desc$ = LstBoxFrm.Tag
         Unload LstBoxFrm
         Set LstBoxFrm = Nothing
      Else
         popmessagecr title$, "File has not been defined."
      End If

End Sub

Sub EditContextDescriptions()
'12Jan98 CKJ Written
'Show a list box of all printer contexts and current descriptions

Dim res$, Numoflines%, i%, Context$
Dim allcontexts$, numofcontexts%, Comment$, ans$
ReDim lines$(100)
           
   Do
      FlushIniCache
      LstBoxFrm.Caption = "EMIS Health"
      LstBoxFrm.lblTitle.Caption = cr & "Select print context description to amend" & cr
      LstBoxFrm.lblHead.Caption = "Context     " & TB & "Comment" & Space$(100)
      'Context        Comment
      '-------------  ---------------------
      'GeneralLbl     Prescription labels
      'GeneralPlain   Plain paper on laser
      
      allcontexts$ = terminal("PrintContexts", "")
      
      ReDim lines$(100)
      deflines allcontexts$, lines$(), ",", 1, numofcontexts
   
      For i = 1 To numofcontexts
         Comment$ = terminal(lines$(i) & "Prompt", "")
         LstBoxFrm.LstBox.AddItem lines$(i) & TB & Comment$
      Next
   
      LstBoxShow
      res$ = LstBoxFrm.Tag
      LstBoxFrm.Show 0
      LstBoxFrm.Enabled = False
   
      If Len(res$) Then
            ReDim lines$(100)
            deflines res$, lines$(), TB & "(*)", 1, Numoflines
            Context$ = lines$(1)
            Comment$ = lines$(2)
                       
            ans$ = Comment$
            k.Max = 50
            k.min = 0
            InputWin "EMIS Health", "Change description for " & Context$, ans$, k
            If ans$ <> Comment$ Then
                  WritePrivateIniFile "Default", Context$ & "Prompt", ans$, dispdata$ & "\TERMINAL.INI", 0
                  FlushIniCache     '28Jun00 JN Added
               End If
         End If
   
      LstBoxFrm.Enabled = True
      Unload LstBoxFrm
   
   Loop While Len(res$)
               
End Sub

Sub Hedit(ByVal Action, txt$)
'Action =  -1 load HighEdit, ensuring it is newly initialised
'          -2 load HighEdit if not already loaded. Do not clear text
'          -3 unload HighEdit
'
'           0 view    RTF provided in txt$
'           1 edit    RTF provided in txt$
'           2 preview RTF provided in txt$
'           3 print   RTF provided in txt$ to default printer
'           4 print   RTF to context provided in txt$ as "context*RTF string"
'
'          10 view    filename provided in txt$  (RTF)
'          11 edit    filename provided in txt$, changes are saved back in same file (RTF)
'          12 preview filename provided in txt$  (RTF)
'          13 print   filename provided in txt$  to default printer (RTF)
'          14 print   to context provided in txt$ as "context*file" (RTF)
'
'         100 view    plain text provided in txt$
'         101 edit    plain text provided in txt$
'         102 preview plain text provided in txt$
'         103 print   plain text provided in txt$ to default printer
'         104 print   plain text to context provided in txt$ as "context*plain text"
'
'         110 view    filename provided in txt$  (plain text)
'         111 edit    filename provided in txt$, changes are saved back in same file (plain text)
'         112 preview filename provided in txt$  (plain text)
'         113 print   filename provided in txt$ to default printer  (plain text)
'         114 print   to context provided in txt$ as "context*file" (plain text)
'
'         214 print   filename in txt$ as "context*file" (HighEdit propriety format)
'Note: In "file*context" the * is chr$(0)
'The 'context' is a unique string of characters which identifies the reason for printing,
' and from this the most appropriate printer for that purpose on this terminal.
' e.g. if context = "TPNlabel" then a 4x4" label stock in a suitable printer (probably on LPT1)
' would be used. However the choice of output device is left to the user - they are offered a
' list of all printers on their machine, and the choice is recorded in Terminal.ini
'
'16Oct96 CKJ Force loading of form before using hWnd
' 8Nov96 CKJ/EAC use HELoadDoc instead of HEPasteRTF - allows head/foot & >32K
' 9Nov96 CKJ Actions 10,11,12,13 added - provide filename containing RTF
'            Actions 0,10 provide view only tool
' 5Aug97 CKJ Added Plain Text options - simply add 100 to the standard actions
'28Oct97 CKJ Added extra menu options, with lookups to external files

'        1000, ""                             clear all extra menus
'        1000, "menu text"                    remove specified menu item        **
'        1001, "-"                            display a separator bar           **
'        1001, "menu text|item¦item"          link menu to list of items        **
'        1002, "menu text|filename"           link menu to plain text file
'        1003, "menu text|filename"           link menu to simple lookup file
'        1004, "menu text|filename"           link menu to compound lookup file **
'                                                ** Not supported yet
'            - where menu text is to be shown to the user on the 'Insert' menu,
'            including an amersand '&' if applicable
'            Filename is the fully qualified drive:\path\filename.ext
'            A plain text file contains one or more lines, all of which are read
'            and offered in a list box.
'            A simple lookup file is of the type read by displaymacrofile.
'            Compound lookup files: to be defined but conceptually like BNFchap:BNFsect
'            Text from all the above files is parsed using printer.ini [rtf] using;
'             ParseCtrlChars DISPDATA$ & "\printer.ini", "RTF", txt$, Changed
'            Note: Hotkeys cannot be assigned to these menus, as they are read only at runtime
'             but it may be possible to simulate the action in code if required.
'             Therefore, a third parameter may be added later for HotKeys
'10Jan98 CKJ Added actions -1, -2, -3; See summary above for info
'            Added actions xx4, where a context string is provided which specifies the type
'             of printer for that terminal.
'            The context string is stored in terminal.ini, for the specified terminal.
'            If the terminal has not been named then one is allocated
'            If the context string is not found, or has a blank value then the user is
'            prompted for the printer to be used. See above for more details.
'02Jul98 CFY New functionality added to either display or print the name of the .rtf file if
'            hiedit due to the fact the file is missing.
'27Nov01 CKJ Added deferred printing option
'10Dec01 CKJ Modified deferred printing to avoid re-saving from inside HE
'            Added filetype to the stored context
'29sep03 CKJ Allow printing demo mode from ascribe.ini [] HEdemo=Y
'01Mar06 CKJ OverrideLayout added
'17Sep10 CKJ Added external printing
'15Dec10 CKJ External printing default is now "Y"
'            Changed writelog from generic DeferredPrinting to ExternalPrint

Dim res%, fil$, FileFormat%, Item%, NumItems%, PRNwas$, PRNnow$, Context$
Dim posn%, dummy%
Dim strDeferredPrintingFile As String     '10Dec01 CKJ
Dim PrinterDriverPort$
Dim msg As String
UpdatedRTFfilename = ""
   '17Sep10 CKJ Added block, currently for action 14 only
   'No deferred printing with this option
   If Action = 14 And InStr(UCase$(Command$), "/HEDEMO") = 0 Then    'Attempt to use external print job, only for RTF file to context
      If TrueFalse(terminal("ExternalPrinting", "Y")) Then           'if set for this terminal
         If ExternalPrint(txt) Then                                  'Attempt to print using AscribePrintJob
            Exit Sub                                                 'Job accepted, exit immediately (NB No confirmation of completion)
         Else
            fil = txt
            replace fil, Nul, "|", 0
            'DeferredPrintingLog "FailedExternalPrint|" & fil, (Action), 0    '15Dec10 CKJ Replaced "DeferredPrinting" with specific entry
            WriteLogSQL "|" & "ExternalPrintingError|" & fil & "|", "ExternalPrint", (Action), 0      'log failed externalprint
            fil = ""
         End If
      End If
   End If

   Select Case Action                     'force unloading if already loaded
      Case -1, -3
         HighEdit.Unload
         Set HighEdit = Nothing
      End Select
   
   If Action <> -3 Then
         HighEdit.Tag = ""                'force loading of the form
      End If

   Select Case Action                     ' 5Aug97 CKJ Select file format
      Case 0 To 99
         FileFormat = FILEFORMAT_RTF
      Case 100 To 199
         FileFormat = FILEFORMAT_ANSI
         Action = Action - 100
      Case 200 To 299
         FileFormat = FILEFORMAT_HIGHEDIT           '30Jun99 AE added
         Action = Action - 200                      '    "
      Case 1000 To 1004
         Select Case Action
            Case 1000
               ReDim mnuInfo(2, 0)
            Case 1001, 1002, 1003         'add another item to the Insert menu
               'mnuInfo(2, 0)   (0,)=Action, (1,)=Title, (2,)=Filename
               On Error Resume Next
               NumItems = UBound(mnuInfo, 2)
               On Error GoTo 0
               NumItems = NumItems + 1
               ReDim Preserve mnuInfo(2, NumItems)
               mnuInfo(0, NumItems) = Format$(Action)
               ReDim lines$(5)
               deflines txt$, lines$(), "|(*)", 1, 0
               If Action = 1001 Then replace lines$(2), "¦", "[cr]", 0
               For Item = 1 To 2
                  mnuInfo(Item, NumItems) = lines$(Item)
               Next
            Case 1004
               popmessagecr ".", "HEdit action 1004 not yet supported"
            End Select
         Action = -1                      ' no further action required, but do not unload on exit
      End Select


   Context$ = ""
   Select Case Action                     'set to alternative printer
      Case 4, 14
         posn = InStr(txt$, Chr$(0))
         If posn Then
               Context$ = Left$(txt$, posn - 1)
               txt$ = Mid$(txt$, posn + 1)
            End If
         dummy = GetCurrentPrinter(PRNwas$)
         SelectPrinterFromContext Context$, PRNnow$
         If PRNnow$ <> PRNwas$ Then
            PrinterDriverPort$ = PRNnow$ '03Jan05 TH Added
            dummy = SetSpecifiedPrinter(PRNnow$)
         End If
      
         If InStr(UCase$(Command$), "/HEDEMO") Then
               Action = Action - 3 'Show on screen if no printer  '16Nov98 ASC
            ElseIf TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "0", "HEDEMO", 0)) Then
               Action = Action - 3 'Show on screen if no printer
            End If

      End Select

   Select Case Action
      Case 0 To 9
         res = True
         MakeLocalFile fil$
         PutTextFile fil$, txt$, res
         If Len(txt$) Then
            res = HighEdit.He.LoadDoc(fil$, FileFormat)
         Else
            res = HighEdit.He.CreateBlankDoc(fil$)
         End If
               If DeferredPrintingActive() Then                                                                '10Dec01 CKJ Keep file for later
                     strDeferredPrintingFile = fil$
                  Else
                     Kill fil$
                  End If

               'res = HEPasteRTF(HighEdit.HE.hWnd, txt$)
      Case 10 To 19
         If Not fileexists(txt$) Then                                                                          '02Jun98 CFY Added
               txt$ = "ERROR  :  " & UCase(txt$) & " does not exist. Please contact your system supervisor."   '         "
               MakeLocalFile fil$                                                                              '         "
               PutTextFile fil$, txt$, res                                                                     '         "
               FileFormat = FILEFORMAT_ANSI                                                                    '         "
               res = HighEdit.He.LoadDoc(txt$, FileFormat)
               If DeferredPrintingActive() Then                                                                '10Dec01 CKJ Keep file for later
                     strDeferredPrintingFile = fil$
                  Else
                     Kill fil$
                  End If
            Else
                If frmTxtWin.cancelClicked = True Then
                    Exit Sub
                End If
                
                res = HighEdit.He.LoadDoc(txt$, FileFormat, 1)
                 If DeferredPrintingActive() Then                                                                '10Dec01 CKJ take copy if necessary
                   MakeLocalFile strDeferredPrintingFile
                   copy txt$, strDeferredPrintingFile
                End If
            End If                                                                                             '02Jun98 CFY Added
      Case Else
         res = False
      End Select

   '03Jan06 TH defer setting of printer here cos loading above seems to reset to default
   If PrinterDriverPort$ <> "" Then dummy = SetSpecifiedPrinter(PrinterDriverPort$)
   
   OverrideLayout Context                                   '01Mar06 CKJ added
   
   If res <> 0 Then
         Select Case Action
            Case 0, 10                                       'view only
               HighEdit.He.ReadOnly = True
               HighEdit.He.CursorHome
               UpdatedRTFfilename = HighEdit.Shows(1)
            
            Case 1, 11                                       'edit
               On Error Resume Next                          'may not have set any at all
               NumItems = UBound(mnuInfo, 2)
               On Error GoTo 0
               If NumItems Then
                     For Item = 1 To NumItems
                        Load HighEdit.mnuInsert(Item)
                        HighEdit.mnuInsert(Item).Caption = mnuInfo(1, Item)
                     Next
                     HighEdit.mnuInsertHdg.Enabled = True
                     HighEdit.mnuInsertHdg.Visible = True
                     HighEdit.mnuInsert(0).Enabled = False
                     HighEdit.mnuInsert(0).Visible = False
                  End If
               
               HighEdit.Tag = ""
               HighEdit.He.CursorHome
               HighEdit.He.SetModified False        'clear the edited flag
               UpdatedRTFfilename = HighEdit.Shows(1)
               
               res = HighEdit.He.IsModified()
               'popmessagecr "HighEdit debug", "File changed = " & YesNo$(res) 'seems reliable
               If HighEdit.Tag <> "exit" Then
                     If Action = 1 Then
                           res = SaveWholeDoc(1, "", txt$)   'Retrieve Txt$ from HE
                        Else
                           res = SaveWholeDoc(2, txt$, "")   'Retrieve Txt$ from HE
                        End If
                  End If
            
            Case 2, 12                                       'print preview
               HighEdit.He.preview
               HighEdit.Tag = "preview"
               HighEdit.He.CursorHome
               
               On Error Resume Next
               HighEdit.Unload
               Set HighEdit = Nothing
               On Error GoTo 0
               
               Exit Sub
            
            Case 3, 13, 4, 14
               If DeferredPrintingActive() Then                                           '10Dec01 CKJ Replaced again to avoid re-saving from inside HE
                     DeferredPrinting 2, strDeferredPrintingFile, Format$(FileFormat) & Context$      'Add filetype as one digit to the context
                  Else
                     DeferredPrintingLog "HE.PrintDoc called", Action, 0                  '31Mar10 CKJ
                     res = HighEdit.He.PrintDocAbortDlg("Document", 1)
                     DeferredPrintingLog "HE.PrintDoc return", Action, res                '31Mar10 CKJ
                  End If

            End Select
      Else
         If Action >= 0 Then popmessagecr "Error", "Paste to Editor was unsuccessful"
      End If

   Select Case Action                     'reset current printer
      Case 4, 14
         If PRNnow$ <> PRNwas$ Then dummy = SetSpecifiedPrinter(PRNwas$)
      End Select

   If Action >= 0 Then
         HighEdit.Unload
         Set HighEdit = Nothing
      End If

End Sub

Sub HEdit_Callback(Index As Integer)
'28Oct97 CKJ Written to handle lookups to external files
'            Needs expanding to other lookup types

Dim title$, Code$, desc$

   title$ = mnuInfo(1, Index)
   replace title$, "&", "", 0

   Select Case mnuInfo(0, Index)
      Case "1001"
         popmenu 0, "", 0, 0
         popmenu 2, mnuInfo(2, Index), 0, 0
         PopMenuShow "", 0, 0
         If Val(PopMnu.Tag) Then desc$ = PopMnu.mnuItem(PopMnu.Tag).Caption
         popmenu 0, "", 0, 0
      Case "1002"
         DisplayPlainFile mnuInfo(2, Index), title$, desc$
      Case "1003"
         displaymacrofile mnuInfo(2, Index), title$, Code$, desc$, False
      Case "1004"
         '
      End Select
   
   If Len(desc$) Then ReplaceSelText desc$
                 
End Sub

Sub HiTable(Action%, DrvPathFile$, Row%, Col%, Value As Variant, success%)

'Basic routines to Handle tables in hiedit.
'Intended for use with blank files; build the table up in a separate
'rtf, then insert the whole file into another file rather than trying to insert
'the table into an existing file.
'Use with files containing multiple tables etc. has not been tested
'and is likely to be unpredictable.

'Action:
'0 - Unload Hiedit
'1 - Add a table to the RTF file in DrvPathFile$, with Row% rows and Col% columns
'2 - Append value% rows to an existing table in the RTF file in DrvPathFile$
'3 - Change the size of the Col%th Column to that specified in Value
'4 - Insert text (held in value$) into the cell specified in row,col
'5 - set the formatting of the cell specified in row,col to the value held in value
'9 - Save the document as RTF

'14 - Return the text in the cell at Row,Col, as a string in Value
'


'more...

'---------------------------------------------------------------------
'17Sep99 AE Written

Dim FileFormat%, OK%, tmp$, tmpint%
Dim r$, act$, n%
Dim lRow&

Static FileLoaded%, TotalRows%, TotalCols%

   On Error GoTo HiTableErr

   lRow = Row
   success = True

   Select Case Action%
      Case 1 To 20
         FileFormat = FILEFORMAT_RTF
      '
      'others
      '
      End Select


   If Not FileLoaded And Action > 0 Then
         Hedit -1, ""
         OK = HighEdit.He.LoadDoc(DrvPathFile$, FileFormat, 1)
         If Not OK Then Error 2105
         FileLoaded = True
      End If
   

   Select Case Action%
      Case 0                                                '<----------Unload
         FileLoaded = False
         HighEdit.Unload
         Set HighEdit = Nothing

      Case 1                                                '<----------Insert Table
         OK = HighEdit.He.InsertTable(Col%, Row%)
         TotalRows = Row%
         TotalCols = Col%

      Case 2                                                '<-----------Append Value Rows
         tmpint = Value                         '09May05 Needs IsTableActive
         If tmpint > 0 Then
               For n = 1 To Value
                     OK = HighEdit.He.InsertTableRow()
                     If Not OK Then Error 2106
                  Next
               TotalRows = TotalRows + tmpint
            End If

      Case 3                                                '<----------Define width of this column
 '!!V93!!        TablehWnd = HETableActivate(HighEdit.HE.hWnd)
 '        tmpint = Value
 '        OK = HESetColumnWidth(HighEdit.HE.hWnd, TablehWnd, 0, Col, tmpint)
 '        If Not OK Then success = False
                                                            '<----------Insert text into a cell
      Case 4
         tmp$ = Value & Chr$(0)
 '!!V93!!        TablehWnd = HETableActivate(HighEdit.HE.hWnd)
 '        OK = HeSetCellText(HighEdit.HE.hWnd, TablehWnd, 0, Row, Col, tmp$)
         If OK <> 0 Then OK = True       'needed as this function doesn't return True = -1
         If Not OK Then Error 2107

      Case 5                                                '<---------Format a cell
         'not working!!!!!!!!!!!
'         TablehWnd = HETableActivate(HighEdit.HE.hWnd)
'         ok = HeGetCellFont(HighEdit.hWnd, TablehWnd, 0, lRow, Col, fHeight%, fName$, tmpint%)
'         tmpint = Value
'         ok = HeSetCellFont(HighEdit.HE.hWnd, TablehWnd, 0, lRow, Col, fHeight, fName$, tmpint%)
'         If Not ok Then Error 2108

      Case 9                                                '<---------Save document
         OK = HighEdit.He.SaveDoc(DrvPathFile$, FileFormat)
         If Not OK Then Error 2104
      
      Case 14                                                '<---------Return the text from a cell
 '!!V93!!        TablehWnd = HETableActivate(HighEdit.HE.hWnd)
 '        OK = HeGetCellText(HighEdit.HE.hWnd, TablehWnd, 0, Row, Col, tmp$)
         If Not OK Then success = False
         Value = tmp$
      
      End Select

HiTableExit:

   Exit Sub

HiTableErr:

   Select Case Action%
      Case 1:    act$ = act$ & "insert table."
      Case 2:    act$ = act$ & "append rows to table."
      Case 3:    act$ = act$ & "edit the colums of the table."
      Case 4:    act$ = act$ & "insert text into a table."
      Case 5:    act$ = act$ & "set the format of a cell."
      Case Else: act$ = act$ & "<Action unknown>."
      End Select
   
   r$ = "Error in HiTable! " & cr$

   Select Case Err
      Case 2104            'unable to save doc
         r$ = r$ & "Was unable to save file: " & DrvPathFile$ & cr$
         r$ = r$ & "Please contact your system administrator"
         popmessagecr "EMIS Health", r$
      
      Case 2105            'unable to load doc
         r$ = r$ & "Error 2105: was unable to load file " & DrvPathFile$ & cr$
         r$ = r$ & "whilst attempting to " & act$
         r$ = r$ & "Please contact your system administrator"
         popmessagecr "EMIS Health", r$
      
      Case 2106            'unable to insert table row
         r$ = r$ & "Error 2106: was unable to append row to table in file: " & DrvPathFile$ & cr$
         r$ = r$ & "Please contact your system administrator"
         popmessagecr "EMIS Health", r$

      Case 2107            'couldn't insert text
         r$ = r$ & "Was unable to insert text into the cell at (" & Format$(Row) & "," & Format$(Col) & cr$
         r$ = r$ & "If this problem persists, please contact your system administrator."
         popmessagecr "EMIS Health", r$
         Resume Next
      
      Case 2108            'Couldn't do formatting
         r$ = r$ & "Was unable to apply the specified formatting at cell (" & Format$(Row) & "," & Format$(Col) & cr$
         r$ = r$ & "If this problem persists, please contact your system administrator."
         popmessagecr "EMIS Health", r$
         
      Case Else
         r$ = r$ & Format$(Err) & ": " & Error$
         r$ = r$ & "Please contact your system administrator"
         popmessagecr "EMIS Health", r$

      End Select

   success = False
   Resume HiTableExit

End Sub

Sub InsertBitmapNoView(RTFfile$, BMPfile$, BitmapMarker$, OutFile$, success%)


'Use He function interface to replace BitmapMarker$ with the picture in BMPfile$.
'HE is not shown during this procedure.
'Outfile is a temporary local file, and so may need to be moved if it is for anything
'but transient use

'Constants used in HESearch:
'Const SEARCH_FORWARD = 0
Const SEARCH_CASE = 2
'SEARCH_WORD = 4
'SEARCH_CURSOR = 8
'SEARCH_BACK = 16
Const SEARCH_INIT = 32
'
'Const SEARCH_NOTFOUND = 0
'Const SEARCH_FOUND = 1
'Const SEARCH_ERROR = 2

'Constants for HEloadPicture
Const FILEFORMAT_BITMAP = 0



Dim r$, found%, inserted%, saved%, OK%
Dim workfil$

   On Error GoTo InsertBMPerr

   If Not fileexists(RTFfile$) Then Error 2100
   If Not fileexists(BMPfile$) Then Error 2101

   'load highedit
   MakeLocalFile workfil$
   FileCopy RTFfile$, workfil$
   Hedit -1, ""
   OK = HighEdit.He.LoadDoc(workfil$, FILEFORMAT_RTF, 1)

   'Find the position of BitmapMarker$
   found = HighEdit.He.search(SEARCH_CASE + SEARCH_INIT, BitmapMarker$, False)
   If found <> 1 Then Error 2102
      
   'Insert the bitmap there
   inserted = HighEdit.He.LoadPicture(BMPfile$, FILEFORMAT_BITMAP)
   If Not inserted Then Error 2103

   'HighEdit.Shows 1

   'save the document back as a new (temporary local) file
   saved = HighEdit.He.SaveDoc(workfil$, FILEFORMAT_HIGHEDIT)
   If Not saved Then Error 2104

   success = True
   OutFile$ = workfil$

InsertBMPexit:

   Hedit -3, ""        'unload highedit
   Exit Sub

InsertBMPerr:

   success = False
   Select Case Err
      Case 2100         'rtf not found
         r$ = "Could not find file " & RTFfile$ & ". Please contact your system administrator"
         popmessagecr "EMIS Health", r$
      
      Case 2101
         r$ = "Could not find file " & BMPfile$ & ". Please contact your system administrator"
         popmessagecr "EMIS Health", r$

      Case 2102         'no bitmapmarker -exit quietly without doing anything
      
      Case 2103         'Failed to insert bitmap
         r$ = "Was unable to insert picture. Please contact your system administrator"
         r$ = cr$ & "InsertBitmapNoView: failed HEInsertBitmap"
         popmessagecr "EMIS Health", r$
      
      Case 2104         'failed to save document
         r$ = "Was unable to insert picture. Please contact you system administrator."
         r$ = r$ & "InsertBitmapNoView: failed HESaveDoc"
         popmessagecr "EMIS Health", r$
      End Select

      OutFile$ = ""
      success = False
   Resume InsertBMPexit

End Sub

Sub DeferredPrinting(ByVal intAction_i As Integer, ByVal strPathFile_i As String, ByVal strContext_i As String)
'27Nov01 CKJ Written
'            Action = 1 Initialise deferred printing. Subsequent calls to print via Hedit will be deferred
'                          DeferredPrinting 1, "", ""
'                     2 Add a file to queue, storing filename and context
'                          DeferredPrinting 2, "<disk:\path\file.ext>", "<filetype><context>"
'                     3 Print the whole queue, remove all entries, delete files, turn off deferred printing
'                          DeferredPrinting 3, "", ""
'                     4 Delete the whole queue, delete files without printing, turn off deferred printing
'                          DeferredPrinting 4, "", ""
'
'            Uses the print heap to store the list of queued items
'               (DeferredPrinting)Total    = "<n>"
'               (DeferredPrinting)File1    = "<disk:\path\file.ext>"
'               (DeferredPrinting)Context1 = "<filetype><context>"
'            Deferred printing is used when the entry "(DeferredPrinting)Total" is present
'05Dec01 CKJ Fault corrected: Action 2 must set DeferredPrinting inactive before HEdit is called
'10Dec01 CKJ Allow activation by Site or Terminal. Terminal.ini DeferredPrinting="Y"  Y/N/T/F/1/0/-1 default="N"
'10Dec01 CKJ Added file type to the context string, since the file is not always RTF now. Filetype is always one digit

Dim strPrefix As String
Dim intloop As Integer
Dim strLoop As String
Dim strFilename As String
Dim strValue As String
Dim intTotal As Integer
Dim intOK As Integer
Dim intAction As Integer

   If gPRNheapID = 0 Then                                                                           'ensure print heap is present
         popmessagecr ".", "Cannot use deferred printing - Print Heap not initialised"

      Else
         strPrefix = "(DeferredPrinting)"
         strValue = "0"
         Heap 11, gPRNheapID, strPrefix & "Total", strValue, intOK                                  'read Total if entry present
         intTotal = Val(strValue)

         Select Case intAction_i
            Case 1                                                                                  'Initialise Deferred Printing
               If TrueFalse(terminal("DeferredPrinting", "N")) Then                                 '10Dec01 CKJ Allow activation by Site or Terminal
                     Heap 10, gPRNheapID, strPrefix & "Total", Format$(intTotal), intOK             'write Total=<n>
                     DeferredPrintingLog strPathFile_i & "|" & strContext_i, intAction_i, intTotal  '31Mar10 CKJ
                  Else                                                                              '10Dec01 CKJ
                     Heap 12, gPRNheapID, strPrefix & "Total", "", intOK                            '   "        remove Total if not active
                  End If

            Case 2                                                                                  'Add a file to the queue
               'If strPathFile_i <> "" Then                                                         'filename was given
               If DeferredPrintingActive() And strPathFile_i <> "" Then                             'filename was given  10Dec01 CKJ Added check
                     intTotal = intTotal + 1
                     strValue = Format$(intTotal)
                     Heap 10, gPRNheapID, strPrefix & "Total", strValue, intOK                      'write Total=<n+1>
                     Heap 10, gPRNheapID, strPrefix & "File" & strValue, strPathFile_i, intOK       'write File<n+1>=...
                     Heap 10, gPRNheapID, strPrefix & "Context" & strValue, strContext_i, intOK     'write Context<n+1>=...
                     
                     DeferredPrintingLog strPathFile_i & "|" & strContext_i, intAction_i, intTotal  '31Mar10 CKJ
                  End If

            Case 3, 4                                                                               'Print or delete whole queue
               Heap 12, gPRNheapID, strPrefix & "Total", "", intOK                                  'remove Total     05Dec01 CKJ Set inactive before HEdit
               DeferredPrintingLog "Processing queue", intAction_i, intTotal                        '31Mar10 CKJ
               For intloop = 1 To intTotal
                  strLoop = Format$(intloop)
                  strFilename = ""
                  Heap 11, gPRNheapID, strPrefix & "File" & strLoop, strFilename, intOK             'read File<n>
                  
                  If strFilename <> "" Then
                        If intAction_i = 3 Then                                                     'print before deleting
                              strValue = ""
                              Heap 11, gPRNheapID, strPrefix & "Context" & strLoop, strValue, intOK 'read Context<n>
                              
                              'If strValue = "" Then                                                'context not  provided     '10Dec01 CKJ removed
                              '      Hedit 13, strFilename                                          'RTF to default printer        "
                              '   Else                                                                                             "
                              '      Hedit 14, strValue & Chr$(0) & strFilename                     'RTF to specified printer      "
                              '   End If                                                                                           "
                              
                              intAction = 0                                                         '10Dec01 CKJ replaces block above
                              Select Case Val(Left$(strValue, 1))                                   'Extract FileType as a single digit
                                 Case FILEFORMAT_RTF:      intAction = 0                            '
                                 Case FILEFORMAT_ANSI:     intAction = 100                          '
                                 Case FILEFORMAT_HIGHEDIT: intAction = 200                          '
                                 End Select                                                         '
                              strValue = Mid$(strValue, 2)                                          'strip off the filetype digit
                              DeferredPrintingLog "Starting|" & strFilename & "|" & strValue, intAction_i, intloop '31Mar10 CKJ
                              If strValue = "" Then                                                 'context not  provided
                                    Hedit intAction + 13, strFilename                               'send file to default printer
                                 Else                                                               '
                                    Hedit intAction + 14, strValue & Chr$(0) & strFilename          'send file to specified printer
                                 End If                                                             '10Dec01 end block
                              DeferredPrintingLog "Finished|" & strFilename & "|" & strValue, intAction_i, intloop '31Mar10 CKJ

                           End If
                        On Error Resume Next
                        Kill strFilename                                                            'delete file on disk
                        On Error GoTo 0
                     End If
                  Heap 12, gPRNheapID, strPrefix & "File" & strLoop, "", intOK                      'remove File<n>
                  Heap 12, gPRNheapID, strPrefix & "Context" & strLoop, "", intOK                   'remove Context<n>
               Next
               'Heap 12, gPRNHeapID, strPrefix & "Total", "", intOK                                 'remove Total     05Dec01 CKJ Moved above calls to HEdit
               DeferredPrintingLog "Completed", intAction_i, intTotal  '31Mar10 CKJ

            End Select
      End If

End Sub

Sub parseRTF(ByVal InFile$, OutFile$)
'---------------------------------------------------------------------------------------------------------------
' 1Mar98 CKJ Written, based on ParseThenPrint
'            Given an RTF file with [itemstoprint] uses heap gPRNheapID to find replaceable items
'            then finishes any remaining items using the printer.ini RTF section.
' 3Mar98 CKJ Extended to allow layout files >32K (eg containing a logo), and to allow the
'            inclusion of fully formatted files also of >32K (formatted meaning that no [xxx]
'            entries will be parsed, the whole file is passed unchanged - if this file needs
'            parsing then do it first)
'            InFile is unchanged
'            OutFile contains full path & file name to a local file, or "" if InFile is unusable.
'            NB: Be sure to delete OutFile after it has been used!
'09Oct98 CKJ Added checks for [ without ] and for [...[...], which caused an infinite loop and
'            an out of memory error respectively.
'22Jan21 AS  MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22
'---------------------------------------------------------------------------------------------------------------

Dim Changed%, Chunk$, Buf$, Completed%, outchan%, openbrace&, closebrace&, char$, middle$   'MM-4782
Dim secondopenbrace&    'MM-4782
   
   Screen.MousePointer = HOURGLASS
   OutFile$ = ""
   If fileexists(InFile$) Then
         Buf$ = ""
         Completed = False
         MakeLocalFile OutFile$
         outchan = FreeFile
         Open OutFile$ For Output As #outchan

         Do
            Changed = False
            If Len(Buf$) < 10000 And Completed = False Then
                  GetFileByChunk InFile$, 10000, Chunk$, Completed
                  If Completed = 1 Then Exit Do           'InFile is unusable so quit
                  Buf$ = Buf$ & Chunk$
                  Changed = True
               End If

            If Len(Buf$) Then
                  Do
                     openbrace = InStr(Buf$, "[")
                     If openbrace > 1 Then                'store all text in front of the [
                           Print #outchan, Left$(Buf$, openbrace - 1);
                           Buf$ = Mid$(Buf$, openbrace)
                           openbrace = 1                  'only has values 0 and 1 beyond here
                        ElseIf openbrace = 0 Then         'no [ at all, so just store it
                           Print #outchan, Buf$;
                           Buf$ = ""
                        End If
                     closebrace = 0
                     If openbrace Then closebrace = InStr(openbrace + 1, Buf$, "]")
                     If closebrace > openbrace And openbrace > 0 Then
                           middle$ = Mid$(Buf$, openbrace + 1, closebrace - openbrace - 1)
                           char$ = "[" & middle$ & "]"
                           secondopenbrace = InStr(middle$, "[") '09Oct98 CKJ added extra check
                           If secondopenbrace Then              '            for open-open-close
                                 Print #outchan, Left$(Buf$, secondopenbrace);
                                 Buf$ = Mid$(Buf$, secondopenbrace + 1)
                              Else
                                 If Left$(LCase$(middle$), 9) = "#include" & TB Then
                                       'include a whole file here direct to output file
                                       CopyFileToChannel Mid$(middle$, 10), outchan
                                       char$ = ""
                                       Changed = True
                                    Else                        'pass through including []
                                       ParseItems gPRNheapID, char$, Changed
                                       ParseCtrlChars dispdata$ & "\printer.ini", "RTF", char$, Changed
                                    End If
      
                                 If char$ = "[" & middle$ & "]" Then         'failed to expand
                                       Print #outchan, Left$(Buf$, closebrace);
                                       Buf$ = Mid$(Buf$, closebrace + 1)
                                    Else                                     'did expand
                                       Buf$ = char$ & Mid$(Buf$, closebrace + 1)
                                       Changed = True
                                    End If
                              End If
                        '09Oct98 CKJ Added check for a single [ without a following ] in view
                        ElseIf openbrace = 1 And closebrace = 0 And (Completed Or Len(Buf$) >= 10000) Then 'closing ] must be within 10K chars of the [
                           Print #outchan, Buf$;     'rogue [ with no ], and either finished reading the file, or chunk in memory is 10K+ chars long
                           Buf$ = ""
                        End If
                  Loop While openbrace > 0 And closebrace > 0
               End If
         Loop While Changed = True Or Completed = False
         Close outchan
         Screen.MousePointer = STDCURSOR

         If Completed = 1 Then
               popmessagecr "!", "Unable to use file " & InFile$ & cr & "It may be locked or in use by another program"
               OutFile$ = ""
            End If

      Else
         Screen.MousePointer = STDCURSOR
         popmessagecr "!", "Unable to open file " & InFile$ & cr & "It may be missing or inaccessible"
      End If
         
End Sub

Sub ParseThenPrint(Context As String, FILE As String, ByVal copies As Integer, success As Integer, ByVal blnReprintRequired As Boolean, ByVal blnUseFile As Boolean)
'------------------------------------------------------------------------------------------------
'16Jan98 CKJ Written
'            Given a print context and an RTF file with [itemstoprint] prints 1 or more copies
'            to local or remote printer. Uses heap gPRNheapID to find replaceable items
'            then finishes any remaining items using the printer.ini RTF section.
' 3Mar98 CKJ Extended to allow layout files >32K (eg containing a logo), and to allow the
'            inclusion of fully formatted files also of >32K (formatted meaning that no [xxx]
'            entries will be parsed, the whole file is passed unchanged)
'20Aug98 CFY Extra functionality added to enable reprinting of last RTF file printed using this
'            routine. This is done by renaming the temporary local file after printing to a
'            pre-determined file name defined with the constant CReprintFile. The file can then
'            be re-printed by calling this routine with <reprint> as the File$ parameter.
'30Jun99 CFY Reserved context 'SCREEN' added which when encountered print previews to screen.
'15Oct03 CKJ CReprintFile$ changed to ReprintFileName()
'20May08 CKJ Added Rowa label confirmation exchange
'            Set param copies ByVal
'27May11 TH  Added new parameter. New requirement to remove the ascreprn file, but this is used effectively as
'            a cache file to create the genuine reprint in certain instances, therefore have added a new param to
'            retain this functionality ONLY when a genuine reprint is required. This then should allow for the file
'            rename and the removal of the ascreprn file once the copy has been done. Original reprn functionality will now
'            be removed so the ascreprn file should not now persist.
'25Jun12 CKJ Corrected above mod to remove temp file if no reprint needed        TFS37032
'------------------------------------------------------------------------------------------------

Dim i%, OutFile$
Dim RobotPrintLabelMessageID As Long
Dim RobotLabelUNCpath As String        '20May08 CKJ
Dim strMessage As String               '   "
   
   If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
   
   'If UCase$(FILE$) = "<REPRINT>" Then FILE$ = ReprintFileName()               '20Aug98 CFY  '27May11 TH Removed (F0088129)
   
   Screen.MousePointer = HOURGLASS
   success = False
   If blnUseFile Then  '04Jan17 TH Here we decide if we are parsing a local file or using a template from a share (now in DB)
      parseRTF FILE$, OutFile$
   Else
      parseRTFfromDB FILE$, OutFile$
   End If
   If OutFile$ <> "" Then
         'For i = 1 To copies
         '   Select Case UCase(Context$)                                                '30Jun99 CFY Added
         '      Case "SCREEN"                                                           '         "
         '         Hedit 12, outfile$                                    'preview it    '         "
         '      Case Else                                                               '         "
         '         Hedit 14, Context$ & nul & outfile$                   'print it
         '   End Select                                                                 '30Jun99 CFY Added
         'Next
         
            Select Case UCase(Context$)                                                '30Jun99 CFY Added
               Case "SCREEN"                                                           '         "
                  Hedit 12, OutFile$                                    'preview it    '         "
            
               Case Else                                                               '         "
               RobotPrintLabelMessageID = GetRobotPrintLabelMessageID()
               
               '20May08 CKJ block altered
               'SetRobotPrintLabelMessageID 0
               If RobotPrintLabelMessageID > 0 Then                        '09oct06 CKJ
                  RobotLabelUNCpath = TxtD(dispdata$ & "\mechdisp.ini", "common", dispdata$ & "\", "RobotLabelInterfacePath", 0) & Format$(RobotPrintLabelMessageID, "00000000") & ".rtf"
                  copy OutFile$, RobotLabelUNCpath
                  If MechDispLabelConfirm(Format$(RobotPrintLabelMessageID), RobotLabelUNCpath, strMessage) Then
                     copies = 0                                            'robot will do it so suppress local print
                  Else   'now print locally
                     'Caution: since this call was intended for robot consumption, copies may have been reduced to 1 much higher up the chain
                     If Len(strMessage) Then popmessagecr "!Error Sending Label to Robot", strMessage
                     Kill RobotLabelUNCpath                                'remove robot copy
                  End If
                  'LabelData already cleared on way out of MechDispLabelConfirm
               End If
               
               For i = 1 To copies
                  Hedit 14, Context$ & Nul & OutFile$                   'print it
               Next
            End Select                                                                 '30Jun99 CFY Added
         
         'If fileexists(ReprintFileName()) Then Kill ReprintFileName()  '20Aug98 CFY  '27May11 TH  Removed (F0088129)
         'Kill outfile$                                                 '20Aug98 CFY
         'Name OutFile$ As ReprintFileName()                            '20Aug98 CFY  '27May11 TH  Removed (F0088129)
         If blnReprintRequired Then  '27May11 TH Now we only create a reprint when we need to - this must not persist beyond the rename to genuine reprint file.
            If fileexists(ReprintFileName()) Then Kill ReprintFileName()
            Name OutFile$ As ReprintFileName()
         Else                                                           '25Jun12 CKJ Added to remove temp file if no reprint needed
            Kill OutFile$                                               '   "     "
         End If
         success = True
      End If
   Screen.MousePointer = STDCURSOR

End Sub

Sub ReplaceSelText(txt$)
'28Oct97 CKJ Added
Dim success%

   success = HighEdit.He.ReplaceSel(txt$, 0)

End Sub

Function ReprintFileName() As String
'15Oct03 CKJ Written
'            Replaces the old constant CReprintFile$ which was hard coded to "C:\ascrep.rtf"
'27May11 TH Changed to try and make the file terminal specific (F0088129)


Dim drvpth$, TerminalName$

   drvpth$ = terminal$("LocalFilePath", "c:")                 'Is path specified?
   'If InStr(1, drvpth$, "%TERMINAL%", 1) Then                 'Is terminal name wanted?
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

         TerminalName$ = Left$(TerminalName$, 8)
         If Len(TerminalName$) = 0 Then TerminalName$ = "DEFAULT"
   If InStr(1, drvpth$, "%TERMINAL%", 1) Then '27May11 TH Moved form above as we will alwalys now use the terminal name if possible in the filename
         replace drvpth$, "%TERMINAL%", TerminalName$, True   'case insensitive replace
      End If
   If Right$(drvpth$, 1) = "\" Then drvpth$ = Left$(drvpth$, Len(drvpth$) - 1)

   'ReprintFileName = drvpth$ & "\ascreprn.rtf"
   ReprintFileName = drvpth$ & "\ascreprn_ " & TerminalName$ & ".rtf"  '27May11 TH Replaced above

End Function

Function SaveWholeDoc(Action%, pathfile$, txt$) As Integer
'Action 1 Save file to temp file name, read & return in txt$, del temp file
'          PathFile ignored, txt$ filled on return. If fails txt$ unchanged
'       2 Save file to specified file name,
'          PathFile holds file name, txt$ ignored
'Returns success True/False

Dim success%, fil$

   Select Case Action
      Case 1
         MakeLocalFile fil$
         success = HighEdit.He.SaveDoc(fil$, FILEFORMAT_RTF)      'success = HighEdit.HE.SaveDoc(pathfile$, OF_DEFHESAVE, FILEFORMAT_RTF)
         If success Then GetTextFile fil$, txt$, success
         Kill fil$
      Case 2
         success = HighEdit.He.SaveDoc(pathfile$, FILEFORMAT_RTF)     'success = HighEdit.HE.SaveDoc(pathfile$, OF_DEFHESAVE, FILEFORMAT_RTF)
      Case Else
         popmessagecr "SaveWholeDoc", "Called with invalid Action = " & Format$(Action)
         success = False
      End Select

   SaveWholeDoc = success
   
End Function

Public Sub SelectPrinterFromContext(Context$, PrinterDriverPort$)
'12Jan98 CKJ Written
'Given Context$, choose a printer if one has not been allocated already
'Returns PrinterDriverPort$ chosen, or "" if user doesn't select one
'25Mar10 CKJ Added Citrix override - allow NExx: to be changed to NEyy: for the same printer name and driver  (RCN P0007 F0081840)

Dim term$, prompt$, allcontexts$, i%

   PrinterDriverPort = terminal(Context$, "")       'read printer for this term/context
   PrinterDriverPort = CitrixOverridePrinterPort(PrinterDriverPort)  '25Mar10 CKJ Added
   
   If PrinterDriverPort = "" Then
         term$ = ASCTerminalName()                   'force terminal to be named
         prompt$ = terminal(Context$ & "Prompt", "")
         ChooseDevice "", PrinterDriverPort$, False
         
         '17Sep10 CKJ Now used for ExternalPrinting, so setting here is not valid
         'If Len(PrinterDriverPort$) > 0 Then         'set it
         '       i = SetSpecifiedPrinter(PrinterDriverPort$)
         '    End If
         
         If Len(Context$) > 0 And Len(PrinterDriverPort$) > 0 Then 'save it
               'Add this context and printer to the user's terminal
               WritePrivateIniFile term$, Context$, PrinterDriverPort$, dispdata$ & "\TERMINAL.INI", 0
               'Add this context to [default] PrintContexts if not already there
               allcontexts$ = terminal("PrintContexts", "")
               If InStr("," & UCase$(allcontexts$) & ",", "," & UCase$(Context$) & ",") = 0 Then
                     WritePrivateIniFile "Default", "PrintContexts", allcontexts$ & "," & Context$, dispdata$ & "\TERMINAL.INI", 0
                  End If
               FlushIniCache     '28Jun00 JN Added
            End If
      End If

End Sub

Private Function CitrixOverridePrinterPort(ByVal PrinterDriverPort As String) As String
'25Mar10 CKJ Citrix may allocate a different port to the same terminal's printer on subsequent Citrix sessions
'            If a printer is specified, check whether the port requested exists.
'            If not, check if the same Printer & Driver exist on a different port. (Checks are not case sensitive)
'            If so, then replace original Port with the one associated with the printer in this session,
'            otherwise return empty string, and allow calling routine to ask user or use default as desired.
'            Eg original printer Port may have been "Ne01:" but Citrix has now allocated "Ne02:" or "Ne74:" etc
'            Facility is optional, and should only be enabled for terminals which are actually Citrix virtual machines.
'            This can be done for individual terminals, or set as the departmental default (and overridden on an individual basis)
'            To enable set CitrixOverridePrinterPort="Y" in terminal section of wConfiguration, settings are Y/N/1/0/-1, default "N"
'            Logging is available but should not be turned on for the whole department, nor left on permanently.
'            To enable set CitrixOverridePrinterPortLog="Y" in terminal section of wConfiguration, settings are Y/N/1/0/-1, default "N"
'            Log is written to SQL table WPharmacyLog with 'CitrixOverridePrinterPort' as the designation          (RCN P0007 F0081840)

Dim sTemp As String
Dim sPrinterDriverPort As String
Dim Prn As Printer
Dim valid As Boolean
Dim sLogfile As String

   sPrinterDriverPort = PrinterDriverPort
   If PrinterDriverPort <> "" Then
      If TrueFalse(terminal("CitrixOverridePrinterPort", "N")) Then
         valid = False
         For Each Prn In Printers         'is printer currently in the live list?
            If UCase$(sPrinterDriverPort) = UCase$(Prn.DeviceName & "," & Prn.DriverName & "," & Prn.Port) Then
               valid = True
               Exit For
            End If
         Next
         
         If Not valid Then                'is same printer + driver in the live list?
            For Each Prn In Printers
               If InStr(1, sPrinterDriverPort, Prn.DeviceName & "," & Prn.DriverName & ",", vbTextCompare) = 1 Then
                  valid = True
                  Exit For
               End If
            Next
                        
            If valid Then                 'found "printer,driver,*****"
               sPrinterDriverPort = Prn.DeviceName & "," & Prn.DriverName & "," & Prn.Port      'same printer & driver with new port
            Else                          'not found, return empty string
               sPrinterDriverPort = ""
            End If
                        
            If TrueFalse(terminal("CitrixOverridePrinterPortLog", "N")) Then
               WriteLogSQL "|Was|" & PrinterDriverPort & "|Now|" & sPrinterDriverPort & "|", "CitrixOverridePrinterPort", (valid), 0
            End If
         End If
      End If
   End If
   
   CitrixOverridePrinterPort = sPrinterDriverPort
   
End Function

Private Function SetSpecifiedPrinter(PrinterDriverPort$) As Integer
'12Jan98 CKJ Written
'Sets a printer for all windows in this HighEdit instance.
'Uses string with "Printer,driver,port" to identify the new printer:
'  e.g. "HP LaserJet III,HPPCL5MS,LPT1:"
'If an empty string is passed, the Windows standard printer is set.
'
'Returns  TRUE  if printer is set
'         FALSE if error occurs

   SetSpecifiedPrinter = HighEdit.He.SetInstancePrinter(PrinterDriverPort$)

   '31Mar10 CKJ added
   If TrueFalse(terminal("SetSpecifiedPrinterLog", "N")) Then
      WriteLogSQL "|" & PrinterDriverPort$ & "|", "SetSpecifiedPrinter", SetSpecifiedPrinter, 0
   End If

End Function

Sub TextToRTF(Action%, txt$, Info$)

'convert a plain text file into RTF format using HiEdit routines.
'Info$ is intended to pass in information about the calling program for display
'if there is an error.  It is displayed with the prefix "Called from "

'Action%:   1 - Convert file provided in Txt$ to RTF
'           2 - Convert Text provided in Txt$ to RTF$

'---------------------------------------------
'03Sep99 AE

Dim Loaded%, saved%, r$, fil$

   On Error GoTo TTRTFerr:

   Select Case Action
      Case 1                                'convert file to rtf
         fil$ = txt$
         If Not fileexists(fil$) Then Error 2100
         Hedit -2, ""       'load if not already loaded
         Loaded = HighEdit.He.LoadDoc(fil$, FILEFORMAT_ANSI)
         saved = HighEdit.He.SaveDoc(fil$, FILEFORMAT_RTF)

      Case 2                                 'convert txt into rtf
         If Len(txt$) Then
               Hedit -1, ""
               MakeLocalFile fil$
               PutTextFile fil$, txt$, saved
               Loaded = HighEdit.He.LoadDoc(fil$, FILEFORMAT_ANSI)
               If Not Loaded Then Error 2101
               saved = HighEdit.He.SaveDoc(fil$, FILEFORMAT_RTF)
               GetTextFile fil$, txt$, Loaded
               Kill fil$
            End If

      End Select
   
   If Not Loaded Then Error 2101
   If Not saved Then Error 2102


TTRTFexit:
                                  
   Hedit -3, ""
   Exit Sub

TTRTFerr:
   
   Select Case Err
      Case 2100
         r$ = "Error in TextToRTF: Could not find file " & fil$ & cr$
      Case 2101
         r$ = "Error in TextToRTF: Could not load file " & fil$
      Case 2102
         r$ = "Error in TextToRTF: Could not save file " & fil$ & cr$
      Case Else
         r$ = "Error in TextToRTF: " & Format$(Err) & ": " & Error$ & cr$
      End Select
   
   If Info$ <> "" Then r$ = r$ & "Called from : " & Info$ & cr$
   popmessagecr "EMIS Health", r$
      
   Resume TTRTFexit

End Sub

Sub CopyFileToChannel(FromFile$, oChan%)

Dim RecLen%, iChan%, readlen&, records&, remainder%, rec&, buffer$, ErrNum%
          
   If fileexists(FromFile) Then
         RecLen = 1024 * 10

         Do
            On Error GoTo CopyFileToChannel_Err
            ErrNum = False
            iChan = FreeFile
            Open FromFile$ For Binary Access Read Write Lock Read Write As #iChan
            Err70msg ErrNum, "File"
         Loop While ErrNum
         On Error GoTo 0

         readlen& = LOF(iChan)
         records& = readlen& \ RecLen             ' whole chunks of 10K
         remainder = readlen& - records& * RecLen ' bit of a record at end
         For rec& = 1 To records&
            buffer$ = Space$(RecLen)
            GoSub ReadRecord
            On Error GoTo CopyFileToChannel_Err
            Print #oChan, buffer$;
         Next
         If remainder Then
               'Rec& is 1 or incremented from last time
               buffer$ = Space$(remainder)
               GoSub ReadRecord
               On Error GoTo CopyFileToChannel_Err
               Print #oChan, buffer$;
            End If
''         FlushBuffers oChan    Not feasible under VB6 - file channel is not exposed

         Close iChan
      End If
   On Error GoTo 0
Exit Sub
      
ReadRecord:
   Do
      On Error GoTo CopyFileToChannel_Err
      ErrNum = False
      Get #iChan%, (rec& - 1) * RecLen + 1, buffer$
      Err70msg ErrNum, "Record"
   Loop While ErrNum
Return

CopyFileToChannel_Err:
   ErrNum = Err
   If ErrorHandler(ErrNum, "WDFHL", "Copy") = 1 Then Resume Next
                                     
End Sub


Sub OverrideLayout(ByVal Context As String)
'01Mar06 CKJ written
'            Override the orientation and/or margins on a per print context basis
'            Multiple print contexts can share the same settings, eg all small label contexts

Dim strSection As String
Dim strAttribute As String
Dim PhysicalMarginTop As Integer
Dim PhysicalMarginLeft As Integer
Dim strValue As String
Dim result As Integer
Dim intloop As Integer
                        
   strSection = Trim$(Context)
   If Len(strSection) Then
      HighEdit.He.GetPhysicalMargins PhysicalMarginLeft, PhysicalMarginTop       'retrieve in case needed
      strSection = "Context:" & terminal("Context" & strSection, strSection)
      If Len(strSection) Then
         Select Case Left$(UCase$(TxtD(dispdata$ & "\terminal.ini", strSection, "", "Orientation", 0)), 1)
            Case "P": HighEdit.He.SetOrientation = 0       'force Portrait
            Case "L": HighEdit.He.SetOrientation = 1       'force Landscape
            End Select
         For intloop = 1 To 4
            strAttribute = "Margin" & Choose(intloop, "Top", "Left", "Right", "Bottom")
            strValue = LCase$(TxtD(dispdata$ & "\terminal.ini", strSection, "", strAttribute, 0))
            Select Case strValue
               Case ""
                  'no action
               Case "physical"
                  Select Case intloop
                     Case 1: HighEdit.He.TopMargin = PhysicalMarginTop / 1000
                     Case 2: HighEdit.He.LeftMargin = PhysicalMarginLeft / 1000
                     Case Else: popmessagecr ".", "Right and bottom margins cannot be set to a 'physical' limit, setting ignored"
                     End Select
               Case Else
                  If IsNumber(strValue, False) Then
                     Select Case intloop
                        Case 1: HighEdit.He.TopMargin = Val(strValue)
                        Case 2: HighEdit.He.LeftMargin = Val(strValue)
                        Case 3: HighEdit.He.RightMargin = Val(strValue)
                        Case 4: HighEdit.He.BottomMargin = Val(strValue)
                        End Select
                  Else
                     popmessagecr "!", "Invalid Terminal setting for " & strSection & ", " & strAttribute & ": '" & strValue & "'"
                  End If
               End Select
         Next
      End If
   End If

End Sub
Sub setHETag(ByVal strHETag As String)
'22Oct09 TH Written
   m_strHETag = strHETag
End Sub

Function getHETag() As String
'22Oct09 TH Written
   getHETag = m_strHETag
End Function

Sub DeferredPrintingLog(ByVal strText As String, ByVal State As Integer, ByVal thread As Integer)
'31Mar10 CKJ written

   If TrueFalse(terminal("DeferredPrintingLog", "N")) Then
      WriteLogSQL "|" & strText & "|", "DeferredPrinting", State, thread
   End If

End Sub

Function ExternalPrint(ByVal ContextPathfile As String) As Boolean
'17Sep10 CKJ written

Dim NewPrinterDriverPort As String
Dim posn As Integer
Dim Context As String
Dim pathfile As String
Dim success As Boolean

   success = False
   pathfile = ContextPathfile                         'only valid for 'pathfile' or '<nul>pathfile'
   posn = InStr(ContextPathfile, Chr$(0))             'context<nul>pathfile' or '<nul>pathfile'
   If posn Then
      Context = Left$(ContextPathfile, posn - 1)
      pathfile = Mid$(ContextPathfile, posn + 1)
   End If
   
   If Not fileexists(pathfile) Then                   'original' version put message into printed document using HighEdit
      popmessagecr ".Unable To Print", "File " & UCase(pathfile) & " does not exist." & crlf & "Please contact your system supervisor."
   Else
      NewPrinterDriverPort = ""
      SelectPrinterFromContext Context, NewPrinterDriverPort
      success = RunExternalPrintJob(pathfile, NewPrinterDriverPort, PrepareOverrideLayout(Context))
   End If
   
   ExternalPrint = success

End Function

Function PrepareOverrideLayout(ByVal Context As String) As String
'01Mar06 CKJ written
'            Override the orientation and/or margins on a per print context basis
'            Multiple print contexts can share the same settings, eg all small label contexts
'17Sep10 CKJ Modified to generate string for external use, not to use HE directly

Dim strSection As String
Dim strAttribute As String
Dim PhysicalMarginTop As Integer
Dim PhysicalMarginLeft As Integer
Dim strValue As String
Dim result As Integer
Dim intloop As Integer
Dim strSettings As String
   
   strSection = Trim$(Context)
   If Len(strSection) Then
      strSection = "Context:" & terminal("Context" & strSection, strSection)
      If Len(strSection) Then
         strValue = Left$(UCase$(TxtD(dispdata$ & "\terminal.ini", strSection, "", "Orientation", 0)), 1)
         Select Case strValue
            Case "P", "L"        'no action
            Case Else            'not valid
               strValue = ""
            End Select
         strSettings = strValue
         
         For intloop = 1 To 4
            strAttribute = "Margin" & Choose(intloop, "Top", "Left", "Right", "Bottom")
            strValue = LCase$(TxtD(dispdata$ & "\terminal.ini", strSection, "", strAttribute, 0))
            Select Case strValue
               Case ""
                  'no action
               Case "physical"
                  Select Case intloop
                     Case 1, 2: strValue = "P"
                     Case Else: strValue = ""
                     End Select
               Case Else
                  If Not IsNumber(strValue, False) Then
                     strValue = ""
                  End If
               End Select
            strSettings = strSettings & "|" & strValue
         Next
      End If
   End If

   PrepareOverrideLayout = strSettings
   
End Function

Function RunExternalPrintJob(ByVal pathfileext As String, ByVal PrinterDriverPort As String, ByVal OverrideOptions As String) As Boolean
'20Sep10 CKJ written - taken from
'support.microsoft.com/kb/129796
'Returns success T/F, where a 5 second timeout from the print job is still treated as success
'28Sep10 CKJ Added config prefix & 1 minute timeout
  
   RunExternalPrintJob = ExecBlockingCommand("ExternalPrinting", App.Path & "\AscribePrintJob.exe " & pathfileext & "|" & PrinterDriverPort & "|" & OverrideOptions, 60000)
  
End Function
        
Private Function ExecBlockingCommand(ByVal TerminalPrefix As String, ByVal cmdline As String, ByVal millisecsTimeout As Long) As Boolean
'20Sep10 CKJ written - taken directly from
'support.microsoft.com/kb/129796
'support.microsoft.com/kb/191584
'support.microsoft.com/kb/176391
'support.microsoft.com/kb/129797
'plus information from
'undim.blogspot.com/2006/08/simulate-multithreading-with.html
'GetExitCodeProcess not implemented because VB runtime (in standard usage) does not return an exit code.
'28Sep10 CKJ Updated, added messages & configurable timeout (milliseconds, -1 for infinite wait)
'15Dec10 CKJ Added basic error trap & extra param on ConditionalMessage

Dim Proc As PROCESS_INFORMATION
Dim start As STARTUPINFO
Dim ret As Long
Dim success As Boolean
   success = False
   On Error GoTo ExecBlockingCommandErr
   
   ' Initialize the STARTUPINFO structure:
   start.cb = Len(start)
   ret = 0
   ' Start the shelled application:
   ret = CreateProcess(vbNullString, cmdline$, 0&, 0&, 1&, NORMAL_PRIORITY_CLASS, 0&, vbNullString, start, Proc)
   If ret <> 0 Then           '0 if process is unable to start
      ' Wait for the shelled application to finish:
      Select Case WaitForSingleObject(Proc.hProcess, millisecsTimeout)     'wait interval in millisecs, or -1 for infinite  28Sep10 CKJ 5s => param
         Case WAIT_TIMEOUT
            'The timeout is long enough for completion under normal circumstances.
            'We could continue waiting, since this is a blocking command, however
            'printing could occasionally take longer, eg connecting to remote queue
            'so here we allow return to main program with success=true
            
            '28Sep10 CKJ Revised. Returning true is only partially acceptable,
            'since the main program will proceed to attempt to rename or delete
            'the temp file, possibly while it is still in use externally. This
            'can give rise to a path/file access error.
            'Similarly, returning false will cause the original HEdit routine to
            'attempt a normal printing of the same locked file. Conversely the
            'external routine may be unable to open/load the file if it has been
            'dealt with in the main program already. Either way, it seems better
            'to inform the user after a much longer delay than 5 secs, then any
            'subsequent messages will be to some degree expected.
            'Now returns success = false, since this is more likely to print.
            ConditionalMessage TerminalPrefix, "WaitTimeout", cmdline, True
         Case WAIT_FAILED
            ConditionalMessage TerminalPrefix, "WaitFailed", cmdline, True
         Case WAIT_ABANDONED
            ConditionalMessage TerminalPrefix, "WaitAbandoned", cmdline, True
         Case WAIT_OBJECT_0      'The object has been signalled, application has ended
            success = True
         Case Else
            ConditionalMessage TerminalPrefix, "UnknownError", cmdline, True
         End Select
         
      'Call GetExitCodeProcess(proc.hProcess, ret)          'not required when calling a VB exe, since exit codes are not available
      Call CloseHandle(Proc.hThread)
      Call CloseHandle(Proc.hProcess)
   Else
      ConditionalMessage TerminalPrefix, "NotStarted", cmdline, True
   End If
   
ExecBlockingCommandExit:
   On Error GoTo 0
   ExecBlockingCommand = success
Exit Function

ExecBlockingCommandErr:
   ConditionalMessage TerminalPrefix, "Error", Format$(Err) & "," & Error$ & "," & cmdline, True
Resume ExecBlockingCommandExit

End Function

Private Sub ConditionalMessage(ByVal TerminalPrefix As String, ByVal TerminalCode As String, ByVal LogOnlyText As String, ByVal ShowByDefault As Boolean)
'28Sep10 CKJ written
'            basic message displayed if showbydefault is true
'            message can be changed in Terminal settings (preferably default section) or disabled by setting to ""
'            no message shown if showbydefault is false and Terminal setting is absent or set to ""
'15Dec10 CKJ Added LogOnlyText and writelog

Dim msg As String

   msg = ""
   If ShowByDefault Then
      msg = "Error while running external program: " & TerminalPrefix & " " & TerminalCode               'basic message as default
   End If
   
   msg = terminal(TerminalPrefix & "Msg" & TerminalCode, msg)                                            'configurable message (or blank)
   ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg, False                                       'replace [cr]
   If Len(msg) Then                                                                                      'show if non-blank
      popmessagecr "." & TerminalPrefix, msg
   End If

   WriteLogSQL "|" & TerminalPrefix & TerminalCode & "|" & LogOnlyText & "|", "ConditionalMessage", Iff(Len(msg), 1, 0), 0
   
End Sub

Sub parseRTFFromAdditionalHeap(ByVal InFile$, OutFile$, intHeapID)
'---------------------------------------------------------------------------------------------------------------
' 04Mar14 TH Written bassed on ParseRtf to allow parsing against an additional heap as well as the global print
'            heap
'22Jan21  AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22
'---------------------------------------------------------------------------------------------------------------

Dim Changed%, Chunk$, Buf$, Completed%, outchan%, openbrace&, closebrace&, char$, middle$   'MM-4782
Dim secondopenbrace&    'MM-4782
   
   Screen.MousePointer = HOURGLASS
   OutFile$ = ""
   If fileexists(InFile$) Then
         Buf$ = ""
         Completed = False
         MakeLocalFile OutFile$
         outchan = FreeFile
         Open OutFile$ For Output As #outchan

         Do
            Changed = False
            If Len(Buf$) < 10000 And Completed = False Then
                  GetFileByChunk InFile$, 10000, Chunk$, Completed
                  If Completed = 1 Then Exit Do           'InFile is unusable so quit
                  Buf$ = Buf$ & Chunk$
                  Changed = True
               End If

            If Len(Buf$) Then
                  Do
                     openbrace = InStr(Buf$, "[")
                     If openbrace > 1 Then                'store all text in front of the [
                           Print #outchan, Left$(Buf$, openbrace - 1);
                           Buf$ = Mid$(Buf$, openbrace)
                           openbrace = 1                  'only has values 0 and 1 beyond here
                        ElseIf openbrace = 0 Then         'no [ at all, so just store it
                           Print #outchan, Buf$;
                           Buf$ = ""
                        End If
                     closebrace = 0
                     If openbrace Then closebrace = InStr(openbrace + 1, Buf$, "]")
                     If closebrace > openbrace And openbrace > 0 Then
                           middle$ = Mid$(Buf$, openbrace + 1, closebrace - openbrace - 1)
                           char$ = "[" & middle$ & "]"
                           secondopenbrace = InStr(middle$, "[") '09Oct98 CKJ added extra check
                           If secondopenbrace Then              '            for open-open-close
                                 Print #outchan, Left$(Buf$, secondopenbrace);
                                 Buf$ = Mid$(Buf$, secondopenbrace + 1)
                              Else
                                 If Left$(LCase$(middle$), 9) = "#include" & TB Then
                                       'include a whole file here direct to output file
                                       CopyFileToChannel Mid$(middle$, 10), outchan
                                       char$ = ""
                                       Changed = True
                                    Else                        'pass through including []
                                       ParseItems gPRNheapID, char$, Changed
                                       ParseItems intHeapID, char$, Changed
                                       ParseCtrlChars dispdata$ & "\printer.ini", "RTF", char$, Changed
                                    End If
      
                                 If char$ = "[" & middle$ & "]" Then         'failed to expand
                                       Print #outchan, Left$(Buf$, closebrace);
                                       Buf$ = Mid$(Buf$, closebrace + 1)
                                    Else                                     'did expand
                                       Buf$ = char$ & Mid$(Buf$, closebrace + 1)
                                       Changed = True
                                    End If
                              End If
                        '09Oct98 CKJ Added check for a single [ without a following ] in view
                        ElseIf openbrace = 1 And closebrace = 0 And (Completed Or Len(Buf$) >= 10000) Then 'closing ] must be within 10K chars of the [
                           Print #outchan, Buf$;     'rogue [ with no ], and either finished reading the file, or chunk in memory is 10K+ chars long
                           Buf$ = ""
                        End If
                  Loop While openbrace > 0 And closebrace > 0
               End If
         Loop While Changed = True Or Completed = False
         Close outchan
         Screen.MousePointer = STDCURSOR

         If Completed = 1 Then
               popmessagecr "!", "Unable to use file " & InFile$ & cr & "It may be locked or in use by another program"
               OutFile$ = ""
            End If

      Else
         Screen.MousePointer = STDCURSOR
         popmessagecr "!", "Unable to open file " & InFile$ & cr & "It may be missing or inaccessible"
      End If
         
End Sub

Sub parseRTFfromDB(ByVal InFile$, OutFile$)
'---------------------------------------------------------------------------------------------------------------
'03Jan17 TH Written based on ParseRTF
'           It still uses a local file to output to, but reads rtf from the DB
'24Jan17 TH Convert chunk counter to long for calculation (TFS 174587)
'02Feb17 TH Added section to allow inclusion of local file (not from DB) on #includx (TFS 175474)
'           This is a bit of a sticking plaster to handle some local data handling on the alternative label
'           List report (TFS 175474)
'06Feb17 TH Added silent running setting for DB #include for backward compatibility (TFS 175148)
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22
'---------------------------------------------------------------------------------------------------------------

Dim Changed%, Chunk$, Buf$, Completed%, outchan%, openbrace&, closebrace&, char$, middle$   'MM-4782
Dim secondopenbrace&    'MM-4782
Dim strRTFText As String
Dim intSuccess As Integer
Dim strRTFincludeText As String
Dim intChunk As Integer
   
   Screen.MousePointer = HOURGLASS
   OutFile$ = ""
   intChunk = 0
   'Get the rtf from the DB then send the test through in "Chunks"
   GetRTFTextFromDB InFile$, strRTFText, intSuccess  '06Dec16 TH Replaced (TFS 157969)
   
   'If fileexists(InFile$) Then
   If intSuccess Then
         Buf$ = ""
         Completed = False
         MakeLocalFile OutFile$
         outchan = FreeFile
         Open OutFile$ For Output As #outchan

         Do
            Changed = False
            If Len(Buf$) < 10000 And Completed = False Then
                  'GetFileByChunk InFile$, 10000, Chunk$, Completed
                  'Simple replacement for above - after discussion with CKJ retain chunking handling of rtf
                  'Do we have a whole chunk ?
                  'If 10000 * (intChunk + 1) >= Len(strRTFText) Then
                  If 10000 * (CLng(intChunk) + 1) >= Len(strRTFText) Then  '24Jan17 TH Convert to long for calculation (TFS 174587)
                     'We will have no more after this, just get the last bit
                     'Chunk$ = Mid$(strRTFText, (10000 * (intChunk)) + 1)
                     Chunk$ = Mid$(strRTFText, (10000 * CLng(intChunk)) + 1) '24Jan17 TH Convert to long for calculation (TFS 174587)
                     Completed = True
                  Else
                     'Take a chunk and increment the chunk marker for next pass - we have more to do
                     'Chunk$ = Mid$(strRTFText, (10000 * (intChunk)) + 1, 10000)
                     Chunk$ = Mid$(strRTFText, (10000 * CLng(intChunk)) + 1, 10000) '24Jan17 TH Convert to long for calculation (TFS 174587)
                     intChunk = intChunk + 1
                  End If
                  
                  
                  If Completed = 1 Then Exit Do           'InFile is unusable so quit
                  Buf$ = Buf$ & Chunk$
                  Changed = True
               End If

            If Len(Buf$) Then
                  Do
                     openbrace = InStr(Buf$, "[")
                    If openbrace > 1 Then                'store all text in front of the [
                        Print #outchan, Left$(Buf$, openbrace - 1);
                           Buf$ = Mid$(Buf$, openbrace)
                        openbrace = 1                  'only has values 0 and 1 beyond here
                    ElseIf openbrace = 0 Then         'no [ at all, so just store it

                        'If (InStr(1, InFile$, "pil.rtf")) > 0 Then     'Commented -MM - 3989, Required in future version
                        'Buf$ = "\rtf1" + Trim(Buf$)                    'Commented -MM - 3989, Required in future version
                        'Print #outchan, Buf$;                          'Commented -MM - 3989, Required in future version
                        'Else                                           'Commented -MM - 3989, Required in future version
                        Print #outchan, Buf$;
                        'End If                                         'Commented -MM - 3989, Required in future version
                         Buf$ = ""
                    End If
                     closebrace = 0
                     If openbrace Then closebrace = InStr(openbrace + 1, Buf$, "]")
                     If closebrace > openbrace And openbrace > 0 Then
                           middle$ = Mid$(Buf$, openbrace + 1, closebrace - openbrace - 1)
                           char$ = "[" & middle$ & "]"
                           secondopenbrace = InStr(middle$, "[") '09Oct98 CKJ added extra check
                           If secondopenbrace Then              '            for open-open-close
                                 Print #outchan, Left$(Buf$, secondopenbrace);
                                 Buf$ = Mid$(Buf$, secondopenbrace + 1)
                              Else
                                 If Left$(LCase$(middle$), 9) = "#include" & TB Then
                                    'include a whole file here direct to output file
                                    'CopyFileToChannel Mid$(middle$, 10), outchan
                                    '03Jan17 TH This requires a new mod to read file from the DB - replace above
                                    'GetRTFTextFromDB Mid$(middle$, 10), strRTFincludeText, intSuccess  '06Dec16 TH Replaced (TFS 157969)
                                    GetRTFTextFromDB Mid$(middle$, 10), strRTFincludeText, intSuccess, True '06Feb17 TH Added silent running setting for backward compatibility (TFS 175148)
                                    'write strRTFincludeText to out file
                                    If intSuccess Then Print #outchan, strRTFincludeText
                                    char$ = ""
                                    Changed = True
                                 ElseIf Left$(LCase$(middle$), 9) = "#includx" & TB Then  '02Feb17 TH Added section to allow inclusion of local file (not from DB) (TFS 175474)
                                    'include a whole file here direct to output file
                                    CopyFileToChannel Mid$(middle$, 10), outchan
                                    '03Jan17 TH This requires a new mod to read file from the DB - replace above
                                    'GetRTFTextFromDB Mid$(middle$, 10), strRTFincludeText, intSuccess  '06Dec16 TH Replaced (TFS 157969)
                                    'write strRTFincludeText to out file
                                    'If intSuccess Then Print #outchan, strRTFincludeText
                                    char$ = ""
                                    Changed = True
                                 Else                        'pass through including []
                                    Call ParseItems(gPRNheapID, char$, Changed)
                                    ParseCtrlChars dispdata$ & "\printer.ini", "RTF", char$, Changed
                                 End If
      
                                 If char$ = "[" & middle$ & "]" Then         'failed to expand
                                       Print #outchan, Left$(Buf$, closebrace);
                                       Buf$ = Mid$(Buf$, closebrace + 1)
                                    Else                                     'did expand
                                       Buf$ = char$ & Mid$(Buf$, closebrace + 1)
                                       Changed = True
                                    End If
                              End If
                        '09Oct98 CKJ Added check for a single [ without a following ] in view
                        ElseIf openbrace = 1 And closebrace = 0 And (Completed Or Len(Buf$) >= 10000) Then 'closing ] must be within 10K chars of the [
                           Print #outchan, Buf$;     'rogue [ with no ], and either finished reading the file, or chunk in memory is 10K+ chars long
                           Buf$ = ""
                        End If
                  Loop While openbrace > 0 And closebrace > 0
               End If
         Loop While Changed = True Or Completed = False
         Close outchan
         Screen.MousePointer = STDCURSOR

''         If Completed = 1 Then
''               popmessagecr "!", "Unable to use file " & InFile$ & cr & "It may be locked or in use by another program"
''               OutFile$ = ""
''            End If

      Else
         Screen.MousePointer = STDCURSOR
         'popmessagecr "!", "Unable to open file " & InFile$ & cr & "It may be missing or inaccessible"
         popmessagecr "!", "Unable to Load rtf for " & InFile$ & cr & "It may be missing or inaccessible"
      End If
         
End Sub

Sub EditRTFFromDB(ByVal strPathfile As String, Optional ByVal strLogFile As String = "")
'10Jan17 TH Created new wrapper for editing rtf in Db (Hosted)
'30Jan17 TH Added Logging (For PN editors) (TFS 174973)

Dim strRTFText As String
Dim strRTFTextCopy As String
Dim strRTFName As String
Dim lngOK As Long
Dim strLogText As String


   strRTFName = GetFileNameFromPath(strPathfile)

   strRTFText = getPharmacyRTFfromSQL(strPathfile, strRTFName)
   strRTFTextCopy = strRTFText
   Hedit 1, strRTFText
   If strRTFTextCopy <> strRTFText Then
      'Now save to DB
      lngOK = WritePharmacyRTFToSQL(strPathfile, strRTFName, strRTFText)
      'Log if required
      If strLogFile <> "" Then
         strLogText = "Edited layout RTF " & strRTFName                       '05Jun00 CKJ added !!** keep copy?
         WriteLog dispdata$ & "\PNedit.log", 0, UserID$, strLogText
      End If
   End If
   
End Sub

Sub parseRTFFromDBFromAdditionalHeap(ByVal InFile$, OutFile$, intHeapID)
'-------------------------------------------------------------------------------------------------------------
' 12Jan12 TH Written bassed on parseRTFFFromAdditionalHeap to use rtf dtat from DB
' 24Jan17 TH Convert chunk counter to long for calculation (TFS 174587)
' 06Feb17 TH Added silent running setting for DB #include for backward compatibility (TFS 175148)
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22
'-------------------------------------------------------------------------------------------------------------

Dim Changed%, Chunk$, Buf$, Completed%, outchan%, openbrace&, closebrace&, char$, middle$
Dim secondopenbrace&
Dim strRTFText As String
Dim intSuccess As Integer
Dim strRTFincludeText As String
Dim intChunk As Integer
   
   Screen.MousePointer = HOURGLASS
   OutFile$ = ""
   'Get the rtf from the DB then send the test through in "Chunks"
   GetRTFTextFromDB InFile$, strRTFText, intSuccess
   
   If intSuccess Then
      Buf$ = ""
      Completed = False
      MakeLocalFile OutFile$
      outchan = FreeFile
      Open OutFile$ For Output As #outchan

      Do
         Changed = False
         If Len(Buf$) < 10000 And Completed = False Then
            'GetFileByChunk InFile$, 10000, Chunk$, Completed
            'Simple replacement for above - after discussion with CKJ retain chunking handling of rtf
            'Do we have a whole chunk ?
            'If 10000 * (intChunk + 1) >= Len(strRTFText) Then
            If 10000 * (CLng(intChunk) + 1) >= Len(strRTFText) Then '24Jan17 TH Convert chunk counter to long for calculation (TFS 174587)
               'We will have no more after this, just get the last bit
               'Chunk$ = Mid$(strRTFText, (10000 * (intChunk)) + 1)
               Chunk$ = Mid$(strRTFText, (10000 * CLng(intChunk)) + 1) '24Jan17 TH Convert chunk counter to long for calculation (TFS 174587)
               Completed = True
            Else
               'Take a chunk and increment the chunk marker for next pass - we have more to do
               'Chunk$ = Mid$(strRTFText, (10000 * (intChunk)) + 1, 10000)
               Chunk$ = Mid$(strRTFText, (10000 * CLng(intChunk)) + 1, 10000) '24Jan17 TH Convert chunk counter to long for calculation (TFS 174587)
               intChunk = intChunk + 1
            End If
            
            
            If Completed = 1 Then Exit Do           'InFile is unusable so quit
            Buf$ = Buf$ & Chunk$
            Changed = True
         End If

         If Len(Buf$) Then
            Do
               openbrace = InStr(Buf$, "[")
               If openbrace > 1 Then                'store all text in front of the [
                     Print #outchan, Left$(Buf$, openbrace - 1);
                     Buf$ = Mid$(Buf$, openbrace)
                     openbrace = 1                  'only has values 0 and 1 beyond here
                  ElseIf openbrace = 0 Then         'no [ at all, so just store it
                     Print #outchan, Buf$;
                     Buf$ = ""
                  End If
               closebrace = 0
               If openbrace Then closebrace = InStr(openbrace + 1, Buf$, "]")
               If closebrace > openbrace And openbrace > 0 Then
                  middle$ = Mid$(Buf$, openbrace + 1, closebrace - openbrace - 1)
                  char$ = "[" & middle$ & "]"
                  secondopenbrace = InStr(middle$, "[") '09Oct98 CKJ added extra check
                  If secondopenbrace Then              '            for open-open-close
                     Print #outchan, Left$(Buf$, secondopenbrace);
                     Buf$ = Mid$(Buf$, secondopenbrace + 1)
                  Else
                     If Left$(LCase$(middle$), 9) = "#include" & TB Then
                        'include a whole file here direct to output file
                        'CopyFileToChannel Mid$(middle$, 10), outchan
                        '03Jan17 TH This requires a new mod to read file from the DB - replace above
                        'GetRTFTextFromDB Mid$(middle$, 10), strRTFincludeText, intSuccess  '06Dec16 TH Replaced (TFS 157969)
                        GetRTFTextFromDB Mid$(middle$, 10), strRTFincludeText, intSuccess, True  '06Feb17 TH Added silent running setting for DB #include for backward compatibility (TFS 175148)
                        
                        'write strRTFincludeText to out file
                        If intSuccess Then Print #outchan, strRTFincludeText
                        char$ = ""
                        Changed = True
                     Else                        'pass through including []
                        ParseItems gPRNheapID, char$, Changed
                        ParseItems intHeapID, char$, Changed
                        ParseCtrlChars dispdata$ & "\printer.ini", "RTF", char$, Changed
                     End If

                     If char$ = "[" & middle$ & "]" Then         'failed to expand
                        Print #outchan, Left$(Buf$, closebrace);
                        Buf$ = Mid$(Buf$, closebrace + 1)
                     Else                                     'did expand
                        Buf$ = char$ & Mid$(Buf$, closebrace + 1)
                        Changed = True
                     End If
                  End If
               '09Oct98 CKJ Added check for a single [ without a following ] in view
               ElseIf openbrace = 1 And closebrace = 0 And (Completed Or Len(Buf$) >= 10000) Then 'closing ] must be within 10K chars of the [
                  Print #outchan, Buf$;     'rogue [ with no ], and either finished reading the file, or chunk in memory is 10K+ chars long
                  Buf$ = ""
               End If
            Loop While openbrace > 0 And closebrace > 0
         End If
      Loop While Changed = True Or Completed = False
      Close outchan
      Screen.MousePointer = STDCURSOR

''         If Completed = 1 Then
''               popmessagecr "!", "Unable to use file " & InFile$ & cr & "It may be locked or in use by another program"
''               OutFile$ = ""
''            End If

   Else
      Screen.MousePointer = STDCURSOR
      'popmessagecr "!", "Unable to open file " & InFile$ & cr & "It may be missing or inaccessible"
      popmessagecr "!", "Unable to Load rtf for " & InFile$ & cr & "It may be missing or inaccessible"
   End If
         
End Sub

