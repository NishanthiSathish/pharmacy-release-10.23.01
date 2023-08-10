Attribute VB_Name = "IPDlistMain"
'DOStoWIN V1.0 (c) ASCribe 1996
'-----------------------------------------------------------------------------
'                       In-Patient Dispensing List V5.4
'-----------------------------------------------------------------------------
'19Apr92 CKJ Program derived from PATMED.BAS 84479 15Apr92 5:33am
'24Apr92 CKJ Released for beta test
'27Apr92 CKJ Allow choice of CIVAS and/or Cytotoxic drugs for 'C' type issue.
'29Jul92 ASC Leave labels now added and dose for ivs now prints fractions of
'            a mg/u instead of integer using SUB foursigfigs
'19Mar93 CKJ Changed menu so that leave and stock options appear
' 2Nov93 CKJ VBDOS: printform => printformV
'18Dec93 ASC Added ATC capability
' 7Mar94 ASC Now uses Rx dates and times
'18Mar94 ASC dp! added to calculated Nod Issued and RxNodIssued also lastqty
'            now calculated
'21Mar94 ASC Now ends if under windows menu
' 7Apr94 CKJ Mod to stop updating of non-ATC records in PMR
'20Apr94 CKJ Sort by Name/Cons added, Free format labels are printed
' 4May94 CKJ Reinstated the IssTyp$() array - used in PrintHeader
'            Select by drug is implemented, & automatically sets civas/cyto.
'15May94 ASC MKS made MKL to match CVL for patidno& before new shell sort
'            label now loaded to allow printing from label file
'12Jul94 ASC ATC flagged items only sent to ATC not all drugs marked for ATC
'17Jul94 ASC Why is "ATC I" printed against every drug for an ATC run - it says ATC at
'            the top, and they may not actually be in-patients.    - done
'13Nov94 ASC added ChkBookout
'18Nov94 ASC Released for full testing - hopefully made worksheets print
'            for each item
'22Nov94 ASC only checks if there is a topupqty if not ATC
'24Nov94 CKJ l.PRN replaced by l.flags, bit 1
' 2Dec94 CKJ Inhibit issue & printout if Manual flag is set
' 9Dec94 CKJ Self med. => issuetype M not S
'            pid.status now written to log
' 7Jan95 CKJ ActionEachDose: Changed boolean logic to exclude PRN doses
'19Jan95 CKJ Added siteinfo defaults
'10Feb95 CKJ Added ChkTxtLbls box - allows user to choose whether free format
'            labels are to be printed on lists
'            Primitive screen display now allowed - see use of 'toscreen'
'            - create a batch file called VIEW.BAT on the path containing
'            @echo off, edit %1   or   @echo off, type %1 | more, pause   etc
'20Mar95 CKJ Added progsdrv
'23Mar95 CKJ Close changed
'04May95 ASC New ATC link completed and tested at Watford
'08May95 ASC Patient costing by issues plus ward stock Rx completed PRNfactor from
'            Patmed.ini used as factor of PRN doses administered for costing
'            purposes. PPOnCost = Factor to multiply cost e.g. 1.5 = 50% on Cost
'12May95 CKJ Several corrections to the above. Added MultiList
'15May95 CKJ/ASC More corrections - costing start date & boolean logic
'17May95 CKJ If individual patient is entered, don't ask for ward & don't
'            use the ward index, ie it now works even if patient discharged.
'            Footer only printed if non-text details printed for that patient
'            Prep date/Until date: Highlight day only on regaining focus
'18May95 CKJ Changed definition of PPoncost in Patmed.ini
'            PPoncost="1.5,1.8,ODL"  1st rate, 2nd rate, isstypes for 2nd rate
'24May95 CKJ Corrected mismatched parameters in label print routines
'            Corrected event handling in the form, on looking for drug
'25May95 CKJ Corrected OnCostReqd scope
' 7Jun95 CKJ ActionEachDose: Moved PrintPatientLabel outside the loop
' 7Jun95 CKJ PrintWorkLable: modified to correct num of lines/label
'            Now looks up name of container
'26Jun95 CKJ Amended tracking of used line count
'30Jun95 CKJ Added GPexp to pt line if valid (King's request)
'16Aug95 CKJ added check on file size for screen viewer
'21Jan96 ASC patcost switch now l.NodIssued * d.DosesPerIssueUnit to give correct conversion for l.nodissued
'12Feb96 EAC Print the stocklevel expected on ward and topup quantity
'01Jul96 ASC converted to windows
'15Aug96 EAC print the correct units for each drug in patient costing
'13sep96 ASC removed reference to CmdLabel and fullpage in Textedit
'26Sep96 CKJ Added HorizCentreForm ipdlist
'03Jun97 KR CallIPDList: Now get wards from supplier file.  Use SelectWards procedure to display ward list.
'18Jun97 KR Fixed spelling mistake in variable name: DosesForIs2sue!  in CallIPDList.
'03Jun97 KR CallIPDList: Fixed subscript out of range error - ward array was not being filled!
'           As now password protected, set the userid when writing to the translog.
'31Oct97 EAC CallIPDList: use the correct array to pull ward codes from
'20Jan98 CKJ CallIPDList: Added k.escd=True if pt not found
'20Jan98 CFY CallIPDList: Added code for blister packing
'21Jan98 CKJ CallIPDList: Now only processes blister packs if selected by the user
'             Shows blister option if Patmed ini set up for blister packing
'17Feb98 CFY CallIPDList: Changed code which determined the start and end times for blister packing
'02Mar98 CFY CallIPDList: Added extra conditions when calling 'PrintDetails' when Blister packing.
'                         Now when blister packing is selected, only the drugs which have been packed
'                         are shown on the report.
'05Mar98 CFY CallIPDList: New parameter added to shellsort
'16Mar98 CFY CallIPDList: Now reads ini file setting in patmed.ini to determine whether or not an editable
'                         preview of the blister pack should be shown.
'17Mar98 CFY CallIPDList: Now takes value of the Book-Out Check box and passes to the blister routines
'                         to indicate whether or not to issue stock.
'                         Extra condition added to stop drugs being booked out by the ipdlist routines when
'                         the blister check box is checked and the book out check box is checked. This is due to
'                         the fact that the blister routines handle the booking out of blister packed drugs themselves
'                         Also added assignment of pid.caseno to the global var gTlogCaseno$ so that the translog can
'                         write the caseno rather than the pid.recno to the log.
'15Apr98 ASC/CKJ issueunits changed to printformV when printing
'20Apr98 CKJ PrintDetails & ActionEachDose: reinstated Ltime$(x) with correct element name
'25Jun98 CFY ActionEachDose: Corrected calculation of quantities on labels. Now no longer divides by the
'            doses per issue unit.
'29Jun98 CFY ActionEachDose: Corrected quantity calculation. Now works correctly with both DSS and non DSS
'            drug data.
'02Jul98 CFY printdetails: Should now print each drug on a separate line.
'21Aug98 CFY printdetails: corrected qty calculations on topup sheets.
'21Aug98 CFY callipdlist: Corrected quantity calculations that are written to the log.
'21Aug98 CFY ActionEachDose: More mods to make calculations work correctly wih both DSS and non DSS drugs.
'02Sep98 TH  CallIPDList: Previewedit option on blisterpack printing now from chkbox not ini setting
'08Aug98 TH  CallIPDList: Added line to file/printout giving drug totals by ward.
'03Aug98 EAC PrintDetails: corrected logic for when rtf file is missing.
'03Aug98 TH  CallIPDList: Rtf printing now by contexts (hedit14)
'13Aug98 EAC PrintDrgQty: if fil = 0 assume nothing has been printed and exit sub
'08Sep98 CFY PrintDrgQty: Made change to quantity line to now read total issue quantity
'14Sep98 CFY CallPickList: Written
'14Sep98 CFY SplitFile: Written
'14Sep98 CFY BuildIssueTypes: Written
'19Nov98 CFY ActionEachDoes: Changed order in which labels are printed. Previously printing occured in the
'            following order : (formula/worklabel), dispensing label, bag label. This has now
'            been chaged to  : dispensing label, (formula/worklabel), bag label. The reason
'            for this is due to the fact that printing of worksheets for multiple patients requires
'            the label to be generated first in order to duplicate the information on the worksheet.
'            Also moved call to PrintWorkLabel to outside the main loop. This is to prevent a worksheet
'            being printed for every dose.
'19Nov98 CFY CallIPDList: Added call to PromptForWrkSht if doing a CIVAS item.
'            Now also does an additional call to PrintManWorksheet at end of process incase
'            there are still patients on the heap waiting to be parsed and printed.
'26Jan99 CFY CallIPDList: Corrected mod of 03Aug98
'24Feb99 SF  CallIPDList: traps for the user cancelling out at various times
'24Feb99 SF  ActionEachDose: added and sets escd% parameter
'15Mar99 SF  CallIPDList: made mods for repeat dispesning
'15Mar99 SF  CallIPDList: now if no patients on a ward displays that ward's code and name
'01Apr99 SF  CallIPDList: bumped up number of patients handled from 100 to 200 repeat dispensing
'07Apr99 SF  CallIPDList: changed the redim of array patsort$ from 100 to 200 for repeat dispensing
'26Apr99 SF  CallIPDList: removed hourglass when warning user that there are no patients on a ward
'14May99 CFY CallIPDList: Now Correctly parses all standard header information when doing a screen preview.
'04Jun99 CFY CallIPDList: Now generates the batch number fo CIVAS products before generating the labels
'             so that the number can be prointed on the label.
'07Jun99 SF  CallIPDList: now opens/closes "patid.mdb" only once to speed up batch processing in repeat dispensing
'28Jul99 AE  ActionEachDose: Added block to print extra civas / manufacturing labels from prescription manager
'06Sep99 CFY ActionEachDose: Change to fucntionality fucntionality of Extra CIVAS labels. Can now have extra labels
'             either per batch or per dose.
'10Dec99 SF  CallIPDlist: now allows the maximum patients per ward to be ini file specified (default is the original 200)
'24May00 AJK PrintDetails : Now passes the ward description though to be printed on print Header
'25Oct99 CFY CallPickList: Additional condition added to filter cancelled transactions.
'02May00 CFY CallPickList: Displays error lines on report if the product cannot be found for a particular transaction
'              Also changed formatting of qty to display only 2dp rather than 3dp.
'12oct01 CKJ CallIPDlist: Added separate frame for patient status & removed link between repeat dispensing and label types
'12Nov01 TH  CallIPDlist: Various changes to look up specific ward details if using patient specific search.
'   "        NB - quick changes for release - overhaul of this still required for 8.5 (#56702)
'14Feb02 TH  CallIPDlist: Added code to allow sort by consultant only if requested by user (option formally ignored) (#49045)
'25Feb02 TH  CallIPDlist: Changed to flag not to reference dispens.frm (#59050)
'01Jun02 All/CKJ Added option explicit & corrected resulting issues
'15Oct02 TH  CallIPDlist: Added flag to stop translog write if manu issue and ActionEachDose has already been called (#)
'16Oct02 TH  CallIPDlist: Moved calls to promptBatchno on civas issue to point where the issue will take place (ie after checks on exclusions) (#)
'21OCt02 TH  CallIPDlist: Mod to suppress 'OK to print msg' (cant cancel at this point) and to add patient details to batchno prompt caption during manu issue
'21Oct02 TH  ActionEachDose: Added calls to put batchnumber and expirydateonly to heap
'13Nov02 CKJ CallIPDlist: Moved call to PromptBatchNumber inside ActionEachDose. Only allocate batchno when there is at least one dose to be handled.
'             If ActionEachDose finds that enough doses have been done already then it would have wasted that batchno
'             Added support for detecting whether a formula has been handled internally by manufacturing
'            ActionEachDose: Allocate batch number only when at least one civas dose is needed
'             Don't print extra labels unless at least one dose has been found
'             Added support for detecting whether a formula has been handled internally by manufacturing             (#64623)
'14Feb03 CKJ Removed ATC.INC from project and moved the two structures here
'            Gauge 'GgeDone' is set from CallIPDlist but the form is never visible at this time. Removed reference
'            to the guage control & removed it from the project.
'29Sep04 TH  CallIPDlist: Added mod to check each label and set to history if date past stop date. These labels will not now be processed.
'05Sep05 PJC/TH CallIPDlist: Added a test for AutoArchive to the logic in the If statement (#79161).
'12Jan07 PJC    CallIPDlist: Added extra empty arguments to the call to PrintManWorksheet (enh77351).
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'21Nov08 CKJ Ported to V10.0 from V8.8
'24May11 CKJ CallIPDList, Actioneachdose, CheckRxStatus: Removed as not used

'problems requiring attention
'-----------------------------
' Badlabel is never set to true (not in scope)
' Recursion during selecting a drug can cause out of stack space error, but
'   very unlikely in normal use now that TxtDrugCode_LostFocus is Static.
'   - not an issue now that drug selection is a form
' The following line is not in any other module - WHY?
'   COMMON SHARED /CIVA/ docyto, DoCivas, notenabled, printout

'improvements needed
'-------------------
' if a script has expired (stopdate<today) print expired or similar on sheet
' allow escape from label printing
'
' amend the checks for duff pointers
' add help                done (page 300 needs writing once the checks are in)
' add margin              done
' add text                done
' add pagination          done
' add ward description    done
' Err70msg                done
' maxnw needs thought - max 160 items on screen   done
' add screen display of incorrect civas/cyto settings, from errorlog.txt

'       8" @ 10cpi   =  80   cpl
'          @ 12cpi   =  96
'          @ 16.5cpi = 132
'          @ 19.8cpi = 158.4
'-----------------------------------------------------------------------------
DefInt A-Z
Option Explicit

Const pagelen = 63    ' lines per page before form feed
Const margin = 10     ' left margin
                                                     
'14Feb03 CKJ Moved from ATC.INC
Type ATCTIM
   name As String * 20
   patid As String * 12
   PatLoc As String * 12
   drugcode As String * 15
   date As String * 6  'American Format
   Time As String * 4
   Dosage As String * 2
   crlf As String * 2
End Type               ' length 71

Dim ATC As ATCTIM
Dim esc$, page%, lins%, fil%, SpoolFile$
Dim IssTyp$(11) 'NB Array must remain as Static
Dim IssType$
Dim td As DateAndTime  'ASC 15May94 made shared
Dim dos As DateAndTime
Dim dt As DateAndTime
Dim xp As DateAndTime  ' ASC 2May94 made shared
Dim Ldose!(6)
Dim LTime$(6)
Dim DosesForIssue!, DoLabel%, Dobaglabel%, DoWorklabel%, Patcost% '06May95
Dim OnCostReqd%        '25May95 CKJ Added

