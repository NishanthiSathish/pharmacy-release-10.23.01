Attribute VB_Name = "PATMED"
'--------------------------
'   Dispensary Programme
'--------------------------
'Modifications
'--------------
'30Mar04 CKJ {SP1}
'            Moved Medicard8066, MedicardOld, EditClinicalSummary & RefreshPatPanelX to Patmed.rem
'along with commented block from inside ShowClinSum
'14Apr04 CKJ Added Issue_Callback
'16May04 TH  DisplaytheLabAndForm: Mod to retain modified dircode field (#67284) - Timing Issue on table refresh
'16May04 TH  ChangeConsultant: Use new enhanced lookup (enh654)
'16May04 TH  labeltoform: Added LabelModified to clause to protect original directions (#65853)
'16May04 TH  onloadingdispens: UMMC pricehide mod to set functionality based on passlvl
'17May04 TH  CheckLabelSpace written to provide quick answer as to whether there is space to save a label (enh1532)
'06May10 AJK SaveLabel: F0073627 Added logging for Off Route product selection
'25Jun10 CKJ Calcdefaultdoses, Formtolabel, Savelabel: Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)
'04Jul11 TH  labeltoform: Make sure days are restored correctly on label read (F0121971)
'15Feb13 XN  FillHeapLabelInfo: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'            furtherinfo:       Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'            getlabel:          Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'            SaveLabel:         Replace WLabel.LastDate string with WLabel.lastSavedDateTime date. (40210)
'01Jul13 TH  CalcIV: Record the actual concentration here for the print heap (TFS 39202)
'11Aug13 TH  DisplaytheLabAndForm: Store multiple reprints if labelcount is set (TFS 71108)

'16Aug13 TH  SaveLabel: Added call to SetNewFastRepeat to record a searchable number (TFS 70134) DoC
'29Jun15 XN  FillHeapLabelInfo: Added lLabelDrugDescription, lLabelDrugDescriptionXML, lLabelDrugDescriptionTrim, and lLabelDrugDescriptionTrimXML (98073)
'17Aug15 TH  CheckRxComplete: If this is a custom dose we also dont need the time (as in PRN) (TFS 126360)
'17Aug15 TH  Authorise: Custom frequency scripts do not need times. (TFS 126360)
'15Sep15 TH  CalcIV: Ensure we derive a dose in a similar matter to CIVAS Stat for Custom frequency - there is no dose in the slot so we have to scrape from the dircode text (TFS 129498)
'15Sep15 TH  isCustomFrequency: Written as useful wrapper (TFS 129498)
'25Nov15 XN  CIVASCheck: Removed sort and moved to so web service works 134997
'06Dec16 TH  PrintRx: Replaced RTF Handling (TFS 157969)
'----------------------------------------------------------------------------------------------------------------------------
DefInt A-Z
Option Explicit

Private Const OBJNAME As String = PROJECT & "Patmed."

Global tto%, pil%, PCL%, pmc%  '18Nov97 SF added (flag for printing medication card)
''Global patmedaction As String * 1

''Global deletetohistory%       '11Nov98 CFY Added
''Global PatSurfaceArea!     '16Jul98 EAC Added for HK Surface Area Mods

Global ChineseAppend$
Global ChineseDirCount%

Dim td As DateAndTime
Dim dt As DateAndTime
Dim xp As DateAndTime
Dim TopUpPeriod$
Dim Ldose!(6)
Dim LTime$(6)
''Dim stcklward$

Dim FailedExchange As Integer

Dim Loaded%
Dim LastEnterDays%
Dim Find$                  '**CHECK** is this used correctly

Dim BlisterSemaphore%        '20Jan98 CFY Added for blister packing

''Dim AskSAUpdate%           '13Aug98 EAC added
''Dim AutoArchive%           '22Sep99 CFY Added

Dim blnFromTxtPromptKeyUp As Integer '17Nov05 TH

Global daysdefined As Boolean    '09May05 was module level but changed as ucDispens uses it too now
Global g_blnLinkedPrescription As Boolean  '12Jul11 TH Added global flag for complex presriptions
Global g_TotalComplexChildren As Integer
Global g_blnSplitDose As Boolean  '03Aug11 TH Made Global


Dim m_blnAttemptedlabelEdit As Boolean  '23Jul12 TH Added
Dim ComparisonLabel As WLabel      '23Jul12 TH Added
Dim m_LabelTypesPreventEdit As String  '20Jul12 TH Added (TFS 26712)
Dim m_intRepeatNumber As Integer   '16Aug13 TH Added (TFS 70134)
Dim m_intTotalRepeats As Integer    '18Aug13 TH Added (TFS 70134)
Dim m_strRptPrescriptionExpiry As String  '18Aug13 TH Added (TFS 70134)
Dim m_sglRptQuantity As Single      '19Aug13 TH Added (TFS 70134)

Dim m_blnExtendedLabel As Boolean   '24Jun14 TH Added

Dim m_DispWardSupplier As supplierstruct  '30Jun17 TH New Cache store for a ward we will retain for the dispensing control to
'                                                     Try and prevent superfluous DB calls. A couple of handlers will allow access
'                                                     Setting, flushing etc. (TFS)


Sub AddAdditionalDir(ByVal findcode As String)
'18Jul01 TH  Procedure written from original code that is now duplicated - this procedure should make maintenance simpler.
'14oct01 CKJ Corrected last mod: variable warnings$ was not set to anything, so the text of the dircode was not shown

Dim found&, ans$, escd%
Dim sMsg As String

   getdir findcode, (pid.ward), found&, WDir
   If found& Then
      ans$ = "Y"
      escd = False
      If passlvl <> 3 Then
            sMsg = WDir.directs
            replace sMsg, Chr$(30), crlf, 0     '**??** is it 10 13 or 30?
            sMsg = "OK to add additional direction code " & RTrim$(WDir.Code) & " ?" & crlf & crlf & sMsg
            popmsg "EMIS Health", sMsg, MB_ICONQUESTION + MB_OKCANCEL, ans$, escd
         End If
      If Not escd And ans$ = "Y" Then expanddir WDir.Code
   Else
      popmessagecr "!", "Invalid Additional Direction Code : " & findcode
   End If
   
End Sub


''Sub AddDirCodeToLabel(lineno, found&)
'''If found& comes in > 0 then uses current contents if dir.directs else looks
'''up code from TxtLabel(LineNo).text
''
''Dim tonum%, Numoflines%, X%
''Dim strFindCode As String
''
''   ReDim lines$(5)
''
''   strFindCode = RTrim$(txtUC("txtLabel", lineno).Text)
''   getdir strFindCode, (pid.ward), found&, WDir
''   If found& And Not InStr(plvl$("Prescribing"), L.IssType) > 0 Then
''      L.dircode = LTrim$(RTrim$(L.dircode)) & RTrim$(WDir.Code) & "/"
''   End If
''
''   tonum = 0
''   If found& Then
''      deflines (WDir.directs), lines$(), Chr$(13), 0, Numoflines
''      If lineno + Numoflines - 1 > 5 Then
''         popmessagecr "NO ROOM", "There are not enough lines left for this code"
''         tonum = 5 - lineno
''      Else
''         tonum = Numoflines - 1
''      End If
''
''      For X = 0 To tonum
''         txtUC("txtLabel", lineno + X).Text = LTrim$(lines$(X))
''      Next
''   End If
''
''   If lineno < 5 Then SetFocusTo txtUC("txtLabel", lineno + tonum + 1)                'txtUC("txtLabel", lineno + tonum + 1).SetFocus
''
''End Sub

Sub AddDirection(TxtDirCodePar$, highlight%, PutDirToForm%, location$)
' 9Sep95 ASC only add / if there is a direction
'10Oct96 ASC moved to patmed.bas from prescrib.frm and TxtDircode made a parameter
' 8Aug97 CKJ Added location as param as not in scope after the above mod.
'02Feb98 ASC removed add as comma as not used any more and NOCr from parameters
'31Mar00 TH  retain "/"
'18Mar02 TH  Removed comma as seperator for direction codes (#59667)

Dim lenstr%, sendslash%, X%, lastslash%, Offset%, found&
Dim strFind As String

   highlight = False
   PutDirToForm = False

   If Len(TxtDirCodePar$) > 1 Then
      lenstr = Len(TxtDirCodePar$)
      sendslash = lenstr
      X = 1
      Do While lenstr - X > 1 'Do we really need a do loop ? ASC !!**
         X = X + 1
         Select Case Mid$(TxtDirCodePar$, lenstr - X, 1)
            Case "/", " ", "\": Exit Do        '18Mar02 TH removed comma as seperator (#59667)
            End Select
      Loop
      lastslash = lenstr - X
      If lenstr - X = 1 Then Offset = 0 Else Offset = 1
      strFind = Mid$(TxtDirCodePar$, lastslash + Offset, sendslash - (lastslash + Offset))
      getdir strFind, location, found, WDir     'not just prescribers, not deleted

      If found& Then
         PutDirToForm = True
      ElseIf LTrim$(TxtDirCodePar$) <> "" Then
         popmessagecr "#", "Direction code not found: '" & LTrim$(TxtDirCodePar$) & "'"
         TxtDirCodePar$ = Left$(TxtDirCodePar$, lastslash)
         If Len(TxtDirCodePar$) = 1 Then TxtDirCodePar$ = ""
         highlight% = True
      End If
      
      If Len(TxtDirCodePar$) > 0 Then  '9Sep95 ASC
         TxtDirCodePar$ = Left$(TxtDirCodePar$, Len(TxtDirCodePar$) - 1) & "/"  '30Jul95 ASC from TxtDircode_change
      End If
   Else
      If Trim$(TxtDirCodePar$) <> "/" Then TxtDirCodePar$ = ""  '31Mar00 TH Replaced below to allow retention of / - this
     ' TxtDircodePar$ = ""                                        '           stops transactions being recorded without entry in PMR
   End If
   
End Sub

Sub archivelabel(LabfForArc&)
'13May95 ASC
'19Dec96 EAC log file now writes to patient directory
'Used to store all old prescriptions that would otherwise be lost when 50
'labs is exceeded. May be used in future instead of history by index patid
'and searching file that way. Could also be used as copy is made from history


'!!V93!! Need to write a copy to the SQL table
popmessagecr ".!!V93!!", "Need to write archive label here"


'Static chan% ', file$, ext$ 17Apr96 KR Made this local as set in beginning anyway            '{SP2} static not necessary?
'
'Dim FILE$, ext$
'Dim recno&, failed%
'Dim lcop As WLabel

'   ext$ = Right$(date$, 2) + Left$(date$, 2)
'   FILE$ = patdatapath$ + "\RX" + ext$
'   If fileexists(FILE$) Then  '09Jun95 ASC
'         If chan = 0 Then
'               OpenRandomFilePtr FILE$, Len(l), chan
'            End If
'         GetPointer FILE$, recno&, True
'         GetRecordNL r, LabfForArc&, labchan%, Len(l)
'         LSet lcop = r
'         lcop.patid = pid.recno
'         LSet r = lcop
'         If lcop.patid <> pid.recno Then
'               MsgBox "lcop.patid=" + lcop.patid + "  pid.recno =" + pid.recno
'               WriteLog patdatapath$ + "\lblpidno.log", 0, UserID$, "archive lcop.patid=" & lcop.patid & "  pid.recno =" & pid.recno  '19Dec96 ascrootpath$ changed to patdatapath$
'            End If
'         PutRecordNL r, recno&, chan%, Len(l)
'         Updateindex "", pid.recno + ext$, recno&, patdatapath$ + "\RX.idx", failed
'         If failed Then
'               popmessagecr "WARNING", "The archive index has failed - please report to your system manager"
'            End If
'      Else
'         MsgBox FILE$ + "missing, contact ASC support desk"
'      End If

End Sub

Sub Authorise(checkedok)
'07Mar97 KR Set PrescriberID password level not 3 or 4
'09Apr97 KR Added check for blank d.siscode to make freeformat labels work.
'14Oct98 TH Extra check to ensure last element of directioncode added to label in prescribing
'15Oct98 TH Automatically add endoflabel directions in prescribing
'06Jan99 SF/CFY/ASC added code to ensure last char will be / once truncated into l.dircode
'02Aug00 MMA Added: Global update for Teamwork
'18Jul01 TH Replaced block with call to AddAdditionalDir
'17Aug15 TH Custom frequency scripts do not need times. (TFS 126360)

Dim slashpos As Integer, lastslashpos As Integer, currentdir As String
Dim Finished As Integer
Dim maxdirlen As Integer

   checkedok = False             '10Jul98 CFY Added

   '09Apr97 KR cludge to make free-format labelling work !!**
   'if no drugcode then free format label therefore authorise true
   If trimz(d.SisCode) = "" Then
         checkedok = True
         Exit Sub
      End If
   
   If Len(RTrim$(storeddirect$)) > 0 And Right$(txtUC("TxtDircode").text, 1) = "/" Then 'And passlvl <> 3 Then   15Oct98 TH took out bar on prescriber
         AddAdditionalDir storeddirect$
         storeddirect$ = ""
      Else
         '19Jan99 EAC Handle labels with modified warnings/instructions
         If Right$(txtUC("TxtDircode").text, 1) = "/" Or passlvl = 3 Then
               checkedok = True
''               If Dispens.fraIV.Visible Then CalcIV 1, True '25Jan95 CKJ Added to force '1d' to '1440'
      
               'add further checks here
               '23Jan95 CKJ CIVAS, container vol=0
''               If Dispens.fraIV.Visible And Val(Dispens.TxtContainerSize.Text) = 0 Then
''                     checkedok = False
''                     popmessagecr "IV Details", "Container size and type not set - please correct"
''                     Dispens.TxtContainerSize.Text = Dispens.TxtFinalVol.Text
''                     Dispens.CmbContainer.SetFocus
''                  End If
      
               '24Jan95 CKJ dose(1) entered but time(1)="" and not PRN
               If RTrim$(txtUC("TxtTime", 1).text) = "" And Val(txtUC("TxtDose", 1).text) > 0 Then
''                     If Dispens.fraIV.Visible Then   'CIVAS
''                           checkedok = False
''                           popmessagecr "Warning", "Enter dosage time for CIVAS administration"
''                        ElseIf Dispens.ChkPRN.Value = 0 Then
                        If chkUC("ChkPRN").Value = 0 And chkUC("ChkManual").Value = 0 Then      '21oct05 CKJ added chkmanual
                              If Not ((Len(Trim$(OCXheap("DirCode", ""))) = 0) And (Val(OCXheap("SCHEDULEID_ADMINISTRATION", "0"))) > 0) Then '17Aug15 TH Custom frequency scripts do not need times. (TFS 126360)
                                 checkedok = False
                                 popmessagecr "Warning", "Enter dosage time or set PRN administration"
                              End If
                        End If
                  End If
      
               '**!!** IS THIS NEEDED IN 9.3?
               If checkedok Then
                  maxdirlen = Len(L.dircode)                         'was fixed at 12 in 8.6
                  If Len(RTrim$(txtUC("TxtDircode").text)) > maxdirlen Then '30Jul95 ASC removes slashes next to whole numbers if no space for Dircode
                     lastslashpos = 1
                     slashpos = 1
                     Do
                        slashpos = InStr(lastslashpos, txtUC("TxtDircode").text, "/")
                        If slashpos = 0 Then Exit Do
                        currentdir$ = Mid$(txtUC("TxtDircode").text, lastslashpos, slashpos - lastslashpos)
                        If LTrim$(Str$(Val(currentdir$))) = currentdir$ Then
                           txtUC("TxtDircode").text = Left$(txtUC("TxtDircode").text, slashpos - 1) & Right$(txtUC("TxtDircode").text, Len(txtUC("TxtDircode").text) - slashpos)
                        End If
                        lastslashpos = slashpos + 1
                     Loop
                     
                     '06Jan99 SF/CFY/ASC added following block to ensure last char will be / once truncated into l.dircode
                     If Len(Trim$(txtUC("TxtDircode").text)) > maxdirlen Then
                        txtUC("TxtDircode").text = Left$(Trim$(txtUC("TxtDircode").text), maxdirlen)
                        If Mid$(txtUC("TxtDircode").text, maxdirlen - 1, 1) = "/" Then
                           txtUC("TxtDircode").text = Left$(txtUC("TxtDircode").text, maxdirlen - 1)
                        Else
                           txtUC("TxtDircode").text = Left$(txtUC("TxtDircode").text, maxdirlen - 1) & "/"
                        End If
                     End If
                  End If
                  formtolabel Finished
                     
                  If Finished Then
                     Select Case passlvl
                        Case 3
                           If Trim$(L.PrescriberID) = "" Then
                              L.PrescriberID = UserID$
                              nextchoice$ = "S"
                           Else
                              'popmessagecr "", "Already Prescribed" ***** needed
                           End If
                        Case 4
                           If Trim$(L.PharmacistID) = "" Then
                              L.PharmacistID = UserID$
                              'nextchoice$ = "S"  10Jun97 KR Removed
                           Else
                              'popmessagecr "", "Aleady checked"  ***** needed
                           End If
                        End Select
                     If passlvl <> 3 Then
                        ToggleRxLabel True
                     End If
                  Else
                     checkedok = False
                  End If
               End If
            Else
               txtUC("TxtDircode").text = txtUC("TxtDircode").text & "/"
            End If
      End If

End Sub

Sub Blanklabel()
'------------------------------------------------------------------------------------------------------------------------
'Mods
'----
'
'13Nov98 EAC HK mod to use full Hospital Number on label
'20Nov98 CKJ/CFY Allow 'surname, forename'
'*16May00 SF now uses consultant code or prescriber code depending on how system is setup
'------------------------------------------------------------------------------------------------------------------------
Dim X%
Dim TempCaseNo$, success                  '13Nov98 EAC
Dim PatientName$

   For X = 0 To 8
      txtUC("TxtLabel", X).text = ""
   Next
   
   '13Nov98 EAC HK Mod to use full Hospital Number on label
   TempCaseNo$ = Trim$(pid.caseno)
''   If OCXlaunch() Then Heap 11, gPRNheapID%, "OCXHospNum", TempCaseNo$, success%
   
   buildname pid, True, PatientName$                                               '20Nov98 CKJ/CFY Allow 'surname, forename'
   txtUC("TxtLabel", 9).text = Left$((PatientName$ & " (" & Trim$(pid.ward) & " " & ReplaceConsWithRxer$() & " " & Trim$(TempCaseNo) & ")" & Space$(36)), 36)
   SetLblNameCaption
   
End Sub


Sub CalcDefaultDoses(escaped%)
'12Dec94 CKJ Full Stock path used
'12Dec94 ASC DosesForDays replaced by simple doses X days
'04Jun97 Getwardtop KR  Now use supplier file and not #ward#.idx
'08Jul97 Added MGO - Milligrams Oral
'22Jan98 ASC Replaced InputBox (CKJ)
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'24Sep98 TH  Added Formats
'23Feb99 SF  now issues in whole packs if setup in the drug file
'30Apr99 CFY Added extra fenceposts to issue whole packs mod to prevent div by zero errors
'24Aug00 JN  Checks Pharmacc is turned off before incrementing l.batchnumber
'20Nov00 SF/CFY  moved 24Aug00 logic into Dispens.frm: txtprompt_keyup
'29May01 TH  Mod to ensure qty on message box is rounded correctly (#46507)
'19Jun01 TH  Removed use of mod when calculating default amounts (issue in whole packs) to handle fractional amounts better (#46507)
'11Jan02 TH  Changed to stop decimal point entry on "no of Doses" input box as shouldnt allow fraction of a dose  (#57650)
'11Jan02 TH  Treat nothing entered (or value <1) in "no of doses" input window equivalent to cancel (#57650)
'31Jan03 TH  (PBSv4) Added seperate switch for PBS items
'22Nov05 TH  Changes to allow suppresion of quantity calcs
'25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)

Dim EnterDays%
Dim topdate%, tdate$
Dim days%, doses!, ans$, DailyDoses!, msg$
Dim wholeIssue%
Dim strDrug As String
Dim strPlural As String
Dim blnSuppressQtyCalc As Boolean  '22Nov05 TH Added

   days = 0
   doses! = 0
   k.escd = False
   
   If Val(txtUC("txtQtyPrinted").text) = 0 And RTrim$(txtUC("txtDrugCode").text) <> "" Then
      If PBSDrugToDispens() Then                       '31Jan03 TH (PBSv4)
         EnterDays% = billpatient(28, ans$)            '   " '***** was 23
         txtUC("txtQtyPrinted").text = ans$
      Else
         Select Case L.IssType
            Case "I", "S", "W"
               getwardtopup pid.ward, tdate$, days, topdate%
               
            Case "D": days = Val(plvl$("DaysForDischarge"))
            
            Case "O": days = Val(plvl$("DaysForOP"))
            
            Case "B"
               Select Case pid.status
                  Case "D": days = Val(plvl$("DaysForDischarge"))
                  Case "O": days = Val(plvl$("DaysForOP"))
                  Case "I": getwardtopup pid.ward, tdate$, days, topdate%
                  End Select
            
            Case "C"
            
               'If l.dose(1) > 0 Or (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
               '19Jun08 TH Replaced above with call to new function
               If CIVASDoseIncStat(L.dose(1)) > 0 Then
                  If d.dosesperissueunit > 0 Then
                     ans$ = plvl$("NumOfCIVASdoses")
                     k.nums = True
                     k.decimals = False   '11Jan02 TH Changed to false as shouldnt allow fraction of a dose  (#57650)
                     k.Max = 4
                     InputWin "Issue calculator", "Enter Number of doses to issue", ans$, k
                     If Val(ans$) < 1 Then k.escd = True    '11Jan02 TH Reinstated but using val to also trap fractions below 1 (#57650)
   
                     If Not k.escd Then
                        doses! = d.dosesperissueunit
                        txtUC("TxtNumOfLabels").text = ans$
                        gCIVASdos$ = CStr(Val(ans$))
                        setm_sgnCivasDose Val(ans$)    '22May08 TH Ported
                     End If
                  Else
                     popmessagecr "#Prescribing units per pack not entered", "Entering prescribing units per pack will do automtaic CIVAS calculations"
                  End If
               End If
         End Select

         If Not k.escd Then
            DosesForDays 1, DailyDoses!
            'If doses! = 0 And d.dosesperissueunit > 0 Then
            '22Nov05 TH replaced above with bloc
            blnSuppressQtyCalc = (d.dosesperissueunit = 0)
            If chkUC("chkManual").Value = 1 Then blnSuppressQtyCalc = True
            If InStr(1, "," & TxtD(dispdata$ & "\PATMED.INI", "", "", "QuantityManualEntryTypes", 0) & ",", "," & Trim$(d.PrintformV) & Trim$(d.DPSform) & ",", 1) Then
               blnSuppressQtyCalc = True
            End If
            
            If WDir.StatDoseFlag Then  '10Jan12 TH Added
               days = 1
            Else
               
               If doses! = 0 And (Not blnSuppressQtyCalc) Then
               '22Nov05 TH ---------
                  msg = ""
                  If d.issueWholePack = "Y" Then
                     'If d.dosesperissueunit >= 1 Then      '25Jun10 CKJ OK to have fraction eg 0.25 mg per tablet  (RCN P0158 F0088216)
                     If d.dosesperissueunit > 0 Then        '   "
                        wholeIssue% = Int(DailyDoses! / d.dosesperissueunit)
                        If (DailyDoses! / d.dosesperissueunit) > wholeIssue% Then wholeIssue% = wholeIssue% + 1
                        msg = Trim$(Str$(wholeIssue%))
                     Else
                        'undefined
                     End If
                  Else
                     'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then   '     "
                     If d.LabelInIssueUnits Then
                        msg = LTrim$(Str$(DailyDoses!))
                     Else
                        msg = LTrim$(Str$(DailyDoses! / d.dosesperissueunit))
                     End If
                  End If
                  
                  If Len(msg) Then
                     strPlural = plural$(Val(msg))
                     'strDrug = Trim$(d.storesdescription)                                 '24May06 TH Added
                     'If Trim$(strDrug) = "" Then strDrug = Trim$(d.Description)           ' XN 4Jun15 98073 New local stores description
                                         strDrug = Trim$(d.DrugDescription)
                     strDrug = "    (" & d.SisCode & ")  " & strDrug & cr & cr & "    "   '   " use strDrug here now
                     plingparse strDrug, "!"
                     msg = strDrug & msg & " " & Trim$(LCase$(d.PrintformV)) & strPlural & " prescribed each day" & cr & cr
                  End If
                  
                  If days = 0 Then
                     EnterDays = LastEnterDays
                  Else
                     EnterDays = days
                  End If
                  ''ans$ = InputBox$(msg$ & "Enter number of days supply" & cr & Msg2$, "Issue Quantity calculator", LTrim$(Str$(EnterDays)))
                  
                  '07Nov05 CKJ removed InputBox
                  ans$ = LTrim$(Str$(EnterDays))
                  k.Max = 3
                  k.min = 1
                  k.nums = True
                  InputWin "Issue Quantity calculator", msg$ & "    Enter number of days supply, or cancel to enter quantity manually" & cr, ans$, k
                  If k.escd Then ans$ = ""
                  days = Val(ans$)
                  LastEnterDays = days
               End If
               
               k.escd = False
               If ans$ = "" Then k.escd = True
         
            End If '10Jan12 TH Added
               
            If doses! = 0 Then doses! = days% * DailyDoses!
               
            If doses! > 0 Then
               'If d.dosesperissueunit > 0 Then
               If d.dosesperissueunit > 0 And (Not blnSuppressQtyCalc) Then '22Nov05 TH replaced above
                  If d.issueWholePack = "Y" Then
                     'If d.dosesperissueunit >= 1 Then   '25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)
                     If d.dosesperissueunit > 0 Then     '   "
                        wholeIssue% = Int(doses! / d.dosesperissueunit)
                        If (doses! / d.dosesperissueunit) > wholeIssue% Then wholeIssue% = wholeIssue% + 1
                        txtUC("txtQtyPrinted").text = Trim$(Str$(wholeIssue%))
                     Else
                        'undefined
                     End If
                  Else
                     'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then  '    "
                     If d.LabelInIssueUnits Then
                        txtUC("txtQtyPrinted").text = LTrim$(Str$(doses!))
                     Else
                        txtUC("txtQtyPrinted").text = LTrim$(Str$(doses! / d.dosesperissueunit))
                     End If
                  End If
                  'PCT - need to record doses here '01Feb12 TH NO - now only ever from direction
                  'If PCTDrugToDispens() Then            '13Dec11 TH TFS 21049
                  '   If Not WDir.StatDoseFlag Then
                  '      setPCTDose Val(txtUC("txtQtyPrinted").text), days%, False
                  '
                  '   End If
                  '
                  'End If
   
                  txtUC("txtQtyPrinted").text = Format$(txtUC("txtQtyPrinted").text)
               Else
                  k.escd = True
                  SetFocusTo txtUC("txtQtyPrinted")
               End If
            Else
               k.escd = True
               SetFocusTo txtUC("txtQtyPrinted")
            End If
         End If
      End If
      escaped = k.escd
   End If
   
End Sub

Sub CalcDosesPrescribed(L As WLabel, DosesPrescribed!)
'27Jul96 ASC Calculates number of doses in prescribing units for the whole prescription

Dim dt As DateAndTime, xp As DateAndTime, thisdose!, X%        ', mins&

   For X = 1 To 6
      Ldose!(X) = L.dose(X)
      LTime$(X) = L.Times(X)
   Next
''   If dow$ = "" Then dow$ = "1234567"  '!!**
   dt.mint = L.RxStartDate
   minstodate dt
   xp.mint = L.StopDate
   minstodate xp
   
''   DosesBetweenTimes True, Ldose!(), LTime$(), (mins&), L.days(), dt, xp, DosesPrescribed!, 0, thisdose!
   DosesBetweenTimes True, Ldose!(), LTime$(), L.days(), dt, xp, DosesPrescribed!, 0, thisdose!

End Sub

Sub CalcIV(DoseNum, changefinalvol%)
'22Nov94 ASC Added changefinalvol
'28Aug98 TH  Changed formats to suppress stray decimal points
'24Sep98 TH  Changed formats
'01Jul13 TH Record the actual concentration here for the print heap (TFS 39202)
'15Sep15 TH  Ensure we derive a dose in a similar matter to CIVAS Stat for Custom frequency - there is no dose in the slot so we have to scrape from the dircode text (TFS 129498)

Dim dose!, Vol!, dosevol!, bagvol!, Minvol!, MaxVol!, DoseByVol!, NewCont$, NewSize$, mult&, text$
Dim temp$
ReDim lines$(4)
Dim intSlash As Integer
Dim strActualConcentration As String
Dim strActualConcentrationmgml As String
Dim strActualDose As String
Dim strActualVolume As String

   dose! = Val(txtUC("txtDose", DoseNum).text)
    
   'dose! = CIVASDoseIncStat(Val(txtUC("txtDose", DoseNum).text)) '25Jun08 TH Replaced
   '25Jun08 TH Added block
   If L.dose(DoseNum) = 0 Then
      'This could be a stat dose if so we will use the stat dose not the current one on screen
      'If (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Then
      If (InStr(LCase(txtUC("TxtDircode").text), "stat") > 0) Or isCustomFrequency() Then '15Sep15 TH Replaced above to also include custom frequency (TFS 129498)
         intSlash = InStr(txtUC("TxtDircode").text, "/")
         If intSlash > 0 Then
            dose! = Val(Left$(txtUC("TxtDircode").text, intSlash - 1))
         End If
      End If
   End If
   '25Jun08 TH -------
   
   If dose! > 0 Then
      If Not changefinalvol Then
         If d.MaxInfusionRate > 0 Then                              '17Dec96 ASC fixed volume IV
            txtUC("TxtFinalVol").text = Format$(d.MaxInfusionRate)
            Vol! = d.MaxInfusionRate
         Else
            If d.mgPerml > 0 And d.dosesperissueunit > 0 Then
               dosevol! = (dose! / d.dosesperissueunit) * (d.ReconVol + d.DisplacementVolume)
               bagvol! = dose! / d.mgPerml
            Else
               'popmessagecr d.Description, "Information for IV calculations not entered"   XN 4Jun15 98073 New local stores description
               popmessagecr d.LabelDescription, "Information for IV calculations not entered"
            End If
            If bagvol! > dosevol! Then
               Vol! = bagvol!
            Else
               Vol! = dosevol!
            End If
            txtUC("TxtFinalVol").text = Format$(Vol!, "###0.##") '24Sep98 TH Reinstated
            txtUC("TxtFinalVol").text = Format$(txtUC("TxtFinalVol").text) '24Sep98 TH Changed
         End If
      Else
         If d.MaxInfusionRate > 0 Then              '17Dec96 ASC fixed volume IV
            Vol! = d.MaxInfusionRate
         Else
            Vol! = Val(txtUC("TxtFinalVol").text)
         End If
         If Vol! <= 0 Then                          '23Jan95 CKJ added
            popmessagecr "Warning", "Final volume should not be zero"
         Else
            If d.MaxmgPerml = 0 Then            '20Jan95 CKJ added check
               popmessagecr "Warning", "Maximum mg per ml = 0   Please set up in the drug file"
            Else
               'If dose! / vol! > d.MaxmgPerml Then      '06Sep98 ASC
               If dp!(dose! / Vol!) > d.MaxmgPerml Then
                  Minvol! = dose! / d.MaxmgPerml
                  popmessagecr "", "Minimum recomended volume for this dose = " + Format$(Minvol!, "###0.##") + "ml - Please correct"
               End If
            End If
            If d.MinmgPerml = 0 Then          '20Jan95 CKJ added check
               popmessagecr "Warning", "Minimum mg per ml = 0   Please set up in the drug file"
            Else
               'If Dose! / vol! < d.MinmgPerml Then      '06Sep98 ASC
               If dp!(dose! / Vol!) < d.MinmgPerml Then
                  MaxVol! = dose! / d.MinmgPerml
                  popmessagecr "", "Maximum recommended volume for this dose = " + Format$(MaxVol!, "###0.##") + "ml - Please correct"
               End If
            End If
         End If
      End If
