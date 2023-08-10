Attribute VB_Name = "PATSUBS"
'--- PATSUBS.BAS ---
'26mar04 CKJ {SP1}
'            removed unused procs SendToPump, showallroutes, UpdateRxDates
'10may04 CKJ ReprintFile: Allows reprints where ID is > FFFFF (1048575). Added warning if > FFFFFF   (#69146)
'16May04 TH  EnterDrug: Added - Terminal basis only - Used to retain focus on dircode after drug entered (#65365)
'16May04 TH  IssueAndPrint: Added update of last dispensers ID on issue (#62626)
'04jun04 ckj 32bit
'10May06 CKJ CheckStandard: if canusespoon=true but dose is not one for spoonfuls then numbers are still needed
'24Feb10 TH  createlabel:  Now  foramt stat doses correctly on CIVAS label .(F78659)
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'25Jun12 CKJ DisplayTheLabel: Added Alternative Labels      TFS24660
'20Jun13 TH  MakeWorksheet: Further changes to the wording with syringe handling including adding new volume params (TFS 51176)
'20Jun13 TH  MakeWorksheet: Replaced instances of ml with mL
'04Jul13 TH  ReprintFile: Mods to support DB reprints in general (TFS 64512)
'18Sep13 TH  EnterDrug: Removed references to Prescribing setting as now obselete (TFS 73749)
'07Jan14 TH  Createlabel:  Suppress route administration text on CIVAS label on switch (TFS 80018)
'17Aug14 TH  Createlabel:  Added space before route expansion (TFS 98040)
'30Apr15 XN  Added gDisableLabelDescriptionAlternative (TFS 98073)
'            createlabel: added support for in-patient\out-patient specific label (TFS 98073)
'            CastRecordsetToProduct: Reads in LabelDescriptionInPatient\LabelDescriptionOutPatient (TFS 98073)
'03Dec15 TH  ReprintFile: More appropriate message when reprint not found (TFS 137255)
'04May16 XN  Added gRequestID_AmmSupplyRequest
'02Aug16 XN  DisplaytheLabel: Added copies count as optional parameter 159413
'----------------------------------------------------------------------------------------------------------------------------

DefInt A-Z
Option Explicit

Global L As WLabel

Global gRequestID_Prescription As Long, gRequestID_Dispensing As Long, gRequestID_AmmSupplyRequest As Long                             '09May05

'Global labrf&(50), pmrptr&, newstart%, currentline%, Firstdisplay%, prescribed%, prescribing%,
'Global labelline$(10), WDir As WDirection, Labf&, TxtLabelChanged%
Global labelline$(16), WDir As WDirection, Labf&, TxtLabelChanged%  '05Aug14 TH
Global nextchoice$, labpromptchanged%, DosesToTopUP!, UserTopUpQty%
Global passlvl%, prepdate$
Global LabelAmended%, Qty!, storeddirect$    ', LabelForArchive&
Global BatchLabel$, BatchNo$, Exdate$  '17Jul96 KR added for printing expiry & batch number on labels.
Global LabelCost!                      '19Mar97 KR added.  Stores cost of label for printing
Global RxOffset&                       '06Jul98 ASC added as offset for prescription start date
Global reusedLabel%                    '05Feb99 SF added to decide whether a label has been re-used
Global FirstLoaded%                    '24Mar99 CFY Moved from dispens.frm
Global gDisableLabelDescriptionAlternative As Boolean '01May15 XN Provides a flag that can be set in code to disable using the alternate LabelDescriptionInPatient or LabelDescriptionOutPatient when creating a label
Global gStdLbl10PreDone As Boolean

Dim iLblSplit As Integer                              '03Feb00 AE  Added for WA Labels
Const LBL_HIGHLIGHT = &HE0E0E0                        '     "
Global Const WA_DEBUG_SWITCH = "/wadebug"             '19Sep00 AE  Command line switch for wa label debugging. MUST BE LOWER CASE HERE!

Dim m_blnReusedDirections As Integer  '04Jun03 TH Added  (#67381)


Sub CalcDefaultcourse(Amnt As Single, dailydose As Single, days%, issuetype As String, DosingDays() As Boolean)
'02May96 KR This procedure checks the amount prescribed and adjusts it
'           according to the length of of the course for specific issue type
'           specified in patmed.ini.  Prevents the problem of defaulting to
'           six months worth.  Note: Only used with ASCribe automation!
'03Jun96 KR Now checks the supplier file for topup information
'04Jun96 KR Added Days to as parameter
'15May00 EAC Added parameter asciiday and code to modified the calculated
'            default based on the asciidays
'09May05 CKJ DosingDays(1 to 7) Mon-Sun

Dim topdate%
Dim iLoop%, iCount%
Dim tdate$

   '27jul96 ASC The six months came from an ini file anyway and might be different on different sites
   'If Amnt \ DailyDose = 182 Then 'six months worth

   Select Case issuetype
      Case "I", "S", "W"
         getwardtopup pid.ward, tdate$, days%, topdate%
         If topdate% = 3 Or topdate% = 4 Then      'no ward found or no date/interval set
            ''Not necessary for kings as no ward top-up dates
            ''27Jul96 Date set to 0 for date top up which needs handling !!**
            'If found& > 0 And Val(Mid$(find$, 6, 2)) Then
            '      Days = Val(Mid$(find$, 6, 2))
            
            Select Case issuetype
               Case "I": days = Val(plvl$("DaysForIP"))
               Case "S": days = Val(plvl$("DaysForSM"))
               Case "W": days = Val(plvl$("DaysForWard"))
            End Select
         End If

      Case "O": days = Val(plvl$("DaysForOP"))
      Case "D": days = Val(plvl$("DaysForDischarge"))
      Case "C": days = Val(plvl$("DaysForCivas"))
      Case "L": days = Val(plvl$("DaysForLeave"))
      End Select

''   iCount = 7              'assume every day unless some are not set
''   If asciiday > 0 Then
''         iCount = 0
''         iDays = asciiday
''         For iLoop = 7 To 1 Step -1
''            If iDays - (2 ^ iLoop) >= 0 Then
''                  iDays = iDays - (2 ^ iLoop)
''                  iCount = iCount + 1
''               End If
''         Next
''      End If

   iCount = 0              'assume every day unless some are not set
   For iLoop = 1 To 7
      If DosingDays(iLoop) Then iCount = iCount + 1
   Next
   If iCount = 0 Then iCount = 7
   
   Amnt = days * dailydose * (iCount / 7)

End Sub

Sub checkroute()
'26Jan98 moved the route check to the end of the direction entry flow
'22Jul98 EAC make language aware
'10Sep98 ASC made the display of all routes a list box to fit on 640 X 480 screens
'09Jan99 ASC This was moved from Dispens.frm
'19Jan99 SF  now automatically selects the route if only one to choose from
'19Jan99 SF  corrects splitting of route text when putting into popmenu which was
'            sometimes causing the route to be displayed twice
'09Oct00 AW  Added code to show licenced/unlicenced routes
'20Nov00 AW  Commented out code to show licenced/unlicenced routes

Dim foundallside%, temp$, routetemp$, routestart%, nextroute%, Numoflines%, X%, expansion$, ans$   '22Jan98 ASC
ReDim lines$(0 To 100)   '06Sep98 ASC Now needs to hold all routes

   If cmbUC("CmbRoute") = "" Then
''         If trimz$(d.route) = "" Then         '09May05 Always will be since this field is no longer read from the DB
      Unload LstBoxFrm
      Do                                                     '06Sep98 ASC whole do loop added to make sure route is added
         LstBoxFrm.Caption = "Route"
         For X = 1 To Val(TxtD(dispdata$ & "\route.ini", "allroutes", "", "Total", True))
            lines$(X) = TxtD(dispdata$ & "\route.ini", "allroutes", "", Format$(X), True)
            GetRouteExpansion lines$(X), expansion$, ""
            If expansion$ = "" Then expansion$ = "** Code '" & lines$(X) & "' not found"
            LstBoxFrm.LstBox.AddItem expansion$
         Next
         LstBoxShow
         WDir.route = lines$(LstBoxFrm.LstBox.ListIndex + 1)
         Unload LstBoxFrm
      Loop Until trimz$(WDir.route) <> ""
''            Else
''               temp$ = TxtD(ASCFileName("route.ini", True, ""), "allsides", "", d.route, foundallside)
''               If InStr(d.route, ",") = 0 And Not foundallside Then
''                     If trimz(d.route) <> "" Then
''                           WDir.route = d.route
''                        End If
''
''                  Else
''                     routetemp$ = ""
''                     routestart = 1
''                     d.route = Trim$(d.route) & ","
''                     Do
''                        nextroute = InStr(routestart, d.route, ",")
''                        If nextroute > 0 Then
''                              If routestart > 1 Then routetemp$ = routetemp$ & ","
''                              routetemp$ = routetemp$ & TxtD(ASCFileName("route.ini", True, ""), "allsides", "", Mid$(d.route, routestart, nextroute - routestart), foundallside)
''                              If Not foundallside Then
''                                    routetemp$ = routetemp$ & Mid$(d.route, routestart, nextroute - routestart)
''                                 End If
''                              routestart = nextroute + 1
''                           End If
''                     Loop Until nextroute = 0
''
''                     deflines routetemp$, lines$(), ",", 1, Numoflines
''
''                     If Numoflines > 1 Then
''                           For X = 1 To Numoflines
''                              GetRouteExpansion lines$(X), expansion$, ""
''                              If expansion$ = "" Then                       ' 8Jan98 CKJ/CY Warn user if code not found
''                              expansion$ = "** Code '" & lines$(X) & "' not found"
''                              End If
''                              popmenu 1, expansion$, True, False
''                           Next
''                           PopMenuShow ans$, 1, 2500
''                           WDir.route = lines$(Val(ans$))
''                           popmenu 0, "", 0, 0
''                        ElseIf Numoflines = 1 Then
''                           WDir.route = lines$(1)
''                        End If
''                  End If
''            End If
            
      For X = 0 To cmbUC("CmbRoute").ListCount - 1
         If UCase$(Trim$(WDir.route)) = UCase$(Trim$(cmbUC("CmbRoute").List(X))) Then
            cmbUC("CmbRoute").ListIndex = X
            Exit For
         End If
      Next
   End If

End Sub

Sub CheckStandard(ByVal findcode As String, WDir As WDirection, done)
'20Dec94 CKJ Major overhaul - large amount of info moved to Patmed.ini
'        TABinstruct = Take           'DosingUnit(s) + instruct
'        TABform = tablets            'DosingUnit(s) + form
'        TABroute = by mouth          'DosingUnit(s) + route
'        MLoralLiq =                  'presence of line alone is enough
'        MLnumsOnly =                 '   "
'        MLnoPlural =                 '   "
'        Words1 = ONE                 'Add as many lines as necessary
'        Words1.5 = ONE AND A HALF    '   "
'        SpoonInstruct = Take         'Enter this line once
'        SpoonCode15 = THREE 5ml      'Add a pair of lines for each of ...
'        SpoonForm15 = spoonfuls      ' ... 5, 10, 15, 20, 25
'Note: if dosing units are plural eg PESS then use of singular eg PES is OK.
'24Jan95 CKJ Error handling added: val("0.9% NaCl") => type mismatch
' 3Feb95 CKJ Allow .5 and 0.5
'29Mar95 ASC plural
'31Mar96 KR Checked whether code$ empty - generates error with left$.  Quick fix !!**
'05jul96 KR Corrected fault with plurals of spray & half a tablet
'08Jul97 KR Added MGO - milligrams oral
'30Sep97 ASC Uses d.route from dataservice if present
'29Nov97 ASC LIQ is set using an oral liquid form found by parsing description. Should come from
'        actual form in the future put into d structure from dataservice
'29Nov97 CKJ Corrected: InStr does not return a boolean
'12Dec97 CKJ Added DPSform to the dosing units which are used to look up in patmed.ini
'            The DPSform will be zero or one character, assumed to be uppercase alpha.
'27Dec97 ASC Expand eye ear and nose to right left eye etc.
'22Jan98 ASC Entire route handler moved to TxtDircode_GotFocus
'30Jan98 ASC/CY route now from d.route for setting LIQ
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'16Feb98 CFY Now converts elixirs to spoonfuls if necessary.
'19Mar98 ASC/CKJ Now makes issue units of ml### become ml for look up in patmed.ini instructions
'27Apr98 ASC/CFY Stopped numbers expanding to words for liquids
'25May98 ASC/CFY Made sure that if site has made dosing units mlo this is preserved for direction code look up
'02Jun98 CFY Now excludes drugs that have elixir in the description and dosing units begining with 'DR'
'            so that dosing units don't get set to mls.
'11Jun98 CFY Corrected above mod.
'12Jun98 CKJ Corrected this mod as it stopped oral liquids working properly
'02Jul98 CFY Added to above mod to allow non DSS drugs that are oral liquids to be treated as
'            such. This previously did not happen as the non DSS drugs have no route.
'24Mar99 AE  Added trap to prevent string handling occuring if direction was not found.
'29Mar99 AE  Added line to prevent numerical words appearing as plurals, eg "FIVEs"
'31Mar99 CKJ/AE Simplified previous mod - if form is blank then don't add 's'
'10Nov01 CKJ Added > 0 to "syrup" comparison
'10May06 CKJ if canusespoon=true but dose is not one for spoonfuls then numbers are still needed

Dim Code$, quantity#, tmp!, ess$, NumbersOnly As Boolean, Instruction$, Form$, du$, found%, dummy%, dummys$, putsere%, yoff%  '29Jun97 ASC
''Dim temp$

