'                            Ordering Programme
'ASC 14Dec92 comments in ordermnu.rem
'ASC 1Nov92  Checklossgain now after programme has made corrections
'ASC 10Nov92 Build of index now replaced with sort only before automatic order
'ASC 15Nov92 Many changes to cyclical ordering now does not require month end
'            procedures to work
'            - F4 info page enhanced
'            - F4 info page used to give info about other sites
'ASC 14Dec92 -PRNSTUBS set up to save memory. Received quantity of 0 now checked
'             for in reconciliation to stop overflow
'            -If anual use is -ve then it is made 0 during end of month calcs
'ASC  3Jan93 -Purchase price assumed at the point of ordering to be issue
'            price. This may cause less use of losses and gains when large
'            amounts are ordered from the approved (cheaper supplier) after
'            a small order was placed with a more expensive supplier.
'ASC  4Jan93 New suppliers are now saved first time
'10Jan93 ASC/CKJ Received from Chris some changes before separating
'            Now DELORD.EXE
' 8nov93 CKJ VBDOS: Uses ORDERS.INC include file, removed DIM statements for
'            items in the include file. NB Original code would not run or
'            compile in PDS 7.1 environment due to the Common mismatch.
'            Items waiting for reconciliation are now deleted only if
'            'delete x days after reconciling' is zero  ie turned off
'24Jan94 CKJ Retyped edits of 12Mar93: After copying live data in Delord,
'            write spaces to end of file to avoid incorrect reports in SNOW.
'            Modified original code to stop on reading a blank record.
'22Feb94 CKJ Mod to delord to handle each file separately
' 9Mar94 CKJ Sort all indexes not just some
' 5Mar95 CKJ Added command line option to delete all "R" type requisitions.
'24Mar95 CKJ Moved Close
'25May95 CKJ Simplified & tidied in preparation for history file
'01Aug96 EAC Added code to handle operation within Windows shell
'14Aug96 EAC/CKJ Delete delivery notes older than 7days and del reconciled items
'                even if the system does not normally reconcile
'28Oct96 CKJ Added tidy indices option:  Delord x /FULL /TidyOrdIdx
'                                        Delord x /FULL /TidyRecIdx
'                                        Delord x /FULL /TidyReqIdx
'            NB Add only one /TidyXxxIdx option to the command line.
'            NB Add /FULL if run from OwnMenu or a batch file otherwise
'               it will run IT.EXE on completion.
'20Feb98 CKJ Delord: Modem (Sitelink) orders, none issued needs deleting here
'26Nov98 CFY Added stub procedured : Function RestrictedView () As Integer
'03Dec98 TH  main: added call to tidyupreprints (moved from winord startup) on commandline /FULL and /TIDYREPRINTS
'03Dec98 TH  tidyupreprints: moved from winord startup to improve speed
'17May99 AE  TidyUpReprints: added rountines to scan for files and show progress bar.
'17May99 AE  ReadWriteDuration: Written
'17May99 AE  TidyStoreReprints: Modified. Now reads the file duration from wdelord.ini, using ReadWriteDuration,
'            rather than it being hard coded.
'17May99 AE  TidyDispReprints: Ditto
'19Oct99 AE  TidyUpReprints: Expanded error handling to write to the monthend log if running as the overnight job,
'            Or to screen if run from the menu manually.
'20Oct99 AE  TidyUpReprints:Corrected line looking for /login parameter
'11Oct99 CFY Added Freeflag% as global variable for compatability with orderlib.bas
'25Jan00 AE  Wdelord.bas:Added iDeleteDeliv and iDelordContext for new overnight job
'25Jan00 AE    CheckLogFiles:Additions for new overnight job.
'                 Added parameter iTestRun and associated code.
'25Jan00 AE    Delord:Various changes for new overnight job
'                 Added error handling for overnight job; wdelord behaves as before
'                 Corrected setting of progress.percent, plus other cosmetic changes.
'                 Added parameter iTestRUn and associated code
'                 Replaced reference to MDIEvents with iDeleteDeliv
'25Jan00 AE    DelordPrint:Now prints to MDIEvents or to frmOvernight depending on where the program
'                 is being run from. If printing to frmOvernight, Seg1-4 are printed separated by " , "
'25Jan00 AE    Main:Additions for new Overnight Job:
'                 Added parameter to call to Delord
'                 Added parameter to call to TidyDisp/StoreReprints
'                 Set iDeleteDeliv
'25Jan00 AE     TidyDispReprints:Corrected FilePath to look at the right path
'                 Also changed error handling to account for new overnight job
'25Jan00 AE    TidyStoreReprints:Corrected FilePath to look at the right path
'                 Also changed error handling to account for new overnight job
'25Jan00 AE    TidyUpReprints:Changes to call to progress for new overnight job.
'                 Added Parameter iTestRun and associated code.
'                 Added error handling for overnight job
'01Feb00 AE  CheckLogFiles:Changed calls to DirExists to DirExistsNoMsg.  Screen messages were causing this program
'            to stop when running as the overnigh
'01Feb00 AE  Delord:Slight change to code for test run. No longer blanks to end of file
'            except on live run
'02Feb00 AE  CheckogFiles:Reinstated line to check for null filename, which had been commented out in error
'              Added extra logging
'02Feb00 AE  Delord:Added extra logging for overnight job
'03Feb00 AE  Delord:Added more extra information for overnight job logs. Also save pointer values
'            in overnight.ini for future checking by the rest of the suite if required.
'03Feb00 AE  TidyUpReprints:Corrected info to show correct number of deleted files. Also added
'            extra logging if overnight job.
'10Feb00 AE  BuildOrdReqIndex:Prevent writelogs from firing if running new overnight job.
'11Feb00 AE  CheckLogFiles:Added same check to Case 4. Prevents error 64 on sites which had no patdata. Error
'            did not effect anything, but looked bad.
'11Feb00 AE  TidyUpReprints:Enhanced ONJ logging to say which files are being deleted
'24Mar00 GRS Main:Moved acquire lock so interactive mode does not lock DB until Password supplied. (Evt 41965)
'            bIsInteractive: Function returns false if app started with o/night param else true for interactive
'19May00 AE  Delord:Added code to simulate the "/inters" switch from the overnight job.  This
'            also allows the user to choose the number of days to keep inters.
'15Sep00 CFY Added OCXLaunch as stub function
'20Nov00 SF  added RxEditor: stub procedure
'22Nov00 EAC TidyStoresReprints: ReadWriteDuration: Handle Dispute Note Reprint Tidying
'17Jan01 TH  Delord: All status 7 reconcil records now retained unless over ridden by ini setting
'            (to protect data prior to AP run or coding slip printing)
'17Jan02 TH  Delord: Moved Inters deletion code to ensure it isnt nulled by mod to protect status 7 recs (these are exceptions) (#54070)
'17Jan02 TH  TidyDispReprints: Altered paths to reflect new reprint folder (#53403) and also a check that the directory exists
'17Jan02 TH  TidyDispReprints, ReadWriteDuration: Added new calls for PBS Clean up (#58302)
'30Apr02 CKJ Delord: Added code to remove totally null filled records and log the number culled
'23May02 CKJ Added switch to allow blanking to end of file. Create a file in dispdata
'            Wdelord1.asc, Wdelord2.asc, Wdelord3.asc, for each ordering file
'            Orders.v8, reconcil.v8 and requis.v8 respectively. Switch files are deleted
'            at the end of the run (but not used or deleted during a test run).
'01oct03 CKJ added brackets on ASCver(), removed the outstanding() array
'21May04 TH  main: Removed call to sethelp



'---------- requiring attention---------------
'
'supplier file needs binary indexing - done
'pointer needs locking when deleting for multi user - done
'must offer reindexing of supplier file  - does after a change
'SUP still param & struct in this module - done
'must allow suppliers to be deleted
' - warn if no order method in supfile when raising orders
' see Warning in Orderlib - Printpick and Selectforsupplier
'
' picking ticket numbers need changing to lock before accepted as printed
' ok in the same way as order numbers.


Option Explicit
DefInt A-Z

Global Const Inifile$ = "\wdelord.ini"
Const LogFilename$ = "\wdelord.log"

'DIM SHARED k AS kbdcontrol
Dim Shared D As drugparameters           '!! shared
Dim Shared r As filerecord
Dim Shared Ord As orderstruct
Dim Shared olog As orderlogstruct
Dim Shared RecNo%(21)                   'record number for current line
Dim mnu$(1 To 14), hlp(1 To 14)

Dim td As dateandtime
Dim dt As dateandtime
Dim xp As dateandtime
			  
Dim formloaded%

'10Oct97 EAC - added for compatability with Orderlib.bas
Global OrderNum$, OSite$, OASCcode$(), ORecNo&(), Oordering$(), PrintToScreen$
Global ordno$, Storepasslvl, sitepth$(0), sitenos(0), EditType%

Global iDeleteDeliv As Integer            '25Jan00 AE  Removes the need to reference MDIEevents directly in the overnight job
Global iDelordContext                     '     "      To direct screen output appropriately