''       ChooseContainer Vol!, (Left$(Dispens.CmbContainer.Text, 1)), NewCont$, NewSize$   '27Dec97 ASC
''       Dispens.TxtContainerSize.Text = NewSize$
'''       cmbUC("CmbContainer").Text = NewCont$  '23May05 TH Removed
''       expandcontainer (Dispens.CmbContainer.Text)                                      '27Dec97 ASC

   End If
   
    ' If we get here Vol! can be zero so rather than doing dose!/Vol! and getting an error
    ' replace the 2 times this calc is performed with the one here and check for Vol! = 0
    ' and set the calc result to zero instead.
    If Vol! <= 0 Then
        DoseByVol! = 0
    Else
        DoseByVol! = dose! / Vol!
    End If
  
   '01Jul13 TH Record the actual concentration here for the print heap (TFS 39202)
   strActualDose = Format$(dose!, "#####0.##")
   strActualVolume = Format$(Vol!, "###0.##")
   'strActualConcentration = Format$(dose!, "#####0.##") & " " & Trim$(d.DosingUnits) & " in " & Format$(Vol!, "###0.##") & " mL"
   strActualConcentration = Format$(strActualDose) & " " & Trim$(d.DosingUnits) & " in " & Format$(strActualVolume) & " mL" '06Aug13 TH Use correctly formatted figures
   'Need this as mg per mL
    strActualConcentrationmgml = Format$(DoseByVol!, "#####0.##")                                        '06Aug13 TH Use correctly formatted figures
   strActualConcentrationmgml = Format$(strActualConcentrationmgml) & " " & Trim$(d.DosingUnits) & "/mL"    '  "
   'Now put on heap '06Aug13 TH Added formats
   Heap 10, gPRNheapID, "ActualDose", Format$(strActualDose), 0
   Heap 10, gPRNheapID, "ActualVolume", Format$(strActualVolume), 0
   Heap 10, gPRNheapID, "ActualConcLong", strActualConcentration, 0
   Heap 10, gPRNheapID, "ActualConcmgml", strActualConcentrationmgml, 0
   strActualConcentrationmgml = Format$(DoseByVol!, "#####0.##")
   Heap 10, gPRNheapID, "ActualConc", strActualConcentrationmgml, 0
   '------
   
   If d.InfusionTime > 0.001 And txtUC("TxtInfusionTime").text = "N/A" Then
      txtUC("TxtInfusionTime").text = LTrim$(Str$(d.InfusionTime))
   End If

   Select Case UCase$(Right$(txtUC("TxtInfusionTime").text, 1))   '24Jan95 CKJ
      Case "H":  mult = 60
      Case "D":  mult = 1440
      Case Else: mult = 1
      End Select
   txtUC("TxtInfusionTime").text = LTrim$(Str$(Val(txtUC("TxtInfusionTime").text) * mult))

   If Val(txtUC("TxtInfusionTime").text) > 0.001 Then
            temp$ = Format$((Vol! / Val(txtUC("TxtInfusionTime").text)) * 60, "###0.##") '24Sep98
            lblUC("LblInfusionRate").Caption = Format$(temp$)

            '!!** Rate warning needs more thought
            ' limit may be ml/min
            '              mg/min
            '              mg/kg/min
            'IF VAL(LblInfusionRate.caption) > d.MaxInfusionRate THEN
            '      popmessagecr "WARNING", "Maximum infusion rate of" + STR$(d.MaxInfusionRate) + "ml/min has been exceeded"
            '   END IF
         Else
            txtUC("TxtInfusionTime").text = "N/A"
            lblUC("LblInfusionRate").Caption = "N/A"
      End If

   text$ = txtUC("txtTime", DoseNum).text
''   Dispens.fraIV.Caption = "&IV details"       '20Jan95 CKJ Removed time !!** It won't always be IV either

End Sub

Sub Calcqtys()
'Calculate Number of doses prescribed
'ASC 30Mar95 if No prescribed is less than calculated for top up then
'            top up = No prescribed
'           -If user changes topup new number preserved and auto recalc stopped
'            to allow qtys for PRN drugs and creams etc. Also fixed after
'            problems at prestwich
'03Jun97 KR  Now use getwardtopup to get topupdate and interval.
'04Jun97 KR  Added setting of information labels on dispensing form.
'08Jun97 KR  Refresh Frames to ensure displayed items visible.
'13Jun97 KR  Removed setting of  d.dosesperissueunit to 1 'cos needed for creams, eyedrops etc.
'19Jun97 KR/ASC Optimised loop code for increased speed
'26Jun97 KR. Ensured that the correct value is taken from the txtqtyprinted textbox if user overides default value
'            for items with dosesperissueunit = 0
'01Jun97 KR converted Text in TxtRxPrescribed to integer for comparison - prevents error if value ""
'08jul97 CKJ/KR Added MGO - milligrams oral
'11June97 KR Added erase of Ldose & Ltime.  Ensures that their is no hangover from a previous label
'14Jan97 SF  merged dosissunit% into dosissunit!
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'24Sep98 TH  Added formats
'23Feb99 SF  now issues in whole packs if setup in the drug file
'30Apr99 CFY Added extra fenceposts to issue whole packs mod to prevent div by zero errors
'19Aug99 SF  if the item is set to issueWholePack then the total amount is now rounded up rather than at each dose
'15May00 EAC Added code to allow default qtys to be calculated correctly for directions that are for specific days of
'            the week
'20Sep00 AJK Ensured rounding of txtqtyprinted.text
'27Jun01 CKJ Added option to inhibit the 'Awaiting Pharmacist' message
'31Jan03 TH  (PBSv4) Set qtys specifically for PBS
'22Nov17 RL Pharmacy Dispensing - quantity calculation for IP dispensing broken - to use the "DaysForIp" from the Wconfiguration table if the topUp interval is 0 (TFS 184566)

'Implicitly uses
' L
' d
'

'txtUC("TxtQtyPrinted") is a candidate for local variable
' the various lbxXXX.visible could be grouped


Dim ShowWarning%
Dim dailyamount!, amt!, nDays%
Dim DosingUnits%, dosissunit!, days%, topdate%, found&, pdate$
Dim valid1%, valid2%, valid3%, valid4%, X%, doses!, thisdose!, topupdate$     'mins&,
Dim RestOfCourse!
Dim iDays%
Dim temp$
Dim strAns As String, intEnterDays As Integer
Dim blnSuppressQtyCalc As Boolean
Dim DosingDays(1 To 7) As Boolean
Dim PCTdoses! '20Nov11 TH Added for PCT
Dim lngnDays As Long
Dim interval As String
Dim td As DateAndTime


   If Trim$(L.PrescriberID) = "" And Trim$(L.PharmacistID) <> "" Then
      WarningCaption "Awaiting Prescriber"
      ShowWarning = True
   End If
   
   If Trim$(L.PrescriberID) <> "" And Trim$(L.PharmacistID) = "" Then
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "InhibitMessageAwaitingPharmacist", 0)) = False Then '27Jun01 CKJ Added
         WarningCaption "Awaiting Pharmacist"
         ShowWarning = True
      End If
   End If
   
   'find topup information for ward
''   If stcklward$ <> pid.ward Then
''         stcklward$ = pid.ward
''      End If
''   getwardtopup stcklward$, Find$, days%, topdate%
   getwardtopup (pid.ward), Find$, days%, topdate%

   'Set the daysforIp from wconfiguration if the top up interval is 0
    If days% = 0 And topdate = 3 Then
    Select Case L.IssType
      Case "I", "S", "W"
            Select Case L.IssType
               Case "I": days = Val(plvl$("DaysForIP"))
               Case "S": days = Val(plvl$("DaysForSM"))
               Case "W": days = Val(plvl$("DaysForWard"))
            End Select
      End Select
        If (days <> 0) Then
            today td
            td.mint = td.mint + (1440& * days)
            minstodate td
            DateToString td, Find$
            topdate = 2
        Else
            days = 0          'No topupdate or interval set
            topdate = 3
        End If
        
   End If
   Select Case topdate%
      Case 1, 2
         found& = True
         TopUpPeriod$ = Str(days%)
      Case 3, 4, 5
         found& = False
         TopUpPeriod$ = ""
      End Select

   parsedate (txtUC("TxtStartDate").text), pdate$, "1", valid1
   parsedate (txtUC("TxtStopDate").text), pdate$, "1", valid2
   parsetime (txtUC("TxtStartTime").text), pdate$, "1", valid3
   parsetime (txtUC("TxtStopTime").text), pdate$, "1", valid4
   If valid1 And valid2 And valid3 And valid4 Then
      StringToDate (txtUC("TxtStopDate").text), dt
      StringToTime (txtUC("TxtStopTime").text), dt
      
      datetomins dt
      'If WDir.StatDoseFlag Then '10Jan10 TH Added window for stat
      '   dt.mint = dt.mint + 1440 '24 Hours
      '   minstodate dt
      'End If
      today td
      
      If L.IsHistory Then
         WarningCaption "Item from PMR History"
         ShowWarning% = True
      ElseIf dt.mint <= td.mint Then                             '10Jan12 TH Replaced with below. Port from PBS Chemo to try and calc a sensible issue qty for a stat
      'ElseIf dt.mint <= td.mint And Not WDir.StatDoseFlag Then    '20Oct11 TH Added stat check (maybe should be 24 hour woindow for stat instead ? SAF)Then
         WarningCaption "Prescription Expired"
         ShowWarning% = True
      Else
         StringToDate (txtUC("TxtStartDate").text), td
         StringToTime (txtUC("TxtStartTime").text), td
         datetomins td
         
         '10June97 KR Ensures that there is no hangover from a previous label
         Erase Ldose!
         Erase LTime$

         For X = 1 To 6
            If Val(txtUC("TxtDose", X).text) = 0 Then Exit For    '19Jun97 ASC/KR
            'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then  '     "
            If d.LabelInIssueUnits Then
               If d.dosesperissueunit > 0 Then                                        '27Apr98 ASC/CFY
                  Ldose!(X) = Val(txtUC("TxtDose", X).text) / d.dosesperissueunit
               End If
            Else
               DosingUnits% = True
               Ldose!(X) = Val(txtUC("TxtDose", X).text)
            End If
            LTime$(X) = txtUC("TxtTime", X).text
            dailyamount! = dailyamount! + Ldose!(X) '02Mar97 KR Added!!
         Next
               
''         dow$ = ""
         For X = 1 To 7
            DosingDays(X) = TrueFalse(chkUC("ChkDay", X).Value)
''            If chkUC("ChkDay", X).Value = 1 Then
''                  dow$ = dow$ + LTrim$(Str$(X))
''                  iDays = iDays + (2 ^ X)          '15May00 EAC Added
''               End If
         Next
''         If dow$ = "" Then dow$ = "1234567"
         DosesBetweenTimes True, Ldose!(), LTime$(), DosingDays(), td, dt, doses!, 0, thisdose!   '09May05 removed (mins&)
         txtUC("TxtNodPrescribed").text = LTrim$(Str$(doses!))

         'Calculate NOD to date
         StringToDate (txtUC("TxtStartDate").text), dt
         StringToTime (txtUC("TxtStartTime").text), dt
         datetomins dt
         today td
         DosesBetweenTimes True, Ldose!(), LTime$(), DosingDays(), dt, td, doses!, 0, thisdose!    '09May05 removed (mins&)
         
         If found& <> 0 Then
            'found topup ward information
            If Val(TopUpPeriod$) > 0 Then
               'Top up by number of days
               If Not UserTopUpQty% Then 'And txtUC("TxtTopUpQty").Visible Then 'ASC 30Mar95 '!!** 16May97 KR Removed
                  'Only recalculate if form visible and user not entered their own number e.g. creams etc.
                  LSet dt = td
                  xp.mint = Val(TopUpPeriod$) * 1440
                  AddExpiry dt, xp
                  
                  '09May05 V8.6 used days "1234567", not from the screen **WHY** and is it correct to use array?
                  DosesBetweenTimes True, Ldose!(), LTime$(), DosingDays(), td, dt, doses!, 0, thisdose!    '09May05 removed (mins&)
                  txtUC("TxtTopUpQty").text = LTrim$(Str$(doses!))
               End If
               
            Else            'ASC 09Jan95
               'Top up to next defined date for ward
               StringToDate (txtUC("TxtStartDate").text), td
               StringToTime (txtUC("TxtStartTime").text), td
               datetomins td
               topupdate$ = Trim$(Find$)
               If Len(topupdate$) = 10 Then
                  StringToDate topupdate$, dt
                  StringToTime "12:00", dt
                  datetomins dt
                  If td.mint >= dt.mint Then
                     If passlvl <> 3 And L.IssType = "I" Then
                        WarningCaption "Enter Ward Topup Date"
                        ShowWarning% = True
                     End If
                  Else
                     doses! = 0
                     DosesBetweenTimes True, Ldose!(), LTime$(), DosingDays(), td, dt, doses!, 0, thisdose!    '09May05 removed (mins&)
                     DosesToTopUP! = doses!
                     txtUC("TxtTopUpQty").text = LTrim$(Str$(doses! - Val(txtUC("TxtSupplied").text)))
                     RestOfCourse! = Val(txtUC("TxtNodPrescribed").text) - Val(txtUC("TxtSupplied").text)
                     If RestOfCourse! < Val(txtUC("TxtTopUpQty").text) Then
                        'If whole course is less than topupqty only give rest of course
                        txtUC("TxtTopUpQty").text = LTrim$(Str$(RestOfCourse!))
                     End If
                  End If
               Else
                  If passlvl <> 3 And L.IssType = "I" Then
                     WarningCaption "No Topup date"
                     ShowWarning% = True
                  End If
               End If
            End If
         End If
      End If
   End If
      
   'If d.dosesperissueunit = 0 Then  'i.e. for items that you do not know how much you are going to give e.g. ointments, eye drops etc
   '15Nov05 CKJ/TH Allow flexibility of when to calculate doses, eg inhalers in mg have dosesperissueunit, but we want to issue at least a whole one.
   blnSuppressQtyCalc = (d.dosesperissueunit = 0)
   If chkUC("chkManual").Value = 1 Then blnSuppressQtyCalc = True
   If InStr(1, "," & TxtD(dispdata$ & "\PATMED.INI", "", "", "QuantityManualEntryTypes", 0) & ",", "," & Trim$(d.PrintformV) & Trim$(d.DPSform) & ",", 1) Then
      blnSuppressQtyCalc = True
   End If
   
   If blnSuppressQtyCalc Then
      lblUC("LblUntil").Visible = False
      lblUC("Lblreason").Visible = False
      txtUC("TxtDescDate").Visible = False
      lblUC("LblSupply").Visible = False
      If txtUC("TxtQtyPrinted").Tag = "" Then txtUC("TxtQtyPrinted").text = "0" '26Jun97 KR.
      
      '02Feb99 EAC Added if clauses
''      If Not (OCXlaunch() And GetOCXAction() = "E") Then
      txtUC("TxtQtyPrinted").Enabled = True
''         txtUC("TxtDircode").Enabled = True
''      End If
         
   Else
      If passlvl = 3 Then
         '20May95 ASC If inpatient use top-up qty for qty to print and Issue
         If L.IssType = "I" And Not ShowWarning% Then
            txtUC("TxtQtyPrinted").text = txtUC("TxtTopUpQty").text
            txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtQtyPrinted").text)
         ElseIf L.IssType = "I" And ShowWarning% Then
            If dailyamount! = 0 Then dailyamount! = 1
            amt! = Val(txtUC("TxtNodPrescribed"))
            CalcDefaultcourse amt, dailyamount!, nDays%, (L.IssType), DosingDays()
            If amt! > 0 Then
               txtUC("TxtQtyPrinted").text = amt!
               txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtQtyPrinted").text)
            Else
               txtUC("TxtQtyPrinted").text = txtUC("TxtNodPrescribed")
               txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtQtyPrinted").text)
            End If
         End If
         If d.issueWholePack = "Y" And InStr(txtUC("TxtQtyPrinted").text, ".") > 0 Then txtUC("TxtQtyPrinted").text = Format$(Int(txtUC("TxtQtyPrinted").text) + 1)      '19Aug99 SF added
         
      Else
         '10Jan12 TH Ported form PBS Chemo - ensure stat gives a calculated issue qty if possible.Requires set up of WDir correctly
         '20Oct11 TH reset on stat dose
         If WDir.StatDoseFlag Then
            txtUC("TxtNodPrescribed") = dailyamount!
            amt = dailyamount
         '   days% = 1
         End If
         '------------------------
         
         Select Case L.IssType
            Case "I", "S", "W"
               '02Feb99 EAC E7 mods; added if statement
''               If Not (OCXlaunch() And GetOCXAction() = "E") Then
                  txtUC("TxtQtyPrinted").Enabled = True
''                  txtUC("TxtDircode").Enabled = True
''               End If

               If Find$ <> "" And days% <> 0 Then
                  lblUC("LblUntil").Visible = True
                  lblUC("Lblreason").Visible = True
                  lblUC("LblSupply").Visible = True
                  txtUC("TxtDescDate").Visible = True
                  lblUC("Lblreason").Caption = "top-up."
                  txtUC("TxtDescDate").text = Find$
                  If txtUC("TxtQtyPrinted").Tag = "" Then
                     If Val(txtUC("TxtNodPrescribed")) < doses! Then '01Jun97 KR added val
                        If DosingUnits% Then
                           If d.dosesperissueunit = 0 Then dosissunit! = 1 Else dosissunit! = d.dosesperissueunit  '14Jan97 SF merged dosissunit% into dosissunit!
                           txtUC("TxtQtyPrinted").text = Str$(Val(txtUC("TxtNodPrescribed")) / dosissunit!)
                           txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtQtyPrinted").text)  '24Sep98 TH Added
                        Else
                           txtUC("TxtQtyPrinted").text = txtUC("TxtNodPrescribed")
                           txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtQtyPrinted").text)  '24Sep98 TH Added
                        End If
                        If d.issueWholePack = "Y" And InStr(txtUC("TxtQtyPrinted").text, ".") > 0 Then txtUC("TxtQtyPrinted").text = Format$(Int(txtUC("TxtQtyPrinted").text) + 1)      '19Aug99 SF added
                        
                        txtUC("TxtDescDate").Visible = False
                        lblUC("LblUntil").Visible = False
                        lblUC("Lblreason").Visible = False
                        lblUC("LblSupply").Caption = "Prescribed less than top-up."
                     Else
                        If doses! - L.RxNodIssued > 0 Then
                           If DosingUnits% Then
                              If d.dosesperissueunit = 0 Then dosissunit! = 1 Else dosissunit! = d.dosesperissueunit  '14Jan97 SF merged dosissunit% into dosissunit!
                              txtUC("TxtQtyPrinted").text = Str$((doses! - L.RxNodIssued) / dosissunit!)
                              temp$ = Format$(Val(txtUC("TxtQtyPrinted").text) / (dailyamount! / dosissunit!), "#0.##")     '24Sep98 TH Changed to retain mask
                              lblUC("LblSupply").Caption = "(" & Format$(temp$) & " days supply.)"
                           Else
                              txtUC("TxtQtyPrinted").text = Str$(doses! - L.RxNodIssued)
                              If dailyamount! = 0 Then dailyamount = 1
                              temp$ = Format$(Val(txtUC("TxtQtyPrinted").text) / dailyamount!, "#0.##")                     '24Sep98 TH Changed to retain mask
                              lblUC("LblSupply").Caption = "(" & Format$(temp$) & " days supply.)"
                           End If
                           If d.issueWholePack = "Y" And InStr(txtUC("TxtQtyPrinted").text, ".") > 0 Then txtUC("TxtQtyPrinted").text = Format$(Int(txtUC("TxtQtyPrinted").text) + 1)      '19Aug99 SF added
                           If dailyamount! = 0 Then dailyamount! = 1
                        Else
                           txtUC("TxtQtyPrinted").text = 0
                           lblUC("LblSupply").Caption = "Ward top-up complete."
                        End If
                     End If
                  End If
               Else
                  lblUC("LblUntil").Visible = False
                  lblUC("Lblreason").Visible = False
                  lblUC("LblSupply").Visible = True
                  txtUC("TxtDescDate").Visible = False
                  lblUC("LblSupply").Caption = "Expired or no ward top-up set."
                  If txtUC("TxtQtyPrinted").Tag = "" Then txtUC("TxtQtyPrinted").text = 0
               End If

            Case "O", "D", "L"
               'CalcDefaultcourse amt, dailyamount!, nDays%, (L.IssType), DosingDays()
               '10Jan12 TH ported from PBS Chemo. Replace above 20Oct11 TH reset on stat dose
               If WDir.StatDoseFlag Then
                  lblUC("LblSupply").Caption = ""
               Else
                  CalcDefaultcourse amt, dailyamount!, nDays%, (L.IssType), DosingDays()
                  lblUC("LblSupply").Caption = "(Default " & Str$(nDays%) & " days supply.)"
               End If
               '02Feb99 EAC E7 mods; add if statement
''               If Not (OCXlaunch() And GetOCXAction() = "E") Then
                  txtUC("TxtQtyPrinted").Enabled = True
''                  txtUC("TxtDircode").Enabled = True
''               End If
               
               lblUC("Lblreason").Visible = False
               txtUC("TxtDescDate").Visible = False
               lblUC("LblUntil").Visible = False
               lblUC("LblSupply").Visible = True
               'lblUC("LblSupply").Caption = "(Default " & Str$(nDays%) & " days supply.)" '10Jan12 TH Replaced with above (Port from PBS Chemo)
               
               If txtUC("TxtQtyPrinted").Tag = "" Then
                  If Val(txtUC("TxtNodPrescribed")) < amt Then   '01Jun97 KR
                     If DosingUnits% Then
                        If d.dosesperissueunit = 0 Then dosissunit! = 1 Else dosissunit! = d.dosesperissueunit '14Jan97 SF merged dosissunit% into dosissunit!
                        txtUC("TxtQtyPrinted").text = Format$(Str$(Val(txtUC("TxtNodPrescribed")) / dosissunit!)) '24Sep98 TH Added
                     Else
                        txtUC("TxtQtyPrinted").text = Format$(txtUC("TxtNodPrescribed"))    '24Sep98 TH Added
                     End If
                     If d.issueWholePack = "Y" And InStr(txtUC("TxtQtyPrinted").text, ".") > 0 Then txtUC("TxtQtyPrinted").text = Format$(Int(txtUC("TxtQtyPrinted").text) + 1)      '19Aug99 SF added
                     txtUC("TxtDescDate").Visible = False
                     lblUC("LblUntil").Visible = False
                     lblUC("Lblreason").Visible = False
                     lblUC("LblSupply").Caption = "Prescribed less than default."
                  Else
                     If DosingUnits% Then
                        If d.dosesperissueunit = 0 Then dosissunit! = 1 Else dosissunit! = d.dosesperissueunit '14Jan97 SF merged dosissunit% into dosissunit!
                        txtUC("TxtQtyPrinted").text = Str$(amt / dosissunit!)                                   '14Jan97 SF merged dosissunit% into dosissunit!
                     Else
                        txtUC("TxtQtyPrinted").text = amt
                     End If
                     If d.issueWholePack = "Y" And InStr(txtUC("TxtQtyPrinted").text, ".") > 0 Then txtUC("TxtQtyPrinted").text = Format$(Int(txtUC("TxtQtyPrinted").text) + 1)      '19Aug99 SF added
                     
                     'txtUC("TxtQtyPrinted").Text = amt
                  End If
               End If
            
            Case "C"
               '02Feb99 EAC E7 mods; added if clause
''               If Not (OCXlaunch() And GetOCXAction() = "E") Then
                     txtUC("TxtQtyPrinted").Enabled = True
''                     txtUC("TxtDircode").Enabled = True
''                  End If

               lblUC("Lblreason").Visible = False
               txtUC("TxtDescDate").Visible = False
               lblUC("LblUntil").Visible = False
               lblUC("LblSupply").Visible = False
               If txtUC("TxtQtyPrinted").Tag = "" Then txtUC("TxtQtyPrinted").text = 0   'forces issues calculator
            
            Case "P"
               lblUC("Lblreason").Visible = False
               txtUC("TxtDescDate").Visible = False
               lblUC("LblUntil").Visible = False
               lblUC("LblSupply").Visible = False
               txtUC("TxtQtyPrinted").text = 0
               txtUC("TxtQtyPrinted").Enabled = False
''               txtUC("TxtDircode").Enabled = False
            End Select
         txtUC("TxtQtyPrinted").Tag = ""
         fraUC("fraLineColour").Refresh
         fraUC("fraPrepared").Refresh
      End If
   End If
      
   If Not ShowWarning Then
      WarningCaption ""
   End If

   If PBSDrugToDispens() Then            '04Mar03 TH (PBSv4) Added Fencepost
      If UCase(Trim$(PBSReadBillitem(53))) <> "N" And L.PrescriptionID = 0 Then
         strAns = ""
         intEnterDays = billpatient(28, strAns)   '***** was 23
         If strAns <> "" Then
            txtUC("TxtQtyPrinted").text = strAns
         End If
      End If
   End If
   
   If PCTDrugToDispens() Then            '20Nov11 TH (PBSv4) Added Fencepost
      '19Sep11 TH Record number of doses here for use in chemo claim
      If Not WDir.StatDoseFlag Then
         PCTdoses! = 0
         StringToDate (txtUC("TxtStartDate").text), td
         StringToTime (txtUC("TxtStartTime").text), td
''         If nDays > 0 Then
''            'derive stop date from this not the default course length ?
''            datetomins td
''            dt.mint = td.mint
''            'datetomins td
''
''            lngnDays = nDays
''
''            dt.mint = dt.mint + (lngnDays * 1440)
''            minstodate dt
''         Else
            StringToDate (txtUC("TxtStopDate").text), dt
            StringToTime (txtUC("TxtStopTime").text), dt
            datetodays txtUC("TxtStartDate").text, txtUC("TxtStopDate").text, lngnDays, 0, "", 0   '13Dec11 TH TFS 21049
            nDays = lngnDays                                                                     '   "
''         End If
         DosesBetweenTimes True, Ldose!(), LTime$(), DosingDays(), td, dt, PCTdoses!, 0, thisdose!
         If thisdose > 0 And PCTdoses > 0 Then
            'TH Hook the dose into PCT for use in calculations for claim
            setPCTDose PCTdoses!, nDays, False
         End If
      End If
   End If
   
      
   'ajk 20Sept00 Event 46985
   txtUC("TxtQtyPrinted").text = strRound(txtUC("TxtQtyPrinted").text)

End Sub

Sub CanTheLabelBeSaved(intLabelok%)
'19Jun01 TH Written as a cutdown version of the things that are checked before saving the label
'           and can result in the label not being saved. By calling this routine prior to the issue
'           it is hoped the issue can be stopped if it is clear the label will not be saved afterwards.
'           This should prevent instances of transactions saved without PMR entries (labels)
'           Fault from RAH Strategy to Proceed (#52393)
'           Code is taken from Formtolabel
'20Jun01 AE  Corrected variable name from RouterRequired to RouteRequired.
'18Jul01 TH Added call add extra direction here, as prompting after issue led to inability to save label (#54002)
'           Closed off for prescribing however to retain previous functionality at this point when prescriber level
'           and avoid possible unidentified implications (safety measure!)

Dim msg$, RouteRequired%
Dim X As Integer

   intLabelok = True
   RouteRequired = False                                                      '20Jun01 AE  Corrected variable name

   If Len(RTrim$(storeddirect$)) > 0 And Right$(txtUC("TxtDircode").text, 1) = "/" And passlvl <> 3 Then    '18Jul01 TH
         AddAdditionalDir storeddirect$
         storeddirect$ = ""
      End If

   If txtUC("TxtDircode").text = "" And passlvl <> 3 Then
         intLabelok = False
         msg$ = "No Direction Code Entered" & crlf
      End If

   For X = 1 To 6
      If LTrim$(txtUC("txtTime", X).text) <> "" Then
            If Val(txtUC("txtDose", X).text) <> 0 Then RouteRequired = True
         End If
   Next

   If cmbUC("CmbRoute").Visible And RouteRequired And LTrim$(cmbUC("CmbRoute").text) = "" Then
         msg$ = msg$ & "Please enter appropriate route" & crlf
         SetFocusTo cmbUC("CmbRoute")
         intLabelok = False
      End If
   
   If intLabelok = False Then popmessagecr "Invalid data", msg$ & "Correct and re-try"
         
End Sub

''Sub ChangeTopupDate()
'''2Apr95 ASC Change Topup Date for a ward
'''03Jun97 KR Now use supplier file to get & set topup date.
'''07Jun97 KR Now read the supplier file with no lock and reread it with lock prior to saving it.
'''           Should lessen the chances of the supplier file being locked at any one time.
''
''Dim sup As supplierstruct
''Dim valid%
''Dim FoundSup As Long, sDate$
''
''   getsupplier pid.ward, 0, FoundSup, sup
''   If FoundSup > 0 And sup.suppliertype = "W" Then
''      parsedate sup.topupdate, sDate$, "1", valid
''      If Trim$(sDate$) <> "" And valid Then
''            Do
''               sDate$ = InputBox$("Enter next topup date ", "Change Topup Date", sDate$)  '!!** change to our library
''               parsedate sDate$, "", "1", valid
''               If Not valid And sDate$ <> "" Then MsgBox "Please re-enter date"
''            Loop Until valid Or sDate$ = ""
''            parsedate sDate$, sDate$, "3", valid
''            getsupplier pid.ward, 0, FoundSup, sup
''            If sDate$ <> "" Then sup.topupdate = sDate$
''            If FoundSup > 0 Then putsupplier FoundSup, sup
''''            stcklward$ = "" 'forces CalcQtys to look up details again next time
''         Else
''            popmessagecr "Change setup in ward editor", "This ward set up for topup by number of days"
''         End If
''
''      End If
''
''End Sub

Sub checkdateorder(startdate$, StartTime$, StopDate$, StopTime$, valid)

   If startdate$ = "" Then startdate$ = txtUC("TxtStartDate").text
   If StartTime$ = "" Then StartTime$ = txtUC("TxtStartTime").text
   If StopDate$ = "" Then StopDate$ = txtUC("TxtStopDate").text
   If StopTime$ = "" Then StopTime$ = txtUC("TxtStopTime").text

   StringToDate startdate$, dt
   StringToTime StartTime$, dt
   datetomins dt

   StringToDate StopDate$, td
   StringToTime StopTime$, td
   datetomins td

   If dt.mint <= td.mint Then valid = True Else valid = False

End Sub

''Sub CheckForPIDChanges(pidptr&)
'''16Jul98 EAC Written for Hong Kong mods
'''05Feb99 CFY Now checks and saves patient notes if necessary
'''24Mar99 CFY Removed line which re-loads PIDExtra as this caused any changes which where made to
'''            be lost.
'''11May99 CFY Reloads original patient record if user decides that they do not want to save changes.
'''02May00 CFY Refreshes heap if patient details have changed
'''15dec00 CKJ Removed the other GetPIDextra which was overwriting changes
'''             NOTE: the underlying problems are that there are too many surface area variables, and none is treated
'''             as the master. This must be corrected. Secondly, the PIDextra and PIDnotes UDTs are written back to disk
'''             without any checks for update in the meantime - ie may overwrite other changes made elsewhere.
'''             This is not acceptable.
'''09Feb01 CKJ Added option to ask or suppress the confirmation box. NB Default is to suppress it.
'''             To enable the confirmation add a line to Patmed.ini
'''             ConfirmSavingHeightWeightChanges = "Y"
'''             where T/F/Y/N/1/0/-1 etc are accepted
''
''Dim msg$, ans$
''Dim success%
''Dim TmpPIDNotes As PatidtypeNotes
''
''   If OCXlaunch() And GetOCXAction() = "E" Then Exit Sub        'Enquiry mode is read only so don't save changes
''
''   GetPatIDNL patno&, pidwas
''
''   msg$ = ""
''
''   GetPIDNotes pid.recno, TmpPIDNotes                                                        '05Feb99 CFY Added
''   If Trim$(TmpPIDNotes.notes) <> Trim$(pidNotes.notes) Then                                 '        "
''         msg$ = msg$ & "Notes, allergies or diagnosis records have been changed. " & crlf    '        "
''      End If                                                                                 '        "
''
''   GetPatidNL patno&, pidwas
''
''   If trimz$(pid.Height) <> trimz$(pidwas.Height) And trimz$(pid.Height) <> "" Then msg$ = msg$ & "Patient's Height was " & Format$(Val(trimz$(pidwas.Height))) & ", now is " & trimz$(pid.Height) & crlf$
''   If trimz$(pid.weight) <> trimz$(pidwas.weight) And trimz$(pid.weight) <> "" Then msg$ = msg$ & "Patient's Weight was " & Format$(Val(trimz$(pidwas.weight))) & ", now is " & trimz$(pid.weight) & crlf$
''   If pidExtra.SurfaceArea = 0 Then pidExtra.SurfaceArea = Val(SurfaceArea(pid.Height, pid.weight)) '16Nov98 ASC/EAC
''   If Abs(pidExtra.SurfaceArea - PatSurfaceArea!) > 0.0001 Then msg$ = msg$ & "Patient's Surface Area was " & Format$(pidExtra.SurfaceArea, "0.00;-0.00;0") & ", now is " & Format$(PatSurfaceArea!, "0.00;-0.00;0") & crlf$
''
''   If Trim$(msg$) <> "" Then
''         ans$ = "Y"
''         k.escd = False
''
''         If TrueFalse(txtd(dispdata$ & "\PATMED.INI", "", "N", "ConfirmSavingHeightWeightChanges", 0)) Then  '09Feb01 CKJ Added option
''               askwin "?Patient Details Amended", "Patient Details have changed." & crlf$ & crlf$ & msg$ & crlf$ & "Ok to save changes?", ans$, k
''            End If
''
''         If ans$ = "Y" And Not k.escd Then
''               SavePatient pid, pidptr&, pidwas, success%
''               pidExtra.SurfaceArea = PatSurfaceArea!
''               PutPIDExtra pid.recno, pidExtra
''               PutPIDNotes pid.recno, pidNotes                                '05Feb99 CFY Added
''               FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0   '02May00 CFY Added
''            Else                                                              '11May99 CFY Added
''               GetPatidNL patno&, pid                                         '       "
''            End If
''      End If
''
''End Sub

Sub CheckIssType(default%)
'22Jun96     re-instated proc from DOS release
'19Dec96 EAC commented out CloseWindow
'04Apr97 KR  added check for CIVAS item when l.civas = "Y" and isstype <> "C"
'06May97 KR  Added check for TPN type to prevent offer to change patid.status
'03Jun97 KR  Now check for ward in supplier file and check for ward stocklist item in mdb.
'12Jun97 KR  Now check TPN issue type P no T
'08Jan99 SF  if label selfmed and inpatient then shouldn't ask to to change to an inpatient
'15Mar99 SF  if in repeat dispensing mode do not ask to change status when creating a label of a different type
'17Jan01 CKJ Amended to avoid asking prescribers if the patient status should be changed     (#49541)
'21May02 SF  now only populates issue type combo with relevant issue types (#60132)
'27May02 SF  fix to mod 21May02 which solves problem with a blank PMR
'28May02 SF  enhnaced the description on confirmation of ward stock issue (#60488)
'24Jun02 TH  Added switch on default 3 to ensure labelamended flag is not set when this procedure is called
'            whilst the user is creating a new script. (#60132)
'25Jun02 SF  changed logic in deciding whether a blank PMR
'06Aug02 TH  Added message box - if wardstock already selected then just warn the user,
'            dont offer a choice (especially when there isnt really one on offer!) (#60488)
'09Aug02 TH  Added check on new labels to ensure default iss type is retained there (#62330)
'25Sep02 TH  Altered logic on above mod (#63323)

'default = true   offer   l.isstype best guess
'default = false  convert l.isstype to CmbIssueType with checking and warnings
'default = 2      convert l.isstype to CmbIssueType with no checking
 
'  Isstype     IF   pid.status   ward stock   wardATC drugATC drugCIVAS  l.isstype
'              --
'I = Inpatient          I
'O = Outpatient         O
'D = Discharge          D
'C = Civas              ?                                         X
'W = Ward stock         I            X
'L = Leave              L or I
'A = ATC                ?                         X       X
'S = Self Medication    I
'B = Baker Cell         not an issue type any more ASC 1Apr95
'T = TPN                ?
'-----------------------------------------------------------------------------

Dim issamended%, temp$, isstoconvtype$
Dim found%
Dim tdate$, days, topdate%
Dim iAsk As Integer             '17Jan01 CKJ added
Dim ans$, failed As Integer, desc$, X As Integer
Dim msg$                        '28May02 SF added (#60488)
Dim blnNewlbl As Integer      '24Jun02 TH Added (#60132)

   issamended = False
   temp$ = L.IssType

   If default = 3 Then      '24Jun02 TH (#60132)
      default = 2
      blnNewlbl = True
   End If

   If default <> 2 And L.IssType <> "C" And L.IssType <> "P" Then   '22Jun96 ASC dispens.CmbIssueType.AddItem "Manufacturing"       '12June97 KR Changed T to P
      If LTrim$(L.IssType) = "" Then
            L.IssType = pid.status
         Else
            If (pid.status <> L.IssType) And Not (pid.status = "I" And L.IssType = "S") Then    '08Jan99 SF
               If Not (pid.status = "I" And InStr("CWLSABP", L.IssType)) And Not (pid.status = "O" And L.IssType = "A") Then
                  isstoconvtype$ = L.IssType
                  Select Case L.IssType
                     Case "C", "L", "W", "A", "S", "B", "P"
                        isstoconvtype$ = "I"
                  End Select

                  iAsk = True                                                               '17Jan01 CKJ Amended to avoid asking prescribers
                  If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "RepeatDispensing", 0)) Then iAsk = False '17Jan01 CKJ Don't ask if it's repeat dispensing
''                           If Mid$(acclevels$, 1, 1) = "3" Then iAsk = False                       '17Jan01 CKJ Don't ask prescribers  08Nov05 CKJ removed acclevels 3
                  
                  If iAsk Then
                                 ' 15Mar99 SF moved all the following code into the above IF block
                     ans$ = "Y"
                     Confirm "Status in patient file = " & pid.status, "change patient status to " & isstoconvtype$, ans$, k
                     If ans$ = "Y" And Not k.escd Then
                        ' I know that the personal details may have changed
                        ' since the record was read, but it a deliberate
                        ' choice to not use any revised name, caseno etc
                        ' at this point, since the operator has accepted
                        ' the data in Ident as it is, and the label should
                        ' reflect what has been accepted.
''                                       getpatidL patno&, pid  ' <== LOCK
''                                       statuswas$ = pid.Status                 'CKJ 26.06.92
                        pid.status = isstoconvtype$
''                                       putpatidL patno&, pid  ' <== UNLOCK
''
''                                       'Update PATWDCON index   26Jun92 CKJ    'CKJ< this line down to ...
''                                       Select Case UCase$(statuswas$)
''                                          Case "D", "S", "X", "Z"     'discharged, stock, expired, merged
''                                             waswsc$ = ""             'not indexed
''                                          Case Else
''                                             waswsc$ = RTrim$(pid.ward + statuswas$ + pid.cons)
''                                          End Select
''
''                                       Select Case UCase$(pid.Status)
''                                          Case "D", "W"
''                                             iswsc$ = ""
''                                          Case Else
''                                             iswsc$ = RTrim$(pid.ward + pid.Status + pid.cons)
''                                          End Select
      ''
''                                       If waswsc$ <> iswsc$ Then    ' ward-status-cons
''                                             passnumber = 2
''                                             Do
''                                                Updateindex waswsc$, iswsc$, patno&, patdatapath$ + "\patwdcon.idx", failed
''                                                If failed = -1 Then
''                                                      popmessagecr "!n!i", ftui + "patwdcon"
''                                                      WriteLog patdatapath$ + "\Error.Log", 0, UserID$, ftui + "patwdcon"
''                                                      Exit Do
''                                                   End If
''                                                If passnumber = 1 Then popmessagecr "!n!bUpdating Index, Please Wait", "Waiting for access to an index; it is still locked"
''                                                If passnumber Then passnumber = passnumber - 1
''                                             Loop While failed
''                                          End If
                     End If
                  End If
               End If
            End If
         End If

         If LTrim$(L.SisCode) <> "" Then
            getwardtopup pid.ward, tdate$, days, topdate%
            If topdate% <> 3 And topdate% <> 4 Then   'ie. ward found
               TopUpPeriod = Str$(days)
            Else
               TopUpPeriod = ""
            End If
            onwsl pid.ward, L.SisCode, found%
      
            If found% = True And pid.status = "I" And L.IssType <> "L" And L.IssType <> "O" And L.IssType <> "D" And L.IssType <> "S" Then 'ASC 14Nov94
               Select Case default
                  Case True
                     L.IssType = "W"
                  Case False
                     If L.IssType = "W" Then                                                  '06Aug02 TH Added (#60488)
                        popmessagecr "#", "Ward Stock Issue. No Stock will be booked out."
                     Else
   ''                              ans$ = "Y"
   ''                              msg$ = "OK to enter as Ward Stock?" & cr & cr
   ''                              msg$ = msg$ & "'No' will issue to patient" & cr
   ''                              msg$ = msg$ & "'Yes' will issue as a ward stock label?"
   ''                              Confirm "?Found on Stock list", msg$, ans$, k
                           
                        ans = TxtD(dispdata$ & "\PATMED.INI", "", "Y", "WardStockIssueDefault", 0)
                        msg = Trim$(d.storesdescription)
                        plingparse msg, "!"
                        msg = "(" & d.SisCode & ")  " & msg & cr & cr
                        msg = msg & "This product is on the stock list for " & Trim$(pid.ward) & cr & cr
                        msg = msg & "OK to record as Ward Stock?" & cr
                        msg = msg & "(No issue will be made from Pharmacy stock)"
                        askwin "?Found on Stock list", msg$, ans$, k
                          
                        If ans$ = "Y" Then L.IssType = "W"
                     End If
               End Select
            End If
                  
            d.SisCode = L.SisCode
            getdrug d, 0, 0, False
''               If (d.ATC = "Y" Or d.ATC = "A") And Mid$(Find$, 5, 1) = "Y" And L.IssType <> "W" Then '12Apr94 ASC   '!!** find$ here
''                     If Default = False Then MsgBox "ATC product"
''                  End If
                  
            If d.ATC = "P" And L.IssType <> "P" Then
               Select Case default
                  Case True
                     L.IssType = "P"
                  Case False
                     ans$ = "Y"
                     Confirm "Repeater Pump item", "make 'Pump'issue type", ans$, k
                     If ans$ = "Y" Then L.IssType = "P"
               End Select
            End If
                  
            If d.civas = "Y" And L.IssType <> "C" Then   'ASC 08.07.92 'Check against batch first 27May08 TH

                     Select Case default
                        Case True
                           L.IssType = "C"
                        Case False
                           'ans$ = "Y"
                           'desc$ = d.Description  '26Jun98 ASC  To allow the user to see which drug when protocol prescribing
                           'plingparse desc$, "!"  '    "
                           'Confirm Trim$(desc$) & " IV (CIVAS) Product", "order from Centralised IV Additive Service", ans$, k  '26Jun98 changed to order from instead of make
                           'If ans$ = "Y" Then
                           L.IssType = "C"
                        End Select
            End If
            If d.civas <> "Y" And L.IssType = "C" Then L.IssType = pid.status '26Jun98 ASC
         End If
      End If
   
   
   '25Jun02 SF wrong type of check as labf& may be 0 for a new item with a populated PMR
   'If labf& > 0 Then    '27May02 SF solves problem with a blank PMR
''   If Dispens.TGLabelList.Rows > 0 Then
''         If (L.IssType <> "P") And (Trim$(L.SisCode) = "") And blnNewlbl Then
''               ' new item so all issue types
''               SetIssueType ""
''            Else
''               ' issue types depending on prescription
''               SetIssueType L.IssType
''            End If
''       Else          '27May02 SF do as before
   

         
   For X = 0 To cmbUC("CmbIssueType").ListCount - 1
      If L.IssType = Left$(cmbUC("CmbIssueType").List(X), 1) Then
         cmbUC("CmbIssueType").ListIndex = X
         Exit For
      End If
   Next
''       End If

   If (L.IssType <> temp$) And Not blnNewlbl Then
      LabelAmended = True
   End If

   '16Jun05 TH Added block
   If UCase$(Left$(cmbUC("CmbIssueType").text, 1)) = "C" Then
      txtUC("TxtQtyPrinted").Visible = False
      lblUC("LblQtyDesc").Visible = False
   Else
      txtUC("TxtQtyPrinted").Visible = True
      lblUC("LblQtyDesc").Visible = True
   End If

End Sub

''Function CheckLabelSpace() As Integer
'''17May04 TH Written to provide quick answer as to whether there is space to save a label (enh1532)
''
''Dim intCount As Integer, blnResult As Integer
''
''   blnResult = False
''   intCount = 1
''   Do                ' look at labrf&() for 1 to 50
''      If labrf&(intCount) <= 0 Then ' check for unused or deleted labels
''            blnResult = True
''            Exit Do
''         Else
''            intCount = intCount + 1
''         End If
''   Loop While intCount < 51
''
''   CheckLabelSpace = blnResult
''
''End Function

