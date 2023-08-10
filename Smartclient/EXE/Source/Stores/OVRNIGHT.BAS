' ----------------------------------------------------------------------------
'                                OVERNIGHT JOB MODULE
'                             -------------------------
'
'Holds routines for the new overnight job.
'When Building Overnite.exe, don't forget to update the ONJVer$ which
'holds the version of this program, as well as the global release number
'as usual.

'-----------------------------------------------------------------------------
'25Jan00 AE Written
'02Feb00 AE  GoOvernightJob:added extra logging.
'              Prevent errors occurring when attempting to remove semaphore files;
'              Only aquirelock on the semaphore files if doing a live run.
'02Feb00 AE  ArrangeONJForm:Added lines for mnuFile(2)
'03Feb00 AE  GoOvernightjob:Changed AquireLock to ONJAquireLock to prevent screen messages.
'03Feb00 AE  ONJAquireLock:Written.  Code taken from AquireLock, and parts pertaining to screen prompting
'            removed.
'03Feb00 AE  ONJStoreErr:Changed to use new procedure ONJWriteini
'03Feb00 AE  TidyONJLogs:Corrected to actually use the defined setting!
'            Also changed to use Input# instead of Input$
'10Feb00 AE  ONJReadSiteINfo: Written. Code ported from readsiteinfo with a few modifications.
'            Retain checking for encrypted hospname, etc. Does not
'            set variables which are irrelevant to the overnight job.
'            Uses ONJLivePath instead of relying on a drive mapping, as
'            these are not re-established by the AT command
'11Feb00 AE  ArrangeONJForm:Added Setup Options Title,Added Live Path to title
'11Feb00 AE  JobsSummary: Refresh Title. Wasn't refreshed if comming from Log View
'16Feb00 AE  GoOverniteJob:Added logging of who/what ran the program after someone was 'playing' with
'            the beta at oldham.
'16Feb00 AE  ONJReadSiteInfo:Changed default for ASC1 to ""
'01Mar00 AE  Overnight:Moved some code form frmONJSplash_Load. Now only asks for the pasword after
'            the live drive has been chosen.
'01Mar00 AE  ShowStatus: Now writes LastRan=INSTALL instead of a blank entry the first time.
'              Otherwise, readprivateprofilestring doesn't pick it up. Also writes
'              Default entries to ini file even if it already exists, but is empty
'01Mar00 AE  ViewONJLog:Cosmetic change to error message
'03Mar00 AE  TidyONJLogs:Correction to line setting sDir.  Was set as "\overnite\logs\*.log*.log" which
'              actually worked fine on NT but gave a "Path not Found" on '95
'03Mar00 TH  Raised version to 1.15 and built
'07Mar00 AE  SaveONJSettings:Now only saves path etc to ASCribe.ini if we are not using a non-standard
'            live path.
'19May00 AE  GoOvernightJob:Cosmetic changes to logging of certain errors.
'19May00 AE  CheckSetupChanges:Additions to allow the user to choose to delete inters after a certain
'            number of days. (similar to /inters switch in delord)
'            ShowSetupOptions: Changes for above
'            ShowExtraSetupInfo: Changes for Above
'            UpdateOptionSettings: Changes for above
'            DeleteIntersAfter: Written as part of above
'-------------------------------------------------
'19May00 AE  Version raised to 1.18
'-------------------------------------------------
'23May00 AE  GoOvernightJob: Enhanced to record time as well as date in ini File. Avoids problem when
'            the job is run before midnight, so a the program thinks it's missed a day.
'26May00 AE  BrowseDriveList:Now forces user to choose a drive, they cannot just cancel
'05Jul00 AE  DoContractPrices:Added line to save the new details to the drug file(!)
'-------------------------------------------------
'05Jul00 AE  Version raised to 1.19
'-------------------------------------------------
'01Nov00 AE  DoContractPrices:Corrected date handling when incrementing the date on the last day of the month
'-------------------------------------------------
'05Jul00 AE  Version raised to 1.20
'-------------------------------------------------
'25Feb02 TH  ONJLog: Replaced close in error trap as this closes all currently opened channels including
'    "       patchan which may yet be needed - instead close the relevant chan if appropriate (#57794)
'25Sep02 TH  DoFinancialCopy: Replaced year date handling for end of year run (#58073)
'01oct03 CKJ Added SlaveModeEnabled()
'05apr04 CKJ {SP1} removed dead globals

Option Explicit
DefInt A-Z

Const BORDER = 350

'File constants
Global Const ONJWorkingDir$ = "\Working"
Global Const ONJLogDir$ = "\Logs"
Global Const ONJLogFile = "\OverNite.log"
Global Const ONJAudit = "\Overnite.AUD"                         'Audit log, logs changes to settings
Const ONJTempLog = "\Overnite.tmp"
Global Const ONJINIFILE$ = "\overnite.ini"
Const MINONJLOGDURATION = 90                                    'min Num of days logs persist on disk
Global Const ONJVer = "version 1.20"                            'Sub version of this program
Global Const sp$ = "-------"                                    'separator for logs

'Constants for patidx options
Const PI_TIDYALL = 1
Const PI_CASENO = 2
Const PI_SNFN = 4
Const PI_FNSN = 8
Const PI_WDCON = 16
Const PI_RECNO = 32
Const PI_GP = 64
Const PI_RX = 128
Const PI_SOUND = 256
Const PI_FNSND = 512

'Display constants
Global Const LST_OFFSET = 30


Global iNumOfSites As Integer

Const ONJRecLen = 128           'Length of each record in the logs

Type SiteTypes
   Number As Integer                     'Site number
   Pat As Integer                        'Patdata,true or false
   Disp As Integer                       'Dispdata,true or false
   Wdelord As Integer                    'Orders re-index
   Patidx As Integer                     'Patient Re-index
   StckNght As Integer                   'Contract Price update
   FINANCPY As Integer                   'Multiple financial copy to \monthend
   SingleCopy As Integer                 'Single financial copy to dispdata.9xx
End Type

Dim SiteTypes() As SiteTypes
Dim SiteCop() As SiteTypes                   'Holds a copy of the data on disk to track changes.
Dim iSiteINdex As Integer
Dim iAutoRun As Integer
Dim sErrProc As String
Dim sErrStage As String

Dim SetupOptions() As String                    'Setup options storage

Sub AddNewRxerOnTheFly ()
'29Aug03 TH/ATW
'STUB
End Sub

Sub AddSite (sSite As String, sType As String)

'Add the given site type as a blank entry in the SiteTypes array


Dim n As Integer, M As Integer
Dim sEntry As String
Dim iNewSite As Integer
Dim iFound As Integer, sBuffer As String, sJob As String

   On Error GoTo ASErr
   sErrProc = "AddSite"
   sErrStage = ""

   iNewSite = True

   For n = 1 To iNumOfSites
	 If Val(sSite) = SiteTypes(n).Number Then
	       iNewSite = False
	       Exit For
	    End If
      Next

   If iNewSite Then
	 iNumOfSites = iNumOfSites + 1
	 ReDim Preserve SiteTypes(1 To iNumOfSites)
	 n = iNumOfSites
	 SiteTypes(n).Number = Val(sSite)
      End If

   
   Select Case sType
      Case "PAT"
	 SiteTypes(n).Pat = True
      Case "DIS"
	 SiteTypes(n).Disp = True
      End Select
   
AsExit:

   Exit Sub

ASErr:

   ONJErrHandler
   Resume AsExit

End Sub

Sub ArrangeChkJobs (sVisible As String)

'Arrange the check boxes & buttons to prevent holes.
'sVisible is a string, with one char for each check box.
'0 = check box not visible, 1 = check box visible, 2 = Check box and button visible


Const FRAJOBS_BORDER = 240

Dim iSpacing As Integer, iPos  As Integer
Dim n As Integer

   iSpacing = (frmOvernight.FraJobs.Height - 2 * FRAJOBS_BORDER) / Len(sVisible)

   'Set the positions
   For n = 1 To Len(sVisible)
      If Val(Mid$(sVisible, n, 1)) >= 1 Then
	    frmOvernight.ChkJob(n - 1).Left = FRAJOBS_BORDER
	    frmOvernight.ChkJob(n - 1).Top = iPos + iSpacing
	    iPos = iPos + iSpacing
	    frmOvernight.ChkJob(n - 1).Visible = True
	    If Val(Mid$(sVisible, n, 1)) = 2 Then
		  frmOvernight.CmdJobMore(n - 1).Left = frmOvernight.FraJobs.Width - frmOvernight.CmdJobMore(n - 1).Width - FRAJOBS_BORDER
		  frmOvernight.CmdJobMore(n - 1).Top = frmOvernight.ChkJob(n - 1).Top
		  frmOvernight.CmdJobMore(n - 1).Visible = True
		  frmOvernight.CmdJobMore(n - 1).Enabled = True
	       Else
		  frmOvernight.CmdJobMore(n - 1).Visible = False
		  frmOvernight.CmdJobMore(n - 1).Enabled = False
	       End If
	 Else
	    frmOvernight.ChkJob(n - 1).Visible = False
	    frmOvernight.CmdJobMore(n - 1).Visible = False
	    frmOvernight.CmdJobMore(n - 1).Enabled = False
	 End If
   Next

End Sub

Sub ArrangeONJForm (iMode As Integer)

'1: Begining Status report, pnlstatus and txtstatus visible.
'2: Summary report, pnlSummary and lst summary visible
'3: Jobs By site, PnlJobs visible
'4: Status report
'5: Screen presence only, when running automatically
'6: Options view, PnlOptions visible
'
'---------------------------------------------------------------
'02Feb00 AE  Added lines for mnuFile(2)
'11Feb00 AE  Added Setup Options Title

Static iCurrentMode As Integer

   sErrProc = "ArrangeONJForm"
   sErrStage = "Case " & Format$(iMode)
   On Error GoTo AOFErr

   frmOvernight.TxtStatus.Text = ""
   frmOvernight.LstSummary.Clear
   ONJinfo ""

   If iMode = iCurrentMode Then Exit Sub

   Select Case iMode
      Case 1                                                    'Begining Status report
	 frmOvernight.PnlOptions.Visible = False
	 frmOvernight.Height = 9200
	 frmOvernight.HscSummary.Visible = False
	 frmOvernight.FraJobs.Visible = False
	 frmOvernight.PicBackground.Visible = False
	 frmOvernight.PnlSummary.Visible = True
	 frmOvernight.PnlJob.Visible = False
	 frmOvernight.LstSummary.Visible = False
	 frmOvernight.PnlSummary.Top = BORDER + frmOvernight.PnlTitle.Top + frmOvernight.PnlTitle.Height
	 frmOvernight.TxtStatus.Top = BORDER
	 frmOvernight.TxtStatus.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.TxtStatus.Left = BORDER
	 frmOvernight.TxtStatus.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.TxtStatus.Visible = True
	 frmOvernight.CmdExit.Visible = False
	 frmOvernight.CmdExit.Enabled = False
	 frmOvernight.CmdProcede.Caption = "&Next..."
	 frmOvernight.CmdProcede.Enabled = True
	 frmOvernight.CmdProcede.Visible = True
	 frmOvernight.CmdProcede.Tag = "NEXT"
	 frmOvernight.MnuFile(0).Enabled = False
	 frmOvernight.MnuFileTitle.Enabled = True            '02Dec00 Changed to True
	 frmOvernight.MnuFile(1).Enabled = False
	 frmOvernight.MnuFile(2).Enabled = True              '02Dec00  Added
	 frmOvernight.MnuFile(2).Visible = True              '    "
	 frmOvernight.MnuViewtitle.Enabled = False
	 frmOvernight.MnuOptionsTitle.Enabled = False
	 frmOvernight.MnuInfoTitle.Enabled = False
	 frmOvernight.PicSplash.Visible = False
	 frmOvernight.PnlTestMode.Visible = True
	 frmOvernight.PnlTitle.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlTestMode.Top + frmOvernight.PnlTestMode.Height - frmOvernight.PnlInfo.Height
	 frmOvernight.CmdProcede.SetFocus

      Case 2                                                    'Summary report
	 frmOvernight.PnlOptions.Visible = False
	 frmOvernight.Height = 9200
	 frmOvernight.FraJobs.Visible = False
	 frmOvernight.PnlSummary.Visible = True
	 frmOvernight.PnlJob.Visible = False
	 frmOvernight.LstSummary.Visible = True
	 frmOvernight.PnlSummary.Top = BORDER + frmOvernight.PnlTitle.Top + frmOvernight.PnlTitle.Height
	 frmOvernight.LstSummary.Height = frmOvernight.PnlSummary.Height - 2 * BORDER + 2 * LST_OFFSET
	 frmOvernight.LstSummary.Width = 10000
	 frmOvernight.LstSummary.Top = -LST_OFFSET
	 frmOvernight.LstSummary.Left = -LST_OFFSET
	 frmOvernight.PicBackground.Visible = True
	 frmOvernight.PicBackground.Top = BORDER
	 frmOvernight.PicBackground.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.PicBackground.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.PicBackground.Left = BORDER
	 frmOvernight.HscSummary.Visible = True
	 frmOvernight.HscSummary.Value = 0
	 frmOvernight.HscSummary.Left = frmOvernight.PicBackground.Left
	 frmOvernight.HscSummary.Top = frmOvernight.PicBackground.Height + frmOvernight.PicBackground.Top
	 frmOvernight.HscSummary.Width = frmOvernight.PicBackground.Width
	 frmOvernight.TxtStatus.Visible = False
	 frmOvernight.CmdExit.Visible = True
	 frmOvernight.CmdExit.Enabled = True
	 frmOvernight.LblTitle.Caption = "Summary of All Scheduled Jobs"
	 frmOvernight.CmdProcede.Caption = "Run &Jobs"
	 frmOvernight.CmdProcede.Enabled = True
	 frmOvernight.CmdProcede.Visible = True
	 frmOvernight.CmdProcede.Tag = "RUN"
	 frmOvernight.MnuFile(0).Enabled = True
	 frmOvernight.LstSummary.Clear
	 frmOvernight.PicSplash.Visible = False
	 frmOvernight.PnlTestMode.Visible = True
	 frmOvernight.PnlTitle.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlTestMode.Top + frmOvernight.PnlTestMode.Height - frmOvernight.PnlInfo.Height
	 frmOvernight.LstSummary.SetFocus

      Case 3                                                   'Jobs By site view
	 frmOvernight.LstSummary.Top = -LST_OFFSET
	 frmOvernight.LstSummary.Left = -LST_OFFSET
	 frmOvernight.LstSummary.Height = frmOvernight.PnlSummary.Height - 2 * BORDER + 2 * LST_OFFSET
	 frmOvernight.PicBackground.Top = BORDER
	 frmOvernight.PicBackground.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.LstSummary.Width = 10000
	 frmOvernight.PicBackground.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.PicBackground.Left = BORDER
	 frmOvernight.PicBackground.Visible = True
	 frmOvernight.HscSummary.Value = 0
	 frmOvernight.HscSummary.Visible = True
	 frmOvernight.HscSummary.Left = frmOvernight.PicBackground.Left
	 frmOvernight.HscSummary.Top = frmOvernight.PicBackground.Height + frmOvernight.PicBackground.Top
	 frmOvernight.HscSummary.Width = frmOvernight.PicBackground.Width
	 frmOvernight.PnlOptions.Visible = False
	 frmOvernight.Height = 9200
	 frmOvernight.FraJobs.Visible = True
	 frmOvernight.PnlSummary.Visible = False
	 frmOvernight.PnlJob.Visible = True
	 frmOvernight.LstSummary.Visible = False
	 frmOvernight.PnlJob.Top = BORDER + frmOvernight.PnlTitle.Top + frmOvernight.PnlTitle.Height
	 frmOvernight.TxtStatus.Visible = False
	 frmOvernight.CmdExit.Visible = True
	 frmOvernight.CmdExit.Enabled = True
	 frmOvernight.CmdProcede.Caption = "Run &Jobs"
	 frmOvernight.CmdProcede.Enabled = True
	 frmOvernight.CmdProcede.Visible = True
	 frmOvernight.CmdProcede.Tag = "RUN"
	 frmOvernight.MnuFile(0).Enabled = True
	 frmOvernight.LblTitle.Caption = "Scheduled Jobs By Site on " & ONJLivePath()
	 frmOvernight.PicSplash.Visible = False
	 frmOvernight.PnlTestMode.Visible = True
	 frmOvernight.PnlTitle.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlTestMode.Top + frmOvernight.PnlTestMode.Height - frmOvernight.PnlInfo.Height
	 frmOvernight.CmdJobNext.SetFocus

      Case 4                                       'Status report
	 frmOvernight.PnlOptions.Visible = False
	 frmOvernight.PicBackground.Visible = False
	 frmOvernight.HscSummary.Visible = False
	 frmOvernight.Height = 9200
	 frmOvernight.FraJobs.Visible = False
	 frmOvernight.PnlSummary.Visible = True
	 frmOvernight.PnlJob.Visible = False
	 frmOvernight.LstSummary.Visible = False
	 frmOvernight.PnlSummary.Top = BORDER + frmOvernight.PnlTitle.Top + frmOvernight.PnlTitle.Height
	 frmOvernight.TxtStatus.Top = BORDER
	 frmOvernight.TxtStatus.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.TxtStatus.Left = BORDER
	 frmOvernight.TxtStatus.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.TxtStatus.Visible = True
	 frmOvernight.CmdExit.Visible = True
	 frmOvernight.CmdExit.Enabled = True
	 frmOvernight.CmdProcede.Caption = "&Back..."
	 frmOvernight.CmdProcede.Enabled = True
	 frmOvernight.CmdProcede.Visible = True
	 frmOvernight.CmdProcede.Tag = "BACK"
	 frmOvernight.MnuFile(0).Enabled = True
	 frmOvernight.PicSplash.Visible = False
	 frmOvernight.PnlTestMode.Visible = True
	 frmOvernight.PnlTitle.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlTestMode.Top + frmOvernight.PnlTestMode.Height - frmOvernight.PnlInfo.Height
	 frmOvernight.CmdProcede.SetFocus

       Case 5
	 frmOvernight.PnlOptions.Visible = False
	 frmOvernight.PicBackground.Visible = False
	 frmOvernight.HscSummary.Visible = False
	 frmOvernight.PnlTitle.Visible = False
	 frmOvernight.Height = frmOvernight.PnlSummary.Height + frmOvernight.PnlInfo.Height + 4 * BORDER
	 frmOvernight.FraJobs.Visible = False
	 frmOvernight.PnlSummary.Visible = True
	 frmOvernight.PnlJob.Visible = False
	 frmOvernight.LstSummary.Visible = False
	 frmOvernight.PnlSummary.Top = BORDER
	 frmOvernight.TxtStatus.Top = BORDER
	 frmOvernight.TxtStatus.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.TxtStatus.Left = BORDER
	 frmOvernight.TxtStatus.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.TxtStatus.Visible = False
	 frmOvernight.CmdExit.Visible = False
	 frmOvernight.CmdExit.Enabled = False
	 frmOvernight.CmdProcede.Caption = "Run &Jobs"
	 frmOvernight.CmdProcede.Enabled = False
	 frmOvernight.CmdProcede.Visible = False
	 frmOvernight.CmdProcede.Tag = "RUN"
	 frmOvernight.MnuFile(0).Enabled = True
	 frmOvernight.PicSplash.Top = BORDER
	 frmOvernight.PicSplash.Left = BORDER
	 frmOvernight.PicSplash.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.PicSplash.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.PicSplash.Visible = True
	 frmOvernight.PnlTestMode.Visible = False
	 frmOvernight.LblSplash.Width = frmOvernight.PicSplash.Width
	 frmOvernight.LblSplash.Height = frmOvernight.PicSplash.Height - frmOvernight.PicLogo.Height - 1.5 * BORDER
	 frmOvernight.LblSplash.Left = 0
	 frmOvernight.MnuFileTitle.Visible = False
	 frmOvernight.MnuViewtitle.Visible = False
	 frmOvernight.MnuOptionsTitle.Visible = False
	 frmOvernight.MnuInfoTitle.Visible = False
	 frmOvernight.MnuHelpTitle.Visible = False
	 frmOvernight.PnlInfo.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlSummary.Top + frmOvernight.PnlSummary.Height + BORDER

      Case 6                              'Options -> Settings view
	 frmOvernight.PicBackground.Visible = False
	 frmOvernight.HscSummary.Visible = False
	 frmOvernight.Height = 9200
	 frmOvernight.PnlOptions.Visible = True
	 frmOvernight.FraJobs.Visible = False
	 frmOvernight.PnlSummary.Visible = False
	 frmOvernight.PnlJob.Visible = False
	 frmOvernight.LstSummary.Visible = False
	 frmOvernight.PnlSummary.Top = 1200
	 frmOvernight.TxtStatus.Top = BORDER
	 frmOvernight.TxtStatus.Height = frmOvernight.PnlSummary.Height - 2 * BORDER
	 frmOvernight.TxtStatus.Left = BORDER
	 frmOvernight.TxtStatus.Width = frmOvernight.PnlSummary.Width - 2 * BORDER
	 frmOvernight.TxtStatus.Visible = False
	 frmOvernight.CmdExit.Visible = False
	 frmOvernight.CmdExit.Enabled = False
	 frmOvernight.CmdProcede.Caption = "E&xit Setup"
	 frmOvernight.CmdProcede.Enabled = True
	 frmOvernight.CmdProcede.Visible = True
	 frmOvernight.CmdProcede.Tag = "EXITSETUP"
	 frmOvernight.MnuFile(0).Enabled = True
	 frmOvernight.PicSplash.Visible = False
	 frmOvernight.PnlTestMode.Visible = True
	 frmOvernight.PnlTitle.Visible = True
	 frmOvernight.PnlInfo.Top = frmOvernight.PnlTestMode.Top + frmOvernight.PnlTestMode.Height - frmOvernight.PnlInfo.Height
	 frmOvernight.FraOptionControls.Enabled = False
	 frmOvernight.MnuFile(0).Enabled = False
	 frmOvernight.MnuFileTitle.Enabled = False
	 frmOvernight.MnuViewtitle.Enabled = False
	 frmOvernight.MnuOptionsTitle.Enabled = False
	 frmOvernight.MnuInfoTitle.Enabled = False
	 frmOvernight.LstOptions.SetFocus
	 frmOvernight.LblTitle.Caption = "Setup Options"                                  '11Feb00 AE  Added

      End Select

   'Settings for all sites
   If Val(Mid$(Acclevels$, 6, 1)) < 9 Then frmOvernight.MnuOptionsTitle.Enabled = False
   
   iCurrentMode = iMode
   frmOvernight.Refresh