Dim Numoflines As Integer
Dim IsRange As Boolean
Dim strLowerValue As String
Dim strUpperValue As String
Dim TimeUnit As String
Dim IsDuration As Boolean

   ReDim lines(10) As String
   
   done = False
   Code$ = RTrim$(findcode)
   If Code$ <> "" Then
      quantity# = 0
      On Local Error Resume Next
      quantity# = Val(findcode)
      On Local Error GoTo 0
      
      '18Oct05 CKJ Added block
      If InStr(1, Code, "TEXT:", 1) = 1 Then
         WDir.Code = Code
         WDir.directs = DirectionTextToPlain(Mid$(Code, 6))    'Remove 'TEXT:' and decode
         done = True
         Exit Sub
      End If

      '26Jun98 Added handling of /Kg and /Msq
      If (UCase$(Right$(Code$, 1)) = "K" Or UCase$(Right$(Code$, 1)) = "M") And LTrim$(Str$(quantity#)) = Left$(Code$, Len(Code$) - 1) Then
''         Select Case UCase$(Right$(Code$, 1))
''            Case "K"   '26Jun98 ASC Allows entry by per Kg
''               Code$ = Left$(Code$, Len(Code$) - 1)
''               DoseFromKg Code$
''               Code$ = Format$(Val(Code$))
''               quantity# = Val(Code$)
''            Case "M"   '26Jun98 ASC Allows entry by per Kg and per m sq
''               Code$ = Left$(Code$, Len(Code$) - 1)
''               DoseFromMsq Code$
''               Code$ = Format$(Val(Code$))
''               quantity# = Val(Code$)
''            End Select

         popmessagecr ".WARNING", "Directions codes which use -K or -M suffix are not supported." & cr & cr & _
                                  "Please enter dose per metre squared and dose per kilogram" & cr & _
                                  "using Prescription Entry only."
         Exit Sub
      End If

'      Infusion duration and infusion duration range. ... over 12 hours ... over 4 to 6 hours ... etc
'      Stored in dircode as /Over[<n>-]<n><S|M|H|D|W>/
'      If InfusionDuration Then
'         tmpDirCode = Format$(InfusionDuration)
'         If InfusionDurationLow Then
'            tmpDirCode = Format$(InfusionDurationLow) & "-" & tmpDirCode
'         End If
'         Select Case OCXheap("UnitAbbreviation_InfusionDuration", "")
'            Case "Sec": TimeUnit = "S"
'            Case "Min": TimeUnit = "M"
'            Case "Hrs": TimeUnit = "H"
'            Case "Day": TimeUnit = "D"
'            Case "Wk" : TimeUnit = "W"
'            End Select
'         TxtDircode = TxtDircode & "Over" & tmpDirCode & TimeUnit

      If InStr(UCase$(Code), "OVER") = 1 And InStr("SMHDW", UCase$(Right$(Code, 1))) > 0 Then     'OVERnnM' 'OVERnn-nnH'
         TimeUnit = Right$(Code, 1)          'Keep S/M/H/D/W
         Code = Mid$(Code, 5)                'Remove 'OVER'
         Code = Left$(Code, Len(Code) - 1)   'Remove time code, keep nnn or nnn-nnn
         IsDuration = True
      End If
      
      'Dose range entry, 1-2 tabs 10-20 mL etc where code is 'Num-Num' and Num is (n{n}[.n{n}]|[.]n{n})
      'Note that anything which resembles this structure but is not a valid range may still be defined as a direction code
      strLowerValue = ""      'lower part of range, otherwise blank
      strUpperValue = ""      'explicit dose if not a range, or upper part of range
      IsRange = False         'set if both Values are filled
      
      deflines Code$, lines$(), "-", 0, Numoflines             '1  1-2  1.5  1.5-2.5  1D  6H+  etc
      Select Case Numoflines
         Case 1                                                'one section, no '-' may be just digits or soemthing more eg 1D 6H+ etc
            If IsNumber(lines(0), False) Then                  'Is it just digits with optionally one decimal point?
               strUpperValue = lines(0)
            End If
         
         Case 2                                                'two sections, neither blank, separated by one '-'
            If IsNumber(lines(0), False) Then                  'Is first part valid?
               If IsNumber(lines(1), False) Then               'and the second part too?
                  strLowerValue = lines(0)
                  strUpperValue = lines(1)
               End If
            End If
         End Select

      '       Instruct                    Dose                       Form
      'take|inhale|insert|give' 'ONE|10 to 20|14|TWO to FOUR' 'tablet|mL dose|grams|5mL spoonfuls'

''      If Code$ = Trim$(Str$(quantity#)) Or Code$ = Strz$((quantity#)) Then 'i.e. a number  '3Feb95 CKJ Added STRz check
      If Len(strUpperValue) Then                               'Definitely a number or number range
         BlankWDirection WDir
         tmp! = Val(strUpperValue)
         If tmp! > 2 Then tmp! = 2
         ess$ = plural((tmp!))
         
         If IsDuration Then
            WDir.Code = "Over" & Code$ & TimeUnit               'OvernnS'  'Overnn.nM'  'Overnn-nnH'  'Overnn.n-nn.nD'
            Select Case TimeUnit
               Case "S": Instruction$ = " sec"
               Case "M": Instruction$ = " min"
               Case "H": Instruction$ = " hour"
               Case "D": Instruction$ = " day"
               Case "W": Instruction$ = " week"
               End Select
            Instruction$ = strUpperValue & Instruction$ & ess
            If Len(strLowerValue) Then
               Instruction$ = strLowerValue & "-" & Instruction$
            End If
            WDir.directs = " over " & Instruction$
            done = True
            
         Else
            WDir.Code = Code$                                  'nn'  'nn.n'  'nn-nn'  'nn.n-nn.n'
               
''            If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or _
''               UCase$(Left$(d.PrintformV, 3)) = "TAB" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "CAP" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "SUP" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "MLO" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "MGO" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "PES" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "NEB" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or _
''               UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
''                  du$ = UCase$(Trim$(d.PrintformV))
''                  If UCase$(Trim$(d.DosingUnits)) = "MLO" Then du$ = "mlo"
''               Else
''                  du$ = UCase$(Trim$(d.DosingUnits))
''               End If

            du$ = UCase$(Trim$(Iff(d.LabelInIssueUnits, d.PrintformV, d.DosingUnits)) & Trim$(d.DPSform))        'DPSform is "" or one character
            Instruction$ = TxtDPatmed("", du$ & "instruct", found)                                               'Take/Give etc
            Form$ = ""
            NumbersOnly = False

            If Not found Then
               popmessagecr "!Please note", "Details have not been set up for dosing unit " & du$
               Exit Sub       '<== WAY OUT
            End If
            
''            If Not found And Right$(du$, 1) = "S" Then ' remove the plural, retry          09May05 plurals not permitted
''                  du$ = Left$(du$, Len(du$) - 1)
''                  Instruction$ = TxtDPatmed(Instruction$, du$ + "instruct", found)
''               End If
            
            done = True
            Form$ = TxtDPatmed("", du$ & "form", 0)
            
'''29Nov05 CKJ Romoved default route entirely. DR-05-0032
            '09May05 SHOULD NOT REFER TO THE DISPENS FORM HERE
''            If cmbUC("CmbRoute") = "" And trimz$(d.route) = "" Then           '23Jan98 CKJ Moved this back from TxtDircode_GotFocus
'''            If cmbUC("CmbRoute") = "" Then                                    '09May05 d.route will always be blank since this field is no longer read from the DB
'''               WDir.route = TxtDPatmed("oral", du$ & "route", dummy)          '22Jan98 CKJ Replaces functionality of patmed.ini method '30Sep97 ASC
'''            End If
            
''                  temp$ = UCase$(d.Description)
''                  If InStr(temp$, "SUSPENSION") > 0 Or _
''                     InStr(temp$, "LIQUID") > 0 Or _
''                     InStr(temp$, "SOLUTION") > 0 Or _
''                     InStr(temp$, "MIXTURE") > 0 Or _
''                     InStr(temp$, "LINCTUS") > 0 Or _
''                     InStr(temp$, "SYRUP") > 0 Or _
''                     InStr(temp$, "ELIXIR") > 0 Then
''                        If UCase(Left$(Trim$(d.DosingUnits), 2)) <> "DR" Then  '12Jun98 CKJ Corrected this mod as it stopped oral liquids working properly
''                              OralLiquid = (LCase$(Trim$(d.route)) = "oral") Or (LCase$(Trim$(d.DosingUnits)) = "mlo")
''                           End If
''                     End If
            
            WDir.dose(1) = Val(strUpperValue)
''15Nov05 CKJ/TH Scaled later on, so don't do it here
''            If d.CanUseSpoon And d.dosesperissueunit <> 0 Then                         '**!!** is this correct??
''                  WDir.dose(1) = Val(strUpperValue) * d.dosesperissueunit              'form$ = "ml" or equivalent    '15Nov05 CKJ also scaled later, so not here
''               End If
            
            dummys$ = TxtDPatmed(WDir.route, du$ & "numsonly", found)
'            If found And Not d.CanUseSpoon Then NumbersOnly = True                       '10May06 CKJ removed. if canusespoon=true but dose is not one for spoonfuls then numbers are still needed
            If found Then NumbersOnly = True                                              '   "
               
            'blank or nn.n     nn.n
            CheckStandardRangeToWords strLowerValue, strUpperValue, NumbersOnly, d.CanUseSpoon, du$, Instruction, Code, Form
                           
            If Len(Form$) Then
               dummys$ = TxtDPatmed(WDir.route, du$ & "noPlural", found)
               If found Then ess$ = ""

               putsere = InStr(Form$, "!")
               If putsere = 0 Then
                  putsere = Len(Form$) + 1
                  Form$ = Form$ & "!"
               End If
               
               yoff = 0
               If Form$ = "!" Then ess$ = ""                         'if form is blank then don't add 's'
               If ess$ = "s" Then
                     If Mid$(Form$, putsere - 2, 2) = "ch" Then ess$ = "es"
                     If Mid$(Form$, putsere - 1, 1) = "y" Then ess$ = "ies": yoff = 1
                     If Mid$(Form$, putsere - 2, 2) = "ay" Then ess$ = "s":  yoff = 0
                     If Mid$(Form$, putsere - 2, 2) = "ey" Then ess$ = "s":  yoff = 0
                  End If
               
               Form$ = Left$(Form$, putsere - 1 - yoff) & ess$ & Right$(Form$, Len(Form$) - putsere)
            End If
            
            '20Jul98 EAC handle chinese labels
            'wdir.directs = Instruction$ + code$ + form$
            ChineseDirCount = 0
            If ReadLanguage(10, 0) = 852 Then
               WDir.directs = Instruction$
               ChineseAppend$ = Code$ & Form$
            Else
               WDir.directs = Instruction$ & Code$ & Form$
               ChineseAppend$ = ""
            End If
         End If
            
      'ElseIf (UCase$(Right$(code$, 1)) = "D" Or UCase$(Right$(code$, 1)) = "W") And LTrim$(Str$(quantity#)) = Left$(code$, Len(code$) - 1) Then
      'ElseIf (UCase$(Right$(Code$, 1))) = "+" Or (UCase$(Right$(Code$, 1)) = "H" Or UCase$(Right$(Code$, 1)) = "D" Or UCase$(Right$(Code$, 1)) = "W") And LTrim$(Str$(quantity#)) = Left$(Code$, Len(Code$) - 1) Then
      ElseIf Right$(Code$, 1) = "+" Or _
            (UCase$(Right$(Code$, 1)) = "H" Or UCase$(Right$(Code$, 1)) = "D" Or UCase$(Right$(Code$, 1)) = "W") And LTrim$(Str$(quantity#)) = Left$(Code$, Len(Code$) - 1) Then
         'Entered number of hours, days or weeks, or an offset of hours or days
         done = True
         BlankWDirection WDir
         WDir.Code = Code$
         Code$ = Left$(Code$, Len(Code$) - 1)
         ess$ = plural(Val(Code$))
         CheckStandardRangeToWords "", (Code), False, False, du$, Instruction, Code, Form
         
         Select Case UCase$(Right$(RTrim$(WDir.Code), 1))
            Case "D"
               If Int(quantity#) = quantity# Then         '26Jun98 ASC to  all 1.5 days etc
                  WDir.directs = TxtDPatmed("for ", "DurFor", 0) & Code$ & TxtDPatmed(" day", "DurDay", 0) & ess$    '"for " code$ " day" ess$
                  WDir.CourseUnits = "day"
                  WDir.CourseLength = quantity#
               Else
                  WDir.CourseUnits = " hr"
                  WDir.CourseLength = quantity# * 24
                  ess$ = plural(WDir.CourseLength * 1!)
                  '"for " wdir.CourseLength " hr" ess$
                  WDir.directs = TxtDPatmed("for ", "DurFor", 0) & Format$(WDir.CourseLength) & TxtDPatmed(" hr", "DurHour", 0) & ess$
               End If
               
            Case "H" '26Jun98 ASC entry by hours
               If Int(quantity#) = quantity# Then
                  WDir.directs = TxtDPatmed("for ", "DurFor", 0) & Code$ & TxtDPatmed(" hour", "DurHour", 0) & ess$  '"for " code$ " hours" ess$
                  WDir.CourseUnits = " hr"
                  WDir.CourseLength = quantity#
               Else
                  WDir.CourseUnits = "mins"
                  WDir.CourseLength = quantity# * 60
                  ess$ = plural(WDir.CourseLength * 1!)
                  'wdir.directs = "for " & Format$(wdir.CourseLength) & " minute" & ess$
                  WDir.directs = TxtDPatmed("for ", "DurFor", 0) & Format$(WDir.CourseLength) & TxtDPatmed(" minute", "DurMin", 0) & ess$
               End If
               
            Case "W"
               WDir.directs = TxtDPatmed("for ", "DurFor", 0) & Code$ & TxtDPatmed(" week", "DurWeek", 0) & ess$     '"for " code$ " week" ess$
               WDir.CourseUnits = " wk"
               WDir.CourseLength = quantity#
               
            Case "+"     '26Jun98 ASC offset start time by hours
               Select Case UCase$(Mid$(RTrim$(WDir.Code), Len(RTrim$(WDir.Code)) - 1, 1))
                  Case "D": RxOffset& = quantity# * 1440
                  Case "H": RxOffset& = quantity# * 60
                  End Select
               
               '09May05 SHOULD NOT REFER TO THE DISPENS. FORM HERE
               With txtUC("TxtDircode")
                  .text = Left$(.text, Len(.text) - Len(Trim$(WDir.Code)))
               End With
               L.RxStartDate = 0
               FormDates
            End Select
      End If
            
      'If UCase$(plvl$("LowerCase")) = "Y" Then WDir.directs = LCase$(WDir.directs)   18oct05 CKJ Cannot do this when printable text is held in the dircode
   End If
   
End Sub

Private Sub CheckStandardRangeToWords(ByVal strLowerValue As String _
                                    , ByVal strUpperValue As String _
                                    , ByVal NumbersOnly As Boolean _
                                    , ByVal OralLiquid As Boolean _
                                    , ByRef DosingUnit As String _
                                    , ByRef Instruction As String _
                                    , ByRef CodeText As String _
                                    , ByRef DosingForm As String _
                                     )
'CodeText arrives as 'nn.n' or 'nn.n-nn.n' and is equivalent to [strUpperValue] or [strLowerValue]-[strUpperValue]
'CodeText is the numeric dose eg "1" "2.5" "20"
' and is returned as "ONE" "TWO AND A HALF" "20"
' or maybe "FOUR 5ml" in conjunction with "Take" and "spoonfuls"
'Uses patmed settings
'  SpoonInstruct = "Take " or "Give "
'  SpoonCodeNN   = "NUMBER 5mL spoonfuls"     where NUMBER is NN/5
' Note that the lines SpoonFormNN are no longer supported or required

Dim found As Integer
Dim dummy As String
   
   found = False
   If OralLiquid Then                                                            'is it potentially usable as spoonfuls
      dummy$ = TxtDPatmed("", "SpoonCode" & CodeText, found)                     ' SpoonCode15 = "THREE 5ml"   SpoonCode5-10 = "ONE or TWO 5ml"
   End If
   
   If found Then                                                                 'This is a liquid in spoonfuls, so change all four attributes
      DosingUnit = "spoon"
      Instruction = TxtDPatmed(Instruction, DosingUnit & "instruct", 0)          ' SpoonInstruct = "Take "
      CodeText = TxtDPatmed(CodeText, DosingUnit & "code" & CodeText, 0)         ' SpoonCode15   = "THREE 5mL spoonfuls"
      DosingForm = ""                                                            ' incorporated into the Instruction
   ElseIf Not NumbersOnly Then
      CodeText = TxtDPatmed(CodeText, "Words" & CodeText, found)                 'search for "Words1.5", default "1.5", "Words2-4" -> "TWO to FOUR", default "2 to 4"
   End If

   If Not found And Len(strLowerValue) > 0 Then                                  'Instruct and digits pass through unchanged except for ranges
      CodeText = strLowerValue & TxtDPatmed(" to ", "WordsRangeConjunction", 0) & strUpperValue    ' to ' or ' or '
   End If

   If Left$(DosingForm, 1) <> " " And Len(Trim$(DosingForm)) > 1 Then
      DosingForm = " " & DosingForm                                              'DosingForm gets a leading space
   End If

End Sub

'Private Sub CheckStandardRangeToWordsX(ByVal Code As String _
                                  , ByVal UseSpoons As Boolean _
                                  , ByVal DosingUnit As String _
                                  , ByVal Instruction As String _
                                  , ByVal DosingForm As String _
                                   )
'Code is the numeric dose range eg "1-2" "2.5-5" "10-20"
' and is returned as "ONE or TWO" "2.5 or 5" "10 or 20"
' or maybe "ONE 10 mL or 20 mL dose" or "TWO or FOUR 5mL spoonfuls"
'Only replace with words if exact code is found in Patmed
'otherwise do 'x or y'

'Passed in are
'    Code    DosingUnit     Instruction    DosingForm     UseSpoons
'    5-10     mlo             Take            mL             1

'In order try
'  If UseSpoons
'     SpoonCode5-10
'  5-10ml               <== NOT IMPLEMENTED
'  5-10
'  else
'     5 " to " 10 " mL dose"

'Result
'  Take ONE or TWO 5 mL spoonsful   or   Take ONE or TWO 5 mL spoonfuls
'  Take ONE 5 to 10 mL dose         or   Take ONE 5 ml to 10 mL dose
'  Give 5 to 10 mL
   
'End Sub

   
''Sub clearlabel(ByRef L As WLabel)
'''09May05 Now just clears the label and nothing else.  !!** except RxOffset&
'''        Uses L as a param, not the global structure
'''30Aug12 TH Moved to WLabelIO
''
''   RxOffset& = 0         '19Jan01 CKJ Added
''   'expiry$ = ""          '25Jan95 CKJ Added  '**!!** was declared locally so would not be the right one
''
''   BlankWLabel L
''
''   L.dispid = "***"     '**???**
''
''End Sub

Sub ClosePatsubs()

Dim i%
   
   'Reset all Variables declared as Global in this module
  
   'Clear All pointers  - originally global variables
   Labf& = 0
   
   'For i = 1 To 10
   For i = 1 To 20  '30May14 TH Extended
      labelline$(i) = ""
   Next
   
   TxtLabelChanged% = 0
   nextchoice$ = ""
   labpromptchanged% = 0
''   newstart% = 0
   DosesToTopUP! = 0
''   prescribed% = 0
   passlvl% = 0
   prepdate$ = ""
''   currentline% = 0
''   Firstdisplay% = 0
''   prescribing% = 0
   LabelAmended% = 0
   Qty! = 0
   storeddirect$ = ""
''   LabelForArchive& = 0
   UserTopUpQty% = 0
   
   clearlabel L
   Erase labelline$

   'clear wdir (Type directstruct)
   BlankWDirection WDir
   
End Sub

Sub ContainerName(volume!, ContAbbr$, contname$)
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

''Static ContData$(), contnum%, doneonce
''Dim contchan, temp$, Numoflines%, i% '29jun97 ASC
''
''   If Not doneonce Then
''         ReDim lines$(1 To 6)
''         contchan = FreeFile    '!!** error checks needed
''         Open dispdata$ + "\containr.dat" For Input As #contchan
''         Do While Not EOF(contchan)
''            Input #contchan, temp$
''            deflines temp$, lines$(), "|", 1, Numoflines%
''            contnum = contnum + 1
''            ReDim Preserve ContData$(1 To 6, 1 To contnum)
''            For i = 1 To 6
''               ContData$(i, contnum) = UCase$(Trim$(lines$(i)))
''            Next
''         Loop
''         Close contchan
''         doneonce = True
''      End If
''
''   For i = 1 To contnum
''      If ContData$(1, i) = UCase$(ContAbbr$) And Val(ContData$(3, i)) = volume! Then
''            contname$ = ContData$(2, i)
''            Exit For
''         End If
''   Next
''
''   If i > contnum Then  ' failed to find correct size in same range
''         contname$ = ContAbbr$
''      End If
   
Dim contnum%, temp$, Numoflines%, i%
         
   contname$ = ContAbbr$                                                   'set the default
   contnum = Val(TxtD(dispdata$ & "\container.ini", "", "0", "total", 0))  'total num of containers defined
     
   For i = 1 To contnum
      ReDim lines$(1 To 6)
      temp$ = UCase$(TxtD(dispdata$ & "\container.ini", "", "", Format$(i), 0))
      deflines temp$, lines$(), "|", 1, Numoflines%
      
      'If lines$(1) = UCase$(ContAbbr$) And Val(lines(3)) = volume! Then
      If lines$(1) = UCase$(ContAbbr$) And Val(lines(5)) = volume! Then
         'contname$ = lines$(2)
         contname$ = lines$(2) '23Dec12 TH replaced
         Exit For
      End If
   Next

End Sub

Sub createlabel(DoseNum, ByVal intSyringelabel As Integer)
'22Nov94 ASC strength put back on second line in CIVAS
'ASC 23Aug94 Place where format of all labels is defined
'23May96 CKJ Added () for plural$
'05Jul96 KR  Forced pass by value in plural$ as plural$ now takes single not integer
'09Apr97 KR  Added cludge to make freeformat labelling work - check for no nsvcode
'11Jun97 KR  Fixed bug that lost the first warning line on outpatient labels
'26Jun97 ASC ASC/KR Ensured that for outpatient labels, if the drug description is long
'            with more than 2 plings, all of the lines greater than 2 get added to the
'            second line - needed for New Zealand.
'10Jul97 KR  Prevents bug that caused 1 line of warning to be initially overwritten.
'26Aug97 CKJ Added plingparse to outpatient labelline(2) to remove extra '!'
'07Sep97 ASC Symptoms were long drug > 35 with two ! in description when directions greater than
'            3 lines long pt directions over warnings - fixed also noticed some fence post and
'            anomolies causing formatting to fail when text in Rx is too big for label. Also if a
'            label had no warning when for inpatient it would also not have warnings when reformtted
'            as outpatient all fixed.
'30Sep97 ASC Warning saying not enough space on label sometimes comes up even when there is enough room
' 8Jan98 CKJ/CY Warn user if route code not found when filling PopMenu
'29May98 SF/CFY Added ability to append drug tradename to the the description
'20Jul98 EAC make hard code text language aware
'28Aug98 TH  Changed formats of issue rate to suppress stray decimal points
'24Sep98 TH  Changed various formats
'11Nov98 TH/CFY Took out trim to ensure that description is put into labelline array
'11Mar99 TH  Code to ensure description always gets on to label
'14Mar99 TH  Code to put description on two lines if it causes problems with rtf printing
'22Mar99 TH  Picks up RTF status properly now
'16Feb00 AE
'09Jun00 JN  Changed format of infusion rate line as original was too long to fit label in certain circumstances
'19Sep00 AE  WA Label debugging
'30Mar01 AE  Now allows individual wards to specify the use of out-patient labels for in-patient issues,
'            for "one hit" dispensing.  Also tidied logic around this area for clarity.
'16Jun08 TH  Mod to resize civas labels with long names (F0025858)
'17Jun08 TH  Added block - black hat kludge to derive a dose on a stat item. (F0025724)
'24Feb10 TH  (F78659) Now also foramt stat doses correctly.
'31Jan13 TH  Check flag for Eyelabel as this has already been handled (TFS 39777,55068)
'07Jan14 TH  Suppress route administration text on CIVAS label on switch (TFS 80018)
'17Aug14 TH  Added space before route expansion (TFS 98040)
'30May14 TH  Extended Label mods
'12Jan17 TH  Refactored for DB RTF Handling (Hosted)

ReDim lines$(5)
Dim temp$, X%, OK%            '20Jul98 EAC added ok
Dim done%, desc$, Numoflines%, Longdrugline%, lineno%, ans$, plingpos%, strlen%, Y%, routeword$, Form$, doseandunits$, hashpos%, namepart2$, pipepos%, administer$, routeinj$, reconvolume!, Tolerance!, infuse$, Hrs%, found& '29jun97 ASC
Dim TradenameAppend%          '29May98 SF/CFY Added
Dim formatting$               '20Jul98 EAC
Dim blnOutPatientlabel As Integer      '30Mar01 AE  Added
Dim sTmpDesc As String                '11Apr01 JN Added to satisfy TH's changes of 14Mar01
Dim LinesAchieved As Integer, FontNumber As Integer, TextOut$, breakpos As Integer, pos As Integer, LinesWanted As Integer, temp2$
Dim strExtra As String   '16Jun08 TH Added
Dim blnCIVASlblUseRouteAdmin As Boolean '07Jan14 TH Added
Dim blnExtendedLabel As Boolean           '24Jun14 TH Added
Dim strAns As String, strMsg As String    '  "
Dim blnDirectionsTooLarge As Boolean
Dim intCeiling As Integer '12Jul14 TH Added
Dim intSuccess As Integer '05Jan17 TH Added

   If Trim$(d.tradename) <> "" Then
         TradenameAppend = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "AppendTradename", 0))
      Else
         TradenameAppend = False
      End If
   
   done = False
   For X = 1 To 5
   'For X = 1 To Iff(L.extralabel, 15, 5) '30May14 TH Extended
      labelline$(X) = ""
   Next
   
   '09Apr97 KR Cludge to make free format label work !!**
   If trimz(d.SisCode) <> "" Then
      If intSyringelabel = 0 Then Blanklabel  '03Dec12 TH Added clause
      plingparse WDir.directs, Chr$(10) '22Jun96 ASC added to DOS proc

      'Determine if we are doing an out-patient label                                              '30Mar01 AE Added block, moved logic from IF statement below
          'Any changes to the logic here should be also reflected in PATMED.BAS FillHeapLabelInfo for the lLabelDrugDescription
      blnOutPatientlabel = False                                                                '     "
      If InStr(plvl$("OutPatLabel"), L.IssType) > 0 Then blnOutPatientlabel = True              'If this issue type uses out patient labels, do so...
      If WardUsesInPatientDirections() And InStr(plvl$("InPatLabel"), L.IssType) > 0 Then       'If this ward uses directions on inpatient labels, AND this is
         blnOutPatientlabel = True                                                           'an inpatient label, use the outpatient label template.
      End If                                                                                 '     "
      
      'Now create the label:
      'Out-Patient style label
      '-----------------------
      If blnOutPatientlabel Then
            ' XN 1May15 98073 If LabelDescriptionOutPatient is set then user this alternate description
                        'Any changes to the logic here should be also reflected in PATMED.BAS FillHeapLabelInfo for the lLabelDrugDescription
            If Trim$(d.LabelDescriptionOutPatient) <> "" And Not (gDisableLabelDescriptionAlternative) Then
                desc$ = Trim$(d.LabelDescriptionOutPatient)
            Else
                desc$ = Trim$(d.LabelDescription)
            End If
                        
            If TradenameAppend Then
                  desc$ = desc$ & " (" & Trim$(d.tradename) & ")"
               'Else
                '   desc$ = Trim$(d.Description) XN 1May15 98073 Done above
            End If
            labelline$(2) = ""
            LinesAchieved = 0

            sTmpDesc = desc$                                                                '14Mar01 TH Replaced above to get a better measure of
            plingparse sTmpDesc, "!"                                                        '    "      Lines required
            FormatLabel sTmpDesc, 1, 35, FontNumber, LinesAchieved, TextOut$, L.extralabel '    "
            iLblSplit = LinesAchieved
            If InStr(LCase(Command$), WA_DEBUG_SWITCH) > 0 And iLblSplit = 0 Then         '19Sep00 AE  Added for debug
                  DumpWaDetails "CreateLabel!" & desc$
               End If

            If Len(RTrim$(desc$)) > 35 Or (LinesAchieved > 1) Then
                  breakpos = InStr(desc$, "!")
                  If breakpos = 0 Then                                    '11Mar99 TH  Done more elegantly below
                        pos = 30
                        Do
                           breakpos = InStr(pos, desc$, " ")
                           pos = pos - 5
                        Loop While breakpos = 0 And pos > 14
                     End If
                  If breakpos > 0 Then
                        labelline$(1) = Left$(desc$, breakpos - 1)
                        labelline$(2) = Right$(desc$, Len(desc$) - breakpos)
                        plingparse labelline$(2), "!"              '26Aug97 CKJ Added
                        lineno = 3
                     Else
                        'lineno = 2
                        lineno = 3                                       '11Mar99 TH Failsafe :Chop the description in two and put it on the label
                        labelline$(1) = Left$(desc$, 35)                 '    "      previously it was putting nothing on the description line !!!!!!
                        labelline$(2) = Right$(desc$, Len(desc$) - 35)
                        plingparse labelline$(2), "!"
                     End If
                  
                  Longdrugline = 1
               Else
                  Longdrugline = 0
                  plingparse desc$, "!"
                  labelline$(1) = desc$
                  lineno = 2 '7Jul97 ASC
               End If
            
            If Not d.EyeLabel Then '31Jan13 TH This has already been handled (TFS 39777,55068)
               GetRouteExpansion L.route, "", routeword$        '26Jan98 ASC
               'WDir.directs = Trim$(WDir.directs) & routeword$  '    "
               WDir.directs = Trim$(WDir.directs) & " " & routeword$ '17Aug14 TH Added space (TFS 98040)
            End If
            
            LinesWanted = 4 - Longdrugline                               '4 or 3 required
            FormatLabel Trim$(WDir.directs), LinesWanted, 35, FontNumber, Numoflines, TextOut$, L.extralabel
            deflines TextOut$, lines$(), cr, 0, (Numoflines)

            X = Numoflines
            Select Case Numoflines
               Case 1, 2, 3
                  lineno = 3 + Longdrugline
                  
               Case Is > 4 - Longdrugline
                  Numoflines = 4
                  ans$ = RTrim$(WDir.directs)
                  plingparse ans$, Chr$(13)
                  plingparse ans$, Chr$(10)
                  replace ans$, "  ", " ", 0
                  'ReDim lines$(6)   '5jul97 ASC was 5
                  ReDim lines$(12)   '01Jul14 TH Extended Label
                  lines$(0) = ans$
                  X = 0
                  Numoflines = 1
                  Do
                     strlen = Len(lines$(X))
                     If strlen > 35 Then
                           Numoflines = Numoflines + 1
                           For Y = 35 To 0 Step -1
                              If Mid$(lines$(X), Y, 1) = " " Then Exit For
                           Next
                           If Y = 0 Then Y = 34 '19May95 ASC
                           ans$ = lines$(X)
                           lines$(X) = Left$(ans$, Y - 1)
                           lines$(X + 1) = LTrim$(Right$(ans$, strlen - Y))
                           'lineno = lineno + 1 '07jul97 ASC
                        End If
                     X = X + 1
                  'Loop Until lines$(X) = "" Or X > 5  '5Jul97 ASC added x > 5
                  Loop Until lines$(X) = "" Or X > 9 '05Aug14 TH
               
               Case 4
                  lineno = 2
               End Select
               
            Select Case Numoflines '5Jul97 ASC                       '07Sep97 ASC
               Case Is > 4 - Longdrugline: lineno = 2 + Longdrugline '07Sep97 ASC
               Case 1, 2:                  lineno = 3 + Longdrugline
               Case 3:                     lineno = 3                '07Sep97 ASC
               Case 4:                     lineno = 2
               End Select
            
            'If Numoflines > 6 - lineno Then
            If Numoflines > 6 - lineno And Not L.extralabel Then '24Jun14 TH Added extra fencepost
            
               temp = ""
               
               
               For X = 0 To UBound(lines)
                  temp = temp & cr & lines(X) & "[cr]"
               Next
               'clean up
               For X = UBound(lines) To 0 Step -1
                  If Right$(temp$, 5) = cr & "[cr]" Then
                     temp$ = Left$(temp$, (Len(temp$) - 5))
                  Else
                     Exit For
                  End If
               Next
               '----
               'Check here if we are doing second labels
               '04Jan17 TH HOSTED TO DO - check in DB !
               
               'GetRTFTextFromDB dispdata$ & "\extdLbl1.rtf", "", intSuccess  '06Dec16 TH Replaced (TFS 157969)
               'If intSuccess Then GetRTFTextFromDB dispdata$ & "\extdLbl2.rtf", "", intSuccess  '06Dec16 TH Replaced (TFS 157969)
               
               'If fileexists(dispdata$ & "\extdLbl1.rtf") And fileexists(dispdata$ & "\extdLbl2.rtf") And TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "PrintExtendedLabels", 0)) Then
               If RTFExistsInDatabase(dispdata$ & "\extdLbl1.rtf") And RTFExistsInDatabase(dispdata$ & "\extdLbl2.rtf") And TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "PrintExtendedLabels", 0)) Then
               'If intSuccess And TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "PrintExtendedLabels", 0)) Then
               
                  'popmessagecr ".NO ROOM", "There are not enough lines left on the label for these directions" & cr & temp & cr & "Please review and edit manually"
                  If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
                     If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "N", "ShowSecondLabelMsgWithNoEdit", 0)) Then popmessagecr ".NO ROOM", "There are not enough lines left on a single label for these directions" & cr & temp & crlf & crlf & "Now printing over 2 labels"
                     blnExtendedLabel = True
                  Else
                     If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "ShowSecondLabelOptionWithEdit", 0)) Then '05Aug14 TH Changed default
                        If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "DefaultSecondLabelOption", 0)) Then
                           strAns = "Y"
                        Else
                           strAns = "N"
                        End If
                        'Produce a suitable msg
                        strMsg = "There are not enough lines left on the label for these directions" & cr & temp & crlf & crlf & "Do you wish to print over two labels"
                        askwin "?NO ROOM", strMsg, strAns, k
                     Else
                        strAns = "Y"
                     End If
                     If strAns = "Y" Then
                        '24Jun14 TH Here we move to extended label
                        blnExtendedLabel = True
                     End If
                  End If
               End If
               
               '------
            End If
            If blnExtendedLabel Then
               'Here we reset the label to accomodate as much as possible
               'first shift the warnings and final line
               For X = 6 To 10
                  labelline$(X + 6) = labelline$(X)
               Next
               For X = lineno To 11
                  labelline$(X) = ""
               Next
               '12Jul14 TH only use the used parts of the array
               intCeiling = UBound(lines)
               For X = UBound(lines) To 0 Step -1
                  If Trim$(lines(X)) = "" Then
                     intCeiling = intCeiling - 1
                  Else
                     Exit For
                  End If
               Next
                  
               'Now add full directions
               If intCeiling > 8 And Trim$(labelline$(2)) = "" Then '05Aug14 TH
                  'see if we can get some space
                  For X = 0 To intCeiling
                     labelline$(X + lineno) = lines(X)
                     If X > 13 Then Exit For '05Aug14 TH
                  Next
                  If intCeiling > 9 Then blnDirectionsTooLarge = True   '05Aug14 TH
                  
               Else
                  For X = 0 To intCeiling
                     labelline$(X + lineno + 1) = lines(X)
                     If X > 13 Then Exit For '05Aug14 TH
                  Next
                  If intCeiling > 8 Then blnDirectionsTooLarge = True
               End If
               'Cant fit - then test if we can "shuffle up" on blank line
               'if two labels busted warn again
               If blnDirectionsTooLarge Then
                  If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
                     popmessagecr ".NO ROOM", "There are not enough lines left on the extended labels for these directions" & cr & temp & cr & cr & "This item cannot be dispensed. Please review the prescription"
                     'Close down control
                     lblUC("DoAction").Caption = "RefreshState-Inactive-Connected"
                     Exit Sub
                  Else
                     popmessagecr ".NO ROOM", "There are not enough lines left on the extended labels for these directions" & cr & temp & cr & cr & "Please review and edit manually"
                  End If
               End If
               ExtendedLabelFromLoad
            Else
               For X = 0 To (Numoflines - 1) '11Jun97 KR changed.
                  labelline$(lineno + X) = Trim$(lines$(X)) '30May95 ASC was ltrim$
               Next
               If lineno < 5 Then lineno = lineno + 1
            End If
            
            done = True
         End If

      'In-Patient style Label
      '----------------------
      If Not done Then
         If InStr(plvl$("InPatLabel"), L.IssType) Then
                        ' XN 1May15 98073 If inpatient and LabelDescriptionInpatient is set then user this alternate description
                        'If TradenameAppend Then
                        '       deflines Trim$(d.Description) & " (" & Trim$(d.tradename) & ")", labelline$(), "!", 1, Numoflines
                        'Else
                        '       deflines d.Description, labelline$(), "!", 1, Numoflines
                        'End If

                        ' XN 1May15 98073 If LabelDescriptionOutPatient is set then user this alternate description
                        'Any changes to the logic here should be also reflected in PATMED.BAS FillHeapLabelInfo for the lLabelDrugDescription
                        If Trim$(d.LabelDescriptionInPatient) <> "" And Not (gDisableLabelDescriptionAlternative) Then
                                        desc$ = Trim$(d.LabelDescriptionInPatient)
                        Else
                                        desc$ = Trim$(d.LabelDescription)
                        End If

                        If TradenameAppend Then
                                        desc$ = desc$ & " (" & Trim$(d.tradename) & ")"
                        End If
                        deflines desc$, labelline$(), "!", 1, Numoflines
            
            If Numoflines > 2 Then labelline$(5) = labelline$(3) Else labelline$(5) = ""
            If Numoflines > 1 Then labelline$(3) = labelline$(2) Else labelline$(3) = ""
            labelline$(2) = ""
            labelline$(4) = ""
            done = True
         End If
      End If

      'CIVAS label
      '-------------
      If Not done Then
         If InStr(plvl$("CIVASLabel"), L.IssType) Then
         
            blnCIVASlblUseRouteAdmin = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "Y", "CIVASlblUseRouteAdmin", 0)) '07Jan14 TH (TFS 80018)
            
            For X = 2 To 5
               labelline$(X) = ""
            Next
            'deflines d.Description, labelline$(), "!", 1, Numoflines  XN 4Jun15 98073 New local stores description
            deflines d.LabelDescription, labelline$(), "!", 1, Numoflines
            Wrapto35chars (labelline$(1)), labelline$(1), namepart2$   '13Jun98 ASC
            ' Lines 1 & 2
            NameOfUnits (L.dose(DoseNum)), Form$
            '20Jul98 EAC handle fractions correctly
            'doseandunits$ = LTrim$(Str$(l.dose(Dosenum))) + form$
            'If L.dose(DoseNum) = Int(L.dose(DoseNum)) Then
            If intSyringelabel > 0 Then
               If getSyringeLabelDose(intSyringelabel) = Int(getSyringeLabelDose(intSyringelabel)) Then
                  formatting$ = "#;0"
               Else
                  formatting$ = "0.##;0"
               End If
               temp$ = Format$(getSyringeLabelDose(intSyringelabel), formatting$)
            Else
               If CIVASDoseIncStat(L.dose(DoseNum)) = Int(CIVASDoseIncStat(L.dose(DoseNum))) Then '24Feb10 TH (F78659) Now also foramt stat doses correctly.
                  formatting$ = "#;0"
               Else
                  formatting$ = "0.##;0"
               End If
               
               'temp$ = Format$(l.dose(DoseNum), formatting$)
               temp$ = Format$(CIVASDoseIncStat(L.dose(DoseNum)), formatting$)
            End If
            '19 Use new function to replace block below
            '17Jun08 TH Added block - black hat kludge to derive a dose on a stat item. (F0025724)
            'If l.dose(DoseNum) = 0 And (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
            '   'If stat derive a dose from the direction code
            '   intSlash = InStr(txtUC("TxtDircode").text, "/")
            '   If intSlash > 0 Then
            '      temp$ = Format$(Left$(txtUC("TxtDircode").text, intSlash - 1), formatting$)
            '   End If
            'End If
            '------------------------
            
            doseandunits$ = Format$(temp$) + Form$
            
            hashpos = InStr(labelline$(1), "#")
            If hashpos Then
                  labelline$(1) = Left$(labelline$(1), hashpos - 1) + doseandunits$ + Mid$(labelline$(1), hashpos + 1)
                  doseandunits$ = ""
               End If
            'namepart2$ = ""
            pipepos = InStr(labelline$(1), "|")  ' 2Feb95 CKJ Added
            If pipepos Then                      ' insert CR at | position
                  namepart2$ = Mid$(labelline$(1), pipepos + 1) + " "
                  labelline$(1) = Left$(labelline$(1), pipepos - 1)
               End If
            Select Case Trim$(UCase$(L.route))   '13Jun98 ASC originally designed for CIVAS now being used for Bladder installations etc
               Case "IV", "IM", "SC", "IT", "IO", "IA", "EPI", "IP", "ID", "SM", "IC"                                            '13Jun98 ASC
                  If L.InfusionTime > 5 Then administer$ = " INFUSION" Else administer$ = " INJECTION"      '20Jan95 CKJ
                  routeinj$ = UCase$(RTrim$(L.route)) + administer$
               End Select
            If intSyringelabel > 0 Then
               labelline$(2) = LTrim$(doseandunits$ + " in " + Format$(getSyringeLabelVolume(intSyringelabel)) & "ml")
            Else
               labelline$(2) = LTrim$(doseandunits$ + " in " + Strz$(L.finalvolume) + "ml")
            End If
            Wrapto35chars (labelline$(1)), labelline$(1), strExtra   '16Jun08 TH Added (F0025858)
            If namepart2$ = "" Then                                  '    "
               namepart2$ = strExtra                                 '    "
            Else                                                     '    "
               namepart2$ = strExtra & " " & namepart2$              '    "
            End If                                                   '    "
            
            If Len(labelline$(1)) < 24 And namepart2$ = "" Then
               If blnCIVASlblUseRouteAdmin Then labelline$(1) = labelline$(1) + " " + routeinj$ '07Jan14 TH Remove routeinj if required (TFS 80018)
            Else
               'If Trim$(routeinj$) <> "" Then namepart2$ = namepart2$ & " " '16Jun08 TH Added
               If Trim$(routeinj$) <> "" And blnCIVASlblUseRouteAdmin Then namepart2$ = namepart2$ & " " '07Jan14 TH Added
               If blnCIVASlblUseRouteAdmin Then
                  labelline$(2) = namepart2$ + routeinj$ + " " + labelline$(2)
               Else
                  labelline$(2) = namepart2$ + " " + labelline$(2) '07Jan14 TH Remove routeinj if required (TFS 80018)
               End If
            End If

            strExtra = ""
            Wrapto35chars (labelline$(2)), labelline$(2), strExtra   '16Jun08 TH Added
            ' Line 3
            reconvolume! = L.finalvolume  'assume equal until checked
            'If l.dose(1) > 0 And d.mgPerml > 0 And d.dosesperissueunit > 0 Then
            '19Jun08 TH Replaced block with new function
            If CIVASDoseIncStat(L.dose(1)) > 0 And d.mgPerml > 0 And d.dosesperissueunit > 0 Then
            
               'reconvolume! = (L.dose(1) / d.dosesperissueunit) * (L.ReconVol + d.DisplacementVolume)
               reconvolume! = (CIVASDoseIncStat(L.dose(1)) / d.dosesperissueunit) * (L.ReconVol + d.DisplacementVolume) '25Jun08 TH replacde above (F0026937)
            'ElseIf l.dose(1) = 0 And (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
            '   intSlash = InStr(txtUC("TxtDircode").text, "/")
            '   If intSlash > 0 Then
            '      statdose! = Val(Left$(txtUC("TxtDircode").text, intSlash - 1))
            '   End If
            '   reconvolume! = (statdose! / d.dosesperissueunit) * (l.ReconVol + d.DisplacementVolume)
            End If
            Tolerance! = Val(plvl$("CIVASmlsTolerance")) '9Mar95 CKJ added, suggest 0.05 ml
            Select Case L.finalvolume - reconvolume!
               Case Is > Tolerance!    'diluted
                  If RTrim$(L.DiluentAbbr) <> "" Then
                     If strExtra <> "" Then
                        labelline$(3) = strExtra & plvl$(RTrim$(L.DiluentAbbr))
                     Else
                        labelline$(3) = plvl$(RTrim$(L.DiluentAbbr))
                     End If
                  Else
                     labelline$(3) = strExtra
                  End If
               Case Is < -Tolerance!   'not valid? recon vol > final vol
                  popmessagecr "#WARNING", "Final volume is less than reconstitution volume"
                  'labelline$(3) = "" '!!**
                  labelline$(3) = strExtra   '16Jun08 TH Added
               Case Else               'equal to within 0.001 ml
                  If RTrim$(L.ReconAbbr) <> "" And plvl$("CIVASlblPrintRecon") <> "N" Then
                     If strExtra <> "" Then
                        labelline$(3) = strExtra & " " & plvl$(RTrim$(L.ReconAbbr))    '16Jun08 TH Added
                     Else
                        labelline$(3) = plvl$(RTrim$(L.ReconAbbr))    '9Mar95 CKJ Added switch
                     End If
                  Else
                     labelline$(3) = strExtra
                  End If
               End Select

            ' Line 4
            If L.InfusionTime > 5 Then
               administer$ = TxtDPatmed("Infuse", "CivasInfuse", OK)
               If L.InfusionTime > 0 And plvl$("PrintInfusionRate") <> "N" Then
                  temp2$ = Format$((L.finalvolume / L.InfusionTime) * 60, "###0.##")
                  If ReadLanguage(10, 0) = 852 Then
                     infuse$ = TxtDPatmed("Hourlyc ", "DurHourly", OK) & Format$(temp2$) & TxtDPatmed(" ml/hr.", "CivasMl/hr", OK) & " "
                  Else
                     infuse$ = TxtDPatmed("(", "CivasAt", OK) & Format$(temp2$) & TxtDPatmed("ml/hr)", "CivasMl/hr", OK)  '24Sep98 TH '09Jun00 JN Amended - see event 21230
                  End If
               End If
            Else
               administer$ = TxtDPatmed("Inject", "CivasInject", OK)
               infuse$ = ""
            End If
            
            If L.InfusionTime > 0 Then
                  If ReadLanguage(10, 0) = 852 Then
                        labelline$(4) = infuse$ & administer$ & TxtDPatmed(" over", "CivasOver", OK)
                     Else
                        labelline$(4) = administer$ & TxtDPatmed(" over", "CivasOver", OK)
                     End If
                  If L.InfusionTime Mod 60 = 0 Then
                        Hrs = L.InfusionTime \ 60
                        If ReadLanguage(10, 0) = 852 Then
                              labelline$(4) = labelline$(4) & Str$(Hrs) & TxtDPatmed(" hour", "DurHour", OK) & plural$((Hrs))
                           Else
                              labelline$(4) = labelline$(4) & Str$(Hrs) & TxtDPatmed(" hour", "DurHour", OK) & plural$((Hrs)) & infuse$
                           End If
                     Else
                        If ReadLanguage(10, 0) = 852 Then
                              labelline$(4) = labelline$(4) & Str$(L.InfusionTime) & TxtDPatmed(" mins", "DurMin", OK)
                           Else
                              labelline$(4) = labelline$(4) & Str$(L.InfusionTime) & TxtDPatmed(" mins", "DurMin", OK) & infuse$
                           End If
                     End If
               Else
                  labelline$(4) = ""
               End If

            ' Line 5
            labelline$(5) = TxtDPatmed("", "CIVASlbltxt", OK)

            '2Feb95 CKJ Use direction code
            If labelline$(5) = "" And Trim$(d.dircode) <> "" Then
''                  WDir.Code = d.dircode
                  getdir (d.dircode), (pid.ward), found&, WDir
                  If found& Then
                        deflines (WDir.directs), lines$(), Chr$(13), 0, Numoflines
                        labelline$(5) = lines$(0)
                     End If
               End If
            If labelline$(5) = "" Then                              '13Jun98 ASC Puts route on if direction codes and CIVASlbltxt not used which I do not think they should be
                  GetRouteExpansion Trim$(L.route), "", routeword$  '     "
                  labelline$(5) = routeword$                        '     "
               End If                                               '     "
            done = True
         End If
      End If

      If Not done Then
         popmessagecr "WARNING", "Issue type not defined for label creation"
      Else
         If intSyringelabel = 0 Then LabelAmended = True
      End If
   End If
   
   If intSyringelabel = 0 Then DisplaytheLabel 1, False, k, "", 0, 0      '07Sep97 makes sure warnings are re-displayed if not on label for this label status at present.   '01Jun02 All/CKJ ! Should it be?

   
End Sub

Function DescriptionSplitLine() As Integer

'16Feb00 AE  Return the line number of the directions split, if used.
'            This is held in the module level iLblSplit

Dim iValue As Integer

   iValue = 0
   If TxtD(dispdata$ & "\patmed.ini", "", "N", "HighlightPMRDescriptionLines", 0) = "Y" Then
         iValue = iLblSplit
      End If

   DescriptionSplitLine = iValue


End Function

Sub DisplaytheLabel(ByRef NumofLabels As Integer, ByRef PrintOutput As Integer, k As kbdcontrol, ByVal expiry As String, ByVal intLabelCount As Integer, ByVal blnExtraLabel As Boolean, Optional ByVal copies As Long = 1)
'--------------------------LABEL PRINTING ROUTINE-----------------------------
'17JUL96 KR  Added printing of batch number & expiry if required (Wansbeck).
'03Mar97 KR  Added check for presence of pigeonholes before printing.
'24Mar97 KR  Print cost on label if setup in ini file & inpatients - Cheviot & Wansbeck
'20Jun97 KR  Now print prescription id on the label, not the labelpointer
'26Aug97 CKJ added l.prescriptionid to the expiry line for NZ,
'            to use add PrintRxNumOnLabel="IODLC" to patmed.ini
'16Jan98 CKJ Added RTF support. Context is 'DispLabel', file is 'DispLbl.rtf',
'            items are 'StdLbl1A' to 'StdLbl10A', 'StdLbl4B' to 'StdLbl6B'
'            plus any standard ones
'25Jan98 CKJ PrintSpecialtyOnLabel added, and last line not limited to 36 chars
'10Feb98 CKJ Amended PrintSpecialtyOnLabel to show (Ward Cons Caseno) or (Ward ConsSpec Caseno)
'25May98 CFY/ASC Removed hash symbol which preceded the prescription number and replaced
'                with 'No. ' if there is room.
'20Jul98 EAC make RTF label printing language aware
'20Jul98 EAC FillHeapDrugInfo added for HK mods
'13Aug98 EAC HK Merge
'11Sep98 CFY Call to reprintfile added after the label has been created. This creates a copy of the
'            label for reprinting later if required.
'05Oct98 CKJ Added call to FormatLabel
'13Nov98 EAC HK Mod to show full HK Hospital Number on the label
'20Nov98 CKJ/CFY Call to Buildname: Added True to shorten name
'21Apr99 TH/CKJ Changed precedence in bit checking of l.flags
'04Jun99 CKJ Added label format character to displbl.rtf
'04Jun99 SF  added patient billing mods
'18Oct99 CFY Now adds PrescriberID to print heap
'16Feb00 AE  Various enhancements for WA. Individual context for each label type,
'            also allow up to 26 label types to be stored against the drug or issue type
'04May00 EAC Correct the handling of labels with modified instructions/warnings
'*16May00 SF returns either cons code or prescriber code
'23Jun00 JN  Added line to show issue number if PrintRxNumonLabel is set to show i.e. "IDLC" - not for outpatients
'23Jun00 JN  Show Rx Issue Number (l.batchnumber) - not for outpatients - see event 42154
'02Aug00 MMA Added: Global update for Teamwork
'10Oct00 AW  Added code to parse description on label - malaysia teamwork
'16Nov00 SF  PBS V2 mods
'12Feb01 AW  Commented out line to parse l.text description
'30Apr01 JN  Added code to manage new Patmed.ini setting 'BNOnLabel' which when set is a caption to prefix the batchnumber on a label
'21Jan02 TH  Mod to properly cope with altered (blank selected) instructions/warnings  (#51791)
'04Mar02 TH  Added Parameter to Reprint call (#MOJ#)
'10Feb03 TH  Replaced bitwise logic of a couple of conditions using instr calls
'25Jun12 CKJ Added Alternative Labels
'06Jan13 TH  Added label count parameter to handle storage of CIVAS labels (sets)
'02Aug16 XN  Added copies count as parameter 159413
'12Jan17 TH  Refactored for DB RTF Handling (Hosted)

'Printoutput = 0  screen
'              3  printer


Dim printcost%, found%
Dim tmp$
Dim TempCaseNo$, success%
Dim PatBillStub%
Dim OK As Integer, sLblFile As String, sSuffix As String
Dim count As Integer, Form$, xx As Integer, tmpCode$, Instruct$, allsmall As Integer, allmedium As Integer, lint As Integer, ans$
Dim FontNumber As Integer, LinesAchieved As Integer, TextOut$, temptype As Integer, X As Integer, warn$, freeline As Integer
Dim spaced As Integer, PatientName$, lastline$
Dim temp As String, iLoop As Integer
Dim strDesc As String '05Mar10 TH Added (F0078677)
Dim intSplitLine As Integer, intloop As Integer '05Mar10 TH Added (F0078677)
Dim strLabel As String
Dim AltLabelContext As String
Dim strReprintMarker As String   '21Jan13 TH (TFS 51163)
Dim ExtCnt, totCnt As Integer '17Jun14 TH
Dim intSuccess As Integer  '08Jan17 TH Added

'debug
Dim sLines() As String

   ReDim lines$(5)
   k.escd = False

   If d.SisCode <> L.SisCode Then  'ASC 17Jul94
         BlankWProduct d
         'd.Description = "*** Issue item not defined ***"  XN 4Jun15 98073 New local stores description
                 d.LabelDescription = "*** Issue item not defined ***"
                 d.DrugDescription = "*** Issue item not defined ***"
         d.SisCode = L.SisCode
         getdrug d, 0, 0, False
      End If

   If PrintOutput < 3 Then  ' screen
         NumofLabels = 1
      Else  'Printer
         If GetRobotPrintLabelMessageID() > 0 Then   '09oct06 CKJ '24Dec09 CKJ reinstated from V8, as had been removed in conversion
            NumofLabels = 1                                       '   "
         End If                                                   '   "
      
      End If

   If Not k.escd Then
         For count = 1 To 10
            Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "A", "", 0      'clear out the heap
            Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "B", "", 0
         Next
         
         For count = 1 To 14 '05Aug14 TH
            Heap 10, gPRNheapID, "ExtLbl" & Format$(count) & "A", "", 0      'clear out the heap
         Next
         
         FillHeapDrugInfo gPRNheapID, d, 0
         FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0, True '30Jun17 TH Use cached ward if (TFS 191443)
         FillHeapLabelInfo gPRNheapID, L, 0
         
         '21Jan13 TH Reprint marker (TFS 51163)
         Heap 12, gPRNheapID, "*", "", 0 'Ensure this is NOT on the heap
                  
         'Print the label
         '---------------
         Form$ = LCase$(d.PrintformV)
         For xx = 1 To NumofLabels
            tmpCode$ = Trim$(L.RevisedInstruction)
            If Len(tmpCode$) Then
               replace tmpCode$, Chr$(161), " ", 0
            Else
               tmpCode$ = d.inscode
            End If
            If Trim$(tmpCode$) <> "" Then GetInsCode Trim$(tmpCode$), Instruct$ '29Jun17 TH Dont get expansion if we dont have a code (TFS 191443)

            ParseL Instruct$, PrintOutput, 1, False  '17Jun14 TH Added Param            '1
            printl Instruct$, PrintOutput, 0, Form$, k.escd                             '1
            
            If PrintOutput = 0 Then labelline$(0) = Form$

            'Stops a mixture of typefaces within the directions
            '--------------------------------------------------
            allsmall = False
            allmedium = False
            For lint = 3 To (Iff((L.extralabel Or blnExtraLabel), 11, 5)) '05Aug14 TH
               ans$ = RTrim$(labelline$(lint))
               If Len(ans$) > 23 Then allsmall = True: Exit For
               If Len(ans$) > 20 Then allmedium = True
            Next
            printcost% = False
            'Print costs on label in directions space if inpatient and if set to print in ini file.
            '24Mar97 KR Added
            If L.IssType = "I" And PrintOutput = 3 Then           '05Oct98 CKJ Moved outside loop
               If InStr(plvl$("OutPatLabel"), "I") = 0 Then
                  If UCase$(TxtD(dispdata & "\" & "patmed.ini", "", "", "CostsOnLabel", found)) = "Y" Then '22Mar97 KR added
                     printcost = True
                  End If
               End If
            End If
               
            '05Oct98 CKJ Place a call to FormatLabel if doRTF to decide on font size...
            '            May choose to do this in two parts, 1&2, 3-5
            '10nov05 CKJ If fonts is 0 then the trailing cr causes 6 lines to be reported
            tmp$ = labelline$(1)
            If (L.extralabel Or blnExtraLabel) Then
               For lint = 2 To 11
                  tmp$ = tmp$ & crlf & labelline$(lint)
               Next
               FormatLabel tmp$, 11, 35, FontNumber, LinesAchieved, TextOut$, True
               If LinesAchieved > 11 Then
                  temp = ""
                  For iLoop = 1 To LinesAchieved   'UBound(labelline)   10Nov05 CKJ
                     temp = temp & cr & "   " & Format$(iLoop) & "|  " & labelline(iLoop) & "[cr]"
                  Next
                  popmessagecr ".NO ROOM", " Warning - Unable to fit entire text onto label" & cr & temp & cr & cr & "Please review and edit manually"
               End If
   
               '12Feb01 AW commented out line below
               'ParseEndDirMarker l.Text, Chr$(LBL_END_DESC), Chr$(30), iLblSplit                     '10Oct00 AW added
               For lint = 1 To 11 '05Aug14 TH
                  temptype = PrintOutput
                  If allmedium And PrintOutput = 3 Then PrintOutput = 6
                  If allsmall And PrintOutput = 3 Then PrintOutput = 5
                  If lint = 4 And printcost% Then
                     tmp$ = money$(5) & (Format$(LabelCost!, "###0.00"))
                  Else
                     tmp$ = labelline$(lint)
                  End If
                  printl tmp$, PrintOutput, lint, Form$, k.escd                            '2-6
                  ParseL tmp$, -(FontNumber%), lint + 1, False   '17Jun14 TH Added Param   '2-6
                  FillHeapLabelText gPRNheapID, labelline$(), iLblSplit, 15                      '16Feb00 AE
                  If PrintOutput = 0 Then labelline$(lint) = Form$
                  PrintOutput = temptype
               Next
            Else
               For lint = 2 To 5
                  tmp$ = tmp$ & crlf & labelline$(lint)
               Next
               FormatLabel tmp$, 5, 35, FontNumber, LinesAchieved, TextOut$, False
               If LinesAchieved > 5 Then
                  temp = ""
                  For iLoop = 1 To LinesAchieved   'UBound(labelline)   10Nov05 CKJ
                     temp = temp & cr & "   " & Format$(iLoop) & "|  " & labelline(iLoop) & "[cr]"
                  Next
                  popmessagecr ".NO ROOM", " Warning - Unable to fit entire text onto label" & cr & temp & cr & cr & "Please review and edit manually"
               End If
   
               '12Feb01 AW commented out line below
               'ParseEndDirMarker l.Text, Chr$(LBL_END_DESC), Chr$(30), iLblSplit                     '10Oct00 AW added
               For lint = 1 To 5
                  temptype = PrintOutput
                  If allmedium And PrintOutput = 3 Then PrintOutput = 6
                  If allsmall And PrintOutput = 3 Then PrintOutput = 5
                  If lint = 4 And printcost% Then
                     tmp$ = money$(5) & (Format$(LabelCost!, "###0.00"))
                  Else
                     tmp$ = labelline$(lint)
                  End If
                  printl tmp$, PrintOutput, lint, Form$, k.escd                            '2-6
                  ParseL tmp$, -(FontNumber%), lint + 1, False   '17Jun14 TH Added Param   '2-6
                  FillHeapLabelText gPRNheapID, labelline$(), iLblSplit, 5                      '16Feb00 AE
                  If PrintOutput = 0 Then labelline$(lint) = Form$
                  PrintOutput = temptype
               Next
            End If
            '03Mar09 TH Added (F0078677) '19Mar10 TH Moved to worksheet printing
            'strLabel = L.text
            'ParseEndDirMarker strLabel, Chr$(LBL_END_DESC), Chr$(LBL_END_LINE), intSplitLine
            'Heap 12, gPRNheapID, "LblDescRaw", "", 0
            'strDesc = ""
            'For intloop = 1 To 5
            '   If intloop <= intSplitLine Then
            '      strDesc = strDesc & labelline$(intloop) & Iff(Right$(labelline$(intloop), 1) = " ", "", " ")
            '   End If
            'Next
            ''Parse out the end of line characters for the raw text items, and replace with spaces
            'replace strDesc, Chr$(LBL_END_LINE), " ", 0
            'Heap 10, gPRNheapID, "LblDescRaw", strDesc, 0
            '----------------
            
            If InStr(plvl$("Warning2"), L.IssType) Then    '20Mar95 CKJ added
               GetWarCode d.warcode2, warn$     ' i/p
            Else
               GetWarCode d.warcode, warn$      ' o/p
            End If

            ReDim lines$(5)
            tmpCode$ = Trim$(L.RevisedWarning)
            If Len(tmpCode$) Then                                                      ' manual choice
               replace tmpCode$, Chr$(161), " ", 0                                  ' deliberately blank
            Else
               tmpCode$ = d.warcode                                                 ' o/p
               If InStr(plvl$("Warning2"), L.IssType) Then tmpCode$ = d.warcode2    ' i/p
            End If
            GetWarCode Trim$(tmpCode$), warn$

            If warn$ <> "" Then
               deflines warn$, lines$(), Chr$(30), 0, 0
            End If

            'space warnings
            '---------------
            freeline = -1
            spaced = False
            For X = 0 To 2
               If LTrim$(RTrim$(lines$(X))) = "" Then
                  If X = 0 Then spaced = True
                  freeline = X
               End If
            Next

            If freeline = 2 And Not spaced Then
               For X = freeline To 1 Step -1
                  lines$(X) = lines$(X - 1)
               Next
               lines$(0) = ""
            End If
            
            If Len(expiry$) > 0 Then
               lines$(3) = plvl$("DoNotUseAfter") & expiry$      '20Jan95 CKJ  "DO NOT USE AFTER: "
               If GlobalManufBatchNum$ <> "" Then                '23Sep96 CKJ Pragmatic Solution - temporary !!**
                  lines$(3) = lines$(3) & " " & Trim$(TxtD(dispdata$ & "\PATMED.INI", "", "", "BNOnLabel", found))    '30Apr01 JN Added BN: switch - if present in .ini file, prefix is added to batch number (event 50602)
                  lines$(3) = lines$(3) & GlobalManufBatchNum$
               End If
            End If

            'If printing batch numbers on label, prompt for number & expiry
            If BatchLabel = "Y" Then
               If Exdate$ <> "" And BatchNo$ <> "" Then
                  lines$(3) = plvl$("DoNotUseAfter") & Exdate$ & " BN: " & BatchNo$
               End If
            End If
            
'>>            If automation$ <> "" Then  '20Apr96   KR  Added Checks for automation
'>>                  If UCase$(UsePigeon$) = "Y" Then    '03Mar97 KR added
'>>                        If Hole% > 0 And PrintHoleNumber Then
'>>                              lines$(3) = "H" & Str$(Hole%) & ": " & lines$(3) '!!** KR
'>>                           End If
'>>                     End If
'>>               End If
            
            If (InStr(plvl$("PrintBatchNumber"), L.IssType) > 0) Or (InStr(plvl$("PrintRxNumOnLabel"), L.IssType) > 0) Then '10Feb03 TH Replaced above
               'tmp$ = " [#" & Format$(l.prescriptionid) & "]"                '25May98 CFY/ASC Replaced block below
               If gStdLbl10PreDone Then
                 Heap 11, gPRNheapID, "stdlbl10AFrigFrig", tmp$, 0
               ElseIf Len(lines$(3)) + Len(Format$(L.PrescriptionID)) > 35 Then   '                "
                  tmp$ = " " & Format$(L.PrescriptionID)                   '                "
               Else                                                        '                "
                  tmp$ = " No." & Format$(L.PrescriptionID)                '                "
                  'If InStr(plvl$("PrintRxNumonLabel"), l.IssType) And l.batchnumber > 0 Then  '23Jun00 JN Drop batch number here where it should fit
                  If (InStr(plvl$("PrintRxNumonLabel"), L.IssType) > 0) And L.batchnumber > 0 Then  '10Feb03 TH Replaced above
                     tmp$ = tmp$ & "/" & Format$(L.batchnumber)
                  End If
               End If                                                      '                "
               'If Len(lines$(3)) + Len(tmp$) < 35 Then    'No point padding, printl trims it
               '      lines$(3) = lines$(3) & String$(35 - Len(lines$(3)) - Len(tmp$), " ")
               '   End If
               PatBillStub% = billpatient(7, tmp$)      '04Jun99SF added to append the repeat number
               lines$(3) = lines$(3) & tmp$
            End If

            Form$ = LCase$(d.PrintformV)
            For X = 0 To 3
               printl lines$(X), PrintOutput, lint, Form$, k.escd                       '7-10
               ParseL lines$(X), PrintOutput, lint + 1, False    '17Jun14 TH Added Param   '7-10
               If PrintOutput = 0 Then   '        x =  0 1 2 3
                  If (L.extralabel Or blnExtraLabel) Then
                     If lint < 15 Then
                        labelline$(lint) = Form$
                     Else
                        labelline$(16) = Form$
                     End If
                  Else
                     If lint < 9 Then    ' warnings on 6 7 8 9
                        labelline$(lint) = Form$
                     Else
                        'plingparse form$, "°"
                        labelline$(10) = Form$   ' expiry onto 10
                     End If
                  End If
               End If
               lint = lint + 1
            Next

            buildname pid, True, PatientName$                               '13Aug98 EAC updated parameters '20Nov98 CKJ/CFY Added True to shorten name
            tmp$ = ReplaceConsWithRxer$()                                                          '16May00 SF returns either cons code or prescriber code
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "PrintSpecialtyOnLabel", 0)) Then
               tmp$ = tmp$ & trimz(pidExtra.Speciality)        '26sep05 CKJ trim to trimz
            End If
            
            '13Nov98 EAC Display full case no on label for HK
            TempCaseNo$ = Trim$(pid.caseno)
''            If OCXlaunch() Then Heap 11, gPRNheapID, "OCXHospNum", TempCaseNo$, success%
            lastline$ = PatientName$ & " (" & Trim$(pid.ward) & " " & Trim$(tmp$) & " " & TempCaseNo$ & ")"

            Select Case PrintOutput
               Case 0
                  labelline$(IIf((L.extralabel Or blnExtraLabel), 15, 9)) = lastline$ '05Aug14 TH
               'CASE 1, 2
                  'PRINT lastline$;  ' no longer needed in form based prog
               Case Else             ' to printer
                  printl lastline$, PrintOutput, lint, Form$, k.escd                    '11
               End Select
            ParseL lastline$, PrintOutput, lint + 1, False    '17Jun14 TH Added Param   '11

            If k.escd Then Exit For
            
            If PrintOutput > 2 Then
               Heap 10, gPRNheapID, "rxid", L.PrescriberID, 0                                                        '18Oct99 CFY Added
                              
               AltLabelContext = GetAltLabelContext()                                        '25Jun12 CKJ Added Alternative Labels
               If Len(AltLabelContext) Or L.extralabel Or blnExtraLabel Then
               
                  If (L.extralabel Or blnExtraLabel) Then   '17Jun14 TH Extra labels - we will make extralabels a sort of lockedd down alternative labe;
                     'OK, now we need to do the smart stuff.
                     'Count through the variable bits of the label, remove any blanks lines (really ? Warnings ?? Readability ? maybe just in directions - check)
                     'Do just Directions for now as this is the sour to launch the functionality proper.
                     ExtCnt = 11  '05Aug14 TH Now reduce labels to 10 lines
                     For lint = 11 To 1 Step -1  '05Aug14 TH Now reduce labels to 10 lines
                        If Trim$(labelline$(lint)) <> "" Then
                           totCnt = lint + 1
                           Exit For
                        End If
                     Next
                     'Clean the heap
                     For count = 1 To 12 '05Aug14 TH Now reduce labels to 10 lines
                        Heap 10, gPRNheapID, "ExtLbl" & Format$(count) & "A", "", 0      'clear out the heap
                     Next
                     ExtCnt = totCnt
                     'Once we have thinned labelline, we will then need to reverse, so that the elements are filled descending from the last line on label two
                     'Put the warnings on - should already be there
                     For lint = 14 To 12 Step -1
                        ParseL labelline$(ExtCnt - 1), -(FontNumber%), lint - 2, True '17Jun14 TH Pass in fontnumber from calipers upstairs
                        ExtCnt = ExtCnt - 1
                     Next
                     For lint = (totCnt - 3) To 1 Step -1  'Pick up from the 6 above 'Now utilise 2 lines for other use
                     
                        ExtCnt = ExtCnt - 1 '***Moved above
                        ParseL labelline$(ExtCnt), -(FontNumber%), lint, True    '17Jun14 TH Pass in fontnumber from calipers upstairs
                        If ExtCnt = 0 Then Exit For
                    Next
                     
                     'Debug Heap 100, gPRNheapID, "", "", 0
               
                     'ParseThenPrint "DispLabel", dispdata$ & "\ExtdLbl.rtf", 1, 0, False '11Aug14 TH
                     ParseThenPrint "DispLabel", dispdata$ & "\ExtdLbl.rtf", 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)
                  Else
                     'ParseThenPrint AltLabelContext, dispdata$ & "\" & AltLabelContext & ".rtf", 1, 0, False     'Note: No reprint stored
                     ParseThenPrint AltLabelContext, dispdata$ & "\" & AltLabelContext & ".rtf", 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)
                  End If
               Else                                                                          'standard labelling
                  sSuffix = ""
                  sLblFile = ASCFileName("DispLbl", False, "")
                  
                  'Use drug-specific format if defined
                  If Trim$(d.labelformat) <> "" Then
                     sSuffix = Trim$(d.labelformat)
                     
                     'If Not fileexists(sLblFile & sSuffix & ".rtf") Then sSuffix = ""
                     If Not RTFExistsInDatabase(sLblFile & sSuffix & ".rtf") Then sSuffix = "" '12Jan17 TH refactored for DB RTF Handling (Hosted)
                     'GetRTFTextFromDB sLblFile & sSuffix & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                     'If Not intSuccess Then sSuffix = ""

                  End If
                  
                  'look for a format defined for this label type if defined
                  If sSuffix = "" Then
                     sSuffix = TxtD(dispdata$ & "\patmed.ini", "", "", "DispLblSuffix" & Trim$(L.IssType), OK)
                  End If
                  
                  'If the desired layout file does not exist, default to standard displbl.rtf
                  'If Not fileexists(sLblFile & sSuffix & ".rtf") Then
                  If Not RTFExistsInDatabase(sLblFile & sSuffix & ".rtf") Then '12Jan17 TH  Refactored for DB RTF Handling (Hosted)
                  'GetRTFTextFromDB sLblFile & sSuffix & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                  'If Not intSuccess Then
                     
                     sSuffix = ""
                     
                     'If Not fileexists(sLblFile & ".rtf") Then
                     If Not RTFExistsInDatabase(sLblFile & ".rtf") Then '12Jan17 TH  Refactored for DB RTF Handling (Hosted)
                     

                     'GetRTFTextFromDB sLblFile & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                     'If Not intSuccess Then
                        tmp$ = "WARNING! Default Label Layout File" & cr$
                        tmp$ = tmp$ & sLblFile & ".rtf is missing." & cr$
                        tmp$ = tmp$ & "Cannot print dispensary labels!"
                        popmessagecr ".EMIS Health", tmp$
                        Exit Sub
                     End If
                  End If
   
                  If billpatient(13, "") Then      '16Nov00 SF now deals with PBS label printing
                     'ParseThenPrint "PBSLabel" & sSuffix, ASCFileName("PBSLbl", False, "") & sSuffix & ".rtf", 1, 0, True '27May11 TH Added param (F0088129)
                     'ParseThenPrint "PBSLabel" & sSuffix, ASCFileName("PBSLbl", False, "") & sSuffix & ".rtf", copies, 0, True ' 02Aug16 XN  159413 number of copies now parameter
                     ParseThenPrint "PBSLabel" & sSuffix, ASCFileName("PBSLbl", False, "") & sSuffix & ".rtf", copies, 0, True, False '04Jan17 TH Use DB parsing (Hosted)
                  Else
                     'ParseThenPrint "DispLabel" & sSuffix, ASCFileName("DispLbl", False, "") & sSuffix & ".rtf", 1, 0, True '27May11 TH Added param (F0088129)
                     ParseThenPrint "DispLabel" & sSuffix, ASCFileName("DispLbl", False, "") & sSuffix & ".rtf", copies, 0, True, False '04Jan17 TH Use DB parsing (Hosted)
                  End If
                  ReprintFile 1, 1, 0, intLabelCount '06Jan13 TH Added param for multipart CIVAS reprints   '04Mar02 TH Added Parameter  (#MOJ#)
                  If fileexists(ReprintFileName()) Then Kill ReprintFileName() '27May11 TH Double insurance to stop file persisting (F0088129)
               End If
            End If

            If PrintOutput > 2 And d.extralabel <> "   " Then printextralabel d.extralabel, k.escd
         Next
      End If

endofsub:
   PrintOutput = 1

End Sub

Sub DosesBetweenTimes(dosesonly%, Ldose!(), LTime$(), DosingDays() As Boolean, dt As DateAndTime, xp As DateAndTime, doses!, cont&, thisdose!)
'ASC 12Feb94 Finds Number of doses to be given between two dates and times
'            If dosesonly%=-1 then routine returns number of doses only
'            otherwise each time a valid dose is found its date and time
'            are returned in cont& and dose in thisdose!. The routime then
'            picks up where it left off and continues counting doses! this
'            allows action to be taken for each dose found. When the last
'            dose has been found cont& is set to 0.
'            dow$ = valid days as a string e.g. Mon Wed Fri = "135"
'            Ldose!(x)=dose given at time LTime$(x)
'            EqualInterval=interval in minutes (set to 0 if not equal dosing)
'
'1Mar93      Quick method for just doses now fixed
'09May05 CKJ replaced dow$ with DosingDays(1 to 7)
'            Removed EqInterval& param as it is not used

Dim td As DateAndTime
Dim ld As DateAndTime
Dim lasttest&, endoffset As Long, xy As Integer, dosesperday!, NumOfDays&, testday&, days$, Y As Integer, testdose&
Dim dow$

   datetomins dt
   datetomins xp
   'start at first dose on first day and work through or at cont& if >0 and not dosesonly

   dow$ = GetIssueDays(DosingDays())
   If dow$ = "1234567" And (Not dosesonly And cont& > 0) Then
         ld.mint = cont& + 1 'last dose
      Else
         ld.mint = dt.mint
         doses! = 0
         thisdose! = 0
      End If
         
   'Unequal dosing
   If Int(xp.mint / 1440) - Int(ld.mint / 1440) > 43800 Then
         'message stopped ASC 28Mar94
         'popmessagecr "Calculation aborted", "Course greater than 120 years"
      Else
         If dosesonly And dow$ = "1234567" Then
               lasttest& = Int(ld.mint / 1440) + 1
               endoffset = xp.mint - (Int(xp.mint / 1440) * 1440)
               For xy = 1 To 6
                  dosesperday! = dosesperday! + Ldose!(xy)
               Next
               doses! = 0
               NumOfDays& = Int(xp.mint / 1440) - Int(ld.mint / 1440)
               If NumOfDays& < 0 Then
                     'IF NumOfDays& < -1 THEN MSGBOX "Start Time must be before End time", 0, "Calculation aborted"
                  Else
                     doses! = dosesperday! * (Int(xp.mint / 1440) - Int(ld.mint / 1440) - 1)
                  End If
            Else
               lasttest& = Int(xp.mint / 1440)
               endoffset = xp.mint - (Int(xp.mint / 1440) * 1440)
            End If

         For testday& = Int(ld.mint / 1440) To lasttest&
            td.mint = (testday& * 1440) + 1
            
''            days$ = LTrim$(Str$(DayOfWeek(td)))
''            If InStr(dow$, days$) > 0 Then

'            **WRONG**
            ''If DosingDays(DayOfWeek(td)) Then               'for each day, 1 (Mon) to 7 (Sun)      **WRONG**
            days$ = LTrim$(Str$(DayOfWeek(td)))
            If InStr(dow$, days$) > 0 Then
               For Y = 1 To 6                               'for each dosing slot 1 to 6
                  If Ldose!(Y) = 0 Then Exit For            'Just to speed things up
                  testdose& = (testday& * 1440) + (Val(Left$(LTime$(Y), 2)) * 60) + Val(Right$(LTime$(Y), 2))
                  If testdose& >= ld.mint And testdose& < (lasttest& * 1440) + endoffset Then
                     thisdose! = Ldose!(Y)
                     doses! = doses! + thisdose!
                     If Not dosesonly Then
                        cont& = testdose&
                        Exit Sub          '<------Exit here if dose found
                     End If
                  End If
               Next
            End If
         Next

      End If
      
   cont& = 0

End Sub

Sub EnterDrug(ByVal blnFormCheck As Boolean)
'09Jan99 ASC  moved from dispens.frm
'05Feb99 SF now only calls createlabel: if label has not been reused
'04Jun99 SF added patient billing mods
'16Nov99 SF added additional PBS patient billing mods
'16Nov99 SF if a PBS item cannot re-use so don't ask
'09Dec99 TH Set focus to directions box for Ward Prescribing when found drug
'09Oct00 AW Added code to show messagebox when drug is not on DSS
'16Nov00 SF PBS V2 mods
'06dec00 ckj moved dss warning above the .setfocus to try to avoid illegal function call (46298)
'09Apr01 CKJ Ensure the View All button is shown/hidden before calling findrdrug
'09Apr01 CKJ added call to GetSetLocalWardListCode to set ward code for FillDrugList
'03May01 CKJ use enabled property of View All button instead of .visible
'12sep01 CKJ changed boolean Protocol to non-boolean protocolphase
'             now has three values
'              0 or false     normal drug selection, not protocol entry
'              1              protocol phase 1, select drug and do all checks against it, returning severity & text
'              2              protocol phase 2, add the drug without checking interactions again
'            added protocolphase parameter to CheckPMRinteractions
'24sep01 CKJ exit early if protocol phase 1, suppress interactions for phase 2
'12Dec01 CKJ Clear ReusedLabel when not reusing a label
'11Jan02 TH  Added to clear directions for new label  (#57504)
'21Jan02 TH  Warn now (Not on DSS) for passlvl 2 if ini file set (enh 1521)
'15apr02 CKJ Added line to clear the NSVcode after severe interaction if user chooses to abort addition of drug
'27Sep02 TH  Mod to above to ensure abort$ only set if NOT found (not just if phase 1 as this breaks the protocol loop) (#)
'07Oct02 TH  Reinstated above mod and made new one after testing - NSVCode to be cleared here on abort only if not part of protocol (#62824)
'21Nov02 TH  Added a mod to stop reuse of labels if required. Also change logic so reuse will not happen for PBS in all circumstances.(#64857)
'07Feb03 TH Reload the original stop date in from the original directions on the label when reusing
'04Jun03 TH Altered above mod. Now use specially set modular variable to 'protect' re-engineered date rather than reusedlabel% (#67381)
'19Jun03 TH Added explicit set of ReusedDirections to false after second checking (#67381)
'31Jan03 TH (PBSv4)  Mods to the way PBS items are identified and then if necessary the new PBS panels will be updated.
'16May04 TH Added - Terminal basis only - Used to retain focus on dircode after drug entered (#65365)
'18Sep13 TH Removed references to Prescribing setting as now obselete (TFS 73749)

Dim drug$, keepisstype$, newRxallowed As Boolean, count%, found%, newdrug%, severity%, abort$, msg$, ans$, reuse%, Item$
Dim NumofLabels%, expiry$, drugescaped%, X%, escaped%, done%, desc$
Dim PatBillStub%     '04Jun99 SF added
Dim TxtDirCodePar As String '28Jan03 TH
Dim pbstxt$           '31Jan03 TH (PBSv4)
Dim strAns As String  '    "
Dim intOK As Integer  '    "

   drug$ = RTrim$(txtUC("txtDrugCode").text)
   keepisstype$ = Left$(cmbUC("CmbIssueType").List(cmbUC("CmbIssueType").ListIndex), 1)
   newRxallowed = True

   If drug$ <> "" Then
      Finddrug.CmdAll.Enabled = (siteinfo$("FormularyEXT", "") <> "")                 '03May01 CKJ swap to use enabled
      Finddrug.CmdAll.Visible = Finddrug.CmdAll.Enabled                               '            set visible from this

''**!!**         GetSetLocalWardListCode True, pid.ward                               '09Apr01 CKJ added to set ward code
      If blnFormCheck Then newdrug = 0 Else newdrug = 2                               '07Nov05 CKJ Suppress warning, eg if it has already been shown
      findrdrug drug$, False, d, 0, found%, newdrug%, False, False
                                                                    
      'Found the Drug
      '--------------
      '16Nov99 SF if PBS dispensing then ensure the same drug is not prescribed twice in a day for the same patient
      'If found Then
      If found Then
         If Not billpatient(15, "1") Then       '16Nov00 SF added to get correct PBS code off the user
            If Trim$(txtUC("TxtPrompt").text) = "A" Then '31Jan03 TH (PBSv4) Added
               pbstxt = "AMEND"
            Else
               pbstxt = ""
            End If
            
            'If BillPatient(12, "") Then   ' escd      '31Jan03 TH (PBSv4) Replaced
            If PBSGetFoundDrugItem() Then                          '31Jan03 TH (PBSv4) Dont warn if not on schedule
               If billpatient(12, pbstxt$) Then                    '    "              Pass in Text
                  ' user cancelled out so abort the issue
                  found = False
                  abort$ = "Y"
               End If
            End If
         Else
            found = False
            abort$ = "Y"
         End If
         If isPBS() And found Then                                               '31Jan03 TH (PBSv4)
            SetPBSNewScript True
            PBSSetNewLabel
            setQuesdefaults 0                                                  '   " '09Mar03 TH (PBSv4) Added Param
            'refresh screens
            If Not PBSGetFoundDrugItem() Then PBSSetbillitems 53, "N"
            intOK = billpatient(28, strAns)
            If strAns <> "" Then txtUC("txtQtyPrinted").text = strAns
            PBSUpdateIssuePanel
            SetPBSNewScript False
         End If
      End If
         
      If found Then
''         If d.indexed <> "1" And (Mid$(acclevels$, 1, 1) = "3" Or (Mid$(acclevels$, 1, 1) = "2" And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "NotOnDSSWarning", 0)))) Then '   "       ini file set (enh 1521)
         If d.indexed <> "1" And Mid$(acclevels$, 1, 1) = "2" And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "NotOnDSSWarning", 0)) Then   '   "       ini file set (enh 1521)  08Nov05 CKJ removed acclevels 3
            'popmessagecr "!Caution", "Caution. No decision support is available for this drug:" & crlf & Trim$(d.Description)  XN 4Jun15 98073 New local stores description
                        popmessagecr "!Caution", "Caution. No decision support is available for this drug:" & crlf & Trim$(d.LabelDescription)
         End If
''**!!**    checkPMRinteractions True, (d.chemical), (d.Description), False, severity, abort$, (protocolphase <> 0)      '   "        and reduced to boolean
      End If

      If abort$ = "Y" Then
         d.SisCode = ""                 '15apr02 CKJ Added to clear the NSVcode after severe interaction if user chooses to abort addition of drug '07Oct02 TH Only if not from protocol (#62824)
         found = False
         LabelAmended = False
      Else
         If severity > 0 Then cmdUC("CmdInteractions").Visible = True
      End If
   
      If found Then         ' tidy up the screen
         Select Case Left$(Trim$(UCase$(d.PrintformV)), 3)
            Case "TAB", "CAP"
               lblUC("LabelBlister").Visible = (TxtD(dispdata$ & "\patmed.ini", "BlisterPacking", "", "Times", 0) <> "")
            Case Else
               lblUC("LabelBlister").Visible = False
            End Select
         txtUC("TextBlister").Visible = lblUC("LabelBlister").Visible

         If L.SisCode <> d.SisCode Then
            If billpatient(13, "") Then
               ans$ = "N"
            ElseIf Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "AllowLabelReuse", 0)) Then  '21Nov02 TH Allow setting to disable ability to reuse labels (#64857)
               ans$ = "N"
            Else
''               For count = UBound(LstRX$) To 1 Step -1            ' Check Current
''                  If LstRX$(count) <> "" Then
''                        Labf& = Val(Right$(LstRX$(count), 9))
''                        msg$ = "current"
''                        GoSub CheckLabel
''                        If ans$ <> "" Then Exit For
''                     End If
''               Next
                           

               '19May95 ASC  check history and make copy if there
               If ans$ <> "Y" Then
                  For count = 1 To 50
''**!!** EQUIVALENT NEEDED
''                     If labrf&(count) < 0 Then
''                           Labf& = labrf&(count) * -1
''                           msg$ = "previous"
''                           GoSub CheckLabel
''                           If reuse <> 0 Or ans$ = "N" Then reuse = reuse * -1: Exit For
''                        End If
                  Next
               End If
            End If
                        
            If ans$ = "Y" Then
               If reuse < 0 Then
''                  Labf& = labrf&(reuse * -1) * -1
''                  labrf&(reuse * -1) = Labf&
''                  putpmr pmrptr&, (pid.recno)
                  FirstLoaded = False                       '03Nov98 CFY
                  getlabel Labf&, L, True
                  NewRx L, False, False
                  L.lastqty = 0                             '25Nov98 CFY
'''**!!** EQUIVALENT NEEDED              MakePMRLine Item$
''**!!** EQUIVALENT NEEDED               AddaRow Item$
''                                 Dispens.TGLabelList.RowIndex = Dispens.TGLabelList.Rows
                  reusedLabel% = True
                  TxtDirCodePar = txtUC("TxtDircode").text                                            '07Feb03 TH Reload the original stop date in from
                  txtUC("TxtDircode").text = ""                                                       '    "      the original directions on the label
                  For X = 1 To Len(RTrim$(TxtDirCodePar))                                             '    "
                     txtUC("TxtDircode").text = txtUC("TxtDircode").text & Mid$(TxtDirCodePar, X, 1)  '    "
                  Next                                                                                '    "
                  setReusedDirections True     '04Jun03 TH Added (#67381)
               Else
''                                 Labf& = Val(Right$(LstRX$(reuse), 9))    '    "
''                                 Dispens.TGLabelList.RowIndex = reuse
                  getlabel Labf&, L, True
                  reusedLabel% = False
                  setReusedDirections False     '19Jun03 TH Added after second checking (#67381)
               End If

               d.SisCode = L.SisCode
               getdrug d, 0, 0, False
''                           Dispens.TGLabelList.MarqueeStyle = 3
''               If UCase$(d.DosingUnits) = "MCG" Then
''                  lblUC("RxUnits", 1) = "microgram"
''               Else
                  lblUC("RxUnits", 1) = LCase$(d.DosingUnits)
''               End If
            Else
               reusedLabel% = False                                                           '12Dec01 CKJ Added
               setReusedDirections False     '19Jun03 TH Added after second checking (#67381)
               Labf& = 0
               clearlabel L
               Erase labelline$

               L.SisCode = d.SisCode       '23Sep96 CKJ Added as TEMP FIX !!**
               ClearDirections             '11Jan02 TH Added to clear directions for new label  (#57504)
               
''                           Dispens.TGLabelList.MarqueeStyle = 5
               L.IssType = keepisstype$ ' reset kept issue type
               getdrug d, 0, 0, False  '!!**
               L.SisCode = d.SisCode
               'CheckIssType True
                     ' drug name changed, so clean other lines
                     ' (preserve only l.isstype)
               DisplaytheLabAndForm NumofLabels, 0, k.escd, expiry$, 0
            End If
         End If
         
         'CheckIssType False 10Oct96 ASC moved to TxtType_LostFocus
         If passlvl <> 3 Then CheckIssType False Else CheckIssType True '06Jun97 KR reinstated??!!
         'If PresentLabel&() <> 0 And Not InStr(plvl$("Prescribing"), l.isstype) And RTrim$(l.dircode) <> "" Then 26Jul96 KR Removed.
         'If PresentLabel&() <> 0 And Not (InStr(plvl$("Prescribing"), L.IssType) <> 0) And RTrim$(L.dircode) <> "" Then      '12oct05 CKJ
         
         '18Sep13 TH Removed as Prescribing setting now obselete (TFS 73749)
         'If L.RequestID <> 0 And Not (InStr(plvl$("Prescribing"), L.IssType) <> 0) And RTrim$(L.dircode) <> "" Then           '   "          **!!** may not be needed though - please review
         '   ans$ = "Y"
         '   Confirm "", "delete current direction codes", ans$, k
         '   If ans$ = "Y" Then
         '      L.dircode = ""
''       '        LabelForArchive& = Labf&
         '   Else
         '      newRxallowed = False
         '   End If
         'End If
         
         If RTrim$(txtUC("txtDrugCode").text) = "" Then drugescaped = True Else drugescaped = False
         'If newRxallowed And InStr(plvl$("Prescribing"), L.IssType) And Not drugescaped Then 'ASC 04.06.92
         If newRxallowed And Not drugescaped Then '18Sep13 TH Removed ref as Prescribing setting now obselete (TFS 73749)
            If Not escaped Then
               labeltoform
               
               'If (Not reusedLabel%) Or l.stopdate = 0 Then  '07Feb03 TH Protect any Reworked StopDate (see above)
               If (Not getReusedDirections()) Or L.StopDate = 0 Then   '04Jun03 TH Replaced Above (#67381)
                  FormDates
               End If                                        '07Feb03 TH
               
               If RTrim$(d.dircode) <> "" And txtUC("TxtDircode").text = "" Then '9Sep95 ASC/CKJ added text=""
                  If Left$(d.dircode, 1) = ">" Then
                     storeddirect$ = RTrim$(Right$(d.dircode, Len(d.dircode) - 1))
                  Else
                     'If PresentLabel&() = 0 Then     '12Oct05 CKJ
                     If L.RequestID = 0 Then          '   "
                        For X = 1 To Len(RTrim$(d.dircode))
                           txtUC("TxtDircode").text = txtUC("TxtDircode").text & Mid$(d.dircode, X, 1)
                        Next
                        If Right$(RTrim$(d.dircode), 1) <> "/" Then txtUC("TxtDircode").text = txtUC("TxtDircode").text + "/"
                        checkroute  '09Jan99 ASC
                        k.escd = True '26Nov96  ASC
                     End If
                  End If
               End If
               
               ToggleRxLabel False
               SetFocusTo txtUC("TxtPrompt")
               
               done = True
               If Not escaped Then
                  For X = 1 To 5
                     If Mid$(labelline$(X), 2, 1) = "!" Then
                        txtUC("txtLabel", X).text = Right$(labelline$(X), Len(labelline$(X)) - 2)
                     Else
                        txtUC("txtLabel", X).text = labelline$(X)
                     End If
                  Next
                  If passlvl <> 3 Then
                        WDir.directs = txtUC("TxtDirections").text  'needed for createlabel
                        If Not reusedLabel% Then createlabel 1, 0    '05Feb99 SF
                        DisplaytheLabAndForm 1, -1, k.escd, expiry$, 0 '21Mar97 KR added
                     End If
                  End If
                  SetFocusTo txtUC("txtLabel", 5)
               End If
            Else
               If newRxallowed Then
                  NewRx L, False, False
                  If Trim$(d.dircode) <> "" Then
''                     WDir.Code = d.dircode
                     getdir d.dircode, (pid.ward), 0, WDir         '11Nov97 CKJ was (foundl&)
                  End If
                  If Not reusedLabel% Then createlabel 1, 0   '05Feb99 SF
                  DisplaytheLabAndForm 1, -1, k.escd, expiry$, 0 '21Mar97 KR added
                  If passlvl <> 3 Then 'not Prescriber
                     On Error Resume Next
                     If InStr(plvl$("OutPatLabel"), L.IssType) Then
                        SetFocusTo txtUC("txtLabel", 3)
                     Else
                        SetFocusTo txtUC("txtLabel", 5)
                     End If
                     On Error GoTo 0
                  End If
               Else
                  SetFocusTo txtUC("txtLabel", 2)
               End If
            End If
         
         'CmdOk_Click
         SetFocusTo txtUC("txtPrompt")
'         If passlvl = 3 Then txtUC("TxtDircode").SetFocus    '09Dec99 TH Added to set focus to directions box for Ward Prescribing
      Else
''!!**V93 may need focus putting on label
''         txtUC("txtDrugCode").SelStart = 0
''         txtUC("txtDrugCode").SelLength = Len(txtUC("txtDrugCode").Text)
''         txtUC("txtDrugCode").SetFocus
      End If
   Else
      SetFocusTo txtUC("txtLabel", 1)
   End If
      
   setReusedDirections False     '04Jun03 TH Added  (#67381)

Exit Sub

CheckLabel:
   getlabel Labf&, L, False      'ASC 11Apr94 Made false to speed up
   If L.SisCode = d.SisCode And L.IssType = keepisstype$ Then
         ans$ = ""
         desc$ = d.LabelDescription  ' desc$ = d.Description XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         Confirm desc$ & " found in " + msg$ + " use", "re-use for this issue", ans$, k
         If ans$ = "Y" Then
               reuse = count
               PatBillStub% = billpatient(5, "")   '04Jun99SF removes repeat info if item being re-used
            End If
      End If
Return

End Sub

Sub FillHeapLabelText(iHeapID As Integer, sLines() As String, iSplitLine As Integer, iMaxLine As Integer)
'
'Place the new label items on the heap given in iHeapID
'the label lines are split and allocated to [rxDescriptionRaw] and
'[rxDirectionsRaw] as plain text.
'[rxDescriptionsSized1-9] and [rxDirectionsSized1-9] are created dependant on an ini switch as
'vernier sized text (with RTF prefix). These are currently sized to fit into the number of lines
'which has been chosen as each part; I don;t think that this is what is required however. Need a
'way of telling the program how many lines we are trying to fit these data items onto.
'
'19Sep00 AE  Added checks for wa label debugging

Dim n As Integer, OK As Integer
Dim sDesc As String, sDir As String
Dim iNumLines As Integer, iFound As Integer
Dim sSection As String, sValue As String
Dim sTxtOut As String, iFontNo As Integer
Dim iDesiredLines As Integer, fFontsize As Single
Dim blnDebugON As Integer, intEntries As Integer

   On Error Resume Next
   iNumLines = UBound(sLines)
   On Error GoTo 0

   blnDebugON = (InStr(LCase(Command$), WA_DEBUG_SWITCH) > 0)                                      '19Sep00 AE

   If iNumLines = 0 Then Exit Sub            'quiet exit for now.

   'Clear out the heap:
   Heap 12, iHeapID, "rxDescriptionRaw", "", OK
   Heap 12, iHeapID, "rxDirectionsRaw", "", OK
   For n = 1 To 9
      Heap 12, iHeapID, "rxDirectionsSized" & Format$(n), sTxtOut, OK
      Heap 12, iHeapID, "rxDescriptionSized" & Format$(n), sTxtOut, OK
   Next

   If iNumLines > iMaxLine Then iNumLines = iMaxLine

   'Split into two data items according to the defined split position.
   'Add spaces at end of lines if not there already to prevent words runningtogether
   For n = 1 To iNumLines
      If n <= iSplitLine Then
            sDesc = sDesc & sLines(n) & Iff(Right$(sLines(n), 1) = " ", "", " ")
         Else
            sDir = sDir & sLines(n) & Iff(Right$(sLines(n), 1) = " ", "", " ")
         End If
   Next

   'Parse out the end of line characters for the raw text items, and replace with spaces
   replace sDesc, Chr$(LBL_END_LINE), " ", 0
   replace sDir, Chr$(LBL_END_LINE), " ", 0

   Heap 10, iHeapID, "rxDescriptionRaw", sDesc, OK
   Heap 10, iHeapID, "rxDirectionsRaw", sDir, OK

   intEntries = 0

   For n = 1 To 9
      sSection = "rxDescriptionSized" & Format$(n)
      sValue = TxtD(dispdata$ & "\terminal.ini", sSection, "", "StdLblFontName", iFound)
      If iFound Then
            intEntries = intEntries + 1                                                                                             '19Sep00 AE
            iDesiredLines = Val(TxtD(dispdata$ & "\terminal.ini", sSection, "1", "StdLblDescriptionLines", iFound))
            FormatLabelNonStd sDesc, dispdata$ & "\terminal.ini", sSection, iDesiredLines, 35, iFontNo, 0, sTxtOut                  '01Jun02 All/CKJ should iLinesAchieved be used?
            fFontsize = Val(TxtD(dispdata$ & "\terminal.ini", sSection, "12", "StdLblFontSize" & Format$(iFontNo), iFound))
            sTxtOut = "{\fs" & Format$(2 * fFontsize) & " " & sTxtOut & "}"           '\fs24 ' for 12 point text
            Heap 10, iHeapID, "rxDescriptionSized" & Format$(n), sTxtOut, OK
         End If

      sSection = "rxDirectionsSized" & Format$(n)
      sValue = TxtD(dispdata$ & "\terminal.ini", sSection, "", "StdLblFontName", iFound)
      If iFound Then
            intEntries = intEntries + 1                                                                                             '19Sep00 AE
            iDesiredLines = Val(TxtD(dispdata$ & "\terminal.ini", sSection, "1", "StdLblDirectionLines", iFound))
            FormatLabelNonStd sDir, dispdata$ & "\terminal.ini", sSection, iDesiredLines, 35, iFontNo, 0, sTxtOut                   '01Jun02 All/CKJ should iLinesAchieved be used?
            fFontsize = Val(TxtD(dispdata$ & "\terminal.ini", sSection, "12", "StdLblFontSize" & Format$(iFontNo), iFound))
            sTxtOut = "{\fs" & Format$(2 * fFontsize) & " " & sTxtOut & "}"           '\fs24 ' for 12 point text
            Heap 10, iHeapID, "rxDirectionsSized" & Format$(n), sTxtOut, OK
         End If
   Next

   'Debuggery:  If the wa debug command switch is on, log if no
   'rxDirections/Description Sized entries are found
   If blnDebugON And intEntries = 0 Then DumpWaDetails "FillHeapLabelText"                               '19Sep00 AE

End Sub

Sub getdir(ByVal findcode As String, location$, found&, WDir As WDirection)
'Used to find a direction using dir.code
'if only the default is present and not deleted.

Dim match$, done As Integer
Dim rs As ADODB.Recordset
   
   On Error GoTo ErrorHandler
   
   BlankWDirection WDir
   match = RTrim$(findcode)            '18oct05 CKJ removed UCase$()
   If Len(match) Then
      CheckStandard match, WDir, done
      
      If done Then
         found = -1
      Else
         location$ = trimz$(UCase$(location$))
   
         Set rs = GetDirectionRSbyCriteria(match, location, 0, False)     'wdircode, location(may be blank), (no language), not deleted
         If Not rs.EOF Then found = rs!WDirectionID
         rs.Close
         Set rs = Nothing
         
         If found& > 0 Then
            If GetDirectionByPK(found, WDir) = 0 Then
               found = 0
            End If
         End If
      End If
   Else
      found = 0
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
Exit Sub

ErrorHandler:
'stop
Resume Cleanup
   
   
End Sub

Sub GetLabelDetails(o_strLabelText As String, o_intBatchNumber As Integer, o_lngStartDate As Long)
'05Sep02 SF added to populate the extra transaction structure

   o_strLabelText = L.text
   o_intBatchNumber = L.batchnumber
   o_lngStartDate = L.startdate
   
End Sub

Sub GetLabelExpiry(sExpiry As String, sWorkingdate As String, sWorkingtime As String, iEscaped As Integer)

'Replaces some code in Dispens.frm TxtPrompt_KeyUp for clarity.
'Prompt the user to confirm calculated expiry, or allow them to enter their own
'if they have EditExpiry in their patmed.ini.
'--------------------------------------------------------
'16Feb00 AE  Written
'30Mar00 AE  Now only adds the word "Expiry" if they do not have "DoNotUseAfter" set up in patmed.ini
'            sWorkingDate/Time now OUT parameters as they are needed later.
'03Apr00 AE  Corrected above
'22Jun00 MMA added to set focus to yes (event nos 45025 & 44865)
'06Oct00 CFY Working data and time now derived from SetDataAndTime routine rather than from
'            controls on the dispens form
'25Oct00 CFY Parameter added to SetDateAndTime call
'08Nov00 CFY Now gets the date and time directly from the dispensary form if not called from teamwork
'02Jan01 AW  removed "!" from messagebox as was removing first letter from Title

'Dim sWorkingdate As String, sWorkingtime As String            '30Mar00 AE Parameterised
Dim sTempExp As String, sAns As String, k As kbdcontrol
Dim sFormat As String, sTmp As String, iValid As Integer
Dim sDate As String, stime As String
Dim iFound As Integer                                          '30Mar00 AE

   'Calculate expiry
''09May05 no teamwork
''   If TmwrkIssue() Then                                           'If this is a call from teamwork we will
''         SetDateAndTime sWorkingdate$, sWorkingtime$, False       'get the date and time from file,
''      Else                                                        'otherwise we will get it straight from the
         sWorkingdate$ = txtUC("txtPrepDate").text                     'dispensary form.
         sWorkingtime$ = txtUC("txtPrepTime").text
''      End If
   
   MakeExpiry k, sWorkingdate, sWorkingtime, sTempExp
   
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "EditExpiry", 0)) Then
         'If set up in patmed.ini, offer the user the expiry for editing as text if required.
         'Optionally, the user can specify the format of the printed expiry
         iValid = True
         sFormat = TxtD(dispdata$ & "\patmed.ini", "", "", "ExpiryDateFormat", iFound)
         If iFound Then
               sTmp = Left$(sTempExp, 10)
               parsedate sTmp, sDate, sFormat, iValid
            Else
               sDate = Left$(sTempExp, 10)
            End If
         
         sFormat = TxtD(dispdata$ & "\patmed.ini", "", "", "ExpiryTimeFormat", iFound)
         If iValid And iFound Then
               sTmp = Right$(sTempExp, 5)
               parsetime sTmp, stime, sFormat, iValid
            Else
               stime = ""
            End If
               
         If Not iValid Then
               sTmp = "WARNING!" & cr$
               sTmp = sTmp & "ExpiryDateFormat and / or ExpiryTimeFormat in Patmed.ini" & cr$
               sTmp = sTmp & "has been set Incorrectly. " & cr$
               sTmp = sTmp & "ExpiryDateFormat: Please use any of d dd m mm mmm mmmm yy yyyy" & cr$
               sTmp = sTmp & "ExpiryTimeFormat: Please use any of 1 2 3 4" & cr$ & cr$
               sTmp = sTmp & "Default format (dd/mm/yyyy) will be used."
               popmessagecr ".Expiry", sTmp
               sDate = Left$(sTempExp, 10)
               stime = Right$(sTempExp, 5)
            End If
         
         sTempExp = sDate & " " & stime

         sAns = sTempExp
         InputWin "Expiry", "Enter Expiry to print on label", sAns, k
         If Not (k.escd Or sAns = "") Then
               sTempExp = sAns
            Else
               sTempExp = ""
            End If
      Else
         'If no patmed.ini setting, use the same method as before; offer to accept expiry,
         'or don't print it.
         sAns = "Y"                                                              '22Jun00 MMA added to set focus to yes (event nos 45025 & 44865)
         Confirm "?EXPIRY ", "calculate expiry from database using" & crlf & sWorkingdate & " " & sWorkingtime, sAns, k
         If sAns <> "Y" Or k.escd Then sTempExp = ""
      End If

   'sExpiry = "Expiry: " & sTempExp                                              '30Mar00 AE
   sExpiry = sTempExp                                                            '     "
   sTmp = TxtD(dispdata$ & "\patmed.ini", "", "", "DoNotUseAfter", iFound)      'Only add the word "Expiry" if they
   'If Not iFound Or sTmp = "" Then sExpiry = "Expiry: " & sExpiry               'are not using the ini file setting for this purpose
   If Not iFound Then sExpiry = "Expiry: " & sExpiry                             '03Apr00 AE Corrected

End Sub


Function getReusedDirections() As Integer
'04Jun03 TH Written (#67381)
   
   getReusedDirections = m_blnReusedDirections
   
End Function

Sub GetRouteExpansion(route$, expansion$, routeword$)
'30Sep97 ASC takes a route abbreviation and makes the expansion and wording needs to be
'            moved out as data when internationalised rather than in the program
'29Nov97 CKJ Corrected spelling
'27Dec97 ASC Moved all data to route.ini
'08Jan98 CKJ/CY Default action is to blank the expansion & routeword
'            Also prevents Illegal Function Call with left(xx, -1)
'22Jan98 ASC Not private now since used in dispens
'22Jul98 EAC make language aware
'06Sep98 ASC Stopped an illegal function call if no comma entered on expansion line

   routeword$ = ""
   expansion$ = ""
   If trimz(route$) <> "" Then
         expansion$ = TxtD(ASCFileName("route.ini", True, ""), route$, "", "expansion", 0)
         routeword$ = Right$(expansion$, Len(expansion$) - InStr(expansion$, ","))
         If InStr(expansion$, ",") > 0 Then  '06Sep98 ASC
               If Len(expansion$) Then expansion$ = Left$(expansion$, InStr(expansion$, ",") - 1)
            End If
      End If

End Sub

Sub HighlightDescriptionLines()
'Highlight the lines on the label which have been set as directions.(WA Label mods)
'Only used if HighlightPMRDescriptionLines is set to Y in Patmed.ini.
'Uses the module level iLblSplit, which holds the number of the last direction
'line.
'--------------------------------------------------------
'16Feb00 AE Written
'19Sep00 AE Added debug checking

Dim n As Integer

   If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "HighlightPMRDescriptionLines", 0)) Then
         If InStr(LCase(Command$), WA_DEBUG_SWITCH) > 0 Then
               'Wa Labeling is turned on, but the setting has not been found
               'Dump the debug log.
               DumpWaDetails "HighlightDescriptionLines"
            End If
         'Quick exit as before if not turned on
         Exit Sub
      End If

   'Highlight the direction lines
   For n = 0 To 5
      If n < DescriptionSplitLine() Then
            txtUC("TxtLabel", n + 1).BackColor = LBL_HIGHLIGHT     'Light Grey
         Else
            txtUC("TxtLabel", n + 1).BackColor = &HFFFFFF           'White (Default)
         End If
   Next

End Sub

''Sub MakeDischargeEvent(pid As patidtype, FILE$)
'''23Sep99 CFY Added
'''21Jan02 TH Changed path for dat file (#53524)
''
''Dim PatientName$
''Dim X As Integer, totaldates As Integer, eventNo&, tempErr As Integer, retries As Integer
''
''   opentables
''   Screen.MousePointer = HOURGLASS
''   EventTbl.AddNew
''   EventTbl.Fields("priority") = 1
''   EventTbl.Fields("OwnerNumber") = trimz(pid.recno)
''   EventTbl.Fields("Consultant") = trimz(pid.cons)
''   EventTbl.Fields("Ward") = trimz(pid.ward)    '     "
''   EventTbl.Fields("To_Be_Done") = -1
''   EventTbl.Fields("FileName") = FILE$
''   buildname pid, False, PatientName$
''   EventTbl.Fields("Text") = "Discharge for " & PatientName$
''
''   totaldates = Val(GetEventIniEntry("Dates", "Total"))      '01Jun02 All/CKJ ! Added line as TotalDates was undefined
''
''   For X = 1 To totaldates
''      If GetEventIniEntry("DateDefaults", Str$(X)) = "t" Then
''            EventTbl.Fields(ReadSQL("Dates", Str$(X))) = Now
''            EventTbl.Fields(ReadSQL("Dates", Str$(X)) & "_initials") = UserID
''         End If
''   Next
''   'GetPointer dispdata$ + "\" & EventsTable & ".dat", eventno&, True   '21Jan02 TH Replaced (#53524)
''   GetPointer gstrSQLpath + "\" & EventsTable & ".dat", eventNo&, True  '    "
''   EventTbl.Fields("EventNumber") = eventNo&
''
''   On Error GoTo Dischargelocked
''   EventTbl.Update
''   On Error GoTo 0
''   DoEvents: FreeLocks
''   Screen.MousePointer = STDCURSOR
''
''Exit Sub
''
''Dischargelocked:
''   tempErr = Err
''   If retries > 10 Then
''         popmessagecr "Trying to write to SQL data base ", "Press RETURN to re-try - If this message persists contact your system manager"
''         retries = 0
''      Else
''         retries = retries + 1
''      End If
''   Screen.MousePointer = HOURGLASS
''   WriteLog dispdata$ & "\tmwrk.log", 0, "", "MakeEvent Error. E:" & Str$(eventNo&) & ", P: " & PID.recno & ", L: n/a, " & d.ATC & ", H: " & Str$(Hole%) & ", R: " & Str$(retries) & ", " & Error$(tempErr)
''   waitforticks 20
''   DoEvents: FreeLocks
''   Screen.MousePointer = STDCURSOR
''   Resume
''End!
''
''End Sub

Sub MakeExpiry(k As kbdcontrol, WorkingDate$, WorkingTime$, expiry$)
'20Sep96 CKJ Removed Noon & Midnight code & converted to 24hr clock

Dim xp As DateAndTime
Dim dt As DateAndTime
Dim actualexpirymins&

   If Not k.escd And LTrim$(WorkingDate$) <> "" And LTrim$(WorkingTime$) <> "" Then
         StringToDate WorkingDate$, dt
         StringToTime WorkingTime$, dt
         datetomins dt
         actualexpirymins& = d.expiryminutes
         xp.mint = actualexpirymins&   'ASC
         AddExpiry dt, xp
         DateToString dt, expiry$      'dd/mm/ccyy
         '   dd/mm/ccyy hh:mm
         expiry$ = expiry$ & Format$(dt.Hrs, " 00") & ":" & Format$(dt.min, "00")
      End If

End Sub

Sub MakeWorksheet(wrks$, dose$, ByVal intSyringestoLabel As Integer, ByVal strVolume As String, ByVal strLastVolume As String)
'06Jun98 CFY Now expands both the diluent and the reconsituent on the label rather than just showing
'            the code.
'22Jul98 EAC Make expansions language aware
'Added code to vary the item [worksheet] according to ini file setting
'17Oct02 TH Added ingvol element (really for use in rxman array)
'20Jun13 TH Further changes to the wording with syringe handling including adding new volume params (TFS 51176)
'20Jun13 TH Replaced instances of ml with mL
'06Aug13 TH For now we remove none syringe container handling (TFS 52317,70882)
'22May14 TH Removed dosevols$ param - this should be calculated centrally (TFS 91489)
'           Now we will calculate the ingredient volume here centrally - added section to do this

Dim DilExpansion$, RecExpansion$    '06Jun98 CFY Added
Dim PrintContainer$
Dim contname$
Dim dosevols$           '22May14 TH Added (TFS 91489)
Dim intloop As Integer  '    "
Dim dosevol!, lastdose! '    "

   '22May14 TH Added section (TFS 91489)
   For intloop = 1 To 6
      lastdose! = dosevol!
      If L.dose(intloop) > 0 Then
         If d.dosesperissueunit > 0 Then
            dosevol! = (L.dose(intloop) / d.dosesperissueunit) * (L.ReconVol + d.DisplacementVolume)
         End If
      End If
      If dosevol! > 0 And lastdose! > 0 And lastdose! <> dosevol! Then
         MsgBox "Unequal doses not yet supported", 0, ""
         dosevol! = 0
      End If
   Next

   dosevols$ = Format$(dosevol!, "###0.##")
   dosevols$ = Format$(dosevols$)
   '----------
   

   '22Jul98 EAC Make language aware
   DilExpansion = TxtD(ASCFileName("patmed.ini", False, ""), "", Trim$(L.DiluentAbbr), Trim$(L.DiluentAbbr), 0) '06Jun98 CFY Added
   RecExpansion = TxtD(ASCFileName("patmed.ini", False, ""), "", Trim$(L.ReconAbbr), Trim$(L.ReconAbbr), 0)    '06Jun98 CFY Added

   PrintContainer$ = TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "SIZEANDTYPE", "WorksheetContainer", 0)   '28Jul99 AE Added


   If L.ReconVol > 0 Then
         'wrks$ = "Use " + STRz$(l.ReconVol) + "ml of " & l.ReconAbbr & "to reconstitute. Then take "             '06Jun98 CFY Replaced with line below
         'wrks$ = "Use " + Strz$(L.ReconVol) + "ml of " & RecExpansion & " to reconstitute per unit. Then take "    '
         wrks$ = "Use " + Strz$(L.ReconVol) + " mL of " & RecExpansion & " to reconstitute per unit. Then take "   '20Jun13 TH Altered to mL
      Else
         wrks$ = "Take "
      End If
   'wrks$ = wrks$ & dosevols$ & " ml ( = " & dose$ & RTrim$(d.DosingUnits) & ")"
   wrks$ = wrks$ & dosevols$ & " mL ( = " & dose$ & RTrim$(d.DosingUnits) & ")" '20Jun13 TH Altered to mL
   'Heap 10, gPRNheapID, "ingvol", dosevols$ + " ml", 0      '17Oct02 TH Added
   Heap 10, gPRNheapID, "ingvol", dosevols$ + " mL", 0      '17Oct02 TH Added '20Jun13 TH Altered to mL
   If RTrim$(L.DiluentAbbr) <> "" Then
         'wrks$ = wrks$ & " and dilute to " & STRz$(l.FinalVolume) & "ml with " & l.DiluentAbbr$   '06Jun98 CFY Replaced with line below
         wrks$ = wrks$ & " and dilute to " & Strz$(L.finalvolume) & " mL with " & DilExpansion$     '
      End If
   ContainerName (L.containersize), L.Container, contname$

   Select Case UCase(PrintContainer$)                                                           '28Jul99 AE Added
      Case "SIZEANDTYPE"                                                                        '     "
         If intSyringestoLabel > 1 Then
            'wrks$ = wrks$ & " and send in " & Trim$(LCase(TxtDPatmed(Format$(intSyringestoLabel), "Words" & Format$(intSyringestoLabel), 0))) & " " & Trim$(Str$(L.containersize)) & "ml " & LCase(contname$) & plural(CSng(intSyringestoLabel))
            '20Jun13 TH Replaced above (TFS 51176)
            wrks$ = wrks$ & " and send as "
            If strVolume = strLastVolume Then
               wrks$ = wrks$ & Format$(intSyringestoLabel) & " x " & strVolume & " mL"
            
            Else
               wrks$ = wrks$ & Format$(intSyringestoLabel - 1) & " x " & strVolume & " mL + "
               wrks$ = wrks$ & "1 x " & strLastVolume & " mL"
            End If
         'Else    '06Aug13 TH For now we remove containers from here (TFS 52317,70882)
            'wrks$ = wrks$ & " and send in a " & Trim$(Str$(L.containersize)) & "ml " & contname$
            'wrks$ = wrks$ & " and send in a " & Trim$(Str$(L.containersize)) & " mL " & contname$ '20Jun13 TH Altered to mL
         End If
      Case "TYPE"                                                                               '     "
         wrks$ = wrks$ & " and send in a " & contname$                                          '     "
      Case "OFF"                                                                                '     "
      End Select                                                                                '     "

End Sub

Sub NameOfUnits(quantity&, Form$)
'24Jan95 CKJ Cut down version of CheckStandard
'            Takes quantity & returns dosing units formatted for printing
'08Jul97 KR  Added MGO - milligrams oral
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'24Feb99 CFY Changed message that is displayed when details aren't found.

Dim tmp&, ess$, temp$, du$, found As Integer, dummy$, putsere As Integer

   tmp& = quantity&                          '20Jan95 CKJ May be up to 750000
   If tmp& > 2 Then tmp& = 2
   ess$ = plural((tmp&))                     'cast to integer
   'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
   If d.LabelInIssueUnits Then
         temp$ = LCase$(d.PrintformV)
      Else
         temp$ = LCase$(d.DosingUnits)
      End If
   Form$ = RTrim$(temp$)             'default

   du$ = UCase$(Trim$(temp$))
   Form$ = TxtDPatmed(Form$, du$ + "form", found)
   If Not found And Right$(du$, 1) = "S" Then ' remove the plural, retry
         du$ = Left$(du$, Len(du$) - 1)
         Form$ = TxtDPatmed(Form$, du$ + "form", found)
      End If
   If Not found Then popmessagecr "Please note:", "Dosing unit details have not been set up for """ & Trim$(temp$) & """"                 '        "
   dummy$ = TxtDPatmed(WDir.route, du$ + "noPlural", found)
   If found Then ess$ = ""

   putsere = InStr(Form$, "!")
   If putsere > 0 Then
         Form$ = Left$(Form$, putsere - 1) + ess$ + Right$(Form$, Len(Form$) - putsere)
      Else
         Form$ = Form$ + ess$
      End If
   
   If UCase$(plvl$("LowerCase")) = "Y" Then Form$ = LCase$(Form$)

End Sub

Sub ParseEndDirMarker(sText As String, sEODMarker As String, sEndLineChar As String, iMarkedLine As Integer)

'Remove the End of Directions marker from the given text,
'and replace with sEndLineChar.  The line number of the line with the
'Marker on is returned in iMarkedLine.  This is calculated by the number
'of sEndLineChar characters in the sText

'------------------------------------------------------------------------------
'16Feb00 AE  written

Dim iEODpos As Integer, n As Integer
Dim sTemp As String

   sTemp = sText
   iMarkedLine = 0

   iEODpos = InStr(sTemp, sEODMarker)
   
   For n = 1 To Len(sTemp)
      Select Case Mid$(sTemp, n, 1)
         Case sEndLineChar, sEODMarker
            iMarkedLine = iMarkedLine + 1
         End Select
      If Mid$(sTemp, n, 1) = sEODMarker Then Exit For
   Next

   If iEODpos > 0 Then Mid$(sTemp, iEODpos, 1) = sEndLineChar
   sText = sTemp

End Sub

Sub ParseL(lines$, dev%, linnum%, ByVal blnExtendedLbl As Boolean)
'-------------------prints label line -----------------------------------------
'
'  dev%  - 3 = printer
'  dev%  - 5 = printer small
'  dev%  - 6 = printer medium
'
'12Jun97 KR  Ensured that the person who entered the prescription and the person who
'            dispensed it both have initals on label - for Kings.

'16Jan98 CKJ Derived from Printl, but only fills gPRNheapID with collated data
'            Data items are in two columns as follows...
'            StdLbl1A  StdLbl1B
'              ...       ...
'            StdLbl11A StdLbl11B
'            where linnum is MANDATORY and must be in the range 1-11 incl
'05Oct98 CKJ Added extra dev% options, using the ini file settings from the Vernier module
'            Where the space has been pre-measured then normal/medium/small is inhibited
'            and replaced by the setting from this module. If dev is negative then use
'            terminal.ini settings such as;
'               StdLblFontSize1 = 14
'               StdLblFontSize2 = 12
'               StdLblFontSize3 = 10
'               StdLblFontSize4 = 8.25
'            to determine font attributes
'            This may be enhanced to include font weight etc in due course.
'23Feb99 SF  now issues in whole packs if setup in the drug file

Dim pline$, PCtrl$, PColour$, Item$, success%, FontSize%
Dim Col As Integer

   'If linnum < 1 Or linnum > 11 Then Exit Sub
   If linnum < 1 Or (L.extralabel = False And linnum > 11) Or (L.extralabel = True And linnum > 21) Then Exit Sub

   pline$ = Trim$(lines$)

   Col = 0
   If Mid$(pline$, 2, 1) = "!" Then
         Col = Val(Left$(pline$, 1))
         pline$ = Mid$(pline$, 3)
      End If
   
   Select Case Col
      Case 0: PColour$ = "Black"
      Case 1: PColour$ = "Red"
      Case 2: PColour$ = "Blue"
      Case 3: PColour$ = "Magenta"
      Case 4: PColour$ = "Yellow"
      Case 5: PColour$ = "Pink"
      Case 6: PColour$ = "Green"
      End Select
   
   Item$ = "{" & printerctrl$(PColour$)     'turns "Red" into "\cf5 "  05Oct98 CKJ Added open {

   If dev < 0 Then                                                    '05Oct98 CKJ Added block
   
         '17Jun14 TH May want different Font sizes for Extended labels ? (TFS )
         
         
         FontSize = Val(terminal$("StdLblFontSize" & Format$(-dev), "0"))
         If FontSize = 0 Then
                popmessagecr ".", "StdLblFontSize" & Format$(-dev) & " must be configured in terminal.ini before use"
             Else
                Item$ = Item$ & "\fs" & Format$(2 * FontSize) & " "   '\fs24 ' for 12 point text
             End If
      Else
         If Len(pline$) <= 20 And linnum < 7 Then PCtrl$ = printerctrl$("Normal")
         If Len(pline$) > 20 Or dev = 6 Then PCtrl$ = printerctrl$("Medium")
         If Len(pline$) > 0 Then
               If Len(pline$) > 23 Or Asc(pline$) = 94 Or dev = 5 Then
                     PCtrl$ = printerctrl$("Small")
                  End If
            End If
      End If
   Item$ = Item & PCtrl$

   If Len(pline$) Then
         If Asc(pline$) = 94 Then     'char ^
               Item$ = Item & Mid$(pline$, 2)
            Else
               Item$ = Item & pline$
            End If
      End If

   Item$ = Item & "}"                                                 '05Oct98 CKJ Added close }

   Heap 10, gPRNheapID, "StdLbl" & Format$(linnum) & "A", Item$, success
   
   If L.extralabel Then Heap 10, gPRNheapID, "ExtLbl" & Format$(linnum) & "A", Item$, success

   If Not blnExtendedLbl Then '17Jun14 TH fencepost to protect B elements on final Extd lbl calls
      Select Case linnum
         Case 4
            Item$ = Left$(prepdate$, 2) + "-" + Mid$(prepdate$, 4, 2) + "-" + Right$(prepdate$, 2)
            Heap 10, gPRNheapID, "StdLbl4B", Item$, success
         Case 5
            If Qty! > 0 Then
                  Item$ = "Qty" & Str$(Qty!) & LCase$(d.PrintformV)            '23Feb99 SF
               Else
                  Item$ = "Chk......"
               End If
            Heap 10, gPRNheapID, "StdLbl5B", Item$, success
         Case 6
            If Len(RTrim$(L.PharmacistID)) > 0 Then
                  Item$ = "(" & trimz(L.PharmacistID) & "/" & UserID$ & ")"
   '>>            ElseIf automation$ <> "" Then         '01Jun02 All/CKJ
   '>>               Item$ = "(" & trimz(l.dispid) & "/" & UserID$ & ")"
               Else
                  Item$ = "(" & UserID$ & ")"
               End If
            Heap 10, gPRNheapID, "StdLbl6B", Item$, success
      End Select
   End If

End Sub

Sub ParseRx(Item$)
'03Nov96 ASC used to get data to print prescriptions
'27sep96 ASC
'27Jan97 ASC Added Summary & discharge summary & replaces trim$ with trimZ
'22Feb97 ASC The discharge summary needs to go via the correct mechanism to the G.P.
'            paper, fax, or e-mail
'07Mar97 KR  Ensured that MakeEvent works correctly.
'08Jul97 KR  added MGO
'25Jul97 CKJ Added labelline block
'            Changed CRLF to rtfCRLF as the former is already globally defined as chr$(13,10)
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'23Oct98 TH  Added new array element for directions for Rxlabel using Vernier formatting
'13Oct99 AE  Now looks on the print heap for items not declared here.
'            Also Added code in dissum: to place the individual parts of the PMR line onto the
'            heap as separate data items.
'01Aug00 CFY Now uses l.rxStartdate instead of l.startdate which contains the prescription startdate.
'14dec00 CKJ 'Discharger' section - moved signature and teamwork event creation to DoDischarge
'19Dec00 CKJ Inappropriate use of Global structures and pointer; now preserved within dissum
'09Feb01 CKJ Keyword "rxsumc", now sets type "C" before calling the routine to build text.
'10Nov01 CKJ Added three calls to FillHeapLabelInfo
'17Apr02 TH  Added the route expansion words to the end of the directions to be printed on the label (#60398)
'22Jan21 AS MM-4782 : SW - PN Worksheet printing errors when adding 11+ items into the ingredients table 10.22

Dim length&, posn&, openbrace&, closebrace&, temp$, char$, middle$, rtfCRLF$, rtfTAB$, dt As DateAndTime    'MM-4782
Dim sumtype$
Dim OK%, RXLayout$        '13oct99 AE
Dim dcop As DrugParameters                       '19Dec00 CKJ added
Dim lcop As WLabel
''Dim Labfcop As Long
Dim Wdircop As WDirection ' directstruct
Dim strRouteExpansion As String                  '17Apr02 TH Added (#60398)
Dim TextOut$, found As Integer, ans$, success%, X As Integer

   ReDim lines$(10) '    "
   ReDim directlines$(6)   ' 23Oct98 TH

   rtfCRLF$ = "\par "
   rtfTAB$ = "\tab "
   length = Len(Item$)

   strRouteExpansion = ""                               '17Apr02 TH Added (#60398)
   GetRouteExpansion L.route, "", strRouteExpansion
   FormatLabel Trim$(L.drdirection) & Trim$(strRouteExpansion), 5, -32767, 0, 0, TextOut$, False                            '01Jun02 All/CKJ FontNumber%, LinesAcheived% undefined - are they needed?
   
   deflines TextOut$, directlines$(), Chr$(13), 0, 0
   FillHeapLabelInfo gPRNheapID, L, False

   If length Then
         posn = 1 'was 0
         Do
            openbrace = InStr(posn, Item$, "[")    'was + 1
            closebrace = 0
            If openbrace Then
                  closebrace = InStr(openbrace + 1, Item$, "]")
                  If closebrace = 0 Then
                        Exit Sub
                     End If
                End If
            If closebrace > openbrace And openbrace > 0 Then
                  char$ = ""
                  middle$ = Mid$(Item$, openbrace + 1, closebrace - openbrace - 1)
                  
                  Select Case LCase$(middle$)
                     Case "dosingunits"
                        'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Then  '08Jul97 KR added MGO                                                                                                                                                  '05Feb98 CFY
                        'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then  '    "
                        If d.LabelInIssueUnits Then
                              char$ = LCase$(d.PrintformV)
                           Else
                              char$ = LCase$(d.DosingUnits)
                           End If
                     Case "discharger"    '22Feb97 ASC
                        'Look for the signature on the heap first                   13oct99 AE Added
                        Heap 11, gPRNheapID, "discharger", char$, found
                        
                        '14dec00 CKJ Moved signature and teamwork event creation to DoDischarge
                        If Not found Then
                              popmessagecr "!", "Caution: Print item '[discharger]' not available." & cr & "It should only be used on discharge documentation"
                           End If

                     Case "route"           '!!** Is this suitable?? LEAR REAR BEAR etc?
                        char$ = trimz(L.route)
                     Case "prn"
                        If Val(L.Prn) Then char$ = "PRN"   '!!** WRONG!!
                     Case "stdate"
                        dt.mint = L.RxStartDate
                        minstodate dt
                        DateToString dt, char$
                        parsedate (char$), char$, "2", 0
                     Case "sttime"
                        dt.mint = L.RxStartDate
                        minstodate dt
                        TimeToString dt, char$
                        parsetime (char$), char$, "1", 0
                     Case "spdate"
                        dt.mint = L.StopDate
                        minstodate dt
                        DateToString dt, char$
                        parsedate (char$), char$, "2", 0
                     Case "sptime"
                        dt.mint = L.StopDate
                        minstodate dt
                        TimeToString dt, char$
                        parsetime (char$), char$, "1", 0
''                     Case "repeat"
''                        If L.RepeatInterval <> 1 And Trim$(L.RepeatUnits) <> "day" Then
''                              char$ = LTrim$(Str$(L.RepeatInterval))
''                              char$ = L.RepeatUnits
''                           End If
                     Case "injection"
                        If L.finalvolume > 0 And L.IssType = "C" Then
                              char$ = LTrim$(Str$(L.finalvolume))
                              If Left$(char$, 1) = "." Then char$ = "0" + char$
                              char$ = char$ & " over " & LTrim$(Str$(L.InfusionTime)) & "min at "
                              If L.InfusionTime > 0 Then
                                    temp$ = Format$((L.finalvolume / L.InfusionTime) * 60, "###0.##")
                                    If Left$(temp$, 1) = "." Then temp$ = "0" & temp$
                                 End If
                              char$ = char$ & temp$ & "ml/hr"
                           End If
                     Case "ward code":       char$ = trimz(pid.ward)
                     Case "consultant code": char$ = trimz(pid.cons)
                     Case "rxno":            char$ = trimz(Str$(L.PrescriptionID))
                     Case "diluent":         char$ = trimz(L.DiluentAbbr)
                     Case "recon":           char$ = trimz(L.ReconAbbr)
                     Case "caseno":          char$ = trimz(pid.caseno)
                     Case "name":            char$ = trimz(pid.forename) & " " & trimz(pid.surname)
                     Case "rxid":            char$ = trimz(L.PrescriberID)
                     Case "chkid":           char$ = trimz(L.PharmacistID)
                     Case "rxsumi"  '22Feb97 ASC Rx summary includes ward stock for inpatients
                        sumtype$ = "IW"
                        GoSub dissum
                     Case "rxsumo"
                        sumtype$ = "O"
                        GoSub dissum
                     Case "rxsumd"
                        sumtype$ = "D"
                        GoSub dissum
                     Case "rxsuml"
                        sumtype$ = "L"
                        GoSub dissum
                     Case "rxsumc"
                        'GoSub dissum                  '09Feb01 CKJ Moved below the selection clause
                        sumtype$ = "C"
                        GoSub dissum                   '09Feb01 CKJ Moved from above
                     Case "rxsums"
                        sumtype$ = "S"
                        GoSub dissum
                     Case "rxsumt"
                        sumtype$ = "T"
                        GoSub dissum
                     Case "summary"
                        'GetTextFile dispdata$ & "\" & trimz$(pid.recno) & ".rtf", ans$, success%
                        'GetTextFile patdatapath$ & "\" & trimz$(pid.recno) & ".rtf", ans$, success%       '19/30Nov97 CKJ '07ec16 TH REmoved as part of filehsare clean up (TFS 157969)
                        
                        'char$ = ans$
                        char$ = "" '07Dec16 TH Replaced above
                        'rtfinsert char$                          '13Oct99 AE
                        
                     Case "labelline1":  char$ = labelline$(0)    '25Jul97 CKJ Added block
                     Case "labelline2":  char$ = labelline$(1)
                     Case "labelline3":  char$ = labelline$(2)
                     Case "labelline4":  char$ = labelline$(3)
                     Case "labelline5":  char$ = labelline$(4)
                     Case "labelline6":  char$ = labelline$(5)
                     Case "labelline7":  char$ = labelline$(6)
                     Case "labelline8":  char$ = labelline$(7)
                     Case "labelline9":  char$ = labelline$(8)
                     Case "labelline10": char$ = labelline$(9)
                     Case "labelline11": char$ = labelline$(10)

                     Case Else
                        
                        Heap 11, gPRNheapID, UCase$(middle$), char$, found     '13Oct99 AE Added. Look for items on the heap first
                        If Not found Then                                      '         "      "
                                    
                              If Left$(middle$, 4) = "dose" And Len(middle$) = 5 Then
                                    If L.dose(Val(Right$(middle$, 1))) > 0 Then
                                          'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
                                          If d.LabelInIssueUnits Then
                                                char$ = Trim$(Str$(L.dose(Val(Right$(middle$, 1))) * d.dosesperissueunit)) + d.DosingUnits
                                             Else
                                                char$ = Trim$(Str$(L.dose(Val(Right$(middle$, 1))))) + d.DosingUnits
                                             End If
                                          If Left$(char$, 1) = "." Then char$ = "0" + char$
                                       End If
                                 End If
                              If Left$(middle$, 4) = "time" And Len(middle$) = 5 Then char$ = L.Times(Val(Right$(middle$, 1)))
                              parsetime (char$), char$, "1", 0
                              If Left$(middle$, 3) = "dir" And Len(middle$) = 4 Then
                                    ReDim lines$(4)
                                    'deflines l.drdirection, lines$(), Chr$(13), 0, NumOfLines    '23Oct98 TH Replaced
                                    'char$ = lines$(Val(Right$(middle$, 1)) - 1)                  '23Oct98 TH Replaced
                                    char$ = directlines$(Val(Right$(middle$, 1)) - 1)             '23Oct98 TH Replaced
                                 End If
      
                              If Left$(middle$, 4) = "drug" And Len(middle$) = 5 Then
                                    ReDim lines$(4)
                                    'deflines d.Description, lines$(), "!", 0, 0  XN 4Jun15 98073 New local stores description
                                                                        deflines d.LabelDescription, lines$(), "!", 0, 0
                                    char$ = lines$(Val(Right$(middle$, 1)) - 1)
                                 End If
                           End If                                                                  '13oct99 AE

                     End Select

                  If char$ = "[" & middle$ & "]" Then
                        posn = openbrace + 1 ' was just before LOOP ...
                     Else
                        'changed = True      '01Jun02 All/CKJ removed as variable is never used
                     End If
                  Item$ = Left$(Item$, openbrace - 1) + char$ + Mid$(Item$, closebrace + 1)
               End If
         Loop While openbrace
      End If

Exit Sub

dissum: '27Jan97 ASC
   
'''Check for the layout RXline.rtf; if this exists, place the PMR on the heap as individual items.         '13oct99 AE
'''Otherwise, put it on as a single string as was done previously.                                         '     "
''                                                                                                         '     "
''   If fileexists(dispdata$ & "\RXLine.rtf") Then GetTextFile dispdata$ & "\RXLine.rtf", RXLayout$, OK    '     "
''
''   LSet dcop = d                                                   '19Dec00 CKJ Preserve d,l,Wdir,Labf&
''   LSet lcop = L
''   LSet Wdircop = WDir
''   Labfcop& = Labf&
''
''   For X = 1 To 50                    ' look at labrf&() for 1 to 50
''      If labrf&(X) > 0 Then
''            Labf& = labrf&(X)
''            getlabel False
''            If InStr(sumtype$, L.IssType) Then
''                  MakePMRLine temp$
''                  FillHeapLabelInfo gPRNheapID, L, False                                              '10Nov01 CKJ Added
''
''                  If RXLayout$ = "" Then                                                              '13oct99 AE
''                        Original code - output raw PMR line
''                        char$ = char$ & Mid$(temp$, 9, 48) & rtfTAB$ & Mid$(temp$, 59, 8) & rtfCRLF$
''                        temp$ = L.drdirection
''                        replace temp$, cr, " ", 0
''                        char$ = char$ & temp$ & rtfCRLF$ & rtfCRLF$                                  '13oct99 AE Moved into IF
''
''                     Else
''                        13oct99 AE added to allow the use of a pmr line as individual items
''                        PMRPartstoHeap True, gPRNheapID, temp$
''                        temp$ = RXLayout$
''                        ParseItems gPRNheapID, temp$, 0
''                        char$ = char$ & temp$
''                     End If
''
''                  char$ = char$ & temp$ & rtfCRLF$ & rtfCRLF$     '13oct99 AE Moved into IF
''               End If
''         End If       ' in range 1 to 50, or 0 if invalid
''   Next
''
''   LSet d = dcop                                                   '19Dec00 CKJ Restore d,l,Wdir,Labf&
''   LSet L = lcop
''   LSet WDir = Wdircop
''   Labf& = Labfcop&
''
''   If RXLayout$ <> "" Then PMRPartstoHeap False, gPRNheapID, ""    '13oct99 AE  Clear items from heap when finished
''   FillHeapLabelInfo gPRNheapID, L, False                          '10Nov01 CKJ Added
''
Return

End Sub


Sub patlabel(k As kbdcontrol, pid As patidtype, bagLabel, wardorpat As Integer)
' Temporary barcoding uses EAN by adding a 9 at beginning if "*" at beginning of number
' of patient number else treats as numeric only adding preceding zeros stripped in
' ident
'13Dec94 ASC made 11 lines like DisplayThelabel
'20Jan95 CKJ Can't use DisplayThelabel because it adds drug details, warnings
'            & directions, so reverted to safer method of printing here.
' 9Feb95 CKJ Changed parameter LblPrn to PrnNum then mapped back
'            Reverse & Forward label moved here
' 7Jun95 CKJ Typeface checked for each group of lines, DOB inhibited
'            BagLabel becomes a switch for label types
'             = True    inhibit personal details,    reverse/forward (PATMED)
'               False     print personal details,    reverse/forward (IDENT)
'               1       inhibit personal details,    reverse/forward
'               2       inhibit personal details, no reverse/forward (IPDLIST)
'26Apr96 Added WardorPat for automation
'        2 = Ward,1 = Pat
'10May97 KR added k.esc before call to reverselabel
'28May97 CKJ/KR Replaced Seqscan with GetSupplierWard
'28Aug97 CKJ Corrected height when in cm
'16Jan98 CKJ Added RTF support. Context is 'PatLabel', file is 'PatLbl.rtf',
'            items are 'StdLbl1A' to 'StdLbl10A' plus any standard ones
'07Jun99 SF  added wardorpat=3 for repeat dispensing where list type info needs to be printed
'09May05 CKJ Removed PrnNum param; was k, pid, PrnNum, bagLabel, wardorpat
'12Jan17 TH  refactored for DB RTF Handling (Hosted)

ReDim strPatientLabel(0 To 10) As String   'Added 25May00 AJK

Dim found%
Dim doall As Integer, wardexp$, consexp$, count As Integer, L1 As Integer, L2 As Integer, PrintSize As Integer
Dim strPatLabelFile As String
Dim strTempFile As String
Dim intSuccess As Integer '08Jan07 TH added (Hosted)

''   lblprn = PrnNum                   '9Feb95 CKJ copy parameter to global var
   doall = True
   Select Case bagLabel
      Case 0:
      Case -1, 1, 2: doall = False
      End Select
   
   k.escd = False

   strPatientLabel(1) = Trim$(pid.forename)
   strPatientLabel(2) = Trim$(pid.surname)
   '28May97 CKJ/KR Replaced Seqscan with GetSupplierWard
   'seqscan pid.ward, wardexp$, dispdata$ + "\wardcode.dat"
   'getsupplierward pid.ward, wardexp$, found%, 0
   If wardorpat = 3 Then
         get5charwardcode pid.ward, wardexp$                    ' 19May10 XN changed name of of function as wardcodes are now 5 characters
      Else
         getsupplierward pid.ward, wardexp$, found%, 0
      End If
   strPatientLabel(4) = wardexp$
   If doall Then
      'SeqScan pid.cons, consexp$, dispdata$ & "\conscode.dat"
      SeqScan pid.cons, consexp$, "conscode"   '21Sep05 TH Replaced to use new Wlookups
      strPatientLabel(5) = consexp$
   End If
   strPatientLabel(7) = "Unit No: " + pid.caseno
   If doall Then
         strPatientLabel(8) = "D.O.B. : " + Left$(pid.dob, 2) + "/" + Mid$(pid.dob, 3, 2) + "/" + Right$(pid.dob, 4)
         If Val(pid.Height) >= 10 Then
               strPatientLabel(9) = "Height : " + Trim$(pid.Height) + "cm"
            ElseIf (Val(Left$(pid.Height, 1)) > 0 Or Val(Right$(pid.Height, 2))) Then
               strPatientLabel(9) = "Height :" + Str$(Int(Val(pid.Height))) + "ft" + Str$(Int(Val(Mid$(pid.Height, 3)))) + "in"
            End If
      End If

   'DisplayTheLabel 1, 3, k, ""  '20Jan95 CKJ Replaced with code below

   'Print Pigeonhole number on bag
''   If automation$ <> "" Then
''         If Hole% > 0 And PrintHoleNumber Then
''               If wardorpat = 2 Then
''                     strPatientLabel(1) = Trim$(PID.ward)
''                     strPatientLabel(2) = wardexp$
''                     strPatientLabel(4) = ""
''                     strPatientLabel(5) = ""
''                     strPatientLabel(6) = ""
''                     strPatientLabel(7) = ""
''                     strPatientLabel(8) = ""
''                  End If
''               strPatientLabel(3) = "Pigeonhole:" & Str$(Hole%) '!!** KR
''            End If
''      End If
   
''   If lblprn = 0 Then
''         popmessagecr "!n!bDemo Mode", "Printer not connected"
''      Else
''         If (UCase$(terminal$("PatmedLblLPTtype", "")) = "RTF") Then '16Jan98 CKJ Added block
               For count = 1 To 10
                  Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "A", strPatientLabel(count), 0
               Next
               
               '17Apr12 TH Added new templates for different situations
               FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
               strPatLabelFile = "\PatLbl.rtf" 'default'
               If wardorpat = 3 Then
                  strTempFile = "\PatLbl_RptDisp"
                  'If fileexists(dispdata$ & strTempFile & "_" & pid.status & ".rtf") Then
                  If RTFExistsInDatabase(dispdata$ & strTempFile & "_" & pid.status & ".rtf") Then '12Jan17 TH  Refactored for DB RTF Handling (Hosted)
                  'GetRTFTextFromDB dispdata$ & strTempFile & "_" & pid.status & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                  'If intSuccess Then
                     strPatLabelFile = strTempFile & "_" & pid.status & ".rtf"
                  'ElseIf fileexists(dispdata$ & strTempFile & ".rtf") Then
                  ElseIf RTFExistsInDatabase(dispdata$ & strTempFile & ".rtf") Then '12Jan17 TH  Refactored for DB RTF Handling (Hosted)
                  'Else
                     'GetRTFTextFromDB dispdata$ & strTempFile & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                     'If intSuccess Then strPatLabelFile = strTempFile & ".rtf"
                     strPatLabelFile = strTempFile & ".rtf"
                  End If
               Else
                  strTempFile = "\PatLbl"
                  'If fileexists(dispdata$ & strTempFile & "_" & pid.status & ".rtf") Then
                  If RTFExistsInDatabase(dispdata$ & strTempFile & "_" & pid.status & ".rtf") Then  '12Jan17 TH  Refactored for DB RTF Handling (Hosted)
                  'GetRTFTextFromDB dispdata$ & strTempFile & "_" & pid.status & ".rtf", "", intSuccess  '08Jan17 TH Replaced above
                  'If intSuccess Then
                     strPatLabelFile = strTempFile & "_" & pid.status & ".rtf"
                  End If
               End If
               '-------
               
               'ParseThenPrint "PatLabel", dispdata$ & "\PatLbl.rtf", 1, 0, False '27May11 TH Added param (F0088129)
               'ParseThenPrint "PatLabel", dispdata$ & strPatLabelFile, 1, 0, False '17Apr12 TH Added to allow different templates
               ParseThenPrint "PatLabel", dispdata$ & strPatLabelFile, 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)
''            Else
'''32bit **GONE**
''            End If
''      End If
                                                
   k.escd = False                                           '24May95 ASC escape added

End Sub

Function plvl$(Entry$)
'23Jan95 CKJ Added warning
'09May05 ckj txt$() removed

Dim lin As String
Dim found As Integer

''   lin$ = txt$(dispdata$ + "\PATMED.INI", "", entry$)
''   If InStr(lin$, "MISSING FROM") Then popmessagecr "!n!bWARNING (Plvl)", lin$
   
   lin$ = TxtD(dispdata$ & "\PATMED.INI", "", "Text " & Entry$ & " missing from PATMED.INI", Entry$, found)
   If found = 0 Then popmessagecr "!WARNING (Plvl)", lin$
   plvl$ = lin$

End Function

''Sub PMRPartstoHeap(Adding%, HeapID%, PMRLine$)
'''
'''Puts the individual data items from a PMR line onto the Heap.
'''
'''12oct99 AE Written
'''Adding: True = Add items to the Heap
'''        False = Remove items from Heap
'''
''' x - not included at present
'''
'''                     length   start stop
'''
''' Type                  1     1     1       x
''' Start Date            7     2     8
''' Item                  48    9     56
''' Dose                  12    57    68      x
''' Time                  30    69    98      x
''' PharmID               3     99    101     x
''' Own Medication        1     102   102
''' Route                 4     103   106     x
''' Issued                7     107   113
''' Issued Date           6     114   119     x
''' Dr                    3     120   122     x
''' Pharm                 3     123   125     x
''' PRN                   1     126   126
'''Stop date              6     127   132
'''Rx id                  9     133   141     x
'''''findfile$              4     142   145     x
'''Internal No            9     146   154
'''
'''
'''19Dec00 CKJ Corrected above comment. Corrected code which uses the Internal No
'''            Note inappropriate use of Global structures and pointer
'''            - these are now preserved in the call from ParseRx
'''31Jan01 CKJ Corrected handling of Patients Own - was setting true for PO, PRN, Manual & Blister packs  (#49542)
'''            Added new data element [RxText] which is the prescription text as a single line.           (#49539)
'''            Corrected calls to Heap 12 (No user implications)
''
''Dim tmp$, dt As DateAndTime, dcop As DrugParameters
''Dim pos%, expan$, dirc$, found&, location$, iByte%
''
''   dcop = d
''
''   If Adding Then
''         tmp$ = Mid$(PMRLine$, 2, 6)                                 'Start Date
''         GoSub DateFromHex
''         Heap 10, HeapID, "RXSTART", tmp$, 0
''
''         tmp$ = Mid$(PMRLine$, 127, 6)                               'Stop Date
''         GoSub DateFromHex
''         Heap 10, HeapID, "RXSTOP", tmp$, 0
''
''         Heap 10, HeapID, "RXITEM", Mid$(PMRLine$, 9, 48), 0        'Description
''
''         tmp$ = Mid$(PMRLine$, 102, 1)                               'OwnMedication
''         'If Asc(tmp$) <> 0 Then tmp$ = "Patient's Own" Else tmp$ = ""   '31Jan01 CKJ Fault: this is an 8 bit flag byte
''         tmp$ = Iff(Asc(tmp$) And &H4, "Patient's Own", "")              '   "        Test PO against mask 0000 0100
''         Heap 10, HeapID, "RXOWNMED", tmp$, 0
''
''         Heap 10, HeapID, "RXISSUED", Mid$(PMRLine$, 107, 7), 0     'number issued
''
''       '  tmp$ = Mid$(PMRLine$, 126, 1)                               'PRN flag
''       '  If Val(tmp$) <> 0 Then tmp$ = "Y" Else tmp$ = "N"
''
''         iByte = Asc(Mid$(PMRLine$, 102, 1))
''         If iByte And &H2 Then
''               tmp$ = "When required"
''            Else
''               tmp$ = ""
''            End If
''         Heap 10, HeapID, "RXPRN", tmp$, 0
''
''         tmp$ = Mid$(PMRLine$, 57, 12)
''         Heap 10, HeapID, "RXDIR", tmp$, 0                          'Dose instructions (codes)
''
''         expan = ""                                                 'Expanded instructions
''         'get label
''         'tmp$ = Trim$(Mid$(PMRLine$, 142, 10))                     '19Dec00 CKJ removed ...
''         tmp$ = Right$(PMRLine$, 9)                                 '   "        Internal No is the last 9 chars
''         Labf& = Val(tmp$)                                          '!!** Global Labf&
''         getlabel False                                             '!!** Global label structure
''         Heap 10, HeapID, "RXROUTE", trimz(L.route), 0              'Also Route
''         'get the drug
''         BlankWProduct d
''         d.SisCode = L.SisCode                                      '(Global drug structure preserved by dcop)
''         getdrug d, 0, 0, False
''
''         'expand the directions
''         tmp$ = Mid$(PMRLine$, 57, 12)
''         Do
''            pos = InStr(tmp$, "/")
''            If pos > 0 Then
''               dirc$ = Mid$(tmp$, 1, pos - 1)
''               tmp$ = Mid$(tmp$, pos + 1)
''               WDir.Code = LTrim$(dirc$)                            '!!** Global direction structure
''               getdir dirc$, location$, found&, WDir
''               If found Then
''                     dirc$ = RTrim$(WDir.directs) & " "
''                     expan$ = expan$ & dirc$
''                  End If
''               End If
''         Loop Until pos = 0
''
''         'If the no expansion was found, for eg if the code had been truncated in the pmr,
''         'default to printing the direction codes instead.
''         If expan$ = "" Then expan$ = Mid$(PMRLine$, 57, 12)
''         Heap 10, HeapID, "RXDIREXP", expan$, 0
''
''         tmp$ = trimz$(L.drdirection)                               '31Jan01 CKJ Take the prescription text
''         replace tmp$, crlf, " ", 0                                 '            change cr/crlf/lf/char30
''         replace tmp$, cr, " ", 0                                   '            into a single space
''         replace tmp$, lf, " ", 0                                   '
''         replace tmp$, Chr$(LBL_END_LINE), " ", 0                             '
''         Heap 10, HeapID, "RXTEXT", tmp$, 0                         '            and post as 'RxText'
''
''         d = dcop
''
''      Else                    'remove items from heap
''         Heap 12, HeapID, "RXSTART", "", 0                           '31Jan01 CKJ Corrected the value parameter
''         Heap 12, HeapID, "RXSTOP", "", 0
''         Heap 12, HeapID, "RXITEM", "", 0         'Description
''         Heap 12, HeapID, "RXOWNMED", "", 0
''         Heap 12, HeapID, "RXISSUED", "", 0       'number issued
''         Heap 12, HeapID, "RXPRN", "", 0
''         Heap 12, HeapID, "RXDIR", "", 0
''         Heap 12, HeapID, "RXROUTE", "", 0        'Also Route
''         Heap 12, HeapID, "RXDIREXP", "", 0
''         Heap 12, HeapID, "RXTEXT", "", 0         'prescription text '25Jan01 CKJ Added
''      End If
''
''Exit Sub
''
''
''DateFromHex:
''
''   If Trim$(tmp$) <> "" Then
''         tmp$ = "&H" & tmp$                      'so that val() will recognise hex notation
''         dt.mint = Val(tmp$) * 1440              'from days back into minutes
''         minstodate dt
''         DateToString dt, tmp$
''         parsedate tmp$, tmp$, "1", 0
''      Else
''         tmp$ = ""
''      End If
''Return
''
''
''End Sub

Sub printl(lines$, dev%, linnum%, Form$, escd)
'-------------------prints label line -----------------------------------------
'
'  dev%  - 0 = fills form$ with text for form printing   ASC 26Jul94
'  dev%  - 1 = screen
'  dev%  - 2 = screen centralised      XXXXX Obsolete
'  dev%  - 3 = printer
'  dev%  - 4 = printer centralised     XXXXX Obsolete
'  dev%  - 5 = printer small
'  dev%  - 6 = printer medium
'
' 3Nov92 CKJ Installed PrnDrvr. Parameter <fileno> has no meaning and is
'            now ignored. All output goes to printer 1 under direct control.
'            By the way, I've just noticed that <linefeed> is already ignored!
' 7Nov92 CKJ Removed parameter <linefeed>, changed <fileno> to <LblPrn>
'            LblPrn takes values 1 or 2 for LPTn: other values ignored.
'12Jun97 KR  Ensured that the person who entered the prescription and the person who
'            dispensed it both have initals on label - for Kings.
'16Jan98 CKJ Added RTF support. Basically does the processing of each line but without
'            printing.
'23Jun98 CFY Stop situation arising were the code attempted to pad the line with 0 or a negative
'            number of spaces, which in turn caused an illegal function call.
'05Oct98 CKJ Removed many tests for doRTF and replaced with one IF...
'            Removed support for centralised printing
'            Unravelled several bits of untidy code - result is functionally identical
'            However the printer part is called for screen too due to a logical error.
'            Error NOT removed as not certain of its effect at this time
'23Feb99 SF  now issues in whole packs if setup in the drug file
'30Apr99 CFY Added extra fenceposts to issue whole packs mod to prevent div by zero errors
'03Jun99 CFY Removed extra calculations that take place on Qty's when IssueWholePacks is set as
'             they are not needed due to the fact that Qty is correct by the time it reaches this point.
'12Feb01 AW  SetDescriptionSplitLine: added if statement to highlight description lines if not a teamwork event



Dim PCtrl$, pline$, plined$, Col%
Dim PColour$, numperlab As Integer, leftfact As Integer, MyPrinter$, Changed As Integer

   If Not escd Then
         If dev% = 2 Or dev% = 4 Then     'Centralise the line
               popmessagecr ".", "Procedure PrintL called with obsolete parameter Dev=2 or 4" '05Oct98 CKJ Remove totally once fully checked
            End If
         
''         doRTF = (UCase$(terminal$("PatmedLblLPTtype", "")) = "RTF")         '16Jan98 CKJ Added
         
         lines$ = Trim$(lines$)
         pline$ = lines$
         k.escd = False

         Select Case dev%
            Case 0                                                           'fill form$ only
               plined$ = pline$                                              '05Oct98 CKJ Tidied
               If Len(pline$) Then
                     If Asc(pline$) = 94 Then plined$ = Mid$(pline$, 2)
                  End If
               Form$ = plined$
               
            Case Is < 3 > 0     '!!** Logical error; (3 > 0) is true, equivalent to Case Is < -1

            Case Else   'must be for the printer !!**NO - see line above
               If dev% > 2 And Mid$(lines$, 2, 1) = "!" Then
                     Col = Val(Left$(lines$, 1))
                     pline$ = Mid$(lines$, 3)
                     Select Case Col
                        Case 0: PColour$ = "Black"
                        Case 1: PColour$ = "Red"
                        Case 2: PColour$ = "Blue"
                        Case 3: PColour$ = "Magenta"
                        Case 4: PColour$ = "Yellow"
                        Case 5: PColour$ = "Pink"
                        Case 6: PColour$ = "Green"
                     End Select
                     PCtrl$ = printerctrl$(PColour$)
                  End If
''               If Not doRTF Then       '05Oct98 CKJ Moved inside one IF instead of many IFs
''32bit
''                  End If
            End Select
      End If

End Sub

Function ReplaceConsWithRxer$()
'16May00 SF added to use the prescriber code instead of the consultant code if setup to do so

Dim txt$
Dim patStub As Variant      '01Jun02 All/CKJ BillPatient returns a variant

   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "PrintPrescriberOnLabel", 0)) Then
         ' use the prescriber code
         txt$ = gPrescriberID$
         If L.batchnumber > 0 Then patStub = billpatient(18, txt$)   ' if Pharmac and a repeat use the original prescriber code regardless of what is currently entered
         If Trim$(txt$) = "" Then txt$ = Trim$(pid.cons)  ' no prescriber id entered so use consultant
         ReplaceConsWithRxer$ = Trim$(txt$)
      Else
         ' do as before (ie. use the consultant code)
         ReplaceConsWithRxer$ = Trim$(pid.cons)
      End If

End Function

Sub ReprintFile(fileType%, Action%, i_lngLabelNo As Long, ByVal intLabelCount As Integer)
'11Sep98 CFY Written
'Creates a copy of the reprintfile generated by the ParsethenPrint routine. The filename is
'based upon the prescription number + a prefix which determines if the file contains a label
'or a worksheet. The Filetype parameter determines the type of file this is:
'
'FILETYPE:
'  1 -  Prescription Label
'  2 -  Worksheet
'
'ACTIONS:
'  1  -  Save a reprint file
'  2  -  Print a reprint file
'
'29Sep98 CFY Added facility to reprint multiple copies
'25Jun99 CFY Now copies reprint files to \reprints beneath the patdata. Ini file option also
'            added which enables the reprint function to be switched on or off. Off is the default
'16Nov00 SF  added facility to reprint PBS repeat authorisation forms
'04Mar02 TH  Added extra parameter to build reprint names for MOJ rx Owing forms (#MOJ#)
'
'Future enhancements needed
'Need to add further information to the reprint files in order to distinguish to the user that
'these are in fact copies and not the original.
'
'15Oct03 CKJ CReprintFile$ changed to ReprintFileName()
'10may04 CKJ Current scheme only supports 5 digit hex numbers; PRExxxxx.RTF where PRE is the prefix
'            FFFFF is 1048575 and is the largest decimal number we can accomodate.
'            Adding one hex digit gives 16x as many labels, sufficient for this version.
'            Prefixes therefore need revising, but only when > 0xFFFFF to avoid loss of existing reprints.
'            As prefixes RAF & POF end in a valid hex digit these cannot be truncated, so mapping is
'            LBL  L-
'            PBS  P-
'            WKS  W-
'            RAF  R-
'            POF  O-
'09May05 CKJ Full prefix now used even with high numbers
'19Mar10 TH Ported : 12Jan07 TH Added for Worksheet reprint (enh77353)
'06Jan13 TH  Added new param to handle multi-part CIVAS reprints. Now store and retrieve reprints for
'            CIVAS labels in the DB. This should allow for reprints of multi part (multiple syringe) labels
'04Jul13 TH  Mods to support DB reprints in general (TFS 64512)
'21Sep14 TH  Make sure new DB reprint routine uses entered copies (TFS 99875)
'03Dec15 TH  More appropriate message when reprint not found (TFS 137255)

Dim filename$, prefix$, ErrMsg$, Context$
Dim ans$, i As Integer
Dim lngFileNo As Long
Dim strDetails As String '12Jan07 TH   (enh77353)
Dim OutFile$             '    "
Dim strText As String       '06Jan13 TH Added
Dim blnSuccess As Boolean   '    "
Dim strParams As String     '    "
Dim intSuccess As Integer   '    "
Dim lngCount As Long        '    "
Dim rsLabels As ADODB.Recordset   '     "
Dim fnum As Integer              '21Jan13 TH (TFS 51163)
Dim strReprintMarker As String   '    "
Dim strReprint As String         '    "
Dim strFileText As String        '    "
Dim blnSomethingtoPrint As Boolean  '01Jul13 TH Added
Dim stdlbl As String
Dim useTextFile As Boolean

   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "EnableReprints", 0)) = False Then
      Exit Sub            ' <==== WAY OUT!!
   End If
      
   blnSomethingtoPrint = False
   useTextFile = True
   
   Select Case fileType
      Case 1:     'Label
         If billpatient(13, "") Then
               prefix = "Pbs"
               ErrMsg$ = "pbslabel"
               Context$ = "PBSLabel"
            Else
               prefix = "Lbl"
               ErrMsg$ = "label"
               Context$ = "DispLabel"
            End If
      Case 2:     'Worksheet
         prefix = "Wks"
         ErrMsg$ = "worksheet"
         Context$ = "ManWkSheet"
         'put new reprintdetails stuff on wrksheet                                                    '12Jan07 TH   (enh77353) '19Mar10 THPorted
         If Action% = 2 Then                                                                          '         "
            strDetails = "Reprinted by " & UserID$ & " on " & Format$(Now, "dd/mm/yyyy hh:mm")        '         "
            Heap 10, gPRNheapID, "ORIGINAL PRINT", strDetails, 0                                      '         "
         End If                                                                                       '         "

      Case 3      'Repeat authorisation form   '16Nov00 SF added for PBS
         prefix = "Raf"
         ErrMsg$ = "rptauthorisation"
         Context$ = "RptAuthorisation"
      Case 4      'Prescription Owing Form     '04Mar02 TH POF Reprint for MOJ (#MOJ#)
         prefix = "POF"                        '    "
         ErrMsg$ = "PrescriptionOwing"         '    "
         Context$ = "RxOwing"                  '    "
      Case 5
                 prefix = "Rlb"
                 ErrMsg$ = "Raw label"
         Context$ = ""
             useTextFile = False
          
                 strText = ""
                 For i = 1 To 11
                         Heap 11, gPRNheapID, "StdLbl" + CStr(i) + "a", stdlbl, 0
                         strText = strText & stdlbl + vbNewLine
                 Next
          End Select
   
   On Error Resume Next                                                             '25Jun99 CFY Added
   MkDir patdatapath$ & "\reprints"                                                 '         "
   On Error GoTo 0                                                                  '         "
    
   '10May04 CKJ Handle file numbers in range 0x100000 to 0xffffff    'V9.3 32bit can handle longer filenames
   lngFileNo = Iff(fileType = 4, i_lngLabelNo, Labf&)
   Select Case lngFileNo
      Case Is < 0          '', Is > &HFFFFFF
         popmessagecr ".", "Reprint file cannot be handled - file number is invalid: " & lngFileNo
         Action = 0
''      Case Is > &HFFFFF
''         If prefix = "POF" Then prefix = "O"
''         prefix = Left$(prefix, 1) & "-"
      End Select
   filename$ = patdatapath$ & "\reprints\" & prefix & Hex$(lngFileNo) & ".rtf"
   
   'If strDetails <> "" And Action% = 2 Then                                     '12Jan07 TH Added (enh77353) '19Mar10 TH Ported
   '      MakeLocalFile OutFile$                                                 '    "
   '      parseRTF filename$, OutFile$                                           '    "
   '      filename$ = OutFile$                                                   '    "
   'End If                                                                       '    "

   Select Case Action
      Case 1:     'Save reprint file
         'If intLabelCount > 0 Then 'CIVAS Label with possible multipart element
         If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "DispensaryReprintFiles", 0)) Then  '01Jul13 TH Now this is default on all labels
            'Assemble parameters and write to DB
                        If useTextFile Then
                                GetTextFile ReprintFileName(), strText, intSuccess
                        Else
                            intSuccess = True
                        End If
                        
            If intSuccess Then
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gPatientSite) & _
                           gTransport.CreateInputParameterXML("LabelNumber", trnDataTypeint, 4, intLabelCount) & _
                           gTransport.CreateInputParameterXML("WLabelID", trnDataTypeint, 7, lngFileNo) & _
                           gTransport.CreateInputParameterXML("Label", trnDataTypeVarChar, Len(strText), strText) & _
                           gTransport.CreateInputParameterXML("Prefix", trnDataTypeVarChar, 3, prefix)
               blnSuccess = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyLabelReprintWrite", strParams)
            End If
         
         Else
            On Error GoTo CreateReprintFile_Err
            FileCopy ReprintFileName(), filename$                                      '15Oct03 CKJ was CReprintFile$
            On Error GoTo 0
         End If

      Case 2:     'Print reprint file
         'here we need to check if they are in the DB
         strParams = gTransport.CreateInputParameterXML("WLabelID", trnDataTypeint, 4, lngFileNo) & _
                   gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gPatientSite) & _
                   gTransport.CreateInputParameterXML("Prefix", trnDataTypeVarChar, 3, prefix)
         lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPharmacyLabelReprintCountbyWLabelIDandSiteID", strParams)
         
         If Not lngCount > 0 Then
            blnSomethingtoPrint = fileexists(filename$)
            
            If blnSomethingtoPrint And strDetails <> "" Then                             '04Jul13 TH Moved from above
                  MakeLocalFile OutFile$                                                 '    "
                  parseRTF filename$, OutFile$                                           '    "
                  filename$ = OutFile$                                                   '    "
            End If
         Else
            blnSomethingtoPrint = True
            strDetails = ""
         End If
   
         'If fileexists(filename$) Or lngCount > 0 Then  '06Jan13 TH added clause
         If blnSomethingtoPrint Then  '01Jul13 TH WE dont want to check for files if there is already something back from the DB
               k.Max = 3                                                            '29Sep98 CFY Added
               k.decimals = True                                                    '        "
               InputWin "EMIS Health", "Enter number of copies required", ans$, k                   '16Nov00 SF fixed caption
               If Not k.escd And Val(ans$) > 0 Then                                 '        "
                     'here we need to check if they are in the DB
                     'strParams = gTransport.CreateInputParameterXML("WLabelID", trnDataTypeint, 4, lngFileNo) & _
                     '          gTransport.CreateInputParameterXML("SiteID", trnDataTypeChar, 255, gPatientSite)
                     'lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLookupCountbyContext", strParams)
   
                     If lngCount > 0 Then
                        'CIVAS Label with possible multipart element
                        Set rsLabels = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyLabelReprintbyWLabelIDandSiteID", strParams)
                        If Not rsLabels.EOF Then
                           rsLabels.MoveFirst
                           Do While Not rsLabels.EOF
                              strText = RtrimGetField(rsLabels!label)
                              
                              
                              'Parse reprint  21Jan13 TH (TFS 51163)
                              strReprintMarker = TxtD(dispdata & "\" & "patmed.ini", "", "*", "ReprintMarker", 0)
                              strReprint = TxtD(dispdata & "\" & "patmed.ini", "", "{\cf0 R}", "ReprintText", 0)
                              
                              Heap 10, gPRNheapID, strReprintMarker, strReprint, 0
                              ParseItems gPRNheapID, strText, 0
                              
                              MakeLocalFile OutFile$
                              PutTextFile OutFile$, strText, intSuccess
                              
                              If intSuccess Then
                                 For i = 1 To Val(ans$) '21Sep14 TH Added (TFS 99875)
                                    If InStr(UCase$(Command$), "PREVIEW") Then
                                       Hedit 12, OutFile$
                                    Else
                                       Hedit 14, Context$ & Chr$(0) & OutFile$
                                    End If
                                 Next
                              End If
                              rsLabels.MoveNext
                              On Error Resume Next                                                             '25Jun99 CFY Added
                              Kill OutFile$                                               '         "
                              On Error GoTo 0
                              Heap 12, gPRNheapID, strReprintMarker, "", 0 'remove from heap
                           Loop
                        End If
                        rsLabels.Close
                        Set rsLabels = Nothing
                     Else
                     
                        '21Jan13 TH Added section (TFS 51163)
                        If fileType = 1 Then
                           strReprintMarker = TxtD(dispdata & "\" & "patmed.ini", "", "*", "ReprintMarker", 0)
                           strReprint = TxtD(dispdata & "\" & "patmed.ini", "", "{\cf0 R}", "ReprintText", 0)
                              
                           Heap 10, gPRNheapID, strReprintMarker, strReprint, 0
                           MakeLocalFile OutFile$                                                 '    "
                           parseRTF filename$, OutFile$                                           '    "
                           filename$ = OutFile$
                        End If
                        For i = 1 To Val(ans$)                                         '        "
                           If InStr(UCase$(Command$), "PREVIEW") Then
                                 Hedit 12, filename$
                              Else
                                 Hedit 14, Context$ & Chr$(0) & filename$
                              End If                                                   '        "
                        Next
                        
                        '22Jan13 TH Tidy up
                        If fileType = 1 And Trim$(OutFile$) <> "" Then
                           On Error Resume Next                                                             '25Jun99 CFY Added
                           Kill OutFile$                                               '         "
                           On Error GoTo 0
                           Heap 12, gPRNheapID, strReprintMarker, "", 0 'remove from heap End If
                        End If
                  End If
               End If
            Else
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "DispensaryReprintFiles", 0)) Then  '03Dec15 TH More appropriate message (TFS 137255)
                  popmessagecr "!EMIS Health", "Reprint file does not exist for this item" & crlf & filename$    '10May04 CKJ added filename
               Else                                                                                      '03Dec15
                  popmessagecr "!EMIS Health", "Reprint file does not exist for this record"             '  "
               End If                                                                                    '  "
            End If
      End Select

ReprintFile_Exit:

   If strDetails <> "" Then                          '12Jan07 TH Added (enh77353)
      Heap 12, gPRNheapID, "Original Print", "", 0   '    "
      If fileexists(filename$) Then
        Kill filename$                               '    "
      End If
   End If                                            '    "
   
Exit Sub
   
CreateReprintFile_Err:
   ErrMsg$ = "Error creating reprint file for this " & ErrMsg$ & cr
   ErrMsg$ = ErrMsg$ & "Error No : " & Format$(Err) & cr
   ErrMsg$ = ErrMsg$ & Error$
   popmessagecr "!EMIS Health", ErrMsg$
   GoTo ReprintFile_Exit

End Sub

''Sub ResetNeededNextTime(Labf&)
''Dim r As filerecord, L As WLabel, localchan%
''
''   openrandomfile patdatapath$ + "\labeltxt.v6", Len(L), localchan%
''   '29jul96 ASC can't lock labels here !!!
''   GetRecordL r, Labf&, localchan%, Len(L)
''   LSet L = r
''   L.needednexttime = ""
''   LSet r = L
''   PutRecordL r, Labf&, localchan%, Len(L)
''   Close localchan%
''
''End Sub

''Sub RxNotesFlag(iByte$, Action%, Value%)
'''11Jun99 CFY Written
'''              Performs various actions on the bit (bit 7) in Byte$ that is used to denote
'''              whether a note has been attached to a prescription.
'''
'''Action        Description
'''  1           Sets the flag
'''  2           Clears the flag
'''  3           Reads the flag and places the result in 'Value%'
''
''Dim AsciiValue%
''
''   AsciiValue% = Asc(iByte$)
''
''   Select Case Action%
''      Case 1:     'Set
''         AsciiValue% = AsciiValue% Or &H80
''         LabelAmended% = True
''      Case 2:     'Clear
''         AsciiValue% = AsciiValue% And &H7F
''         LabelAmended% = True
''      Case 3:     'Read
''         Value% = (AsciiValue% And &H80) = &H80
''   End Select
''
''   iByte$ = Chr$(AsciiValue%)
''
''End Sub


Sub SetDateAndTime(dateout$, timeout$, ForceRead As Integer)
'1Feb95 CKJ DateToMins needed to use the time
'06Oct00 CFY dateout and timeout values now 'cached' using cheesy static variables. This is because the
'            values were previously cached on the dispens form (not good).
'12Oct00 CFY Fixed stupid mistake which was passing TimeOut$ in DateOut!!!!
'25Oct00 CFY SetDateAndTime now allows a forced refresh of the cached date and time using the ForcRead parameter

Dim chan%, newtimeneeded%, valid% '29Jun97 ASC
Dim td As DateAndTime
Dim dt As DateAndTime

Static strDateOut As String, strTimeout As String

'**!!** Remove or replace in 9.3

   If (Trim$(strDateOut) <> "") And (Not ForceRead) Then
         dateout$ = strDateOut
         timeout$ = strTimeout
      Else
         If fileexists("c:\datetime.asc") Then
               chan = FreeFile
               Open "c:\datetime.asc" For Input As chan
               Input #chan, dateout$
               Input #chan, timeout$
               Close #chan
               StringToDate dateout$, dt
               StringToTime timeout$, dt
               datetomins dt
               today td
               If dt.mint < td.mint Then newtimeneeded = True
            Else
               newtimeneeded = True
            End If
         If newtimeneeded Then
               parsedate "t", dateout$, "1", valid
               timeout$ = Left$(Time$, 5)
            End If
         
         strDateOut = dateout$
         strTimeout = timeout$
      
      End If

End Sub

Sub SetDescriptionSplitLine(iValue As Integer)

'Set the value of iLblSplit.  This is a module level variable which
'holds the value of the last line which is to be sent to the directions
'data item for printing.
'12Feb01 AW added if statement to highlight description lines if not a teamwork event

   iLblSplit = iValue
''   If Not TmwrkIssue() Then             '12Feb01 AW moved from patmed.bas: getlabel
        HighlightDescriptionLines
''    End If
End Sub

Sub setReusedDirections(blnReusedDirections As Integer)
'04Jun03 TH Written (#67381)
   
   m_blnReusedDirections = blnReusedDirections
   
End Sub


Sub ShowColourAndDescriptionSplitMenu(ByVal Index As Integer, ByVal blnExtraLabel As Boolean)
'Show a pop-up menu allowing the user to change the label lines
'which are sent to the Description / instructions data items.
'Accessed by mouse click or keyboard shortcut.
'16Feb00 AE  Written
'09May05 CKJ Combined colour & split menu to avoid floating toolbar on web page
'------------------------------------------------------------
Dim sMenuItems As String
Dim sAns As String
Dim iLoop As Integer
   
   sMenuItems = "&Black[cr]&Red[cr]B&lue[cr]&Magenta[cr]&Yellow[cr]&Pink[cr]&Green"
      
   If Index <= DescriptionSplitLine() Then
      sMenuItems = sMenuItems & "[cr] [cr]"
      For iLoop = 1 To 5
         sMenuItems = sMenuItems & "&" & Format$(iLoop) & " Line Description[cr]"
      Next
      sMenuItems = sMenuItems & "&Cancel"
   End If
    
   Unload PopMnu
   popmenu 2, sMenuItems, 0, 0
   PopMenuShow sAns, 0, 0

   Select Case Val(sAns)
      Case 1 To 8    'colours
         setforecolour Index, Val(sAns - 1), blnExtraLabel
      
      Case 8, 14     'separator, Cancel
         'No action
      
      Case 9 To 13   'Change Direction split
         SetDescriptionSplitLine (Val(sAns) - 8)   '1 to 5
            
      End Select

End Sub

''Sub StoreSeverityAndMessage(ByVal i_WriteData As Integer, io_intSeverity As Integer, io_strMessage As String)
'''------------------------------------------------------------------------
'''24Sep01 CKJ Written. Provides propertylet/get style functionality, avoiding the need for globals
'''            i_WriteData = True  takes given parameters and stores them
'''                        = False returns the stored data
'''------------------------------------------------------------------------
''Static intSeverity As Integer
''Static strMessage As String
''
''   If i_WriteData = False Then                        'read data
''         io_intSeverity = intSeverity
''         io_strMessage = strMessage
''      Else                                            'write data
''         intSeverity = io_intSeverity
''         strMessage = io_strMessage
''      End If
''
''End Sub

Function Strz$(Number!)
'Take a real number, convert to string, remove leading space
'and if less than 1, add a leading zero

Dim n$ '29Jun97 ASC

   n$ = LTrim$(Str$(Number!))
   If Left$(n$, 1) = "." Then n$ = "0" + n$
   Strz$ = n$

End Function

Function TxtDPatmed(default As String, Entry As String, found As Integer) As String
'20Jul98 EAC make language aware
'09May05 Was Txtd2$()

   TxtDPatmed = TxtD(ASCFileName("PATMED.INI", False, ""), "", default, Entry, found)

End Function

Function WardUsesInPatientDirections() As Integer

'Look for the ward this patient is on, and check if the InPatientDirections flag is set.
'This flag is set by the user in the amendsupplier (winord)
'Returns:
'     True if this ward does use inpatient directions.
'     False otherwise.
'-------------------------------------------------------------------------------------------
'30Mar01 AE  Written
'

Dim udtSupplier As supplierstruct
Dim strWard As String
Dim RecordPosition As Long
Dim blnInPatDirections As Integer


'First get the ward that this patient is on:
   strWard = pid.ward
   'Read from the cache first if we have one
   GetDispWardSupplier strWard, RecordPosition, udtSupplier  '30Jun17 TH Use cache (TFS 191443)
   If RecordPosition = 0 Then getsupplier strWard, 0, RecordPosition, udtSupplier
   
'Check the flag
   blnInPatDirections = False
   If Val(udtSupplier.InPatientDirections) = 1 Then blnInPatDirections = True

'Return
   WardUsesInPatientDirections = blnInPatDirections

End Function

Private Sub Wrapto35chars(FullLine$, firstline$, remainder$)
'13Jun98 ASC Written to simplify createlabel should be used on all label types when we have time just CIVAS at present.
Dim breakpos

   breakpos = InStr(FullLine$, "!")
   plingparse FullLine$, "!"
   If breakpos > 35 Or (breakpos = 0 And Len(FullLine$) > 35) Then
         For breakpos = 35 To 0 Step -1
            If Mid$(FullLine$, breakpos, 1) = " " Then Exit For
         Next
         If breakpos = 0 Then breakpos = 34
      End If
   If breakpos > 0 Then
         firstline$ = Left$(FullLine$, breakpos - 1)
         remainder$ = Trim$(Right$(FullLine$, Len(FullLine$) - breakpos))
      Else
         remainder$ = ""
         firstline$ = FullLine$
      End If

End Sub

Sub ToggleRxLabel(ByVal label As Boolean)
'23Oct96 switches between label and prescription view
'27Jun97 KR Only show iv details if civas and prescription visible
'07Jul97 KR Added fraRx.Refresh as not redrawing properly.
'05Feb99 SF now only calls createlabel: if label has not been reused
'09May05 CKJ moved from Patmed
'        ToggleRxLabel True      sets to Label view
'        ToggleRxLabel False     sets to Prescription view

Dim X As Integer

   If fraUC("fraRx").Visible = label Then  '5Jul97  ASC
         If label And LabelAmended Then  '5Jul97 ASC added
               WDir.directs = txtUC("TxtDirections").text  'needed for createlabel     ''**!!**
               If Not reusedLabel% Then
                  If txtUC("TxtFinalVol").Visible Then
                     If Val(txtUC("TxtFinalVol").text) <= 9999 And Val(txtUC("TxtInfusionTime").text) <= 9999 Then formtolabel 0 '19May08 TH
                  End If
                  'createlabel 1, 0                                 ''**!!**
                  If Not L.extralabel Then createlabel 1, 0  '01Jul14 TH Extended label. If the label is extended we wont re-create it
               End If      '19May08 TH
               memorytolabel                                                           ''**!!**
            
            End If
         
         fraUC("fraRx").Visible = Not label
''         shpUC("ShpLabel").Visible = label          '26Jun98 ASC   Stops prescription controls from being partially hidden after screen refreshes

         For X = 0 To 9
            txtUC("TxtLabel", X).Visible = label
         Next
         lblUC("lblExpiry").Visible = label
         
         If label Then
''               fraIV.Visible = False
               fraUC("fraDays").Visible = False
               fraUC("fraIVdetails").Visible = False
''               ImgColour.Visible = True    '09Jan98 ASC
            Else
''               ImgColour.Visible = False
            End If
            
''         cmdUC("CmdPrompt", 6).Enabled = False        '' Not label    [Clear]
''         linUC("Line10").Visible = False     ''label
            
         If fraUC("fraRx").Visible And L.IssType = "C" Then     '27Jun97 KR
''               fraIV.Visible = True
               fraUC("fraIVdetails").Visible = True
               fraUC("fraIVdetails").Refresh
         
            Else
''               fraIV.Visible = False
               fraUC("fraIVdetails").Visible = False
            End If
         fraUC("fraRx").Refresh      '07Jul97 KR Added
      End If

End Sub


Function DirectionTextEscape(ByVal strIn As String) As String
'17Nov05 CKJ Written to handle storage of plain text in directions, stored as ".../text:AnyTextHere/..."
'            Currently escapes space and slash
      
Dim strOut As String

   strOut = strIn
   replace strOut, " ", Chr$(160), 0      'non breaking space (32 + 128)
   replace strOut, "/", "¬", 0
   DirectionTextEscape = strOut

End Function

Function DirectionTextToPlain(ByVal strIn As String) As String
'17Nov05 CKJ Written to handle storage of plain text in directions, stored as ".../text:AnyTextHere/..."
'            Currently escapes space and slash

Dim strOut As String

   strOut = strIn
   replace strOut, Chr$(160), " ", 0
   replace strOut, "¬", "/", 0
   DirectionTextToPlain = strOut
   
End Function
Function GetLabelRequestID() As Long
'22May08 TH Written
' Needed to cough up the request ID so that it can be recorded in the translog

   GetLabelRequestID = L.RequestID

End Function
Sub setLabelExtraLabelFlag(blnExtraLabelFlag As Boolean)
'14May14 Th written
   L.extralabel = blnExtraLabelFlag
End Sub

