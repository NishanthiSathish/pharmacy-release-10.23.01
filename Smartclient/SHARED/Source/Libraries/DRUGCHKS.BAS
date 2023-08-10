Attribute VB_Name = "DRUGCHKS"
'-------------------------------------------------------------------------------------------------
'        DRUGCHKS.BAS
'       --------------
'
'Modification History
'-------------------------------------------------------------------------------------------------
'16May97 ASC used to handle interaction and dosing checking checking
'29May97 KR  Added CloseInteractionDB
'25jul97 CKJ CheckAllergy: added check to prevent msg "Previously allergic to <empty string>"
'21Aug97 CKJ Partially merged changes from ASC
'27Aug97 CKJ Merged remaining changes from ASC
'29Nov97 ASC CheckDose: changed from d.printformv to d.dosingunits
' 8Dec97 CKJ/SF CheckDose: Changed Confirm to AskWin, correcting grammar too
'20Dec97 ASC/SF Corrected cross checking in CheckAllergy
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'11Feb98 CFY CheckDose: Changed from using d.PrintformV to d.dosingunits so that conversion kicks in correctly.
'30Apr98 ASC/CFY checkdose: dosesperissueunit=0 is no longer an error condition it means that we do not know the number of doses per issue unit e.g. sprays
'26Jul98 ASC Therapeutic duplication
'27Jul98 ASC Added cumulative dose
'30Jul98 EAC CheckCumlativeDose: made work when no items in PMR
'31Jul98 ASC now looks in history
'22Sep98 TH  CheckPMRinteractions: Stop Chemicals interacting with themselves
'12Feb99 JP  CheckPMRinteractions: Added patient details to interactions/allergy details
'24May99 CKJ OpenInteractionDb: Now always reads interact.mdb from App.Path
'28May99 TH  CheckPMRinteractions: Make sure checkallergy is fired even for one drug
'04Jun99 ASC Added to check for individual ingrediants where chemical may = *chemical1,chemical2,chemical3*
'            Also moved AllergyMsg from WIDENT.BAS to the drugchks module to improve encapsulation
'            This solves event number NZ 50418,50338    UK18947,18734
'19Jul99 AE  CheckDose:Added call for pharmacokinetic montioring
'30Jul99 TH  Checkallergy: Added Penicillamine to penicillins allergy $
'10jan00 AE  CheckDose:Changed Mod of 19Jul99 to remove reference to Dispens
'            SetKineticsMonitoring: Written for above mod.
'            iMonitorKinetics: Added for above mod.
'17Jan00 SF  CheckAllergy: added rINN changes
'19Jan00 AW  CheckAllergy: added Celecoxib to Nsaids allergy $
'08Mar00 TH  CheckAllergy: Added new entries (From HCC)
'09Mar00 TH  CheckAllergy: Added Cefsulodin
'12Sep00 JN  CheckDose: Event 46298 - added logging for cancels out of dosage warning message
'26Sep00 JN  CheckDose: When show BNFpage for this item is chosen, the directions are cleared and should stop label saving (event 46799)
'28Mar01 TH  CheckPMRinteractions: Moved Therapeutic Duplication call outside clauses to ensure it fires
'12sep01 CKJ CheckPMRinteractions: added protocol parameter
'12sep01 CKJ CheckTherapeuticDuplication: Now private sub
'            Corrected use of 'severity' as this is an I/O parameter and could have arrived with severity=2
'             If duplication is found then this would have been set back to severity=1
'             Now it can only increase the severity level, not decrease it.
'18Sep01 CKJ CheckTherapeuticDuplication: Added check for partially matching BNF codes.
'             If both are at least 5 characters (eg 01.02) but one is longer
'             (eg 01.02.03) then compare at the length of the shorter code (01.02 v 01.02 = match)
'             Inhibition at sub section level only happens if both codes are present in the inhibit file.
'24Sep01 CKJ CheckDose: Site may choose to exclude PRN items from dose range checking
'            patmed.ini [DoseChecks]SuppressDoseCheckforPRN="Y"  default="N"
'09oct01 CKJ CheckPMRinteractions: Ensure stored severity increases but cannot decrease
'25Oct01 TH/CKJ  CheckPMRinteractions: Explicitly exclude history from interaction checks as previous (#56346)
'30Oct01 CKJ CheckDose: Dose check box - default action is to re-enter dose instead of show BNF
'27Nov01 CKJ checkPMRinteractions: Abort Addition message now editable                                (#57019)
'            patmed.ini [Messages] MsgAbortAddProduct="multi-line[cr]prompt"
'                                  MsgAbortAddProductDefault="N"    'optional, default is "Y"
'27Nov01 TH  CheckDose: Added changes and additions to logs as part of Royal London Enhancement (#57200)
'29nov01 CKJ CheckAllergy: Removed leading comma from cephalosporins$ as it is always appended to penicillins$
'             stripped double commas from PreviousAllergies$
'             Trailing comma in PreviousAllergies$ plus double comma in penicillins$ & cephalosporins$
'             caused false positive allergy warning to fire where chemical.txt had a trailing comma
'            Corrected Boolean logic with PenDrug and NSdrug (no functional change)                   (#54062)
'17Jan02 TH  CheckAllergy: Various additions and changes to Drug$s (From HCC)   (#58312)
'17Jan02 TH  CheckAllergy: Added Allergy checking on sulphonamides and Sulphydryl group  (#58312)
'21May03 TH  CheckAllergy: Added Heparin group and made additions to Nsaids,penecillins and cephalosporins  (#)
'                          Also removed duplicate entries in Cephalosporins and Nsaids.
'13Jun03 TH  CheckAllergy: Added Parecoxib to Nsaids
'19jun03 CKJ/TH CheckAllergy: added VALDECOXIB & PARECOXIB to sulphonamides
'10Mar04 TH  CheckAllergy: Altered spelling of Imipenem on instruction from DSS
'----------------------------------------------------------------
'V10 Consolidation

'08Sep08 TH  Checkdose: Minor changes for dose range checking in v9 (F0027850)
'24May11 CKJ DAO2.5 has not been eliminated. Removed 'as database' and 'as table'
'            as these were not in use but forced loading of DAO2.5 in the project


'-------------------------------------------------------------------------------------------------

Option Explicit
DefInt A-Z

'Dim IntersDb As Database
'Dim IntersTbl As table
Dim chems$(1 To 100, 0 To 6) '26Jul98 ASC Added total dose and units for cytotoxics and shared accros module

Dim iKineticsMonitoring As Integer     '10jan00 AE Added