AOFExit:

Exit Sub

AOFErr:
   
   ONJErrHandler
   Resume AOFExit

End Sub

Sub BlankFinancpySettings ()

'Changes all the SiteTypes().FINANCPY settings to 0

Dim n As Integer

   For n = 1 To iNumOfSites
      SiteTypes(n).SingleCopy = 0
   Next

End Sub

Sub BrowseDriveList (iNewSetup As Integer)
   
'Offer a list of all writeable, available drives plus "Default"
'Allow the user to change the current live drive by choosing from the list.
'If they choose to change, and this is not the first run of the program,
'the ini file is killed and re-created with the new drive entry in.
'LastRan is ommited, and the program terminates.  This forces the program to
're-enter the firstrun set up process when next run.

'iNewSetup = True:  Change is written to the ini file, and proc exits
'iNewSetup = False: Dire warnings, ini file is destroyed and recreated, program
'                   terminates. On re-running, it will enter the initial setup process
'---------------------------------------------------------------------------------------
'26May00 AE  Now forces user to choose a drive, they cannot just cancel


Dim n As Integer, iValue As Integer
Dim sDrv As String, sMsg As String, iFil As Integer
Dim ok As Integer, sCurDrive As String

   sCurDrive = ONJLivePath()
   
   Unload frmPopList
   Do                                                 '26May00 AE  Added loop to force choice
      CentreForm frmPopList
      frmPopList.Caption = "Overnight Job"
      frmPopList.Prompt = "Choose Live Drive"
      frmPopList.LstBox.Clear
      frmPopList.LstBox.AddItem "Default"
      frmPopList.LstBox.ItemData(frmPopList.LstBox.NewIndex) = 1
      For n = Asc("C") To Asc("Z")
	    sDrv = Chr$(n) & ":\"
	    On Error Resume Next
	    iValue = GetAttr(sDrv)                       '(ATTR_READONLY = 1)
	    If Err = 0 And Not (iValue And 1) Then       'device available, and not (readonly)
		  frmPopList.LstBox.AddItem sDrv
		  frmPopList.LstBox.ItemData(frmPopList.LstBox.NewIndex) = n
	       End If
	 On Error GoTo 0
	 Next
	 frmPopList.Show 1
   Loop Until frmPopList.Tag <> ""

   iValue = Val(frmPopList.Tag)
   

   If iValue = 1 Then                                 'Default Live Drive
	 GetLivePath
	 sDrv = ONJLivePath()
      Else
	 sDrv = Chr$(iValue) & ":"
      End If

   If sCurDrive = sDrv Then Exit Sub                  'Quietly exit if no change made

   If Not iNewSetup Then
	 sMsg = "Warning!  You have chosen to change the Live Drive" & cr$
	 sMsg = sMsg & "upon which this program acts." & cr$ & cr$
	 sMsg = sMsg & "Continuing will result in ALL OVERNIGHT JOB SETTINGS BEING LOST!" & cr$
	 sMsg = sMsg & "(Your Action will be logged)" & cr$
	 sMsg = sMsg & "Are you SURE you wish to do this ?"
	 iValue = MessageBox(sMsg, MB_YESNO + MB_DEFBUTTON2 + MB_ICONSTOP, "Overnight Job")
	 If iValue = IDYES Then
	       sMsg = "This program will now exit.  Run the program again to" & cr$
	       sMsg = sMsg & "set it up for the new Live Drive" & cr$ & cr$
	       sMsg = sMsg & "Are you SURE you wish to do this ?"
	       iValue = MessageBox(sMsg, MB_YESNO + MB_DEFBUTTON2 + MB_ICONSTOP, "Overnight Job")
	       If iValue = IDYES Then
		     'user has chosen to change the drive; kill the current ini file
		     'Create a new ini file on disk
		     WriteONJAuditLine "Changed Live Drive", sDrv, 0
		     Kill AppPathNoSlash() & ONJINIFILE$
		     iFil = FreeFile
		     Open AppPathNoSlash() & ONJINIFILE$ For Output As iFil
		     Close iFil
		     frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Creating File " & AppPathNoSlash() & ONJINIFILE$ & crlf$
		     WritePrivateIniFile "", "LogFileDuration", Format$(2 * MINONJLOGDURATION), AppPathNoSlash() & ONJINIFILE$, ok  'default is twice minimum
		     WritePrivateIniFile "", "MultipleSnapshot", "N", AppPathNoSlash() & ONJINIFILE$, ok   'default multiple copy is into monthend\
		     WritePrivateIniFile "", "ForceSingleSnapshot", "Y", AppPathNoSlash() & ONJINIFILE$, ok                         'default is on
		     WritePrivateIniFile "", "NonStandardLivePath", sDrv, AppPathNoSlash() & ONJINIFILE$, ok
		     frmOvernight.Tag = ""
		     frmOvernight.Hide                    '<===Exit program
		  End If
	 End If

      Else
      'first run, just save new setting and exit
	 WritePrivateIniFile "", "NonStandardLivePath", sDrv, AppPathNoSlash() & ONJINIFILE$, ok
	 SetONJLivePath sDrv
      End If



End Sub

Sub CheckAndLogChanges ()

'Compare the current data on disk with the copy taken when the program first started.
'Any changes are logged into the Logs directory, in an .AUD file which has a simple encryption run on it.

Dim iFound As Integer, n As Integer
Dim sLogFile  As String, sLine As String, sEncrLine As String
Dim sValue As String * 3, sNAme As String
Dim iFil As Integer

   sErrProc = "CheckAndLogChanges"
   sErrStage = ""
   On Error GoTo CALCErr

   'First time, sitecop will be empty, so quick exit
   On Error Resume Next
   n = UBound(SiteCop)
   On Error GoTo CALCErr
   If n = 0 Then Exit Sub

   'Any changes will have been saved to disk.
   For n = 1 To iNumOfSites
	 If n <= UBound(SiteCop) Then                       'Only compare if there is data to compare with!
	       If SiteTypes(n).Wdelord <> SiteCop(n).Wdelord Then
		     sValue = IFF(SiteTypes(n).Wdelord = 0, "OFF", "ON")
		     sNAme = "Stores Reindexing"
		     WriteONJAuditLine sNAme, sValue, SiteTypes(n).Number
		  End If
	 
	       If SiteTypes(n).Patidx <> SiteCop(n).Patidx Then
		     sValue = IFF(SiteTypes(n).Patidx = 0, "OFF", "ON")
		     sNAme = "Patient Reindexing"
		     WriteONJAuditLine sNAme, sValue, SiteTypes(n).Number
		  End If
	 
	       If SiteTypes(n).FINANCPY <> SiteCop(n).FINANCPY Then
		     sValue = IFF(SiteTypes(n).FINANCPY = 0, "OFF", "ON")
		     sNAme = "Financial Copy to " & GetMonthendDir()
		     WriteONJAuditLine sNAme, sValue, SiteTypes(n).Number
		  End If
	 
	       If SiteTypes(n).SingleCopy <> SiteCop(n).SingleCopy Then
		     sValue = IFF(SiteTypes(n).SingleCopy = 0, "OFF", "ON")
		     sNAme = "Financial Copy to Dispdata.9**"
		     WriteONJAuditLine sNAme, sValue, SiteTypes(n).Number
		  End If

	       If SiteTypes(n).StckNght <> SiteCop(n).StckNght Then
		     sValue = IFF(SiteTypes(n).StckNght = 0, "OFF", "ON")
		     sNAme = "Contract Price Update"
		     WriteONJAuditLine sNAme, sValue, SiteTypes(n).Number
		  End If
	    End If
   Next

CALCExit:

Exit Sub

CALCErr:

   ONJErrHandler
   Resume CALCExit

End Sub

Sub CheckSetupChanges ()

'Called when exiting setup, checks for changes against the current settings on disk.
'19May00 AE  Additions to allow the user to choose to delete inters after a certain
'            number of days. (similar to /inters switch in delord)


Dim iMultipleSnapshot As Integer, iFound As Integer, sTmp As String
Dim iComp As Integer, ans$, k As kbdcontrol, sSite As String, n As Integer
Dim iValue As Integer, sLine As String

   sErrProc = "CheckSetupChanges"
   sErrStage = ""
   On Error GoTo CSCErr

   sTmp = "Are you sure you wish to accept these settings ?"
   AskWin "!Overnight Job", sTmp, ans$, k
   Select Case ans$
      Case "Y"
	 'Multiple financial copy setting
	 sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "MultipleSnapshot", iFound)
	 If sTmp <> SetupOptions(1) Then
	       sLine = IFF(SetupOptions(1) = "Y", "ON", "OFF")
	       WriteONJAuditLine "Multiple Financial Copy", sLine, 0
	       WritePrivateIniFile "", "MultipleSnapshot", SetupOptions(1), AppPathNoSlash() & ONJINIFILE, iFound
	       'Also write to ascribe.ini, so that reporter can pick up if the setting is turned on
	       For n = 1 To iNumOfSites
		     sSite = Format$(SiteTypes(n).Number, "000")
		     WritePrivateIniFile "OvernightJob", "MultipleSnapshot", SetupOptions(1), "\dispdata." & sSite & "\Ascribe.ini", 0
		  Next
	    End If
	 
	 'Force Financial copy to Dispdata.9xx setting
	 sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "ForceSingleSnapshot", iFound)
	 If sTmp <> SetupOptions(4) Then
	       sLine = IFF(SetupOptions(4) = "Y", "ON", "OFF")
	       WritePrivateIniFile "", "ForceSingleSnapshot", SetupOptions(4), AppPathNoSlash() & ONJINIFILE, iFound
	       WriteONJAuditLine "Force Financial Copy to Dispdata.9xx", sLine, 0
	    End If

	 'Delete delivery notes older than 7 days
	 sTmp = TxtD$(dispdata$ & "\wdelord.ini", "", "", "DeleteDelNotes", iFound)
	 iValue = Val(sTmp)
	 iComp = Val(SetupOptions(2))
	 If iComp <> iValue Then
	       WritePrivateIniFile "", "DeleteDelNotes", Format$(iComp), dispdata$ & "\wdelord.ini", iFound
	       WriteONJAuditLine "Delete Delivery Notes > 7Days", IFF(iComp, "ON", "OFF"), 0
	    End If
	 
	 'Log file duration setting
	 sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "LogFileDuration", iFound)
	 iValue = Val(sTmp)
	 iComp = Val(SetupOptions(3))
	 If iComp <> iValue Then
	       WritePrivateIniFile "", "LogFileDuration", Format$(iComp), AppPathNoSlash() & ONJINIFILE, iFound
	       WriteONJAuditLine "Log file duration", Format$(iComp), 0
	    End If
	 
	 'Internal orders duration on disk                                                                     '19May00 AE Added
	 sTmp = TxtH$(AppPathNoSlash() & ONJINIFILE, "", "", "DeleteInters", iFound)                           '     "
	 iValue = Val(sTmp)                                                                                    '     "
	 iComp = Val(SetupOptions(5))                                                                          '     "
	 If iComp <> iValue Then                                                                               '     "
	       WritePrivateIniFile "", "DeleteInters", Format$(iComp), AppPathNoSlash() & ONJINIFILE, iFound   '     "
	       WriteONJAuditLine "Delete Internal Orders", Format$(iComp), 0                                   '     "
	    End If                                                                                             '     "

	 
	 
	 '
	 '
	 'Other checks if required
	 '
	 '
	 k.escd = False
	 
	 FlushIniCache

      Case "N"
	 popmessagecr "#OvernightJob", "Settings unchanged"
	 k.escd = False

      Case ""
	 k.escd = True
      End Select

   frmOvernight.MnuFile(0).Enabled = True
   frmOvernight.MnuFileTitle.Enabled = True
   frmOvernight.MnuViewtitle.Enabled = True
   frmOvernight.MnuOptionsTitle.Enabled = True
   frmOvernight.MnuInfoTitle.Enabled = True

   If Not k.escd Then showsitejobs 1

CSCExit:

Exit Sub

CSCErr:

   ONJErrHandler
   Resume CSCExit

End Sub

Sub ChoosePatIdxOptions ()

'Allow the user to set patient re-indexing options.
'These are converted to a string, and stored in the
'SiteTypes array; they're passed in to ONJPatientReindex as
'a parameter

Dim sTmp As String, sResult As String
Dim iValue As Integer

   sTmp = "Patient Reindexing Options; "
   frmoptionset 0, sTmp
   frmoptionset 1, "Full Rebuild of Case No. Index (\Patid.idx)"
   frmoptionset 1, "Full Rebuild of Surname,Forename Index (\Patsnfn.idx)"
   frmoptionset 1, "Full Rebuild of Forename,Surname Index (\Patfnsn.idx)"
   frmoptionset 1, "Full Rebuild of Ward,Status,Consultant Index (\Patwdcon.idx)"
   frmoptionset 1, "Full Rebuild of Internal Record Number Index (\Patrecno.idx)"
   frmoptionset 1, "Full Rebuild of GP Index (\Patgp.idx)"
   frmoptionset 1, "Full Rebuild of Prescription Number Index (\Rx.idx)"
   frmoptionset 1, "Full Rebuild of Surname Soundalike Index (\Patsound.idx)"
   frmoptionset 1, "Full Rebuild of Initial,Surname Soundalike Index (\Patfnsnd.idx)"

   sTmp = "000000000"
   iValue = SiteTypes(iSiteINdex).Patidx
   If iValue And PI_CASENO Then Mid$(sTmp, 1, 1) = "1"
   If iValue And PI_SNFN Then Mid$(sTmp, 2, 1) = "1"
   If iValue And PI_FNSN Then Mid$(sTmp, 3, 1) = "1"
   If iValue And PI_WDCON Then Mid$(sTmp, 4, 1) = "1"
   If iValue And PI_RECNO Then Mid$(sTmp, 5, 1) = "1"
   If iValue And PI_GP Then Mid$(sTmp, 6, 1) = "1"
   If iValue And PI_RX Then Mid$(sTmp, 7, 1) = "1"
   If iValue And PI_SOUND Then Mid$(sTmp, 8, 1) = "1"
   If iValue And PI_FNSND Then Mid$(sTmp, 9, 1) = "1"

   frmoptionshow sTmp, sResult
   frmoptionset 0, ""

   If sResult = "" Then Exit Sub
   iValue = 1
   If Mid$(sResult, 1, 1) = "1" Then iValue = iValue + PI_CASENO
   If Mid$(sResult, 2, 1) = "1" Then iValue = iValue + PI_SNFN
   If Mid$(sResult, 3, 1) = "1" Then iValue = iValue + PI_FNSN
   If Mid$(sResult, 4, 1) = "1" Then iValue = iValue + PI_WDCON
   If Mid$(sResult, 5, 1) = "1" Then iValue = iValue + PI_RECNO
   If Mid$(sResult, 6, 1) = "1" Then iValue = iValue + PI_GP
   If Mid$(sResult, 7, 1) = "1" Then iValue = iValue + PI_RX
   If Mid$(sResult, 8, 1) = "1" Then iValue = iValue + PI_SOUND
   If Mid$(sResult, 9, 1) = "1" Then iValue = iValue + PI_FNSND
   
   SiteTypes(iSiteINdex).Patidx = iValue