Sub CheckRxComplete(completeRx)
'06Oct99 CKJ Corrected TxtStopDate where TxtStopTime expected
'22Sep00 JN  Added check for TxtDirCode Tag set to C
'17Aug15 TH If this is a custom dose we also dont need the time (as in PRN) (TFS 126360)

Dim X, rightorder
   
   completeRx = True

   If LCase$(txtUC("TxtDircode").Tag) = "c" Then    '22Sep00 JN Added check for TxtDirCode.Tag = "c" here...
         completeRx = False
         Exit Sub
      End If

   For X = 1 To 6
      If Trim$(txtUC("TxtDose", X).text) <> "" And Trim$(txtUC("TxtTime", X).text) = "" Then
         completeRx = False
         Exit For
      End If
   Next
   
   'When manual or PRN or doses or time only used as an indicator
   If chkUC("ChkPRN").Value = 1 Or chkUC("ChkManual").Value = 1 Then
         completeRx = True
      End If
      
   '17Aug15 TH If this is a custom dose we also dont need the time (as in PRN) (TFS 126360)
   If (Len(OCXheap("Dircode", "")) = 0) And (Val(OCXheap("ScheduleID_Administration", "0")) > 0) Then completeRx = True
   
      
''   'Checks for multiple doses per day                     '09May05 a hang over from equalinterval dosing, where only 1st dose and no times are entered
''   If Val(txtUC("TxtRepeatInterval").Text) > 1 And cmbUC("CmbRepeatUnits").Text = "day" And Trim$(txtUC("TxtDose", 1).Text) <> "" Then
''         completeRx = True
''      End If
      
   If Not completeRx Then popmessagecr "!Prescription is not complete", "A dose has been specified without an administration time - please correct or set the PRN or manual box"
   
   'Checks dates and time format as well as order
   parsedate (txtUC("TxtStartDate")), "", "", rightorder
   If Not rightorder Then popmessagecr "!", "Start date not valid, please re-enter": completeRx = False
   
   parsedate (txtUC("TxtStopDate")), "", "", rightorder
   If Not rightorder Then popmessagecr "!", "Stop date not valid, please re-enter": completeRx = False
   
   parsetime (txtUC("TxtStartTime")), "", "", rightorder
   If Not rightorder Then popmessagecr "!", "Start time not valid, please re-enter": completeRx = False
   
   parsetime (txtUC("TxtStopTime")), "", "", rightorder
   If Not rightorder Then popmessagecr "!", "Stop time not valid, please re-enter": completeRx = False

   checkdateorder (txtUC("TxtStartDate")), (txtUC("TxtStartTime")), (txtUC("TxtStopDate")), (txtUC("TxtStopTime")), rightorder
   If rightorder = False Then
         popmessagecr "!", "Start Time is after Stop Time - please correct before saving"
         completeRx = False
      End If

End Sub

''Sub ChooseContainer(volume!, ContAbbr$, ContNew$, ContVol$)
'''27Jan95 CKJ written
'''File structure:
''' Abbr|Name|Nominal_volume|Volume_as_supplied|Maximum_volume|Minimum_volume
''' S|SYR|50|0|45|5
''' B|BAG|500|530|600|50
'''Given current container & vol required, returns new container abbr & vol
'''
'''Mods needed
'''!!** Should allow use of 2 x 50ml syr instead of switching to a 100ml bag
''
''Static ContData$(), contnum%, doneonce, ContMax%
''Dim MaxVol!, contchan As Integer, temp$, numoflines%, i As Integer           '01Jun02 All/CKJ
''
''   If Not doneonce Then
''         MaxVol! = 0
''         ReDim lines$(1 To 6)
''         contchan = FreeFile    '!!** error checks needed
''         Open dispdata$ + "\containr.dat" For Input As #contchan
''         Do While Not EOF(contchan)
''            Input #contchan, temp$
''            deflines temp$, lines$(), "|", 1, numoflines%
''            contnum = contnum + 1
''            ReDim Preserve ContData$(1 To 6, 1 To contnum)
''            For i = 1 To 6
''               ContData$(i, contnum) = UCase$(Trim$(lines$(i)))
''            Next
''            If Val(ContData$(5, contnum)) > MaxVol! Then
''                  ContMax = contnum
''                  MaxVol! = Val(ContData$(5, ContMax))
''               End If
''         Loop
''         Close contchan
''         doneonce = True
''      End If
''
''   For i = 1 To contnum
''      If ContData$(1, i) = ContAbbr$ And Val(ContData$(5, i)) >= volume! And Val(ContData$(6, i)) <= volume! Then
''            ContVol$ = ContData$(3, i)
''            ContNew$ = ContAbbr$
''            Exit For
''         End If
''   Next
''
''   If i > contnum Then  ' failed to find correct size in same range
''         For i = 1 To contnum
''            If Val(ContData$(5, i)) >= volume! And Val(ContData$(6, i)) <= volume! Then
''                  Exit For
''               End If
''         Next
''         If i > contnum Then i = ContMax
''         ContVol$ = ContData$(3, i)
''         ContNew$ = ContData$(1, i)
''         If ContNew$ <> ContAbbr$ Then
''               popmessagecr "Note", "Changing to " + ContVol$ + "ml " + ContData$(2, i)
''            End If
''      End If
''
''End Sub

Sub ChooseDirectionCode(WDirCode As String)
'14Jan96 ASC made lines$ static to improve speed of loading 2nd time
'07jul97 ASC corrected pointer& - 2
'14Oct97 CKJ corrected fencepost errors:
'            UBound(lines$) always fails first time with subscript out of range
'             since lines$() has not been DIM'ed
'            Corrected FOR loop: should not read beyond EOF
'            Moved GetPointer inside loop
'            Added hourglass
'            (also: array could be sized one less, and the RESUME NEXT should not be needed)
'05Mar98 CFY New parameter added to shellsort
'22Jul98 EAC make language aware
'21Mar00 GRS Dont display direction if user is a prescriber and .hideprescriber is set
'25Feb02 TH  use enhlistbox as default now (old form can be used on ini switch) (enh1340)
'            This standardises most of the selection screens from dispensing (wards,rxers etc. - but not cons) and allows
'            the text entry of the code enabling a psuedo text search on more than one char. Also added an override
'            (from terminal.ini) to allow an extension of the form width if required.
'09May05 CKJ renamed from ChooseDirection and added param do it doesn't touch the global WDir

'Select directions from SQL
' Selection criteria
'  sessionid (implies site)
'  language
'  code
'  ward
'  hideprescriber
'  deleted
'
' What to return
'  count(*)
'  *
'  pk, code, ward, text, hideprescriber
'
' Sort order
'  natural
'  by code
'  by text


Dim lErrNo        As Long
Dim sErrDesc      As String

Dim pointer&
Dim strLine As String
Dim blnOldForm As Integer
Dim intScrnWdth As Integer
Dim rs As ADODB.Recordset

   On Error GoTo ErrorHandler
   WDirCode = ""
   blnOldForm = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "OldDirectionForm", 0))

   If blnOldForm Then
      LstBoxFrm.lblTitle = "Choose a Direction"
      LstBoxFrm.lblHead = "  Code  " & TB & "Direction"
   Else
      EnhLstFrm.LstBox.Clear
      EnhLstFrm.Caption = "Choose a Direction"
      EnhLstFrm.lblTitle.Caption = ""
      EnhLstFrm.lblHead.Caption = "Code     " & TB & "Direction"
   End If
                  
'Select directions from SQL
' Selection criteria:
'  xxx sessionid (implies site)
'  xxx language
'  xxx ward
'  0/1 hideprescriber
'  0   deleted
'
' What to return:
'  pk, code, text, ward


'            If Not WDir.deleted And LTrim$(WDir.location) = "" Then
'If found& > 0 And Not (passlvl = 3 And WDir.HidePrescriber) Then

   Screen.MousePointer = HOURGLASS
'''Set rs = New ADODB.Recordset
   Set rs = GetDirectionRSbyCriteria("", "", 0, False)
   
   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         intScrnWdth = GreaterOf(Val(terminal$("DirectionScreenWidth", "70")), 4)
         Do While Not rs.EOF
            strLine = GetField(rs!directs)
            plingparse strLine, cr
            replace strLine, lf, "", 0
            strLine = Trim$(strLine)                   'remove any trailing spaces which were CRs
            If Len(strLine) > intScrnWdth Then
               strLine = Left$(strLine, intScrnWdth - 4) & " ..."
            End If
            strLine = RtrimGetField(rs!Code) & TB & strLine
            
            If blnOldForm Then
                  LstBoxFrm.LstBox.AddItem "  " & strLine
               Else
                  EnhLstFrm.LstBox.AddItem strLine
               End If
            rs.MoveNext
         Loop
      End If
   End If
   Screen.MousePointer = STDCURSOR
   
   If blnOldForm Then
      LstBoxShow
      If LstBoxFrm.LstBox.ListIndex > -1 Then
         WDirCode = Left$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB) - 1)
      End If
      Unload LstBoxFrm
   Else
      k.escd = False          '**?? needed?
      EnhLstBoxShow
      If EnhLstFrm.LstBox.Tag <> "" Then
         WDirCode = Trim$(UCase$(EnhLstFrm.TxtInput.text))
      End If
      Unload EnhLstFrm
   End If
      
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If lErrNo Then Err.Raise lErrNo, OBJNAME, sErrDesc
Exit Sub

ErrorHandler:
   lErrNo = Err.Number           'store incoming values
   sErrDesc = Err.Description
Resume Cleanup

End Sub

Sub ChooseMultipleDirections(ByVal intMaxnum As Integer, ByVal strPrompts As String, ByVal strPromptBold As String, intNumSelected As Integer, strSelected() As String)
'10Nov01 CKJ derived from ChooseDirection
'            NB Does not cache directions. If needed this should be done centrally, not in each proc.
'14feb03 ckj Added strPrompts. Up to four lines of text can be displayed. Use <cr> to separate lines
'            Added strPromptBold. "0000" to "1111" where 1 is bold on each line

Dim lines$(), dirs%
Dim found&, pointer&, X%, direction$
Dim strTemp As String
Dim count As Integer
Dim strLine As String
Dim rs As ADODB.Recordset

   ReDim strPrompt(3) As String

   k.escd = False
   intNumSelected = 0
   dirs = 0
   Screen.MousePointer = HOURGLASS
   
''   GetPointer ASCFileName("direct.v6", False, ""), pointer&, 0
''   ReDim lines$(1 To pointer& - 1)
''   For X = 2 To pointer&
''''      getdir (X), "", found&
''      found& = GetDirectionByPK(X, WDir)
''      If found& > 0 And Not (passlvl = 3 And WDir.HidePrescriber) Then
''            direction$ = WDir.directs
''            plingparse direction$, cr
''            If Not WDir.deleted And LTrim$(WDir.location) = "" Then
''                  dirs = dirs + 1
''                  lines$(dirs) = Trim$(WDir.Code) & TB & direction$
''               End If
''         End If
''   Next
''   shellsort lines$(), dirs, 0, ""
''
''   Load MultiList
''   MultiList.Caption = "ASCribe"
''
''   If Len(strPrompts) = 0 Then strPrompts = cr & "Select one or more Directions" & cr & cr
''   If Len(strPromptBold) = 0 Then strPromptBold = "0100"
''   deflines strPrompts, strPrompt(), cr & "(*)", 0, 0
''   For count = 0 To 3
''      MultiList.lblLine(count).Caption = strPrompt(count)
''      MultiList.lblLine(count).FontBold = TrueFalse(Mid$(strPromptBold, count + 1, 1))
''   Next
''
''   MultiList.Tag = Format$(intMaxnum)
''   For count = 1 To dirs
''      MultiList.LstUnSelected.AddItem lines$(count)
''   Next
   
   Load MultiList
   
   MultiList.Caption = "EMIS Health"
   If Len(strPrompts) = 0 Then strPrompts = cr & "Select one or more Directions" & cr & cr
   If Len(strPromptBold) = 0 Then strPromptBold = "0100"
   deflines strPrompts, strPrompt(), cr & "(*)", 0, 0
   For count = 0 To 3
      MultiList.lblLine(count).Caption = strPrompt(count)
      MultiList.lblLine(count).FontBold = TrueFalse(Mid$(strPromptBold, count + 1, 1))
   Next
   
   MultiList.Tag = Format$(intMaxnum)
   
   Set rs = GetDirectionRSbyCriteria("", "", 0, (passlvl = 3))    'hide from prescribers if necessary
   
   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         Do While Not rs.EOF
            strLine = GetField(rs!directs)
            plingparse strLine, cr
            replace strLine, lf, "", 0
            strLine = Trim$(strLine)                   'remove any trailing spaces which were CRs
            strLine = RtrimGetField(rs!Code) & TB & strLine
            
            MultiList.LstUnselected.AddItem strLine
            rs.MoveNext
         Loop
      End If
   End If
   Screen.MousePointer = STDCURSOR
   HorizCentreForm MultiList

   MultiList.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   
   If Val(MultiList.Tag) = True Then  'valid
         intNumSelected = MultiList.LstSelected.ListCount
         If intNumSelected > intMaxnum And intMaxnum > 0 Then intNumSelected = intMaxnum
         ReDim strSelected(intNumSelected) As String
         For count = 1 To intNumSelected
            strTemp = Trim$(MultiList.LstSelected.List(count - 1))
            strSelected(count) = Left$(strTemp, InStr(strTemp, TB) - 1)
         Next
      Else
         k.escd = True
      End If
   
   Unload MultiList

End Sub

Sub ClearDirections()
'21Sep00 JN Written to clear directions boxes on dispens.frm
'26Sep00 JN Moved to Patmed.bas as referred to in DrugChks.bas now

Dim intClearAdmin As Integer

   txtUC("txtDircode").text = ""
   txtUC("txtDirections").text = ""
   For intClearAdmin = 1 To 6
      txtUC("txtDose", intClearAdmin).text = ""
      txtUC("txtTime", intClearAdmin).text = ""
   Next

End Sub

''Sub clinsum_callback(Idx%, ans$)
'''To fill in the default text for the given control and answer
'''12oct99 AE Written.
''
''Dim tmp$
''
''   Select Case UCase(ans)
''      Case "Y"
''         ClinSum.TxtEntry(Idx).Text = GetClinSumDef(ClinGetIndex(Idx, "TBRL"), 1)
''
''      Case "N"
''         ClinSum.TxtEntry(Idx).Text = GetClinSumDef(ClinGetIndex(Idx, "TBRL"), 2)
''
''      Case "LIST"
''         tmp$ = ClinSum.TxtEntry(Idx).Text
''         ans$ = SelectedFromList(GetClinSumDef(ClinGetIndex(Idx, "TBRL") + 1, 2), (ClinSum.LblSection(Idx).Caption))
''         If ans$ <> "" Then
''               tmp$ = tmp$ & ans$
''               ClinSum.TxtEntry(Idx).Text = tmp$
''            End If
''
''      Case "TREE"
''         tmp$ = ClinSum.TxtEntry(Idx).Text
''         ans$ = Trim$(TreeSelectByParameters(GetClinSumDef(ClinGetIndex(Idx, "TBRL"), 2), 0))
''         If ans$ <> "" Then
''               tmp$ = tmp$ & ans$
''               ClinSum.TxtEntry(Idx).Text = tmp$
''            End If
''
''      'more...
''      End Select
''
''End Sub

''Sub CloseKinetics()
''
'''Clears up the selector instance and other objects in memory
'''22Jun00 AE Written
''
''Dim iHnd As Integer, sError  As String
''Dim iLine As Integer, bFinished As Integer
''Dim sText As String
''Dim iButton As Integer
''
''   'Clear the selector handle, allow to retry if failed
''   On Error GoTo CloseKineticsErr
''   iLine = 1
''   KineticsSelectorHnd 0, iHnd
''
''   Do
''      If iHnd > 0 Then SelectorFinished iHnd, sError
''      If sError <> "" Then
''            sText = sError & crlf$ & crlf$
''            sText = sText & "Click OK to try again, Cancel to terminate the program"
''            iButton = MessageBox(sText, MB_OKCANCEL + MB_ICONEXCLAMATION, "Pharmacokinetics")
''            bFinished = (iButton <> IDOK)
''         Else
''            bFinished = True
''         End If
''   Loop Until bFinished
''
''   KineticsCache 0, "", 0, ""
''
''CloseKineticsExit:
''Exit Sub
''
''CloseKineticsErr:
''   popmessagecr "!Pharmacokinetics", Format$(Err) & ": '" & Error$ & "' occured in CloseKinetics."
''Resume CloseKineticsExit
''
''End Sub

Sub ClosePatMed()

Dim i As Integer
   
   FailedExchange = 0
   Loaded% = 0
   LastEnterDays = 0
   Find$ = ""
   
   TopUpPeriod$ = ""
   For i = 1 To 6
      Ldose!(i) = 0
      LTime$(i) = ""
   Next
''   stcklward$ = ""

End Sub

Sub DecBlister()
'20Jan98 CFY Added

   BlisterSemaphore = BlisterSemaphore - 1

End Sub

Function DetailHandler(ByVal strAttribute As String, ByVal strValue As String, ByVal strSuffix As String) As String
'23Feb04 CKJ written
'            "  Surname: ", "Bloggs", ""  returns Surname: Bloggs
'            "  Surname: ", "", ""        returns nothing
'            "", "XYZ", ""                returns XYZ
'            "ABC", "XYZ", "DEF"          returns ABCXYZDEF

   If Len(strValue) Then                            'Item present
         DetailHandler = strAttribute & strValue & strSuffix
      Else
         DetailHandler = ""
      End If

End Function

Sub DisplaytheLabAndForm(NumofLabels%, PrintOutput%, escaped As Integer, expiry$, duplicate%)
'PrintOutput=-1 displays from Labelline$() faithfully to form
'22Jul96 KR  Added local copy of d, dcop, so as to preserve the value of d during calls.
'            This is because d is now global and previously it would not have been visible to
'            patmed.bas.  Fixes problem of change of drug not following through to prescribe
'            screen.
'23Sep96 CKJ Removed local d
'19Dec96 EAC Split issue qty over xx labels
'15Jan97 EAC Only split issue of xx labels if user specifies more than one label to be printed
'            don't use module level variable QtyIssued! as a temporary variable, use new tempqty!
'            remove confirmation of printing query
'03Feb97 KR  Merged Changes from S.
'18Feb97 KR  Incorporated ShowLabelsCalculator
'05Mar97 KR  Added check for civas labelling.
'21Mar97 KR  Removed ShowLabelsCalculator as now incorporated in issue form
'            Added duplicate parameter - still used for printing
'07Apr97 KR  Added setting of directions on the form, even if the
'            dispensing frame is not visible.
'08May97 KR  Changed setting of directions of form (see 07Apr97 ).  Now always call labeltoform
'            (prescriber &  dispenser view) which is necessary for setting start & stop dates which
'            are required during CheckRxComplete when saving a label.
'            Removed call to MakeExpirey as not needed.
'13Jun98 ASC would be a subscript out of range or division by zero if this is handling a free format label
'08oct98 CKJ Allow wrapping of lines when txt boxes are filled (eg long drug with '!' >36 chars)
'30Nov98 CFY Added code to handle duplicate sets of labels
'04May00 EAC Corrected handling of labels with edited warnings/instructions
'23Jun00 JN  Added routine to update the issue/batch number
'02Aug00 MMA Added: Global update for Teamwork
'29Jan02 TH  Add count of label element to print heap (enh 914)
'25Feb02 TH  Removed above for CIVAS lbls. Couldnt properly handle extra labels and anyway enhancement is not intended for CIVAS
'04Mar02 TH  Set MOJ Owing status to screen (#MOJ#)
'28May02 SF  displays DSS warning information (enh#1521)
'05Jun02 TH  Added possible prefix to lblcnt element (enh#914)
'09Mar04 CKJ Added location codes
'16May04 TH  Mod to retain modified dircode field (#67284)
'17May11 TH  Ported Robot changes from v8 for Trafford (RCNP0641)
'11Aug13 TH  Store multiple reprints if labelcount is set (TFS 71108)

Dim Col As Integer
Dim tempqty!               '15Jan97 EAC
Dim Y%
Dim strLblcnt As String '29Jan02 TH (enh 914)
Dim intPatBillStub, strMsg As String   '04Mar02 TH Added
Dim X As Integer, ans$
Dim strCaption As String   '09Mar04 CKJ
Dim RobotMessageID As Long  '20Nov06 CKJ '17May11 TH Ported (RCNP0641)
Dim intsyringeloop As Integer '03Dec12 TH Added
Dim tmplabelline$(10)  '03Dec12 TH Added
Dim intloop As Integer
Dim strSyrcnt As String  '06Dec12 TH
Dim intTotCIVASlbls  As Integer '09Jan13 TH Added for numbering of complete CIVAS label cycle
Dim intCIVASlblNum As Integer
Dim strCIVAScnt As String
   
   If PrintOutput = 0 Then
         'Labf& = PresentLabel&()   '12Oct05 CKJ
         Labf& = L.RequestID        '   "
         If Labf& <> 0 Then
               getlabel Labf&, L, False
            End If
      Else
         If PrintOutput = -1 Then
               PrintOutput = 0 'i.e. do not do conversion
            Else
               If L.extralabel Then
                  memorytolabel
                  For X = 1 To 11   '05Aug14 TH
                     If Mid$(labelline$(X), 2, 1) = "!" Then labelline$(X) = Right$(labelline$(X), Len(labelline$(X)) - 2)
                     Col = StoredColour(frmExtraLabel.TxtLabel(X).ForeColor)              '!!**
                     If Col > 0 Then
                           labelline$(X) = LTrim$(Str$(Col)) + "!" + frmExtraLabel.TxtLabel(X).text
                        Else
                           labelline$(X) = frmExtraLabel.TxtLabel(X).text
                        End If
                  Next
               Else
                  For X = 1 To 5    '?????97 ASC was 6
                     If Mid$(labelline$(X), 2, 1) = "!" Then labelline$(X) = Right$(labelline$(X), Len(labelline$(X)) - 2)
                     Col = StoredColour(txtUC("TxtLabel", X).ForeColor)              '!!**
                     If Col > 0 Then
                           labelline$(X) = LTrim$(Str$(Col)) + "!" + txtUC("TxtLabel", X).text
                        Else
                           labelline$(X) = txtUC("TxtLabel", X).text
                        End If
                  Next
               End If
           End If
      End If
   
   '19Dec96 EAC Split issue qty over xx labels
   If PrintOutput <> 3 Then
         DisplaytheLabel NumofLabels%, (PrintOutput%), k, expiry$, 0, 0
      Else
         If L.IssType <> "C" Then      'Added check for civas labelling
               For Y = 1 To duplicate%
                  tempqty! = Qty!
                  For X = 1 To NumofLabels%
                     If NumofLabels% = 1 Then
                           Qty! = tempqty!
                           LabelCost! = TotalIssueCost! / 100
                        Else
                           If tempqty! > 0 Then       '13Jun98 ASC would be a subscript out of range or division by zero if this is handling a free format label
                                 Qty! = LabelValues(X)
                                 LabelCost! = ((Qty! / tempqty!) * TotalIssueCost!) / 100
                              End If
                        End If
'>>                     Reverselabel k.escd

                     RobotMessageID = GetRobotPrintLabelMessageID()     '20nov06 CKJ prevent multiple copies printing locally '17May11 TH Ported (RCNP0641)
                     
                     If Not escaped Then
                           '29Jan02 TH Add count of label element to print heap (enh 914)
                           If InStr(TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCount", 0), L.IssType) > 0 And NumofLabels% > 1 Then
                              strLblcnt = Trim$(Str$(X)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "LabelCountSeparator", 0) & Trim$(Str$(NumofLabels%)) & TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCountSuffix", 0)
                              strLblcnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCountPrefix", 0) & strLblcnt     '05Jun02 TH Added possible prefix
                              Heap 10, gPRNheapID, "LblCnt", strLblcnt, 0
                              DisplaytheLabel 1, 3, k, expiry$, X, 0 '11Aug13 TH Moved from below (TFS 71108)
                           Else
                              Heap 10, gPRNheapID, "LblCnt", "", 0
                              DisplaytheLabel 1, 3, k, expiry$, 0, 0 '11Aug13 TH Moved from below (TFS 71108)
                           End If
                           'DisplaytheLabel 1, 3, k, expiry$, 0 '11Aug13 TH Moved above to try an store multiple reprints if labelcount is set (TFS 71108)
''                           If Not k.escd Then
'>>                                 forwardlabel k.escd
''                              End If
                        End If
                        
                     If RobotMessageID Then Exit For                    '20nov06 CKJ prevent multiple copies printing locally '17May11 TH Ported (RCNP0641)
                  
                  Next
                  Qty! = tempqty!
               Next
            Else
               'CIVAS LAbels
               'number doses so that can calculate the number of labels + 1
               tempqty! = Qty!
               Qty! = 0
               '03Dec12 TH Here for multi label syring issues
               'First work out how many labels store labelline originals
               'then replace dose and volume for each container
               'restore originals and out
               If Syringestolabel() > 1 Then
                  'store labelline() originals
                  For intloop = 0 To 10
                     tmplabelline$(intloop) = labelline$(intloop)
                  Next
               End If
               
               '09Jan13 TH Added for numbering of complete CIVAS label cycle
               intTotCIVASlbls = Syringestolabel() * NumofLabels%
               intCIVASlblNum = 1
               
               For intsyringeloop = 1 To Syringestolabel()
                  If Syringestolabel() > 1 Then
                     createlabel 1, intsyringeloop
                     '05Dec12 TH Add heap element here
                     strSyrcnt = Trim$(Str$(intsyringeloop)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "SyringeCountSeparator", 0) & Trim$(Str$(Syringestolabel())) & TxtD(dispdata$ & "\PATMED.INI", "", " syringes", "SyringeCountSuffix", 0)
                     strSyrcnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "SyringeCountPrefix", 0) & strSyrcnt     '05Jun02 TH Added possible prefix
                     Heap 10, gPRNheapID, "SyrCnt", strSyrcnt, 0
                  Else
                     Heap 10, gPRNheapID, "SyrCnt", "", 0
                  End If
                  For X = 1 To NumofLabels%
                     If Not escaped Then
                     
                        '09Jan13 TH Added Section (TFS 51980)
                        'strCIVAScnt = Trim$(Str$(intTotCIVASlbls)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "CIVASlblCountSeparator", 0) & Trim$(Str$(intCIVASlblNum)) & TxtD(dispdata$ & "\PATMED.INI", "", "", "CIVASlblCountSuffix", 0)
                        strCIVAScnt = Trim$(Str$(intCIVASlblNum)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "CIVASlblCountSeparator", 0) & Trim$(Str$(intTotCIVASlbls)) & TxtD(dispdata$ & "\PATMED.INI", "", "", "CIVASlblCountSuffix", 0) '14Jan13 TH Altered after testing as two figures were wrong way round
                        strCIVAScnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "CIVASlblCountPrefix", 0) & strCIVAScnt     '09Jan13 TH Added possible prefix
                        Heap 10, gPRNheapID, "CCnt", strCIVAScnt, 0
                        '09Jan13 TH ------
                        
                        DisplaytheLabel 1, 3, k, expiry$, intsyringeloop, 0 '06Jan13 TH Added Param
                        intCIVASlblNum = intCIVASlblNum + 1
                     End If
                  Next
               Next
               If Syringestolabel() > 1 Then
                  'restore labelline() originals
                  For intloop = 0 To 10
                     labelline$(intloop) = tmplabelline$(intloop)
                  Next
                  'createlabel 1, 0 'reset screen
                  'DisplaytheLabel 1, False, k, ""
               End If
               Qty! = tempqty!
               '05Dec12 TH Alear heap element for syringe counting
               Heap 10, gPRNheapID, "SyrCnt", "", 0
               Heap 10, gPRNheapID, "CCnt", "", 0
            End If
      End If
   
   If PrintOutput = 0 Then
         For X = 0 To 9                                                  '08oct98 CKJ Added
            txtUC("TxtLabel", X).text = ""
         Next
         If L.extralabel Then
''            'setforecolour 0, True
''            'ans$ = RTrim$(labelline$(0))
''            'If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''            'txtUC("TxtLabel", 0).text = LTrim$(txtUC("TxtLabel", 0).text & " " & ans$) '   "
''            'txtUC("TxtLabel", 0).Refresh
''
''            txtUC("TxtLabel", 2).text = "This is an Extended Label"
''            txtUC("TxtLabel", 2).Refresh
''
''            txtUC("TxtLabel", 3).text = "Click here to view Label"
''            txtUC("TxtLabel", 3).Refresh
''
''            'For X = 6 To 9
''            '   setforecolour (X), True
''            '   ans$ = RTrim$(labelline$((X + 10)))
''            '   If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''            '   txtUC("TxtLabel", (X)).text = LTrim$(txtUC("TxtLabel", (X)).text & " " & ans$)  '   "
''            '   txtUC("TxtLabel", (X)).Refresh
''            'Next
''            setforecolour 9, True, False
''            'ans$ = RTrim$(labelline$(19))
''            ans$ = RTrim$(labelline$(17)) 'reserve 2 lines
''            If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''            txtUC("TxtLabel", 9).text = LTrim$(txtUC("TxtLabel", 9).text & " " & ans$) '   "
''            txtUC("TxtLabel", 9).Refresh
            setExtendedLabelWYSWY
         Else
            For X = 0 To 9
               setforecolour X, True, False
               ans$ = RTrim$(labelline$(X))
               If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
               txtUC("TxtLabel", X).text = LTrim$(txtUC("TxtLabel", X).text & " " & ans$) '   "
               txtUC("TxtLabel", X).Refresh
            Next
         End If
      End If
   If InStr(plvl$("PrintRxNumOnLabel"), L.IssType) Then
         lblUC("lblExpiry").Caption = " No." & Format$(L.PrescriptionID) & "/" & Format$(L.batchnumber)
         '04Mar02 TH Set MOJ Owing status to screen (#MOJ#)
         intPatBillStub = billpatient(23, strMsg)
         If Trim$(strMsg) <> "" Then lblUC("lblExpiry").Caption = lblUC("lblExpiry").Caption & strMsg
      Else
         lblUC("lblExpiry").Caption = labelline$(10)
      End If
   lblUC("lblExpiry").Refresh
   txtUC("TxtDrugCode").text = L.SisCode
   lblUC("LblPrintForm").Caption = d.PrintformV

   CheckIssType 2
   
   DSSInformation L.SisCode     '28May02 SF displays DSS warning information (enh#1521)
   '08May97 KR Changed.  Always call labeltoform which is necessary to set start & stop dates
   If Labf& > 0 Then labeltoform

   '09Mar04 CKJ Added block
   strCaption = TxtD(dispdata$ & "\patmed.ini", "Messages", "[cr]-  ", "MsgLocationDetail", 0)     'Custom line
   strMsg = DetailHandler(strCaption, Trim$(d.loccode2), "")                                       'line 3, may be blank
   strMsg = DetailHandler(strCaption, Trim$(d.loccode) & strMsg, "")                               'line 2+3, may also be blank
   strCaption = TxtD(dispdata$ & "\patmed.ini", "Messages", "Location:", "MsgLocationHeader", 0)   'Custom line
   strMsg = DetailHandler(strCaption, strMsg, "")                                                  'line 1+2+3, may also be blank
   If Len(strCaption) = 0 Then strMsg = ""                                                         'turn it all off if header absent

   ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
   lblUC("lblLocation").Caption = strMsg

End Sub

''Sub DoseFromKg(dose$)
'''26Jun98 ASC now allows the user to round the result and displays the calculation used
''
''Dim ans$, du$
''
''   If Val(pid.weight) > 0 Then
''         ans$ = LTrim$(Str$(Val(dose$) * Val(pid.weight)))
''         'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then    '26Jun98 ASC
''         If d.LabelInIssueUnits Then
''               du$ = LCase$(Trim$(d.PrintformV))
''            Else
''               du$ = LCase$(Trim$(d.DosingUnits))
''            End If
''         inputwin "Dosing per Kg Calculation", " Weight = " & pid.weight & "Kg" & cr & cr & " Exact dose calculated from " & dose$ & du$ & " per Kg = " & ans$ & du$ & cr, ans$, k
''         If k.escd Then
''               dose$ = "0"
''            Else
''               dose$ = Format$(Val(ans$))
''            End If
''      Else
''         MsgBox "Patient's weight Not entered", 0, ""
''      End If
''
''End Sub

''Sub DoseFromMsq(dose$)
'''26Jun98 ASC Allow user to round the dose
'''06Jul98 ASC Allow user to escape if Surface area not known
'''13Aug98 EAC Use stored patient surface
'''14Oct98 CKJ Squared symbol from country.044
'''28Jan99 Corrected line which displays the patients height. Was previously ommiting the inches.
'''02Sep99 AE Mods to stop prompting for Height and Weight even if surface area is entered
'''        currently, there is code to save the dosing sa, but no field in the standard db for it.
''
''Dim tmp$, ans$, squared$                                 '13Aug98 EAC added ans$
''Dim sa$, du$
''
''   k.escd = False                                                     '02Sep99AE Added
''   squared$ = TxtD("country", "", "²", "Squared", 0) '14Oct98 CKJ
''   'changed to use function from ident 03Dec96 ASC
''
''   If Val(pid.weight) >= 0.1 And Val(pid.Height) > 0 Then             '02Sep99AE Moved from above
''         sa$ = SurfaceArea(pid.Height, pid.weight)
''         If PatSurfaceArea! <> Val(sa$) And AskSAUpdate Then        '       "
''               tmp$ = "Calculated Surface Area = " & sa$ & " m" & squared$ & cr  '14Oct98 CKJ    '      "
''               tmp$ = tmp$ & "Dosing Surface Area = " & Format$(PatSurfaceArea!) & " m" & squared$ & cr  '14Oct98 CKJ       '    "
''               tmp$ = tmp$ & crlf$ & "Do you want to update the Dosing Surface Area using the Calculated Surface Area?"
''               askwin "?Surface Area", tmp$, ans$, k
''               If ans$ = "Y" And Not k.escd Then
''                     PatSurfaceArea! = Val(sa$)
''''                     Dispens.TxtPatDet(2).Text = sa$
''                  End If
''               k.escd = False
''               AskSAUpdate = False
''            End If
''      ElseIf PatSurfaceArea! <= 0.00001 Then                                      '02Sep99 AE Added
''         tmp$ = "Cannot calculate dose from surface area.  Height and Weight, " & crlf$
''         tmp$ = tmp$ & "or Dosing Surface Area must be entered to perform the calculation."
''         popmessagecr "!Surface Area", tmp$
''         k.escd = True
''      Else
''         tmp$ = "Height or Weight not entered.  OK to use Dosing Surface Area "   '    "
''         tmp$ = tmp$ & "to calculate Dose ?"                                      '    "
''         askwin "?Surface Area", tmp$, ans$, k                                    '    "
''         If ans$ <> "Y" Then k.escd = True                                        '    "
''      End If                                                                      '    "
''
''
''      If Not k.escd Then                                                          '02Sep99 AE Added
''         sa$ = Format$(PatSurfaceArea!)
''
''         If Val(pid.Height) >= 10 Then
''               tmp$ = pid.Height & " cm"
''            Else
''               tmp$ = Left$(pid.Height, 1) + Chr$(39) + Right$(Trim$(pid.Height), 2) + Chr$(34)    '    "
''            End If
''         'popmessagecr "Surface Area Calculation", " Height = " & tmp$ & cr & " Weight = " & pid.weight & "Kg" & cr & " Surface area used = " & sa$ & " m²"
''         ans$ = Format$(Val(dose$) * Val(sa$), "###0.##")                                                                                                                                                                                                                                                                                                                                                                                                                                                '26Jun98 ASC
''         If InStr(ans$, ".") = Len(ans$) Then ans$ = Left$(ans$, Len(ans$) - 1) '09Jan98 ASC removes trailing point
''         'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then    '    "
''         If d.LabelInIssueUnits Then
''               du$ = LCase$(Trim$(d.PrintformV))                                                                                                                                                                                                                                                                                                                                                                                                                                                         '    "
''            Else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         '    "
''               du$ = LCase$(Trim$(d.DosingUnits))                                                                                                                                                                                                                                                                                                                                                                                                                                                        '    "
''            End If                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       '    "
''         inputwin "Surface Area Calculation", " Height = " & tmp$ & cr & " Weight = " & pid.weight & "kg" & cr & " Surface area used = " & sa$ & " m" & squared$ & cr & " Exact Dose calculated from " & dose$ & du$ & " per m" & squared$ & " = " & ans$ & du$ & cr, ans$, k  '14Oct98 CKJ
''         'popmessagecr "Surface Area Calculation", " Height = " & tmp$ & cr & " Weight = " & pid.weight & "Kg" & cr & " Surface area used = " & sa$ & " m²"                                                                                                                                                                                                                                                                                                                                              '    "
''         'dose$ = Format$(Val(dose$) * Val(sa$), "###0.##")
''         If k.escd Then
''               dose$ = "0"
''            Else
''               dose$ = Format$(Val(ans$))
''            End If
''
''      End If                                                                              '02Sep99 AE Added
''
''End Sub