''Private Sub CheckTherapeuticDuplication(chemical1$, chemical2$, route1$, route2$, desc1$, desc2$, BNFcode1$, BNFcode2$, msg$, severity%, nomessage%)
'''26Jun98 ASC Checks for chemical or therapeutic group duplication unless DSS.ini contains the section listed in
'''        "BNFSectionNoCheck" e.g. 08.01
'''12sep01 CKJ Now private sub
'''            Corrected use of 'severity' as this is an I/O parameter and could have arrived with severity=2
'''             If duplication is found then this would have been set back to severity=1
'''             Now it can only increase the severity level, not decrease it.                                  (#55374)
'''18Sep01 CKJ Added check for partially matching BNF codes. If both are at least 5 characters (eg 01.02) but one is longer
'''             (eg 01.02.03) then compare at the length of the shorter code (01.02 v 01.02 = match)
'''             Inhibition at sub section level only happens if both codes are present in the inhibit file.    (#55374)
''
''Dim Section$, SubSection$, found%
''Dim intLocalSeverity As Integer                                                                    '12sep01 CKJ
''Dim intCodeLen As Integer                                                                          '18sep01 CKJ
''Dim found1 As Integer, found2 As Integer
''
''   intLocalSeverity = 0                                                                            '12sep01 CKJ
''   If (chemical1$ = chemical2$) And (route1$ = route2$) And (desc1$ <> desc2$) Then
''         'severity% = 1                                                                            '12sep01 CKJ
''         intLocalSeverity = 1
''         msg$ = msg$ & " -  Duplication " & crlf & Trim$(desc1$) & " already prescribed" & crlf & crlf
''      Else
''         intCodeLen = LesserOf(Len(BNFcode1$), Len(BNFcode2$))                                     '18sep01 CKJ Added
''         'If Len(BNFcode1$) >= 5 Then                                                              '    check that both are long enough
''         If intCodeLen >= 5 Then
''               Section$ = txtd(dispdata$ & "\DSS.INI", "BNFSectionNoCheck", "", Left$(BNFcode1$, 5), found)
''
''               If Not found Then
''                     'SubSection$ = txtd(dispdata$ & "\DSS.INI", "BNFSubSectionNoCheck", "", BNFcode1$, found)  '18sep01 CKJ
''                     SubSection$ = txtd(dispdata$ & "\DSS.INI", "BNFSubSectionNoCheck", "", BNFcode1$, found1)
''                     SubSection$ = txtd(dispdata$ & "\DSS.INI", "BNFSubSectionNoCheck", "", BNFcode2$, found2)
''                     If found1 And found2 Then found = True
''                  End If
''
''               'If (BNFcode1$ = BNFcode2$) And (route1$ = route2$) And (desc1$ <> desc2$) And Not found Then '18sep01 CKJ split into two lines
''               If (route1$ = route2$) And (desc1$ <> desc2$) And Not found Then
''                     If (BNFcode1$ = BNFcode2$) Then
''                           'severity = 1                                                                     '12sep01 CKJ
''                           intLocalSeverity = 1
''                           msg$ = msg$ & " -  Therapeutic Duplication " & crlf & Trim$(desc1$) & " already prescribed" & crlf & crlf
''
''                        Else                  '18sep01 CKJ new addition, check partial bnf codes e.g. 01.02.03.04 v 01.02.03
''                           If Left$(BNFcode1$, intCodeLen) = Left$(BNFcode2$, intCodeLen) Then
''                                 intLocalSeverity = 1
''                                 msg$ = msg$ & " -  Possible Therapeutic Duplication" & crlf
''                                 msg$ = msg$ & "between Formulary Codes " & BNFcode1$ & " and " & BNFcode2$ & crlf
''                                 msg$ = msg$ & Trim$(desc1$) & " already prescribed" & crlf & crlf
''                              End If
''                        End If                '18sep01 ckj --------
''                  End If
''            End If
''      End If
''
''   If intLocalSeverity > severity Then severity = intLocalSeverity                                 '12sep01 CKJ
''
''End Sub

Function GetUserPreference(ByVal strUserID As String, ByVal strEntry As String, ByVal strDefault As String) As String
'-------------------------------------------------------------------------------------
'12sep01 CKJ written
'            This looks up user preferences and returns the result.
'            The individual user settings are stored in dispdata.###\userpref.ini
'            where the user ID is used as the section code.
'            This file is automatically maintained and is not to be edited manually.
'            If the file, section or entry do not exist then the default is returned
'            If the userId or entry are blank then the default is returned
'            e.g.
'            [<UserIDcode>]
'            ShowProtocolWarnings = "All"
'            Note the special case where strUserID="<DEFAULT>" which reads from the default section []
'            instead of the named userid section. Note this is case sensitive.
'-------------------------------------------------------------------------------------
Dim strSection As String

   If Len(Trim$(strUserID)) = 0 Or Len(Trim$(strEntry)) = 0 Then
         GetUserPreference = strDefault
      Else
         strSection = Iff(strUserID = "<DEFAULT>", "", strUserID)
         GetUserPreference = TxtD(dispdata$ & "\userpref.ini", strSection, strDefault, strEntry, False)
      End If

End Function

Sub LogUserPreferenceChange(ByVal strUserID As String, ByVal strEntry As String, ByVal strNewValue As String)
'-------------------------------------------------------------------------------------
'12sep01 CKJ written
'            This logs a change to a user preference entry.
'            The logs are stored in dispdata.###\userpref.log
'            where the user ID is used as the section code.
'            If the file, section or entry did not exist then this is logged
'            If the userId or entry are blank then this is logged
'            e.g.
'            [<UserIDcode>]
'            ShowProtocolWarnings = "All"
'-------------------------------------------------------------------------------------
Dim strLog As String
Dim strOldValue As String

   If Len(Trim$(strUserID)) = 0 Then
         strOldValue = "<INVALID USE - USER ID IS BLANK>"
      ElseIf Len(Trim$(strEntry)) = 0 Then
         strOldValue = "<INVALID USE - PREFERENCE ID IS BLANK>"
      Else
         strOldValue = GetUserPreference(strUserID, strEntry, "<ENTRY NOT FOUND>")
      End If
   
   strLog = "Terminal='" & ASCTerminalName$() & "': "
   strLog = strLog & "UserID='" & strUserID & "', Entry='" & strEntry & "', "
   strLog = strLog & "OldValue='" & strOldValue & "', NewValue='" & strNewValue & "'"

   WriteLog dispdata$ & "\userpref.log", 0, UserID$, strLog

End Sub

''Sub OpenInteractionDb(OpenDB%)
'''!!** add check for licence file before use - 2 options.
'''   dose range checking - 1
'''   interactions = 2
'''24May99 CKJ Now always reads interact.mdb from App.Path
''
''Static opened%
''Dim success%
''   'If Not fileexists(progsDRV$ & "\ascribe\interact.mdb") Then'30Jan98 ASC/EAC
''   If Not fileexists(AppPathNoSlash() & "\interact.mdb") Then  '24May99 CKJ Replaces progsDRV$
''         Exit Sub                                              '30Jan98 ASC/EAC
''      End If
''
''   success = True
''   On Error GoTo OpenInteractiondb_Err
''   If OpenDB Then
''         If Not opened Then     'try opening it
''               'Set IntersDb = OpenDatabase(progsDRV$ & "\ascribe\interact.mdb", False, True) '24May99 CKJ removed
''               Set IntersDb = OpenDatabase(AppPathNoSlash() & "\interact.mdb", False, True)   '24May99 CKJ Replaces progsDRV$
''               Set IntersTbl = IntersDb.OpenTable("interactions", 4)
''               opened = True
''            End If
''      Else
''         If opened Then         'try closing it
''               IntersTbl.Close
''               IntersDb.Close
''               Set IntersDb = Nothing
''               Set IntersTbl = Nothing
''               opened = False
''            End If
''      End If
''
''OpenInteractiondb_Exit:
''   On Error GoTo 0
''   'OpenInteractionDb = success
''Exit Sub
''
''OpenInteractiondb_Err:
''   popmessagecr "ASCribe", "OpenInteractdb error: Could not " & Iff(OpenDB, "open", "close") & " the database"
''   success = False
''''   END!     'Until reads license file ##!!?? ASC
''Resume OpenInteractiondb_Exit
''
''End Sub

''Private Sub CheckAllergy(chemical$, ByVal PreviousAllergies$, msg$)
'''------------------------------------------------------------------------------------------------
'''14Jul97 ASC
'''Checks if the new Chemical$ is in PreviousAllergies$ and returns the
'''patient note entry if it does, also checks for cross allergies with other penicillins
'''and cephalosporins and NSAIDS
'''25jul97 CKJ added check to prevent msg "Previously allergic to <empty string>"
'''17Aug97 ASC fixed multiple allergy checks and reformatted wording and added NSAID cross checks
'''25Aug97 ASC removed PA$ usage and merged changes from 17Aug97
'''20Dec97 ASC/SF corrected cross checks so that NSAID's are separated from penicillins and Cephalosporins
'''27Apr98 ASC/CFY re-corrected above
'''04Jun99 ASC If the allergy is found without a notes entry still warns with generic message
'''            also added PENICILLIN,CEPHALOSPORIN and NSAID as a genereic for each group
'''30Jul99 TH  Added Penicillamine to penicillin allergy $
'''17Jan00 SF  added rINN changes
'''19Jan00 AW  added Celecoxib to Nsaids allergy $
'''08Mar00 TH  Added new entries (From HCC)
'''09Mar00 TH  Added Cefsulodin
'''29nov01 CKJ Removed leading comma from cephalosporins$ as it is always appended to penicillins$
'''             stripped double commas from PreviousAllergies$
'''             Trailing comma in PreviousAllergies$ plus double comma in penicillins$ & cephalosporins$
'''             caused false positive allergy warning to fire where chemical.txt had a trailing comma
'''            Corrected Boolean logic with PenDrug and NSdrug (no functional change)
'''17Jan02 TH  Various additions and changes to Drug$s (From HCC)   (#58312)
'''17Jan02 TH  Added Allergy checking on sulphonamides and Sulphydryl group  (#58312)
'''21May03 TH  Added Heparin group and made additions to Nsaids,penecillins and cephalosporins  (#)
'''            Also removed duplicate entries in Cephalosporins and Nsaids.
'''13Jun03 TH  Added Parecoxib to Nsaids
'''19jun03 CKJ/TH added VALDECOXIB & PARECOXIB to sulphonamides
'''10Mar04 TH  Altered spelling of Imipenem on instruction from DSS
'''------------------------------------------------------------------------------------------------
''
''Dim penicillins$, cephalosporins$, NSAIDS$, startpos%, endpos%, allergy$     '29Nov01 CKJ Removed PA$ as never used
''Dim PenDrug%, NSDrug%   '27Apr98 ASC/CFY
''Dim sulphydrylgroup$, sulphonamides$          '17Jan02 TH  (#58312)
''Dim sulphonamidesDrug%, sulphydrylgroupDrug%
''Dim blnHeparinDrug As Integer, strHeparins As String
''
''   PenDrug = False   '27Apr98 ASC/CFY
''   NSDrug = False    '     "
''   sulphonamidesDrug = False     '17Jan02 TH  (#58312)
''   sulphydrylgroupDrug = False
''   blnHeparinDrug = False  '21May03 TH Added
''   chemical$ = UCase$(Trim$(chemical$))
''
''   If chemical$ <> "" And Len(Trim$(PreviousAllergies$)) > 1 Then            '25jul97 CKJ added to prevent msg "Previously allergic to <empty string>"
''                                                                             '25Aug97 ASC added And Len(Trim$(PreviousAllergies$)) > 1 for speed
''         'PreviousAllergies$ = UCase$("," & Trim$(PreviousAllergies$) & ",") '25Aug97 ASC moved below if '20Dec97 ASC
''         'PreviousAllergies$ = UCase$(Trim$(PreviousAllergies$) & ",")       '25Aug97 ASC moved below if        '20Dec97 ASC '30Nov01 CKJ
''         PreviousAllergies$ = "," & UCase$(Trim$(PreviousAllergies$)) & ","  '25Aug97 ASC moved below if        '20Dec97 ASC '30Nov01 CKJ in case leading "," absent
''         replace PreviousAllergies$, ",,", ",", 0                            '29Nov01 CKJ added to prevent pairs of commas
''
''         If InStr(PreviousAllergies$, "," & Trim$(chemical$) & ",") > 0 Then
''               msg$ = msg$ & AllergyMsg$(chemical$)  '17Aug97 ASC
''               If msg$ = "" Then msg$ = "Allergic to " & chemical$ & " with detail found in notes." '04Jun99 ASC
''            Else
''               '04Jun99 ASC added PENICILLIN,CEPHALOSPORIN and NSAID as a genereic for each group below and new drugs from groups.txt
''               'penicillins$ = ",PHENOXYMETHYLPENICILLIN,AMOXYCILLIN,BENZYLPENICILLIN,PROCAINE PENICILLIN,CLOXACILLIN,FLUCLOXACILLIN,TEMOCILLIN,CO-AMOXICLAV,AMOXYCILLIN,AMPICILLIN,BACAMPICILLIN,CO-FLUAMPICIL,AZLOCILLIN,PIPERACILLIN,TICARCILLIN,AZTREONAM,MEROPENEM,BENZATHINE PENICILLIN,CARBENICILLIN,DICLOXACILLIN,MEZLOCILLIN,PIVAMPICILLIN,PENICILLIN,"
''               penicillins$ = ",PHENOXYMETHYLPENICILLIN,AMOXYCILLIN,BENZYLPENICILLIN,PROCAINE PENICILLIN,CLOXACILLIN,FLUCLOXACILLIN,TEMOCILLIN,CO-AMOXICLAV,AMOXYCILLIN,AMPICILLIN,BACAMPICILLIN,CO-FLUAMPICIL,AZLOCILLIN,PIPERACILLIN,TICARCILLIN,AZTREONAM,MEROPENEM,BENZATHINE PENICILLIN,CARBENICILLIN,DICLOXACILLIN,MEZLOCILLIN,PIVAMPICILLIN,PENICILLIN,PENICILLAMINE,"   '30Jul99 TH Added Penicillamine
''               penicillins$ = penicillins$ & "PROCAINE BENZYLPENICILLIN,AMOXICILLIN,"            '17Jan00 SF added for rINN changes
''               penicillins$ = penicillins$ & "METHICILLIN,PIVMECILLINAM,"    '08Mar00 TH Added
''               penicillins$ = penicillins$ & "DICLOXACILLIN,SULTAMICILLIN,"    '17Jan02 TH Added  (#58312)
''               'penicillins$ = penicillins$ & "IMEPENEM,"        '21May03 TH Added
''               penicillins$ = penicillins$ & "IMIPENEM,"      '05Mar04 TH Altered spelling on instruction from DSS
''
''               'cephalosporins$ = ",CEFACLOR,CEFADROXIL,CEFIXIME,CEFODIZIME,CEFOTAXIME,CEFOXITIN,CEFPIROME,CEFPODOXIME,CEFTAZIDIME,CEFTIBUTEN,CEFTRIAXONE,CEFUROXIME,CEPHALEXIN,CEPHAMANDOLE,CEPHAZOLIN,CEPHRADINE,CEFOTETAN,CEPHALOTHIN,CEPHALOSPORIN,"  '08Mar00 TH Removed ceftibuten '29nov01 CKJ removed leading comma
''               cephalosporins$ = "CEFACLOR,CEFADROXIL,CEFIXIME,CEFODIZIME,CEFOTAXIME,CEFOXITIN,CEFPIROME,CEFPODOXIME,CEFTAZIDIME,CEFTIBUTEN,CEFTRIAXONE,CEFUROXIME,CEPHALEXIN,CEPHAMANDOLE,CEPHAZOLIN,CEPHRADINE,CEFOTETAN,CEPHALOTHIN,CEPHALOSPORIN,"    '08Mar00 TH Removed ceftibuten '29nov01 CKJ removed leading comma
''               cephalosporins$ = cephalosporins$ & "CEFALEXIN,CEFAMANDOLE,CEFAZOLIN,CEFRADINE,"  '17Jan00 SF added for rINN changes
''               'cephalosporins$ = cephalosporins$ & "CEFEPIME,CEFOPERAZONE"   '08Mar00 TH Added
''               cephalosporins$ = cephalosporins$ & "CEFEPIME,CEFOPERAZONE,CEFSULODIN," '09Mar00 TH Added Cefsulodin
''               'cephalosporins$ = cephalosporins$ & "CEFOTETAN,"       '17Jan02 TH Added   (#58312)  '20May03 TH Removed (Duplicate)
''               cephalosporins$ = cephalosporins$ & "CEFPROXZIL,"   '21May03 TH Added
''
''               'NSAIDS$ = ",ACECLOFENAC,ACEMETACIN,ALCLOFENAC,AZAPROPAZONE,CLOMETACIN,DEXKETOPROFEN,DICLOFENAC,DIFLUNISAL,ETODOLAC,FENBUFEN,FENOPROFEN,FEPRAZONE,FLOCTAFENINE,FLUFENAMIC ACID,FLURBIPROFEN,GLAFENINE,IBUPROFEN,INDOMETHACIN,ISOXICAM,KEBUZONE,KETOPROFEN,MECLOFENAMIC ACID,MEFENAMIC ACID,MOFEBUTAZONE,MELOXICAM,NABUMETONE,NAPROXEN,NEFOPAM,NIMESULIDE,OXAMETACIN,OXYPHENBUTAZONE,PHENYLBUTAZONE,PIROXICAM,SULINDAC,TENIDAP,TENOXICAM,TIAPROFENIC ACID,TOFENAMIC ACID,TOLMETIN,ACECLOFENAC,ASPIRIN,NSAID," '17Aug97 ASC   '25Aug97 removed stray space
''               '20May03 TH Replaced above
''               NSAIDS$ = ",ACECLOFENAC,ACEMETACIN,ALCLOFENAC,AZAPROPAZONE,CLOMETACIN,DEXKETOPROFEN,DICLOFENAC,DIFLUNISAL,ETODOLAC,FENBUFEN,FENOPROFEN,FEPRAZONE,FLOCTAFENINE,"
''               NSAIDS$ = NSAIDS$ & "FLUFENAMIC ACID,FLURBIPROFEN,GLAFENINE,IBUPROFEN,INDOMETHACIN,ISOXICAM,KEBUZONE,KETOPROFEN,MECLOFENAMIC ACID,"
''               NSAIDS$ = NSAIDS$ & "MEFENAMIC ACID,MOFEBUTAZONE,MELOXICAM,NABUMETONE,NAPROXEN,NEFOPAM,NIMESULIDE,OXAMETACIN,OXYPHENBUTAZONE,PHENYLBUTAZONE,"
''               NSAIDS$ = NSAIDS$ & "PIROXICAM,SULINDAC,TENIDAP,TENOXICAM,TIAPROFENIC ACID,TOLFENAMIC ACID,TOLMETIN,ASPIRIN,NSAID,"     '20May03 TH Changed TOFENAMIC ACID to TOLFENAMIC ACID  ,Removed ACECLOFENAC (duplicate)
''               '-------------------------
''               'NSAIDS$ = NSAIDS$ & "INDOMETACIN,"                                               '17Jan00 SF added for rINN changes
''               NSAIDS$ = NSAIDS$ & "INDOMETACIN,CELECOXIB,"                                               '17Jan00 SF added for rINN changes   '19Jan00 AW added celecoxib
''               NSAIDS$ = NSAIDS$ & "ROFECOXIB,"                              '08Mar00 TH Added
''               NSAIDS$ = NSAIDS$ & "KETOROLAC,BENORILATE,"   '17Jan02 TH Added (#58312)
''               NSAIDS$ = NSAIDS$ & "BENORYLATE,ETORICOXIB,LORNOXICAM,SULFINPYRAZONE,SULPHINPYRAZONE,VALDECOXIB,"
''               NSAIDS$ = NSAIDS$ & "PARECOXIB,"         '13Jun03 TH Added
''
''               sulphonamides$ = ",ACETAZOLAMIDE,ACETOHEXAMIDE,ALMOTRIPTAN,ALTHIAZIDE,ALTIZIDE,BEMETIZIDE,BENDROFLUAZIDE,"                                                 '17Jan02 TH Added  (#58312)
''               sulphonamides$ = sulphonamides$ & "BENDROFLUMETHIAZIDE,BENZTHIAZIDE,BRINZOLAMIDE,BUMETANIDE,BUTHIAZIDE,BUTIZIDE,CARBUTAMIDE,CELECOXIB,"                    '    "
''               sulphonamides$ = sulphonamides$ & "CHLOROTHIAZIDE,CHLORPROPAMIDE,CHLORTHALIDONE,CHLORTALIDONE,CLOPAMIDE,CYCLOPENTHIAZIDE,CYCLOTHIAZIDE,"                   '    "
''               sulphonamides$ = sulphonamides$ & "DORZOLAMIDE,EPITHIAZIDE,EPITIZIDE,FRUSEMIDE,FUROSEMIDE,GLIBENCLAMIDE,GLICLAZIDE,GLIMEPIRIDE,GLIBORNURIDE,"              '    "
''               sulphonamides$ = sulphonamides$ & "GLIPIZIDE,GLIQUIDONE,GLISENTIDE,GLISOLAMIDE,GLISOXEPIDE,GLYCLOPYRAMIDE,GLYCYCLAMIDE,HYDROCHLOROTHIAZIDE,"               '    "
''               sulphonamides$ = sulphonamides$ & "HYDROFLUMETHIAZIDE,INDAPAMIDE,MAFENIDE,MEBUTIZIDE,MEFRUSIDE,METHAZOLAMIDE,METHYCLOTHIAZIDE,METHYLSULFATHIAZOLE,"        '    "
''               sulphonamides$ = sulphonamides$ & "METICRANE,METOLAZONE,NARATRIPTAN,PHTHALYLSULPHATHIAZOLE,PIRETANIDE,POLYTHIAZIDE,QUINETHAZONE,SULFA DRUG,"               '    "
''               sulphonamides$ = sulphonamides$ & "SULPHAPYRIDINE,SULFAPYRIDINE,SULPHADIAZINE,SULFADIAZINE,SULPHADIMIDINE,SULFADIMIDINE,SULPHAFURAZOLE,"                   '    "
''               sulphonamides$ = sulphonamides$ & "SULFAFURAZOLE,SULPHAMETHOXAZOLE,SULFAMETHOXAZOLE,SULPHADIMETHOXINE,SULFADIMETHOXINE,SULPHAMETHOXYDIAZINE,"              '    "
''               sulphonamides$ = sulphonamides$ & "SULPHAMETHOXYPYRIDAZINE,SULFAMETHOXYPYRIDAZINE,SULFADOXINE,SULFAMETOPYRAZINE,SULPHAGUANIDINE,SULFAGUANIDINE,"           '    "
''               sulphonamides$ = sulphonamides$ & "SUCCINYLSULPHATHIAZOLE,SULPHASALAZINE,SULFASALAZINE,SULPHANILAMIDE,SULFANILAMIDE,SULFAMETROLE,SULFADOXINE,"             '    "
''               sulphonamides$ = sulphonamides$ & "SULFAMERAZINE,SULFAMETHYLTHIAZOLE,SULFASUCCINAMIDE,SULFENAZONE,SULPHACETAMIDE,SULFACETAMIDE,SULPHAMETHIZOLE,"           '    "
''               sulphonamides$ = sulphonamides$ & "SULFAMETHIZOLE,SULPHAMOXOLE,SULFAMOXOLE,SULPHASOMIDINE,SULFISOMIDINE,SULFASOMIDINE,SULPHATHIAZOLE,SULFATHIAZOLE,"       '    "
''               sulphonamides$ = sulphonamides$ & "SULPHONAMIDE,SULFONAMIDE,SUMATRIPTAN,TECLOTHIAZIDE,THIAZIDE,TOLAZAMIDE,TOLBUTAMIDE,TORASEMIDE,TRICHLORMETHIAZIDE,"      '    "
''               sulphonamides$ = sulphonamides$ & "TRIPAMIDE,XIPAMIDE,"                                                                                                    '    "
''               sulphonamides$ = sulphonamides$ & "VALDECOXIB,PARECOXIB,"                                                                                                  '19jun03 CKJ/TH
''
''               sulphydrylgroup$ = ",CAPTOPRIL,PENICILLAMINE,SODIUM AUROTHIOMALATE,THIOGUANINE,TIOPRONIN,SULPHYDRYL GROUP,"                                                '    "
''
''               strHeparins = ",HEPARIN,CERTOPARIN,NADROPARIN,DALTEPARIN,REVIPARIN,ENOXAPARIN,TINZAPARIN,"  '21May03 TH Added
''
''               If InStr(penicillins$ & cephalosporins$, "," & chemical$ & ",") Then '27Apr98 ASC/CFY
''                     PenDrug = True                                                 '     "
''                  End If                                                            '     "
''                                                                                    '     "
''               If InStr(NSAIDS$, "," & chemical$ & ",") Then                        '     "
''                     NSDrug = True                                                  '     "
''                  End If                                                            '     "
''
''               If InStr(sulphonamides$, "," & chemical$ & ",") Then        '17Jan02 TH Added  (#58312)
''                     sulphonamidesDrug = True                              '     "
''                  End If                                                   '     "
''
''               If InStr(sulphydrylgroup$, "," & chemical$ & ",") Then      '     "
''                     sulphydrylgroupDrug = True                            '     "
''                  End If                                                   '     "
''
''               If InStr(strHeparins, "," & chemical$ & ",") Then      '21May03 TH Added
''                     blnHeparinDrug = True                            '     "
''                  End If                                              '     "
''
''
''               'If PenDrug Or NSDrug Then   '27Apr98 ASC/CFY
''               'If PenDrug Or NSDrug Or sulphonamidesDrug Or sulphydrylgroupDrug Then   '17Jan02 TH Replaced above  (#58312)  '21May03 TH Replaced
''               If PenDrug Or NSDrug Or sulphonamidesDrug Or sulphydrylgroupDrug Or blnHeparinDrug Then
''                     startpos = 1
''                     Do
''                        endpos% = InStr(startpos% + 1, PreviousAllergies$, ",")
''                        'allergy$ = Mid$(PreviousAllergies$, startpos, endpos)
''                        allergy$ = Mid$(PreviousAllergies$, startpos + 1, endpos - startpos - 1) '17Aug97 ASC used endpos - startpos - 1 instead of endpos
''                        startpos% = endpos%
''
''                        'If InStr(penicillins$ & cephalosporins$, "," & allergy$ & ",") Then                '27Apr98 ASC/CFY
''                        'If PenDrug And InStr(penicillins$ & cephalosporins$, "," & allergy$ & ",") Then    '      "          29Nov01 CKJ corrected
''                        If PenDrug And InStr(penicillins$ & cephalosporins$, "," & allergy$ & ",") > 0 Then '      "             "        Boolean expression
''                              If InStr(penicillins$, "," & allergy$ & ",") > 0 Then                                                                                                                '                      "
''                                    msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with penicillins can occur from (" & chemical$ & ")"       '17Aug97 ASC          '20Dec97 ASC
''                                 Else                                                                                                                                               '20Dec97 ASC
''                                    msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with cephalosporins from (" & chemical$ & ")"             '17Aug97 ASC           '20Dec97 ASC
''                                 End If                                                                                                                                             '20Dec97 ASC
''                              End If
''                                                                                                         '29Nov01 CKJ corrected
''                        'If NSDrug And InStr(NSAIDS$, "," & allergy$ & ",") Then                         '        Boolean expression
''                        If NSDrug And InStr(NSAIDS$, "," & allergy$ & ",") > 0 Then
''                              msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with NSAID's from (" & chemical$ & ")"                    '17Aug97 ASC      '20Dec97 ASC
''                           End If
''                        If sulphonamidesDrug And InStr(sulphonamides$, "," & allergy$ & ",") > 0 Then                                                   '17Jan02 TH Added  (#58312)
''                              msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with sulphonamide-related drugs from (" & chemical$ & ")"
''                           End If
''
''                        If sulphydrylgroupDrug And InStr(sulphydrylgroup$, "," & allergy$ & ",") > 0 Then
''                              msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with sulphydryl group from (" & chemical$ & ")"
''                           End If
''
''                        If blnHeparinDrug And InStr(strHeparins, "," & allergy$ & ",") > 0 Then                                               '21May03 TH Added
''                              msg$ = msg$ & AllergyMsg$(allergy$) & crlf & "Cross reactivity with Heparin from (" & chemical$ & ")"
''                           End If
''
''                     Loop Until endpos = Len(PreviousAllergies$)
''                  End If
''            End If
''      End If
''
''
''
'''   chemical$ = UCase$(Trim$(chemical$))
'''
'''   If chemical$ <> "" And Len(Trim$(PreviousAllergies$)) > 1 Then            '25jul97 CKJ added to prevent msg "Previously allergic to <empty string>"
'''                                                                             '25Aug97 ASC added And Len(Trim$(PreviousAllergies$)) > 1 for speed
'''         'PreviousAllergies$ = UCase$("," & Trim$(PreviousAllergies$) & ",")  '25Aug97 ASC moved below if '20Dec97 ASC
'''         PreviousAllergies$ = UCase$(Trim$(PreviousAllergies$) & ",")  '25Aug97 ASC moved below if        '20Dec97 ASC
'''         If InStr(PreviousAllergies$, "," & Trim$(chemical$) & ",") > 0 Then
'''               Msg$ = Msg$ & AllergyMsg$(chemical$)  '17Aug97 ASC
'''            Else
'''               penicillins$ = ",PHENOXYMETHYLPENICILLIN,AMOXYCILLIN,BENZYLPENICILLIN,PROCAINE PENICILLIN,CLOXACILLIN,FLUCLOXACILLIN,TEMOCILLIN,CO-AMOXICLAV,AMOXYCILLIN,AMPICILLIN,BACAMPICILLIN,CO-FLUAMPICIL,AZLOCILLIN,PIPERACILLIN,TICARCILLIN,AZTREONAM,MEROPENEM,"
'''               cephalosporins$ = ",CEFACLOR,CEFADROXIL,CEFIXIME,CEFODIZIME,CEFOTAXIME,CEFOXITIN,CEFPIROME,CEFPODOXIME,CEFTAZIDIME,CEFTIBUTEN,CEFTRIAXONE,CEFUROXIME,CEPHALEXIN,CEPHAMANDOLE,CEPHAZOLIN,CEPHRADINE,"
'''               NSAIDS$ = ",ALCLOFENAC,AZAPROPAZONE,CLOMETACIN,DICLOFENAC,DIFLUNISAL,FENOPROFEN,FEPRAZONE,FLOCTAFENINE,FLUFENAMIC ACID,FLURBIPROFEN,GLAFENINE,IBUPROFEN,INDOMETHACIN,ISOXICAM,KEBUZONE,KETOPROFEN,MECLOFENAMIC ACID,MEFENAMIC ACID,MOFEBUTAZONE,MELOXICAM,NABUMETONE,NAPROXEN,NEFOPAM,NIMESULIDE,OXAMETACIN,OXYPHENBUTAZONE,PHENYLBUTAZONE,PIROXICAM,SULINDAC,TENIDAP,TIAPROFENIC ACID,TOFENAMIC ACID,TOLMETIN,ACECLOFENAC,ACEMETACIN,ETODOLAC,FENBUFEN,TENOXICAM,ASPIRIN," '17Aug97 ASC   '25Aug97 removed stray space
'''
'''               If InStr(penicillins$ & cephalosporins$ & NSAIDS$, "," & chemical$ & ",") Then  '17Aug97 ASC added NSAIDS
'''                     startpos = 1
'''                     Do
'''                        endpos% = InStr(startpos% + 1, PreviousAllergies$, ",")
'''                        'allergy$ = Mid$(PreviousAllergies$, startpos, endpos)
'''                        allergy$ = Mid$(PreviousAllergies$, startpos + 1, endpos - startpos - 1) '17Aug97 ASC used endpos - startpos - 1 instead of endpos
'''                        startpos% = endpos%
'''                        'If InStr(penicillins$, "," & allergy$ & ",") Then '25Aug97 ASC added "," 's to allergy$                                                                    '20Dec97 ASC
'''                        If InStr(penicillins$, "," & allergy$ & ",") > 0 Or InStr(cephalosporins$, "," & allergy$ & ",") Then                                                       '20Dec97 ASC
'''                              If InStr(penicillins$, "," & chemical$ & ",") > 0 Then   '25Aug97 ASC added "," 's to allergy$                                                        '20Dec97 ASC
'''                                    Msg$ = Msg$ & AllergyMsg$(allergy$) & CRLF & "Cross reactivity with penicillins can occur from (" & chemical$ & ")"       '17Aug97 ASC          '20Dec97 ASC
'''                                 Else                                                                                                                                               '20Dec97 ASC
'''                                    Msg$ = Msg$ & AllergyMsg$(allergy$) & CRLF & "Cross reactivity with cephalosporins from (" & chemical$ & ")"             '17Aug97 ASC           '20Dec97 ASC
'''                                 End If                                                                                                                                             '20Dec97 ASC
'''                           End If
'''                        'If InStr(NSAIDS$, "," & allergy$ & ",") Then '17Aug97 ASC '25Aug97 ASC added "," 's to allergy$
'''                        If InStr(NSAIDS$, "," & allergy$ & ",") > 0 And InStr(NSAIDS$, "," & chemical$ & ",") > 0 Then '17Aug97 ASC '25Aug97 ASC added "," 's to allergy$           '20Dec97 ASC
'''                              Msg$ = Msg$ & AllergyMsg$(allergy$) & CRLF & "Cross reactivity with NSAID's from (" & chemical$ & ")"                    '17Aug97 ASC      '20Dec97 ASC
'''                           End If
'''                     Loop Until endpos = Len(PreviousAllergies$)
'''                  End If
'''             End If
'''      End If
''
''
''End Sub

''Sub CheckCumulativeDoses(msg$)
'''28Jul98 Only works on current prescriptions needs enhancing to include all prescriptions and
'''        give a summary  and then check against the recomended cum dose for that chemical
'''30Jul98 EAC made work when no items in PMR
'''31Jul98 ASC now looks in history
''
''Dim X%, i%
''Dim tmp$
''
''   'checkPMRinteractions False, "", "", 2, 0, ""       '31Jul98 ASC changed to 2,0  '15Sep98 CFY replaced '12sep01 CKJ confirmed with ASC that this commented out line should remain out of use - superceded by code below
''
''   msg$ = ""
''
''   For i = 0 To -1 Step -1
''      ScanCumulativeDose i
''
''      If i = 0 Then
''            msg$ = "Current medications only:" & crlf & crlf
''         Else
''            msg$ = msg$ & crlf & crlf & "Current and discontinued medications:" & crlf & crlf
''         End If
''
''      tmp$ = ""
''
''      X = 0
''      Do
''         X = X + 1
''         If Trim$(chems$(X, 0)) <> "" Then
''               'msg$ = msg$ & Left$(Trim$(chems$(x, 0)) & pad$(" ", Len(d.description)), Len(d.description)) & tb$ & tb$ & tb$ & Format$(Val(chems$(x, 4)), "0.00;0") & chems$(x, 5) & CRLF     '15Sep98 CFY Replaced
''               tmp$ = tmp$ & chems$(X, 2) & TB & Format$(Val(chems$(X, 4)), "0.00 ;0 ") & chems$(X, 5) & crlf      '      "
''            End If
''      Loop Until chems$(X, 0) = "" Or X = UBound(chems$, 1)
''
''      If tmp$ = "" Then tmp$ = "No items found" & crlf
''      msg$ = msg$ & tmp$
''
''   Next
''
''   msg$ = msg$ & crlf & "NOTE: Archived medications are not included"
''
''End Sub

Sub CheckDose(doses!(), ans$)
'16May97 ASC checks dose against mins and maxs from drug file then offers to show BNF if outside range
'29Nov97 ASC changed from d.printformv to d.dosingunits
' 8Dec97 CKJ/SF Changed Confirm to AskWin, correcting grammar too
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'11Feb98 CFY Changed from using d.PrintformV to d.dosingunits so that conversion kicks in correctly.
'30Apr98 ASC/CFY dosesperissueunit=0 is no longer an error condition it means that we do not know the number of doses per issue unit e.g. sprays
'26Jun98 ASC ONly checks for minimum dosing for age > 16yrs Maximum dosing checks still done for paeds
'19Jul99 AE  Added call for pharmacokinetic montioring
'10Jan00 AE  Changed above to remove reference to Dispens
'14Sep00 JN  Added new logfile, 'cancdose.log' to pick up when users are turned back by the Warning
'   "    JN  Does this by logging, then treating as Re-Enter dose
'26Sep00 JN  When show BNFpage for this item is chosen, the directions are cleared and should stop label saving
'24Sep01 CKJ Site may choose to exclude PRN items from dose range checking
'            patmed.ini [DoseChecks]SuppressDoseCheckforPRN="Y"  default="N"
'30Oct01 CKJ Dose check box - default action is to re-enter dose instead of show BNF
'27Nov01 TH  Added changes and additions to logs as part of Royal London Enhancement (#57200)
'08Sep08 TH  Minor changes for dose range checking in v9 (F0027850)
'---------------------------------------------------------------------------

Dim dailydose!, frequency%, X%, msg$, conv!, desc$
Dim NumericalAge!, dat$, valid% '26Jun98 ASC
ReDim Menu$(4), menuhlp(4)     '    "
Dim strLogMsg As String      '27Nov01 TH Added for Royal London enh (#57200)

''   If iKineticsMonitoring Then MonitorKinetics                  '10jan00 AE  Changed to remove reference to Dispens

   '24Sep01 CKJ Added block. Site may choose to exclude PRN items from dose range checking
   '            Note that this directly references dispens. which is undesirable as it limits the use of this proc,
   '            however it has done so since 26Sep00 (see below) and hence I have not added a new parameter.
   '            Note also that it uses the PRN checkbox, so this check will miss items described as PRN in the text
   '            of directions if the checkbox is unticked. This may be changed in the future if needed.
   If chkUC("ChkPRN").Value Then
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "DoseChecks", "N", "SuppressDoseCheckforPRN", 0)) Then
               ans$ = ""
               Exit Sub
            End If
      End If
   
   NumericalAge! = 0                                          '26Jun98 ASC
   parsedate pid.dob, dat$, "1", valid                        '     "
   If valid Then datetodays dat$, "", 0, NumericalAge!, "", 0 '     "
         
   For X = 1 To 6
      If doses!(X) > 0 Then frequency = frequency + 1: dailydose! = dailydose! + doses!(X)
   Next
   'ASC/EAC 22Sep97
   
'05Nov08 TH Replaced above as dose should already have been factored.
''   If d.dosesperissueunit <> 0 Then
''         '29Nov97 ASC
''         'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Then   '08Jul97 KR Added MGO                                                                                                                                                                                                     '05Feb98 CFY
''         'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then           '     "
''         'If UCase$(Left$(d.DosingUnits, 3)) = "TAB" Or UCase$(Left$(d.DosingUnits, 3)) = "CAP" Or UCase$(Left$(d.DosingUnits, 3)) = "SUP" Or UCase$(Left$(d.DosingUnits, 3)) = "MLO" Or UCase$(Left$(d.DosingUnits, 3)) = "MGO" Or UCase$(Left$(d.DosingUnits, 3)) = "PES" Or UCase$(Left$(d.DosingUnits, 3)) = "NEB" Or UCase$(Left$(d.DosingUnits, 3)) = "LOZ" Or UCase$(Left$(d.DosingUnits, 3)) = "SPR" Then   '11Feb98 CFY
''         If d.LabelInIssueUnits Then
''               dailydose! = dailydose! * d.dosesperissueunit
''            End If
''      'Else                                                                                 '30Apr98 ASC/CFY
''      '   popmessagecr "", "Dose Range checking not possible - doses per issue unit = 0"    '     "
''      '   Exit Sub                                                                          '     "
''      End If

   
   'If dailydose! < d.MinDailyDose And d.MinDailyDose <> 0 Then Msg$ = Msg$ & "LOW daily dose "
   If dailydose! < d.MinDailyDose And d.MinDailyDose <> 0 And NumericalAge! >= 16 Then msg$ = msg$ & "LOW daily dose "
   If dailydose! > d.MaxDailyDose And d.MaxDailyDose <> 0 Then msg$ = msg$ & "HIGH daily dose "
   If frequency% < d.MinDoseFrequency And d.MinDoseFrequency <> 0 Then msg$ = msg$ & "LOW daily frequency "
   If frequency% > d.MaxDoseFrequency And d.MaxDoseFrequency <> 0 Then msg$ = msg$ & "High daily frequency "

   If msg$ <> "" Then
         ans$ = "2"                                             'default action is to re-enter dose
         desc$ = Trim$(d.LabelDescription)  ' desc$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
         plingparse desc$, "!"
         Menu$(0) = "DOSE CHECK WARNING - " & msg$
         Menu$(1) = "Show BNF page for this item"
         'Menu$(2) = "Re-enter Dose"
         Menu$(2) = "Review Prescription" '08Sep08 TH  Altered
         Menu$(3) = "Accept dose (your action is logged)"
         inputmenu Menu$(), menuhlp(), ans$, k
         Select Case Val(ans$)
            Case 0
               strLogMsg = " (" & Trim$(d.SisCode) & ") Patient Caseno : " & Trim$(pid.caseno)
               strLogMsg = strLogMsg & " Patient Record No. = " & pid.recno
               WriteLog dispdata$ & "\cancdose.log", SiteNumber, UserID$, msg$ & strLogMsg
               ans$ = "Y"
               
            Case 1:
               ClearDirections                     '26Sep00 JN clear directions here so Rx is not complete
               txtUC("TxtDircode").Tag = "C"        '26Sep00 JN added 'tag' to directions code to denote cancelled from here
               LoadBNF
               ans$ = "Y"
               
            Case 2:
               ans$ = "Y"
               'strLogMsg = "Re-entered Dose  for  (" & Trim$(d.SisCode) & ") Patient Caseno : " & Trim$(pid.caseno)
               strLogMsg = "Reviewed Prescription for  (" & Trim$(d.SisCode) & ") Patient Caseno : " & Trim$(pid.caseno)
               strLogMsg = strLogMsg & " Patient Record No. = " & pid.recno
               WriteLog dispdata$ & "\cancdose.log", SiteNumber, UserID$, msg$ & strLogMsg
               
            Case 3:
               strLogMsg = "Accepted dose for (" & Trim$(d.SisCode) & ") Patient Caseno : " & Trim$(pid.caseno)
               strLogMsg = strLogMsg & " Patient Record No. = " & pid.recno
               WriteLog dispdata$ & "\dosage.log", SiteNumber, UserID$, msg$ & strLogMsg
               
            End Select
      End If

End Sub

''Private Sub CheckInteraction(chemical1$, chemical2$, route1$, route2$, desc1$, desc2$, msg$, severity%, nomessage%, strShowWarnings As String)
'''16May97 ASC checks one chemical entity against another and adds result to msg$
'''08Aug96 ASC now checks for route and multiple chemical entities
'''13Aug ASC/CKJ checked and ready for testing
'''12sep01 CKJ Pointless appending descriptions to chemicalx$ since these are not used subsequently
'''            Therefore modified to build up the msg$ directly, keeping format similar to original
'''            Route check was case sensitive i.e. "Top." so changed to case insenstive comparison
'''            Removed EXIT SUB, keeping single point of exit
'''            Added ability to suppress level 1 or level 1 & 2 warnings
''
''Dim search$, temp$, InteractionSeverity%
''Dim intDoIt As Integer                    '12sep01 CKJ
''
''   If chemical1$ > chemical2$ Then  'Index is in alphabetical order for two chemicals
''      temp$ = route1$
''      route1$ = route2$
''      route2$ = temp$
''
''      temp$ = chemical1$
''      chemical1$ = chemical2$
''      chemical2$ = temp$
''
''      temp$ = desc1$
''      desc1$ = desc2$
''      desc2$ = temp$
''   End If
''
''   search$ = chemical1$ & " + " & chemical2$
''   IntersTbl.Seek "=", search$
''   'Debug.Print search$
''
''   If Not IntersTbl.NoMatch Then
''      'If trimz$(GetField(IntersTbl!route1)) = trimz$(route1$) Or trimz$(GetField(IntersTbl!route2)) = trimz$(route2$) Then Exit Sub
''      'If trimz$(GetField(IntersTbl!route1)) = trimz$(route1$) And trimz$(route1$) <> "" Then Exit Sub  '27Aug97 CKJ Added
''      'If trimz$(GetField(IntersTbl!route2)) = trimz$(route2$) And trimz$(route2$) <> "" Then Exit Sub  '26Aug97 ASC Added
''
''      intDoIt = True                                                             '12sep01 CKJ Use flag instead of exit sub
''      If trimz$(GetField(IntersTbl!route1)) = trimz$(route1$) And trimz$(route1$) <> "" Then intDoIt = False  '27Aug97 CKJ Added
''      If trimz$(GetField(IntersTbl!route2)) = trimz$(route2$) And trimz$(route2$) <> "" Then intDoIt = False  '26Aug97 ASC Added
''
''      'If trimz$(route1$) = "Top." Or trimz$(route2$) = "Top." Then Exit Sub     '12sep01 CKJ made case insensitive, and
''      If LCase$(trimz$(route1$)) = "top." Then intDoIt = False                   '   "        use flag instead of exit sub
''      If LCase$(trimz$(route2$)) = "top." Then intDoIt = False
''
''      InteractionSeverity = GetField(IntersTbl!severity) + 1
''
''      '12sep01 CKJ Show warnings: none/level2/all (strShowWarnings = "" / "2" / "12")
''      If InStr(strShowWarnings, Format$(InteractionSeverity)) = 0 Then intDoIt = False
''
''      If intDoIt Then                                                            '12sep01 CKJ added
''         If Not nomessage Then
''            '12sep01 CKJ Pointless appending descriptions to chemicalx$ since these are not used subsequently
''            '            Therefore modified to build up the msg$ directly, keeping format similar to original
''            'If desc1$ <> "" Then chemical1$ = chemical1$ & " from " & desc1$ & "+" & CRLF
''            'If desc2$ <> "" Then chemical2$ = chemical2$ & " from " & desc2$
''            'If InteractionSeverity = 2 Then search$ = search$ & " (Potentially Serious)"
''            'msg$ = msg$ & " -  " & search$ & CRLF & GetField(IntersTbl!Text) & CRLF & CRLF
''
''            '12sep01 CKJ Block written, see above
''            msg$ = msg$ & " -  "
''            If desc1$ = "" And desc2$ = "" Then
''                  msg$ = msg$ & search$
''               Else
''                  msg$ = msg$ & chemical1$
''                  If desc1$ <> "" Then msg$ = msg$ & " from " & desc1$
''                  msg$ = msg$ & " +" & crlf
''
''                  msg$ = msg$ & chemical2$
''                  If desc2$ <> "" Then msg$ = msg$ & " from " & desc2$
''               End If
''            If InteractionSeverity = 2 Then msg$ = msg$ & crlf & " (Potentially Serious)"
''            msg$ = msg$ & crlf & GetField(IntersTbl!Text) & crlf & crlf
''         End If
''
''         If InteractionSeverity > severity Then severity = InteractionSeverity
''      End If
''   End If
''
''End Sub

''Sub checkPMRinteractions(newdrugonly%, ByVal chemical$, desc$, nomessage%, severity%, abort$, ByVal intIsProtocol As Integer)
'''16May97 ASC used to check any interactions against the interaction table.
'''08Aug96 ASC now checks for route and multiple chemical entities
'''13Aug97 ASC/CKJ checked and ready for testing
'''17Aug97 ASC tidied wording and corrected multiple allergy problem
'''25Aug97 ASC merged changes with 17Aug97 changes
'''26Jun98 ASC Added BNF code for therapeutic duplication checking
'''28Jul98 ASC Added cumulative dose
'''29Jul98 ASC noessage=2 means lokk in history
'''22Sep98 TH  Stop Chemicals interacting with themselves
'''12Feb99 JP  Added patient details to interactions/allergy details
'''24May99 CKJ Now always reads interact.mdb from App.Path
'''28May99 TH  Make sure checkallergy is fired even for one drug
'''28Mar01 TH  Moved Therapeutic Duplication call outside clauses to ensure it fires
'''12sep01 CKJ added protocol parameter
'''             True =  testing the potential addition of protocol items. Collect severity & messages
'''                     but don't display them
'''             False = normal use
'''            Allow suppression of warnings based on user requests.
'''            reduced NoMessage back to Boolean, as nomessage=2 is no longer used
'''            stores severity & message for use outside, when in Protocol mode
'''09oct01 CKJ Ensure stored severity increases but cannot decrease
'''25Oct01 TH/CKJ  Explicitly exclude history from interaction checks as previous     (#56346)
'''27Nov01 CKJ Abort Addition message now editable                                    (#57019)
'''            patmed.ini [Messages] MsgAbortAddProduct="multi-line[cr]prompt"
'''                                  MsgAbortAddProductDefault="N"    'optional, default is "Y"
''
'''If NewDrugonly Then checks the new drug added against the current medication otherwise checks
'''               all drugs against each other
'''   Chemical$   chemical name of new drug added (still in memory)
'''If Nomessage   then just checks greatest severity of interactions found used to set Traffic light (boolean)
'''   Severity    0=none found
'''               1=proceed with caution
'''               2=action required
'''   ans$        users response as to whether to abort addition of new drug
'''--------------------------------------------------------------------------------------
''
''Dim X%, msg$, Y%, z%, i%, n%, endmsg$, Numoflines%
''Dim dcop As DrugParameters
''Dim locallabf&
''Dim locall As WLabel
''Dim duped%, lngFound As Long
''Dim PatientName$                    '12Feb99 JP added
''Dim dob$                            '  "
''Dim strShowWarnings As String       '12sep01 CKJ added
''Dim strWarningMsg As String
''Dim intSeverity As Integer          '09oct01 CKJ
''Dim strMsg As String                '27Nov01 CKJ
''
''   'If Not fileexists(progsDRV$ & "\ascribe\interact.mdb") Then Exit Sub '30Jan98 ASC/EAC
''   If Not fileexists(AppPathNoSlash() & "\interact.mdb") Then Exit Sub   '24May99 CKJ Replaces progsDrv$
''
''   chemical$ = Trim$(chemical$)
''   If newdrugonly And chemical$ = "" Then Exit Sub
''   nomessage = (nomessage <> 0)    '12sep01 ckj reduce to Boolean
''
''   ReDim lines$(1 To 10)
''   'ReDim chems$(1 To 100, 0 To 2)
''   'ReDim chems$(1 To 100, 0 To 3) '26Jun98 ASC Added BNF code for therapeutic duplication checking
''   '                               '26Jul98 ASC declared dim in general
''   Erase chems$                    '28Jul98 ASC
''   z = 0
''   OpenInteractionDb True
''   IntersTbl.index = "Interactions"
''
''   '12Sep01 CKJ Added block
''   strShowWarnings = "12"                                      'default is to show level 1 and 2 warnings
''   If intIsProtocol Then
''         If TrueFalse(txtd(dispdata$ & "\ASCribe.ini", "PMRinteractions", "N", "AllowProtocolWarningSuppression", False)) Then
''               Select Case LCase(GetUserPreference(UserID$, "ShowProtocolWarnings", "all"))
''                  Case "all":       strShowWarnings = "12"
''                  Case "severity2": strShowWarnings = "2"
''                  Case "none":      strShowWarnings = ""
''                  Case Else:        strShowWarnings = "12"     'default is to show level 1 and 2 warnings
''                  End Select
''            End If
''      Else
''         If TrueFalse(txtd(dispdata$ & "\ASCribe.ini", "PMRinteractions", "N", "AllowNonProtocolWarningSuppression", False)) Then
''               Select Case LCase(GetUserPreference(UserID$, "ShowNonProtocolWarnings", "all"))
''                  Case "all":       strShowWarnings = "12"
''                  Case "severity2": strShowWarnings = "2"
''                  Case "none":      strShowWarnings = ""
''                  Case Else:        strShowWarnings = "12"     'default is to show level 1 and 2 warnings
''                  End Select
''            End If
''      End If
''
''   LSet dcop = d
''   For X = 1 To 50                    ' look at labrf&() for 1 to 50
''      'If labrf&(x) > 0 Or (nomessage = 2 And labrf&(x) < 0) Then                                 '12sep01 CKJ
''      'If labrf&(x) > 0 Or (nomessage And labrf&(x) < 0) Then
''''      If labrf&(X) > 0 Then       '25Oct01 TH/CKJ Explicitly exclude history from checks (as done in effect before as nomessage never set to 2) (#56346)
''If 0 = 1 Then     '**!!**
''''            locallabf& = labrf&(X)
''''            GetRecordNL r, Abs(locallabf&), labchan%, Len(locall)
''            LSet locall = r
''            d.SisCode = locall.SisCode
''            getdrug d, 0, lngFound, False
''            If lngFound Then
''                  duped = False
''                  If Trim$(d.chemical) = "" Then                                                  '31Jul98 ASC
''                        Numoflines = 1
''                        If InStr(d.Description, "!") > 0 Then
''                              d.chemical = Left$(d.Description, InStr(d.Description, "!") - 1)
''                           Else
''                              d.chemical = Left$(d.Description, InStr(d.Description, " ") - 1)
''                           End If
''                     End If
''                  For Y = 1 To z  'fill array with unique chemical entities
''                     'If chems$(y, 0) = "" Then Exit For
''                     If chems$(Y, 0) = Trim$(d.chemical) And chems$(Y, 5) = Trim$(d.DosingUnits) Then
''                           duped = True
''                           Exit For
''                        Else
''                           If chems$(Y, 0) = Trim$(d.chemical) Then 'duplicated chemical does not need another iteraction check but stored to display cumulative dose
''                                 chems$(Y, 6) = "Y"
''                              End If
''                        End If
''                  Next
''                  If Not duped Then
''                        deflines d.chemical, lines$(), ",", 1, Numoflines
''                        For n = 1 To Numoflines
''                           If z + 1 > UBound(chems$, 1) Then
''                                 'ReDim Preserve chems$(1 To z, 0 To 2)
''                                 popmessagecr "Interaction Check: WARNING", "More than 100 chemicals to check - only first 100 will be considered"
''                              Else
''                                 z = z + 1
''                                 chems$(z, 0) = Trim$(lines$(n))
''                                 chems$(z, 1) = Trim$(L.route)
''                                 'If numoflines > 1 Then chems$(z, 2) = Trim$(d.description) '26Jun98 ASC
''                                 desc$ = d.Description   '26Jun98 ASC
''                                 plingparse desc$, "!"   '    "
''                                 chems$(z, 2) = desc$    '    "
''                                 chems$(z, 3) = Trim$(d.bnf) '26Jun98 ASC Added BNF code for therapeutic duplication checking
''                                 If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
''                                       chems$(z, 4) = Format$(Val(chems$(Y, 4)) + (locall.Nodissued * d.dosesperissueunit))    '26Jul98 ASC
''                                    Else                                                                                       '    "
''                                       chems$(z, 4) = Format$(Val(chems$(Y, 4)) + locall.Nodissued)                            '    "
''                                    End If                                                                                     '    "
''                                 chems$(z, 5) = Trim$(d.DosingUnits)                             '      "
''
''                                 'If Not newdrugonly Then CheckAllergy lines$(n), pidextra.allergy, Msg$
''                                 'If Not newdrugonly Then CheckAllergy lines$(n), pidextra.allergy, Msg$
''                                 'If Not newdrugonly Then CheckAllergy lines$(n), pidextra.allergy, msg$   '26Jul98 ASC
''                                 If Not newdrugonly And chems$(Y, 6) <> "Y" Then CheckAllergy lines$(n), pidExtra.allergy, msg$  '26Jul98 ASC makes sure the allergy to a chemical is only checked and printed once
''                                 If msg$ <> "" Then severity = 2 'Allergy found '25Aug97 ASC
''                                 'Debug.Print d.chemical, z, lines$(n)
''                              End If
''                        Next
''                     Else      '26Jul98 ASC
''                        If (UCase$(Left$(d.PrintformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
''                              chems$(Y, 4) = Format$(Val(chems$(Y, 4)) + (locall.Nodissued * d.dosesperissueunit))    '26Jul98 ASC
''                           Else                                                                                       '    "
''                              chems$(Y, 4) = Format$(Val(chems$(Y, 4)) + locall.Nodissued)                            '    "
''                           End If                                                                                     '    "
''                     End If
''               End If
''         End If
''   Next
''   'If newdrugonly Then CheckAllergy d.chemical, pidextra.allergy, Msg$
''   'If newdrugonly Then CheckAllergy lines$(n), pidextra.allergy, msg$
''   'If msg$ <> "" Then msg$ = "ALLERGY WARNING" & CRLF & msg$ & CRLF: severity% = 2 'Allergy found
''   LSet d = dcop
''
''
''   'If Len(chemical$) > 0 And y > 0 Then        'Look to see if a chemical in memory has been sent
''   If Len(chemical$) > 0 Then    '28May99 TH Replaced Above so as to fire checkallergy if newdrugonly
''         deflines chemical$, lines$(), ",", 1, Numoflines   '17Aug97 ASC was starting at 0
''         For n = 1 To Numoflines
''            z = z + 1
''            chems$(z, 0) = lines$(n)
''            chems$(z, 1) = Trim$(L.route)
''            'If numoflines > 1 Then chems$(z, 2) = Trim$(desc$)  26Jun98 ASC
''            desc$ = d.Description   '26Jun98 ASC
''            plingparse desc$, "!"   '    "
''            chems$(z, 2) = desc$    '    "
''            chems$(z, 3) = Trim$(d.bnf) '26Jun98 ASC Added BNF code for therapeutic duplication checking
''            If Y > 0 Then            '28May99 TH  Prevent zero element in chems array
''                  chems$(z, 4) = Format$(Val(chems$(Y, 4)) + (L.Nodissued * d.dosesperissueunit))    '26Jul98 ASC
''               End If                '28May99 TH
''            chems$(z, 5) = Trim$(d.DosingUnits)                             '      "           '    "
''
''            If newdrugonly Then CheckAllergy lines$(n), pidExtra.allergy, msg$
''            If msg$ <> "" Then severity = 2 'Allergy found '25Aug97 ASC
''         Next
''      End If
''   If severity = 2 Then msg$ = "ALLERGIES FOUND: " & msg$ & crlf & String$(120, "-") & crlf & crlf '17Aug97 ASC
''   'If Msg$ <> "" Then severity = 2 'Allergy found
''
''   If newdrugonly Then
''         i = z - Numoflines + 1     'since the above IF... must have fired for us to get here
''                          '17Aug97 ASC added /Allergies
''         Editor.Caption = "Interactions/Allergies found when adding " & chemical$  'leave as chemical although not too elegant if a combination
''         endmsg$ = "Click Interaction button to show all interactions"
''      Else
''         i = 2            '17Aug97 ASC added /Allergies
''         Editor.Caption = "Interactions/Allergies found in current medication"
''      End If
''
''   For Y = z To i Step -1 'end of chemical list contains new drug either just look at this or look
''                          'at this against each of the other drugs in the list if looking for ANY interaction
''      'Debug.Print chems$(y, 0), y
''      For X = 1 To Y - 1
''         If chems$(X, 6) <> "Y" And chems$(Y, 6) <> "Y" Then '26Jul98 ASC
''               If chems$(X, 0) <> chems$(Y, 0) Then           '22Sep98 TH  Stop Chemicals interacting with themselves
''                     CheckInteraction (chems$(X, 0)), (chems$(Y, 0)), (chems$(X, 1)), (chems$(Y, 1)), (chems$(X, 2)), (chems$(Y, 2)), msg$, severity%, nomessage%, strShowWarnings
''                     'CheckTherapeuticDuplication (chems$(x, 0)), (chems$(y, 0)), (chems$(x, 1)), (chems$(y, 1)), (chems$(x, 2)), (chems$(y, 2)), (chems$(x, 3)), (chems$(y, 3)), msg$, severity%, nomessage% '26Jun98 ASC
''                     If severity = 2 And nomessage Then Exit For
''                  End If
''            End If                                        '    "
''         If InStr(strShowWarnings, "1") Then              '12sep01 CKJ Show duplication (level 1 warnings) if appropriate
''               CheckTherapeuticDuplication (chems$(X, 0)), (chems$(Y, 0)), (chems$(X, 1)), (chems$(Y, 1)), (chems$(X, 2)), (chems$(Y, 2)), (chems$(X, 3)), (chems$(Y, 3)), msg$, severity%, nomessage%  '28Mar01 TH Moved outside clauses to ensure it fires
''            End If
''      Next
''      If severity = 2 And nomessage Then Exit For
''   Next
''
''   'If msg$ <> "" And Not nomessage Then  '29Jul98 ASC
''   'If msg$ <> "" And Not nomessage And nomessage <> 2 Then '29Jul98 ASC    '12sep01 CKJ back to just a boolean
''
''   StoreSeverityAndMessage False, intSeverity, strWarningMsg                '24Sep01 CKJ read existing message
''   If msg$ <> "" Then                                       '29Jul98 ASC    '   "    separate building of message from display
''         strWarningMsg = strWarningMsg & crlf & crlf & msg$                 '   "    append new message
''         buildname pid, False, PatientName$
''         dob$ = pid.dob                                                                                                         '12Feb99 JP added
''         If Trim$(pid.dob) = "" Then dob$ = "Unknown"                                                                           '  "
''         msg$ = "Case Number : " & pid.caseno & crlf & "Name : " & PatientName$ & crlf & "DOB : " & dob$ & crlf & crlf & msg$   '  "
''      End If
''   If severity > intSeverity Then intSeverity = severity                    '09Oct01 CKJ Added
''   StoreSeverityAndMessage True, intSeverity, strWarningMsg                 '24Sep01 CKJ store severity & new message
''
''   'If msg$ <> "" And Not nomessage Then   '29Jul98 ASC                     '12sep01 CKJ back to just a boolean
''   If msg$ <> "" And Not nomessage And Not intIsProtocol Then  '29Jul98 ASC '12sep01 CKJ  "   '24sep01 CKJ non-protocol only
''         Editor.Txt1 = msg$ & crlf & crlf & endmsg$
''         Editor.LblCode = ""
''         Editor.cmdExit.default = True
''         Editor.Tag = ""
''         CentreForm Editor
''         Editor.Show 1
''         Unload Editor
''      End If
''
''   'If newdrugonly And severity = 2 Then                                      '24sep01 CKJ Question is asked in RxProtocol
''   If newdrugonly And severity = 2 And Not intIsProtocol Then                 '   "        if intProtocol is True
''         'Confirm "Logging your action", "abort addition of new drug", abort$, k                   '27Nov01 CKJ Message now editable
''         strMsg = "OK to abort addition of new product?"
''         strMsg = txtd(dispdata$ & "\patmed.ini", "Messages", strMsg, "MsgAbortAddProduct", 0)
''         abort$ = txtd(dispdata$ & "\patmed.ini", "Messages", "Y", "MsgAbortAddProductDefault", 0)
''         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
''         askwin "!Logging your action", strMsg, abort$, k
''
''         If k.escd Then abort$ = "Y"
''         If abort$ = "N" Then WriteLog dispdata$ & "\interact.log", SiteNumber, UserID$, msg$
''      End If
''
''End Sub

''Sub ScanCumulativeDose(DoHistory%)
''
''Dim X%, Y%, z%, i%, n%, Numoflines%
''Dim dcop As DrugParameters
''Dim locall As WLabel
''Dim duped%, lngFound As Long
''Dim UseChemical%, ptr%, maxitems%
''Dim desc$
''
''   ReDim lines$(1 To 10)
''
''   Erase chems$
''   maxitems = 0
''   LSet dcop = d
''   For X = 1 To 50                    ' look at labrf&() for 1 to 50
''''      If labrf&(X) > 0 Or (DoHistory And labrf&(X) < 0) Then
''If 0 = 1 Then     '**!!**
''''            GetRecordNL r, Abs(labrf&(X)), labchan%, Len(locall)
''            LSet locall = r
''            d.SisCode = locall.SisCode
''            getdrug d, 0, lngFound, False
''            If lngFound Then
''                  duped = False
''
''                  'Work out what kind of search will be needed for this drug
''                  deflines d.chemical, lines$(), ",", 1, Numoflines
''                  If Numoflines > 1 Or Trim$(d.chemical) = "" Or d.dosesperissueunit = 0 Or Trim$(d.DosingUnits) = "" Then
''                        UseChemical = False
''                     Else
''                        UseChemical = True
''                     End If
''
''                  'Search for either the drug or chemical in the array
''                  For ptr = 1 To maxitems
''                     If UseChemical Then
''                           If chems$(ptr, 0) = Trim$(d.chemical) And chems$(ptr, 5) = Trim$(d.DosingUnits) Then
''                                 duped = True
''                                 Exit For
''                              End If
''                        Else
''                           If chems$(ptr, 0) = Trim$(d.SisCode) Then
''                                 duped = True
''                                 Exit For
''                              End If
''                        End If
''                  Next
''
''                  If Not duped Then
''                        If maxitems + 1 > UBound(chems$, 1) Then
''                              popmessagecr "Interaction Check: WARNING", "More than 100 chemicals to check - only first 100 will be considered"
''                              Exit For
''                           Else
''                              maxitems = maxitems + 1
''                              If UseChemical Then
''                                    chems$(ptr, 0) = Trim$(d.chemical)
''                                    chems$(ptr, 2) = Trim$(d.chemical)
''                                    chems$(ptr, 5) = Trim$(d.DosingUnits)
''                                 Else
''                                    chems$(ptr, 0) = Trim$(d.SisCode)
''                                    desc$ = Trim$(d.Description)
''                                    plingparse desc$, "!"
''                                    chems$(ptr, 2) = desc$
''                                    If Trim$(d.DosingUnits) <> "" And d.dosesperissueunit <> 0 Then
''                                          chems$(ptr, 5) = Trim$(d.DosingUnits)
''                                       Else
''                                          chems$(ptr, 5) = Trim$(d.PrintformV)
''                                       End If
''                                 End If
''                           End If
''                     End If
''
''                  If Trim$(d.DosingUnits) <> "" And d.dosesperissueunit <> 0 Then
''                        chems$(ptr, 4) = Format$(Val(chems$(ptr, 4)) + (locall.Nodissued * d.dosesperissueunit))
''                     Else
''                        chems$(ptr, 4) = Format$(Val(chems$(ptr, 4)) + locall.Nodissued)
''                  End If
''               End If
''         End If
''   Next
''
''   LSet d = dcop
''
''End Sub

''Sub SetKineticsMonitoring(iStatus As Integer)
''
'''So that external progs can set the monitoring flag.
''
'''10jan00 AE
''
'''Status:
'''0 - No Monitoring
'''1 - Monitoring on
''
''
''   iKineticsMonitoring = iStatus
''
''End Sub

Function SetUserPreference(ByVal strUserID As String, ByVal strEntry As String, ByVal strValue As String) As Integer
'-------------------------------------------------------------------------------------
'12sep01 CKJ written
'            This looks up writes a user preference entry.
'            The individual user settings are stored in dispdata.###\userpref.ini
'            where the user ID is used as the section code.
'            This file is automatically maintained and is not to be edited manually.
'            Function returns success True/False
'            If the file, section or entry do not exist then they are created
'            If the userId or entry are blank then the success=false is returned
'            e.g.
'            [<UserIDcode>]
'            ShowProtocolWarnings = "All"
'-------------------------------------------------------------------------------------
Dim intSuccess As Integer

   If Len(Trim$(strUserID)) = 0 Or Len(Trim$(strEntry)) = 0 Then
         LogUserPreferenceChange strUserID, strEntry, "<COULD NOT STORE NEW SETTING OF '" & strValue & "'>"
         SetUserPreference = False
      Else
         LogUserPreferenceChange strUserID, strEntry, strValue
         WritePrivateIniFile strUserID, strEntry, strValue, dispdata$ & "\userpref.ini", intSuccess
         SetUserPreference = intSuccess
      End If

End Function

''Function AllergyMsg(ByVal chemical$) As String
'''14Jul97 CKJ Written
'''            text stream of the notes may contain the following (* = Chr160)
'''...<crlf>Allergy/Reaction Record*Chemical*dd/mm/ccyy hh:mm UID UserName<crlf>text over several lines*...
'''                                 ^-- snip out text from here ...   ...   ...   ...   ... to here --^
'''04Jun99 ASC Added to check for individual ingrediants where chemical may = *chemical1,chemical2,chemical3*
'''            Also moved to the drugchks module to improve encapsulation
''
''Dim txt$, strt%, posn1%, posn2%
''
''   txt$ = ""
''   strt = 1
''   Do
''      posn2 = 0
''      posn1 = 0
''      posn1 = InStr(strt, pidNotes.notes, Chr$(160) & chemical$ & Chr$(160))
''      If posn1 = 0 Then posn1 = InStr(strt, pidNotes.notes, "," & chemical$ & Chr$(160))             '04Jun99 ASC
''      If posn1 = 0 Then posn1 = InStr(strt, pidNotes.notes, "," & chemical$ & ",")                   '    "
''      If posn1 = 0 Then posn1 = InStr(strt, pidNotes.notes, Chr$(160) & chemical$ & ",")             '    "
''      If posn1 Then
''            'posn2 = InStr(posn1 + Len(chemical$) + 2, PIDNotes.notes, Chr$(160))                    '    "
''            posn2 = InStr(InStr(posn1 + 1, pidNotes.notes, Chr$(160)) + 1, pidNotes.notes, Chr$(160)) '    "
''            If posn2 Then                                    'after ch160 to before ch160
''                  txt$ = txt$ & crlf & crlf & Mid$(pidNotes.notes, posn1 + 1, posn2 - posn1 - 1)
''                  strt = posn2 + 1
''               End If
''         End If
''   Loop While posn2
''   AllergyMsg = txt$
''
''End Function

Function ChangeUserPreference(ByVal strUserID As String, ByVal strEntry As String) As Integer
'-------------------------------------------------------------------------------------
'12sep01 CKJ written
'            This allows a user to change a preference setting.
'            The individual user settings are stored in dispdata.###\userpref.ini
'            where the user ID is used as the section code.
'            Function returns success True/False/1 where 1 means the user escaped without change
'
'            The default section stores information about the settings
'            []
'            TEXT:ShowProtocolWarnings="description goes here with new lines as[cr]"
'            OPTS:ShowProtocolWarnings=3
'            OPT1:ShowProtocolWarnings="All|Show all warnings"
'            OPT2:ShowProtocolWarnings="Severity2|Show severe warnings only"
'            OPT3:ShowProtocolWarnings="None|Show no warnings"
'            DFLT:ShowProtocolWarnings=1
'
'            The TEXT:<strEntry> holds a paragraph of explanation, with embedded [CR] as desired.
'            The OPTS:<strEntry> must have an integer, the number of options which follow
'            For each option there must be an entry OPT<integer>:<strEntry> containing the code
'            If any are absent then success = false is returned.
'            Optionally displayable text can be appended separated by a single pipe character '|'
'            The DFLT:<strEntry> sets the option number of the default entry, if absent then option 1 is the default.
'            If the file, section or entry do not exist then they are created
'            If the userId or entry are blank then the success=false is returned
'-------------------------------------------------------------------------------------
Dim intSuccess As Integer
Dim strText As String
Dim strDefaultSection As String
Dim intOptions As Integer
Dim intloop As Integer
Dim strTemp As String
Dim intPosn As Integer
Dim strDefaultOption As String
Dim strChoice As String
Dim strUserPreference As String

   intSuccess = False
   If Len(Trim$(strUserID)) > 0 And Len(Trim$(strEntry)) > 0 Then
         strDefaultSection = "<DEFAULT>"
         strEntry = Trim$(strEntry)
         strText = GetUserPreference(strDefaultSection, "TEXT:" & strEntry, "(No description available)")
         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strText, False
         
         intOptions = Val(GetUserPreference(strDefaultSection, "OPTS:" & strEntry, "0"))
         strDefaultOption = GetUserPreference(strDefaultSection, "DFLT:" & strEntry, "1")
         strUserPreference = GetUserPreference(strUserID, strEntry, "")
         If intOptions > 0 Then
               intSuccess = True                              'now assume ok until proven otherwise
               ReDim strOptions(1 To 2, 1 To intOptions) As String     '(1,x) is the code, (2,x) is the description
               For intloop = 1 To intOptions
                  strTemp = GetUserPreference(strDefaultSection, "OPT" & Format$(intloop) & ":" & strEntry, "")
                  If strTemp = "" Then                        'setting is absent
                        intSuccess = False
                        Exit For
                     End If
                  strOptions(1, intloop) = strTemp            'code
                  strOptions(2, intloop) = strTemp            'description same as code at first
                  intPosn = InStr(strTemp, "|")
                  If intPosn Then                             'split code & description
                        strOptions(1, intloop) = Left$(strTemp, intPosn - 1)
                        strOptions(2, intloop) = Mid$(strTemp, intPosn + 1)
                     End If
                  If strOptions(1, intloop) = strUserPreference Then strDefaultOption = Format$(intloop)
               Next
            End If

         If intSuccess Then
               frmoptionset -1, "Amend User Preference"       'set for radio buttons
               frmoptionset -2, strText                       'set text prompt
               For intloop = 1 To intOptions
                  frmoptionset 1, strOptions(2, intloop)      'add a line
               Next
               frmoptionshow strDefaultOption, strChoice
               frmoptionset 0, ""                             'unload
               If Val(strChoice) = 0 Then
                     LogUserPreferenceChange strUserID, strEntry, "<CANCEL SELECTED>"
                     intSuccess = 1                           'escaped or timed out
                  Else
                     intSuccess = SetUserPreference(strUserID, strEntry, strOptions(1, Val(strChoice)))
                  End If
            End If
      End If

   ChangeUserPreference = intSuccess

End Function