End Sub

Sub ClearONJFiles ()

'Tidy up working files before a run
   On Error Resume Next
   Kill AppPathNoSlash() & ONJWorkingDir$ & "\*.tmp"
   On Error GoTo 0

End Sub

Function DeleteIntersAfter () As Integer

'Return the number of days to delete completed internal orders after.
'If zero, setting is considered turned off and they will not be deleted.
'19May00 AE

   DeleteIntersAfter = Val(TxtH$(AppPathNoSlash() & ONJINIFILE, "", "", "DeleteInters", 0))

End Function

Sub DoContractPrices (iTestRun As Integer, iToScreen As Integer)

'It iTestRun then do everything except update the drug file.  The details are read and logged, and the
'changes entered are deleted.  No changes are made to the contract data or the drug price if testrun is on.
'
'25jan00 AE  Based on Sub Main from StckNght
'05Jul00 AE  Added line to save the new details to the drug file(!)
'01Nov00 AE  Corrected date handling when incrementing the date on the last day of the month

Dim dyn As dynaset
Dim tdtest1 As DateAndTime, tdtest2 As DateAndTime, tdNow As DateAndTime
Dim today$, sql$, newcontno$, newcontprice$, oldcontprice$, oldcontno$, TblName$
Dim foundPtr&, findPtr&    ' 01Jun02 ALL/ATW
Dim tdAddOne As DateAndTime

Dim workingdate$


   ONJLog sp$ & "Starting Contract Price update " & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False
   ONJinfo "Opening Contract Price Database..."

   If Not Fileexists(dispdata$ & "\wslist.mdb") Then
	 'replace with new log routine
	 ONJLog sp$ & sp$ & "Warning! Could not find Wslist.mdb in " & dispdata$, iTestRun, iToScreen, True, False
	 End
      End If

   Set WSDB = OpenDatabase(dispdata$ & "\wslist.mdb")

   'meat and two veg bit
   today$ = Format(Now, "ddmmyyyy")
   
   tdtest1.Yrs = Val(Mid$(today$, 5, 4))
   tdtest1.Mth = Val(Mid$(today$, 3, 2))
   tdtest1.Day = Val(Mid$(today$, 1, 2))
   tdtest1.hrs = 23
   tdtest1.min = 59
   datetomins tdtest1
   
   tdtest2.Yrs = Val(Mid$(today$, 5, 4))
   tdtest2.Mth = Val(Mid$(today$, 3, 2))
   tdtest2.Day = Val(Mid$(today$, 1, 2))
   tdtest2.hrs = 12
   tdtest2.min = 0
   datetomins tdtest2

   today tdNow

   If tdNow.mint < tdtest1.mint And tdNow.mint > tdtest2.mint Then
	 'if time is between midday and midnight then
	 'assume that we are looking for next days date
	 'tdnow.Day = tdnow.Day + 1                                              '01Nov00 AE  Corrected date handling
	 tdAddOne.Day = 1                                                        '     "
	 addexpiry tdNow, tdAddOne                                               '     "
      End If
	    
   datetostring tdNow, workingdate$

   ONJLog sp$ & sp$ & "Looking for records with date of change = " & workingdate$, iTestRun, iToScreen, False, False
   ONJLog sp$ & sp$ & "Processing Drug contract details", iTestRun, iToScreen, False, False
   ONJinfo "Looking for records with date of change = " & workingdate$

   On Error GoTo MainErr

   'Process any changes in drug contract details
   TblName$ = "ExtraDrugDetails"
   sql$ = "SELECT * FROM ExtraDrugDetails WHERE DateOfChange = '" & workingdate$ & "';"
   Set dyn = WSDB.CreateDynaset(sql$)

   Do While Not dyn.EOF
	
      foundPtr& = 0: findPtr = 0   ' 01Jun02 ALL/ATW
      d.siscode = getfield(dyn!NSVCode)
      getdrug d, findPtr, foundPtr&, True   ' 01Jun02 ALL/ATW
   
      If foundPtr& Then
	    ONJinfo "Processing Changes for Drug " & d.siscode
	    oldcontprice$ = d.contprice
	    oldcontno$ = d.contno
      
	    newcontprice$ = getfield(dyn!NewContractPrice)
	    If Trim(newcontprice$) <> "" Then
		  If Not iTestRun Then
			d.contprice = Format$(Val(newcontprice$) * 100)
		     End If
		  ONJLog sp$ & sp$ & d.siscode & " - Contract price changed from " & oldcontprice$ & " to " & d.contprice, iTestRun, iToScreen, False, False
	       End If
	    
	    newcontno$ = getfield(dyn!NewContractNumber)
	    If Trim(newcontno$) <> "" Then
		  If Not iTestRun Then
			d.contno = newcontno$
		     End If
		  ONJLog sp$ & sp$ & d.siscode & " - Contract number changed from " & oldcontno$ & " to " & d.contno, iTestRun, iToScreen, False, False
	       End If
      
	    If Not iTestRun Then putdrug d, foundPtr&                                      '05Jul00 AE Ooops....this line was missing  ' 01Jun02 ALL/ATW

	    dyn.Edit                             'Delete the entry even if a test run
	    dyn!DateofChange = ""
	    dyn!NewContractPrice = ""
	    dyn!NewContractNumber = ""
	    dyn.Update
	       
      
	 Else
	    'log drug not found to update
	    ONJLog sp$ & sp$ & "ERROR! Could not find drug " & d.siscode, iTestRun, iToScreen, True, False
	 End If
      
      dyn.MoveNext

   DoEvents

   Loop

   ONJLog sp$ & sp$ & "Processing Supplier Contract Details file.", iTestRun, iToScreen, False, False

   'process any changes in supplier contract details
   TblName$ = "ExtraSupplierData"
   sql$ = "SELECT * FROM ExtraSupplierData WHERE DateOfChange = '" & workingdate$ & "';"
   Set dyn = WSDB.CreateDynaset(sql$)

   Do While Not dyn.EOF
	
      ONJinfo "Processing Changes for Supplier " & dyn!supcode
      If Not iTestRun Then                                     'Live run.
	    dyn.Edit
	    dyn!CurrentContractData = dyn!NewContractData
	    dyn!NewContractData = ""
	    dyn!DateofChange = ""
	    dyn.Update
	    dyn.MoveNext
	 Else                                                  'Test - log details, delete change entries, leave original data unchanged
	    ONJLog sp$ & sp$ & "changing contract data from " & dyn!CurrentContractData & " to " & dyn!NewContractData, iTestRun, iToScreen, False, False
	    dyn.Edit
	    dyn!NewContractData = ""
	    dyn!DateofChange = ""
	    dyn.Update
	    dyn.MoveNext
	 End If
	    
   ONJLog sp$ & "Processed contract details for supplier : " & getfield(dyn!supcode), iTestRun, iToScreen, False, False

   DoEvents

   Loop

   On Error GoTo 0
   ONJLog sp$ & "Finished updating contract prices" & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False

ShutDown:
   On Error Resume Next
   ' close the dynaset
   dyn.Close
   WSDB.Close

   Set dyn = Nothing
   Set WSDB = Nothing
   On Error GoTo 0

Exit Sub

MainErr:
'Write Errors to the overnight job logs
   ONJLog sp$ & sp$ & "Error " & Format$(Err) & ":'" & Error$ & "' occurred while processing " & TblName$ & ".", iTestRun, iToScreen, True, False
   ONJStoreError Right$(dispdata$, 3), "ContractPrices", True, iTestRun
   Resume ShutDown

End Sub

Sub DoFinancialCopy (iMonthend, iOldMethod, iTestRun As Integer)
'
'               Take copy of all files needed for finance reporting
'
'Now allows multiple copies, the switch for which is stored in the ini file.
'Can still copy to Dispdata.901 - 912 as before, but can also copy to \monthend.
'In this case, the data is stored in \Monthend\yyyymm.xxx
'Where yyyymm is the numerical date, eg, 200001 - 200012, and xxx is the site number.
'Thus all data from november 2000 for site 123 goes into Monthend\200011.123

'As per original, copy dispdata.xxx to dispdata.9mm, unless before 7am on the first day of
'the month, in which case copy to the previous month's.
'
'iMonthend:   Set to True to copy the data into Monthend\yyyymm.xxx
'iOldMethod:  Set to True to copy the data into Dispdata.9xx.  Note that both of these
'             can be True, in which case the data is copied into both places.
'iTestRun:    If true, simply checks for access to all directories and files.
'------------------------------------------------------------------------------------
'
'25jan00 AE  Taken from original financpy.bas and modified
'25Sep02 TH  Replaced year date handling for end of year run (#58073)


Dim td As DateAndTime, dt As DateAndTime
Dim sFrom As String, sDestNew As String, sDrv As String
Dim sFile As String, n As Integer, sDestOld As String
Dim sLine As String, sTempFile As String
Dim iMultipleCopies As Integer, iFound As Integer
Dim iTmp As Integer, sMsg As String

   On Error GoTo DoFcErr

   If Not (iMonthend Or iOldMethod) Then Exit Sub                      'Quiet exit if not copying anything


   Screen.MousePointer = HOURGLASS
   ONJLog sp$ & "Starting Financial copy for site " & Right$(dispdata$, 3) & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False

   sDrv = ONJLivePath()

   today td                                                             ' today
   dt.mint = td.mint - 420                                              ' minus 7hrs
   minstodate dt                                                        ' day when last work was done

'Select destination directory
   If iOldMethod Then
	 sDestOld = sDrv & "\Dispdata." & Format$(900 + dt.Mth)                        ' eg,906 for june
	 If Not DirExistsNoMsg(sDestOld, iTmp) Then
	       ONJLog sp$ & sp$ & "Creating Dir: " & sDestOld & "...", iTestRun, iTestRun, False, False
	       MkDir sDestOld
	       ONJLog sp$ & sp$ & "Done.", iTestRun, iTestRun, False, False
	    End If
      End If

   If iMonthend Then
	 'sDestNew = GetMonthendDir() & "\" & Format$(Now, "yyyy") & Format$(dt.Mth, "00") & "." & Right$(dispdata$, 3)   '25Sep02 TH Replaced for end of year run
	 sDestNew = GetMonthendDir() & "\" & Format$(dt.Yrs, "0000") & Format$(dt.Mth, "00") & "." & Right$(dispdata$, 3) '     "
	 If Not DirExistsNoMsg(sDrv & GetMonthendDir(), iTmp) Then
	       ONJLog sp$ & sp$ & "Creating Dir: " & sDrv & GetMonthendDir() & "...", iTestRun, iTestRun, False, False
	       MkDir sDrv & GetMonthendDir()
	       ONJLog sp$ & sp$ & "Done.", iTestRun, iTestRun, False, False
	    End If

	 If Not DirExistsNoMsg(sDrv & sDestNew, iTmp) Then
	       ONJLog sp$ & sp$ & "Creating Dir: " & sDrv & sDestNew & "...", iTestRun, iTestRun, False, False
	       MkDir sDrv & sDestNew
	       ONJLog sp$ & sp$ & "Done.", iTestRun, iTestRun, False, False
	    End If
      End If
   
'If test run, check that the destination directory is accessible
   If iTestRun Then
	 If iOldMethod Then
	       iTmp = GetAttr(sDestOld)
	       If (iTmp And 1) <> 0 Then          '1 = ATTR_READONLY
		     ONJLog sp$ & sp$ & "Warning! Cannot Write to  " & sDestOld, iTestRun, iTestRun, True, False
		  End If
	    End If
	 If iMonthend Then
	       iTmp = GetAttr(sDestNew)
	       If (iTmp And 1) <> 0 Then          '1 = ATTR_READONLY
		     ONJLog sp$ & sp$ & "Warning! Cannot Write to  " & sDestNew, iTestRun, iTestRun, True, False
		  End If
	    End If
      End If

'Find the site doing the financial copy...
   sFrom = dispdata$
   sFile = ""

   sMsg = IFF(iTestRun, " (Test)", "")
   If iOldMethod Then ONJLog sp$ & sp$ & "Copying to " & sDestOld & sMsg, iTestRun, iTestRun, False, False
   If iMonthend Then ONJLog sp$ & sp$ & "Copying to " & sDrv & sDestNew & sMsg, iTestRun, iTestRun, False, False
      
   sFile = Dir$(sFrom & "\*.*")
      Do
	 If sFile <> "" Then
	       ONJinfo "Copying File: " & sFile
		If Not iTestRun Then                    'Do the copy (Test Mode off)
			If iOldMethod Then
			      FileCopy sFrom & "\" & sFile, sDestOld & "\" & sFile
			   End If
			If iMonthend Then
			      FileCopy sFrom & "\" & sFile, sDrv & sDestNew & "\" & sFile
			   End If

		  Else                                 'Copy to Working Dir, then kill to check ok
		     sTempFile = AppPathNoSlash() & ONJWorkingDir & "\" & sFile
		     FileCopy sFrom & "\" & sFile, sTempFile
		     Kill sTempFile
		  End If
DoFCResume:
		  sFile = Dir$
	    End If
      Loop Until sFile = ""

   On Error GoTo 0
   Screen.MousePointer = STDCURSOR
   ONJLog sp$ & "Completed Financial copy for site " & Right$(dispdata$, 3) & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False

Exit Sub

DoFcErr:
'Errors found during copy.
'Write errors to log, attempt to continue so that as much data as possible is copied.

   ONJLog sp$ & sp$ & "ERROR " & Format$(Err) & ":'" & Error$ & "' Occurred whilst trying to copy " & sFile, iTestRun, iTestRun, True, False
   ONJStoreError Right$(dispdata$, 3), "FinancialCopy", True, iTestRun
   Resume DoFCResume

End Sub

Sub DoTestRun ()

'Do a test run of the overnight job

      frmOvernight.LblTitle.Caption = "Job Running"
      ArrangeONJForm 4
      frmOvernight.CmdExit.Visible = False
      frmOvernight.CmdExit.Enabled = False

      GoOvernightJob True, True
      ONJinfo "Setup mode"


End Sub

Sub EnableSetupControls (iMode As Integer)

'Setup up the appropriate options for the chosen setting.
'
'Mode:   0 - Clear TAG properties of the option controls
'        1 - Show ON and OFF buttons
'        2 - Show text box
'        3 - Show ON / Off and Command Button

   Select Case iMode
      Case 0
	 frmOvernight.OptSetupON.Tag = ""
	 frmOvernight.OptSetupOFF.Tag = ""

      Case 1
	 frmOvernight.OptSetupON.Enabled = True
	 frmOvernight.OptSetupON.Visible = True
	 frmOvernight.OptSetupOFF.Enabled = True
	 frmOvernight.OptSetupOFF.Visible = True
	 frmOvernight.TxtSetup.Enabled = False
	 frmOvernight.TxtSetup.Visible = False
	 frmOvernight.CmbSetup.Visible = False
	 frmOvernight.CmbSetup.Enabled = False

      Case 2
	 frmOvernight.OptSetupON.Enabled = False
	 frmOvernight.OptSetupON.Visible = False
	 frmOvernight.OptSetupOFF.Enabled = False
	 frmOvernight.OptSetupOFF.Visible = False
	 frmOvernight.TxtSetup.Enabled = True
	 frmOvernight.TxtSetup.Visible = True
	 frmOvernight.CmbSetup.Visible = False
	 frmOvernight.CmbSetup.Enabled = False



      Case 3
	 frmOvernight.OptSetupON.Enabled = True
	 frmOvernight.OptSetupON.Visible = True
	 frmOvernight.OptSetupOFF.Enabled = True
	 frmOvernight.OptSetupOFF.Visible = True
	 frmOvernight.TxtSetup.Enabled = False
	 frmOvernight.TxtSetup.Visible = False
	 frmOvernight.CmbSetup.Visible = True
	 frmOvernight.CmbSetup.Enabled = True
      '
      '
      'more...
      '
      '
      Case Else
	 frmOvernight.OptSetupON.Enabled = False
	 frmOvernight.OptSetupON.Visible = False
	 frmOvernight.OptSetupOFF.Enabled = False
	 frmOvernight.OptSetupOFF.Visible = False
	 frmOvernight.TxtSetup.Enabled = False
	 frmOvernight.TxtSetup.Visible = False
	 frmOvernight.CmbSetup.Visible = False
	 frmOvernight.CmbSetup.Enabled = False


      End Select
      

End Sub

Sub GetLabelDetails (a As String, b As Integer, c As Long)

'29Aug03 TH/ATW
'STUB

End Sub

Sub GetLivePath ()
   
'Find the actual path to the live drive, since we are running on the server,
'not a mapped network drive

Dim iFailed As Integer, iFound As Integer, sPath As String
Dim n As Integer, sTmp As String
   
   sErrProc = "GetLivePath"
   sErrStage = ""
   On Error GoTo GLPErr

   iFailed = False
   iFound = False
   sPath = App.Path

   Do
      'Take off the final dir in the path
      n = Len(sPath)
      Do
	 If Mid$(sPath, n, 1) = "\" Then
	       sPath = Mid$(sPath, 1, n - 1)
	       iFound = True
	    Else
	       n = n - 1
	    End If
	 If n = 0 Then iFailed = True
      Loop Until iFailed Or iFound

      iFound = False
      If Not iFailed Then
	    sTmp = Dir$(sPath & "\ascroot", ATTR_DIRECTORY)
	    If sTmp <> "" Then iFound = True
	 End If
   Loop Until iFailed Or iFound

   If Not iFailed Then
	 SetONJLivePath sPath
      Else
	 sTmp = "Critical Error; Cannot find \ASCroot on this path (" & App.Path & ")" & cr$
	 sTmp = sTmp & "Please re-install Overnite.exe into a folder below the Live Drive"
	 popmessagecr ".Overnight Job", sTmp
	 Close
	 End
      End If