Sub DosesForDays(days%, doses!)
'26Jan95 CKJ If Days<0 then calc but inhibit message

Dim domsg As Integer, X As Integer, thisdose!, coursedoses!       'mins&,

   If days Then
         domsg = (days >= 0)
         days = Abs(days)
         For X = 1 To 6
            Ldose!(X) = L.dose(X)
            LTime$(X) = L.Times(X)
         Next
         
''         If dow$ = "" Then dow$ = "1234567"  '!!**

         today td
         LSet dt = td
         xp.mint = days * 1440
         AddExpiry dt, xp
         
         DosesBetweenTimes True, Ldose!(), LTime$(), L.days(), td, dt, doses!, 0, thisdose!     '09May05 removed (mins&)
         
         'ASC 31Oct94 Added to stop topping up beyond end of course
         CalcDosesPrescribed L, coursedoses!
         If coursedoses! - L.RxNodIssued < doses! Then
               doses! = coursedoses! - L.RxNodIssued
               If domsg Then popmessagecr "#", "Only" + Str$(doses!) + " doses required to complete the course"
            End If
      End If

End Sub

Sub DSSInformation(ByVal i_strNSVCode As String)
'28May02 SF added to display DSS information (enh#1521)

Const cSection = "Messages"

Dim udtProduct As DrugParameters
Dim strMessageSetting As String, strColourSetting As String
Dim strMessage As String, strColour As String
Dim lngFound As Long

   
   ' lookup NSV Code and make sure product exists
   BlankWProduct udtProduct
   udtProduct.SisCode = i_strNSVCode
   getdrug udtProduct, 0, lngFound, False
   
   If lngFound = 0 Then
         ' product not found
         strMessageSetting = "DSSMessageStatusNotFound"
         strColourSetting = "DSSColourStatusNotFound"

      ElseIf udtProduct.indexed = "1" Then
         ' product on DSS
         strMessageSetting = "DSSMessageStatusYES"
         strColourSetting = "DSSColourStatusYES"

      Else
         ' product not on DSS
         strMessageSetting = "DSSMessageStatusNO"
         strColourSetting = "DSSColourStatusNO"

      End If

   ' user defined
   strMessage = TxtD(dispdata$ & "\Patmed.INI", cSection, "", strMessageSetting, False)              ' default no message
   replace strMessage, "[cr]", crlf, 0
   strColour = TxtD(dispdata$ & "\Patmed.INI", cSection, Format$(Black), strColourSetting, False)    ' default colour black
   
   ' update display
   On Error Resume Next
   
   lblUC("lblDSSWarning").Caption = strMessage
   lblUC("lblDSSWarning").ForeColor = Val(strColour)
   
   On Error GoTo 0

End Sub

Sub DumpWaDetails(ByVal i_strContext As String)

'Debug routine.  Dumps (hopefuly) usefull information to a text file.
'The first time, will do a full dump of the ini file caches to the
'file, but thereafter will not to avoid wasting vast amounts of space.
'i_strContext is the name of the calling procedure, but can contain
'other info, separated by a "!"
'---------------------------------------------------------------------
'19Sep00 AE  Written

Dim strMsg As String
Dim strTmp As String
Dim blnFound As Integer
Dim n As Integer
Dim strSetting As String
Dim intFileCache As Integer, intIniCache As Integer
Dim strContext As String, strInfo As String
Dim intPos As Integer
Dim intFil As Integer

Static s_blnDumpedCache As Integer
Static s_intEvents As Integer
Const logfile = "\WaLabel.log"

'Remove pling
   strContext = i_strContext
   intPos = InStr(strContext, "!")
   If intPos Then
         strInfo = Mid$(strContext, intPos + 1)
         strContext = Mid$(strContext, 1, intPos - 1)
      End If

'Increment events counter
   s_intEvents = s_intEvents + 1

'Open file
   intFil = FreeFile
   Open dispdata$ & logfile For Append As intFil

   strMsg = crlf$ & crlf$ & "------------------------------------------------------------" & crlf$
   strMsg = strMsg & "Event logged at: " & Format$(Now, "ddmmmyyyy hh:mm:ss") & crlf$
   strMsg = strMsg & "Event " & Format$(s_intEvents) & " in this session." & crlf$
   strMsg = strMsg & "LabelID = " & L.PrescriptionID & crlf$
   strMsg = strMsg & "LabelType = " & L.IssType & crlf$
   strMsg = strMsg & "Patient Record Number=" & Format$(pid.recno) & crlf$
   strMsg = strMsg & crlf$

   Select Case LCase(strContext)
      Case "fillheaplabeltext"
         strMsg = strMsg & "FillHeapLabelText:" & crlf$
         strMsg = strMsg & "Found no settings for RxDescriptionSized or rxDirectionsSized!" & crlf$
      
      Case "highlightdescriptionlines"
         strMsg = strMsg & "HighlightDescriptionLines:" & crlf$
         strMsg = strMsg & "Could not find setting 'HighlightPMRDescriptionLines' in Patmed.ini!" & crlf$
      
      Case "createlabel"
         strMsg = strMsg & "CreateLabel:" & crlf$
         strMsg = strMsg & "iLblSplitLine=0" & crlf$
         strMsg = strMsg & "Description = " & strInfo & crlf$
      End Select

'Standard investigation report
   strMsg = strMsg & crlf$ & crlf$
   strMsg = strMsg & "Looking for settings:" & crlf$
   strMsg = strMsg & "Patmed.ini:HighlightPMRDescriptionLines="
   strTmp = TxtD(dispdata$ & "\patmed.ini", "", "N", "HighlightPMRDescriptionLines", blnFound)
   strMsg = strMsg & Iff(blnFound, strTmp, "<Not Found>") & crlf$

   For n = 1 To 9
      strSetting = "rxDescriptionSized" & Format$(n)
      strMsg = strMsg & "Terminal.ini:" & strSetting & ":StdLblFontName="
      strTmp = TxtD(dispdata$ & "\terminal.ini", strSetting, "", "StdLblFontName", blnFound)
      strMsg = strMsg & Iff(blnFound, strTmp, "<Not Found>") & crlf$
      strSetting = "rxDirectionsSized" & Format$(n)
      strMsg = strMsg & "Terminal.ini:" & strSetting & ":StdLblFontName="
      strTmp = TxtD(dispdata$ & "\terminal.ini", strSetting, "", "StdLblFontName", blnFound)
      strMsg = strMsg & Iff(blnFound, strTmp, "<Not Found>") & crlf$
   Next

'Other info
   strMsg = strMsg & crlf$ & "Internal Variables:" & crlf$
   strMsg = strMsg & "DescriptionSplitLine()=" & Format$(DescriptionSplitLine()) & crlf$
   ''strMsg = strMsg & "PatmedLblLPTType=" & UCase$(terminal$("PatmedLblLPTtype", "")) & crlf$
   strMsg = strMsg & crlf$

'Dump this section to the file
   Print #intFil, strMsg
   strMsg = ""

   If Not s_blnDumpedCache Then
         strMsg = strMsg & crlf$ & crlf$ & "Commencing INI Cache Dump:" & crlf$
         strMsg = strMsg & "File Cache:" & crlf$
         'Dump the contents of the heaps to the file
         GetIniHeapId intFileCache, intIniCache
         'File cache
         If intFileCache > 0 Then
               For n = 0 To frmHeap.lstHeap(intFileCache).ListCount - 1
                  strMsg = strMsg & frmHeap.lstHeap(intFileCache).List(n) & crlf$
               Next
            Else
               strMsg = strMsg & "File Cache Heap ID = 0!" & crlf$
            End If

         'Entries cache
         strMsg = strMsg & crlf$ & crlf$ & "Entries Cache:" & crlf$
         If intIniCache > 0 Then
               For n = 0 To frmHeap.lstHeap(intIniCache).ListCount - 1
                  strMsg = strMsg & frmHeap.lstHeap(intIniCache).List(n) & crlf$
               Next
            Else
               strMsg = strMsg & "Entry Cache Heap ID = 0!" & crlf$
            End If
         
         'Replace cr$ with crlf$
         replace strMsg, cr$, "¬", 0
         replace strMsg, "¬", crlf$, 0
         'Dump to file
         Print #intFil, strMsg
         strMsg = ""
         s_blnDumpedCache = True
      End If

   Close #intFil
'Pop a message the first time only
   If s_intEvents = 1 Then
         strTmp = "The label debug monitor has detected a problem with the" & cr$
         strTmp = strTmp & "label setup and has produced a log." & cr$
         strTmp = strTmp & "(To disable this feature, remove the switch '"
         strTmp = strTmp & WA_DEBUG_SWITCH & "' from the command line)"
         popmessagecr "Label Debug", strTmp
      End If
   
   DoSaferEvents 1
   ScreenRefresh
''   Dispens.Refresh

End Sub

Sub enterdate(DateStr$)
Dim valid
   
   KeyPad.Caption = "Enter Date"
   KeyPad.lblUnits.Caption = "Date"
   KeyPad.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   If Len(RTrim$(KeyPad.LCD.text)) > 0 And KeyPad.Tag = "-1" Then
         parsedate (KeyPad.LCD.text), DateStr$, "2", valid
         If Not valid Then k.escd = True: popmessagecr "!", "Date entered incorrectly - please retry"
      Else
         k.escd = True
      End If
   Unload KeyPad

End Sub

Sub EnterDirections(ByVal sDirections As String, sStartDate As String, DoseTime() As String, sRouteIn As String, sRouteChosen As String)
'------------------------------------------------------------------
'02Jun00 AE  Enter the directions on dispens.frm, as is done for protocols.
'
'sDirections:  string holding directions, eg 2/b/10d
'sStartDate:   If blank, uses the default (today), otherwise this date is written to the script if valid
'              If this is written, the start time is set to midnight that day.
'DoseTime():   If empty, the dosing times from the direction file are used; otherwise,
'              valid dates are written into the boxes on the script.  Dates are only written in if
'              there is a corresponding dose.
'sRouteIn:     String holding the route. If multiple or blank, the user is promted for a route.
'              The route used is passed out in sRouteChosen

'It appears necessary to enter each character in turn to make the
'process work.
'
'Directions are entered, then the prescription is saved
'
'25apr02 CKJ Added icon to message box
'------------------------------------------------------------------
   
Dim sDirs As String
Dim n As Integer, sTmp As String
Dim iNumTimes As Integer, bValid As Integer

   'Ensure the text box is empty first to prevent problems.
   'dispens.TxtDircode.Text = ""
   lblUC("DoAction").Caption = "DELETEDIR"
   DoEvents
   lblUC("DoAction").Caption = ""

   'Enter Directions
   sDirs = sDirections
   If Right$(sDirs, 1) <> "/" Then sDirs = sDirs & "/"

   'We have to use doevents here as dosaferevents uses a modal form which interfers
   'with popmessages which occur on dispens.
   For n = 1 To Len(sDirs)
      txtUC("TxtDircode").text = txtUC("TxtDircode").text & Mid$(sDirs, n, 1)
      DoEvents
   Next

   'If dosing times have been specified, these take precedence over the ones from
   'the direction file.
   On Error Resume Next
   iNumTimes = UBound(DoseTime)
   On Error GoTo 0

   For n = 1 To iNumTimes
      parsetime DoseTime(n), sTmp, "1", bValid
      If bValid And Trim$(txtUC("txtDose", n)) <> "" Then
      'times are only written in if valid and there is a corresponding dose entered
         txtUC("txtTime", n).text = sTmp
      End If
   Next
      
   'Enter the start date if one specified:
   If Trim$(sStartDate) <> "" Then
      parsedate sStartDate, sTmp, "1", bValid
      If bValid Then
         txtUC("txtStartDate") = sTmp
         txtUC("txtStartTime") = "00:00"
      End If
   End If
   
   'Enter the route
   sRouteIn = UCase(Trim$(sRouteIn))
   cmbUC("CmbRoute").ListIndex = -1
   For n = 0 To cmbUC("CmbRoute").ListCount - 1
      sTmp = UCase(Trim$(cmbUC("CmbRoute").List(n)))
      If sTmp = sRouteIn Then
         cmbUC("CmbRoute").ListIndex = n
         Exit For
      End If
   Next
   
   'if the drug has no route, or multiple route, must prompt for them now rather than in the
   'saving process, or it messes up the flow of events.
   'CheckRoute prompts for and enters the chosen route in CmbRoute
   If cmbUC("CmbRoute").ListIndex = -1 Then checkroute
   
   'Now return the chosen route.  This means that the calling proc can re-use it if
   'entering multiple prescriptions, without prompting for it at each one.
   sRouteChosen = cmbUC("CmbRoute").List(cmbUC("CmbRoute").ListIndex)

   'Save the Rx
   Confirm "?Pharmacokinetics", "authorise this prescription", sTmp, k     '25apr02 CKJ Added icon
   If sTmp <> "Y" Then Exit Sub
   lblUC("DoAction").Caption = "SAVE"                 'Save current prescription
   lblUC("DoAction").Caption = ""                     'Reset
''   Dispens.TGLabelList.SetFocus
   
End Sub