Dim WorkingDate$, WorkingTime$, ToScreen%, ATCfile$
Dim PatientCost! '08May95 ASC

Dim docyto%
Dim DoCivas%
Dim Notenabled%
Dim printout%
Dim newward%, firstpatient%, firstdrug%
Dim PatientName$, issuedesc$, SendtoATC%
Dim tday$, wnow$, WDexpand$, excIVcyto%, headermessage$

Dim RTFTxt$       '30Jul98 CFY Added
Dim PrintError%   '30Jul98 CFY Added
Dim PgFeedWards%  '30Jul98 CFY Added

Dim printdrugtotal%          '31Jul98 TH Added
Dim totalexpectedqty!        '31Jul98 TH Added
Dim totaltopupqty!           '31Jul98 TH Added
Dim grandtotalexpectedqty!   '31Jul98 TH Added
Dim grandtotaltopupqty!      '31Jul98 TH Added
Dim drugdesc$                '31Jul98 TH Added
Dim Layout$, PatsPerSheet%   '19Nov98 CFY

'24May11 CKJ Removed as not used
'Sub ActionEachDose(frmAction As Form, SendtoATC%, MakeMacro%, dircode$, escd%, o_blnFormulaHandled As Integer)
''17Jul94 ASC Takes start time as dt and stop time as xp and produces
''            output for each dose between
'' 2Dec94 CKJ Only action if Manual flag is not set
'' 7Jan95 CKJ Changed boolean logic to exclude PRN doses
'' 7Jun95 CKJ moved PrintPatientLabel outside the loop
''20Apr98 CKJ reinstated Ltime$(x) with correct element name
''29Jun98 CFY Corrected quantity calculation. Now works correctly with both DSS and non DSS
''            drug data.
''21Aug98 CFY More mods to make calculations work correctly wih both DSS and non DSS drugs.
''19Nov98 CFY Changed order in which labels are printed. Previously printing occured in the
''            following order : (formula/worklabel), dispensing label, bag label. This has now
''            been chaged to  : dispensing label, (formula/worklabel), bag label. The reason
''            for this is due to the fact that printing of worksheets for multiple patients requires
''            the label to be generated first in order to duplicate the information on the worksheet.
''            Also moved call to PrintWorkLabel to outside the main loop. This is to prevent a worksheet
''            being printed for every dose.
''13Jan99 CFY Moved procedure SplitFiles to module subpatme.bas for wider user.
''24Feb99 SF  added and sets escd% parameter
''28Jul99 AE  Added block to print extra civas / manufacturing labels from prescription manager
''06Sep99 CFY Change to fucntionality fucntionality of Extra CIVAS labels. Can now have extra labels
''            either per batch or per dose.
''21Oct02 TH  Added calls to put batchnumber and expirydateonly to heap
''13Nov02 CKJ Allocate batch number only when at least one civas dose is needed
''            Don't print extra labels unless at least one dose has been found
''            Added support for detecting whether a formula has been handled internally by manufacturing
'
''!!** seems slow for some items - why?
''       appears to loop many times before printing
'
'Dim Create%
'Dim RxNodIssued!                 '21Aug98 CFY Added
'Dim found%, ExtraLabels%, ExtraLabelsBatch%, ExtraLabelsDose%
'Dim BagLabelReqd As Integer, X As Integer, mins&, asciiday   As Integer, dow$, doses!, cont&, thisdose!, dosedate$, valid As Integer, DoseTime$, numDoses%, expiry$ '01Jun02 All/CKJ
'Dim blnBatchNumAllocated As Integer  '13Nov02 CKJ
'
'   'PrintWorkL = True            '19Nov98 CFY Removed
'   BagLabelReqd = False
'   blnBatchNumAllocated = False  '13Nov02 CKJ
'
'   If d.dosesperissueunit > 0 And (UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR") Then     '21Aug98 CFY Added
'         RxNodIssued! = L.RxNodIssued / d.dosesperissueunit                                                                                                                                                                                                                                                                                                                                                                         '21Aug98 CFY Added
'      Else                                                                                                                                                                                                                                                                                                                                                                                                                          '21Aug98 CFY Added
'         RxNodIssued! = L.RxNodIssued                                                                                                                                                                                                                                                                                                                                                                                               '21Aug98 CFY Added
'      End If                                                                                                                                                                                                                                                                                                                                                                                                                        '21Aug98 CFY Added
'
'   Do
'      For X = 1 To 6
'         Ldose!(X) = L.dose(X)
'         '01jUL96 ASC !!##**
'         'LTime$(x) = l.time(x)
'         LTime$(X) = L.Times(X)          '20Apr98 CKJ reinstated with correct element name
'      Next
''@@'      mins& = L.EqualInterval
''@@'      Select Case L.TimeUnits
''@@'         Case "day": mins& = mins& * 1440
''@@'         Case " wk": mins& = mins& * 10080
''@@'         Case " hr": mins& = mins& * 60
''@@'      End Select
''@@'      asciiday = Asc(L.days)
'      dow$ = ""
'      For X = 7 To 1 Step -1
'         If asciiday - (2 ^ X) >= 0 Then
'               asciiday = asciiday - 2 ^ X
'               dow$ = dow$ + LTrim$(Str$(X))
'            End If
'      Next
'      If dow$ = "" Then dow$ = "1234567"  '!!**
''@@'      DosesBetweenTimes False, Ldose!(), LTime$(), (mins&), dow$, dt, xp, doses!, cont&, thisdose!
'      dos.mint = cont&
'      minstodate dos
'      DateToString dos, dosedate$
'      parsedate (dosedate$), dosedate$, "5", valid
'      TimeToString dos, DoseTime$
'      parsetime (DoseTime$), DoseTime$, "2", valid
'      'IF SendToATC THEN 04May95  ASC       manual flag not set
''@@'      If SendtoATC And d.ATC = "Y" And (Asc(L.Flags) And &H1) = 0 Then
'            If cont& > 0 Then
'                  'If doses! > l.RxNodIssued Then  '17May95 CKJ/ASC removed startmins&>0 OR   '21Aug98 CFY Replaced
'                  If doses! > RxNodIssued! Then                                               '
'                        ''If Ipdlist.ChkBookout.Value = 1 Then '05May95 ASC
'                        If RptDispAction = 1 Then '@@'
'                              PutATC ATCfile$, DoseTime$, dosedate$, (thisdose!)
'                           End If
'                        dircode$ = L.dircode
'                        DosesForIssue! = DosesForIssue! + thisdose!
'                     End If
'               End If
''@@'         End If
'
'      '04May95 ASC
''@@'      If Ipdlist.TxtDateBefore.Text <> "ALL" And Not SendtoATC Then
'      'IF Ipdlist.TxtDateBefore.text <> "ALL" THEN
'      'IF DoLabel THEN 23Nov94 ASC
'            'IF cont& > 0 THEN
'            'popmessagecr "", "!" + STR$(ASC(l.flags)) + "! " + STR$((ASC(l.flags) AND &H1)) + "  " + STR$((ASC(l.flags) AND &H1) = 0) '!!** debug only
''@@'            If cont& > 0 And (Asc(L.Flags) And &H1) = 0 Then '2Dec94 CKJ and Manual flag not set
'                  'If doses! > l.RxNodIssued Then   '17May95 CKJ/ASC removed startmins&>0 OR   '21Aug98 CFY Replaced
'                  If doses! > RxNodIssued! Then                                                '21Aug98 CFY
'                        numDoses% = numDoses% + 1
'                        Select Case L.IssType
'                           Case "C"
'                              '13Nov02 CKJ At least one dose needed, so allocate batch number
'                              If DoCivas And DoWorklabel And Not blnBatchNumAllocated Then
'                                    PromptBatchNumber True
'                                    blnBatchNumAllocated = True
'                                 End If
'                              '--- 13Nov02
'
'                              If d.expiryminutes > 0 And DoLabel Then
''@@'                                    MakeExpiry k, (Ipdlist.txtPrepDate.Text), (Ipdlist.txtPrepTime.Text), expiry$
'                                 End If
'
'                              DosesForIssue! = DosesForIssue! + thisdose!
'                              'put expirydate only and batchnumber elements onto heap here                                                                     '21Oct02 TH Added
'                              If Len(Trim$(expiry$)) > 0 Then Heap 10, gPRNheapID, "ExpiryDateOnly", Trim$(Left$(Trim$(expiry$), Len(Trim$(expiry$)) - 5)), 0  '   "
'                              'If Trim$(GlobalManufBatchNum$) <> "" Then Heap 10, gPrnHeapID, "BatchNumber", Trim$(GlobalManufBatchNum$), 0                    '   "        '13Nov02 CKJ always write
'                              Heap 10, gPRNheapID, "BatchNumber", Trim$(GlobalManufBatchNum$), 0                                                               '   "        '   "
'                              If DoLabel Then DisplaytheLabel 1, 3, k, expiry$      '19Nov98 CFY Moved here from below
'                              'If PrintWorkL Then '18Nov94                                                                                                                                                                                '19Nov98 CFY removed
'                                    '02Dec96 ASC
'                                    'If DoWorklabel Then PrintWorkLabel TxTd(dispdata$ + "\patmed.ini", "Manufacturing", "Y", "FullWorksheet", 0) = "Y", NumofLabels, (ipdlist.TxtPrepDate.Text), (ipdlist.TxtPrepTime.Text), expiry$
'                                    'If DoWorklabel Then PrintWorkLabel NumofLabels, (Ipdlist.TxtPrepDate.Text), (Ipdlist.TxtPrepTime.Text), expiry$, formulafound '15Dec96 ASC  added formulafound                                       '19Nov98 CFY removed
'                               '     PrintWorkL = False                                                                                                                                                                                   '19Nov98 CFY removed
'                               '  End If                                                                                                                                                                                                  '19Nov98 CFY removed
'                              'If DoLabel Then DisplayTheLabel 1, 3, k, expiry$     '19Nov98 CFY
'                              If Dobaglabel Then BagLabelReqd = True  '7Jun95 CKJ moved PrintPatientLabel outside the loop
'
'                           Case Else  'ASC 20Nov94
'                              'IF d.DosesPerIssueUnit <> 0 AND (ASC(l.flags) AND &H2) > 0 THEN '23Nov94 ASC 24Nov94 CKJ
'                              '##
''@@'                              If d.dosesperissueunit <> 0 And (Asc(L.Flags) And &H2) = 0 Then '23Nov94 ASC 24Nov94 CKJ '7Jan95 CKJ Changed > to =
''@@'                                    DosesBetweenTimes True, Ldose!(), LTime$(), (mins&), dow$, dt, xp, doses!, cont&, thisdose!
'                                    If d.expiryminutes > 0 And DoLabel Then
'                                          MakeExpiry k, WorkingDate$, WorkingTime$, expiry$
'                                       End If
'                                    If d.dosesperissueunit > 0 Then 'ASC 07Nov94
'                                          '15Aug96 EAC - should above line be
'                                          'QTY! = (doses! / d.DosesPerIssueUnit) - l.RxNodIssued  '21Aug98 CFY Replaced
'                                          Qty! = dp!(doses! - RxNodIssued!)                       '
'                                          '---
'                                       Else
'                                          Qty! = 1
'                                       End If
'                                    DosesForIssue! = Qty!
'                                    'put expirydate only and batchnumber elements onto heap here                                                                     '21Oct02 TH Added
'                                    If Len(Trim$(expiry$)) > 0 Then Heap 10, gPRNheapID, "ExpiryDateOnly", Trim$(Left$(Trim$(expiry$), Len(Trim$(expiry$)) - 5)), 0  '   "
'                                    'If Trim$(GlobalManufBatchNum$) <> "" Then Heap 10, gPrnHeapID, "BatchNumber", Trim$(GlobalManufBatchNum$), 0                    '   "      13Nov02 CKJ Not needed until manufacturing of non-civas items is enabled in prescription manager
'                                    If Dobaglabel Then PrintPatientLabel
'                                    If DoLabel Then DisplaytheLabel 1, 3, k, expiry$
'                                    cont& = 0
''@@'                                 End If
'                           End Select
'                     End If
''@@'               End If
''@@'         End If
'   Loop Until cont& = 0
'
'   '28Jul99 AE Added block to print extra civas / manufacturing labels from prescription manager
'   'If DoLabel Then                     '13Nov02 CKJ Removed
'   If DoLabel And numDoses > 0 Then     '   "        Don't print unless at least one dose has been found
''@@'         getformula found
'         If found Then
''@@'               If GetField(FormulaTable!DosingUnits) Then    'Non-batch manufactured product
'                     ExtraLabelsBatch = Val(TxtD(dispdata$ + "\patmed.ini", "", "0", "SpareCIVASlabelsBatch", 0))
'                     ExtraLabelsDose = Val(TxtD(dispdata$ + "\patmed.ini", "", "B", "SpareCIVASlabelsDose", 0))
'                     ExtraLabels = (numDoses * ExtraLabelsDose) + ExtraLabelsBatch
'                     If ExtraLabels > 0 Then DisplaytheLabel ExtraLabels, 3, k, expiry$
''@@'                  End If
'            End If
'
'      End If
''@@'   CloseFormulaDatabase
'   '-----
'
'   If DoWorklabel And numDoses% > 0 Then                                                                                                  '19Nov98 CFY Added
'         'PrintWorkLabel NumDoses%, (Ipdlist.TxtPrepDate.Text), (Ipdlist.TxtPrepTime.Text), expiry$, formulafound, PatsPerSheet%, layout$  '       "  '24Feb99 SF replaced
'         'PrintWorkLabel frmAction, NumDoses%, (Ipdlist.TxtPrepDate.Text), (Ipdlist.TxtPrepTime.Text), expiry$, formulafound, PatsPerSheet%, layout$, escd%   '24Feb99 SF  '01Jun02 All/CKJ
'         'PrintWorkLabel frmAction, NumDoses%, (Ipdlist.TxtPrepDate.Text), (Ipdlist.TxtPrepTime.Text), expiry$, 0, PatsPerSheet%, layout$, escd%              '24Feb99 SF  '01Jun02 All/CKJ formulafound never used
''@@'         PrintWorkLabel frmAction, numDoses%, (Ipdlist.TxtPrepDate.Text), (Ipdlist.TxtPrepTime.Text), expiry$, 0, PatsPerSheet%, layout$, escd%, o_blnFormulaHandled       '13Nov02 CKJ Added param. Set if a formula has been handled internally
'      End If
'
'   If BagLabelReqd Then PrintPatientLabel    ' 7Jun95 CKJ
'
'End Sub