GLPExit:

Exit Sub

GLPErr:

   ONJErrHandler
   Resume GLPExit

End Sub

Sub GetONJPassword ()

'Dim sFullname As String

Dim iValid As Integer

   askpassword iValid, "", "Overnight Job"
   If iValid Then iValid = Val(Mid$(Acclevels$, 6, 1)) >= 8
   If Not iValid Then
	 popmessagecr ".Overnight Job", "You are not authorised to use this utility."
	 Close
	 End
      End If

   frmOvernight.LblPasswordFlag.Caption = "0"


End Sub

Sub GetOvernightData (success As Integer)

'Read the overnight ini file

Dim iFound As Integer, M As Integer
Dim n As Integer, sBuffer As String, sJob As String
Dim sSite As String

   sErrProc = "GetOvernightData"
   sErrStage = ""
   On Error GoTo GODErr

   FlushIniCache
   success = True

   sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, "Sites", "0", "Number", iFound)
   If sBuffer = "0" Or Not iFound Then
	 success = False
	 Exit Sub
      End If
   
   iNumOfSites = Val(sBuffer)
   ReDim SiteTypes(1 To iNumOfSites)

   'Read the data into the array
   For n = 1 To iNumOfSites
      sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, "Sites", "", Format$(n), iFound)
      SiteTypes(n).Number = Val(sBuffer)
      
      If iFound Then
	    sSite = TxtD$(AppPathNoSlash() & ONJINIFILE$, "Sites", "", Format$(n), iFound)
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "ORDERSIDX", iFound)
	    SiteTypes(n).Wdelord = IFF(sBuffer = "Y", True, False)
	 End If

      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "PATIENTIDX", iFound)
	    SiteTypes(n).Patidx = Val(sBuffer)
	 End If

      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "FINANCPY", iFound)
	    SiteTypes(n).FINANCPY = IFF(sBuffer = "Y", True, False)
	 End If

      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "SINGLECOPY", iFound)
	    SiteTypes(n).SingleCopy = IFF(sBuffer = "Y", True, False)
	 End If

      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "CONTRACTUPD", iFound)
	    SiteTypes(n).StckNght = IFF(sBuffer = "Y", True, False)
	 End If
      
      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "DISPDATA", iFound)
	    SiteTypes(n).Disp = IFF(sBuffer = "Y", True, False)
	 End If
      
      If iFound Then
	    sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, sSite, "", "PATDATA", iFound)
	    SiteTypes(n).Pat = IFF(sBuffer = "Y", True, False)
	 End If

      If Not iFound Then Exit For

   Next

   success = iFound

GODExit:

Exit Sub

GODErr:

   ONJErrHandler
   Resume GODExit

End Sub

Function GetSiteIndex ()


   GetSiteIndex = iSiteINdex

End Function

Sub GoOvernightJob (iTestRun As Integer, iToScreen As Integer)


'Run the overnight job according to the stored parameters
'The semaphore (lock) files from wdelord and Patidx are still used, for compatability with older versions of
'the suite. If an error is encountered during indexing, these files remain on disk.
'If errors did occurr, as well as being logged they are stored in the ini file.  If ascshell finds the new
'overnight job running on the system , it will look here to check that the job ran correctly.
'-----------------------------------------------------------
'
'02Feb00 AE added extra logging.
'           Prevent errors occurring when attempting to remove semaphore files;
'           Only aquirelock on the semaphore files if doing a live run.
'03Feb00 AE  Changed AquireLock to ONJAquireLock to prevent screen messages.
'16Feb00 AE  Added logging of who/what ran the program after someone was 'playing' with
'            the beta at oldham.
'19May00 AE  Cosmetic changes to logging of certain errors.
'23May00 AE  Enhanced to record time as well as date in ini File. Avoids problem when
'            the job is run before midnight, so a the program thinks it's missed a day.


Dim ok As Integer, n As Integer, sMsg As String
Dim k As kbdcontrol, ans$, gDispdata$, gPatdatapath$
Dim iFil As Integer, sFile As String, sSite As String
Dim sLockFile As String, iSingle As Integer, iMultiple As Integer
Dim iValue As Integer, sComm As String

   On Error GoTo GoONJErr
   Screen.MousePointer = HOURGLASS                    '02Feb00 AE
   FlushIniCache           'Since we may be writing, then reading from the ini file.

   'Take a copy of the global dispdata and patdata folder names
   gDispdata$ = dispdata$
   gPatdatapath$ = patdatapath$

   'If test run then clear working file if it exists
   ClearONJFiles
   
   'Clear error entries in the ini file
   For n = 1 To iNumOfSites
	 sSite = Format$(SiteTypes(n).Number, "000")
	 ONJStoreError sSite, "OrdersReIndex", False, iTestRun
	 ONJStoreError sSite, "TidyReprints", False, iTestRun
	 ONJStoreError sSite, "ContractPrices", False, iTestRun
	 ONJStoreError sSite, "FinancialCopy", False, iTestRun
	 ONJStoreError sSite, "PatientReIndex", False, iTestRun
   Next
      
     
   'Log to daily log and master log if a live run
   ONJLog "", iTestRun, iToScreen, False, False
   ONJLog sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$, iTestRun, iToScreen, False, False
   sMsg = "Overnite: "                                                                                '16Feb00 AE
   If InStr(UCase(Command$), "/RUN") Then                                                             '     "
	 sMsg = sMsg & " live run using /RUN"                                                         '     "
      ElseIf InStr(UCase(Command$), "/TEST") Then                                                     '     "
	 sMsg = sMsg & " test run using /TEST"                                                        '     "
      ElseIf InStr(UCase(Command$), "/VIEWMASTER") Then                                               '     "
	 sMsg = sMsg & " run from EMIS Health by " & userid$ & " on site " & Format$(Val(Command$))      '     "
      Else                                                                                            '     "
	 sMsg = sMsg & " run by " & userid$ & " on site " & Format$(Val(Command$))                    '     "
      End If                                                                                          '     "
   ONJLog sMsg, iTestRun, iToScreen, False, False                                                     '     "
   
   ONJLog "STARTING OVERNIGHT JOB at " & tb$ & tb$ & tb$ & Format$(Now, "dd/mm/yyyy hh:mm:ss"), iTestRun, iToScreen, False, False
   ONJLog "", iTestRun, iToScreen, False, False
   ONJinfo ""

   PositionProgress

   If Not iTestRun Then
	 ONJLog "", iTestRun, iToScreen, False, True
	 ONJLog sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$, iTestRun, iToScreen, False, True
	 ONJLog Chr$(127) & Format$(Now, "dd/mm/yyyy hh:mm:ss") & " - STARTING overnight job.", iTestRun, iToScreen, False, True
      End If

'Do the jobs for each site in turn
   For n = 1 To iNumOfSites
      ONJLog "STARTING Jobs for Site " & Format$(SiteTypes(n).Number, "000") & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False

      dispdata$ = IFF(SiteTypes(n).Disp, ONJLivePath() & "\Dispdata." & Format$(SiteTypes(n).Number, "000"), "")
      patdatapath$ = IFF(SiteTypes(n).Pat, ONJLivePath() & "\Patdata." & Format$(SiteTypes(n).Number, "000"), "")

      'Financial copy. Note we may be copying both to Monthed and Dispdata.9xx
      If (SiteTypes(n).FINANCPY Or SiteTypes(n).SingleCopy) And dispdata$ <> "" Then
	    iSingle = SiteTypes(n).SingleCopy
	    iMultiple = SiteTypes(n).FINANCPY
	    DoFinancialCopy iMultiple, iSingle, iTestRun
	 End If

      ONJinfo ""

      'Contract Price Update
      If SiteTypes(n).StckNght And dispdata$ <> "" Then DoContractPrices iTestRun, iToScreen
      ONJinfo ""
      
      'Orders Reindexing
      If SiteTypes(n).Wdelord And dispdata$ <> "" Then
	    ONJLog sp$ & "Starting Tidy / Reindex Order files" & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False
	    ReadOrdData
	    sLockFile = dispdata$ & "\wdelord.lck"
	    CheckLogFiles True, iTestRun
	    If Not iTestRun Then                              '02Feb00 AE  Only leave semaphore if actually indexing
		  ONJAquireLock sLockFile, 2, ok              '03Feb00 AE  Changed to ONJAquirelock
		  If Not ok Then Error 32100                  '      "
	       End If                                         '      "
	    PositionProgress
	    Delord 1, iTestRun
	    PositionProgress
	    Delord 2, iTestRun
	    PositionProgress
	    Delord 3, iTestRun
	    PositionProgress
	    ONJLog sp$ & sp$ & "Tidying Reprint Files..." & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False   '02Feb00 AE  '01Mar00 AE Added "..."
	    TidyStoreReprints iTestRun
	    PositionProgress
	    TidyDispReprints iTestRun
	    ONJLog sp$ & sp$ & "Files Tidied." & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False           '02Jan00 AE
	    ONJLog sp$ & "Finished order-reindex " & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False
	    If Not iTestRun Then                               '02Feb00 AE  Only leave semaphore if actually indexing
		  ONJAquireLock sLockFile, 0, ok               '03Feb00 AE  Changed to ONJAquirelock
		  If Not ok Then Error 32101                   '     "
	       End If                                          '     "
	    'Only remove semaphore if no errors encountered
	    If UCase(TxtD$(AppPathNoSlash() & ONJINIFILE$, Format$(SiteTypes(n).Number, "000"), "OK", "OrdersReIndex", 0)) = "OK" Then   '02Feb00 AE Changed default to "OK"
		  If Fileexists(sLockFile) Then Kill sLockFile '02Feb00 AE  Added fileexists
	       End If
	    ONJinfo ""
	 End If

WdelordAbort:
      'Patient Reindexing
      If SiteTypes(n).Patidx And patdatapath$ <> "" Then
	    sLockFile = ONJLivePath() & "\ascroot" & "\system.lck"
	    ONJAquireLock sLockFile, 2, ok                           '03Feb00 AE  Changed to ONJAquirelock
	    If Not ok Then Error 32100
	    sLockFile = patdatapath$ & "\patidx.lck"
	    If Not iTestRun Then                               '02Feb00 AE  Only leave semaphore if actually indexing
		  ONJAquireLock sLockFile, 2, ok               '03Feb00 AE  Changed to ONJAquirelock
		  If Not ok Then Error 32100                   '     "
	       End If                                          '     "
	    iValue = SiteTypes(n).Patidx
	    sComm = PatidxCommand(iValue)
	    ONJPatientReindex sComm, iTestRun
	    sLockFile = patdatapath$ & "\patidx.lck"
	    If Not iTestRun Then                               '02Feb00 AE  Only leave semaphore if actually indexing
		  ONJAquireLock sLockFile, 0, ok               '03Feb00 AE  Changed to ONJAquirelock
		  If Not ok Then Error 32101                   '     "
	       End If                                          '     "
	    'Only remove semaphore if no errors encountered
	    If UCase(TxtD$(AppPathNoSlash() & ONJINIFILE$, Format$(SiteTypes(n).Number, "000"), "OK", "PatientReIndex", 0)) = "OK" Then    '02Feb00 AE Changed default to "OK"
		  If Fileexists(sLockFile) Then Kill sLockFile '02Feb00 AE  Added Fileexists
	       End If
	    sLockFile = ONJLivePath() & "\ascroot" & "\system.lck"      'However, always release system.lck!
	    ONJAquireLock sLockFile, 0, ok
	    If Not ok Then Error 32101
	 End If

PatIDXAbort:
      ONJinfo ""
      ONJLog "FINISHED Jobs for Site " & Format$(SiteTypes(n).Number, "000") & tb$ & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iToScreen, False, False
      ONJLog "", iTestRun, iToScreen, False, False
      
   Next

   ONJLog "FINISHED OVERNIGHT JOB at " & tb$ & tb$ & tb$ & Format$(Now, "dd/mm/yyyy hh:mm:ss"), iTestRun, iToScreen, False, False
   ONJLog sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$, iTestRun, iToScreen, False, False

   'insert error log
   InsertONJErrorLog iTestRun

   If Not iTestRun Then
	 ONJLog Format$(Now, "dd/mm/yyyy hh:mm:ss") & " - FINISHED overnight job.", iTestRun, iToScreen, False, True
	 ONJLog sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$ & sp$, iTestRun, iToScreen, False, True
	 ONJLog "", iTestRun, iToScreen, False, True
      End If
   
   patdatapath$ = gPatdatapath$
   dispdata$ = gDispdata$
   
   'Store the date of the last live run in the ONJ.ini
   If Not iTestRun Then
	 WritePrivateIniFile "", "LastRan", Format$(Now, "dd/mm/yyyy hh:mm"), AppPathNoSlash() & ONJINIFILE$, ok     '23May00 AE  Enhanced to record time as well as date
      End If

   If iAutoRun Then frmOvernight.Hide
   Screen.MousePointer = STDCURSOR                       '02Feb00 AE

   Exit Sub

GoONJErr:
'Log all errors, then carry on.

   Select Case Err
      Case 32100            'Failed to aquire lock.  In this case abort the action and go to the next
	 sMsg = sp & "WARNING! Failed to get lock on " & sLockFile & ". "                                   '19May00 AE  Added sp
	 If InStr(UCase(sLockFile), "SYSTEM.LCK") <> 0 Or InStr(UCase(sLockFile), "PATIDX.LCK") <> 0 Then
	       sMsg = sMsg & "Patient index aborted!"
	       ONJLog sMsg$, iTestRun, iToScreen, True, False
	       ONJStoreError Format$(SiteTypes(n).Number, "000"), "PatientReIndex", True, iTestRun
	       Resume PatIDXAbort
	    ElseIf InStr(UCase(sLockFile), "WDELORD.LCK") <> 0 Then
	       sMsg = sMsg & "Stores index aborted!"
	       ONJLog sMsg$, iTestRun, iToScreen, True, False
	       ONJStoreError Format$(SiteTypes(n).Number, "000"), "OrdersReIndex", True, iTestRun
	       Resume WdelordAbort
	    End If
	 

      Case 32101              'Failed to release lock.  Safe to carry on, but log the problem
	 sMsg = sp & "WARNING!! Failed to release lock on " & sLockFile & ". "                             '19May00 AE  Added sp
	 ONJLog sMsg$, iTestRun, iToScreen, True, False

      Case Else
	 ONJLog sp$ & sp$ & "Error " & Format$(Err) & ": " & Error$, iTestRun, iToScreen, True, False
      End Select

   Resume Next

End Sub

Sub InsertONJErrorLog (iTestRun As Integer)

'get the error summary from the log, and insert it into the appropriate log
'If a test run, inserts at the end of the temporary log;
'If a live run, inserts into the master log and the current log.


Dim sErrorLog As String, iErrLen As Integer
Dim sDestLog As String
Dim sBuffer As String
Dim iSource As Integer', iDest As Integer

   sErrProc = "InsertONJErrorLog"
   sErrStage = ""
   On Error GoTo IOELErr
   

   sErrorLog = AppPathNoSlash() & ONJWorkingDir$ & "\" & Format$(Now, "dd-mm") & ".tmp"
   
   If Fileexists(sErrorLog) Then
      
	 iSource = FreeFile
	 Open sErrorLog For Input As iSource
      
	 iErrLen = LOF(iSource)
	 sBuffer = Input$(iErrLen, iSource)
      
	 If Trim$(sBuffer) <> "" Then
		If Not iTestRun Then
		     'Insert into master log
		      ONJLog "The following errors occured during this run:", iTestRun, False, False, True
		      ONJLog sBuffer, iTestRun, False, False, True
		      'Insert into Current (Daily) log
		      ONJLog "", iTestRun, False, False, False
		      ONJLog "The following errors occured during this run:", iTestRun, False, False, False
		      ONJLog sBuffer, iTestRun, False, False, False
		      ONJLog "", iTestRun, False, False, False

		  Else
		      ONJLog "", iTestRun, True, False, iTestRun
		      ONJLog "The following errors occured during this run:", iTestRun, True, False, iTestRun
		      ONJLog sBuffer, iTestRun, True, False, iTestRun
		      ONJLog "", iTestRun, True, False, iTestRun
		  End If
	    End If
      
	 Close
      End If

IOELExit:

Exit Sub

IOELErr:

   ONJErrHandler
   Resume IOELExit

End Sub

Function isPBS () As Integer
'29Aug03 TH/ATW
'STUB
End Function

Sub ItemTypeStatus (ByVal a, ByVal b$, ByVal c$, ByVal d$)

'29Aug03 TH/ATW
'STUB

End Sub

Sub JobsSummary ()

'Show all current jobs in a list box, ordered by site.
'Dbl click goes to that job by site
'------------------------------------------------------------
'11Feb00 AE  Refresh Title. Wasn't refreshed if comming from Log View