''Sub enterdose()
'''15Oct96 ASC moved from prescribe form
'''05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'''08Oct98 ASC/TH Now Handles oral liquids for prescribing
'''16Oct98 TH  Added format
'''10Nov98 TH  Code to deal with none oral solutions
'''10Nov01 CKJ Added > 0 to "syrup" comparison
'''18Mar02 TH  Added Tag to Keypad so that dose input has new validation (#59667)
'''18Mar02 TH  Removed format on output from dose entry keypad (#59667)
'''05Apr02 CKJ Changed tag from "dose" to "1." and + to & in the above mod
'''24May02 TH  Ensure decimals under one are prefixed by a zero (basically does what the format used to do but is more specific)
''
''
''Direct entry of dose is not supported in this version"      ''**!!**
''
''Dim temp$
''
''   KeyPad.LblUnits.Caption = LCase$(d.DosingUnits)
''   KeyPad.LCD.Tag = "1."    '18Mar02 TH Added (#59667)
''   KeyPad.Show 1
''   If Len(RTrim$(KeyPad.LCD.Text)) > 0 And KeyPad.Tag = "-1" Then
''      'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then   '     "
''      If d.LabelInIssueUnits Then
''         temp$ = Trim$(Str$(dp!(Val(KeyPad.LCD.Text) / d.dosesperissueunit)))
''      Else
''         temp$ = d.Description
''         If InStr(temp$, "SUSPENSION") > 0 Or InStr(temp$, "LIQUID") > 0 Or (InStr(temp$, "SOLUTION") > 0 And (InStr(UCase$(d.route), "ORAL") > 0 Or InStr(UCase$(d.route), "NG") > 0 Or InStr(UCase$(d.route), "ET") > 0)) Or InStr(temp$, "MIXTURE") > 0 Or InStr(temp$, "LINCTUS") > 0 Or InStr(temp$, "SYRUP") > 0 Or InStr(temp$, "ELIXIR") > 0 Then   '10Nov98 TH Deal with none oral solutions '10Nov01 CKJ Added > 0 to "syrup"
''            temp$ = Trim$(Str$(dp!(Val(KeyPad.LCD.Text) / d.dosesperissueunit)))
''         Else
''            temp$ = Trim$(KeyPad.LCD.Text)
''         End If
''      End If
''
''      txtUC("txtDircode").Text = txtUC("txtDircode").Text & temp$         '18Mar02 TH Replaced above, removed format  (#59667)
''      txtUC("txtDircode").Text = txtUC("txtDircode").Text & "/"
''      LabelAmended = True
''   Else
''      k.escd = True
''   End If
''   Unload KeyPad
''
''End Sub

''Sub EnterDrugFromCode(sNSVCode As String)
'''To enter a drug onto the PMR programmatically.
'''unfortunately there does not appear to be a nice way to do this...
'''------------------------------------------------------------------------------
'''02Jun00 AE
''
''   txtUC("txtPrompt").Text = sNSVCode
''   lblUC("DoAction").Caption = "NEW"                   'NEW: Enter this drug as a newRX
''   lblUC("DoAction").Caption = ""                      'Reset
''
''End Sub

''Sub Enterlength()
''
''   KeyPad.Caption = "Enter Length in days"
''   KeyPad.LblUnits.Caption = ""
''   KeyPad.cmdBtn(13).Visible = False
''   KeyPad.cmdBtn(19).Visible = False
''   KeyPad.cmdBtn(20).Visible = False
''   KeyPad.Show 1
''   If Trim$(KeyPad.LCD) <> "" And KeyPad.Tag = "-1" Then
''         txtUC("txtDircode").Text = txtUC("txtDircode").Text & KeyPad.LCD.Text & "d"
''         txtUC("txtDircode").Text = txtUC("txtDircode").Text & "/"
''         LabelAmended = True
''      End If
''   Unload KeyPad
''
''End Sub

Sub EnterTime(Timestr$)
Dim valid

   KeyPad.Caption = "Enter Time"
   KeyPad.lblUnits.Caption = "hh.mm"
   KeyPad.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   If Len(RTrim$(KeyPad.LCD.text)) > 0 And KeyPad.Tag = "-1" Then
         parsetime (KeyPad.LCD.text), Timestr$, "1", valid
         If Not valid Then k.escd = True: popmessagecr "!", "Time entered incorrectly - please retry"
      Else
         k.escd = True
      End If
   Unload KeyPad

End Sub

''Sub expandcontainer(Container$)
'''27Dec97 ASC used to expand to a description for the container from the one letter stored on disk
''
''Dim X As Integer      '01Jun02 All/CKJ
''
''   If Len(Container$) = 1 Then
''    For X = 0 To Dispens.CmbContainer.ListCount - 1
''       Dispens.CmbContainer.ListIndex = X
''       If Left$(Dispens.CmbContainer.Text, 1) = Container$ Then Exit For
''    Next
''      End If
''
''End Sub

Sub expanddir(dircode As String)
'26jul96 KR Added Trim$ to ensure code is cleared from label box if directions form is used.
   
Dim ans$, X As Integer

   If Trim$(dircode) = "" Then
         k.escd = True
      Else
         ans$ = RTrim$(LTrim$(dircode)) & "/"
         For X = 1 To Len(ans$)
            txtUC("TxtDircode").text = txtUC("TxtDircode").text & Mid$(ans$, X, 1)
         Next
         LabelAmended = True
      End If

End Sub

Sub FillHeapLabelInfo(ByVal HeapID As Integer, L As WLabel, success As Integer)
'09Aug99 SF added to put label info onto the heap for printing.
'           Note: not all the label elements have not been added
'16Feb00 AE Extra data items for WA. These are in fact duplicates, but necessary
'           for "political reasons".
'29Jun01 CKJ Added extra fields for printing prescription details
'10Nov01 CKJ Added MapTimesToTimeBands
'26Feb02 ATW Added some more label items for outgoing interface (BLT)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'29Jun15 XN  Added lLabelDrugDescription, lLabelDrugDescriptionXML, lLabelDrugDescriptionTrim, and lLabelDrugDescriptionTrimXML (98073)
Dim dt As DateAndTime
Dim act%, temp$
Dim X As Integer
Dim id As Integer
Dim splitpoint As Integer  '16Jul09 TH Ported
Dim verbcount As Integer
Dim verbs As String
Dim iLoop As Integer
Dim dtemp As DrugParameters
Dim bFound As Long


   ReDim strTimesCopy(6) As String                               '10Nov01 CKJ Added
   
   success = False
   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   act = Iff(id > 0, 10, 12)                                     'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive

   If id > 0 Then
      Heap act, id, "lDircode", Trim$(L.dircode), 0
      Heap act, id, "lRoute", Trim$(L.route), 0
''         Heap act, id, "lTimeUnits", Trim$(L.TimeUnits), 0
''      Heap act, id, "lRepeatInterval", Format$(L.RepeatInterval), 0
      Heap act, id, "lRepeatUnits", Trim$(L.RepeatUnits), 0
''         Heap act, id, "lDays", Trim$(L.Days), 0
      
      For X = 1 To 6
         Heap act, id, "lDose" & X, Format$(L.dose(X)), 0
         Heap act, id, "lTime" & X, Trim$(L.Times(X)), 0
      Next
      
      Heap act, id, "lSisCode", Trim$(L.SisCode), 0
      Heap act, id, "lPatID", Trim$(L.patid), 0
      
      dt.mint = L.deletedate
      minstodate dt
      DateToString dt, temp$
      Heap act, id, "lDeleteDate", Trim$(temp$), 0

      Heap act, id, "lPrescriptionid", Format$(L.PrescriptionID), 0
      Heap act, id, "lBasePrescriptionID", Format$(L.BasePrescriptionID), 0

      Heap act, id, "rxPrescriptionID", Format$(L.PrescriptionID), 0    '16Feb00 AE  Added
      Heap act, id, "rxRecNo", Format$(Labf&), 0                        '     "
      Heap act, id, "rxRepeatNum", Format$(L.batchnumber), 0            '     "

      dt.mint = L.startdate
      minstodate dt
      DateToString dt, temp$
      Heap act, id, "lStartdate", temp$, 0
      
      dt.mint = L.StopDate
      minstodate dt
      DateToString dt, temp$
      Heap act, id, "lStopdate", temp$, 0

      ' 12Apr02 ATW Added Long versions of DT fields for more accurate interface exports
      Heap act, id, "lStartDateLong", CStr(L.startdate), 0
      Heap act, id, "lStopDateLong", CStr(L.StopDate), 0
      Heap act, id, "lRxStartDateLong", CStr(L.RxStartDate), 0
      Heap act, id, "lDeleteDateLong", CStr(L.deletedate), 0

      Heap act, id, "lIssType", Trim$(L.IssType), 0
      Heap act, id, "lLastqty", Format$(L.lastqty), 0
      'Heap act, ID, "lLastdate", Trim$(l.lastdate), 0
      Heap act, id, "lTopupqty", Format$(L.topupqty), 0
      Heap act, id, "lDispid", Trim$(L.dispid), 0
      Heap act, id, "lPrescriberid", Trim$(L.PrescriberID), 0
      Heap act, id, "lPharmacistID", Trim$(L.PharmacistID), 0
      Heap act, id, "lStoppedBy", Trim$(L.StoppedBy), 0
''         Heap act, id, "lRxstatus", Trim$(L.rxstatus), 0
      dt.mint = L.RxStartDate
      minstodate dt
      DateToString dt, temp$
      Heap act, id, "lRxStartDate", temp$, 0
      Heap act, id, "lNodIssued", Format$(L.Nodissued), 0
      Heap act, id, "lBatchnumber", Format$(L.batchnumber), 0
      Heap act, id, "lRxNodIssued", Format$(L.RxNodIssued), 0

      Heap act, id, "lRxNum", Format$(Labf&), 0
      
      temp$ = trimz$(L.drdirection)                                         'Take the prescription text
      replace temp$, crlf, " ", 0                                           'change cr/crlf/lf/char30
      replace temp$, cr, " ", 0                                             'into a single space
      replace temp$, lf, " ", 0
      replace temp$, Chr$(LBL_END_LINE), " ", 0
      replace temp$, Chr$(LBL_END_DESC), " ", 0
      Heap act, id, "lRxText", temp$, 0

      temp$ = trimz$(L.text)                                                'Take the label text
      replace temp$, crlf, " ", 0                                           'change cr/crlf/lf/char30
      replace temp$, cr, " ", 0                                             'into a single space
      replace temp$, lf, " ", 0
      replace temp$, Chr$(LBL_END_LINE), " ", 0
      replace temp$, Chr$(LBL_END_DESC), " ", 0
      Heap act, id, "lText", temp$, 0

''         Heap act, id, "lManIss", Iff((Asc(L.Flags) And &H1), "YES", "NO"), 0  'Manual Issue
''         Heap act, id, "lPRN", Iff((Asc(L.Flags) And &H2), "PRN", ""), 0       'PRN'
''         Heap act, id, "lOwnMed", Iff((Asc(L.Flags) And &H4), "YES", "NO"), 0  'Patient's own
      Heap act, id, "lManIss", Iff(L.ManualQuantity, "YES", "NO"), 0          'Manual Issue
      Heap act, id, "lPRN", Iff(L.Prn, "PRN", ""), 0                          'PRN'
      Heap act, id, "lOwnMed", Iff(L.PatientsOwn, "YES", "NO"), 0             'Patient's own
      Heap act, id, "lBlister", Format$(L.Blister), 0                         'Blister Pack number
   
      Heap act, id, "lLastDate", LastSavedDateTimeToLastDate(L.lastSavedDateTime), 0           ' 40210 XN 15Feb13 use proper date\time for WLabel       Heap act, id, "lLastDate", L.lastdate, 0  'ddmmccyy'
      Heap act, id, "llastSavedDateTime", Format$(L.lastSavedDateTime, "dd/mm/yyyy hh:MM:ss"), 0 ' 40210 XN 15Feb13 use proper date\time for WLabel
                           
      Heap act, id, "lWardCode", Trim$(L.wardcode), 0
      Heap act, id, "lConsCode", Trim$(L.ConsCode), 0
      
      
      '16Jul09 TH Moved from v8 for Rpt Disp Project 5Jan08 CKJ Added block to autogenerate Product Description & Direction Text from label text
      '!!** may need to add calls to RemoveColourInfo or equivalent
      temp$ = trimz$(L.text)                                                  'Take the label text
      splitpoint = InStr(temp$, Chr$(&H1F))                               'chr(31) marks WA split
      If splitpoint = 0 Then
         replace temp$, crlf, cr, 0                                           'change crlf/lf/char30 into cr
         replace temp$, lf, cr, 0
         replace temp$, Chr$(30), cr, 0
         verbs = TxtD(dispdata & "\patmed.ini", "", "give ,take ,insert ,put ,inhale ,apply ,use ,suck ,irrigate ,wash ,implant ,place ,chew ,dilute ,eat ,dilute ,drink ,spray ,inject ,dissolve ,infuse ,add ,hold ", "DirectionVerbs", 0)
         ReDim Verb(100) As String
         deflines verbs, Verb(), ",", 1, verbcount
         For iLoop = 1 To verbcount
            splitpoint = InStr(1, temp$, cr & Verb(iLoop), 1)                 'split on <cr><verb><space>
            If splitpoint Then Exit For
         Next
      
         If splitpoint = 0 Then splitpoint = InStr(temp, cr & cr)             'split on <cr><cr>  - look for first blank line
         If splitpoint = 0 Then splitpoint = InStr(temp, cr)                  'split on <cr>      - keep just first line
      End If
      replace temp$, cr, " ", 0                                               'cr into a single space
      Heap act, id, "lDirectionsInferred", Trim$(Mid$(temp$, splitpoint + 1)), 0
      If splitpoint Then temp$ = Left$(temp$, splitpoint - 1) Else temp$ = ""
      Heap act, id, "lProductInferred", Trim$(temp$), 0
      
      Heap act, id, "lContainerSize", Format$(L.containersize), 0
      Heap act, id, "lRptDispQtyPerLabel", Format$(L.containersize), 0
      '---

                           
      temp$ = ""
      For X = 1 To 6
         If Trim$(L.Times(X)) <> "" Then
            temp$ = temp$ & Left$(L.Times(X), 2) & ":" & Mid$(L.Times(X), 3, 2) & " "
         End If
      Next
      Heap act, id, "lTimes", temp$, 0

      For X = 1 To 6
         strTimesCopy(X) = L.Times(X)
      Next
      MapTimesToTimeBands strTimesCopy()
          
          '
          ' Added bit below to place the drug label description (used on the dispensing label onto the heap) XN 29Jun15 98073
          ' Any changes in the logic below should be reflected in PATSUBS.BAS createlabel
          '
          
          dtemp.SisCode = L.SisCode
          getdrug dtemp, 0, bFound, False
          If bFound > 0 Then
                  'Determine if we are doing an out-patient label
                  Dim blnOutPatientlabel As Boolean
                  blnOutPatientlabel = False
                  If InStr(plvl$("OutPatLabel"), L.IssType) > 0 Then blnOutPatientlabel = True              'If this issue type uses out patient labels, do so...
                  If WardUsesInPatientDirections() And InStr(plvl$("InPatLabel"), L.IssType) > 0 Then       'If this ward uses directions on inpatient labels, AND this is
                         blnOutPatientlabel = True                                                           'an inpatient label, use the outpatient label template.
                  End If                                                                                 '     "
                  
                  ' determine the drug label description
                  Dim drugLabelDescription As String, drugLabelDescriptionTrim As String
                  If blnOutPatientlabel Then
                         ' Out-Patient label so if set use the LabelDescriptionOutPatient description
                         If Trim$(dtemp.LabelDescriptionOutPatient) <> "" And Not (gDisableLabelDescriptionAlternative) Then
                                drugLabelDescription = Trim$(dtemp.LabelDescriptionOutPatient)
                         Else
                                drugLabelDescription = Trim$(dtemp.LabelDescription)
                         End If
                  ElseIf InStr(plvl$("InPatLabel"), L.IssType) Then
                        ' In-Patient label so if set use the LabelDescriptionInPatient description
                        If Trim$(dtemp.LabelDescriptionInPatient) <> "" And Not (gDisableLabelDescriptionAlternative) Then
                                drugLabelDescription = Trim$(dtemp.LabelDescriptionInPatient)
                        Else
                                drugLabelDescription = Trim$(dtemp.LabelDescription)
                        End If
                  Else
                        'Plain CIVAS label
                        drugLabelDescription = dtemp.LabelDescription
                  End If
                  
                  plingparse drugLabelDescription, "!"
                  
                  Heap act, id, "lLabelDrugDescription", Trim$(drugLabelDescription$), 0
                  Heap act, id, "lLabelDrugDescriptionXML", XMLEscape(Trim$(drugLabelDescription$)), 0    '17May10 TH Added UHB (F0077941)
                  drugLabelDescriptionTrim$ = Left$(drugLabelDescription$, Val(TxtD(dispdata$ & "\genint.ini", "StockInterface", "20", "DescriptionTrim", 0))) '06May09 TH Added (F)
                  Heap act, id, "lLabelDrugDescriptionTrim", drugLabelDescriptionTrim$, 0
                  Heap act, id, "lLabelDrugDescriptionTrimXML", XMLEscape(drugLabelDescriptionTrim$), 0 '06May09 TH Added
          End If
          
      success = True
   End If

End Sub

Sub FormDates()
'26Jun98 ASC Now takes start date from prepared date on front screen to allow entry of prescriptions in advance
Dim d$, t$
Dim dat$, tim$, valid As Integer

   '-------------21May95 ASC starts new prescriptions
   d$ = txtUC("txtPrepDate").text                    ' mm-dd-yyyy
   t$ = txtUC("txtPrepTime").text                    ' hh:mm:ss
   dt.Yrs = Val(Right$(d$, 4))
   dt.day = Val(d$)
   dt.mth = Val(Mid$(d$, 4, 2))
   dt.Hrs = Val(t$)
   dt.min = Val(Mid$(t$, 4, 2))
   datetomins dt                                ' finds .mint & .yday
   dt.mint = dt.mint + RxOffset&

   If L.startdate = 0 Then
      L.startdate = dt.mint
   End If
   
   If L.RxStartDate = 0 Or L.StopDate = 0 Then
      L.RxStartDate = dt.mint
      xp.mint = Val(plvl$("DefaultRxLength"))
      AddExpiry dt, xp
      datetomins dt
      L.StopDate = dt.mint
   End If

   dt.mint = L.RxStartDate
   minstodate dt
   DateToString dt, dat$
   txtUC("TxtStartDate").text = dat$

   TimeToString dt, tim$
   parsetime (tim$), tim$, "1", valid
   txtUC("TxtStartTime").text = tim$

   dt.mint = L.StopDate
   minstodate dt
   DateToString dt, dat$
   txtUC("TxtStopDate").text = dat$

   TimeToString dt, tim$
   parsetime (tim$), tim$, "1", valid
   txtUC("TxtStopTime").text = tim$

End Sub

Sub formtolabel(Finished%)
'13Nov97 CFY Code to handle own medication checkbox
'20Jan98 CFY Added coding to set blister pack bits in flag field
'22jan98 CKJ Single error message instead of 2 or 3
'22Jan98 ASC Ask route only if route combo visible (CKJ)
'25Jan98 CKJ/ASC simplified blister handling
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'19Jan99 EAC Enhancement 603
'15Mar99 SF  removed the setting of l.topupqty as this is now used for repeat dispensing
'31Mar99 SF  removed 15Mar99 mod as l.topupqty now not used in repeat dispensing
'31Mar99 SF  repeat dispensing mods
'13Apr99 SF  now only fills l.containersize if l.issuetype P, C or repeat dispensing not turned on
'11Jun99 CFY Fix. Was not previously taking the current status of l.flags into account when the status of the
'            bits.
'02Aug00 MMA Added: Global update for Teamwork
'10Nov00 AW  added code to pick up licenced route from drug file, if no licenced route setup warns user.
'20Nov00 AW  commented out code for licenced/unlicenced routes
'08Jan00 CKJ Corrected handling of Chk Manual, ChkPRN & ChkPatOwn. Original would set but never unset these flag bits.
'15Apr02 TH  Changed bit handling for Blister Packing. Now explicitly turns off bits not required so editing works  (#53284)
'    "       Also, by largely reinstating the initial method of doing this I think it makes this more readable (for me anyway)
'25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)

Dim RouteRequired As Boolean
Dim msg$
Dim nocode As Integer, X As Integer, xs$, valid As Integer, dat$, tim$
    
   Finished = False
   FailedExchange = False
   RouteRequired = False
   msg$ = ""

   LSet r = L
   If txtUC("txtDircode").text = "" And passlvl <> 3 Then
      FailedExchange = True
      nocode = True
      msg$ = "No Direction Code Entered" & cr
   End If

   L.dircode = txtUC("txtDircode").text
   L.route = cmbUC("CmbRoute").text
   
   For X = 1 To 6
      If LTrim$(txtUC("txtTime", X).text) <> "" Then
         xs$ = txtUC("txtTime", X).text
         parsetime (xs$), xs$, "2", valid
         L.Times(X) = xs$

         L.dose(X) = Val(txtUC("txtDose", X).text)
         'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then  '
         'If d.LabelInIssueUnits And d.dosesperissueunit >= 1 Then    '21oct05 CKJ added d.dosesperissueunit >= 1
         If d.LabelInIssueUnits And d.dosesperissueunit > 0 Then      '25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)
            L.dose(X) = dp!(L.dose(X) / d.dosesperissueunit)
         End If
         If Val(txtUC("txtDose", X).text) <> 0 Then RouteRequired = True
      Else
         L.dose(X) = 0
         L.Times(X) = ""
      End If
   Next

   If cmbUC("CmbRoute").Visible And RouteRequired And LTrim$(cmbUC("CmbRoute").text) = "" Then '22Jan98 ASC
      msg$ = msg$ & "Please enter appropriate route" & cr     '22Jan98 CKJ
      SetFocusTo cmbUC("CmbRoute")
      FailedExchange = True
   End If

''   L.RepeatInterval = Val(txtUC("txtRepeatInterval").Text)
   L.RepeatUnits = cmbUC("CmbRepeatUnits").text
   L.topupqty = Val(txtUC("txtTopUpQty").text)     '15Mar99 SF removed, l.topupqty now used to hold number of labels in repeat dispensing  '31Mar99 SF reinstated

''   If Trim$(LCase$(cmbUC("CmbRepeatUnits").Text)) = "wk" Then         '28Oct05 CKJ Store days regardless of repeat setting
      For X = 1 To 7
         L.days(X) = TrueFalse(chkUC("ChkDay", X).Value)
      Next
''   End If
   
   L.ManualQuantity = TrueFalse(chkUC("ChkManual").Value)
   L.Prn = TrueFalse(chkUC("ChkPRN").Value)
   L.PatientsOwn = TrueFalse(chkUC("ChkPatOwn").Value)
   
   Select Case Val(txtUC("TextBlister").text)             'blister requested on screen?
      Case 0:    If L.Blister > 0 Then DecBlister        'No, so decrement
      Case Else: If L.Blister = 0 Then IncBlister        'Yes, so increment
      End Select
   L.Blister = Val(txtUC("TextBlister").text)          'store the blister number
   
   L.topupqty = Val(txtUC("txtTopUpQty").text)     '15Mar99 SF removed, l.topupqty now used to hold number of labels in repeat dispensing  '31Mar99 SF reinstated
   'l.NodPrescribed = VAL(dispens.TxtNodPrescribed.text)
   
   'l.RxNodIssued = Val(Dispens.TxtSupplied.Text)  '!!**  04JUn97 KR

   If FailedExchange Then
      LSet L = r
      If Not nocode Then popmessagecr "Invalid data", msg$ & "Correct and re-try"
   Else
      Finished = True
   End If

   dat$ = txtUC("txtStartDate").text
   StringToDate dat$, dt
   tim$ = txtUC("txtStartTime").text
   StringToTime tim$, dt
   datetomins dt
   L.RxStartDate = dt.mint

   dat$ = txtUC("txtStopDate").text
   StringToDate dat$, dt
   tim$ = txtUC("txtStopTime").text
   StringToTime tim$, dt
   datetomins dt
   L.StopDate = dt.mint

''   L.ReconVol = Val(Dispens.TxtReconVol.Text)
''   L.ReconAbbr = Dispens.CmbReconAbbr.Text
''   L.DiluentAbbr = Dispens.CmbDiluentAbbr.Text
''   L.Container = Left$(cmbUC("CmbContainer").Text, 1)
   L.finalvolume = Val(txtUC("txtFinalVol").text)
''   If L.IssType = "C" Or L.IssType = "P" Or Not TrueFalse(txtd(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "RepeatDispensing", 0)) Then L.containersize = Val(Dispens.TxtContainerSize.Text)   '13Apr99 SF
   L.InfusionTime = Val(txtUC("txtInfusionTime").text)
   L.drdirection = txtUC("txtDirections").text
   L.wardcode = pid.ward
   L.ConsCode = pid.cons
   LabelAmended = True

End Sub

Sub furtherinfo()
'21Jan96 ASC added number of doses dispensed on this RX
'19Feb96 EAC trap division by zero error
'27Feb97 KR  Added trimz on all pid fields to remove null character - now displays correct;ly
'16Feb98 CKJ Corrected display alignment, also shows full description & prescription number,
'            formatted DOB & added pid.recno
'16Jul99 SF  added additional patient billing info to "Further Information" screen
'09Feb00 SF/MMA/VS added reorder pack size and issue units
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim msg$, tmp$, valid%
Dim text$, dat$

   msg$ = ""
   BlankWProduct d
   d.SisCode = L.SisCode
   getdrug d, 0, 0, False
   msg$ = msg$ & Space$(25) & TB & Space$(50) & cr
   text$ = Trim$(d.LabelDescription)    ' text$ = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
   plingparse text$, "!"
   msg$ = msg$ & text$ & cr & cr
   msg$ = msg$ & "Total Qty dispensed:" & TB & Format$(L.Nodissued, "###0.### ") & LCase$(d.PrintformV) & cr
   msg$ = msg$ & "Qty disp. on this Rx:" & TB
   If d.dosesperissueunit > 0 Then
      'If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Or L.IssType = "C" Then
      If d.LabelInIssueUnits Then
         msg$ = msg$ & Format$((L.RxNodIssued / d.dosesperissueunit), "###0.### ")
         msg$ = msg$ & LCase$(d.PrintformV)
      Else
         msg$ = msg$ & Format$(L.RxNodIssued, "###0.### ")
         msg$ = msg$ & LCase$(d.DosingUnits)
      End If
   End If
   
   msg$ = msg$ & cr
   dt.mint = L.startdate
   minstodate dt
   DateToString dt, dat$
   msg$ = msg$ & "Start date:" & TB & dat$ & cr
   If L.StopDate <> 0 Then
         dt.mint = L.StopDate
         minstodate dt
         DateToString dt, dat$
      Else
         dat$ = ""
      End If

   '22Jun96 made single tabs to line up and now show sex and patient status
   msg$ = msg$ & "Stop date:" & TB & dat$ & cr
   parsedate LastSavedDateTimeToLastDate(L.lastSavedDateTime), tmp$, "dd/mm/ccyy", valid        ' 40210 XN 15Feb13 use proper date\time for WLabel    parsedate (L.lastdate), tmp$, "dd/mm/ccyy", valid
   msg$ = msg$ & "Last issue date:" & TB & Iff(valid, tmp$, "Not recorded") & cr
   
   msg$ = msg$ & "Direction code:" & TB & Trim$(L.dircode) & cr
   msg$ = msg$ & "Last Dispenser's id:" & TB & L.dispid & cr
   msg$ = msg$ & "Prescriber's id:" & TB & L.PrescriberID & cr
   msg$ = msg$ & "Pharmacists's id:" & TB & L.PharmacistID & cr
   msg$ = msg$ & "Issue Type:" & TB & L.IssType & cr
   msg$ = msg$ & "Pack Size:" & TB & Trim$(d.convfact) & " " & Trim$(d.PrintformV) & cr
   msg$ = msg$ & "Prescription number:" & TB & L.PrescriptionID & "/" & L.batchnumber & cr & cr
   
   msg$ = msg$ & "Case Number:" & TB & trimz(pid.caseno) & cr
   msg$ = msg$ & "Internal Number:" & TB & trimz(pid.recno) & cr
   tmp$ = trimz(pid.dob)
   Select Case Left$(tmp$, 4)
      Case ""
         msg$ = msg$ & "Date of birth:" & TB & "Not known" & cr
      Case "0000"
         msg$ = msg$ & "Year of birth:" & TB & Mid$(tmp$, 5, 4) & cr
      Case Else
         msg$ = msg$ & "Date of birth:" & TB & Left$(tmp$, 2) & "/" & Mid$(tmp$, 3, 2) & "/" & Mid$(tmp$, 5, 4) & cr
      End Select
   msg$ = msg$ & "Weight:" & TB & trimz(pid.weight) & " kg" & cr
   msg$ = msg$ & "Height:" & TB & trimz(pid.Height) & cr
   msg$ = msg$ & "Sex:" & TB & trimz(pid.sex) & cr
   msg$ = msg$ & "Patient Status:" & TB & trimz(pid.status) & cr
   If L.needednexttime = "A" Then
         msg$ = msg$ & "Team work" & TB & "Requested" & cr
      End If

   valid = billpatient(8, msg$)
   
   popmessagecr "#Further Information", msg$
   
End Sub

''Private Sub GetANewLabel()
'''Sub Getanewlabel () ' 06Mar02 ATW/TH Scoped procedure to Private as only SaveLabel calls it.
'''---------------------------------------------------------------------------------
''
'''    must cope with 1) no labels defined
'''                   2) some defined
'''                   3) all allocated
'''    - find empty slot in the rf's
'''         - if present then use it
'''    - no empty slot, find a deleted label
'''         - undelete it, reallocate it
'''    - no deleted labels ( all in use )
'''         - get rid of oldest label, and continue as above
'''12Jun97 KR Moved getting of next prescription ID to dispens.frm when select new label.
'''05Mar02 Localised label variable to prevent NewRx clearing useful detail as it saves.
'''24May02 TH/SF Ensure LabelForArchive is set to stop scripts disappearing from history ! (#60424)
''
''Dim count As Integer, count1 As Integer, newlabno&, newrecno&
''
''   If PresentLabel&() <> 0 Then Stop ' should not be here unless saving a new label
''
''   count = 1
''   Do                ' look at labrf&() for 1 to 50
''      If labrf&(count) = 0 Then
''            GetPointer patdatapath$ + "\labeltxt.v6", newlabno&, True
''            '30sep96 ASC/CKJ added for internal prescription ID
''            'GetPointer patdatapath$ + "\RxID.dat", l.PrescriptionID, True  '12Jun97 KR Moved to dispens.frm
''            labrf&(count) = newlabno&    ' needed only if count=50
''            newrecno& = newlabno&        ' take next free pointer
''            Exit Do
''         Else
''            count = count + 1
''         End If
''   Loop While count < 51
''
''   If count > 50 Then ' no unused labels found, so look for first deleted one
''         count = 1    ' This section altered 21Jul91 CKJ
''         Do           ' look at labrf&() for 1 to 50
''            If labrf&(count) < 0 Then
''                  labrf&(count) = -labrf&(count)
''                  newrecno& = labrf&(count)
''                  Labf& = newrecno&
''                  LabelForArchive& = Labf&  '24May02 TH/SF This is required to stop scripts disappearing from history ! (#60424)
''                  'NewRx False, False '05Mar02 ATW Extra parameter for more encapsulated routine
''                  'NewRx lbl, False, False ' 06Mar02 ATW/TH Removed call completely - utterly pointless as PutLabel only puts glbl l which is in a good state at this point.
''                  Exit Do
''               Else
''                  count = count + 1
''               End If
''         Loop While count < 51
''      End If
''
''   If count < 50 Then
''         ' found a match, and it is not at the end of the array
''         For count1 = count To 49
''            labrf&(count1) = labrf&(count1 + 1)
''         Next
''         count = 50 ' place it at the end, even if there are unused or deleted gaps
''         labrf&(50) = newrecno&
''      End If
''
''   If count > 50 Then ' failed to find spare or deleted entry so find first
''         '12May95 ASC
''         MsgBox "No more than 50 current medications allowed", 0, "Prescription cannot be saved - delete old medication history"
''         Labf& = 0
''         Exit Sub
''      End If
''
''   ' we now have the chosen entry in count, which must equal 50
''   If count <> 50 Then Stop ' ! should never happen
''   Labf& = labrf&(50)
''   'EAC 08Jan96
''
''   ' Putlabel ' 06Mar02 ATW/TH Moved into SaveLabel as this is not GetANewLabelAndSaveIt, it's more GetAnUnusedLabelPointer
''
''End Sub

Sub getlabel(ByVal LabelID As Long, L As WLabel, updateform%)
'28Dec93 ASC  Made procedure and added prescribing
'21May95 ASC  Now copes with gettig from arcgive files
'22Nov95 EAC  Declare local variable to be used to access either the labeltxt
'             or RX files to prevent wrong file being written to else where
'             after labchan had been modified
'27May99 SF/TH/CFY expanded the message for a patient/label mismatch and now logs
'27May99 SF/CKJ now only allows user to amend the record number if setup in command line parameter
'02Feb00 TH   Orphan mismatched labels from history
'16Feb00 AE  Additions to remove end of description marker if using highlight description mod.
'13Sep00 CFY Checks teamworkIssue status and bypasses references to dispens form.
'19Dec00 CKJ Corrected patient lookup from l.patid
'12Feb01 AW commented out if statement, now in SetDescriptionSplitLine
'21Jan02 TH  Removed call to setbuttons - this references ident.frm and causes problems in ocx mode (#46829)
'25Feb02 TH  Use incoming param as flag to stop unwanted references to dispens.frm through the WA HighlightPMRLines functionality (#59050)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

''Static lastfile$
Dim lblpid As patidtype
Dim iSplitLine As Integer
Dim lngFound As Long
Dim blnNotDispensing  As Integer
Dim localchan%, Numoflines As Integer, X As Integer, trimmed As Integer, msg$, localItem$, dat$, valid As Integer, ins%, badlabel As Integer, ans$

    blnNotDispensing = False           '25Feb02 TH Use incoming param as flag to stop (#59050)
    If updateform = 3 Then             '    "      unwanted references to dispens.frm
          updateform = False
          blnNotDispensing = True
       End If

   clearlabel L
   Erase labelline$

   If updateform Then                  'Clear the form and the label
         BlankWDirection WDir
         BlnkPrescribFrm True
         labeltoform
      End If

   Erase labelline$

''   GetRecordNL r, Labf&, localchan%, Len(l)
''
''   LSet l = r

   GetLabelNL LabelID, L

   ParseEndDirMarker L.text, Chr$(LBL_END_DESC), Chr$(LBL_END_LINE), iSplitLine
   If Not blnNotDispensing Then SetDescriptionSplitLine iSplitLine

   deflines L.text, labelline$(), Chr$(LBL_END_LINE), 1, Numoflines
   For X = 1 To Numoflines ' + 1
      Do
         trimmed = False
         If Len(labelline$(X)) >= 2 Then
               If Left$(labelline$(X), 2) = "^^" Then
                     labelline$(X) = Right$(labelline$(X), Len(labelline$(X)) - 1)
                     trimmed = True
                  End If
            End If
      Loop Until Not trimmed
   Next
   
   '**!!** To be reviewed
   If 0 = 1 And L.patid <> pid.recno Then            ' bad data (should never happen)
         If L.patid <> Space$(Len(L.patid)) Then          ' added CKJ 19Aug91
''               ScanIndexes 1, L.patid, 0, lngFound                            '19Dec00 CKJ get patient details from l.patid
''               If lngFound > 0 Then                                           '   "        if found in index otherwise they
''                     GetPatidNL lngFound, lblpid                              '   "        will be blank as PID are strings
''                  End If
               
               WriteLog patdatapath$ & "\errorlog.txt", SiteNumber%, UserID$, "RecNo: " & Trim$(pid.recno) & ", Patient: " & Trim$(pid.caseno) & " " & Trim$(pid.forename) & " " & Trim$(pid.surname) & ". Prescription seems to belong to RecNo: " & Trim$(lblpid.recno) & ", Patient: " & Trim$(lblpid.caseno) & " " & Trim$(lblpid.forename) & " " & Trim$(lblpid.surname)    '27May99 SF/TH/CFY added logging"
               msg$ = "RecNo: " & Trim$(pid.recno) & ", Patient: " & Trim$(pid.caseno) & " " & Trim$(pid.forename) & " "
               msg$ = msg$ & Trim$(pid.surname) & ". Prescription seems to belong to RecNo: " & Trim$(lblpid.recno) & ", Patient: " & Trim$(lblpid.caseno) & " "
               msg$ = msg$ & " " & Trim$(lblpid.forename) & " " & Trim$(lblpid.surname) & " File = findfile" & crlf & "Complete record ;" & crlf & r.record
               WriteLog patdatapath$ & "\errorlog.txt", SiteNumber%, UserID$, msg$
               
               Screen.MousePointer = STDCURSOR
               msg$ = "The Current Record Number is: " & Trim$(pid.recno) & crlf
               msg$ = msg$ & "Patient: " & Trim$(pid.caseno) & " " & Trim$(pid.forename) & " " & Trim$(pid.surname) & crlf & crlf
               msg$ = msg$ & "but the prescription appears to belong to : " & Trim$(L.patid) & crlf
               msg$ = msg$ & "Patient: " & Trim$(lblpid.caseno) & " " & Trim$(lblpid.forename) & " " & Trim$(lblpid.surname) & crlf & crlf
               msg$ = msg$ & "THIS INFORMATION WILL NOW BE " & crlf
               msg$ = msg$ & "WRITTEN TO THE PATIENT NOTES " & crlf
               msg$ = msg$ & "AND LOGGED IN : " & crlf
               msg$ = msg$ & patdatapath$ & "\LABELLOG.TXT" & crlf
               popmessagecr ".Label Mismatch", msg$
Stop '**!!**
               'Write to notes
               msg$ = crlf & Format$(Now, "dd-mm-yyyy hh:nn ") & UserID$ & " " & UserFullName$ & crlf
               msg$ = msg$ & " A patient / label mismatch was detected for this patient ;" + crlf
               msg$ = msg$ & "The Current Record Number is: " & Trim$(pid.recno) + crlf
               msg$ = msg$ & "Patient: " & Trim$(pid.caseno) & " " & Trim$(pid.forename) & " " & Trim$(pid.surname) & crlf & crlf
               msg$ = msg$ & "but the prescription appears to belong to : " & Trim$(L.patid) & crlf
               msg$ = msg$ & "Patient: " & Trim$(lblpid.caseno) & " " & Trim$(lblpid.forename) & " " & Trim$(lblpid.surname) & crlf & crlf
''               MakePMRLine localItem$
               
               msg$ = msg$ & "Type:" & Mid$(localItem$, 1, 1) & crlf
               msg$ = msg$ & "Item:" & Mid$(localItem$, 9, 48) & crlf
               msg$ = msg$ & "Dose:" & Mid$(localItem$, 57, 12) & "   "
               msg$ = msg$ & "Time:" & Mid$(localItem$, 69, 30) & "   "
               msg$ = msg$ & "Route:" & Mid$(localItem$, 103, 4) & crlf

               dt.mint = L.startdate
               minstodate dt
               DateToString dt, dat$
               msg$ = msg$ & "Start Date:" & dat$ & "   "

               dt.mint = L.StopDate
               minstodate dt
               DateToString dt, dat$
               msg$ = msg$ & "Stop Date:" & dat$ & "   "

               parsedate LastSavedDateTimeToLastDate(L.lastSavedDateTime), dat$, "1", valid          ' 40210 XN 15Feb13 use proper date\time for WLabel    parsedate L.lastdate, dat$, "1", valid
               If valid Then
                     msg$ = msg$ & "Issued Date:" & dat$ & crlf
                  End If
               
               msg$ = msg$ & crlf & "Label :" & crlf
               For ins% = 1 To Numoflines ' + 1
                  msg$ = msg$ & labelline$(ins) & crlf
               Next

               On Error Resume Next
''               pidNotes.notes = pidNotes.notes & crlf & msg$
               If Error Then Err = 0
               
               WriteLog patdatapath$ & "\labellog.txt", SiteNumber%, UserID$, msg$

               clearlabel L

               If updateform Then
                     'Clear the form and the label
                     BlankWDirection WDir
                     BlnkPrescribFrm True
                     labeltoform
                  End If
            
               Erase labelline$
               badlabel = True
            End If
      End If

End Sub

Sub GetToday(TodayAsLong&)

   today td
   TodayAsLong& = td.mint

End Sub

Sub getwardtopup(ward$, tdate$, days%, topdate%)
'04Jun97 KR added.
'This procedure returns the number of days until topup and the topup date.
'Inputs:    ward$    -  name of word to find topup info.
'Outputs:   tdate$   -  topupdate either from the supplier file or calculated.
'                    -  "" returned if not supplier not found
'           Days%    -  days til topup, either from supplier file or calculated
'                       can be zero if topup date expired or supplier not found
'           topdate% -  1 - topup date from supplier file, 2 - calculated from days ,
'                       3 - no topupinterval or topupdate set
'                       4 - no supplier or no ward supplier type
'                       5 - top-up expired.
'                       Supplier.topupdate always has priority over supplier.topupinterval
'30Jul98 TH Added & to designate number and prevent overflow(as bas file is not option explicit)
'31Mar99 SF Now gets topup level for "L" type suppliers

Dim sup As supplierstruct
Dim DaysTilTopUp&, valid%
Dim td As DateAndTime
Dim lfoundsup As Long, dat$

   days% = 0
   tdate$ = ""
   topdate% = 0
   If L.IssType <> "C" Then

         'Read from the cache first if we have one
        GetDispWardSupplier ward$, lfoundsup, sup  '30Jun17 TH Use cache (TFS 191443)
        If lfoundsup = 0 Then getsupplier ward$, 0, lfoundsup, sup

         'If foundsup% > 0 And sup.suppliertype = "W" Then
         If lfoundsup > 0 And (sup.suppliertype = "W" Or sup.suppliertype = "L") Then  '31Mar99 SF
               'Check topupdate and number of days fields - date has preference
               If trimz(sup.topupdate) <> "" And trimz(sup.topupdate) <> "0" Then
                     parsedate sup.topupdate, tdate$, "1", valid
                     datetodays "", tdate$, DaysTilTopUp&, 0, "", valid%
                     If DaysTilTopUp& < 0 Then  'topup date expired
                           days = 0
                           topdate% = 5
                        Else
                           days = CInt(DaysTilTopUp&)
                           topdate% = 1
                        End If
               
               ElseIf Trim$(sup.TopupInterval) <> "" Then
                     days = Val(sup.TopupInterval)
                     today td
                     td.mint = td.mint + (1440& * days)
                     minstodate td
                     DateToString td, tdate$
                     topdate% = 2
      
                     'CalculateDate
                  Else
                     days = 0          'No topupdate or interval set
                     dat$ = ""
                     topdate% = 3
                  End If
            Else
               topdate% = 4   'no supplier found or not supplier type W
            End If
      End If

End Sub

Sub IncBlister()
'20Jan98 CFY Added

   BlisterSemaphore = BlisterSemaphore + 1

End Sub


Sub initBlister()
'20Jan98 CFY Added
   
   BlisterSemaphore = 0

End Sub

''Sub InitialiseKinetics()
''
'''Procedure created to do licence checks, set up caches, selector instances etc.
'''Called from OnLoadingDispens.
'''---------------------------------------------------------------------------------
'''02jun00 AE  Written
'''19Jun00 AE  Corrected retry to resume at the correct point
''
''Dim bContinue As Integer, sErr As String
''Dim sText As String, iButton As Integer
''Dim iContinuePos As Integer
''Dim iHnd As Integer
''
''   LX frmMsgWin.lblbox, "PK", 32, 0                          '05Jul99 AE added to check licence file
''   If Val(frmMsgWin.lblbox.Tag) = 0 Or Val(Mid$(acclevels$, 3, 1)) < 1 Then '10jan00 AE Added password checks
''      Dispens.MnuViewKinetics.Visible = False    '    "
''      Dispens.MnuViewKinetics.Enabled = False    '    "
''      Dispens.MnuTools(7).Visible = False        '    "   (separator)
''      Dispens.MnuMonitorKinetics.Visible = False
''      Dispens.MnuMonitorKinetics.Enabled = False
''   Else
''      'Set up cache and selector. Ensure all are done.
''
''InitCache:
''      'Set up the kinetics cache of drug names for which we have regimens
''      On Error GoTo ErrContinue
''      iContinuePos = 1
''      KineticsCache 1, "", "", sErr                           'I've no idea why this sometimes fails...'02Jun00 AE  Added for speed
''InitSelector:
''      'Create a new selector instance for kinetics to use
''      On Error GoTo ErrContinue
''      iContinuePos = 2
''      SelectorInitialise iHnd, "1", sErr
''getSelectorHnd:
''      'Store the handle of this instance
''      On Error GoTo ErrContinue
''      iContinuePos = 3
''      KineticsSelectorHnd 1, iHnd
''   End If
''
''   Unload frmMsgWin
''
''InitKinetExit:
''
''Exit Sub
''
''ErrContinue:
''   'If an error, prompt the user if they wish to try again.
''   bContinue = False
''   If sErr <> "" Then
''         sText = sErr & crlf$ & crlf$
''         sText = sText & "Click OK to try again, Cancel to terminate the program"
''         iButton = MessageBox(sText, MB_OKCANCEL + MB_ICONEXCLAMATION, "Pharmacokinetics")
''         bContinue = (iButton = IDOK)                                                        '19Jun00 AE  Corrected button to "IDOK"
''      Else
''         bContinue = True
''      End If
''
''   If Not bContinue Then
''         Close
''         End!
''      End If
''
''   Select Case iContinuePos                           '19Jun00 AE  Added to make retry work possibly
''      Case 1
''         Resume InitCache
''      Case 2
''         Resume InitSelector
''      Case 3
''         Resume getSelectorHnd
''      Case Else
''         Error Err
''      End Select
''
''End Sub

Sub Issue_Callback()
'14apr04 CKJ Print one standard label now
'            Borrowed from frmIdent KeyUp F7
   
   FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
   patlabel k, pid, True, 1

End Sub

Sub labeltoform()
'This procedure fills the dispens form controls from the label structure

'22Jul96 KR  Added local copy of d as d now global.
'25Jul96 KR  Moved setting of rxunit label after the getdrug 'cos at start
'            d is not set as now using local copy.
'23Sep96 CKJ Removed local d
'01Jun97 KR  Added setting of dispensing description labels.
'19Jun97 ASC/KR Optimised loop code in increase speed.
'20Jun97 KR  Added extra Routes
'27Jun97 KR  Only make iv details visible in prescription view.
' 5Aug97 CKJ/KR Removed Exit For on displaying doses -
'            logic faulty as it left subsequent doses on screen and in the calculated quantities
'13Nov97 CFY Code to handle own medication checkbox
'20Jan98 CFY Added handling of blister pack text box
'30Jan98 CFY Added refresh to frame
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'22Jul98 EAC make language aware
'28Aug98 TH  Changed formats to suppress stray decimal places
'24Sep98 TH  Changed various formats
'16Oct98 TH  Added various formats
'13Nov98 EAC HK mod to display the full Hospital Number on the Label
'20Nov98 CKJ/CFY Allow 'sn, fn'
'19Jan99 EAC Enhancement 603
'15Mar99 SF  removed the displaying l.topupqty as this is now used for repeat dispensing
'31Mar99 SF  removed 15Mar99 mod as l.topupqty now not used in repeat dispensing
'31Mar99 SF  repeat dispensing mods
'13Apr99 SF  qty text box filled with l.containersize if repeat dispensing turned on l.issuetype not C or P and l.containersize >0
'26Apr99 SF  if repeat dispensing item clear TxtQtyPrinted.Tag to allow change event to fire
'04May00 EAC removed references to l.flags
'13Jul00 AJK commented out call to calcqtys
'02Aug00 MMA Added: Global update for Teamwork
'04Oct00 AW  Now calls Calcqtys if civas item
'09Oct00 AW  Added code to show licenced/unlicenced routes
'08Nov00 AW  restore call to calcqtys
'20Nov00 AW  commented out code to show licenced/unlicenced routes
'29May01 TH  Added clause to prevent blanking of directions during amend (which leads to logged issue but no PMR entry) (#52393)
'07Feb03 TH  Dont call FormDates if Label is reused to try and retain the original stop date from the direction code
'04Jun03 TH  Altered above mod. Now use specially set modular variable to 'protect' re-engineered date rather than reusedlabel% (#67381)
'16May04 TH  Added LabelModified to clause to protect original directions (#65853)
'04Jul11 TH  Make sure days are restored correctly on label read (F0121971)

Dim temp$
Dim dosetting%
Dim TempCaseNo$, success%                 '13Nov98 EAC Added
Dim PatientName$
Dim contchan As Integer, lasttemp$, X As Integer, dropped As Integer, Out$, valid As Integer, iByte As Integer, drug$, temp2$

   StopEvents = True
   UserTopUpQty% = False
''   If Dispens.CmbReconAbbr.ListCount = 0 Then
''         Dispens.CmbReconAbbr.AddItem "NS"
''         Dispens.CmbReconAbbr.AddItem "WFI"
''         Dispens.CmbReconAbbr.AddItem "D5W"   '!!**pos  "G"
''         Dispens.CmbReconAbbr.AddItem "4/5"   '!!**pos  "IL" intralipid for diazepam?

         'dispens.CmbContainer.AddItem "S"    '27Dec97 ASC
         'dispens.CmbContainer.AddItem "B"    '27Dec97 ASC
         'dispens.CmbContainer.AddItem "V"    '27Dec97 ASC
         'dispens.CmbContainer.AddItem "O"    '27Dec97 ASC
          
''         contchan = FreeFile    '!!** error checks needed                                  '27Dec97 ASC
''         Open dispdata$ + "\containr.dat" For Input As #contchan                           '27Dec97 ASC
''         Do While Not EOF(contchan)                                                        '27Dec97 ASC
''            Input #contchan, temp$                                                         '27Dec97 ASC
''            If temp$ <> "" And Left$(temp$, 1) <> lasttemp$ Then                           '27Dec97 ASC
''                  Dispens.CmbContainer.AddItem Mid$(temp$, 3, InStr(3, temp$, "|") - 3)    '27Dec97 ASC
''               End If                                                                      '27Dec97 ASC
''            lasttemp$ = Left$(temp$, 1)                                                    '27Dec97 ASC
''         Loop                                                                              '27Dec97 ASC
''         Close contchan                                                                    '27Dec97 ASC
         
         For X = 1 To Val(TxtD(ASCFileName("route.ini", True, ""), "allroutes", "", "Total", True))
            cmbUC("CmbRoute").AddItem TxtD(ASCFileName$("route.ini", False, ""), "allroutes", "", Format$(X), True)
         Next
         dropped = True
      
''      End If
   
   If cmbUC("CmbRoute").ListIndex = -1 Then
         dosetting = True
      Else
         If L.route <> cmbUC("CmbRoute").List(cmbUC("CmbRoute").ListIndex) Then dosetting = True
      End If
   If dosetting Then
         For X = 0 To cmbUC("CmbRoute").ListCount - 1
            'If l.route = cmbUC("CmbRoute").List(x) Then  '09Jan99 ASC
            If UCase$(Trim$(L.route)) = UCase$(Trim$(cmbUC("CmbRoute").List(X))) Then   '    "
                  cmbUC("CmbRoute").ListIndex = X
                  Exit For '19Jun97 ASC/KR
               End If
         Next
      End If

   If Trim$(L.dircode) <> "" Then
         txtUC("TxtDircode").text = RTrim$(L.dircode)
      End If
   
   SetRepeatCombo L.RepeatUnits

''   txtUC("TxtRepeatInterval").Text = LTrim$(Str$(L.RepeatInterval))
   txtUC("TxtTopUpQty").text = LTrim$(Str$(L.topupqty))     '15Mar99 SF removed, l.topupqty now used to hold number of labels in repeat dispensing  '31Mar99 SF reinstated"
   txtUC("TxtSupplied").text = LTrim$(Str$(L.RxNodIssued))

   For X = 1 To 6
      'If Trim$(l.Times(X)) = "" Then Exit For '19jun97 ASC/KR '5Aug97 CKJ/KR Removed - logic faulty as it left subsequent doses on screen and in the calculated quantities
      parsetime L.Times(X), Out$, "1", valid
      txtUC("TxtTime", X).text = Out$
      txtUC("TxtDose", X).Enabled = True
      If L.dose(X) = 0 Then
            temp$ = ""
         Else
            'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
            If d.LabelInIssueUnits Then
                  temp$ = LTrim$(Str$(L.dose(X) * d.dosesperissueunit))
               Else
                  temp$ = LTrim$(Str$(L.dose(X)))
               End If
         End If
      txtUC("TxtDose", X).text = Format$(temp$)
   Next
   
''   asciiday = Asc(L.Days)
''   If asciiday > 0 Then    '19jUN97 asc/kr
''         For X = 7 To 1 Step -1
''            If asciiday - (2 ^ X) >= 0 Then
''                  asciiday = asciiday - 2 ^ X
''                  Dispens.ChkDay(X).Value = 1
''                  daysdefined = True
''               Else
''                  Dispens.ChkDay(X).Value = 0
''               End If
''         Next
''      End If
   daysdefined = False
   'For X = 7 To 1
   For X = 1 To 7  '04Jul11 TH (F0121971) Make sure days are restored correctly
      chkUC("ChkDay", X).Value = Iff(L.days(X), 1, 0)
      If L.days(X) = False Then daysdefined = True       '28Oct05 CKJ inverted logic. Expects every day to be 1111111, so one or more '0' means omit
   Next
   
   fraUC("FraDays").Visible = (Trim$(LCase$(cmbUC("CmbRepeatUnits").text)) = "wk")

''   iByte = Asc(L.Flags)
''   Dispens.ChkManual.Value = iByte And &H1        '0 or 1
''   Dispens.ChkPRN.Value = (iByte And &H2) \ 2     '0 or 1
''   Dispens.ChkPatOwn.Value = (iByte And &H4) \ 4  '0 or 1 '13Nov97 CFY
''   Dispens.TextBlister = Format$((iByte \ 8) And 7)   '25Jan98 CKJ Simplified xx111xxx -> 111
   
   chkUC("ChkManual").Value = Iff(L.ManualQuantity, 1, 0)
   chkUC("ChkPRN").Value = Iff(L.Prn, 1, 0)
   chkUC("ChkPatOwn").Value = Iff(L.PatientsOwn, 1, 0)
   txtUC("TextBlister").text = L.Blister
   
   If (Not getReusedDirections()) Or L.StopDate = 0 Then   '04Jun03 TH Replaced Above (#67381)
      FormDates
   End If
   
   Calcqtys                     '08Nov00 AW restore call to calcqtys
   
   d.SisCode = L.SisCode
   getdrug d, 0, 0, False
   drug$ = d.LabelDescription   'drug$ = d.Description XN 4Jun15 98073 New local stores description
   plingparse drug$, "!"
''   lblUC("LblDrug").Caption = drug$
   
   lblUC("RxUnits", 1) = d.DosingUnits       '25Oct05 CKJ removed lcase - data should already be correct in Units table

   If L.IssType = "C" Then
         If fraUC("fraRx").Visible Then     '27Jun97 KR
''               Dispens.fraIV.Visible = True
               fraUC("fraIVdetails").Visible = True
            Else
''               Dispens.fraIV.Visible = False
               fraUC("fraIVdetails").Visible = False
            End If
''         If L.ReconVol = 0 Then
''               Dispens.TxtReconVol.Text = Format$(d.ReconVol, "#0.##") '16Nov96 ASC now format$
''            Else
''               Dispens.TxtReconVol.Text = Format$(L.ReconVol, "#0.##") '16Nov96 ASC now format$
''            End If
''         Dispens.TxtReconVol.Text = Format$(Dispens.TxtReconVol.Text)  '24Sep98 TH Added
''         If LTrim$(L.ReconAbbr) = "" Then
''               Dispens.CmbReconAbbr.Text = d.ReconAbbr
''            Else
''               Dispens.CmbReconAbbr.Text = L.ReconAbbr
''            End If
''         If LTrim$(L.DiluentAbbr) = "" Then
''               Dispens.CmbDiluentAbbr.Text = d.Diluent1Abbr
''            Else
''               Dispens.CmbDiluentAbbr.Text = L.DiluentAbbr
''            End If
''         If LTrim$(L.Container) = "" Then
''               Dispens.CmbContainer.Text = d.IVcontainer
''            Else
''               Dispens.CmbContainer.Text = L.Container
''            End If
''         expandcontainer (Dispens.CmbContainer.Text)  '27Dec97 ASC
         
         If d.InfusionTime > 0.001 Then
               txtUC("TxtInfusionTime").text = LTrim$(Str$(d.InfusionTime))
               temp2$ = Format$((L.finalvolume / d.InfusionTime) * 60, "###0.##")     '24Sep98 TH  Changed format to retain mask
               lblUC("LblInfusionRate").Caption = Format$(temp2$) '24Sep98 TH

            Else
               txtUC("TxtInfusionTime").text = "N/A"
            End If
         temp2$ = Format$(L.finalvolume, "###0.##") '24Sep98 TH  Changed to retain mask
         txtUC("TxtFinalVol").text = Format$(temp2$) '24Sep98 TH

''         Dispens.TxtContainerSize.Text = LTrim$(Str$(L.containersize))
         txtUC("TxtInfusionTime").text = LTrim$(Str$(L.InfusionTime))
      Else
''         Dispens.fraIV.Visible = False
         fraUC("fraIVdetails").Visible = False
      End If
      
   temp$ = RTrim$(L.drdirection)
   '03Oct96 CKJ/KR parsed temp$ for all past and current line separators so that lines displayed correctly.
   replace temp$, crlf, Chr$(LBL_END_LINE), 0
   replace temp$, lf, Chr$(LBL_END_LINE), 0
   replace temp$, cr, Chr$(LBL_END_LINE), 0
   replace temp$, Chr$(LBL_END_LINE), crlf, 0
   txtUC("TxtDirections").text = temp$
   
   SetLblQtyDescCaption L.IssType
   
   SetLblNameCaption
   
   If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "RepeatDispensing", 0)) And L.IssType <> "C" And L.IssType <> "P" And L.containersize > 0 Then '26Apr99 SF
      txtUC("TxtQtyPrinted").text = L.containersize
      txtUC("TxtQtyPrinted").Tag = ""
   End If
   
   StopEvents = False
         
   fraUC("fraRx").Refresh

End Sub


Sub LoadBNF()
'09Dec96 ASC
'needs more thought before this could run on the server or any other directory than \bnf\exe
'as installed (may only last until next version of BNF since no agreement has been reached to keep
'the format of the BNF standard as yet
'29may97 CKJ added call to GetActiveWindow so as to prevent the Browser application
'            from losing input focus immediately
'26Jun98 ASC Now takes Appactivate window title from terminal.ini
'22May00 AE  Changed to do an index search rather than a contents search, as some BNF INN names
'            are non-standard and stop the contents search working.
'24May02 CKJ BNF commands & parse limits are now configurable
'09May05 CKJ

Dim temp As String
Dim strCommand As String
Dim intloop As Integer
Dim strParseLimit As String
Dim iret As Long
Dim Hwnd As Long
Dim msg As String
Dim strErr As String

Const SW_SHOWNORMAL = 1

   On Error GoTo BNF_ERR
   
   Screen.MousePointer = HOURGLASS
        strCommand = TxtD(dispdata$ & "\Patmed.ini", "LoadBNF", "https://bnf.emishealth.com/search/external/?ApiKey=1DA88ADC-CC07-4B02-8B30-9CC95DB88718&pagenumber=1&searchid=", "1", 0)
        temp$ = d.LabelDescription & " "     ' temp$ = d.Description & " " XN 4Jun15 98073 New local stores description6164
   
   If Trim$(d.chemical) <> "" Then temp$ = d.chemical & " "
   strParseLimit = TxtD(dispdata$ & "\Patmed.ini", "LoadBNF", "!([{,", "ParseLimit", 0)
   For intloop = 1 To Len(strParseLimit)
      plingparse temp$, Mid$(strParseLimit, intloop, 1)
   Next
   temp$ = LCase$(Left$(temp$, InStr(temp$, " ") - 1))
   
   strErr = ""
   Hwnd = GetActiveWindow()  ' GetDesktopWindow()
   iret = ShellExecute(Hwnd, "Open", strCommand & temp$, "", "", SW_SHOWNORMAL)
   Screen.MousePointer = STDCURSOR
   
   If iret <= 32 Then
      Select Case iret
         Case 0:    msg = "Insufficient system memory or corrupt program file"
         Case 2:    msg = "File not found"
         Case 3:    msg = "Invalid path"
         Case 5:    msg = "Sharing or protection error"
         Case 8:    msg = "Insufficient memory to run program"
         Case 11:   msg = "Invalid program file"
         Case 14:   msg = "Unknown program file type"
         Case 19:   msg = "Attempt to run a compressed program file"
         Case 20:   msg = "Invalid DLL"
         Case 21:   msg = "Program requires Windows 32-bit extensions"
         Case 31:   msg = "No application associated with this type of file"
         Case Else: msg = "Error" & Str$(iret) & " occurred trying to run application"
         End Select
      MsgBox msg, MB_ICONEXCLAMATION, "Launch Error"
      
      strErr = Format$(iret)
   End If