'18Aug98 EAC stub variables
Global Reprintno%
Global picknumber%

Global FreeFlag%            '11Oct99 CFY

'30Mar99 AE  Reprint File Duration Variables
Const STORE_FILE_DUR = "10"            'Default file duration for stores reprints  (days)
Const DISP_FILE_DUR = "2"              'Default file duration for dispensary reprints

Sub askward (rod$, jane$, freddy%)
   '03Mar99 TH stub proc
End Sub

Function BillPatDispensQty (dummy1%, dummy2!, dummy3%, dummy4%)
'stub procedure
End Function

Function BillPatient (dummy1%, dummy2$)
'stub procedure

End Function

Function bIsInteractive (sCommand$) As Integer
'
'  Parameters sCommand$ - Supplied command line string
'
'             Returns     True if Interactive, False if Overnight
'
'24Mar00 GRS  Check to see whether the app is launched in interactive or overnight mode
'
   If InStr(1, sCommand$, "/TIDYORDIDX", 1) > 0 Then
	 bIsInteractive = False
      ElseIf InStr(1, Command$, "/TIDYRECIDX", 1) > 0 Then
	 bIsInteractive = False
      ElseIf InStr(1, Command$, "/TIDYREQIDX", 1) > 0 Then
	 bIsInteractive = False
      ElseIf InStr(1, Command$, "/TIDYSTOREREPRINTS", 1) > 0 Then
	 bIsInteractive = False
      ElseIf InStr(1, Command$, "/TIDYDISPREPRINTS", 1) > 0 Then
	 bIsInteractive = False
      ElseIf InStr(1, Command$, "/FULL", 1) > 0 Then
	 bIsInteractive = False
      Else
	 bIsInteractive = True
      End If

End Function

Sub buildordreqindex (EditType, rebuild)
'-----------------------------------------------------------------------------
' Rebuild True  => complete rebuild from original file
'         False => Sort & remove deleted items only
'9Mar94  CKJ Sort all indexes
'21Aug95 ASC Added pickno index and siteno index to requis.asc
'28Oct96 CKJ Moved filename block from inside 'If Rebuild ...'
'30Oct98 EAC Y2K changes applied to new filenames as follows;
'             ORDER.ASC    => ORDER.V8
'             RECONCIL.ASC => RECONCIL.V8
'             REQUIS.ASC   => REQUIS.V8
'
'             ORDER.IDX    => ORDCODE.IDX
'             ORDORDNO.IDX => ORDNUM.IDX
'
'             RECONCIL.IDX => RECCODE.IDX
'             RECORDNO.IDX => RECNUM.IDX
'
'             REQUIS.IDX   => REQCODE.IDX
'             REQORDNO.IDX => REQNUM.IDX
'             REQPICNO.IDX => REQPICK.IDX
'             REQSITNO.IDX => REQSITE.IDX
'-----------------------------------------------------------------------------
'26Jan99 EAC Changed Writelogs to write to the new Reindexing logfile
'10Feb00 AE  Prevent writelogs from firing if running new overnight job.


Dim stat$, optype$, entries$, temp$, recnum$, msg$
Dim endvar%, loopvar%, ErrNo%
Dim pointer&, x&


   ReDim filename$(1 To 4)
   ReDim title$(1 To 4)
   ReDim idxchan%(1 To 4)

   Select Case EditType                       '28Oct96 CKJ Moved from inside If Rebuild ...
      Case 1
	 filename$(1) = "\ORDCODE.IDX":    title$(1) = "Order Index"
	 filename$(2) = "\ORDNUM.IDX": title$(2) = "Order Number Index"
      Case 4
	 filename$(1) = "\RECCODE.IDX": title$(1) = "Reconciliation Index"
	 filename$(2) = "\RECNUM.IDX": title$(2) = "Reconciliation Number Index"
      Case 5
	 filename$(1) = "\REQCODE.IDX":   title$(1) = "Requisition Index"
	 filename$(2) = "\REQNUM.IDX": title$(2) = "Requisition Number Index"
	 filename$(3) = "\REQPICK.IDX": title$(3) = "Picking Ticket Number Index"         '21Aug95 ASC
	 filename$(4) = "\REQSITE.IDX": title$(4) = "Requisition Site Number Index"         '   "
      Case Else
	 popmessagecr "WARNING", "Pointer edit type not defined please inform system manager"
	 Exit Sub                                            ' <== WAY OUT
   End Select
	 
   If rebuild Then
	 optype$ = "rebuild"
      Else
	 optype$ = "reindex"
      End If
   
   endvar = 2
   If EditType = 5 Then endvar = 4
   
   For loopvar = 1 To endvar
      If iDelordContext <> 1 Then                                      '10Feb00 AE  Added for Overnight Job
	    Writelog GetIndexLogFileName$(), SiteNumber%, "", "WDELORD: Asked to " & optype$ & " file : " & filename$(loopvar)      '26Jan99 EAC changed writelog path
	 End If                                                        '      "
   Next
   
   If rebuild Then

	 getnumofords EditType, pointer&, False
	 DelordPrint "Re-Building : Scanning File for" & Str$(pointer& - 1) & " entries", "", "", ""


	 On Error Resume Next
	 For loopvar = 1 To endvar

	    idxchan(loopvar) = FreeFile
	    Open dispdata$ & filename$(loopvar) For Binary Access Write Lock Read Write As #idxchan(loopvar)
	    ErrNo = Err
	    If ErrNo > 0 Then
		  idxchan(loopvar) = 0
		  msg$ = "Error opening file : " & filename$(loopvar) & " Err = " & Format$(ErrNo) & " : " & Error$(ErrNo)
		  If formloaded Then popmsg "Error", msg$, 16, "", 0                                                 '26Jan99 EAC changed writelog path
		  If iDelordContext <> 1 Then                                      '10Feb00 AE  Added for Overnight Job
			Writelog GetIndexLogFileName$(), SiteNumber%, "", "WDELORD: " & msg$
		     End If                                                        '      "
	       End If

	 Next
	 
	 If idxchan(1) = 0 Or idxchan(2) = 0 Or (EditType = 5 And idxchan(3) = 0) Or (EditType = 5 And idxchan(4) = 0) Then    '13Oct97 EAC
	       For loopvar = 1 To endvar
		  Close #idxchan(loopvar)
	       Next
	       msg$ = "Aborting Rebuild"
	       If formloaded Then popmsg "Error", msg$, 16, "", 0
	       If iDelordContext <> 1 Then                                      '10Feb00 AE  Added for Overnight Job
		     Writelog GetIndexLogFileName$(), SiteNumber%, "", "WDELORD: " & msg$                                               '26Jan99 EAC changed writelog path
		  End If                                                        '      "
	       Exit Sub
	    End If
	 
	 On Error GoTo 0
	 
	 entries$ = Right$(String$(6, "0") & LTrim$(Str$(pointer& - 1)), 6)
	 For loopvar = 1 To endvar
	    
	    temp$ = "7" & Space$(6) & entries$ & cr$        ' 7 long
	    temp$ = temp$ & Space$(7) & "000000" & cr$      ' 7 long
	    Put #idxchan(loopvar), , temp$

	 Next

	 For x& = 2 To pointer&                      'scans order/requisition file
	    loopvar = 1
	    getorder Ord, x&, EditType, False
	    recnum$ = Right$(String$(6, "0") & LTrim$(Str$(x&)), 6)

	    temp$ = UCase$(Left$(Trim$(Ord.code) & "       ", 7)) & recnum$ & cr$
	    On Error GoTo WriteIndexErr
	    Put #idxchan(loopvar), , temp$
	    On Error GoTo 0
	    loopvar = loopvar + 1

	    If Trim(Ord.num) = "" Then stat$ = lf$ Else stat$ = cr$
	    temp$ = UCase$(Left$(Trim$(Ord.num) & "       ", 7)) & recnum$ & stat$
	    On Error GoTo WriteIndexErr
	    Put #idxchan(loopvar), , temp$
	    On Error GoTo 0
	    loopvar = loopvar + 1


	    If EditType = 5 Then
		  'use lf$ to delete index records in sortindex
		  If Ord.status = "R" Or Ord.status = "D" Then stat$ = lf$ Else stat$ = cr$
		  temp$ = UCase$(Left$(Trim$(Str$(Ord.pickno)) & "       ", 7)) & recnum$ & stat$
		  On Error GoTo WriteIndexErr
		  Put #idxchan(loopvar), , temp$
		  On Error GoTo 0
		  loopvar = loopvar + 1

		  temp$ = UCase$(Left$(Trim$(Ord.supcode) & "       ", 7)) & recnum$ & stat$
		  On Error GoTo WriteIndexErr
		  Put #idxchan(loopvar), , temp$
		  On Error GoTo 0
		  loopvar = loopvar + 1
	       End If
	 Next

	 For loopvar = 1 To endvar
	    Close idxchan(loopvar)
	    If iDelordContext <> 1 Then                                      '10Feb00 AE  Added for Overnight Job
		  Writelog GetIndexLogFileName$(), SiteNumber%, "", "WDELORD: Finished " & optype$ & "ing file : " & filename$(loopvar)      '26Jan99 EAC changed writelog path
	       End If                                                        '      "
	 Next

      End If
   
   For loopvar = 1 To endvar
      If Not formloaded Then title$(loopvar) = ""
      sortindex title$(loopvar), dispdata$ & filename$(loopvar)
   Next