Dim n As Integer
Dim iSiteHasJobs As Integer
Const sIndent = "----------"
Dim sTmp As String, iValue As Integer

   sErrProc = "JobsSummary"
   On Error GoTo JSErr

   ArrangeONJForm 2
   frmOvernight.LblTitle.Caption = "Summary of All Scheduled Jobs on " & ONJLivePath()    '11Feb00 AE  Ensure title is refreshed
   ONJinfo "Setup mode"
   frmOvernight.HscSummary.Value = 0

   For n = 1 To iNumOfSites
      
      sErrStage = "n = " & Format$(n)

      iSiteHasJobs = False
      frmOvernight.LstSummary.AddItem "Site: " & Format$(SiteTypes(n).Number, "000")
      frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
      If SiteTypes(n).Wdelord Then
	    frmOvernight.LstSummary.AddItem sIndent & "Tidy & Reindex Orders"
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	    iSiteHasJobs = True
	 End If
      
      
      iValue = SiteTypes(n).Patidx
      If iValue <> 0 Then
	    If iValue = 1 Then
		  sTmp = "Tidy Patient Indexes"
	       Else
		  sTmp = "Tidy All Patient Idx, & rebuild "
	       End If
	    If iValue And PI_CASENO Then sTmp = sTmp & " " & "CaseNo,"
	    If iValue And PI_SNFN Then sTmp = sTmp & " " & "SnFn,"
	    If iValue And PI_FNSN Then sTmp = sTmp & " " & "FnSn,"
	    If iValue And PI_WDCON Then sTmp = sTmp & " " & "WdCon,"
	    If iValue And PI_RECNO Then sTmp = sTmp & " " & "RecNo,"
	    If iValue And PI_GP Then sTmp = sTmp & " " & "Gp,"
	    If iValue And PI_RX Then sTmp = sTmp & " " & "RxNo,"
	    If iValue And PI_SOUND Then sTmp = sTmp & " " & "SnSnd,"
	    If iValue And PI_FNSND Then sTmp = sTmp & " " & "FnSnd,"
	    If iValue > 1 Then sTmp = sTmp & " indexes."

	    frmOvernight.LstSummary.AddItem sIndent & sTmp
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	    iSiteHasJobs = True
	 End If

      If SiteTypes(n).FINANCPY Then
	    frmOvernight.LstSummary.AddItem sIndent & "Financial copy to " & GetMonthendDir()
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	    iSiteHasJobs = True
	 End If

      If SiteTypes(n).SingleCopy Then
	    frmOvernight.LstSummary.AddItem sIndent & "Financial copy to \Dispdata.9**"
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	    iSiteHasJobs = True
	 End If

      If SiteTypes(n).StckNght Then
	    frmOvernight.LstSummary.AddItem sIndent & "Update Contract Prices"
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	    iSiteHasJobs = True
	 End If

      If Not iSiteHasJobs Then
	    frmOvernight.LstSummary.AddItem sIndent & "No Jobs Scheduled"
	    frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = n
	 End If

      frmOvernight.LstSummary.AddItem ""

   Next

   frmOvernight.LstSummary.Tag = "JOBS"

JSExit:

Exit Sub

JSErr:

   ONJErrHandler
   Resume JSExit

End Sub

Sub ONJAquireLock (pathfile$, LockType As Integer, done As Integer)

'Code ported from AquireLock, this version is identical except nothing
'is sent to screen and only 0,1,2 are acceptable locktypes.
'Tries once only to release / aquire lock, returns true or false as appropriate.

' PathFile: Full pathname of file to lock, filename also used as message.
' Locktype: 0 Release, 1 Acquire shared, 2 Acquire exclusive lock
' Returns:  Done T/F where False is because we failed to get / release the lock
'-----------------------------------------------------------------
'03Feb00 AE  Written.  Code taken from AquireLock, and parts pertaining to screen prompting
'            removed.

Dim k1 As kbdcontrol
Dim msg$, Msg2$, Count%, LockChan%, ans$
Static NumLocks%, Locks$(), Lockdata%()

   If LockType = 100 Then
	 msg$ = ""
	 For Count = 1 To NumLocks
	    msg$ = msg$ & "      " & Format$(Lockdata(2, Count)) & tb
	    Select Case Lockdata(1, Count)
	       Case 0: msg$ = msg$ & "Released"
	       Case 1: msg$ = msg$ & "Shared"
	       Case 2: msg$ = msg$ & "Exclusive"
	       End Select
	    msg$ = msg$ & tb & Locks$(Count)
	 Next
	 pathfile$ = msg$
	 done = True
	 Exit Sub
      End If

   If done = 1 Then done = True: Exit Sub      '03Feb00 AE I can't see what this is supposed to do
   
   done = True
   msg$ = pathfile$
   Msg2$ = T1("IsLckd")     '!" is locked by another user"
   pathfile$ = UCase$(pathfile$)
   LockType = Abs(LockType)
   
   For Count = 1 To NumLocks
      If Locks$(Count) = pathfile$ Then
	    If Lockdata(1, Count) = LockType Then Exit Sub
	    If Lockdata(1, Count) <> 0 Then  '10Apr95 CKJ Added
		  Close Lockdata(2, Count)
		  TrackOpenedFiles Lockdata(2, Count), "", ""          '24Aug99 CKJ
		  Lockdata(1, Count) = 0   ' released
		  Lockdata(2, Count) = 0   ' chan = 0 " "
	       End If
	    Exit For
	 End If
   Next
   If NumLocks < Count Then
	 NumLocks = Count            ' same No as before or NumLocks + 1
	 ReDim Preserve Locks$(NumLocks)
	 ReDim Preserve Lockdata(1 To 2, NumLocks)
      End If
   Locks$(Count) = pathfile$
   Lockdata(1, Count) = LockType
   If LockType = 0 Then Exit Sub     ' no further action on releasing a lock
   
   On Error GoTo ONJAcquireLock_Err

   done = True
   LockChan = FreeFile

   If LockType = 1 Then ' shared lock
	 Open pathfile$ For Binary Access Read Lock Write As #LockChan Len = (1)
      Else              ' exclusive lock
	 Open pathfile$ For Binary Access Read Write Lock Read Write As #LockChan Len = (1)
      End If

   If done Then
	 Lockdata(2, Count) = LockChan
	 TrackOpenedFiles LockChan, pathfile$, "AcquireLock " & IFF(LockType = 1, "Shared", "Exclusive")          '24Aug99 CKJ
      Else
	 Lockdata(1, Count) = 0
      End If
   
   On Error GoTo 0

Exit Sub

ONJAcquireLock_Err:
   done = False
Resume Next

End Sub

Sub ONJErrHandler ()

Dim sTmp As String
'To handle any unforseen errors in the program.

   sTmp = "The following error has occurred in " & App.EXEName & cr$
   sTmp = sTmp & "Error " & Format$(Err) & ":'" & Error$ & "'" & cr$ & cr$
   If sErrProc <> "" Then sTmp = sTmp & "Procedure Name: " & sErrProc & cr$
   If sErrStage <> "" Then sTmp = sTmp & "Stage: " & sErrStage & cr$ & cr$
   sTmp = sTmp & "Please consult your System Supervisor." & cr$ & cr$

   popmessagecr ".Overnight Job", sTmp


End Sub

Sub ONJinfo (sText As String)

'Write text to frmOvernight.LblInfo. Separate proc for clarity and to allow more
'flexibility if required.

   sErrProc = "ONJInfo"
   sErrStage = ""
   On Error GoTo OIErr

   If frmOvernight.Lblinfo.Visible Then
	 frmOvernight.Lblinfo.Caption = sText
	 frmOvernight.Lblinfo.Refresh
      End If

OIExit:

Exit Sub

OIErr:

   ONJErrHandler
   Resume OIExit

End Sub

Sub ONJLog (sText As String, iTestRun As Integer, iToScreen As Integer, iErr As Integer, iMaster As Integer)

'Write to the Overnight Log if running screenless, or to screen if doing a test run.

'sText    = To be written to the log
'iTestRun = Is this a live run (write to main log) or a test (write to temp log)
'ToScreen = To right to screen or not ?  Needed as this routine is used by InsertONJError log
'iErr     = Is this an error message ? If so, also write to the error log which acts as a summary of errors
'iMaster  <>0: Write to master log , 0: Write to ordinary, daily log

'All log entries are expanded to a fixed length of 128 bytes, or to the next multiple thereof.

'25Feb02 TH Replaced close in error trap as this closes all currently opened channels including patchan which
'    "      may yet be needed - instead close the relevant chan if appropriate (#57794)


Dim iFil As Integer
Dim sFile As String
Dim sBuffer As String
Dim iLength As Integer

   On Error GoTo ONJLogErr

   If Len(sText) <= ONJRecLen Then           'Expand to the record length if text is shorter
	 sText = sText & Space$(ONJRecLen - Len(sText))
      End If

   If iTestRun Then
	 sFile = AppPathNoSlash() & ONJWorkingDir$ & ONJTempLog
      Else
	 If iMaster Then
	       sFile = AppPathNoSlash() & ONJLogDir$ & ONJLogFile
	    Else
	       sFile = AppPathNoSlash() & ONJLogDir$ & "\" & Format$(Now, "yyyymmdd") & ".log"
	    End If
      End If

   iFil = FreeFile
   Open sFile For Append As iFil
   Print #iFil, sText
   Close iFil

   'Write errors to a temp file which is inserted into the main log as a summary of all errors this run
   If iErr Then
	 iFil = FreeFile
	 sFile = AppPathNoSlash() & ONJWorkingDir$ & "\" & Format$(Now, "dd-mm") & ".tmp"
	 Open sFile For Append As iFil
	 Print #iFil, sText
	 Close iFil
      End If
	 
   If iTestRun Then ViewONJLog 2, sFile

ONJLogExit:
   
   Exit Sub

ONJLogErr:

   'Close                 '21Feb02 TH Replaced as this closes all currently opened channels
			  '    "      including patchan which may yet be needed  - instead
   On Error Resume Next   '    "      close the relevant chan if appropriate (#57794)
   Close iFil             '    "
   On Error GoTo 0        '    "

   Resume ONJLogExit

End Sub

Sub ONJPatientReindex (sComstr As String, iTestRun As Integer)

'Original patidx routine from patidx.bas.
'Slightly modified to use new Logging etc.  Also pass in sCOmmstr instead of looking to
'Command$ for the parameters.  This retains all the previous functionality, with miniumum
'change.

'16Nov98 CKJ Added soundalike name match
'27Jan99 EAC Added logging to central logfile
'01Feb00 AE  Ported from PatientReindex.
'            Changed logging from PatidxLog to ONJLog.  Also added block
'            To allow new parameter "/tidyall". Code is otherwise unchanged.
					       
Dim debugging%, s$, individual%, OKtodoFull%
Dim do1%, do2%, do3%, do4%, do5%, do6%, do7%, do8%, do9%
Dim idxchan1%, idxchan2%, idxchan3%, idxchan4%, idxchan5%, idxchan6%, idxchan8%, idxchan9%
Dim pointer&, entries$, recno&, recnum$, Surname$, Forename$, ward$, cons$
Dim locPID As PatIDType
Dim sDesc As String                                            '01Feb00 AE Added
Dim sCaption As String, sIndex As String, sFile As String      '     "

   setinput 0, k
   k.helpfile = ""

   debugging = False
    
'01Feb00 AE  removed help screen, but kept for reference:

   '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
   '                                             '
   '   WARNING!!  NO LOCKING OF INDICES YET !!   '
   '   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   '
   '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

   'sComStr = UCase$(Command$ & " ")

'   If InStr(sComStr, "/?") > 0 Or InStr(sComStr, "/H") > 0 Then
'         s$ = "PATIDX <site>            " & TB & "fast re-index of all indexes" & cr & cr
'         s$ = s$ & "PATIDX <site> /FULL" & TB & "complete rebuild of all indexes (except RX.IDX)" & cr
'         s$ = s$ & "PATIDX <site> /<n> [/<n>]" & TB & "where <n> is as follows;" & cr
'         s$ = s$ & "   /1   for PATID.IDX" & TB & "case number" & cr
'         s$ = s$ & "   /2   for PATSNFN.IDX" & TB & "surname, forename" & cr
'         s$ = s$ & "   /3   for PATFNSN.IDX" & TB & "forename, surname" & cr
'         s$ = s$ & "   /4   for PATWDCON.IDX" & TB & "ward, status, consultant" & cr
'         s$ = s$ & "   /5   for PATRECNO.IDX" & TB & "internal record number" & cr
'         s$ = s$ & "   /6   for PATGP.IDX" & TB & "GP" & cr
'         s$ = s$ & "   /7   for RX.IDX" & TB & "prescription number" & cr
'         s$ = s$ & "   /8   for PATSOUND.IDX" & TB & "surname soundalike" & cr
'         s$ = s$ & "   /9   for PATFNSND.IDX" & TB & "initial, surname soundalike" & cr
'         s$ = s$ & "PATIDX <site> /FULL /DEBUG" & TB & "reindex with debug (for ASC use only)" & cr & cr
'         s$ = s$ & "PATIDX <site> /? " & TB & "display this help page" & cr
'         s$ = s$ & "PATIDX <site> /H " & TB & "display this help page" & cr
'         s$ = s$ & cr
'         s$ = s$ & "Replace <site> with the appropriate site number, for example;" & cr
'         s$ = s$ & "PATIDX 9            " & TB & "site 9, fast re-index" & cr
'         s$ = s$ & "PATIDX 9 /FULL      " & TB & "site 9, full re-build of all indexes" & cr
'         s$ = s$ & "PATIDX 9 /2 /3      " & TB & "site 9, fast re-index of name indexes" & cr
'         s$ = s$ & "PATIDX 9 /FULL /2 /3" & TB & "site 9, full re-build of name indexes" & cr
'         s$ = s$ & "PATIDX 9 /7         " & TB & "site 9, fast re-index of Rx Archive index only" & cr
'         s$ = s$ & "PATIDX 9 /FULL /7" & TB & "same as above, /FULL is ignored for RX.IDX alone"
'         's$ = s$ & "Re-indexing can be interrupted whilst in progress - contact the ASC help line."
'         popmessagecr "Re-Index Patient Database", s$
'
'     Else                  ' *** Do the re-index ***
	 
   ONJLog sp$ & "Starting Patient Re-Index " & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False
   
   Screen.MousePointer = HOURGLASS

   If Not iTestRun Then                                                            '<==Start of live run
	 do1 = False
	 do2 = False
	 do3 = False
	 do4 = False
	 do5 = False
	 do6 = False
	 do7 = False
	 do8 = False
	 do9 = False
	 individual = False
	 OKtodoFull = False
	 If InStr(sComstr, "/1") Then do1 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/2") Then do2 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/3") Then do3 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/4") Then do4 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/5") Then do5 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/6") Then do6 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/7") Then do7 = True: individual = True
	 If InStr(sComstr, "/8") Then do8 = True: individual = True: OKtodoFull = True
	 If InStr(sComstr, "/9") Then do9 = True: individual = True: OKtodoFull = True
	 If Not individual Then
	       OKtodoFull = True
	       do1 = True
	       do2 = True
	       do3 = True
	       do4 = True
	       do5 = True
	       do6 = True
	       do7 = True
	       do8 = True
	       do9 = True
	    End If
	 
	 ' check whether to sort existing indices, or to start from scratch
	 If InStr(sComstr, "/FULL") > 0 And OKtodoFull Then
	       PatientFileSize pointer&, 0       ' get NOP
	       ONJinfo " Scanning Patient File for" & Str$(pointer& - 1) & " records"   ' (1st record contains the pointers)
	       entries$ = Right$(String$(6, "0") & LTrim$(Str$(pointer& - 1)), 6)
      
	       'open files & write new pointers
	       If do1 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patid.idx"                         '27Jan99 EAC Added
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patid.idx", iTestRun, iTestRun, False, False
		     idxchan1% = FreeFile
		     Open patdatapath$ & "\patid.idx" For Output Lock Read Write As #idxchan1
		     Print #idxchan1, "10" & Space$(8) & entries$ & cr$;       ' 10 long
		     Print #idxchan1, Space$(10) & "000000" & cr$;             ' 10 long
		  End If
      
	       If do2 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patsnfn.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patsnfn.idx", iTestRun, iTestRun, False, False
		     idxchan2% = FreeFile
		     Open patdatapath$ & "\patsnfn.idx" For Output Lock Read Write As #idxchan2
		     Print #idxchan2, "21" & Space$(19) & entries$ & cr$;      ' 21 long
		     Print #idxchan2, Space$(21) & "000000" & cr$;             ' 21 long
		  End If
      
	       If do3 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patfnsn.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patfnsn.idx", iTestRun, iTestRun, False, False
		     idxchan3% = FreeFile
		     Open patdatapath$ & "\patfnsn.idx" For Output Lock Read Write As #idxchan3
		     Print #idxchan3, "21" & Space$(19) & entries$ & cr$;      ' 21 long
		     Print #idxchan3, Space$(21) & "000000" & cr$;             ' 21 long
		  End If
      
	       If do4 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patwdcon.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patwdcon.idx", iTestRun, iTestRun, False, False
		     idxchan4% = FreeFile
		     Open patdatapath$ & "\patwdcon.idx" For Output Lock Read Write As #idxchan4
		     Print #idxchan4, "9" & Space$(8) & entries$ & cr$;        '  9 long
		     Print #idxchan4, Space$(9) & "000000" & cr$;              '  9 long
		  End If
      
	       If do5 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patrecno.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patrecno.idx", iTestRun, iTestRun, False, False
		     idxchan5% = FreeFile
		     Open patdatapath$ & "\patrecno.idx" For Output Lock Read Write As #idxchan5
		     Print #idxchan5, "10" & Space$(8) & entries$ & cr$;       ' 10 long
		     Print #idxchan5, Space$(10) & "000000" & cr$;             ' 10 long
		  End If
      
	       If do6 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patid.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patid.idx", iTestRun, iTestRun, False, False
		     idxchan6% = FreeFile
		     Open patdatapath$ & "\patgp.idx" For Output Lock Read Write As #idxchan6
		     Print #idxchan6, "4" & Space$(3) & entries$ & cr$;        '  4 long
		     Print #idxchan6, Space$(4) & "000000" & cr$;              '  4 long
		  End If
      
	       'do7 is handled elsewhere
      
	       If do8 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patsound.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patsound.idx", iTestRun, iTestRun, False, False
		     idxchan8 = FreeFile
		     Open patdatapath$ & "\patsound.idx" For Output Lock Read Write As #idxchan8
		     Print #idxchan8, "10" & Space$(8) & entries$ & cr$;       '  10 long
		     Print #idxchan8, Space$(10) & "000000" & cr$;             '  10 long
		  End If
      
	       If do9 Then
		     ONJinfo "Creating index: " & patdatapath$ & "\patfnsnd.idx"
		     ONJLog sp$ & sp$ & "Creating index: " & patdatapath$ & "\patfnsnd.idx", iTestRun, iTestRun, False, False
		     idxchan9 = FreeFile
		     Open patdatapath$ & "\patfnsnd.idx" For Output Lock Read Write As #idxchan9
		     Print #idxchan9, "10" & Space$(8) & entries$ & cr$;       '  10 long
		     Print #idxchan9, Space$(10) & "000000" & cr$;             '  10 long
		  End If
      
	       For recno& = 2 To pointer&
		  GetPatidNL recno&, locPID                '<== NO LOCKING 11Aug91 CKJ
      
		  recnum$ = Right$(String$(6, "0") & LTrim$(Str$(recno&)), 6)
      
		  If do1 Then
			If LTrim$(locPID.caseno) = "" Then
			      Print #idxchan1, UCase$(Left$(LTrim$(locPID.caseno) & Space$(10), 10)) & recnum$ & lf$;
			   Else
			      Print #idxchan1, UCase$(Left$(LTrim$(locPID.caseno) & Space$(10), 10)) & recnum$ & cr$;
			   End If
		     End If
      
		  If do2 Or do3 Then
			' strip out punctuation ... keep only letters/numbers
			Parsename 1, locPID.Surname, Surname$             '18Apr92 CKJ Added
			Parsename 1, Left$(locPID.Forename, 1), Forename$
		     End If
      
		  If LTrim$(Surname$ & Forename$) = "" Then
			If do2 Then Print #idxchan2, Surname$ & Forename$ & recnum$ & lf$;       '21 long
			If do3 Then Print #idxchan3, Forename$ & Surname$ & recnum$ & lf$;       '21 long
		     Else
			If do2 Then Print #idxchan2, Surname$ & Forename$ & recnum$ & cr$;       '21 long
			If do3 Then Print #idxchan3, Forename$ & Surname$ & recnum$ & cr$;       '21 long
		     End If
      
		  If do4 Then
			ward$ = UCase$(locPID.ward)
			cons$ = UCase$(locPID.cons)
			If LTrim$(ward$ & locPID.status & cons$) = "" Or UCase$(locPID.status) = "D" Or UCase$(locPID.status) = "S" Then
			      Print #idxchan4, ward$ & locPID.status & cons$ & recnum$ & lf$; ' 9 long
			   Else
			      Print #idxchan4, ward$ & locPID.status & cons$ & recnum$ & cr$; ' 9 long
			   End If
		     End If
      
		  If do5 Then
			If LTrim$(locPID.recno) = "" Then
			      Print #idxchan5, UCase$(Left$(LTrim$(locPID.recno) & Space$(10), 10)) & recnum$ & lf$;
			   Else
			      Print #idxchan5, UCase$(Left$(LTrim$(locPID.recno) & Space$(10), 10)) & recnum$ & cr$;
			   End If
		     End If
      
		  If do6 Then
			If LTrim$(locPID.GP) = "" Then
			      Print #idxchan6, UCase$(Left$(LTrim$(locPID.GP) & Space$(4), 4)) & recnum$ & lf$;
			   Else
			      Print #idxchan6, UCase$(Left$(LTrim$(locPID.GP) & Space$(4), 4)) & recnum$ & cr$;
			   End If
		     End If
      
		  If do8 Then
			Parsename 2, locPID.Surname, Surname$             'Soundalike matching
			If Surname$ = "" Then
			      Print #idxchan8, Space$(10) & recnum$ & lf$;
			   Else
			      Print #idxchan8, pad$(Surname$, 10) & recnum$ & cr$;
			   End If
		     End If
      
		  If do9 Then
			Parsename 2, locPID.Surname, Surname$             'Soundalike matching
			Parsename 1, Left$(locPID.Forename, 1), Forename$
			If Surname$ = "" Then
			      Print #idxchan9, Space$(10) & recnum$ & lf$;
			   Else
			      Print #idxchan9, Forename$ & pad$(Surname$, 9) & recnum$ & cr$;
			   End If
		     End If
      
	       Next recno&
      
	       If idxchan1 Then Close idxchan1
	       If idxchan2 Then Close idxchan2
	       If idxchan3 Then Close idxchan3
	       If idxchan4 Then Close idxchan4
	       If idxchan5 Then Close idxchan5
	       If idxchan6 Then Close idxchan6
	       If idxchan8 Then Close idxchan8
	       If idxchan9 Then Close idxchan9
      
	    End If
      
	 'Now sort the chosen indexes                           '01Feb00 AE  Added block
	 If InStr(UCase(sComstr), "/TIDYALL") Then              'Allows the tidying of all indexes,
	       do1 = True                                       'and the full rebuilding of selected
	       do2 = True                                       'indexes.
	       do3 = True                                       '       "
	       do4 = True                                       '       "
	       do5 = True                                       '       "
	       do6 = True                                       '       "
	       do7 = True                                       '       "
	       do8 = True                                       '       "
	       do9 = True                                       '       "
	    End If                                              '       "

	 If do1 Then
	       sIndex = "\patid.idx"
	       sDesc = "Case Number index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do2 Then
	       sIndex = "\patsnfn.idx"
	       sDesc = "Surname/Initial index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do3 Then
	       sIndex = "\patfnsn.idx"
	       sDesc = "Initial/Surname index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do4 Then
	       sIndex = "\patwdcon.idx"
	       sDesc = "Ward/Consultant index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do5 Then
	       sIndex = "\patrecno.idx"
	       sDesc = "Record Number index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do6 Then
	       sIndex = "\patgp.idx"
	       sDesc = "GP/Practice index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do7 Then
	       sIndex = "\rx.idx"
	       sDesc = "Rx Archive index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do8 Then
	       sIndex = "\patsound.idx"
	       sDesc = "Soundalike index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	 If do9 Then
	       sIndex = "\patfnsnd.idx"
	       sDesc = "Soundalike index"
	       ONJSortPatIdx sIndex, sDesc, iTestRun
	    End If
	  
	 PositionProgress
	 ONJinfo "Finished Indexing"
 
	 Screen.MousePointer = STDCURSOR                                      '<===== End of Live ReIndex

   Else                                                                       '<===== Start of Test Run
	 sFile = patdatapath$ & "\patid.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patsnfn.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patfnsn.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patwdcon.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patrecno.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patgp.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\rx.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patsound.idx"
	 GoSub PITestRun
	 sFile = patdatapath$ & "\patfnsnd.idx"
	 GoSub PITestRun

   End If                                                                     '<===== End of Test Run

   ONJLog sp$ & "Finished Patient Re-index " & tb$ & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), iTestRun, iTestRun, False, False