End_BNF:
Exit Sub

BNF_ERR:
Resume End_BNF

End Sub

Sub MakeDoseUnitsLbl()
'05Jul96 KR  Forced pass by value in plural$ as plural$ now takes single not int
   
Dim capt$, X As Integer, nod&, ess$

   capt$ = RTrim$(lblUC("RxUnits", 1).Caption)
   If Right$(capt$, 1) = "s" Then capt$ = Left$(capt$, Len(capt$) - 1)
   
   For X = 1 To 6
      nod& = Val(txtUC("TxtDose", X).text) '20Jan95 CKJ Nod to Nod#
      If nod& > 0 Then                      ' since max dose is 999999
            If capt$ = "mg" Then
                  ess$ = ""
               Else
                  If nod& > 2 Then nod& = 2
                  ess$ = plural$((nod&))
               End If
            lblUC("RxUnits", 1).Caption = LCase$(capt$ + ess$)
         End If
   Next

End Sub

''Sub MakePMRLine(Item$)
'''02Oct96 KR added Asciiz call.
'''5Oct96 ASC modified for use with True grid and extended structure
''
''   '                     length   start stop
''
''   ' Type                  1     1     1
''   ' Date                  7     2     8
''   ' Item                  48    9     56
''   ' Dose                  12    57    68
''   ' Time                  30    69    98
''   ' PharmID               3     99    101
''   ' Own Medication        1     102   102
''   ' Route                 4     103   106
''   ' Issued                7     107   113
''   ' Date                  6     114   119
''   ' Dr                    3     120   122
''   ' Pharm                 3     123   125
''   ' PRN                   1     126   126
''   'Stop date              6     127   132
''   'Rx id                  9     133   141
''''   'findfile               4     142   145
''   'Internal No            9     146   154
''
''
'''28Jul97 CKJ two digits only if exact hour
'''13Nov97 CFY New column inserted for patients own medication
'''17Nov97 CFY Changed position of patients Own column
'''18Nov97 CFY Added PharmId column
'''28May98 CFY Extra code added which stops drug descriptions which
'''            which have a third line, being omitted from the pmr grid
'''26Dec98 ASC Added PRN and stop date for widened display
'''19Jan99 EAC Enhancement 603: handle labels with modified warnings/instructions
'''26Mar99 AE  Changed LstRX to pass dates as a hex string(6-character) instead of ddmmyy or yymmdd
'''31Mar99 CKJ/AE Added checks for blank/zero dates
'''01Apr99 AE Moved above mod to correct position
'''06Mar00 SF if a Pyxis supplied item then display "P" in the "Issued" column
'''08Mar00 SF corrected 06Mar00 Pyxis mod logic
'''04May00 EAC Correct handling of labels with modified instructions/warnings
'''02Aug00 MMA Added: Global update for Teamwork
'''25Aug00 JN  Only start looking for direction text after drug description
'''09Nov00 JN  Fixed problem with the way the PMR line was being built. Faulty storing of label number was causing label mismatch (event 48065)
'''14Dec00 JN/CKJ  Moved blank drug description detection code here...
'''15Dec00 JN/CKJ  If drug description is not set up properly, drug description will show '<Blank>' in truegrid
'''15Dec00 JN/CKJ  Refined how drug description was parsed and built - now doesn't check first line of description for directions
'''19Dec00 CKJ Corrected the comment block above, where findfile and Internal No were the wrong way round
'''20Dec00 JN/CFY  Fixed problem with blank lines and newly-created PMRs
'''22Dec00 JN/SF/CKJ Commented-out code which sets LstRx() and logging added patdata blnklab.log (event 49440)
'''29Mar01 CKJ/ASC Changed to ensure all label lines are visible (event 51459)
'''28May02 SF for civas label types now displays the CIVAS qty (gCIVASdos$) (#39741)
'''27Jun02 SF removed mod 28May02 SF (#39741)
''
''
''Dim desc$, temp$, Numoflines%, dat$, dt As DateAndTime, days&, extra%, valid%
''Dim pyxisTxt$     '06Mar00 SF added
''Dim udtDrug As DrugParameters    '14Dec00 JN Added
''Dim lngNSVfound As Long       '14Dec00 JN Added
''Dim X As Integer
''
''   ReDim lines$(10)     '29Mar01 CKJ/ASC Changed to ensure all label lines visible
''
''   deflines L.Text, lines$(), Chr$(LBL_END_LINE), 1, Numoflines
''   desc$ = trimz(lines$(1))
''   For X = 2 To Numoflines    'ignore the first line of the description
''      temp$ = UCase(trimz(lines$(X)))
''      If InStr(temp$, "TAKE ") = 1 Then Exit For
''      If InStr(temp$, "GIVE ") = 1 Then Exit For
''      If InStr(temp$, "INHALE ") = 1 Then Exit For
''      If InStr(temp$, "SUCK ") = 1 Then Exit For
''      If InStr(temp$, "APPLY ") = 1 Then Exit For
''      If InStr(temp$, "INSERT") = 1 Then Exit For
''      If InStr(temp$, "PUT ") = 1 Then Exit For
''      If InStr(temp$, "SPRAY ") = 1 Then Exit For
''      If InStr(temp$, "IRRIGATE ") = 1 Then Exit For
''
''      temp$ = trimz(lines$(X))
''      If Len(temp$) Then desc$ = desc$ & " " & temp$
''   Next
''
''   If LTrim$(desc$) = "" And TrueFalse(txtd(dispdata$ & "\patmed.ini", "", "N", "NoBlankDrugDescriptions", 0)) Then    '14Dec00 JN Added this check
''         udtDrug.SisCode = L.SisCode
''         getdrug udtDrug, 0, lngNSVfound, False
''         If lngNSVfound > 0 Then
''               desc$ = udtDrug.Description
''               plingparse desc$, "!"
''            End If
''
''         If Trim$(desc$) = "" Then
''               desc$ = "<Blank>"
''            End If
''
''         'Log the event
''         WriteLog patdatapath$ & "\blnklab.log", SiteNumber, UserID$, "NSVCode: '" & L.SisCode & "', Drug Description: '" & udtDrug.Description & "', PMR Desc: '" & desc$ & "', l.patid: '" & L.patid & "', l.text: '" & L.Text & "'"
''
''      End If
''
''   dt.mint = L.RxStartDate                   '24Mar99 AE  Changed to pass dates in LstRX in hex rather than ddmmyy or yymmdd
''   If dt.mint <> 0 Then                      '01Apr99 AE Moved from position above
''         days& = Int(dt.mint / 1440)         'to convert minutes to days - check for rounding (should round down to this day). Should be ok as hexdt is an integer
''         dat$ = Hex$(days&)                  'converted to hex
''         dat$ = pad$(dat$, 6)                'Pad with spaces to 6 characters.
''      Else
''         dat$ = Space$(6)                    '31Mar99 CKJ/AE Added
''      End If
''   dat$ = dat$ & " "                         'additional spacer between date and description.
''
''   Item$ = L.IssType & dat$ & pad$(desc$, 48)
''
''''   If gintModified = 1 Then L.dircode = Space$(Len(L.dircode))      '04May00 EAC changed from l.flags      '02Aug00 MMA changed to global
''   Item$ = Item$ & L.dircode
''
''   extra = 0                                     '28Jul97 CKJ two digits only if exact hour
''   For X = 1 To 6
''      If Right$(L.Times(X), 2) = "00" Then
''            Item$ = Item$ & Left$(L.Times(X), 2) & " "   'keep first two chars only
''            extra = extra + 2                            'remember to pad with spaces
''         Else
''            Item$ = Item$ & L.Times(X) & " "             'do it the old way
''         End If
''   Next
''   Item$ = Item$ & Space$(extra)                         'add missing spaces
''
''   'Last Issued Date
''   parsedate L.lastdate, dat$, "1", valid     'ddmmyy -> dd/mm/ccyy
''   If valid Then                              '31Mar99 CKJ/AE Added
''         StringToDate dat$, dt
''         days& = Int(dt.mint / 1440)          '24Mar99 AE changed to pass dates as hex
''         dat$ = Hex$(days&)
''         dat$ = pad$(dat$, 6)
''      Else
''         dat$ = Space$(6)                     '31Mar99 CKJ/AE Added
''      End If
''
''   Item$ = Item$ & L.PharmacistID   '18Nov97 CFY
''   Item$ = Item$ & L.Flags '17Nov97 CFY re-added here
''
''   '08Mar00 SF corrected the logic below
''   '06Mar00 SF added to display if a Pyxis supplied item
''   If PyxisSetup() Then
''         If L.PyxisItem Then
''               pyxisTxt$ = Trim$(txtd(dispdata$ & "\PYXIS.INI", "Defaults", "P", "PyxisPMRtext", 0))
''               If Len(pyxisTxt$) > 7 Then pyxisTxt$ = Left$(pyxisTxt$, 7)
''               Item$ = Item$ & L.route & pad$(pyxisTxt$, 7) & dat$
''            Else
''               Item$ = Item$ & L.route & pad$(Str$(L.lastqty), 7) & dat$
''            End If
''      Else
''         Item$ = Item$ & L.route & pad$(Str$(L.lastqty), 7) & dat$   '06Mar00 SF moved into ELSE block
''      End If
''
''   dt.mint = L.StopDate
''   If dt.mint <> 0 Then                       '31Mar99 CKJ/AE Added
''         days& = Int(dt.mint / 1440)          '24Mar99 AE changed to pass dates as hex
''         dat$ = Hex$(days&)
''         dat$ = pad$(dat$, 6)
''      Else
''         dat$ = Space$(6)                     '31Mar99 CKJ/AE Added
''      End If
''
''   Item$ = Item$ & L.prescriberid & L.PharmacistID & L.PRN & dat$ & Left$(Format$(L.prescriptionid) & "         ", 9) & "    " & Left$(Format$(Labf&) & Space$(9), 9)   '09Nov00 JN Amended
''
''End Sub

Sub MakeTTOandPIL()
'ASC 27Mar94 makes TTO and PIL files
'26Nov95 Now prints PIL for status entered rather than pid.status
'        patient may be I but a leaflet for all L's is needed
'16Jan96 EAC Added new TTO/PIL status selection form
'09Feb96 EAC if printing PCLs display extra check box and date entry text box
'08Dec97 SF now makes PMC file
'22Dec97 ASC/SF changed use of plvl to TxtD$ to stop showing error if features not used
'27Jan98 CFY changed condition which determines wheher TTO/PIL window is displayed, so that
'        it will now appear when a patient has drugs for blister packing.
'30Jun98 CFY/SF Now picks up all patient status types as specified in patmed.ini. Previously
'               only picked up discharge patients.
'22Sep99 CFY Calls new routines for patient/blister printing.

Dim TTOing$
Dim PILing$
Dim PMCing$

   TTOing$ = TxtD(dispdata$ & "\PATMED.INI", "", "", "TTO", False)
   PILing$ = TxtD(dispdata$ & "\PATMED.INI", "", "", "PIL", False)
   PMCing$ = TxtD(dispdata$ & "\PATMED.INI", "", "", "PMC", False)

   If InStr(Trim$(PMCing$), UCase$(pid.status)) Then
         pmc = True
      Else
         pmc = False
      End If

   If Trim$(TTOing$) <> "" Then tto = True Else tto = False

   If TxtD(dispdata$ & "\patmed.ini", "", "", "PCL", 0) = "" Then
         PCL = False
      Else
         PCL = True
      End If
   If (Trim$(PILing$) <> "" And chkUC("chkPIL").Value = 1) Then pil = True Else pil = False
                                                                                 '         "
''   If tto Or pil Or pmc Then CallPatientPrinting                                 '         "
   If BlisterSemaphore <> 0 Then CallBlisterPacking                              '         "

End Sub

Sub MapTimesToTimeBands(strScriptTimes() As String)
'10Nov01 CKJ Written
'            This procedure takes the l.times() array and selects which of six printable boxes will be populated
'            Consider two doses at 8am and 8pm. These would normally be printed on a prescribing label as
'             ------------------
'                    |  08:00  |
'                    |---------|
'                    |  20:00  |
'                    |---------|
'                    |         |
'                    |---------|
'                    |         |
'                    |---------|
'                    |         |
'                    |---------|
'                    |         |
'             ------------------
'
'            This routine choses the 'best' boxes to use, such as
'             ------------------
'                    |         |
'                    |---------|
'                    |  08:00  |
'                    |---------|
'                    |         |
'                    |---------|
'                    |         |
'                    |---------|
'                    |  20:00  |
'                    |---------|
'                    |         |
'             ------------------
'            The boxes are represented by printable elements [lBoxT1] to [lBoxT6] on the heap.
'            The mapping is controlled by configuration options in dispdata.xxx/MapTimes.ini as follows
'
'               [TimeBands]
'               Total = 4              <== This is the crucial line which indicates file is present (Must = 4 in this version)
'               Start1=00:00           <== Always 00:00
'               Start2=09:30           <== format HH:NN mandatory
'               Start3=15:30           <== 24hr clock must be used
'               Start4=19:30           <== Implicit end of each band is one minute before next, i.e. 09:29 15:29 19:29 23:59
'                                          4 bands only are supported, no more, no less. Four is the number of the bands.
'                                          (Five is right out, Three also except that thou proceed to Four)
'               [MapTimeToBox]
'               1=0****0               <== 1, 2 or 3 times get spread between the four adjacent banded boxes
'               2=0****0               <== The '****' block must be contiguous, ie ****00 0****0 or 00****
'               3=0****0
'               4=011110               <== 4, 5 or 6 times get placed in fixed positions
'               5=111110
'               6=111111
'
'               [ConflictResolution]
'               2000=011000            <== 2 entries in band 1 get split into boxes 2 & 3
'               0200=001100
'               0020=000110
'               0002=000110
'               3000=011100
'               0300=011100
'               0030=001110
'               0003=001110
'               2100=011100
'               2010=011100
'               2001=011010
'               0210=011100
'               0201=001110
'               0021=001110
'               1200=011100
'               1020=010110
'               1002=010110
'               0120=001110
'               0102=001110
'               0012=001110
'
'            If this file is not configured or if a problem is encountered during processing
'            (i.e. duff config file or duff data) then it behaves as if the following settings were in force;
'            [MapTimeToBox]
'            1=100000
'            2=110000
'            3=111000
'            4=111100
'            5=111110
'            6=111111
'            No time bands and therefore no conflicts.
'            This is essentially the default printing which was used on all previous prescription labels.


Dim intTimesUsed As Integer            'total number of entries to parse, from 0 to 6
Dim intloop As Integer
Dim strPathfile As String
Dim strTemp As String
Dim intSuccess As Integer
Dim strMapTimeToBox As String          'six character string ultimately representing which boxes to fill e.g. "010110"
Dim intCounter As Integer
Dim intBand As Integer
Dim strBands As String                 'four character string holding number of items in each time band e.g. "1020"
Dim strBandStart As String

   ReDim strBox(1 To 6) As String      'Six printable data items suitably formatted as HH:NN
   ReDim strTimes(1 To 6) As String    'l.times() cleaned up and formatted as HHNN
   ReDim intBandStart(1 To 4)          'time of start of each band as integer in range 0 to 2359

   intSuccess = True
   strPathfile = dispdata$ & "\MapTimes.ini"
   If TxtD(strPathfile, "TimeBands", "", "Total", 0) <> "4" Then  'File not present so create it with defaults
         strTemp = "[TimeBands]|Total=4|Start1=00:00|Start2=09:30|Start3=15:30|Start4=19:30||[MapTimeToBox]|1=0****0|2=0****0|3=0****0|4=011110|5=111110|6=111111||[ConflictResolution]|2000=011000|0200=001100|0020=000110|0002=000110|3000=011100|0300=011100|0030=001110|0003=001110|2100=011100|2010=011100|2001=011010|0210=011100|0201=001110|0021=001110|1200=011100|1020=010110|1002=010110|0120=001110|0102=001110|0012=001110|"
         replace strTemp, "|", crlf, 0
         PutTextFile strPathfile, strTemp, intSuccess
         If Not intSuccess Then
               popmessagecr ".", "Could not create mapping file " & strPathfile & crlf & "Please inform Supervisor"
            End If
      End If

   intTimesUsed = 0
   For intloop = 1 To 6                                                    'Check each entry in turn
      strTemp = Trim$(strScriptTimes(intloop))                             'accepts HHNN or HH:NN
      If strTemp <> "" Then                                                'has a time in it
            intTimesUsed = intTimesUsed + 1
            parsetime strTemp, strTimes(intTimesUsed), "2", intSuccess     'format to just HHNN
            If Not intSuccess Then Exit For                                'not parseable
         End If
   Next
   If intTimesUsed = 0 Then intSuccess = False                             'no times, so no work to do
   
   If intSuccess Then
         For intBand = 1 To 4                                              'read time bands from configuration file
            strTemp = TxtD(strPathfile, "TimeBands", "", "Start" & Format$(intBand), intSuccess)
            If Not intSuccess Then Exit For                                'no such entry in file
            parsetime strTemp, strBandStart, "2", intSuccess               'format to just HHNN
            If Not intSuccess Then Exit For                                'invalid entry in file
            intBandStart(intBand) = Val(strBandStart)                      'store for band checking
            If intBand > 1 Then                                            'times must increase in order
                  If intBandStart(intBand) <= intBandStart(intBand - 1) Then
                        intSuccess = False
                        Exit For
                     End If
               End If
         Next
         If Not intSuccess Then popmessagecr ".", "Contact Supervisor: Invalid time band entry in " & strPathfile
      End If
   
   If intSuccess Then                                                      'file present and at least one dose to do
         strMapTimeToBox = TxtD(strPathfile, "MapTimeToBox", "", Format$(intTimesUsed), 0)
         If InStr(strMapTimeToBox, "****") Then                            'pre-process times to bands
               strBands = "0000"                                           'number of items in each band
               For intloop = 1 To intTimesUsed                             '1 to 1, up to 1 to 6
                  If intloop > 1 Then                                      'times must increase in order
                        If Val(strTimes(intloop)) <= Val(strTimes(intloop - 1)) Then
                              intSuccess = False
                              Exit For
                           End If
                     End If
                  Select Case Val(strTimes(intloop))                       'HHNN as an integer
                     Case Is >= intBandStart(4): intBand = 4
                     Case Is >= intBandStart(3): intBand = 3
                     Case Is >= intBandStart(2): intBand = 2
                     Case Else:                  intBand = 1
                     End Select
                  Mid$(strBands, intBand, 1) = Format$(Val(Mid$(strBands, intBand, 1)) + 1)      'increment appropriate digit
               Next
               Heap 10, gPRNheapID, "Debug:strBands", strBands, 0                                           'to aid debugging
               Heap 10, gPRNheapID, "Debug:strMapTimeToBox_A", strMapTimeToBox, 0                           '    "

               If intSuccess Then
                     If InStr(strBands, "2") = 0 And InStr(strBands, "3") = 0 Then
                           replace strMapTimeToBox, "****", strBands, 0    'fix up the replaceable block
                        Else                                               'conflict found - read alternative format
                           strMapTimeToBox = TxtD(strPathfile, "ConflictResolution", "", strBands, intSuccess)
                        End If
                  End If
               Heap 10, gPRNheapID, "Debug:strMapTimeToBox_B", strMapTimeToBox, 0                           'to aid debugging
            End If

         If intSuccess Then
               'Now strMapTimeToBox contains only 0s and 1s corresponding to boxes to be used e.g. "010010" for 8am & 8pm
               intCounter = 0
               For intloop = 1 To 6                                        'for each box
                  If Mid$(strMapTimeToBox, intloop, 1) = "1" Then          'put text in this box
                        intCounter = intCounter + 1                        'e.g. strBox(5) could contain l.times(1)
                        parsetime strTimes(intCounter), strBox(intloop), "1", intSuccess   'format to HH:NN for printing
                        If Not intSuccess Then Exit For
                     End If
               Next
            End If
      End If

   For intloop = 1 To 6
      If Not intSuccess Then strBox(intloop) = strScriptTimes(intloop)     'default is to use l.times() as before
      Heap 10, gPRNheapID, "lBoxT" & Format$(intloop), strBox(intloop), 0  'Post lBoxT1 to lBoxT6 on the heap
   Next

End Sub

Sub memorytolabel()
'16feb00  Addition to highlight description if needed
'!!V93!! Seems to be called from iodl combo - is this right?

Dim X As Integer, ans$

   If L.extralabel Then
      setExtendedLabelWYSWY
      For X = 0 To 15 '05Aug14 TH
         setforecolour X, True, True
         ans$ = RTrim$(labelline$(X))
         If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
         frmExtraLabel.TxtLabel(X).text = ans$
      Next
   Else
      For X = 0 To 9
         setforecolour X, True, False
         ans$ = RTrim$(labelline$(X))
         If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
         txtUC("TxtLabel", X).text = ans$
      Next
   End If
   HighlightDescriptionLines                                           '16Feb00 AE

End Sub

Sub NewRx(L As WLabel, AskIfNew, blankdirect)
'21May95 ASC Rewritten didn't work before dates sorted out in
'            formdates (In labeltoform) Used to make a new prescription
'            from an old copy keeping old dose etc but starting with new
'            dates etc.
'19Jun95 CKJ Removed line
'03Nov98 CFY Added l.lasttqy
'25Nov98 CFY/SF removed above mod
'16Nov99 SF clears l.prescriptionid so it is not re-used
'16May00 SF only want to blank l.prescriptionid if a new item
'15Mar02 ATW Added l as parameter to encapsule routine better - calls to this in NewRx were erasing details that
'              should have been kept - brand new 'scrips in Prescriber mode had no PrescriberID

Dim ans$

   ans$ = "Y"
   If AskIfNew Then
         Confirm "New Prescription", "Discontinue old Prescription and start a new prescription", ans$, k
      End If
   If ans$ = "Y" Then
''         LabelForArchive& = Labf& '09Jun95 ASC
         L.dispid = ""
         L.StoppedBy = ""
         L.RxStartDate = 0  'gets set to today in formdates
         L.StopDate = 0
         L.deletedate = 0  'ASC 27Nov95
         L.RxNodIssued = 0
         L.topupqty = 0
         L.batchnumber = 0
         L.PrescriberID = ""
         L.PharmacistID = ""
         If blankdirect Then L.dircode = ""
         labeltoform
         If blankdirect Then
               BlnkPrescribFrm False
               L.PrescriptionID = 0                   '16May00 SF only want to blank if a new item
            End If
      End If

End Sub

Sub OnClosingDispens(andexit)
'26Sep96 CKJ Closes logs on exit
'18Feb98 CFY Removed ability to added discharge patients to the patwdcon index.
'            This is to allow us to review what how to handle discharge patients in
'            batch blister packing.
'15Dec98 SF  added patient billing call
'04Jun99 SF  patient billing mods
'21Jul99 SF  now clears the rx number to lookup on in case the next lookup is not via "/P"
'14Oct99  AE  Added line to unload frmcolour, otherwise it persists through the TTO/PIL printing process.
'25Oct00 CFY Calls SetDateAndTime with ForceRead parameter set if preparation time has been changed
'29Jun01 CKJ Added option to allow prescribers to use patientprinting screen
'09Aug02 TH  Added call to sortpmr to reset sort order for next patient (#62371)
'05Mar03 TH  (PBSv4) Moved call to shut the billing objects as was causing referencing problems.

Dim PatBillStub%     '04Jun99 SF added
Dim ans$, chan As Integer, waswsc$, iswsc$, baddata As Integer
   
   SetDateAndTime "", "", True      'Force re-read to refresh static variables
   
   If pid.status = "D" Then
      If BlisterSemaphore <> 0 Then          'Add patient to patwdcon index
         waswsc$ = ""
         iswsc$ = "" 'pid.ward & pid.Status & pid.cons      '!!** 18Feb98 CFY Removed
      Else                                   'Remove patient from patwdcon index
         waswsc$ = pid.ward & pid.status & pid.cons
         iswsc$ = ""
      End If
'>>      IndexUpdate waswsc$, iswsc$
   End If

   '** Unlock here **
   If pid.recno > 0 Then            '08Nov05 CKJ Was patno&
      '29Jun01 CKJ Added option to allow prescribers to print
      If passlvl <> 3 Or TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "N", "AllowPrescriberAccess", 0)) Then
         MakeTTOandPIL
      End If
   End If
  
   If andexit Then
         ToggleRxLabel True
         '25Mar96 KR Added as precaution, as wdir & l are now global variables
         BlankWDirection WDir
         clearlabel L
         Erase labelline$

         PatBillStub% = billpatient(2, "") '05Mar03 TH (PBSv4) Moved from above  '12Mar03 TH (PBSv4) Moved from below
''         Unload Dispens
''         CloseSubPatMed  '26Sep96 CKJ Added to close logs
         gPrescriberID$ = ""     '25Jul97 CKJ added
      End If

End Sub

Sub onloadingdispens()
'20JUN96 KR Cleared patient medication record to prevent patient-label mismatch error
'10May97 KR Added Infobarstatus 3 if prescriber view - not being set
'04Jun97 KR If prescriber view, change SAVE button to Authorise.
'13Jun97 KR Reinstated check for presence of rxid.dat from lost edit
'SHARED loaded 12mar96 KR declared at module level
'13Nov97 CFY New column added for patients own medication
'17Nov97 CFY Moved column position of patients own
'18Nov97 CFY Added PharmId column
'11Feb98 CKJ/CFY If PMR is locked then exit, don't proceed
'18Feb98 CKJ Exit if patient cannot be loaded eg locked elsewhere
'22Jul98 EAC make language aware
'08Oct98 ASC/CFY Adjusted column widths to make better use of space now that we are displaying dates
'                in a different format
'15Dec98 SF  added patient billing call
'25May99 CKJ Changed path & added error handling round LoadPicture
'04Jun99 SF  patient billing mods
'08Jun99 EAC Change references to Ident form so that Ident is not loaded when in OCX mode
'05Jul99 AE  added to check licence file to enable new pharmacokinetics module
'22Sep99 CFY Picks up new AutoArchive setting from patmed.ini
'10Jan00 AE  Added password checks for pharmacokinetics.
'02Jun00 AE  Licence checks etc for Kinetics moved into InitialiseKinetics
'18May00 TH  Changed column heading from rx no. to rec no.
'01Sep01 TH  Added call to refresh preparation date/time if not explicitly stored (clean out statics)(#46712)
'25Oct01 TH/CKJ Open labchan for future use here (in case this could be bypassed later) (#56346)
'20Mar02 TH  Added wordwrap property on description to false to retain as much as possible of text (#51757)
'27Sep02 TH  Added clean out of heap for UMMC rxing items/pigeon hole stuff - in 8.4 this was on switch, now it is mandatory !
'16May04 TH  UMMC pricehide mod to set functionality based on passlvl

Dim PatBillStub%     '04Jun99 SF added
Dim filename$, errtxt$                                    '25May99 CKJ Added
Dim baddata As Integer, valid As Integer, X As Integer, id$, Choice$, i As Integer, done As Integer

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "onloadingdispens"

   On Error GoTo ErrorHandler
''   AutoArchive = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "AutoArchive", 0))            '22Sep99 CFY Added
   
   Labf& = 0
''   LabelForArchive& = 0
   baddata = 0
   StopEvents = True
   If Not Loaded Then   '20May95 ASC
      passlvl = Val(Left$(acclevels$, 1))
         If passlvl < 5 Then                    '16May04 TH Altered after testing  (UMMC pricehide)
            SetFindDrugLowPassLevel True
         Else
            SetFindDrugLowPassLevel False
         End If
         Loaded = True
      End If

''   If patno& > 0 Then
''         getpatidL patno&, pid               ' <== LOCK PID
''         pmrptr& = Val(pid.ptr(8))   ' = rf(8)
''
''         If pmrptr& = 0 Then
''               GetPointer patdatapath$ + "\pmr.v5", pmrptr&, True
''               pid.ptr(8) = LTrim$(Str$(pmrptr&))
''               putpatidL patno&, pid             ' <== UNLOCK PID
''
''               '2OJun95 ASC Reinstalled 'cos label not clearing if enter new patient from dispensing screen.
''               For X = 1 To 50
''                  labrf&(X) = 0
''               Next
''
''               ' ** Lock here **
''               lockpmr pmrptr&, True, k  ' f
''               '!!** Should trap k.escd and quit if failed to lock
''               putpmr pmrptr&, (pid.recno)   ' f
''            Else
''               UnlockPatid patno&, Len(pid)  ' <== UNLOCK PID
''               ' ** Lock here **
''               id$ = pid.recno
''               baddata = 0                       ' 31Jul91 CKJ
''               GetPMR pmrptr&, id$, baddata
''               '26Jun96 CKJ Replaced with baddata check below
''               'If baddata Then END  'PMR does not match unit no in file1
''            End If
''      End If
''
''   If baddata Then
''         'Since OnClosingDispens assumes the patient records are loaded & locked, we cannot use it here
''         'Instead of proceeding with no patient loaded, now explicity shut things & quit
''         CloseSubPatMed
''         OpenInteractionDb False
''         gPrescriberID$ = ""
''         k.escd = True
''         'stopevents is already true and is the flag to say we exited early
''         Exit Sub                     '<=== WAY OUT
''
''      Else
         BlankWProduct d
         clearlabel L     ' set defaults for Dispens.TxtLabel().text,) etc
         Erase labelline$
'>>         If Choice$ <> "A" Then Dispens.TGLabelList.MarqueeStyle = 5
         LabelAmended = False
         Qty! = 0

         If passlvl <> 3 Then SetDateAndTime "", "", True     '01Sep01 TH Added to refresh preparation date/time if not explicitly stored (clean out statics)(#46712)
         SetDispenseForm
''         FindSmallLabelPrn
         If plvl$("PIL") <> "" Then
            chkUC("chkPIL").Visible = False        '09May05 was True now always disabled
            chkUC("chkPIL").Value = 0
         End If
         
         Blanklabel
''      End If
   
'    Field           charpos
'    -----           -------
   ' Type               1
   ' Date               9
   ' Item               48
   ' Dose               19
   ' Route              5
   ' Issued             7
   ' Date               9
   ' Own Medication     1
   ' Dr                 4
   ' Pharm              4
   ' Internal No        9
   ' File               4

   If passlvl = 3 Then
         lblUC("LblQtyDesc").Visible = False
         txtUC("TxtQtyPrinted").Visible = False
         lblUC("LblPrintForm").Visible = False
''         Dispens.MnuTools(0).Enabled = False
''         cmdUC("CmdPrompt", 6).Enabled = True
''         cmdUC("CmdPrompt", 7).Enabled = True
''         Dispens.MnuTools(1).Enabled = True
''         cmdUC("CmdPrompt", 9).Enabled = True
''         Dispens.MnuTools(2).Enabled = True
         done = True
      Else
         lblUC("LblPrintForm").Visible = True
''         Dispens.MnuTools(0).Enabled = True
''         cmdUC("CmdPrompt", 6).Enabled = False
''         cmdUC("CmdPrompt", 7).Enabled = False
''         Dispens.MnuTools(1).Enabled = False
''         Dispens.MnuTools(2).Enabled = False
      End If
'>>   infobarstatus 3      '10May97 KR Added
   
'>>   InitialiseKinetics                                          '?????00 AE  Code moved into procedure
                     
''   If Not fileexists(ASCFileName("route.ini", True, "")) Then
''         popmessagecr "File not found", ASCFileName("route.ini", True, "") & cr & "Please report to your system manager"
''      End If
''
''   If Not fileexists(dispdata$ & "\containr.dat") Then
''         popmessagecr "File not found", dispdata$ & "\containr.dat" & cr & "Please report to your system manager"
''      End If
   
''   picUC("PctCmd", 1).Visible = (trimz$(pidNotes.notes) <> "")
''   picUC("PctCmd", 2).Visible = (trimz$(pidExtra.allergy) <> "")
''   picUC("PctCmd", 3).Visible = (trimz$(pidExtra.diagnosis) <> "")

   PatBillStub% = billpatient(0, "")     '04Jun99 SF added to load patient details

   StopEvents = False
   If passlvl = 3 Then lblUC("Label3").Caption = "Start Protocol     Time" '09Jan99 ASC

   Heap 10, gPRNheapID, "PatientTicketNo", "", 0                                '27Sep02 TH Clean out pigeon elements
   Heap 10, gPRNheapID, "PigeonholeNo", "", 0


Cleanup:
'   On Error Resume Next
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Sub


Sub onwsl(ward$, NSVCode$, found%)
'02Jun97 KR  Added.
'found% =  0 Not found on stock list
'found% = -1 Found on stock list
'found% =  2 number error has occured
'03May01 CKJ Modified so that OnWSL only returns found=True for a prescribing ward if the item has a topup level > 0
'            Now also uses a snapshot instead of dynaset, as it is a read only procedure.

Dim lngFound As Long
Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrHandler

   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, NSVCode) & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, ward)
   lngFound = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWWardStockListIsItemPresent", strParameters)
      
Cleanup:
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "OnWSL", sErrDesc
   End If
   found = (lngFound <> 0)
Exit Sub

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
   
End Sub