'@@'AXE
''Sub CallPickList()
'''14Sep98 CFY Added
'''Description: Generates a report of all items issued between a specified time period and a
'''             specified Rx type.
'''25Oct99 CFY Additional condition added to filter cancelled transactions.
'''02May00 CFY Displays error lines on report if the product cannot be found for a particular transaction
'''            Also changed formatting of qty to display only 2dp rather than 3dp.
''
''Dim file$, yyyymm$, Tmpfile$, OutTxt$
''Dim fil%, TmpFileNo%, ItemsFound%, i%
''Dim pointer&, recno&
''Dim t As transaction
''Dim startdate As DateAndTime, StopDate As DateAndTime, TransDate As DateAndTime
''Dim RTFTxt$
''Dim PgHdr$, PgItem$, PgEnd$, valid As Integer, yyyymmddStart$, yyyymmddStop$, yyyymmddTrans$, lngFound As Long       '01Jun02 All/CKJ  was found%
''
''   ReDim NSVCode(0) As String
''   ReDim Qtys(0) As Single
''
''   'Check RTF file exists. If so open and split the RTF into its componants
''   If fileexists(dispdata$ & "\picklist.rtf") Then
''         GetTextFile dispdata$ & "\picklist.rtf", RTFTxt$, 0
''         SplitFile RTFTxt$, PgHdr$, PgItem$, PgEnd$
''      Else
''         popmessagecr "!ASCribe", "Error. Cannot find file " & dispdata$ & "\picklist.rtf"
''         Exit Sub             '<---- WAY OUT!!!
''      End If
''
''   'Build a list of issue types that are to be printed
''   BuildIssueTypes
''
''   'Work out which transaction file needs to be read
''   parsedate (Ipdlist.TxtPrepDate.Text), yyyymm$, "yyyymm", valid
''   file$ = transpath$ & "\tl" & yyyymm$
''
''   parsedate (Ipdlist.TxtPrepDate.Text), yyyymmddStart$, "yyyymmdd", valid
''   parsedate (Ipdlist.TxtDateBefore.Text), yyyymmddStop$, "yyyymmdd", valid
''   '!!** Check validity of dates
''
''   If fileexists(file$) Then
''         Screen.MousePointer = HOURGLASS
''
''         'Make local disk file to build the RTF image
''         MakeLocalFile Tmpfile$
''         TmpFileNo% = FreeFile
''         Open Tmpfile$ For Binary Access Write Lock Read Write As #TmpFileNo
''
''         'Parse and print the page header
''         Put TmpFileNo%, , PgHdr$
''
''         'Open transaction file
''         fil = FreeFile
'''@@'         openrandomfile file$, Len(t), fil
'''@@'         GetPointerSQL file$, pointer&, False
''
''         For recno& = 2 To pointer&
'''@@'            GetRecordNL r, recno&, fil, Len(t)
''            LSet t = r
''            parsedate t.date, yyyymmddTrans$, "yyyymmdd", valid
''            Select Case yyyymmddTrans$
''               Case yyyymmddStart$ To yyyymmddStop$
''                  'If InStr(IssType$, t.labeltype) Then                                '25Oct99 CFY Replaced
''                  If (InStr(IssType$, t.labeltype)) And (trimz(t.kind) <> "0") Then    '         "
''                        For i = 1 To ItemsFound%
''                           If NSVCode(i) = t.SisCode Then Exit For
''                        Next
''                        If i > ItemsFound% Then
''                              ItemsFound = ItemsFound + 1
''                              ReDim Preserve NSVCode(ItemsFound)
''                              NSVCode(ItemsFound) = t.SisCode
''                              ReDim Preserve Qtys(ItemsFound)
''                              Qtys(ItemsFound) = 0
''                           End If
''                        Qtys(i) = Qtys(i) + Val(t.Qty)
''                     End If
''               End Select
''         Next
''
''         For i = 1 To ItemsFound
'''@@'            cleardrug d
''            d.SisCode = NSVCode(i)
''            getdrug d, 0, lngFound, False    '01Jun02 All/CKJ
''
''            'If found% > 0 Then                                                        '02May00 CFY Removed
''            '      FillHeapDrugInfo gPrnHeapID, d, 0                                   '         "
''            '      Heap 10, gPrnHeapID, "tQty", Format$(Qtys(i), "0.0##"), 0           '         "
''            '   End If                                                                 '         "
''
''            If lngFound = 0 Then                                                                   '02May00 CFY Added    '01Jun02 All/CKJ
'''@@'                  cleardrug d                                                                      '         "
''                  d.SisCode = NSVCode(i)                                                           '         "
''                  d.Description = "!!! PRODUCT NOT FOUND (NSVCODE : " & d.SisCode & ") !!!"        '         "
''               End If                                                                              '         "
''
''            Heap 10, gPRNheapID, "tQty", Format$(Qtys(i), "0.0#"), 0                               '02May00 CFY Added
''            FillHeapDrugInfo gPRNheapID, d, 0                                                      '         "
''
''            OutTxt$ = PgItem$
''            ParseItems gPRNheapID, OutTxt$, 0
''            Put TmpFileNo%, , OutTxt$
''         Next
''
''         Put TmpFileNo%, , PgEnd$
''         Close TmpFileNo%
''
''         Close fil
''
''         If ItemsFound Then
''               ParseThenPrint "IssuedList", Tmpfile$, 1, 0
''            Else
''               popmessagecr "!", "No items found for printing"
''            End If
''
''         Kill Tmpfile$
''
''         Screen.MousePointer = STDCURSOR
''      Else
''         popmessagecr "!ASCribe", "Error. Cannot find transaction file " & file$
''      End If
''
''   Erase NSVCode
''   Erase Qtys
''
''End Sub

'24May11 CKJ Not used
'Sub CheckRxStatus(ForAction%)
''@@'to be checked - was a dummy proc in V8, does it need doing fully in V10?
'
'Dim asciiday  As Integer, x As Integer, approved As Integer
'
'   ForAction% = True
'   asciiday = Asc(l.RxStatus)
'   For x = 7 To 0 Step -1
'      approved% = False
'      If asciiday - (2 ^ x) >= 0 Then
'            asciiday = asciiday - 2 ^ x
'            approved% = True
'         End If
'      If (approved% And IPDList.CmbSeenBy(x + 1).ListIndex = 1) Or (Not approved% And IPDList.CmbSeenBy(x + 1).ListIndex = 0) Then
'            ForAction% = False
'            Exit For
'         End If
'   Next
'
'End Sub

Sub foursigfigs(X!)
      If X! > 999.4 Then
            X! = Int(X! + 0.5)
            Exit Sub
         End If
      If X! > 99.4 Then
            X! = Int(X! * 10 + 0.5) / 10
            Exit Sub
         End If
      If X! > 9.4 Then
            X! = Int(X! * 100 + 0.5) / 100
            Exit Sub
         End If
      If X! > 0.9999 Then
            X! = Int(X! * 1000 + 0.5) / 1000
            Exit Sub
         End If

End Sub

Sub printdetails(TextOnly, ward$)
'-----------------------------------------------------------------------------
'  issuedesc
'     I
'     Cy
'    ?Cy
' ?CyIV?
'
'20Apr94 CKJ If TextOnly then print l.text instead
'17May95 CKJ Incorrect use of idlen, tabDrug and lenptdata can cause
'            space$(<negative number>)
'            Disabled this completely, all lines marked with ''
'            !!** needs reinstating correctly.
'30Jun95 CKJ Added GPexp to pt line if valid (King's request)
'12Feb96 EAC Print the stocklevel expected on ward and topup quantity
'15Aug96 EAC print the correct units for each drug in patient costing
'15Apr98 ASC/CKJ issue units changed to printformV when printing
'20Apr98 CKJ reinstated Ltime$(x) with correct element name
'02Jul98 CFY Should now print each drug on a separate line.
'05Jul98 ASC checked units and calculation when printing topup sheets
'03Aug98 EAC corrected logic for when rtf file is missing.
'21Aug98 CFY changed above mod
'21Aug98 AJK added ward$ parameter
'-----------------------------------------------------------------------------
ReDim wline$(5)
'12Feb96 EAC - mods to allow expected qty on wards to be printed
Dim supplydate As DateAndTime
Dim startdate As DateAndTime
Dim topupdate As DateAndTime
'---
Dim TxtStart%
Dim TxtStop%
Dim dob$, age$, ageval!, wardexp$, consexp$, GPexp$, desc$, dosedate$, DrugCost!, Numoflines As Integer, X As Integer, mins&, asciiday As Integer, dow$, dat$, temp$ '01Jun02 All/CKJ
Dim valid As Integer, doses!, thisdose!, ExpectedQty!, topupqty!, topupqtystr$  '01Jun02 All/CKJ

 ''idlen = LEN(issuedesc$)      ' 1 to 7 chars
 ''tabDrug = 5                  ' tab to column for drug description
                                '08May95 from 33 to 5 for start and stop dates and Costing info

   If fil = 0 Then              ' setup printer
         PrintError = False                                                   '30Jul98 CFY Added
         If Not fileexists(dispdata$ & "\ipdlist.rtf") Then                   '         "
               popmessagecr "!EMIS Health", "File 'ipdlist.rtf' not found."       '         "
               PrintError = True                                              '         "
            Else                                                              '         "
               GetTextFile dispdata$ & "\ipdlist.rtf", RTFTxt$, 0             '         "
            End If                                                            '         "
                                                                              '         "
         If Not PrintError Then              '03Aug98 EAC Added
               MakeLocalFile SpoolFile$
               fil = FreeFile
               Open SpoolFile$ For Output As fil
      
               TxtStart% = InStr(RTFTxt$, "[data]") - 1                             '30Jul98 CFY Added
               Print #fil, Left$(RTFTxt$, TxtStart%)                                '30Jul98 CFY Added
            End If

         'If printout Then                                                    '30Jul98 CFY Removed
         '      Print #fil, esc$; "@";               ' reset                  '         "
         '      Print #fil, Chr$(15);                ' condensed              '         "
         '      Print #fil, esc$; "M";               ' elite                  '         "
         '      Print #fil, esc$; "l"; Chr$(margin); ' left margin            '         "
         '   End If
         '         "
      ElseIf newward And PgFeedWards% Then                      ' form feed
         'If printout Then Print #fil, Chr$(12); ' form feed                  '30Jul98 CFY Replaced
         'Totals here
         If Not PrintError Then Print #fil, " \page "                         '    "
      End If

   If PrintError Then Exit Sub              '<----- WAY OUT!!                 '30Jul98 CFY Added
   
   If newward Then             ' print full header
         page = 1
         printheader True, ward$
         newward = False
      End If

   If firstdrug Then            ' print patient details
         firstdrug = False
         If firstpatient Then
               firstpatient = False
            Else
               If lins >= pagelen - 3 Then   ' start new page
                     'If printout Then Print #fil, Chr$(12);   ' form feed   '30Jul98 CFY Replaced
                     If printout Then Print #fil, " \page "                  '    "
                     page = page + 1
                     printheader True, ward$
                  Else
                     Print #fil, " \par "     ' blank line between entries       '+1
                     lins = lins + 1
                  End If
            End If

         'PRINT #fil, " "; pid.caseno; " "; patientname$; " "; pid.cons; " "; pid.dob
'@@'         Expandpid pid, dob$, age$, ageval!, wardexp$, consexp$, GPexp$     '12May95 CKJ added
         Print #fil, " "; pid.caseno; " "; PatientName$; "  "; dob$; "  ("; consexp$; ")";
         If InStr(GPexp$, "< Invalid") = 0 And GPexp$ <> "" Then     '30Jun95 CKJ Added
               Print #fil, "  ("; GPexp$; ")";
            End If
         Print #fil, " \par "                                                    '+2
         lins = lins + 1
         
       ''lenptdata = LEN(patientname$) + 12  ' len(sp + caseno + sp + name)

       ''IF lenptdata >= tabDrug - idlen THEN
       ''      PRINT #fil,
       ''      lins = lins + 1
       ''      PRINT #fil, SPACE$(tabDrug - idlen);
       ''   ELSE
       ''      PRINT #fil, SPACE$(tabDrug - idlen - lenptdata);
       ''   END IF
      Else
         If lins >= pagelen Then       ' start new page
               'If printout Then Print #fil, Chr$(12);   ' form feed   '30Jul98 CFY Replaced
               If printout Then Print #fil, " \page "                  '
               page = page + 1
               printheader True, ward$       ' short header
              'PRINT #fil, pid.caseno; " "; patientname$; " "; pid.cons; " "; pid.dob; "  (Continued...)"
               Print #fil, pid.caseno; " "; PatientName$; "  "; dob$; "  ("; consexp$; ")  (Continued...)"
               Print #fil, " \par "                                               '+1
               lins = lins + 1
            End If
       ''PRINT #fil, SPACE$(tabDrug - idlen);
      End If

   If TextOnly Then                  '20Apr94 CKJ Added
         desc$ = Left$(L.text, 56)   '56 chars max
         plingparse desc$, Chr$(30)
         'PRINT #fil, issuedesc$; "  "; desc$  15May95 ASC/CKJ
       ''PRINT #fil, issuedesc$; "  "; desc$, " "; l.Dircode
         Print #fil, issuedesc$; Space$(8 - Len(issuedesc$)); desc$, " "; L.dircode  '+1
         
      Else
         '08May95 ASC ----                            '17May95 CKJ moved inside IF/ELSE
         dos.mint = L.RxStartDate   '15May95 ASC
         minstodate dos
         DateToString dos, dosedate$
         Print #fil, dosedate$; " ";
         dos.mint = L.StopDate
         minstodate dos
         DateToString dos, dosedate$
         Print #fil, dosedate$; " ";
         '----------------

         desc$ = d.LabelDescription ' 56 chars max ' desc$ = d.Description XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
       ''PRINT #fil, issuedesc$; "  "; desc$, " "; l.Dircode; "   ";
         Print #fil, issuedesc$; Space$(8 - Len(issuedesc$)); desc$, " "; L.dircode; "   ";
         '22Nov94 ASC only checks if there is a topupqty if not ATC
         'IF issuedesc$ = "ATC" THEN
'@@'         If Ipdlist.TxtDateBefore.Text <> "ALL" Then
               If Patcost Then '06May95
                     DrugCost! = (((DosesForIssue! / Val(d.convfact)) / 100) * Val(d.cost))
                     If d.dosesperissueunit <> 0 Then
                           DrugCost! = (DrugCost! / d.dosesperissueunit)
                        End If
                     If OnCostReqd Then
                           deflines plvl$("PPOnCost"), wline$(), ",", 1, Numoflines  '1.5,1.8,ODL
                           If InStr(wline$(3), L.IssType) Then
                                 DrugCost! = DrugCost! * Val(wline$(2))
                              Else
                                 DrugCost! = DrugCost! * Val(wline$(1))
                              End If
                           'IF INSTR(plvl$("PPOnCost1Types"), l.isstype) THEN
                           '      DrugCost! = DrugCost! * VAL(plvl$("PPOnCost1"))
                           '   ELSE
                           '      DrugCost! = DrugCost! * VAL(plvl$("PPOnCost2"))
                           '   END IF
                        End If
                     PatientCost! = PatientCost! + DrugCost!
                     '15Aug96 EAC - print the correct units for each drug
                     'Print #fil, Left$(Str$(DosesForIssue!) + Space$(6), 6) + d.DosingUnits;
                     Print #fil, Left$(Str$(DosesForIssue!) + Space$(6), 6) + d.PrintformV;
                     '---
                     Print #fil, Format(dp!(DrugCost!), "###.##")               '+1
                     'PRINT #fil, USING "####.##";
                  Else
'@@'
''                     If Asc(L.Flags) And &H1 Then         '24Nov94 CKJ
''                           Print #fil, "        MANUAL"
''                        ElseIf d.dosesperissueunit = 0 Then
''                           Print #fil, "        WHOLE PACKS"
''                        ElseIf Asc(L.Flags) And &H2 Then
''                           Print #fil, "        PRN"
''                        Else
                           '12Feb96 EAC
                           For X = 1 To 6
                              Ldose!(X) = L.dose(X)
                              'LTime$(x) = l.time(x)
                              '01julASC !!##**
                              LTime$(X) = L.Times(X)                  '20Apr98 CKJ reinstated with correct element name
                           Next
'@@'                           Select Case L.TimeUnits
'@@'                              Case "day": mins& = mins& * 1440
'@@'                              Case " wk": mins& = mins& * 10080
'@@'                              Case " hr": mins& = mins& * 60
'@@'                           End Select
'@@'                           asciiday = Asc(L.days)
                           dow$ = ""
                           For X = 7 To 1 Step -1
                              If asciiday - (2 ^ X) >= 0 Then
                                    asciiday = asciiday - 2 ^ X
                                    dow$ = dow$ + LTrim$(Str$(X))
                                 End If
                           Next
                           If dow$ = "" Then dow$ = "1234567"  '!!**
                           'read Precription start date from label
                           startdate.mint = L.RxStartDate
                           minstodate startdate
                           'read the date that the topup will be supplied on
'@@'                           dat$ = Ipdlist.txtPrepDate.Text
                           parsedate dat$, temp$, "1", valid
                           StringToDate temp$, supplydate
                           'read the time the topup will be supplied at
'@@'                           dat$ = Ipdlist.txtPrepTime.Text
                           If Trim$(dat$) <> "" Then
                                 parsetime dat$, temp$, "2", valid
                                 supplydate.Hrs = Val(Mid$(temp$, 1, 2))
                                 supplydate.min = Val(Mid$(temp$, 3, 2))
                              End If
                           datetomins supplydate
                           'calculate the number of doses between RxStartDate and Supply
'@@'                           DosesBetweenTimes True, Ldose!(), LTime$(), 0, dow$, startdate, supplydate, doses!, 0, thisdose!
                           'calculate the expected quantity left on the ward
                           '05Jul98 ASC
                           'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then                      '05Jul98 ASC     '06Jul98 CFY
                           If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Or L.IssType = "C" Then    '05Jul98 ASC     '06Jul98 CFY
                                 ExpectedQty! = (L.RxNodIssued / d.dosesperissueunit) - doses!                                                                                                                                                                                                                                                                                                                                                                                                                                                '    "
                              Else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          '    "
                                 'ExpectedQty! = dp!(l.RxNodIssued / d.dosesperissueunit) - doses!                                                                                                                                                                                                                                                                                                                                                                                                                             '    "           '06Jul98 CFY
                                 ExpectedQty! = L.RxNodIssued - doses!                                                                                                                                                                                                                                                                                                                                                                                                                                                                      '06Jul98 CFY
                              End If                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        '    "

                           'Now work out topup quantity for until specified date
                           'read the date that the topup will last until
'@@'                           dat$ = Ipdlist.TxtDateBefore.Text
                           parsedate dat$, temp$, "1", valid
                           StringToDate temp$, topupdate
                           'read the time that the topup will last until
'@@'                           dat$ = Ipdlist.TxtTimeBefore.Text
                           If Trim$(dat$) <> "" Then
                                 parsetime dat$, temp$, "2", valid
                                 topupdate.Hrs = Val(Mid$(temp$, 1, 2))
                                 topupdate.min = Val(Mid$(temp$, 3, 2))
                              End If
                           datetomins topupdate
                           'calculate the number of doses required between the supply date and the end of the topup period
'@@'                           DosesBetweenTimes True, Ldose!(), LTime$(), 0, dow$, supplydate, topupdate, doses!, 0, thisdose!
                           'topup quantity supplied will be the number of doses needed minus the quantity left on the ward
                           If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then       '05Jul98 ASC
                                 topupqty! = doses! - ExpectedQty!                                                                                                                                                                                                                                                                                                                                                                                                                                                            '06Jul98 CFY
                              Else                                                                                                                                                                                                                                                                                                                                                                                           '06Jul98 CFY
                                 topupqty! = (doses! / d.dosesperissueunit) - ExpectedQty!                                                                                                                                                                                                                                                                                                                                   '06Jul98 CFY
                              End If                                                                                                                                                                                                                                                                                                                                                                                         '06Jul98 CFY

                           If topupqty! < 0 Then: topupqty! = 0
                           Print #fil, "  "; ExpectedQty!;
                           'Print #fil, d.DosingUnits;        '16Apr98 ASC/CKJ
                           '05Jul98 ASC
'@@'WTF?                           If Left$(d.Description, 5) = "ERYTH" Then MsgBox ""
                           'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then    '05Jul98 ASC
                           If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or (UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR") Or L.IssType = "C" Then
                                 Print #fil, d.PrintformV;          '      "
                              Else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         '    "
                                 Print #fil, d.DosingUnits;                                                                                                                                                                                                                                                                                                                                                                                                                                                                '    "
                              End If                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       '    "
                           Print #fil, "   "; topupqty!;
                           'Print #fil, d.DosingUnits         '      "
                           'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then    '05Jul98 ASC
                           If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or (UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR") Or L.IssType = "C" Then
                                 Print #fil, d.PrintformV;          '      "
                              Else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         '    "
                                 Print #fil, d.DosingUnits;                                                                                                                                                                                                                                                                                                                                                                                                                                                                '    "
                              End If                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       '    "
                           
                           '---
                           '*********
                           totaltopupqty! = totaltopupqty! + topupqty!
                           totalexpectedqty! = totalexpectedqty! + ExpectedQty!
                        End If                                                  '+1
                  End If
'@@'            Else
               If L.topupqty > 0 And InStr("IS", L.IssType) > 0 Then '24Nov94
                     topupqty! = L.topupqty
                     foursigfigs (topupqty!)
                     topupqtystr$ = Left$(LTrim$(Str$(topupqty!)) + "     ", 5)
                     Print #fil, topupqty!;
                     '05Jul98 ASC
                     'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then    '05Jul98 ASC
                     If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or (UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR") Or L.IssType = "C" Then
                           Print #fil, d.PrintformV                                                                                                                                                                                                                                                                                                  '    "
                        Else                                                                                                                                                                                                                                                                                                                                                                                                   '    "
                           Print #fil, d.DosingUnits                                  '+1
                        End If                                                                                                                                                                                                                                                                                                                                                                                                 '    "
                  Else
                     'Print #fil,                            '02Jul98 CFY Added                    '+1
                  End If
'@@'            End If
'@@'      End If
   Print #fil, " \par "                                                '+1
   lins = lins + 1

End Sub

Private Sub printdrgqty()
'31Jul98 TH Prints line to #fil showing drug totals
'13Aug98 EAC if fil = 0 assume nothing has been printed and exit sub
'08Sep98 CFY Made change to quantity line to now read total issue quantity

   If fil = 0 Then Exit Sub         '13Aug98 EAC

   drugdesc$ = Trim$(d.LabelDescription)   'drugdesc$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
   Print #fil, " \par ";
   Print #fil, drugdesc$; " \tab "; "Total Expected Quantity : "; totalexpectedqty!; " \tab "; "Total TopUp Quantity : "; totaltopupqty!; " \tab "; "Total Issue Quantity : "; totaltopupqty! + totalexpectedqty!; " \par "; '
   grandtotalexpectedqty! = grandtotalexpectedqty! + totalexpectedqty!
   totalexpectedqty! = 0
   grandtotaltopupqty! = grandtotaltopupqty! + totaltopupqty!
   totaltopupqty! = 0

End Sub

Sub printheader(full%, ward$)
'-----------------------------------------------------------------------------
'  Print page header
'
'  Full = True   for first page only
'21Feb94 ASC Added headermessage$ for use in conjunction with ATC file and
'            macros etc.
' 4May94 CKJ
'12Feb96 EAC Print the stocklevel expected on ward and topup quantity
'-----------------------------------------------------------------------------
'SHARED tday$, now$, WDexpand$, DoCivas, docyto, excIVcyto, headermessage$

Dim doneone As Integer, count As Integer         '01Jun02 All/CKJ

   
   lins = 7
   Print #fil, " \par "                                                           '1
   Print #fil, " Printed on "; tday$; " at "; wnow$; Tab(8); ward$; Tab(8); Left$(headermessage$ + Space$(40), 40); " "; WDexpand$;
'@@'   If Ipdlist.TxtDateBefore.Text <> "ALL" Then
'@@'         Print #fil, " For Supply until " + Ipdlist.TxtDateBefore.Text + " at " + Ipdlist.TxtTimeBefore.Text;
'@@'      End If
   If Not full Then Print #fil, " (Continued)";
   Print #fil, Tab(135); "Page"; page                                     '2
   Print #fil, " \par "                                                  '3
   If full Then
         Print #fil, " \par "
         If Patcost Then  '08May95 ASC                                    '+1
               Print #fil, Space$(60) + "PATIENT MEDICATION COSTING";
            Else
               Print #fil, Tab(12); "Top up date "; String$(20, "_");
               Print #fil, Tab(50); "Checked by  "; String$(20, "_");
            End If

         Print #fil, Tab(97); "Selected issue type"; plural$(Len(IssType$)); ";"  '+2
         Print #fil, Tab(97);
         doneone = False                                      '9Dec94 CKJ
         For count = 1 To UBound(IssTyp$)
               If Len(Trim(IssTyp$(count))) Then
                     If doneone Then Print #fil, ", ";
                     Print #fil, IssTyp$(count);
                     doneone = True
                  End If
         Next
'@@'         If Ipdlist.TxtDrugCode.Text <> "" Then Print #fil, " for drug "; Ipdlist.TxtDrugCode.Text;
         Print #fil, " \par "                                                     '+3

         If Not Patcost Then
               Print #fil, Tab(12); "Filled by   "; String$(20, "_");
               Print #fil, Tab(50); "Issued by   "; String$(20, "_");
            End If

         If DoCivas And Not docyto Then
               If excIVcyto Then
                     Print #fil, Tab(97); "(Excluding IV cytotoxics)";
                  Else
                     Print #fil, Tab(97); "(Including IV cytotoxics)";
                  End If
            End If
         Print #fil, " \par "                                                     '+4
         Print #fil, " \par "                                                     '+5
         lins = lins + 5
      End If
   Print #fil,                                                            '4
   Print #fil, " Case"; Space$(20); "Issue"; Tab(118);
   If Patcost Then
        If OnCostReqd Then Print #fil, Tab(129); "Total";  '25May95 CKJ Added
        Print #fil, " \par "
     Else
        '12Feb96 EAC
        'PRINT #fil, "Top-up      Required"                                '5
        Print #fil, "Expected   Top-up"                                '5
        '---
     End If
   Print #fil, " \par "
   Print #fil, " Number     Patient name"; Tab(26); "Type  Drug description";
   Print #fil, Tab(100); "Directions        Quantity   ";
   If Patcost Then
         Print #fil, "Cost"
      Else
         Print #fil, "Quantity   Signed"
      End If                                                              '6
   Print #fil, " \par "
   Print #fil, String$(144, "-")
   Print #fil, " \par "
                  
End Sub

Sub PrintPatientLabel()

Static Lastpatid$

   If pid.caseno <> Lastpatid$ Then
'@@'         patlabel k, pid, lblprn, 2, 0
      End If

   Lastpatid$ = pid.caseno

End Sub

Sub PrintTotalCost()

   'If fil > 0 Then     'spool file opened                                 '30Jul98 CFY Replaced
   If fil > 0 And Not PrintError Then                                      '      "
         Print #fil, " \par "                                             '+1
         Print #fil, Space$(109) + "Patient Total :";
         'PRINT #fil, USING "#####.##"; PatientCost!                       '+2
         Print #fil, Format(PatientCost!, "#####.##")                      '+2
         Print #fil, String$(144, "-")                                    '+3
         lins = lins + 3
         PatientCost! = 0
      End If

End Sub

Sub PutATC(ATCfile$, DoseTime$, dosedate$, nod%)


Static ATCchan
Static LastATCfile$

Dim X As Integer, ATCptr&     '01Jun02 All/CKJ

   If LastATCfile$ <> ATCfile$ And ATCchan <> 0 Then Close ATCchan: ATCchan = 0
   
   For X = 1 To nod%
      If fileexists(ATCfile$ + ".dat") Then
            GetPointerSQL ATCfile$ + ".PTR", ATCptr&, True
         Else
            ATCptr& = 1
            GetPointerSQL ATCfile$ + ".PTR", (ATCptr&), 2
         End If
      If ATCchan = 0 Then
'@@'            openrandomfile ATCfile$ + ".dat", Len(ATC), ATCchan
         End If
      ATC.name = PatientName$
      ATC.patid = pid.caseno
      ATC.PatLoc = pid.ward
      ATC.drugcode = d.ATCCode
      ATC.date = dosedate$ '"123093"'American Format
      ATC.Time = DoseTime$ '"1400"
      ATC.Dosage = "01"
      ATC.crlf = Chr$(13) + Chr$(10)

      Put ATCchan, ATCptr&, ATC
   Next
End Sub

Sub BuildIssueTypes()
'14Sep98 CFY Written
'Description: Builds a list of issue types that have been selected from the ipdlist form.

   IssType$ = ""
   
'@@'
''   If Ipdlist.ChkType(1).Value = 1 Then
''         IssType$ = IssType$ + "I"
''         IssTyp$(1) = "In-pt"
''      End If
''
''   If Ipdlist.ChkType(2).Value = 1 Then
''         IssType$ = IssType$ + "O"
''         IssTyp$(2) = "Out-pt"
''      End If
''
''   If Ipdlist.ChkType(3).Value = 1 Then
''         IssType$ = IssType$ + "D"
''         IssTyp$(3) = "Disch"
''      End If
''
''   If Ipdlist.ChkType(4).Value = 1 Then
''         IssType$ = IssType$ + "L"
''         IssTyp$(4) = "Leave"
''      End If
''
''   If Ipdlist.ChkType(5).Value = 1 Then
''         IssType$ = IssType$ + "W"
''         IssTyp$(5) = "Stock"
''      End If
''
''   If Ipdlist.ChkType(6).Value = 1 Then
''         IssType$ = IssType$ + "C"
''         IssTyp$(6) = "CIVAS"
''         DoCivas = True
''      End If
''
''   If Ipdlist.ChkType(8).Value = 1 Then
''         IssType$ = IssType$ + "C"
''         IssTyp$(8) = "Cyto"
''         docyto = True
''      End If
''
''   If Ipdlist.ChkType(10).Value = 1 Then
''         IssType$ = IssType$ + "S"
''         IssTyp$(10) = "Self Med."
''      End If
''
''   If Ipdlist.ChkType(11).Value = 1 Then
''         IssType$ = IssType$ + "T"
''         IssTyp$(11) = "PN"
''      End If

End Sub

'24May11 CKJ Removed as not used
'Sub CallIPDlist(frmIPD As Form)
''04Nov96 KR Added ucase around comparison of case number.
''           Replaced brackets so that they were correct
''03Jun97 KR Now get wards from supplier file.  Use SelectWards procedure to display ward list.
''18Jun97 KR Fixed spelling mistake in variable name: DosesForIs2sue!
''03Jun97 KR Fixed subscript out of range error - ward array was not being filled!
''           As now password protected, set the userid when writing to the translog.
''31Oct97 EAC - use the correct array to pull ward codes from
''20Jan98 CKJ Added k.escd=True if pt not found, otherwise gauge control fails
''20Jan98 CFY Added code for handling blister packs
''21Jan98 CKJ Made blister packing only happen if selected by the user
''17Feb98 CFY Changed code which determined the start and end times for blister packing
''02Mar98 CFY Added extra conditions when calling 'PrintDetails' when Blister packing.
''            Now when blister packing is selected, only the drugs which have been packed
''            are shown on the report.
''05Mar98 CFY New parameter added to shellsort
''16Mar98 CFY Now reads ini file setting in patmed.ini to determine whether or not an editable
''            preview of the blister pack should be shown.
''17Mar98 CFY Now takes value of the Book-Out Check box and passes to the blister routines
''            to indicate whether or not to issue stock.
''            Extra condition added to stop drugs being booked out by the ipdlist routines when
''            the blister check box is checked and the book out check box is checked. This is due to
''            the fact that the blister routines handle the booking out of blister packed drugs themselves
''            Also added assignment of pid.caseno to the global var gTlogCaseno$ so that the translog can
''            write the caseno rather than the pid.recno to the log.
''03Aug98 TH  Added line to file/printout totalling drugs for each ward and giving a grand total
''            whenever a specific drug is entered.
''03Aug98 TH  Rft printing now by contexts (hedit14)
''21Aug98 CFY Corrected quantity calculations that are written to the log.
''02Sep98 TH  Previewedit option on blisterpack printing now from chkbox not ini setting
''19Nov98 CFY Added call to PromptForWrkSht if doing a CIVAS item.
''            Now also does an additional call to PrintManWorksheet at end of process incase
''            there are still patients on the heap waiting to be parsed and printed.
''26Jan99 CFY Corrected mod of 03Aug98
''24Feb99 SF  traps for the user cancelling out at various times
''15Mar99 SF  made mods for repeat dispesning
''15Mar99 SF  now if no patients on a ward displays that ward's code and name
''01Apr99 SF  bumped up number of patients handled from 100 to 200 repeat dispensing
''07Apr99 SF  changed the redim of array patsort$ from 100 to 200 for repeat dispensing
''26Apr99 SF  removed hourglass when warning user that there are no patients on a ward
''14May99 CFY Now Correctly parses all standard header information when doing a screen preview.
''04Jun99 CFY Now generates the batch number fo CIVAS products before generating the labels
''            so that the number can be prointed on the label.
''07Jun99 SF  now opens/closes "patid.mdb" only once to speed up batch processing in repeat dispensing
''10Dec99 SF  now allows the maximum patients per ward to be ini file specified (default is the original 200)
''04Sep01 JN  added code to search wards for more than one patient type
''12oct01 CKJ Added separate frame for patient status & removed link between repeat dispensing and label types
''12Nov01 TH  Various changes to look up specific ward details if using patient specific search.
''   "        NB - quick changes for release - overhaul of this still required for 8.5 (#56702)
''14Feb02 TH  Added code to allow sort by consultant only if requested by user (option formally ignored) (#49045)
''25Feb02 TH  Changed to flag not to reference dispens.frm (#59050)
''15Oct02 TH  Added flag to stop translog write if manu issue and ActionEachDose has already been called (#)
''16Oct02 TH  Moved calls to promptBatchno on civas issue to point where the issue will take place (ie after checks on exclusions) (#)
''21OCt02 TH  Mod to suppress 'OK to print msg' (cant cancel at this point) and to add patient details to batchno prompt caption during manu issue
''13Nov02 CKJ Moved call to PromptBatchNumber inside ActionEachDose. Only allocate batchno when there is at least one dose to be handled.
''            If ActionEachDose finds that enough doses have been done already then it would have wasted that batchno
''            Added support for detecting whether a formula has been handled internally by manufacturing
''29Sep04 TH  Added mod to check each label and set to history if date past stop date. These labels will not now be processed.
''05Sep05 PJC/TH Added a test for AutoArchive to the logic in the If statement (#79161).
''12Jan07 PJC Added extra empty arguments to the call to PrintManWorksheet (enh77351).
'
'Dim msg As String
'Dim pointer&, i&
'Dim WDCode$
'Dim pos%
'Dim sup As supplierstruct
'Dim Find&
'Dim DoBlister%, Pack%, PrintPack%, BlisterError%  '20Jan98 CFY Added
'Dim SevenDays As DateAndTime
'Dim StartTime As DateAndTime                      '20Jan98 CFY Added
'Dim StopTime As DateAndTime                       '20Jan98 CFY Added
'Dim CurrStart As DateAndTime
'Dim CurrStop As DateAndTime
'Dim Issue%                                        '17Mar98 CFY Added
'Dim temp$, valid%                                 '03May98 CKJ Y2K
'Dim TxtStart%
'Dim manuEscd%     '24Feb99 SF added
'Dim rptPatCount&, typeList$                       '15Mar99 SF added
'Dim OutFile$                                      '14May99 CFY Added
'Dim RptDispOK As Integer                          '07Jun99 SF added
'Dim PatientsPerWardLimit%                         '10Dec99 SF added
'Dim strWardName$                                  '23May00 AJK added
'Dim intTypeLoop As Integer                        '04Sep01 JN added
'Dim strPatStatus As String                        '12oct01 CKJ
'Dim numpts As Integer, DoList As Integer, DoTxtLabels As Integer, DoRptDispens As Integer, DoTxtLbls As Integer, extn As Integer, filename$, OK As Integer, stopmins&, ans$      '01Jun02 All/CKJ
'Dim nw As Integer, found&, maxpmrptr&, maxlblptr&, escd As Integer, count As Integer, WDnum As Integer, cont&, srt$, patid$, txtPIDno$, baddata As Integer  '01Jun02 All/CKJ
'Dim footer As Integer, Label As Integer, Create As Integer, ForAction%, badlabel As Integer, lngIPDfound As Long, DoPrint As Integer, MakeMacro%, dircode$, mach$, issuetype$    '01Jun02 All/CKJ   '01Jun02 All/CKJ ipdfound was integer
'Dim IssueCost$, PreviewEdit As Integer, keep As Integer    '01Jun02 All/CKJ
'Dim blnManufactLogsDone As Integer  '15Oct02 TH Added
'Dim strTemp As String '21Oct02 Th Added
'Dim blnFormulaHandled As Integer                   '13Nov02 CKJ
'Dim blnPmrchanged As Integer      '29Sep04 TH Added
'Dim lngTodaymins As Long          '    "
'Dim FoundSup As Long
'
'   blnManufactLogsDone = False   '15Oct02 TH Added
'   printdrugtotal = False   ' 31Jul98 TH Reset Flag
'   'setinput 0, k
'   k.HelpFile = "\dispasc\ipdlist.hlp"
'   esc$ = Chr$(27)      '<== still used in printing!
'   'sethelp
'   today td
'   DateToString td, tday$
'   wnow$ = Left$(Time$, 5)
'   '27Jul96 ASC
'   'LblPrn = Val(siteinfo$("IPDlistLPT", "1"))   '19Jan95 CKJ Added "1"
''@@'   FindSmallLabelPrn
'   '---------
''@@'   HorizCentreForm Ipdlist '26Sep96 CKJ Added
''@@'   Ipdlist.ChkOutput(10).Enabled = (TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "", "Times", 0) <> "")
'
'   'ipdlist.Show 1                                                         '11Sep98 CFY
'
'   numpts = 0
'   PatientsPerWardLimit = Val(TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", "200", "PatientsPerWardLimit", 0))   '10Dec99 SF allow ini file increase
'   ReDim patsort$(PatientsPerWardLimit)                                                                                 '10Dec99 SF added
'   rptPatCount& = SetRptPosition&(True)     '15Mar99 SF added
'
'   'If IPDList.CmdCancel.Cancel = True Then GoTo Wayout
'   'If ipdlist.CmdCancel.Cancel = True Then Unload ipdlist: Exit Sub       '11Sep98 CFY
'
''@@'   prepdate$ = Ipdlist.txtPrepDate.Text
'
'   docyto = False
'   DoCivas = False
'   IssType$ = ""
'   Notenabled = False
'   Erase IssTyp$
'   '24Jul96 ASC reset for Windows
'   DoList = False
'   printout = False
'   ToScreen = False
'   DoTxtLabels = False
'   Patcost = False
'   OnCostReqd = False
'   DoLabel = False
'   Dobaglabel = False
'   DoWorklabel = False
'   Notenabled = False
'   SendtoATC = False
'   DoBlister = False
'   PrintPack = False
'   PgFeedWards = True
'   DoRptDispens = False    '15Mar99 SF added
'   '---------
'
'   layout$ = ""
'   PatsPerSheet% = 0
'
''@@'
'''   If Ipdlist.ChkType(1).Value = 1 Then IssType$ = IssType$ + "I": IssTyp$(1) = "In-pt"
'''   If Ipdlist.ChkType(2).Value = 1 Then IssType$ = IssType$ + "O": IssTyp$(2) = "Out-pt"
'''   If Ipdlist.ChkType(3).Value = 1 Then IssType$ = IssType$ + "D": IssTyp$(3) = "Disch"
'''   If Ipdlist.ChkType(4).Value = 1 Then IssType$ = IssType$ + "L": IssTyp$(4) = "Leave"
'''   If Ipdlist.ChkType(5).Value = 1 Then IssType$ = IssType$ + "W": IssTyp$(5) = "Stock"
'''   If Ipdlist.ChkType(6).Value = 1 Then IssType$ = IssType$ + "C": IssTyp$(6) = "CIVAS": DoCivas = True
'''   'If IPDList.ChkType(7).Value = 1 Then isstype$ = isstype$ + "E": notenabled = True
'''   If Ipdlist.ChkType(8).Value = 1 Then IssType$ = IssType$ + "C": IssTyp$(8) = "Cyto": docyto = True
'''   'If IPDList.ChkType(9).Value = 1 Then notenabled = True
'''   If Ipdlist.ChkType(10).Value = 1 Then IssType$ = IssType$ + "S": IssTyp$(10) = "Self Med."
'''
'''   strPatStatus = ""                                                                       '12oct01 CKJ added
'''   If Ipdlist.chkPatStatus(0).Value = 1 Then strPatStatus = strPatStatus & "I"             '   "
'''   If Ipdlist.chkPatStatus(1).Value = 1 Then strPatStatus = strPatStatus & "O"             '   "
'''   If Ipdlist.chkPatStatus(2).Value = 1 Then strPatStatus = strPatStatus & "L"             '   "
'''
'''   If Ipdlist.ChkOutput(0).Value Then DoList = True: printout = True 'Printout
'''   If Ipdlist.ChkOutput(1).Value Then DoList = True: ToScreen = True 'Screen
'''   If Ipdlist.ChkOutput(2).Value And DoList Then DoTxtLbls = True    'Free format labels
'''   If Ipdlist.ChkOutput(3).Value And DoList Then Patcost = True      'Patient Costing '06May95
'''   If Ipdlist.ChkOutput(4).Value And Patcost Then OnCostReqd = True  'Patient Costing '06May95
'''   If Ipdlist.ChkOutput(5).Value Then DoLabel = True                 'Labels
'''   If Ipdlist.ChkOutput(6).Value Then Dobaglabel = True              'Labels
'''   If Ipdlist.ChkOutput(7).Value Then DoWorklabel = True             'Labels
'''   If Ipdlist.ChkOutput(8).Value Then Notenabled = True              'Worksheet
'''   If Ipdlist.ChkOutput(9).Value Then SendtoATC = True               'ATC
'''   If Ipdlist.ChkOutput(10).Value Then DoBlister = True              'Blister Packing
'''   If Ipdlist.ChkOutput(11).Value Then PgFeedWards = True            '30Jul98 CFY Added Page Feed
'''   If Ipdlist.ChkOutput(13).Value Then DoRptDispens = True           '15Mar99 SF added
'
'   '07Jun99 SF added following block
'   If DoRptDispens Then
'         'If Not OpenClosePIDdb(True) Then            '25Jan08 CKJ removed - logic wrong
'         '      Exit Sub
'         '   ElseIf Not RptDBsetupOk() Then
'         '      rptDispOk% = OpenClosePIDdb(False)
'         '      Exit Sub
'         '   End If
'
''@@'
'''         If OpenClosePIDDB(True) Then                 '25Jan08 CKJ Now tests db structure after opening
'''               If Not RptDBsetupOK() Then
'''                  RptDispOK = OpenClosePIDDB(False)
'''                  Exit Sub
'''               End If
'''            Else
'''               Exit Sub
'''            End If
'      End If
'   '07Jun99 SF -----
'
'   If SendtoATC Then
'         Do
'            If extn > 99 Then
'                  MsgBox "Cannot make another ATC file", 0, "Too many ATC files"
''@@'                  End
'               End If
'            If Not fileexists("ATC" + LTrim$(Str$(extn)) + ".DAT") Then
'                  filename$ = "ATC" + LTrim$(Str$(extn))
'                  OK = True
'               Else
'                  extn = extn + 1
'               End If
'         Loop Until OK
'         ATCfile$ = filename$
'         headermessage$ = "ATC file = " + ATCfile$
'      End If
'
'   'stringtodate (Ipdlist.TxtDateAfter.text), dt   'not used
'   'StringToTime (Ipdlist.TxtTimeAfter.text), dt   'not used
'   'datetomins dt                                  'not used
'   'startmins& = dt.mint                           'not used
'   'IF Ipdlist.TxtDateAfter.text = "ALL" THEN dt.mint = 0  'not used
'   dt.mint = 0   '08May95 ASC
'
''@@'   StringToDate (Ipdlist.TxtDateBefore.Text), xp
''@@'   StringToTime (Ipdlist.TxtTimeBefore.Text), xp
'   datetomins xp
'   stopmins& = xp.mint
'
'   'Cls
'   excIVcyto = False
'   If DoCivas And Not docyto Then
'         ans$ = "Y"
'         k.helpnum = 10
'         Confirm "CIVAS chosen, but not Cyto.", "exclude IV Cytotoxics from the report", ans$, k
'         If k.escd Then
'               nw = 0
'            Else
'               excIVcyto = (ans$ = "Y")
'            End If
'      End If
'
'   '03Jul97 KR
'   If Not fileexists(dispdata$ & "\supfile.v5") Then
'         popmessagecr "", " Cannot print IPD List: Supplier code file has not been defined."
'      Else
''@@'         If RTrim$(Ipdlist.TxtPatid.Text) = "" Then     '12Nov01 TH Only fill array if not pat specific
'               fil = FreeFile
''@@'               openrandomfile dispdata$ & "\supfile.v5", Len(sup), fil
'               GetPointerSQL dispdata$ + "\supfile.v5", pointer&, 0
'               ReDim WDname$(pointer&)
'               ReDim WDDesc$(pointer&)
'               For Find& = 2 To pointer&
''@@'                  GetRecordNL r, (Find&), fil, Len(sup)                         '@~@~
'                  LSet sup = r
'                  If Trim$(sup.Code) <> "" Then
'                        'If UCase$(sup.InUse) <> "N" And sup.suppliertype = "W" Then                           '15Mar99 SF replaced
'                        typeList$ = UCase$(TxtD(dispdata$ & "\ASCRIBE.INI", "PID", "W", "WardsDisplayed", 0))  '15Mar99 SF
'                        If InStr(typeList$, sup.suppliertype) And UCase$(sup.inuse) <> "N" Then                '15Mar99 SF
'                              WDname$(Find& - 1) = sup.Code
'                              WDDesc$(Find& - 1) = sup.Code & Chr$(9) & Trim$(sup.fullname)
'                           End If
'                     End If
'               Next
'               Close fil
'               fil = 0
''@@'            End If                                     '12Nov01 TH
'      End If
''   If Not fileexists(dispdata$ & "\wardcode.dat") Then
''         popmessagecr "", " Cannot print IPD List: Ward code file has not been defined."
''      Else
''         On Error GoTo diskerrhandler
''         Do
''            errno = False
''            fil = FreeFile
''            Open dispdata$ & "\wardcode.dat" For Input Lock Write As #fil
''            Err70msg errno, "Ward Code file"
''         Loop While errno
''
''         Input #fil, numofwards
''         ReDim WDname$(numofwards)
''         ReDim WDdesc$(numofwards)
''         For count = 1 To numofwards
''            Input #fil, WDname$(count), WDdesc$(count)
''            WDdesc$(count) = "    " + WDdesc$(count)
''            Mid$(WDdesc$(count), 1, 4) = WDname$(count)
''         Next
''         Close #fil
''         On Error GoTo 0
'
'
''@@'         If RTrim$(Ipdlist.TxtPatid.Text) <> "" Then         '16May95 CKJ Added section
''@@'               Ipdlist.TxtPatid.Text = UCase$(Ipdlist.TxtPatid.Text) '04Nov96 KR/CKJ added.
''@@'               binarysearchidx RTrim$(Ipdlist.TxtPatid.Text), patdatapath$ + "\PatID.Idx", True, 0, found&
'               If found& Then
''@@'                     GetPatidNL found&, pid                  ' <== NO LOCK PID
''@@'                     GetPIDExtra (pid.recno), pidExtra
'                     nw = 1
'                     ReDim WDDesc$(nw)      '12Nov01 TH Added
'                     ReDim WDname$(nw)      '   "
'                     WDname$(nw) = pid.ward
'                     'WDcode = pid.ward  '03Jun97 KR
'                     '12Nov01 TH Block Added
'                     getsupplier pid.ward, 0, FoundSup, sup
'                     If FoundSup Then
'                           WDDesc$(nw) = sup.Code & Chr$(9) & Trim$(sup.fullname)
'                        Else
'                           WDDesc$(nw) = pid.ward & Chr$(9) & "Ward Not Found"
'                        End If
'                     '-------------------
'                     numpts = 1
'                     pointer& = 1 '12Nov01 TH
'                     'patsort$(numpts) = MKL$(found&)
'                     patsort$(numpts) = Left$(Str$(found&) + Space$(10), 10)
'                  Else
'                     nw = 0
''@@'                     popmessagecr "!n!b", "Patient with Case Number '" + RTrim$(Ipdlist.TxtPatid.Text) + "' not found"
'                     k.escd = True             '21Jan98 CKJ Added, otherwise 'ipdlist.GgeDone.Max = nw' goes bang
'                  End If
'
''            ElseIf True Then                  'switch between display methods
''@@'            Else
'               '03Jun97 KR
'               'Get total size of file - ensures array always big enough later on.
'               'GetPointer dispdata$ + "\supfile.v5", pointer&, 0
'               'ReDim WDdesc$(pointer&)
'               k.escd = False
'               'SelectWards WDDesc$(), nw, True, 1    '15Mar99 SF replaced
'               If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "RepeatDispensing", 0)) Then '15Mar99 SF
'                     SelectWards WDDesc$(), nw, True, 0                                                           '15Mar99 SF
'                  Else                                                                                            '15Mar99 SF
'                     SelectWards WDDesc$(), nw, True, 1                                                           '15Mar99 SF
'                  End If                                                                                          '15Mar99 SF
''               Load multilist
''               For count = 1 To numofwards
''                  multilist.LstUnselected.AddItem Left$(WDdesc$(count), 4) + " " + Mid$(WDdesc$(count), 5)
''               Next
''
''               multilist.Caption = "Select one or more departments or wards"
''              'multilist.lblLine(0).Caption = ""
''               multilist.lblLine(1).Caption = "Press A-Z or CURSOR KEYS to move, then SPACE to select, RETURN when finished"
''               multilist.lblLine(2).Caption = "To add or remove all, press TAB to move to the button required && press SPACE"
''              'multilist.lblLine(3).Caption = ""
'
''               multilist.Show 1
'
''               If Val(multilist.Tag) Then    'valid
''                     nw = multilist.LstSelected.ListCount
''                     For count = 1 To nw
''                        WDname$(count) = Left$(multilist.LstSelected.List(count - 1), 4)
''                     Next
''                  Else
''                     nw = 0
''                     k.escd = True
''                  End If
''               Unload multilist
''@@'            End If
'
'            fil = 0
'            escaped = False
'            If Not k.escd Then
''@@'                  MDIevents.MousePointer = 11
'                  'Ipdlist.GgeDone.Max = nw                  '14feb03 CKJ Pointless - form is not visible here
'                  'Ipdlist.GgeDone.Value = nw / 10
'                  If nw > 0 Then
'                        GetPointerSQL patdatapath$ + "\pmr.v5", maxpmrptr&, False
'                        GetPointerSQL patdatapath$ + "\labeltxt.v6", maxlblptr&, False
'                     End If
'
'                  '!!** Surely this should only happen on actually printing the first label
''@@'                  If DoLabel Or DoWorklabel Or Dobaglabel Then Reverselabel escd
'                  '** Main loop through wards **
'                  For count = 1 To nw
'                     strWardName$ = Right(WDDesc$(count), Len(WDDesc$(count)) - 6)
'                     WDexpand$ = ""
'                     For WDnum = 1 To pointer&       '03Jul97 KR was  To numofwards
'                        'If InStr(WDdesc$(WDnum), WDname$(count)) = 1 Then '03Jul97 KR
'                        If InStr(WDDesc$(count), WDname$(WDnum)) = 1 Then
'                                WDexpand$ = Mid$(WDDesc$(WDnum), 6)
'                              Exit For
'                           End If
'                     Next
'                     'pos = InStr(WDdesc$(count), Chr$(9))
'                     'WDexpand$ = Trim$(Mid$(WDdesc$(count), pos + 1))
'                     'WDcode = Trim$(Left$(WDdesc$(count), pos - 1))
'                     'Cls
'                     'LOCATE , , 0
'                     'Print " Ward " & WDname$(count) & "   " & WDexpand$ & ","
'                     cont& = 0
'
'                     '*** find all in-patients on the ward ***
'
'                     If numpts = 0 Then   ' PatID not specified; go searching
'                           If Len(strPatStatus$) = 0 Then                                          '12oct01 CKJ added
'                                 popmessagecr "!", "Please select at least one patient status"     '   "
'                              End If                                                               '   "
'                           For intTypeLoop = 1 To Len(strPatStatus$)                               '04Sep01 JN Added
'                              found& = False                                                       '   "
'                              cont& = 0                                                            '12oct01 CKJ added
'                              Do
'                                 '31Oct97 EAC - use the correct array to pull ward codes from
'                                 'binarysearchidx Left$(WDDesc$(count), 4) + "I", patdatapath$ + "\PatWdCon.Idx", False, cont&, found&' only four characters in the wardcode! '12oct01 CKJ removed
'                                 'binarysearchidx Left$(WDName$(WDnum), 4) + "I", patdatapath$ + "\PatWdCon.Idx", False, cont&, found& ' only four characters in the wardcode!
'                                 '---
'                                 'binarysearchidx WDname$(count) + "I", patdatapath$ + "\PatWdCon.Idx", False, cont&, found& '03Jun97 KR
'                                 'binarysearchidx WDcode + "I", patdatapath$ + "\PatWdCon.Idx", False, cont&, found&
''@@'                                 binarysearchidx Left$(WDDesc$(Count), 4) & Mid$(strPatStatus, intTypeLoop, 1), patdatapath$ & "\PatWdCon.Idx", False, cont&, found& '12oct01 CKJ use new patstaus checkbox data
'
'                                 If found& Then
'                                       'If numpts = 200 Then    '01Apr99 SF bumped up to 200 from 100 for repeat dispensing   '10Dec99 SF replaced
'                                       If numpts = PatientsPerWardLimit Then                                                  '10Dec99 SF
''@@'                                             binarysearchidx "", "", 0, 0, (found&) 'close
'                                             popmessagecr "!n!iFind Patients", "Found > " & Format$(PatientsPerWardLimit) & " patients on ward" + WDname$(WDnum) + " - first " & Format$(PatientsPerWardLimit) & " will be printed"   '12Dec99 SF
'                                             found& = 0
'                                          Else
'                                             numpts = numpts + 1
''@@'                                             If Ipdlist.OptSort(0).Value = False Then
''@@'                                                   GetPatidNL found&, pid ' <== NOLOCK PID
'                                                   'GetPIDExtra (pid.recno), PIDExtra         '14Feb02 TH Removed as unnecessary drain on performance
'                                                'End If                                     '14Feb02 TH Need Pid.cons for sort later ! (#49045)
''@@'                                                Else                                        '     "
''@@'                                                   GetPatidNL found&, pid ' <== NOLOCK PID  '     "
''@@'                                                End If                                      '     "
''@@'                                             If Ipdlist.OptSort(1).Value Then
'                                                   srt$ = UCase$(Left$(pid.surname, 10))
''@@'                                                ElseIf Ipdlist.OptSort(2).Value Then
'                                                   srt$ = UCase$(pid.cons) + UCase$(Left$(pid.surname, 10))
''@@'                                                ElseIf Ipdlist.OptSort(0).Value Then       '14Feb02 TH Added to allow sort by consultant only (#49045)
'                                                   srt$ = UCase$(pid.cons)                 '    "
''@@'                                                Else
'                                                   srt$ = ""
''@@'                                                End If
'                                             'patsort$(numpts) = srt$ + MKL$(found&) '14May94 ASC was MKS !
'                                             patsort$(numpts) = srt$ + Left$(Str$(found&) + Space$(10), 10) '14May94 ASC was MKS !
'                                          End If
'                                    End If
'                              Loop While found&
'                           Next                                   '04Sep01 JN Added
'                        End If
'
'                     If numpts Then
'                           'Print numpts; "in-patient"; plural$(numpts); " found"
'                           'If ipdlist.OptSort(0).Value = False Then shellsort patsort$(), numpts, 0     '16Dec96 ASC  '05Mar98 Removed and replaced with line below
'                           'If Ipdlist.OptSort(0).Value = False Then shellsort patsort$(), numpts, 0, ""  '
'                           shellsort patsort$(), numpts, 0, ""    '14Feb02 TH Now sort on consultant if required  (#49045)
'                           newward = True
'                           firstpatient = True
'
'                           ' ** Loop for each patient **
'
'                           For i = 1 To numpts
'                              'If INKEY$ = esc$ And Not escaped Then escaped = True
'                              Heap 10, gPRNheapID, "PatientDetails", "", 0       '18Oct02 TH Added to blank details at start of each pat loop
'                              'patno& = CVL(Right$(patsort$(i), 4)) ' last 4 chars => long int
''@@'                              patno& = Val(Right$(patsort$(i), 10)) ' last 10 chars => long int
''@@'                              GetPatidNL patno&, pid      ' <== NOLOCK PID
''@@'                              GetPIDExtra (pid.recno), pidExtra
'                              patid$ = pid.recno
'                              If DoRptDispens Then                                   '15Mar99 SF added
'                                    rptPatCount& = SetRptPosition&(rptPatCount&)     '15Mar99 SF added
'                                    PutRptPatient pid, rptPatCount&                  '15Mar99 SF added
'                                 Else                                                '15Mar99 SF added
'                                    ' 02Mar99 SF moved all the following code into the ELSE block
'                                    gTlogCaseno$ = pid.caseno              '17Jan98 CFY Added
''@@'                                    txtPIDno$ = UCase$(RTrim$(Ipdlist.TxtPatid.Text))
'                                    If txtPIDno$ = "" Or txtPIDno$ = RTrim$(UCase$(pid.caseno)) Then           '04Nov96 KR Added ucase$
''@@'                                          pmrptr& = Val(pid.ptr(8))
''@@'                                          If pmrptr& > 0 Then
'                                                PatientName$ = LTrim$(RTrim$(pid.forename) + " ") + Trim$(pid.surname)
'                                                'Print " ù "; patientname$;
'                                                firstdrug = True
''@@'                                                If pmrptr& > maxpmrptr& Then
'                                                      GetPointerSQL patdatapath$ + "\pmr.v5", maxpmrptr&, False
''@@'                                                   End If
''@@'                                                If pmrptr& > maxpmrptr& Then
''@@'                                                      WriteLog patdatapath$ + "\errorlog.txt", 0, "", "Invalid pointer in PATID: Patient's Internal Rec No = " + patid$ + ", PATID contains pointer to PMR =" + Str$(pmrptr&)
'                                                   Else
'                                                      baddata = 3  ' write any errors to log file
'                                                      blnPmrchanged = False   '29Sep04 TH Added
''@@'                                                      GetPMR pmrptr&, patid$, baddata           ' lock
'                                                      'lockpmr pmrptr&, 0                        ' unlock
'                                                      'lockpmr pmrptr&, 0, k                       ' unlock    '29Sep04 TH Moved below to keep lock through the whole process
'                                                      'If InStr(Command$, "/DEBUG") Then displaypointers
'
'                                                      footer = False
'
'                                                      '20Jan98 CFY Added                                                                     '17Feb98 CFY Removed
'                                                      'If DoBlister Then                                                                     'and replaced with code below
'                                                      '      PrintPack = False
'                                                      '      today StartTime
'                                                      '      getsupplier pid.ward, 0, foundsup, False, sup
'                                                      '      stringtodate sup.TopUpDate, StopTime '!!** is this correct start/stop time??
'                                                      '      InitPatBlisters StartTime, StopTime
'                                                      '   End If
'
'                                                      '17Feb98 CFY Added -----
'                                                      If DoBlister Then
'                                                            PrintPack = False
'                                                            ''Issue = Ipdlist.ChkBookout.Value    '17Mar98 CFY Added
'                                                            Issue = RptDispAction '@@'
'
'                                                            'Setup start and stop times
''@@'                                                            StringToDate (Ipdlist.txtPrepDate.Text), StartTime
''@@'                                                            StringToTime (Ipdlist.txtPrepTime.Text), StartTime
'                                                            datetomins StartTime
''@@'                                                            If Trim$(Ipdlist.TxtDateBefore.Text) <> "" And Trim$(Ipdlist.TxtTimeBefore.Text) <> "" Then
''@@'                                                                  StringToDate (Ipdlist.TxtDateBefore.Text), StopTime
''@@'                                                                  StringToTime (Ipdlist.TxtTimeBefore.Text), StopTime
'                                                                  datetomins StopTime
'                                                               Else
'                                                                  getsupplier pid.ward, 0, FoundSup, sup       'Create blister pack till
'                                                                  StringToDate sup.topupdate, StopTime               'top-up date.
'                                                               End If
'                                                            InitPatBlisters StartTime, StopTime, BlisterError
'                                                         End If
'                                                      '------------
'                                                      GetToday lngTodaymins  '29Sep04 TH Added - reset for each patient (cos if CIVAS could take a while)
'                                                      For Label = 1 To 50   '** Loop for each label **
''@@'                                                         If Labrf&(label) > 0 Then
''@@'                                                               If Labrf&(label) > maxlblptr& Then
'                                                                     GetPointerSQL patdatapath$ + "\labeltxt.v6", maxlblptr&, False
''@@'                                                                  End If
''@@'                                                               If Labrf&(label) > maxlblptr& Then
''@@'                                                                     WriteLog patdatapath$ + "\errorlog.txt", 0, "", "Invalid pointer in PMR: Patient's Internal Rec No = " + patid$ + ", PMR contains pointer to label =" + Str$(Labrf&(label))
''@@'                                                                  Else
''@@'                                                                     Labf& = Labrf&(label)
'                                                                     'Getlabel LabF&, False
'                                                                     'getlabel False    '25Feb02 TH Changed to flag not to reference dispens.frm (#59050)
''@@'                                                                     getlabel 3
'                                                                     '
'                                                                     'Check against stop date here.(see selectrx) if past then set to history by flagging to putpmr
'
''@@'                                                                     If (Labrf&(label) > 0) And (L.StopDate <= lngTodaymins) And (L.StopDate > 0) And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "AutoArchive", 0)) Then  '05Sep05 PJC/TH Added a test for AutoArchive to the logic in the If statement (#79161).
'                                                                     'if (labrf&(label) > 0) And (l.stopdate <= lngTodaymins) And (l.stopdate > 0)                         '29Sep04 TH Added section                                                      '         "
'                                                                           L.StoppedBy = UserID$                                                                           '    "
'                                                                           L.deletedate = lngTodaymins                                                                     '    "
'                                                                           LSet r = L                                                                                      '    "
''@@'                                                                           PutRecordNL r, Labf&, labchan%, Len(L)                                                          '    "
''@@'                                                                           Labrf&(label) = Labrf&(label) * -1    'mark as history                                          '    "
'                                                                           blnPmrchanged = True                                                                            '    "
''@@'                                                                        Else                                                                                               '    "
'
'                                                                           'if Do Blister then                                                     '17Feb98 CFY
'                                                                           If DoBlister And Not BlisterError And InStr(IssType$, L.IssType) Then   '     "
''@@'                                                                                 If CheckPackNo() Then
'                                                                                       BlisterPackDrug StartTime, StopTime, Create, Issue          '17Mar98 CFY Added Issue parameter
'                                                                                       If Create Then PrintPack = True
'                                                                                    End If
''@@'                                                                              End If
'
'                                                                           CheckRxStatus ForAction%
'                                                                           If ForAction% Then
'                                                                                 GlobalManufBatchNum$ = ""                 '13Nov02 CKJ added
'                                                                                 setbatchnum ""                            '   "
'                                                                                 Heap 10, gPRNheapID, "BatchNumber", "", 0 '   "
'                                                                                 'NB Does not address m_batchnumber in formula.bas nor ManBlister.batch
'
'                                                                                 If badlabel = 0 Then '!!** NEVER SET TO True
'                                                                                       If Len(Trim(L.SisCode)) <> 7 Then '20Apr94 CKJ free format label
'                                                                                             'ideally would check drug file & if drug not found then
'                                                                                             'assume free text but this would slow it down greatly
'                                                                                             If Trim(L.text) <> "" And DoTxtLbls Then  '10Feb95 CKJ Added
'                                                                                                   issuedesc$ = "(Text)"
'                                                                                                   'printdetails True, strWardName$                '02Mar98 CFY Removed and replaced with following
'                                                                                                   If DoBlister Then                                  '        "
''@@'                                                                                                         If CheckPackNo() Then printdetails True, strWardName$      '        "
'                                                                                                      Else                                            '        "
'                                                                                                         printdetails True, strWardName$                            '        "
'                                                                                                      End If                                          '        "
'                                                                                                End If
'
'                                                                                          ElseIf InStr(IssType$, L.IssType) Then
''@@'                                                                                             cleardrug d
'                                                                                             d.SisCode = L.SisCode
''@@'                                                                                             If Ipdlist.TxtDrugCode.Text <> "" And d.SisCode <> Ipdlist.TxtDrugCode.Text Then
'                                                                                                   d.SisCode = ""
'                                                                                                   'DrugTotalingFlag
'                                                                                                   printdrugtotal = True     ' 31Jul98 TH
''@@'                                                                                                End If
'                                                                                             If d.SisCode <> "" Then
'                                                                                                   getdrug d, False, lngIPDfound, False      '01Jun02 All/CKJ
'                                                                                                   issuedesc$ = L.IssType
'                                                                                                Else
'                                                                                                   lngIPDfound = 0                           '01Jun02 All/CKJ
'                                                                                                End If
'
'                                                                                             If lngIPDfound > 0 And L.IssType = "C" And (docyto Or DoCivas) Then     '01Jun02 All/CKJ added > 0
'                                                                                                   '16Oct02 TH Moved block below
'                                                                                                   'If DoCivas And DoWorklabel Then                                            '19Nov98 CFY
'                                                                                                   '      'If layout$ = "" Then PromptForWrkSht layout$, PatsPerSheet%          '       " '24Feb99 SF replaced
'                                                                                                   '      If layout$ = "" Then PromptForWrkSht layout$, PatsPerSheet%, manuEscd%          '24Feb99 SF
'                                                                                                   '      PromptBatchNumber          '04Jun99 CFY Added
'                                                                                                   '   End If                                                                   '       "
'                                                                                                   '-------------------------------
'                                                                                                   Select Case d.cyto
'                                                                                                      Case "Y":  issuedesc$ = "Cy"
'                                                                                                      Case "N":  issuedesc$ = ""
'                                                                                                      Case Else: issuedesc$ = "?Cy"   ' not Y or N
'                                                                                                      End Select
'
'                                                                                                   Select Case d.civas
'                                                                                                      Case "Y":  issuedesc$ = issuedesc$ + " IV"
'                                                                                                      Case "N"
'                                                                                                         If d.cyto = "N" Then     'C' type issue on non CIVAS/Cyto drug
'                                                                                                               issuedesc$ = "?C"  ' print it anyway since main file is clearly wrong!
'                                                                                                               WriteLog dispdata$ + "\errorlog.txt", 0, "", "Issue type 'C': Drug " + d.SisCode + " '" + RTrim$(d.Description) + "' is neither CIVAS nor Cyto"
'                                                                                                            End If
'                                                                                                      Case Else: issuedesc$ = issuedesc$ + " ?IV"
'                                                                                                      End Select
'
'                                                                                                   DoPrint = False
'                                                                                                   If docyto And d.cyto <> "N" Then DoPrint = True   ' cyto wanted & found
'                                                                                                   If DoCivas Then                                   ' civas wanted
'                                                                                                         If excIVcyto And d.cyto = "Y" Then          ' but not cytos
'                                                                                                               DoPrint = False
'                                                                                                            Else
'                                                                                                               If d.civas <> "N" Then DoPrint = True ' found civas
'                                                                                                            End If
'                                                                                                      End If
'                                                                                                   If Not DoPrint Then
'                                                                                                         lngIPDfound = False      '01Jun02 All/CKJ
'                                                                                                      Else                                                                             '16Oct02 TH Moved block from above (if no print then dont prompt for batchno etc.)
'                                                                                                         If DoCivas And DoWorklabel Then                                               '    "
'                                                                                                               If layout$ = "" Then PromptForWrkSht layout$, PatsPerSheet%, manuEscd%  '    "
'                                                                                                               strTemp = d.Description                                '21OCt02 TH Mod to suppress 'OK to print msg' (cant cancel at this point) and to add patient details to batchno prompt caption
'                                                                                                               plingparse strTemp, "!"   '   "                        '    "
''@@'                                                                                                               Ipdlist.Tag = Trim$(strTemp) & " for " & PatientName   '    "
'                                                                                                               'PromptBatchNumber True                                '    "   13Nov02 CKJ Moved inside ActionEachDose
''@@'                                                                                                               Ipdlist.Tag = ""                                       '    "
'                                                                                                            End If                                                                     '    "
'                                                                                                      End If                                                                           '    "
'                                                                                                End If
'
'                                                                                             'MSGBOX "found", 0, STR$(found) 'debug
'
'                                                                                             'If ipdfound Then                      ' action details  '24Feb99 SF replaced
'                                                                                             If lngIPDfound > 0 And Not manuEscd% Then    '24Feb99 SF    '01Jun02 All/CKJ added > 0
'                                                                                                   'LOCATE , 2
'                                                                                                   'Print Chr$(251);             ' tick
'                                                                                                   DosesForIssue! = 0 '8Mar93 ASC '7Apr94 CKJ moved from inside IF ATC...
'                                                                                                   'IF (SendToATC AND l.isstype = "A") OR (DoLabel AND INSTR(isstype$, l.isstype)) THEN
''@@'                                                                                                   If Ipdlist.TxtDateBefore.Text <> "ALL" Or (DoLabel And InStr(IssType$, L.IssType)) Then
'                                                                                                         manuEscd% = False                     '24Feb99 SF
'                                                                                                         dt.mint = L.RxStartDate               '17May95 CKJ/ASC replaces below
'                                                                                                         'IF l.RxStartDate > startmins& THEN   '17May95 CKJ/ASC removed startmins&
'                                                                                                         '      dt.mint = l.RxStartDate
'                                                                                                         '   ELSE
'                                                                                                         '      xp.mint = startmins&      '!!** dt or xp
'                                                                                                         '   END IF
'                                                                                                         minstodate dt
'
'                                                                                                         If L.StopDate < stopmins& Then
'                                                                                                               xp.mint = L.StopDate
'                                                                                                            Else
'                                                                                                               xp.mint = stopmins&
'                                                                                                            End If
'                                                                                                         minstodate xp
'                                                                                                         'dosesforissue! = 0 '8Mar93 ASC '7Apr94 moved out of IF
'                                                                                                         '--------- 8May 95 ASC patient costing added
'                                                                                                         If Patcost And L.IssType <> "W" Then
'                                                                                                               '21Jan96 ASC -------
'                                                                                                               'DosesForIssue! = l.NodIssued
'                                                                                                               '15Aug96 EAC above should be changed to
'                                                                                                               'DosesForIssue! = l.NodIssued * d.DosesPerIssueUnit
'                                                                                                               If d.dosesperissueunit > 0 Then
'                                                                                                                     DosesForIssue! = L.Nodissued * d.dosesperissueunit
'                                                                                                                  End If
'                                                                                                               '--------------
'                                                                                                            Else
'                                                                                                               'ActionEachDose SendtoATC%, MakeMacro%, dircode$            '24Feb99 SF replaced
'                                                                                                               'ActionEachDose frmIPD, SendtoATC%, MakeMacro%, dircode$, manuEscd%  '24Feb99 SF      '14Jul00 JN
'                                                                                                               ActionEachDose frmIPD, SendtoATC%, MakeMacro%, dircode$, manuEscd%, blnFormulaHandled '13Nov02 CKJ Added param
'                                                                                                               'blnManufactLogsDone = True  '15Oct02 TH Added                                        '   "
'                                                                                                               If manuEscd Or blnFormulaHandled Then blnManufactLogsDone = True  '15Oct02 TH Added   '   "
'                                                                                                            End If
''@@'                                                                                                         If Patcost And (Asc(L.Flags) And &H2) <> 0 Then '15May95 ASC/CKJ brackets
'                                                                                                               'DosesForIs2sue! = DosesForIssue! * Val(plvl$("PRNfactor"))
'                                                                                                               DosesForIssue! = DosesForIssue! * Val(plvl$("PRNfactor")) '18Jun97 KR Fixed
'                                                                                                            End If
'                                                                                                         '---------------------------
'                                                                                                         'If SendtoATC Then mach$ = ":AT" Else mach$ = ":LAB"  '03Jul97 KR
'                                                                                                         If SendtoATC Then mach$ = ":AT" Else mach$ = UserID$
'                                                                                                         If d.dosesperissueunit > 0 Then  'ASC 07Nov94
'                                                                                                               If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then        '21Aug98 CFY
'                                                                                                                     Qty! = dp!(DosesForIssue!)                                                                                                                                                                                                                                                                                                                                                                      '     "
'                                                                                                                  Else                                                                                                                                                                                                                                                                                                                                                                                               '     "
'                                                                                                                     Qty! = dp!(DosesForIssue! / d.dosesperissueunit)                                                                                                                                                                                                                                                                                                                                                '     "
'                                                                                                                  End If                                                                                                                                                                                                                                                                                                                                                                                             '     "
'                                                                                                            Else                                                                                                                                                                                                                                                                                                                                                                                                     '     "
'                                                                                                               Qty! = 1
'                                                                                                            End If
'                                                                                                         'ASC 13Nov94 added ChkBookout
'                                                                                                         'IF DosesForIssue! > 0 AND Ipdlist.ChkBookOut.value = 1 THEN '7Apr94 CKJ Moved inside IF ATC...
'                                                                                                         'If DosesForIssue! > 0 And ipdlist.ChkBookOut.Value = 1 And (Asc(l.flags) And &H1) = 0 Then       '7Apr94 CKJ Moved inside IF ATC... '2Dec94 CKJ and Manual flag not set                                       '17Mar98 CFY Replaced with line below
'                                                                                                         'If DosesForIssue! > 0 And Ipdlist.ChkBookOut.Value = 1 And (Asc(l.flags) And &H1) = 0 And Ipdlist.ChkOutput(10).Value <> 1 Then       '7Apr94 CKJ Moved inside IF ATC... '2Dec94 CKJ and Manual flag not set   '                  "  '24Feb99 SF replaced
''@@'                                                                                                         If Not manuEscd% And DosesForIssue! > 0 And Ipdlist.ChkBookOut.Value = 1 And (Asc(L.Flags) And &H1) = 0 And Ipdlist.ChkOutput(10).Value <> 1 Then     '24Feb99 SF
'                                                                                                               issuetype$ = L.IssType
'                                                                                                               If issuetype$ = "S" Then issuetype$ = "M"  '9Dec94 CKJ Self Med stored as M not S
'                                                                                                               'Translog d, (ipdfound), mach$, patid$, QTY!, dircode$, pid.ward, pid.cons, pid.Status, sitepaths%, issuetype$, issuecost$    '9Dec94 CKJ
'                                                                                                               If Not blnManufactLogsDone Then Translog d, (lngIPDfound), mach$, patid$, Qty!, dircode$, pid.ward, pid.cons, pid.status, SiteNumber%, issuetype$, IssueCost$    '03Jul97 KR '01Jun02 All/CKJ  '15Oct02 TH Added clause and reset of new boolean
'                                                                                                               blnManufactLogsDone = False                                                                                                                                                                    '    "
'                                                                                                               'l.RxNodIssued = dp!(l.RxNodIssued + DosesForIssue!)                                                                                                                                                                                                                                                                                                                                                  '21Aug98 CFY
'                                                                                                               L.Nodissued = dp!(L.Nodissued + Qty!)                                                                                                                                                                                                                                                                                                                                                                 '     "
'                                                                                                               If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then        '     "
'                                                                                                                     L.RxNodIssued = dp!(L.RxNodIssued + (DosesForIssue! * d.dosesperissueunit))                                                                                                                                                                                                                                                                                                                     '     "
'                                                                                                                  Else                                                                                                                                                                                                                                                                                                                                                                                               '     "
'                                                                                                                     L.RxNodIssued = dp!(L.RxNodIssued + DosesForIssue!)                                                                                                                                                                                                                                                                                                                                             '     "
'                                                                                                                  End If                                                                                                                                                                                                                                                                                                                                                                                             '     "
'
'                                                                                                               '24Feb99 SF replaced following block of code with one below it
'                                                                                                               'If l.lastdate <> Mid$(Date$, 4, 2) + Left$(Date$, 2) + Right$(Date$, 2) Then    '03May98 CKJ Y2K
'                                                                                                               'parsedate (l.lastdate), temp$, "3", valid            '03May98 CKJ Y2K ddmmccyy
'                                                                                                               'If Not valid Or temp$ <> thedate(False, True) Then   '03May98 CKJ Y2K
'                                                                                                               '      l.lastqty = Qty!
'                                                                                                               '   Else
'                                                                                                               '      l.lastqty = dp!(l.lastqty + Qty!)  '25Aug93 added dp! ASC
'                                                                                                               '   End If
'                                                                                                               'l.lastdate = Mid$(Date$, 4, 2) + Left$(Date$, 2) + Right$(Date$, 2) '03May98 CKJ Y2K
'                                                                                                               'l.lastdate = thedate(False, False) '03May98 CKJ Y2K still ddmmyy but avoids midnight problem
'                                                                                                               ''***
'                                                                                                               'End If
'
'                                                                                                               '24Feb99 SF replaced above block of code with the following
'                                                                                                               parsedate (L.lastdate), temp$, "3", valid
'                                                                                                               If Not valid Or temp$ <> thedate(False, True) Then
'                                                                                                                     L.lastqty = Qty!
'                                                                                                                  Else
'                                                                                                                     L.lastqty = dp!(L.lastqty + Qty!)
'                                                                                                                  End If
'                                                                                                               L.lastdate = thedate(False, False)
'                                                                                                               '***
'
'
'                                                                                                               If SendtoATC Then L.dispid = "*AT" Else L.dispid = "*LAB"
'                                                                                                               '01Jul96 ASC
'                                                                                                               'PutLabelIPD LabF&
''@@'                                                                                                               Putlabel
'                                                                                                            End If
'                                                                                                      End If
'                                                                                                   k.escd = False
'                                                                                                   If printout And DosesForIssue! > 0 And SendtoATC Then
'                                                                                                         issuedesc$ = "ATC"   ' 11Apr94 ASC
'                                                                                                         'printdetails 0 , strWardName$        ' all data, headers etc       '02Mar98 CFY Removed and replaced with following
'                                                                                                         If DoBlister Then                                     '
''@@'                                                                                                               If CheckPackNo() Then
'                                                                                                                     printdetails 0, strWardName$
'                                                                                                                     If printdrugtotal Then '31Jul98 TH
'                                                                                                                           printdrgqty
'                                                                                                                        End If
'                                                                                                                  End If
'                                                                                                            Else
'                                                                                                               printdetails 0, strWardName$
'                                                                                                               If printdrugtotal Then       '31Jul98 TH
'                                                                                                                     printdrgqty
'                                                                                                                  End If
'                                                                                                            End If
'                                                                                                         footer = True
'                                                                                                      End If
'                                                                                                   If (printout Or ToScreen Or Patcost) And Not SendtoATC Then '08May95 ASC added patcost
'                                                                                                         'printdetails 0 , strWardName$        ' all data, headers etc       '02Mar98 CFY Removed and replaced with following
'                                                                                                         If DoBlister Then                                     '
''@@'                                                                                                               If CheckPackNo() Then
'                                                                                                                     printdetails 0, strWardName$
'                                                                                                                     If printdrugtotal Then '31Jul98 TH
'                                                                                                                           printdrgqty
'                                                                                                                        End If
'                                                                                                                  End If
'                                                                                                            Else
'                                                                                                               printdetails 0, strWardName$
'                                                                                                               If printdrugtotal Then       '31Jul98 TH
'                                                                                                                     printdrgqty
'                                                                                                                  End If
'                                                                                                            End If
'                                                                                                         footer = True
''@@'                                                                                                      End If
'                                                                                                   If k.escd Then Exit For
''@@'                                                                                                End If
''@@'                                                                                          End If
''@@'                                                                                    End If
''@@'                                                                              End If
''@@'                                                                        End If    '29Sep04 TH Added
''@@'                                                                  End If
''@@'                                                            End If
'
'                                                         If k.escd Then escaped = True: Exit For
''@@'                                                         If Trim$(Ipdlist.TxtDrugCode.Text) = "" Then layout$ = ""    '19Nov98 CFY Force system to prompt for a new worksheet
'                                                      Next  ' label
'
'                                                      If blnPmrchanged Then               '29Sep04 TH Added to put the pmr (if setting any labels to history)
''@@'                                                            putpmr pmrptr&, (pid.recno)   '   "       then just remove the lock after processing everything required
'                                                         End If                           '   "
''@@'                                                      lockpmr pmrptr&, 0, k               '   "
'
'
'                                                      GlobalManufBatchNum$ = ""                 '13Nov02 CKJ added
'                                                      setbatchnum ""                            '   "
'                                                      Heap 10, gPRNheapID, "BatchNumber", "", 0 '   "
'                                                      'NB Does not address m_batchnumber in formula.bas nor ManBlister.batch
'
'                                                      If PrintPack Then
'                                                            'PreviewEdit = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "N", "PreviewEdit", 0))  '16Mar98 CFY Added
''@@'                                                            PreviewEdit = Ipdlist.ChkOutput(1).Value     '02Sep98 TH
'                                                            PrintPatPacks StartTime, PreviewEdit
'                                                            PrintPack = False
'                                                            EndBlisterPacking
'                                                         End If
'
'                                                      If Patcost And footer Then PrintTotalCost  'Patient footer
'                                                      'Print
'                                                   End If
''@@'                                             End If
''@@'                                       End If
''@@'                                 End If      '15Mar99 SF added
'                           Next  ' patient
'                        Else
'                           'Print "  No in-patients found"
'
'                           '**** Take out msgbox and add to some kind of review
'                           'popmessagecr "", "No patients found"                    '15Mar99 SF replaced
'                           temp$ = Trim$(WDDesc$(count))                            '15Mar99 SF
'                           replace temp$, Chr$(9), "", 0                            '15Mar99 SF
'                           'screen.MousePointer = STDCURSOR                         '26Apr99 SF added
''@@'                           MDIevents.MousePointer = STDCURSOR                       '12oct01 CKJ corrected
'                           popmessagecr "#", "No patients found on ward: " & temp$  '15Mar99 SF
'                           'screen.MousePointer = HOURGLASS                         '26Apr99 SF added
''@@'                           MDIevents.MousePointer = HOURGLASS                       '12oct01 CKJ corrected
'                        End If
'
'                     If escaped And count < nw Then
'                           ans$ = "N"
'                           k.helpnum = 20
'                           Confirm "!n!bEscape Requested", "abandon processing of all remaining wards", ans$, k
'                           If ans$ = "Y" Then
'                                 Exit For
'                              Else
'                                 escaped = False
'                              End If
'                        End If
'                     numpts = 0   '17May95 CKJ
'                     'Ipdlist.GgeDone.Value = nw                    '14feb03 CKJ Pointless - form is not visible here
'                  Next ' ward
'               End If
'
'            '!!** See above comment
''@@'            If DoLabel Or DoWorklabel Or Dobaglabel Then forwardlabel escaped                     '24May95 CKJ added escaped
'            'If DoWorklabel Then PrintManWorksheet 0, 0, 0, 0, "", 0, 0, "", "", "", 0, layout$    '19Nov98 CFY Added.  '24Feb99 SF replaced
'            'If DoWorklabel Then PrintManWorksheet frmIPD, 0, 0, 0, 0, "", 0, 0, "", "", "", 0, layout$, 0  '24Feb99 SF       '14Jul00 JN   '12Jan07 PJC replaced by below (enh77351)
''@@'            If DoWorklabel Then PrintManWorksheet frmIPD, 0, 0, 0, 0, "", 0, 0, "", "", "", 0, layout$, "", "", 0                           '12Jan07 PJC Added extra arguments (enh77351)
'
''@@'            MDIevents.MousePointer = 0
'            'If fil Then                                                   '30Jul98 CFY Replaced
'            If fil And Not PrintError Then
'                  'Grand Total Here
'                  If printdrugtotal Then                 '31Jul98 TH
'                        Print #fil, " \page ";
'                        Print #fil, " \par ";
'                        Print #fil, drugdesc$; " \tab "; " Grand Total Exptd Qty : "; grandtotalexpectedqty!; " \tab "; "Grand Total TopUp Qty : "; grandtotaltopupqty!; " \tab "; "Grand Total Qty : "; grandtotaltopupqty! + grandtotalexpectedqty!; " \par "; '
'                        grandtotalexpectedqty! = 0
'                        grandtotaltopupqty! = 0
'                     End If
'
'                  TxtStart% = InStr(RTFTxt$, "[data]") + Len("[data]")
'                  Print #fil, Mid$(RTFTxt, TxtStart%, Len(RTFTxt))
'
'                  Close fil
'                  keep = True
'
'                  If escaped Then
'                        ans$ = "Y"
'                        k.helpnum = 30
'                        Confirm "!n!bEscaped", "print all wards processed so far", ans$, k
'                        If ans$ = "N" Or k.escd Then keep = False
'                     End If
'
'                  If keep Then
'                        If ToScreen Then
'                              parseRTF SpoolFile$, OutFile$                            '         "
'                              Hedit 11, OutFile$                                       '         "
'                              Kill OutFile$                                            '         "
'                           End If
'                        If printout Then
'                              'spool spoolfile$          '30Jul98 CFY
'                              'HEdit 14, "PrMngr*SpoolFile$"               '03Aug98 TH       '26Jan99 CFY Corrected
'                              ParseThenPrint "RxMngr", SpoolFile$, 1, 0                      '     "
'                           Else
'                              Kill SpoolFile$
'                           End If
'                     Else
'                        Kill SpoolFile$
'                     End If
'               End If
'
''@@'   If DoRptDispens Then RptDispOK% = OpenClosePIDDB(False)      '07Jun99 SF added
'
'End Sub