PIExit:

Exit Sub

PITestRun:
'Just check that all the indexes are accessible.

      ONJinfo "Searching for Index:   " & sFile

      If Fileexists(sFile) Then
	    ONJLog sp$ & sp$ & "Found Index " & sFile, iTestRun, iTestRun, False, False
	    ONJinfo "Found Index:   " & sFile
	 Else
	    ONJLog sp$ & sp$ & "WARNING! Index " & sFile & " missing!", iTestRun, iTestRun, True, False
	    ONJinfo "Missing Index: " & sFile
	 End If

Return

'--------------------------------------
PIErr:
'Log errors, do not try to tidy other indexes.  This is to ensure that all indexes are
'in a useable state, or the index must be run again.

   ONJLog sp$ & sp$ & "Error " & Format$(Err) & ":'" & Error$ & "' occured during patient Re-index", iTestRun, iTestRun, True, False
   ONJLog sp$ & sp$ & "Patient Re-index Failed.", iTestRun, iTestRun, True, False
   ONJStoreError Right$(dispdata$, 3), "PatientReIndex", True, iTestRun
   Resume PIExit
   

End Sub

Sub ONJReadSiteInfo (sCommand As String)

'10Feb00 AE  code ported from readsiteinfo with a few modifications.
'            Retain checking for encrypted hospname, etc. Does not
'            set variables which are irrelevant to the overnight job.
'            Uses ONJLivePath instead of relying on a drive mapping, as
'            these are not re-established by the AT command
'16Feb00 AE  Changed default for ASC1 to ""

Dim comfile$, cplace%, mplace%, alllines$, chan%, numoflines%, sitepaths%
Dim raw$, ans$, z1%, z2%, siteext$, success%
Dim patdataEXT$, dispdataEXT$, stockdataEXT$, chksum%, tmp$
Dim ProgsDrv$          '24May99 CKJ Now local instread of global

Dim iFound As Integer

   ReDim linex$(5)     '16Oct97 CKJ was static

   cr$ = Chr$(13)
   lf$ = Chr$(10)      '10Mar97 CKJ Added
   crlf$ = cr & lf
   tb$ = Chr$(9)
  'nul is also available globally, and does not need setting here. It defaults to chr$(0).

   ChDrive Left$(ONJLivePath(), 2)                          '10Feb00 AE
   ChDir ONJLivePath() & "\"                                'Probably not needed
   ProgsDrv = ONJLivePath() & "\"                           '     "
   
   'If sitepaths% = 0 Then sitepaths% = Val(sCommand)
   sitepaths% = Val(sCommand)
   'raw$ = siteinfo$("asc", "ª")                             '10Feb00 AE  Replaced with below
   raw$ = TxtD$(ONJLivePath() & "\dispdata." & Format$(sitepaths, "000") & "\siteinfo.ini", "", "ª", "asc", iFound)
   If raw$ = "ª" Or sitepaths% = 0 Then                      '   "
	 MsgBox "No site selected!" & cr & cr & UCase$(sCommand), 16, "EMIS Health"    '28Oct97 CKJ Replaced popmessagecr as this is prior to opening .044 file
	 Close
	 End
      Else
'         raw$ = raw$ & siteinfo$("asc1", "")                '10Feb00 AE Replaced with below
	 raw$ = raw$ & TxtD$(ONJLivePath() & "\dispdata." & Format$(sitepaths, "000") & "\siteinfo.ini", "", "", "asc1", iFound)   '16Feb00 AE  Changed default to ""
	 ans$ = raw$
	 decodehex ans$
	 deflines ans$, linex$(), "|", 0, numoflines%
	 z1% = 0
	 antihack Mid$(ans$, InStr(ans$, "|") + 1), z1%
	 z2% = 0
	 antihack Mid$(raw$, 4 * Len(linex$(0)) + 5), z2%
	 If (linex$(0) <> Str$(z1%) & Str$(z2%)) Then    '28Oct97 CKJ Was a call to 'hacked'
	       MsgBox "It would appear that this program has been tampered with ..." & cr & "Please contact EMIS Health Hospital Pharmacy for a replacement program." & cr, 16, "EMIS Health"
	       Close
	       End
	    End If
	 ans$ = ""
	 raw$ = ""
      End If
   hospabbr$ = linex$(1)
   hospname1$ = linex$(2)
   hospname2$ = linex$(3)
   singleuseronly% = Val(linex$(4))
   
   'progsDRV$ = siteinfo$("programsDRV", "")              '19Jan95 CKJ default '26Dec98 ASC
   'tpnprogspath$ = ProgsDrv$ & "\tpnprogs"               '05apr04 CKJ {SP1}
   'kinprogspath$ = ProgsDrv$ & "\kinprogs"               '   "
   'dispprogs$ = ProgsDrv$ & "\dispasc"                   '   "
   'pharmpath$ = ProgsDrv$ & "\pharm"                     '   "
   rootpath$ = ProgsDrv$ & "\ascroot"
   'stockprogs$ = ProgsDrv$ & "\stockl"                   '   "
   orderpath$ = ProgsDrv$ & "\orders"
   'catno$ = "ean13"                                      '   "
   
   siteext$ = Right$("00" & LTrim$(Str$(sitepaths%)), 3)
   If singleuseronly% Then siteext$ = "001"  '19Jan95 CKJ *REMOVED*
					     '23Jan95 CKJ *REPLACED*

   passfile$ = dispdata$ & "\startup.asc"
   lpt$ = "lpt1"      '14Mar96 CKJ was lpt1: - can't copy under Windows to this device
   lpt2$ = "lpt2"     '14Mar96 CKJ was lpt2:     "

   transpath$ = ONJLivePath() & "\translog"               'Add Livepath to the paths we'll need
   orderlogpath$ = ONJLivePath() & "\orderlog"
   rootpath$ = ONJLivePath() & "\ASCroot"
   dispdata$ = ONJLivePath() & "\Dispdata." & Format$(sitepaths, "000")

   antihack hospname1$ & hospname2$ & hospabbr$, chksum%       ' now for compatibility only

   sitenumber% = sitepaths%

   'Flx 0, "", 0
'   TerminalName$ = TxtD$("C:\ASCTERM.INI", "", "Unknown", "TerminalName", 0)  '10Feb00 AE  Removed

   SetupPRNheap True, 0     '16Jan98 CKJ Added to allocate gPRNheapID

End Sub

Sub ONJSortPatIdx (sIndex As String, sDesc As String, iTestRun As Integer)

'Small routine to check that indexes exist before attempting to sort them.
'This is to prevent the popmessage which would otherwise be written to screen.

   sErrProc = "ONJSortPatIDx"
   sErrStage = "sIndex = " & sIndex
   
   
   If Fileexists(patdatapath$ & sIndex) Then
	 PositionProgress
	 ONJinfo "Sorting Index: " & sIndex
	 ONJLog sp$ & sp$ & "Sorting Index : " & sIndex, iTestRun, iTestRun, False, False
	 sortindex sDesc, patdatapath$ & sIndex
      Else
	 ONJLog sp$ & sp$ & "WARNING! Index " & sIndex & " missing!", False, False, True, False
	 ONJinfo "Missing Index: " & sIndex
      End If
		  

End Sub

Sub ONJStoreError (sSite As String, sEntry As String, iErr As Integer, iTestRun As Integer)

'Write an entry to the overnight.ini file.  These are then looked at by the ascshell
'when it loads, to inform the user if the overnight job ran into problems.
'Effectively a replacement for the wdelord.lck and patidx.lck files, although these
'are still used but this program is unlikely to fail in such a way as to leave these behind.

'sSite:    Site number under which to write this error
'sEntry:   Entry to write to the ini file.  All are stored under the site number
'iErr:     False sets the entry to "OFF", True sets the entry to indicate that there was an error.

'Note that errors are only stored if we're doing a live run.
'---------------------------------------------------------------------
'03Feb00 AE  Changed to use new procedure ONJWriteini


Dim iSuccess As Integer


   If Not iTestRun Then
	 'WritePrivateIniFile sSite, sEntry, Iff(iErr, "ERROR", "OK"), AppPathNoSlash() & ONJINIFILE, iSuccess
	 ONJwriteIni sSite, sEntry, IFF(iErr, "ERROR", "OK"), iSuccess                      '03Feb00 AE replaced above
      End If


End Sub

Sub ONJwriteIni (sSite As String, sEntry As String, sValue As String, iSuccess As Integer)

'Write an entry to the Overnight job ini file.

   WritePrivateIniFile sSite, sEntry, sValue, AppPathNoSlash() & ONJINIFILE, iSuccess


End Sub

Sub OverNight (iSetupMode As Integer)

'Master Control Routine for overnight job
'iSetupMode: 1-  First ever run of the program
'            2-  Enter Setup mode
'            0-  Run automatically, no user input.
'
'--------------------------------------------------------
'01Mar00 AE  Moved some code form frmONJSplash_Load. Now only asks for the pasword after
'            the live drive has been chosen.


Dim iFil As Integer, sFrmFlag As String, n As Integer
Dim iFound As Integer, iDone As Integer, sBuffer As String
Dim sTmp As String, iButton As Integer
Dim sIniFile As String
Dim sPath As String, sDummy As String, sMsg As String, sCommand As String           '01Mar00 AE Added
   
   sErrProc = "OverNight"
   sErrStage = ""

   On Error GoTo OvernightErr
   
'01Mar00 AE Moved block from frmONJSplash_Load. Now allows you to choose the live path before
'attempting to find the password file! -> not an issue on NT sites, mod is to allow use on
'Novell.
   'If first Ever Run, offer to change live path before the ini file is created etc.
   'Have to use MsgBox as MessageBox tries to read the data files and we don't know where
   'they are yet.
   If iSetupMode = 1 Then
	 sIniFile = AppPathNoSlash() & ONJINIFILE
	 sBuffer = ReadPrivateIniFile(sIniFile, "", "NonStandardLivePath")
	 If sBuffer = "" Then
	       sTmp = "This program has detected the following Live "
	       sTmp = sTmp & "Drive: " & ONJLivePath() & "  "
	       sTmp = sTmp & "(This will be appropriate for most installations.)  "
	       sTmp = sTmp & "However, if the data folders (Dispdata and Patdata) "
	       sTmp = sTmp & "are on a different drive to this program, choose ""NO"""
	       sTmp = sTmp & " to select the correct drive.  "
	       sTmp = sTmp & "Is this the correct drive ?"
	       iButton = MsgBox(sTmp, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, "Overnight Job Setup")
	       If iButton = IDNO Then
		     BrowseDriveList True
		  End If
	    End If
	 End If
   
   
'Check that data on the live drive is accessible; otherwise, Readsiteinfo goes into
'an infinite loop as it trys to read DQQW for the text to put on the error box, which
'leads to another error, etc, etc.
   On Error Resume Next
   sPath = ONJLivePath() & "\dispdata." & Format$(Val(Command$), "000")
   sDummy = Dir$(sPath & "\*.ini")
   If Err <> 0 Or sDummy = "" Then
	 sMsg = "Cannot read data in " & sPath & ".  "
	 If Err <> 0 Then sMsg = sMsg & "The following error occurred: " & Format$(Err) & ": '" & Error$ & "'. "
	 sMsg = sMsg & "Check that the drive is accessible. This program "
	 sMsg = sMsg & "will now terminate."
	 On Error GoTo 0
	 Select Case iSetupMode
	    Case 1, 2
	       MsgBox sMsg, MB_ICONSTOP, "Overnight Job"
	    Case 0
	       ONJLog sMsg, False, False, False, True
	    End Select
	 Exit Sub                                 '<- Safe exit
      End If
   On Error GoTo 0

   sCommand = UCase(Command$)
   ONJReadSiteInfo sCommand
   Select Case iSetupMode
      Case 1, 2
	 GetONJPassword
      End Select
   FrmONJSplash.Hide
'-------------------

   iDelordContext = 1
   iDone = False
   sFrmFlag = ""
   'Take a copy of the data on disk for comparison later
   GetOvernightData iFound
   If iFound Then
	 ReDim SiteCop(1 To iNumOfSites)
	 For n = 1 To iNumOfSites
	    SiteCop(n) = SiteTypes(n)
	 Next
      End If

   Do
	 Load frmOvernight
	 CentreForm frmOvernight
	 frmOvernight.Tag = sFrmFlag

	 Select Case iSetupMode
	    Case 1
	       frmOvernight.OptTestOn.Value = True         'Always default to test mode for safety
	       frmOvernight.Tag = "FIRST"
	       frmOvernight.Show 1
	       If frmOvernight.Tag <> "CONTINUE" Then
		     iDone = True
		  Else
		     iSetupMode = 0
		  End If
	       

	    Case 2, 3                                    'Setup or Test run
	       frmOvernight.OptTestOn.Value = True         'Always default to test mode for safety
	       sBuffer = TxtD$(AppPathNoSlash() & ONJINIFILE$, "Sites", "¬", "Number", iFound)
	       If iFound Then GetOvernightData iFound
	       If iFound Then
		     frmOvernight.Tag = "SETUP"
		     'ArrangeONJForm 2
		     frmOvernight.Show 1
		     If frmOvernight.Tag <> "CONTINUE" Then
			   iDone = True
			Else
			   iSetupMode = 0
			End If
		  Else
		     iSetupMode = 1
		  End If

	    Case Else                                    'running automatically
	       iAutoRun = True
	       GetOvernightData iFound
	       If iFound Then
		     frmOvernight.LblSplash.Caption = "Overnight Job Running"
		     ArrangeONJForm 5
		     frmOvernight.Show 0
		     frmOvernight.Refresh
		     GoOvernightJob False, False
		     TidyONJLogs
		     If frmOvernight.Tag <> "CONTINUE" Then
			   iDone = True
			Else
			   iSetupMode = 2
			End If

		  Else                                   'Cue setup if can't find the ini file
		     iSetupMode = 1
		  End If

	    End Select