''Function PresentLabel&()
'''5Oct96 ASC converted for use with True Grid
''
''''   If Dispens.TGLabelList.MarqueeStyle = 5 Then
''''         PresentLabel& = 0
''''      Else
''''         PresentLabel& = Val(Dispens.TGLabelList.ColumnText(15))      '   "
''''         findfile$ = Dispens.TGLabelList.ColumnText(16)               '   "
''''      End If
''
''   PresentLabel = L.RequestID
''
''End Function

Function PresentPrescriptionID&()

   PresentPrescriptionID& = L.PrescriptionID

End Function

Sub PrintRx()
'10Nov99 TH Set Prescriber Labels to context printing (RXLbl)
'06Dec16 TH Replaced RTF Handling (TFS 157969)

Dim ans$, success%
Dim filename$

   Screen.MousePointer = HOURGLASS

   If chkUC("ChkPRN").Value Then
         filename$ = "\RXPRN.rtf"
      Else
         filename$ = "\RXGEN.rtf"
      End If

   'GetTextFile dispdata$ & filename$, ans$, success%
   GetRTFTextFromDB dispdata$ & filename$, ans$, success%  '06Dec16 TH Replaced (TFS 157969)
   
   ParseRx ans$
   
   If InStr(Command$, "preview") Then         'print preview
         Screen.MousePointer = STDCURSOR
         Hedit 2, ans$
      Else                                    'print
         Hedit 4, "RXLbl" & Nul & ans$
      End If
   Screen.MousePointer = STDCURSOR

End Sub

Sub querydelete(outdat$)
'!!** need to trap escape & pass it back
'15Feb99 SF now allows the user to cancel out of discontinuing a prescription
'06Mar00 SF if a Pyxis supplied item then send a discontinue event
'08Mar00 SF  corrected 06Mar00 Pyxis mod logic
'16Mar00 TH/MMA ADDED allows user to issue, discontinue and return a new prescription on the same day
'20Mar00 SF  querydelete: replaces pid.recno with pid.caseno parameter when calling CreatePyxisEvent:
'20Mar00 SF  savelabel: now only writes a Pyxis TeamWork event if a valid Pyxis ward
'24Feb99 EAC automatically fill discontinuation date if in OCX Recovery Mode
'23May02 CKJ Added block to check for future dates
'24Jun02 CKJ Modified wording

Dim ndbd As Long           'Number of days between dates
Dim sMsg As String
Dim indat$, valid As Integer, done As Integer

   '24Feb99 EAC HK Mod - when in recovery mode automatically fill the discontinuation date
''   If OCXlaunch() And GetOCXAction() = "R" Then
''         indat$ = Format$(Now, "DD/MM/YYYY")
''         outdat$ = indat$
''      Else
         parsedate "t", indat$, "1", valid
      
         Do
            InputWin "Discontinue", "Enter the date the medication was discontinued", indat$, k
            If k.escd Then Exit Do
            If indat$ <> "" Then
                  parsedate indat$, outdat$, "1", valid
                  If Not valid And indat$ <> "" Then
                        popmessagecr "Please RE-TRY", "Incorrect date format"
                     End If
      
                  If valid Then                                                  '23May02 CKJ Added block to check for future dates
                        datetodays outdat$, "", ndbd&, 0, "", valid              'compare date entered with today, return number of days between dates
                        If ndbd& < 0 Then                                        'difference is negative, so date given is in the future
                              sMsg = "Discontinuation date entered as " & outdat$ & " is invalid" & cr & "because dates in the future cannot be accepted." & cr & cr
                              sMsg = sMsg & "If you wish to set a discontinuation date in the future" & cr & "then either amend the Stop Date on the prescription" & cr
                              sMsg = sMsg & "or enter a direction code for the duration required" & cr & "e.g. 5d for five days or 1w for one week, etc." & cr
                              sMsg = sMsg & "otherwise please re-enter the date now."
                              
                              popmessagecr "!", sMsg
                              valid = False
                           End If
                     End If
               End If

            If (indat$ = outdat$ And valid) Or indat$ = "" Then done = True
            indat$ = outdat$
         Loop Until done
''      End If

   If k.escd Then
         indat$ = ""
         outdat$ = ""
      End If

   If indat$ <> "" Then
         StringToDate indat$, td
         td.Hrs = Format(Now, "hh")
         td.min = Format(Now, "nn")
         datetomins td
         L.StopDate = td.mint
         
''         If PyxisSetup() Then
''               If L.PyxisItem Then CreatePyxisEvent 1, L.prescriptionid, pid.caseno, d.SisCode, 0, Trim$(pid.ward)
''            End If
      End If

End Sub

Sub QuerySave(ans$)
'07Aug97 KR  Reinstated default setting of "Y".
'02Feb98 CFY Removed setting of labelamended flag to false after call to savelabel.
'            Shouldn't be set here as savelabel sets depending upon whether the
'            PMR was successfully saved.
'05Feb99 SF  now checks to make sure prescription is complete before asking to save it
'14Sep00 JN  from anonymous change of 20Jul98, ans$ should have been "Y" if labelamended = False.
'   "     "  It wasn't doing that, so added Else statement to main If and set ans$ = "Y" (event 47254)
'22Sep00 JN  ensure TxtDirCode.Tag is set to "" to avoid clashed through cancelling an issue
'25Apr02 CKJ Replaced Confirm with multiline AskWin, as title was too short to show full message

Dim rxComplete%  '05Feb99 SF added

   ans$ = "N"     '20Jul98 set to no if label not amended, yes otherwise
   If LabelAmended Then
      CheckRxComplete rxComplete%     '05Feb99 SF added
      If rxComplete% Then             '05Feb99 added, and moved following code into the IF block
         ans$ = "Y"     '07Aug97 KR Reinstated.
         k.helpnum = 70
         
         askwin "?EMIS Health", "This has been amended but not saved" & crlf & "OK to save?", ans$, k  '25apr02 CKJ replaces the 'Confirm'
         If ans$ = "Y" Then   'KR
            SaveLabel 0
         Else
''            LabelForArchive& = 0  '09Jun95  ASC
            LabelAmended = False
            ans$ = "N"
         End If
      Else     '05Feb99 SF added
         popmessagecr "#", "This is incomplete and will not be saved"  '05Feb99 SF added
      End If   '05Feb99 SF added
   Else
      ans$ = "Y"     '14Sep00 JN Added
   End If
   txtUC("TxtDircode").Tag = ""      '22Sep00 Added to ensure tag is cleared if issue cancelled after dosage re-entered

End Sub

Sub RemoveUncommitedDirCode(TxtDirCodePar$, backspace%)
'5Oct96 ASC Moved from main precibing form and passed txtdircode.text as a parameter
'19Jan01 CKJ If the remaining direction does not have "<0-9><H,D>+/" then RxOffset may have been deleted, so set to zero

Dim testpos As Integer, slash As Integer

   testpos = Len(TxtDirCodePar$) + (backspace = 0)
   Do
      If Mid$(TxtDirCodePar$, testpos, 1) = "/" Then
            slash = testpos
            Exit Do
         End If
      testpos = testpos - 1
   Loop Until testpos = 0  'ASC 13Nov94 added testpos =0

   TxtDirCodePar$ = Left$(TxtDirCodePar$, slash - backspace)
   If Len(TxtDirCodePar$) = 1 Then TxtDirCodePar$ = ""

   '19Jan01 CKJ If the remaining direction does not have "<0-9><H,D>+/" then RxOffset may have been deleted, so set to zero
   If InStr(UCase$(TxtDirCodePar$), "+H/") = 0 And InStr(UCase$(TxtDirCodePar$), "+D/") = 0 Then RxOffset& = 0

End Sub

Sub rightuprite(ans$)

   If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
   ans$ = RTrim$(ans$)

End Sub

''Sub rINNcheck()
'''20Jan00 SF added to check if rINN change warning bit set
''
''Dim dcopy As DrugParameters
''Dim drug$, lngFound As Long
''
''   If TrueFalse(TxtD(patdatapath$ & "\PATMED.INI", "rINN", "0", "UpdatedLabelTxt", 0)) Then
''      If L.rINNflag Then
''         BlankWProduct dcopy
''         dcopy.SisCode = L.SisCode
''         getdrug dcopy, 0, lngFound, False
''         If lngFound Then
''            drug$ = Trim$(dcopy.Description)
''            plingparse drug$, "!"
''         Else
''            drug$ = "***** Cannot lookup NSV Code: " & L.SisCode & " *****"
''         End If
''         popmessagecr "#ASCribe", "This drug has changed to the new rINN:" & cr & drug$ & cr & cr & "Please check and amend the label if required."
''      End If
''   End If
''
''End Sub

Sub rtfinsert(char$)
'25Jan96

   If Len(char$) > 3 Then
         Do
            char$ = Left$(char$, Len(char$) - 1)
         Loop Until Asc(Right$(char$, 1)) = 125
         If Right$(char$, 2) = Chr$(125) & Chr$(125) Then char$ = Left$(char$, Len(char$) - 1)
         If Asc(char$) = 123 Then char$ = Right$(char$, Len(char$) - 1)
      End If

End Sub

Sub SaveLabel(success)
'22jun96 KR Added reset l.NeededNextTime if user bypasses teamwork.
'18Feb97 KR Prompt user to change label  back to overide teamwork.
'03Mar97 KR Added check for use pigeon so that teamwork can work without
'           pigeonholes if necessary
'09Mar97 KR Added ward prescribing check so that an event is not created for
'           discharge issues unless discharge button visible.
'13May97 KR Added check for access level so that only call createlabel if in prescriber mode.
'           Fixed problem of colours not being saved.
'01Jun97 KR Added setting of colours from Putlabel
'04Jun97 KR invalid variable checked - passlevel instead of acclevels$
'12Jun97 KR Added Checking and Setting of Prescription ID
'27Jun97 KR Removed the disabling of the dispense form.
'16Nov98 ASC added success to parameters.
'05Feb99 SF now only calls createlabel: if label has not been reused
'15Apr99 CFY Removed as condition which could prevent discharge items being added to the
'            teamwork queue.
'28Sep99 CFY Call to new routine ValidTeamworkRx to determine if the prescription should be added
'            to the teamwork queue.
'28Oct99 CFY Moved code which intialiases Teamwork so that it should always fire.
'16Feb00 AE  Additions for WA LAbels
'06Mar00 SF  sets/clears Pyxis bit
'08Mar00 SF  corrected 06Mar00 Pyxis mod logic
'20Mar00 SF  now only writes a Pyxis TeamWork event if a valid Pyxis ward
'11May00 SF  added logging on a try and find items that the site(Taranaki/Pyxis) says are being saved to the PMR but not TeamWork
'01Jun00 MMA/CFY added popmessagecr (event no.44104)
'11Sep00 JN  Added check to prevent prompting for Ward Stock items in Teamwork (Order Comms) (event 46806)
'31Jan01 CKJ Amended to allow confusing OrderComms messages to be rewritten in patmed.ini    (#49541)
'08Mar01 SF/CFY mod added based on the original TH mod to allow pyxis to continue as before
'09Apr01 CKJ Suppress the "Supply done or in progress" message, and set the item back to 'not in progress' if
'            User is a prescriber, issue type is "D" and terminal.ini SuppressSupplyDoneMsg="Y" (or T/1/-1)         (#50977)
'14jun01 ckj Suppress message via terminal.ini; SuppressOCAllocatePigeonholeMsg="Y"
'24Sep01 CKJ Added option to suppress Supply Done messages for more label types than just "D"
'             Terminal.ini[<TerminalID>]SuppressSupplyDoneMsgTypes="IODL"   'list label types for which suppression is wanted
'             Note that this takes precedence over the existing Terminal.ini[<TerminalID>]SuppressSupplyDoneMsg="Y"
'             and is executed first. If no matching label type is found then the old setting is looked up.
'05Mar02 ATW Amended to maintain new WLabel.BasePrescriptionID
'09Apr02 TH/ATW Added Fencepost to prevent put when >50 current meds and recno = 0
'25Mar03 TH (PBSv4) Added fencepost for PBS so that Last Issued Qty is not always recorded here.
'06May10 AJK F0073627 Added logging for Off Route product selection
'25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'16Aug13 TH Added call to SetNewFastRepeat to record a searchable number (TFS 70134) DoC

Dim msg As String, medtype As String
''Dim MakeTheEvent%
Dim X%, Col%, temp$, temp1$
Dim valid%
Dim response%, ExitLoop%
Dim logItemsSaved%
Dim blnPyxisEvent As Integer
Dim chkd As Integer, ans$, converter!
Dim Item$
Dim sglQty As Single '22May08 TH Ported
Dim blnNewDispensing As Boolean '06May10 AJK F0073627 Added
Dim strOffRoute As String '06May10 AJK F0073627 Added

'24Jul12 TH Label Auditing enhancement (TFS 39623)
Dim strLabelTextOld As String
Dim strLabelInsCodeOld As String
Dim strLabelWarCodeOld As String
Dim strLabelIssTypeOld As String
Dim strParams As String
Dim lngOK As Long
Dim strNewText As String
Dim strNewWarning As String
Dim strNewInstruction As String
'24Jul12 TH ---------

   '!!** error handler required
   
   logItemsSaved = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "LogMakeEvent", 0))
''   MakeTheEvent = False
   
   '11May00 SF added logging to try and find lost Pyxis events but may be used for any TeamWork setup
   If logItemsSaved Then
         WriteLog dispdata$ & "\tmwrk.log", 0, "", "--------------------"
         WriteLog dispdata$ & "\tmwrk.log", 0, "", "MakeEvent Log ('" & txtUC("txtPrompt").text & "' pressed): PID.recno=" & trimz(pid.recno) & ", Case#=" & Trim$(pid.caseno) & ", NSV=" & L.SisCode
      End If
   
   CheckRxComplete success
   If success Then
         Authorise chkd
         
         If Not chkd Then
            popmessagecr "!EMIS Health", "The label is not complete and has NOT been saved"  '01Jun00 MMA/CFY added (event no.44104)
            Exit Sub   '<------------------ WAY OUT
         End If
         
         '13May97 KR Added - need to create label if in prescriber view as normal label never shown.
         If passlvl = 3 Then
               WDir.directs = txtUC("txtDirections").text  'needed for createlabel
               If Not reusedLabel% Then createlabel 1, 0
               memorytolabel
            End If
            
''09May05 old style Automation not supported
''         If automation$ <> "" And ((Mid$(acclevels$, 1, 1) = "8" Or Mid$(acclevels$, 1, 1) = "3")) Then
''               eventinifile = dispdata$ & "\" & automation$
''               buttondef
''
''               If patmedaction = "S" Then
''                     If L.needednexttime <> "A" Then
''                           L.needednexttime = "A"
''                           If UCase$(UsePigeon$) = "Y" Then
''                                 ExitLoop% = False
''                                 Do
''                                    Hole% = 0         'reset hole as always with same hole while in patmed
''                                                      'except in change patient within patmed!
''                                    '22Jun96 ASC/KR Move from Makeevent so that we ca know the labf once makeevent
''                                    'is called
''                                    'Need to check whether patient or ward dispensing & Allocate Pigeonhole
''                                    msg = "Allocate pigeonhole by individual patient?" & crlf
''                                    msg = msg & "(Choose NO to allocate by ward," & crlf
''                                    msg = msg & "or CANCEL to bypass Teamwork.)"
''
''                                    'medtype = txtD(eventinifile, "DispenseType", "", (l.isstype), found%)
''                                    '22Jun96 ASC changed to confirm from message box and allowed escape and always ask question with correct default
''                                    If medtype = "W" Then ans$ = "N" Else ans$ = "Y"
''
''                                    '14jun01 ckj suppress message based on terminal name
''                                    k.escd = False
''                                    If TrueFalse(terminal("SuppressOCAllocatePigeonholeMsg", "N")) Then
''                                          msg$ = txtd(dispdata$ & "\patmed.ini", "Messages", msg$, "MsgOCAllocatePigeonhole", 0)
''                                          ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0
''                                          Confirm "Patient/Ward Based Dispensing", msg, ans$, k
''                                       End If
''
''                                    If ans$ = "Y" Then medtype = "P" Else medtype = "W"
''                                    If Not k.escd Then
''                                          MakeTheEvent = ValidTeamWorkRx(L)
''                                          ExitLoop% = True
''                                       Else                                                                                '17Nov98 CFY Added
''                                          msg$ = "You are about to bypass Order Comms, therefore" & crlf                      '       "
''                                          msg$ = msg$ & "this item will not be added to the Order Comms queue. " & crlf       '       "
''                                          msg$ = msg$ & "Are you sure you want to do this ?"                               '       "
''
''                                          msg$ = txtd(dispdata$ & "\patmed.ini", "Messages", msg$, "MsgOCBypassOrderComms", 0)    '31Jan01 CKJ Added to allow message to be rewritten
''                                          ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0
''
''                                          response% = MessageBox(msg$, 4 + MB_ICONQUESTION, "ASCribe")                     '       "
''                                          If response% = IDYES Then                                                        '       "
''                                          MakeTheEvent = False
''                                          L.needednexttime = ""
''                                          ExitLoop% = True
''                                       End If
''                                 End If
''                                 Loop Until ExitLoop% '17Nov98 CFY Added
''                              Else
''                                 'bypass pigeonhole allocation
''                                 Hole% = 0
''                                 MakeTheEvent = ValidTeamWorkRx(L)
''                                 'what else should happen here? !!**
''                              End If
''                        Else
''                           '18Feb97 KR Prompt user to change label  back to overide teamwork.
''                           k.escd = False
''
''                           '08Mar01 SF/CFY added based on the original TH mod to allow pyxis to continue as before
''                           'If l.IssType <> "W" Then      '11Sep00 JN Added to prevent asking for WardStock Items
''                           blnPyxisEvent = PyxisSetup()
''                           If blnPyxisEvent Then blnPyxisEvent = OnPyxisWard(pid.ward)
''                           If (blnPyxisEvent) Or ((Not blnPyxisEvent) And (L.IssType <> "W")) Then
''                                 If passlvl = 3 And InStr(UCase$(terminal("SuppressSupplyDoneMsgTypes", "")), L.IssType) > 0 Then     '24Sep01 CKJ Added block
''                                       L.needednexttime = ""
''                                    ElseIf passlvl = 3 And L.IssType = "D" And TrueFalse(terminal("SuppressSupplyDoneMsg", "N")) Then '09Apr01 CKJ Added block
''                                       L.needednexttime = ""
''                                    Else
''                                       '08Mar01 SF/CFY -----
''                                       '31Jan01 CKJ Amended to allow message to be rewritten
''                                       msg$ = "This item has been marked as an Order Comms item and it" & crlf & "is either completed or in progress." & crlf & "Do you wish to reset it so that" & crlf & "it can be reprinted (resetting will overide Order Comms)?"
''                                       msg$ = txtd(dispdata$ & "\patmed.ini", "Messages", msg$, "MsgOCMarkedAsOrderComms", 0)  '31Jan01 CKJ Added to allow message to be rewritten
''                                       ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0
''                                       askwin "Supply done or in progress", msg$, ans$, k
''
''                                       If ans$ = "Y" And Not k.escd Then
''                                             L.needednexttime = ""
''                                          End If
''                                    End If                                                                                     '09Apr01 CKJ Added
''                              End If
''                        End If
''                  End If
''            End If

         If Not k.escd Then
               If g_blnPSO Then Qty! = 0
               parsedate LastSavedDateTimeToLastDate(L.lastSavedDateTime), temp$, "3", valid ' 40210 XN 15Feb13 use proper date\time for WLabel    parsedate (L.lastdate), temp$, "3", valid
               If Not PBSKeepDate() Then        '25Mar03 TH Added (PBSv4)
                     If Not valid Or temp$ <> thedate(False, True) Then
                        If blnFromTxtPromptKeyUp And Qty! <> 0 And L.IssType = "C" And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "Y", "DoseQtyOnPMR", 0)) Then  '22Sep05 TH '17Nov05 TH Added extra checks
                           sglQty = getm_sgnCivasDose()                         '22Sep05 TH '22May08 TH Ported from v8
                           L.lastqty = sglQty                                   '22Sep05 TH
                        Else                                                    '22Sep05 TH
                           L.lastqty = Qty!
                        End If
                     Else
                        If blnFromTxtPromptKeyUp And Qty! <> 0 And L.IssType = "C" And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "Y", "DoseQtyOnPMR", 0)) Then  '22Sep05 TH '17Nov05 TH Added extra checks
                           sglQty = getm_sgnCivasDose()                           '22Sep05 TH
                           L.lastqty = dp!(L.lastqty + sglQty)                    '22Sep05 TH
                        Else                                                      '22Sep05 TH
                           L.lastqty = dp!(L.lastqty + Qty!) '25Aug93 added dp! ASC
                        End If                                                    '22Sep05 TH
                     End If                  '25Mar03 TH Added (PBSv4)

                  End If
               L.Nodissued = L.Nodissued + Qty!
               'If d.dosesperissueunit > 1 Then     '25Jun10 CKJ Changed to handle fractional dosesperissueunit eg 0.25 mg per tablet  (RCN P0158 F0088216)
               If d.dosesperissueunit > 0 Then      '   "
                     converter! = d.dosesperissueunit
                     L.RxNodIssued = L.RxNodIssued + (Qty! * converter!)
                  Else
                     L.RxNodIssued = L.RxNodIssued + Qty!
                  End If
            
               If Qty! > 0 Then    ' some issued
                     If chkUC("chkPIL").Visible Then chkUC("chkPIL").Value = 1
                  End If
               Qty! = 0
            
            temp$ = ""
            'For X = 1 To 5   '14May14 TH Replaced with below
            If L.extralabel Then
               For X = 1 To 11 '08Aug14 TH (TFS 97519)
                  Col = StoredColour((frmExtraLabel.TxtLabel(X).ForeColor))  '!**
                  temp1$ = labelline$(X) 'Added ExtraLabel switch
                  temp1$ = LTrim$(RTrim$(temp1$))
                  If temp1$ = "" Then temp1$ = " "
                  
                  If Col > 0 Then
                        temp$ = temp$ + LTrim$(Str$(Col)) + "!" + temp1$ + Chr$(LBL_END_LINE)
                     Else
                        If X = DescriptionSplitLine() Then                           '16Feb00 AE  Replace normal EOL char with End of Direction
                              temp$ = temp$ + temp1$ + Chr$(LBL_END_DESC)                '            marker if appropriate.
                           Else
                              temp$ = temp$ + temp1$ + Chr$(LBL_END_LINE)
                           End If
                     End If
               Next
            Else
               For X = 1 To 5
                  Col = StoredColour((txtUC("txtLabel", X).ForeColor))  '!**
                  temp1$ = txtUC("txtLabel", X).text
                  temp1$ = LTrim$(RTrim$(temp1$))
                  If temp1$ = "" Then temp1$ = " "
                  
                  If Col > 0 Then
                        temp$ = temp$ + LTrim$(Str$(Col)) + "!" + temp1$ + Chr$(LBL_END_LINE)
                     Else
                        If X = DescriptionSplitLine() Then                           '16Feb00 AE  Replace normal EOL char with End of Direction
                              temp$ = temp$ + temp1$ + Chr$(LBL_END_DESC)                '            marker if appropriate.
                           Else
                              temp$ = temp$ + temp1$ + Chr$(LBL_END_LINE)
                           End If
                     End If
               Next
            End If
            L.text = temp$
                        
            L.dispid = UserID$

            '12Jun97 KR Added
            '05Mar02 ATW Augmented to support a persistent BasePrescriptionID - this number will be the same for all
            '              Prescription rows derived from an orginal - this eases tracing of the history of the scrip
            '              and helps clients of exporting interfaces stay sane by allowing them to amend prescriptions too....
            If L.PrescriptionID = 0 Then
               GetPointerSQL patdatapath$ & "\RxID.dat", L.PrescriptionID, True
               If L.BasePrescriptionID = 0 Then
                  L.BasePrescriptionID = L.PrescriptionID
               End If
               
               '16Aug13 TH Added to record a searchable number (TFS 70134) DoC
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StorePharmacyRxIDasFastRepeat", 0)) Then
                  temp$ = SetNewFastRepeat(Format$(L.PrescriptionID))
               'ElseIf TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CreatePharmacyFastRepeat", 0)) Then
               'This isnt really useful yet until Wlabel type is extended to include this
               End If
               
            End If
            
''            '06Mar00 SF added for Pyxis interface
''            If PyxisSetup() Then
''                  If (L.IssType = "W") And (OnPyxisWard(pid.ward)) Then
''                        CheckPyxisItem (L.SisCode)    ' set/clear Pyxis item bit where appropriate
''                     Else
''                        L.PyxisItem = False
''                     End If
''               Else
''                  L.PyxisItem = False
''               End If
            
''            If PresentLabel&() > 0 Then
''                  Labf& = PresentLabel&()
''               Else
''                  GetANewLabel     'find slot for the label & save it
''                  If Labf& = 0 Then '12May95 ASC more than 50 labels
''                        Labf& = PresentLabel&()
''                     Else
''                        MakePMRLine Item$
''                        AddaRow Item$
''
''                        putpmr pmrptr&, (pid.recno)
''                     End If
''               End If
''
''            If Labf& <> 0 Then     '09Apr02 TH/ATW Added Fencepost to prevent put when >50 current meds and recno = 0
''                  Putlabel  ' 06Mar02 ATW/TH  Moved here from i) If clause above and ii) GetANewLabel
''               End If

            
            
            '06May10 AJK F0073627 Check to see if this is a new dispensing before PutLabel populates the RequestID
            If L.RequestID > 0 Then
               blnNewDispensing = False
            Else
               blnNewDispensing = True
            End If
            Putlabel L         '09May05 CKJ Does not have 50 limit
            
            '06May10 AJK F0073627 Log save as off route if the heap switch is set and it is the first save
            Heap 11, gPRNheapID, "sOffRouteProductSelected", strOffRoute, 0
            If TrueFalse(strOffRoute) And blnNewDispensing Then
               WriteLogSQL L.RequestID, "OffRouteProductSelected", 0, CDbl(L.RequestID)
            End If
            
            '27Jul12 TH Label Auditing enhancement (TFS 39623)
            If m_blnAttemptedlabelEdit Then
               '23Jul12 TH If this flag is set we need to do a comparison and record any relevant changes
               'getlabel L.RequestID, ComparisonLabel, 0
               If ComparisonLabel.text <> L.text Then strLabelTextOld = ComparisonLabel.text
               If ComparisonLabel.RevisedWarning <> L.RevisedWarning Then
                  If Trim$(ComparisonLabel.RevisedWarning) = "" Then
                     strLabelWarCodeOld = d.warcode '??(warcode 2)
                  Else
                     strLabelWarCodeOld = ComparisonLabel.RevisedWarning
                  End If
               End If
               If ComparisonLabel.RevisedInstruction <> L.RevisedInstruction Then
                  If Trim$(ComparisonLabel.RevisedInstruction) = "" Then
                     strLabelInsCodeOld = d.inscode
                  Else
                     strLabelInsCodeOld = ComparisonLabel.RevisedInstruction
                  End If
               End If
               If ComparisonLabel.IssType <> L.IssType Then strLabelIssTypeOld = ComparisonLabel.IssType
               If (Len(strLabelTextOld) > 0) Or (Len(strLabelWarCodeOld) > 0) Or (Len(strLabelInsCodeOld) > 0) Or (Len(strLabelIssTypeOld) > 0) Then
                  'save the changes
                  strNewText = L.text
                  strNewWarning = L.RevisedWarning
                  strNewInstruction = L.RevisedInstruction
                  plingparse strNewText, Chr(30)
                  plingparse strLabelTextOld, Chr(30)
                  plingparse strNewWarning, Chr$(161)
                  plingparse strNewInstruction, Chr$(161)
                  plingparse strNewText, Chr(31)
                  plingparse strLabelTextOld, Chr(31)
                  strParams = gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, L.RequestID) & _
                              gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                              gTransport.CreateInputParameterXML("UserID", trnDataTypeVarChar, 7, UserID$) & _
                              gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 7, gEntityID_User) & _
                              gTransport.CreateInputParameterXML("NewText", trnDataTypeVarChar, 255, IIf(strLabelTextOld = "", Null, strNewText)) & _
                              gTransport.CreateInputParameterXML("OldText", trnDataTypeVarChar, 255, IIf(strLabelTextOld = "", Null, strLabelTextOld)) & _
                              gTransport.CreateInputParameterXML("NewWarCode", trnDataTypeVarChar, 12, IIf(strLabelWarCodeOld = "", Null, strNewWarning)) & _
                              gTransport.CreateInputParameterXML("OldWarCode", trnDataTypeVarChar, 12, IIf(strLabelWarCodeOld = "", Null, strLabelWarCodeOld)) & _
                              gTransport.CreateInputParameterXML("NewInsCode", trnDataTypeVarChar, 12, IIf(strLabelInsCodeOld = "", Null, strNewInstruction)) & _
                              gTransport.CreateInputParameterXML("OldInsCode", trnDataTypeVarChar, 12, IIf(strLabelInsCodeOld = "", Null, strLabelInsCodeOld)) & _
                              gTransport.CreateInputParameterXML("NewIssType", trnDataTypeVarChar, 1, IIf(strLabelIssTypeOld = "", Null, L.IssType)) & _
                              gTransport.CreateInputParameterXML("OldIssType", trnDataTypeVarChar, 1, IIf(strLabelIssTypeOld = "", Null, strLabelIssTypeOld))
                              
                  'lngOK = gTransport.ExecuteInsertSP(g_SessionID, "WLabelAudit", strParams)
                  lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWlabelAuditInsertfromDispensing", strParams)
               End If
               m_blnAttemptedlabelEdit = False
               
            End If
            '27Jul12 TH Label Auditing enhancement (TFS 39622) End
            
            
            Labf& = L.RequestID                             '!!** temp
            lblUC("DoAction").Caption = "RefreshView-Save"       'clunky but works
            
            '11May00 SF added logging to try and find lost Pyxis events but may be used for any TeamWork setup
''            If logItemsSaved Then WriteLog dispdata$ & "\tmwrk.log", 0, "", "MakeEvent Log ('" & txtUC("txtPrompt").Text & "' pressed): PID.recno=" & trimz(pid.recno) & ", Case#=" & Trim$(pid.caseno) & ", Labf&=" & Format$(Labf&) & ", NSV=" & L.SisCode & ", MakeTheEvent%=" & Format$(MakeTheEvent)
               
''            'Teamwork Debuginfo
''            If InStr(Command$, "/debug") Then
''                  msg = "Dir:        " & TB & CurDir$ & crlf
''                  msg = msg & "Ini File:   " & TB & eventinifile & crlf
''                  msg = msg & "MakeEvent:  " & TB & Str$(MakeTheEvent) & crlf
''                  msg = msg & "Database:   " & TB & eventsFile & crlf
''                  msg = msg & "Table:      " & TB & EventsTable & crlf & crlf
''                  popmessagecr "Order Comms Debug Info", msg
''               End If
            
''               If MakeTheEvent Then
''                  '29Jul96 ASc **!! should not be needed
''                  d.SisCode = L.SisCode
''                  getdrug d, 0, 0, False
''
''                  '20Mar00 SF only send a Pyxis event to TeamWork if a valid Pyxis ward
''                  If PyxisSetup() Then
''                        ' create the event otherwise warn user not a Pyxis ward
''                        If OnPyxisWard(pid.ward) Then
''**!!** Pyxis not supported in V93                              makeevent Labf&, "", pid, d, k, medtype, L.IssType
''                           Else
''                              popmessagecr "#ASCribe", "The ward '" & Trim$(pid.ward) & "' is not defined as a Pyxis ward." & cr & "A TeamWork event will not be created."
''                           End If
''                     Else
''                        ' do as before
''**!!** Pyxis not supported in V93                        makeevent Labf&, "", pid, d, k, medtype, L.IssType   '20Mar00 SF moved statement into ELSE block
''                     End If
''               End If
''
''            updatePMRline '02Dec96
              LabelAmended = False
''            Dispens.TGLabelList.RefreshRow = Dispens.TGLabelList.RowIndex
         End If
      Else                            '16Nov98 ASC
''         txtUC("txtDircode").SetFocus
         '11May00 SF added logging to try and find lost Pyxis events but may be used for any TeamWork setup
         If logItemsSaved Then WriteLog dispdata$ & "\tmwrk.log", 0, "", "MakeEvent Log ('" & txtUC("txtPrompt").text & "' pressed - *** failed ChkRxComplete): PID.recno=" & trimz(pid.recno) & ", Case#=" & Trim$(pid.caseno) & ", NSV=" & L.SisCode
      End If

   k.escd = False

End Sub


''Sub SelectRx(History%, issuetype$, pmrchanged%)
'''find valid labels in labrf&()
'''SHARED loaded  12MAR96 KRmoved to module level
'''18Jan96 EAC close RX.IDX index after use
'''06MAR96 EAC - remove FirstDisplay=TRUE - testing revealed not needed and seemed to cause spurious movement of highlight
'''03Apr97 KR  Put all expired labels to history.
'''            Added pmrchanged parameter.  Set if any labels marked for history.'
'''10May97 KR  Added check for labels > 50 to prevent subscript out of range error when including history in view.
'''20May97 KR  Added else statement with the > 50 check to deal with history items.
'''20Jan98 CFY Added code for handling the blister semaphore
'''22Jan98 CKJ Added l.stopdate>0 to prevent FF labels & TPN going to history
'''12Aug98 TH  Changed Condition code so that it will return correct matches
'''22Sep99 CFY Added AutoArchive flag so that auto archiving of prescriptions can be switched off.
'''02Dec99 TH  Merged from 8.1 :'18Oct99 TH  If badlabel detected in getlabel then refresh PMR
'''01Mar00 AE  Merged the rest of mod dated 18Nov99. Prevent out of string space errors by limiting the number of records read in.
'''02Aug00 MMA Added: Global update for Teamwork
'''10Jun02 TH  Added preselected sort order on start date (#enh1637)
'''01Aug02 TH  Mod to above to get asc and des the right way around
''
''Dim todaymins&
''Dim count&, toomany%, msg$
''Dim badlabel As Integer, X As Integer, tofind$, cont&, found&, Item$
''
''   ReDim LstRX$(0)
''
''   toomany = False
''   count& = 0
''
''   If Dispens.TGLabelList.Rows = 0 Then   '09Jun95 ASC
''         Blanklabel
''         txtUC("txtDrugCode").Text = ""
''         txtUC("TxtDircode").Text = ""
''      End If
''
''   '02Apr97 KR Clears the actual grid  - redim just clears the array.
''   'Therefore also blanklabel
''   Dispens.TGLabelList.Rows = 0
''   Dispens.TGLabelList.Refresh
''   Blanklabel
''   If Loaded Then
''         If History = False Then History = 1
''         initBlister                        '20Jan98 CFY Added
''         Do                                      '18Oct99 TH '02Dec99 TH Merged from 8.1
''            badlabel = 0
''             For X = 1 To 50                     ' look at labrf&() for 1 to 50
''                If labrf&(X) * History > 0 Then
''                      Labf& = labrf&(X) * History
''                      GoSub addalabel
''                   End If       ' in range 1 to 50, or 0 if invalid
''             Next
''            If badlabel Then
''                  ReDim LstRX$(0)
''                  Blanklabel
''                  Dispens.TGLabelList.Rows = 0
''                  Dispens.TGLabelList.Refresh
''               End If
''         Loop While badlabel
''
''         If History = True Then
''               Do
''                  tofind$ = pid.recno
''                  binarysearchidx tofind$, patdatapath$ + "\RX.idx", 1, cont&, found&
''                  If found& > 0 And UCase(Trim$(Left(tofind$, 10))) = UCase(Trim$(pid.recno)) Then
''                        Labf& = found&
''                        findfile$ = Right$(tofind$, 4)
''                        GoSub addalabel
''                        count = count + 1
''                        If count >= MAXHISTORYITEMS Then toomany = True
''                     End If
''               Loop While found& And Not toomany
''               binarysearchidx "", "", 0, 0, 0
''
''               If toomany Then
''                     msg$ = "This patient has too many prescriptions to display in " & crlf$
''                     msg$ = msg$ & "the PMR.  The most recent " & Format$(MAXHISTORYITEMS) & " items" & crlf$
''                     msg$ = msg$ & "will be shown." & crlf$ & crlf$
''                     popmessagecr "!Ascribe", msg$
''                  End If
''               '---
''            End If
''
''         Erase labelline$
''         '06MAR96 EAC - remove FirstDisplay=TRUE - testing revealed not needed and seemed to cause spurious movement of highlight
''         'Firstdisplay = true'Used to highlight default in TxtPromptGotFocus_
''         newstart = False
''      End If
''
''      '02Apr97 KR Added.  Fixes problem with truegrid not refreshing 1st row properly
''      If Dispens.TGLabelList.Rows > 0 Then
''            Dispens.TGLabelList.RefreshRow = 1
''            Select Case Trim$(UCase$(txtd(dispdata$ & "\patmed.ini", "", "", "PMRSortonStart", 0)))   '10Jun02 TH Added (#enh1637)
''               Case "D": sortPMR -8                                                                   '01Aug02 TH Replaced above - apparently these were the wrong way
''               Case "A": sortPMR 8                                                                    '    "      around, but I have always been a bit stupid about asc and des.
''               Case Else: sortPMR 0                                                                   'Original entry
''            End Select                                                                                '    "
''         Else
''            Blanklabel
''            txtUC("txtDrugCode").Text = ""
''            txtUC("TxtDircode").Text = ""
''            clearlabel L
''            Erase labelline$
''
''         End If
''
''Exit Sub
''
''addalabel:
''   Stop '**!!**
''
''   pmrchanged = False
''   getlabel False
''   'Delete items to history if expired and not already in history '03Apr97 KR
''   GetToday todaymins&
''   If X <= 50 Then      '10May97 KR added
''         If (labrf&(X) > 0) And (L.StopDate <= todaymins&) And (L.StopDate > 0) And AutoArchive Then                                                           '         "
''               L.StoppedBy = UserID$
''               L.deletedate = todaymins&
''               LSet r = L
''               PutRecordNL r, Labf&, labchan%, Len(L)
''               labrf&(X) = labrf&(X) * -1    'mark as history
''               pmrchanged = True
''            Else
''               If InStr(issuetype$, L.IssType) Then
''                     gintModified = 0
''                     gstrModDirCode = ""
''                     If (Asc(L.Flags) And &H40) = &H40 Then
''                           gintModified = 1
''                           gstrModDirCode = L.dircode
''                        End If
''
''                     MakePMRLine Item$
''                     AddaRow Item$
''                     If L.Blister > 0 Then IncBlister
''                  End If
''
''            End If
''      Else
''         If InStr(issuetype$, L.IssType) Then
''               MakePMRLine Item$
''               AddaRow Item$
''            End If
''      End If
''
''Return
''
''End Sub

''Sub SetAskSAUpdate(flag%)
''' Flag% should be boolean true or false
''' If flag = true then DoseFromMsq will ask if the dosing SA
''' should be updated with the calculated SA if the two values don't match
''
''   AskSAUpdate = flag%
''
''End Sub

Sub SetDispenseForm()
'16Aug12 TH Added casing around check to see which label types are allowed for this selection (TFS 40661)
'20Aug12 TH Missed inpatient in above change. Now done

Dim dateout$, timeout$

Dim ErrNumber As Long, ErrDescription As String
Dim intloop As Integer
Const ErrSource As String = "SetDispenseForm"

   On Error GoTo ErrorHandler
   
   For intloop = 0 To 9
      txtUC("TxtLabel", (intloop)).MousePointer = 0
      txtUC("TxtLabel", (intloop)).FontUnderline = False
   Next

   If cmbUC("CmbIssueType").ListCount = 0 Then
         'newtimeneeded = False                                   '01Jun02 All/CKJ ? Not in scope but perhaps should be
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "I") Or ((Not (InStr(UCase(m_LabelTypesPreventEdit), "I") > 0)) And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "I") > 0))) Then
            cmbUC("CmbIssueType").AddItem "In-Patient"
         End If
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "O") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "O") > 0)) And L.IssType <> "O" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "O") > 0)) Then cmbUC("CmbIssueType").AddItem "Out-Patient"
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "D") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "D") > 0)) And L.IssType <> "D" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "D") > 0)) Then cmbUC("CmbIssueType").AddItem "Discharge"
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "L") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "L") > 0)) And L.IssType <> "L" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "L") > 0)) Then cmbUC("CmbIssueType").AddItem "Leave"
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "W") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "W") > 0)) And L.IssType <> "W" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "W") > 0)) Then cmbUC("CmbIssueType").AddItem "Ward Stock"
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "C") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "C") > 0)) And L.IssType <> "C" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "C") > 0)) Then cmbUC("CmbIssueType").AddItem "CIVAS"                '27Oct06 TH Reinstated  '07NOv05 CKJ TEMPORARY REMOVAL UNTIL CIVAS ENABLED **!!**V93
         If (IIf(Trim$(L.IssType) = "", pid.status, L.IssType) = "S") Or (Not (InStr(UCase(m_LabelTypesPreventEdit), "S") > 0)) And L.IssType <> "S" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "S") > 0)) Then cmbUC("CmbIssueType").AddItem "Self Med."