Exit Sub

WriteIndexErr:

   msg$ = "Error writing to file: " & filename$(loopvar) & " Err = " & Format$(Err) & " - " & Error$(Err)
   Select Case iDelordContext                                                                   '10Feb00 AE  Moved into CASE and
      Case 1                                                                                    'Added Case 1
	 ONJLog sp$ & sp$ & sp$ & msg$, False, False, True, False                               '     "
	 Resume Next
	 '     "
      Case Else
	 If formloaded Then popmsg "Error", msg$, 16, "", 0
	 Writelog GetIndexLogFileName$(), SiteNumber%, "", msg$                                 '26Jan99 EAC changed writelog path
	 Resume Next
      End Select

End Sub

Sub CheckLogFiles (ShowMessage%, iTestRun As Integer)
' 1Aug97 CKJ Log file creation based on rename for safety
'            Checks files for two years ahead
'            ShowMessage = -1  any files created or creation failures are displayed
'                           0  logged to  \orderlog\OLcreate.log etc  only
'24Aug97 CKJ corrected writelog path/file
'            added check for each directory - create files if dir found
'            added old style RX logs for as long as needed - RXyymm
'25Jan00 AE  Additions for new overnight job.
'            Added parameter iTestRun and associated code.
'01Feb00 AE  Changed calls to DirExists to DirExistsNoMsg.  Screen messages were causing this program
'            to stop when running as the overnigh
'02Feb00 AE  Reinstated line to check for null filename, which had been commented out in error
'            Added extra logging
'11Feb00 AE  Added same check to Case 4. Prevents error 64 on sites which had no patdata. Error
'            did not effect anything, but looked bad.

Dim msg$, counter%, yr%, mth%, i%, filename$, dirname$, success, prefix$, RecLen%, YearFormat%
Dim sPath As String                                  '25Jan00 AE
Dim sTmp As String, iErrCode As Integer

   msg$ = ""
   If iDelordContext = 1 Then                                                           '02Feb00 AE Added
	 ONJLog sp$ & sp$ & "Updating Log and RX files", iTestRun, iTestRun, False, False    '     "
      End If                                                                            '     "
   For i = 1 To 4
      prefix$ = ""
      Select Case i                                  '24Aug97 CKJ added check for each directory
	 Case 1
	    'If direxists(orderlogpath$) Then                                   '01Feb00 AE replaced with DirExistsNoMsg
	    If DirExistsNoMsg(orderlogpath$, iErrCode) Then
		  prefix$ = "OL"
		  dirname$ = orderlogpath$ & "\"
		  RecLen = 256
		  YearFormat = 4
	       ElseIf iErrCode <> 0 Then
		     sTmp = orderlogpath$
		     GoSub HandleErrorMessage
	       End If
	 Case 2
	    'If direxists(transpath$) Then
	    If DirExistsNoMsg(transpath$, iErrCode) Then
		  prefix$ = "TL"
		  dirname$ = transpath$ & "\"
		  RecLen = 256
		  YearFormat = 4
	       ElseIf iErrCode <> 0 Then
		     sTmp = transpath$
		     GoSub HandleErrorMessage
	       End If
	 Case 3
	    sPath = Patdatapath$                                                 '25Jan00 AE Prevent null filename being passed
	    If Trim$(sPath) = "" Then sPath = "\patdata." & Right$(dispdata$, 3) '     "   02Feb00 AE reinstated !!
	    'If direxists(patdatapath$) Then                                      '     "
	    'If direxists(sPath) Then                                             '     "
	    If DirExistsNoMsg(sPath, iErrCode) Then                               '01Feb00 AE  Now uses DirExistsNoMsg
		  prefix$ = "RX"
		  dirname$ = Patdatapath$ & "\"
		  RecLen = 256
	       ElseIf iErrCode <> 0 Then
		     sTmp = sPath
		     GoSub HandleErrorMessage
		  YearFormat = 4
	       End If
	 Case 4                                      'compatibility with V7.x files
	    'If direxists(patdatapath$) Then
	    sPath = Patdatapath$                                                   '11Feb00 AE Prevent null filename being passed
	    If Trim$(sPath) = "" Then sPath = "\patdata." & Right$(dispdata$, 3)   '    "
	    'If DirExistsNoMsg(patdatapath$, iErrCode) Then                        '01Feb00 AE  Now uses DirExistsNoMsg
	    If DirExistsNoMsg(sPath, iErrCode) Then                                '11Feb00 AE  use sPath to prevent null filename
		  prefix$ = "RX"
		  dirname$ = Patdatapath$ & "\"
		  RecLen = 256
	       ElseIf iErrCode <> 0 Then
		     sTmp = Patdatapath$
		     GoSub HandleErrorMessage
		  YearFormat = 2
	       End If
	 End Select

      If Len(prefix$) Then                           '24Aug97 CKJ only create files if dir found
	    For yr = Year(Now) To Year(Now) + 1                 'this year and next
	       For mth = 1 To 12                                'all months in the year
		  filename$ = prefix$ & Right$(Format$(yr, "0000"), YearFormat) & Format$(mth, "00")
		  If Not iTestRun Then                                                 '25Jan00 AE Added TestRun for Overnight Job
			CreateFileWithPointer dirname$, filename$, RecLen, success
		     Else                                                              '     "
			If fileexists(dirname$ & filename$) Then       'Simulate CreateFilewithPointer for test run
			      success = 1                              '      "        '     "
			   Else                                        '      "        '     "
			      success = True                           '      "        '     "
			   End If                                      '      "        '     "
		     End If                                                            '     "

		  If success <> 1 Then
			If iDelordContext = 1 Then                                                    '25Jan00 AE New ONJ; write to onj log
			      msg$ = dirname$ & filename$                                                      '     "
			      If iTestRun Then                                                                 'Make clear if simulating or
				    msg$ = msg$ & " will be created"                                           'actually creating the file
				 Else                                                                          '     "
				    msg$ = msg$ & IFF(success = True, " created", " creation failed") & tb     '     "
				 End If                                                                        '     "
			      ONJLog sp$ & sp$ & msg$, iTestRun, iTestRun, False, False                        '     "
			   Else
			      msg$ = msg$ & dirname$ & filename$ & IFF(success = True, " created", " creation failed") & tb
			   End If
		     End If
	       Next
	    Next
	 End If
   Next
   
   If msg$ <> "" And iDelordContext <> 1 Then                         '25Jan00 AE
	 Writelog dirname$ & "create.log", 0, userid$, msg$           'Running as wdelord; work as before
	 If ShowMessage Then popmessagecr "Log File Creation", msg$   '    "
      End If

   If iDelordContext = 1 Then ONJLog sp$ & sp$ & "Done.", iTestRun, iTestRun, False, False  '02Feb00 AE Added

Exit Sub