ErrResume:
      sFrmFlag = frmOvernight.Tag
      Unload frmOvernight
      DoSaferEvents 1
      iAutoRun = False
   Loop Until iDone

   CheckAndLogChanges
   
   Exit Sub

OvernightErr:

   ONJErrHandler
   iSetupMode = 2                'setup
   frmOvernight.Tag = ""
   Resume ErrResume

End Sub

Function PatidxCommand (iValue As Integer) As String

'Convert an integer value into a set of command line parameters
'understood by patidx.

Dim sComm As String


   sComm = ""
   If iValue > 0 Then
	 If iValue > 1 Then
	       sComm = sComm & "/FULL "
	       If iValue And PI_CASENO Then sComm = sComm & "/1 "
	       If iValue And PI_SNFN Then sComm = sComm & "/2 "
	       If iValue And PI_FNSN Then sComm = sComm & "/3 "
	       If iValue And PI_WDCON Then sComm = sComm & "/4 "
	       If iValue And PI_RECNO Then sComm = sComm & "/5 "
	       If iValue And PI_GP Then sComm = sComm & "/6 "
	       If iValue And PI_RX Then sComm = sComm & "/7 "
	       If iValue And PI_SOUND Then sComm = sComm & "/8 "
	       If iValue And PI_FNSND Then sComm = sComm & "/9 "
	    End If
	 If iValue And PI_TIDYALL Then sComm = sComm & "/TIDYALL "
      End If


   PatidxCommand = sComm

End Function

Function PBSDrugToDispens () As Integer
'29Aug03 TH/ATW
' STUB
End Function

Function PBSGetBillitem (b As Integer) As String
'29Aug03 TH/ATW
'STUB
End Function

Function PBSGetExceptionalQty () As Single
'29Aug03 TH/ATW
'STUB
End Function

Sub PharmacistEditor (a As Integer)

'29Aug03 TH/ATW
'STUB

End Sub

Sub PharmacistInCharge (a As Integer)

'29Aug03 TH/ATW
'STUB

End Sub

Sub PositionProgress ()

'Position progress form somewhere sensible
   
   Load Progress

   If iAutoRun Then
	 Progress.Left = frmOvernight.Left + .5 * (frmOvernight.Width - Progress.Width)
	 Progress.Top = frmOvernight.Top + frmOvernight.PnlSummary.Top + frmOvernight.PnlSummary.Height - 1.1 * Progress.Height
	 If Not Progress.Visible Then
	       If Progress.lblInfo.Caption <> "" Then Progress.Show 0
	    End If
      Else
	 Progress.Left = frmOvernight.Left + .5 * (frmOvernight.Width - Progress.Width)
	 Progress.Top = frmOvernight.Top + frmOvernight.PnlSummary.Top + frmOvernight.PnlSummary.Height + BORDER
      End If




End Sub

Sub SaveONJSettings (iValid As Integer)

'Write the current settings to the ini file
'--------------------------------------------------------------------------------
'07Mar00 AE  Now only saves path etc to ASCribe.ini if we are not using a non-standard
'            live path.

Dim success As Integer, n As Integer
Dim sSite As String
Dim iFil As Integer
Dim sMePath As String

   sErrProc = "SaveONJSettings"
   sErrStage = ""
   On Error GoTo SOSErr

   'Ensure saved if we're on a sitejobs screen
   UpdateSiteJobs

   'Perform any validation
   ValidateSettings iValid
   If Not iValid Then Exit Sub

   WritePrivateIniFile "Sites", "Number", Format$(iNumOfSites), AppPathNoSlash() & ONJINIFILE$, success

   For n = 1 To iNumOfSites
      sSite = Format$(SiteTypes(n).Number, "000")
      WritePrivateIniFile "Sites", Format$(n), sSite, AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "DISPDATA", IFF((SiteTypes(n).Disp), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "PATDATA", IFF((SiteTypes(n).Pat), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "ORDERSIDX", IFF((SiteTypes(n).Wdelord), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "PATIENTIDX", Format$(SiteTypes(n).Patidx), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "FINANCPY", IFF((SiteTypes(n).FINANCPY), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "CONTRACTUPD", IFF((SiteTypes(n).StckNght), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      WritePrivateIniFile sSite, "SINGLECOPY", IFF((SiteTypes(n).SingleCopy), "Y", "N"), AppPathNoSlash() & ONJINIFILE$, success
      
      'Update Siteinfo.ini for each site with info about this program
      'Path is considered to be the path from the live drive to this program
      If TxtH$(AppPathNoSlash() & ONJINIFILE$, "", "NO", "NonStandardLivePath", 0) = "NO" Then                                '07Mar00 AE  Added if.  If live path is not on this machine,
	    sMePath = Mid$(AppPathNoSlash(), Len(ONJLivePath()) + 1)                                                          '            it is unlikely that other machines will be able to see this program.
	    WritePrivateIniFile "OvernightJob", "Path", sMePath, "\dispdata." & sSite & "\Ascribe.ini", success
	    WritePrivateIniFile "OvernightJob", "Logs", sMePath & ONJLogDir$, "\dispdata." & sSite & "\Ascribe.ini", success
	 End If
   Next
	 
SOSExit:

Exit Sub

SOSErr:

   ONJErrHandler
   Resume SOSExit

End Sub

Sub SetKeepPBSDefaults (a As Integer)

'29Aug03 TH/ATW
'STUB

End Sub

Sub ShowExtraSetupInfo (iIndex As Integer)

'To show extra info when the user clicks on one of the
'setup options from the list box.

'19May00 AE  Additions to allow the user to choose to delete inters after a certain
'            number of days. (similar to /inters switch in delord)

Dim sTmp As String, sMsg As String
Dim iFound As Integer
Dim sPrompt As String               'Goes onto the prompt label

   frmOvernight.txtExtraInfo.Text = ""
   frmOvernight.FraOptionControls.Enabled = True
   sPrompt = ""

   Select Case iIndex
      Case 1
	 'Multiple Finance copy setting
	 sMsg = "This setting allows the program to take nightly snapshots of multiple dispdatas."
	 sMsg = sMsg & " These will be saved in the " & GetMonthendDir() & " Directory"
	 EnableSetupControls 1
	 sTmp = SetupOptions(1)
	 frmOvernight.OptSetupON.Tag = "N"
	 frmOvernight.OptSetupOFF.Tag = "N"
	 frmOvernight.OptSetupON.Value = (sTmp = "Y")
	 frmOvernight.OptSetupOFF.Value = Not (frmOvernight.OptSetupON.Value)
	 frmOvernight.CmbSetup.Clear
   

      Case 2
	 'Delete Delnotes > 7 days
	 sMsg = "This setting forces the deletion of all delivery notes which have been "
	 sMsg = sMsg & "on disk for more than 7 days.  This will be applied to all sites "
	 sMsg = sMsg & "for which 'Orders Re-Index' has been chosen."
	 EnableSetupControls 1
	 frmOvernight.OptSetupON.Tag = "N"
	 frmOvernight.OptSetupOFF.Tag = "N"
	 frmOvernight.OptSetupON.Value = Val(SetupOptions(2))
	 frmOvernight.OptSetupOFF.Value = Not (frmOvernight.OptSetupON.Value)

      Case 3
	 'Log file duration on disk
	 sMsg = "Set the number of days for which the Overnight Job log files are kept"
	 sMsg = sMsg & " on disk.  This can be reduced if disk space is an issue."
	 EnableSetupControls 2
	 frmOvernight.TxtSetup.Text = SetupOptions(3)
	 frmOvernight.TxtSetup.Tag = "1234567890"         'Valid input chars
	 sPrompt = "(Enter value and press Return)"
      
      Case 4
      'Force single snapshot copy to dispdata.9xx
	 sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "ReporterVer", iFound)
	 sMsg = "If turned on, this enforces the setting up of a financial copy from "
	 sMsg = sMsg & "a single site into Dispdata.9** (where ** is the month from "
	 sMsg = sMsg & "01 to 12)" & crlf$
	 If Not iFound Then
	       sMsg = sMsg & "A multiple-snapshot capable version of the EIS has NOT been"
	       sMsg = sMsg & " detected running on this system. It is advised that you leave "
	       sMsg = sMsg & " this setting turned ON."
	    Else
	       sMsg = sMsg & "This is intended to ensure compatability with older versions of"
	       sMsg = sMsg & " the EIS"
	    End If
	 EnableSetupControls 1
	 frmOvernight.OptSetupON.Tag = "N"
	 frmOvernight.OptSetupOFF.Tag = "N"
	 frmOvernight.OptSetupON.Value = (SetupOptions(4) = "Y")
	 frmOvernight.OptSetupOFF.Value = Not (frmOvernight.OptSetupON.Value)

      Case 5
      'Delete Internal orders after 'n' days                                                                      '19May00 AE
	 sMsg = "This setting will delete completed internal orders from the system after the "                   '     "
	 sMsg = sMsg & "set number of days.  This will prevent unreconciled internal orders"                      '     "
	 sMsg = sMsg & " cluttering up the system. (Analogous to the old '/INTERS' command line switch)."         '     "
	 sMsg = sMsg & " This setting will be applied to all sites for which 'Orders Re-Index' has been chosen"   '     "
	 EnableSetupControls 2                                                                                    '     "
	 frmOvernight.TxtSetup.Text = SetupOptions(5)                                                             '     "
	 frmOvernight.TxtSetup.Tag = "1234567890"         'Valid input chars                                      '     "
	 sPrompt = "(Enter value and press Return)"                                                               '     "

      '
      '
      'more
      '
      '
      End Select

   'Clear tags of setup controls (this activates them)
   EnableSetupControls 0
   frmOvernight.LblSetupPrompt.Caption = sPrompt
   frmOvernight.txtExtraInfo.Text = sMsg

End Sub

Sub ShowSetupOptions ()

'Allow the changing of fundamental settings, eg financial copy from 1 / many sites.
'The menu is only enabled for top level passwords.

'19May00 AE  Additions to allow the user to choose to delete inters after a certain
'            number of days. (similar to /inters switch in delord)


Dim msg$, ans$, k As kbdcontrol
Dim sTmp As String, iFound As Integer
Dim sLine As String

   sErrProc = "ShowSetupOptions"
   sErrStage = ""
   On Error GoTo SSOErr


   msg$ = "WARNING!  Changing the following settings can affect the way" & cr$
   msg$ = msg$ & "the system functions." & cr$ & cr$
   msg$ = msg$ & "DO NOT PROCEEDE Except on instructions from EMIS Health" & cr$
   msg$ = msg$ & "All changes will be logged." & cr$ & cr$
   msg$ = msg$ & "Proceede ?"

   AskWin "Overnight Job", msg$, ans$, k
   If ans$ <> "Y" Then Exit Sub
   
   ArrangeONJForm 6
      

   'Read current settings from disk:
   ReDim SetupOptions(1 To 5) As String                                                     '19May00 AE  Changed to 5
   'Multiple snapshot. Format is MultipleSnapshot={Y/N}|Drive:\Path\
   sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "MultipleSnapshot", iFound)
   SetupOptions(1) = sTmp
   'Delete Delivery notes > 7 days.  Format is {-1/0}
   sTmp = TxtD$(dispdata$ & "\wdelord.ini", "", "", "DeleteDelNotes", iFound)
   SetupOptions(2) = sTmp
   'Duration of ONJ logs on disk. Numerical format
   sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "LogFileDuration", iFound)
   SetupOptions(3) = sTmp
   'Force the user to retain a financial copy to dispdata.9xx.  Format is {Y/N}
   sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "ForceSingleSnapshot", iFound)
   SetupOptions(4) = sTmp
   'Delete internal orders after 'n' days                                                    '19May00 AE  Added
   sTmp = TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "DeleteInters", iFound)               '     "
   SetupOptions(5) = sTmp                                                                    '     "

   UpdateOptionsList
   EnableSetupControls 0

SSOExit:

Exit Sub

SSOErr:

   ONJErrHandler
   Resume SSOExit

End Sub

Sub showsitejobs (iIndex As Integer)
			   

'Display the jobs for this site, allow editing
'ChkJobs(0)       Orders Reindex
'ChkJobs(1)       Contract Price Update
'ChkJobs(2)       Multiple Financial Copy
'ChkJobs(3)       Single Financial Copy
'ChkJobs(4)       Patient Re-Indexing

Dim iMultipleCopies  As Integer, n As Integer
Dim sVisible As String

   sErrProc = "ShowSiteJobs"
   sErrStage = "iIndex = " & Format$(iIndex)
   On Error GoTo SSJErr

   sVisible = "00000"

   ArrangeONJForm 3
   ONJinfo "Setup mode"

   iSiteINdex = iIndex
   frmOvernight.LblSiteNum.Caption = Format$(SiteTypes(iSiteINdex).Number, "000")

   For n = 0 To 4
      frmOvernight.ChkJob(n).Value = 0
      frmOvernight.ChkJob(n).Visible = 0
   Next

   If SiteTypes(iSiteINdex).Pat Then
	 Mid$(sVisible, 5, 1) = "2"
	 frmOvernight.CmdJobMore(4).Caption = "Advanced..."
      End If

   'Turn on appropriate buttons for each site type
   If Not SiteTypes(iSiteINdex).Disp Then
	 Mid$(sVisible, 1, 4) = "0000"
      Else
	 Mid$(sVisible, 1, 4) = "1111"
      End If

   'Are multiple financial copies enabled ?
   iMultipleCopies = (TxtD$(AppPathNoSlash() & ONJINIFILE, "", "", "MultipleSnapshot", 0) = "Y")
   If Not iMultipleCopies Then
	 Mid$(sVisible, 3, 1) = "0"
      End If

   If SiteTypes(iSiteINdex).Wdelord Then frmOvernight.ChkJob(0).Value = 1
   If SiteTypes(iSiteINdex).StckNght Then frmOvernight.ChkJob(1).Value = 1
   If SiteTypes(iSiteINdex).FINANCPY Then frmOvernight.ChkJob(2).Value = 1
   If SiteTypes(iSiteINdex).SingleCopy Then frmOvernight.ChkJob(3).Value = 1
   If SiteTypes(iSiteINdex).Patidx And SiteTypes(iSiteINdex).Pat Then frmOvernight.ChkJob(4).Value = 1

   ArrangeChkJobs sVisible

SSJExit:

Exit Sub

SSJErr:

   ONJErrHandler
   Resume SSJExit

End Sub

Sub ShowStatus (iFirstRun As Integer)
'Initial status summary, showing dispdatas,patdatas, etc.
'Picks up new Disp / Patdatas if added; would be nice to remove entries if the
'folders are deleted.
'---------------------------------------------------------------
'01Mar00 AE  Now writes LastRan=INSTALL instead of a blank entry the first time.
'            Otherwise, readprivateprofilestring doesn't pick it up. Also writes
'            Default entries to ini file even if it already exists, but is empty

Dim sDisp As String, sLine As String, iDispFound As Integer, iPatFound As Integer
Dim sPat As String, iFil As Integer, ok As Integer
Dim sPath As String, n As Integer, sTmp As String
Dim iFailed As Integer, iFound As Integer

   sErrProc = "ShowStatus"
   sErrStage = "iFirstRun = " & Format$(iFirstRun)
   On Error GoTo SStErr

   Screen.MousePointer = HOURGLASS

'Set up form

   ArrangeONJForm IFF(iFirstRun, 1, 4)

   ONJinfo "Setup mode"
   frmOvernight.LblTitle.Caption = "Status Report"

'do intro if neccesary

   If iFirstRun Then
	 frmOvernight.TxtStatus.Text = "The Overnight Job will now procede with initial setup..." & crlf$ & crlf$ & crlf$
	 
	 If Not Fileexists(AppPathNoSlash() & ONJINIFILE$) Then
	       'Create a new ini file on disk
	       iFil = FreeFile
	       Open AppPathNoSlash() & ONJINIFILE$ For Output As iFil
	       Close iFil
	    End If
	 frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Creating File " & AppPathNoSlash() & ONJINIFILE$ & crlf$                         '01Mar00 AE  Moved outside of IF
	 WritePrivateIniFile "", "LogFileDuration", Format$(2 * MINONJLOGDURATION), AppPathNoSlash() & ONJINIFILE$, ok  'default is twice minimum
	 WritePrivateIniFile "", "MultipleSnapshot", "N", AppPathNoSlash() & ONJINIFILE$, ok                            'default multiple copy is Off
	 WritePrivateIniFile "", "ForceSingleSnapshot", "Y", AppPathNoSlash() & ONJINIFILE$, ok                         'default is on
	    

	 'Ensure it holds a blank lastran entry.
	 WritePrivateIniFile "", "LastRan", "INSTALL", AppPathNoSlash() & ONJINIFILE$, ok
      
	 'Check for working directory hanging below the one with this program in
	  If Not Direxists(AppPathNoSlash() & ONJWorkingDir) Then
	       MkDir AppPathNoSlash() & ONJWorkingDir
	       frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Creating Directory " & AppPathNoSlash() & ONJWorkingDir & crlf$
	    End If

	 If Not Direxists(AppPathNoSlash() & ONJLogDir) Then
	       MkDir AppPathNoSlash() & ONJLogDir
	       frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Creating Directory " & AppPathNoSlash() & ONJLogDir & crlf$ & crlf$
	    End If

      End If

'Run status report.

'Show Live Drive
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Finding Live Drive..." & crlf$
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Live Drive = " & ONJLivePath() & crlf$ & crlf$


'Find dispdatas
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Searching for dispdatas..." & crlf$
   sDisp$ = Dir$(ONJLivePath() & "\dispdata.*", ATTR_DIRECTORY)
   iDispFound = False

   Do
      If sDisp$ <> "" Then
	    If Val(Right$(sDisp$, 3)) < 900 Then        'Ignore financial copy folders
		  sLine$ = "      Found: " & sDisp$
		  frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$ & sLine$
		  iDispFound = True
		  AddSite (Right$(sDisp$, 3)), "DIS"
	       End If
	    sDisp$ = Dir$
	 End If
   Loop Until sDisp$ = ""

   
   If Not iDispFound Then
	 frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$ & "No Dispdata Folders Found!"
      End If

'Find Patdatas
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$ & crlf$ & crlf$
   frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & "Searching for patdatas..." & crlf$
   
   sPat$ = Dir$(ONJLivePath() & "\patdata.*", ATTR_DIRECTORY)
   iPatFound = False
   Do
      If sPat$ <> "" Then
	    If Val(Right$(sDisp$, 3)) < 900 Then        'Ignore financial copy folders
		  sLine$ = "      Found: " & sPat$
		  frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$ & sLine$
		  iPatFound = True
		  AddSite (Right$(sPat$, 3)), "PAT"
		  sPat$ = Dir$
	       End If
	 End If
   Loop Until sPat$ = ""

   If Not iPatFound Then
	 frmOvernight.TxtStatus.Text = frmOvernight.TxtStatus.Text & crlf$ & "No Patient Data Found!"
      End If

   If iFirstRun Then
	 ONJinfo "If this seems correct, click on 'Next' to Proceede"
      Else
	 ONJinfo ""
      End If
   
   Screen.MousePointer = STDCURSOR

SStExit:

   FlushIniCache

Exit Sub

SStErr:

   ONJErrHandler
   Resume SStExit

End Sub

Function SlaveModeEnabled ()
'01oct03 CKJ for 9.2 interface

   SlaveModeEnabled = False

End Function

Sub TidyONJLogs ()

'Tidy up the overnight job's own log files.
'This proc runs every time the overnight job is run live.
'After ONJLogDuration% days, a daily log is deleted, and its entry
'In the master log file is removed, along with anything before it.

'This should keep the logs to a manageable size.
'------------------------------------------------------------------------
'03Feb00 AE  Corrected to actually use the defined setting!
'            Also changed to use Input# instead of Input$
'03Mar00 AE  Correction to line setting sDir.  Was set as "\overnite\logs\*.log*.log" which
'            actually worked fine on NT but gave a "Path not Found" on '95

Dim dt As DateAndTime, td As DateAndTime
Dim sFile As String, sDir As String
Dim sFileDate As String, lDays As Long, sToday As String
Dim iFil As Integer, sBuffer As String, iFinshed As Integer
Dim lCount As Long, lEnd As Long, iNewFil As Integer, sNewFile As String
Dim iFinished As Integer, ok As Integer
Dim iDuration As Integer                                                '03Feb00 AE Added

   sErrProc = "TidyONJLogs"
   On Error GoTo TOLErr

   iDuration = Val(TxtD$(AppPathNoSlash() & ONJINIFILE, "", Format$(2 * MINONJLOGDURATION), "LogFileDuration", ok))  '03Feb00 AE Added
   sDir = AppPathNoSlash() & ONJLogDir '& "\*.log"                                 '03Mar00 AE Corrected
										   '      "
   sFile = Dir$(sDir & "\*.log")                                                   '      "
   If sFile <> "" Then
	 today td
	 datetostring td, sToday
	 Do
	    sErrStage = "Scanning Directory"
	    If "\" & UCase(sFile) <> UCase(ONJLogFile) Then
		  sFileDate = Left$(sFile, 8)
		  sFileDate = Right$(sFileDate, 2) & "/" & Mid$(sFileDate, 5, 2) & "/" & Left$(sFileDate, 4)
		  datetodays sFileDate, sToday, lDays, 0, "", ok
		  'If lDays > MINONJLOGDURATION Then GoSub DeleteONJLog             '03Feb00 AE corrected
		  If lDays > iDuration Then GoSub DeleteONJLog                      '     "
	       End If
	       sFile = Dir$
	 Loop Until sFile = ""
      End If


TOLExit:

   Exit Sub

DeleteONJLog:
   'Delete the daily log;
   sErrStage = "File Deletion"
   Kill AppPathNoSlash() & ONJLogDir & "\" & sFile
   'Remove its entry from the master log.
   iFil = FreeFile
   sErrStage = "Finding position in Master Log"
   Open AppPathNoSlash() & ONJLogDir & ONJLogFile For Input As iFil
   lCount = 0
   iFinished = False
   Do
      If Not EOF(iFil) Then
	    'sBuffer = Input$(ONJRecLen + 2, #iFil)
	    Input #iFil, sBuffer                             '    "
	    lCount = lCount + 1
	    If InStr(sBuffer, sFileDate) Then               'Found the start of the entry for that date
		  Do
		     If Not EOF(iFil) Then                  'Search for the end of the entry...
			   'sBuffer = Input$(ONJRecLen + 2, #iFil)          '03Feb00 AE Changed
			   Input #iFil, sBuffer                             '    "
			   lCount = lCount + 1
			   replace sBuffer, crlf$, "  ", 0
			   If Trim$(sBuffer) = "" Then      'found it.
				 lEnd = lCount              'Store in lEnd and exit loop
				 iFinished = True
			      End If
			Else
			   iFinished = True
			End If
		  Loop Until iFinished

	       End If
	 Else
	    iFinished = True
	 End If

   Loop Until iFinished
   Close iFil

   'If we found the entry in the master log, delete everything from the start to the end of the log.
   iFil = FreeFile

   sErrStage = "Editing Master Log"

   Open AppPathNoSlash() & ONJLogDir & ONJLogFile For Input As iFil
   sNewFile = AppPathNoSlash() & ONJWorkingDir$ & "\ONJTemp.log"

   iNewFil = FreeFile
   Open sNewFile For Output As iNewFil
   
   lCount = 0
   Do
      If Not EOF(iFil) Then
	    'sBuffer = Input$(ONJRecLen + 2, iFil)
	    Input #iFil, sBuffer                                '03Feb00 AE Changed
	    sBuffer = Mid$(sBuffer, 1, ONJRecLen)
	       If lCount > lEnd Then
		  Print #iNewFil, sBuffer
	       End If
	 End If
      lCount = lCount + 1
   Loop Until EOF(iFil)
      
   Close iFil
   Close iNewFil

   'Rename the new log to be the master log, delete the old one
   Kill AppPathNoSlash() & ONJLogDir & ONJLogFile
   Name sNewFile As AppPathNoSlash() & ONJLogDir & ONJLogFile

   Return

'----------------------------------------------------------------
TOLErr:

   Close                                     '03Feb00 AE Added for safe exit
   ONJErrHandler
   Resume TOLExit

End Sub

Sub UpdateOptionSettings (iSetting As Integer, iIndex As Integer)

'Update the setting for the given option according to the appropriate controls.

'19May00 AE Addition for Delete Inters Setting


   Select Case iSetting
      Case 1
	 'Multiple finacial copy setting
	 SetupOptions(1) = IFF((frmOvernight.OptSetupON.Value), "Y", "N")

      Case 2
	 'Delete Delnots > 7 days
	 SetupOptions(2) = IFF((frmOvernight.OptSetupON.Value), "-1", "0")

      Case 3
	 'Log file duration
	 SetupOptions(3) = frmOvernight.TxtSetup.Text

      Case 4
	 'Force Single Financial copy setting
	 SetupOptions(4) = IFF((frmOvernight.OptSetupON.Value), "Y", "N")

      Case 5
	 'Delete internal orders after 'n' days                                     '19May00 AE
	 SetupOptions(5) = frmOvernight.TxtSetup.Text

      End Select

   frmOvernight.LstOptions.Clear
   UpdateOptionsList
   frmOvernight.LstOptions.ListIndex = iIndex
   frmOvernight.LstOptions.SetFocus
   

End Sub

Sub UpdateOptionsList ()

'19May00 AE  Addition for delete inters setting


Dim sLine  As String
Dim sTmp As String, iPos As Integer

   sErrProc = "UpdateOptionsList"
   sErrStage = ""
   On Error GoTo UOLerr

   'Add the options to the list box.
   If frmOvernight.LstOptions.ListCount = 0 Then
	 'Multiple financial copies. Parse out on/off and path for copy
	 sLine = "Financial Copy from Multiple Sites" & tb$ & tb$ & IFF(SetupOptions(1) = "Y", "ON", "OFF")
	 frmOvernight.LstOptions.AddItem sLine
	 frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.NewIndex) = 1
	 
	 'Delete Delnotes older than 7 days
	 sLine = "Delete delivery notes older than 7 days" & tb$ & tb$ & IFF(Val(SetupOptions(2)), "ON", "OFF")
	 frmOvernight.LstOptions.AddItem sLine
	 frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.NewIndex) = 2
	 
	 'Log File Duration on Disk
	 sLine = "Number of Days to keep log files" & tb$ & tb$ & SetupOptions(3)
	 frmOvernight.LstOptions.AddItem sLine
	 frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.NewIndex) = 3
	 
	 'Force retention of a single snapshot copy to dispdata.9xx
	 sLine = "Force financial copy to dispdata.9xx" & tb$ & tb$ & IFF(SetupOptions(4) = "Y", "ON", "OFF")
	 frmOvernight.LstOptions.AddItem sLine
	 frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.NewIndex) = 4

	 'Delete internal orders from reconcilliation screen after 'n' days                                          '19May00 AE  Added
	 sLine = "No of days to keep completed internal orders" & tb$ & IFF(Val(SetupOptions(5)) > 0, SetupOptions(5), "OFF")  '     "
	 frmOvernight.LstOptions.AddItem sLine                                                                       '     "
	 frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.NewIndex) = 5                                      '     "
	 
	 
	 '
	 '
	 'more...
	 '
	 '
      End If

   frmOvernight.LstOptions.ListIndex = 0