''         cmbUC("CmbIssueType").AddItem "PN"                     '03NOv05 CKJ TEMPORARY REMOVAL UNTIL PN ENABLED **!!**V93
         
         SetDateAndTime dateout$, timeout$, False                 '25Oct00 CFY Added ForceRead Parameter
         
         txtUC("txtPrepDate").text = dateout$
         txtUC("txtPrepTime").text = timeout$
      End If

Cleanup:
'   On Error Resume Next
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription & crlf & "UserControl state =" & UserControlIsAlive
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Sub


Sub setforecolour(ByVal linnum As Integer, ByVal colr As Integer, ByVal blnExtraLabel As Boolean)
'if colr<>-1 then set to this colour and print line as this colour and add
'colr%! to beginning of line else find colour for line and print it

Dim Col As Long
Dim ScreenColour$, charschopped As Integer

   ScreenColour$ = terminal$("ScreenColour", "Y")

   If ScreenColour$ = "Y" Then
         If Mid$(labelline$(linnum), 2, 1) = "!" Then
               If colr = -1 Then
                  colr = Val(Left$(labelline$(linnum), 1))
               End If
               charschopped = 2
            Else
               If colr = -1 Then colr = 0
               charschopped = 0
            End If

         If colr > 0 Then
               labelline$(linnum) = LTrim$(Str$(colr)) & "!" & Right$(labelline$(linnum), Len(labelline$(linnum)) - charschopped)
               charschopped = 2
            End If
         
         Select Case colr
            Case 0: Col = Black
            Case 1: Col = Red
            Case 2: Col = Blue
            Case 3: Col = Magenta
            Case 4: Col = Yellow
            'Case 5: Col = Green
            Case 5: Col = &H8080FF        '09May05 was named as Green but should be Pink  '30May14 TH Added
            Case 6: Col = QBColor(2)      'Green
         End Select
         If blnExtraLabel Then
            frmExtraLabel.TxtLabel(linnum).ForeColor = Col
         Else
            txtUC("TxtLabel", linnum).ForeColor = Col
         End If
      Else
         If blnExtraLabel Then
            frmExtraLabel.TxtLabel(linnum).ForeColor = Black
         Else
            txtUC("TxtLabel", linnum).ForeColor = Black
         End If
      End If

End Sub

Sub SetIssueType(ByVal i_strIssueType As String)
'21May02 SF (#60132) added to populate type issue combo list depending on the given issue type
'           if no issue type passed in then list all issue types
'15Oct02 TH Added mod to ensure that on a new label the default is set to the pid status

Dim intCount As Integer

   On Error Resume Next

   ' clear list
   cmbUC("CmbIssueType").Clear
   
   If (InStr(m_LabelTypesPreventEdit, i_strIssueType) > 0) Or (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), i_strIssueType) > 0) Then ' in prohibited list then
      popmessagecr "EMIS Health", "You are not allowed to change this type of label"
      Exit Sub
   End If
   'CIVAS Clingfilm also ?
   
   
   ' populate list
'   If (i_strIssueType <> "P") Or (i_strIssueType = "") Then
'         cmbUC("CmbIssueType").AddItem "In-Patient"
'         cmbUC("CmbIssueType").AddItem "Out-Patient"
'         cmbUC("CmbIssueType").AddItem "Discharge"
'         cmbUC("CmbIssueType").AddItem "Leave"
'         cmbUC("CmbIssueType").AddItem "Ward Stock"
'''         cmbUC("CmbIssueType").AddItem "CIVAS"                  '07NOv05 CKJ TEMPORARY REMOVAL UNTIL CIVAS ENABLED **!!**V93
'         cmbUC("CmbIssueType").AddItem "Self Med."
'      End If
      
      If (i_strIssueType <> "P") Or (i_strIssueType = "") Then
         If (Not (InStr(m_LabelTypesPreventEdit, "I") > 0)) And L.IssType <> "I" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "I") > 0)) Then cmbUC("CmbIssueType").AddItem "In-Patient"
         If (Not (InStr(m_LabelTypesPreventEdit, "O") > 0)) And L.IssType <> "O" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "O") > 0)) Then cmbUC("CmbIssueType").AddItem "Out-Patient"
         If (Not (InStr(m_LabelTypesPreventEdit, "D") > 0)) And L.IssType <> "D" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "D") > 0)) Then cmbUC("CmbIssueType").AddItem "Discharge"
         If (Not (InStr(m_LabelTypesPreventEdit, "L") > 0)) And L.IssType <> "L" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "L") > 0)) Then cmbUC("CmbIssueType").AddItem "Leave"
         If (Not (InStr(m_LabelTypesPreventEdit, "W") > 0)) And L.IssType <> "W" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "W") > 0)) Then cmbUC("CmbIssueType").AddItem "Ward Stock"
''         cmbUC("CmbIssueType").AddItem "CIVAS"                  '07NOv05 CKJ TEMPORARY REMOVAL UNTIL CIVAS ENABLED **!!**V93
         If (Not (InStr(m_LabelTypesPreventEdit, "S") > 0)) And L.IssType <> "S" And (Not (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), "S") > 0)) Then cmbUC("CmbIssueType").AddItem "Self Med."
      End If

''03NOv05 CKJ TEMPORARY REMOVAL UNTIL PN ENABLED **!!**V93
''   If (i_strIssueType = "P") Or (i_strIssueType = "") Then
''         cmbUC("CmbIssueType").AddItem "PN"
''      End If
      
   ' highlight relevant issue type
   If i_strIssueType <> "" Then
         ' set to current issue type
         For intCount = 0 To cmbUC("CmbIssueType").ListCount - 1
            If i_strIssueType = Left$(cmbUC("CmbIssueType").List(intCount), 1) Then
                  cmbUC("CmbIssueType").ListIndex = intCount
                  Exit For
               End If
         Next
      Else
         If pid.status <> "" Then
               ' set to patient status as default issue type
               For intCount = 0 To cmbUC("CmbIssueType").ListCount - 1
                  If pid.status = Left$(cmbUC("CmbIssueType").List(intCount), 1) Then
                        cmbUC("CmbIssueType").ListIndex = intCount
                        Exit For
                     End If
               Next
            Else
               ' set to first item in the list
               cmbUC("CmbIssueType").ListIndex = 0
            End If
      End If

   On Error GoTo 0

End Sub

Sub SetRepeatCombo(Entry$)
'03Feb96 ASC made the CmdRepeat combo type 2 to stop editing

   With cmbUC("CmbRepeatUnits")
      If .ListCount = 0 Then
         .AddItem "day"
         .AddItem " wk"
      End If
   
      Entry$ = RTrim$(Entry$)
      Select Case LCase$(Trim$(Entry$))
         Case "day": .ListIndex = 0
         Case "wk":  .ListIndex = 1
      End Select
   End With

End Sub

Sub SetRxNodIssued()
'04Jun97 KR added.
'Used when the user wants to change the default amount to be issued in
'automatic dispensing.  In 7.5, could set the supplied field in the prescribing form.
'Now that prescribing form amalgamated, they can amend the Txtqtyprinted field,
'save the label (S) and rxnodissued gets amended accordingly e.g.
'  Assume 6 already issued and TxtTopUpQty = 3
'  TxtQtyPrinted would default to 3.  If they then changed it to 2 and saved the label,
'  rxnodissued would be set to 7
'     rxnodissued = rxnodissued + (topupqty - txtqtyprinted)
'         6       =      6      + (   3     -       2      )
'                 =      7

   Select Case L.IssType
      Case "I", "S", "W"
         If Val(txtUC("txtQtyPrinted").text) < Val(txtUC("TxtTopUpQty").text) And Val(txtUC("txtQtyPrinted").text) <> 0 Then
               L.RxNodIssued = L.RxNodIssued + (Val(txtUC("TxtTopUpQty").text) - Val(txtUC("txtQtyPrinted").text))
            End If
      End Select

End Sub


''Sub ShowClinSum(profileID%, FileName$, PrintFiles$())
'''Handle the Clinical summary form after it has been set up using BuildClinSum
'''Show the form, then build a text file from the data entered on the form
'''------------------------------------------------------------------------
'''19Jan00 AE  Merged code which was lost in the original merge
'''20Nov00 AE  Fixed faults with control indexes.  Code appears to have been lost
'''            somewhere along the line.
'''27Jun01 CKJ Added option: patmed.ini [] "InhibitClinicalSummaryScreen", default is "N"
'''            If set then it creates the file as normal but with no sections in it.
''
''Dim fil%
''Dim Title$, txt$, NumSections%, n%
''Dim Row%
''Dim L%, tmp$
''Dim Numfiles%, tempfile$, OK%
''Dim db As Database, sn As Snapshot, SQL$
''
'''Maximum number of characters which will be displayed on a single line.
'''This is guessed, since the font size is not known until the clinical summary is entered
'''onto the discharge letter.
'''Const MAX_CHARS_PER_LINE = 90
''Const TITLECOLWIDTH = 4000    'Sizes of columns in the clinical summary table
''Const TEXTCOLWIDTH = 15000
''
''   Numfiles = 0
''   Erase PrintFiles$
''   k.escd = False
''
''   If TrueFalse(txtd(dispdata$ & "\patmed.ini", "", "N", "InhibitClinicalSummaryScreen", 0)) = False Then '27Jun01 CKJ Added
''''         ClinSum.Show 1
''
''''         NumSections = Val(ClinSum.Tag)
''         If NumSections = 0 Then
''               k.escd = True
''''               Unload ClinSum
''               Exit Sub
''            End If
''      Else                                                                                                '27Jun01 CKJ
''         NumSections = 0
''      End If
''
''   'Add the default copies of the discharge letter to files()
''   Set db = OpenDatabase(dispdata$ & "\clinsum.mdb")
''   SQL$ = "SELECT * FROM Summarys WHERE ID = " & Format$(profileID)
''   Set sn = db.CreateSnapshot(SQL$)
''   txt$ = sn!DefaultCopies
''
''   Do
''      L = InStr(txt$, ",")
''      If L <> 0 Then
''            Numfiles = Numfiles + 1
''            ReDim Preserve PrintFiles(1 To Numfiles)
''            fil = Val(Mid$(txt$, 1, L - 1))
''            PrintFiles(Numfiles) = "Disch" & Format$(fil, "000") & ".rtf"
''            txt$ = Mid$(txt$, L + 1)
''         End If
''   Loop Until L = 0
''
''   'scrape the text and section titles from the form and save in a file
''
''   'make a blank file in rtf format
''   MakeLocalFile tempfile$
''   TextToRTF 1, tempfile$, "ShowClinSum"
''
''   'insert the table
''   HiTable 1, tempfile$, 1, 2, 0, OK
''   'Set the column sizes
''   HiTable 3, tempfile$, 0, 1, TITLECOLWIDTH, OK
''   HiTable 3, tempfile$, 0, 2, TEXTCOLWIDTH, OK
''
''   For n = 1 To NumSections
''''      If ClinCtrlType(n) <> "C" Then
''            If n > 1 Then HiTable 2, tempfile$, 0, 0, 1, OK 'Add 1 row to the table
''''                  Title$ = ClinSum.LblSection(n - 1).Caption
''''                  txt$ = ClinSum.TxtEntry(ClinCtrlIndex(n)).Text
''                  Row = Row + 1
''                  'Insert the text into the table
''                  HiTable 4, tempfile$, Row, 1, Title$, OK
''                  HiTable 4, tempfile$, Row, 2, txt$, OK
''''               Else
''''                  If ClinSum.Chk(ClinCtrlIndex(n)).Value = 1 Then
''                  Numfiles = Numfiles + 1
''                  ReDim Preserve PrintFiles$(1 To Numfiles)
''''                  PrintFiles$(Numfiles) = ClinSum.Chk(ClinCtrlIndex(n)).Tag
''''               End If
''''         End If
''   Next
''
''   HiTable 9, tempfile$, 0, 0, 0, OK
''   HiTable 0, "", 0, 0, 0, 0
''   FileCopy tempfile$, FileName$
''   Kill tempfile$
''
''''   Unload ClinSum
''
''End Sub

Sub ShowInfo()
'**!!** Not appropriate for 9.3?

Dim chan As Integer, Info$
Dim pathfile As String

   pathfile = dispdata$ & "\info\" & d.SisCode & ".txt"
   If fileexists(pathfile) Then
         chan = FreeFile
         Open pathfile For Input As chan
         Do
            Line Input #chan, Info$
            Editor.Txt1.text = Editor.Txt1.text + Info$ + crlf$
         Loop Until EOF(chan)
         Close chan
      Else
         MsgBox "No dosing information entered"
      End If

   Editor.Txt1.Tag = Editor.Txt1.text
   'Editor.lblTitle.Caption = "Dosing Information" '16MAR96 KR
   Editor.Caption = "Dosing Information"
   Editor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   If Editor.Txt1.Tag <> Editor.Txt1.text Then
         chan = FreeFile
         Open pathfile For Output As chan
         Print #chan, Editor.Txt1.text
         Close chan
      End If
   Unload Editor

End Sub

''Sub ShowPMRdebug()
'''22Jan98 CKJ List the PMR details for debugging
''Dim X%
''
''   LstBoxFrm.Caption = "PMR debug screen"
''   LstBoxFrm.lblTitle = cr & "PMR pointers for PMR Record" & Str$(pmrptr&) & cr
''   LstBoxFrm.lblHead = " Num" & TB & " Pointer     "
''
''   For X = 1 To 50
''      LstBoxFrm.LstBox.AddItem Str$(X) & TB & Str$(labrf&(X))
''   Next
''
''   LstBoxShow
''   Unload LstBoxFrm
''
''End Sub

Sub StopDateLostFocus(sDate$, valid)
'10Oct96 ASC moved from Prescrib.frm

Dim rightorder As Integer

   parsedate sDate$, sDate$, "1", valid
   
   If valid Then
         checkdateorder "", "", sDate$, "", rightorder
         If Not rightorder Then Beep
      End If

   If Not valid Then Beep

End Sub

Function StoredColour(ScreenColour As Long) As Integer
'17Mar96 KR Added RGB long colors for compatibility
'19Jan99 EAC Handle green that is used on screen label

   Select Case ScreenColour
      Case Black:    StoredColour = 0 '1
      Case Red:      StoredColour = 1 '2
      Case Blue:     StoredColour = 2 '3
      Case Magenta:  StoredColour = 3 '4
      Case Yellow:   StoredColour = 4 '5
      Case QBColor(2): StoredColour = 6   '30May14 TH Added
      Case Green:    StoredColour = 5 '6
      Case 32768:    StoredColour = 5        '19Jan99 EAC added
      Case Else:     StoredColour = 0
      End Select

End Function

Function strRound(ByVal strInput As String) As String
'Function to round number up or down. Note, it should be used with caution to handle negative numbers ('23/Oct00 CKJ/MMA)
'ajk 20/09/2000
'23/Oct00 CKJ/MMA added to replace spaces
'22Jan01 JN added extra checks to ensure value passed in through strInput are in the format "0.xxxx", instead of ".xxxx"

Dim intLen As Integer
Dim intCount As Integer
Dim strOutput As String

    'Initialize variables
    If Left$(strInput, 1) = "." Then           '22Jan01 JN Added check for no leading zero
         strInput = "0" & strInput
      End If
    replace strInput, "-.", "-0.", 0           '22Jan01 JN Added check here
    replace strInput, " .", "0.", 0            '23/Oct00 CKJ/MMA added
    strRound = strInput
    strOutput = strInput
    intLen = Len(strInput)

    'Error Check
    If intLen = 0 Then
        Exit Function
    End If
    
    'Error Check
    If IsNumeric(strInput) = False Then
        Exit Function
    End If

    'Find the dot
    For intCount = 1 To intLen

        If Mid$(strInput, intCount, 1) = "." Then
           If CLng(Mid$(strInput, intCount + 1, 1)) >= 5 Then
                strOutput = CStr(CLng(Left$(strInput, intCount - 1)) + 1)
                'strOutput = CStr(Val(Left(strInput, intCount - 1)) + 1)
                Exit For
           Else
                strOutput = Left$(strInput, intCount - 1)
                Exit For
           End If
        End If
    Next

    If strOutput = "" Then
        strOutput = "0"
    End If

    strRound = strOutput
    
End Function

Sub TxtDircodeChange(TxtDirCodePar$, highlight%, PutDirToForm%)
'30Jul95 ASC If a "," is used the CR is inhibited
'02Feb98 ASC removed add as comma as not used any more
'18Mar02 TH Removed comma as seperator in directions (#59667)

Static LastLen%

   If LastLen + 1 = Len(TxtDirCodePar$) Then  '27Mar95
         Select Case Right$(TxtDirCodePar$, 1)
            Case "/", " ", "\"               '18Mar02 TH Removed comma as seperator (#59667)
               LastLen = Len(TxtDirCodePar$)
               AddDirection TxtDirCodePar$, highlight%, PutDirToForm%, (pid.ward)
            End Select
      End If
   LastLen = Len(TxtDirCodePar$)

End Sub

''Sub updatePMRline()
'''02Dec96
''
''Dim Item$, Rowinedit As Integer
''
''   If PresentLabel&() <> 0 Then
''         MakePMRLine Item$
''         Rowinedit = Dispens.TGLabelList.RowIndex
''         LstRX$(Rowinedit) = Item$
''         Dispens.TGLabelList.RefreshRow = Dispens.TGLabelList.RowIndex
''         memorytolabel
''      End If
''
''End Sub

Sub WarningCaption(Warning$)
'28May ASC Stop flashing warnings on prescribing screen

''   If warning$ <> lblUC("LblWarning").Caption Then
''         If warning$ <> String$(29, Chr$(32)) Then
''               lblUC("LblWarning").ForeColor = Red  'red
''            Else
''               lblUC("LblWarning").ForeColor = 0  'black
''               lblUC("LblQtyDesc").ForeColor = 0
''            End If
''         lblUC("LblWarning").Caption = warning$
''      End If

   If Len(Warning$) Then
      lblUC("LblWarning").ForeColor = Red  'red
   Else
      lblUC("LblWarning").ForeColor = 0  'black
   End If
   lblUC("LblWarning").Caption = Warning$

End Sub

Sub BlnkPrescribFrm(civas)
'10Oct96 ASC
'11Jun97 KR Added resetting of descriptive labels.
'02May00 EAC reset daysdefined% if blanking directions
'19Jan01 CKJ clear RxOffset
'09May05 CKJ

Dim X%

   StopEvents = True
      
   For X = 1 To 6
      txtUC("TxtDose", X).text = ""
      txtUC("TxtTime", X).text = ""
   Next
   cmbUC("CmbRoute").ListIndex = -1
   txtUC("TxtDirections").text = ""
   'TxtEqualInterval.text = ""
   'CmbTimeUnits.Text = "" 10Oct96
   'CmbRepeatUnits.text = ""
   'TxtRepeatInterval.text = ""
   txtUC("TxtDircode").text = ""
   txtUC("TxtNodPrescribed").text = ""
   If civas Then
''         TxtReconVol.Text = ""
''         CmbReconAbbr.Text = ""
''         CmbDiluentAbbr.Text = ""
''         CmbContainer.Text = ""
         txtUC("TxtFinalVol").text = ""
''         TxtContainerSize.Text = ""
         txtUC("TxtInfusionTime").text = ""
         lblUC("LblInfusionRate").Caption = ""
      End If

   fraUC("FraDays").Visible = False
   
   lblUC("LblPrintForm").Caption = ""
   'lblUC("LblQtyDesc").Caption = "&Qty:"
   SetLblQtyDescCaption ""
   lblUC("LblSupply").Caption = ""
   
   daysdefined = False
   RxOffset& = 0
   
   StopEvents = False

End Sub

Sub SetLblQtyDescCaption(ByVal strIssType As String)
'09May05

Dim temp As String

   Select Case L.IssType
      Case "I":  temp = "Inpatient"
      Case "O":  temp = "Outpatient"
      Case "D":  temp = "Discharge"
      Case "S":  temp = "Self-Med"
      Case "P":  temp = ""
      Case "L":  temp = "Leave"
      Case "M":  temp = "Manuf."
      Case "W":  temp = "Stock"
      Case "C":  temp = "Civas"
      Case Else: temp = ""
      End Select
   lblUC("LblQtyDesc").Caption = temp & " Qty:"
            
End Sub

Sub SetLblNameCaption()
'09May05

   lblUC("LblName").Caption = " Rx: " & L.PrescriberID & "   Chk: " & L.PharmacistID & "   Disp: " & L.dispid
   
End Sub

Sub SetFromTxtPromptKeyUp()
'17Nov05 TH Writtenv'22May08 TH Ported from v8
   blnFromTxtPromptKeyUp = True
End Sub
Sub ClearFromTxtPromptKeyUp()
'17Nov05 TH Written '22May08 TH Ported from v8
   blnFromTxtPromptKeyUp = False
End Sub
Function CIVASCheck(ByVal blnReturn As Boolean) As Boolean
'06Jun08 TH Written - largely for CIVAS returns
'25Nov15 XN Removed sort and moved to so web service works 134997

Dim strAns As String
Dim sglQty As Single
Dim rsBatchStock As ADODB.Recordset
Dim strDesc As String
Dim strParams As String
Dim dlocal As DrugParameters
Dim X As Integer
Dim blnNonCIVASIssue As Boolean
Dim strBatch As String

   blnNonCIVASIssue = False
   
   If L.SisCode <> "" Then
      dlocal.SisCode = L.SisCode
      getdrug dlocal, 0, 0, False
      'If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "CIVASIssueBatchCheck", 0)) Then
         '28May08 TH CIVAS RETURNS; here we see if we have any batch qty. If so we offer the user
         '           the option to issue this directly rather than remake a new batch
         strAns = "N"
         If Val(dlocal.stocklvl) > 0 Then
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, dlocal.SisCode)
            Set rsBatchStock = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLevelbySiteandNSVCode", strParams)
            sglQty = 0
            If rsBatchStock.RecordCount > 0 Then
               'rsBatchStock.Sort = "Expiry desc"    XN 25Nov15 134997 do sorting in SP for when using web transport layer
               strBatch = "Batch Number" & Space$(14) & TB & "Qty" & Space$(3) & TB & "Expriy"
               Do While Not rsBatchStock.EOF
                  sglQty = sglQty + rsBatchStock!Qty
                  strBatch = strBatch & crlf & pad$(rsBatchStock!batchnumber, 25) & TB & pad$(Format$(rsBatchStock!Qty), 6) & TB & rsBatchStock!expiry
                  rsBatchStock.MoveNext
               Loop
            End If
            
            If sglQty > 0 Then
               'strDesc = dlocal.storesdescription
               'If Trim$(strDesc) = "" Then strDesc = dlocal.Description   XN 4Jun15 98073 New local stores description
                           strDesc = dlocal.DrugDescription
               plingparse strDesc, "!"
               strDesc = strDesc & crlf & crlf & "Current Stock Level : " & Trim$(dlocal.stocklvl) & " " & dlocal.PrintformV & crlf & "Batch Stock Level : " & Format$(sglQty) & crlf
               strDesc = strDesc & crlf & strBatch
               strDesc = strDesc & crlf & crlf & "Do you wish to use this existing stock instead of a new manufacturing " & Iff(blnReturn, "return.", "issue.")
               askwin "CIVAS Product", strDesc, strAns, k
            End If
         End If
         If strAns = "Y" Then
            L.IssType = pid.status
            blnNonCIVASIssue = True
         Else
            L.IssType = "C"
         End If
      'Else
      '   L.IssType = "C"
      'End If

      For X = 0 To cmbUC("CmbIssueType").ListCount - 1
         If L.IssType = Left$(cmbUC("CmbIssueType").List(X), 1) Then
            cmbUC("CmbIssueType").ListIndex = X
            Exit For
         End If
      Next
      

      'If (L.IssType <> temp$) And Not blnNewlbl Then
      '   LabelAmended = True
      'End If

      '16Jun05 TH Added block
      If UCase$(Left$(cmbUC("CmbIssueType").text, 1)) = "C" Then
         txtUC("TxtQtyPrinted").Visible = False
         lblUC("LblQtyDesc").Visible = False
      Else
         txtUC("TxtQtyPrinted").Visible = True
         lblUC("LblQtyDesc").Visible = True
      End If

   End If
   
   CIVASCheck = blnNonCIVASIssue
End Function

Sub SetAttemptedlabelEdit(ByVal blnAttemptedlabelEdit As Boolean)
'27Jul12 TH Label Auditing enhancement (TFS 39622)

Dim strTemp As String
Dim strTemp1 As String
Dim X As Integer
Dim Col As Long

   'If Not blnAttemptedlabelEdit Then
   '   ComparisonLabel.text = ""
   'Else
   If blnAttemptedlabelEdit And (Not m_blnAttemptedlabelEdit) Then
      strTemp = ""
      For X = 1 To 5
         Col = StoredColour((txtUC("txtLabel", X).ForeColor))  '!**
         
         strTemp1 = txtUC("txtLabel", X).text
         
         strTemp1 = LTrim$(RTrim$(strTemp1))
         If strTemp1 = "" Then strTemp1 = " "
         
         If Col > 0 Then
               strTemp = strTemp + LTrim$(Str$(Col)) + "!" + strTemp1 + Chr$(LBL_END_LINE)
            Else
               If X = DescriptionSplitLine() Then                           '16Feb00 AE  Replace normal EOL char with End of Direction
                     strTemp = strTemp + strTemp1 + Chr$(LBL_END_DESC)                '            marker if appropriate.
                  Else
                     strTemp = strTemp + strTemp1 + Chr$(LBL_END_LINE)
                  End If
            End If
      Next
      'L.text = temp$
      LSet ComparisonLabel = L
      ComparisonLabel.text = strTemp
      
   End If
   m_blnAttemptedlabelEdit = blnAttemptedlabelEdit
   
End Sub

Function GetAttemptedlabelEdit() As Boolean
'27Jul12 TH Label Auditing enhancement (TFS 39622)

   GetAttemptedlabelEdit = m_blnAttemptedlabelEdit
   
End Function
Sub SetLabelTypesPreventEdit(ByVal strLabelTypesPreventEdit As String)
'27Jul12 TH Label Auditing enhancement (TFS 39622)
'14Apr15 TH Strip C Type labels and warn here (TFS 110013)

   If InStr(strLabelTypesPreventEdit, "C") > 0 Then
      popmessagecr "!", "Desktop Incorrectly Configured. CIVAS Label type should not be included as a preventable label edit type"
      strLabelTypesPreventEdit = UCase$(strLabelTypesPreventEdit)
      replace strLabelTypesPreventEdit, "C", "", 0
   End If
   m_LabelTypesPreventEdit = strLabelTypesPreventEdit
   
End Sub

Function GetLabelTypesPreventEdit() As String
'27Jul12 TH Label Auditing enhancement (TFS 39622)
'09Aug12 TH Added Ucase on incoming params (TFS 40661)

   GetLabelTypesPreventEdit = UCase(m_LabelTypesPreventEdit)
   
End Function

Sub setRepeatNumber(ByVal intRepeatNumber As Integer)
'16Aug13 TH Added (TFS 70134)

   m_intRepeatNumber = intRepeatNumber
   Heap 10, gPRNheapID, "RptNum", Format$(intRepeatNumber), 0

End Sub

Function getRepeatNumber() As Integer
'18Aug13 TH Added (TFS 70134)

   getRepeatNumber = m_intRepeatNumber

End Function

Sub setTotalRepeats(ByVal intTotalRepeats As Integer)
'18Aug13 TH Added (TFS 70134)

   m_intTotalRepeats = intTotalRepeats
   Heap 10, gPRNheapID, "RptTot", Format$(intTotalRepeats), 0

End Sub

Function getTotalRepeats() As Integer
'18Aug13 TH Added (TFS 70134)

   getTotalRepeats = m_intTotalRepeats
   

End Function
Sub setRptPrescriptionExpiry(ByVal strRptPrescriptionExpiry As String)
'18Aug13 TH Added (TFS 70134)

   m_strRptPrescriptionExpiry = strRptPrescriptionExpiry
   Heap 10, gPRNheapID, "RptExpiry", strRptPrescriptionExpiry, 0

End Sub

Function getRptPrescriptionExpiry() As String
'18Aug13 TH Added (TFS 70134)

   getRptPrescriptionExpiry = m_strRptPrescriptionExpiry

End Function
Sub setRptQuantity(ByVal sglRptQuantity As Single)
'18Aug13 TH Added (TFS 70134)

   m_sglRptQuantity = sglRptQuantity
   'Heap 10, gPRNheapID, "RptExpiry", strRptPrescriptionExpiry, 0

End Sub

Function getRptQuantity() As Single
'18Aug13 TH Added (TFS 70134)

   getRptQuantity = m_sglRptQuantity

End Function
Sub setExtendedLabel(ByVal blnExtendedLabel As Boolean)
'24Jun14 TH Written

   m_blnExtendedLabel = blnExtendedLabel
   'Heap 10, gPRNheapID, "RptExpiry", strRptPrescriptionExpiry, 0

End Sub

Function getExtendedLabel() As Boolean
'24Jun14 TH Written

   getExtendedLabel = m_blnExtendedLabel

End Function

Sub ChooseInstructionCode()
'18Jan99 EAC show list of warnings/instructions to user
'09May05 Is is correct to amend memory image then paste this to the screen?
'        Shouldn't it work on the screen only until asked to copy to memory?

Dim Code$, expn$
Dim CANCELLED As Integer

   ListInstructions Code$, expn$, CANCELLED
   If Not CANCELLED Then
      labelline$(0) = expn$
      
      L.RevisedInstruction = Code$                    'just one instruction code
      LabelAmended = True
       If Not L.extralabel Then memorytolabel '17Jun14 TH Added Fencepost
      SetAttemptedlabelEdit True
   End If
         
End Sub
Sub ChooseWarningCode()
'18Jan99 EAC show list of warnings/instructions to user
'09May05 Is is correct to amend memory image then paste this to the screen?
'        Shouldn't it work on the screen only until asked to copy to memory?

Dim Code$, expn$
Dim CANCELLED As Integer, loopvar%, Numoflines%

   ReDim warn$(10)
   
   ListWarnings Code$, expn$, CANCELLED
   If Not CANCELLED Then
      deflines expn$, warn$(), Chr$(LBL_END_LINE) & "(*)", 1, Numoflines
      
      For loopvar = 1 To 3
         'labelline$(loopvar + 5) = warn$(loopvar)
         labelline$(loopvar + IIf(L.extralabel, 15, 5)) = warn$(loopvar)
      Next
      
      L.RevisedWarning = Code$                        'just one warning code
      LabelAmended = True
      If Not L.extralabel Then memorytolabel '17Jun14 TH Added Fencepost
      SetAttemptedlabelEdit True
   End If

End Sub
Sub ExtendedLabelFromLoad()


Dim intloop As Integer
Dim strAns As String

   
   DisplaytheLabel 1, False, k, "", 0, True '01Jul14 TH Added to ensure warnings are on the label correctly
   
   For intloop = 0 To 15 '05Aug14 TH
      frmExtraLabel.TxtLabel(intloop).text = ""
   Next
   'set the form
   For intloop = 0 To 15
      setforecolour intloop, True, True
      strAns = RTrim$(labelline$(intloop))
      If Mid$(strAns, 2, 1) = "!" Then strAns = Right$(strAns, Len(strAns) - 2)
      frmExtraLabel.TxtLabel(intloop).text = strAns 'labelline$(intloop) ' txtUC("TxtLabel", intloop).text
   Next
   

   StopEvents = False
   frmExtraLabel.Tag = "fromload"
   frmExtraLabel.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   frmExtraLabel.Tag = ""
   
   setExtendedLabelWYSWY
   
   
End Sub
Function IsExtraLabel() As Boolean
'25Jun14 TH Written

   IsExtraLabel = L.extralabel
End Function
Sub setExtendedLabelWYSWY()
'01Jul14 TH Written
'12Aug14 TH Now parse all description lines (TFS 97728)

Dim intloop As Integer
Dim strDrugLine1 As String
Dim strDrugLine2 As String
Dim breakpos As Integer, LinesAchieved As Integer
Dim strDrugDesc As String, sTmpDesc As String
Dim FontNumber As Integer
Dim TextOut$
Dim pos As Integer
Dim strLastLine As String

   For intloop = 0 To 9
      txtUC("TxtLabel", intloop).text = ""
   Next
   strDrugDesc = Trim$(d.LabelDescription)      'strDrugDesc = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
            
   strDrugLine2 = ""
   LinesAchieved = 0

   sTmpDesc = strDrugDesc
   plingparse sTmpDesc, "!"                                                        '    "      Lines required
   FormatLabel sTmpDesc, 1, 35, FontNumber, LinesAchieved, TextOut$, L.extralabel '    "
   

   If Len(RTrim$(strDrugDesc)) > 35 Or (LinesAchieved > 1) Then
      breakpos = InStr(strDrugDesc, "!")
      If breakpos = 0 Then
         pos = 30
         Do
            breakpos = InStr(pos, strDrugDesc, " ")
            pos = pos - 5
         Loop While breakpos = 0 And pos > 14
      End If
      If breakpos > 0 Then
         strDrugLine1 = Left$(strDrugDesc, breakpos - 1)
         strDrugLine2 = Right$(strDrugDesc, Len(strDrugDesc) - breakpos)
       Else
         strDrugLine1 = Left$(strDrugDesc, 35)                  '    "      previously it was putting nothing on the description line !!!!!!
         strDrugLine2 = Right$(strDrugDesc, Len(strDrugDesc) - 35)
      End If
      plingparse strDrugLine1, "!"  '12Aug14 TH Now parse both lines (TFS 97728)
      plingparse strDrugLine2, "!"  '  "
   Else
      plingparse strDrugDesc, "!"
      strDrugLine1 = strDrugDesc
   End If
   
   
   txtUC("TxtLabel", 1).text = "Label details for"
   txtUC("TxtLabel", 1).FontName = "Courier New"
   txtUC("TxtLabel", 1).ForeColor = Blue
   txtUC("TxtLabel", 1).FontSize = 9.75
   txtUC("TxtLabel", 1).MousePointer = lblUC("lblPrompt", 4).MousePointer
   txtUC("TxtLabel", 1).MouseIcon = lblUC("lblPrompt", 4).MouseIcon
   txtUC("TxtLabel", 1).Refresh
   
   txtUC("TxtLabel", 2).text = strDrugLine1
   txtUC("TxtLabel", 2).ForeColor = Blue
   txtUC("TxtLabel", 2).MousePointer = lblUC("lblPrompt", 4).MousePointer
   txtUC("TxtLabel", 2).MouseIcon = lblUC("lblPrompt", 4).MouseIcon
   txtUC("TxtLabel", 2).Refresh
   
   txtUC("TxtLabel", 3).text = strDrugLine2
   txtUC("TxtLabel", 3).ForeColor = Blue
   txtUC("TxtLabel", 3).MousePointer = lblUC("lblPrompt", 4).MousePointer
   txtUC("TxtLabel", 3).MouseIcon = lblUC("lblPrompt", 4).MouseIcon
   txtUC("TxtLabel", 3).Refresh
   
   txtUC("TxtLabel", 4).text = "Extends over two labels"
   txtUC("TxtLabel", 4).FontName = "Courier New"
   txtUC("TxtLabel", 4).ForeColor = Blue
   txtUC("TxtLabel", 4).FontSize = 9.75
   txtUC("TxtLabel", 4).MousePointer = lblUC("lblPrompt", 4).MousePointer
   txtUC("TxtLabel", 4).MouseIcon = lblUC("lblPrompt", 4).MouseIcon
   txtUC("TxtLabel", 4).Refresh
   
   txtUC("TxtLabel", 5).text = "Click here to view"
   txtUC("TxtLabel", 5).FontName = "Courier New"
   txtUC("TxtLabel", 5).ForeColor = Blue
   txtUC("TxtLabel", 5).FontSize = 9.75
   txtUC("TxtLabel", 5).MousePointer = lblUC("lblPrompt", 4).MousePointer
   txtUC("TxtLabel", 5).MouseIcon = lblUC("lblPrompt", 4).MouseIcon
   txtUC("TxtLabel", 5).Refresh
      
   setforecolour 9, True, False
   strLastLine = RTrim$(labelline$(15)) '05Aug14 TH
   If Mid$(strLastLine, 2, 1) = "!" Then strLastLine = Right$(strLastLine, Len(strLastLine) - 2)
   txtUC("TxtLabel", 9).text = LTrim$(txtUC("TxtLabel", 9).text & " " & strLastLine) '   "
   txtUC("TxtLabel", 9).Refresh
   
   
End Sub

Function isCustomFrequency() As Boolean
'15Sep15 TH Written as useful wrapper (TFS 129498)

   If ((Len(Trim$(OCXheap("DirCode", ""))) = 0) And (Val(OCXheap("SCHEDULEID_ADMINISTRATION", "0"))) > 0) Then
      isCustomFrequency = True
   Else
      isCustomFrequency = False
   End If
   
   
   
End Function

Sub setDispWardSupplier(ByVal strSupCode As String)
'30Jul17 TH Handlers to use new cached ward (TFS)

    getsupplier strSupCode, 0, 0, m_DispWardSupplier

End Sub

Sub GetDispWardSupplier(ByVal strSupCode As String, ByRef lngFoundSup As Long, ByRef sup As supplierstruct)
'30Jul17 TH Handlers to use new cached ward (TFS)

If Trim$(strSupCode) = Trim$(m_DispWardSupplier.Code) Then
    lngFoundSup = m_DispWardSupplier.SupplierID
    sup = m_DispWardSupplier
Else
    lngFoundSup = 0
    clearsup sup
End If

End Sub