HandleErrorMessage:

   If iDelordContext = 1 Then
	 ONJLog sp$ & sp$ & "ERROR " & Format$(iErrCode) & ":'" & Error$(iErrCode) & "' Occurred whilst reading """ & sTmp & "", iTestRun, iTestRun, True, False   '02Feb00 AE Added double quotes
      Else
	 msg$ = "Error " & Format$(iErrCode) & ": '" & Error$(iErrCode) & "'" & cr$
	 msg$ = msg$ & "Occurred whilst reading """ & sTmp & """" & cr$ & cr$
	 msg$ = msg$ & "Please consult your System Supervisor"
	 popmessagecr ".Wdelord", msg$
      End If

   Return

End Sub

Sub ClearSemaphoreFile ()

Dim done%


   AcquireLock dispdata$ & "\wdelord.lck", 0, done

   On Error GoTo CSF_Err
   Kill dispdata$ & "\wdelord.lck"
   On Error GoTo 0

Exit Sub

CSF_Err:

   Writelog GetIndexLogFileName$(), SiteNumber%, userid$, "WDELORD: Failed to delete the WDELORD.LCK file. Error No: " & Format$(Err) & " , ErrorMsg : " & Error$(Err)
   Resume Next

End Sub

Sub CreateFileWithPointer (diskpath$, filename$, recordlength%, success%)
'---------------------------------------------------------------------------------------------
' 1Aug97 CKJ Proc written
'            This procedure is intended to create a file on disk which contains one record
'            The record consists of a 4 byte pointer of value 1, plus spaces to end of record
'            It is suitable for use in creating blank log files.
'            The main criterion is that it MUST NOT overwrite an existing file, and therefore
'            it has been decided that fileexists() is not sufficient as a check. Some networks
'            in the late 1980s reported file not found when it did exist but there was a net
'            error. Even if modern networks do not suffer from this fault it is not safe to
'            assume this could not happen now.
'
'            Approach taken is to create a file using a temporary file name and then rename
'            this to the correct name. If the target file exists then the rename will fail
'            gracefully and will not cause loss of data or overwriting of an existing file.
'
'            If creation fails this may leave '~Create.tmp' on disk. This is OK as it
'            will be reused next time. Do not try deleting, since the error may have
'            been a network problem in the first place.
'
'            IN:
'            diskpath      the full network share or disk drive and path
'                          the name MUST be terminated with '\'
'                          NB this must exist
'                          Do not leave blank or use '.' or '..' or just 'C:' 'F:' etc
'                          This is to ensure that direxists() operates correctly
'                          Suitable examples include:
'                          'F:\dirname\'    '\dirname\'    'C:\'    '\'
'            filename      the filename and extension of the file to create
'                          This should not exist, but if it does no action is taken
'            recordlength  The length in bytes in the range 4 to 1024 inclusive.
'                          If less than 4 then 4 is assumed. No Error Is raised
'                          If >1024 then 1024 is assumed. No Error Is raised
'            success       ignored
'
'            OUT:
'            All params unchanged except for
'            success       -1 (T) file created successfully
'                           1     file already exists
'                           0 (F) failed  eg network error or invalid path
'
'27Aug97 CKJ If no extension then add .* to the fileexists
'            Not ideal but seems to be needed on NT4 in NZ, though not reproduced on test
'            NB Temporary fix as this materially affects the procedure & could prevent files
'            being created if one of another extension exists. eg RX199708.BAK etc
'04Dec98 TH  Moved from stkmaint.bas - removed msgboxes because will be working as part of overnight job
'---------------------------------------------------------------------------------------------
Dim chan%, Buffer As String, RecLen%, extra$
Dim msg$

   success = False
   If Len(diskpath$) = 0 Or Right$(diskpath$, 1) <> "\" Then
	 'popmessagecr "Procedure CreateFileWithPointer", "Contact ASC Support Desk" & cr & "Procedure called with path name = '" & diskpath$ & "'"  '04Dec98 TH
	 msg$ = "Procedure CreateFileWithPointer. Contact EMIS Health Support Desk : Procedure called with path name = '" & diskpath$ & "'"                  '04Dec98 TH
	 Writelog diskpath$ & "create.log", 0, userid$, msg$                                                                                         '04Dec98 TH
      Else
	 If direxists(diskpath$) Then
	       extra$ = ""          '27Aug97 CKJ If no extension then add .*   NB: Temporary fix
	       If InStr(filename$, ".") = 0 Then extra$ = ".*"
	       If Not fileexists(diskpath$ & filename$ & extra$) Then
		     Select Case recordlength
			Case Is < 4:    RecLen = 4
			Case Is > 1024: RecLen = 1024
			Case Else: RecLen = recordlength
			End Select
		     Buffer = Space$(RecLen%)
		     Mid$(Buffer$, 1, 4) = Chr$(1) & String$(3, 0) 'Long Int 1& is hex 01 00 00 00
		     On Error GoTo CreateFileWithPointer_Err
		     chan = FreeFile
		     Open diskpath$ & "~Create.tmp" For Binary As #chan
		     Put #chan, 1, Buffer
		     FlushBuffers chan
		     Close #chan
		     Name diskpath$ & "~Create.tmp" As diskpath$ & filename$
		     success = True
		  Else
		     success = 1            'file already exists
		  End If
	    End If
      End If
   
CreateFileWithPointer_Exit:
Exit Sub

CreateFileWithPointer_Err:
   'No action, just exit
Resume CreateFileWithPointer_Exit

End Sub

Sub Delord (phase, iTestRun As Integer)
' 8Nov93 CKJ Now only del if not reconciling
' 5Mar95 CKJ Added command line option to delete all "R" type requisitions.
'14Aug96 EAC/CKJ Delete delivery notes older than 7days and del reconciled items
'                even if the system does not normally reconcile
'20Feb98 CKJ Modem (Sitelink) orders, none issued needs deleting here
'30Sep99 TH Added command  to delete internals from reconciliation screen
'11Oct99 TH Keep internals for 7 days before deletion
'25Jan00 AE Various changes for new overnight job
'           Added error handling for overnight job; wdelord behaves as before
'           Corrected setting of progress.percent, plus other cosmetic changes.
'           Added parameter iTestRUn and associated code
'           Replaced reference to MDIEvents with iDeleteDeliv
'01Feb00 AE  Slight change to code for test run. No longer blanks to end of file
'            except on live run
'02Feb00 AE  Added extra logging for overnight job
'03Feb00 AE  Added extra information for overnight job logs. Also save pointer values
'            in overnight.ini for future checking by the rest of the suite if required.
'19May00 AE  Added code to simulate the "/inters" switch from the overnight job.  This
'            also allows the user to choose the number of days to keep inters.
'17Jan01 TH  All status 7 reconcil records now retained unless over ridden by ini setting
'            (to protect data prior to AP run or coding slip printing)
'17Jan02 TH  Moved Inters deletion code to ensure it isnt nulled by above code (these are exceptions) (#54070)
'30Apr02 CKJ Added code to remove totally null filled records and log the number culled
'23May02 CKJ Added switch to allow blanking to end of file. Create a file in dispdata
'            Wdelord1.asc, Wdelord2.asc, Wdelord3.asc, for each ordering file
'            Orders.v8, reconcil.v8 and requis.v8 respectively. Switch files are deleted
'            at the end of the run (but not used or deleted during a test run).

Dim paydate$, tdat$, issdate$
Dim EditType%, keepitem%, Valid%, quit%
Dim pointer&, rptr&, wptr&, lastptr&, ndbd&, test&
Dim LogPntr&                                 '03Feb00 AE  Added
Dim iKeepDays As Integer, iCount As Integer  '19May00 AE  Added
Dim KeepInvoices%          '17Jan01 TH
Dim intNullRecords As Integer                '30Apr02 CKJ Added
Dim blnBlanktoEnd As Integer                 '23May02 CKJ Added

   intNullRecords = 0                        '30Apr02 CKJ Added

   'DelordPrint "total ÃÄÄÄÄ´ read ÃÄÄÄÄÄÄ´ write", " Tidying ...                                   "
   
   On Error GoTo DelordErr                   '25Jan00 AE Added error trapping

   KeepInvoices% = TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", "KeepInvoices", 0))   '17Jan01 TH

   Select Case phase
      Case 1
	 EditType = 1   'ordering
	 Progress.lblInfo.Caption = "Tidying Orders..."                     '25Jan00 AE Cosmetic changes for Progress
	 If iDelordContext = 1 Then                                         '02Feb00 AE Added extra logging
	       ONJLog sp$ & sp$ & "Tidying Orders..." & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False
	    End If                                                          '    "
      Case 2
	 EditType = 4   'reconcil
	 Progress.lblInfo.Caption = "Tidying Reconciliations..."            '25Jan00 AE Cosmetic changes for Progress
	 If iDelordContext = 1 Then                                         '02Feb00 AE Added extra logging
	       ONJLog sp$ & sp$ & "Tidying Reconciliations..." & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False
	    End If                                                          '    "

      Case 3
	 EditType = 5   'requis
	 Progress.lblInfo.Caption = "Tidying Requisitions..."               '25Jan00 AE Cosmetic changes for Progress
	 If iDelordContext = 1 Then                                         '02Feb00 AE Added extra logging
	       ONJLog sp$ & sp$ & "Tidying Requisitions..." & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False
	    End If                                                          '    "
      
      Case 4: EditType = 5   'history       '!!** not implemented yet
   End Select
   
   getnumofords EditType, pointer&, False
   rptr& = 2
   wptr& = 2
   lastptr& = pointer&
   If lastptr& < rptr& Then Exit Sub       '18Aug98 EAC Added
   
   If iDelordContext = 1 Then                           '25Jan00 AE  Added for new Overnight Job
	 PositionProgress                               '      "
      Else                                              'Prevent errors when running new Overnight Job in setup mode
	 Progress.Show 0
      End If                                            '      "
      
   Do While rptr& <= lastptr&
      
      'Progress.PerCent = ((lastptr& / rptr&) * 100)    '25Jan00 AE Corrected. rptr is always < lastptr
      Progress.PerCent = ((rptr& / lastptr&) * 100)     '      "
      DelordPrint "Tidying...", "Total " & Format$(pointer&), "Read " & Format$(rptr&), "Write " & Format$(wptr&)
      getorder Ord, rptr&, EditType, True             '<-LOCK & read record
      LSet r = Ord
      keepitem = True
   
      '14Aug96 EAC mod for kings to get rid of orders with blank NSVcodes
      If Trim$(Ord.code) = "" Then keepitem = False
      '---
   
      Select Case EditType '22Feb94 CKJ Added to handle each file on its own
   
	 Case 1                        ' ORDER.ASC
	    Select Case Ord.status
	       Case "R", "D": keepitem = False
	    End Select
   
	 Case 4                        ' RECONCIL.ASC
	    Select Case Ord.status
	       Case "4", "7", "8"      '8 added ASC 06Apr92
		  'delete all items delreconcile% days past date for paying
		  'or delreceipt days past date received
		  If Val(Ord.status) = 7 Or Val(Ord.status) = 8 Then   '8 added ASC 06Apr92
			paydate$ = Ord.paydate
		     Else
			paydate$ = Ord.recdate
		     End If
		  parsedate (paydate$), paydate$, "1", Valid
		  If Valid Then
			'convdat paydate$
			'paydate$ = LEFT$(paydate$, 6) + "19" + RIGHT$(paydate$, 2) '!!** only works to year 2000
			tdat$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 4)
			datetodays paydate$, tdat$, ndbd&, 0, "", Valid
			If ndbd& > delreconcile And (Val(Ord.status) = 7 Or Val(Ord.status) = 8) And delreconcile > 0 Then '24Jan94 CKJ Added valid
				       keepitem = False
			      End If
   
			'IF ndbd& > delreceipt AND VAL(ord.status) = 4 AND delreceipt > 0 AND delreconcile = 0 THEN   '8Nov93 CKJ Now only del if not reconciling  '24Jan94 CKJ Added valid
			Select Case Ord.status '14Aug96 CKJ/EAC Del reconciled items, even if normally reconciliation is not done
			   Case "4", "7", "8"
			      If ndbd& > delreceipt And delreceipt > 0 And delreconcile = 0 Then    '8Nov93 CKJ Now only del if not reconciling  '24Jan94 CKJ Added valid
				    keepitem = False
				 End If
			End Select
		     End If

		  'If TrueFalse(TxtD(Dispdata$ & "winord.ini", "", "0", "DeleteInternals", 0)) And ord.internalmethod = "I" Then keepitem = False
		  'If InStr(1, UCase$(Command$), "/INTERS", 1) > 0 And Ord.internalmethod = "I" Then   '19May00 AE  Replaced with block below           '30Sep99 TH switch to delete internals from reconciliation screen
		  '         If ndbd& > 7 Then keepitem = False                                           '     "                                        '11Oct99 TH Allow for seven days before deletion
		  '      End If                                                                          '     "                                        '      "
		     
		  If KeepInvoices% And Ord.status = "7" Then keepitem = True    '17Jan02 TH Moved from below as inters of status 7 should still be deleted if necessary ! (#54070)
		  
		  iKeepDays = DeleteIntersAfter()                                                     '19May00 AE  replaces above
		  If InStr(UCase$(Command$), "/INTERS") <> 0 Then iKeepDays = 7                       'Now allows use of setting from overnight job program
		  If iKeepDays > 0 And Ord.internalmethod = "I" Then                                  'with variable number of days to.
			If ndbd& > iKeepDays Then                                                     '     "
			      keepitem = False                                                        '     "
			      iCount = iCount + 1                                                     '     "
			   End If                                                                     '     "
		     End If                                                                           '     "
		  'If KeepInvoices% And Ord.status = "7" Then keepitem = True   '17Jan01 TH '17Jan02 TH Moved above
	       Case "D": keepitem = False
	    End Select
   
	 Case 5                          ' REQUIS.ASC
	    Select Case Ord.status
   
	       '14Aug96 EAC - mod for kings to delete delivery notes older than seven days
	       Case "7"
		  
		  'If InStr(1, Command$, "/DELDELIV", 1) > 0 Or MDIEvents.MnuOption(0).Checked Then    '25Jan00 AE replaced reference to form
		  If InStr(1, Command$, "/DELDELIV", 1) > 0 Or iDeleteDeliv Then                       '    "
			issdate$ = Ord.recdate
			parsedate (issdate$), issdate$, "1", Valid
			If Valid And Ord.internalmethod <> "M" Then
			      tdat$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 4)
			      datetodays issdate$, tdat$, ndbd&, 0, "", Valid
			      If ndbd& > 7 Then keepitem = False
			   End If
		     End If
	       '---
   
	       '20Feb98 CKJ Modem (Sitelink) orders, none issued needs deleting here
	       Case "8"         'because sitelink does not send tofollow information
		  If Ord.internalmethod = "M" And Val(Ord.received) = 0 Then
			issdate$ = Ord.recdate
			parsedate (issdate$), issdate$, "1", Valid
			If Valid Then
			      tdat$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 4)
			      datetodays issdate$, tdat$, ndbd&, 0, "", Valid
			      If ndbd& > Delrequis And Delrequis > 0 Then keepitem = False
			   End If
		     End If
	       '---

	       Case "R"       'delete all items delrequis days after issuing
		  issdate$ = Ord.recdate
		  parsedate (issdate$), issdate$, "1", Valid
		  If InStr(1, Command$, "/ALLREQUIS", 1) > 0 Then Valid = True  '5Mar95 CKJ Added
		  If Valid Then
			tdat$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 4)
			datetodays issdate$, tdat$, ndbd&, 0, "", Valid
			If ndbd& > Delrequis And Delrequis > 0 Then keepitem = False
		     End If
	       Case "D": keepitem = False
	    End Select
      End Select
   
      If r.record = String$(1024, 0) Then             '30Apr02 CKJ Added
	    keepitem = False                          '  "
	    intNullRecords = intNullRecords + 1       '  "
	 End If                                       '  "

      If iTestRun Then keepitem = True                '25Jan00 AE Added. Live run - same as before
      If keepitem Then   ' item needs keeping  05.04.92 ASC "D" only absolute if edittype 1 or 5
	    If rptr& <> wptr& Then                    ' copy record
		  getorder Ord, wptr&, EditType, True ' <-LOCK place to write
		  LSet Ord = r
		  putorder Ord, wptr&                 ' <-UNLOCK replace (IDX built below)
	       End If
	    wptr& = wptr& + 1
	 End If
      putorder Ord, rptr&                 '<-UNLOCK read pointer
      rptr& = rptr& + 1
   
   Loop
   
   '03Feb00 AE Added
   If iDelordContext = 1 Then
	 If EditType = 4 Then                                          '19May00 AE  Added IF Block to log inters deleted
	       If iCount > 0 Then ONJLog sp$ & sp$ & sp$ & "Deleted: " & Format$(iCount) & " Inters over " & Format$(iKeepDays) & " days old", iTestRun, iTestRun, False, False
	    End If
	 ONJLog sp$ & sp$ & sp$ & "Read: " & Format$(rptr& - 1) & ".  Write: " & Format$(wptr& - 1), iTestRun, iTestRun, False, False
	 If intNullRecords Then                                        '30Apr02 CKJ Added block
	       ONJLog sp$ & sp$ & sp$ & "Deleted: " & Format$(intNullRecords) & " Null filled records.", iTestRun, iTestRun, False, False
	    End If
      End If

   If Not iTestRun Then                         '01Feb00 AE added IF
	 blnBlanktoEnd = fileexists(dispdata$ & "\wdelord" & Format$(phase) & ".asc")           '23May02 CKJ added
	 'set file length=wptr-1
	 getnumofords EditType, (wptr& - 1), 2
	 
	 quit = False               '24Jan94 CKJ Retyped edits of 12Mar93, with mod to halt on empty record
	 test& = LOF(getorderchan%()) \ Len(Ord)
	 Do While wptr& <= test&    'Blank from next record to end of file
				    'or end of used portion if sooner
	    DelordPrint "Checking...", "Total " & Format$(pointer&), "Reading " & Format$(wptr&), ""
	    getorder Ord, wptr&, EditType, True   ' <== LOCK
	    LSet r = Ord
	    'If LTrim$(r.record) = "" Then quit = True                                          '23May02 CKJ removed
	    If Not blnBlanktoEnd And LTrim$(r.record) = "" Then quit = True                     '   "        added
	    r.record = ""
	    LSet Ord = r
	    putorder Ord, wptr&                   ' <== UNLOCK
	    wptr& = wptr& + 1
	    If quit Then Exit Do
	 Loop
	 
	 'If Not iTestRun Then                         '25Jan00 AE added IF   01Feb00 AE moved above
	 buildordreqindex EditType, True  ' rebuild from scratch
	 
	 If blnBlanktoEnd Then                                                                  '23May02 CKJ added block
	       On Error Resume Next                                                             '   "
	       Kill dispdata$ & "\wdelord" & Format$(phase) & ".asc"                            '   "
	       On Error GoTo 0                                                                  '   "
	    End If                                                                              '   "
      End If                                    '01Feb00 AE
									     '02Feb00 AE Added
   If iDelordContext = 1 Then                                                '      "
	 getnumofords EditType, LogPntr&, False                                                       '03Feb00 AE Added to log further info.
	 ONJLog sp$ & sp$ & sp$ & "Pointer = " & Format$(LogPntr&), iTestRun, iTestRun, False, False  '     "
	 ONJwriteIni Right$(dispdata$, 3), "Pointer" & Format$(EditType), Format$(LogPntr&), 0        '     "
	 ONJLog sp$ & sp$ & "Done." & tb$ & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False   '11Feb00 AE Added extra tb$
      End If                                                                 '      "
   

DelordExit:                                     '25Jan00 AE Added as part of below
   Exit Sub

DelordErr:                                      '25Jan00 AE Added error handling block for new Overnight Job
					       
   If iDelordContext = 0 Then       'If Running just as Wdelord, pass error out as before.
	 Error Err
      Else                          'Otherwise, write to overnight job logs.
	 ONJLog sp$ & sp$ & "Error " & Format$(Err) & ":'" & Error$ & "' occurred during Order Deletion", iTestRun, iTestRun, True, False                '     "
	 ONJStoreError Right$(dispdata$, 3), "OrdersReIndex", True, iTestRun
	 Resume DelordExit
      End If

End Sub

Sub DelordPrint (Seg1$, seg2$, seg3$, seg4$)

'29Mar99AE  Now any segment can be passed Chr$(0) as an argument. This has the effect
'           of being transparent, ie what was there before remains unchanged
'25Jan00 AE  Now prints to MDIEvents or to frmOvernight depending on where the program is being run from
'            If printing to frmOvernight, Seg1-4 are printed separated by " , "

   If iDelordContext = 0 Then               'Running Wdelord alone
	 If formloaded Then
      
	       MDIEvents.StatusBar.Segment = 0
      
	       If Seg1$ <> "" Then
		  If Asc(Seg1$) <> 0 Then MDIEvents.StatusBar.SegCaption = Seg1$
	       Else MDIEvents.StatusBar.SegCaption = Seg1$
	       End If                                                                 '29Mar99AE
      
	       MDIEvents.StatusBar.Segment = 1
	       If seg2$ <> "" Then
		  If Asc(seg2$) <> 0 Then MDIEvents.StatusBar.SegCaption = seg2$      '29Mar99AE
	       Else MDIEvents.StatusBar.SegCaption = seg2$
	       End If
      
	       MDIEvents.StatusBar.Segment = 2
	       If seg3$ <> "" Then
		  If Asc(seg3$) <> 0 Then MDIEvents.StatusBar.SegCaption = seg3$      '29Mar99AE
	       Else MDIEvents.StatusBar.SegCaption = seg3$
	       End If
      
	       MDIEvents.StatusBar.Segment = 3
	       If seg4$ <> "" Then
		  If Asc(seg4$) <> 0 Then MDIEvents.StatusBar.SegCaption = seg4$      '29Mar99AE
	       Else MDIEvents.StatusBar.SegCaption = seg4$
	       End If
      
	    End If

      Else
      'Running Delord from frmOvernight                                               '25Jan00 AE
	    ONJinfo Seg1$ & " , " & seg2$ & " , " & seg3$ & " , " & seg4$
      End If

End Sub

Sub DoseFromKg (dummy$)

End Sub

Sub DoseFromMsq (dummy$)

End Sub

Sub EditDirections (dummy%)

End Sub

Sub getprintpath (dummy$, dum1%)

End Sub

Sub Issue_Callback ()
'21May04 TH Stubbage
End Sub

Sub LoadBNF ()

End Sub

Sub main ()
'26Jan99 EAC Add semaphore file that will be left as a dropping if the index process fails
'26Jan99 EAC Changed Writelogs to write to the new Reindexing logfile
'03Dec98 TH added tidyupreprints (moved from winord startup)
'03Dec98 TH Added call to checklogfiles
'25Jan00 AE  Additions for new Overnight Job:
'            Added parameter to call to Delord
'            Added parameter to call to TidyDisp/StoreReprints
'            Set iDeleteDeliv
'24Mar00 GRS Moved acquire lock so interactive mode does not lock DB until Password supplied. (Evt 41965)
'01oct03 CKJ added brackets on ASCver()
'            removed outstanding() array
'21May04 TH  Removed call to sethelp

'Dim nod&, Valid%, found%   ' 01Jun02 ALL/ATW        '01oct03 CKJ removed nod&
Dim Valid%, found%   ' 01Jun02 ALL/ATW               '   "
Dim tempd As drugparameters
Dim fullname$, msg$
Dim done%                                                         '26Jan99 EAC added
   If app.PrevInstance Then
	 Close
	 End
      End If

   readsiteinfo
   
   '24Mar00 GRS Check to see if we are in Interactive, or overnight mode. Don't lock yet if Interactive
   If Not bIsInteractive(Command$) Then
	 AcquireLock dispdata$ & "\wdelord.lck", 2, done                '26Jan99 EAC added
      End If

   If Not fileexists(dispdata$ & "\prodinfo.v8") Or (FileLen(dispdata$ & "\prodinfo.v8") < Len(tempd)) Then
	 msg$ = "This program has been built for use with V8.0 drug file. This file could not be found. The program could not start."
	 If InStr(1, Command$, "/TIDYORDIDX", 1) > 0 Or InStr(1, Command$, "/TIDYRECIDX", 1) > 0 Or InStr(1, Command$, "/TIDYREQIDX", 1) > 0 Or InStr(1, Command$, "/FULL", 1) > 0 Then
	       Writelog GetIndexLogFileName$(), SiteNumber%, "", "WDELORD: " & msg$         '26Jan99 EAC changed writelog path
	    Else
	       popmessagecr "Stock Control Re-indexing", msg$
	    End If
	 Close
	 End
      End If

   setinput 0, k
   k.helpfile = "ordermnu.hlp"
   'sethelp   '21May04 TH Removed

   'getnod nod                              '01oct03 CKJ Removed - unused
   'ReDim outstanding(nod) As String * 6    '01oct03 CKJ Removed - unused but fails when nod>32767
   
   'ChDir orderpath$          '26Jan99 EAC don't think this is necessary now
   
   ReadOrdData

   'CheckLogFiles (False)    '03Dec98 TH Added - Always checks logs regardless      '25Jan00 AE  Added parameter
   CheckLogFiles False, False                                                       '     "
   formloaded = False
   
   Writelog GetIndexLogFileName$(), SiteNumber, userid$, "WDELORD: Called with command line parameters - " & UCase$(Command$)
   '245Mar00 GRS NOTE: If this list is extended, bIsInteractive should also be modified to ensure the lock is writ!
   If InStr(1, Command$, "/TIDYORDIDX", 1) > 0 Then       ' Delord 43 /TidyAaaIdx /Full
	 buildordreqindex 1, False                 ' tidy ordering indices
      ElseIf InStr(1, Command$, "/TIDYRECIDX", 1) > 0 Then
	 buildordreqindex 4, False                 ' tidy reconciliation indices
      ElseIf InStr(1, Command$, "/TIDYREQIDX", 1) > 0 Then
	 buildordreqindex 5, False                 ' tidy requisitioning indices
      ElseIf InStr(1, Command$, "/TIDYSTOREREPRINTS", 1) > 0 Then
	 TidyStoreReprints False                        ' tidy stores reprints       '25Jan00 AE Added parameter
      ElseIf InStr(1, Command$, "/TIDYDISPREPRINTS", 1) > 0 Then
	 TidyDispReprints False                         ' tidy dispensary reprints   '25Jan00 AE Added parameter
      ElseIf InStr(1, Command$, "/FULL", 1) > 0 Then
	 Delord 1, False                              '25Jan00 AE Added parameter
	 Delord 2, False                              '     "
	 Delord 3, False                              '     "
	 TidyStoreReprints False                      '     "
	 TidyDispReprints False                       '     "
      Else
	 
	 askpassword Valid%, fullname$, "Stock Control Re-indexing"
	    If Valid Then
	       AcquireLock dispdata$ & "\wdelord.lck", 2, done                '24Mar00 GRS Moved for Interactive mode
	       Load MDIEvents
	       MDIEvents.MnuOption(0).Checked = (Val(TxtD$(dispdata$ & Inifile$, "", "0", "DeleteDelNotes", found)) = True)
	       iDeleteDeliv = MDIEvents.MnuOption(0).Checked               '25Jan00 AE Added
	       MDIEvents.Caption = hospabbr$ & "Stock Control Indexing Utility      Version " & ASCVer()          '01oct03 CKJ added brackets on ASCver()
	       formloaded = True
	    Else
	       popmessagecr "Stock Control Re-index", "You are not authorised to use this utility."
	    End If
      End If

   If Not formloaded Then
	 ClearSemaphoreFile                                                      '26Jan99 EAC Added
	 Writelog GetIndexLogFileName$(), SiteNumber%, userid$, "WDELORD: Finished Reindexing."
	 Close
	 End
      End If

End Sub

Function OCXLaunch () As Integer
'Stub
End Function

Function PresentPrescriptionID& ()

End Function

Sub PrinterParse (dummy$)

End Sub

Sub printlabels (dum1 As String, dum2 As String)

End Sub

Sub Ques_Callback (dummy%)

End Sub

Function ReadWriteDuration% (Entry$, ReadValue$, WriteValue$)

'17May99 AE  Written
'Function can Read a single item from the ini file (held in Inifile$, currently wdelord.ini)
'or Write a single item to it.
'To read, the third parameter (WriteValue) is left blank.  If a read cannot find the item,
'a default value is written in. Defaults are declared in Wdelord.bas_(declarations)
'The value of the function is True if the operation was successful, False otherwise.
'22Nov00 Handle Dispute Note Reprint Tidying
'17Jan02 TH Added PBS reprints clean up (#58302)

Dim found%, Section$, Item$, Default$, success%
   success% = True
   Section$ = "FileDurations"
   
   Select Case Entry$
      Case "S_DLV"
	 Item$ = "DeliveryNotes"
	 Default$ = STORE_FILE_DUR
      Case "S_RQS"
	 Item$ = "RequisitionNotes"
	 Default$ = STORE_FILE_DUR
      Case "S_RET"
	 Item$ = "ReturnNotes"
	 Default$ = STORE_FILE_DUR
      Case "S_ORD"
	 Item$ = "OrderNotes"
	 Default$ = STORE_FILE_DUR
      Case "D_WKS"
	 Item$ = "Worksheets"
	 Default$ = DISP_FILE_DUR
      Case "D_LBL"
	 Item$ = "Labels"
	 Default$ = DISP_FILE_DUR

      Case "D_PBS"                   '17Jan02 TH Added PBS clean up (#58302)
	 Item$ = "PBSLabels"         '     "
	 Default$ = DISP_FILE_DUR    '     "
      Case "D_RAF"                   '     "
	 Item$ = "PBSRAF"            '     "
	 Default$ = DISP_FILE_DUR    '     "

      '22Nov00 EAC Added
      Case "S_DSP"
	 Item$ = "DisputeNotes"
	 Default$ = STORE_FILE_DUR
      '---
      Case Else
	 ReadWriteDuration% = False
	 Exit Function
   End Select

   If WriteValue$ = "" Then                          'doing a read
      ReadValue$ = TxtD(dispdata$ & Inifile$, Section$, Default$, Item$, found%)
      If Not found Then WritePrivateIniFile Section$, Item$, Default$, dispdata$ & Inifile$, success%
   Else                                              'Writing to the ini file
      WritePrivateIniFile Section$, Item$, WriteValue$, dispdata$ & Inifile$, success%
   End If

   ReadWriteDuration = success%


End Function

Function RestrictedView () As Integer

   RestrictedView = False

End Function

Sub RxEditor (a%, b%)
'20Nov00 SF added stub procedure
End Sub

Sub ShowInfo ()

End Sub

Sub striprtf (dummy$)

End Sub

Sub TidyDispReprints (iTestRun As Integer)

'Removes Dispensary RTF files from disk after a number of days specified in Wdelord.ini.
'17May99 AE Modified. Gets file durations from ini File using ReadWriteDuration
'25Jan00 AE  Corrected FilePath to look at the right path
'            Also changed error handling to account for new overnight job
'17Jan02 TH Altered paths to reflect new reprint folder (#53403) and also a check that the directory exists
'17Jan02 TH Added new calls for PBS Clean up


Dim msg$, FilePath$, Files$, Value$, Entry$, success%                       '17May99 AE
Dim strTmppath As String   '17Jan02 TH Added
									    
'Dim Duration%                                                              '17May99 AE Removed
   'Duration% = 2                                                           ''
   'TidyUpReprints patdatapath$, "lbl*.rtf", Duration%                      ''
   'TidyUpReprints patdatapath$, "wks*.rtf", Duration%                      ''

    'FilePath$ = patdatapath$                                                    '17May99 AE '25Jan00 AE corrected '09Jan02 TH altered to reflect new reprint folder (#53403)
    FilePath$ = Patdatapath$ & "\reprints"                                                                     '    "
    If direxists(FilePath$) Then                               '17Jan02 TH Check path and log if cant process                                                     '    "
	  Files$ = "wks*.rtf"                                                     ''''        '    "
	  DelordPrint "", "Tidying Worksheet Files...", "", ""                    '
	  Entry = "D_WKS"                                                         '
	  GoSub TidyFiles                                                         '
										  
	  Files$ = "lbl*.rtf"'
	  DelordPrint "", "Tidying Label Files", "", ""                           '
	  Entry = "D_LBL"                                                         '
	  GoSub TidyFiles                                                         '
		
	  Files$ = "pbs*.rtf"'                                             '17Jan02 TH Added for PBS Clean up (#58302)
	  DelordPrint "", "Tidying  PBS Label Files", "", ""               '    "
	  Entry = "D_PBS"                                                  '    "
	  GoSub TidyFiles                                                  '    "
      
	  Files$ = "raf*.rtf"'                                             '    "
	  DelordPrint "", "Tidying Repeat Authority Form Files", "", ""    '    "
	  Entry = "D_RAF"                                                  '    "
	  GoSub TidyFiles                                                  '    "
										  '
	  DelordPrint " Files Tidied.", "", "", ""                                '
       Else                                                     '    "                                                   '17Jan02 TH
	  Writelog GetIndexLogFileName$(), SiteNumber%, "---", "Path/File not available for Tidy Up : " & Patdatapath$   '    "
       End If                                                   '    "                                                   '    "
Exit Sub                                                                    '
									    '
TidyFiles:                                                                  '
									    '
    success% = ReadWriteDuration(Entry, Value$, "")                           '
    If success Then                                                           '
	 TidyUpReprints FilePath$, Files$, Val(Value$), iTestRun              '
       Else                                                                   '
	 msg$ = "Unable to find or write to " & cr$                           '
	 msg$ = msg$ & FilePath & Inifile$ & cr$                              '
	 If formloaded Then                                                   '25Jan00 AE write to log if running screenless
	       msg$ = msg$ & "Please contact your System Administrator" & cr$ '        "
	       msg$ = msg$ & "Files remain unchanged."                        '        "
	       popmessagecr "!EMIS Health", msg$                                  '        "
	    Else                                                              '         "
	       Writelog GetIndexLogFileName$(), SiteNumber, userid$, "Wdelord: " & msg$ & "Program Halted."     '25Jan00 AE Added
	    End If                                                            '25Jan00 AE Added
	 Close                                                                'Program halts if wdelord.ini is not present or locked.
	 End                                                                  '     "
    End If                                                                    '     "

									    '17May99 AE
Return
									     
End Sub

Sub TidyStoreReprints (iTestRun As Integer)

'Removes Store RTF files from disk after a number of days specified in Wdelord.ini.
'17May99 AE Modified. Gets file durations from ini File using ReadWriteDuration
'25Jan00 AE  Corrected FilePath to look at the right path
'            Also changed error handling to account for new overnight job
'22Nov00 EAC Tidy Dispute Note Reprints

Dim msg$, FilePath$, Files$, Value$, Entry$, success%                '17May99 AE


'Dim Duration%                                                       '17May99 AE Removed
								     ''
   'Duration% = 10                                                   ''
   'TidyUpReprints dispdata$ & "\delnotes", "*.rtf", Duration%       ''
   'TidyUpReprints dispdata$ & "\orders", "*.rtf", Duration%         ''
   'TidyUpReprints dispdata$ & "\requis", "*.rtf", Duration%         ''
   'TidyUpReprints dispdata$ & "\returns", "*.rtf", Duration%        ''

    FilePath$ = dispdata$ & "\delnotes"                              '17May99 AE   25Jan00 AE corrected
    Files$ = "*.rtf"                                                 '
								     '
    DelordPrint "", "Tidying Delivery Notes...", "", ""              '
    Entry = "S_DLV"                                                  '
    GoSub DoTidy                                                     '
								     '
    FilePath$ = dispdata$ & "\orders"                                '25Jan00 AE   25Jan00 AE corrected                               '
    DelordPrint "", "Tidying Order Notes...", "", ""                 '
    Entry = "S_ORD"                                                  '
    GoSub DoTidy                                                     '
								     '
    FilePath$ = dispdata$ & "\requis"                                '25Jan00 AE  25Jan00 AE corrected                               '
    DelordPrint "", "Tidying Requisition Notes...", "", ""           '
    Entry = "S_RQS"                                                  '
    GoSub DoTidy                                                     '
								     '
    FilePath$ = dispdata$ & "\returns"                               '25Jan00 AE  25Jan00 AE corrected
    DelordPrint "", "Tidying Return Notes", "", ""                   '
    Entry = "S_RET"                                                  '
    GoSub DoTidy                                                     '
								     '
    FilePath$ = dispdata$ & "\dispnote"                               '22Nov00 EAC Tidy Dispute Note Reprints
    DelordPrint "", "Tidying Dispute Notes", "", ""                   '
    Entry = "S_DSP"                                                  '
    GoSub DoTidy                                                     '
								     '
    DelordPrint " Files Tidied.", "", "", ""                         '
								     '
Exit Sub                                                             '
								     '
								     '
DoTidy:                                                              '
								     '
    success% = ReadWriteDuration(Entry, Value$, "")                  '
    If success Then                                                  '
	 TidyUpReprints FilePath$, Files$, Val(Value$), iTestRun        '
       Else                                                             '
	 msg$ = "Unable to find or write to " & cr$                     '
	 msg$ = msg$ & FilePath & Inifile$ & cr$                        '
	 If formloaded Then                                             '25Jan00 AE write to log if running screenless
	       msg$ = msg$ & "Please contact your System Administrator" & cr$ '        "
	       msg$ = msg$ & "Files remain unchanged."                        '        "
	       popmessagecr "!EMIS Health", msg$                                  '        "
	    Else                                                              '         "
	       Writelog GetIndexLogFileName$(), SiteNumber, userid$, "Wdelord: " & msg$ & "Program Halted."     '25Jan00 AE Added
	    End If                                                                                              '    "
	 Close                                                       'Program halts if wdelord.ini is not present or locked.
	 End                                                         '     "
    End If                                                           '     "
								     '     "
Return                                                               '17May99 AE

End Sub

Sub TidyUpReprints (Path$, file$, Duration%, iTestRun As Integer)
'05Mar98 ASC/EAC Procedure written keeps 10 days of reprints on line and kills off other files
'18Mar98 CKJ Found error if date includes am/pm -> Type mismatch in datediff
'            Avoid this by keeping the date as a variant type 7, and not casting to string.
'26Mar98 CFY Added error handling to trap potential problems using the Dir$ and FileDateTime functions
'07Apr98 CFY Added extra error trap around the second dir$
'17Apr98 CFY LineNumbers and stonger error trapping added. Now can optionally log all events that
'            that occur within this procedure by setting a command line switch 'logindebug'
'03Dec98 TH  Taken from Storeasc.bas , removed msgbox in debug mode
'29Mar99 CFY Made procedure a little more generic and flexible by using parameters to specify
'            file location, filename and duration.
'17May99 AE  Added routines to scan for files and display progress bar when deleting.
'19Oct99 AE  Expanded error handling to write to the monthend log if running as the overnight job,
'            Or to screen if run from the menu manually.
'20Oct99 AE  Corrected line looking for /login parameter
'25Jan00 AE  Changes to call to progress for new overnight job.
'            Added Parameter iTestRun and associated code.
'            Added error handling for overnight job
'03Feb00 AE  Corrected info to show correct number of deleted files. Also added
'            extra logging if overnight job.
'11Feb00 AE  Enhanced ONJ logging to say which files are being deleted

Dim filename$, FileInfo As Variant, x%
Dim errnum, msg$  '26Mar98 CFY Added
Dim Stage$
Dim debugmode%
Dim NumFiles%, InitialDir$, Count% '17May99 AE Added
Dim iKillCount As Integer            '03Feb00 AE Added
Dim sTmp As String                  '11Feb00 AE Added
	 
  If InStr(LCase$(Command$), "/logindebug") Then       '20Oct99 AE Corrected to Lcase
	debugmode = True
     Else
	debugmode = False
     End If

   If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "TIDYUPREPRINTS STARTED"
   
   'On Error Resume Next
   'MkDir dispdata$ & PrintPath$
   'If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "Mkdir " & dispdata$ & PrintPath$ & " complete."
   'On Error GoTo 0
   
   On Error GoTo Reprint_Err             '26Mar98 CFY Added
   Stage$ = "Initial DirScan"

   DelordPrint " Scanning for files...", Chr$(0), "", ""                  '17May99 AE
   InitialDir$ = Dir$(Path$ & "\" & file$)                                '
   NumFiles = 0                                                           '
   If InitialDir$ <> "" Then                                              '
      Do                                                                  '
	 filename$ = Dir$                                                 '
	 NumFiles = NumFiles + 1                                          '
      Loop Until filename = ""                                            '
   End If                                                                 '
									  '
   DelordPrint " " & Format(NumFiles) & " Files Found.", Chr$(0), "", ""  '17May99 AE

   filename$ = Dir$(Path$ & "\" & file$)
   If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "Initial Dir$ = " & InitialDir$
   'If filename$ <> "" Then   17May99 AE removed
						   
   If NumFiles <> 0 Then                           '17May99 AE
	 filename$ = InitialDir$                   '
	 Count = 1                                 '
	 Progress.lblInfo = "Deleting Files..."    '

	 If iDelordContext = 1 Then                '25Jan00 AE  Added
	       PositionProgress                    'Prevent errors when running new Overnight Job in setup mode
	    Else                                   '      "
	       Progress.Show 0                     '17May99 AE
	    End If                                 '      "

	 Do
	    On Error GoTo Reprint_Err              '26Mar98 CFY Added
	    Stage$ = "FileInfo Interrogation"
	    FileInfo = FileDateTime(Path$ & "\" & filename$)
	    If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "FileInfo : " & FileInfo
	    
	    'Keep 30 days of prints ready for reprint but delete the rest
	    'If DateDiff("d", Format$(fileinfo$, "dd/mm/yyyy"), Now) > 10 Then  '18Mar98 CKJ
   
	    On Error GoTo Reprint_Err
	    Stage$ = "DateDiff Function"
	    If DateDiff("d", FileInfo, Now) > Duration% Then                            '   "
		  On Error GoTo Reprint_Err
		  Stage$ = "File Kill"
		  If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "About to kill file " & filename

		  'Kill Path$ & "\" & filename$                                  '25Jan00 AE Added if
		  If Not iTestRun Then Kill Path$ & "\" & filename$              '     "
		  iKillCount = iKillCount + 1                                    '03Feb00 AE  Added
		  If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "Killed File."
	       End If
	    On Error GoTo Reprint_Err                   '26Mar98 CFY Added
	    Stage$ = "Secondary DirScan"
	    filename$ = Dir$
	    If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "Secondary Dir$ = " & filename

	    Progress.PerCent = Count / NumFiles * 100     '17May99 AE
	    If filename$ <> "" Then Count = Count + 1                              '03Feb00 AE Added IF   17May99 AE

	 Loop Until filename$ = ""

	 Unload Progress                                                           '17May99 AE
	 DelordPrint " " & Format(iKillCount) & " Files Deleted.", Chr$(0), "", "" '03Feb00 AE  Corrected to use iKillCount 17May99 AE
	 If iDelordContext = 1 Then                                                 '03Feb00 AE Added logging
	       msg$ = IFF(iTestRun, " will be deleted.", " deleted")                '     "
	       sTmp = Right$(Path$, 9)                                              '11Feb00 AE  Enhanced logging
	       If InStr(sTmp, "\") > 0 Then sTmp = Mid$(sTmp, InStr(sTmp, "\"))     '     "
	       msg$ = msg$ & " from " & sTmp                                        '     "
	       ONJLog sp$ & sp$ & sp$ & Format$(iKillCount) & " of " & Format$(NumFiles) & msg$, iTestRun, iTestRun, False, False
	    End If                                                                  '     "

   End If

TidyUpReprints_Exit:
   On Error GoTo 0
   If debugmode Then Writelog dispdata$ & "\startup.log", SiteNumber%, "---", "TIDYUPREPRINTS FINISHED"
   Exit Sub

'26Mar98 CFY Added Error handling block
Reprint_Err:
   
   If iDelordContext = 0 Then                            'Do as in original Wdelord    '25Jan00 AE
	 msg$ = "Error Tidying reprints :  " & crlf
	 msg$ = msg$ & "Stage       : " & Stage$ & crlf
	 msg$ = msg$ & "Line Number : " & Erl & crlf
	 msg$ = msg$ & "ErrorNum    : " & Err & crlf
	 msg$ = msg$ & Error$
	 'If debugmode Then popmessagecr "ASCribe", msg$      '03Dec98 TH removed
	 If debugmode Then
	       Writelog dispdata$ & "\startup.log", SiteNumber%, "---", msg$
      
	    ElseIf InStr(Command$, "/full") Then                                 '19Oct99 AE Added
	       Writelog GetIndexLogFileName$(), SiteNumber%, "", msg$            '     "
										 '     "
	    Else                                                                 '     "
	       msg$ = "Deletion of reprint files failed." & cr$ & msg$           '     "
	       msg$ = msg$ & cr$ & "Path: " & Path$ & cr$                        '     "
	       msg$ = msg$ & "File: " & filename$ & cr$ & cr$                    '     "
	       msg$ = msg$ & "Please contact EMIS Health Support."               '     "
	       popmessagecr ".EMIS Health", msg$                                 '     "
	    End If                                                               '     "
      Else                                                                       '25Jan00 AE  Added ELSE block
      'Otherwise, running new Overnight Job
	 msg$ = "Error " & Format$(Err) & ":'" & Error$ & "' occurred whilst Tidying Reprints (" & Stage$ & ")"
	 ONJLog sp$ & sp$ & msg$, iTestRun, iTestRun, True, False                '     "
	 ONJStoreError Right$(dispdata$, 3), "TidyReprints", True, iTestRun
      End If                                                                     '     "
      
   'GoTo TidyUpReprints_Exit                                               '19Oct99 AE Replaced
   Resume TidyUpReprints_Exit                                              '     "

End Sub

Sub WSspool (dummy1$, dummy2$, dum1%, dum2%, dum3%, dum4$)

End Sub