UOLexit:

Exit Sub

UOLerr:

   ONJErrHandler
   Resume UOLexit

End Sub

Sub UpdateSiteJobs ()

'update acording to what's on the screen
'Only do so if we're looking at the JobsBySite view, otherwise
'all will be blank.


Dim Idx As Integer, iMultipleCopies As Integer

   sErrProc = "UpdateSiteJobs"
   sErrStage = ""
   On Error GoTo USJErr

   'Only do if we're looking at a jobs by site view.
   If Not (frmOvernight.PnlJob.Visible) Then Exit Sub

   'Only allow one site to have ChkJob(3) turned on (single financial copy)
   If frmOvernight.ChkJob(3).Value <> 0 Then BlankFinancpySettings

   Idx = GetSiteIndex()
   If Idx > 0 Then
	 SiteTypes(Idx).Wdelord = (frmOvernight.ChkJob(0).Value <> 0)
	 If frmOvernight.ChkJob(4).Value = 0 Then
	       SiteTypes(Idx).Patidx = 0
	    ElseIf SiteTypes(Idx).Patidx = 0 Then            'Only set to one if no extra options chosen
	       SiteTypes(Idx).Patidx = 1
	    End If
	 SiteTypes(Idx).FINANCPY = (frmOvernight.ChkJob(2).Value <> 0)
	 SiteTypes(Idx).SingleCopy = (frmOvernight.ChkJob(3).Value <> 0)
	 SiteTypes(Idx).StckNght = (frmOvernight.ChkJob(1).Value <> 0)
      End If

USJExit:

Exit Sub

USJErr:

   ONJErrHandler
   Resume USJExit

End Sub

Sub ValidateSettings (iValid As Integer)

'Perform any neccesary validation of the settings chosen

Dim n As Integer, iValue As Integer, iFound As Integer
Dim sMsg As String, iFailed As Integer

   iFailed = False

   'Force single snapshot
   If TxtD$(AppPathNoSlash() & ONJINIFILE$, "", "", "ForceSingleSnapshot", iFound) = "Y" Then
	 iValue = 0
	 For n = 1 To iNumOfSites
	       If SiteTypes(n).SingleCopy Then iValue = True
	 Next
	 If Not iValue Then
	       sMsg = "You have chosen to retain a financial copy to " & cr$
	       sMsg = sMsg & "the Dispdata.9xx folders, but have not set one up. " & cr$
	       sMsg = sMsg & "You must set a copy up, or turn off the ""Force Financial Copy" & cr$
	       sMsg = sMsg & "to Dispdata.9xx"" setting." & cr$
	       sMsg = sMsg & "Leaving this setting on will ensure compatability with " & cr$
	       sMsg = sMsg & "older versions (v8.1 + ) of the EIS system"
	       popmessagecr ".Overnight Job", sMsg
	       iFailed = True
	    End If
      End If
   '
   '
   'more...
   '
   '


   iValid = Not iFailed



End Sub

Sub ViewONJLog (iMode As Integer, sDrvPthFile As String)

'Logs are text files for simplicity, held in the \logs directory under the directory in which the
'app is running

'Each Day has a separate log, named like the old monthend logs yyyymmdd.log eg 19991102.log,19991103.log etc
'There is also a master error log which is continuous, and record a successful job completion, or
'any errors which were encountered.  This is named ONJErr.log

'iMOde:  0 - View master error log
'iMode:  1 - View most recent log
'iMode:  2 - View log passed in in sFile
'iMode: <0 - View encrypted log passed in sFile
'-----------------------------------------------------------------------
'01Mar00 AE  Cosmetic change to error message

Dim sFile As String
Dim dt As DateAndTime, td As DateAndTime
Dim sLogDir$, iFlag As Integer

Dim iFil As Integer, iFinished As Integer
Dim sBuffer As String, sTmp As String
Dim iEncrypted As Integer

   sErrProc = "ViewONJLog"
   sErrStage = "iMode = " & Format$(iMode) & ", File = " & sDrvPthFile
   On Error GoTo VOLErr

   sLogDir$ = AppPathNoSlash() & ONJLogDir$
   ArrangeONJForm 2
   frmOvernight.HscSummary.Value = 0

   'Check if file is encrypted
   If iMode < 0 Then
	 iEncrypted = True
	 iMode = 2
      Else
	 iEncrypted = False
      End If

   Select Case iMode
      Case 0
	 'Displays the master log in the list box on frmovernight.
	 sFile = sLogDir$ & ONJLogFile$
	 frmOvernight.LblTitle.Caption = "Viewing Master Log"

      Case 1
	  'look for today's log first
	 sFile = "\" & Format$(Now, "yyyymmdd") & ".log"
	 If Not Fileexists(sLogDir$ & sFile) Then
	       'If not there, look for most recent
	       today td
	       Do
		  dt.Day = dt.Day - 1
		  addexpiry td, dt
		  sFile = "\" & Format$(td.Yrs, "00") & Format$(td.Mth, "00") & Format$(td.Day, "00") & ".log"
		  If Fileexists(sLogDir$ & sFile) Then iFinished = True
		  If dt.Day < -28 Then iFinished = True                     'Only look up to one month ago
	       Loop Until iFinished
	    End If
	 frmOvernight.LblTitle.Caption = "Viewing Log " & Mid$(sFile, 2, Len(sFile) - 4)
	 sFile = sLogDir$ & sFile
	 

      Case 2
      'Use given log file name
      sFile = sDrvPthFile
      frmOvernight.LblTitle.Caption = "Viewing Log " & sFile
      End Select
	  
   If Not Fileexists(sFile) Then
	 popmessagecr "Overnight Job", "No Log file ( " & sFile & " )"                           '01Mar00 AE  Corrected
      Else
	 iFil = FreeFile
	 Open sFile For Input As iFil
	 'read one line at a time into the buffer and display on the screen
	 Do
	    If Not EOF(iFil) Then
		  Input #iFil, sBuffer
		  'Decrypt file if necessary
		  If iEncrypted <> 0 Then
			decodehex sBuffer
		     End If
		  
		  iFlag = 0
		  'for master log, item data is 1 for a line with a start date, 0 otherwise.
		  If iMode = 0 Then
			If Left$(sBuffer, 1) = Chr$(127) Then
			      sBuffer = Mid$(sBuffer, 2)
			      iFlag = 1
			   End If
		     End If
		  frmOvernight.LstSummary.AddItem sBuffer
		  frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.NewIndex) = iFlag
		  frmOvernight.LstSummary.ListIndex = frmOvernight.LstSummary.NewIndex
	       End If
	 Loop Until EOF(iFil)
	 Close iFil
	 frmOvernight.LstSummary.Refresh
      End If

   frmOvernight.LstSummary.Tag = "LOG"

VOLExit:

Exit Sub

VOLErr:

   Select Case Err
      Case 381
      'Invalid property array index; list box has burst. Highly unlikely,
      'will fail gracefully anyway, but this will provide the user with
      'a reson as to why.
	 sTmp = "Warning! Log is too big to view!" & cr$
	 sTmp = sTmp & "You are advised to lower the number of" & cr$
	 sTmp = sTmp & "days for which the logs are stored on disk."
	 popmessagecr "!Overnight Job", sTmp
      
      Case Else
	 ONJErrHandler
      End Select

   Resume VOLExit

End Sub

Sub WriteONJAuditLine (sNAme As String, sValue As String, iSite As Integer)

'Write a XOR encrypted line to the Overnight.aud file
'If iSite is 0, ALL is written for the sites affected

Dim sEncrLine As String, sLogFile As String
Dim iFil As Integer
Dim sSite As String, sLine As String

   sErrProc = "WriteONJAuditLine"
   sErrStage = ""
   On Error GoTo WOALErr

   sLogFile = AppPathNoSlash() & ONJLogDir & ONJAudit

   If iSite > 0 Then
	 sSite = Format$(iSite, "000")
      Else
	 sSite = "ALL"
      End If

   sLine = Format$(Now, "dd/mm/yyyy") & " - " & userid$ & " " & Format$(sitenumber, "000")
   sLine = sLine & " Changed " & sNAme & " for Site " & sSite & " to " & sValue
   sLine = sLine & Space$(ONJRecLen - Len(sLine))
   sEncrLine = sLine
   encodehex sEncrLine
   iFil = FreeFile
   Open sLogFile For Append As iFil
   Print #iFil, sEncrLine
   Close iFil

WOALExit:

Exit Sub

WOALErr:

   ONJErrHandler
   Close
   Resume WOALExit

End Sub

